package uz.uapp.auth;

import java.io.IOException;
import java.sql.Connection;
import javax.naming.InitialContext;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.sql.DataSource;

/**
 * Per-request session gate for protected resources.
 * <p>
 * - Reads the opaque UAPP_SID cookie.
 * - Calls CORE.AUTH_API.Validate_Session on a connection: slides the idle
 * window, enforces expiry, and loads the UAPP application context.
 * - On failure: 401 + JSON, no detail leak.
 * <p>
 * IMPORTANT (connection pooling): UAPP is a session-scoped DB context.
 * It must be (re)loaded on the SAME pooled connection the request later uses
 * for business SQL. The cleanest integration is for the data-access layer to
 * call AuthDb.validateSession(workingConn, token, ip, ua) at the start of its
 * unit of work. This filter is the security gate; bindContext() below is the
 * helper the data layer should call with its own connection.
 */
public class AuthFilter implements Filter {

	private static final String DS = "java:comp/env/jdbc/UAPP";

	public void init(FilterConfig c) {
	}

	public void destroy() {
	}

	public static String tokenFromCookie(HttpServletRequest req) {
		if (req.getCookies() == null) return null;
		for (Cookie ck : req.getCookies()) {
			if ("UAPP_SID".equals(ck.getName())) return ck.getValue();
		}
		return null;
	}

	/**
	 * Comma-separated exact IPs of reverse proxies allowed to set X-Forwarded-For.
	 * Unset (default) = never trust X-Forwarded-For, always use the socket's
	 * remote address.
	 */
	private static final String TRUSTED_PROXIES_ENV = "AUTH_TRUSTED_PROXIES";

	private static boolean isTrustedProxy(String remoteAddr) {
		String trusted = System.getenv(TRUSTED_PROXIES_ENV);
		if (trusted == null || trusted.isEmpty()) return false;
		for (String ip : trusted.split(",")) {
			if (ip.trim().equals(remoteAddr)) return true;
		}
		return false;
	}

	private static String clientIp(HttpServletRequest req) {
		String remoteAddr = req.getRemoteAddr();
		if (isTrustedProxy(remoteAddr)) {
			String xff = req.getHeader("X-Forwarded-For");
			if (xff != null && !xff.isEmpty()) {
				String[] hops = xff.split(",");
				String nearestHop = hops[hops.length - 1].trim();
				if (!nearestHop.isEmpty()) return nearestHop;
			}
		}
		return remoteAddr;
	}

	private static final String UNSAFE_METHODS = "POST|PUT|PATCH|DELETE";

	private static boolean sameOriginAsRequest(HttpServletRequest req) {
		String host = req.getHeader("Host");
		if (host == null) return false;
		String origin = req.getHeader("Origin");
		String sourceUrl = origin;
		if (sourceUrl == null || sourceUrl.isEmpty()) sourceUrl = req.getHeader("Referer");
		if (sourceUrl == null || sourceUrl.isEmpty()) return false;
		String sourceHost = sourceUrl.replaceFirst("^[a-zA-Z][a-zA-Z0-9+.-]*://", "");
		int slash = sourceHost.indexOf('/');
		if (slash >= 0) sourceHost = sourceHost.substring(0, slash);
		return sourceHost.equalsIgnoreCase(host);
	}

	/**
	 * Data layer calls this with the connection it will use for business SQL.
	 */
	public static long bindContext(Connection cn, HttpServletRequest req) throws Exception {
		String token = tokenFromCookie(req);
		if (token == null) return -1;
		AuthDb.Result r = AuthDb.validateSession(cn, token, clientIp(req),
			req.getHeader("User-Agent"));
		return r.ok() ? r.userId : -1;
	}

	public void doFilter(ServletRequest sreq, ServletResponse sres, FilterChain chain)
		throws IOException, ServletException {
		HttpServletRequest req = (HttpServletRequest) sreq;
		HttpServletResponse res = (HttpServletResponse) sres;
		if (req.getMethod().matches(UNSAFE_METHODS) && !sameOriginAsRequest(req)) {
			res.setStatus(HttpServletResponse.SC_FORBIDDEN);
			res.setContentType("application/json; charset=UTF-8");
			res.setHeader("Cache-Control", "no-store");
			res.getWriter().write("{\"code\":2,\"msg\":\"origin\"}");
			return;
		}
		String token = tokenFromCookie(req);
		boolean ok = false;
		if (token != null) {
			try {
				DataSource ds = (DataSource) new InitialContext().lookup(DS);
				try (Connection cn = ds.getConnection()) {
					AuthDb.Result r = AuthDb.validateSession(
						cn, token, clientIp(req), req.getHeader("User-Agent"));
					if (r.ok()) {
						req.setAttribute("uapp.user_id", r.userId);
						ok = true;
					}
				}
			} catch (Exception e) {
				ok = false;
			}
		}
		if (!ok) {
			res.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
			res.setContentType("application/json; charset=UTF-8");
			res.setHeader("Cache-Control", "no-store");
			res.getWriter().write("{\"code\":1,\"msg\":\"session\"}");
			return;
		}
		chain.doFilter(sreq, sres);
	}
}
