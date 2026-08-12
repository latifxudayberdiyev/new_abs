/*     */ package ia.files;
/*     */ 
/*     */ import java.io.BufferedInputStream;
/*     */ import java.io.ByteArrayOutputStream;
/*     */ import java.io.IOException;
/*     */ import java.nio.ByteBuffer;
/*     */ import java.nio.CharBuffer;
/*     */ import java.nio.charset.Charset;
/*     */ import java.util.Enumeration;
/*     */ import java.util.Vector;
/*     */ import javax.servlet.http.HttpServletRequest;
/*     */ 
/*     */ public class RequestData
/*     */ {
/*     */   private RequestContent[] requestContent;
/*     */   private int paramCount;
/*     */   private byte[] data;
/*     */   private String boundary;
/*  42 */   private String charset = "Windows-1251";
/*     */ 
/*     */   public String getCharset()
/*     */   {
/*  50 */     return this.charset;
/*     */   }
/*     */ 
/*     */   public void setCharset(String charset)
/*     */   {
/*  59 */     this.charset = charset;
/*     */   }
/*     */ 
/*     */   public RequestData(HttpServletRequest request, int maxSize)
/*     */     throws Exception
/*     */   {
/*  69 */     this.boundary = extractBoundary(request.getHeader("Content-Type"));
/*  70 */     this.data = readRequest(request, maxSize);
/*  71 */     extractData();
/*     */   }
/*     */ 
/*     */   private static byte[] readRequest(HttpServletRequest request, int maxSize) throws IOException
/*     */   {
/*  76 */     BufferedInputStream bufStream = new BufferedInputStream(request.getInputStream());
/*  77 */     ByteArrayOutputStream arrStream = new ByteArrayOutputStream();
/*     */     try {
/*  79 */       while ((b = bufStream.read()) != -1)
/*  80 */         arrStream.write(b);
/*  81 */       int b = arrStream.toByteArray();
/*     */ 
/*  84 */       return b;
/*     */     }
/*     */     finally
/*     */     {
/*  83 */       bufStream.close();
/*  84 */       arrStream.close();
/*     */     }
/*     */   }
/*     */ 
/*     */   private String extractBoundary(String str) {
/*  89 */     int index = str.lastIndexOf("boundary=");
/*  90 */     String boundary = str.substring(index + 9);
/*  91 */     return "--" + boundary;
/*     */   }
/*     */ 
/*     */   private void extractData() throws Exception {
/*  95 */     Vector dataVec = new Vector();
/*  96 */     String dataStr = new String(this.data, "ASCII");
/*  97 */     int index = 0; int prev_index = 0;
/*     */ 
/*  99 */     for (int i = 0; (index = dataStr.indexOf(this.boundary, index)) != -1; ++i) {
/* 100 */       if (i != 0) {
/* 101 */         RequestContent reqContent = extractFileData(prev_index, index - 2);
/* 102 */         dataVec.addElement(reqContent);
/*     */       }
/* 104 */       index += this.boundary.length();
/* 105 */       prev_index = index;
/*     */     }
/* 107 */     this.paramCount = dataVec.size();
/* 108 */     this.requestContent = new RequestContent[this.paramCount];
/* 109 */     Enumeration en = dataVec.elements();
/* 110 */     for (int i = 0; en.hasMoreElements(); ++i)
/* 111 */       this.requestContent[i] = ((RequestContent)en.nextElement());
/*     */   }
/*     */ 
/*     */   private RequestContent extractFileData(int indexBegin, int indexEnd) throws Exception {
/* 115 */     int partLength = indexEnd - indexBegin + 1;
/* 116 */     byte[] partData = new byte[partLength];
/*     */ 
/* 118 */     System.arraycopy(this.data, indexBegin, partData, 0, partLength);
/* 119 */     String dataStr = new String(partData, "ASCII");
/*     */ 
/* 122 */     String fileName = "";
/* 123 */     String parName = "";
/* 124 */     String mimeType = "";
/*     */ 
/* 126 */     int index = dataStr.indexOf("\r\n\r\n", 2);
/* 127 */     if (index != -1) {
/* 128 */       String header = Charset.forName(this.charset).decode(ByteBuffer.wrap(partData, 0, index)).toString();
/* 129 */       parName = parseParName(header);
/* 130 */       fileName = parseFileName(header);
/* 131 */       mimeType = parseMimeType(header);
/* 132 */       indexBegin += index + 4;
/*     */     }
/* 134 */     return new RequestContent(parName, fileName, mimeType, indexBegin, indexEnd);
/*     */   }
/*     */ 
/*     */   private String parseFileName(String header)
/*     */   {
/* 141 */     header.toLowerCase();
/*     */     int index;
/* 142 */     if ((index = header.indexOf("filename=")) != -1) {
/* 143 */       index += 10;
/* 144 */       int up_index = header.indexOf(34, index);
/*     */ 
/* 146 */       String fileName = header.substring(index, up_index);
/* 147 */       index = fileName.lastIndexOf(47);
/* 148 */       up_index = fileName.lastIndexOf(92);
/* 149 */       return fileName.substring(Math.max(index, up_index) + 1);
/*     */     }
/* 151 */     return "NO_FILE";
/*     */   }
/*     */ 
/*     */   private String parseParName(String header) {
/* 155 */     String parName = null;
/*     */ 
/* 158 */     header.toLowerCase();
/*     */     int index;
/* 159 */     if ((index = header.indexOf("name=")) != -1) {
/* 160 */       index += 6;
/* 161 */       int up_index = header.indexOf(34, index);
/* 162 */       parName = header.substring(index, up_index);
/*     */     }
/* 164 */     return parName;
/*     */   }
/*     */ 
/*     */   private String parseMimeType(String header) {
/* 168 */     String mimeType = null;
/*     */     int index;
/* 171 */     if ((index = header.indexOf("Content-Type: ")) != -1) {
/* 172 */       index += "Content-Type: ".length();
/* 173 */       int up_index = header.indexOf("\r\n", index);
/* 174 */       if (up_index != -1)
/* 175 */         mimeType = header.substring(index, up_index);
/*     */       else
/* 177 */         mimeType = header.substring(index);
/*     */     }
/* 179 */     return mimeType;
/*     */   }
/*     */ 
/*     */   public String getMimeType(String parName)
/*     */   {
/* 189 */     for (int i = 0; i < this.paramCount; ++i)
/* 190 */       if (this.requestContent[i].parName.equals(parName))
/* 191 */         return this.requestContent[i].mimeType;
/* 192 */     return null;
/*     */   }
/*     */ 
/*     */   public String getFileName(String parName)
/*     */   {
/* 202 */     for (int i = 0; i < this.paramCount; ++i)
/* 203 */       if (this.requestContent[i].parName.equals(parName))
/* 204 */         return this.requestContent[i].fileName;
/* 205 */     return null;
/*     */   }
/*     */ 
/*     */   public long getFileSize(String parName)
/*     */   {
/* 215 */     for (int i = 0; i < this.paramCount; ++i)
/* 216 */       if (this.requestContent[i].parName.equals(parName))
/* 217 */         return this.requestContent[i].lastIndex - this.requestContent[i].startIndex;
/* 218 */     return 0L;
/*     */   }
/*     */ 
/*     */   public byte[] getParByteValue(String parName)
/*     */   {
/* 228 */     for (int i = 0; i < this.paramCount; ++i)
/* 229 */       if (this.requestContent[i].parName.equals(parName)) {
/* 230 */         int size = this.requestContent[i].lastIndex - this.requestContent[i].startIndex;
/* 231 */         byte[] retByte = new byte[size];
/* 232 */         System.arraycopy(this.data, this.requestContent[i].startIndex, retByte, 0, size);
/* 233 */         return retByte;
/*     */       }
/* 235 */     return null;
/*     */   }
/*     */ 
/*     */   public String getParValue(String parName)
/*     */   {
/* 245 */     byte[] retByte = getParByteValue(parName);
/* 246 */     return (retByte == null) ? null : Charset.forName(this.charset).decode(ByteBuffer.wrap(retByte)).toString();
/*     */   }
/*     */ 
/*     */   private class RequestContent
/*     */   {
/*     */     public String fileName;
/*     */     public String parName;
/*     */     public int startIndex;
/*     */     public int lastIndex;
/*     */     public String mimeType;
/*     */ 
/*     */     public RequestContent(String parName, String fileName, String mimeType, int startIndex, int lastIndex)
/*     */     {
/*  30 */       this.parName = parName;
/*  31 */       this.fileName = fileName;
/*  32 */       this.mimeType = mimeType;
/*  33 */       this.startIndex = startIndex;
/*  34 */       this.lastIndex = lastIndex;
/*     */     }
/*     */   }
/*     */ }

/* Location:           D:\FIDO\BANK\IABS\HR\UPDATE\HR_1\jsp\ibs\ia\WEB-INF\classes\
 * Qualified Name:     ia.files.RequestData
 * JD-Core Version:    0.5.4
 */