program RtcGateway;

{ Copyright (c) Danijel Tkalcec,
  RealThinClient components - http://www.realthinclient.com }

{$INCLUDE rtcDefs.inc}

uses
  {$ifdef rtcDeploy}
  {$IFNDEF IDE_2006up}FastMM4,{$ENDIF}
  {$endif}
  rtcLog,
  SysUtils,
  rtcService,
  Windows,
  SvcMgr,
  WinSvc,
  Forms,
  RtcGatewayForm in 'RtcGatewayForm.pas' {MainForm},
  RtcGatewaySvc in 'RtcGatewaySvc.pas' {Rtc_GatewayService: TService};

{$R *.res}

begin
StartLog;
try
  if IsDesktopMode(RTC_GATEWAYSERVICE_NAME) then
    begin
    Forms.Application.Initialize;
    Forms.Application.Title := 'RTC Gateway';
  Forms.Application.CreateForm(TMainForm, MainForm);
  Forms.Application.Run;
    end
  else
    begin
    xLog('Starting RTC Gateway ...');
    SvcMgr.Application.Initialize;
    SvcMgr.Application.CreateForm(TRtc_GatewayService, Rtc_GatewayService);
    SvcMgr.Application.Run;
    end;
except
  on E:Exception do
    xLog('FATAL ERROR '+E.ClassName+': '+E.Message);
  end;
end.
