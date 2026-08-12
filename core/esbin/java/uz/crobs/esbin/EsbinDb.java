package uz.crobs.esbin;

import java.io.Reader;
import java.sql.CallableStatement;
import java.sql.Clob;
import java.sql.Connection;
import java.sql.Types;
import uz.core.cms.CmsLogUtil;
import uz.core.cms.Util;
import uz.core.sql.CoreDBConnection;

/**
 * Thin JDBC bridge to CORE.ESBIN_GATEWAY (Login/Logout/Execute_Request).
 *
 * Same shape as uz.crobs.auth.AuthDb: values pass via OUT bind variables
 * (no JSON round-trip / no eval) and login/logout go through a Core.Hash_t.
 * o_Code: 0=ok, non-zero=denied/error (see EsbinGatewayServlet's HTTP mapping).
 *
 * DB access: this project has no JNDI-pooled DataSource (verified - no
 * resource-ref anywhere in Tomcat conf or context.xml). Every JSP connects
 * via uz.core.sql.CoreDBConnection.initWalletConnection(...) (Oracle Wallet /
 * SEPS, same pattern as ibs/auth_login.jsp) - this bridge opens one such
 * wallet connection per call, matching that existing, working pattern rather
 * than a pool that doesn't exist in this deployment.
 */
public final class EsbinDb {

    private static Connection conn() throws Exception {
        String tnsAlias = Util.requiredConfig("CORE_DB_TNS_ALIAS");
        String walletLocation = Util.requiredConfig("CORE_DB_WALLET_LOCATION");
        String tnsAdmin = Util.requiredConfig("CORE_DB_TNS_ADMIN");
        CoreDBConnection cods = new CoreDBConnection();
        cods.initWalletConnection(tnsAlias, walletLocation, tnsAdmin);
        Connection c = cods.getConnection();
        if (c == null) {
            throw new IllegalStateException("ESBIN: DB connection (wallet) failed");
        }
        return c;
    }

    public static final class LoginResult {
        public int code;
        public String msg;
        public String accessToken;
        public long expiresIn;
        public String partnerCode;
        public boolean ok() { return code == 0; }
    }

    public static final class ExecResult {
        public int code;
        public String msg;
        public String response; // raw JSON from o_Response CLOB
        public boolean ok() { return code == 0; }
    }

    public static LoginResult login(String login, String password, String clientIp) throws Exception {
        String sql =
            "declare h Core.Hash_t := Core.Hash_t(); c number; m varchar2(400); o varchar2(4000); " +
            "begin h.Put('login',?); h.Put('password',?); h.Put('client_ip',?); " +
            "Core.Esbin_Gateway.Login(h,c,m,o); ?:=c; ?:=m; " +
            "?:=h.Get_Optional_Varchar2('access_token'); ?:=h.Get_Optional_Number('expires_in'); " +
            "?:=h.Get_Optional_Varchar2('partner_code'); end;";
        try (Connection cn = conn(); CallableStatement cs = cn.prepareCall(sql)) {
            cs.setString(1, login); cs.setString(2, password); cs.setString(3, clientIp);
            cs.registerOutParameter(4, Types.NUMERIC);
            cs.registerOutParameter(5, Types.VARCHAR);
            cs.registerOutParameter(6, Types.VARCHAR);
            cs.registerOutParameter(7, Types.NUMERIC);
            cs.registerOutParameter(8, Types.VARCHAR);
            cs.execute();
            LoginResult r = new LoginResult();
            r.code = cs.getInt(4); r.msg = cs.getString(5);
            r.accessToken = cs.getString(6); r.expiresIn = cs.getLong(7); r.partnerCode = cs.getString(8);
            return r;
        }
    }

    public static void logout(String accessToken, String clientIp) throws Exception {
        String sql =
            "declare h Core.Hash_t := Core.Hash_t(); c number; m varchar2(400); o varchar2(4000); " +
            "begin h.Put('access_token',?); h.Put('client_ip',?); " +
            "Core.Esbin_Gateway.Logout(h,c,m,o); end;";
        try (Connection cn = conn(); CallableStatement cs = cn.prepareCall(sql)) {
            cs.setString(1, accessToken); cs.setString(2, clientIp);
            cs.execute();
        }
    }

    public static ExecResult execute(String accessToken, String clientIp, String methodCode,
                                      String extRequestId, String requestJson) throws Exception {
        String sql =
            "begin Core.Esbin_Gateway.Execute_Request(i_Access_Token=>?, i_Client_Ip=>?, i_Method_Code=>?, " +
            "i_Request=>?, i_Ext_Request_Id=>?, o_Response=>?, o_Code=>?, o_Msg=>?, o_Ora_Msg=>?); end;";
        try (Connection cn = conn(); CallableStatement cs = cn.prepareCall(sql)) {
            cs.setString(1, accessToken);
            cs.setString(2, clientIp);
            cs.setString(3, methodCode);
            cs.setString(4, requestJson);
            cs.setString(5, extRequestId);
            cs.registerOutParameter(6, Types.CLOB);
            cs.registerOutParameter(7, Types.NUMERIC);
            cs.registerOutParameter(8, Types.VARCHAR);
            cs.registerOutParameter(9, Types.VARCHAR);
            cs.execute();
            ExecResult r = new ExecResult();
            r.code = cs.getInt(7);
            r.msg = cs.getString(8);
            r.response = clobToString(cs.getClob(6));
            // o_Ora_Msg: raw Oracle error text, server-side diagnostics ONLY.
            // Security-review finding: must never reach ExecResult / the caller.
            String oraMsg = cs.getString(9);
            if (oraMsg != null && !oraMsg.isEmpty()) {
                CmsLogUtil.log("ESBIN Execute_Request o_Ora_Msg=" + oraMsg
                    + " method=" + methodCode + " ext_request_id=" + extRequestId);
            }
            return r;
        }
    }

    private static String clobToString(Clob clob) throws Exception {
        if (clob == null) {
            return null;
        }
        try {
            StringBuilder sb = new StringBuilder();
            try (Reader reader = clob.getCharacterStream()) {
                char[] buf = new char[8192];
                int n;
                while ((n = reader.read(buf)) != -1) {
                    sb.append(buf, 0, n);
                }
            }
            return sb.toString();
        } finally {
            clob.free();
        }
    }

    private EsbinDb() {}
}
