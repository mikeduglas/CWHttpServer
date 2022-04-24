!* Simple http server
!* Mike Duglas 2022
!* mikeduglas@yandex.ru

  MEMBER

  PRAGMA('link(CWHttpServer.lib)')

  INCLUDE('winapi.inc'), ONCE
  INCLUDE('tbstr.inc'), ONCE
  INCLUDE('cwhttpserver.inc'), ONCE

  MAP
    MODULE('Clarion API')
      AttachThreadToClarion(BOOL pAllocate),PASCAL
    END

    MODULE('CWHttpServer api')
      CWHttpServer_Init(LONG pInst),PASCAL,DLL(1)
      CWHttpServer_Kill(LONG pInst),PASCAL,DLL(1)
      CWHttpServer_Start(LONG pInst),PASCAL,DLL(1)
      CWHttpServer_Stop(LONG pInst),PASCAL,DLL(1)
      CWHttpServer_Listen(LONG pInst),PASCAL,DLL(1)
      CWHttpServer_AddUri(LONG pInst,BSTR pUri),PASCAL,DLL(1)
      CWHttpServer_SetRequestReceivedCallback(LONG pInst,LONG pFuncAddr),PASCAL,DLL(1)

      CWHttpServer_Request_GetContent(LONG pInst),BSTR,PASCAL,DLL(1)
      CWHttpServer_Request_GetUrl(LONG pInst),BSTR,PASCAL,DLL(1)
      CWHttpServer_Request_GetHost(LONG pInst),BSTR,PASCAL,DLL(1)
      CWHttpServer_Request_GetPort(LONG pInst),LONG,PASCAL,DLL(1)
      CWHttpServer_Request_GetAbsoluteUrl(LONG pInst),BSTR,PASCAL,DLL(1)
      CWHttpServer_Request_GetAbsolutePath(LONG pInst),BSTR,PASCAL,DLL(1)
      CWHttpServer_Request_GetRawUrl(LONG pInst),BSTR,PASCAL,DLL(1)
      CWHttpServer_Request_GetQueryString(LONG pInst),BSTR,PASCAL,DLL(1)
      CWHttpServer_Request_GetHeadersCount(LONG pInst),LONG,PASCAL,DLL(1)
      CWHttpServer_Request_GetHeaderByIndex(LONG pInst,LONG pIndex,*BSTR pName,*BSTR pValue),PASCAL,DLL(1)
      CWHttpServer_Request_GetCookiesCount(LONG pInst),LONG,PASCAL,DLL(1)
      CWHttpServer_Request_GetCookieByIndex(LONG pInst,LONG pIndex,*BSTR pName,*BSTR pValue),PASCAL,DLL(1)
      CWHttpServer_Request_GetUserAgent(LONG pInst),BSTR,PASCAL,DLL(1)
      CWHttpServer_Request_GetUserHostName(LONG pInst),BSTR,PASCAL,DLL(1)
      CWHttpServer_Request_GetUserHostAddress(LONG pInst),BSTR,PASCAL,DLL(1)
      CWHttpServer_Request_GetUserLanguages(LONG pInst),BSTR,PASCAL,DLL(1)
      CWHttpServer_Request_GetAcceptTypes(LONG pInst),BSTR,PASCAL,DLL(1)

      CWHttpServer_Response_SetContent(LONG pInst,BSTR pContent,BSTR pContentType),PASCAL,DLL(1)
      CWHttpServer_Response_SetStatusCode(LONG pInst,LONG pStatusCode),PASCAL,DLL(1)
      CWHttpServer_Response_SetStatusDescription(LONG pInst,BSTR pStatusDescription),PASCAL,DLL(1)
      CWHttpServer_Response_SetRedirectLocation(LONG pInst,BSTR pRedirectLocation),PASCAL,DLL(1)
      CWHttpServer_Response_SetRedirect(LONG pInst,BSTR pUrl),PASCAL,DLL(1)
      CWHttpServer_Response_GetHeadersCount(LONG pInst),LONG,PASCAL,DLL(1)
      CWHttpServer_Response_GetHeaderByIndex(LONG pInst,LONG pIndex,*BSTR pName,*BSTR pValue),PASCAL,DLL(1)
      CWHttpServer_Response_AddHeader(LONG pInst,BSTR pName,BSTR pValue),PASCAL,DLL(1)
      CWHttpServer_Response_AppendHeader(LONG pInst,BSTR pName,BSTR pValue),PASCAL,DLL(1)
      CWHttpServer_Response_GetCookiesCount(LONG pInst),LONG,PASCAL,DLL(1)
      CWHttpServer_Response_GetCookieByIndex(LONG pInst,LONG pIndex,*BSTR pName,*BSTR pValue),PASCAL,DLL(1)
      CWHttpServer_Response_AppendCookie(LONG pInst,BSTR pName,BSTR pValue,BSTR pPath,BSTR pDomain),PASCAL,DLL(1)
      CWHttpServer_Response_SetCookie(LONG pInst,BSTR pName,BSTR pValue,BSTR pPath,BSTR pDomain),PASCAL,DLL(1)
    END

    RequestReceivedCallback(LONG pClaInst, |
      BSTR pContentType,BSTR pHttpMethod,BSTR pUrl),PASCAL,PRIVATE

    Bstring::ToUtf8(BSTR pBstr),STRING,PRIVATE
    Bstring::FromUtf6(BSTR pBstr, UNSIGNED pCodepage),STRING,PRIVATE
    Bstring::FromCP(STRING pInput, UNSIGNED pCodepage), BSTR, PRIVATE
    Bstring::FromCP(*BSTR pBstr, STRING pInput, UNSIGNED pCodepage), BSTR, PROC, PRIVATE
    AllocFromCP(TSysString this, *BSTR pBstr, STRING pInput, UNSIGNED pCodepage), BSTR, PROC, PRIVATE
  END

