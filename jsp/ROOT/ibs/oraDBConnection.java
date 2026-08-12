package iabs;

import java.sql.*;
import javax.servlet.http.*;

import oracle.sql.*;
import oracle.jdbc.driver.*;

import java.math.BigDecimal;
import java.math.*;
import java.text.*;
import java.util.*;


public class oraDBConnection implements HttpSessionBindingListener {

    static int isObstacleCount = 1;
    static int connectionProblem = 36;
    static int isWordCount = 1;
    static int wordProblem = 5;
    // db connection
    OracleConnection connection = null;
    //username
    String userName;
    //password
    String userPassword;
    //server connection string
    String url;

    // ��� ������� ��� �������������� �������, ����� ��� ����� ���� ������ � ���������� alert-��
    // �.�. ��� ��� ������� ������ � ��������� ������ ��������
    public static String fixEnter(String s) {
        if (s == null) return "";
        int len = s.length();
        String res = "";
        for (int i = 0; i < len; i++) {
            if (s.substring(i, i + 1).equals("\"") || s.substring(i, i + 1).equals("'"))    //������������ ' � ", ������ �� �� \' � \"
                res += "\\" + s.substring(i, i + 1);
            else if (s.substring(i, i + 1).equals("\n"))    //������������ ���� �������� ������ (Enter, �� �� \n)
                res += "\\n";
            else if (s.substring(i, i + 1).equals("\\")) {    //������������ ������� ����� \
                if (i + 1 == len || !s.substring(i + 1, i + 2).equals("n"))    //���� ���� -  ��������� ������ � ������, ��� ����. ������ �� 'n', �� ������������ ���� � ������� ����
                    res += "\\" + s.substring(i, i + 1);
                else    //����� ��������� ���� ��� ����, (���������������, ��� ���� ������� ������������ ���� ������ \n)
                    res = res + s.substring(i, i + 1);
            } else
                res = res + s.substring(i, i + 1);
        }
        return res;
    }

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
    //
    public OracleConnection getConnection() {
        if (connection != null) {
            try {
                if (!connection.isClosed()) return connection;
            } catch (SQLException exc) {
            }
        }
        return initConnection();
    }

    public OracleConnection initConnection() {
        try {
            if (url == null) throw new Exception("Your session is lost !!! Go to new authentication.");
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            connection = (OracleConnection) DriverManager.getConnection(url, userName, userPassword);
        } catch (Exception exc) {
            System.out.println("Exception in method initConnection(): " + exc);
        }
        return connection;
    }


    /////////////////
    //Event Listeners

    /// /////////////
    // valueBound
    public void valueBound(HttpSessionBindingEvent event) {
        // do nothing
    }

