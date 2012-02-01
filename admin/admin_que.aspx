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
           FillOptionsGrid()
            
        End If
        conn.ConnectionString = ConfigurationManager.ConnectionStrings("db").ConnectionString
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
       
    End Sub
    
    
    Sub btnCancel_Click(ByVal s As Object, ByVal e As EventArgs)
        
    End Sub
    
    Sub btnSubmit_Click(ByVal s As Object, ByVal e As EventArgs)

        
    End Sub
    
    Sub dgrdList_Command(ByVal s As Object, ByVal e As DataGridCommandEventArgs)
       
    End Sub
    Sub EditForm(ByVal idVal As Integer)
       
    End Sub
    Sub dtGrd_Paging(ByVal s As Object, ByVal e As DataGridPageChangedEventArgs)
       
    End Sub
    
    Sub dtGrd_SortChange(ByVal s As Object, ByVal e As DataGridSortCommandEventArgs)
        
    End Sub
    Sub btnSearch_Click(ByVal s As Object, ByVal e As EventArgs)
        
    End Sub
    
    Sub btnAddOption_Click(ByVal s As Object, ByVal e As EventArgs)
    End Sub
    
    Sub FillOptionsGrid()
        conn.ConnectionString = ConfigurationManager.ConnectionStrings("db").ConnectionString
        Dim optionSql As String
        If ViewState("sortField") = String.Empty Then
            ViewState("sortField") = "pst_date"
            ViewState("sortOrder") = "DESC"
        End If
        optionSql = " SELECT opt_id,opt_text,q_id as opt_id,opt_text,q_id from [option]"
        
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
        Dim sql As String
        If e.CommandName.Equals("Insert")
            sql = "INSERT INTO [option](opt_text,q_id) VALUES (@opt_text,@q_id)"
            Dim cmdSql As New SqlCommand(sql, conn)
            cmdSql.Parameters.AddWithValue("@opt_text", CType(grdOptions.FooterRow.FindControl("txtNewOption"),TextBox).Text)
            cmdSql.Parameters.AddWithValue("@q_id", 1)
            conn.Open()
            ViewState("idOptVal") = cmdSql.ExecuteScalar
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
            <asp:DataGrid ID="dtGrd" runat="server" AutoGenerateColumns="false" DataKeyField="pst_id"
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
                    <label for="txtQuestion">
                        Question Text</label>
                    <div class="input">
                        <asp:TextBox ID="txtQuestion" runat="server" TextMode="MultiLine" Height="200" Width="500" ClientIDMode="Static"></asp:TextBox><asp:RequiredFieldValidator ErrorMessage="Required" ControlToValidate="txtQuestion"
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
            <div>
                <table>
                    <tr>
                        <td>
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
                        </td>
                    </tr>
                </table>
            </div>
        </asp:View>
    </asp:MultiView>
</asp:Content>
