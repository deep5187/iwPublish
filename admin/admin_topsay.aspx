<%@ Page Title="" Language="VB" MasterPageFile="admin.master" %>
<%@ Register TagPrefix="asp" Namespace="AjaxControlToolkit" Assembly="AjaxControlToolkit"%>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="TwitterVB2" %>
<script runat="server">
    Dim conn As New SqlConnection
    Private Const VirtualFileRoot As String = "~/files/images/"
    Sub page_load()
        conn.ConnectionString = ConfigurationManager.ConnectionStrings("db").ConnectionString
        If Not Page.IsPostBack Then
            showlist()
        End If
    End Sub
    Sub showlist()
        conn.ConnectionString = ConfigurationManager.ConnectionStrings("db").ConnectionString
        Dim adminSql As String
        If ViewState("sortField") = String.Empty Then
            ViewState("sortField") = "ts_percentile"
            ViewState("sortOrder") = "DESC"
        End If
        adminSql = " SELECT  ts_id,ts_fname,ts_lname,ts_percentile,ts_year,admin_id" & _
                                 " FROM topsay "
        If txtSrchName.Text <> String.Empty Then
            adminSql &= " WHERE ts_name LIKE '%" & txtSrchName.Text.Replace("'", "''") & "%'"
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
        litPageHeader.Text="Topper's Say"
        mvwMain.SetActiveView(vwGrid)
    End Sub
    Sub btnAdd_Click(ByVal s As Object, ByVal e As EventArgs)
        txtFname.Text = ""
        txtLname.Text=""
        txtPercentile.Text=""
        txtYear.Text=""
        txtText.Text = ""
        txtQuote.Text=""
        imgPhoto.ImageUrl="../images/noimage.png"
        cbxHidden.Checked = True
        lblAdmin.Text = HttpContext.Current.User.Identity.Name
        ViewState("idVal") = ""
        btnSubmit.Text = "Add"
        litPageHeader.Text="Topper's Say <small>Add</small>"
        mvwMain.SetActiveView(vwFrm)
    End Sub
    
    
    Sub btnCancel_Click(ByVal s As Object, ByVal e As EventArgs)
        litPageHeader.Text="Topper's Say"
        mvwMain.SetActiveView(vwGrid)
    End Sub
    
    Sub btnSubmit_Click(ByVal s As Object, ByVal e As EventArgs)
        Dim flag As Char = "n"
        If Page.IsValid Then
            Dim sql As String
            If Len(ViewState("idVal")) = 0 Then
                sql = "INSERT INTO topsay(ts_fname,ts_lname,ts_year,ts_percentile,ts_image,ts_quote,ts_hidden,ts_text,admin_id) VALUES" & _
                              "(@ts_fname,@ts_lname,@ts_year,@ts_percentile,@ts_image,@ts_quote,@ts_hidden,@ts_text, @admin_id); SELECT @@IDENTITY;"
                flag = "i"
            Else
                sql = "UPDATE topsay SET ts_fname=@ts_fname, ts_lname=@ts_lname,ts_percentile=@ts_percentile,ts_image=@ts_image,ts_quote=@ts_quote,ts_text=@ts_text," & _
                       "ts_year=@ts_year, ts_hidden=@ts_hidden, admin_id=@admin_id WHERE ts_id = " & ViewState("idVal")
                flag = "u"
            End If
            Dim cmdSql As New SqlCommand(sql, conn)
            cmdSql.Parameters.AddWithValue("@ts_fname", txtFname.Text)
            cmdSql.Parameters.AddWithValue("@ts_lname", txtLname.Text)
            cmdSql.Parameters.AddWithValue("@ts_text", txtText.Text)
            cmdSql.Parameters.AddWithValue("@ts_percentile", txtPercentile.Text)
            cmdSql.Parameters.AddWithValue("@ts_year", txtYear.Text)
            cmdSql.Parameters.AddWithValue("@ts_quote", txtQuote.Text)

            If cbxHidden.Checked Then
                cmdSql.Parameters.AddWithValue("@ts_hidden", 1)
            Else
                cmdSql.Parameters.AddWithValue("@ts_hidden", 0)
            End If
            
            'storing image if it has been uploaded
            If filePhotoUpload.HasFile Then 
                Dim charsToTrim() As Char = {"*", " ", "\"}
                Dim guid As Guid = System.Guid.NewGuid()
                filePhotoUpload.SaveAs(Server.MapPath(VirtualFileRoot & "/") & guid.ToString() & filePhotoUpload.FileName.Trim(charsToTrim))
                cmdSql.Parameters.AddWithValue("@ts_image", guid.ToString() & filePhotoUpload.FileName.Trim(charsToTrim))
                'Deleting the old file once we have uploaded the new file
                If hiddenPhotoUrl.Value IsNot "" Then
                    If File.Exists(Server.MapPath(VirtualFileRoot & "/") & hiddenPhotoUrl.Value) Then
                        File.Delete(Server.MapPath(VirtualFileRoot & "/") & hiddenPhotoUrl.Value)
                    End If
                End If
            Else
                'if now new file specified then restore the previous value
                If hiddenPhotoUrl.Value = "" Then
                    cmdSql.Parameters.AddWithValue("@ts_image", DBNull.Value)
                Else
                    cmdSql.Parameters.AddWithValue("@ts_image", hiddenPhotoUrl.Value)
                End If
            End If
            cmdSql.Parameters.AddWithValue("@admin_id",IST.DataAccess.GetAdminId(HttpContext.Current.User.Identity.Name))
            conn.Open()

            If Len(ViewState("idVal")) = 0 Then
                ViewState("idVal") = cmdSql.ExecuteScalar
            Else
                cmdSql.ExecuteNonQuery()
            End If
   
        
            conn.Close()
            showlist()
        End If
        
    End Sub
    
    Sub dgrdList_Command(ByVal s As Object, ByVal e As DataGridCommandEventArgs)
        Select Case e.CommandName
            Case "delete"
                Dim idVal As Integer = dtGrd.DataKeys(e.Item.ItemIndex)
                
                conn.Open()
                Dim cmdSql As SqlCommand
                cmdSql = New SqlCommand("DELETE FROM topsay WHERE ts_id = " & idVal, conn)
                cmdSql.ExecuteNonQuery()
                conn.Close()
                
                showlist()
            Case "edit"
                Dim idVal As Integer = dtGrd.DataKeys(e.Item.ItemIndex)
                EditForm(idVal)
        End Select
    End Sub
    Sub EditForm(ByVal idVal As Integer)
        Dim sql As String = "SELECT ts_id,ts_fname,ts_lname,ts_percentile,ts_year,isnull(ts_image,'') as ts_image,ts_quote,ts_text,isnull(ts_hidden,1) as ts_hidden, admin_id FROM topsay WHERE ts_id = " & idVal
        Dim dtb As DataTable = IST.DataAccess.GetDataTable(sql)
        
        If dtb.Rows.Count > 0 Then
            Dim dr As DataRow = dtb.Rows(0)
            
            txtFname.Text = dr("ts_fname").ToString
            txtLname.Text = dr("ts_lname").ToString
            txtYear.Text = dr("ts_year").ToString
            If Not Convert.IsDBNull(dr("ts_hidden"))
                cbxHidden.Checked = dr("ts_hidden")
            Else
                cbxHidden.Checked = false
            End If
            txtPercentile.Text = dr("ts_percentile").ToString
            txtText.Text = dr("ts_text").ToString
            txtQuote.Text = dr("ts_quote").ToString
            hiddenPhotoUrl.Value = dr("ts_image").ToString
            If Not Convert.IsDBNull(dr("ts_image"))
                If Request.IsLocal
                    imgPhoto.ImageUrl = "http://" & Request.Url.Authority & "/iwPublish/files/images/" & dr("ts_image").ToString
                 Else
                    imgPhoto.ImageUrl = "http://" & Request.Url.Authority & "/files/images/" & dr("ts_image").ToString
                End If
                
                hiddenPhotoUrl.Value = dr("ts_image").ToString
            Else
                imgPhoto.ImageUrl = "../images/noimage.png"
                hiddenPhotoUrl.Value=""
                
            End If
            lblAdmin.Text = HttpContext.Current.User.Identity.Name
            ViewState("idVal") = idVal
            btnSubmit.Text = "Update"
            litPageHeader.Text="Topper's Say <small>Edit</small>"
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
            <asp:Button ID="btnAdd" runat="server" Text="Add New" OnClick="btnAdd_Click" CssClass="btn btn-large btn-success" />
            <div class="well form-search">
                Name
                <asp:TextBox ID="txtSrchName" runat="server" CssClass="input-medium search-query"/>
                <asp:Button ID="btnSearch" Text="Search" OnClick="btnSearch_Click" runat="server"
                    CssClass="btn" />
            </div>
            <br />
            <asp:DataGrid ID="dtGrd" runat="server" AutoGenerateColumns="false" DataKeyField="ts_id"
                OnItemCommand="dgrdList_Command" AllowPaging="true" OnPageIndexChanged="dtGrd_Paging"
                PageSize="3" PagerStyle-Mode="NumericPages" AllowSorting="true" OnSortCommand="dtGrd_SortChange"
                CssClass="table table-bordered">
                <Columns>
                    <asp:TemplateColumn HeaderText="Name" SortExpression="ts_fname,ts_lname">
                        <ItemTemplate>
                            <%#Container.DataItem("ts_fname")%> <%#Container.DataItem("ts_lname") %>
                        </ItemTemplate>
                    </asp:TemplateColumn>
                    <asp:BoundColumn DataField="ts_year" HeaderText="Year" SortExpression="ts_year">
                    </asp:BoundColumn>
                    <asp:BoundColumn DataField="ts_percentile" HeaderText="Percentile" SortExpression="ts_percentile">
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
            <div class="form-horizontal">
            <fieldset>
                <div class="control-group">
                    <label for="txtFname">
                        Name</label>
                    <div class="controls">
                        
                        <asp:TextBox ID="txtFname" runat="server" ClientIDMode="Static"></asp:TextBox>
                        <p class="help-block">First</p>
                        <asp:RequiredFieldValidator ErrorMessage="Required" ControlToValidate="txtFname"
                        ID="reqtxtFname" Display="Dynamic" runat="server"></asp:RequiredFieldValidator>
                        
                        <asp:TextBox ID="txtLname" runat="server" ClientIDMode="Static">
                        </asp:TextBox>
                        <p class="help-block">Last</p>
                        <asp:RequiredFieldValidator ErrorMessage="Required" ControlToValidate="txtLname" ID="reqtxtLname"
                        display="Dynamic" runat="server"></asp:RequiredFieldValidator>
                    </div>
                </div>

                <div class="control-group">
                    <label for="txtYear">Year</label>
                    <div class="controls">
                    <asp:TextBox ID="txtYear" runat="server" ClientIDMode="Static"></asp:TextBox>
                    <p class="help-block">e.g. format 2012</p>
                     <asp:RequiredFieldValidator ErrorMessage="Required" ControlToValidate="txtYear" ID="reqtxtYear"
                        runat="server" Display="Dynamic"></asp:RequiredFieldValidator>
                    <asp:RegularExpressionValidator ControlToValidate="txtYear" ID="regtxtYear" runat="server"
                        ErrorMessage="Invalid Year" ValidationExpression="^\d{4}$" Display="Dynamic"></asp:RegularExpressionValidator>
                    </div>
                </div>
                 <div class="control-group">
                    <label for="txtPercentile">Percentile</label>
                    <div class="controls">
                    <asp:TextBox ID="txtPercentile" runat="server" ClientIDMode="Static"></asp:TextBox>
                    <p class="help-block">e.g. format 98.00 or 99.12</p>
                     <asp:RequiredFieldValidator ErrorMessage="Required" ControlToValidate="txtPercentile" ID="RequiredFieldValidator1"
                        runat="server" Display="Dynamic"></asp:RequiredFieldValidator>
                    <asp:RegularExpressionValidator ControlToValidate="txtPercentile" ID="RegularExpressionValidator1" runat="server"
                        ErrorMessage="Invalid Percentile" ValidationExpression="^[0-9]*\.[0-9][0-9]$" Display="Dynamic"></asp:RegularExpressionValidator>
                    </div>
                </div>
                <div class="control-group">
                <label for="imgUpload" class="control-label">
                    Photo
                </label>
                <div class="controls"> 
                    <asp:Image ID="imgPhoto" ClientIDMode="Static" runat="server" Height="200" Width="200" ImageUrl="../images/noimage.png"  AlternateText="Photo"/>
                    <asp:HiddenField ID="hiddenPhotoUrl" runat="server" /> 
                    <p class="help-block">Current Photo</p>
                    <br />
                    <asp:FileUpload ID="filePhotoUpload"   runat="server"/>
                    <p class="help-block">Upload New Photo</p>
                </div>
                </div>
                <div class="control-group">
                    <label for="txtQuote" class="control-label">
                        Quote</label>
                    <div class="controls">
                        <asp:TextBox ID="txtQuote" runat="server" TextMode="MultiLine" Height="200" Width="90%" ClientIDMode="Static"></asp:TextBox>
                        <asp:RequiredFieldValidator ErrorMessage="Required" ControlToValidate="txtQuote"
                        ID="RequiredFieldValidator2" runat="server"></asp:RequiredFieldValidator>
                        <asp:HtmlEditorExtender ID="HtmlEditorExtender3"
                            TargetControlID="txtQuote"
                         runat="server" />
                    </div>
                    
                </div>
                <div class="control-group">
                    <label for="txtText" class="control-label">
                        Text</label>
                    <div class="controls">
                        <asp:TextBox ID="txtText" runat="server" TextMode="MultiLine" Height="200" Width="90%" ClientIDMode="Static"></asp:TextBox>
                        <asp:RequiredFieldValidator ErrorMessage="Required" ControlToValidate="txtText"
                        ID="reqtxtQueText" runat="server"></asp:RequiredFieldValidator>
                        <asp:HtmlEditorExtender ID="HtmlEditorExtender1"
                            TargetControlID="txtText"
                         runat="server" />
                    </div>
                </div>
                <div class="control-group">
                    <label for="cbxHidden">Hidden</label>
                    <div class="controls">
                     <asp:CheckBox ID="cbxHidden" runat="server" />
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

