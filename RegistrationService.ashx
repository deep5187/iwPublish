<%@ WebHandler Class="admin.RegistrationService" %>
Imports System.Web
Imports System.Security.Cryptography
Imports Jayrock.Json
Imports Jayrock.JsonRpc
Imports Jayrock.JsonRpc.Web
Namespace admin
	Public Class RegistrationService
        Inherits JsonRpcHandler
        Const Private key As String = "578wefhjw824bfa78r3j4brdfuo3b87fsja839rwqbwe8w3brwe8fb39"
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
        Public Function RegisterUser(ByVal name As String, ByVal email As String, ByVal phoneNo As String, ByVal hash As String, Optional ByVal platform As String = "android") As Dictionary(Of String, Object)
            Dim d As New Dictionary(Of String, Object)
            Try
                Dim result As String = Nothing
                Dim hmac = New HMACSHA256(Encoding.ASCII.GetBytes(key))
                If hash = Nothing Then
                    hash = ""
                End If
                If phoneNo = Nothing Then
                    phoneNo = ""
                End If
                Dim byteText As Byte() = Encoding.ASCII.GetBytes(name + email + phoneNo)
            
                Dim hashValue As Byte() = hmac.ComputeHash(byteText)
            
                result = Convert.ToBase64String(hashValue)

                Dim id As Integer = -1
                If result.Trim().Equals(hash.Trim()) Then
                    id = IST.DataAccess.CreateOrReturnUser(name, email, phoneNo,platform)
                    d.Add("error", DBNull.Value)
                    d.Add("result", id)
                    d.Add("msg", "User registered succesfully")
                Else
                    d.Add("error", 1001)
                    d.Add("result", id)
                    d.Add("msg", "Security breach. Hash did not match.")
                End If
                d.Add("jsonrpc", "2.0")
                d.Add("id", 0)
            Catch Ex As Exception
                d.Add("error", 1002)
                d.Add("result", -1)
                d.Add("msg", Ex.Message)
                d.Add("jsonrpc", "2.0")
                d.Add("id", 0)
            End Try
            
            Return d
        End Function
        <JsonRpcMethod("updateUser")> _
        Public Function UpdateUser(ByVal id As Integer, ByVal name As String, ByVal email As String, ByVal phoneNo As String, ByVal hash As String) As Dictionary(Of String, Object)
            Dim d As New Dictionary(Of String, Object)
            Try
                Dim result As String = Nothing
                Dim hmac = New HMACSHA256(Encoding.ASCII.GetBytes(key))
                If hash = Nothing Then
                    hash = ""
                End If
                If phoneNo = Nothing Then
                    phoneNo=""
                End If
                Dim byteText As Byte() = Encoding.ASCII.GetBytes(Convert.ToString(id) + name + email + phoneNo)
            
                Dim hashValue As Byte() = hmac.ComputeHash(byteText)
            
                result = Convert.ToBase64String(hashValue)
                Dim success As Boolean = False
                If result.Trim().Equals(hash.Trim()) Then
                    success = IST.DataAccess.UpdateUser(id, name, email, phoneNo)
                    d.Add("error", DBNull.Value)
                    d.Add("result", success)
                    d.Add("msg", "User updated succesfully")
                Else
                    d.Add("error", 1001)
                    d.Add("result", success)
                    d.Add("msg", "Security breach. Hash did not match.")
                End If
                d.Add("jsonrpc", "2.0")
                d.Add("id", 0)
            Catch Ex As Exception
                d.Add("error", 1002)
                d.Add("result", False)
                d.Add("msg",Ex.Message)
                d.Add("jsonrpc", "2.0")
                d.Add("id", 0)
            End Try
            Return d
        End Function
    End Class
End Namespace

