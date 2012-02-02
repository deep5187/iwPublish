<%@ Page Title="" Language="VB" MasterPageFile="admin.master" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="TwitterVB2" %>
<script runat="server">
    Dim conn As New SqlConnection
    Shared cntTilClick As Integer = 0
    Shared cntDateClick As Integer
    'Public oauthToken As String = "226367135-xy3HNxXWrN7uLxJHUPkqs1rfiCRGg7GHxw62nLwG"
    'Public oauthSecret As String = "RY8Tlb5hPWj8qrGqNVSQNHDyNIoROvtCkbkqOPb0lI0"
    Sub page_load()

        Dim tw As New TwitterAPI
        
        'If Request("oauth_token") Is Nothing Then
        '    '' Send the browser to Twitter, and send the URl of the page to come back to after authentication
        '    Response.Redirect(tw.GetAuthenticationLink(ConfigurationManager.AppSettings("ConsumerKey"), ConfigurationManager.AppSettings("ConsumerKeySecret"), "http://www.deep-shah.com/admin/admin_articles.aspx"))
        'Else
        '    '' Exchange the rquest token for an access token
        '    'tw.GetAccessTokens(ConfigurationManager.AppSettings("ConsumerKey"), ConfigurationManager.AppSettings("ConsumerKeySecret"), Request.QueryString("oauth_token"), Request.QueryString("oauth_verifier"))
        '    'oauthToken = tw.OAuth_Token
        '    'oauthSecret = tw.OAuth_TokenSecret            '' You've got all the tokensS now.  You can write them to a database, cookies, or whatever.
        'End If
        conn.ConnectionString = ConfigurationManager.ConnectionStrings("db").ConnectionString
        If Not Page.IsPostBack Then
            showlist()
            With ddlAdmin
                .DataSource = IST.DataAccess.GetDataTable("SELECT admin_id, admin_fname +'  '+admin_lname as adminame, admin_username, admin_password, admin_email, admin_last_login FROM administrator")
                .DataValueField = "admin_id"
                .DataTextField = "adminame"
                .DataBind()
                .Items.Insert(0, New ListItem("Select...", ""))
            End With
            With cbxlCats
                .DataSource = IST.DataAccess.GetDataTable("SELECT cat_id, cat_name FROM category WHERE cat_type = 'News'")
                .DataValueField = "cat_id"
                .DataTextField = "cat_name"
                .DataBind()
            End With
            
        End If
    End Sub
    Sub showlist()
        conn.ConnectionString = ConfigurationManager.ConnectionStrings("db").ConnectionString
        Dim adminSql As String
        If ViewState("sortField") = String.Empty Then
            ViewState("sortField") = "pst_date"
            ViewState("sortOrder") = "DESC"
        End If
        adminSql = " SELECT pst_id, pst_title, pst_summary, pst_text, pst_allow_comments, CONVERT(varchar,pst_date,101) as pst_date, pst_hidden, admin_id" & _
                                 " FROM posting "
        If txtSrchTitle.Text <> String.Empty Then
            adminSql &= " WHERE pst_title LIKE '%" & txtSrchTitle.Text.Replace("'", "''") & "%'"
        End If
   
        adminSql &= "ORDER BY " & ViewState("sortField") & " " & ViewState("sortOrder")
        With dtGrd
            .DataSource = IST.DataAccess.GetDataTable(adminSql)
        End With
        
        If dtGrd.Items.Count <= 1 Then
            If dtGrd.CurrentPageIndex <= dtGrd.PageCount And dtGrd.CurrentPageIndex > 0 Then
                dtGrd.CurrentPageIndex = dtGrd.CurrentPageIndex - 1
            End If
        End If
        
        dtGrd.DataBind()
        litPageHeader.Text="Articles"
        mvwMain.SetActiveView(vwGrid)
    End Sub
    Sub btnAdd_Click(ByVal s As Object, ByVal e As EventArgs)
        txtTitle.Text = ""
        txtSummary.Text = ""
        txtText.Text = ""
        txtDate.Text = DateTime.Today
        cbxAllow.Checked = True
        cbxHidden.Checked = False
        ddlAdmin.ClearSelection()
        cbxlCats.ClearSelection()
        ViewState("idVal") = ""
        btnSubmit.Text = "Add"
        litPageHeader.Text="Articles <small>Add</small>"
        mvwMain.SetActiveView(vwFrm)
    End Sub
    
    
    Sub btnCancel_Click(ByVal s As Object, ByVal e As EventArgs)
        litPageHeader.Text="Articles"
        mvwMain.SetActiveView(vwGrid)
    End Sub
    
    Sub btnSubmit_Click(ByVal s As Object, ByVal e As EventArgs)
        Dim flag As Char = "n"
        If Page.IsValid Then
            Dim sql As String
            If Len(ViewState("idVal")) = 0 Then
                sql = "INSERT INTO posting(pst_title, pst_summary, pst_text, pst_allow_comments, pst_date, pst_hidden, admin_id) VALUES" & _
                              "(@pst_title, @pst_summary, @pst_text, @pst_allow_comments, @pst_date, @pst_hidden, @admin_id); SELECT @@IDENTITY;"
                flag = "i"
            Else
                sql = "UPDATE posting SET pst_title=@pst_title, pst_summary=@pst_summary, pst_text=@pst_text, pst_allow_comments=@pst_allow_comments," & _
                       "pst_date=@pst_date, pst_hidden=@pst_hidden, admin_id=@admin_id WHERE pst_id = " & ViewState("idVal")
                flag = "u"
            End If
            Dim cmdSql As New SqlCommand(sql, conn)
            cmdSql.Parameters.AddWithValue("@pst_title", txtTitle.Text)
            If txtSummary.Text = "" Then
                cmdSql.Parameters.AddWithValue("@pst_summary", DBNull.Value)
            Else
                cmdSql.Parameters.AddWithValue("@pst_summary", txtSummary.Text)
            End If
            cmdSql.Parameters.AddWithValue("@pst_text", txtText.Text)
            cmdSql.Parameters.AddWithValue("@pst_date", txtDate.Text)
            If cbxAllow.Checked Then
                cmdSql.Parameters.AddWithValue("@pst_allow_comments", 1)
            Else
                cmdSql.Parameters.AddWithValue("@pst_allow_comments", 0)
            End If
            If cbxHidden.Checked Then
                cmdSql.Parameters.AddWithValue("@pst_hidden", 1)
            Else
                cmdSql.Parameters.AddWithValue("@pst_hidden", 0)
            End If
            cmdSql.Parameters.AddWithValue("@admin_id", ddlAdmin.SelectedItem.Value)
            conn.Open()

            If Len(ViewState("idVal")) = 0 Then
                ViewState("idVal") = cmdSql.ExecuteScalar
            Else
                cmdSql.ExecuteNonQuery()
            End If
            

            Dim tmpItem As ListItem
            cmdSql = New SqlCommand("DELETE FROM posting_category WHERE pst_id = " & ViewState("idVal"), conn)
            cmdSql.ExecuteNonQuery()
            For Each tmpItem In cbxlCats.Items
                If tmpItem.Selected Then
                    cmdSql = New SqlCommand("INSERT INTO posting_category (pst_id, cat_id) VALUES (" & ViewState("idVal") & ", " & CInt(tmpItem.Value) & ")", conn)
                    cmdSql.ExecuteNonQuery()
                End If
            Next
        
            conn.Close()
            showlist()
        End If
        
    End Sub
    
    Sub dgrdList_Command(ByVal s As Object, ByVal e As DataGridCommandEventArgs)
        Select Case e.CommandName
            Case "delete"
                Dim idVal As Integer = dtGrd.DataKeys(e.Item.ItemIndex)
                Dim sql As String = "DELETE FROM posting WHERE pst_id = " & idVal
                
                conn.Open()
                Dim cmdSql As SqlCommand
                cmdSql = New SqlCommand("DELETE FROM posting_category WHERE pst_id = " & idVal, conn)
                cmdSql.ExecuteNonQuery()
                cmdSql = New SqlCommand("DELETE FROM comment WHERE pst_id = " & idVal, conn)
                cmdSql.ExecuteNonQuery()
                cmdSql = New SqlCommand("DELETE FROM posting WHERE pst_id = " & idVal, conn)
                cmdSql.ExecuteNonQuery()
                conn.Close()
                
                showlist()
            Case "edit"
                Dim idVal As Integer = dtGrd.DataKeys(e.Item.ItemIndex)
                EditForm(idVal)
        End Select
    End Sub
    Sub EditForm(ByVal idVal As Integer)
        Dim sql As String = "SELECT pst_id, pst_title, pst_summary, pst_text, pst_allow_comments, CONVERT(varchar,pst_date,101) as pst_date, pst_hidden, admin_id FROM posting WHERE pst_id = " & idVal
        Dim dtb As DataTable = IST.DataAccess.GetDataTable(sql)
        
        If dtb.Rows.Count > 0 Then
            Dim dr As DataRow = dtb.Rows(0)
            
            txtTitle.Text = dr("pst_title").ToString
            txtSummary.Text = dr("pst_summary").ToString
            txtText.Text = dr("pst_text").ToString
            txtDate.Text = dr("pst_date").ToString
            cbxAllow.Checked = dr("pst_allow_comments")
            cbxHidden.Checked = dr("pst_hidden")
            ddlAdmin.SelectedValue = dr("admin_id")
            cbxlCats.ClearSelection()
            dtb = IST.DataAccess.GetDataTable("SELECT * FROM posting_category WHERE pst_id = " & idVal)
            For Each dr In dtb.Rows
                cbxlCats.Items.FindByValue(dr("cat_id")).Selected = True
            Next

            ViewState("idVal") = idVal
            btnSubmit.Text = "Update"
            litPageHeader.Text="Articles <small>Edit</small>"
            mvwMain.SetActiveView(vwFrm)
        End If
    End Sub
    Sub dtGrd_Paging(ByVal s As Object, ByVal e As DataGridPageChangedEventArgs)
        dtGrd.CurrentPageIndex = e.NewPageIndex
        showlist()
    End Sub
    
    Sub dtGrd_SortChange(ByVal s As Object, ByVal e As DataGridSortCommandEventArgs)
        ViewState("sortField") = e.SortExpression
        If ViewState("sortOrder") = "ASC" Then
            ViewState("sortOrder") = "DESC"
        Else
            ViewState("sortOrder") = "ASC"
        End If
        
        showlist()
    End Sub
    Sub btnSearch_Click(ByVal s As Object, ByVal e As EventArgs)
        dtGrd.CurrentPageIndex = 0
        showlist()
    End Sub

    
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css"
        rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4/jquery.min.js"></script>
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js"></script>
    <script type="text/javascript">
        $(function () {
            $("input[id$=txtDate]").datepicker();
        });
              
    </script>
