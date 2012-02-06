<%@ Page Language="VB" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Xml" %>

<script runat="server">
Sub Page_Load()
        Response.ContentType = "text/xml"
        
        Dim stg As New XmlWriterSettings
        stg.Indent = True
        stg.NewLineOnAttributes = True
        
        Dim wrt As XmlWriter = XmlWriter.Create(Response.OutputStream, stg)
        
        wrt.WriteStartDocument()
        wrt.WriteStartElement("topsay")
        wrt.WriteElementString("pubDate", DateTime.Now.ToString("r"))
        wrt.WriteElementString("managingEditor", "deep5187@gmail.com (Deep Shah)")
        wrt.WriteElementString("webMaster", "deep5187@gmail.com (Deep Shah)")
        Dim dtb As DataTable = IST.DataAccess.GetDataTable("SELECT * FROM topsay WHERE ts_hidden = 'false' ORDER BY  ts_percentile DESC")
        
        For Each dr As DataRow In dtb.Rows
            wrt.WriteStartElement("topper")
            wrt.WriteElementString("name", dr("ts_fname").ToString & " " & dr("ts_lname").ToString)
            wrt.WriteElementString("percentile",dr("ts_percentile"))
            wrt.WriteElementString("year",dr("ts_year"))
            wrt.WriteStartElement("quote")
            wrt.WriteCData(dr("ts_quote").ToString)
            wrt.WriteEndElement() 'quote
            wrt.WriteStartElement("say")
            wrt.WriteCData(dr("ts_text").ToString)
            wrt.WriteEndElement 'say
            If Convert.IsDBNull(dr("ts_image")) Then
                wrt.WriteElementString("photo", "")
            Else
                If Request.IsLocal Then
                
                    wrt.WriteElementString("photo", "http://" & Request.Url.Authority & "/iwPublish/files/images/" & dr("ts_image"))
                Else
                    wrt.WriteElementString("photo", "http://" & Request.Url.Authority & "/files/images/" & dr("ts_image"))
                End If
            End If
            wrt.WriteEndElement() 'topper
        Next
        
        wrt.WriteEndElement() 'topsay
        wrt.WriteEndDocument()
        wrt.Close()
    End Sub
</script>
