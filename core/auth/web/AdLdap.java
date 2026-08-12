package uz.uapp.auth;

import java.util.Hashtable;
import javax.naming.Context;
import javax.naming.directory.InitialDirContext;

/**
 * Active Directory authentication via LDAPS bind.
 * <p>
 * SECURITY:
 * - LDAPS only (ldaps://, port 636). Plain ldap:// with a password is forbidden.
 * - UPN bind (user@DOMAIN) -> no DN search, minimal LDAP-injection surface.
 * - The password is used transiently for the bind, never stored or logged,
 * and is cleared right after use.
 * - On ANY failure return false (no reason leak to the caller / client).
 * <p>
 * Config (web.xml context-param or JNDI env):
 * - uapp.ad.url     e.g.  ldaps://dc01.bank.local:636
 * - uapp.ad.domain  e.g.  BANK.LOCAL
 */
public final class AdLdap {

	private AdLdap() {
	}

	public static boolean authenticate(String url, String domain,
	                                   String username, char[] password) {
		if (url == null || !url.toLowerCase().startsWith("ldaps://")) {
			// refuse to send a password over a non-TLS LDAP channel
			return false;
		}
		if (username == null || username.isEmpty() || password == null || password.length == 0) {
			return false;
		}
		if (domain == null || domain.trim().isEmpty()) {
			// uapp.ad.domain is not configured in web.xml
			return false;
		}
		// UPN: user@DOMAIN  (sanitize: keep only the bare account part)
		String account = username.trim();
		int at = account.indexOf('@');
		if (at >= 0) account = account.substring(0, at);
		// allow only safe account characters (defense in depth)
		if (!account.matches("[A-Za-z0-9._\\-]{1,64}")) {
			return false;
		}
		String principal = account + "@" + domain;

		Hashtable<String, Object> env = new Hashtable<String, Object>();
		env.put(Context.INITIAL_CONTEXT_FACTORY, "com.sun.jndi.ldap.LdapCtxFactory");
		env.put(Context.PROVIDER_URL, url);
		env.put(Context.SECURITY_PROTOCOL, "ssl");
		env.put(Context.SECURITY_AUTHENTICATION, "simple");
		env.put(Context.SECURITY_PRINCIPAL, principal);
		env.put(Context.SECURITY_CREDENTIALS, new String(password));
		env.put("com.sun.jndi.ldap.connect.timeout", "5000");
		env.put("com.sun.jndi.ldap.read.timeout", "5000");

		InitialDirContext ctx = null;
		try {
			ctx = new InitialDirContext(env);   // bind == authentication
			return true;
		} catch (Exception e) {
			return false;                       // invalid credentials or unreachable
		} finally {
			env.remove(Context.SECURITY_CREDENTIALS);
			if (ctx != null) {
				try {
					ctx.close();
				} catch (Exception ignore) {
				}
			}
		}
	}
}
