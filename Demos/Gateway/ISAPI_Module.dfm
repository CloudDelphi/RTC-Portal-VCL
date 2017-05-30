object ISAPIModule: TISAPIModule
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Left = 316
  Top = 133
  Height = 187
  Width = 292
  object Server: TRtcISAPIServer
    FixupRequest.RemovePrefix = True
    Left = 32
    Top = 15
  end
  object RtcGateTestProvider: TRtcDataProvider
    Server = Server
    OnCheckRequest = RtcGateTestProviderCheckRequest
    OnDataReceived = RtcGateTestProviderDataReceived
    Left = 148
    Top = 16
  end
  object Gateway: TRtcPortalGateway
    Server = Server
    WriteLog = True
    AutoRegisterUsers = True
    AutoSaveInfo = True
    EncryptionKey = 16
    ForceEncryption = True
    AutoSessionsLive = 600
    AutoSessions = True
    ModuleFileName = '/gate'
    Left = 148
    Top = 72
  end
end
