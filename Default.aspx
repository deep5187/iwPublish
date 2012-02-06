<%@ Page Title="" Language="VB" MasterPageFile="~/MasterPage.master" %>

<script runat="server">
    Sub Page_Load()
        If HttpContext.Current.User.Identity.IsAuthenticated Then
            Response.Redirect("~/admin/admin_catnews.aspx")
        Else
            Response.Redirect("~/login.aspx")
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cpHoldMain" Runat="Server">


</asp:Content>

