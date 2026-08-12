package uz.crobs.esbin;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import uz.core.cms.CmsLogUtil;

/**
 * Stateless bearer-token HTTP gateway to CORE.ESBIN_GATEWAY for external
 * systems / mobile apps (inbound ESB). No HttpSession, no CSRF cookie - see
 * web.xml's /api/esbin/v1/* mapping and the CSRF/PageInitFilter exemptions
 * for this path.
 *
 * POST /api/esbin/v1/login   {"login","password"} -> access_token
 * POST /api/esbin/v1/logout  Bearer token -> 204 (always)
 * POST /api/esbin/v1/execute Bearer token + X-Esbin-Method-Code +
 *                            X-Esbin-Ext-Request-Id, body = raw request JSON
 */
public class EsbinGatewayServlet extends HttpServlet {

    private static final int MAX_BODY_BYTES = 1_000_000; // ~1MB, enough for a process-call JSON payload

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException, ServletException {
        try {
            String path = req.getPathInfo();
            if ("/login".equals(path)) {
                doLogin(req, res);
            } else if ("/logout".equals(path)) {
                doLogout(req, res);
            } else if ("/execute".equals(path)) {
                doExecute(req, res);
            } else {
                res.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            // Never leak exception detail to an external caller - log server-side only.
            CmsLogUtil.log(e);
            writeJson(res, 500, errorJson(-1, "Tizim xatosi"));
        }
    }

    private void doLogin(HttpServletRequest req, HttpServletResponse res) throws Exception {
        String body = readBody(req, res);
        if (body == null) {
            return; // 413 already sent
        }
        String login;
        String password;
        try {
            JsonObject json = new JsonParser().parse(body).getAsJsonObject();
            login = json.has("login") ? json.get("login").getAsString() : null;
            password = json.has("password") ? json.get("password").getAsString() : null;
        } catch (Exception e) {
            writeJson(res, 400, errorJson(-1, "Notog'ri so'rov"));
            return;
        }

        EsbinDb.LoginResult r = EsbinDb.login(login, password, clientIp(req));
        if (!r.ok()) {
            writeJson(res, 401, errorJson(r.code, r.msg));
            return;
        }
        JsonObject out = new JsonObject();
        out.addProperty("access_token", r.accessToken);
        out.addProperty("token_type", "Bearer");
        out.addProperty("expires_in", r.expiresIn);
        out.addProperty("partner_code", r.partnerCode);
        res.setHeader("Cache-Control", "no-store");
        writeJson(res, 200, out);
    }

    private void doLogout(HttpServletRequest req, HttpServletResponse res) throws Exception {
        String token = bearerToken(req);
        if (token != null) {
            EsbinDb.logout(token, clientIp(req));
        }
        // Logout always reports success per the PL/SQL design - nothing to surface.
        res.setStatus(HttpServletResponse.SC_NO_CONTENT);
    }

    private void doExecute(HttpServletRequest req, HttpServletResponse res) throws Exception {
        String token = bearerToken(req);
        if (token == null) {
            writeJson(res, 401, errorJson(-1, "Avtorizatsiya talab qilinadi"));
            return;
        }
        String methodCode = req.getHeader("X-Esbin-Method-Code");
        String extRequestId = req.getHeader("X-Esbin-Ext-Request-Id");
        if (methodCode == null || methodCode.isEmpty() || extRequestId == null || extRequestId.isEmpty()) {
            writeJson(res, 400, errorJson(-1, "X-Esbin-Method-Code / X-Esbin-Ext-Request-Id talab qilinadi"));
            return;
        }
        String body = readBody(req, res);
        if (body == null) {
            return; // 413 already sent
        }

        EsbinDb.ExecResult r = EsbinDb.execute(token, clientIp(req), methodCode, extRequestId, body);
        if (r.ok()) {
            res.setStatus(HttpServletResponse.SC_OK);
            res.setContentType("application/json; charset=UTF-8");
            res.setHeader("Cache-Control", "no-store");
            res.getWriter().write(r.response == null ? "" : r.response);
            return;
        }
        writeJson(res, httpStatusFor(r.code), errorJson(r.code, r.msg));
    }

    private static int httpStatusFor(int code) {
        switch (code) {
            case 401:
            case 403:
            case 404:
            case 409:
                return code;
            default:
                return 500;
        }
    }

    // ponytail: X-Forwarded-For is intentionally NOT trusted here - the proxy
    // topology in front of Tomcat isn't yet confirmed to be a TLS-terminating
    // proxy that overwrites that header, so trusting it would let any caller
    // forge their way past the IP-allowlist the PL/SQL side enforces. Extend
    // to trust X-Forwarded-For once a specific trusted-proxy IP set is
    // confirmed and hardcoded.
    private static String clientIp(HttpServletRequest req) {
        return req.getRemoteAddr();
    }

    private static String bearerToken(HttpServletRequest req) {
        String h = req.getHeader("Authorization");
        if (h == null || h.length() < 7 || !h.regionMatches(true, 0, "Bearer ", 0, 7)) {
            return null;
        }
        String token = h.substring(7).trim();
        return token.isEmpty() ? null : token;
    }

    // ponytail: cap applies both to a declared Content-Length over the limit
    // (fast fail) and to the actual bytes read (covers unknown/chunked
    // length) - security-review finding, no body-size cap on an
    // internet-facing endpoint.
    private static String readBody(HttpServletRequest req, HttpServletResponse res) throws IOException {
        int declared = req.getContentLength();
        if (declared > MAX_BODY_BYTES) {
            res.sendError(HttpServletResponse.SC_REQUEST_ENTITY_TOO_LARGE);
            return null;
        }
        byte[] buf = new byte[MAX_BODY_BYTES + 1];
        int total = 0;
        try (InputStream in = req.getInputStream()) {
            int n;
            while (total < buf.length && (n = in.read(buf, total, buf.length - total)) != -1) {
                total += n;
            }
        }
        if (total > MAX_BODY_BYTES) {
            res.sendError(HttpServletResponse.SC_REQUEST_ENTITY_TOO_LARGE);
            return null;
        }
        return new String(buf, 0, total, StandardCharsets.UTF_8);
    }

    private static void writeJson(HttpServletResponse res, int status, JsonObject json) throws IOException {
        res.setStatus(status);
        res.setContentType("application/json; charset=UTF-8");
        res.getWriter().write(json.toString());
    }

    private static JsonObject errorJson(int code, String msg) {
        JsonObject o = new JsonObject();
        o.addProperty("code", code);
        o.addProperty("msg", msg);
        return o;
    }
}
