<!-- #include file="conn.asp" --> 
<% 
'�����ݿ��ж��û��Ƿ����,infoΪ����,usernameΪ�ֶ��� 
set rsc=server.createobject("adodb.recordset") 
sqlc="select * from userinfo where username='"&request.Form("username")&"' and password='"&request.Form("password")&"'  " 
rsc.open sqlc,conn,1,1 


session("username")=rsc("username") 
session("password")=rsc("password") 

if rsc("username")="" Then

session.Timeout=30 
rsc.close 
set rsc=nothing 
response.Write("<center>")

response.Write "<a href='login.asp' target='_self'>��¼ʧ��,�����µ�¼</a>"

response.Write("</center>")

Else
Session("ustaus")=1
session.Timeout=30 
rsc.close 
set rsc=nothing 

response.Redirect("index.asp") 
end if






'����û�������,session("username")Ϊ�� 
%>