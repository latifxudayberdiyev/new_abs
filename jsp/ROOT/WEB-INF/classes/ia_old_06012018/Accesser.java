/*    */ package ia;
/*    */ 
/*    */ import java.io.IOException;
/*    */ import java.sql.CallableStatement;
/*    */ import java.sql.Connection;
/*    */ import java.sql.SQLException;
/*    */ import java.util.logging.Level;
/*    */ import java.util.logging.Logger;
/*    */ import javax.servlet.http.HttpServletResponse;
/*    */ 
/*    */ public class Accesser
/*    */ {
/*    */   private static Connection con;
/*    */ 
/*    */   public static boolean hasForm(int formId)
/*    */   {
/* 24 */     CallableStatement cs = null;
/*    */     try {
/* 26 */       cs = con.prepareCall("{? = call Ia_Api.Check_Form(" + formId + ") }");
/* 27 */       cs.registerOutParameter(1, 12);
/* 28 */       cs.execute();
/* 29 */       boolean bool = cs.getString(1).equals("Y");
/*    */ 
/* 38 */       return bool;
/*    */     }
/*    */     catch (Exception e)
/*    */     {
/* 31 */       e.printStackTrace();
/* 32 */       ex = 0;
/*    */ 
/* 38 */       return ex;
/*    */     }
/*    */     finally
/*    */     {
/* 34 */       if (cs != null) try {
/* 35 */           cs.close();
/*    */         } catch (SQLException ex) {
/* 37 */           Logger.getLogger(Accesser.class.getName()).log(Level.SEVERE, null, ex);
/*    */         } 
/*    */     }
/*    */   }
/*    */ 
/*    */   public static boolean hasAction(int actionId)
/*    */   {
/* 43 */     CallableStatement cs = null;
/*    */     try {
/* 45 */       cs = con.prepareCall("{? = call Ia_Api.Check_Action(" + actionId + ") }");
/* 46 */       cs.registerOutParameter(1, 12);
/* 47 */       cs.execute();
/* 48 */       boolean bool = cs.getString(1).equals("Y");
/*    */ 
/* 57 */       return bool;
/*    */     }
/*    */     catch (Exception e)
/*    */     {
/* 50 */       e.printStackTrace();
/* 51 */       ex = 0;
/*    */ 
/* 57 */       return ex;
/*    */     }
/*    */     finally
/*    */     {
/* 53 */       if (cs != null) try {
/* 54 */           cs.close();
/*    */         } catch (SQLException ex) {
/* 56 */           Logger.getLogger(Accesser.class.getName()).log(Level.SEVERE, null, ex);
/*    */         } 
/*    */     }
/*    */   }
/*    */ 
/*    */   public static void check(Connection conn, HttpServletResponse response)
/*    */   {
/* 62 */     con = conn;
/* 63 */     CallableStatement cs = null;
/*    */     try {
/* 65 */       if (conn == null) {
/* 66 */         response.sendRedirect("/ibs/sessionOut.html");
/*    */         return;
/*    */       }
/* 69 */       cs = conn.prepareCall("{? = call Ia_Api.Check_Access }");
/* 70 */       cs.registerOutParameter(1, 12);
/* 71 */       cs.execute();
/* 72 */       if (cs.getString(1).equals("N"))
/* 73 */         response.sendRedirect("/ibs/sessionOut.html");
/*    */     }
/*    */     catch (Exception ex) {
/* 76 */       e.printStackTrace();
/*    */       try {
/* 78 */         response.sendRedirect("/ibs/sessionOut.html");
/*    */       } catch (IOException ex) {
/* 80 */         Logger.getLogger(Accesser.class.getName()).log(Level.SEVERE, null, ex);
/*    */       }
/*    */     } finally {
/* 83 */       if (cs != null) try {
/* 84 */           cs.close();
/*    */         } catch (SQLException ex) {
/* 86 */           Logger.getLogger(Accesser.class.getName()).log(Level.SEVERE, null, ex);
/*    */         }
/*    */     }
/*    */   }
/*    */ }

/* Location:           D:\FIDO\BANK\IABS\HR\UPDATE\HR_1\jsp\ibs\ia\WEB-INF\classes\
 * Qualified Name:     ia.Accesser
 * JD-Core Version:    0.5.4
 */