</asp:Content>
<asp:Content ID="PageHeader" ContentPlaceHolderID="cpHoldPageHeader" runat="server">
    <asp:Literal ID="litPageHeader" runat="server">Articles</asp:Literal>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cpHoldMain" runat="Server">
    <asp:MultiView ID="mvwMain" runat="server">
        <asp:View ID="vwGrid" runat="server">
            <asp:Button ID="btnAdd" runat="server" Text="Add New" OnClick="btnAdd_Click" CssClass="btn success" />
            <div>
                <h3>
                    Search By</h3>
                Title
                <asp:TextBox ID="txtSrchTitle" runat="server" />
                <asp:Button ID="btnSearch" Text="Search" OnClick="btnSearch_Click" runat="server"
                    CssClass="btn" />
            </div>
            <br />
            <asp:DataGrid ID="dtGrd" runat="server" AutoGenerateColumns="false" DataKeyField="pst_id"
                OnItemCommand="dgrdList_Command" AllowPaging="true" OnPageIndexChanged="dtGrd_Paging"
                PageSize="3" PagerStyle-Mode="NumericPages" AllowSorting="true" OnSortCommand="dtGrd_SortChange"
                CssClass="bordered-table" HeaderStyle-CssClass="gridHead">
                <Columns>
                    <asp:BoundColumn DataField="pst_title" HeaderText="Title" SortExpression="pst_title">
                    </asp:BoundColumn>
                    <asp:BoundColumn DataField="pst_date" HeaderText="Date" SortExpression="pst_date">
                    </asp:BoundColumn>
                    <asp:TemplateColumn>
                        <ItemTemplate>
                            <asp:LinkButton ID="btnEdit" Text="Edit" CommandName="edit" CssClass="btn small"
                                runat="server" />
                            <asp:LinkButton ID="btnDel" CommandName="delete" Text="Delete" OnClientClick="javascript:return confirm('Are you sure you want to delete this record?');"
                                runat="server" CssClass="btn small" />
                        </ItemTemplate>
                    </asp:TemplateColumn>
                </Columns>
            </asp:DataGrid>
        </asp:View>
        <asp:View ID="vwFrm" runat="server">
            <form>
            <fieldset>
                <div class="clearfix">
                    <label for="txtTitle">
                        Title</label>
                    <div class="input">
                        <asp:TextBox ID="txtTitle" runat="server" Width="500" ClientIDMode="Static"></asp:TextBox><asp:RequiredFieldValidator ErrorMessage="Required" ControlToValidate="txtTitle"
                        ID="reqtxtTitle" runat="server"></asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="clearfix">
                    <label for="txtSummary">Summary</label>
                    <div class="input">
                        <asp:TextBox ID="txtSummary" runat="server" TextMode="MultiLine" Width="500" Height="100" ClientIDMode="Static"></asp:TextBox>
                    </div>
                </div>
                <div class="clearfix">
                    <label for="txtText">Text</label>
                    <div class="input">
                        <asp:TextBox ID="txtText" runat="server" TextMode="MultiLine" Height="200" Width="500" ClientIDMode="Static"></asp:TextBox><asp:RequiredFieldValidator ErrorMessage="Required" ControlToValidate="txtText" ID="reqtxtText"
                        runat="server"></asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="clearfix">
                    <label for="txtDate">Date</label>
                    <div class="input">
                    <asp:TextBox ID="txtDate" runat="server" ClientIDMode="Static"></asp:TextBox>
                     <asp:RequiredFieldValidator ErrorMessage="Required" ControlToValidate="txtDate" ID="reqtxtDate"
                        runat="server" Display="Dynamic"></asp:RequiredFieldValidator>
                    <asp:RegularExpressionValidator ControlToValidate="txtDate" ID="regtxtDate" runat="server"
                        ErrorMessage="Invalid Date" ValidationExpression="^\d{1,2}\/\d{1,2}\/\d{4}$"></asp:RegularExpressionValidator>
                    </div>
                </div>
                <div class="clearfix">
                    <label for="cbxHidden">Hidden</label>
                    <div class="input">
                     <asp:CheckBox ID="cbxHidden" runat="server" />
                    </div>
                </div>
                <div class="clearfix">
                    <label for="cbxAllow">Allow Comments</label>
                    <div class="input">
                        <asp:CheckBox ID="cbxAllow" runat="server" />
                    </div>
                </div>
                <div class="clearfix">
                    <label for="ddlAdmin">Admin</label>
                    <div class="input">
                        <asp:DropDownList ID="ddlAdmin" runat="server">
                    </asp:DropDownList>
                    <asp:RequiredFieldValidator ErrorMessage="Required" ControlToValidate="ddlAdmin"
                        ID="reqddlAdmin" runat="server"></asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="clearfix">
                    <label for="cbxlCats">Categories</label>
                    <div class="input">
                     <asp:CheckBoxList ID="cbxlCats" runat="server" class="bordered-table">
                    </asp:CheckBoxList>
                    </div>
                </div>
               
            </fieldset>
            <div class="actions">
            <asp:Button ID="btnSubmit" Text="Add" OnClick="btnSubmit_Click" runat="server" CssClass="btn primary" />
            <asp:Button ID="btnCancel" Text="Cancel" OnClick="btnCancel_Click" CausesValidation="false"
                        runat="server" CssClass="btn" />
            </div>
            </form>
        </asp:View>
    </asp:MultiView>
</asp:Content>
