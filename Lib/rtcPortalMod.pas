{ Copyright 2004-2017 (c) RealThinClient.com (http://www.realthinclient.com) }

unit rtcPortalMod;

interface

{$INCLUDE rtcDefs.inc}

uses
  SysUtils, Classes,

  rtcLog, SyncObjs, rtcInfo;

const
  // Version of the RTC PORTAL components
  RTCPORTAL_VERSION: String = 'v5.10 (2017.Q4)';

type
  (* Copy the lines below to a new unit when you want to implement a new Module for the RTC Portal Client.
    Comment out the methods you don't need or want to implement and use "Complete class at cursor"
    to have a wrapper class with empty methods prepared by the Delphi IDE.
    ----->
    TRtcPYourOwnModule=class(TRtcPModule) // Change "TRtcPYourOwnModule" to the name of your class
    protected
    function SenderLoop_Check(Sender:TObject):boolean; override;
    procedure SenderLoop_Prepare(Sender:TObject); override;
    procedure SenderLoop_Execute(Sender:TObject); override;

    procedure Call_LogIn(Sender:TObject); override;
    procedure Call_LogOut(Sender:TObject); override;
    procedure Call_Error(Sender:TObject; Data:TRtcValue); override;
    procedure Call_FatalError(Sender:TObject; Data:TRtcValue); override;

    procedure Call_Start(Sender:TObject; Data:TRtcValue); override;
    procedure Call_Params(Sender:TObject; Data:TRtcValue); override;

    procedure Call_BeforeData(Sender:TObject); override;

    procedure Call_UserLoggedIn(Sender:TObject; const uname:String; uinfo:TRtcRecord); override;
    procedure Call_UserLoggedOut(Sender:TObject; const uname:String); override;

    procedure Call_UserJoinedMyGroup(Sender:TObject; const group:String; const uname:String; uinfo:TRtcRecord); override;
    procedure Call_UserLeftMyGroup(Sender:TObject; const group:String; const uname:String); override;

    procedure Call_JoinedUsersGroup(Sender:TObject; const group:String; const uname:String; uinfo:TRtcRecord); override;
    procedure Call_LeftUsersGroup(Sender:TObject; const group:String; const uname:String); override;

    procedure Call_DataFromUser(Sender:TObject; const uname:String; Data:TRtcFunctionInfo); override;

    procedure Call_AfterData(Sender:TObject); override;
    end;
    <----- *)

  (* Copy the lines below to a new unit when you want to implement a new connection layer for RTC Portal.
    All methods need to be implemented. To get a wrapper for your class, use "Complete class at cursor".
    ----->
    TMyOwnPortalClient=class(TAbsPortalClient)
    protected
    function GetActive: boolean; override;
    procedure SetActive(const Value: boolean); override;

    function GetMode:TRtcPortalClientMode; override;
    procedure SetMode(const Value: TRtcPortalClientMode); override;

    function GetLoginUsername: String; override;
    procedure SetLoginUsername(const Value: String); override;

    function GetParamsLoaded: boolean; override;
    procedure SetParamsLoaded(const Value: boolean); override;

    public
    function canSendNext: boolean; override;

    procedure ParamSet(Sender:TObject; const ParamName:String; ParamValue:TRtcValueObject); override;
    procedure ParamAdd(Sender:TObject; const ParamName:String; ParamValue:TRtcValueObject); override;
    procedure ParamDel(Sender:TObject; const ParamName:String; ParamValue:TRtcValueObject); override;

    procedure LockSender; override;
    procedure UnLockSender(Sender:TObject); override;

    procedure SendPing(Sender:TObject); override;
    procedure SendToUser(Sender:TObject; const username:String; rec:TRtcFunctionInfo); override;
    procedure AddUserToMyGroup(Sender:TObject; const username, Group:String); override;
    procedure RemoveUserFromMyGroup(Sender:TObject; const username, Group:String); override;
    procedure SendToMyGroup(Sender:TObject; const Group:String; rec:TRtcFunctionInfo); override;
    procedure DisbandMyGroup(Sender:TObject; const Group:String); override;
    procedure LeaveUserGroup(Sender:TObject; const username, Group:String); override;

    procedure CallEvent(Sender:TObject; Event:TRtcCustomDataEvent; Obj:TObject; Data:TRtcValue); overload; override;
    procedure CallEvent(Sender:TObject; Event:TRtcCustomDataEvent; Data:TRtcValue); overload; override;
    procedure CallEvent(Sender:TObject; Event:TRtcCustomEvent; Obj:TObject); overload; override;
    procedure CallEvent(Sender:TObject; Event:TRtcCustomEvent); overload; override;
    end;
    <-----
    IMPORTANT NOTE:
    For a description of what each method has to do, please check the TAbsPortalClass interface (below).
    Also, make sure that your component extending TAbsPortalClient calls ALL of the following methods
    in the right places to trigger user-defined events and forward data to RTC Portal Modules ...

    procedure Event_LogIn(Sender:TObject);
    procedure Event_LogOut(Sender:TObject);
    procedure Event_Error(Sender:TObject; Data:TRtcValue);
    procedure Event_FatalError(Sender:TObject; Data:TRtcValue);

    procedure Event_Start(Sender:TObject; Data:TRtcValue);
    procedure Event_Params(Sender:TObject; Data:TRtcValue);

    procedure Event_SenderLoop(Sender:TObject);

    procedure Event_BeforeData(Sender:TObject);
    procedure Event_UserLoggedIn(Sender:TObject; const uname:String; uinfo:TRtcRecord);
    procedure Event_UserLoggedOut(Sender:TObject; const uname:String);
    procedure Event_UserJoinedMyGroup(Sender:TObject; const group:String; const uname:String; uinfo:TRtcRecord);
    procedure Event_UserLeftMyGroup(Sender:TObject; const group:String; const uname:String);
    procedure Event_JoinedUsersGroup(Sender:TObject; const group:String; const uname:String; uinto:TRtcRecord);
    procedure Event_LeftUsersGroup(Sender:TObject; const group:String; const uname:String);
    procedure Event_DataFromUser(Sender:TObject; const uname:String; Data:TRtcFunctionInfo);
    procedure Event_AfterData(Sender:TObject);
  *)

  TAbsPortalClient = class;

  TRtcPortalEvent = procedure(Sender: TAbsPortalClient) of object;
  TRtcPortalDataEvent = procedure(Sender: TAbsPortalClient;
    const Data: TRtcValue) of object;
  TRtcPortalMsgEvent = procedure(Sender: TAbsPortalClient; const Msg: String)
    of object;
  TRtcPortalUserEvent = procedure(Sender: TAbsPortalClient; const User: String)
    of object;
  TRtcPortalGroupEvent = procedure(Sender: TAbsPortalClient;
    const Group, User: String) of object;

  TRtcPModule = class;

  TRtcPModuleUserEvent = procedure(Sender: TRtcPModule; const User: String) of object;

  TRtcPModuleUserAccessEvent = procedure(Sender: TRtcPModule; const User: String; var Allow: boolean) of object;

  TRtcStringList = class(TStringList);

  // @exclude
  TRtcPModuleList = class
  private
    FList: TList;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(Value: TRtcPModule);
    procedure Remove(Value: TRtcPModule);

    procedure RemoveAll;

    function Count: integer;
    function Get(index: integer): TRtcPModule;
  end;

  TRtcPortalComponent = class(TComponent)
  private
    function GetVersionPortal: String;
    procedure SetVersionPortal(const Value: String);
  published
    { RealThinClient Portal Version (for information only) }
    property Version_Portal: String read GetVersionPortal write SetVersionPortal
      stored False;
  end;

  { TRtcPModule is the abstract RTC Portal Module, which you can extend
    if you want to write your own components working with the RTCPortalClient. }
  TRtcPModule = class(TRtcPortalComponent)
  private
    FClient: TAbsPortalClient;
    FModules: TRtcPModuleList;

    FSubscribers: TRtcRecord;
    FSubscriberCnt: integer;

    FOnQueryAccess: TRtcPModuleUserAccessEvent;
    FOnOldUser: TRtcPModuleUserEvent;
    FOnNewUser: TRtcPModuleUserEvent;

    FRCS: TCriticalSection;
    FRemoteUserInfos: TRtcRecord;
    FRemoteUserCnt: TRtcRecord;

    function GetClient: TAbsPortalClient;
    procedure SetClient(const Value: TAbsPortalClient);
    
    function GetRemoteUserInfo(const UserName: String): TRtcRecord;
    procedure SetRemoteUserInfo(const UserName: String; const Value: TRtcRecord);

  protected
    (* Methods which can be used by the component writer *)

    CS: TCriticalSection;

    procedure initSubscribers;
    function isSubscriber(const username: String): boolean;
    function setSubscriber(const username: String; active: boolean): boolean;
    function getSubscriberCnt: integer;

    // Called before Call_Start, Call_LogOut, Call_Error and Call_FatalError
    procedure Init; virtual;

    // Implement if you are linking to any other TRtcPModule. Usage:
    // Check if you are refferencing the "Module" component and remove the reference
    procedure UnlinkModule(const Module: TRtcPModule); virtual;

    procedure UpdateRemoteUserCnt(const UserName:String; cnt:integer);

  protected
    (* PROTECTED Methods to be implemented by the component writer (events) *)

    { Implement this function to return TRUE if you have some data waiting to be sent.
      This function is used by the Desktop Host and File Upload components,
      since they need to send a lot of data by splitting it in smaller chunks. }
    function SenderLoop_Check(Sender: TObject): boolean; virtual;
    { Once you have implemented SenderLoop_Check,
      implement this method to prepare your data for sending. }
    procedure SenderLoop_Prepare(Sender: TObject); virtual;
    { This method will be executed after SenderLoop_Prepare
      and should be used for the actual sending. }
    procedure SenderLoop_Execute(Sender: TObject); virtual;

    { This method will be called when the user has logged in to the Gateway. }
    procedure Call_LogIn(Sender: TObject); virtual;
    { This method will be called when the user has logged out of the Gateway. }
    procedure Call_LogOut(Sender: TObject); virtual;
    { This method will be called when there was an Error and the user was logged out of the Gateway. }
    procedure Call_Error(Sender: TObject; Data: TRtcValue); virtual;
    { This method will be called when there was a FATAL ERROR and the user was logged out of the Gateway. }
    procedure Call_FatalError(Sender: TObject; Data: TRtcValue); virtual;

    { This method will be called when the component was activated.
      You should use this method to initialize all structures. }
    procedure Call_Start(Sender: TObject; Data: TRtcValue); virtual;
    { This method will be called after a user has requested to receive
      parameters from the Gateway. All parameters will be passed to
      this method in a rtc_Record structure, so you can pick out the
      ones interesting for you and store them in your local component variables. }
    procedure Call_Params(Sender: TObject; Data: TRtcValue); virtual;

    { This event will be called when data has been received from the Gateway,
      before anything is done with it. You can use this event to prepare your
      component for processing data received from other users. }
    procedure Call_BeforeData(Sender: TObject); virtual;

    { A user visible to you (Host) has logged in to the Gateway. }
    procedure Call_UserLoggedIn(Sender: TObject; const uname: String; uinfo:TRtcRecord); virtual;
    { A user visible to you (Host) has logged out of the Gateway. }
    procedure Call_UserLoggedOut(Sender: TObject; const uname: String); virtual;

    { The user "uname" was successfully added to your Group "group".
      From here on, this new user will be receiving all data you send to
      the Group "group" [ Client.SendToMyGroup() ]. }
    procedure Call_UserJoinedMyGroup(Sender: TObject; const Group: String;
      const uname: String; uinfo:TRtcRecord); virtual;

    { The user "uname" was successfully removed from your Group "group".
      From here on, the user will no longer receive data you send to the Group. }
    procedure Call_UserLeftMyGroup(Sender: TObject; const Group: String;
      const uname: String); virtual;

    { You were successfully added to the Group "group", maintaned by the user "uname".
      From here on, you will be receiving all data the user sends to the group. }
    procedure Call_JoinedUsersGroup(Sender: TObject; const Group: String;
      const uname: String; uinfo:TRtcRecord); virtual;

    { You were successfully removed from the Group "group", maintaned by the user "uname".
      From here on, you will no longer be receiving data the user sends to the group. }
    procedure Call_LeftUsersGroup(Sender: TObject; const Group: String;
      const uname: String); virtual;

    { You have received data "Data" from user "uname". In this method,
      you should check if the data is of relevance to you and process it where necessary. }
    procedure Call_DataFromUser(Sender: TObject; const uname: String;
      Data: TRtcFunctionInfo); virtual;

    { This event will be called after last data package received from the Gateway was processed.
      You can use this event for possible post-processing and memory cleanup. }
    procedure Call_AfterData(Sender: TObject); virtual;

    procedure Event_NewUser(Sender: TObject; const uname: String; uinfo:TRtcRecord);
    procedure Event_OldUser(Sender: TObject; const uname: String);
    function Event_QueryAccess(Sender: TObject; const uname: String): boolean;

    procedure xOnOldUser(Sender, Obj: TObject; Data: TRtcValue);
    procedure xOnNewUser(Sender, Obj: TObject; Data: TRtcValue);
    procedure xOnQueryAccess(Sender, Obj: TObject; Data: TRtcValue);

    { "User" is asking for access to our Desktop. You can either leave this event un-implemented
      if you want to allow access to all users with granted access rights, or implement this event
      to set the "Allow" parmeter (passed into the event) saying if this user may have access or not. }
    property OnQueryAccess: TRtcPModuleUserAccessEvent read FOnQueryAccess
      write FOnQueryAccess;
    { We have a new Desktop Host user, username = "user".
      You can use this event to maintain a list of active Desktop Host users. }
    property OnUserJoined: TRtcPModuleUserEvent read FOnNewUser
      write FOnNewUser;
    { "User" no longer has our Desktop Host open.
      You can use this event to maintain a list of active Desktop Host users. }
    property OnUserLeft: TRtcPModuleUserEvent read FOnOldUser write FOnOldUser;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    { For Internal Use only, used for adding and removing other
      RtcPModule components which our component is refferencing. }
    procedure AddModule(const Module: TRtcPModule);
    procedure RemModule(const Module: TRtcPModule);

    { Use the CallEvent() method to call the "Event" synchronized when AutoSyncEvents is TRUE,
      or call it from a background thread when AutoSyncEvents is FALSE.
      No objects will be destroy in the method. If you have created any of
      the objects passed to this method, you will also need to free them. }
    procedure CallEvent(Sender: TObject; Event: TRtcCustomDataEvent;
      Obj: TObject; Data: TRtcValue); overload;
    procedure CallEvent(Sender: TObject; Event: TRtcCustomDataEvent;
      Data: TRtcValue); overload;
    procedure CallEvent(Sender: TObject; Event: TRtcCustomEvent;
      Obj: TObject); overload;
    procedure CallEvent(Sender: TObject; Event: TRtcCustomEvent); overload;

    { Returns a *COPY* of LoginUserInfo data received from remote user "UserName".
      You need to manually FREE the Object received from this property.

      NOTE: Assigning a TRtcRecord object here will create a *COPY* of the
      Object being assigned and replace the UserInfo stored in this component,
      but it will NOT affect any UserInfo data stored on the Gateway. }
    property RemoteUserInfo[const UserName:String]:TRtcRecord read GetRemoteUserInfo write SetRemoteUserInfo;

  published
    property Client: TAbsPortalClient read GetClient write SetClient;
  end;

  { Abstract Portal Client class:
    -> implement to use a specific set of connection components. }
  TAbsPortalClient = class(TRtcPortalComponent)
  private
    FModules: TRtcPModuleList;
    FGatewayParams: boolean;

    FRCS: TCriticalSection;
    FRemoteUserInfos: TRtcRecord;
    FRemoteUserCnt: TRtcRecord;

    FOldUserList, FOldSuperUserList: TRtcStringList;
    FUserSList, FSuperUserSList: TRtcStringList;
    FRestrictAccess: boolean;

    FOnError: TRtcPortalMsgEvent;
    FOnFatalError: TRtcPortalMsgEvent;

    FOnLogIn: TRtcPortalEvent;
    FOnLogOut: TRtcPortalEvent;
    FOnUserLoggedOut: TRtcPortalUserEvent;
    FOnUserLoggedIn: TRtcPortalUserEvent;

    FOnStart: TRtcPortalDataEvent;
    FOnParams: TRtcPortalDataEvent;

    FOnJoinedUsersGroup: TRtcPortalGroupEvent;
    FOnUserJoinedMyGroup: TRtcPortalGroupEvent;
    FOnLeftUsersGroup: TRtcPortalGroupEvent;
    FOnUserLeftMyGroup: TRtcPortalGroupEvent;

    procedure AddModule(const Module: TRtcPModule);
    procedure RemModule(const Module: TRtcPModule);

    function GetInUserList(const username: String): boolean;
    procedure SetInUserList(const username: String; const Value: boolean);

    function GetIsSuperUserList(const username: String): boolean;
    procedure SetIsSuperUserList(const username: String; const Value: boolean);

    function GetRestrictAccess: boolean;
    procedure SetRestrictAccess(const Value: boolean);

    function GetSuperUserCount: integer;
    function GetUserListCount: integer;

    function GetSuperUserName(const idx: integer): String;
    function GetUserListName(const idx: integer): String;

    function GetSuperUserList: TStrings;
    function GetUserList: TStrings;
    procedure SetSuperUserList(const Value: TStrings);
    procedure SetUserList(const Value: TStrings);

    procedure DoUserListChanged(Sender: TObject);
    procedure DoSuperUserListChanged(Sender: TObject);

    procedure SetUserParams(Sender: TObject; Data: TRtcValue);

    procedure xOnError(Sender, Obj: TObject; Data: TRtcValue);
    procedure xOnFatalError(Sender, Obj: TObject; Data: TRtcValue);

    procedure xOnLogIn(Sender, Obj: TObject);
    procedure xOnLogOut(Sender, Obj: TObject);

    procedure xOnUserLoggedOut(Sender, Obj: TObject; Data: TRtcValue);
    procedure xOnUserLoggedIn(Sender, Obj: TObject; Data: TRtcValue);
    procedure xOnStart(Sender, Obj: TObject; Data: TRtcValue);
    procedure xOnParams(Sender, Obj: TObject; Data: TRtcValue);

    procedure xOnJoinedUsersGroup(Sender, Obj: TObject; Data: TRtcValue);
    procedure xOnUserJoinedMyGroup(Sender, Obj: TObject; Data: TRtcValue);
    procedure xOnLeftUsersGroup(Sender, Obj: TObject; Data: TRtcValue);
    procedure xOnUserLeftMyGroup(Sender, Obj: TObject; Data: TRtcValue);

    function GetRemoteUserInfo(const UserName: String): TRtcRecord;
    procedure SetRemoteUserInfo(const UserName: String; const Value: TRtcRecord);

  protected
    (* Methods to be used by the Connection class to trigger user-defined events
      and forward data data to RTC Portal Modules linked to this PortalClient. *)

    procedure Event_LogIn(Sender: TObject);
    procedure Event_LogOut(Sender: TObject);
    procedure Event_Error(Sender: TObject; Data: TRtcValue);
    procedure Event_FatalError(Sender: TObject; Data: TRtcValue);

    procedure Event_Start(Sender: TObject; Data: TRtcValue);
    procedure Event_Params(Sender: TObject; Data: TRtcValue);

    procedure Event_SenderLoop(Sender: TObject);

    procedure Event_BeforeData(Sender: TObject);

    procedure Event_UserLoggedIn(Sender: TObject; const uname: String; uinfo:TRtcRecord);
    procedure Event_UserLoggedOut(Sender: TObject; const uname: String);

    procedure Event_UserJoinedMyGroup(Sender: TObject; const Group: String; const uname: String; uinfo:TRtcRecord);
    procedure Event_UserLeftMyGroup(Sender: TObject; const Group: String; const uname: String);

    procedure Event_JoinedUsersGroup(Sender: TObject; const Group: String; const uname: String; uinfo:TRtcRecord);
    procedure Event_LeftUsersGroup(Sender: TObject; const Group: String; const uname: String);

    procedure Event_DataFromUser(Sender: TObject; const uname: String; Data: TRtcFunctionInfo);
    procedure Event_AfterData(Sender: TObject);

    procedure UpdateRemoteUserCnt(const UserName:String; cnt:integer);

  protected
    (* PROTECTED Virtual Abstract methods - to be implemented in Connection class *)

    function GetActive: boolean; virtual; abstract;
    procedure SetActive(const Value: boolean); virtual; abstract;

    procedure SetLoginUsername(const Value: String); virtual; abstract;
    function GetLoginUsername: String; virtual; abstract;

    function GetParamsLoaded: boolean; virtual; abstract;
    procedure SetParamsLoaded(const Value: boolean); virtual; abstract;

    function GetPublish: boolean; virtual; abstract;
    procedure SetPublish(const Value: boolean); virtual; abstract;

    function GetSubscribe: boolean; virtual; abstract;
    procedure SetSubscribe(const Value: boolean); virtual; abstract;

  public
    (* PUBLIC Virtual Abstract methods - to be implemented in Connection class *)

    { If you want to send data which is normally being sent from the "SenderLoop"
      from outside of the "SenderLoop" , you can use this function to
      check if you may do so. The function will return FALSE if the data
      is already being sent and/or prepared in the "SenderLoop",
      in which case you should NOT send it from elsewhere.
      You should NOT use this function for "non-loop" sending. }
    function canSendNext: boolean; virtual; abstract;

    { Use this method to set any users parameter.
      All parameter changes will be sent to the Gateway.
      "ParamValue" object will be destroyed by the method (do not destroy it yourself). }
    procedure ParamSet(Sender: TObject; const ParamName: String;
      ParamValue: TRtcValueObject); virtual; abstract;
    { Use this method to add a new element to users parameter.
      All parameter changes will be sent to the Gateway.
      "ParamValue" object will be destroyed by the method (do not destroy it yourself). }
    procedure ParamAdd(Sender: TObject; const ParamName: String;
      ParamValue: TRtcValueObject); virtual; abstract;
    { Use this method to remove an element from users parameter.
      All parameter changes will be sent to the Gateway.
      "ParamValue" object will be destroyed by the method (do not destroy it yourself). }
    procedure ParamDel(Sender: TObject; const ParamName: String;
      ParamValue: TRtcValueObject); virtual; abstract;

    { You want to send a number of small packages to the Gateway,
      but do not want them to be sent separately (reduce latency effect)?
      You can call LockSender before you start sending data out
      and call UnLockSender when you have prepared everything for sending. }
    procedure LockSender; virtual; abstract;

    { You want to send a number of small packages to the Gateway,
      but do not want them to be sent separately (reduce latency effect)?
      You can call LockSender before you start sending data out
      and call UnLockSender when you have prepared everything for sending. }
    procedure UnLockSender(Sender: TObject); virtual; abstract;

    { Send a PING to the Gateway (no data). }
    procedure SendPing(Sender: TObject); virtual; abstract;

    { Send data "rec" to the user "username".
      "rec" object will be destroyed in the method (do not try to free it yourself). }
    procedure SendToUser(Sender: TObject; const username: String;
      rec: TRtcFunctionInfo); virtual; abstract;

    { Send data "rec" to your group "Group".
      "rec" object will be destroyed in the method (do not try to free it yourself). }
    procedure SendToMyGroup(Sender: TObject; const Group: String;
      rec: TRtcFunctionInfo); virtual; abstract;

    { Add user "username" to your group "Group". If the user is online,
      all data you send to your group "Group" will also be sent to the user "username". }
    procedure AddUserToMyGroup(Sender: TObject; const username, Group: String);
      virtual; abstract;

    { Remove user "username" from your group "Group". From this point on,
      the user "username" will no longer receive data you send to your group "Group". }
    procedure RemoveUserFromMyGroup(Sender: TObject;
      const username, Group: String); virtual; abstract;

    { Disband your group "Group". After a group has been disbanded, it will have no
      more group members, so it will no longer make sense sending data to that group.
      You can always start a new group, by adding users to it [ AddUserToMyGroup() ]. }
    procedure DisbandMyGroup(Sender: TObject; const Group: String);
      virtual; abstract;

    { Remove yourself from the group "Group" maintained by user "username". }
    procedure LeaveUserGroup(Sender: TObject; const username, Group: String);
      virtual; abstract;

    { Use the CallEvent() method to call the "Event" synchronized when AutoSyncEvents is TRUE,
      or call it from a background thread when AutoSyncEvents is FALSE.
      No objects should be destroyed in any of the CallEvent() methods. }
    procedure CallEvent(Sender: TObject; Event: TRtcCustomDataEvent;
      Obj: TObject; Data: TRtcValue); overload; virtual; abstract;
    procedure CallEvent(Sender: TObject; Event: TRtcCustomDataEvent;
      Data: TRtcValue); overload; virtual; abstract;
    procedure CallEvent(Sender: TObject; Event: TRtcCustomEvent; Obj: TObject);
      overload; virtual; abstract;
    procedure CallEvent(Sender: TObject; Event: TRtcCustomEvent); overload;
      virtual; abstract;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    { Read to check if user is in allowed users list,
      Set to TRUE to add the user to allowed users list,
      Set to FALSE to remove the user from allowed users list.
      To be able to change any data in this property, Active has to be FALSE.

      If GatewayParams is TRUE, this parameter will be stored on the Gateway.
      When GatewayParams and RestrictParams are TRUE,
      only users in the UserList will see the Host when it logs in and out,
      while all other users will NOT see the Host in their "connected users" list. }
    property inUserList[const username: String]: boolean read GetInUserList
      write SetInUserList;

    { Read to check if user is in the Super Users list,
      Set to TRUE to add the user to Super Users list,
      Set to FALSE to remove the user from Super Users list.

      If GatewayParams is TRUE, this parameter will be stored on the Gateway. }
    property isSuperUser[const username: String]: boolean
      read GetIsSuperUserList write SetIsSuperUserList;

    property gUserListCount: integer read GetUserListCount;
    property gSuperUserCount: integer read GetSuperUserCount;
    property gUserListName[const idx: integer]: String read GetUserListName;
    property gSuperUserName[const idx: integer]: String read GetSuperUserName;

    { Returns a *COPY* of UserInfo data received for the remote user "UserName".
      You need to manually FREE the Object received from this property.

      NOTE: Assigning a TRtcRecord object will create a *COPY* of the
      Object being assigned and replace the UserInfo stored in this component,
      but it will NOT affect any UserInfo data stored on the Gateway. }
    property RemoteUserInfo[const UserName:String]:TRtcRecord read GetRemoteUserInfo write SetRemoteUserInfo;

  published
    { Set to TRUE to start receiving data and notifications from the Gateway.
      Before you set Active to TRUE, make sure both of your Client objects
      (Client_Get and Client_Put) have their AutoConnect property set to TRUE.
      If you want to use parameters stored on the Gateway, make sure you
      also set GatewayParams to TRUE before setting Active to TRUE.

      NOTE: If you only need to read and modify user parameters,
      you should leave Active as FALSE, and change it to TRUE only
      after the user is fully set up to receive data from other users.
      Setting active to TRUE will disable changing some properties. }
    property Active: boolean read GetActive write SetActive default False;

    { Make the user visible to other users on the same Gateway who have UserNotify=True }
    property UserVisible: boolean read GetPublish write SetPublish
      default False;

    { Notify us when users with UserVisible=True log in or out of the Gateway. }
    property UserNotify: boolean read GetSubscribe write SetSubscribe
      default False;

    { Login Username }
    property LoginUserName: String read GetLoginUsername write SetLoginUsername;

    { Set to TRUE if you wish to store all user parameters on the Gateway
      and load parameters from the Gateway after Activating the component.
      When GatewayParams is FALSE, parameter changes will NOT be sent to the Gateway,
      nor will current parameters stored on the Gateway be loaded on start. }
    property GwStoreParams: boolean read FGatewayParams write FGatewayParams
      default False;

    { Shows if Gateway Parameters were loaded from the Gateway.
      Set to TRUE to reload Gateway Params, set to FALSE to have
      the parameters reloaded the next time you set Active to TRUE.
      When setting Active to TRUE and GwStoreParams is TRUE but GwParamsLoaded is not TRUE,
      Gateway params will automatically be loaded before activating the Client. }
    property GParamsLoaded: boolean read GetParamsLoaded write SetParamsLoaded
      default False;

    { Read to check if access to this Host is restricted only to users from the User List,
      Set to TRUE to restrict access only to users from allowed users list,
      Set to FALSE to allow access to all users, ignoring the users list.
      To be able to change this property, Active has to be FALSE.

      If GatewayParams is TRUE, this parameter will be stored on the Gateway.
      When GatewayParams and RestrictParams are TRUE,
      only users in the UserList will see the Host when it logs in and out,
      while all other users will NOT see the Host in their "connected users" list.

      WARNING! If "GRestrictAccess" is TRUE on the Gateway,
      it will affect the way your Client is seen by other users,
      regardless of your local GRestrictAccess settings.

      In other words, when you set GWStoreParams to FALSE and you
      change GRestrictAccess locally, your client (Host) will be visible
      only to users in the userlist stored on the Gateway,
      and your local changes will not have an effect. }
    property GRestrictAccess: boolean read GetRestrictAccess
      write SetRestrictAccess default False;

    { This list is provided for easier read access to a list of Users allowed access.
      You can also check, add and remove users by using the inUserList[] property. }
    property GUsers: TStrings read GetUserList write SetUserList;

    { This list is provided for easier read access to a list of SuperUsers.
      You can also check, add and remove super users by using the isSuperUser[] property. }
    property GSuperUsers: TStrings read GetSuperUserList write SetSuperUserList;

    { You have been logged in to the Gateway.
      Event will be called with this TAbsPortalClient object as the "Obj" parameter. }
    property OnLogIn: TRtcPortalEvent read FOnLogIn write FOnLogIn;
    { You have been logged out of the Gateway.
      Event will be called with this TAbsPortalClient object as the "Obj" parameter. }
    property OnLogOut: TRtcPortalEvent read FOnLogOut write FOnLogOut;

    { This event will be triggered after GwParamsLoaded was set to TRUE.
      Event will be called with this TAbsPortalClient object as the "Obj" parameter
      and the "Data" parameter will hold a rtc_Record with all user parameters.
      Before the event is called, this and all connected components will read the
      parameters and prepare their properties to reflect the parameters received. }
    property OnParams: TRtcPortalDataEvent read FOnParams write FOnParams;
    { You are now ready to receive data from the Gateway.
      Event will be called with this TAbsPortalClient object as the "Obj" parameter
      and the result received from the Gateway after start as the "Data" parameter. }
    property OnStart: TRtcPortalDataEvent read FOnStart write FOnStart;

    { This event will be triggered when there was an error communicating with the
      Gateway, but there is still a chance you could get the connection to work by
      using the same parameters (try to log in again). }
    property OnError: TRtcPortalMsgEvent read FOnError write FOnError;
    { This event will be triggered when there was a FATAL ERROR while trying to
      communicate with the Gateway. Chances of getting the connection to work again
      by using the same parameters and trying to log in again are almost zero. }
    property OnFatalError: TRtcPortalMsgEvent read FOnFatalError
      write FOnFatalError;

    { This event will be triggered when a user visible to us logs in to the Gateway.
      This event makes it possible to maintain a list of currently active users in real-time. }
    property OnUserLoggedIn: TRtcPortalUserEvent read FOnUserLoggedIn
      write FOnUserLoggedIn;
    { This event will be triggered when a user which was visible to us logs out of to the Gateway.
      This event makes it possible to maintain a list of currently active users in real-time. }
    property OnUserLoggedOut: TRtcPortalUserEvent read FOnUserLoggedOut
      write FOnUserLoggedOut;

    { *Optional* This event will be triggered when a user has joined one of our Groups.
      Event will be called with this TAbsPortalClient object as the "Obj" parameter
      and the "Data" parameter holding a rtc_Record structure with "user" and "group" strings. }
    property On_UserJoinedMyGroup: TRtcPortalGroupEvent
      read FOnUserJoinedMyGroup write FOnUserJoinedMyGroup;
    { *Optional* This event will be triggered when a user has left one of our Groups.
      Event will be called with this TAbsPortalClient object as the "Obj" parameter
      and the "Data" parameter holding a rtc_Record structure with "user" and "group" strings. }
    property On_UserLeftMyGroup: TRtcPortalGroupEvent read FOnUserLeftMyGroup
      write FOnUserLeftMyGroup;

    { *Optional* This event will be triggered when we have joined a group maintained by a user.
      Event will be called with this TAbsPortalClient object as the "Obj" parameter
      and the "Data" parameter holding a rtc_Record structure with "user" and "group" strings. }
    property On_JoinedUsersGroup: TRtcPortalGroupEvent read FOnJoinedUsersGroup
      write FOnJoinedUsersGroup;
    { *Optional* This event will be triggered when we have left a group maintained by a user.
      Event will be called with this TAbsPortalClient object as the "Obj" parameter
      and the "Data" parameter holding a rtc_Record structure with "user" and "group" strings. }
    property On_LeftUsersGroup: TRtcPortalGroupEvent read FOnLeftUsersGroup
      write FOnLeftUsersGroup;
  end;

implementation

// <$hash!> //

{ TRtcPModuleList }

constructor TRtcPModuleList.Create;
begin
  inherited;
  FList := TList.Create;
end;

destructor TRtcPModuleList.Destroy;
begin
  FList.Free;
  inherited;
end;

procedure TRtcPModuleList.Add(Value: TRtcPModule);
var
  idx: integer;
begin
  idx := FList.IndexOf(Value);
  if idx >= 0 then
    FList.Delete(idx);
  FList.Add(Value);
end;

function TRtcPModuleList.Count: integer;
begin
  Result := FList.Count;
end;

procedure TRtcPModuleList.Remove(Value: TRtcPModule);
var
  idx: integer;
begin
  idx := FList.IndexOf(Value);
  if idx >= 0 then
    FList.Delete(idx);
end;

procedure TRtcPModuleList.RemoveAll;
begin
  FList.Clear;
end;

function TRtcPModuleList.Get(index: integer): TRtcPModule;
begin
  if (index >= 0) and (index < FList.Count) then
    Result := TRtcPModule(FList.Items[index])
  else
    raise Exception.Create('TRtcPModuleList.Get returned NIL');
end;

{ TAbsPortalClient }

constructor TAbsPortalClient.Create(AOwner: TComponent);
begin
  inherited;
  FModules := TRtcPModuleList.Create;

  FOldUserList := TRtcStringList.Create;
  FOldUserList.Sorted := True;

  FOldSuperUserList := TRtcStringList.Create;
  FOldSuperUserList.Sorted := True;

  FUserSList := TRtcStringList.Create;
  FUserSList.Sorted := True;

  FSuperUserSList := TRtcStringList.Create;
  FSuperUserSList.Sorted := True;

  FUserSList.OnChange := DoUserListChanged;
  FSuperUserSList.OnChange := DoSuperUserListChanged;

  FRestrictAccess := False;

  FRCS:=TCriticalSection.Create;
  FRemoteUserInfos:=TRtcRecord.Create;
  FRemoteUserCnt:=TRtcRecord.Create;
end;

destructor TAbsPortalClient.Destroy;
begin
  while FModules.Count > 0 do
    FModules.Get(0).Client := nil;

  FModules.Free;

  FUserSList.Free;
  FSuperUserSList.Free;

  FOldUserList.Free;
  FOldSuperUserList.Free;

  FRemoteUserInfos.Free;
  FRemoteUserCnt.Free;
  FRCS.Free;
  inherited;
end;

procedure TAbsPortalClient.AddModule(const Module: TRtcPModule);
begin
  FModules.Add(Module);
end;

procedure TAbsPortalClient.RemModule(const Module: TRtcPModule);
begin
  FModules.Remove(Module);
end;

procedure TAbsPortalClient.Event_UserLoggedIn(Sender: TObject;
  const uname: String; uinfo:TRtcRecord);
var
  Msg: TRtcValue;
  i: integer;
begin
  UpdateRemoteUserCnt(uname,1);
  if assigned(uinfo) then
    RemoteUserInfo[uname]:=uinfo;

  for i := 0 to FModules.Count - 1 do
    FModules.Get(i).Call_UserLoggedIn(Sender, uname, uinfo);

  if assigned(FOnUserLoggedIn) then
  begin
    Msg := TRtcValue.Create;
    try
      Msg.asText := uname;
      CallEvent(Sender, xOnUserLoggedIn, Msg);
    finally
      Msg.Free;
    end;
  end;
end;

procedure TAbsPortalClient.Event_UserLoggedOut(Sender: TObject;
  const uname: String);
var
  Msg: TRtcValue;
  i: integer;
begin
  for i := 0 to FModules.Count - 1 do
    FModules.Get(i).Call_UserLoggedOut(Sender, uname);

  if assigned(FOnUserLoggedOut) then
  begin
    Msg := TRtcValue.Create;
    try
      Msg.asText := uname;
      CallEvent(Sender, xOnUserLoggedOut, Msg);
    finally
      Msg.Free;
    end;
  end;

  UpdateRemoteUserCnt(uname,-1);
end;

procedure TAbsPortalClient.Event_UserJoinedMyGroup(Sender: TObject;
  const Group, uname: String; uinfo:TRtcRecord);
var
  i: integer;
  Msg: TRtcValue;
begin
  UpdateRemoteUserCnt(uname,1);
  if assigned(uinfo) then
    RemoteUserInfo[uname]:=uinfo;

  for i := 0 to FModules.Count - 1 do
    FModules.Get(i).Call_UserJoinedMyGroup(Sender, Group, uname, uinfo);

  if assigned(FOnUserJoinedMyGroup) then
  begin
    Msg := TRtcValue.Create;
    try
      with Msg.newRecord do
      begin
        asText['user'] := uname;
        asText['group'] := Group;
      end;
      CallEvent(Sender, xOnUserJoinedMyGroup, Msg);
    finally
      Msg.Free;
    end;
  end;
end;

procedure TAbsPortalClient.Event_UserLeftMyGroup(Sender: TObject;
  const Group, uname: String);
var
  i: integer;
  Msg: TRtcValue;
begin
  for i := 0 to FModules.Count - 1 do
    FModules.Get(i).Call_UserLeftMyGroup(Sender, Group, uname);

  if assigned(FOnUserLeftMyGroup) then
  begin
    Msg := TRtcValue.Create;
    try
      with Msg.newRecord do
      begin
        asText['user'] := uname;
        asText['group'] := Group;
      end;
      CallEvent(Sender, xOnUserLeftMyGroup, Msg);
    finally
      Msg.Free;
    end;
  end;

  UpdateRemoteUserCnt(uname,-1);
end;

procedure TAbsPortalClient.Event_JoinedUsersGroup(Sender: TObject;
  const Group, uname: String; uinfo:TRtcRecord);
var
  i: integer;
  Msg: TRtcValue;
begin
  UpdateRemoteUserCnt(uname,1);
  if assigned(uinfo) then
    RemoteUserInfo[uname]:=uinfo;

  for i := 0 to FModules.Count - 1 do
    FModules.Get(i).Call_JoinedUsersGroup(Sender, Group, uname, uinfo);

  if assigned(FOnJoinedUsersGroup) then
  begin
    Msg := TRtcValue.Create;
    try
      with Msg.newRecord do
      begin
        asText['user'] := uname;
        asText['group'] := Group;
      end;
      CallEvent(Sender, xOnJoinedUsersGroup, Msg);
    finally
      Msg.Free;
    end;
  end;
end;

procedure TAbsPortalClient.Event_LeftUsersGroup(Sender: TObject;
  const Group, uname: String);
var
  i: integer;
  Msg: TRtcValue;
begin
  for i := 0 to FModules.Count - 1 do
    FModules.Get(i).Call_LeftUsersGroup(Sender, Group, uname);

  if assigned(FOnLeftUsersGroup) then
  begin
    Msg := TRtcValue.Create;
    try
      with Msg.newRecord do
      begin
        asText['user'] := uname;
        asText['group'] := Group;
      end;
      CallEvent(Sender, xOnLeftUsersGroup, Msg);
    finally
      Msg.Free;
    end;
  end;

  UpdateRemoteUserCnt(uname,-1);
end;

procedure TAbsPortalClient.Event_Start(Sender: TObject; Data: TRtcValue);
var
  i: integer;
  x: TRtcPModule;
begin
  for i := 0 to FModules.Count - 1 do
  begin
    x := FModules.Get(i);
    x.Init;
    x.Call_Start(Sender, Data);
  end;

  if assigned(FOnStart) then
    CallEvent(Sender, xOnStart, Data);
end;

procedure TAbsPortalClient.Event_Params(Sender: TObject; Data: TRtcValue);
var
  i: integer;
begin
  SetUserParams(Sender, Data);

  for i := 0 to FModules.Count - 1 do
    FModules.Get(i).Call_Params(Sender, Data);

  if assigned(FOnParams) then
    CallEvent(Sender, xOnParams, Data);
end;

procedure TAbsPortalClient.Event_LogIn(Sender: TObject);
var
  i: integer;
begin
  FRCS.Acquire;
  try
    FRemoteUserInfos.Clear;
    FRemoteUserCnt.Clear;
  finally
    FRCS.Release;
    end;

  for i := 0 to FModules.Count - 1 do
    FModules.Get(i).Call_LogIn(Sender);

  if assigned(FOnLogIn) then
    CallEvent(Sender, xOnLogIn);
end;

procedure TAbsPortalClient.Event_LogOut(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to FModules.Count - 1 do
  begin
    FModules.Get(i).Init;
    FModules.Get(i).Call_LogOut(Sender);
  end;

  if assigned(FOnLogOut) then
    CallEvent(Sender, xOnLogOut);
end;

procedure TAbsPortalClient.Event_Error(Sender: TObject; Data: TRtcValue);
var
  i: integer;
begin
  for i := 0 to FModules.Count - 1 do
  begin
    FModules.Get(i).Init;
    FModules.Get(i).Call_Error(Sender, Data);
  end;

  if assigned(FOnError) then
    CallEvent(Sender, xOnError, Data);
end;

procedure TAbsPortalClient.Event_FatalError(Sender: TObject; Data: TRtcValue);
var
  i: integer;
begin
  for i := 0 to FModules.Count - 1 do
  begin
    FModules.Get(i).Init;
    FModules.Get(i).Call_FatalError(Sender, Data);
  end;

  if assigned(FOnFatalError) then
    CallEvent(Sender, xOnFatalError, Data);
end;

procedure TAbsPortalClient.Event_SenderLoop(Sender: TObject);
var
  tosend: array of boolean;
  am_sending: boolean;

  function Send_Check: boolean;
  var
    ok: boolean;
    i: integer;
  begin
    ok := False;
    for i := 0 to FModules.Count - 1 do
    begin
      tosend[i] := FModules.Get(i).SenderLoop_Check(Sender);
      ok := ok or tosend[i];
    end;
    if ok then
      Result := canSendNext
    else
      Result := False;
  end;

  procedure Send_Prepare;
  var
    i: integer;
  begin
    for i := 0 to FModules.Count - 1 do
      if tosend[i] then
        FModules.Get(i).SenderLoop_Prepare(Sender);
  end;

  procedure Send_Execute;
  var
    i: integer;
  begin
    for i := 0 to FModules.Count - 1 do
      if tosend[i] then
        FModules.Get(i).SenderLoop_Execute(Sender);
  end;

begin
  if FModules.Count = 0 then
    Exit;

  try
    am_sending := False;
    SetLength(tosend, FModules.Count);

    try
      if Send_Check then
      begin
        am_sending := True;
        Send_Prepare;
      end;
    except
      on E: Exception do
        Log('SEND Prepare', E);
    end;

    try
      if am_sending then
        Send_Execute;
    except
      on E: Exception do
        Log('SEND Execute', E);
    end;
  finally
    SetLength(tosend, 0);
  end;
end;

procedure TAbsPortalClient.Event_BeforeData(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to FModules.Count - 1 do
    FModules.Get(i).Call_BeforeData(Sender);
end;

procedure TAbsPortalClient.Event_DataFromUser(Sender: TObject;
  const uname: String; Data: TRtcFunctionInfo);
var
  i: integer;
begin
  for i := 0 to FModules.Count - 1 do
    FModules.Get(i).Call_DataFromUser(Sender, uname, Data);
end;

procedure TAbsPortalClient.Event_AfterData(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to FModules.Count - 1 do
    FModules.Get(i).Call_AfterData(Sender);
end;

procedure TAbsPortalClient.SetRestrictAccess(const Value: boolean);
begin
  if FRestrictAccess <> Value then
  begin
    if FGatewayParams then
      ParamSet(nil, 'RestrictAccess', TRtcBooleanValue.Create(Value));
    FRestrictAccess := Value;
  end;
end;

function TAbsPortalClient.GetRestrictAccess: boolean;
begin
  Result := FRestrictAccess;
end;

procedure TAbsPortalClient.SetInUserList(const username: String;
  const Value: boolean);
var
  idx: integer;
begin
  idx := FUserSList.IndexOf(username);
  if Value <> (idx >= 0) then
    if Value then
      FUserSList.Add(username)
    else
      FUserSList.Delete(idx);
end;

function TAbsPortalClient.GetInUserList(const username: String): boolean;
begin
  if FRestrictAccess then
    Result := FUserSList.IndexOf(username) >= 0
  else
    Result := True;
end;

procedure TAbsPortalClient.SetIsSuperUserList(const username: String;
  const Value: boolean);
var
  idx: integer;
begin
  idx := FSuperUserSList.IndexOf(username);
  if Value <> (idx >= 0) then
    if Value then
      FSuperUserSList.Add(username)
    else
      FSuperUserSList.Delete(idx);
end;

function TAbsPortalClient.GetIsSuperUserList(const username: String): boolean;
begin
  Result := FSuperUserSList.IndexOf(username) >= 0;
end;

procedure TAbsPortalClient.SetUserParams(Sender: TObject; Data: TRtcValue);
var
  i: integer;
  rec: TRtcRecord;
  uname: String;
begin
  if Data.isType = rtc_Record then
  begin
    with Data.asRecord do
    begin
      FRestrictAccess := asBoolean['RestrictAccess'];

      FUserSList.BeginUpdate;
      try
        FOldUserList.Clear;
        FUserSList.Clear;
        if isType['AllowUsers'] = rtc_Record then
        begin
          rec := asRecord['AllowUsers'];
          for i := 0 to rec.Count - 1 do
          begin
            uname := rec.FieldName[i];
            if rec.isType[uname] <> rtc_Null then
            begin
              FOldUserList.Add(uname);
              FUserSList.Add(uname);
            end;
          end;
        end;
      finally
        FUserSList.EndUpdate;
      end;

      FSuperUserSList.BeginUpdate;
      try
        FOldSuperUserList.Clear;
        FSuperUserSList.Clear;
        if isType['SuperUsers'] = rtc_Record then
        begin
          rec := asRecord['SuperUsers'];
          for i := 0 to rec.Count - 1 do
          begin
            uname := rec.FieldName[i];
            if rec.isType[uname] <> rtc_Null then
            begin
              FOldSuperUserList.Add(uname);
              FSuperUserSList.Add(uname);
            end;
          end;
        end;
      finally
        FSuperUserSList.EndUpdate;
      end;
    end;
  end;
end;

function TAbsPortalClient.GetSuperUserCount: integer;
begin
  Result := FSuperUserSList.Count;
end;

function TAbsPortalClient.GetUserListCount: integer;
begin
  Result := FUserSList.Count;
end;

function TAbsPortalClient.GetSuperUserName(const idx: integer): String;
begin
  if (idx >= 0) and (idx < FSuperUserSList.Count) then
    Result := FSuperUserSList.Strings[idx]
  else
    Result := '';
end;

function TAbsPortalClient.GetUserListName(const idx: integer): String;
begin
  if (idx >= 0) and (idx < FUserSList.Count) then
    Result := FUserSList.Strings[idx]
  else
    Result := '';
end;

procedure TAbsPortalClient.DoSuperUserListChanged(Sender: TObject);
var
  idx, a: integer;
  User: String;

  procedure SetUser(Value: boolean);
  var
    rec: TRtcRecord;
  begin
    if FGatewayParams then
    begin
      rec := TRtcRecord.Create;
      rec.asBoolean[User] := Value;
      if Value then
        ParamAdd(nil, 'SuperUsers', rec)
      else
        ParamDel(nil, 'SuperUsers', rec);
    end;

    if Value then
      FOldSuperUserList.Add(User)
    else
      FOldSuperUserList.Delete(idx);
  end;

begin
  // First, we add all users missing from the "Old" list
  for a := 0 to FSuperUserSList.Count - 1 do
  begin
    User := trim(FSuperUserSList.Strings[a]);
    if User <> '' then
    begin
      idx := FOldSuperUserList.IndexOf(User);
      if idx < 0 then
        SetUser(True);
    end;
  end;

  // Then, we remove all users from "Old" which are not in the current userlist
  for idx := FOldSuperUserList.Count - 1 downto 0 do
  begin
    User := FOldSuperUserList.Strings[idx];
    if FSuperUserSList.IndexOf(User) < 0 then
      SetUser(False);
  end;
end;

procedure TAbsPortalClient.DoUserListChanged(Sender: TObject);
var
  idx, a: integer;
  User: String;

  procedure SetUser(Value: boolean);
  var
    rec: TRtcRecord;
  begin
    if FGatewayParams then
    begin
      rec := TRtcRecord.Create;
      rec.asBoolean[User] := Value;
      if Value then
        ParamAdd(nil, 'AllowUsers', rec)
      else
        ParamDel(nil, 'AllowUsers', rec);
    end;

    if Value then
      FOldUserList.Add(User)
    else
      FOldUserList.Delete(idx);
  end;

begin
  // First, we add all users missing from the "Old" list
  for a := 0 to FUserSList.Count - 1 do
  begin
    User := trim(FUserSList.Strings[a]);
    if User <> '' then
    begin
      idx := FOldUserList.IndexOf(User);
      if idx < 0 then
        SetUser(True);
    end;
  end;

  // Then, we remove all users from "Old" which are not in the current userlist
  for idx := FOldUserList.Count - 1 downto 0 do
  begin
    User := FOldUserList.Strings[idx];
    if FUserSList.IndexOf(User) < 0 then
      SetUser(False);
  end;
end;

function TAbsPortalClient.GetUserList: TStrings;
begin
  Result := FUserSList;
end;

function TAbsPortalClient.GetSuperUserList: TStrings;
begin
  Result := FSuperUserSList;
end;

procedure TAbsPortalClient.xOnError(Sender, Obj: TObject; Data: TRtcValue);
begin
  FOnError(self, Data.asText);
end;

procedure TAbsPortalClient.xOnFatalError(Sender, Obj: TObject; Data: TRtcValue);
begin
  FOnFatalError(self, Data.asText);
end;

procedure TAbsPortalClient.xOnLogIn(Sender, Obj: TObject);
begin
  FOnLogIn(self);
end;

procedure TAbsPortalClient.xOnLogOut(Sender, Obj: TObject);
begin
  FOnLogOut(self);
end;

procedure TAbsPortalClient.xOnParams(Sender, Obj: TObject; Data: TRtcValue);
begin
  FOnParams(self, Data);
end;

procedure TAbsPortalClient.xOnStart(Sender, Obj: TObject; Data: TRtcValue);
begin
  FOnStart(self, Data);
end;

procedure TAbsPortalClient.xOnJoinedUsersGroup(Sender, Obj: TObject;
  Data: TRtcValue);
begin
  FOnJoinedUsersGroup(self, Data.asRecord.asText['group'],
    Data.asRecord.asText['user']);
end;

procedure TAbsPortalClient.xOnLeftUsersGroup(Sender, Obj: TObject;
  Data: TRtcValue);
begin
  FOnLeftUsersGroup(self, Data.asRecord.asText['group'],
    Data.asRecord.asText['user']);
end;

procedure TAbsPortalClient.xOnUserJoinedMyGroup(Sender, Obj: TObject;
  Data: TRtcValue);
begin
  FOnUserJoinedMyGroup(self, Data.asRecord.asText['group'],
    Data.asRecord.asText['user']);
end;

procedure TAbsPortalClient.xOnUserLeftMyGroup(Sender, Obj: TObject;
  Data: TRtcValue);
begin
  FOnUserLeftMyGroup(self, Data.asRecord.asText['group'],
    Data.asRecord.asText['user']);
end;

procedure TAbsPortalClient.xOnUserLoggedIn(Sender, Obj: TObject;
  Data: TRtcValue);
begin
  FOnUserLoggedIn(self, Data.asText);
end;

procedure TAbsPortalClient.xOnUserLoggedOut(Sender, Obj: TObject;
  Data: TRtcValue);
begin
  FOnUserLoggedOut(self, Data.asText);
end;

procedure TAbsPortalClient.SetSuperUserList(const Value: TStrings);
begin
  FSuperUserSList.BeginUpdate;
  try
    FSuperUserSList.Clear;
    if assigned(Value) then
      FSuperUserSList.AddStrings(Value);
  finally
    FSuperUserSList.EndUpdate;
  end;
end;

procedure TAbsPortalClient.SetUserList(const Value: TStrings);
begin
  FUserSList.BeginUpdate;
  try
    FUserSList.Clear;
    if assigned(Value) then
      FUserSList.AddStrings(Value);
  finally
    FUserSList.EndUpdate;
  end;
end;

function TAbsPortalClient.GetRemoteUserInfo(const UserName: String): TRtcRecord;
  begin
  FRCS.Acquire;
  try
    if FRemoteUserInfos.isType[UserName]=rtc_Record then
      Result:=TRtcRecord(FRemoteUserInfos.asRecord[UserName].copyOf)
    else
      Result:=TRtcRecord.Create;
  finally
    FRCS.Release;
    end;
  end;

procedure TAbsPortalClient.SetRemoteUserInfo(const UserName: String; const Value: TRtcRecord);
  begin
  FRCS.Acquire;
  try
    FRemoteUserInfos.isNull[UserName]:=True;
    if assigned(Value) then
      FRemoteUserInfos.asRecord[UserName]:=Value;
  finally
    FRCS.Release;
    end;
  end;

procedure TAbsPortalClient.UpdateRemoteUserCnt(const UserName: String; cnt: integer);
  begin
  FRCS.Acquire;
  try
    FRemoteUserCnt.asInteger[UserName]:=FRemoteUserCnt.asInteger[UserName]+cnt;
    if FRemoteUserCnt[UserName]<=0 then
      begin
      FRemoteUserInfos.isNull[UserName]:=True;
      FRemoteUserCnt.isNull[UserName]:=True;
      end;
  finally
    FRCS.Release;
    end;
  end;

{ TRtcPModule }

constructor TRtcPModule.Create(AOwner: TComponent);
begin
  inherited;
  FClient := nil;
  CS := TCriticalSection.Create;
  FModules := TRtcPModuleList.Create;

  FSubscribers := TRtcRecord.Create;
  FSubscriberCnt := 0;

  FRCS := TCriticalSection.Create;
  FRemoteUserInfos := TRtcRecord.Create;
  FRemoteUserCnt := TRtcRecord.Create;
end;

destructor TRtcPModule.Destroy;
begin
  while FModules.Count > 0 do
    FModules.Get(0).UnlinkModule(self);

  if assigned(FClient) then
    FClient.RemModule(self);

  FModules.Free;
  FSubscribers.Free;
  CS.Free;

  FRemoteUserInfos.Free;
  FRemoteUserCnt.Free;
  FRCS.Free;
  inherited;
end;

procedure TRtcPModule.AddModule(const Module: TRtcPModule);
begin
  // add a link to a module referencing us
  FModules.Add(Module);
end;

procedure TRtcPModule.RemModule(const Module: TRtcPModule);
begin
  // remove a link from a module referencing us
  FModules.Remove(Module);
end;

procedure TRtcPModule.UnlinkModule(const Module: TRtcPModule);
begin
  // implement in specific PModule to remove links
  // to any RtcPModules which we are directly referencing
end;

function TRtcPModule.isSubscriber(const username: String): boolean;
begin
  CS.Acquire;
  try
    Result := FSubscribers.asBoolean[username];
  finally
    CS.Release;
  end;
end;

function TRtcPModule.setSubscriber(const username: String;
  active: boolean): boolean;
begin
  CS.Acquire;
  try
    if active <> FSubscribers.asBoolean[username] then
    begin
      Result := True;
      if active then
      begin
        FSubscribers.asBoolean[username] := True;
        Inc(FSubscriberCnt);
      end
      else
      begin
        FSubscribers.asBoolean[username] := False;
        Dec(FSubscriberCnt);
        if FSubscriberCnt = 0 then
          FSubscribers.Clear;
      end;
    end
    else
      Result := False;
  finally
    CS.Release;
  end;
end;

function TRtcPModule.getSubscriberCnt: integer;
begin
  CS.Acquire;
  try
    Result := FSubscriberCnt;
  finally
    CS.Release;
  end;
end;

procedure TRtcPModule.SetClient(const Value: TAbsPortalClient);
begin
  if Value <> FClient then
  begin
    if assigned(FClient) then
      FClient.RemModule(self);
    FClient := Value;
    if assigned(FClient) then
      FClient.AddModule(self);
  end;
end;

function TRtcPModule.GetClient: TAbsPortalClient;
begin
  Result := FClient;
end;

procedure TRtcPModule.CallEvent(Sender: TObject; Event: TRtcCustomDataEvent;
  Data: TRtcValue);
begin
  if assigned(Client) then
    Client.CallEvent(Sender, Event, self, Data);
end;

procedure TRtcPModule.CallEvent(Sender: TObject; Event: TRtcCustomDataEvent;
  Obj: TObject; Data: TRtcValue);
begin
  if assigned(Client) then
    Client.CallEvent(Sender, Event, Obj, Data);
end;

procedure TRtcPModule.CallEvent(Sender: TObject; Event: TRtcCustomEvent);
begin
  if assigned(Client) then
    Client.CallEvent(Sender, Event, self);
end;

procedure TRtcPModule.CallEvent(Sender: TObject; Event: TRtcCustomEvent;
  Obj: TObject);
begin
  if assigned(Client) then
    Client.CallEvent(Sender, Event, Obj);
end;

procedure TRtcPModule.Init;
begin
  FSubscribers.Clear;
  FSubscriberCnt := 0;

  FRCS.Acquire;
  try
    FRemoteUserInfos.Clear;
    FRemoteUserCnt.Clear;
  finally
    FRCS.Release;
    end;
end;

procedure TRtcPModule.initSubscribers;
begin
  FSubscribers.Clear;
  FSubscriberCnt := 0;
end;

function TRtcPModule.SenderLoop_Check(Sender: TObject): boolean;
begin
  Result := False;
end;

procedure TRtcPModule.SenderLoop_Prepare(Sender: TObject);
begin
end;

procedure TRtcPModule.SenderLoop_Execute(Sender: TObject);
begin
end;

procedure TRtcPModule.Call_UserLoggedIn(Sender: TObject; const uname: String; uinfo:TRtcRecord);
begin
  UpdateRemoteUserCnt(uname,1);
  if assigned(uinfo) then
    RemoteUserInfo[uname]:=uinfo;
end;

procedure TRtcPModule.Call_UserLoggedOut(Sender: TObject; const uname: String);
begin
  UpdateRemoteUserCnt(uname,-1);
end;

procedure TRtcPModule.Call_Start(Sender: TObject; Data: TRtcValue);
begin
end;

procedure TRtcPModule.Call_Params(Sender: TObject; Data: TRtcValue);
begin
end;

procedure TRtcPModule.Call_BeforeData(Sender: TObject);
begin
end;

procedure TRtcPModule.Call_AfterData(Sender: TObject);
begin
end;

procedure TRtcPModule.Call_DataFromUser(Sender: TObject; const uname: String;
  Data: TRtcFunctionInfo);
begin
end;

procedure TRtcPModule.Call_JoinedUsersGroup(Sender: TObject;
  const Group, uname: String; uinfo:TRtcRecord);
begin
  UpdateRemoteUserCnt(uname,1);
  if assigned(uinfo) then
    RemoteUserInfo[uname]:=uinfo;
end;

procedure TRtcPModule.Call_LeftUsersGroup(Sender: TObject;
  const Group, uname: String);
begin
  UpdateRemoteUserCnt(uname,-1);
end;

procedure TRtcPModule.Call_UserJoinedMyGroup(Sender: TObject;
  const Group, uname: String; uinfo:TRtcRecord);
begin
  UpdateRemoteUserCnt(uname,1);
  if assigned(uinfo) then
    RemoteUserInfo[uname]:=uinfo;
end;

procedure TRtcPModule.Call_UserLeftMyGroup(Sender: TObject;
  const Group, uname: String);
begin
  UpdateRemoteUserCnt(uname,-1);
end;

procedure TRtcPModule.Call_Error(Sender: TObject; Data: TRtcValue);
begin
end;

procedure TRtcPModule.Call_FatalError(Sender: TObject; Data: TRtcValue);
begin
end;

procedure TRtcPModule.Call_LogIn(Sender: TObject);
begin
end;

procedure TRtcPModule.Call_LogOut(Sender: TObject);
begin
end;

procedure TRtcPModule.Event_NewUser(Sender: TObject; const uname: String; uinfo:TRtcRecord);
var
  Msg: TRtcValue;
begin
  UpdateRemoteUserCnt(uname,1);
  if assigned(uinfo) then
    RemoteUserInfo[uname]:=uinfo;

  if assigned(FOnNewUser) then
  begin
    Msg := TRtcValue.Create;
    try
      Msg.asText := uname;
      CallEvent(Sender, xOnNewUser, Msg);
    finally
      Msg.Free;
    end;
  end;
end;

procedure TRtcPModule.Event_OldUser(Sender: TObject; const uname: String);
var
  Msg: TRtcValue;
begin
  if assigned(FOnOldUser) then
  begin
    Msg := TRtcValue.Create;
    try
      Msg.asText := uname;
      CallEvent(Sender, xOnOldUser, Msg);
    finally
      Msg.Free;
    end;
  end;
  UpdateRemoteUserCnt(uname,-1);
end;

function TRtcPModule.Event_QueryAccess(Sender: TObject;
  const uname: String): boolean;
var
  Msg: TRtcValue;
begin
  Result := True;
  if assigned(FOnQueryAccess) then
  begin
    Msg := TRtcValue.Create;
    try
      Msg.asText := uname;
      CallEvent(Sender, xOnQueryAccess, Msg);
      Result := Msg.asBoolean;
    finally
      Msg.Free;
    end;
  end;
end;

procedure TRtcPModule.xOnNewUser(Sender, Obj: TObject; Data: TRtcValue);
begin
  FOnNewUser(self, Data.asText);
end;

procedure TRtcPModule.xOnOldUser(Sender, Obj: TObject; Data: TRtcValue);
begin
  FOnOldUser(self, Data.asText);
end;

procedure TRtcPModule.xOnQueryAccess(Sender, Obj: TObject; Data: TRtcValue);
var
  Allow: boolean;
begin
  Allow := True;
  FOnQueryAccess(self, Data.asText, Allow);
  Data.isNull := True;
  Data.asBoolean := Allow;
end;

function TRtcPModule.GetRemoteUserInfo(const UserName: String): TRtcRecord;
  begin
  FRCS.Acquire;
  try
    if FRemoteUserInfos.isType[UserName]=rtc_Record then
      Result:=TRtcRecord(FRemoteUserInfos.asRecord[UserName].copyOf)
    else
      Result:=TRtcRecord.Create;
  finally
    FRCS.Release;
    end;
  end;

procedure TRtcPModule.SetRemoteUserInfo(const UserName: String; const Value: TRtcRecord);
  begin
  FRCS.Acquire;
  try
    FRemoteUserInfos.isNull[UserName]:=True;
    if assigned(Value) then
      FRemoteUserInfos.asRecord[UserName]:=Value;
  finally
    FRCS.Release;
    end;
  end;

procedure TRtcPModule.UpdateRemoteUserCnt(const UserName: String; cnt: integer);
  begin
  FRCS.Acquire;
  try
    FRemoteUserCnt.asInteger[UserName]:=FRemoteUserCnt.asInteger[UserName]+cnt;
    if FRemoteUserCnt[UserName]<=0 then
      begin
      FRemoteUserInfos.isNull[UserName]:=True;
      FRemoteUserCnt.isNull[UserName]:=True;
      end;
  finally
    FRCS.Release;
    end;
  end;

{ TRtcPortalComponent }

function TRtcPortalComponent.GetVersionPortal: String;
begin
  Result := RTCPORTAL_VERSION;
end;

procedure TRtcPortalComponent.SetVersionPortal(const Value: String);
begin
  // This method has to exist for Delphi
  // to display the property in the IDE.
end;

end.
