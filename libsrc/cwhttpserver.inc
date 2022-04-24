!* Simple http server
!* Mike Duglas 2022
!* mikeduglas@yandex.ru

THttpServerRequest            CLASS, TYPE, MODULE('cwhttpserver.clw'), LINK('cwhttpserver.clw')
srv                             &THttpServerBase, PRIVATE

Content                         PROCEDURE(),STRING
Url                             PROCEDURE(),STRING
Host                            PROCEDURE(),STRING
Port                            PROCEDURE(),LONG
AbsoluteUrl                     PROCEDURE(),STRING
AbsolutePath                    PROCEDURE(),STRING
RawUrl                          PROCEDURE(),STRING
QueryString                     PROCEDURE(),STRING
UserAgent                       PROCEDURE(),STRING
UserHostName                    PROCEDURE(),STRING
UserHostAddress                 PROCEDURE(),STRING
UserLanguages                   PROCEDURE(),STRING
AcceptTypes                     PROCEDURE(),STRING
GetHeadersCount                 PROCEDURE(),LONG
GetHeaderByIndex                PROCEDURE(LONG pIndex,*STRING pName,*STRING pValue)
GetCookiesCount                 PROCEDURE(),LONG
GetCookieByIndex                PROCEDURE(LONG pIndex,*STRING pName,*STRING pValue)
                              END

THttpServerResponse           CLASS, TYPE, MODULE('cwhttpserver.clw'), LINK('cwhttpserver.clw')
srv                             &THttpServerBase, PRIVATE

Content                         PROCEDURE(STRING pContent,STRING pContentType)
StatusCode                      PROCEDURE(LONG pStatusCode)
StatusDescription               PROCEDURE(STRING pStatusDescription)
RedirectLocation                PROCEDURE(STRING pRedirectLocation)
Redirect                        PROCEDURE(STRING pUrl)
GetHeadersCount                 PROCEDURE(),LONG
GetHeaderByIndex                PROCEDURE(LONG pIndex,*STRING pName,*STRING pValue)
AddHeader                       PROCEDURE(STRING pName,STRING pValue)
AppendHeader                    PROCEDURE(STRING pName,STRING pValue)
GetCookiesCount                 PROCEDURE(),LONG
GetCookieByIndex                PROCEDURE(LONG pIndex,*STRING pName,*STRING pValue)
AppendCookie                    PROCEDURE(STRING pName,STRING pValue,<STRING pPath>,<STRING pDomain>)
SetCookie                       PROCEDURE(STRING pName,STRING pValue,<STRING pPath>,<STRING pDomain>)
                              END

THttpServerBase               CLASS, TYPE, MODULE('cwhttpserver.clw'), LINK('cwhttpserver.clw')
inst                            LONG, PROTECTED
nCodePage                       LONG, PROTECTED
request                         &THttpServerRequest, PROTECTED
response                        &THttpServerResponse, PROTECTED
bListening                      BOOL, PROTECTED

Construct                       PROCEDURE()
Destruct                        PROCEDURE(), VIRTUAL

StartServer                     PROCEDURE(), VIRTUAL
StopServer                      PROCEDURE(), VIRTUAL
AddPrefix                       PROCEDURE(STRING pUri), VIRTUAL
Listen                          PROCEDURE(), BOOL, PROC, VIRTUAL

OnRequestReceived               PROCEDURE(STRING pContentType,STRING pHttpMethod,STRING pUrl), VIRTUAL, PROTECTED
                              END
