<%@ WebService Language="VB" Class="RegistrationService" %>

Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols

' To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line.
' <System.Web.Script.Services.ScriptService()> _
<WebService(Namespace := "http://catapp.informationworks.in/")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _  
Public Class RegistrationService
    Inherits System.Web.Services.WebService 
    
	<WebMethod()> _
	Public Function HelloWorld() As String
		Return "Hello World"
	End Function

End Class
