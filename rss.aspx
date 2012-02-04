<%@ Page Language="VB" %>
<%@ Import Namespace="System.XML" %>
<%@ Import Namespace="System.Data" %>

<script runat="server">
    
    Sub Page_Load()
        Response.ContentType = "text/xml"
        
        Dim stg As New XmlWriterSettings
        stg.Indent = True
        stg.NewLineOnAttributes = True
        
        Dim wrt As XmlWriter = XmlWriter.Create(Response.OutputStream, stg)
        
        wrt.WriteStartDocument()
        wrt.WriteStartElement("rss")
        wrt.WriteAttributeString("version", "2.0")
        
        wrt.WriteStartElement("channel")
        
        wrt.WriteElementString("title", "CATapp - News")
        wrt.WriteElementString("link", "http://catapp.in/")
        wrt.WriteElementString("pubDate", DateTime.Now.ToString("r"))
        wrt.WriteElementString("managingEditor", "deep5187@gmail.com (Deep Shah)")
        wrt.WriteElementString("webMaster", "deep5187@gmail.com (Deep Shah)")
        Dim dtb As DataTable = IST.DataAccess.GetDataTable("SELECT TOP 10 * FROM posting ORDER BY pst_date DESC")
        
        For Each dr As DataRow In dtb.Rows
            wrt.WriteStartElement("item")
            wrt.WriteElementString("title", dr("pst_title"))
            'wrt.WriteElementString("link", "http://deep-shah.com/default.aspx?id=" & dr("pst_id"))
            wrt.WriteStartElement("description")
            wrt.WriteCData(dr("pst_text").ToString())
            wrt.WriteEndElement()'description
            wrt.WriteElementString("guid", "http://deep-shah.com/default.aspx?id=" & dr("pst_id"))
            wrt.WriteElementString("pubDate", CType(dr("pst_date"),DateTime).ToString("r"))
            Dim sqlCat As String = "SELECT cat_name FROM posting_category pc JOIN category c ON  pc.cat_id = c.cat_id WHERE pst_id = " & dr("pst_id")
            Dim dtbCat As DataTable = IST.DataAccess.GetDataTable(sqlCat)
            Dim drCat As DataRow
            For Each drCat In dtbCat.Rows
                wrt.WriteElementString("Category", drCat("cat_name"))
            Next
            wrt.WriteEndElement() 'item
        Next
        
        wrt.WriteEndElement() 'channel
        
        wrt.WriteEndElement() 'rss
        wrt.WriteEndDocument()
        wrt.Close()
    End Sub

</script>
