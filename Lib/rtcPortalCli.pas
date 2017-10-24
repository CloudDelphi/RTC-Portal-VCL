{ Copyright 2004-2017 (c) RealThinClient.com (http://www.realthinclient.com) }

unit rtcPortalCli;

interface

{$INCLUDE rtcDefs.inc}

uses
  SysUtils, Classes,
  Windows, ComObj, ActiveX, SyncObjs,

  rtcSystem, rtcLog,
  rtcZLib, rtcInfo, rtcConn,
  rtcFunction, rtcDataCli, rtcCliModule,

  rtcPortalMod;

var
  S_RTCP_ERROR_CONNECT: String = 'Unable to connect to the Gateway.';
  S_RTCP_ERROR_NOCRYPT: String = 'Gateway does NOT support Encryption.';
  S_RTCP_ERROR_NEEDCRYPT: String = 'Gateway requires Encryption.';
  S_RTCP_ERROR_WRONGCRYPT: String = 'Invalid Encryption/Secure Key.';
  S_RTCP_ERROR_INVALID: String = 'Invalid response from the Gateway (code %s).';
  S_RTCP_ERROR_REJECTED: String = 'Response from the Gateway was rejected.';

  S_RTCP_ERROR_USERLIST
    : String = 'RestrictAccess is FALSE, User List has no relevance.';
  S_RTCP_ERROR_SUPERUSERS
    : String =
    'User has no access (not in User List), can not add to Super Users list.';

type
  TrtcpCompressLevel = (rtcpCompNormal, rtcpCompMax, rtcpCompFast, rtcpCompOff);

var
  RTCP_COMPRESS_LEVEL: array [TrtcpCompressLevel] of TZCompressionLevel = (
    zcDefault,
    zcMax,
    zcFastest,
    zcNone
  );

type
  TRtcPortalCli = class(TAbsPortalClient)
  private
    FPublish, FSubscribe,
    FStarting, FParamsLoaded: boolean;

    FGetModule: TRtcClientModule;
    FPutModule: TRtcClientModule;

    FLoginID: RtcString;
    FCS: TCriticalSection;
    FErrorGet: integer;
    FErrorPut: integer;

    RPut, RGet, RPreStart, RStart, RLogout, RSetParam, RGetParams: TRtcResult;

    FLoggedIn: boolean;

    MsgTick: integer;
    NowSending, SentNext: boolean;
    SenderLocked: integer;
    LastStoredFn: boolean;
    LastStoredUser: String;
    LastStoredArr: boolean;
    StoredUserData: TRtcDataSet;

    FForceEncrypt: boolean;
    FRetryOtherCalls: integer;
    FAutoEncrypt: integer;
    FRetryFirstLogin: integer;
    FModuleFileName: RtcString;
    FSecureKey: RtcString;
    FModuleHost: RtcString;
    FCompress: TrtcpCompressLevel;
    FAutoSync: boolean;

    FClient4Put: TRtcDataClient;
    FClient4Get: TRtcDataClient;
    FLink4Put: TRtcDataClientLink;
    FLink4Get: TRtcDataClientLink;

    FLoginUserName: String;
    FLoginPassword: String;
    FLoginUserInfo: TRtcValue;

    procedure SetAutoEncrypt(const Value: integer);
    procedure SetCompress(const Value: TrtcpCompressLevel);
    procedure SetForceEncrypt(const Value: boolean);
    procedure SetModuleFileName(const Value: RtcString);
    procedure SetModuleHost(const Value: RtcString);
    procedure SetRetryFirstLogin(const Value: integer);
    procedure SetRetryOtherCalls(const Value: integer);
    procedure SetSecureKey(const Value: RtcString);
    procedure SetAutoSync(const Value: boolean);
    procedure SetClient4Get(const Value: TRtcDataClient);
    procedure SetClient4Put(const Value: TRtcDataClient);
    procedure SetLink4Get(const Value: TRtcDataClientLink);
    procedure SetLink4Put(const Value: TRtcDataClientLink);

    function NextTick: integer;

    procedure PackNow;
    procedure SendNow(Sender: TObject; FromPut: boolean = False);

    procedure RGetParamsReturn(Sender: TRtcConnection; Data, Result: TRtcValue);
    procedure RSetParamReturn(Sender: TRtcConnection; Data, Result: TRtcValue);

    procedure RPreStartReturn(Sender: TRtcConnection; Data, Result: TRtcValue);
    procedure RStartReturn(Sender: TRtcConnection; Data, Result: TRtcValue);
    procedure RGetReturn(Sender: TRtcConnection; Data, Result: TRtcValue);

    procedure RLogoutReturn(Sender: TRtcConnection; Data, Result: TRtcValue);

    procedure RPutReturn(Sender: TRtcConnection; Data, Result: TRtcValue);
    procedure RPutRequestAborted(Sender: TRtcConnection;
      Data, Result: TRtcValue);

    procedure ClientModuleLogin(Sender: TRtcConnection; Data: TRtcValue);

    procedure ClientModuleLoginGetResult(Sender: TRtcConnection;
      Data, Result: TRtcValue);
    procedure ClientModuleGetResponseAbort(Sender: TRtcConnection);
    procedure ClientModuleGetEncryptNotSupported(Sender: TRtcConnection);
    procedure ClientModuleGetEncryptRequired(Sender: TRtcConnection);
    procedure ClientModuleGetEncryptWrongKey(Sender: TRtcConnection);
    procedure ClientModuleGetResponseReject(Sender: TRtcConnection);
    procedure ClientModuleGetResponseError(Sender: TRtcConnection);
    procedure ClientModuleGetBeginRequest(Sender: TRtcConnection);
    procedure ClientModuleGetConnectLost(Sender: TRtcConnection);

    procedure ClientModuleLoginPutResult(Sender: TRtcConnection;
      Data, Result: TRtcValue);
    procedure ClientModulePutResponseAbort(Sender: TRtcConnection);
    procedure ClientModulePutEncryptNotSupported(Sender: TRtcConnection);
    procedure ClientModulePutEncryptRequired(Sender: TRtcConnection);
    procedure ClientModulePutEncryptWrongKey(Sender: TRtcConnection);
    procedure ClientModulePutResponseReject(Sender: TRtcConnection);
    procedure ClientModulePutResponseError(Sender: TRtcConnection);
    procedure ClientModulePutBeginRequest(Sender: TRtcConnection);
    procedure ClientModulePutConnectLost(Sender: TRtcConnection);

    procedure DoErrorGet(Sender: TObject; Msg: TRtcValue);
    procedure DoErrorPut(Sender: TObject; Msg: TRtcValue);
    procedure DoFatalErrorGet(Sender: TObject; Msg: TRtcValue);
    procedure DoFatalErrorPut(Sender: TObject; Msg: TRtcValue);

    procedure Prepare;
    procedure Start;
    procedure LogOut;
    
    procedure SetLoginUserInfo(const Value: TRtcRecord);
    function GetLoginUserInfo: TRtcRecord;

  protected

    function GetActive: boolean; override;
    procedure SetActive(const Value: boolean); override;

    function GetParamsLoaded: boolean; override;
    procedure SetParamsLoaded(const Value: boolean); override;

    function GetLoginUsername: String; override;
    procedure SetLoginUsername(const Value: String); override;

    function GetPublish: boolean; override;
    procedure SetPublish(const Value: boolean); override;

    function GetSubscribe: boolean; override;
    procedure SetSubscribe(const Value: boolean); override;

  protected

    function GetLoginPassword: String;
    procedure SetLoginPassword(const Value: String);

    function GetLoggedIn: boolean;
    procedure SetLoggedIn(const Value: boolean);

    property LoggedIn: boolean read GetLoggedIn write SetLoggedIn;

    { You can link your components (one or more) to a DataClientLink component
      by assigning your @Link(TRtcDataClientLink) component to child component's Link property.
      Doing this, you only have to set the Client property for the master
      DataClientLink component and don't need to do it for every single
      DataRequest component. }
    property Link_Get: TRtcDataClientLink read FLink4Get write SetLink4Get;
    { You can also link your components (one or more) directly to your
      DataClient connection component by assigning your
      @Link(TRtcDataClient) connection component to this child component's Client property.
      This is useful if you don't want to use a DataClientLink. }
    property Client_Get: TRtcDataClient read FClient4Get write SetClient4Get;
    { You can link your components (one or more) to a DataClientLink component
      by assigning your @Link(TRtcDataClientLink) component to chind component's Link property.
      Doing this, you only have to set the Client property for the master
      DataClientLink component and don't need to do it for every single
      DataRequest component. }
    property Link_Put: TRtcDataClientLink read FLink4Put write SetLink4Put;
    { You can also link your components (one or more) directly to your
      DataClient connection component by assigning your
      @Link(TRtcDataClient) connection component to this child component's Client property.
      This is useful if you don't want to use a DataClientLink. }
    property Client_Put: TRtcDataClient read FClient4Put write SetClient4Put;

    { To be able to call remote functions, this TRtcPortalCli's ModuleFileName
      property has to be identical to the "ModuleFileName" property of the PServerModule
      which you want to use. }
    property ModuleFileName: RtcString read FModuleFileName
      write SetModuleFileName;

    { "Request.Host" will be assigned this property before sending the request out. @html(<br>)
      For servers which serve multiple hosts, or where ServerModule has assigned its
      ModuleHost property, it is very important to set this TRtcPortalCli's ModuleHost
      property to the appropriate host name. }
    property ModuleHost: RtcString read FModuleHost write SetModuleHost;

  public
    constructor Create(AOWner: TComponent); override;
    destructor Destroy; override;

    { TRtcClientModule used for sending data to the Gateway.
      It can be used to make calls to remote functions assigned
      to a "HelperGroup" and linked to the TRtcPortalGateway component. }
    property Module:TRtcClientModule read FPutModule;

    { If you want to send data from outside of the "SenderLoop" which is
      normally being sent from the "SenderLoop", you can use this function to
      check if you may do so. The function will return FALSE if the data
      is already being sent and/or prepared in the "SenderLoop",
      in which case you should NOT send it from elsewhere.
      You should NOT use this function for "non-loop" sending. }
    function canSendNext: boolean; override;

    { Use this method to set any users parameter.
      All parameter changes will be sent to the Gateway.
      "ParamValue" object will be destroyed by the method (do not destroy it yourself). }
    procedure ParamSet(Sender: TObject; const ParamName: String;
      ParamValue: TRtcValueObject); override;
    { Use this method to add a new element to users parameter.
      All parameter changes will be sent to the Gateway.
      "ParamValue" object will be destroyed by the method (do not destroy it yourself). }
    procedure ParamAdd(Sender: TObject; const ParamName: String;
      ParamValue: TRtcValueObject); override;
    { Use this method to remove an element from users parameter.
      All parameter changes will be sent to the Gateway.
      "ParamValue" object will be destroyed by the method (do not destroy it yourself). }
    procedure ParamDel(Sender: TObject; const ParamName: String;
      ParamValue: TRtcValueObject); override;

    { You want to send a number of small packages to the Gateway,
      but do not want them to be sent separately (reduce latency effect)?
      You can call LockSender before you start sending data out
      and call UnLockSender when you have prepared everything for sending. }
    procedure LockSender; override;

    { You want to send a number of small packages to the Gateway,
      but do not want them to be sent separately (reduce latency effect)?
      You can call LockSender before you start sending data out
      and call UnLockSender when you have prepared everything for sending. }
    procedure UnLockSender(Sender: TObject); override;

    { Send a PING to the Gateway (no data). }
    procedure SendPing(Sender: TObject); override;

    { Send data "rec" to the user "username".
      "rec" object will be destroyed in the method (do not try to free it yourself). }
    procedure SendToUser(Sender: TObject; const username: String;
      rec: TRtcFunctionInfo); override;

    { Send data "rec" to your group "Group".
      "rec" object will be destroyed in the method (do not try to free it yourself). }
    procedure SendToMyGroup(Sender: TObject; const Group: String;
      rec: TRtcFunctionInfo); override;

    { Add user "username" to your group "Group". If the user is online,
      all data you send to your group "Group" will also be sent to the user "username". }
    procedure AddUserToMyGroup(Sender: TObject;
      const username, Group: String); override;

    { Remove user "username" from your group "Group". From this point on,
      the user "username" will no longer receive data you send to your group "Group". }
    procedure RemoveUserFromMyGroup(Sender: TObject;
      const username, Group: String); override;

    { Disband your group "Group". After a group has been disbanded, it will have no
      more group members, so it will no longer make sense sending data to that group.
      You can always start a new group, by adding users to it [ AddUserToMyGroup() ]. }
    procedure DisbandMyGroup(Sender: TObject; const Group: String); override;

    { Remove yourself from the group "Group" maintained by user "username". }
    procedure LeaveUserGroup(Sender: TObject;
      const username, Group: String); override;

  public
    { Use the CallEvent() method to call the "Event" synchronized when AutoSyncEvents is TRUE,
      or call it from a background thread when AutoSyncEvents is FALSE.
      No objects should be destroyed in any of the CallEvent() methods. }
    procedure CallEvent(Sender: TObject; Event: TRtcCustomDataEvent;
      Obj: TObject; Data: TRtcValue); overload; override;
    procedure CallEvent(Sender: TObject; Event: TRtcCustomDataEvent;
      Data: TRtcValue); overload; override;
    procedure CallEvent(Sender: TObject; Event: TRtcCustomEvent; Obj: TObject);
      overload; override;
    procedure CallEvent(Sender: TObject; Event: TRtcCustomEvent);
      overload; override;

    { Custom User Info will be sent every time with User Login data and forwarded
      to all other users when we become visible to them, or join their group.
      You can either use the LoginUserInfo property to assign each individial
      parameter by name, or you can assign a TRtcRecord directly to "LoginUserInfo"
      if you want to prepare parameters in a TRtcRecord and then set all parameters at once.
      
      Only a copy of the original TRtcRecord object will be assigned, so you still need
      to destroy the original TRtcRecord, if you have created it just for the purpose
      of assigning it to this property. But, you can safely assign any TRtcRecord object
      you don't own directly, because it won't be modified nor used after the assignment.
      Use the "RemoteUserInfo" property to access UserInfo received from other users.

      "LoginUserInfo" getter returns a direct pointer to the internal TRtcRecord object.
      Do NOT destroy that complete object by calling "Free" like "LoginUserInfo.Free".
      If there was no TRtcRecord created before, it will be created on first use.
      
      WARNING: Changing the "LoginUsername" property will CLEAR all User info assigned here,
      so you need to set "LoginUserName" first, then you can populate all "LoginUserInfo" values. }
    property LoginUserInfo:TRtcRecord read GetLoginUserInfo write SetLoginUserInfo;

  published

    { If all events which your component implements have to access the GUI,
      to avoid checking the "Sender.inMainThread" and calling Sender.Sync(Event)
      for every event, you can set this AutoSyncEvent property to true,
      which will ensure that any event assigned to this component will
      be called from the main thread (synchronized, when needed). }
    property AutoSyncEvents: boolean read FAutoSync write SetAutoSync
      default False;

{$IFDEF COMPRESS}
    { Use this property to define what compression level you want to use when sending data from
      this Portal Client to another Portal Client. Default Compression value is "rtcpCompNormal".
      You can use different compression levels for each Portal Client. If your Portal Client needs to
      work with Portal Clients which don't support compression, you have to use "cNone".
      Note that data will be compressed here and uncompressed by the receiving Client.
      There will be no decompression/compression done on the Server side. }
    property DataCompress: TrtcpCompressLevel read FCompress write SetCompress
      default rtcpCompNormal;
{$ENDIF}
    { Set this property to a value other than 0 if you want to use automatic Encryption
      with a random generated key of "EncryptKey" bytes. One byte stands for
      encryption strength of 8 bits. For strong 256-bit encryption, use 32 bytes. @html(<br><br>)

      The final encryption key is combined from a client-side key and a key
      received from the server, while server decides about its encryption strength.
      If server doesn't support Encryption, data will not be encrypted,
      regardless of the value you use for EncryptionKey. }
    property DataEncrypt: integer read FAutoEncrypt write SetAutoEncrypt
      default 0;

    { If you need a 100% secure connection, define a Secure Key String
      (combination of letters, numbers and special characters) for each
      PServerModule/TRtcPortalCli pair, additionally to the EncryptionKey value.
      TRtcPortalCli will be able to communicate with a PServerModule ONLY if
      they both use the same SecureKey. Default value for the SecureKey is
      an empty String (means: no secure key). @html(<br><br>)

      SecureKey will be used in the encryption initialisation handshake,
      to encrypt the first key combination sent by the ClientModule.
      Since all other data packages are already sent using some kind of encryption,
      by defining a SecureKey, you encrypt the only key part which would have
      been sent out without special encryption. }
    property DataSecureKey: RtcString read FSecureKey write SetSecureKey;

    { Setting this property to TRUE will tell this TRtcPortalCli to work with the
      Server ONLY if Server supports encryption. If EncryptionKey is > 0 and
      server doesn't support encryption, function calls will not be passed to
      the server and any response coming from the server will be rejected, until
      server enables encryption. }
    property DataForceEncrypt: boolean read FForceEncrypt write SetForceEncrypt
      default False;

    { Set this property to a value other than 0 (zero) if you want the TRtcPortalCli to
      try logging in again (how many times) if the first login attempt fails.
      To have the TRtcPortalCli retry unlimited number of times, set this value to -1. }
    property RetryFirstLogin: integer read FRetryFirstLogin
      write SetRetryFirstLogin default 0;

    { Set this property to a value other than 0 (zero) if you want the TRtcPortalCli to
      retry sending other calls (calls made once first login was successful), in case a
      call to the Server should fail because of a disconnect or any other connection problem.
      To have the TRtcPortalCli retry unlimited number of times, set this value to -1. }
    property RetryOtherCalls: integer read FRetryOtherCalls
      write SetRetryOtherCalls default 0;

    { Login Password }
    property LoginPassword: String read FLoginPassword write SetLoginPassword;
  end;

  { RTC Portal Client component working with any RTC SDK connection components. }
  TRtcPortalClient = class(TRtcPortalCli)
  published
    property Link_Get;
    property Client_Get;
    property Link_Put;
    property Client_Put;
    property ModuleFileName;
    property ModuleHost;
  end;

implementation

{ TRtcPortalCli }

constructor TRtcPortalCli.Create(AOWner: TComponent);
begin
  inherited;
  { "GET Module" -> used for retrieving data and notifications from the Gateway. }
  FGetModule := TRtcClientModule.Create(nil);
  FGetModule.AutoSessions := True;
  FGetModule.HyperThreading := True;

  FGetModule.OnBeginRequest := ClientModuleGetBeginRequest;
  FGetModule.OnConnectLost := ClientModuleGetConnectLost;
  FGetModule.OnEncryptNotSupported := ClientModuleGetEncryptNotSupported;
  FGetModule.OnEncryptRequired := ClientModuleGetEncryptRequired;
  FGetModule.OnEncryptWrongKey := ClientModuleGetEncryptWrongKey;

  FGetModule.OnLogin := ClientModuleLogin;
  FGetModule.OnLoginResult := ClientModuleLoginGetResult;

  FGetModule.OnResponseAbort := ClientModuleGetResponseAbort;
  FGetModule.OnResponseError := ClientModuleGetResponseError;
  FGetModule.OnResponseReject := ClientModuleGetResponseReject;

  { "PUT Module" -> used for sending data to the Gateway as needed. }
  FPutModule := TRtcClientModule.Create(nil);
  FPutModule.AutoSessions := True;
  FPutModule.HyperThreading := True;

  FPutModule.OnBeginRequest := ClientModulePutBeginRequest;
  FPutModule.OnConnectLost := ClientModulePutConnectLost;
  FPutModule.OnEncryptNotSupported := ClientModulePutEncryptNotSupported;
  FPutModule.OnEncryptRequired := ClientModulePutEncryptRequired;
  FPutModule.OnEncryptWrongKey := ClientModulePutEncryptWrongKey;

  FPutModule.OnLogin := ClientModuleLogin;
  FPutModule.OnLoginResult := ClientModuleLoginPutResult;

  FPutModule.OnResponseAbort := ClientModulePutResponseAbort;
  FPutModule.OnResponseError := ClientModulePutResponseError;
  FPutModule.OnResponseReject := ClientModulePutResponseReject;

  // Default property values
  FLoginUserInfo := TRtcValue.Create;

  FParamsLoaded := False;
  FStarting := False;

  FPublish := False;
  FSubscribe := False;
  FCompress := rtcpCompNormal;

  FLoginID := '';
  FCS := TCriticalSection.Create;
  FErrorGet := -1;
  FErrorPut := -1;

  FLoggedIn := False;

  MsgTick := 0;
  SenderLocked := 0;
  NowSending := False;
  SentNext := False;
  StoredUserData := nil;
  LastStoredArr := False;
  LastStoredUser := '';
  LastStoredFn := False;

  RLogout := TRtcResult.Create(nil);
  RLogout.OnReturn := RLogoutReturn;

  RPut := TRtcResult.Create(nil);
  RPut.OnReturn := RPutReturn;
  RPut.RequestAborted := RPutRequestAborted;

  RPreStart := TRtcResult.Create(nil);
  RPreStart.OnReturn := RPreStartReturn;

  RStart := TRtcResult.Create(nil);
  RStart.OnReturn := RStartReturn;

  RGet := TRtcResult.Create(nil);
  RGet.OnReturn := RGetReturn;

  RSetParam := TRtcResult.Create(nil);
  RSetParam.OnReturn := RSetParamReturn;

  RGetParams := TRtcResult.Create(nil);
  RGetParams.OnReturn := RGetParamsReturn;

  Prepare;
end;

destructor TRtcPortalCli.Destroy;
begin
  if assigned(StoredUserData) then
  begin
    StoredUserData.Free;
    StoredUserData := nil;
    LastStoredArr := False;
    LastStoredUser := '';
    LastStoredFn := False;
  end;

  FLoginUserInfo.Free;

  FGetModule.Free;
  FPutModule.Free;

  RLogout.Free;
  RPut.Free;
  RGet.Free;
  RPreStart.Free;
  RStart.Free;
  RSetParam.Free;
  RGetParams.Free;

  FCS.Free;
  inherited;
end;

procedure TRtcPortalCli.SetAutoEncrypt(const Value: integer);
begin
  if Value <> FAutoEncrypt then
  begin
    FGetModule.EncryptionKey := Value;
    FPutModule.EncryptionKey := Value;
    FAutoEncrypt := FGetModule.EncryptionKey;
  end;
end;

procedure TRtcPortalCli.SetClient4Get(const Value: TRtcDataClient);
begin
  if Value <> FClient4Get then
  begin
    FGetModule.Client := Value;
    FClient4Get := FGetModule.Client;
    FLink4Put := FGetModule.Link;
  end;
end;

procedure TRtcPortalCli.SetClient4Put(const Value: TRtcDataClient);
begin
  if Value <> FClient4Put then
  begin
    FPutModule.Client := Value;
    FClient4Put := FPutModule.Client;
    FLink4Put := FPutModule.Link;
  end;
end;

procedure TRtcPortalCli.SetLink4Get(const Value: TRtcDataClientLink);
begin
  if Value <> FLink4Get then
  begin
    FGetModule.Link := Value;
    FLink4Get := FGetModule.Link;
    FClient4Get := FGetModule.Client;
  end;
end;

procedure TRtcPortalCli.SetLink4Put(const Value: TRtcDataClientLink);
begin
  if Value <> FLink4Put then
  begin
    FPutModule.Link := Value;
    FLink4Put := FPutModule.Link;
    FClient4Put := FPutModule.Client;
  end;
end;

procedure TRtcPortalCli.SetCompress(const Value: TrtcpCompressLevel);
begin
  FCompress := Value;
end;

procedure TRtcPortalCli.SetForceEncrypt(const Value: boolean);
begin
  if Value <> FForceEncrypt then
  begin
    FGetModule.ForceEncryption := Value;
    FPutModule.ForceEncryption := Value;
    FForceEncrypt := FGetModule.ForceEncryption;
  end;
end;

procedure TRtcPortalCli.SetModuleFileName(const Value: RtcString);
begin
  if Value <> FModuleFileName then
  begin
    FGetModule.ModuleFileName := Value;
    FPutModule.ModuleFileName := Value;
    FModuleFileName := FGetModule.ModuleFileName;
  end;
end;

procedure TRtcPortalCli.SetModuleHost(const Value: RtcString);
begin
  if Value <> FModuleHost then
  begin
    FGetModule.ModuleHost := Value;
    FPutModule.ModuleHost := Value;
    FModuleHost := FGetModule.ModuleHost;
  end;
end;

procedure TRtcPortalCli.SetSecureKey(const Value: RtcString);
begin
  if Value <> FSecureKey then
  begin
    FGetModule.SecureKey := Value;
    FPutModule.SecureKey := Value;
    FSecureKey := FGetModule.SecureKey;
  end;
end;

procedure TRtcPortalCli.SetAutoSync(const Value: boolean);
begin
  FAutoSync := Value;
end;

procedure TRtcPortalCli.SetRetryFirstLogin(const Value: integer);
begin
  FRetryFirstLogin := Value;
end;

procedure TRtcPortalCli.SetRetryOtherCalls(const Value: integer);
begin
  FRetryOtherCalls := Value;
end;

procedure TRtcPortalCli.SetLoginPassword(const Value: String);
begin
  if Value <> FLoginPassword then
  begin
    LogOut;
    FLoginPassword := Trim(Value);
    Prepare;
  end;
end;

procedure TRtcPortalCli.SetLoginUsername(const Value: String);
begin
  if FLoginUserName <> Value then
  begin
    LogOut;
    FLoginUserName := Trim(Value);
    FLoginUserInfo.Clear;
    Prepare;
  end;
end;

function NewGUID: RtcString;
var
  GUID: TGUID;
  function GuidToStr: RtcString;
  begin
    Result := RtcString(IntToHex(GUID.D1, 8) + IntToHex(GUID.D2, 4) +
      IntToHex(GUID.D3, 4) + IntToHex(GUID.D4[0], 2) + IntToHex(GUID.D4[1], 2) +
      IntToHex(GUID.D4[2], 2) + IntToHex(GUID.D4[3], 2) + IntToHex(GUID.D4[4],
      2) + IntToHex(GUID.D4[5], 2) + IntToHex(GUID.D4[6], 2) +
      IntToHex(GUID.D4[7], 2));
  end;

begin
  if CoCreateGuid(GUID) = S_OK then
    Result := GuidToStr
  else
    Result := '';
end;

procedure TRtcPortalCli.Prepare;
begin
  FLoginID := NewGUID;

  FCS.Acquire;
  try
    MsgTick := 0;
    SenderLocked := 0;
    NowSending := False;
    SentNext := False;
    if assigned(StoredUserData) then
    begin
      StoredUserData.Free;
      StoredUserData := nil;
      LastStoredUser := '';
      LastStoredFn := False;
      LastStoredArr := False;
    end;
  finally
    FCS.Release;
  end;

  FErrorGet := -1;
  FErrorPut := -1;
  FLoggedIn := False;
  with FGetModule do
  begin
    ResetLogin;
    AutoLogin := True;
    AutoRepost := FRetryFirstLogin;
  end;
  with FPutModule do
  begin
    ResetLogin;
    AutoLogin := True;
    AutoRepost := FRetryFirstLogin;
  end;
end;

procedure TRtcPortalCli.ClientModuleLogin(Sender: TRtcConnection;
  Data: TRtcValue);
begin
  if not LoggedIn then
  begin
    with Data.NewFunction('Login') do
    begin
      asText['user'] := FLoginUserName;
      asText['pwd'] := FLoginPassword;
      asString['id'] := FLoginID;
      if FLoginUserInfo.isType=rtc_Record then
        asRecord['info'] := FLoginUserInfo.asRecord;
    end;
  end
  else
  begin
    with Data.NewFunction('ReLogin') do
    begin
      asText['user'] := FLoginUserName;
      asText['pwd'] := FLoginPassword;
      asString['id'] := FLoginID;
      if FLoginUserInfo.isType=rtc_Record then
        asRecord['info'] := FLoginUserInfo.asRecord;
    end;
  end;
end;

procedure TRtcPortalCli.ClientModuleLoginPutResult(Sender: TRtcConnection;
  Data, Result: TRtcValue);
begin
  if Result.isType = rtc_Exception then
  begin
    if UpperCase(Result.asException) = 'LOGGED OUT' then
      DoErrorPut(Sender, Result)
    else
      DoFatalErrorPut(Sender, Result);
  end
  else
    FPutModule.AutoRepost := FRetryOtherCalls;
end;

procedure TRtcPortalCli.ClientModuleLoginGetResult(Sender: TRtcConnection;
  Data, Result: TRtcValue);
begin
  if Result.isType = rtc_Exception then
  begin
    if UpperCase(Result.asException) = 'LOGGED OUT' then
      DoErrorGet(Sender, Result)
    else
      DoFatalErrorGet(Sender, Result);
  end
  else if not LoggedIn then
  begin
    LoggedIn := True;
    FGetModule.AutoRepost := FRetryOtherCalls;
    Event_LogIn(Sender);
  end;
end;

procedure TRtcPortalCli.ClientModuleGetResponseAbort(Sender: TRtcConnection);
var
  Msg: TRtcValue;
begin
  Msg := TRtcValue.Create;
  try
    case FErrorGet of
      - 1:
        Msg.asException := S_RTCP_ERROR_CONNECT;
      -2:
        Msg.asException := S_RTCP_ERROR_NOCRYPT;
      -3:
        Msg.asException := S_RTCP_ERROR_NEEDCRYPT;
      -4:
        Msg.asException := S_RTCP_ERROR_WRONGCRYPT;
      -5:
        Msg.asException := S_RTCP_ERROR_REJECTED;
    else
      Msg.asException := Format(S_RTCP_ERROR_INVALID, [IntToStr(FErrorGet)]);
    end;
    TRtcDataClient(Sender).Session.Close;
    DoErrorGet(Sender, Msg);
  finally
    Msg.Free;
  end;
end;

procedure TRtcPortalCli.ClientModulePutResponseAbort(Sender: TRtcConnection);
var
  Msg: TRtcValue;
begin
  Msg := TRtcValue.Create;
  try
    case FErrorPut of
      - 1:
        Msg.asException := S_RTCP_ERROR_CONNECT;
      -2:
        Msg.asException := S_RTCP_ERROR_NOCRYPT;
      -3:
        Msg.asException := S_RTCP_ERROR_NEEDCRYPT;
      -4:
        Msg.asException := S_RTCP_ERROR_WRONGCRYPT;
      -5:
        Msg.asException := S_RTCP_ERROR_REJECTED;
    else
      Msg.asException := Format(S_RTCP_ERROR_INVALID, [IntToStr(FErrorPut)]);
    end;
    TRtcDataClient(Sender).Session.Close;
    DoErrorPut(Sender, Msg);
  finally
    Msg.Free;
  end;
end;

procedure TRtcPortalCli.ClientModuleGetEncryptNotSupported
  (Sender: TRtcConnection);
begin
  FErrorGet := -2;
end;

procedure TRtcPortalCli.ClientModuleGetEncryptRequired(Sender: TRtcConnection);
begin
  FErrorGet := -3;
end;

procedure TRtcPortalCli.ClientModuleGetEncryptWrongKey(Sender: TRtcConnection);
begin
  FErrorGet := -4;
end;

procedure TRtcPortalCli.ClientModuleGetResponseReject(Sender: TRtcConnection);
begin
  FErrorGet := -5;
end;

procedure TRtcPortalCli.ClientModuleGetResponseError(Sender: TRtcConnection);
begin
  FErrorGet := TRtcDataClient(Sender).Response.StatusCode;
end;

procedure TRtcPortalCli.ClientModuleGetBeginRequest(Sender: TRtcConnection);
begin
  FErrorGet := -1;
end;

procedure TRtcPortalCli.ClientModuleGetConnectLost(Sender: TRtcConnection);
begin
  FErrorGet := -1;
end;

procedure TRtcPortalCli.ClientModulePutEncryptNotSupported
  (Sender: TRtcConnection);
begin
  FErrorPut := -2;
end;

procedure TRtcPortalCli.ClientModulePutEncryptRequired(Sender: TRtcConnection);
begin
  FErrorPut := -3;
end;

procedure TRtcPortalCli.ClientModulePutEncryptWrongKey(Sender: TRtcConnection);
begin
  FErrorPut := -4;
end;

procedure TRtcPortalCli.ClientModulePutResponseReject(Sender: TRtcConnection);
begin
  FErrorPut := -5;
end;

procedure TRtcPortalCli.ClientModulePutResponseError(Sender: TRtcConnection);
begin
  FErrorPut := TRtcDataClient(Sender).Response.StatusCode;
end;

procedure TRtcPortalCli.ClientModulePutBeginRequest(Sender: TRtcConnection);
begin
  FErrorPut := -1;
end;

procedure TRtcPortalCli.ClientModulePutConnectLost(Sender: TRtcConnection);
begin
  FErrorPut := -1;
end;

procedure TRtcPortalCli.LogOut;
begin
  if LoggedIn then
  begin
    LoggedIn := False;
    FGetModule.AutoLogin := False;
    with FPutModule do
    begin
      AutoLogin := False;
      with Data.NewFunction('Logout') do
      begin
        asText['user'] := FLoginUserName;
        asText['pwd'] := FLoginPassword;
      end;
      Call(RLogout);
    end;

    // Wait for logout to complete
    if FPutModule.WaitForCompletion(False, 10) then
      FGetModule.WaitForCompletion(False, 10);

    Prepare;
  end;
end;

function TRtcPortalCli.GetLoggedIn: boolean;
begin
  FCS.Acquire;
  try
    Result := FLoggedIn;
  finally
    FCS.Release;
  end;
end;

procedure TRtcPortalCli.SetLoggedIn(const Value: boolean);
begin
  FCS.Acquire;
  try
    FLoggedIn := Value;
  finally
    FCS.Release;
  end;
end;

procedure TRtcPortalCli.RLogoutReturn(Sender: TRtcConnection;
  Data, Result: TRtcValue);
begin
  FStarting := False;
  FParamsLoaded := False;
  LoggedIn := False;
  if Result.isType = rtc_Exception then
    Event_FatalError(Sender, Result)
  else
    Event_LogOut(Sender);
end;

procedure TRtcPortalCli.DoErrorGet(Sender: TObject; Msg: TRtcValue);
begin
  // error in GET will also log out the PUT client.
  FStarting := False;
  FParamsLoaded := False;
  LoggedIn := False;
  Event_Error(Sender, Msg);
end;

procedure TRtcPortalCli.DoErrorPut(Sender: TObject; Msg: TRtcValue);
begin
  // error in PUT logs out only the PUT client.
  // we will need to log out the GET client manually.
  FStarting := False;
  FParamsLoaded := False;
  Event_Error(Sender, Msg);
end;

procedure TRtcPortalCli.DoFatalErrorGet(Sender: TObject; Msg: TRtcValue);
begin
  // error in GET will also log out the PUT client.
  FStarting := False;
  FParamsLoaded := False;
  LoggedIn := False;
  Event_FatalError(Sender, Msg);
end;

procedure TRtcPortalCli.DoFatalErrorPut(Sender: TObject; Msg: TRtcValue);
begin
  // error in PUT logs out only the PUT client.
  // we will need to log out the GET client manually.
  FStarting := False;
  FParamsLoaded := False;
  Event_FatalError(Sender, Msg);
end;

procedure TRtcPortalCli.CallEvent(Sender: TObject; Event: TRtcCustomEvent;
  Obj: TObject);
begin
  if assigned(Event) then
    if AutoSyncEvents and assigned(Sender) then
      begin
      if TRtcConnection(Sender).inMainThread then
        Event(Sender, Obj)
      else
        TRtcConnection(Sender).Sync(Event, Obj);
      end
    else
      Event(Sender, Obj);
end;

procedure TRtcPortalCli.CallEvent(Sender: TObject; Event: TRtcCustomEvent);
begin
  if assigned(Event) then
    if AutoSyncEvents and assigned(Sender) then
      begin
      if TRtcConnection(Sender).inMainThread then
        Event(Sender, self)
      else
        TRtcConnection(Sender).Sync(Event, self);
      end
    else
      Event(Sender, self);
end;

procedure TRtcPortalCli.CallEvent(Sender: TObject; Event: TRtcCustomDataEvent;
  Obj: TObject; Data: TRtcValue);
begin
  if assigned(Event) then
    if AutoSyncEvents and assigned(Sender) then
      begin
      if TRtcConnection(Sender).inMainThread then
        Event(Sender, Obj, Data)
      else
        TRtcConnection(Sender).Sync(Event, Obj, Data);
      end
    else
      Event(Sender, Obj, Data);
end;

procedure TRtcPortalCli.CallEvent(Sender: TObject; Event: TRtcCustomDataEvent;
  Data: TRtcValue);
begin
  if assigned(Event) then
    if AutoSyncEvents and assigned(Sender) then
      begin
      if TRtcConnection(Sender).inMainThread then
        Event(Sender, self, Data)
      else
        TRtcConnection(Sender).Sync(Event, self, Data);
      end
    else
      Event(Sender, self, Data);
end;

procedure TRtcPortalCli.PackNow;
var
  arr: TRtcArray;
  rec: TRtcFunctionInfo;
begin
  if LastStoredArr then
  begin
    LastStoredArr := False;
    arr := StoredUserData.asArray['d'];
    try
      StoredUserData.asObject['d'] := nil;
      // store the Array as a compressed RtcString
      StoredUserData.asString['d'] :=
        RtcBytesToString(ZCompress_Ex(arr.toCodeEx,
        RTCP_COMPRESS_LEVEL[FCompress]));
    finally
      arr.Free;
    end;
  end
  else if LastStoredUser <> '' then
  begin
    rec := StoredUserData.asFunction['d'];
    try
      StoredUserData.asObject['d'] := nil;
      // store the Function Call as a compressed RtcString
      StoredUserData.asString['d'] :=
        RtcBytesToString(ZCompress_Ex(rec.toCodeEx,
        RTCP_COMPRESS_LEVEL[FCompress]));
    finally
      rec.Free;
    end;
  end;
  LastStoredUser := '';
  LastStoredFn := False;
end;

procedure TRtcPortalCli.SendNow(Sender: TObject; FromPut: boolean = False);
var
  tosend: boolean;
begin
  Event_SenderLoop(Sender);

  FCS.Acquire;
  try
    tosend := assigned(StoredUserData);
    if not tosend then
      NowSending := False;
  finally
    FCS.Release;
  end;

  if tosend then
  begin
    FCS.Acquire;
    try
      PackNow;
      with FPutModule do
      begin
        with Data.NewFunction('Put') do
        begin
          asInteger['x'] := NextTick;
          asObject['p'] := StoredUserData;
          StoredUserData := nil;
          SentNext := False;
        end;
      end;
    finally
      FCS.Release;
    end;
    if FromPut and (Sender is TRtcConnection) then
      FPutModule.Call(RPut, True, TRtcConnection(Sender))
    else
      FPutModule.Call(RPut);
  end;
end;

procedure TRtcPortalCli.LockSender;
begin
  FCS.Acquire;
  try
    Inc(SenderLocked);
  finally
    FCS.Release;
  end;
end;

procedure TRtcPortalCli.UnLockSender(Sender: TObject);
var
  tosend: boolean;
begin
  FCS.Acquire;
  try
    Dec(SenderLocked);
    tosend := not NowSending and (SenderLocked = 0) and LoggedIn;
    if tosend then
      NowSending := True;
  finally
    FCS.Release;
  end;
  if tosend then
    SendNow(Sender);
end;

{ PutMessage(Sender:TObject; const username:String; rec:TRtcFunctionInfo); }
procedure TRtcPortalCli.SendToUser(Sender: TObject; const username: String;
  rec: TRtcFunctionInfo);
var
  o: TRtcValueObject;
  arr: TRtcArray;
  tosend: boolean;
begin
  FCS.Acquire;
  try
    if not assigned(StoredUserData) then
      StoredUserData := TRtcDataSet.Create;

    with StoredUserData do
    begin
      if not LastStoredFn and (username = LastStoredUser) then
      begin
        if not LastStoredArr then
        begin
          // move "old" object to array
          LastStoredArr := True;
          o := asObject['d'];
          asObject['d'] := nil;
          arr := newArray('d');
          arr.asObject[arr.Count] := o;
        end
        else
          arr := asArray['d'];
        // add new object to array
        arr.asObject[arr.Count] := rec;
      end
      else
      begin
        PackNow;
        Append;
        // user to receive the request
        asText['to'] := username;
        // data to receive
        asObject['d'] := rec;
        LastStoredUser := username;
      end;
    end;
    tosend := not NowSending and (SenderLocked = 0) and LoggedIn;
    if tosend then
      NowSending := True;
  finally
    FCS.Release;
  end;
  if tosend then
    SendNow(Sender);
end;

{ PutPing(Sender:TObject); }
procedure TRtcPortalCli.SendPing(Sender: TObject);
var
  tosend: boolean;
begin
  FCS.Acquire;
  try
    if not assigned(StoredUserData) then
      StoredUserData := TRtcDataSet.Create;
    tosend := not NowSending and (SenderLocked = 0) and LoggedIn;
    if tosend then
      NowSending := True;
  finally
    FCS.Release;
  end;
  if tosend then
    SendNow(Sender);
end;

{ PutFnMessage(Sender:TObject; const func:String; rec:TRtcFunctionInfo); }
procedure TRtcPortalCli.SendToMyGroup(Sender: TObject; const Group: String;
  rec: TRtcFunctionInfo);
var
  o: TRtcValueObject;
  arr: TRtcArray;
  tosend: boolean;
begin
  FCS.Acquire;
  try
    if not assigned(StoredUserData) then
      StoredUserData := TRtcDataSet.Create
    else
      PackNow;
    with StoredUserData do
    begin
      if LastStoredFn and (Group = LastStoredUser) then
      begin
        if not LastStoredArr then
        begin
          // move "old" object to array
          LastStoredArr := True;
          o := asObject['d'];
          asObject['d'] := nil;
          arr := newArray('d');
          arr.asObject[arr.Count] := o;
        end
        else
          arr := asArray['d'];
        // add new object to array
        arr.asObject[arr.Count] := rec;
      end
      else
      begin
        PackNow;
        Append;
        // function to receive the request
        asText['fn'] := Group;
        // data to receive
        asObject['d'] := rec;
        LastStoredFn := True;
        LastStoredUser := Group;
      end;
    end;
    tosend := not NowSending and (SenderLocked = 0) and LoggedIn;
    if tosend then
      NowSending := True;
  finally
    FCS.Release;
  end;
  if tosend then
    SendNow(Sender);
end;

{ PutSubscribe(Sender:TObject; const username, func:String); }
procedure TRtcPortalCli.AddUserToMyGroup(Sender: TObject;
  const username, Group: String);
var
  tosend: boolean;
begin
  FCS.Acquire;
  try
    if not assigned(StoredUserData) then
      StoredUserData := TRtcDataSet.Create
    else
      PackNow;
    with StoredUserData do
    begin
      Append;
      asText['s'] := Group;
      asText['user'] := username;
    end;
    tosend := not NowSending and (SenderLocked = 0) and LoggedIn;
    if tosend then
      NowSending := True;
  finally
    FCS.Release;
  end;
  if tosend then
    SendNow(Sender);
end;

{ PutUnSubscribe(Sender:TObject; const username, func:String); }
procedure TRtcPortalCli.RemoveUserFromMyGroup(Sender: TObject;
  const username, Group: String);
var
  tosend: boolean;
begin
  FCS.Acquire;
  try
    if not assigned(StoredUserData) then
      StoredUserData := TRtcDataSet.Create
    else
      PackNow;
    with StoredUserData do
    begin
      Append;
      asText['u'] := Group;
      asText['user'] := username;
    end;
    tosend := not NowSending and (SenderLocked = 0) and LoggedIn;
    if tosend then
      NowSending := True;
  finally
    FCS.Release;
  end;
  if tosend then
    SendNow(Sender);
end;

{ PutUnSubscribeFn(Sender:TObject; const func:String); }
procedure TRtcPortalCli.DisbandMyGroup(Sender: TObject; const Group: String);
var
  tosend: boolean;
begin
  FCS.Acquire;
  try
    if not assigned(StoredUserData) then
      StoredUserData := TRtcDataSet.Create
    else
      PackNow;
    with StoredUserData do
    begin
      Append;
      asText['uf'] := Group;
    end;
    tosend := not NowSending and (SenderLocked = 0) and LoggedIn;
    if tosend then
      NowSending := True;
  finally
    FCS.Release;
  end;
  if tosend then
    SendNow(Sender);
end;

{ TermSubscribe(Sender:TObject; const username, func:String); }
procedure TRtcPortalCli.LeaveUserGroup(Sender: TObject;
  const username, Group: String);
var
  tosend: boolean;
begin
  FCS.Acquire;
  try
    if not assigned(StoredUserData) then
      StoredUserData := TRtcDataSet.Create
    else
      PackNow;
    with StoredUserData do
    begin
      Append;
      asText['t'] := Group;
      asText['user'] := username;
    end;
    tosend := not NowSending and (SenderLocked = 0) and LoggedIn;
    if tosend then
      NowSending := True;
  finally
    FCS.Release;
  end;
  if tosend then
    SendNow(Sender);
end;

function TRtcPortalCli.NextTick: integer;
begin
  FCS.Acquire;
  try
    Inc(MsgTick);
    if MsgTick > 99 then
      MsgTick := 1;
    Result := MsgTick;
  finally
    FCS.Release;
  end;
end;

function TRtcPortalCli.canSendNext: boolean;
begin
  FCS.Acquire;
  try
    Result := not SentNext;
    SentNext := True;
  finally
    FCS.Release;
  end;
end;

procedure TRtcPortalCli.RPutReturn(Sender: TRtcConnection;
  Data, Result: TRtcValue);
var
  tosend: boolean;
begin
  if Result.isType = rtc_Exception then
  begin
    FCS.Acquire;
    try
      NowSending := False;
    finally
      FCS.Release;
    end;
    DoErrorPut(Sender, Result);
  end
  else if LoggedIn then
  begin
    FCS.Acquire;
    try
      tosend := (SenderLocked = 0);
      if not tosend then
        NowSending := False;
    finally
      FCS.Release;
    end;
    if tosend then
      SendNow(Sender, True);
  end
  else
  begin
    FCS.Acquire;
    try
      NowSending := False;
    finally
      FCS.Release;
    end;
  end;
end;

procedure TRtcPortalCli.RPutRequestAborted(Sender: TRtcConnection;
  Data, Result: TRtcValue);
begin
  FCS.Acquire;
  try
    NowSending := False;
  finally
    FCS.Release;
  end;
end;

procedure TRtcPortalCli.Start;
begin
  if GwStoreParams and not GParamsLoaded then
  begin
    Prepare;
    FStarting := True;
    GParamsLoaded := True;
  end
  else
  begin
    Prepare;
    // Start Host or Control
    with FGetModule do
    begin
      if FPublish and FSubscribe then
      begin
        Data.NewFunction('Control').asBoolean['on'] := True;
        Call(RPreStart);
      end
      else if FPublish then
      begin
        Data.NewFunction('Host').asBoolean['on'] := True;
        Call(RStart);
      end
      else // if not publishing, we are *always* a subscriber
      begin
        Data.NewFunction('Control').asBoolean['on'] := True;
        Call(RStart);
      end;
    end;
  end;
end;

procedure TRtcPortalCli.RPreStartReturn(Sender: TRtcConnection;
  Data, Result: TRtcValue);
begin
  if Result.isType = rtc_Exception then
    DoErrorGet(Sender, Result)
  else if LoggedIn then // start infinite loop
    with FGetModule do
    begin
      Data.NewFunction('Host').asBoolean['on'] := True;
      Call(RStart, True, Sender);
    end;
end;

procedure TRtcPortalCli.RStartReturn(Sender: TRtcConnection;
  Data, Result: TRtcValue);
begin
  if Result.isType = rtc_Exception then
    DoErrorGet(Sender, Result)
  else
  begin
    Event_Start(Sender, Result);

    if LoggedIn then // start infinite loop
      with FGetModule do
      begin
        Data.NewFunction('Get').asInteger['x'] := NextTick;
        Call(RGet, True, Sender);
      end;
  end;
end;

procedure TRtcPortalCli.RGetReturn(Sender: TRtcConnection;
  Data, Result: TRtcValue);
var
  a, i, j: integer;
  uname: String;
  rec: TRtcRecord;
  arr: TRtcArray;

  x: TRtcValue;
  xarr: TRtcArray;

begin
  if not LoggedIn then
    Exit;

  if Result.isType = rtc_Exception then
    DoErrorGet(Sender, Result)
  else
  begin
    try
      if Result.isType = rtc_Record then
      begin
        LockSender;
        try
          Event_BeforeData(Sender);

          // scan received messages, user-by-user ...
          for a := 0 to Result.asRecord.Count - 1 do
          begin
            uname := Result.asRecord.FieldName[a];
            if Result.asRecord.isType[uname] = rtc_Array then
            begin
              arr := Result.asRecord.asArray[uname];
              // go through all messages received from user "uname" ...
              for i := 0 to arr.Count - 1 do
              begin
                if arr.isType[i] = rtc_Boolean then
                begin
                  // Other Users login/logout info (old Gateway)
                  if arr.asBoolean[i] then
                    Event_UserLoggedIn(Sender, uname, nil)
                  else
                    Event_UserLoggedOut(Sender, uname);
                end
                else if arr.isType[i] = rtc_Record then
                begin
                  rec := arr.asRecord[i];
                  if CompareText(uname, FLoginUserName) = 0 then
                  begin
                    if rec.asBoolean['on'] then
                      begin
                      if rec.isType['info']=rtc_Record then
                        Event_UserJoinedMyGroup(Sender, rec.asText['fn'],
                            rec.asText['user'], rec.asRecord['info'])
                      else
                        Event_UserJoinedMyGroup(Sender, rec.asText['fn'],
                            rec.asText['user'], nil);
                      end
                    else if rec.asBoolean['off'] then
                      Event_UserLeftMyGroup(Sender, rec.asText['fn'],
                        rec.asText['user']);
                  end
                  else
                  begin
                    if rec.asBoolean['on'] then
                      begin
                      if rec.isType['info']=rtc_Record then
                        Event_JoinedUsersGroup(Sender, rec.asText['fn'],
                            rec.asText['user'], rec.asRecord['info'])
                      else
                        Event_JoinedUsersGroup(Sender, rec.asText['fn'],
                            rec.asText['user'], nil);
                      end
                    else if rec.asBoolean['off'] then
                      Event_LeftUsersGroup(Sender, rec.asText['fn'],
                        rec.asText['user'])
                    else if rec.asBoolean['in'] then
                      begin
                      if rec.isType['info']=rtc_Record then
                        Event_UserLoggedIn(Sender, uname, rec.asRecord['info'])
                      else
                        Event_UserLoggedIn(Sender, uname, nil);
                      end
                    else if rec.asBoolean['out'] then
                      Event_UserLoggedOut(Sender, uname);
                  end;
                end
                else if arr.isType[i] = rtc_String then
                begin
                  // decompress the package
                  x := TRtcValue.FromCode
                    (RtcBytesToString
                    (ZDecompress_Ex(RtcStringToBytes(arr.asString[i]))));
                  try
                    if x.isType = rtc_Array then
                    begin
                      xarr := x.asArray;
                      for j := 0 to xarr.Count - 1 do
                        if xarr.isType[j] = rtc_Function then
                          Event_DataFromUser(Sender, uname, xarr.asFunction[j]);
                    end
                    else if x.isType = rtc_Function then
                      Event_DataFromUser(Sender, uname, x.asFunction);
                  finally
                    x.Free;
                  end;
                end;
              end;
            end;
          end;

          Event_AfterData(Sender);
        finally
          UnLockSender(Sender);
        end;
      end;
    except
      on E: Exception do
        Log('GET', E);
    end;

    if LoggedIn then
    begin
      SendPing(nil);
      with FGetModule do
      begin
        Data.NewFunction('Get').asInteger['x'] := NextTick;
        Call(RGet, True, Sender);
      end;
    end;
  end;
end;

procedure TRtcPortalCli.ParamSet(Sender: TObject; const ParamName: String;
  ParamValue: TRtcValueObject);
begin
  if csReading in ComponentState then
    Exit;

  with FPutModule do
  begin
    with Data.NewFunction('User.Set') do
      asObject[ParamName] := ParamValue;
    Call(RSetParam);
  end;
end;

procedure TRtcPortalCli.ParamAdd(Sender: TObject; const ParamName: String;
  ParamValue: TRtcValueObject);
begin
  if csReading in ComponentState then
    Exit;

  with FPutModule do
  begin
    with Data.NewFunction('User.Add') do
      asObject[ParamName] := ParamValue;
    Call(RSetParam);
  end;
end;

procedure TRtcPortalCli.ParamDel(Sender: TObject; const ParamName: String;
  ParamValue: TRtcValueObject);
begin
  if csReading in ComponentState then
    Exit;

  with FPutModule do
  begin
    with Data.NewFunction('User.Del') do
      asObject[ParamName] := ParamValue;
    Call(RSetParam);
  end;
end;

function TRtcPortalCli.GetParamsLoaded: boolean;
begin
  Result := FParamsLoaded;
end;

procedure TRtcPortalCli.SetParamsLoaded(const Value: boolean);
begin
  if not(csReading in ComponentState) then
    if Value then
    begin
      with FPutModule do
      begin
        Data.NewFunction('User.Get');
        Call(RGetParams);
      end;
    end
    else
      FParamsLoaded := False;
end;

procedure TRtcPortalCli.RSetParamReturn(Sender: TRtcConnection;
  Data, Result: TRtcValue);
begin
  if Result.isType = rtc_Exception then
    DoErrorPut(Sender, Result);
end;

procedure TRtcPortalCli.RGetParamsReturn(Sender: TRtcConnection;
  Data, Result: TRtcValue);
begin
  if Result.isType = rtc_Exception then
    DoErrorPut(Sender, Result)
  else if Result.isType = rtc_Record then
  begin
    FParamsLoaded := True;
    Event_Params(Sender, Result);
    if FStarting then
    begin
      FStarting := False;
      // Start Host or Control
      with FGetModule do
      begin
        if FPublish and FSubscribe then
        begin
          Data.NewFunction('Control').asBoolean['on'] := True;
          Call(RPreStart);
        end
        else if FPublish then
        begin
          Data.NewFunction('Host').asBoolean['on'] := True;
          Call(RStart);
        end
        else if FSubscribe then
        begin
          Data.NewFunction('Control').asBoolean['on'] := True;
          Call(RStart);
        end
        else
        begin
          Data.NewFunction('Get').asInteger['x'] := NextTick;
          Call(RGet);
        end;
      end;
    end;
  end;
end;

function TRtcPortalCli.GetActive: boolean;
begin
  Result := LoggedIn;
end;

procedure TRtcPortalCli.SetActive(const Value: boolean);
begin
  if not(csReading in ComponentState) then
    if Value<>LoggedIn then
      if Value then
        Start
      else 
        LogOut;
end;

function TRtcPortalCli.GetLoginPassword: String;
begin
  Result := FLoginPassword;
end;

function TRtcPortalCli.GetLoginUsername: String;
begin
  Result := FLoginUserName;
end;

function TRtcPortalCli.GetPublish: boolean;
begin
  Result := FPublish;
end;

function TRtcPortalCli.GetSubscribe: boolean;
begin
  Result := FSubscribe;
end;

procedure TRtcPortalCli.SetPublish(const Value: boolean);
begin
  if Value <> FPublish then
  begin
    if LoggedIn then
      LogOut;
    FPublish := Value;
  end;
end;

procedure TRtcPortalCli.SetSubscribe(const Value: boolean);
begin
  if Value <> FSubscribe then
  begin
    if LoggedIn then
      LogOut;
    FSubscribe := Value;
  end;
end;

procedure TRtcPortalCli.SetLoginUserInfo(const Value: TRtcRecord);
  begin
  FLoginUserInfo.Clear;
  if assigned(Value) then
    FLoginUserInfo.asRecord:=Value;
  end;

function TRtcPortalCli.GetLoginUserInfo: TRtcRecord;
  begin
  if FLoginUserInfo.isType=rtc_Record then
    Result:=FLoginUserInfo.asRecord
  else
    Result:=FLoginUserInfo.newRecord;
  end;

end.