!!!region Encoding
Bstring::ToUtf8               PROCEDURE(BSTR pBstr)
enc                             TStringEncoding
bstrText                        TSysString
  CODE
  IF pBstr
    bstrText.Assign(pBstr)
    RETURN enc.ToUtf8(bstrText.WideStringRef(), CP_UTF16)
  ELSE
    RETURN ''
  END
  
Bstring::FromUtf6             PROCEDURE(BSTR pBstr, UNSIGNED pCodepage)
ss                              TSysString
enc                             TStringEncoding
  CODE
  ss.Assign(pBstr)
  RETURN enc.FromUtf16(ss.WideStringRef(), pCodepage)

Bstring::FromCP               PROCEDURE(STRING pInput, UNSIGNED pCodepage)
bstr                            BSTR(0)
  CODE
  RETURN Bstring::FromCP(bstr, pInput, pCodepage)
  
Bstring::FromCP               PROCEDURE(*BSTR pBstr, STRING pInput, UNSIGNED pCodepage)
bs                              TSysString
  CODE
  bs.AllocFromCP(pBstr, pInput, pCodepage)
  bs.DontFree(TRUE)
  RETURN pBstr

AllocFromCP                   PROCEDURE(TSysString this, *BSTR pBstr, STRING pInput, UNSIGNED pCodepage)
enc                             TStringEncoding
  CODE
  IF pBstr <> 0
    this.Assign(pBstr)
    this.ReAlloc(enc.ToCWStr(pInput, pCodepage))
    pBstr = this.GetPtr()
  ELSE
    pBstr = this.Alloc(enc.ToCWStr(pInput, pCodepage))
  END
  RETURN pBstr
!!!endregion
  
!!!region Callbacks
RequestReceivedCallback       PROCEDURE(LONG pClaInst, |
                                BSTR pContentType,BSTR pHttpMethod,BSTR pUrl)
srv                             &THttpServerBase
sContentType                    STRING(256), AUTO
sHttpMethod                     STRING(20), AUTO
sUrl                            STRING(1024), AUTO
disableSubmit                   STRING(20), AUTO
  CODE
  AttachThreadToClarion(TRUE)
  
  IF pClaInst
    srv &= (pClaInst)
    
    sContentType = Bstring::ToUtf8(pContentType)
    sHttpMethod = Bstring::ToUtf8(pHttpMethod)
    sUrl = Bstring::ToUtf8(pUrl)
    
    srv.OnRequestReceived(sContentType, sHttpMethod, sUrl)
  END
