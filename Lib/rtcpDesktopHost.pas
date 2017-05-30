{ Copyright 2004-2017 (c) RealThinClient.com (http://www.realthinclient.com) }

unit rtcpDesktopHost;

interface

{$INCLUDE rtcDefs.inc}
{$INCLUDE rtcPortalDefs.inc}

uses
  Windows, Classes, SysUtils, Controls,
{$IFNDEF IDE_1}
  Variants,
{$ENDIF}
  rtcLog, SyncObjs,
  rtcInfo, rtcPortalMod,

  rtcScrCapture, rtcScrUtils,
  rtcWinLogon,

  rtcpFileTrans,
  rtcpDesktopConst;

type
  TRtcPDesktopHost = class(TRtcPModule)
  private
    CS2: TCriticalSection;
    Clipboards: TRtcRecord;
    FLastMouseUser: String;
    FDesktopActive: boolean;

    Scr: TRtcScreenCapture;
    LastGrab: longword;

    FramePause, FrameSleep: longword;

    RestartRequested: boolean;

    FShowFullScreen: boolean;
    FScreenRect: TRect;

    FUseMouseDriver: boolean;
    FUseMirrorDriver: boolean;
    FCaptureAllMonitors: boolean;
    FCaptureLayeredWindows: boolean;
    FScreenInBlocks: TrdScreenBlocks;
    FScreenRefineBlocks: TrdScreenBlocks;
    FScreenRefineDelay: integer;
    FScreenSizeLimit: TrdScreenLimit;

    FColorLimit: TrdColorLimit;
    FLowColorLimit: TrdLowColorLimit;
    FColorReducePercent: integer;
    FFrameRate: TrdFrameRate;

    FAllowControl: boolean;
    FAllowView: boolean;

    FAllowSuperControl: boolean;
    FAllowSuperView: boolean;

    loop_needtosend, loop_need_restart: boolean;
    loop_s1, loop_s2: RtcString;

    _desksub: TRtcArray;
    _sub_desk: TRtcRecord;

    FAccessControl: boolean;
    FGatewayParams: boolean;

    FFileTrans: TRtcPFileTransfer;

    procedure setClipboard(const username: String; const data: RtcString);

    procedure ScrStart;
    procedure ScrStop;

    function GetLastMouseUser: String;
    function GetColorLimit: TrdColorLimit;
    function GetLowColorLimit: TrdLowColorLimit;
    function GetFrameRate: TrdFrameRate;
    function GetShowFullScreen: boolean;
    function GetUseMirrorDriver: boolean;
    function GetUseMouseDriver: boolean;
    function GetCaptureLayeredWindows: boolean;

    procedure SetColorLimit(const Value: TrdColorLimit);
    procedure SetLowColorLimit(const Value: TrdLowColorLimit);
    procedure SetFrameRate(const Value: TrdFrameRate);
    procedure SetShowFullScreen(const Value: boolean);
    procedure SetUseMirrorDriver(const Value: boolean);
    procedure SetUseMouseDriver(const Value: boolean);
    procedure SetCaptureLayeredWindows(const Value: boolean);

    function setDeskSubscriber(const username: String; active: boolean)
      : boolean;

    function GetAllowControl: boolean;
    function GetAllowSuperControl: boolean;
    function GetAllowSuperView: boolean;
    function GetAllowView: boolean;
    procedure SetAllowControl(const Value: boolean);
    procedure SetAllowSuperControl(const Value: boolean);
    procedure SetAllowSuperView(const Value: boolean);
    procedure SetAllowView(const Value: boolean);

    function GetCaptureAllMonitors: boolean;
    procedure SetCaptureAllMonitors(const Value: boolean);

    function GetColorReducePercent: integer;
    procedure SetColorReducePercent(const Value: integer);

    function MayViewDesktop(const user: String): boolean;
    function MayControlDesktop(const user: String): boolean;

    procedure SetFileTrans(const Value: TRtcPFileTransfer);
    procedure MakeDesktopActive;

    function GetSendScreenInBlocks: TrdScreenBlocks;
    function GetSendScreenRefineBlocks: TrdScreenBlocks;
    function GetSendScreenRefineDelay: integer;
    function GetSendScreenSizeLimit: TrdScreenLimit;

    procedure SetSendScreenInBlocks(const Value: TrdScreenBlocks);
    procedure SetSendScreenRefineBlocks(const Value: TrdScreenBlocks);
    procedure SetSendScreenRefineDelay(const Value: integer);
    procedure SetSendScreenSizeLimit(const Value: TrdScreenLimit);

  protected
    // Implement if you are linking to any other TRtcPModule. Usage:
    // Check if you are refferencing the "Module" component and remove the refference
    procedure UnlinkModule(const Module: TRtcPModule); override;

    function SenderLoop_Check(Sender: TObject): boolean; override;
    procedure SenderLoop_Prepare(Sender: TObject); override;
    procedure SenderLoop_Execute(Sender: TObject); override;

    procedure Call_LogIn(Sender: TObject); override;
    procedure Call_LogOut(Sender: TObject); override;
    procedure Call_Error(Sender: TObject; data: TRtcValue); override;
    procedure Call_FatalError(Sender: TObject; data: TRtcValue); override;

    procedure Call_Start(Sender: TObject; data: TRtcValue); override;
    procedure Call_Params(Sender: TObject; data: TRtcValue); override;

    procedure Call_BeforeData(Sender: TObject); override;

    // procedure Call_UserLoggedIn(Sender: TObject; const uname: String; uinfo:TRtcRecord); override;
    // procedure Call_UserLoggedOut(Sender: TObject; const uname: String); override;

    procedure Call_UserJoinedMyGroup(Sender: TObject; const group: String;
      const uname: String; uinfo:TRtcRecord); override;
    procedure Call_UserLeftMyGroup(Sender: TObject; const group: String;
      const uname: String); override;

    // procedure Call_JoinedUsersGroup(Sender: TObject; const group: String; const uname: String; uinfo:TRtcRecord); override;
    // procedure Call_LeftUsersGroup(Sender: TObject; const group: String; const uname: String); override;

    procedure Call_DataFromUser(Sender: TObject; const uname: String;
      data: TRtcFunctionInfo); override;

    procedure Call_AfterData(Sender: TObject); override;

    procedure Init; override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Restart;

    // Open Desktop session for user "uname"
    procedure Open(const uname: String; Sender: TObject = nil);

    // Close all Desktop sessions: all users viewing or controlling our Desktop will be disconnected.
    procedure CloseAll(Sender: TObject = nil);
    // Close Desktop sessions for user "uname"
    procedure Close(const uname: String; Sender: TObject = nil);

    property LastMouseUser: String read GetLastMouseUser;

    function MirrorDriverInstalled(Init: boolean = False): boolean;

  published
    { Set to TRUE if you wish to store access right and screen parameters on the Gateway
      and load parameters from the Gateway after Activating the component.
      When gwStoreParams is FALSE, parameter changes will NOT be sent to the Gateway,
      nor will current parameters stored on the Gateway be loaded on start. }
    property GwStoreParams: boolean read FGatewayParams write FGatewayParams
      default False;

    { Set to FALSE if you want to ignore Access right settings and allow all actions,
      regardless of user lists and AllowView/Control parameters set by this user. }
    property AccessControl: boolean read FAccessControl write FAccessControl
      default True;

    { Allow users to View our Desktop?
      If gwStoreParams=True, this parameter will be stored on the Gateway. }
    property GAllowView: boolean read GetAllowView write SetAllowView
      default True;
    { Allow Super users to View our Desktop?
      If geStoreParams=True, this parameter will be stored on the Gateway. }
    property GAllowView_Super: boolean read GetAllowSuperView
      write SetAllowSuperView default True;

    { Allow users to Control our Desktop?
      If gwStoreParams=True, this parameter will be stored on the Gateway. }
    property GAllowControl: boolean read GetAllowControl write SetAllowControl
      default True;
    { Allow Super users to Control our Desktop?
      If gwStoreParams=True, this parameter will be stored on the Gateway. }
    property GAllowControl_Super: boolean read GetAllowSuperControl
      write SetAllowSuperControl default True;

    { This property defines in how many frames the Screen image will be split when processing the first image pass.
      If gwStoreParams=True, this parameter will be stored on the Gateway. }
    property GSendScreenInBlocks: TrdScreenBlocks read GetSendScreenInBlocks
      write SetSendScreenInBlocks default rdBlocks1;
    { This property defines in how many steps the Screen image will be refined.
      If gwStoreParams=True, this parameter will be stored on the Gateway. }
    property GSendScreenRefineBlocks: TrdScreenBlocks
      read GetSendScreenRefineBlocks write SetSendScreenRefineBlocks
      default rdBlocks1;
    { This property defines minimum delay (in seconds) before the Screen image can be refined.
      If the value is zero, a default delay of 500 ms (0.5 seconds) will be used.
      If gwStoreParams=True, this parameter will be stored on the Gateway. }
    property GSendScreenRefineDelay: integer read GetSendScreenRefineDelay
      write SetSendScreenRefineDelay default 0;
    { This property defines how much data can be sent in a single screen frame.
      If gwStoreParams=True, this parameter will be stored on the Gateway. }
    property GSendScreenSizeLimit: TrdScreenLimit read GetSendScreenSizeLimit
      write SetSendScreenSizeLimit default rdBlockAnySize;
    { Use Video Mirror Driver (if installed)?
      Using video mirror driver can greatly improve remote desktop performance.
      If gwStoreParams=True, this parameter will be stored on the Gateway. }
    property GUseMirrorDriver: boolean read GetUseMirrorDriver
      write SetUseMirrorDriver default False;
    { Use Virtual Mouse Driver (if DLL and SYS files are available)?
      Using virtual mouse driver makes it possible to control the UAC screen on Vista,
      but requires the EXE to be compiled with the "rtcportaluac" manifest file,
      signed with a trusted certificate and placed in a trusted folder like "C:/Program Files". }
    property GUseMouseDriver: boolean read GetUseMouseDriver
      write SetUseMouseDriver default False;
    { Capture Layered Windows even if not using mirror driver (slows down screen capture)?
      If gwStoreParams=True, this parameter will be stored on the Gateway. }
    property GCaptureLayeredWindows: boolean read GetCaptureLayeredWindows
      write SetCaptureLayeredWindows default False;
    { Capture Screen from All Monotirs when TRUE, or only from the Primary Display when FALSE.
      If gwStoreParams=True, this parameter will be stored on the Gateway. }
    property GCaptureAllMonitors: boolean read GetCaptureAllMonitors
      write SetCaptureAllMonitors default False;

    { Limiting the number of colors can reduce bandwidth needs and improve performance.
      If gwStoreParams=True, this parameter will be stored on the Gateway. }
    property GColorLimit: TrdColorLimit read GetColorLimit write SetColorLimit
      default rdColor8bit;
    { Setting LowColorLimit value lower than ColorLimit value will use dynamic color reduction to
      improve performance by sending the image in LowColorLimit first and then refining up to ColorLimit.
      If gwStoreParams=True, this parameter will be stored on the Gateway. }
    property GColorLowLimit: TrdLowColorLimit read GetLowColorLimit
      write SetLowColorLimit default rd_ColorHigh;
    { ColorReducePercent defines the minimum percentage (0-100) by which the normal color
      image has to be reduced in size using low color limit in order to use the low color image.
      If gwStoreParams=True, this parameter will be stored on the Gateway. }
    property GColorReducePercent: integer read GetColorReducePercent
      write SetColorReducePercent default 0;
    { Reducing Frame rate can reduce CPU usage and bandwidth needs.
      If gwStoreParams=True, this parameter will be stored on the Gateway. }
    property GFrameRate: TrdFrameRate read GetFrameRate write SetFrameRate
      default rdFramesMax;

    { If FullScreen is TRUE, the whole Screen (Desktop region) is sent.
      If FullScreen is FALSE, only the part defined with "ScreenRect" is sent.
      If gwStoreParams=True, this parameter will be stored on the Gateway. }
    property GFullScreen: boolean read GetShowFullScreen write SetShowFullScreen
      default True;

    { Rectangular Screen Region to be sent when FullScreen is FALSE.
      This parameter is NOT stored on the Gateway. }
    property ScreenRect: TRect read FScreenRect write FScreenRect;

    { FileTransfer component to be used when we need to send a file to a user. }
    property FileTransfer: TRtcPFileTransfer read FFileTrans write SetFileTrans;

    { User with username = "user" is asking for access to our Desktop.
      Note that ONLY users with granted access will trigger this event. If you have already limited
      access to this Host by using the AllowUsersList, users who are NOT on that list will be ignored
      and no events will be triggered for them. So ... you could leave this event empty (not implemented)
      if you want to allow access to all users with granted access rights, or you could implement this event
      to set the "Allow" parmeter (passed into the event as TRUE) saying if this user may access our Desktop.

      If you implement this event, make sure it will not take longer than 20 seconds to complete, because
      this code is executed from the context of a connection component responsible for receiving data from
      the Gateway and if this component does not return to the Gateway before time runs out, the client will
      be disconnected from the Gateway. If you implement this event by using a dialog for the user, that dialog
      will have to auto-close whithin no more than 20 seconds automatically, selecting what ever you find apropriate. }
    property OnQueryAccess;
    { We have a new Desktop Host user, username = "user".
      You can use this event to maintain a list of active Desktop Host users. }
    property OnUserJoined;
    { "User" no longer has our Desktop Host open.
      You can use this event to maintain a list of active Desktop Host users. }
    property OnUserLeft;
  end;

implementation

uses Math;

{ TRtcPDesktopHost }

constructor TRtcPDesktopHost.Create(AOwner: TComponent);
begin
  inherited;
  CS2 := TCriticalSection.Create;
  Clipboards := TRtcRecord.Create;
  FLastMouseUser := '';
  FDesktopActive := False;
  _desksub := nil;
  _sub_desk := nil;

  FAccessControl := True;

  FAllowView := True;
  FAllowControl := True;

  FAllowSuperView := True;
  FAllowSuperControl := True;

  FShowFullScreen := True;
  FScreenInBlocks := rdBlocks1;
  FScreenRefineBlocks := rdBlocks1;
  FScreenRefineDelay := 0;
  FScreenSizeLimit := rdBlockAnySize;
  FUseMirrorDriver := False;
  FUseMouseDriver := False;
  FCaptureAllMonitors := False;
  FCaptureLayeredWindows := False;

  FColorLimit := rdColor8bit;
  FLowColorLimit := rd_ColorHigh;
  FColorReducePercent := 0;
  FFrameRate := rdFramesMax;
end;

destructor TRtcPDesktopHost.Destroy;
begin
  FileTransfer := nil;

  ScrStop;
  if assigned(_desksub) then
  begin
    _desksub.Free;
    _desksub := nil;
  end;
  if assigned(_sub_desk) then
  begin
    _sub_desk.Free;
    _sub_desk := nil;
  end;
  Clipboards.Free;
  CS2.Free;
  inherited;
end;

function TRtcPDesktopHost.MayControlDesktop(const user: String): boolean;
begin
  if FAccessControl and assigned(Client) then
    Result := (FAllowControl and Client.inUserList[user]) or
      (FAllowSuperControl and Client.isSuperUser[user])
  else
    Result := True;
end;

function TRtcPDesktopHost.MayViewDesktop(const user: String): boolean;
begin
  if FAccessControl and assigned(Client) then
    Result := (FAllowView and Client.inUserList[user]) or
      (FAllowSuperView and Client.isSuperUser[user])
  else
    Result := True;
end;

procedure TRtcPDesktopHost.Init;
begin
  ScrStop;
  inherited;
end;

procedure TRtcPDesktopHost.MakeDesktopActive;
begin
  if not FDesktopActive then
  begin
    FDesktopActive := True;
    SwitchToActiveDesktop;
  end;
end;

procedure TRtcPDesktopHost.Call_LogIn(Sender: TObject);
begin
end;

procedure TRtcPDesktopHost.Call_LogOut(Sender: TObject);
begin
end;

procedure TRtcPDesktopHost.Call_Params(Sender: TObject; data: TRtcValue);
begin
  CS2.Acquire;
  try
    RestartRequested := False;
    FLastMouseUser := '';
    Clipboards.Clear;
  finally
    CS2.Release;
  end;

  if FGatewayParams then
    if data.isType = rtc_Record then
      with data.asRecord do
      begin
        FAllowView := not asBoolean['NoViewDesktop'];
        FAllowControl := not asBoolean['NoControlDesktop'];

        FAllowSuperView := not asBoolean['NoSuperViewDesktop'];
        FAllowSuperControl := not asBoolean['NoSuperControlDesktop'];

        FShowFullScreen := not asBoolean['ScreenRegion'];
        FUseMirrorDriver := asBoolean['MirrorDriver'];
        FUseMouseDriver := asBoolean['MouseDriver'];
        FCaptureAllMonitors := asBoolean['AllMonitors'];
        FCaptureLayeredWindows := asBoolean['LayeredWindows'];

        FScreenInBlocks := TrdScreenBlocks(asInteger['ScreenBlocks']);
        FScreenRefineBlocks := TrdScreenBlocks(asInteger['ScreenBlocks2']);
        FScreenRefineDelay := asInteger['Screen2Delay'];
        FScreenSizeLimit := TrdScreenLimit(asInteger['ScreenLimit']);
        FColorLimit := TrdColorLimit(asInteger['ColorLimit']);
        FLowColorLimit := TrdLowColorLimit(asInteger['LowColorLimit']);
        FColorReducePercent := asInteger['ColorReducePercent'];
        FFrameRate := TrdFrameRate(asInteger['FrameRate']);
      end;
end;

procedure TRtcPDesktopHost.Call_Start(Sender: TObject; data: TRtcValue);
begin
  ScrStart;
end;

procedure TRtcPDesktopHost.Call_Error(Sender: TObject; data: TRtcValue);
begin
end;

procedure TRtcPDesktopHost.Call_FatalError(Sender: TObject; data: TRtcValue);
begin
end;

procedure TRtcPDesktopHost.Call_BeforeData(Sender: TObject);
begin
  if assigned(_desksub) then
  begin
    _desksub.Free;
    _desksub := nil;
  end;
  if assigned(_sub_desk) then
  begin
    _sub_desk.Free;
    _sub_desk := nil;
  end;
  FDesktopActive := False;
end;

procedure TRtcPDesktopHost.Call_UserJoinedMyGroup(Sender: TObject;
  const group, uname: String; uinfo:TRtcRecord);
begin
  inherited;

  if group = 'idesk' then
  begin
    if MayViewDesktop(uname) then
    begin
      // store to change temporary to full subscription
      if not assigned(_desksub) then
        _desksub := TRtcArray.Create;
      _desksub.asText[_desksub.Count] := uname;

      if not isSubscriber(uname) then
        Event_NewUser(Sender, uname, uinfo);
    end;
  end
  else if group = 'desk' then
  begin
    if MayViewDesktop(uname) then
    begin
      if setDeskSubscriber(uname, True) then
      begin
        // Event_NewUser(Sender, uname);
      end;
    end;
  end;
end;

procedure TRtcPDesktopHost.Call_UserLeftMyGroup(Sender: TObject;
  const group, uname: String);
begin
  if group = 'idesk' then
  begin
    if not isSubscriber(uname) then
      Event_OldUser(Sender, uname);
  end
  else if group = 'desk' then
  begin
    if setDeskSubscriber(uname, False) then
      Event_OldUser(Sender, uname);
  end;

  inherited;
end;

procedure TRtcPDesktopHost.Call_DataFromUser(Sender: TObject;
  const uname: String; data: TRtcFunctionInfo);
var
  s: RtcString;
  r: TRtcFunctionInfo;
  MyFiles: TRtcArray;
  k: integer;
  ScrChanged: boolean;
begin
  if data.FunctionName = 'mouse' then
  begin
    if MayControlDesktop(uname) and isSubscriber(uname) then
    begin
      MakeDesktopActive;
      if data.isType['d'] = rtc_Integer then
      begin
        CS2.Acquire;
        try
          FLastMouseUser := uname;
        finally
          CS2.Release;
        end;
        CS.Acquire;
        try
          if assigned(Scr) then
            case data.asInteger['d'] of
              1:
                Scr.MouseDown(uname, data.asInteger['x'],
                  data.asInteger['y'], mbLeft);
              2:
                Scr.MouseDown(uname, data.asInteger['x'],
                  data.asInteger['y'], mbRight);
              3:
                Scr.MouseDown(uname, data.asInteger['x'], data.asInteger['y'],
                  mbMiddle);
            end;
        finally
          CS.Release;
        end;
      end
      else if data.isType['u'] = rtc_Integer then
      begin
        CS2.Acquire;
        try
          FLastMouseUser := uname;
        finally
          CS2.Release;
        end;
        CS.Acquire;
        try
          if assigned(Scr) then
            case data.asInteger['u'] of
              1:
                Scr.MouseUp(uname, data.asInteger['x'],
                  data.asInteger['y'], mbLeft);
              2:
                Scr.MouseUp(uname, data.asInteger['x'],
                  data.asInteger['y'], mbRight);
              3:
                Scr.MouseUp(uname, data.asInteger['x'], data.asInteger['y'],
                  mbMiddle);
            end;
        finally
          CS.Release;
        end;
      end
      else if data.isType['w'] = rtc_Integer then
      begin
        CS.Acquire;
        try
          if assigned(Scr) then
            Scr.MouseWheel(data.asInteger['w']);
        finally
          CS.Release;
        end;
      end
      else
      begin
        CS.Acquire;
        try
          if assigned(Scr) then
            Scr.MouseMove(uname, data.asInteger['x'], data.asInteger['y']);
        finally
          CS.Release;
        end;
      end;
    end;
  end
  else if data.FunctionName = 'key' then
  begin
    if MayControlDesktop(uname) then
    begin
      if isSubscriber(uname) then
      begin
        MakeDesktopActive;
        CS.Acquire;
        try
          if assigned(Scr) then
          begin
            if data.isType['d'] = rtc_Integer then
              Scr.KeyDown(data.asInteger['d'], [])
            else if data.isType['u'] = rtc_Integer then
              Scr.KeyUp(data.asInteger['u'], [])
            else if data.isType['p'] = rtc_String then
              Scr.KeyPress(data.asString['p'], data.asInteger['k'])
            else if data.isType['p'] = rtc_WideString then
              Scr.KeyPressW(data.asWideString['p'], data.asInteger['k'])
            else if data.isType['lw'] = rtc_Integer then
              Scr.LWinKey(data.asInteger['lw'])
            else if data.isType['rw'] = rtc_Integer then
              Scr.RWinKey(data.asInteger['rw'])
            else if data.isType['s'] = rtc_String then
            begin
              Scr.SpecialKey(data.asString['s']);
              if data.asString['s'] = 'COPY' then
              begin
                if assigned(FileTransfer) then
                begin
                  // wait for Ctrl+C to be processed by the receiving app
                  Sleep(250);
                  // Clipboard has changed. Check if we have files in it and start sending them
                  MyFiles := Get_ClipboardFiles;
                  if assigned(MyFiles) then
                    try
                      for k := 0 to MyFiles.Count - 1 do
                        FileTransfer.Send(uname, MyFiles.asText[k]);
                    finally
                      MyFiles.Free;
                    end;
                end;
              end;
            end;
          end;
        finally
          CS.Release;
        end;
      end
      else
      begin
        MakeDesktopActive;
        CS.Acquire;
        try
          if data.isType['s'] = rtc_String then
            if data.asString['s'] = 'HDESK' then
              Hide_Wallpaper
            else if data.asString['s'] = 'SDESK' then
              Show_Wallpaper;
        finally
          CS.Release;
        end;
      end;
    end;
  end
  else if data.FunctionName = 'cbrd' then
  begin
    if MayControlDesktop(uname) and isSubscriber(uname) then
    begin
      MakeDesktopActive;
      // Clipboard data
      s := data.asString['s'];
      setClipboard(uname, s);
    end;
  end
  else if data.FunctionName = 'gcbrd' then
  begin
    if MayControlDesktop(uname) and isSubscriber(uname) then
    begin
      MakeDesktopActive;
      r := nil;
      // Clipboard request
      CS2.Acquire;
      try
        s := Get_Clipboard;
        if (Clipboards.isType[uname] = rtc_Null) or
          (s <> Clipboards.asString[uname]) then
        begin
          Put_Clipboard(s);
          s := Get_Clipboard;
          if (Clipboards.isType[uname] = rtc_Null) or
            (s <> Clipboards.asString[uname]) then
          begin
            if s = '' then
            begin
              Clipboards.asString[uname] := '';
              r := TRtcFunctionInfo.Create;
              r.FunctionName := 'cbrd';
              // r.asString['s']:='';
            end
            else
            begin
              Clipboards.asString[uname] := s;
              r := TRtcFunctionInfo.Create;
              r.FunctionName := 'cbrd';
              r.asString['s'] := s;
            end;
          end;
        end;
      finally
        CS2.Release;
      end;
      if assigned(r) then
        Client.SendToUser(Sender, uname, r);
    end;
  end
  else if (data.FunctionName = 'chgdesk') then
  begin
    if MayControlDesktop(uname) then
    begin
      ScrChanged := False;
      if (data.isType['color'] = rtc_Integer) and
        (GColorLimit <> TrdColorLimit(data.asInteger['color'])) then
      begin
        GColorLimit := TrdColorLimit(data.asInteger['color']);
        ScrChanged := True;
      end;
      if (data.isType['colorlow'] = rtc_Integer) and
        (GColorLowLimit <> TrdLowColorLimit(data.asInteger['colorlow'])) then
      begin
        GColorLowLimit := TrdLowColorLimit(data.asInteger['colorlow']);
        ScrChanged := True;
      end;
      if (data.isType['colorpercent'] = rtc_Integer) and
        (GColorReducePercent <> data.asInteger['colorpercent']) then
      begin
        GColorReducePercent := data.asInteger['colorpercent'];
        ScrChanged := True;
      end;
      if (data.isType['frame'] = rtc_Integer) and
        (GFrameRate <> TrdFrameRate(data.asInteger['frame'])) then
      begin
        GFrameRate := TrdFrameRate(data.asInteger['frame']);
        ScrChanged := True;
      end;
      if (data.isType['mirror'] = rtc_Boolean) and
        (GUseMirrorDriver <> data.asBoolean['mirror']) then
      begin
        GUseMirrorDriver := data.asBoolean['mirror'];
        ScrChanged := True;
      end;
      if (data.isType['mouse'] = rtc_Boolean) and
        (GUseMouseDriver <> data.asBoolean['mouse']) then
      begin
        GUseMouseDriver := data.asBoolean['mouse'];
        ScrChanged := True;
      end;
      if (data.isType['scrblocks'] = rtc_Integer) and
        (GSendScreenInBlocks <> TrdScreenBlocks(data.asInteger['scrblocks']))
      then
      begin
        GSendScreenInBlocks := TrdScreenBlocks(data.asInteger['scrblocks']);
        ScrChanged := True;
      end;
      if (data.isType['scrblocks2'] = rtc_Integer) and
        (GSendScreenRefineBlocks <> TrdScreenBlocks(data.asInteger
        ['scrblocks2'])) then
      begin
        GSendScreenRefineBlocks :=
          TrdScreenBlocks(data.asInteger['scrblocks2']);
        ScrChanged := True;
      end;
      if (data.isType['scr2delay'] = rtc_Integer) and
        (GSendScreenRefineDelay <> data.asInteger['scr2delay']) then
      begin
        GSendScreenRefineDelay := data.asInteger['scr2delay'];
        ScrChanged := True;
      end;
      if (data.isType['scrlimit'] = rtc_Integer) and
        (GSendScreenSizeLimit <> TrdScreenLimit(data.asInteger['scrlimit']))
      then
      begin
        GSendScreenSizeLimit := TrdScreenLimit(data.asInteger['scrlimit']);
        ScrChanged := True;
      end;
      if (data.isType['monitors'] = rtc_Boolean) and
        (GCaptureAllMonitors <> data.asBoolean['monitors']) then
      begin
        GCaptureAllMonitors := data.asBoolean['monitors'];
        ScrChanged := True;
      end;
      if (data.isType['layered'] = rtc_Boolean) and
        (GCaptureLayeredWindows <> data.asBoolean['layered']) then
      begin
        GCaptureLayeredWindows := data.asBoolean['layered'];
        ScrChanged := True;
      end;
      if ScrChanged then
        Restart;
    end;
  end
  // New "Desktop View" subscriber ...
  else if (data.FunctionName = 'desk') and (data.FieldCount = 0) then
  begin
    // allow subscriptions only if "CanViewDesktop" is enabled
    if MayViewDesktop(uname) then
      if Event_QueryAccess(Sender, uname) then
      begin
        if not assigned(_sub_desk) then
          _sub_desk := TRtcRecord.Create;
        _sub_desk.asBoolean[uname] := True;
      end;
  end;
end;

procedure TRtcPDesktopHost.Call_AfterData(Sender: TObject);
var
  a: integer;
  have_desktop: boolean;
  uname: String;

  procedure SendDesktop(full: boolean);
  var
    fn1, fn2: String;
    s1, s2: RtcString;
    fn: TRtcFunctionInfo;
  begin
    // New user for Desktop View
    fn := nil;

    CS.Acquire;
    try
      if assigned(Scr) and
        (full or ((getSubscriberCnt > 0) and Client.canSendNext)) then
      begin
        if not have_desktop then
        begin
          LastGrab := GetTickCount;
          Scr.GrabScreen;
          Scr.GrabMouse;
          have_desktop := True;
        end;

        if full then
        begin
          // Send Initial Full Screen to New subscribers
          s1 := Scr.GetScreen;
          s2 := Scr.GetMouse;
          fn1 := 'idesk';
          fn2 := 'init';
        end
        else
        begin
          // Send Screen Delta to already active subscribers
          s1 := Scr.GetScreenDelta;
          s2 := Scr.GetMouseDelta;
          fn1 := 'desk';
          fn2 := 'next';
        end;
      end;
    finally
      CS.Release;
    end;

    if s1 <> '' then
    begin
      fn := TRtcFunctionInfo.Create;
      fn.FunctionName := 'desk';
      fn.asString[fn2] := s1;
    end;
    if s2 <> '' then
    begin
      if not assigned(fn) then
      begin
        fn := TRtcFunctionInfo.Create;
        fn.FunctionName := 'desk';
      end;
      fn.asString['cur'] := s2;
    end;

    if assigned(fn) then
      Client.SendToMyGroup(Sender, fn1, fn);
  end;

begin
  have_desktop := False;
  try
    if assigned(_desksub) then
    begin
      MakeDesktopActive;

      // Send Delta screen
      SendDesktop(False);
      // Send initial screen
      SendDesktop(True);

      // Change temporary subscriptions to full subscriptions ...
      for a := 0 to _desksub.Count - 1 do
      begin
        uname := _desksub.asText[a];
        Client.AddUserToMyGroup(Sender, uname, 'desk');
        Client.RemoveUserFromMyGroup(Sender, uname, 'idesk');
      end;
    end;

    if assigned(_sub_desk) then
    begin
      for a := 0 to _sub_desk.Count - 1 do
      begin
        uname := _sub_desk.FieldName[a];
        Client.AddUserToMyGroup(Sender, uname, 'idesk');
      end;
    end;
  finally
    if assigned(_desksub) then
    begin
      _desksub.Free;
      _desksub := nil;
    end;
    if assigned(_sub_desk) then
    begin
      _sub_desk.Free;
      _sub_desk := nil;
    end;
  end;
end;

function TRtcPDesktopHost.SenderLoop_Check(Sender: TObject): boolean;
begin
  loop_needtosend := False;
  loop_need_restart := False;

  CS.Acquire;
  try
    Result := (getSubscriberCnt > 0) and assigned(Scr);
  finally
    CS.Release;
  end;
end;

procedure TRtcPDesktopHost.SenderLoop_Prepare(Sender: TObject);
var
  nowtime: longword;
begin
  CS.Acquire;
  try
    if (getSubscriberCnt > 0) and assigned(Scr) then
    begin
      SwitchToActiveDesktop;

      loop_needtosend := True;

      loop_s1 := '';
      loop_s2 := '';

      loop_need_restart := RestartRequested;
      RestartRequested := False;

      nowtime := GetTickCount;
      if LastGrab > 0 then
        if FrameSleep > 0 then
          Sleep(FrameSleep)
        else if (FramePause > 0) and (FramePause > nowtime - LastGrab) then
          Sleep(FramePause - (nowtime - LastGrab));

      LastGrab := GetTickCount;
      Scr.GrabScreen;
      loop_s1 := Scr.GetScreenDelta;

      Scr.GrabMouse;
      loop_s2 := Scr.GetMouseDelta;
    end;
  finally
    CS.Release;
  end;
end;

procedure TRtcPDesktopHost.SenderLoop_Execute(Sender: TObject);
var
  fn: TRtcFunctionInfo;
begin
  fn := nil;

  if loop_needtosend then
  begin
    if loop_s1 <> '' then
    begin
      fn := TRtcFunctionInfo.Create;
      fn.FunctionName := 'desk';
      fn.asString['next'] := loop_s1;
    end;
    if loop_s2 <> '' then
    begin
      if not assigned(fn) then
      begin
        fn := TRtcFunctionInfo.Create;
        fn.FunctionName := 'desk';
      end;
      fn.asString['cur'] := loop_s2;
    end;

    if assigned(fn) then
      Client.SendToMyGroup(Sender, 'desk', fn)
    else
      Client.SendPing(Sender);

    if loop_need_restart then
    begin
      ScrStop;
      ScrStart;
    end;
  end;
end;

function TRtcPDesktopHost.GetLastMouseUser: String;
begin
  CS2.Acquire;
  try
    Result := FLastMouseUser;
  finally
    CS2.Release;
  end;
end;

function TRtcPDesktopHost.setDeskSubscriber(const username: String;
  active: boolean): boolean;
begin
  Result := setSubscriber(username, active);
  CS.Acquire;
  try
    if Result and assigned(Scr) and not active and (getSubscriberCnt = 0) then
      Scr.Clear;
  finally
    CS.Release;
  end;
end;

procedure TRtcPDesktopHost.setClipboard(const username: String;
  const data: RtcString);
begin
  CS2.Acquire;
  try
    Clipboards.asString[username] := data;
    Put_Clipboard(data);
  finally
    CS2.Release;
  end;
end;

procedure TRtcPDesktopHost.SetAllowView(const Value: boolean);
begin
  if Value <> FAllowView then
  begin
    if FGatewayParams and assigned(Client) then
      Client.ParamSet(nil, 'NoViewDesktop', TRtcBooleanValue.Create(not Value));
    FAllowView := Value;
  end;
end;

function TRtcPDesktopHost.GetAllowView: boolean;
begin
  Result := FAllowView;
end;

procedure TRtcPDesktopHost.SetAllowControl(const Value: boolean);
begin
  if Value <> FAllowControl then
  begin
    if FGatewayParams and assigned(Client) then
      Client.ParamSet(nil, 'NoControlDesktop',
        TRtcBooleanValue.Create(not Value));
    FAllowControl := Value;
  end;
end;

function TRtcPDesktopHost.GetAllowControl: boolean;
begin
  Result := FAllowControl;
end;

procedure TRtcPDesktopHost.SetAllowSuperView(const Value: boolean);
begin
  if Value <> FAllowSuperView then
  begin
    if FGatewayParams and assigned(Client) then
      Client.ParamSet(nil, 'NoSuperViewDesktop',
        TRtcBooleanValue.Create(not Value));
    FAllowSuperView := Value;
  end;
end;

function TRtcPDesktopHost.GetAllowSuperView: boolean;
begin
  Result := FAllowSuperView;
end;

procedure TRtcPDesktopHost.SetAllowSuperControl(const Value: boolean);
begin
  if Value <> FAllowSuperControl then
  begin
    if FGatewayParams and assigned(Client) then
      Client.ParamSet(nil, 'NoSuperControlDesktop',
        TRtcBooleanValue.Create(not Value));
    FAllowSuperControl := Value;
  end;
end;

function TRtcPDesktopHost.GetAllowSuperControl: boolean;
begin
  Result := FAllowSuperControl;
end;

procedure TRtcPDesktopHost.SetUseMirrorDriver(const Value: boolean);
begin
  if Value <> FUseMirrorDriver then
  begin
    if FGatewayParams and assigned(Client) then
      Client.ParamSet(nil, 'MirrorDriver', TRtcBooleanValue.Create(Value));
    FUseMirrorDriver := Value;
  end;
end;

procedure TRtcPDesktopHost.SetUseMouseDriver(const Value: boolean);
begin
  if Value <> FUseMouseDriver then
  begin
    if FGatewayParams and assigned(Client) then
      Client.ParamSet(nil, 'MouseDriver', TRtcBooleanValue.Create(Value));
    FUseMouseDriver := Value;
  end;
end;

procedure TRtcPDesktopHost.SetCaptureAllMonitors(const Value: boolean);
begin
  if Value <> FCaptureAllMonitors then
  begin
    if FGatewayParams and assigned(Client) then
      Client.ParamSet(nil, 'AllMonitors', TRtcBooleanValue.Create(Value));
    FCaptureAllMonitors := Value;
  end;
end;

procedure TRtcPDesktopHost.SetCaptureLayeredWindows(const Value: boolean);
begin
  if Value <> FCaptureLayeredWindows then
  begin
    if FGatewayParams and assigned(Client) then
      Client.ParamSet(nil, 'LayeredWindows', TRtcBooleanValue.Create(Value));
    FCaptureLayeredWindows := Value;
  end;
end;

function TRtcPDesktopHost.GetUseMirrorDriver: boolean;
begin
  Result := FUseMirrorDriver;
end;

function TRtcPDesktopHost.GetUseMouseDriver: boolean;
begin
  Result := FUseMouseDriver;
end;

function TRtcPDesktopHost.GetCaptureAllMonitors: boolean;
begin
  Result := FCaptureAllMonitors;
end;

function TRtcPDesktopHost.GetCaptureLayeredWindows: boolean;
begin
  Result := FCaptureLayeredWindows;
end;

procedure TRtcPDesktopHost.SetSendScreenInBlocks(const Value: TrdScreenBlocks);
begin
  if Value <> FScreenInBlocks then
  begin
    if FGatewayParams and assigned(Client) then
      Client.ParamSet(nil, 'ScreenBlocks', TRtcIntegerValue.Create(Ord(Value)));
    FScreenInBlocks := Value;
  end;
end;

function TRtcPDesktopHost.GetSendScreenInBlocks: TrdScreenBlocks;
begin
  Result := FScreenInBlocks;
end;

procedure TRtcPDesktopHost.SetSendScreenRefineBlocks
  (const Value: TrdScreenBlocks);
begin
  if Value <> FScreenRefineBlocks then
  begin
    if FGatewayParams and assigned(Client) then
      Client.ParamSet(nil, 'ScreenBlocks2',
        TRtcIntegerValue.Create(Ord(Value)));
    FScreenRefineBlocks := Value;
  end;
end;

function TRtcPDesktopHost.GetSendScreenRefineBlocks: TrdScreenBlocks;
begin
  Result := FScreenRefineBlocks;
end;

procedure TRtcPDesktopHost.SetSendScreenRefineDelay(const Value: integer);
begin
  if Value <> FScreenRefineDelay then
  begin
    if FGatewayParams and assigned(Client) then
      Client.ParamSet(nil, 'Screen2Delay', TRtcIntegerValue.Create(Value));
    FScreenRefineDelay := Value;
  end;
end;

function TRtcPDesktopHost.GetSendScreenRefineDelay: integer;
begin
  Result := FScreenRefineDelay;
end;

procedure TRtcPDesktopHost.SetSendScreenSizeLimit(const Value: TrdScreenLimit);
begin
  if Value <> FScreenSizeLimit then
  begin
    if FGatewayParams and assigned(Client) then
      Client.ParamSet(nil, 'ScreenLimit', TRtcIntegerValue.Create(Ord(Value)));
    FScreenSizeLimit := Value;
  end;
end;

function TRtcPDesktopHost.GetSendScreenSizeLimit: TrdScreenLimit;
begin
  Result := FScreenSizeLimit;
end;

procedure TRtcPDesktopHost.SetShowFullScreen(const Value: boolean);
begin
  if Value <> FShowFullScreen then
  begin
    if FGatewayParams and assigned(Client) then
      Client.ParamSet(nil, 'ScreenRegion', TRtcBooleanValue.Create(not Value));
    FShowFullScreen := Value;
  end;
end;

function TRtcPDesktopHost.GetShowFullScreen: boolean;
begin
  Result := FShowFullScreen;
end;

procedure TRtcPDesktopHost.SetColorLimit(const Value: TrdColorLimit);
begin
  if Value <> FColorLimit then
  begin
    if FGatewayParams and assigned(Client) then
      Client.ParamSet(nil, 'ColorLimit', TRtcIntegerValue.Create(Ord(Value)));
    FColorLimit := Value;
  end;
end;

function TRtcPDesktopHost.GetColorLimit: TrdColorLimit;
begin
  Result := FColorLimit;
end;

procedure TRtcPDesktopHost.SetColorReducePercent(const Value: integer);
begin
  if Value <> FColorReducePercent then
  begin
    if FGatewayParams and assigned(Client) then
      Client.ParamSet(nil, 'ColorReducePercent',
        TRtcIntegerValue.Create(Ord(Value)));
    FColorReducePercent := Value;
  end;
end;

function TRtcPDesktopHost.GetColorReducePercent: integer;
begin
  Result := FColorReducePercent;
end;

procedure TRtcPDesktopHost.SetLowColorLimit(const Value: TrdLowColorLimit);
begin
  if Value <> FLowColorLimit then
  begin
    if FGatewayParams and assigned(Client) then
      Client.ParamSet(nil, 'LowColorLimit',
        TRtcIntegerValue.Create(Ord(Value)));
    FLowColorLimit := Value;
  end;
end;

function TRtcPDesktopHost.GetLowColorLimit: TrdLowColorLimit;
begin
  Result := FLowColorLimit;
end;

procedure TRtcPDesktopHost.SetFrameRate(const Value: TrdFrameRate);
begin
  if Value <> FFrameRate then
  begin
    if FGatewayParams and assigned(Client) then
      Client.ParamSet(nil, 'FrameRate', TRtcIntegerValue.Create(Ord(Value)));
    FFrameRate := Value;
  end;
end;

function TRtcPDesktopHost.GetFrameRate: TrdFrameRate;
begin
  Result := FFrameRate;
end;

procedure TRtcPDesktopHost.ScrStart;
begin
  CS.Acquire;
  try
    if not assigned(Scr) and (FAllowView or FAllowControl or FAllowSuperView or
      FAllowSuperControl) then
    begin
      LastGrab := 0;
      FrameSleep := 0;
      FramePause := 0;
      case FFrameRate of
        rdFrames50:
          FramePause := 1000 div 50;
        rdFrames40:
          FramePause := 1000 div 40;
        rdFrames25:
          FramePause := 1000 div 25;
        rdFrames20:
          FramePause := 1000 div 20;
        rdFrames10:
          FramePause := 1000 div 10;
        rdFrames8:
          FramePause := 1000 div 8;
        rdFrames5:
          FramePause := 1000 div 5;
        rdFrames4:
          FramePause := 1000 div 4;
        rdFrames2:
          FramePause := 1000 div 2;
        rdFrames1:
          FramePause := 1000 div 1;

        rdFrameSleep500:
          FrameSleep := 500;
        rdFrameSleep400:
          FrameSleep := 400;
        rdFrameSleep250:
          FrameSleep := 250;
        rdFrameSleep200:
          FrameSleep := 200;
        rdFrameSleep100:
          FrameSleep := 100;
        rdFrameSleep80:
          FrameSleep := 80;
        rdFrameSleep50:
          FrameSleep := 50;
        rdFrameSleep40:
          FrameSleep := 40;
        rdFrameSleep20:
          FrameSleep := 20;
        rdFrameSleep10:
          FrameSleep := 10;

      else
        FramePause := 16; // Max = 59 FPS
      end;

      Scr := TRtcScreenCapture.Create;
      case FColorLimit of
        rdColor4bit:
          begin
            Scr.BPPLimit := 0;
            Scr.Reduce16bit := $8E308E30; // 6bit
            Scr.Reduce32bit := $00C0C0C0; // 6bit
          end;
        rdColor6bit:
          begin
            Scr.Reduce16bit := $8E308E30; // 6bit
            Scr.Reduce32bit := $00C0C0C0; // 6bit
          end;
        rdColor8bit:
          begin
            Scr.BPPLimit := 1;
            Scr.Reduce16bit := $CF38CF38; // 9bit
            Scr.Reduce32bit := $00E0E0E0; // 9bit
          end;
        rdColor9bit:
          begin
            Scr.Reduce16bit := $CF38CF38; // 9bit
            Scr.Reduce32bit := $00E0E0E0; // 9bit
          end;
        rdColor12bit:
          begin
            Scr.Reduce16bit := $EFBCEFBC; // 12bit
            Scr.Reduce32bit := $00F0F0F0; // 12bit
          end;
        rdColor15bit:
          begin
            Scr.Reduce16bit := $FFF0FFF0; // 15bit
            Scr.Reduce32bit := $00F8F8F8; // 15bit
          end;
        rdColor16bit:
          begin
            Scr.BPPLimit := 2;
            Scr.Reduce32bit := $80F8F8F8; // 16bit
          end;
        rdColor18bit:
          begin
            Scr.Reduce32bit := $00FCFCFC; // 18bit
          end;
        rdColor21bit:
          begin
            Scr.Reduce32bit := $00FEFEFE; // 21bit
          end;
      end;

      case FLowColorLimit of
        rd_Color6bit, rd_ColorHigh6bit:
          begin
            Scr.LowReduce16bit := $8E308E30; // 6bit
            Scr.LowReduce32bit := $00C0C0C0; // 6bit
          end;
        rd_Color9bit, rd_ColorHigh9bit:
          begin
            Scr.LowReduce16bit := $CF38CF38; // 9bit
            Scr.LowReduce32bit := $00E0E0E0; // 9bit
          end;
        rd_Color12bit, rd_ColorHigh12bit:
          begin
            Scr.LowReduce16bit := $EFBCEFBC; // 12bit
            Scr.LowReduce32bit := $00F0F0F0; // 12bit
          end;
        rd_Color15bit, rd_ColorHigh15bit:
          begin
            Scr.LowReduce16bit := $FFF0FFF0; // 15bit
            Scr.LowReduce32bit := $00F8F8F8; // 15bit
          end;
        rd_Color18bit, rd_ColorHigh18bit:
          begin
            Scr.LowReduce32bit := $00FCFCFC; // 18bit
          end;
        rd_Color21bit, rd_ColorHigh21bit:
          begin
            Scr.LowReduce32bit := $00FEFEFE; // 21bit
          end;
      end;

      if FLowColorLimit < rd_ColorHigh6bit then
        Scr.LowReduceType := 0
      else
        Scr.LowReduceType := 1;

      if (Scr.Reduce32bit > 0) and (Scr.LowReduce32bit > 0) then
        Scr.LowReducedColors := Scr.LowReduce32bit < Scr.Reduce32bit
      else
        Scr.LowReducedColors := Scr.LowReduce32bit > 0;
      Scr.LowReduceColorPercent := GColorReducePercent;

      Scr.LayeredWindows := FCaptureLayeredWindows;

      case FScreenInBlocks of
        rdBlocks1:
          Scr.ScreenBlockCount := 1;
        rdBlocks2:
          Scr.ScreenBlockCount := 2;
        rdBlocks3:
          Scr.ScreenBlockCount := 3;
        rdBlocks4:
          Scr.ScreenBlockCount := 4;
        rdBlocks5:
          Scr.ScreenBlockCount := 5;
        rdBlocks6:
          Scr.ScreenBlockCount := 6;
        rdBlocks7:
          Scr.ScreenBlockCount := 7;
        rdBlocks8:
          Scr.ScreenBlockCount := 8;
        rdBlocks9:
          Scr.ScreenBlockCount := 9;
        rdBlocks10:
          Scr.ScreenBlockCount := 10;
        rdBlocks11:
          Scr.ScreenBlockCount := 11;
        rdBlocks12:
          Scr.ScreenBlockCount := 12;
      end;

      case FScreenRefineBlocks of
        rdBlocks1:
          begin
            Scr.Screen2BlockCount := Scr.ScreenBlockCount * 2;
            if Scr.Screen2BlockCount < 4 then
              Scr.Screen2BlockCount := 4
            else if Scr.Screen2BlockCount > 12 then
              Scr.Screen2BlockCount := 12;
          end;
        rdBlocks2:
          Scr.Screen2BlockCount := 2;
        rdBlocks3:
          Scr.Screen2BlockCount := 3;
        rdBlocks4:
          Scr.Screen2BlockCount := 4;
        rdBlocks5:
          Scr.Screen2BlockCount := 5;
        rdBlocks6:
          Scr.Screen2BlockCount := 6;
        rdBlocks7:
          Scr.Screen2BlockCount := 7;
        rdBlocks8:
          Scr.Screen2BlockCount := 8;
        rdBlocks9:
          Scr.Screen2BlockCount := 9;
        rdBlocks10:
          Scr.Screen2BlockCount := 10;
        rdBlocks11:
          Scr.Screen2BlockCount := 11;
        rdBlocks12:
          Scr.Screen2BlockCount := 12;
      end;

      case FScreenSizeLimit of
        rdBlock1KB:
          Scr.MaxTotalSize := 1024;
        rdBlock2KB:
          Scr.MaxTotalSize := 1024 * 2;
        rdBlock4KB:
          Scr.MaxTotalSize := 1024 * 4;
        rdBlock8KB:
          Scr.MaxTotalSize := 1024 * 8;
        rdBlock12KB:
          Scr.MaxTotalSize := 1024 * 12;
        rdBlock16KB:
          Scr.MaxTotalSize := 1024 * 16;
        rdBlock24KB:
          Scr.MaxTotalSize := 1024 * 24;
        rdBlock32KB:
          Scr.MaxTotalSize := 1024 * 32;
        rdBlock48KB:
          Scr.MaxTotalSize := 1024 * 48;
        rdBlock64KB:
          Scr.MaxTotalSize := 1024 * 64;
        rdBlock96KB:
          Scr.MaxTotalSize := 1024 * 96;
        rdBlock128KB:
          Scr.MaxTotalSize := 1024 * 128;
        rdBlock192KB:
          Scr.MaxTotalSize := 1024 * 192;
        rdBlock256KB:
          Scr.MaxTotalSize := 1024 * 256;
        rdBlock384KB:
          Scr.MaxTotalSize := 1024 * 384;
        rdBlock512KB:
          Scr.MaxTotalSize := 1024 * 512;
      end;

      if FScreenRefineDelay < 0 then
        Scr.Screen2Delay := 0
      else if FScreenRefineDelay = 0 then
        Scr.Screen2Delay := 500
      else
        Scr.Screen2Delay := FScreenRefineDelay * 1000;

      if FShowFullScreen then
        Scr.FullScreen := True
      else
        Scr.FixedRegion := FScreenRect;

      Scr.MouseDriver := FUseMouseDriver;
      Scr.MultiMonitor := FCaptureAllMonitors;

      // Always set the "MirageDriver" property at the end ...
      Scr.MirageDriver := FUseMirrorDriver;
    end;
  finally
    CS.Release;
  end;
end;

procedure TRtcPDesktopHost.ScrStop;
begin
  CS.Acquire;
  try
    if assigned(Scr) then
    begin
      Scr.Free;
      Scr := nil;
    end;
  finally
    CS.Release;
  end;
end;

procedure TRtcPDesktopHost.Restart;
begin
  CS.Acquire;
  try
    if getSubscriberCnt = 0 then
    begin
      ScrStop;
      ScrStart;
    end
    else
      RestartRequested := True;
  finally
    CS.Release;
  end;
  // if assigned(FOnStartHost) then FOnStartHost;
end;

procedure TRtcPDesktopHost.SetFileTrans(const Value: TRtcPFileTransfer);
begin
  if Value <> FFileTrans then
  begin
    if assigned(FFileTrans) then
      FFileTrans.RemModule(self);
    FFileTrans := Value;
    if assigned(FFileTrans) then
      FFileTrans.AddModule(self);
  end;
end;

procedure TRtcPDesktopHost.UnlinkModule(const Module: TRtcPModule);
begin
  if Module = FFileTrans then
    FileTransfer := nil;
  inherited;
end;

procedure TRtcPDesktopHost.CloseAll(Sender: TObject);
begin
  Client.DisbandMyGroup(Sender, 'desk');
end;

procedure TRtcPDesktopHost.Close(const uname: String; Sender: TObject);
begin
  Client.RemoveUserFromMyGroup(Sender, uname, 'desk');
end;

procedure TRtcPDesktopHost.Open(const uname: String; Sender: TObject);
begin
  Client.AddUserToMyGroup(Sender, uname, 'idesk');
end;

function TRtcPDesktopHost.MirrorDriverInstalled(Init: boolean = False): boolean;
var
  s: TRtcScreenCapture;
begin
  CS.Acquire;
  try
    if assigned(Scr) then
      Result := Scr.MirageDriverInstalled(Init)
    else
    begin
      s := TRtcScreenCapture.Create;
      try
        Result := s.MirageDriverInstalled(Init);
      finally
        s.Free;
      end;
    end;
  finally
    CS.Release;
  end;
end;

end.
