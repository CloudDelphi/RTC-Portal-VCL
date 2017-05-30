unit rdDesktopView;

interface

{$include rtcDefs.inc}
{$ifdef RTCHost}
  {$define RTCViewer}
{$endif}

uses
  Windows, Messages, SysUtils,
  Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ShellAPI,

  rtcpFileTrans,
  rtcpDesktopControl, rtcpDesktopControlUI, rtcPortalMod,
  rtcpDesktopConst, Buttons, Spin;

type
  TrdDesktopViewer = class(TForm)
    Scroll: TScrollBox;
    sStatus: TLabel;
    pImage: TRtcPDesktopViewer;
    myUI: TRtcPDesktopControlUI;
    panOptions: TPanel;
    btnCycle: TSpeedButton;
    btnSettings: TSpeedButton;
    panSettings: TPanel;
    grpMirror: TComboBox;
    grpMouse: TComboBox;
    btnAccept: TBitBtn;
    grpLayered: TComboBox;
    grpScreenBlocks: TComboBox;
    grpMonitors: TComboBox;
    grpColor: TComboBox;
    grpFrame: TComboBox;
    btnCancel: TBitBtn;
    btnWallpaper: TSpeedButton;
    btnCtrlAltDel: TSpeedButton;
    btnSmoothScale: TSpeedButton;
    btnMapKeys: TSpeedButton;
    btnExactCursor: TSpeedButton;
    btnGetSelected: TSpeedButton;
    Label1: TLabel;
    grpColorLow: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label4: TLabel;
    cbReduceColors: TSpinEdit;
    Label11: TLabel;
    Label12: TLabel;
    grpScreenLimit: TComboBox;
    grpScreenBlocks2: TComboBox;
    Label13: TLabel;
    Label14: TLabel;
    grpScreen2Refine: TComboBox;
    DesktopTimer: TTimer;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormDeactivate(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure myUIOpen(Sender: TRtcPDesktopControlUI);
    procedure myUIClose(Sender: TRtcPDesktopControlUI);
    procedure myUIError(Sender: TRtcPDesktopControlUI);
    procedure myUIData(Sender: TRtcPDesktopControlUI);
    procedure myUILogOut(Sender: TRtcPDesktopControlUI);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure pImageMouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
    procedure btnCycleClick(Sender: TObject);
    procedure btnSettingsClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnAcceptClick(Sender: TObject);
    procedure btnWallpaperClick(Sender: TObject);
    procedure btnCtrlAltDelClick(Sender: TObject);
    procedure btnSmoothScaleClick(Sender: TObject);
    procedure btnMapKeysClick(Sender: TObject);
    procedure btnExactCursorClick(Sender: TObject);
    procedure btnGetSelectedClick(Sender: TObject);
    procedure ScrollMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure pImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pImageMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure grpColorLowChange(Sender: TObject);
    procedure DesktopTimerTimer(Sender: TObject);
    procedure pImageDblClick(Sender: TObject);

  protected
    LMouseX,LMouseY:integer;
    LMouseD:boolean;

    LMouseDown,
    RMouseDown,
    LWinDown,
    RWinDown:boolean;

    procedure CreateParams(Var params: TCreateParams); override;

    {$IFNDEF RtcViewer}
    // declare our DROPFILES message handler
    procedure AcceptFiles( var msg : TMessage ); message WM_DROPFILES;
    {$ENDIF}

  public
    { Public declarations }

    PFileTrans:TRtcPFileTransfer;

    procedure InitScreen;
    procedure FullScreen;

    property UI:TRtcPDesktopControlUI read myUI;
  end;

implementation

{$R *.dfm}

{ TrdDesktopViewer }

procedure TrdDesktopViewer.CreateParams(Var params: TCreateParams);
  begin
  inherited CreateParams( params );
  params.ExStyle := params.ExStyle or WS_EX_APPWINDOW;
  params.WndParent := GetDeskTopWindow;
  end;

function checkControl:string;
  begin
  {$IFNDEF RtcViewer}
  Result:='Control';
  {$ELSE}
  Result:='View';
  {$ENDIF}
  end;

{$IFNDEF RtcViewer}
procedure TrdDesktopViewer.AcceptFiles( var msg : TMessage );
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
        PFileTrans.Send(UI.UserName, myFileName);
        end;
      end;
  finally
    // let Windows know that you're done
    DragFinish( msg.WParam );
    end;
  end;
{$ENDIF}

procedure TrdDesktopViewer.FormClose(Sender: TObject; var Action: TCloseAction);
  begin
  DesktopTimer.Enabled:=False;
  Action:=caFree;
  end;

procedure TrdDesktopViewer.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  begin
  DesktopTimer.Enabled:=False;
  CanClose:=myUI.CloseAndClear;
  end;

procedure TrdDesktopViewer.myUILogOut(Sender: TRtcPDesktopControlUI);
  begin
  Close;
  end;

procedure TrdDesktopViewer.InitScreen;
  begin
  Scroll.HorzScrollBar.Visible:=False;
  Scroll.VertScrollBar.Visible:=False;
  Scroll.VertScrollBar.Position:=0;
  Scroll.HorzScrollBar.Position:=0;

  pImage.Left:=0;
  pImage.Top:=0;
  WindowState:=wsNormal;
  BorderStyle:=bsSizeable;

  if myUI.HaveScreen then
    begin
    if myUI.ScreenWidth<Screen.Width then
      ClientWidth:=myUI.ScreenWidth
    else
      Width:=Screen.Width;
    if myUI.ScreenHeight<Screen.Height then
      ClientHeight:=myUI.ScreenHeight
    else
      Height:=Screen.Height;
    if myUI.ScreenHeight>=Screen.Height then
      begin
      Left:=0;
      Top:=0;
      WindowState:=wsMaximized;
      end
    else
      begin
      Left:=(Screen.Width-Width) div 2;
      Top:=(Screen.Height-Height) div 2;
      end;
    end;

  if (pImage.Align<>alClient) and myUI.HaveScreen then
    begin
    pImage.Align:=alNone;
    pImage.Width:=myUI.ScreenWidth;
    pImage.Height:=myUI.ScreenHeight;
    Scroll.HorzScrollBar.Visible:=True;
    Scroll.VertScrollBar.Visible:=True;
    end;

  BringToFront;

  {$IFNDEF RtcViewer}
  { tell Windows that you're accepting drag and drop files }
  if assigned(PFileTrans) then
    DragAcceptFiles( Handle, True );
  {$ENDIF}
  end;

procedure TrdDesktopViewer.FullScreen;
  begin
  // move to Full Screen mode
  Scroll.HorzScrollBar.Visible:=False;
  Scroll.VertScrollBar.Visible:=False;
  Scroll.VertScrollBar.Position:=0;
  Scroll.HorzScrollBar.Position:=0;

  WindowState:=wsNormal;
  BorderStyle:=bsNone;
  Left:=0;
  Top:=0;
  Width:=Screen.Width;
  Height:=Screen.Height;

  if (pImage.Align=alNone) and myUI.HaveScreen then
    begin
    pImage.Width:=myUI.ScreenWidth;
    pImage.Height:=myUI.ScreenHeight;
    Scroll.HorzScrollBar.Visible:=True;
    Scroll.VertScrollBar.Visible:=True;
    if pImage.Width<Screen.Width then
      pImage.Left:=(Screen.Width-pImage.Width) div 2
    else
      pImage.Left:=0;
    if pImage.Height<Screen.Height then
      pImage.Top:=(Screen.Height-pImage.Height) div 2
    else
      pImage.Top:=0;
    end;
    
  BringToFront;

  {$IFNDEF RtcViewer}
  { tell Windows that you're accepting drag and drop files }
  DragAcceptFiles( Handle, True );
  {$ENDIF}

  end;

procedure TrdDesktopViewer.FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
  begin
  myUI.SendMouseWheel(WheelDelta,Shift);
  end;

procedure TrdDesktopViewer.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  begin
  case Key of
    VK_LWIN: LWinDown:=True;
    VK_RWIN: RWinDown:=True;
    end;

  if LWinDown or RWinDown then
    begin
    if Key=Ord('W') then
      begin
      pImage.Align:=alNone;
      if BorderStyle<>bsNone then
        FullScreen
      else
        InitScreen;
      Key:=0;
      Exit;
      end
    else if Key=Ord('S') then
      begin
      pImage.Align:=alClient;
      if (myUI.ScreenWidth>=Screen.Width) or
         (myUI.ScreenHeight>=Screen.Height) then
        begin
        if BorderStyle<>bsNone then
          FullScreen
        else
          InitScreen;
        end
      else
        InitScreen;
      Exit;
      end;
    end;
  {$IFNDEF RtcViewer}
  if myUI.ControlMode<>rtcpNoControl then
    myUI.SendKeyDown(Key,Shift);
  {$ENDIF}
  Key:=0;
  end;

procedure TrdDesktopViewer.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
{$IFNDEF RtcViewer}
  var
    temp:Word;
{$ENDIF}
  begin
  if (LWinDown or RWinDown) and (Key in [Ord('S'),Ord('W')]) then
    Exit;

  case Key of
    VK_LWIN: LWinDown:=False;
    VK_RWIN: RWinDown:=False;
    end;

  {$IFNDEF RtcViewer}
  if myUI.ControlMode<>rtcpNoControl then
    begin
    temp:=Key; // a work-around for Internal Error in Delphi 7 compiler
    myUI.SendKeyUp(temp,Shift);
    end;
  {$ENDIF}
  Key:=0;
  end;

procedure TrdDesktopViewer.FormDeactivate(Sender: TObject);
  begin
  myUI.Deactivated;
  LWinDown:=False;
  RWinDown:=False;
  LMouseDown:=False;
  LMouseD:=False;
  RMouseDown:=False;
  pImage.Cursor:=200; // small dot
  end;

procedure TrdDesktopViewer.myUIOpen(Sender: TRtcPDesktopControlUI);
  begin
  pImage.Align:=alClient;

  Caption:=myUI.UserName+' - Desktop '+checkControl;
  sStatus.Font.Color:=clWhite;
  sStatus.Caption:='Loading initial screen. Please wait ...';
  sStatus.Visible:=True;

  WindowState:=wsNormal;
  BorderStyle:=bsSizeable;
  Width:=400;
  Height:=90;
  Scroll.HorzScrollBar.Position:=0;
  Scroll.VertScrollBar.Position:=0;

  BringToFront;
  BringWindowToTop(Handle);

  {$IFNDEF RtcViewer}
  { tell Windows that you're accepting drag and drop files }
  if assigned(PFileTrans) then
    DragAcceptFiles( Handle, True );
  {$ENDIF}
  end;

procedure TrdDesktopViewer.myUIClose(Sender: TRtcPDesktopControlUI);
  begin
  DesktopTimer.Enabled:=False;
  pImage.Align:=alNone;

  Caption:=Caption+' - Closed by Host';
  sStatus.Font.Color:=clRed;
  sStatus.Caption:='Desktop session closed by Host.';
  sStatus.Visible:=True;

  WindowState:=wsNormal;
  BorderStyle:=bsSizeable;
  Width:=400;
  Height:=90;
  Scroll.HorzScrollBar.Position:=0;
  Scroll.VertScrollBar.Position:=0;
  MessageBeep(0);

  {$IFNDEF RtcViewer}
  { tell Windows that you're accepting drag and drop files }
  DragAcceptFiles( Handle, False );
  {$ENDIF}
  end;

procedure TrdDesktopViewer.myUIError(Sender: TRtcPDesktopControlUI);
  begin
  DesktopTimer.Enabled:=False;
  pImage.Align:=alNone;

  Caption:=Caption+' - Disconnected';
  sStatus.Font.Color:=clRed;
  sStatus.Caption:='Desktop session terminated.';
  sStatus.Visible:=True;

  WindowState:=wsNormal;
  BorderStyle:=bsSizeable;
  Width:=400;
  Height:=90;
  Scroll.HorzScrollBar.Position:=0;
  Scroll.VertScrollBar.Position:=0;
  MessageBeep(0);

  {$IFNDEF RtcViewer}
  { tell Windows that you're accepting drag and drop files }
  DragAcceptFiles( Handle, False );
  {$ENDIF}
  end;

procedure TrdDesktopViewer.myUIData(Sender: TRtcPDesktopControlUI);
  begin
  if sStatus.Visible and UI.HaveScreen then
    begin
    Caption:=myUI.UserName+' - Desktop '+checkControl;
    sStatus.Visible:=False;
    WindowState:=wsNormal;
    if myUI.ScreenWidth<Screen.Width then
      ClientWidth:=myUI.ScreenWidth
    else
      Width:=Screen.Width;
    if myUI.ScreenHeight<Screen.Height then
      ClientHeight:=myUI.ScreenHeight
    else
      Height:=Screen.Height;
    if myUI.ScreenHeight>=Screen.Height then
      begin
      Left:=0;
      Top:=0;
      WindowState:=wsMaximized;
      end
    else
      begin
      WindowState:=wsNormal;
      Left:=(Screen.Width-Width) div 2;
      Top:=(Screen.Height-Height) div 2;
      end;
    {$IFNDEF RtcViewer}
    { tell Windows that you're accepting drag and drop files }
    if assigned(PFileTrans) then
      DragAcceptFiles( Handle, True );
    {$ENDIF}
    DesktopTimer.Enabled:=True;
    end;
  end;

procedure TrdDesktopViewer.ScrollMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  begin
  if MyUI.ControlMode=rtcpNoControl then Exit;

  if not (panSettings.Visible or panOptions.Visible) then
    begin
    btnCycle.Down:=BorderStyle=bsNone;
    if btnCycle.Down then btnCycle.Hint:='To Windowed mode'
    else btnCycle.Hint:='To Full Screen mode';
    btnSmoothScale.Down:=UI.SmoothScale;
    btnMapKeys.Down:=UI.MapKeys;
    btnExactCursor.Down:=UI.ExactCursor;
    panOptions.Left:=10;
    panOptions.Top:=10;
    panOptions.Visible:=True;
    end;
  end;

procedure TrdDesktopViewer.pImageMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  begin
  if MyUI.ControlMode=rtcpNoControl then
    begin
    if LMouseD then
      SetBounds(Left+X-LMouseX,Top+Y-LMouseY,Width,Height);
    end
  else if not (LMouseDown or RMouseDown) then
    begin
    if panOptions.Visible then
      begin
      if (Y+pImage.Left>panOptions.Height+15) or (X+pImage.Top>panOptions.Width+15) then
        begin
        panOptions.Visible:=False;
        panSettings.Visible:=False;
        // Hints will bring the main window to Top.
        // Need to fix this for Full Screen mode.
        BringToFront;
        BringWindowToTop(Handle);
        end;
      end
    else if not panSettings.Visible then
      if ( ((Y<5) and (X<5)) or ((Y<2) and (X<panOptions.Width)) ) and
         ( (pImage.Left<=5) or (pImage.Top<=5) ) then
        ScrollMouseMove(Sender,Shift,X,Y);
    end;
  end;

procedure TrdDesktopViewer.pImageMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  begin
  if myUI.ControlMode=rtcpNoControl then
    begin
    if Button=mbLeft then
      begin
      LMouseD:=True;
      LMouseX:=X;LMouseY:=Y;
      end;
    end
  else
    begin
    if Button=mbLeft then LMouseDown:=True;
    if Button=mbRight then RMouseDown:=True;
    if (panOptions.Visible or panSettings.Visible) then
      begin
      // if the user clicks somewhere on the screen, auto-cancel the Settings panel
      panOptions.Visible:=False;
      panSettings.Visible:=False;
      end;
    end;
  end;

procedure TrdDesktopViewer.btnCycleClick(Sender: TObject);
  begin
  if (myUI.ScreenWidth>=Screen.Width) or
     (myUI.ScreenHeight>=Screen.Height) then
    begin
    pImage.Align:=alClient;
    if BorderStyle<>bsNone then
      FullScreen
    else
      InitScreen;
    end
  else
    begin
    if BorderStyle<>bsNone then
      begin
      pImage.Align:=alNone;
      FullScreen;
      end
    else
      begin
      pImage.Align:=alClient;
      InitScreen;
      end;
    end;
  end;

procedure TrdDesktopViewer.btnSettingsClick(Sender: TObject);
  begin
  panOptions.Visible:=False;

  panSettings.Left:=10;
  panSettings.Top:=10;
  panSettings.Visible:=True;

  // Clear Host Settings
  grpScreenBlocks.ItemIndex:=-1;
  grpScreenBlocks2.ItemIndex:=-1;
  grpScreen2Refine.ItemIndex:=-1;
  grpScreenLimit.ItemIndex:=-1;
  grpLayered.ItemIndex:=-1;
  grpMirror.ItemIndex:=-1;
  grpMouse.ItemIndex:=-1;
  grpMonitors.ItemIndex:=-1;
  grpColor.ItemIndex:=-1;
  grpFrame.ItemIndex:=-1;
  grpColorLow.ItemIndex:=-1;
  cbReduceColors.Value:=0;
  cbReduceColors.Enabled:=False;
  cbReduceColors.Color:=clBtnFace;
  end;

procedure TrdDesktopViewer.btnCancelClick(Sender: TObject);
  begin
  panSettings.Visible:=False;
  end;

procedure TrdDesktopViewer.btnAcceptClick(Sender: TObject);
  begin
  panSettings.Visible:=False;
  UI.ChgDesktop_Begin;
  try
    if grpLayered.ItemIndex>=0 then      UI.ChgDesktop_CaptureLayeredWindows(grpLayered.ItemIndex=0);
    if grpMirror.ItemIndex>=0 then       UI.ChgDesktop_UseMirrorDriver(grpMirror.ItemIndex=0);
    if grpMouse.ItemIndex>=0 then        UI.ChgDesktop_UseMouseDriver(grpMouse.ItemIndex=0);
    if grpMonitors.ItemIndex>=0 then     UI.ChgDesktop_CaptureAllMonitors(grpMonitors.ItemIndex=0);
    if grpColor.ItemIndex>=0 then        UI.ChgDesktop_ColorLimit(TRdColorLimit(grpColor.ItemIndex));
    if grpFrame.ItemIndex>=0 then        UI.ChgDesktop_FrameRate(TRdFrameRate(grpFrame.ItemIndex));
    if grpScreenBlocks.ItemIndex>=0 then UI.ChgDesktop_SendScreenInBlocks(TrdScreenBlocks(grpScreenBlocks.ItemIndex));
    if grpScreenBlocks2.ItemIndex>=0 then UI.ChgDesktop_SendScreenRefineBlocks(TrdScreenBlocks(grpScreenBlocks2.ItemIndex));
    if grpScreen2Refine.ItemIndex>=0 then  UI.ChgDesktop_SendScreenRefineDelay(grpScreen2Refine.ItemIndex);
    if grpScreenLimit.ItemIndex>=0 then  UI.ChgDesktop_SendScreenSizeLimit(TrdScreenLimit(grpScreenLimit.ItemIndex));
    if grpColorLow.ItemIndex>=0 then
      begin
      UI.ChgDesktop_ColorLowLimit(TrdLowColorLimit(grpColorLow.ItemIndex));
      UI.ChgDesktop_ColorReducePercent(cbReduceColors.Value);
      end;
  finally
    UI.ChgDesktop_End;
    end;
  end;

procedure TrdDesktopViewer.btnWallpaperClick(Sender: TObject);
  begin
  if btnWallpaper.Down then
    begin
    btnWallpaper.Hint:='Show Wallpaper';
    UI.Send_HideDesktop;
    end
  else
    begin
    btnWallpaper.Hint:='Hide Wallpaper';
    UI.Send_ShowDesktop;
    end;
  end;

procedure TrdDesktopViewer.btnCtrlAltDelClick(Sender: TObject);
  begin
  UI.Send_CtrlAltDel;
  end;

procedure TrdDesktopViewer.btnSmoothScaleClick(Sender: TObject);
  begin
  UI.SmoothScale:=not UI.SmoothScale;
  pImage.Repaint;
  end;

procedure TrdDesktopViewer.btnMapKeysClick(Sender: TObject);
  begin
  UI.MapKeys:=not UI.MapKeys;
  end;

procedure TrdDesktopViewer.btnExactCursorClick(Sender: TObject);
  begin
  UI.ExactCursor:=not UI.ExactCursor;
  pImage.Repaint;
  end;

procedure TrdDesktopViewer.btnGetSelectedClick(Sender: TObject);
  begin
  UI.Send_FileCopy;
  end;

procedure TrdDesktopViewer.pImageMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  begin
  if MyUI.ControlMode=rtcpNoControl then
    begin
    if Button=mbLeft then
      LMouseD:=False;
    end
  else
    begin
    if Button=mbLeft then LMouseDown:=False;
    if Button=mbRight then RMouseDown:=False;
    end;
  end;

procedure TrdDesktopViewer.grpColorLowChange(Sender: TObject);
  begin
  cbReduceColors.Enabled:=grpColorLow.ItemIndex>0;
  if cbReduceColors.Enabled then
    cbReduceColors.Color:=clWindow
  else
    cbReduceColors.Color:=clBtnFace;
  end;

procedure TrdDesktopViewer.DesktopTimerTimer(Sender: TObject);
  begin
  if assigned(myUI) and MyUI.InControl and (GetForegroundWindow<>Handle) then
    FormDeactivate(nil);
  end;

procedure TrdDesktopViewer.pImageDblClick(Sender: TObject);
  var
    cw,ch:integer;
  begin
  if myUI.ControlMode=rtcpNoControl then
    if BorderStyle=bsSizeable then
      begin
      cw:=ClientWidth;
      ch:=ClientHeight;
      BorderStyle:=bsNone;
      ClientWidth:=cw;
      ClientHeight:=ch;
      end
    else
      begin
      cw:=ClientWidth;
      ch:=ClientHeight;
      BorderStyle:=bsSizeable;
      ClientWidth:=cw;
      ClientHeight:=ch;
      end;
  end;

end.
