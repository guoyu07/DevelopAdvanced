<!-- #include file="conn.asp" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=gb2312" />
    <title>�û�ע��</title>

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
        <h3>
            <center>
                �û�ע��

            </center>
        </h3>


        <div class="pro_detail">

            <% 
=request("msg") 
            %>
            <form name="form1" method="post" action="adduser.asp?ac=adduser">
                <table border="0">
                    <tr>
                        <td height="30">�û�����</td>
                        <td height="30">
                            <input name="username" type="text" id="username">
                            *</td>
                    </tr>
                    <tr>
                        <td height="30">���룺</td>
                        <td height="30">
                            <input name="password" type="password" id="password">
                            *</td>
                    </tr>
                    <tr>
                        <td height="30">ȷ�����룺</td>
                        <td height="30">
                            <input name="password2" type="password" id="password2">
                            *</td>
                    </tr>
                    <tr>
                        <td height="30">�Ա�</td>
                        <td height="30">
                            <input name="sex" type="text" id="sex"></td>
                    </tr>

                    <tr>
                        <tr>
                            <td height="30">QQ��</td>
                            <td height="30">
                                <input name="qq" type="text" id="qq"></td>
                        </tr>
                        <tr>
                            <td height="30">Mail��</td>
                            <td height="30">
                                <input name="mail" type="text" id="mail"></td>
                        </tr>


                        <tr>
                            <td></td>
                            <td>
                                <input type="submit" name="Submit" value="�ύ"></td>
                        </tr>
                </table>
            </form>
        </div>
    </div>
    <!--�������ݽ���-->
</body>
</html>
