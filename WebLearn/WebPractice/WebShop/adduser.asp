<!-- #include file="conn.asp" --> 
<html> 
<head> 
<meta http-equiv="Content-Type" content="text/html; charset=gb2312"> 
<title>�ɹ�</title> 
</head> 
<body> 
<% 
ac=request.QueryString("ac") 
msg="ע�������Ϣ" 
if request.Form("username")="" then 
msg=msg&"<br>"&"�û�������Ϊ��" 
end if 
if strcomp(cstr(request.Form("password")),cstr(request.Form("password2")))<>0 then 
msg=msg&"<br>"&"�����������벻ͬ" 
end if 

if len(request.Form("password"))<6 then 
msg=msg&"<br>"&"����̫��" 
end if 

if strcomp(msg,"ע�������Ϣ")>0 then 
response.Redirect("reg.asp?msg="&msg) 
end if 

if ac="adduser" then 

set rsc=server.createobject("adodb.recordset") 
sql="select * from userinfo where username='"&request.Form("username")&"'" 

rsc.open sql,conn,1,1 
ck=rsc("username") 
set rsc=nothing 

if ck<>"" then 
msg=msg&"<br>"&"�û�������ע��" 
response.Redirect("reg.asp?msg="&msg) 
end if 

dsql="select * from userinfo where id is null" 
set rs=server.createobject("adodb.recordset") 
rs.open dsql,conn,1,3 
rs.addnew 
rs("username")=request.Form("username") 
rs("password")=request.Form("password") 
rs("email")=request.Form("mail") 
rs("qq")=request.Form("qq") 
rs("sex")=request.Form("sex") 
rs("time")=now 
rs.update 
set rs=nothing 
%> 
<center> 
<a href="index.asp" target="_self">ע��ɹ�,�����½</a> 
</center> 
<% 
end if 
%> 
</body> 
</html> 
