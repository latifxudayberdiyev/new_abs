package iabs;

//import java.text.*;

import java.util.*;
import java.io.*;
import java.sql.*;
//import oracle.sql.*;
import oracle.jdbc.driver.*;

public class oraAlert implements Runnable {
    private static boolean executing = false;
    private static boolean isThreadStopped = true;
    private static int timeOut = 600;
    private static java.util.Date lastDate;
    private static Hashtable hs = new Hashtable();
    private CallableStatement cs = null;
    private Statement st = null;
    private ResultSet rs = null;
    private static boolean isDBMSAlertRegistered = false;
    private static OutputStreamWriter logFile = null;
    private static boolean isWriteToSystemOut = true;
    private static String logURL = "c:\\alert_log.txt";
    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd.MM.yyyy hh:mm:ss");
    //Thread for fast job.
    private static Thread m_MultiTask = null;
    // db connection
    private OracleConnection connection = null;
    //username
    private static String userName;
    //password
    private static String userPassword;
    //server connection string
    private static String url;
    private static String callMessage = "begin"
            + "  dbms_alert.WaitOne('RS_DATA_UPDATED', ?, ?, ?);"
            + "end;";
    private static String query = "Select distinct t.To# From Magic_Messages t Where t.Type# = 1 and t.posted is null";

    //	private String query = "Select t.To#, '\t\t\t' || to_char(t.MDate,'dd.mm.yyyy hh24:mi:ss') || chr(13) || t.Text From Magic_Messages t Where t.Type# = 1 and t.posted is null Order By t.MDate";
    // �������� ����� ������, ��������� �������� ������� oracle �� ��������� ��������� ��� ������������� ������� �������.
    //		����� ��������� ��������� ��������� ������� ��������� �� ��������� ������ ���������
    //		 � ��� ����� ��������� ���������� � ��������� ��� ������� �� ����� �������������.
    private void execute() {
        if (m_MultiTask == null || !m_MultiTask.isAlive()) {
            printLog("Create new THREAD...");
            m_MultiTask = new Thread(this);
            printLog("Start new THREAD...");
            m_MultiTask.start();    //��������� �����.
            executing = true;
            printLog("New THREAD started.");
        } else {
            printLog("One THREAD already been started !!!");
        }
    }

    public void run() {    //����� ��� ���������� ������ ����� (����� �� ����, ���� ��������� ���������)
        isThreadStopped = false;
        lastDate = new java.util.Date();
        while (!isThreadStopped) {
            if (isConnected()) {
                try {
                    printLog("Calling dbms_alert.WaitOne() procedure...");
                    cs.execute();                    //����� ��������� �������� ��������� � ����������� �����
                    printLog("dbms_alert.WaitOne() procedure executed...");
                    printLog("Attemting to put messages...");
                    putMessages();        // �������� ������� ��������� � ������ ����� ��������� � ��������� ��� �������.
                    printLog("Putting mesages end.");
                } catch (Exception e) {
                    printLog("Exception in method run(): " + e.toString());
                    isThreadStopped = true;
                }
            } else {
                printLog("Cannot create connectin to database !!!");
                isThreadStopped = true;
            }
            //���� ������ ������ ���� ��������� � ����� �� �������� ���� ���������, �� ���������� ������ ������. (��� ����� �������)
            if ((new java.util.Date()).getTime() - lastDate.getTime() > timeOut * 2000) isThreadStopped = true;
        }
        closeAll();
        if (isWriteToSystemOut) printLog("Message checking stopped.");
        if (isWriteToSystemOut) printLog(".......................................");
        executing = false;
    }

    private void putMessages() {
        try {
            synchronized (this) {
                printLog("Executing query to get messages...");
                rs = st.executeQuery(query);
                printLog("Query executed.");
                int i = 0;
                while (rs.next()) {
                    i++;
                    hs.put(rs.getString(1), "New message recievied !");
                }
                printLog("Detecting and puting to hash table " + i + " messages.");
                rs.close();
                rs = null;
            }
        } catch (Exception e) {
            printLog("Exception in method putMessages(): " + e.toString());
            isThreadStopped = true;
        }
    }

    private boolean isConnected() {
        try {
            if (connection != null) return true;
            printLog("Attemting to get connection...");
            if (getConnection() == null)
                return false;                                        //������� ���������� ������� � ����.
            printLog("Connection create.");
            printLog("Register dbms_alert...");
            cs = connection.prepareCall("begin dbms_alert.Register('RS_DATA_UPDATED'); end;");    // ������������ � ������ ������ ��� �����.
            cs.execute();                                                                        //  (��������� ������ ���������)
            isDBMSAlertRegistered = true;
            printLog("dbms_alert registered.");
            cs.close();
            cs = connection.prepareCall(callMessage);                                                //������� ��������� � ������.
            cs.setInt(3, timeOut);                                        //������� ������� ������� ��������� ������.
            cs.registerOutParameter(1, Types.VARCHAR);                                        //���������. �� ������������.
            cs.registerOutParameter(2, Types.NUMERIC);                                        //��� ��������� (���� ��� ��� ����������� ���������). �� ������������.
            st = connection.createStatement();                                                    //������� Statement ��� ������������ ������������� ��� ������ � ��������.
            return true;
        } catch (Exception e) {
            printLog("Exception in method isConnectRestored(): " + e.toString());
            return false;
        }
    }

