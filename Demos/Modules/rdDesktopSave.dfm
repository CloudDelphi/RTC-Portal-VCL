object rdDesktopSaver: TrdDesktopSaver
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Left = 562
  Top = 145
  Height = 112
  Width = 242
  object myUI: TRtcPDesktopControlUI
    AutoScroll = True
    OnClose = myUIClose
    OnError = myUIError
    OnLogOut = myUILogOut
    OnData = myUIData
    Left = 20
    Top = 12
  end
end