!!!endregion
  
!!!region THttpServerRequest
THttpServerRequest.Content PROCEDURE()
bstrVal                         BSTR, AUTO
  CODE
  bstrVal = CWHttpServer_Request_GetContent(SELF.srv.inst)
  RETURN Bstring::FromUtf6(bstrVal, SELF.srv.nCodePage)
  
THttpServerRequest.Url     PROCEDURE()
bstrVal                         BSTR, AUTO
  CODE
  bstrVal = CWHttpServer_Request_GetUrl(SELF.srv.inst)
  RETURN Bstring::FromUtf6(bstrVal, SELF.srv.nCodePage)
  
THttpServerRequest.Host    PROCEDURE()
bstrVal                         BSTR, AUTO
  CODE
  bstrVal = CWHttpServer_Request_GetHost(SELF.srv.inst)
  RETURN Bstring::FromUtf6(bstrVal, SELF.srv.nCodePage)
  
THttpServerRequest.Port    PROCEDURE()
  CODE
  RETURN CWHttpServer_Request_GetPort(SELF.srv.inst)
  
THttpServerRequest.AbsoluteUrl PROCEDURE()
bstrVal                             BSTR, AUTO
  CODE
  bstrVal = CWHttpServer_Request_GetAbsoluteUrl(SELF.srv.inst)
  RETURN Bstring::FromUtf6(bstrVal, SELF.srv.nCodePage)
    
THttpServerRequest.AbsolutePath    PROCEDURE()
bstrVal                                 BSTR, AUTO
  CODE
  bstrVal = CWHttpServer_Request_GetAbsolutePath(SELF.srv.inst)
  RETURN Bstring::FromUtf6(bstrVal, SELF.srv.nCodePage)

THttpServerRequest.RawUrl  PROCEDURE()
bstrVal                         BSTR, AUTO
  CODE
  bstrVal = CWHttpServer_Request_GetRawUrl(SELF.srv.inst)
  RETURN Bstring::FromUtf6(bstrVal, SELF.srv.nCodePage)
  
THttpServerRequest.QueryString PROCEDURE()
bstrVal                             BSTR, AUTO
  CODE
  bstrVal = CWHttpServer_Request_GetQueryString(SELF.srv.inst)
  RETURN Bstring::FromUtf6(bstrVal, SELF.srv.nCodePage)
  
THttpServerRequest.UserAgent  PROCEDURE()
bstrVal                         BSTR, AUTO
  CODE
  bstrVal = CWHttpServer_Request_GetUserAgent(SELF.srv.inst)
  RETURN Bstring::FromUtf6(bstrVal, SELF.srv.nCodePage)
  
THttpServerRequest.UserHostName   PROCEDURE()
bstrVal                             BSTR, AUTO
  CODE
  bstrVal = CWHttpServer_Request_GetUserHostName(SELF.srv.inst)
  RETURN Bstring::FromUtf6(bstrVal, SELF.srv.nCodePage)
  
THttpServerRequest.UserHostAddress    PROCEDURE()
bstrVal                                 BSTR, AUTO
  CODE
  bstrVal = CWHttpServer_Request_GetUserHostAddress(SELF.srv.inst)
  RETURN Bstring::FromUtf6(bstrVal, SELF.srv.nCodePage)
  
THttpServerRequest.UserLanguages  PROCEDURE()
bstrVal                             BSTR, AUTO
  CODE
  bstrVal = CWHttpServer_Request_GetUserLanguages(SELF.srv.inst)
  RETURN Bstring::FromUtf6(bstrVal, SELF.srv.nCodePage)
  
THttpServerRequest.AcceptTypes    PROCEDURE()
bstrVal                             BSTR, AUTO
  CODE
  bstrVal = CWHttpServer_Request_GetAcceptTypes(SELF.srv.inst)
  RETURN Bstring::FromUtf6(bstrVal, SELF.srv.nCodePage)