    private void closeAll() {
        if (isDBMSAlertRegistered) {    //���� �� ���������������� �����, �� ������� ��� �������.
            try {
                printLog("Remove alert....");
                cs = connection.prepareCall("begin DBMS_ALERT.REMOVE('RS_DATA_UPDATED'); end;");
                cs.execute();
                printLog("DBMS_ALERT removed successfuly.");
                isDBMSAlertRegistered = false;
            } catch (Exception e) {
                printLog("Cannot remove DBMS_ALERT :" + e.toString());
            }
        }
        printLog("Closing all....");
        String mes = "";
        try {
            mes = "CallableStatement";
            if (cs != null) cs.close();
            mes = "Statement";
            if (st != null) st.close();
            mes = "Connection";
            if (connection != null && !connection.isClosed()) connection.close();
            printLog("Connection closed.");
            if (logFile != null) {
                printLog("Closing alert_log...");
                mes = "logFile";
                logFile.close();
            }
        } catch (Exception e) {
            printLog("Cannot close " + mes + " :" + e.toString());
        } finally {
            connection = null;
        }
        if (isWriteToSystemOut) printLog("Stop wessage checking...");
    }

    private void printLog(String line) {
        line = (sdf.format(new java.util.Date())) + " " + line;
        if (isWriteToSystemOut)
            System.out.println(line);
        else {
            try {
                if (logFile == null) logFile = new OutputStreamWriter(new FileOutputStream(logURL, false), "Cp1251");
                logFile.write(line + "\n");
                logFile.flush();
            } catch (IOException e) {
                isWriteToSystemOut = true;
                printLog("Exception in method printLog: " + e.toString());
                printLog("Switch log to System.out");
            }
        }
    }

//////////////////////////////////////////////////////////////////////////

    /// //////////          Start and stop Messages checking    ///////////////
    public void start() {
        synchronized (this) {
            if (!executing) {
                printLog(".......................................");
                printLog("Attemting to start messages checking...");
                execute();
            } else {
                printLog("...Messages checking already started !");
                return;
            }
        }
        if (executing) printLog("Messages checking started.");
    }

    public void stop() {
        printLog("Attemting to stop messages checking...");
        synchronized (this) {
            isThreadStopped = true;
        }
        //if (executing) printLog("Messages checking cannot be stopped !!! (Sorry...)");
    }
//////////////////////////////////////////////////////////////////////////

    /// /////////////////     publick part for output messages   //////////////
    public boolean isExecuting() {
        return executing;
    }

    public boolean hasMessage(String empCode) {
        synchronized (lastDate) {
            lastDate = new java.util.Date();    //��������, ��� ���� ���������� ���������.
        }
        return (getMessage(empCode) != null);
    }

    public String getMessage(String empCode) {
        synchronized (lastDate) {    //��������, ��� ���� ���������� ���������.
            lastDate = new java.util.Date();
        }
        synchronized (hs) {
            String mess = (String) hs.get(empCode);
//			hs.remove(empCode);
            return (mess);
        }
    }

    public void removeMessage(String empCode) {
        synchronized (hs) {
            hs.remove(empCode);
        }
    }

    public void setLogToSystem() {
        isWriteToSystemOut = true;
    }

    public void setLogToFile() {
        isWriteToSystemOut = false;
    }

    public void setLogURL(String _logURL) {
        logURL = _logURL;
    }

    public String getLogURL() {
        return logURL;
    }

    public void setTimeOut(int _timeOut) {
        timeOut = _timeOut;
    }

    public int getTimeOut() {
        return timeOut;
    }
//////////////////////////////////////////////////////////////////////////

    /// /////////////////          Connection part      ///////////////////////
    /// ///////////////
    //set user name
    public void setUserName(String name) {
        this.userName = name;
    }

    /// ///////////////
    //get user name
    public String getUserName() {
        return this.userName;
    }

    /// /////////////////
    //set user Password
    public void setUserPassword(String password) {
        this.userPassword = password;
    }

    /// /////////////////
    //get user Password
    public String getUserPassword() {
        return this.userPassword;
    }

    /// ///////////////
    // set url
    public void setUrl(String url) {
        this.url = url;
    }

    /// ///////////////
    // get url
    public String getUrl() {
        return this.url;
    }

    /// ///////////////
    //get connection
    private OracleConnection getConnection() {
        if (connection != null) return connection;
        else return initConnection();
    }

    public OracleConnection initConnection() {
        try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            connection = (OracleConnection) DriverManager.getConnection
                    (url, userName, userPassword);
        } catch (SQLException exc) {
            printLog("Exception in method initConnection(): " + exc);
        }
        return connection;
    }
//////////////////////////////////////////////////////////////////////////

}
