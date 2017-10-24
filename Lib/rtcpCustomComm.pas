{ Copyright 2004-2017 (c) RealThinClient.com (http://www.realthinclient.com) }

unit rtcpCustomComm;

interface

{$INCLUDE rtcDefs.inc}

uses
  Windows, Classes, SysUtils, {$IFNDEF IDE_1} Variants, {$ENDIF}
  rtcLog, rtcSystem, rtcInfo, rtcPortalMod;

type
  TRtcPCustomCommand = class;

  TRtcPCustCommEventType = (etConnect, etDisconnect);

  TRtcPCustCommMsgEvent = procedure(Sender: TRtcPCustomCommand;
    const UserName: string; const Msg: string) of object;

  TRtcPCustCommDataEvent = procedure(Sender: TRtcPCustomCommand;
    const UserName: string; const Data:TRtcValue) of object;

  TRtcPCustCommConEvent = procedure(Sender: TRtcPCustomCommand;
    UserName: String) of object;

  TRtcPCustomCommand = class(TRtcPModule)
  private

    AmHost: TRtcRecord;
    AmHostCnt: integer;

    FCommandName: String;
    FCommandGroup: String;

    FOnMsg: TRtcPCustCommMsgEvent;
    FOnOpen: TRtcPCustCommConEvent;
    FOnClose: TRtcPCustCommConEvent;
    FOnData:TRtcPCustCommDataEvent;

    FHostMode: boolean;
    FAccessControl: boolean;
    FAllow: boolean;
    FAllowSuper: boolean;

    procedure Event_Open(Sender: TObject; UserName: String; UserInfo:TRtcRecord);
    procedure Event_Close(Sender: TObject; UserName: String);
    procedure Event_Msg(Sender: TObject; const who, msg: String);
    procedure Event_Data(Sender: TObject; const who: String; data: TRtcValueObject);

    procedure SetCommandName(const Value: String);

  protected
    //procedure Call_LogOut(Sender: TObject); override;
    procedure Call_Error(Sender: TObject; Data: TRtcValue); override;
    procedure Call_FatalError(Sender: TObject; Data: TRtcValue); override;

    procedure Call_UserJoinedMyGroup(Sender: TObject; const group: string;
      const uname: string; uinfo:TRtcRecord); override;

    procedure Call_UserLeftMyGroup(Sender: TObject; const group: string;
      const uname: string); override;

    procedure Call_JoinedUsersGroup(Sender: TObject; const group: string;
      const uname: string; uinfo:TRtcRecord); override;

    procedure Call_LeftUsersGroup(Sender: TObject; const group: string;
      const uname: string); override;

    procedure Call_DataFromUser(Sender: TObject; const uname: string;
      Data: TRtcFunctionInfo); override;

    procedure xOnOpen(Sender, Obj: TObject; Data: TRtcValue);
    procedure xOnClose(Sender, Obj: TObject; Data: TRtcValue);
    procedure XOnMsg(Sender, Obj: TObject; Data: TRtcValue);
    procedure xOnData(Sender, Obj: TObject; Data: TRtcValue);

    function MayJoinGroup(const user: String): boolean;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    { Open Command group (allows group command broadcasts).
      When BeTheHost=True, "Username" is invited to our own Command group.
      When BeTheHost=False, we ask to join the Command group maintained by user "Username".
      NOTE: A Command Group is NOT required for sending messages or data directly to users.
      You can send messages and data direct to any user if you know its username.
      Command Groups are ONLY required if you want to send the same message or data
      to multiple users inside your currently active Command Group with a single call. }
    procedure Open(const UserName: string; Sender: TObject = nil);

    { Close Command group.
      Called with own username, disbands our own Command group and kicks all users out.
      Called with a username of a user that was invited to join our Command group, the user is kicked out.
      If we were invited to a Command group maintained by "Username", we leave that Command group. }
    procedure Close(const UserName: string; Sender: TObject = nil);

    { Send message "msg" to user "UserName".
      Call with own username to send a message to all users in our Command Group.
      Triggers the "OnMessageReceived" event with "Msg" at user "UserName". }
    procedure SendMessage(const UserName, msg: String;
      Sender: TObject = nil);

    { Send data (TRtcValueObject) to user "UserName".
      Call with own username to send data to all users in our Command Group.
      Triggers the "OnDataReceived" event with "Data" (as TRtcValue) at user "UserName".

      IMPORTANT: Do NOT destroy the "Data" object sent as a parameter to this method.
      It will be destroyed internally by the "SendCustomData" method. }
    procedure SendData(const UserName: String; const Data:TRtcValueObject;
      Sender: TObject = nil);

  published

    { Allow other users to Join our Command Group? }
    property AllowJoin: boolean read FAllow write FAllow default True;
    { Allow other super users to Join our Command Group? }
    property AllowJoin_Super: boolean read FAllowSuper write FAllowSuper default True;

    { Group Command sessions have 2 sides. For multiple clients to be able to have a shared
      group session, at least one client has to have BeTheHost property set to True.
      You can NOT initiate a group session between two clients if they both have BeTheHost=False.
      On the other hand, if two clients have BeTheHost=True, the one to initiate
      the open command will become the command group host for the duration of the command session.
      The command host can invite any number of clients to his command group, while any client
      with BeTheHost=False (and appriproate rights) can join the command group hosted by this client. }
    property BeTheHost: boolean read FHostMode write FHostMode default True;

    { Set to FALSE if you want to ignore Access right settings and allow all actions,
      regardless of user lists and AllowJoin parameters set by this user. }
    property AccessControl: boolean read FAccessControl write FAccessControl default True;

    { "CommandName" allows you to use multiple TRtcPCustomCommand components with a single PortalClient.
      Commands sent through this component will ONLY be received by a component with the same "CommandName". }
    property CommandName: String read FCommandName write SetCommandName;

    { On the Host side: User with username = "user" is asking for access to our Command group.

      On the Viewer/Control side: User with username = "user" has invited us to his Command group (allowed access).
      This event can be used on the Control side when you want the Host to initiate the Group.

      Note that ONLY users with granted access will trigger this event. If you have already limited
      access to this Host by using the AllowUsersList, users who are NOT on that list will be ignored
      and no events will be triggered for them. So ... you could leave this event empty (not implemented)
      if you want to allow access to all users with granted access rights, or you could implement this event
      to set the "Allow" parmeter (passed into the event as TRUE) saying if this user may access our Group.

      If you implement this event, make sure it will not take longer than 20 seconds to complete, because
      this code is executed from the context of a connection component responsible for receiving data from
      the Gateway and if this component does not return to the Gateway before time runs out, the client will
      be disconnected from the Gateway. If you implement this event by using a dialog for the user, that dialog
      will have to auto-close whithin no more than 20 seconds automatically, selecting what ever you find apropriate. }
    property OnQueryAccess;

    property OnUserJoined:      TRtcPCustCommConEvent read FOnOpen write FOnOpen;
    property OnUserLeft:        TRtcPCustCommConEvent read FOnClose write FOnClose;
    property OnMessageReceived: TRtcPCustCommMsgEvent read FOnMsg write FOnMsg;
    property OnDataReceived:    TRtcPCustCommDataEvent read FOnData write FOnData;
  end;

implementation

{ TRtcPCustomCommand }

constructor TRtcPCustomCommand.Create(AOwner: TComponent);
begin
  inherited;
  FAccessControl := True;
  FHostMode := True;
  FAllow := True;
  FAllowSuper := True;
  AmHost := TRtcRecord.Create;
  AmHostCnt := 0;
  FCommandName := '';
  FCommandGroup := 'custom-command';
end;

destructor TRtcPCustomCommand.Destroy;
begin
  FCommandName := '';
  FCommandGroup := '';
  AmHost.Free;
  inherited;
end;

procedure TRtcPCustomCommand.Call_DataFromUser(Sender: TObject;
  const uname: string; Data: TRtcFunctionInfo);
var
  d:TRtcValueObject;
begin
  if Data.FunctionName = 'custom-command-open' then
  begin
    if Data.asText['name']=FCommandName then
    begin
      if BeTheHost and MayJoinGroup(uname) then
        if Event_QueryAccess(Sender, uname) then
          Client.AddUserToMyGroup(Sender, uname, FCommandGroup);
    end;
  end
  else if Data.FunctionName = 'custom-command' then
  begin
    if Data.asText['name']=FCommandName then
    begin
      if not Data.isNull['msg'] then
        Event_msg(Sender, uname, Data.asText['msg']);
      if not Data.isNull['data'] then
      begin
        d:=Data.asObject['data'];
        Data.asObject['data']:=nil;
        Event_Data(Sender, uname, d);
      end;
    end;
  end;
end;

procedure TRtcPCustomCommand.Call_Error(Sender: TObject; Data: TRtcValue);
begin
end;

procedure TRtcPCustomCommand.Call_FatalError(Sender: TObject; Data: TRtcValue);
begin
end;

procedure TRtcPCustomCommand.Call_JoinedUsersGroup(Sender: TObject;
  const group, uname: string; uinfo:TRtcRecord);
begin
  inherited;

  // we were invited to join user's group
  if group = FCommandGroup then
    if not isSubscriber(uname) then
      if MayJoinGroup(uname) and Event_QueryAccess(Sender, uname) then
      // we are being asked to join a group session
      begin
        if setSubscriber(uname, True) then
          Event_Open(Sender, uname, uinfo);
      end
      else // setting "Allow" to FALSE will close the command session
        Close(uname, Sender);
end;

procedure TRtcPCustomCommand.Call_LeftUsersGroup(Sender: TObject;
  const group, uname: string);
begin
  if group = FCommandGroup then
    if setSubscriber(uname, False) then
      Event_Close(Sender, uname);

  inherited;
end;

procedure TRtcPCustomCommand.Call_UserJoinedMyGroup(Sender: TObject;
  const group, uname: string; uinfo:TRtcRecord);
begin
  inherited;

  if group = FCommandGroup then
    if setSubscriber(uname, True) then
    begin
      AmHost.asBoolean[uname] := True;
      Inc(AmHostCnt);
      Event_Open(Sender, uname, uinfo);
    end;
end;

procedure TRtcPCustomCommand.Call_UserLeftMyGroup(Sender: TObject;
  const group, uname: string);
begin
  if group = FCommandGroup then
    if setSubscriber(uname, False) then
    begin
      AmHost.asBoolean[uname] := False;
      Dec(AmHostCnt);
      Event_Close(Sender, uname);
    end;

  inherited;
end;

procedure TRtcPCustomCommand.Event_Open(Sender: TObject; UserName: String; UserInfo:TRtcRecord);
var
  msg: TRtcValue;
begin
  if assigned(FOnOpen) then
  begin
    msg := TRtcValue.Create;
    try
      msg.asText := UserName;
      CallEvent(Sender, xOnOpen, msg);
    finally
      msg.Free;
    end;
  end;
end;

procedure TRtcPCustomCommand.Event_Close(Sender: TObject; UserName: String);
var
  msg: TRtcValue;
begin
  if assigned(FOnClose) then
  begin
    msg := TRtcValue.Create;
    try
      msg.asText := UserName;
      CallEvent(Sender, xOnClose, msg);
    finally
      msg.Free;
    end;
  end;
end;

procedure TRtcPCustomCommand.xOnOpen(Sender, Obj: TObject; Data: TRtcValue);
begin
  if assigned(FOnOpen) then
    FOnOpen(self, Data.asText);
end;

procedure TRtcPCustomCommand.xOnClose(Sender, Obj: TObject; Data: TRtcValue);
begin
  if assigned(FOnClose) then
    FOnClose(self, Data.asText);
end;

procedure TRtcPCustomCommand.Event_msg(Sender: TObject; const who, msg: String);
var
  rec: TRtcValue;
begin
  if assigned(FOnMsg) then
  begin
    rec := TRtcValue.Create;
    try
      with rec.NewRecord do
      begin
        asText['who'] := who;
        asText['msg'] := msg;
      end;
      CallEvent(Sender, XOnMsg, rec);
    finally
      rec.Free;
    end;
  end;
end;

procedure TRtcPCustomCommand.Event_Data(Sender: TObject; const who: String;
  data: TRtcValueObject);
var
  rec: TRtcValue;
begin
  if assigned(FOnData) then
  begin
    rec := TRtcValue.Create;
    try
      with rec.NewRecord do
      begin
        asText['who'] := who;
        asObject['data'] := data;
      end;
      CallEvent(Sender, XOnData, rec);
    finally
      rec.Free;
    end;
  end
  else
    data.Free;
end;

procedure TRtcPCustomCommand.XOnMsg(Sender, Obj: TObject; Data: TRtcValue);
begin
  if assigned(FOnMsg) then
    FOnMsg(self, Data.asRecord.asText['who'], Data.asRecord.asText['msg']);
end;

procedure TRtcPCustomCommand.xOnData(Sender, Obj: TObject;
  Data: TRtcValue);
var
  d:TRtcValue;
begin
  if assigned(FOnData) then
  begin
    d:=TRtcValue.Create;
    try
      d.asObject:=Data.asRecord.asObject['data'];
      Data.asRecord.asObject['data']:=nil;
      FOnData(self, Data.asRecord.asText['who'], d);
    finally
      d.Free;
    end;
  end;
end;

procedure TRtcPCustomCommand.Close(const UserName: string; Sender: TObject);
begin
  if CompareText(UserName, Client.LoginUsername) = 0 then
  begin
    Client.DisbandMyGroup(Sender, FCommandGroup);
    AmHost.Clear;
    AmHostCnt := 0;
  end
  else if AmHost.asBoolean[UserName] then
    Client.RemoveUserFromMyGroup(Sender, UserName, FCommandGroup)
  else
    Client.LeaveUserGroup(Sender, UserName, FCommandGroup);
end;

procedure TRtcPCustomCommand.Open(const UserName: string; Sender: TObject);
var
  fn: TRtcFunctionInfo;
begin
  if BeTheHost then
    Client.AddUserToMyGroup(Sender, UserName, FCommandGroup)
  else
  begin
    fn := TRtcFunctionInfo.Create;
    fn.FunctionName := 'custom-command-open';
    fn.asText['name']:=FCommandName;
    Client.SendToUser(Sender, UserName, fn);
  end;
end;

procedure TRtcPCustomCommand.SendMessage(const UserName, msg: String;
  Sender: TObject);
var
  fn: TRtcFunctionInfo;
begin
  if CompareText(UserName, Client.LoginUsername) = 0 then
  begin
    fn := TRtcFunctionInfo.Create;
    fn.FunctionName := 'custom-command';
    fn.asText['name']:=FCommandName;
    fn.asText['msg'] := msg;
    Client.SendToMyGroup(Sender, FCommandGroup, fn);
  end
  else
  begin
    fn := TRtcFunctionInfo.Create;
    fn.FunctionName := 'custom-command';
    fn.asText['name']:=FCommandName;
    fn.asText['msg'] := msg;
    Client.SendToUser(Sender, UserName, fn);
  end;
end;

procedure TRtcPCustomCommand.SendData(const UserName: String;
  const Data: TRtcValueObject; Sender: TObject);
var
  fn: TRtcFunctionInfo;
begin
  if CompareText(UserName, Client.LoginUsername) = 0 then
  begin
    fn := TRtcFunctionInfo.Create;
    fn.FunctionName := 'custom-command';
    fn.asText['name']:=FCommandName;
    fn.asObject['data'] := data;
    Client.SendToMyGroup(Sender, FCommandGroup, fn);
  end
  else
  begin
    fn := TRtcFunctionInfo.Create;
    fn.FunctionName := 'custom-command';
    fn.asText['name']:=FCommandName;
    fn.asObject['data'] := data;
    Client.SendToUser(Sender, UserName, fn);
  end;
end;

procedure TRtcPCustomCommand.SetCommandName(const Value: String);
begin
  FCommandName := Value;
  if FCommandName='' then
    FCommandGroup:='custom-command'
  else
    FCommandGroup:='custom-command.'+FCommandName;
end;

function TRtcPCustomCommand.MayJoinGroup(const user: String): boolean;
begin
  if FAccessControl then
    Result := (FAllow and Client.inUserList[user]) or
      (FAllowSuper and Client.isSuperUser[user])
  else
    Result := True;
end;

end.
