Imports Microsoft.VisualBasic

Public Class myTwitter
    Inherits TwitterVB2.TwitterOAuth
    Public Sub myGetAccessToken(ByVal AuthToken As String, ByVal AuthVerifier As String)
        Token = AuthToken
        Verifier = AuthVerifier
        Dim Response As String = OAuthWebRequest(Method.POST, "https://api.twitter.com/oauth/access_token", String.Empty)
        If Response.Length > 0 Then
            Dim qs As NameValueCollection = HttpUtility.ParseQueryString(Response)
            If qs("oauth_token") IsNot Nothing Then
                Token = qs("oauth_token")
            End If
            If qs("oauth_token_secret") IsNot Nothing Then
                TokenSecret = qs("oauth_token_secret")
            End If
        End If
    End Sub
End Class
