<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=gb2312" />
<title>sasa shopping</title>

<link rel="stylesheet" href="styles/main.css" type="text/css" />
<link rel="stylesheet" href="styles/index.css" type="text/css" />
<link rel="stylesheet" href="styles/skin/skin_1.css" type="text/css" id="cssfile" />



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
<!--���忪ʼ-->
<div id="content">
	<div class="content_left">
		<div class="global_module news">
			<h3>������֪</h3>
			 1.&nbsp;&nbsp;�ڱ���ԤԼ��Ʒ����ң��ڵ���������յ��������ֻ����š������ʼ��Ȳ�ͬ��ʽ�Ĳ���֪ͨ��
			 <br>
			 2.&nbsp;&nbsp;Ԥ���𲻿��ˣ�����ת��������Ʒ��
		    <br>

             3.&nbsp;&nbsp;����δ����ϵ��ֱ��������Ʒ֧����������Ȩȡ���ý��ס�

			
		</div>

		<div class="global_module news">
			<h3>��ϵ��ʽ</h3>
			<div class="scrollNews" >
				<ul>
					
					<li>QQ��772555190</li>
					<li>��ϵ�ֻ���15921628769</li>
					
				</ul>
			</div>


		
		</div>

			<div class="global_module news">
			<h3>����ʱ��</h3>
			<div class="scrollNews" >
				<ul>
					
					<li>��һ�����գ�10:30-24:00</li>
					<li>���������գ�10:00-24:00</li>
					
				</ul>
			</div>


		
		</div>
 		
 		
	 </div>
	



	
	<div class="content_right">

	   <div class="ad" >
			 <ul class="slider" >
				<li><img src="image/0.jpg"/></li>
			
			  </ul>
			 
		</div>
	        <div class="global_module prolist">
		    <h3>��Ʒ�б�</h3>
                <div  class="prolist_content">
                <ul>
                    <li>
                        <a href="1.asp"><img src="image/1.jpg" alt="" /></a><span>Black Album 02 </a></span><span> һ�ڼ� 40 Ԫ</span>
                    </li>
					 <li>
                        <a href="1.asp"><img src="image/2.jpg" alt="" /></a><span>Carnival Fantasy </a></span><span> һ�ڼ� 40 Ԫ</span>
                    </li>
					 <li>
                        <a href="1.asp"><img src="image/3.jpg" alt="" /></a><span>Black Album 01 </a></span><span> һ�ڼ� 40 Ԫ</span>
                    </li>
					 <li>
                        <a href="1.asp"><img src="image/4.jpg" width="160"  alt="" /></a><span>�μ� Drifting Dream- </a></span><span> һ�ڼ� 70 Ԫ</span>
                    </li>
					
				</ul>
			
         </div>
       </div> 

	    </div> 



</div>
<!--�������-->
</body>
</html>
