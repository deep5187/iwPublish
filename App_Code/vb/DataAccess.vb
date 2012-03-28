Imports Microsoft.VisualBasic
Imports System.Data
Imports System.Data.SqlClient

Namespace IST

    Public Class DataAccess
        Dim Shared ReadOnly Conn As New SqlConnection(ConfigurationManager.ConnectionStrings("db").ConnectionString)
        Public Shared Function GetDataTable(ByVal sql As String) As DataTable
           
            Dim sqlDa As New SqlDataAdapter(sql, Conn)
            Dim dtb As New DataTable
            sqlDa.Fill(dtb)
            Return dtb
        End Function
        
        Public Shared Function GetAdminId(ByVal userName As String) As Integer
            Dim sql As String = "SELECT admin_id from administrator WHERE admin_username = '" & userName &"'"
            Dim cmdSql As New SqlCommand(sql,Conn)
            Conn.Open()
            Dim adminId As Integer = CType(cmdSql.ExecuteScalar(),Integer)
            Conn.Close()
            Return adminId
        End Function

        Public Shared Function CreateOrReturnUser(ByVal name As String, ByVal email As String, ByVal phoneNo As String) As Integer
            Dim searchUserSql As String = "SELECT id FROM iwadmin.[user] WHERE name = '" + name + "' and email LIKE '" + email + "'"
            Dim id As Integer = -1
            Dim dtb As DataTable = GetDataTable(searchUserSql)
            If dtb.Rows.Count > 0 Then
                id = CInt(dtb.Rows(0)("id"))
            Else
                Try
                    Dim sql As String = "INSERT INTO iwadmin.[user] VALUES('" + name + "','" + email + "','" + phoneNo + "'); SELECT @@IDENTITY; "
                    Dim cmdSql As New SqlCommand(sql, Conn)
                    If Conn.State <> ConnectionState.Open Then
                        Conn.Open()
                    End If
                    id = CType(cmdSql.ExecuteScalar(), Integer)
                    Conn.Close()
                Catch Ex As Exception
                Finally
                    Conn.Close()
                End Try
            End If
            Return id
        End Function
    End Class

End Namespace