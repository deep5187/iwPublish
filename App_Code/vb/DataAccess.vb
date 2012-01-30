Imports Microsoft.VisualBasic
Imports System.Data
Imports System.Data.SqlClient

Namespace IST

    Public Class DataAccess

        Public Shared Function GetDataTable(ByVal sql As String) As DataTable
            Dim Conn As New SqlConnection(ConfigurationManager.ConnectionStrings("db").ConnectionString)
            Dim sqlDa As New SqlDataAdapter(sql, Conn)
            Dim dtb As New DataTable
            sqlDa.Fill(dtb)
            Return dtb
        End Function

    End Class

End Namespace