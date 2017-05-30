{
  @html(<b>)
  RTC Portal Component Registration
  @html(</b>)
  Copyright 2004-2017 (c) RealThinClient.com (http://www.realthinclient.com) 
  @html(<br><br>)

  All RTC Portal VCL and Non-VCL components are being
  registered to Delphi component palette using this unit.
}
unit rtcPortalReg;

{$INCLUDE rtcDefs.inc}

interface

// This procedure is being called by Delphi to register the components.
procedure Register;

implementation

uses
  rtcPortalCli, rtcPortalHttpCli,
  rtcpFileTrans, rtcpFileTransUI,
  rtcpChat, rtcpChatUI,
  rtcpDesktopHost,
  rtcpDesktopControl, rtcpDesktopControlUI,
  rtcpFileExplore,
  rtcpCustomComm,
  rtcPortalGate,
  Classes;

procedure Register;
begin
  RegisterComponents('RTC Portal', [TRtcPortalClient, TRtcHttpPortalClient,
    TRtcPFileTransfer, TRtcPFileTransferUI, TRtcPChat, TRtcPChatUI,
    TRtcPDesktopHost, TRtcPDesktopControl, TRtcPDesktopControlUI,
    TRtcPDesktopViewer, TRtcPFileExplorer, TRtcPCustomCommand,
    TRtcPortalGateway]);
end;

end.
