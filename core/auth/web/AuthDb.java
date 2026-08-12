package uz.uapp.auth;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Types;

/**
 * Thin JDBC bridge to CORE.AUTH_API.Validate_Session, used by AuthFilter's
 * bindContext() pattern (per-request session validation on the SAME pooled
 * connection the data layer uses for business SQL, so the UAPP context
 * loaded here is visible to subsequent DB work).
 * <p>
 * Values are passed via OUT bind variables (no JSON round-trip / no eval).
 */
public final class AuthDb {

	public static final class Result {
		public int code;
		public String msg;
		public long userId;

		public boolean ok() {
			return code == 0;
		}
	}

	public static Result validateSession(Connection cn, String token, String ip, String ua) throws Exception {
		String sql =
			"declare h Core.Hash_t := Core.Hash_t(); c number; m varchar2(400); o varchar2(4000); " +
				"begin h.Put('session_token',?); h.Put('client_ip',?); h.Put('user_agent',?); " +
				"Core.Auth_Api.Validate_Session(h,c,m,o); ?:=c; ?:=m; ?:=h.Get_Optional_Number('user_id'); end;";
		try (CallableStatement cs = cn.prepareCall(sql)) {
			cs.setString(1, token);
			cs.setString(2, ip);
			cs.setString(3, ua);
			cs.registerOutParameter(4, Types.NUMERIC);
			cs.registerOutParameter(5, Types.VARCHAR);
			cs.registerOutParameter(6, Types.NUMERIC);
			cs.execute();
			Result r = new Result();
			r.code = cs.getInt(4);
			r.msg = cs.getString(5);
			r.userId = cs.getLong(6);
			return r;
		}
	}

	private AuthDb() {
	}
}
