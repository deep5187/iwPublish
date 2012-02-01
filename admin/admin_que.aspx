<%@ Page Title="" Language="VB" MasterPageFile="admin.master"  %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="TwitterVB2" %>
<script runat="server">
    Dim conn As New SqlConnection
    Shared cntTilClick As Integer = 0
    Shared cntDateClick As Integer
    Dim optionsTxtBox    As List(Of TextBox) = New List(Of TextBox)

    Sub page_load()
        If Not Page.IsPostBack Then
           showlist()
            With ddlAdmin
                .DataSource = IST.DataAccess.GetDataTable("SELECT admin_id, admin_fname +'  '+admin_lname as adminame, admin_username, admin_password, admin_email, admin_last_login FROM administrator")
                .DataValueField = "admin_id"
                .DataTextField = "adminame"
                .DataBind()
                .Items.Insert(0, New ListItem("Select...", ""))
            End With
        End If
        conn.ConnectionString = ConfigurationManager.ConnectionStrings("db").ConnectionString
    End Sub

    Sub showlist()
        conn.ConnectionString = ConfigurationManager.ConnectionStrings("db").ConnectionString
        Dim adminSql As String
        If ViewState("sortField") = String.Empty Then
            ViewState("sortField") = "q_date"
            ViewState("sortOrder") = "DESC"
        End If
        adminSql = " SELECT q_id, q_name, q_text, q_solution, CONVERT(varchar,q_date,101) as q_date, q_hidden, admin_id" & _
                                 " FROM question "
        If txtSrchName.Text <> String.Empty Then
            adminSql &= " WHERE q_name LIKE '%" & txtSrchName.Text.Replace("'", "''") & "%'"
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
        litPageHeader.Text="Questions"
        mvwMain.SetActiveView(vwGrid)
    End Sub

    
    Sub btnAdd_Click(ByVal s As Object, ByVal e As EventArgs)
        txtQueName.Text = ""
        txtQueText.Text = ""
        txtDate.Text = DateTime.Today
        cbxHidden.Checked = False
        ddlAdmin.ClearSelection()
        cbxlCats.ClearSelection()
        ViewState("idVal") = ""
        btnSubmit.Text = "Add and Continue"
        litPageHeader.Text="Questions <small>Add</small>"
        mvwMain.SetActiveView(vwFrm)
    End Sub
    
    
    Sub btnCancel_Click(ByVal s As Object, ByVal e As EventArgs)
        litPageHeader.Text="Questions"
        mvwMain.SetActiveView(vwGrid)
    End Sub
    
    Sub btnSubmit_Click(ByVal s As Object, ByVal e As EventArgs)
    Dim flag As Char = "n"
        If Page.IsValid Then
            Dim sql As String
            If Len(ViewState("idVal")) = 0 Then
                sql = "INSERT INTO question(q_name, q_text, q_date, q_hidden, admin_id) VALUES" & _
                              "(@q_name, @q_text, @q_date, @q_hidden, @admin_id); SELECT @@IDENTITY;"
                flag = "i"
            Else
                sql = "UPDATE question SET q_name=@q_name, q_text=@q_text," & _
                      "q_date=@q_date, q_hidden=@q_hidden, admin_id=@admin_id WHERE q_id = " & ViewState("idVal")
                flag = "u"
            End If
            Dim cmdSql As New SqlCommand(sql, conn)
            cmdSql.Parameters.AddWithValue("@q_name", txtQueName.Text)
            
            cmdSql.Parameters.AddWithValue("@q_text", txtQueText.Text)
            cmdSql.Parameters.AddWithValue("@q_date", txtDate.Text)
     
            If cbxHidden.Checked Then
                cmdSql.Parameters.AddWithValue("@q_hidden", 1)
            Else
                cmdSql.Parameters.AddWithValue("@q_hidden", 0)
            End If
            cmdSql.Parameters.AddWithValue("@admin_id", ddlAdmin.SelectedItem.Value)
            conn.Open()

            If Len(ViewState("idVal")) = 0 Then
                ViewState("idVal") = cmdSql.ExecuteScalar
            Else
                cmdSql.ExecuteNonQuery()
            End If
            

            'Dim tmpItem As ListItem
            'cmdSql = New SqlCommand("DELETE FROM posting_category WHERE pst_id = " & ViewState("idVal"), conn)
            'cmdSql.ExecuteNonQuery()
            'For Each tmpItem In cbxlCats.Items
            '    If tmpItem.Selected Then
            '        cmdSql = New SqlCommand("INSERT INTO posting_category (pst_id, cat_id) VALUES (" & ViewState("idVal") & ", " & CInt(tmpItem.Value) & ")", conn)
            '        cmdSql.ExecuteNonQuery()
            '    End If
            'Next
        
            conn.Close()
            
            FillOptionsGrid()
        End If
    End Sub
    
    Sub dgrdList_Command(ByVal s As Object, ByVal e As DataGridCommandEventArgs)
       Select Case e.CommandName
            Case "delete"
                Dim idVal As Integer = dtGrd.DataKeys(e.Item.ItemIndex)
                Dim sql As String = "DELETE FROM [option] WHERE q_id = " & idVal
                
                conn.Open()
                Dim cmdSql As SqlCommand
                cmdSql = New SqlCommand("DELETE FROM [option] WHERE q_id = " & idVal, conn)
                cmdSql.ExecuteNonQuery()
                cmdSql = New SqlCommand("DELETE FROM question WHERE q_id = " & idVal, conn)
                cmdSql.ExecuteNonQuery()
                conn.Close()
                showlist()
            Case "edit"
                Dim idVal As Integer = dtGrd.DataKeys(e.Item.ItemIndex)
                EditForm(idVal)
        End Select
    End Sub
    Sub EditForm(ByVal idVal As Integer)
       Dim sql As String = "SELECT q_id, q_name, q_text, q_solution, CONVERT(varchar,q_date,101) as q_date, q_hidden, admin_id FROM question WHERE q_id = " & idVal
       Dim dtb As DataTable = IST.DataAccess.GetDataTable(sql)
        
        If dtb.Rows.Count > 0 Then
            Dim dr As DataRow = dtb.Rows(0)
            
            txtQueName.Text = dr("q_name").ToString
            txtQueText.Text = dr("q_text").ToString
            txtDate.Text = dr("q_date").ToString
            If Not Convert.IsDBNull(dr("q_hidden"))
                cbxHidden.Checked = dr("q_hidden")
            Else
                cbxHidden.Checked = false
            End If
            
            ddlAdmin.SelectedValue = dr("admin_id")
            cbxlCats.ClearSelection()
            'dtb = IST.DataAccess.GetDataTable("SELECT * FROM posting_category WHERE pst_id = " & idVal)
            'For Each dr In dtb.Rows
            '    cbxlCats.Items.FindByValue(dr("cat_id")).Selected = True
            'Next

            ViewState("idVal") = idVal
            btnSubmit.Text = "Update and Continue"
            litPageHeader.Text="Questions <small>Edit</small>"
            mvwMain.SetActiveView(vwFrm)
        End If
    End Sub
    Sub dtGrd_Paging(ByVal s As Object, ByVal e As DataGridPageChangedEventArgs)
       
    End Sub
    
    Sub dtGrd_SortChange(ByVal s As Object, ByVal e As DataGridSortCommandEventArgs)
        
    End Sub
    Sub btnSearch_Click(ByVal s As Object, ByVal e As EventArgs)
        
    End Sub
    Sub btnFinish_Click(ByVal s As Object, ByVal e As EventArgs)
        showlist()
    End Sub
    
    Sub FillOptionsGrid()
        Dim idVal As Integer = CType(ViewState("idVal"),Integer)
        conn.ConnectionString = ConfigurationManager.ConnectionStrings("db").ConnectionString
        Dim optionSql As String
        If ViewState("sortField") = String.Empty Then
            ViewState("sortField") = "q_date"
            ViewState("sortOrder") = "DESC"
        End If
        optionSql = " SELECT opt_id,opt_text,q_id as opt_id,opt_text,q_id from [option] WHERE q_id=" & idVal
        
        Dim dt As DataTable  = IST.DataAccess.GetDataTable(optionSql)
        If dt.Rows.Count>0 then
            With grdOptions
                .DataSource = dt
                .DataBind()
            End With
        Else
            dt.Rows.Add(dt.NewRow())
            With grdOptions
                .DataSource = dt
                .DataBind()
            End With
            
            Dim TotalColumns As Integer = grdOptions.Columns.Count
            With grdOptions.Rows(0)
                .Cells.Clear
                .Cells.Add(new TableCell())
                .Cells(0).ColumnSpan = TotalColumns
                .Cells(0).Text = "No Options Added Yet..."
            End With
        End If
        litPageHeader.Text="Options"
        mvwMain.SetActiveView(vwFrmOptions)
    End Sub
    Sub grdOptions_RowDataBound(sender as Object,e as GridViewRowEventArgs)
    
    End Sub
    Sub grdOptions_RowEditing(sender As object,e As GridViewEditEventArgs)
         grdOptions.EditIndex = e.NewEditIndex
        FillOptionsGrid()
    End Sub
    Sub grdOptions_RowCancelingEdit(sender As Object, e As GridViewCancelEditEventArgs)
        grdOptions.EditIndex=-1
        FillOptionsGrid()
    End Sub
    Sub grdOptions_RowUpdating(sender As Object, e as GridViewUpdateEventArgs )
        Dim sql As String
       
        Dim txtOptionTxt As TextBox = CType(grdOptions.Rows(e.RowIndex).FindControl("txtOptText"),TextBox)
        sql = "UPDATE [option] SET opt_text = @opt_text WHERE opt_id = "& grdOptions.DataKeys(e.RowIndex).Value.ToString
        
        Dim cmdSql As New SqlCommand(sql, conn)
        
        cmdSql.Parameters.AddWithValue("@opt_text", txtOptionTxt.Text)
        conn.Open()
        cmdSql.ExecuteNonQuery
        conn.Close()
        grdOptions.EditIndex = -1
        FillOptionsGrid()
    End Sub
    Sub grdOptions_RowDeleting(sender As object,e As GridViewDeleteEventArgs)
         Dim sql As String
         Dim idVal As Integer = CType(grdOptions.DataKeys(e.RowIndex).Value,Integer)
         sql = "DELETE FROM [option] WHERE opt_id = "& idVal
         Dim cmdSql As New SqlCommand(sql, conn)
        conn.Open()
        cmdSql.ExecuteNonQuery()
        conn.Close()
        FillOptionsGrid()
    End Sub
    Sub grdOptions_RowCommand(sender As object ,e As GridViewCommandEventArgs)
        Dim IdVal As Integer = CType(ViewState("idVal"),Integer)
        Dim sql As String
        If e.CommandName.Equals("Insert")
            sql = "INSERT INTO [option](opt_text,q_id) VALUES (@opt_text,@q_id)"
            Dim cmdSql As New SqlCommand(sql, conn)
            cmdSql.Parameters.AddWithValue("@opt_text", CType(grdOptions.FooterRow.FindControl("txtNewOption"),TextBox).Text)
            cmdSql.Parameters.AddWithValue("@q_id", IdVal)
            conn.Open()
            ViewState("idOptVal") = cmdSql.ExecuteScalar()
            conn.Close()
            FillOptionsGrid()
        End If
        
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
                Name
                <asp:TextBox ID="txtSrchName" runat="server" />
                <br />
                Text
                <asp:TextBox ID="txtSrchText" runat="server" />
                <asp:Button ID="btnSearch" Text="Search" OnClick="btnSearch_Click" runat="server"
                    CssClass="btn" />
            </div>
            <br />
            <asp:DataGrid ID="dtGrd" runat="server" AutoGenerateColumns="false" DataKeyField="q_id"
                OnItemCommand="dgrdList_Command" AllowPaging="true" OnPageIndexChanged="dtGrd_Paging"
                PageSize="3" PagerStyle-Mode="NumericPages" AllowSorting="true" OnSortCommand="dtGrd_SortChange"
                CssClass="bordered-table" HeaderStyle-CssClass="gridHead">
                <Columns>
                    <asp:BoundColumn DataField="q_name" HeaderText="Name" SortExpression="q_name">
                    </asp:BoundColumn>
                    <asp:BoundColumn DataField="q_date" HeaderText="Date" SortExpression="q_date">
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
                    <label for="txtQueName">
                        Question Name
                    </label>
                    <asp:TextBox ID="txtQueName" runat="server" ClientIDMode="Static"></asp:TextBox>

                </div>
                <div class="clearfix">
                    <label for="txtQueText">
                        Question Text</label>
                    <div class="input">
                        <asp:TextBox ID="txtQueText" runat="server" TextMode="MultiLine" Height="200" Width="500" ClientIDMode="Static"></asp:TextBox><asp:RequiredFieldValidator ErrorMessage="Required" ControlToValidate="txtQueText"
                        ID="reqtxtTitle" runat="server"></asp:RequiredFieldValidator>
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
            <asp:Button ID="btnSubmit" Text="Add and Continue" OnClick="btnSubmit_Click" runat="server" CssClass="btn primary" />
            <asp:Button ID="btnCancel" Text="Cancel" OnClick="btnCancel_Click" CausesValidation="false"
                        runat="server" CssClass="btn" />
            </div>
            </form>
        </asp:View>
        <asp:View ID="vwFrmOptions" runat="server">
            <asp:GridView ID="grdOptions" runat="server" AutoGenerateColumns="False" DataKeyNames="opt_id"
                OnRowCancelingEdit="grdOptions_RowCancelingEdit" OnRowDataBound="grdOptions_RowDataBound"
                OnRowEditing="grdOptions_RowEditing" OnRowUpdating="grdOptions_RowUpdating" OnRowCommand="grdOptions_RowCommand"
                ShowFooter="True" OnRowDeleting="grdOptions_RowDeleting">
                <Columns>
                    <%--<asp:TemplateField HeaderText="ID" HeaderStyle-HorizontalAlign="Left">
                                        <EditItemTemplate>
                                            <asp:Label ID="lblId" runat="server" Text='<%# Bind("opt_id") %>'></asp:Label>
                                        </EditItemTemplate>
                                        <ItemTemplate>
                                            <asp:Label ID="lblId" runat="server" Text='<%# Bind("opt_id") %>'></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField>--%>
                    <asp:TemplateField HeaderText="Option Text" HeaderStyle-HorizontalAlign="Left">
                        <EditItemTemplate>
                            <asp:TextBox ID="txtOptText" runat="server" Text='<%# Bind("opt_text") %>'></asp:TextBox>
                        </EditItemTemplate>
                        <FooterTemplate>
                            <asp:TextBox ID="txtNewOption" runat="server"></asp:TextBox>
                        </FooterTemplate>
                        <ItemTemplate>
                            <asp:Label ID="lblOptionText" runat="server" Text='<%# Bind("opt_text") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Edit" ShowHeader="False" HeaderStyle-HorizontalAlign="Left">
                        <EditItemTemplate>
                            <asp:LinkButton ID="lbkUpdate" runat="server" CausesValidation="True" CommandName="Update"
                                Text="Update"></asp:LinkButton>
                            <asp:LinkButton ID="lnkCancel" runat="server" CausesValidation="False" CommandName="Cancel"
                                Text="Cancel"></asp:LinkButton>
                        </EditItemTemplate>
                        <FooterTemplate>
                            <asp:LinkButton ID="lnkAdd" runat="server" CausesValidation="False" CommandName="Insert"
                                Text="Insert"></asp:LinkButton>
                        </FooterTemplate>
                        <ItemTemplate>
                            <asp:LinkButton ID="lnkEdit" runat="server" CausesValidation="False" CommandName="Edit"
                                Text="Edit"></asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:CommandField HeaderText="Delete" ShowDeleteButton="True" ShowHeader="True" />
                </Columns>
            </asp:GridView>
            <div class="actions">
            <asp:Button ID="btnFinish" Text="Finish" OnClick="btnFinish_Click" runat="server" CssClass="btn primary" />
            </div>     
        </asp:View>
    </asp:MultiView>
</asp:Content>