THttpServerRequest.GetHeadersCount    PROCEDURE()
  CODE
  RETURN CWHttpServer_Request_GetHeadersCount(SELF.srv.inst)

THttpServerRequest.GetHeaderByIndex   PROCEDURE(LONG pIndex,*STRING pName,*STRING pValue)
bstrName                                BSTR
bstrValue                               BSTR
  CODE
  bstrName = Bstring::FromCP(All(' '), CP_ACP)
  bstrValue = Bstring::FromCP(All(' '), CP_ACP)
  
  CWHttpServer_Request_GetHeaderByIndex(SELF.srv.inst, |
    pIndex-1, bstrName, bstrValue)
  
  pName = Bstring::FromUtf6(bstrName, SELF.srv.nCodePage)
  pValue = Bstring::FromUtf6(bstrValue, SELF.srv.nCodePage)

THttpServerRequest.GetCookiesCount    PROCEDURE()
  CODE
  RETURN CWHttpServer_Request_GetCookiesCount(SELF.srv.inst)

THttpServerRequest.GetCookieByIndex   PROCEDURE(LONG pIndex,*STRING pName,*STRING pValue)
bstrName                                BSTR
bstrValue                               BSTR
  CODE
  bstrName = Bstring::FromCP(All(' '), CP_ACP)
  bstrValue = Bstring::FromCP(All(' '), CP_ACP)
  
  CWHttpServer_Request_GetCookieByIndex(SELF.srv.inst, |
    pIndex-1, bstrName, bstrValue)
  
  pName = Bstring::FromUtf6(bstrName, SELF.srv.nCodePage)
  pValue = Bstring::FromUtf6(bstrValue, SELF.srv.nCodePage)
!!!endregion
  
!!!region THttpServerResponse
THttpServerResponse.Content    PROCEDURE(STRING pContent,STRING pContentType)
  CODE
  CWHttpServer_Response_SetContent(SELF.srv.inst, | 
    Bstring::FromCP(pContent, CP_ACP), |
    Bstring::FromCP(pContentType, CP_ACP))
  
THttpServerResponse.StatusCode PROCEDURE(LONG pStatusCode)
  CODE
  CWHttpServer_Response_SetStatusCode(SELF.srv.inst, | 
    pStatusCode)
  
THttpServerResponse.StatusDescription  PROCEDURE(STRING pStatusDescription)
  CODE
  CWHttpServer_Response_SetStatusDescription(SELF.srv.inst, | 
    Bstring::FromCP(pStatusDescription, CP_ACP))
   
THttpServerResponse.RedirectLocation   PROCEDURE(STRING pRedirectLocation)
  CODE
  CWHttpServer_Response_SetRedirectLocation(SELF.srv.inst, | 
    Bstring::FromCP(pRedirectLocation, CP_ACP))
    
THttpServerResponse.Redirect   PROCEDURE(STRING pUrl)
  CODE
  CWHttpServer_Response_SetRedirect(SELF.srv.inst, | 
    Bstring::FromCP(pUrl, CP_ACP))

THttpServerResponse.GetHeadersCount   PROCEDURE()
  CODE
  RETURN CWHttpServer_Response_GetHeadersCount(SELF.srv.inst)

THttpServerResponse.GetHeaderByIndex  PROCEDURE(LONG pIndex,*STRING pName,*STRING pValue)
bstrName                                BSTR
bstrValue                               BSTR
  CODE
  bstrName = Bstring::FromCP(All(' '), CP_ACP)
  bstrValue = Bstring::FromCP(All(' '), CP_ACP)
  
  CWHttpServer_Response_GetHeaderByIndex(SELF.srv.inst, |
    pIndex-1, bstrName, bstrValue)
  
  pName = Bstring::FromUtf6(bstrName, SELF.srv.nCodePage)
  pValue = Bstring::FromUtf6(bstrValue, SELF.srv.nCodePage)
    
