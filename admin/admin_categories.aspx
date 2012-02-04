<%@ Page Title="" Language="VB" MasterPageFile="admin.master" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<script runat="server">
    Dim conn As SqlConnection
    Sub Page_Load()
        conn = New SqlConnection(ConfigurationManager.ConnectionStrings("db").ConnectionString)
        If Not Page.IsPostBack Then
            ShowCatList()
        End If
    End Sub
    
    Private Sub ShowCatList()
        Dim sql As String = "SELECT cat_id,cat_name,cat_type FROM category"
        dtGrd.DataSource = IST.DataAccess.GetDataTable(sql)
        dtGrd.DataBind()
        litPageHeader.Text="Categories"
        mvwMain.SetActiveView(vmList)
    End Sub
    
    Sub dtGrid_ItemCmd(ByVal s As Object, ByVal e As DataGridCommandEventArgs)
        Select Case e.CommandName
            Case "Edit"
              
                EditForm(dtGrd.DataKeys(e.Item.ItemIndex))
                
            Case "Delete"
                Dim sql As String = "DELETE FROM category WHERE cat_id=" & dtGrd.DataKeys(e.Item.ItemIndex)
                Dim sqlcmd As New SqlCommand(sql, conn)
                conn.Open()
                sqlcmd.ExecuteNonQuery()
                conn.Close()
                
                ShowCatList()
        End Select
    End Sub

    Sub EditForm(ByVal id As Integer)
        Dim dtb As DataTable = IST.DataAccess.GetDataTable("SELECT cat_name,cat_type FROM category WHERE cat_id=" & id)
        If dtb.Rows.Count > 0 Then
            Dim dr As DataRow = dtb.Rows(0)
            catNameTxt.Text = dr("cat_name")
            If Not Convert.IsDBNull(dr("cat_type")) Then
                lstCatType.SelectedValue = dr("cat_type")
            End If
            
            ViewState("id") = id
            subBtn.Text = "Update"
            litPageHeader.Text="Categories <small>Edit</small>"
            mvwMain.SetActiveView(vmForm)
        End If
        
    End Sub
    Protected Sub canBtn_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        litPageHeader.Text="Categories"
        mvwMain.SetActiveView(vmList)
    End Sub
    
    Protected Sub addBtn_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        catNameTxt.Text = ""
        ViewState("id") = ""
        subBtn.Text = "Add New"
        litPageHeader.Text="Categories <small>Add</small>"
        mvwMain.SetActiveView(vmForm)
    End Sub

    Protected Sub subBtn_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim sql As String
        If Page.IsValid Then
            If Len(ViewState("id")) = 0 Then
                sql = "INSERT INTO category (cat_name,cat_type) VALUES (@cat_name,@cat_type)"
            Else
                sql = "UPDATE category SET cat_name=@cat_name, cat_type=@cat_type WHERE cat_id=" & ViewState("id")
            End If
            Dim sqlcmd As New SqlCommand(sql, conn)
            sqlcmd.Parameters.AddWithValue("@cat_name", catNameTxt.Text)
            sqlcmd.Parameters.AddWithValue("@cat_type", lstCatType.SelectedValue)
            conn.Open()
            sqlcmd.ExecuteNonQuery()
            conn.Close()
            ShowCatList()
        End If
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
</asp:Content>
<asp:Content ID="PageHeader" ContentPlaceHolderID="cpHoldPageHeader" runat="server">
    <asp:Literal ID="litPageHeader" runat="server">Categories</asp:Literal>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cpHoldMain" runat="Server">
    <asp:MultiView ID="mvwMain" runat="server">
        <asp:View ID="vmList" runat="server">
            <asp:Button ID="addBtn" runat="server" Text="Add New" OnClick="addBtn_Click" CssClass="btn btn-large btn-success" />
            <asp:DataGrid ID="dtGrd" runat="server" AutoGenerateColumns="false" DataKeyField="cat_id"
                OnItemCommand="dtGrid_ItemCmd" CssClass="table table-bordered">
                <Columns>
                    <asp:BoundColumn DataField="cat_name" HeaderText="Category"></asp:BoundColumn>
                    <asp:BoundColumn DataField="cat_type" HeaderText="Type"></asp:BoundColumn>
                    <asp:TemplateColumn>
                        <ItemTemplate>
                            <asp:Button Text="Edit" CommandName="Edit" runat="server" CssClass="btn btn-small" />
                            <asp:Button ID="Button1" Text="Delete" CommandName="Delete" runat="server" OnClientClick="javascript:return confirm('Are you sure you want to delete this record?');"
                                CssClass="btn btn-small" />
                        </ItemTemplate>
                    </asp:TemplateColumn>
                </Columns>
            </asp:DataGrid>
        </asp:View>
        <asp:View ID="vmForm" runat="server">
            <div class="form-horizontal">
                <div class="control-group">
                    <label for="lstCatType">
                        Type
                    </label>
                    <div class="controls">
                        <asp:DropDownList ID="lstCatType" runat="server">
                            <asp:ListItem Value="News" Text="News"></asp:ListItem>
                            <asp:ListItem Value="Question" Text="Question"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="control-group">
                    <label for="catNameTxt">
                        Category</label>
                    <div class="controls">
                        <asp:TextBox ID="catNameTxt" runat="server"></asp:TextBox>
                        <asp:RequiredFieldValidator ControlToValidate="catNameTxt" ErrorMessage="Required"
                            runat="server" Display="Dynamic"></asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="form-actions">
                    <asp:Button ID="subBtn" runat="server" Text="Submit" OnClick="subBtn_Click" CssClass="btn btn-primary" />
                    <asp:Button ID="canBtn" runat="server" Text="Cancel" CausesValidation="false" OnClick="canBtn_Click"
                        CssClass="btn" />
                </div>
            </div>
        </asp:View>
    </asp:MultiView>
</asp:Content>
