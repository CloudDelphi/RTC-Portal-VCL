{ Copyright (c) Danijel Tkalcec,
  RealThinClient components - http://www.realthinclient.com }

unit RtcGatewaySvc;

interface

{$INCLUDE rtcDefs.inc}

uses
  Windows, Messages, SysUtils, Classes,
  Graphics, Controls, SvcMgr, Dialogs,

  rtcLog, rtcInfo, rtcCrypt,
  rtcSystem, rtcThrPool,

  rtcSrvModule, rtcPortalGate,
  rtcDataSrv, rtcConn, rtcHttpSrv;

const
  RTC_GATEWAYSERVICE_NAME='Rtc_GatewayService';

type
  TRtc_GatewayService = class(TService)
    HttpServer: TRtcHttpServer;
    RtcGateTestProvider: TRtcDataProvider;
    Gateway: TRtcPortalGateway;
    procedure ServiceShutdown(Sender: TService);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServiceDestroy(Sender: TObject);
    procedure RtcGateTestProviderCheckRequest(Sender: TRtcConnection);
    procedure RtcGateTestProviderDataReceived(Sender: TRtcConnection);
    procedure HttpServerListenError(Sender: TRtcConnection; E: Exception);
  private
    { Private declarations }
  public
    { Public declarations }
    Running:boolean;

    function GetServiceController:
      {$IFDEF VER120} PServiceController;
      {$ELSE} TServiceController; {$ENDIF} override;

    procedure StartMyService;
    procedure StopMyService;

    procedure LoadSetup;
  end;

var
  Rtc_GatewayService: TRtc_GatewayService;

implementation

{$R *.DFM}

procedure ServiceController(CtrlCode: DWord); stdcall;
  begin
  Rtc_GatewayService.Controller(CtrlCode);
  end;

function TRtc_GatewayService.GetServiceController:
  {$IFDEF VER120} PServiceController;
  {$ELSE} TServiceController; {$ENDIF}
  begin
  Result := {$IFDEF VER120}@{$ENDIF}ServiceController;
  end;

procedure TRtc_GatewayService.ServiceStart(Sender: TService; var Started: Boolean);
  begin
  StartMyService;
  Started:=Running;
  end;

procedure TRtc_GatewayService.ServiceStop(Sender: TService; var Stopped: Boolean);
  begin
  StopMyService;
  Stopped:=not Running;
  end;

procedure TRtc_GatewayService.ServiceShutdown(Sender: TService);
  begin
  StopMyService;
  end;

procedure TRtc_GatewayService.StartMyService;
  begin
  if not running then
    begin
    StartLog;
    try
      LOG_THREAD_EXCEPTIONS:=True;
      LOG_EXCEPTIONS:=True;

      RTC_THREAD_PRIORITY:=tpHighest;

      Gateway.InfoFileName:=ChangeFileExt(AppFileName,'.usr');

      LoadSetup;

      HttpServer.Listen;

      running := True;
    except
      on E:Exception do
        Log('Error '+E.ClassName+': '+E.Message);
      end;
    end;
  end;

procedure TRtc_GatewayService.StopMyService;
  begin
  if running then
    begin
    try HttpServer.StopListenNow; except end;
    running := False;
    end;
  end;

procedure TRtc_GatewayService.LoadSetup;
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
          begin
          try
            if info.asBoolean['ISAPI'] then
              Gateway.ModuleFileName:=info.asString['DLL']+'/gate'
            else
              Gateway.ModuleFileName:='/$rdgate';

            Gateway.SecureKey:=info.asString['SecureKey'];
            Gateway.AutoRegisterUsers:=not info.asBoolean['NoAutoReg'];

            if info.asBoolean['Bind'] then
              HttpServer.ServerAddr:=info.asString['Address']
            else
              HttpServer.ServerAddr:='';
            HttpServer.ServerPort:=info.asString['Port'];

          finally
            info.Free;
            end;
          end;
        end;
      end;
    end;
  end;

procedure TRtc_GatewayService.ServiceDestroy(Sender: TObject);
  begin
  HttpServer.StopListenNow;
  end;

procedure TRtc_GatewayService.RtcGateTestProviderCheckRequest(
  Sender: TRtcConnection);
begin
  with TRtcDataServer(Sender) do
    if Request.FileName='/' then
      Accept;
end;

procedure TRtc_GatewayService.RtcGateTestProviderDataReceived(
  Sender: TRtcConnection);
begin
  with TRtcDataServer(Sender) do
    if Request.Complete then
      begin
      Write('<HTML><BODY>');
      Write('RTC Portal Gateway SERVICE is now ready to be used.<BR><BR>');
      Write('RTC Portal Host and Control can be downloaded from <a href="http://www.realthinclient.com">www.RealThinClient.com</a>');
      Write('</BODY></HTML>');
      end;
end;

procedure TRtc_GatewayService.HttpServerListenError(Sender: TRtcConnection;
    E: Exception);
  begin
  xLog('Error: '+E.Message);
  xLog('GATEWAY IS NOT ACCESSIBLE ANYMORE.');
  end;

end.
