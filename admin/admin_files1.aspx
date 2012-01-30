<%@ Page Title="" Language="VB" MasterPageFile="~/MasterPage.master" %>
<%@ Import Namespace="System.IO" %>

<script runat="server">
    

    Dim di As New DirectoryInfo(Server.MapPath("~/files/"))
    Sub Page_Load()      
        If Not Page.IsPostBack Then
            PopDirList()
            mvw.SetActiveView(vwMain)
            ShowList()
        End If
    End Sub
    
    Sub PopDirList()
        With ddlFolder
            .DataSource = di.GetDirectories()
            .DataBind()
        End With
        ddlFolder.Items.Insert(0,New ListItem("Select..",""))
    End Sub
    
    Sub ShowList()
        Dim diCurrent As New DirectoryInfo(Server.MapPath("~/files/" & ddlFolder.SelectedValue & "/"))
        
        lbxFiles.Items.Clear()

        For Each fi As FileInfo In diCurrent.GetFiles("*.*")
            lbxFiles.Items.Add(New ListItem(fi.Name, fi.FullName))
        Next
    End Sub
    
   
    Sub btnAdd_Click(ByVal s As Object, ByVal e As EventArgs)   
        
        If Page.IsValid Then
            If filUpload.HasFile Then
                filUpload.SaveAs(Server.MapPath("~/files/" & ddlFolder.SelectedValue & "/") & filUpload.FileName)
            End If
      
            ShowList()
        End If
     
    End Sub
  
    Sub btnDel_Click(ByVal s As Object, ByVal e As EventArgs)
        If lbxFiles.SelectedValue <> String.Empty Then
            If File.Exists(lbxFiles.SelectedValue) Then
                File.Delete(lbxFiles.SelectedValue)
                ShowList()
            End If
        End If
    End Sub
    
    Protected Sub ddlFolder_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        ShowList()
    End Sub

    Protected Sub btnAddFolder_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        txtNewFold.Text=""
        mvw.SetActiveView(vwNewFold)
    End Sub

    Protected Sub btnAddNewFolder_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim diRoot As New DirectoryInfo(Server.MapPath("~/files/"))
        Dim diCheck As New DirectoryInfo(Server.MapPath("~/files/" & txtNewFold.Text))
        If diCheck.Exists Then
            litFoldCreatError.text = "Error: The folder already exists"
        Else
            diRoot.CreateSubdirectory(txtNewFold.Text)
            PopDirList()
            mvw.SetActiveView(vwMain)
        End If
        
    End Sub

    Protected Sub btnCanelAddFold_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        mvw.SetActiveView(vwMain)
    End Sub

    Protected Sub btnDeleteFolder_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If Page.IsValid Then
            Dim diRoot As New DirectoryInfo(Server.MapPath("~/files/" & ddlFolder.SelectedValue))
            diRoot.Delete(True)
            PopDirList()
            ShowList()
        End If   
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">

    <link href="../adminStyle.css" rel="stylesheet" type="text/css" />
    <link href="../jquery-ui-1.8.6.custom.css" rel="stylesheet" type="text/css" />
     <link rel="Stylesheet" href="../buttons.css" />
    <link href="../jquery.alerts.css" rel="stylesheet" type="text/css" />
  <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4/jquery.min.js"></script>
  <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js"></script>
  <script type="text/javascript" src="../jquery.alerts.js"></script>

<script type="text/javascript">
    var data;
    jQuery(document).ready(function () {
        $(document).ready(function () {
            $("#accordion1").accordion({ collapsible: true });
            $("#accordion2").accordion({ collapsible: true });
        });

        //in the dialog setup
        $('#dialog').dialog({
            modal: true,
            buttons: {
                Save: function () {
                    console.log(data);
                    WebForm_DoPostBackWithOptions(new WebForm_PostBackOptions("ctl00$cpHoldMain$btnDeleteFolder", "", true, "Folder", "", false, false));
                    $(this).dialog('close');
                },
                Cancel: function () {
                    $(this).dialog('close');
                }
            }
        });
        $('#dialog').dialog('close');
    });
    function myconfirm(el) {
      data = el;
      $('#dialog').dialog("open"); //show dialog //this should prevent the default event
      return false;
  }
