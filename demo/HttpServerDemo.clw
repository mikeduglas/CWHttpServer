  PROGRAM

  INCLUDE('cwhttpserver.inc'), ONCE

  MAP
    RunServer()

    INCLUDE('printf.inc'), ONCE
  END

  CODE
  RunServer()
  MESSAGE('Server stopped.', 'CWHttpServer', ICON:Exclamation)

  
RunServer                     PROCEDURE()
url                             STRING('http://localhost:8000/')
pageData                        STRING( |           
                                  '<<!DOCTYPE>' & |
                                  '<<html>' & |
                                  '  <<head>' & |
                                  '    <<title>CWHttpServer Example<</title>' & |
                                  '  <</head>' & |
                                  '  <<body>' & |
                                  '    <<p>Page Views: %i<</p>' & |
                                  '    <<form method=''post'' action=''shutdown''>' & |
                                  '      <<input type=''submit'' value=''Shutdown'' %s>' & |
                                  '    <</form>' & |
                                  '  <</body>' & |
                                  '<</html>')
pageViews                       LONG(0)

httpServer                      CLASS(THttpServerBase)
OnRequestReceived                 PROCEDURE(STRING pContentType,STRING pHttpMethod,STRING pUrl), DERIVED, PROTECTED
                                END

  CODE
  httpServer.AddPrefix(url)
  httpServer.StartServer()
  
  LOOP
    IF NOT httpServer.Listen()
      BREAK
    END
  END
  
  httpServer.StopServer()


httpServer.OnRequestReceived  PROCEDURE(STRING pContentType,STRING pHttpMethod,STRING pUrl)
request                         &THttpServerRequest
response                        &THttpServerResponse
disableSubmit                   STRING(20)
  CODE
  request &= SELF.request
  response &= SELF.response
  
  IF pHttpMethod = 'POST' AND request.AbsolutePath() = '/shutdown'
    !- shutdown
    SELF.bListening = FALSE
    disableSubmit = 'disabled'  !- disable shutdown button
  END
    
  IF request.AbsolutePath() <> '/favicon.ico' !- ignore favicon request
    !- send html response
    pageViews +=1
    response.StatusCode(200)  !- OK
    response.Content(printf(pageData, pageViews, disableSubmit), 'text/html')
  END
    
