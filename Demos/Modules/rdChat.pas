{ Copyright (c) RealThinClient components
  - http://www.realthinclient.com }

unit rdChat;

interface

{$INCLUDE rtcDefs.inc}

uses
  Windows, Messages, SysUtils,
  Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Clipbrd,

  ShellAPI,

  rtcInfo, Buttons, Menus,

  rtcpFileTrans,
  rtcpDesktopControl,
  rtcpChat, rtcpChatUI, rtcPortalMod;

const
  RTC_CHAT_MAXDISPLAY:integer=2048;

type
  TChatMsgType = (RTC_MSG_SELF, RTC_MSG_FRIEND,
                  RTC_MSG_LOGIN, RTC_MSG_LOGOUT, RTC_MSG_ERROR);

  TRdUserChatField=class(TPanel)
  private
    FNamePanel:TPanel;
    FNameLabel:TLabel;

    FTextPanel:TPanel;
    FTextLabel:TLabel;
    FTextLabel2:TLabel;

    FUser: String;
    FText, FText2: String;
    FCursor: String;
    FTitleColor: TColor;
    FPrefix: string;
    FBackColor: TColor;

    procedure SetText(const Value: String);
    procedure SetUser(const Value: String);
    procedure SetCursor(const Value: string);
    procedure SetTitleColor(const Value: TColor);
    procedure SetPrefix(const Value: string);
    procedure SetBackColor(const Value: TColor);

  public
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;

    procedure UpdateEvents(MouseUp:TMouseEvent);

    procedure UpdateSize;

    procedure NewLine;

    property User:String read FUser write SetUser;

    property Text:String read FText write SetText;
    property Prefix:string read FPrefix write SetPrefix;
    property Cursor:string read FCursor write SetCursor;
    property TitleColor:TColor read FTitleColor write SetTitleColor;
    property BackColor:TColor read FBackColor write SetBackColor;
    end;

  TrdChatForm = class(TForm)
    pMain: TPanel;
    pSplit: TSplitter;
    pBox: TScrollBox;
    mChatLog: TRichEdit;
    pTitle: TPanel;
    cTitle: TLabel;
    Panel2: TPanel;
    btnClose: TSpeedButton;
    btnMinimize: TSpeedButton;
    btnOnTop: TSpeedButton;
    myBox: TPanel;
    pTimer: TTimer;
    Panel3: TPanel;
    pRight: TPanel;
    pBottom: TPanel;
    pSize2: TPanel;
    pSize1: TPanel;
    pLeft: TPanel;
    pTop: TPanel;
    pSize4: TPanel;
    pSize3: TPanel;
    Panel12: TPanel;
    btnLockChatBoxes: TSpeedButton;
    btnClearHistory: TSpeedButton;
    btnHideHistory: TSpeedButton;
    btnDesktop: TSpeedButton;
    btnHideTyping: TSpeedButton;
    CopyPastePopupMenu: TPopupMenu;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    HistoryPopupMenu: TPopupMenu;
    miSaveHistory: TMenuItem;
    miLoadHistory: TMenuItem;
    dlgSaveHistory: TSaveDialog;
    dlgLoadHistory: TOpenDialog;
    miCopyHistory: TMenuItem;
    myUI: TRtcPChatUI;

    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnMinimizeClick(Sender: TObject);
    procedure pTitleMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure pTitleMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure pTitleMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure btnOnTopClick(Sender: TObject);
    procedure pTimerTimer(Sender: TObject);
    procedure Panel3MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Panel3MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure Panel3MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure btnLockChatBoxesClick(Sender: TObject);
    procedure btnHideHistoryClick(Sender: TObject);
    procedure btnClearHistoryClick(Sender: TObject);
    procedure btnDesktopClick(Sender: TObject);
    procedure btnHideTypingClick(Sender: TObject);
    procedure CopyPasteMouseEvent(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Copy1Click(Sender: TObject);
    procedure Paste1Click(Sender: TObject);
    procedure miSaveHistoryClick(Sender: TObject);
    procedure miLoadHistoryClick(Sender: TObject);
    procedure miCopyHistoryClick(Sender: TObject);

    procedure myUIUserJoined(Sender: TRtcPChatUI);
    procedure myUIUserLeft(Sender: TRtcPChatUI);
    procedure myUIMessage(Sender: TRtcPChatUI);
    procedure myUIError(Sender: TRtcPChatUI);
    procedure myUIInit(Sender: TRtcPChatUI);
    procedure myUILogOut(Sender: TRtcPChatUI);
    procedure myUIOpen(Sender: TRtcPChatUI);
    procedure myUIClose(Sender: TRtcPChatUI);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);

  protected
    { Private declarations }
    FReady:boolean;
    
    FMe:TrdUserChatField;
    FLastUser: string;
    FLastColor:integer;
    FOtherCnt:integer;
    FOthers:TRtcInfo;

    FOnTop:boolean;
    FLockBoxes:boolean;
    FHideTyping:boolean;
    FHideHistory:boolean;

    function TopLoc(const user:string):integer;
    procedure UpdateAllSizes;
    function NextFreeColor:TColor;

    procedure AddMessage(const uname, text: string; msgType:TChatMsgType; Color:TColor);
    procedure AddUser(const uname:string);
    procedure RemUser(const uname:string);

    procedure Open_Form(const mode:string);
    procedure Close_Form(const mode:string);

    procedure CreateParams(Var params: TCreateParams); override;

    {$IFNDEF RtcViewer}
    // declare our DROPFILES message handler
    procedure AcceptFiles( var msg : TMessage ); message WM_DROPFILES;
    {$ENDIF}

  public
    PFileTrans:TRtcPFileTransfer;
    PDesktopControl:TRtcPDesktopControl;

    procedure NotOnTop;

    property UI:TRtcPChatUI read myUI;
  end;

implementation

{$R *.dfm}

var
  CChatFriendName:TColor = clGray;
  CChatMyName:TColor     = clGray;
  CChatSystem:TColor     = clRed;
  CChatLogin:TColor      = clGreen;
  CChatLogout:TColor     = clMaroon;

{ TRdUserChatField }

constructor TRdUserChatField.Create(AOwner: TComponent);
  begin
  inherited;

  FUser:='';
  FText:='';
  FText2:='';
  FCursor:='';
  FPrefix:='';

  FTitleColor:=clGray;
  FBackColor:=clWhite;

  FNamePanel := TPanel.Create(nil);
  with FNamePanel do
    begin
    Parent := self;
    Align := alTop;
    BorderWidth := 2;

    ParentColor := False;
    Color:= FTitleColor;
    end;

  FNameLabel := TLabel.Create(nil);
  with FNameLabel do
    begin
    Parent := FNamePanel;
    Align := alTop;
    Font.Size := 10;

    ParentColor := False;
    ParentFont := False;
    Transparent := False;

    Color := FTitleColor;
    Font.Color := clWhite;

    WordWrap:=False;
    Caption:= 'NameLabel';
    end;

  FTextPanel := TPanel.Create(nil);
  with FTextPanel do
    begin
    Parent := self;
    Align := alTop;
    BorderWidth := 4;

    ParentColor := False;
    ParentFont := False;
    Color := FBackColor;

    BevelOuter := bvLowered;
    end;

  FTextLabel2:= TLabel.Create(nil);
  with FTextLabel2 do
    begin
    Visible:=False;

    Parent := FTextPanel;
    Align := alTop;

    Font.Size := 10;

    ParentColor := False;
    ParentFont := False;
    Transparent := False;

    Color := FBackColor;
    Font.Color := clBlack;

    WordWrap := True;
    end;

  FTextLabel:= TLabel.Create(nil);
  with FTextLabel do
    begin
    Parent := FTextPanel;
    Align := alTop;

    Font.Size := 10;

    ParentColor := False;
    ParentFont := False;
    Transparent := False;

    Color := FBackColor;
    Font.Color := clBlack;

    WordWrap := True;
    end;
  end;

destructor TRdUserChatField.Destroy;
  begin
  FNameLabel.Free;
  FTextLabel.Free;
  FTextLabel2.Free;
  FNamePanel.Free;
  FTextPanel.Free;
  inherited;
  end;

procedure TRdUserChatField.UpdateEvents(MouseUp:TMouseEvent);
  begin
  FTextLabel2.OnMouseUp := MouseUp;
  FTextLabel.OnMouseUp := MouseUp;
  end;

procedure TRdUserChatField.NewLine;
  begin
  FText2:=FText;
  FText:='';
  if FText2<>'' then
    begin
    if not FTextLabel2.Visible then
      begin
      FTextLabel2.AutoSize:=False;
      FTextLabel2.Align:=alTop;
      FTextLabel2.Top:=0;
      FTextLabel2.Caption:=FText2;
      FTextLabel2.Visible:=True;
      FTextLabel2.AutoSize:=True;
      end
    else
      FTextLabel2.Caption:=FText2;
    FTextLabel.Caption:=FPrefix+FText+FCursor;
    end
  else
    begin
    FTextLabel2.Visible:=False;
    FTextLabel.Caption:=FPrefix+FText+FCursor;
    end;
  end;

procedure TRdUserChatField.SetCursor(const Value: string);
  begin
  FCursor := Value;
  FTextLabel.Caption:=FPrefix+FText+FCursor;
  end;

procedure TRdUserChatField.SetPrefix(const Value: string);
  begin
  FPrefix := Value;
  FTextLabel.Caption:=FPrefix+FText+FCursor;
  end;

procedure TRdUserChatField.SetText(const Value: String);
  begin
  FText := Value;
  FTextLabel.Caption:=FPrefix+FText+FCursor;
  end;

procedure TRdUserChatField.SetTitleColor(const Value: TColor);
  begin
  FTitleColor := Value;
  FNamePanel.Color := FTitleColor;
  FNameLabel.Color := FTitleColor;
  FTextLabel2.Font.Color := FTitleColor;
  end;

procedure TRdUserChatField.SetBackColor(const Value: TColor);
  begin
  FBackColor := Value;
  FTextPanel.Color := FBackColor;
  FTextLabel.Color := FBackColor;
  FTextLabel2.Color := FBackColor;
  end;

procedure TRdUserChatField.SetUser(const Value: String);
  begin
  FUser := Value;
  FNameLabel.Caption:=FUser;
  end;

procedure TRdUserChatField.UpdateSize;
  begin
  FTextLabel2.Font.Color:=FTitleColor;
  FTextLabel2.Color:=FBackColor;

  FTextLabel.Font.Color:=clBlack;
  FTextLabel.Color:=FBackColor;

  FNameLabel.Font.Color:=clWhite;
  FNameLabel.Color:=FTitleColor;

  FTextLabel2.AutoSize:=False;
  FTextLabel2.AutoSize:=True;

  FTextLabel.AutoSize:=False;
  FTextLabel.AutoSize:=True;

  FTextPanel.AutoSize:=False;
  FTextPanel.AutoSize:=True;

  FNameLabel.AutoSize:=False;
  FNameLabel.AutoSize:=True;

  FNamePanel.AutoSize:=False;
  FNamePanel.AutoSize:=True;

  AutoSize:=False;
  AutoSize:=True;
  end;

{ TrdChatForm }

{$IFNDEF RtcViewer}
procedure TrdChatForm.AcceptFiles( var msg : TMessage );
  const
    cnMaxFileNameLen = 1024;
  var
    i,
    nCount     : integer;
    acFileName : array [0..cnMaxFileNameLen] of char;
    myFileName : string;
  begin
  // find out how many files we're accepting
  nCount := DragQueryFile( msg.WParam,
                           $FFFFFFFF,
                           acFileName,
                           cnMaxFileNameLen );

  try
    // query Windows one at a time for the file name
    for i := 0 to nCount-1 do
      begin
      DragQueryFile( msg.WParam, i, acFileName, cnMaxFileNameLen );

      if assigned(PFileTrans) then
        begin
        myFileName:=acFileName;
        PFileTrans.Send(myUI.UserName, myFileName);
        end;
      end;
  finally
    // let Windows know that you're done
    DragFinish( msg.WParam );
    end;
  end;
{$ENDIF}

procedure TrdChatForm.CreateParams(Var params: TCreateParams);
  begin
  inherited CreateParams( params );
  params.ExStyle := params.ExStyle or WS_EX_APPWINDOW;
  params.WndParent := GetDeskTopWindow;
  end;

procedure TrdChatForm.FormCreate(Sender: TObject);
  begin
  FReady:=False;

  FOnTop:=False;
  FLockBoxes:=False;
  FHideTyping:=False;
  FHideHistory:=False;

  FOthers:=nil;
  FOtherCnt:=0;
  pTimer.Enabled:=False;

  // This is absolutely needed! Without this, the RichEdit won't scroll
  // to the end automatically! Don't ask me why though...
  mChatLog.HideSelection   := False;
  mChatLog.HideScrollBars  := True;
  end;

function TrdChatForm.TopLoc(const user:string): integer;
  var
    a:integer;
    xTop:integer;
    uname:string;
    pan:TRdUserChatField;
  begin
  xTop:=MaxLongint;
  if assigned(FOthers) then
    for a:=FOthers.FieldCount-1 downto 0 do
      begin
      uname:=FOthers.FieldName[a];
      if (uname<>user) and FOthers.asBoolean[uname] then
        begin
        pan:=TRdUserChatField(FOthers.asPtr[uname]);
        if assigned(pan) then
          if length(pan.Text)=0 then
            if pan.Top<xTop then
              xTop:=pan.Top;
        end;
      end;
  Result:=xTop;
  end;

procedure TrdChatForm.FormKeyPress(Sender: TObject; var Key: Char);
  var
    s:string;
  begin
  if assigned(myUI.Module) and assigned(FMe) and assigned(FOthers) then
    begin
    if ActiveControl=mChatLog then
      myBox.SetFocus;

    if Key=^V then
      begin
      s:=Clipboard.asText;
      if Copy(s,length(s),1)=#10 then Delete(s,length(s),1);
      if Copy(s,length(s),1)=#13 then Delete(s,length(s),1);
      if s<>'' then
        begin
        if length(FMe.Text)>0 then
          begin
          AddMessage(myUI.Module.Client.LoginUsername, FMe.Text,RTC_MSG_SELF,clBlack);
          if FHideTyping then
            myUI.Send(FMe.Text);
          FMe.NewLine;
          end;
        { add one space if we are sending a single character from clipboard,
          to differentiate from the case where a user has pressed a key. }
        if length(s)=1 then
          s:=s+' ';
        if length(s)<=RTC_CHAT_MAXDISPLAY then
          FMe.Text:=s
        else
          FMe.Text:=Copy(s,1,RTC_CHAT_MAXDISPLAY)+' ...';
        FMe.NewLine;
        AddMessage(myUI.Module.Client.LoginUsername,s,RTC_MSG_SELF, clBlack);
        myUI.Send(s);
        end;
      end
    else if Key=#8 then
      begin
      if length(FMe.Text)>0 then
        begin
        FMe.Text:=Copy(FMe.Text,1,length(FMe.Text)-1);
        if not FHideTyping then
          myUI.Send(#8)
        else if length(FMe.Text)=0 then
          myUI.Send(#0); // clear "<typing a message ...>" text
        end;
      end
    else if Key=#13 then
      begin
      if length(FMe.Text)>0 then
        begin
        AddMessage(myUI.Module.Client.LoginUsername,FMe.Text,RTC_MSG_SELF, clBlack);
        if FHideTyping then
          myUI.Send(FMe.Text);
        end;
      FMe.NewLine;
      if not FHideTyping then
        myUI.Send(#13);
      end
    else if Key>=#32 then
      begin
      FMe.Text:=FMe.Text+Key;
      if not FHideTyping then
        myUI.Send(Key)
      else if length(FMe.Text)=1 then
        myUI.Send(#1); // send "<typing a message ...>" text
      end;
    end
  else
    MessageBeep(0);
  Key:=#0;
  end;

procedure TrdChatForm.FormResize(Sender: TObject);
  begin
  UpdateAllSizes;
  end;

procedure TrdChatForm.UpdateAllSizes;
  var
    a:integer;
    uname:string;
    pan:TRdUserChatField;
  begin
  if assigned(FMe) then
    FMe.UpdateSize;
  if assigned(FOthers) then
    for a:=0 to FOthers.FieldCount-1 do
      begin
      uname:=FOthers.FieldName[a];
      if FOthers.asBoolean[uname] then
        begin
        pan:=TRdUserChatField(FOthers.asPtr[uname]);
        if assigned(pan) then
          pan.UpdateSize;
        end;
      end;
  mChatLog.Refresh;
  end;

procedure TrdChatForm.AddMessage(const uname, text: string; msgType:TChatMsgType; Color:TColor);
  begin
  mChatLog.Lines.BeginUpdate;
  mChatLog.Paragraph.FirstIndent := 0;
  case msgType of
    RTC_MSG_SELF:
      begin
      if FLastUser<>uname then
        begin
        FLastUser:=uname;
        mChatLog.SelAttributes.Color:=CChatMyName;
        mChatLog.SelAttributes.Style:=[];
        mChatLog.Lines.Add(uname + ':');
        end;
      mChatLog.SelAttributes.Color:=Color;
      mChatLog.SelAttributes.Style:=[];
      mChatLog.Lines.Add('   '+text);
      end;
    RTC_MSG_FRIEND:
      begin
      if FLastUser<>uname then
        begin
        FLastUser:=uname;
        mChatLog.SelAttributes.Color:=CChatFriendName;
        mChatLog.SelAttributes.Style:=[];
        mChatLog.Lines.Add(uname + ':');
        end;
      mChatLog.SelAttributes.Color:=Color;
      mChatLog.SelAttributes.Style:=[fsBold];
      mChatLog.Lines.Add('   '+text);
      end;
    RTC_MSG_ERROR:
      begin
      FLastUser:='';
      mChatLog.SelAttributes.Color:=Color;
      mChatLog.SelAttributes.Style:=[fsBold];
      mChatLog.Lines.Add(uname + ' '+ text);
      click;
      end;
    RTC_MSG_LOGIN:
      begin
      FLastUser:='';
      mChatLog.SelAttributes.Color:=Color;
      mChatLog.SelAttributes.Style:=[];
      mChatLog.Lines.Add(uname +' '+ text);
      end;
    RTC_MSG_LOGOUT:
      begin
      FLastUser:='';
      mChatLog.SelAttributes.Color:=Color;
      mChatLog.SelAttributes.Style:=[];
      mChatLog.Lines.Add(uname +' '+ text);
      end;
    end;
  mChatLog.Lines.EndUpdate;
  end;

procedure TrdChatForm.FormClose(Sender: TObject; var Action: TCloseAction);
  begin
  Action:=caFree;
  end;

procedure TrdChatForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  begin
  CanClose:=myUI.CloseAndClear;
  end;

procedure TrdChatForm.myUILogOut(Sender: TRtcPChatUI);
  begin
  Close;
  end;

procedure TrdChatForm.FormDestroy(Sender: TObject);
  begin
  pTimer.Enabled:=False;
  if assigned(FOthers) then
    begin
    FOthers.Free;
    FOthers:=nil;
    end;
  end;

function TrdChatForm.NextFreeColor: TColor;
  begin
  case FLastColor of
    0:Result:=clMaroon;
    1:Result:=clNavy;
    2:Result:=clGreen;
    3:Result:=clPurple;
    else Result:=clTeal;
    end;
  Inc(FLastColor);
  if FLastColor>4 then FLastColor:=0;
  end;

procedure TrdChatForm.btnCloseClick(Sender: TObject);
  begin
  Close;
  end;

procedure TrdChatForm.btnMinimizeClick(Sender: TObject);
  begin
  WindowState:=wsMinimized;
  end;

procedure TrdChatForm.btnOnTopClick(Sender: TObject);
begin
  FOnTop:=not FOnTop;
  if FOnTop then
    begin
    btnOnTop.Caption:='Normal';
    FormStyle:=fsStayonTop;
    end
  else
    begin
    FormStyle:=fsNormal;
    btnOnTop.Caption:='To Top';
    end;
  {$IFNDEF RtcViewer}
  if assigned(FOthers) then
    // tell Windows that you're
    // accepting drag and drop files
    DragAcceptFiles( Handle, True );
  {$ENDIF}
  end;

procedure TrdChatForm.btnLockChatBoxesClick(Sender: TObject);
  begin
  FLockBoxes:=not FLockBoxes;
  if FLockBoxes then
    btnLockChatBoxes.Caption:='Unlock Boxes'
  else
    btnLockChatBoxes.Caption:='Lock Chat Boxes';
  end;

procedure TrdChatForm.pTimerTimer(Sender: TObject);
  begin
  //  Disable the Timer for the blinking cursor Chat when loses focus September 18 2007, Alejandro Romero Parra
  If GetForegroundWindow = self.WindowHandle  then
    Begin
    if assigned(FMe) and assigned(FOthers) then
      if FMe.Cursor='|' then
        FMe.Cursor:='  '
      else
        FMe.Cursor:='|';
    End
  Else
    FMe.Cursor:='  ';
  end;

var
  LMouseX,LMouseY:integer;
  LMouseD:boolean=False;

procedure TrdChatForm.pTitleMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  begin
  LMouseD:=True;
  LMouseX:=X;LMouseY:=Y;
  end;

procedure TrdChatForm.pTitleMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  begin
  if LMouseD then
    SetBounds(Left+X-LMouseX,Top+Y-LMouseY,Width,Height);
  end;

procedure TrdChatForm.pTitleMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  begin
  LMouseD:=False;
  end;

var
  LMouseX2,LMouseY2:integer;
  LMouseD2:boolean=False;

procedure TrdChatForm.Panel3MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  begin
  LMouseX2:=X;
  LMouseY2:=Y;
  LMouseD2:=True;
  end;

procedure TrdChatForm.Panel3MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  begin
  if LMouseD2 then
    begin
    if Sender=pRight then
      SetBounds(Left,Top,Width+X-LMouseX2,Height)
    else if Sender=pBottom then
      SetBounds(Left,Top,Width,Height+Y-LMouseY2)
    else if Sender=pLeft then
      SetBounds(Left+X-LMouseX2,Top,Width-X+LMouseX2,Height)
    else if Sender=pTop then
      SetBounds(Left,Top+Y-LMouseY2,Width,Height-Y+LMouseY2)
    else if (Sender=pSize1) or (Sender=pSize2) then
      SetBounds(Left,Top,Width+X-LMouseX2,Height+Y-LMouseY2)
    else
      SetBounds(Left+X-LMouseX2,Top+Y-LMouseY2,Width-X+LMouseX2,Height-Y+LMouseY2);
    end;
  end;

procedure TrdChatForm.Panel3MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  begin
  LMouseD2:=False;
  end;

procedure TrdChatForm.btnHideHistoryClick(Sender: TObject);
  begin
  FHideHistory:=not FHideHistory;
  if FHideHistory then
    begin
    pMain.Visible:=False;
    pSplit.Visible:=False;
    btnHideHistory.Caption:='Show History';
    end
  else
    begin
    pMain.Visible:=True;
    pSplit.Visible:=True;
    pMain.Top:=pTitle.Height;
    pSplit.Top:=pMain.Top+pMain.Height;
    btnHideHistory.Caption:='Hide History';
    end;
  end;

procedure TrdChatForm.btnClearHistoryClick(Sender: TObject);
  begin
  FLastUser:='';
  mChatLog.Lines.BeginUpdate;
  mChatLog.Lines.Clear;
  mChatLog.Lines.EndUpdate;
  end;

procedure TrdChatForm.btnDesktopClick(Sender: TObject);
  begin
  if assigned(PDesktopControl) then
    PDesktopControl.Open(myUI.UserName);
  end;

procedure TrdChatForm.NotOnTop;
  begin
  if FOnTop then
    btnOnTopClick(btnOnTop);
  end;

procedure TrdChatForm.btnHideTypingClick(Sender: TObject);
  begin
  FHideTyping:=not FHideTyping;
  if FHideTyping then
    begin
    if length(FMe.Text)>0 then
      begin
      AddMessage(myUI.Module.Client.LoginUsername, FMe.Text,RTC_MSG_SELF, clBlack);
      FMe.NewLine;
      myUI.Send(#13);
      end;
    btnHideTyping.Caption:='Show my Typing';
    end
  else
    begin
    if length(FMe.Text)>0 then
      begin
      AddMessage(myUI.Module.Client.LoginUsername, FMe.Text,RTC_MSG_SELF, clBlack);
      myUI.Send(FMe.Text);
      FMe.NewLine;
      end;
    btnHideTyping.Caption:='Hide my Typing';
    end;
  end;

var
  PopupField:TLabel;

procedure TrdChatForm.CopyPasteMouseEvent(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
  var
    P:TPoint;
  begin
  If (Button = mbRight) and (Sender is TLabel) then
    begin
    GetCursorPos(P);
    PopupField:=TLabel(Sender);
    CopyPastePopupMenu.Popup(P.X,P.Y);
    end;
  end;

procedure TrdChatForm.Copy1Click(Sender: TObject);
  begin
  ClipBoard.AsText:=PopupField.Caption;
  end;

procedure TrdChatForm.Paste1Click(Sender: TObject);
  Var
    i: Integer;
    Text: String;
  begin
  If Clipboard.HasFormat(CF_TEXT) and (Clipboard.AsText <> '') then
    Begin
    Text := Clipboard.AsText;
    For i := 1 to length(Text) do
      FormKeyPress(nil, Text[i]);
    End;
  end;

procedure TrdChatForm.miSaveHistoryClick(Sender: TObject);
  begin
  If dlgSaveHistory.Execute then
    Begin
    mChatLog.Lines.BeginUpdate;
    mChatLog.Lines.SaveToFile(dlgSaveHistory.FileName);
    mChatLog.Lines.EndUpdate;
    End;
  end;

procedure TrdChatForm.miLoadHistoryClick(Sender: TObject);
  begin
  If dlgLoadHistory.Execute then
    begin
    mChatLog.Lines.BeginUpdate;
    mChatLog.Lines.LoadFromFile(dlgLoadHistory.FileName);
    mChatLog.Lines.EndUpdate;
    End;
  end;

procedure TrdChatForm.miCopyHistoryClick(Sender: TObject);
  begin
  Clipboard.AsText:=mChatLog.Lines.Text;
  end;

procedure TrdChatForm.AddUser(const uname: string);
  var
    pan:TRdUserChatField;
  begin
  pan:=TRdUserChatField(FOthers.asPtr[uname]);
  if not assigned(pan) then
    begin
    Inc(FOtherCnt);
    pan:=TRdUserChatField.Create(self);
    pan.Parent:=pBox;
    pan.Align:=alTop;
    pan.UpdateEvents(CopyPasteMouseEvent);

    FOthers.asPtr[uname]:=pan;
    FOthers.asBoolean[uname]:=True;

    pan.TitleColor:=NextFreeColor;
    pan.BackColor:=$E0E0E0;
    pan.Text:='';
    pan.Cursor:='~';
    pan.User:=uname;
    pan.UpdateSize;
    if not FLockBoxes then
      if pan.Top>TopLoc(uname) then
        pan.Top:=TopLoc(uname);

    AddMessage(uname, 'has JOINED the Chat.', RTC_MSG_LOGIN, pan.TitleColor);
    end
  else if not FLockBoxes then
    if pan.Top>TopLoc(uname) then
      pan.Top:=TopLoc(uname);
  end;

procedure TrdChatForm.myUIUserJoined(Sender: TRtcPChatUI);
  begin
  AddUser(myUI.Recv_User);
  end;

procedure TrdChatForm.RemUser(const uname: string);
  var
    pan:TRdUserChatField;
  begin
  if assigned(FOthers) then // and (uname<>LoginName) then
    begin
    pan:=TrdUserChatField(FOthers.asPtr[uname]);
    if assigned(pan) then
      begin
      Dec(FOtherCnt);
      if length(pan.Text)>0 then
        AddMessage(uname, pan.Text, RTC_MSG_FRIEND, pan.TitleColor);
      AddMessage(uname, 'has LEFT the Chat.', RTC_MSG_LOGOUT, CChatLogout);
      pan.Visible:=False;
      pan.Parent:=nil;
      pan.Free;
      FOthers.asBoolean[uname]:=False;
      FOthers.asPtr[uname]:=nil;
      end;
    end;
  end;

procedure TrdChatForm.myUIUserLeft(Sender: TRtcPChatUI);
  begin
  RemUser(myUI.Recv_User);
  end;

procedure TrdChatForm.myUIMessage(Sender: TRtcPChatUI);
  var
    pan:TRdUserChatField;
    uname, text:string;
  begin
  uname:=myUI.Recv_User;
  text:=myUI.Recv_Message;

  // if we are not the Host, we will also be receiving our messages
  if uname=myUI.Module.Client.LoginUsername then Exit;

  // If we are not the Host, we will not be notified about a new user
  // if the user was already inside the chat when we arrived.
  AddUser(uname);

  if GetForegroundWindow<>Handle then
    begin
    if WindowState=wsMinimized then
      begin
      WindowState:=wsNormal;
      BringToFront;
      BringWindowToTop(Handle);
      MessageBeep(0);
      end;
    end;

  pan:=TRdUserChatField(FOthers.asPtr[uname]);
  if assigned(pan) then
    begin
    if text=#1 then
      pan.Cursor:='Typing ...'
    else if text=#0 then
      pan.Cursor:='~'
    else if text=#8 then
      begin
      if length(pan.Text)>0 then
        pan.Text:=Copy(pan.Text,1,length(pan.Text)-1);
      end
    else if text=#13 then
      begin
      if length(pan.Text)>0 then
        AddMessage(uname,pan.Text,RTC_MSG_FRIEND,pan.TitleColor);
      pan.NewLine;
      end
    else if length(text)=1 then
      pan.Text:=pan.Text+text
    else if length(text)>0 then
      begin
      pan.Cursor:='~';
      if length(pan.Text)>0 then
        begin
        AddMessage(uname,pan.Text,RTC_MSG_FRIEND,pan.TitleColor);
        pan.NewLine;
        end;
      if length(text)<=RTC_CHAT_MAXDISPLAY then
        pan.Text:=text
      else
        pan.Text:=Copy(pan.Text,1,RTC_CHAT_MAXDISPLAY)+'...';
      AddMessage(uname,text,RTC_MSG_FRIEND,pan.TitleColor);
      pan.NewLine;
      end;
    end;
  end;

procedure TrdChatForm.Open_Form(const mode: string);
  begin
  btnDesktop.Visible:=Assigned(PDesktopControl);

  Left:=Screen.Width-Width;
  Top:=Screen.Height-Height-40;

  Caption:=mode+myUI.UserName+' - Chat';
  cTitle.Caption:=mode+'Chat - '+myUI.UserName;

  FLastUser:='';
  FLastColor:=0;

  if not assigned(FOthers) then
    FOthers:=TRtcInfo.Create;

  if not assigned(FMe) then
    begin
    FMe:=TRdUserChatField.Create(self);
    FMe.Parent:=myBox;
    FMe.Align:=alTop;
    FMe.UpdateEvents(CopyPasteMouseEvent);
    FMe.Top:=0;

    FMe.TitleColor:=clGray;
    FMe.BackColor:=clWhite;
    end;

  FMe.Prefix:='';
  FMe.Cursor:='|';
  FMe.Text:='';
  FMe.User:=myUI.Module.Client.LoginUsername;
  UpdateAllSizes;

  pTimer.Enabled:=True;

  {$IFNDEF RtcViewer}
  // tell Windows that you're
  // accepting drag and drop files
  DragAcceptFiles( Handle, True );
  {$ENDIF}

  FReady:=True;
  end;

procedure TrdChatForm.myUIInit(Sender: TRtcPChatUI);
  begin
  if not FReady then Open_Form('(Init) ');
  end;

procedure TrdChatForm.myUIOpen(Sender: TRtcPChatUI);
  begin
  Open_Form('');
  end;

procedure TrdChatForm.Close_Form(const mode: string);
  var
    a:integer;
    user:string;
  begin
  Caption:=mode+myUI.UserName+' - Chat';
  cTitle.Caption:=mode+'Chat - '+myUI.UserName;

  if assigned(FOthers) then
    begin
    for a:=FOthers.Count-1 downto 0 do
      begin
      user:=FOthers.FieldName[a];
      RemUser(user);
      end;

    FOthers.Free;
    FOthers:=nil;
    end;

  FMe.Prefix:='';
  FMe.Cursor:='|';
  FMe.Text:='';
  FMe.Cursor:='  ';
  pTimer.Enabled:=False;

  {$IFNDEF RtcViewer}
  // tell Windows that you're
  // accepting drag and drop files
  DragAcceptFiles( Handle, False );
  {$ENDIF}

  FReady:=False;
  end;

procedure TrdChatForm.myUIClose(Sender: TRtcPChatUI);
  begin
  Close_Form('(Closed) ');
  if WindowState=wsMinimized then Close;
  end;

procedure TrdChatForm.myUIError(Sender: TRtcPChatUI);
  begin
  Close_Form('(DISCONNECTED) ');
  // we disconnected. can not use this chat window anymore.
  myUI.Module:=nil;
  if WindowState=wsMinimized then Close;
  end;

end.
