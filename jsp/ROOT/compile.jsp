<%@page import="uz.fido_biznes.cms.Util" %>
<%@ page import="java.sql.*,java.net.*"
         contentType="text/html;charset=Windows-1251" %>
<html>
<head>
	<title>Compile</title>
</head>
<body>
<script>
	AJAX = ajax =
		{
			load: function (url) {
				xhr = new ActiveXObject("Microsoft.XMLHTTP"), mtd = "GET";

				xhr.open(mtd, url, true);

				var post = null;

				xhr.onreadystatechange = function () {
					if (xhr.readyState == 4) {
						if (xhr.status != 200) {
							err++;
						}
						compileNext();
					}
				};
				xhr.send(post);
			}
		};
	var i = 0, err = 0;

	function compileNext() {
		i++;
		btnCompile.disabled = true;
		document.getElementById("sta").innerHTML = 'Compiled:' + i + " Error=" + err;
		if (i != filelist.length) {
			AJAX.load(filelist[i]);
		} else {
			btnCompile.disabled = false;
			i = 0;
			err = 0;
		}
	}
</script>
<script>

	<%String fs = System.getProperty("file.separator");
					String apppath = application.getRealPath(fs);
					int pos = apppath.length();
					java.io.File jsp = new java.io.File(apppath+"ibs/");
					out.print("var filelist=[");
					collectjsp(jsp, out, pos);
					out.print("];");
	%>
	document.write("Files to compile:" + filelist.length);

	function compile() {
		compileNext();
	}
</script>
<button onclick="compile()" id=btnCompile>Compile</button>
<p id=sta>

</p>
</body>
</html>
<%!
	void collectjsp(java.io.File file, JspWriter out, int pos)
		throws java.io.IOException {
		java.io.File[] files = file.listFiles();
		for (int i = 0; i < files.length; i++) {
			java.io.File f = files[i];
			if (f.isDirectory()) {
				if (!f.getName().equals("WEB-INF")) {
					collectjsp(f, out, pos);
				}
			} else {
				String jsp = f.getPath().substring(pos);
				if (jsp.substring(jsp.length() - 4).equals(".jsp")) {
					out.print(",'" + Util.quotesEsc(jsp) + "'");
				}
			}
		}
	}
%>