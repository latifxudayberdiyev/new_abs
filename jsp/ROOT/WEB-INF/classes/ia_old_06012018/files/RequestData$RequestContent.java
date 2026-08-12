/*    */ package ia.files;
/*    */ 
/*    */ class RequestData$RequestContent
/*    */ {
/*    */   public String fileName;
/*    */   public String parName;
/*    */   public int startIndex;
/*    */   public int lastIndex;
/*    */   public String mimeType;
/*    */ 
/*    */   public RequestData$RequestContent(RequestData paramRequestData, String parName, String fileName, String mimeType, int startIndex, int lastIndex)
/*    */   {
/* 30 */     this.parName = parName;
/* 31 */     this.fileName = fileName;
/* 32 */     this.mimeType = mimeType;
/* 33 */     this.startIndex = startIndex;
/* 34 */     this.lastIndex = lastIndex;
/*    */   }
/*    */ }

/* Location:           D:\FIDO\BANK\IABS\HR\UPDATE\HR_1\jsp\ibs\ia\WEB-INF\classes\
 * Qualified Name:     ia.files.RequestData.RequestContent
 * JD-Core Version:    0.5.4
 */