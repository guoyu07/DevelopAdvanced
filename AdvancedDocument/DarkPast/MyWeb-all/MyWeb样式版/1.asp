<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=gb2312" />
<title>Black Ablum2</title>

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

 <%
if  Session("ustaus") then 

response.Write("<li>")
response.Write "<a href='userct.asp'>��������</a>"
response.Write("</li>")
response.Write("<li>")
response.Write "<a href='exit.asp'>�˳�</a>"
response.Write("</li>")

response.Write("<li>")
response.Write "<a href='order.asp'>����</a>"
response.Write("</li>")

Else
response.Write("<li>")
response.Write "<a href='login.asp'>��¼</a>"
response.Write("</li>")
response.Write("<li>")
response.Write "<a href='reg.asp'>ע��</a>"
response.Write("</li>")

End if
%> 



	</ul>
</div>
<!--��������-->


<!--�������ݿ�ʼ-->
<div id="content" class="global_module">
	<h3>��Ʒ��Ϣ</h3>
	<div class="pro_detail">
		<div class="pro_detail_left">
			<div class="jqzoom"><img src="image/001.jpg" class="fs" alt=""  /></div>
				<span>
                <a href="image/001.jpg" id="thickImg"class="thickbox">
                   <img alt="�������ͼ" src="image/look.gif" />
                </a>
            </span>
		
		</div>
		<div class="pro_detail_right">
			<h4>Black Ablum2</h4>
			<p>������ideolo�ĸ��˶���ͬ�˱�Black Ablum�ĵڶ���
			<br>ͬ�����ޱ�ֵ���ղص�һ��

             <br>40Ԫ�վɣ����¼�����

           <br>�����֧������Ů����Ŀ������ÿһ�ֹ�ע��������������Ʒ�Ķ���m(_ _)m
          </p>
			
		</div>
	</div>
</div>
<!--�������ݽ���-->
</body>
</html>
