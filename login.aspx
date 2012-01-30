<%@ Page Title="" Language="VB" MasterPageFile="~/MasterPage.master" %>

<%@ Import Namespace="System.Data" %>

<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">
    Dim conn As New SqlConnection
    Sub page_load()
        conn.ConnectionString = ConfigurationManager.ConnectionStrings("db").ConnectionString
       
    
    End Sub
    Sub btnLogin_click(ByVal o As Object,ByVal s As EventArgs)
        
        Dim sql As String = "SELECT admin_id FROM administrator WHERE admin_username = @admin_username AND admin_password=@admin_password"
    
        Dim sqlcmd As New SqlCommand(Sql, conn)
        sqlcmd.Parameters.AddWithValue("@admin_username", txtUname.Text)
        sqlcmd.Parameters.AddWithValue("@admin_password", txtPass.Text)
        conn.Open()
        Dim dtr As SqlDataReader = sqlcmd.ExecuteReader
        If dtr.Read() Then
            FormsAuthentication.RedirectFromLoginPage(txtUname.Text, False)
        Else
            litError.Text = "Invalid Username or Password"
        End If
        conn.Close()
    End Sub
    
    
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
</asp:Content>
<asp:Content ID="PageHeader" ContentPlaceHolderID="cpHoldPageHeader" runat="server">
Login
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cpHoldMain" Runat="Server">
<div class="error">
<asp:Literal ID="litError" runat="server" ></asp:Literal>
</div>
<div id="loginFrm">
<form>
        <fieldset>
          <div class="clearfix">
            <label for="txtUname"> Username</label>
            <div class="input">
              <asp:TextBox ID="txtUname" runat="server" ClientIDMode="Static"></asp:TextBox>
            </div>
          </div><!-- /clearfix -->
          <div class="clearfix">
            <label for="txtPass">Password</label>
            <div class="input">
              <asp:TextBox ID="txtPass" runat="server" TextMode="Password" ClientIDMode="Static"></asp:TextBox>
            </div>
          </div>
          <div class="actions">
                <asp:Button id="btnLogin" runat="server" OnClick="btnLogin_Click" Text="Login" cssClass="btn primary"/>
          </div>
          </fieldset>
</form>
</div>
</asp:Content>

