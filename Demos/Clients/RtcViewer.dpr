program RtcViewer;

{ Copyright (c) Danijel Tkalcec,
  RealThinClient components - http://www.realthinclient.com }

uses
  Forms,
  RtcControlForm in 'RtcControlForm.pas' {MainForm},
  rdChat in '..\Modules\rdChat.pas' {rdChatForm},
  rdDesktopView in '..\Modules\rdDesktopView.pas' {rdDesktopViewer},
  rdSetClient in '..\Modules\rdSetClient.pas' {rdClientSettings};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'RTC Viewer';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
