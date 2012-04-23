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
        wrt.WriteElementString("managingEditor", "deep5187@gmail.com (Deep Shah)")
        wrt.WriteElementString("webMaster", "deep5187@gmail.com (Deep Shah)")
        Dim dtb As DataTable = IST.DataAccess.GetDataTable("SELECT TOP 10 * FROM question WHERE q_hidden='false' ORDER BY q_date DESC")
        
        For Each dr As DataRow In dtb.Rows
            wrt.WriteStartElement("question")
            wrt.WriteAttributeString("id",dr("q_id"))
            wrt.WriteElementString("quedate", dr("q_date"))
            wrt.WriteElementString("quename",dr("q_name"))
            
            If Convert.IsDBNull(dr("q_instruction"))
                wrt.WriteElementString("instruction","")
            Else
                wrt.WriteStartElement("instruction")
                wrt.WriteCData(HttpUtility.HtmlDecode(dr("q_instruction").ToString()))
                wrt.WriteEndElement() 'instruction
            End If
            wrt.WriteStartElement("quetext")
            wrt.WriteCData(HttpUtility.HtmlDecode(dr("q_text").ToString()))
            wrt.WriteEndElement() 'quetext
            If Convert.IsDBNull(dr("q_diagram")) Then
                wrt.WriteElementString("diagram", "")
                wrt.WriteElementString("queimagename","")
            Else
                If Request.IsLocal Then
                
                    wrt.WriteElementString("diagram", "http://" & Request.Url.Authority & "/iwPublish/files/images/" & dr("q_diagram"))
                Else
                    wrt.WriteElementString("diagram", "http://" & Request.Url.Authority & "/files/images/" & dr("q_diagram"))
                End If
                wrt.WriteElementString("queimagename",dr("q_diagram").ToString.substring(0,dr("q_diagram").ToString.LastIndexOf(".")))
            End If
            If Convert.IsDBNull(dr("q_soldiagram")) Then
                wrt.WriteElementString("soldiagram", "")
                wrt.WriteElementString("quesolimagename", "")
            Else
                If Request.IsLocal Then
                
                    wrt.WriteElementString("soldiagram", "http://" & Request.Url.Authority & "/iwPublish/files/images/" & dr("q_soldiagram"))
                Else
                    wrt.WriteElementString("soldiagram", "http://" & Request.Url.Authority & "/files/images/" & dr("q_soldiagram"))
                End If
                wrt.WriteElementString("quesolimagename", dr("q_soldiagram").ToString.Substring(0, dr("q_soldiagram").ToString.LastIndexOf(".")))
            End If
            Dim dtbOption As DataTable = IST.DataAccess.GetDataTable("SELECT opt_text,opt_correct FROM question q JOIN [option] o ON q.q_id = o.q_id WHERE q.q_id = " & dr("q_id"))
            wrt.WriteStartElement("answer")
            For Each drOpt As DataRow In dtbOption.Rows
                wrt.WriteStartElement("option")
                wrt.WriteAttributeString("correct",drOpt("opt_correct"))
                wrt.WriteCData(drOpt("opt_text").toString())
                wrt.WriteEndElement
                'wrt.WriteAttributeString("correct",drOpt("opt_correct"))
            Next
            wrt.WriteEndElement() 'answer
            If Convert.IsDBNull(dr("q_hint"))
                wrt.WriteElementString("hint","")
            Else
                wrt.WriteStartElement("hint")
                wrt.WriteCData(HttpUtility.HtmlDecode(dr("q_hint").ToString()))
                wrt.WriteEndElement() 'hint
            End If
            wrt.WriteStartElement("solution")
            Wrt.WriteCData(HttpUtility.HtmlDecode(dr("q_solution").toString()))
            wrt.WriteEndElement() 'solution
            wrt.WriteEndElement() 'question
        Next
        
        wrt.WriteEndElement() 'questions
        wrt.WriteEndDocument()
        wrt.Close()
    End Sub
</script>