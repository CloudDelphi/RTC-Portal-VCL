program RtcHost;

{ Copyright (c) Danijel Tkalcec,
  RealThinClient components - http://www.realthinclient.com }

{$INCLUDE rtcDefs.inc}

uses
  {madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,}
  {$ifdef rtcDeploy}
  {$IFNDEF IDE_2006up} FastMM4, {$ENDIF}
  {$endif}
  rtcLog,
  SysUtils,
  rtcInfo,
  rtcService,
  Windows,
  SvcMgr,
  WinSvc,
  Forms,
  ShellApi,
  rtcFastStrings,
  RtcHostForm in 'RtcHostForm.pas' {MainForm},
  RtcHostSvc in 'RtcHostSvc.pas' {Rtc_HostService: TService},
  dmSetRegion in '..\Modules\dmSetRegion.pas' {dmSelectRegion},
  rdChat in '..\Modules\rdChat.pas' {rdChatForm},
  rdFileTrans in '..\Modules\rdFileTrans.pas' {rdFileTransfer},
  rdSetClient in '..\Modules\rdSetClient.pas' {rdClientSettings},
  rdSetHost in '..\Modules\rdSetHost.pas' {rdHostSettings},
  rdDesktopView in '..\Modules\rdDesktopView.pas' {rdDesktopViewer},
  rdDesktopSave in '..\Modules\rdDesktopSave.pas' {rdDesktopSaver: TDataModule},
  rdFileBrowse in '..\Modules\rdFileBrowse.pas' {rdFileBrowser};

//{$R rtcportaluac.res rtcportaluac.rc}
{$R *.res}

var
  cnt:integer;
  s:RtcString;

begin
StartLog;
try
  if IsDesktopMode(RTC_HOSTSERVICE_NAME) then
    begin
    If (Win32MajorVersion>=6) and (pos('-VISTA',uppercase(CmdLine))<>0) Then
      begin
      s:='';
      if pos('-AUTORUN',uppercase(CmdLine))<>0 then s:=s+' -AUTORUN';
      if pos('-SILENT',uppercase(CmdLine))<>0 then s:=s+' -SILENT';
      Write_File(ChangeFileExt(AppFileName,'.run'),s);

      ShellExecute(0,'open',PChar(String(AppFileName)),'/INSTALL /SILENT',nil,SW_SHOW);
      Sleep(500);
      ShellExecute(0,'open','net',PChar('start '+RTC_HOSTSERVICE_NAME),nil,SW_HIDE);
      cnt:=0;
      repeat
        Sleep(500);
        Inc(cnt);
        until not File_Exists(ChangeFileExt(AppFileName,'.run')) or (cnt>=20);
      Sleep(500);
      // Service will return FALSE from its "Start" event,
      // so it does not have to be stopped manually, we can simply uninstall it.
      ShellExecute(0,'open',PChar(String(AppFileName)),'/UNINSTALL /SILENT',nil,SW_HIDE);

      if File_Exists(ChangeFileExt(AppFileName,'.run')) then
        begin
        Delete_File(ChangeFileExt(AppFileName,'.run'));
        Forms.Application.Initialize;
        Forms.Application.Title := 'RTC Host';
        Forms.Application.CreateForm(TMainForm, MainForm);
        Forms.Application.Run;
        end;
      end
    else
      begin
      Forms.Application.Initialize;
      Forms.Application.Title := 'RTC Host';
      Forms.Application.CreateForm(TMainForm, MainForm);
      Forms.Application.Run;
      end;
    end
  else
    begin
    if not File_Exists(ChangeFileExt(AppFileName,'.run')) then
      xLog('RTC Host Service ...');
    SvcMgr.Application.Initialize;
    SvcMgr.Application.CreateForm(TRtc_HostService, Rtc_HostService);
    SvcMgr.Application.Run;
    end;
except
  on E:Exception do
    xLog('FATAL ERROR '+E.ClassName+': '+E.Message);
  end;
end.
