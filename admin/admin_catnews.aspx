<%@ Page Title="" Language="VB" MasterPageFile="admin.master" %>
<%@ Register TagPrefix="asp" Namespace="AjaxControlToolkit" Assembly="AjaxControlToolkit"%>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="TwitterVB2" %>
<script runat="server">
    Dim conn As New SqlConnection
    Sub page_load()
        
        conn.ConnectionString = ConfigurationManager.ConnectionStrings("db").ConnectionString
        If Not Page.IsPostBack Then
            showlist()
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
        litPageHeader.Text="CATNews"
        mvwMain.SetActiveView(vwGrid)
    End Sub
    Sub btnAdd_Click(ByVal s As Object, ByVal e As EventArgs)
        txtTitle.Text = ""
        txtText.Text = ""
        txtDate.Text = DateTime.Today
        cbxHidden.Checked = False
        lblAdmin.Text = HttpContext.Current.User.Identity.Name
        cbxlCats.ClearSelection()
        ViewState("idVal") = ""
        btnSubmit.Text = "Add"
        litPageHeader.Text="CATNews <small>Add</small>"
        mvwMain.SetActiveView(vwFrm)
    End Sub
    
    
    Sub btnCancel_Click(ByVal s As Object, ByVal e As EventArgs)
        litPageHeader.Text="CATNews"
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
            cmdSql.Parameters.AddWithValue("@pst_summary", DBNull.Value)
            cmdSql.Parameters.AddWithValue("@pst_text", txtText.Text)
            cmdSql.Parameters.AddWithValue("@pst_date", txtDate.Text)
            cmdSql.Parameters.AddWithValue("@pst_allow_comments", 1)

            If cbxHidden.Checked Then
                cmdSql.Parameters.AddWithValue("@pst_hidden", 1)
            Else
                cmdSql.Parameters.AddWithValue("@pst_hidden", 0)
            End If
            cmdSql.Parameters.AddWithValue("@admin_id",IST.DataAccess.GetAdminId(HttpContext.Current.User.Identity.Name))
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
        Dim sql As String = "SELECT pst_id, pst_title, pst_summary, pst_text, CONVERT(varchar,pst_date,101) as pst_date, pst_hidden, admin_id FROM posting WHERE pst_id = " & idVal
        Dim dtb As DataTable = IST.DataAccess.GetDataTable(sql)
        
        If dtb.Rows.Count > 0 Then
            Dim dr As DataRow = dtb.Rows(0)
            
            txtTitle.Text = dr("pst_title").ToString
            txtText.Text = dr("pst_text").ToString
            txtDate.Text = dr("pst_date").ToString
            cbxHidden.Checked = dr("pst_hidden")
            lblAdmin.Text = HttpContext.Current.User.Identity.Name
            cbxlCats.ClearSelection()
            dtb = IST.DataAccess.GetDataTable("SELECT * FROM posting_category WHERE pst_id = " & idVal)
            For Each dr In dtb.Rows
                cbxlCats.Items.FindByValue(dr("cat_id")).Selected = True
            Next

            ViewState("idVal") = idVal
            btnSubmit.Text = "Update"
            litPageHeader.Text="CATNews <small>Edit</small>"
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
    <asp:Literal ID="litPageHeader" runat="server">CATNews</asp:Literal>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cpHoldMain" runat="Server">
    <asp:MultiView ID="mvwMain" runat="server">
        <asp:View ID="vwGrid" runat="server">
            <asp:Button ID="btnAdd" runat="server" Text="Add New" OnClick="btnAdd_Click" CssClass="btn btn-large btn-success" />
            <div class="well form-search">
                Title
                <asp:TextBox ID="txtSrchTitle" runat="server" CssClass="input-medium search-query"/>
                <asp:Button ID="btnSearch" Text="Search" OnClick="btnSearch_Click" runat="server"
                    CssClass="btn" />
            </div>
            <br />
            <asp:DataGrid ID="dtGrd" runat="server" AutoGenerateColumns="false" DataKeyField="pst_id"
                OnItemCommand="dgrdList_Command" AllowPaging="true" OnPageIndexChanged="dtGrd_Paging"
                PageSize="3" PagerStyle-Mode="NumericPages" AllowSorting="true" OnSortCommand="dtGrd_SortChange"
                CssClass="table table-bordered">
                <Columns>
                    <asp:BoundColumn DataField="pst_title" HeaderText="Title" SortExpression="pst_title">
                    </asp:BoundColumn>
                    <asp:BoundColumn DataField="pst_date" HeaderText="Date" SortExpression="pst_date">
                    </asp:BoundColumn>
                    <asp:TemplateColumn HeaderText="Hidden" SortExpression="pst_hidden">
                        <ItemTemplate>
                            <asp:CheckBox ID="chkHidden" runat="server" Checked='<%# Eval("pst_hidden") %>' Enabled="false"  />
                        </ItemTemplate>
                    </asp:TemplateColumn>
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
            <div class="form-horizontal">
            <fieldset>
                <div class="control-group">
                    <label for="txtTitle">
                        Title</label>
                    <div class="controls">
                        <asp:TextBox ID="txtTitle" runat="server" Width="500" ClientIDMode="Static"></asp:TextBox><asp:RequiredFieldValidator ErrorMessage="Required" ControlToValidate="txtTitle"
                        ID="reqtxtTitle" runat="server"></asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label for="txtText">Text</label>
                    <div class="controls">
                        <asp:TextBox ID="txtText" runat="server" TextMode="MultiLine" Height="200" Width="500" ClientIDMode="Static"></asp:TextBox><asp:RequiredFieldValidator ErrorMessage="Required" ControlToValidate="txtText" ID="reqtxtText"
                        runat="server"></asp:RequiredFieldValidator>
                        <asp:HtmlEditorExtender ID="HtmlEditorExtender2"
                            TargetControlID="txtText"
                         runat="server" />
                    </div>
                </div>
                <div class="control-group">
                    <label for="txtDate">Date</label>
                    <div class="controls">
                    <asp:TextBox ID="txtDate" runat="server" ClientIDMode="Static"></asp:TextBox>
                     <asp:RequiredFieldValidator ErrorMessage="Required" ControlToValidate="txtDate" ID="reqtxtDate"
                        runat="server" Display="Dynamic"></asp:RequiredFieldValidator>
                    <asp:RegularExpressionValidator ControlToValidate="txtDate" ID="regtxtDate" runat="server"
                        ErrorMessage="Invalid Date" ValidationExpression="^\d{1,2}\/\d{1,2}\/\d{4}$"></asp:RegularExpressionValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label for="cbxHidden">Hidden</label>
                    <div class="controls">
                     <asp:CheckBox ID="cbxHidden" runat="server" />
                    </div>
                </div>
                <div class="control-group">
                    <label for="cbxlCats">Categories</label>
                    <div class="controls">
                     <asp:CheckBoxList ID="cbxlCats" runat="server" CssClass="checkBoxLst">
                    </asp:CheckBoxList>
                    </div>
                </div>
                <div class="control-group">
                    <label for="lblAdmin" class="control-label">
                        Last Editor
                    </label>
                    <div class="controls">
                    <asp:Label ID="lblAdmin" runat="server">
                    </asp:Label>
                    </div>
                </div>
            </fieldset>
            <div class="form-actions">
            <asp:Button ID="btnSubmit" Text="Add" OnClick="btnSubmit_Click" runat="server" CssClass="btn btn-primary" />
            <asp:Button ID="btnCancel" Text="Cancel" OnClick="btnCancel_Click" CausesValidation="false"
                        runat="server" CssClass="btn" />
            </div>
            </div>
        </asp:View>
    </asp:MultiView>
</asp:Content>
