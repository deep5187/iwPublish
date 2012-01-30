<%@ Page Title="" Language="VB" MasterPageFile="admin.master" %>

<script runat="server">

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <link rel="Stylesheet" href="http://extjs-public.googlecode.com/svn/tags/extjs-3.2.1/release/resources/css/ext-all.css" />
    <link rel="Stylesheet" href="http://extjs-public.googlecode.com/svn/tags/extjs-3.2.1/release/resources/css/xtheme-gray.css" />
    <link rel="Stylesheet" href="http://extjs-public.googlecode.com/svn/tags/extjs-3.2.1/release/examples/ux/css/RowEditor.css" />
    <script type="text/javascript" src="http://extjs-public.googlecode.com/svn/tags/extjs-3.2.1/release/adapter/ext/ext-base.js"></script>
    <script type="text/javascript" src="http://extjs-public.googlecode.com/svn/tags/extjs-3.2.1/release/ext-all-debug.js"></script>
    <script type="text/javascript" src="http://extjs-public.googlecode.com/svn/tags/extjs-3.2.1/release/examples/ux/RowEditor.js"></script>
    <script type="text/javascript" src="http://extjs-public.googlecode.com/svn/tags/extjs-3.2.1/release/examples/ux/CheckColumn.js"></script>
    <script type="text/javascript" src="admincat.js"></script>
    <style type="text/css">
        .addIcon
        {
            background: url(../add-icon.png) no-repeat top left !important;
        }

        .deleteIcon
        {
            background:url(../delete-icon.png) no-repeat top left !important;
        }

        .saveIcon
        {
            background:url(../save-as-icon.png) no-repeat top left !important;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cpHoldMain" Runat="Server">
<div id="grid"></div>
</asp:Content>

