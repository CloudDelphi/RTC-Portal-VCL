object Rtc_HostService: TRtc_HostService
  OldCreateOrder = False
  OnCreate = ServiceCreate
  OnDestroy = ServiceDestroy
  DisplayName = 'RTC Host v5'
  Interactive = True
  OnShutdown = ServiceShutdown
  OnStart = ServiceStart
  OnStop = ServiceStop
  Left = 338
  Top = 150
  Height = 289
  Width = 289
  object PClient: TRtcHttpPortalClient
    UserVisible = True
    GwStoreParams = True
    OnLogIn = PClientLogIn
    OnLogOut = PClientLogOut
    OnParams = PClientParams
    OnStart = PClientStart
    OnError = PClientError
    OnFatalError = PClientFatalError
    AutoSyncEvents = True
    DataEncrypt = 16
    DataForceEncrypt = True
    RetryFirstLogin = 3
    RetryOtherCalls = 10
    MultiThreaded = True
    Gate_Timeout = 300
    Left = 37
    Top = 61
  end
  object PFileTrans: TRtcPFileTransfer
    Client = PClient
    BeTheHost = True
    GwStoreParams = True
    OnUserJoined = PFileTransUserJoined
    OnUserLeft = PFileTransUserLeft
    On_FileSendStart = PFileTrans_FileSendStart
    On_FileRecvStart = PFileTrans_FileRecvStart
    Left = 97
    Top = 9
  end
  object PChat: TRtcPChat
    Client = PClient
    BeTheHost = True
    GwStoreParams = True
    OnUserJoined = PChatUserJoined
    OnUserLeft = PChatUserLeft
    Left = 97
    Top = 57
  end
  object PDesktop: TRtcPDesktopHost
    Client = PClient
    GwStoreParams = True
    FileTransfer = PFileTrans
    OnUserJoined = PDesktopUserJoined
    OnUserLeft = PDesktopUserLeft
    Left = 97
    Top = 105
  end
  object timCheckProcess: TTimer
    Enabled = False
    OnTimer = timCheckProcessTimer
    Left = 188
    Top = 8
  end
  object PDesktopControl: TRtcPDesktopControl
    Client = PClient
    OnNewUI = PDesktopControlNewUI
    Left = 96
    Top = 156
  end
  object timCheckSvc: TTimer
    Enabled = False
    Interval = 5000
    OnTimer = timCheckSvcTimer
    Left = 188
    Top = 80
  end
end
