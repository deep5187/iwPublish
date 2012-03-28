<%@ WebHandler Class="admin.RegistrationService" %>
Imports System.Web
Imports System.Security.Cryptography
Imports Jayrock.Json
Imports Jayrock.JsonRpc
Imports Jayrock.JsonRpc.Web
Namespace admin
	Public Class RegistrationService
		Inherits JsonRpcHandler
		<JsonRpcMethod("greetings")> _
		Public Function Greetings() As Dictionary(of String,Object)
            'Return "Welcome to Jayrock!"
            Dim d As New Dictionary(Of String, Object)
            d.Add("result", "Hello this works")
            d.Add("error", DBNull.Value)
            d.Add("id", 0)
            Return d
		End Function
        <JsonRpcMethod("registerUser")> _
        Public Function RegisterUser(ByVal name As String, ByVal email As String,ByVal phoneNo As String, ByVal hash As String) As Dictionary(Of String, Object)
            Dim d As New Dictionary(Of String, Object)
            Const key As String = "578wefhjw824bfa78r3j4brdfuo3b87fsja839rwqbwe8w3brwe8fb39"
            Dim result As String = Nothing
            Dim hmac = New HMACSHA256(Encoding.ASCII.GetBytes(key))
            
            Dim byteText As Byte() = Encoding.ASCII.GetBytes(name + email + phoneNo)
            
            Dim hashValue As Byte() = hmac.ComputeHash(byteText)
            
            result = Convert.ToBase64String(hashValue)

            Dim id As Integer = -1
            If result.Trim().Equals(hash.Trim()) Then
                id = IST.DataAccess.CreateOrReturnUser(name, email, phoneNo)
                d.Add("error", DBNull.Value)
                d.Add("result", id)
            Else
                d.Add("error", 1001)
                d.Add("result", id)
            End If
            d.add("hash",result)
            d.Add("jsonrpc", "2.0")          
            d.Add("id", 0)
            
            Return d
        End Function
	End Class
End Namespace

