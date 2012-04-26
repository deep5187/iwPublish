<%@ Page Title="" Language="VB" MasterPageFile="admin.master"  ValidateRequest="false"%>

<%@ Import Namespace="System.Data.SqlClient" %>
<script runat="server">
    Dim conn As New SqlConnection
    Sub page_load()
        If Not Page.IsPostBack Then
           showlist()
        End If
        conn.ConnectionString = ConfigurationManager.ConnectionStrings("db").ConnectionString
    End Sub
    Sub showlist()
        conn.ConnectionString = ConfigurationManager.ConnectionStrings("db").ConnectionString
        Dim userSql As String
        userSql = " SELECT [name],[email],[phoneno],[regdate],[id],[platform] FROM [iwadmin].[user] ORDER BY [regdate] DESC, [id] DESC "
        Dim cntUser = "SELECT COUNT(*) FROM [iwadmin].[user]"
        With dtGrd
            .DataSource = IST.DataAccess.GetDataTable(userSql)
        End With
        Dim sqlcmd As New SqlCommand(cntUser, conn)
        conn.Open()
        Dim cnt As String = sqlcmd.ExecuteScalar()
        conn.Close()
        litPageHeader.Text = "User - " + cnt
        dtGrd.DataBind()
    End Sub
</script>
<asp:Content ID="PageHeader" ContentPlaceHolderID="cpHoldPageHeader" runat="server">
    <asp:Literal ID="litPageHeader" runat="server">Users</asp:Literal>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cpHoldMain" runat="Server">
            <asp:DataGrid ID="dtGrd" runat="server" AutoGenerateColumns="false" DataKeyField="id"
                CssClass="table table-bordered">
                <Columns>
                    <asp:BoundColumn DataField="name" HeaderText="Name">
                    </asp:BoundColumn>
                    <asp:BoundColumn DataField="email" HeaderText="Date">
                    </asp:BoundColumn>
                    <asp:BoundColumn DataField="phoneno" HeaderText="Phone No">
                    </asp:BoundColumn>
                    <asp:BoundColumn DataField="regdate" HeaderText="Registration Date">
                    </asp:BoundColumn>
                    <asp:BoundColumn DataField="platform" HeaderText="Platform">
                    </asp:BoundColumn>
                </Columns>
            </asp:DataGrid>
          </asp:Content>