THttpServerResponse.AddHeader PROCEDURE(STRING pName,STRING pValue)
  CODE
  CWHttpServer_Response_AddHeader(SELF.srv.inst, | 
    Bstring::FromCP(pName, CP_ACP), |
    Bstring::FromCP(pValue, CP_ACP))
    
THttpServerResponse.AppendHeader  PROCEDURE(STRING pName,STRING pValue)
  CODE
  CWHttpServer_Response_AppendHeader(SELF.srv.inst, | 
    Bstring::FromCP(pName, CP_ACP), |
    Bstring::FromCP(pValue, CP_ACP))

THttpServerResponse.GetCookiesCount   PROCEDURE()
  CODE
  RETURN CWHttpServer_Response_GetCookiesCount(SELF.srv.inst)

THttpServerResponse.GetCookieByIndex  PROCEDURE(LONG pIndex,*STRING pName,*STRING pValue)
bstrName                                BSTR
bstrValue                               BSTR
  CODE
  bstrName = Bstring::FromCP(All(' '), CP_ACP)
  bstrValue = Bstring::FromCP(All(' '), CP_ACP)
  
  CWHttpServer_Response_GetCookieByIndex(SELF.srv.inst, |
    pIndex-1, bstrName, bstrValue)
  
  pName = Bstring::FromUtf6(bstrName, SELF.srv.nCodePage)
  pValue = Bstring::FromUtf6(bstrValue, SELF.srv.nCodePage)
    
THttpServerResponse.AppendCookie  PROCEDURE(STRING pName,STRING pValue,<STRING pPath>,<STRING pDomain>)
  CODE
  CWHttpServer_Response_AppendCookie(SELF.srv.inst, | 
    Bstring::FromCP(pName, CP_ACP), |
    Bstring::FromCP(pValue, CP_ACP), |
    Bstring::FromCP(pPath, CP_ACP), |
    Bstring::FromCP(pDomain, CP_ACP) |
    )

THttpServerResponse.SetCookie PROCEDURE(STRING pName,STRING pValue,<STRING pPath>,<STRING pDomain>)
  CODE
  CWHttpServer_Response_SetCookie(SELF.srv.inst, | 
    Bstring::FromCP(pName, CP_ACP), |
    Bstring::FromCP(pValue, CP_ACP), |
    Bstring::FromCP(pPath, CP_ACP), |
    Bstring::FromCP(pDomain, CP_ACP) |
    )
!!!endregion
  
!!!region THttpServerBase
THttpServerBase.Construct     PROCEDURE()
  CODE
  SELF.inst = ADDRESS(SELF)
  SELF.nCodePage = CP_ACP
  SELF.request &= NEW THttpServerRequest
  SELF.request.srv &= SELF
  SELF.response &= NEW THttpServerResponse
  SELF.response.srv &= SELF
  SELF.bListening = FALSE
  
  CWHttpServer_Init(SELF.inst)
  CWHttpServer_SetRequestReceivedCallback(SELF.inst, ADDRESS(RequestReceivedCallback))

THttpServerBase.Destruct      PROCEDURE()
  CODE
  CWHttpServer_Kill(SELF.inst)
  
  SELF.bListening = FALSE
  DISPOSE(SELF.request)
  DISPOSE(SELF.response)
  
THttpServerBase.StartServer   PROCEDURE()
  CODE
  CWHttpServer_Start(SELF.inst)
  
THttpServerBase.StopServer    PROCEDURE()
  CODE
  CWHttpServer_Stop(SELF.inst)
  
THttpServerBase.AddPrefix     PROCEDURE(STRING pUri)
  CODE
  CWHttpServer_AddUri(SELF.inst, Bstring::FromCP(pUri, CP_ACP))
    
THttpServerBase.Listen        PROCEDURE()
  CODE
  SELF.bListening = TRUE
  CWHttpServer_Listen(SELF.inst)
  RETURN SELF.bListening

THttpServerBase.OnRequestReceived PROCEDURE(STRING pContentType,STRING pHttpMethod,STRING pUrl)
  CODE
!!!endregion