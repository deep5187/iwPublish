<%@ Page Title="" Language="VB" MasterPageFile="admin.master" %>
<%@ Import Namespace="System.IO" %>

<script runat="server">
    
    ReadOnly VirtualFileRoot As String = "~/files/"
    Dim di As New DirectoryInfo(Server.MapPath("~/files/"))
    Sub Page_Load()      
        If Not Page.IsPostBack Then
            mvw.SetActiveView(vwMain)
            ShowList()
            PopDirList()
        End If
        litFoldErr.Text=""
    End Sub
    
    Sub PopDirList()
       
        Dim root As TreeNode = AddNodeAndDescendents(di, Nothing)
        trFile.Nodes.Clear()
        trFile.Nodes.Add(root)
        trFile.ExpandDepth = 1
        trFile.ExpandAll()
    End Sub
    
    Function AddNodeAndDescendents(ByVal folder As DirectoryInfo, ByVal parentNode As TreeNode) As TreeNode
        Dim virtualFolderPath As String

        If parentNode Is Nothing Then
            virtualFolderPath = VirtualFileRoot
        Else
            virtualFolderPath = parentNode.Value + folder.Name + "/"
        End If
        

        Dim node As TreeNode = New TreeNode(folder.Name, virtualFolderPath)

      
        Dim subFolders As DirectoryInfo() = folder.GetDirectories()
        Dim subFolder As DirectoryInfo
        For Each subFolder In subFolders
            Dim child As TreeNode = AddNodeAndDescendents(subFolder, node)
            node.ChildNodes.Add(child)
        Next
        Return node
    End Function
        
    
    Sub ShowList()
        Dim diCurrent As New DirectoryInfo(Server.MapPath(VirtualFileRoot))
        
        lbxFiles.Items.Clear()

        For Each fi As FileInfo In diCurrent.GetFiles("*.*")
            lbxFiles.Items.Add(New ListItem(fi.Name, fi.FullName))
        Next
    End Sub
    
    Sub Showlist(ByVal file As String)
        Dim diCurrent As New DirectoryInfo(Server.MapPath(file))
        
        lbxFiles.Items.Clear()

        For Each fi As FileInfo In diCurrent.GetFiles("*.*")
            lbxFiles.Items.Add(New ListItem(fi.Name, fi.FullName))
        Next
    End Sub
   
    Sub btnAdd_Click(ByVal s As Object, ByVal e As EventArgs)

        If Page.IsValid Then
            If filUpload.HasFile Then
                If trFile.SelectedValue <> String.Empty Then
                    filUpload.SaveAs(Server.MapPath(trFile.SelectedValue & "/") & filUpload.FileName)
                    ShowList(trFile.SelectedValue)
                    
                Else
                    filUpload.SaveAs(Server.MapPath(VirtualFileRoot & "/") & filUpload.FileName)
                    ShowList()
                End If
                
            End If
      
           
        End If
     
    End Sub
  
    Sub btnDel_Click(ByVal s As Object, ByVal e As EventArgs)
        If lbxFiles.SelectedValue <> String.Empty Then
            If File.Exists(lbxFiles.SelectedValue) Then
                File.Delete(lbxFiles.SelectedValue)
                ShowList(trFile.SelectedValue)
            End If
        End If
    End Sub
   

    Protected Sub btnAddFolder_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        txtNewFold.Text = ""
        If trFile.SelectedValue <> String.Empty Then
            ViewState("folder") = trFile.SelectedValue
        Else
            ViewState("folder") = VirtualFileRoot
        End If
        
        mvw.SetActiveView(vwNewFold)
    End Sub

    Protected Sub btnAddNewFolder_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim diRoot As New DirectoryInfo(Server.MapPath(ViewState("folder")))
        Dim diCheck As New DirectoryInfo(Server.MapPath(ViewState("folder") & txtNewFold.Text))
        If diCheck.Exists Then
            litFoldCreatError.Text = "Error: The folder already exists"
        Else
            diRoot.CreateSubdirectory(txtNewFold.Text)
            PopDirList()
            mvw.SetActiveView(vwMain)
        End If
        
    End Sub

    Protected Sub btnCanelAddFold_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        mvw.SetActiveView(vwMain)
    End Sub

    Protected Sub btnDeleteFolder_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        If Page.IsValid Then
            If trFile.SelectedValue <> String.Empty AND trFile.SelectedValue <> VirtualFileRoot Then
                Dim diRoot As New DirectoryInfo(Server.MapPath(trFile.SelectedValue))
                diRoot.Delete(True)
                PopDirList()
                ShowList()
            ElseIf trFile.SelectedValue = String.Empty Then
                litFoldErr.Text = "Please select a folder to delete <br />"
            Else               
                litFoldErr.Text = "Can't delete this folder <br />"
            End If
          
        End If
    End Sub

    Protected Sub trFile_SelectedNodeChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        ShowList(trFile.SelectedValue)
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">

    <link href="../adminStyle.css" rel="stylesheet" type="text/css" />
    <link href="../jquery-ui-1.8.6.custom.css" rel="stylesheet" type="text/css" />
    <link href="../jquery-ui-.custom.css" rel="stylesheet" type="text/css" />
     <link rel="Stylesheet" href="../buttons.css" />
    <link href="../jquery.alerts.css" rel="stylesheet" type="text/css" />
  <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4/jquery.min.js"></script>
  <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js"></script>
  <script type="text/javascript" src="../jquery.alerts.js"></script>

<script type="text/javascript">
    var data;
    jQuery(document).ready(function () {
        $(document).ready(function () {
            $("#listfile").accordion({ collapsible: true });
            $("#fileupload").accordion({ collapsible: true });
            $("#tree").accordion({ collapsible: false });
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
        <div id="tree">
        <h3><a href="#">Folders</a></h3>
        <div id="treeview">
        <div class="error"><asp:literal ID="litFoldErr" runat="server"></asp:literal></div>
            <asp:ImageButton ID="btnAddFolder" ImageUrl="folder_add.png"  runat="server" OnClick="btnAddFolder_Click" CssClass="buttonBig" CausesValidation="false"/>
            <asp:ImageButton ID="btnDeleteFolder"  ImageUrl="folder_delete.png" Text="Delete" runat="server" OnClick="btnDeleteFolder_Click" CssClass="buttonBig" ValidationGroup="Folder" OnClientClick="javascript:return confirm('Are you sure you want to delete this folder');"/>
            <asp:TreeView ID="trFile"  NodeStyle-ImageUrl="folder.png" runat="server" OnSelectedNodeChanged="trFile_SelectedNodeChanged" SelectedNodeStyle-Font-Bold="true" SelectedNodeStyle-Font-Underline="true" ></asp:TreeView>       
        </div>
        </div>

   
      <div id="listfile" class="upload">
            <h3><a href="#">List of Files</a></h3>
            <div id="files">
            <asp:ListBox ID="lbxFiles" Rows="20" runat="server" Height="150px" Width="300px"/> <br />
            <asp:Button ID="btnDelete" Text="Delete" onclick="btnDel_Click" runat="server" CssClass="buttonBig"  CausesValidation="false" OnClientClick="javascript:return confirm('Are you sure you want to delete this file');"/>
            </div>
        </div>
   
        <div id="fileupload" class="upload">
         <h3><a href="#">Upload File</a></h3>
        
        <div id="uploads">
        Select a file to Upload:
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
        </div> 


</asp:View>
<asp:View ID="vwNewFold" runat="server">
<table>
    <tr>
        <td class="error"><asp:Literal ID="litFoldCreatError" runat="server"></asp:Literal></td>
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




