{ Copyright (c) Danijel Tkalcec,
  RealThinClient components - http://www.realthinclient.com }

unit ISAPI_Module;

interface

{$INCLUDE rtcDefs.inc}

uses
  SysUtils, Classes,

  Forms, // D4

  rtcLog, rtcInfo,
  rtcSystem, rtcCrypt,
  rtcThrPool,

  rtcISAPISrv, rtcConn, rtcDataSrv,
  rtcSrvModule, rtcPortalGate;

type
  TISAPIModule = class(TDataModule)
    Server: TRtcISAPIServer;
    RtcGateTestProvider: TRtcDataProvider;
    Gateway: TRtcPortalGateway;
    procedure DataModuleCreate(Sender: TObject);
    procedure RtcGateTestProviderCheckRequest(Sender: TRtcConnection);
    procedure RtcGateTestProviderDataReceived(Sender: TRtcConnection);
  private
    { Private declarations }
  public
    { Public declarations }

    procedure LoadSetup;
  end;

var
  ISAPIModule: TISAPIModule;

implementation

{$R *.dfm}

procedure TISAPIModule.DataModuleCreate(Sender: TObject);
  begin
  StartLog;
  try
    xLog('Initializing RTC Gateway ISAPI ...');

    LoadSetup;
    Gateway.InfoFileName:=ChangeFileExt(AppFileName,'.usr');

    { If your WebServer doesn't like the ISAPI to "hold" connections,
      you should set the "Gateway.TimeoutResponse" to 0 (zero).
      The default setting for the Gateway would be 20 (sec),
      but if you have a lot of users on the Gateway and your WebServer
      does not like that RTC Host will be keeping a thread busy,
      you should try with a lower TimeoutResponse. }

    xLog('RTC GATEWAY ISAPI is READY FOR USE.');
  except
    on E:Exception do
      Log('Error '+E.ClassName+': '+E.Message);
    end;
  end;

procedure TISAPIModule.LoadSetup;
  var
    CfgFileName:String;
    s:RtcString;
    s2:RtcByteArray;
    info:TRtcRecord;
    len:int64;
    len2:longint;
  begin
  s2:=nil;
  CfgFileName:= ChangeFileExt(AppFileName,'.inf');
  xLog('Reading configuration from "'+CfgFileName+'" ...');
  len:=File_Size(CfgFileName);
  if len>5 then
    begin
    s:=Read_File(CfgFileName,len-5,5);
    if s='@RTC@' then
      begin
      s2:=Read_FileEx(CfgFileName,len-4-5,4);
      Move(s2[0],len2,4);
      if (len2=len-4-5) then
        begin
        s := Read_File(CfgFileName,len-4-5-len2,len2,rtc_ShareDenyNone);
        DeCrypt(s, 'RTC Gateway 2.0');
        try
          info:=TRtcRecord.FromCode(s);
        except
          info:=nil;
          end;
        if assigned(info) then
          try
            if info.asString['SecureKey']<>'' then
              xLog('Using Secure Key.')
            else
              xLog('Secure Key is empty.');
            Gateway.SecureKey:=info.asString['SecureKey'];
            Gateway.AutoRegisterUsers:=not info.asBoolean['NoAutoReg'];
          finally
            info.Free;
          end;
        end;
      end;
    end;
  xLog('... end of configuration file.');
  end;

procedure TISAPIModule.RtcGateTestProviderCheckRequest(Sender: TRtcConnection);
  begin
  with TRtcDataServer(Sender) do
    if Request.FileName='/' then
      Accept;
  end;

procedure TISAPIModule.RtcGateTestProviderDataReceived(Sender: TRtcConnection);
  begin
  with TRtcDataServer(Sender) do
    if Request.Complete then
      begin
      Write('<HTML><BODY>');
      Write('RTC Portal Gateway ISAPI is now ready to be used.<BR><BR>');
      Write('RTC Portal Host and Control can be downloaded from <a href="http://www.realthinclient.com">www.RealThinClient.com</a>');
      Write('</BODY></HTML>');
      end;
  end;

end.
