library RtcGateway_ISAPI;

{ Copyright (c) Danijel Tkalcec,
  RealThinClient components - http://www.realthinclient.com }

{$include rtcDeploy.inc}

uses
  ActiveX,
  Forms,
  ComObj,
  rtcISAPIApp,
  ISAPI_Module in 'ISAPI_Module.pas' {ISAPIModule: TDataModule};

{$R *.res}

exports
  GetExtensionVersion,
  HttpExtensionProc,
  TerminateExtension;

begin
  Application.Initialize;
  Application.CreateForm(TISAPIModule, ISAPIModule);
  Application.Run;
end.
