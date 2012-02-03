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
        wrt.WriteStartElement("questions")
        'wrt.WriteAttributeString("version", "2.0")
        wrt.WriteElementString("pubDate", DateTime.Now.ToString("r"))
        wrt.WriteElementString("managingEditor", "deshah@syr.edu (Deep Shah)")
        wrt.WriteElementString("webMaster", "deshah@syr.edu (Deep Shah)")
        Dim dtb As DataTable = IST.DataAccess.GetDataTable("SELECT TOP 10 * FROM question ORDER BY q_date DESC")
        
        For Each dr As DataRow In dtb.Rows
            wrt.WriteStartElement("question")
            wrt.WriteAttributeString("id",dr("q_id"))
            wrt.WriteElementString("quedate", dr("q_date"))
            If Convert.IsDBNull(dr("q_instruction"))
                wrt.WriteElementString("instruction","")
            Else
                wrt.WriteElementString("instruction","<![CDATA[" & dr("q_instruction") & "]]>")
            End If
            
            wrt.WriteElementString("quetext", "<![CDATA[" & dr("q_text") & "]]>")
            If Convert.IsDBNull(dr("q_diagram"))
                wrt.WriteElementString("diagram","")
            Else
                If Request.IsLocal Then
                
                wrt.WriteElementString("diagram", "http://" & Request.Url.Authority & "/iwPublish/files/images/" & dr("q_diagram"))
            Else
                wrt.WriteElementString("diagram", "http://" & Request.Url.Authority & "/files/images/" & dr("q_diagram"))
            End If
            End If
            
            Dim dtbOption As DataTable = IST.DataAccess.GetDataTable("SELECT opt_text,opt_correct FROM question q JOIN [option] o ON q.q_id = o.q_id WHERE q.q_id = " & dr("q_id"))
            wrt.WriteStartElement("answer")
            For Each drOpt As DataRow In dtbOption.Rows
                wrt.WriteStartElement("option")
                wrt.WriteAttributeString("correct",drOpt("opt_correct"))
                wrt.WriteString(drOpt("opt_text"))
                wrt.WriteEndElement
                'wrt.WriteAttributeString("correct",drOpt("opt_correct"))
            Next
            wrt.WriteEndElement() 'answer
            wrt.WriteEndElement() 'question
        Next
        
        wrt.WriteEndElement() 'questions
        wrt.WriteEndDocument()
        wrt.Close()
    End Sub
</script>