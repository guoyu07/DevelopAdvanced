<!-- #include file="conn.asp" --> 
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=gb2312" />
<title>����</title>

<link rel="stylesheet" href="styles/main.css" type="text/css" />
<link rel="stylesheet" href="styles/detail.css" type="text/css" />
<link rel="stylesheet" href="styles/skin/skin_1.css" type="text/css" id="cssfile" />
<link rel="stylesheet" href="styles/thickbox.css" type="text/css" />

</head>
<body>
<!--ͷ����ʼ-->
<div id="header">
	<a id="logo" href="index.asp">sasa Shopping</a>

</div>


<!--ͷ������-->
<!--������ʼ-->
<div id="navigation">
	<ul>
		
		 <li><a href="#">��ϵ����</a></li>





	</ul>
</div>
<!--��������-->


<!--�������ݿ�ʼ-->
<div id="content" class="global_module">
	<h3><center> 
	����

</center> </h3>


	<div class="pro_detail">

<% 
set rsc=server.createobject("adodb.recordset") 
sqlc="select  proname  from production "
rsc.open sqlc,conn,1,1 
%> 


<% 
=request("msg") 
%> 
<form name="form1" method="post" action="addorder.asp "> 

<table border="0"   > 
<tr> 
<td >��Ʒ��</td> 
<td  >

<select name="mainmenu" size="1" >
<option value=0>��ѡ����Ʒ&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</option>
       <%while not rsc.eof%>
<option value="<%=rsc("proname")%>"><%=rsc("proname")%></option>
<%rsc.movenext
wend%>
</select>


</td> 
</tr> 
<tr> 
<td height="30">����</td> 
<td height="30"><input name="num" type="text" id="num"> 
</td> 
</tr> 
<tr> 
<td height="30">��ϵ��ַ</td> 
<td height="30"><input name="add" type="text" id="add"> 
</td> 
</tr> 
<tr> 
<td height="30">�绰����</td> 
<td height="30"><input name="phone" type="text" id="phone"></td> 
</tr> 

<tr> 
<tr> 
<td> </td> 
<td><input type="submit" name="Submit" value="�ύ"></td> 
</tr> 
</table> 
</form> 
	</div>
</div>
<!--�������ݽ���-->
</body>
</html>