</script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cpHoldMain" Runat="Server">
<asp:MultiView ID="mvw" runat="server">
<asp:View ID="vwMain" runat="server">
<!--List Box Control for displaying file names to user-->
        <div id="dialog" title="Dialog Title"></div>
<div id="accordion2">
 <h3><a href="#">Select Folder</a></h3>
    <div id="selfold" >
    <asp:DropDownList ID="ddlFolder" runat="server" OnSelectedIndexChanged="ddlFolder_SelectedIndexChanged" AutoPostBack="true" Width="300px" />
    <asp:RequiredFieldValidator ID="RequiredFieldValidator2" ControlToValidate="ddlFolder" ErrorMessage="Required" runat="server" Display="Dynamic" ValidationGroup="Folder"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator ID="RequiredFieldValidator3" ControlToValidate="ddlFolder" ErrorMessage="Required" runat="server" Display="Dynamic" ValidationGroup="FileUpload"></asp:RequiredFieldValidator>
    <asp:Button ID="btnAddFolder" Text="Add Folder" runat="server" OnClick="btnAddFolder_Click" CssClass="buttonBig" CausesValidation="false"/>
    <asp:Button ID="btnDeleteFolder" Text="Delete Folder" runat="server" OnClick="btnDeleteFolder_Click" CssClass="buttonBig" ValidationGroup="Folder" OnClientClick="javascript:return confirm('Are you sure you want to delete this folder');"/>
    </div>
</div>
<div id="accordion1">
    <h3><a href="#">Upload File</a></h3>
        <div id="filelist">
        Select a file to Upload:
        <div>
        <table>
        <tr>
            <td><asp:TextBox id="fileName" cssClass="file_input_textbox"  ReadOnly="true" runat="server"></asp:TextBox>
            </td>
            <td>
            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" ControlToValidate="filUpload" ErrorMessage="Required" runat="server" Display="Dynamic" ValidationGroup="FileUpload"></asp:RequiredFieldValidator>
            </td>
            <td>
                <div class="file_input_div">
                <input type="button" value="Browse" class="file_input_button buttonBig"  />
                <asp:FileUpload ID="filUpload" runat="server" onchange="javascript: document.getElementById('ctl00_cpHoldMain_fileName').value = this.value" CssClass="file_input_hidden" />
                </div>         
            </td>
        </tr>
        </table> 
        <asp:Button ID="btnUpload" Text="Upload" OnClick="btnAdd_Click" runat="server" CssClass="buttonBig" ValidationGroup="FileUpload"/>          
        </div> 
        <div id="listfile">
            <asp:ListBox ID="lbxFiles" Rows="20" runat="server" Height="150px" Width="300px"/> <br />
            <asp:Button ID="btnDelete" Text="Delete" onclick="btnDel_Click" runat="server" CssClass="buttonBig"  CausesValidation="false" OnClientClick="javascript:return confirm('Are you sure you want to delete this file');"/>
        </div>
        </div> 
</div>
</asp:View>
<asp:View ID="vwNewFold" runat="server">
<table>
    <tr>
        <td><asp:Literal ID="litFoldCreatError" runat="server"></asp:Literal></td>
    </tr>
    <tr>
        <td>New Folder Name</td>
        <td><asp:TextBox ID="txtNewFold" runat="server"></asp:TextBox></td>
        <td><asp:RequiredFieldValidator ID="reqTxtNewFold" ControlToValidate="txtNewFold" ErrorMessage="Required" runat="server" Display="Dynamic"></asp:RequiredFieldValidator></td>
    </tr>
    <tr>
        <td><asp:Button ID="btnAddNewFolder" Text="Add" runat="server" OnClick="btnAddNewFolder_Click" /></td>
        <td><asp:Button ID="btnCanelAddFold" Text="Cancel" runat="server" CausesValidation="false" OnClick="btnCanelAddFold_Click" /></td>    
    </tr>
</table>
</asp:View>
</asp:MultiView>

</asp:Content>

