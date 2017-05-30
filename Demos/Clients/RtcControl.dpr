program RtcControl;

{ Copyright (c) Danijel Tkalcec,
  RealThinClient components - http://www.realthinclient.com }

{$INCLUDE rtcDefs.inc}

uses
  {$ifdef rtcDeploy}
  {$IFNDEF IDE_2006up}FastMM4,{$ENDIF}
  {$endif}
  rtcLog,
  Forms,
  RtcControlForm in 'RtcControlForm.pas' {MainForm},
  rdChat in '..\Modules\rdChat.pas' {rdChatForm},
  rdDesktopView in '..\Modules\rdDesktopView.pas' {rdDesktopViewer},
  rdFileTrans in '..\Modules\rdFileTrans.pas' {rdFileTransfer},
  rdSetClient in '..\Modules\rdSetClient.pas' {rdClientSettings},
  dmSetRegion in '..\Modules\dmSetRegion.pas' {dmSelectRegion},
  rdFileBrowse in '..\Modules\rdFileBrowse.pas' {rdFileBrowser};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'RTC Control';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
