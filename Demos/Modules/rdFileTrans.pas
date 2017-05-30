{ Copyright (c) Danijel Tkalcec,
  RealThinClient components - http://www.realthinclient.com }

unit rdFileTrans;

interface

{$INCLUDE rtcDefs.inc}

uses
  Windows, Messages, SysUtils,
  Classes, Graphics, Controls, Forms,
  Dialogs, ShellAPI, Gauges, StdCtrls, ExtCtrls,

  rtcInfo, Buttons, ComCtrls,

  rtcPortalMod, rtcpFileTrans, rtcpFileTransUI,
  rtcpFileExplore, rdFileBrowse;

type
  TrdFileTransfer = class(TForm)
    pTitlebar: TPanel;
    cTitleBar: TLabel;
    btnClose: TButton;
    cUserName: TLabel;
    Panel1: TPanel;
    DownPanel: TPanel;
    pMain: TPageControl;
    pSending: TTabSheet;
    pReceiving: TTabSheet;
    gRecvCurrent: TGauge;
    gRecvTotal: TGauge;
    lRecvFileName: TLabel;
    lRecvCurrent: TLabel;
    lRecvTotal: TLabel;
    gSendCurrent: TGauge;
    gSendCompleted: TGauge;
    lSendFileName: TLabel;
    lSendCurrent: TLabel;
    lSendCompleted: TLabel;
    lSendTotal: TLabel;
    gSendTotal: TGauge;
    btnMinimize: TButton;
    lRecvTime: TLabel;
    lRecvSpeed: TLabel;
    lSendTime: TLabel;
    lSendSpeed: TLabel;

    myUI: TRtcPFileTransferUI;
    Bevel1: TBevel;
    Bevel2: TBevel;
    lRecvToFolder: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    lSendFromFolder: TLabel;
    DownLabel: TLabel;
    btnExplore: TSpeedButton;
    btnCancelSend: TSpeedButton;
    btnCancelFetch: TSpeedButton;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCloseClick(Sender: TObject);

    procedure pTitlebarMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure pTitlebarMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure pTitlebarMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure btnMinimizeClick(Sender: TObject);
    procedure btnOpenInboxClick(Sender: TObject);

    procedure myUIInit(Sender: TRtcPFileTransferUI);
    procedure myUIOpen(Sender: TRtcPFileTransferUI);
    procedure myUIClose(Sender: TRtcPFileTransferUI);
    procedure myUIError(Sender: TRtcPFileTransferUI);
    procedure myUILogOut(Sender: TRtcPFileTransferUI);
    procedure myUIRecv(Sender: TRtcPFileTransferUI);
    procedure myUISend(Sender: TRtcPFileTransferUI);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure lSendFromFolderClick(Sender: TObject);
    procedure DownPanelClick(Sender: TObject);

    procedure FileBrowserClose(Sender: TObject);
    procedure myUIRecvCancel(Sender: TRtcPFileTransferUI);
    procedure myUISendCancel(Sender: TRtcPFileTransferUI);
    procedure btnCancelSendClick(Sender: TObject);
    procedure btnCancelFetchClick(Sender: TObject);

  private
    FBrowser: boolean;
    MyBrowser: TrdFileBrowser;
    FAutoBrowse: boolean;
    
    procedure SetBrowser(const Value: boolean);
    
  protected
    FReady: boolean;

    // declare our DROPFILES message handler
    procedure AcceptFiles( var msg : TMessage ); message WM_DROPFILES;
    procedure CreateParams(Var params: TCreateParams); override;

    procedure Form_Open(const mode:string);
    procedure Form_Close(const mode:string);

  public
    property UI:TRtcPFileTransferUI read myUI;

    // File Transfer Window with the option to open a File Browser / Remote Explorer window?
    property WithExplorer:boolean read FBrowser write SetBrowser default False;
    // Automatically open a Remote File Explorer / Browser window when File Transfer window opens?
    property AutoExplore:boolean read FAutoBrowse write FAutoBrowse default False;
  end;

implementation

{$R *.dfm}

{ TrdFileTransfer }

var
  LMouseX,LMouseY:integer;
  LMouseD:boolean=False;

procedure TrdFileTransfer.pTitlebarMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  begin
  LMouseD:=True;
  LMouseX:=X;LMouseY:=Y;
  end;

procedure TrdFileTransfer.pTitlebarMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  begin
  if LMouseD then
    SetBounds(Left+X-LMouseX,Top+Y-LMouseY,Width,Height);
  end;

procedure TrdFileTransfer.pTitlebarMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  begin
  LMouseD:=False;
  end;

procedure TrdFileTransfer.CreateParams(Var params: TCreateParams);
  begin
  inherited CreateParams( params );
  params.ExStyle := params.ExStyle or WS_EX_APPWINDOW;
  params.WndParent := GetDeskTopWindow;
  end;

procedure TrdFileTransfer.AcceptFiles( var msg : TMessage );
  const
    cnMaxFileNameLen = 1024;
  var
    i,
    nCount     : integer;
    acFileName : array [0..cnMaxFileNameLen] of char;
    myFileName : string;
  begin
  if not assigned(myUI.Module) then MessageBeep(0);

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

      if assigned(myUI.Module) then
        begin
        myFileName:=acFileName;
        myUI.Send(myFileName);
        end;
      end;
  finally
    // let Windows know that you're done
    DragFinish( msg.WParam );
    end;
  end;

procedure TrdFileTransfer.FormClose(Sender: TObject; var Action: TCloseAction);
  begin
  Action:=caFree;
  end;

procedure TrdFileTransfer.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  begin
  if assigned(MyBrowser) then
    MyBrowser.Close;
  CanClose:=myUI.CloseAndClear;
  end;

procedure TrdFileTransfer.myUILogOut(Sender: TRtcPFileTransferUI);
  begin
  Close;
  end;

procedure TrdFileTransfer.FormCreate(Sender: TObject);
  begin
  // tell Windows that you're
  // accepting drag and drop files
  DragAcceptFiles( Handle, True );
  FReady:=False;
  FBrowser:=False;
  MyBrowser:=nil;

  Left:=Screen.Width-Width;
  Top:=0;
  end;

procedure TrdFileTransfer.FormDestroy(Sender: TObject);
  begin
  DragAcceptFiles(Handle, False);
  end;

procedure TrdFileTransfer.btnCloseClick(Sender: TObject);
  begin
  Close;
  end;

procedure TrdFileTransfer.btnMinimizeClick(Sender: TObject);
  begin
  WindowState:=wsMinimized;
  end;

procedure TrdFileTransfer.btnOpenInboxClick(Sender: TObject);
  var
    DestFolder:String;
  begin
  if assigned(myUI.Module) then
    begin
    if lRecvToFolder.Caption='INBOX' then
      DestFolder:=myUI.Module.FileInboxPath
    else
      DestFolder:=lRecvToFolder.Caption;
    ShellExecute(handle, 'open', PChar(DestFolder), nil,nil,SW_SHOW);
    end;
  end;

procedure TrdFileTransfer.Form_Open(const mode: string);
  begin
  if FAutoBrowse and FBrowser then
    DownPanelClick(self);

  Caption:=mode+myUI.UserName+' - Files';

  cUserName.Caption:=myUI.UserName;
  cTitleBar.Caption:=mode+'Files';

  lSendFileName.Caption:='----';
  lSendFromFolder.Caption:='----';
  lSendCurrent.Caption:='-- / --';
  lSendTotal.Caption:='-- / --';
  lSendCompleted.Caption:='-- / --';

  gSendCurrent.Progress:=0;
  gSendTotal.Progress:=0;
  gSendCompleted.Progress:=0;
  gSendCurrent.MaxValue:=10000;
  gSendTotal.MaxValue:=10000;
  gSendCompleted.MaxValue:=10000;

  gSendCurrent.ForeColor:=clNavy;
  gSendTotal.ForeColor:=clTeal;
  gSendCompleted.ForeColor:=clGreen;

  lSendSpeed.Caption:='-';
  lSendTime.Caption:='---';

  lRecvFileName.Caption:='----';
  lRecvToFolder.Caption:='----';
  lRecvCurrent.Caption:='-- / --';
  lRecvTotal.Caption:='-- / --';
  gRecvCurrent.Progress:=0;
  gRecvTotal.Progress:=0;
  gRecvCurrent.MaxValue:=10000;
  gRecvTotal.MaxValue:=10000;

  gRecvCurrent.ForeColor:=clNavy;
  gRecvTotal.ForeColor:=clGreen;

  lRecvSpeed.Caption:='-';
  lRecvTime.Caption:='---';

  if WindowState=wsNormal then
    begin
    BringToFront;
    BringWindowToTop(Handle);
    end;

  Left:=Screen.Width-Width;
  Top:=0;

  FReady:=True;
  end;

procedure TrdFileTransfer.Form_Close(const mode: string);
  begin
  if assigned(MyBrowser) then
    MyBrowser.Close;

  cUserName.Caption:=myUI.UserName;
  cTitleBar.Caption:='('+mode+')';

  gSendCurrent.ForeColor:=clMaroon;
  gSendTotal.ForeColor:=clMaroon;
  gSendCompleted.ForeColor:=clMaroon;

  lSendSpeed.Caption:=mode;
  lSendTime.Caption:='---';

  gRecvCurrent.ForeColor:=clMaroon;
  gRecvTotal.ForeColor:=clMaroon;

  lRecvSpeed.Caption:=mode;
  lRecvTime.Caption:='---';
  
  FReady:=False;
  end;

procedure TrdFileTransfer.myUIInit(Sender: TRtcPFileTransferUI);
  begin
  if not FReady then Form_Open('(Init) ');
  end;

procedure TrdFileTransfer.myUIOpen(Sender: TRtcPFileTransferUI);
  begin
  Form_Open('');
  end;

procedure TrdFileTransfer.myUIClose(Sender: TRtcPFileTransferUI);
  begin
  Form_Close('Closed');
  if WindowState=wsMinimized then Close;
  end;

procedure TrdFileTransfer.myUIError(Sender: TRtcPFileTransferUI);
  begin
  Form_Close('DISCONNECTED');
  // we disconnected. Can not use this FileTransfer window anymore.
  myUI.Module:=nil;
  if WindowState=wsMinimized then Close;
  end;

procedure TrdFileTransfer.myUIRecv(Sender: TRtcPFileTransferUI);
  begin
  if myUI.Recv_FirstTime then
    begin
    if pMain.ActivePage<>pReceiving then
      pMain.ActivePage:=pReceiving;
    gRecvCurrent.ForeColor:=clNavy;
    gRecvTotal.ForeColor:=clGreen;
    end;

  if myUI.Recv_FileCount>1 then
    lRecvFileName.Caption:='['+IntToStr(myUI.Recv_FileCount)+'] '+myUI.Recv_FileName
  else
    lRecvFileName.Caption:=myUI.Recv_FileName;

  if myUI.Recv_ToFolder='' then
    lRecvToFolder.Caption:='INBOX'
  else
    lRecvToFolder.Caption:=myUI.Recv_ToFolder;

  lRecvCurrent.Caption:=Format('%.0n / %.0n KB', [myUI.Recv_FileIn/1024, myUI.Recv_FileSize/1024]);
  lRecvTotal.Caption:=Format('%.0n / %.0n KB', [myUI.Recv_BytesComplete/1024, myUI.Recv_BytesTotal/1024]);

  if myUI.Recv_FileSize>0 then
    gRecvCurrent.Progress:=round(myUI.Recv_FileIn/myUI.Recv_FileSize*10000)
  else
    gRecvCurrent.Progress:=0;

  if myUI.Recv_BytesTotal>0 then
    gRecvTotal.Progress:=round(myUI.Recv_BytesComplete/myUI.Recv_BytesTotal*10000)
  else
    gRecvTotal.Progress:=0;

  if (myUI.Recv_FileCount=0) and (myUI.Recv_BytesComplete=myUI.Recv_BytesTotal) then
    begin
    gRecvCurrent.ForeColor:=clSilver;
    gRecvTotal.ForeColor:=clSilver;

    lRecvTime.Caption:='DONE. Completed in '+myUI.Recv_TotalTime;
    lRecvSpeed.Caption:=Format('Speed: %.0n Kbps',[myUI.Recv_KBit/1]);

    if myUI.Recv_ToFolder='' then
      btnOpenInboxClick(nil);
    end
  else if myUI.Recv_BytesComplete>0 then
    begin
    lRecvSpeed.Caption:=Format('Speed: %.0n Kbps',[myUI.Recv_KBit/1]);
    lRecvTime.Caption:='Estimated completion in '+myUI.Recv_ETA;
    end
  else
    begin
    lRecvSpeed.Caption:='';
    lRecvTime.Caption:='';
    end;
  end;

procedure TrdFileTransfer.myUISend(Sender: TRtcPFileTransferUI);
  begin
  if myUI.Send_FirstTime then
    begin
    if pMain.ActivePage<>pSending then
      pMain.ActivePage:=pSending;

    gSendCurrent.ForeColor:=clNavy;
    gSendTotal.ForeColor:=clTeal;
    gSendCompleted.ForeColor:=clGreen;
    end;

  if myUI.Send_FileCount>1 then
    lSendFileName.Caption:='['+IntToStr(myUI.Send_FileCount)+'] '+myUI.Send_FileName
  else
    lSendFileName.Caption:=myUI.Send_FileName;

  lSendFromFolder.Caption:=myUI.Send_FromFolder;

  lSendCurrent.Caption:=Format('%.0n / %.0n KB', [myUI.Send_FileOut/1024,myUI.Send_FileSize/1024]);
  lSendTotal.Caption:=Format('%.0n / %.0n KB', [myUI.Send_BytesPrepared/1024, myUI.Send_BytesTotal/1024]);
  lSendCompleted.Caption:=Format('%.0n / %.0n KB', [myUI.Send_BytesComplete/1024, myUI.Send_BytesTotal/1024]);

  if myUI.Send_FileSize>0 then
    gSendCurrent.Progress:=round(myUI.Send_FileOut/myUI.Send_FileSize*10000)
  else
    gSendCurrent.Progress:=0;

  if myUI.Send_BytesTotal>0 then
    begin
    gSendTotal.Progress:=round(myUI.Send_BytesPrepared/myUI.Send_BytesTotal*10000);
    gSendCompleted.Progress:=round(myUI.Send_BytesComplete/myUI.Send_BytesTotal*10000);
    end
  else
    begin
    gSendTotal.Progress:=0;
    gSendCompleted.Progress:=0;
    end;

  if (myUI.Send_FileCount=0) and (myUI.Send_BytesComplete=myUI.Send_BytesTotal) then
    begin
    gSendCurrent.ForeColor:=clSilver;
    gSendTotal.ForeColor:=clSilver;
    gSendCompleted.ForeColor:=clSilver;

    lSendTime.Caption:='DONE. Completed in '+myUI.Send_TotalTime;
    lSendSpeed.Caption:=Format('Speed: %.0n Kbps',[myUI.Send_KBit/1]);
    end
  else if myUI.Send_BytesComplete>0 then
    begin
    lSendSpeed.Caption:=Format('Speed: %.0n Kbps',[myUI.Send_KBit/1]);
    lSendTime.Caption:='Estimated completion in '+myUI.Send_ETA;
    end
  else
    begin
    lSendSpeed.Caption:='';
    lSendTime.Caption:='';
    end;
  end;

procedure TrdFileTransfer.lSendFromFolderClick(Sender: TObject);
  var
    SrcFolder:String;
  begin
  if assigned(myUI.Module) then
    begin
    SrcFolder:=lSendFromFolder.Caption;
    ShellExecute(handle, 'open', PChar(SrcFolder), nil,nil,SW_SHOW);
    end;
  end;

procedure TrdFileTransfer.SetBrowser(const Value: boolean);
  begin
  FBrowser := Value;
  btnExplore.Enabled:=FBrowser;
  end;

procedure TrdFileTransfer.DownPanelClick(Sender: TObject);
  begin
  if FBrowser then
    begin
    if not assigned(MyBrowser) then
      begin
      MyBrowser:=TrdFileBrowser.Create(nil);
      MyBrowser.BeforeClose:=FileBrowserClose;
      MyBrowser.Show;
      MyBrowser.UI:=myUI;
      end;
    MyBrowser.BringToFront;
    end;
  end;

procedure TrdFileTransfer.FileBrowserClose(Sender: TObject);
  begin
  if assigned(MyBrowser) then
    begin
    MyBrowser.UI:=nil;
    MyBrowser:=nil;
    end;
  end;

procedure TrdFileTransfer.myUIRecvCancel(Sender: TRtcPFileTransferUI);
  begin
  lRecvFileName.Caption:='Cancelled';
  end;

procedure TrdFileTransfer.myUISendCancel(Sender: TRtcPFileTransferUI);
  begin
  lSendFileName.Caption:='Cancelled';
  end;

procedure TrdFileTransfer.btnCancelSendClick(Sender: TObject);
  begin
  if myUI.Send_FileName <> '' then
    myUI.Cancel_Send(IncludeTrailingPathDelimiter(myUI.Send_FromFolder) + myUI.Send_FileName);
  end;

procedure TrdFileTransfer.btnCancelFetchClick(Sender: TObject);
  begin
  if myUI.Recv_FileName <> '' then
    myUI.Cancel_Fetch(myUI.Recv_FileName);
  end;

end.