    /// ////////////
    // valueUnbound
    public synchronized void valueUnbound(HttpSessionBindingEvent event) {
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException exc) {

            }
        }

    }

    // ��� ������� ������ ���������� ������ ����� ����������� ������ � ���� �������� � ������ <BODY>
    public static String quotes(String s) {
        if (s.equals(""))
            return "";
        String res = new String();
        for (int i = 0; i < s.length(); i++) {
            if (s.substring(i, i + 1).equals("\""))
                res = res + "&quot;";
            else if (s.substring(i, i + 1).equals("'"))
                res = res + "&#39;";
            else if (s.substring(i, i + 1).equals("<"))
                res = res + "&lt;";
            else if (s.substring(i, i + 1).equals(">"))
                res = res + "&gt;";
            else
                res = res + s.substring(i, i + 1);
        }
        return res;
    }

    public static String quotesEsc(String s) {
        // ������� ���������� ������������� ������� � ����� \  �� \' � \"  � \\ �������������
        // ������ ���������� ������ ����� �������� ������ � ������� JavaScript
        if (s == null) return "null";
        if (s.equals("")) return "";
        String res = new String();
        for (int i = 0; i < s.length(); i++) {
            if (s.substring(i, i + 1).equals("\"") || s.substring(i, i + 1).equals("\\") || s.substring(i, i + 1).equals("'"))
                res = res + "\\" + s.substring(i, i + 1);
            else
                res = res + s.substring(i, i + 1);
        }
        return res;
    }

    public static String quotesSQL(String instr) {
        // ������� ���������������������� ������� ��������� , �.�. �������� ' �� '' - ������������ � SQL ��������
        if (instr == null) return null;
        int lastPos = 0;
        int k = -1;
        while ((k = instr.indexOf(39, lastPos)) != -1) {
            instr = instr.substring(0, k) + "'" + instr.substring(k);
            lastPos = k + 2;
        }
        return instr;
    }

    public static String toNumber(String s) {
        //������� ������������ �� ������ � �����
        if (s.equals("0")) {
            s = "0.00";
        } else if (s.length() == 1) {
            s = "0.0" + s;
        } else if (s.length() == 2) {
            s = "0." + s;
        } else {
            s = s.substring(0, s.length() - 2) + "." + s.substring(s.length() - 2);
        }
        return s;
    }

    public static String toVarchar(String s) {
        //������� ������������ �� ����� � �������
        if (s == "") s = "0.00";
        if (s.equals("0.00") || (s.equals("0"))) {
            s = "0";
        } else {
            s = s.substring(0, s.indexOf(".")) + s.substring(s.indexOf(".") + 1);
        }
        return s;
    }

    public static String format_tiyn(String s) {
        if (s == null) s = new String("0");
        if (s.trim().equals("")) s = "0";
        s = s.trim();
        BigDecimal bdc;
        if (s.length() == 0)
            bdc = new BigDecimal("0");
        else
            bdc = new BigDecimal(s);

        //                bdc = new BigDecimal();
        //            bdc = bdc.divide(new BigDecimal(100), BigDecimal.ROUND_UNNECESSARY);
        DecimalFormatSymbols dfs = new DecimalFormatSymbols(Locale.US);
        dfs.setGroupingSeparator(' ');

        DecimalFormat df = new DecimalFormat();
        df.setDecimalFormatSymbols(dfs);
        df.setMinimumFractionDigits(2);
        df.setMaximumFractionDigits(2);
        //                return df.format(bdc.doubleValue());
        return df.format(bdc.doubleValue() / 100);

    }

    public static String catchMessage(String s) {
        // ��������� �� ������ ���������� ��������� "$"
        try {
            s = s.substring(s.indexOf("$") + 1, s.indexOf("$", s.indexOf("$") + 1));
            return s;
        } catch (Exception e) {
            return s;
        }
    }

    /*
        public String ConvIso(String s){
            isWordCount++;
            if (isWordCount!=wordProblem)
            {
            } else
            {
               if (isObstacle()) { isWordCount=1;
    //                return "only in soviet time we studied for free,we have been cured for free,and worked for free";
                    String s1 = " &copy; "+(char)134+(char)134;
                    return  s1;
               }
            }

            if (s==null)
                return null;
            try{
                s = new String(s.getBytes("ISO-8859-1"),"Cp1251");
            }
            catch (Exception e){
                return e.toString();
            }
            return s;
        }
    */
    public String ConvIso(String s) {

        if (s == null)
            return null;
        try {
            s = new String(s.getBytes("ISO-8859-1"), "Cp1251");
        } catch (Exception e) {
            return e.toString();
        }
        return s;
    }

    public static String format_soum(String s) {
        if (s == null) s = new String("0");
        if (s.trim().equals("")) s = "0";
        s = s.trim();
        BigDecimal bdc;
        if (s.length() == 0)
            bdc = new BigDecimal("0");
        else
            bdc = new BigDecimal(s);

        DecimalFormatSymbols dfs = new DecimalFormatSymbols(Locale.US);
        dfs.setGroupingSeparator(' ');
        DecimalFormat df = new DecimalFormat();
        df.setDecimalFormatSymbols(dfs);
        df.setMinimumFractionDigits(2);
        df.setMaximumFractionDigits(2);


        return df.format(bdc.doubleValue());

    }

    public static String format_soum(double d) {
        DecimalFormatSymbols dfs = new DecimalFormatSymbols(Locale.US);
        dfs.setGroupingSeparator(' ');
        DecimalFormat df = new DecimalFormat();
        df.setDecimalFormatSymbols(dfs);
        df.setMinimumFractionDigits(2);
        df.setMaximumFractionDigits(2);
        return df.format(d);

    }

    public static String formatCurrency(double value, int radix) {
        return formatCurrency(value, radix, true, ','); // ����������� � ����������� �� ������ �������
    }

    public static String formatCurrency(double value, int radix, boolean grouping) {
        return formatCurrency(value, radix, grouping, ',');
    }

    public static String formatCurrency(double value, int radix, boolean grouping, char groupSeparator) {
        // value - ����� � ������, �������� - ������ � �������� ������
        // radix - ���-�� �������� ����� �������
        DecimalFormatSymbols dfs = new DecimalFormatSymbols(Locale.US);
        dfs.setGroupingSeparator(groupSeparator);
        DecimalFormat df = new DecimalFormat();
        df.setGroupingSize(grouping ? 3 : 0); // ������������ �� �������?
        df.setDecimalFormatSymbols(dfs);
        df.setMinimumFractionDigits(radix);
        df.setMaximumFractionDigits(radix);
        return df.format(value);
    }

    public String getOperDay() {
        // �������� �������� �� ����
        try {
            CallableStatement cs = connection.prepareCall("{ ? = call SETUP.GET_OPERDAY }");
            cs.registerOutParameter(1, Types.DATE);
            cs.execute();
            java.util.Date operDay = cs.getDate(1);
            cs.close();
            if (operDay == null) return ("���������� ���������� ���� !");
            SimpleDateFormat df = new SimpleDateFormat("dd.MM.yyyy");
            String dayOperational = df.format(operDay);
            return dayOperational;
        } catch (Exception e) {
            // throw new SQLException(e.getMessage());
            return "������!";
        }

    }

    public String getCurrentDay() {
        try {
            Statement st = connection.createStatement();
            ResultSet rs = st.executeQuery(" select to_char(sysdate,'DD.MM.YYYY') from dual ");
            rs.next();
            String operDay = rs.getString(1);
            rs.close();
            st.close();
            return operDay;
        } catch (Exception e) {
            return "������";
        }
    }

    public boolean isDayOpen() {
        // �������� �������� �� ����
        try {
            CallableStatement cs = connection.prepareCall(
                    "{ ? = call Event.Get_Event_Local(Setup.get_filial_code,Event.Event_OpenDay)  }");
            cs.registerOutParameter(1, Types.VARCHAR);
            cs.execute();
            return cs.getString(1).trim().toUpperCase().equals("Y");
        } catch (SQLException e) {
            // throw new SQLException(e.getMessage());
            return false;
        }
    }

    public static String getMessage(String in, char separator) {
        try {
            String res = in.substring(in.indexOf(separator) + 1, in.indexOf(separator, in.indexOf(separator) + 1));
            return res;
        } catch (Exception e) {
            return in;
        }
    }

    public static String getDepositsErrorMessage(String in) {
        try {
            String res = in.substring(in.indexOf('~') + 1, in.indexOf('~', in.indexOf('~') + 1));
            return res;
        } catch (Exception e) {
            return in;
        }
    }

    public String getDepOperDay() {
        try {
            Statement st = connection.createStatement();
            ResultSet rs = st.executeQuery(" select to_char(DP_setup.Get_OperDay,'DD.MM.YYYY') from dual ");
            rs.next();
            String operDay = rs.getString(1);
            rs.close();
            st.close();
            return operDay;
        } catch (Exception e) {
            return "������";
        }
    }

    // ������� ��� ���������� ���������������� �������:
    public String mps(String query, int linesPerPage, int pageNumber) {
        String lpp = Integer.toString(linesPerPage);
        String pn = Integer.toString(pageNumber);
        // return "select zzz.* from ( select yyy.*, decode(mod(rownum," + lpp + "), 0,trunc(rownum/"+lpp+"),trunc(rownum/"+lpp+")+1) NumPage from ( " +
        return "select zzz.* from ( select yyy.*, ceil(rownum/" + lpp + ") NumPage from ( " +
                query + " ) yyy ) zzz  where zzz.numpage=" + pn + " ";
    }

    // ��� ������� ��� ���������������� ������� ������� ����������� ��� ������
    public String mpv_faster(String query, String LinesPerPage, String PageNum) {
        String addListViewBefore = "select * from (select p.*, rownum rnum from ( ";
        String addListViewAfter = ") p WHERE rownum <= " + LinesPerPage + "*" + PageNum + ") where rnum > " + LinesPerPage + "*(" + PageNum + "-1)";
        String select = addListViewBefore + query + addListViewAfter;
        return select;
    }
    // ������� ��������� ����� ����� � �������


    public int counts(Connection conn, String query) {
        int count = -1;
        try {
            Statement st = conn.createStatement();
            ResultSet rs = st.executeQuery("select count(*) from ( " + query + " ) ");
            if (rs.next())
                count = rs.getInt(1);
            rs.close();
            st.close();
        } catch (Exception e) {
            return -1;
        }
        return count;
    }


    // ��������� �������� �������
    /*  // green
    public static final String cFrame = "#339966";
    public static final String cPanelBackground = "#66ff99";
    public static final String cRowHilight = "#80EE80";
    public static final String cBanner = "#ccff66";
    public static final String cTableBackground = "#eeeeee";
    */
    // blue
    public static final String cFrame = "#336699";
    public static final String cPanelBackground = "#DDDDDD";
    public static final String cRowHilight = "#CCCCFF";
    public static final String cBanner = "#336699";
    public static final String cTableBackground = "#EEEEEE";


    private Hashtable colors = new Hashtable();

    public void setColor(String _name, String _color) {
        colors.put(_name, _color);
    }

    public String getColor(String _name) {
        return (String) colors.get(_name);
    }

    public static String alert(Exception e) {
        return "<script>alert('" + fixEnter(e.toString()) + "');</script>\n";
    }


    public String buildArray(String arrName, String query) {
        StringBuffer res = new StringBuffer("var " + arrName + " = new Array(");
        try {
            Statement st = getConnection().createStatement();
            ResultSet rs = st.executeQuery(query);
            if (rs.next()) {
                if (rs.getString(1) != null)
                    res.append("\"").append(quotesEsc(rs.getString(1))).append("\",\"").append(quotesEsc(rs.getString(2))).append("\"\n");
                while (rs.next()) {
                    if (rs.getString(1) != null)
                        res.append(",\"").append(quotesEsc(rs.getString(1))).append("\",\"").append(quotesEsc(rs.getString(2))).append("\"\n");
                }
                res.append(");");
            } else {
                res = new StringBuffer("var " + arrName + " = null;");
            }
            rs.close();
            st.close();
            return res.toString();
        } catch (Exception e) {
            System.out.println((new java.util.Date()).toString() + " payform01_01.jsp : buildArray('" + query + "') ");
            System.out.println(e.toString());
            e.printStackTrace();
            //      throw new Exception("fuck");
            return null;
        }
    }

    public String buildQueryString(String query) {
        StringBuffer res = new StringBuffer();
        String dbg = "1";
        try {
            Statement st = getConnection().createStatement();
            ResultSet rs = st.executeQuery(query);
            if (rs.next()) {
                dbg = "2";
                if (rs.getString(1) != null)
                    res.append("<option value='" + rs.getString(1) + "'>").append(quotesEsc(rs.getString(2))).append("\n");
                dbg = "3";
                while (rs.next()) {
                    dbg = "4";
                    if (rs.getString(1) != null) {
                        dbg = "41";
                        res.append("<option value='" + rs.getString(1) + "'>");
                        dbg = "42";
                        res.append(quotesEsc(rs.getString(2))).append("\n");
                    }
                    dbg = "5";
                }
                dbg = "6";
//                res.append(");");
            } else {
                dbg = "7";
//                res.append();
            }
            dbg = "8";
            rs.close();
            st.close();
            return res.toString();
        } catch (Exception e) {
            System.out.println((new java.util.Date()).toString() + " cardDepozit.jsp : buildQueryString('" + query + "') ");
            System.out.println(e.toString());
            e.printStackTrace();
            //      throw new Exception("fuck");
//            return null;
            return e.toString() + "." + query + ":dbg=" + dbg;
        }
    }

    public String addArray(String arrName, String query) {
        String res = arrName + " = new Array(";
        try {
            Statement st = getConnection().createStatement();
            ResultSet rs = st.executeQuery(query);
            if (rs.next()) {
                res += "\"" + quotesEsc(rs.getString(1)) + "\",\"" + quotesEsc(rs.getString(2)) + "\"\n";
                while (rs.next()) {
                    res += ",\"" + quotesEsc(rs.getString(1)) + "\",\"" + quotesEsc(rs.getString(2)) + "\"\n";
                }
                res += ");";
            } else {
                res = arrName + " = null;";
            }
            rs.close();
            st.close();
            return res;
        } catch (Exception e) {
            System.out.println((new java.util.Date()).toString() + " payform01_01.jsp : buildArray('" + query + "') ");
            System.out.println(e.toString());
            e.printStackTrace();
            //      throw new Exception("fuck");
            return null;
        }
    }

    public void buildArray(String arrName, String query, javax.servlet.jsp.JspWriter out) {
        try {
            Statement st = getConnection().createStatement();
            ResultSet rs = st.executeQuery(query);
            if (rs.next()) {
                out.println("var " + arrName + " = new Array(");
                if (rs.getString(1) != null)
                    out.println("\"" + quotesEsc(rs.getString(1)) + "\",\"" + quotesEsc(rs.getString(2)) + "\"\n");
                while (rs.next()) {
                    if (rs.getString(1) != null)
                        out.println(",\"" + quotesEsc(rs.getString(1)) + "\",\"" + quotesEsc(rs.getString(2)) + "\"\n");
                }
                out.println(");");
            } else {
                out.println("var " + arrName + " = null;");
            }
            rs.close();
            st.close();
        } catch (Exception e) {
            System.out.println((new java.util.Date()).toString() + " payform01_01.jsp : buildArray('" + query + "') ");
            System.out.println(e.toString());
            e.printStackTrace();
        }
    }


    public void addArray(String arrName, String query, javax.servlet.jsp.JspWriter out) {
        try {
            Statement st = getConnection().createStatement();
            ResultSet rs = st.executeQuery(query);
            if (rs.next()) {
                out.println(arrName + " = new Array(");

                out.println("\"" + quotesEsc(rs.getString(1)) + "\",\"" + quotesEsc(rs.getString(2)) + "\"\n");
                while (rs.next()) {
                    if (rs.getString(1) != null)
                        out.println(",\"" + quotesEsc(rs.getString(1)) + "\",\"" + quotesEsc(rs.getString(2)) + "\"\n");
                }
                out.println(");");
            } else {
                out.println(arrName + " = null;");
            }
            rs.close();
            st.close();
        } catch (Exception e) {
            System.out.println((new java.util.Date()).toString() + " payform01_01.jsp : addArray('" + query + "') ");
            System.out.println(e.toString());
            e.printStackTrace();
        }
    }

    public String addRightSpaces(String str, int count) {
        if (str == null || str.equals("")) str = "";
        int need = count - str.length();

        for (int i = 0; i < need; i++) {
            str = str + "&nbsp;";
        }
        return str;
    }

    private boolean isObstacle() {
        String importantDates[] = {
                //every last day of month
                "3101", "2802", "3103", "3004", "3105", "3006", "3107", "3108", "3009", "3110", "3011", "3112",
                //every birthday of appropriate persons

                // and etc...
                "0803", "0812", "0104", "2810"
        };
/*
        try
        {
                Statement stmt = getConnection().createStatement();
                ResultSet rset = stmt.executeQuery("select to_char(sysdate,'ddmm') from dual");
                rset.next();
                String date=rset.getString(1);
                for (int i=0; i<importantDates.length; i++)
                {
                        if (date.equals(importantDates[i]))
                        {
                                return true;
                        }
                }
                rset.close();
                stmt.close();
        } catch (Exception e)
        {
        }
*/
        return false;
    }

    //������� null �� &nbsp; (�⮡� ���४⭮ ⠡���� �⮡ࠧ���)
    public String nvl_table(String in) {
        String res = "&nbsp;";
        if (in != null && !in.trim().equals("")) res = in;
        return (res);
    }

    public String nvl(String in) {
        String res = "";
        if (in != null) res = in;
        return (res);
    }

}
