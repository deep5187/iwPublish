<%@ Page Title="" Language="VB" MasterPageFile="admin.master"  %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="TwitterVB2" %>
<script runat="server">
    Dim conn As New SqlConnection
    Shared cntTilClick As Integer = 0
    Shared cntDateClick As Integer
    Dim optionsTxtBox    As List(Of TextBox) = New List(Of TextBox)
    'Public oauthToken As String = "226367135-xy3HNxXWrN7uLxJHUPkqs1rfiCRGg7GHxw62nLwG"
    'Public oauthSecret As String = "RY8Tlb5hPWj8qrGqNVSQNHDyNIoROvtCkbkqOPb0lI0"
    Protected Property NumberOfControls As Integer
        Get
            Return CType(ViewState("NumControls"),Integer)
        End Get
        Set
            ViewState("NumControls") = Value
        End Set
    End Property
    Sub page_load()
        If Not Page.IsPostBack Then
           NumberOfControls = 0
           mvwMain.SetActiveView(vwFrm)
        Else
            If Session("Options") Is Nothing
                optionsTxtBox = New List(Of TextBox)
                Session("Options") = optionsTxtBox
            Else
                optionsTxtBox = CType(Session("Options"),List(Of TextBox))
            End If
           
           createControls()
        End If
        
    End Sub
    Sub createControls()
       For Each tx As TextBox In Session("Options") 
            plholdOptions.Controls.Add(tx)
       Next
    End Sub
    
    Function createOption(_id as Integer) As TextBox
    Dim tx As TextBox = New TextBox()
            tx.ID = "Options" + _id.ToString()
            Return tx
    End Function
    
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
        Dim tx As TextBox = createOption(CInt(Math.Ceiling(Rnd() * 100000)))
        optionsTxtBox.Add(tx)
        plholdOptions.Controls.Add(tx)
        NumberOfControls = NumberOfControls+1
        Session("Options") = optionsTxtBox
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
                    <label for="txtQuestion">
                        Title</label>
                    <div class="input">
                        <asp:TextBox ID="txtQuestion" runat="server" TextMode="MultiLine" Height="200" Width="500" ClientIDMode="Static"></asp:TextBox><asp:RequiredFieldValidator ErrorMessage="Required" ControlToValidate="txtQuestion"
                        ID="reqtxtTitle" runat="server"></asp:RequiredFieldValidator>
                    </div>
                </div>
                <div class="clearfix">
                    <label for="">Options</label>
                    <div class="input">
                        <asp:Button runat="server" Text="Add" id="btnAddOption" OnClick="btnAddOption_Click"  CausesValidation="false"/>
                        <asp:PlaceHolder ID="plholdOptions" runat="server">
                        </asp:PlaceHolder>
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
