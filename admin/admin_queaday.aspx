<%@ Page Title="" Language="VB" MasterPageFile="admin.master"  %>
<%@ Import Namespace="System.IO" %>
<%@ Register Assembly="CKEditor.NET" Namespace="CKEditor.NET" TagPrefix="CKEditor" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="TwitterVB2" %>
<script runat="server">
    Dim conn As New SqlConnection
    Private Const VirtualFileRoot As String = "~/files/images/"
    Sub page_load()
        If Not Page.IsPostBack Then
           showlist()
           With cbxlCats
                .DataSource = IST.DataAccess.GetDataTable("SELECT cat_id, cat_name FROM category WHERE cat_type = 'Question'")
                .DataValueField = "cat_id"
                .DataTextField = "cat_name"
                .DataBind()
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
        adminSql = " SELECT q_id, q_name, CONVERT(varchar,q_date,101) as q_date, q_hidden" & _
                                 " FROM question "
        If txtSrchName.Text <> String.Empty Then
            adminSql &= " WHERE q_name LIKE '%" & txtSrchName.Text.Replace("'", "''") & "%'"
        End If
   
        adminSql &= "ORDER BY " & ViewState("sortField") & " " & ViewState("sortOrder") & ", q_id DESC" 
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
        txtQueSolution.Text=""
        txtQueHint.Text=""
        txtQueInstruction.Text=""
        imgDiagram.ImageUrl="../images/noimage.png"
        imgDiagramUrl.Value=""
        txtDate.Text = DateTime.Today
        cbxHidden.Checked = True
        cbxlCats.ClearSelection()
        ViewState("idVal") = ""
        lblAdmin.Text = HttpContext.Current.User.Identity.Name
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
                sql = "INSERT INTO question(q_name, q_text,q_hint,q_solution,q_instruction, q_date, q_hidden,q_diagram, admin_id) VALUES" & _
                              "(@q_name, @q_text,@q_hint,@q_solution,@q_instruction, @q_date, @q_hidden,@q_diagram, @admin_id); SELECT @@IDENTITY;"
                flag = "i"
            Else
                sql = "UPDATE question SET q_name=@q_name, q_text=@q_text,q_instruction=@q_instruction,q_hint=@q_hint, q_solution=@q_solution," & _
                      "q_date=@q_date, q_hidden=@q_hidden,q_diagram=@q_diagram, admin_id = @admin_id WHERE q_id = " & ViewState("idVal")
                flag = "u"
            End If
            Dim cmdSql As New SqlCommand(sql, conn)
            'storing image if it has been uploaded
            If imgUpload.HasFile Then 
                Dim charsToTrim() As Char = {"*", " ", "\"}
                Dim guid As Guid = System.Guid.NewGuid()
                imgUpload.SaveAs(Server.MapPath(VirtualFileRoot & "/") & guid.ToString() & imgUpload.FileName.Trim(charsToTrim))
                cmdSql.Parameters.AddWithValue("@q_diagram", guid.ToString() & imgUpload.FileName.Trim(charsToTrim))
                'Deleting the old file once we have uploaded the new file
                If imgDiagramUrl.Value IsNot "" Then
                    If File.Exists(Server.MapPath(VirtualFileRoot & "/") & imgDiagramUrl.Value) Then
                        File.Delete(Server.MapPath(VirtualFileRoot & "/") & imgDiagramUrl.Value)
                    End If
                End If
            Else
                'if now new file specified then restore the previous value
                If imgDiagramUrl.Value = "" Then
                    cmdSql.Parameters.AddWithValue("@q_diagram", DBNull.Value)
                Else
                    cmdSql.Parameters.AddWithValue("@q_diagram", imgDiagramUrl.Value)
                End If
            End If
            cmdSql.Parameters.AddWithValue("@q_name", txtQueName.Text)
            
            cmdSql.Parameters.AddWithValue("@q_text", txtQueText.Text)
            cmdSql.Parameters.AddWithValue("@q_date", txtDate.Text)
            cmdSql.Parameters.AddWithValue("@q_solution",txtQueSolution.Text)
            If txtQueHint.Text <> ""
                cmdSql.Parameters.AddWithValue("@q_hint",txtQueHint.Text)
            Else 
                cmdSql.Parameters.AddWithValue("@q_hint",DBNull.Value)
            End If
            cmdSql.Parameters.AddWithValue("@q_instruction",txtQueInstruction.text)
            If cbxHidden.Checked Then
                cmdSql.Parameters.AddWithValue("@q_hidden", 1)
            Else
                cmdSql.Parameters.AddWithValue("@q_hidden", 0)
            End If
            
            
            cmdSql.Parameters.AddWithValue("@admin_id",IST.DataAccess.GetAdminId(HttpContext.Current.User.Identity.Name))
            
            conn.Open()

            If Len(ViewState("idVal")) = 0 Then
                ViewState("idVal") = cmdSql.ExecuteScalar
            Else
                cmdSql.ExecuteNonQuery()
            End If
            

            Dim tmpItem As ListItem
            cmdSql = New SqlCommand("DELETE FROM question_category WHERE q_id = " & ViewState("idVal"), conn)
            cmdSql.ExecuteNonQuery()
            For Each tmpItem In cbxlCats.Items
                If tmpItem.Selected Then
                    cmdSql = New SqlCommand("INSERT INTO question_category (q_id, cat_id) VALUES (" & ViewState("idVal") & ", " & CInt(tmpItem.Value) & ")", conn)
                    cmdSql.ExecuteNonQuery()
                End If
            Next
        
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
       Dim sql As String = "SELECT q_id, q_name, q_text,isnull(q_hint,'') as q_hint, isnull(q_solution,'') as q_solution,isnull(q_instruction,'') as q_instruction, CONVERT(varchar,q_date,101) as q_date, q_hidden,q_diagram, admin_id FROM question WHERE q_id = " & idVal
       Dim dtb As DataTable = IST.DataAccess.GetDataTable(sql)
        
        If dtb.Rows.Count > 0 Then
            Dim dr As DataRow = dtb.Rows(0)
            lblAdmin.Text = HttpContext.Current.User.Identity.Name
            txtQueName.Text = dr("q_name").ToString
            txtQueText.Text = dr("q_text").ToString
            txtQueSolution.Text = dr("q_solution").ToString
            txtQueHint.Text= dr("q_hint").ToString
            txtQueInstruction.Text = dr("q_instruction").ToString
            txtDate.Text = dr("q_date").ToString
            If Not Convert.IsDBNull(dr("q_hidden"))
                cbxHidden.Checked = dr("q_hidden")
            Else
                cbxHidden.Checked = false
            End If
            
            
            If Not Convert.IsDBNull(dr("q_diagram"))
                If Request.IsLocal Then
                    imgDiagram.ImageUrl = "http://" & Request.Url.Authority & "/iwPublish/files/images/" & dr("q_diagram").ToString
                Else    
                    imgDiagram.ImageUrl = "http://" & Request.Url.Authority & "/files/images/" & dr("q_diagram").ToString
                End If
                
                imgDiagramUrl.Value = dr("q_diagram").ToString
            Else
                imgDiagram.ImageUrl = "../images/noimage.png"
                imgDiagramUrl.Value=""
                
            End If
            cbxlCats.ClearSelection()
            dtb = IST.DataAccess.GetDataTable("SELECT * FROM question_category WHERE q_id = " & idVal)
            For Each dr In dtb.Rows
                cbxlCats.Items.FindByValue(dr("cat_id")).Selected = True
            Next

            ViewState("idVal") = idVal
            btnSubmit.Text = "Update and Continue"
            litPageHeader.Text="Questions <small>Edit</small>"
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
    Sub btnFinish_Click(ByVal s As Object, ByVal e As EventArgs)
        showlist()
    End Sub
    
    Sub FillOptionsGrid()
        Dim idVal As Integer = CType(ViewState("idVal"),Integer)
        conn.ConnectionString = ConfigurationManager.ConnectionStrings("db").ConnectionString
        Dim optionSql As String
        optionSql = " SELECT opt_id,opt_text,q_id,opt_correct from [option] WHERE q_id=" & idVal
        Dim dt As DataTable  = IST.DataAccess.GetDataTable(optionSql)
        If dt.Rows.Count>0 then
            With grdOptions
                .DataSource = dt
                .DataBind()
            End With
        Else
            dt.Rows.Add(dt.NewRow())
            For Each dr As DataRow In dt.Rows
                dr("opt_correct") = False
            Next
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
        If Not litPageHeader.Text.Contains("Options") Then
          
        litPageHeader.Text=litPageHeader.Text & " > Options"
        End If
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
        sql = "UPDATE [option] SET opt_text = @opt_text, opt_correct = @opt_correct WHERE opt_id = "& grdOptions.DataKeys(e.RowIndex).Value.ToString
        
        Dim cmdSql As New SqlCommand(sql, conn)
        
        cmdSql.Parameters.AddWithValue("@opt_text", txtOptionTxt.Text)
        cmdSql.Parameters.AddWithValue("@opt_correct",CType(grdOptions.Rows(e.RowIndex).FindControl("chkCorrectEdit"),CheckBox).Checked)
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
            sql = "INSERT INTO [option](opt_text,q_id,opt_correct) VALUES (@opt_text,@q_id,@opt_correct)"
            Dim cmdSql As New SqlCommand(sql, conn)
            cmdSql.Parameters.AddWithValue("@opt_text", CType(grdOptions.FooterRow.FindControl("txtNewOption"),TextBox).Text)
            cmdSql.Parameters.AddWithValue("@q_id", IdVal)
            cmdSql.Parameters.AddWithValue("@opt_correct",CType(grdOptions.FooterRow.FindControl("chkCorrectAdd"),CheckBox).Checked)
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
            <asp:Button ID="btnAdd" runat="server" Text="Add New" OnClick="btnAdd_Click" CssClass="btn btn-large btn-success" />
            <div class="well form-search">
                Name
                <asp:TextBox ID="txtSrchName" runat="server" CssClass="input-medium search-query" />
                <asp:Button ID="btnSearch" Text="Search" OnClick="btnSearch_Click" runat="server"
                    CssClass="btn" />
            </div>
            <br />
            <asp:DataGrid ID="dtGrd" runat="server" AutoGenerateColumns="false" DataKeyField="q_id"
                OnItemCommand="dgrdList_Command" AllowPaging="true" OnPageIndexChanged="dtGrd_Paging"
                PageSize="3" PagerStyle-Mode="NumericPages" AllowSorting="true" OnSortCommand="dtGrd_SortChange"
                CssClass="table table-bordered">
                <Columns>
                    <asp:BoundColumn DataField="q_name" HeaderText="Name" SortExpression="q_name">
                    </asp:BoundColumn>
                    <asp:BoundColumn DataField="q_date" HeaderText="Date" SortExpression="q_date">
                    </asp:BoundColumn>
                    <asp:TemplateColumn HeaderText="Hidden" SortExpression="q_hidden">
                        <ItemTemplate>
                            <asp:CheckBox ID="chkHidden" runat="server" Checked='<%# Eval("q_hidden") %>' Enabled="false" />
                        </ItemTemplate>
                    </asp:TemplateColumn>
                    <asp:TemplateColumn>
                        <ItemTemplate>
                            <asp:LinkButton ID="btnEdit" Text="Edit" CommandName="edit" CssClass="btn btn-small"
                                runat="server" />
                            <asp:LinkButton ID="btnDel" CommandName="delete" Text="Delete" OnClientClick="javascript:return confirm('Are you sure you want to delete this record?');"
                                runat="server" CssClass="btn btn-small" />
                        </ItemTemplate>
                    </asp:TemplateColumn>
                </Columns>
            </asp:DataGrid>
        </asp:View>
        <asp:View ID="vwFrm" runat="server">
           <div class="form-horizontal">
            <fieldset>
                
                <div class="control-group">
                    <label for="txtQueName" class="control-label">
                        Name
                    </label>
                    <div class="controls">
                    <asp:TextBox ID="txtQueName" runat="server" ClientIDMode="Static" Width="90%"></asp:TextBox>
                    <asp:RequiredFieldValidator ErrorMessage="Required" ControlToValidate="txtQueName"
                        ID="reqtxtQueName" runat="server" Display="Dynamic"></asp:RequiredFieldValidator>
                    <p class="help-block">Provide a meaningful name for the question. This is important as you will be searching questions on this.</p>
                    </div>
                </div>
                <div class="control-group">
                    <label for="txtQueInstruction" class="control-label">
                        Instruction</label>
                    <div class="controls">
                        <asp:TextBox ID="txtQueInstruction" runat="server" TextMode="MultiLine" Height="200" Width="90%" ClientIDMode="Static"></asp:TextBox>
                        <asp:RequiredFieldValidator ErrorMessage="Required" ControlToValidate="txtQueInstruction"
                        ID="RequiredFieldValidator1" runat="server"></asp:RequiredFieldValidator>
                        
                    </div>
                    
                </div>
                <div class="control-group">
                    <label for="txtQueText" class="control-label">
                        Text</label>
                    <div class="controls">
                        <asp:TextBox ID="txtQueText" runat="server" TextMode="MultiLine" Height="200" Width="90%" ClientIDMode="Static"></asp:TextBox>
                        <asp:RequiredFieldValidator ErrorMessage="Required" ControlToValidate="txtQueText"
                        ID="reqtxtQueText" runat="server"></asp:RequiredFieldValidator>
                        
                    </div>
                </div>
                <div class="control-group">
                    <label for="txtQueHint" class="control-label">
                        Hint</label>
                    <div class="controls">
                        <CKEditor:CKEditorControl ID="txtQueHint" runat="server" TextMode="MultiLine" Height="100" Width="90%" ClientIDMode="Static"></CKEditor:CKEditorControl>           
                    </div>
                </div>
                <br />
                <br />
                <div class="control-group">
                    <label for="txtQueSolution" class="control-label">
                        Solution</label>
                    <div class="controls">
                        <CKEditor:CKEditorControl ID="txtQueSolution" runat="server" TextMode="MultiLine" Height="200" Width="90%" ClientIDMode="Static"></CKEditor:CKEditorControl>
                        <asp:RequiredFieldValidator ErrorMessage="Required" ControlToValidate="txtQueSolution"
                        ID="retxtQueSolution" runat="server"></asp:RequiredFieldValidator>
                      
                    </div>
                    
                </div>
                <div class="control-group">
                <label for="imgUpload" class="control-label">
                    Image
                </label>
                <div class="controls"> 
                    <asp:Image ID="imgDiagram" ClientIDMode="Static" runat="server" Height="200" Width="200" ImageUrl="../images/noimage.png"  AlternateText="Diagram"/>
                    <asp:HiddenField ID="imgDiagramUrl" runat="server" /> 
                    <p class="help-block">Current Diagram</p>
                    <br />
                    <asp:FileUpload ID="imgUpload"   runat="server"/>
                    <p class="help-block">Upload New Diagram</p>
                </div>
                </div>
                <div class="control-group">
                    <label for="txtDate" class="control-label">Date</label>
                    <div class="controls">
                    <asp:TextBox ID="txtDate" runat="server" ClientIDMode="Static"></asp:TextBox>
                     <asp:RequiredFieldValidator ErrorMessage="Required" ControlToValidate="txtDate" ID="reqtxtDate"
                        runat="server" Display="Dynamic"></asp:RequiredFieldValidator>
                    <asp:RegularExpressionValidator ControlToValidate="txtDate" ID="regtxtDate" runat="server"
                        ErrorMessage="Invalid Date" ValidationExpression="^\d{1,2}\/\d{1,2}\/\d{4}$"></asp:RegularExpressionValidator>
                    </div>
                </div>
                <div class="control-group">
                    <label for="cbxHidden" class="control-label">Hidden</label>
                    <div class="controls">
                    <label class="checkbox"></label>
                    <asp:CheckBox ID="cbxHidden" runat="server" Checked="true"/>
                    <p class="help-block">Checking this will hide this question from the front end user</p>
                    </div>
                </div>
                <div class="control-group">
                    <label for="cbxlCats" class="control-label">Categories</label>
                    <div class="controls">
                    <asp:CheckBoxList ID="cbxlCats" runat="server" CssClass="checkBoxLst" >
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
            <asp:Button ID="btnSubmit" Text="Add and Continue" OnClick="btnSubmit_Click" runat="server" CssClass="btn btn-primary" />
            <asp:Button ID="btnCancel" Text="Cancel" OnClick="btnCancel_Click" CausesValidation="false"
                        runat="server" CssClass="btn" />
            </div>
            </div>
        </asp:View>
        <asp:View ID="vwFrmOptions" runat="server">
            <asp:GridView ID="grdOptions" runat="server" AutoGenerateColumns="False" DataKeyNames="opt_id"
                OnRowCancelingEdit="grdOptions_RowCancelingEdit" OnRowDataBound="grdOptions_RowDataBound"
                OnRowEditing="grdOptions_RowEditing" OnRowUpdating="grdOptions_RowUpdating" OnRowCommand="grdOptions_RowCommand"
                ShowFooter="True" OnRowDeleting="grdOptions_RowDeleting" CssClass="table table-bordered" BorderWidth="0">
                <Columns>
                    <asp:TemplateField HeaderText="Option Text" HeaderStyle-HorizontalAlign="Left">
                        <EditItemTemplate>
                            <asp:TextBox ID="txtOptText" runat="server" Text='<%# Bind("opt_text") %>' TextMode="MultiLine" Height="50" Width="90%"></asp:TextBox>
                        </EditItemTemplate>
                        <FooterTemplate>
                            <asp:TextBox ID="txtNewOption" runat="server" TextMode="MultiLine" Height="50" Width="90%"></asp:TextBox>
                        </FooterTemplate>
                        <ItemTemplate>
                            <asp:Label ID="lblOptionText" runat="server" Text='<%# Bind("opt_text") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Correct" HeaderStyle-HorizontalAlign="Left">
                        <EditItemTemplate>
                            <asp:CheckBox ID="chkCorrectEdit" runat="server" Checked='<%# Eval("opt_correct")%>'/>
                        </EditItemTemplate>
                        <FooterTemplate>
                            <asp:CheckBox ID="chkCorrectAdd" runat="server" />
                        </FooterTemplate>
                        <ItemTemplate>
                            <asp:CheckBox  Enabled="false" ID="chkCorrectHidden" runat="server" Checked='<%# Eval("opt_correct")%>'/>
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
            <div class="form-actions">
            <asp:Button ID="btnFinish" Text="Finish" OnClick="btnFinish_Click" runat="server" CssClass="btn btn-primary" />
            </div>     
        </asp:View>
    </asp:MultiView>
</asp:Content>
