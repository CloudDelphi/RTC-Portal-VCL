object Rtc_GatewayService: TRtc_GatewayService
  OldCreateOrder = False
  OnDestroy = ServiceDestroy
  DisplayName = 'RTC Gateway v5'
  OnShutdown = ServiceShutdown
  OnStart = ServiceStart
  OnStop = ServiceStop
  Left = 349
  Top = 123
  Height = 180
  Width = 305
  object HttpServer: TRtcHttpServer
    MultiThreaded = True
    Timeout.AfterConnecting = 300
    OnListenError = HttpServerListenError
    FixupRequest.RemovePrefix = True
    MaxRequestSize = 16000
    MaxHeaderSize = 64000
    Left = 48
    Top = 11
  end
  object RtcGateTestProvider: TRtcDataProvider
    Server = HttpServer
    OnCheckRequest = RtcGateTestProviderCheckRequest
    OnDataReceived = RtcGateTestProviderDataReceived
    Left = 172
    Top = 12
  end
  object Gateway: TRtcPortalGateway
    Server = HttpServer
    WriteLog = True
    AutoRegisterUsers = True
    AutoSaveInfo = True
    EncryptionKey = 16
    ForceEncryption = True
    AutoSessionsLive = 600
    AutoSessions = True
    ModuleFileName = '/$rdgate'
    Left = 172
    Top = 72
  end
end
