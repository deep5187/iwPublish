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

    End Class

End Namespace