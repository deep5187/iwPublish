<%@ WebHandler Class="admin.HelloWorld" %>
Imports System.Web
Imports Jayrock.Json
Imports Jayrock.JsonRpc
Imports Jayrock.JsonRpc.Web
Namespace admin
	Public Class HelloWorld
		Inherits JsonRpcHandler
		<JsonRpcMethod("greetings")> _
		Public Function Greetings() As String
			Return "Welcome to Jayrock!"
		End Function
        <JsonRpcMethod("registerUser")> _
        Public Function RegisterUser(name as String, email as String) As Dictionary(of String,Object)
            Dim d As New Dictionary(Of String, Object)
            d.Add("jsonrpc","2.0")
            d.Add("result",true)
            d.Add("error",Nothing)
            d.Add("id",0)
            Return d
        End Function
	End Class
End Namespace

