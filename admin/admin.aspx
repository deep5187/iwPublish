<%@ Page Title="Administrator Administration" Language="VB" MasterPageFile="admin.master" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">
    
    Dim Connection As SqlConnection
    
    '********************
    ' Main Page Load
    '********************
    Sub Page_Load()
        Connection = New SqlConnection(ConfigurationManager.ConnectionStrings("db").ConnectionString)
        
        If Not Page.IsPostBack Then
            ShowList()
        End If
    End Sub
    
    '********************
    ' Show Existing Records
    '********************
    Sub ShowList()
        Dim sql As String = "SELECT * FROM administrator ORDER BY admin_id DESC"
        
        dgrdList.DataSource = IST.DataAccess.GetDataTable(sql)
        dgrdList.DataBind()
        
        mvwMain.SetActiveView(vwList)
    End Sub

    '********************
    ' Add New Record
    '********************
    Protected Sub btnSub_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If Page.IsValid Then
            Dim sql As String
            If Len(ViewState("idVal")) = 0 Then
                sql = "INSERT INTO administrator (admin_fname, admin_lname, admin_username, admin_password, admin_email) VALUES (@admin_fname, @admin_lname, @admin_username, @admin_password, @admin_email)"
            Else
                sql = "UPDATE administrator SET admin_fname=@admin_fname, admin_lname=@admin_lname, admin_username=@admin_username, admin_password=@admin_password, admin_email=@admin_email WHERE admin_id = " & ViewState("idVal")
            End If
            Dim cmdsql As New SqlCommand(sql, Connection)
        
            If txtFname.Text = String.Empty Then
                cmdsql.Parameters.AddWithValue("@admin_fname", DBNull.Value)
            Else
                cmdsql.Parameters.AddWithValue("@admin_fname", txtFname.Text)
            End If
            If txtLname.Text = String.Empty Then
                cmdsql.Parameters.AddWithValue("@admin_lname", DBNull.Value)
            Else
                cmdsql.Parameters.AddWithValue("@admin_lname", txtLname.Text)
            End If
            cmdsql.Parameters.AddWithValue("@admin_username", txtUname.Text)
            cmdsql.Parameters.AddWithValue("@admin_password", txtPass.Text)
            cmdsql.Parameters.AddWithValue("@admin_email", txtEmail.Text)
        
            Connection.Open()
            cmdsql.ExecuteNonQuery()
            Connection.Close()
            
            ShowList()
        End If
    End Sub
    
    '********************
    ' Add New Clicked
    '********************
    Sub btnAdd_Click(ByVal s As Object, ByVal e As EventArgs)
        txtFname.Text = ""
        txtLname.Text = String.Empty
        txtEmail.Text = ""
        txtUname.Text = ""
        txtPass.Text = ""
        ViewState("idVal") = ""
        btnSub.Text = "Add New"
        
        mvwMain.SetActiveView(vwForm)
    End Sub
    
    '********************
    ' Cancel Clicked
    '********************
    Sub btnCancel_Click(ByVal s As Object, ByVal e As EventArgs)
        mvwMain.SetActiveView(vwList)
    End Sub
    
    '********************
    ' Datagrid Button Click
    '********************
    Sub dgrdList_ItemCommand(ByVal s As Object, ByVal e As DataGridCommandEventArgs)
        Select Case e.CommandName
            Case "edit"
                EditForm(dgrdList.DataKeys(e.Item.ItemIndex))
            Case "delete"
                Dim sql As String = "DELETE FROM administrator WHERE admin_id = " & dgrdList.DataKeys(e.Item.ItemIndex)
                Dim cmdSql As New SqlCommand(sql, Connection)
                Connection.Open()
                cmdSql.ExecuteNonQuery()
                Connection.Close()
                
                ShowList()
        End Select
    End Sub
    
    '********************
    ' Edit Form
    '********************
    Sub EditForm(ByVal idval As Integer)
        Dim dtb As DataTable = IST.DataAccess.GetDataTable("SELECT * FROM administrator WHERE admin_id = " & idval)
        If dtb.Rows.Count > 0 Then
            Dim dr As DataRow = dtb.Rows(0)
            
            txtFname.Text = dr("admin_fname").ToString
            txtLname.Text = dr("admin_lname").ToString
            txtEmail.Text = dr("admin_email")
            txtUname.Text = dr("admin_username")
            txtPass.Text = dr("admin_password")
            
            ViewState("idVal") = idval
            btnSub.Text = "Update"
            mvwMain.SetActiveView(vwForm)
        End If
    End Sub
    
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <link rel="Stylesheet" href="../buttons.css" />
    <link rel="Stylesheet" href="../adminStyle.css" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cpHoldMain" runat="server">

    <asp:MultiView ID="mvwMain" runat="server">
        <asp:View ID="vwList" runat="server">
            <asp:Button ID="btnAdd" Text="Add" OnClick="btnAdd_Click" runat="server" />
            <asp:DataGrid ID="dgrdList"
             AutoGenerateColumns="false"
             UseAccessibleHeader="true"
             OnItemCommand="dgrdList_ItemCommand"
             DataKeyField="admin_id"
             runat="server"
             CssClass="grid"  HeaderStyle-CssClass="gridHead">
                <Columns>
                    <asp:BoundColumn DataField="admin_id" HeaderText="Primary Key" />
                    <asp:TemplateColumn HeaderText="Name">
                        <ItemTemplate>
                            <%#Container.DataItem("admin_fname")%> <%# Container.DataItem("admin_lname")%>
                        </ItemTemplate>
                    </asp:TemplateColumn>
                    <asp:BoundColumn HeaderText="Username" DataField="admin_username" />
                    <asp:TemplateColumn HeaderText="Email">
                        <ItemTemplate>
                           <a href="mailto:<%#Container.DataItem("admin_email")%>"><%# Container.DataItem("admin_email")%></a>
                        </ItemTemplate>
                    </asp:TemplateColumn>

                    <asp:ButtonColumn ButtonType="PushButton" CommandName="edit" Text="Edit" />
                    <asp:TemplateColumn>
                        <ItemTemplate>
                            <asp:Button ID="btnDel" Text="Delete" CommandName="delete" OnClientClick="javascript:return confirm('Are you sure you want to delete this record?');" runat="server" />
                        </ItemTemplate>
                    </asp:TemplateColumn>
                </Columns>
            </asp:DataGrid>
        </asp:View>

        <asp:View ID="vwForm" runat="server">
        <div class="grid">
       
            <table  >
                <tr>
                    <td>First Name</td>
                    <td>
                        <asp:TextBox ID="txtFname" runat="server" />
                    </td>
                </tr>
                <tr>
                    <td>Last Name</td>
                    <td>
                        <asp:TextBox ID="txtLname" runat="server" />
                    </td>
                </tr>
                <tr>
                    <td>User Name</td>
                    <td>
                        <asp:TextBox ID="txtUname" runat="server" />
                        <asp:RequiredFieldValidator ID="RequiredFieldValidator1" ControlToValidate="txtUname" ErrorMessage="Required" Display="Dynamic" runat="server" />
                    </td>
                </tr>
                 <tr>
                    <td>Password</td>
                    <td>
                        <asp:TextBox ID="txtPass" TextMode="Password" runat="server" />
                        <asp:RequiredFieldValidator ID="RequiredFieldValidator2" ControlToValidate="txtPass" ErrorMessage="Required" Display="Dynamic" runat="server" />
                    </td>
                </tr>
                 <tr>
                    <td>Email</td>
                    <td>
                        <asp:TextBox ID="txtEmail" runat="server" />
                        <asp:RequiredFieldValidator ID="RequiredFieldValidator3" ControlToValidate="txtEmail" ErrorMessage="Required" Display="Dynamic" runat="server" />
                    </td>
                </tr>
            </table>
            <asp:Button ID="btnSub" Text="Submit" onclick="btnSub_Click" runat="server" />
            <asp:Button ID="btnCancel" Text="Cancel" OnClick="btnCancel_Click" CausesValidation="false" runat="server" />
             </div>
        </asp:View>
    </asp:MultiView>

        

</asp:Content>