unit rdSetHost;

interface

{$include rtcDefs.inc}

uses
  Windows, Messages, SysUtils, Variants,
  Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, ComCtrls,

{$IFDEF IDE_XE3up}
  UITypes,
{$ENDIF}

  dmSetRegion, ShellApi, rtcInfo,

  rtcPortalMod, rtcpFileTrans, rtcWinLogon,
  rtcpChat, rtcpDesktopConst, rtcpDesktopHost, Spin;

type
  TrdHostSettings = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Label6: TLabel;
    xAllowUsersList: TCheckBox;
    eUsers: TListView;
    btnAddUser: TButton;
    btnRemUser: TButton;
    xMayUploadAnywhere: TCheckBox;
    xMayViewDesktop: TCheckBox;
    xMayControlDesktop: TCheckBox;
    xMayUploadFiles: TCheckBox;
    xMayDownloadFiles: TCheckBox;
    xMayJoinChat: TCheckBox;
    TabSheet2: TTabSheet;
    Label19: TLabel;
    Label20: TLabel;
    eSuperUsers: TListView;
    btnAddSuperUser: TButton;
    btnRemSuperUser: TButton;
    xSuperMayViewDesktop: TCheckBox;
    xSuperMayDownloadFiles: TCheckBox;
    xSuperMayUploadAnywhere: TCheckBox;
    xSuperMayJoinChat: TCheckBox;
    xSuperMayUploadFiles: TCheckBox;
    xSuperMayControlDesktop: TCheckBox;
    TabSheet3: TTabSheet;
    Label5: TLabel;
    Label17: TLabel;
    Label14: TLabel;
    Label10: TLabel;
    xShowFullScreen: TCheckBox;
    xUseMirrorDriver: TCheckBox;
    cbColorLimit: TComboBox;
    cbFrameRate: TComboBox;
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
    xCaptureLayered: TCheckBox;
    xCaptureAllMonitors: TCheckBox;
    xUseMouseDriver: TCheckBox;
    Label1: TLabel;
    cbLowColorLimit: TComboBox;
    Label2: TLabel;
    xMayBrowseFiles: TCheckBox;
    xMayDeleteFiles: TCheckBox;
    xMayRenameFiles: TCheckBox;
    xMayExecuteCommands: TCheckBox;
    xMayMoveFiles: TCheckBox;
    xSuperMayBrowseFiles: TCheckBox;
    xSuperMayRenameFiles: TCheckBox;
    xSuperMayDeleteFiles: TCheckBox;
    xSuperMayMoveFiles: TCheckBox;
    xSuperMayExecuteCommands: TCheckBox;
    Label7: TLabel;
    Label8: TLabel;
    cbScreenBlocks: TComboBox;
    cbReduceColors: TSpinEdit;
    Label9: TLabel;
    cbScreenLimit: TComboBox;
    Label3: TLabel;
    cbScreenRefineBlocks: TComboBox;
    Label11: TLabel;
    Label12: TLabel;
    Label4: TLabel;
    xMayRenameFolders: TCheckBox;
    xMayDeleteFolders: TCheckBox;
    xMayMoveFolders: TCheckBox;
    Label13: TLabel;
    xSuperMayRenameFolders: TCheckBox;
    xSuperMayDeleteFolders: TCheckBox;
    xSuperMayMoveFolders: TCheckBox;
    Label15: TLabel;
    cbScreenRefineDelay: TComboBox;
    btnMirrorInstall: TButton;
    btnMirrorUninstall: TButton;
    Label16: TLabel;
    btnMirrorDownload: TButton;
    lblDriverCheck: TLabel;
    xMayCreateFolders: TCheckBox;
    xSuperMayCreateFolders: TCheckBox;
    Label18: TLabel;
    Label21: TLabel;
    procedure xAllowUsersListClick(Sender: TObject);
    procedure eUsersClick(Sender: TObject);
    procedure btnAddUserClick(Sender: TObject);
    procedure btnRemUserClick(Sender: TObject);
    procedure eSuperUsersClick(Sender: TObject);
    procedure btnAddSuperUserClick(Sender: TObject);
    procedure btnRemSuperUserClick(Sender: TObject);
    procedure xSendAllChangesClick(Sender: TObject);
    procedure xUseMirrorDriverClick(Sender: TObject);
    procedure cbColorLimitChange(Sender: TObject);
    procedure cbFrameRateChange(Sender: TObject);
    procedure xShowFullScreenClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure xCaptureLayeredClick(Sender: TObject);
    procedure lblMirrorClick(Sender: TObject);
    procedure cbLowColorLimitChange(Sender: TObject);
    procedure btnMirrorInstallClick(Sender: TObject);
    procedure btnMirrorUninstallClick(Sender: TObject);
  private
    { Private declarations }
    ScreenRegionSet,
    NewScreenConfig:boolean;

    procedure Setup;

  public
    { Public declarations }
    PClient:TAbsPortalClient;
    PFileTrans:TRtcPFileTransfer;
    PChat:TRtcPChat;
    PDesktop:TRtcPDesktopHost;

    procedure Execute;
  end;

implementation

{$R *.dfm}

{ TrdHostParams }

procedure TrdHostSettings.Execute;
  begin
  Setup;
  Show;
  end;

procedure TrdHostSettings.Setup;
  var
    i:integer;
    el:TListItem;
  begin
  xAllowUsersList.Checked:=PClient.gRestrictAccess;
  eUsers.Clear;
  for i := 0 to PClient.GUsers.Count - 1 do
    begin
    el:=eUsers.Items.Add;
    el.Caption:=PClient.GUsers.Strings[i];
    end;
  eSuperUsers.Clear;
  for i := 0 to PClient.GSuperUsers.Count - 1 do
    begin
    el:=eSuperUsers.Items.Add;
    el.Caption:=PClient.GSuperUsers.Strings[i];
    end;

  if assigned(PDesktop) then
    begin
    xMayViewDesktop.Checked:=PDesktop.GAllowView;
    xMayControlDesktop.Checked:=PDesktop.GAllowControl;
    xSuperMayViewDesktop.Checked:=PDesktop.GAllowView_Super;
    xSuperMayControlDesktop.Checked:=PDesktop.GAllowControl_Super;

    if PDesktop.MirrorDriverInstalled then
      begin
      lblDriverCheck.Caption:='(installed and ready)';
      btnMirrorDownload.Enabled:=False;
      btnMirrorInstall.Enabled:=False;
      btnMirrorUninstall.Enabled:=File_Exists(ExtractFilePath(AppFileName)+'\VideoDriver\Uninstall.bat');
      end
    else
      begin
      lblDriverCheck.Caption:='(driver NOT installed)';
      btnMirrorInstall.Enabled:=File_Exists(ExtractFilePath(AppFileName)+'\VideoDriver\Install.bat');
      btnMirrorDownload.Enabled:=not btnMirrorInstall.Enabled;
      btnMirrorUnInstall.Enabled:=False;
      end;
    xUseMirrorDriver.Checked:=PDesktop.GUseMirrorDriver;
    xUseMouseDriver.Checked:=PDesktop.GUseMouseDriver;

    xCaptureLayered.Checked:=PDesktop.GCaptureLayeredWindows;
    xCaptureAllMonitors.Checked:=PDesktop.GCaptureAllMonitors;
    xShowFullScreen.Checked:=PDesktop.GFullScreen;
    cbColorLimit.ItemIndex:=Ord(PDesktop.GColorLimit);
    cbFrameRate.ItemIndex:=Ord(PDesktop.GFrameRate);
    cbLowColorLimit.ItemIndex:=Ord(PDesktop.GColorLowLimit);
    cbReduceColors.Value:=PDesktop.GColorReducePercent;
    cbScreenBlocks.ItemIndex:=Ord(PDesktop.GSendScreenInBlocks);
    cbScreenRefineBlocks.ItemIndex:=Ord(PDesktop.GSendScreenRefineBlocks);
    cbScreenRefineDelay.ItemIndex:=PDesktop.GSendScreenRefineDelay;
    cbScreenLimit.ItemIndex:=Ord(PDesktop.GSendScreenSizeLimit);

    cbReduceColors.Enabled:=cbLowColorLimit.ItemIndex>0;
    if cbReduceColors.Enabled then
      cbReduceColors.Color:=clWindow
    else
      cbReduceColors.Color:=clBtnFace;
    end;
  if assigned(PChat) then
    begin
    xMayJoinChat.Checked:=PChat.GAllowJoin;
    xSuperMayJoinChat.Checked:=PChat.GAllowJoin_Super;
    end;
  if assigned(PFileTrans) then
    begin
    xMayBrowseFiles.Checked:=PFileTrans.GAllowBrowse;
    xMayUploadFiles.Checked:=PFileTrans.GAllowUpload;
    xMayDownloadFiles.Checked:=PFileTrans.GAllowDownload;
    xMayUploadAnywhere.Checked:=PFileTrans.GUploadAnywhere;

    xMayRenameFiles.Checked:=PFileTrans.GAllowFileRename;
    xMayMoveFiles.Checked:=PFileTrans.GAllowFileMove;
    xMayDeleteFiles.Checked:=PFileTrans.GAllowFileDelete;

    xMayCreateFolders.Checked:=PFileTrans.GAllowFolderCreate;
    xMayRenameFolders.Checked:=PFileTrans.GAllowFolderRename;
    xMayMoveFolders.Checked:=PFileTrans.GAllowFolderMove;
    xMayDeleteFolders.Checked:=PFileTrans.GAllowFolderDelete;
    xMayExecuteCommands.Checked:=PFileTrans.GAllowShellExecute;

    xSuperMayBrowseFiles.Checked:=PFileTrans.GAllowBrowse_Super;
    xSuperMayUploadFiles.Checked:=PFileTrans.GAllowUpload_Super;
    xSuperMayDownloadFiles.Checked:=PFileTrans.GAllowDownload_Super;
    xSuperMayUploadAnywhere.Checked:=PFileTrans.GUploadAnywhere_Super;

    xSuperMayRenameFiles.Checked:=PFileTrans.GAllowFileRename_Super;
    xSuperMayMoveFiles.Checked:=PFileTrans.GAllowFileMove_Super;
    xSuperMayDeleteFiles.Checked:=PFileTrans.GAllowFileDelete_Super;

    xSuperMayCreateFolders.Checked:=PFileTrans.GAllowFolderCreate_Super;
    xSuperMayRenameFolders.Checked:=PFileTrans.GAllowFolderRename_Super;
    xSuperMayMoveFolders.Checked:=PFileTrans.GAllowFolderMove_Super;
    xSuperMayDeleteFolders.Checked:=PFileTrans.GAllowFolderDelete_Super;
    xSuperMayExecuteCommands.Checked:=PFileTrans.GAllowShellExecute_Super;
    end;

  if PClient.Active then
    begin
    xAllowUsersList.Enabled:=False;
    eUsers.Enabled:=False;
    btnAddUser.Enabled:=False;
    btnRemUser.Enabled:=False;
    end
  else
    begin
    xAllowUsersList.Enabled:=True;
    eUsers.Enabled:=xAllowUsersList.Checked;
    btnAddUser.Enabled:=eUsers.Enabled;
    btnRemUser.Enabled:=False;
    end;

  if assigned(PDesktop) then
    begin
    ScreenRegionSet:=PClient.Active or (PDesktop.ScreenRect.Left<PDesktop.ScreenRect.Right);
    NewScreenConfig:=not ScreenRegionSet;
    end
  else
    begin
    NewScreenConfig:=False;
    ScreenRegionSet:=True;
    end;
  end;

procedure TrdHostSettings.xAllowUsersListClick(Sender: TObject);
  begin
  if xAllowUsersList.Checked then
    begin
    eUsers.Enabled:=True;
    eUsers.Color:=clWindow;
    btnAddUser.Enabled:=True;
    if eUsers.Items.Count>0 then
      begin
      eUsers.ItemIndex:=0;
      btnRemUser.Enabled:=True;
      end;
    end
  else
    begin
    eUsers.Enabled:=False;
    eUsers.Color:=clBtnFace;
    btnAddUser.Enabled:=False;
    btnRemUser.Enabled:=False;
    end;
  end;

procedure TrdHostSettings.eUsersClick(Sender: TObject);
  begin
  if (eUsers.ItemIndex>=0) and (eUsers.Items[eUsers.ItemIndex].Caption<>'') then
    btnRemUser.Enabled:=True
  else
    btnRemUser.Enabled:=False;
  end;

procedure TrdHostSettings.btnAddUserClick(Sender: TObject);
  var
    uname:string;
    a:integer;
    have:boolean;
    el:TListItem;
  begin
  uname:='';
  if InputQuery('Allow Access for User','Username',uname) then
    begin
    uname:=Trim(uname);
    if uname<>'' then
      begin
      have:=False;
      for a := 0 to eUsers.Items.Count - 1 do
        if eUsers.Items[a].Caption=uname then
          begin
          have:=True;
          Break;
          end;
      if not have then
        begin
        el:=eUsers.Items.Add;
        el.Caption:=uname;
        el.Update;
        end;
      end;
    end;
  end;

procedure TrdHostSettings.btnRemUserClick(Sender: TObject);
  var
    uname:string;
  begin
  if eUsers.ItemIndex>=0 then
    begin
    uname:=eUsers.Items[eUsers.ItemIndex].Caption;
    if uname<>'' then
      eUsers.Items.Delete(eUsers.ItemIndex);
    end;
  end;

procedure TrdHostSettings.eSuperUsersClick(Sender: TObject);
  begin
  if (eSuperUsers.ItemIndex>=0) and (eSuperUsers.Items[eSuperUsers.ItemIndex].Caption<>'') then
    btnRemSuperUser.Enabled:=True
  else
    btnRemSuperUser.Enabled:=False;
  end;

procedure TrdHostSettings.btnAddSuperUserClick(Sender: TObject);
  var
    uname:string;
    a:integer;
    have:boolean;
    el:TListItem;
  begin
  uname:='';
  if InputQuery('Add new Super User to the list','Username',uname) then
    begin
    uname:=Trim(uname);
    if uname<>'' then
      begin
      have:=False;
      for a := 0 to eSuperUsers.Items.Count - 1 do
        if eSuperUsers.Items[a].Caption=uname then
          begin
          have:=True;
          Break;
          end;
      if not have then
        begin
        el:=eSuperUsers.Items.Add;
        el.Caption:=uname;
        el.Update;
        end;
      end;
    end;
  end;

procedure TrdHostSettings.btnRemSuperUserClick(Sender: TObject);
  var
    uname:string;
  begin
  if eSuperUsers.ItemIndex>=0 then
    begin
    uname:=eSuperUsers.Items[eSuperUsers.ItemIndex].Caption;
    if uname<>'' then
      eSuperUsers.Items.Delete(eSuperUsers.ItemIndex);
    end;
  end;

procedure TrdHostSettings.xSendAllChangesClick(Sender: TObject);
  begin
  NewScreenConfig:=True;
  end;

procedure TrdHostSettings.xUseMirrorDriverClick(Sender: TObject);
  begin
  NewScreenConfig:=True;
  end;

procedure TrdHostSettings.cbColorLimitChange(Sender: TObject);
  begin
  NewScreenConfig:=True;
  end;

procedure TrdHostSettings.cbLowColorLimitChange(Sender: TObject);
  begin
  NewScreenConfig:=True;
  cbReduceColors.Enabled:=cbLowColorLimit.ItemIndex>0;
  if cbReduceColors.Enabled then
    cbReduceColors.Color:=clWindow
  else
    cbReduceColors.Color:=clBtnFace;
  end;

procedure TrdHostSettings.cbFrameRateChange(Sender: TObject);
  begin
  NewScreenConfig:=True;
  end;

procedure TrdHostSettings.xCaptureLayeredClick(Sender: TObject);
  begin
  NewScreenConfig:=True;
  end;

procedure TrdHostSettings.xShowFullScreenClick(Sender: TObject);
  begin
  NewScreenConfig:=True;
  ScreenRegionSet:=False;
  end;

procedure TrdHostSettings.btnOKClick(Sender: TObject);
  var
    R:TRect;
    selRegion:TdmSelectRegion;
    a:integer;
    sl:TStringList;
  begin
  if NewScreenConfig then
    begin
    if xShowFullScreen.Checked then
      R:=Rect(0,0,Screen.Width,Screen.Height)
    else if not ScreenRegionSet then
      begin
      if MessageDlg('Limit Visible Desktop Region?'#13#10#13#10+
                    'Click "YES" and select a region with your mouse, or'#13#10+
                    'Click "NO" to show your Primary Screen to remote users.',
                    mtConfirmation,[mbYes,mbNo],0)=mrYes then
        begin
        WindowState:=wsMinimized;
        try
          Sleep(500);
          selRegion:=TdmSelectRegion.Create(nil);
          try
            R:=selRegion.GrabScreen(xCaptureAllMonitors.Checked);
          finally
            SelRegion.Free;
            end;
        finally
          WindowState:=wsNormal;
          end;
        end
      else
        R:=Rect(0,0,Screen.Width,Screen.Height);
      end;
    end;

  PClient.GRestrictAccess:=xAllowUsersList.Checked;

  sl:=TStringList.Create;
  try
    for a := 0 to eUsers.Items.Count - 1 do
      sl.Add(eUsers.Items[a].Caption);
    PClient.GUsers:=sl;
  finally
    sl.Free;
    end;

  sl:=TStringList.Create;
  try
    for a := 0 to eSuperUsers.Items.Count - 1 do
      sl.Add(eSuperUsers.Items[a].Caption);
    PClient.GSuperUsers:=sl;
  finally
    sl.Free;
    end;

  if assigned(PChat) then
    begin
    PChat.GAllowJoin:=xMayJoinChat.Checked;
    PChat.GAllowJoin_Super:=xSuperMayJoinChat.Checked;
    end;

  if assigned(PFileTrans) then
    begin
    PFileTrans.GAllowBrowse:=xMayBrowseFiles.Checked;
    PFileTrans.GAllowUpload:=xMayUploadFiles.Checked;
    PFileTrans.GAllowDownload:=xMayDownloadFiles.Checked;
    PFileTrans.GUploadAnywhere:=xMayUploadAnywhere.Checked;

    PFileTrans.GAllowBrowse_Super:=xSuperMayBrowseFiles.Checked;
    PFileTrans.GAllowUpload_Super:=xSuperMayUploadFiles.Checked;
    PFileTrans.GAllowDownload_Super:=xSuperMayDownloadFiles.Checked;
    PFileTrans.GUploadAnywhere_Super:=xSuperMayUploadAnywhere.Checked;

    PFileTrans.GAllowFileRename:=xMayRenameFiles.Checked;
    PFileTrans.GAllowFileMove:=xMayMoveFiles.Checked;
    PFileTrans.GAllowFileDelete:=xMayDeleteFiles.Checked;

    PFileTrans.GAllowFolderCreate:=xMayCreateFolders.Checked;
    PFileTrans.GAllowFolderRename:=xMayRenameFolders.Checked;
    PFileTrans.GAllowFolderMove:=xMayMoveFolders.Checked;
    PFileTrans.GAllowFolderDelete:=xMayDeleteFolders.Checked;
    PFileTrans.GAllowShellExecute:=xMayExecuteCommands.Checked;

    PFileTrans.GAllowFileRename_Super:=xSuperMayRenameFiles.Checked;
    PFileTrans.GAllowFileMove_Super:=xSuperMayMoveFiles.Checked;
    PFileTrans.GAllowFileDelete_Super:=xSuperMayDeleteFiles.Checked;

    PFileTrans.GAllowFolderCreate_Super:=xSuperMayCreateFolders.Checked;
    PFileTrans.GAllowFolderRename_Super:=xSuperMayRenameFolders.Checked;
    PFileTrans.GAllowFolderMove_Super:=xSuperMayMoveFolders.Checked;
    PFileTrans.GAllowFolderDelete_Super:=xSuperMayDeleteFolders.Checked;
    PFileTrans.GAllowShellExecute_Super:=xSuperMayExecuteCommands.Checked;
    end;

  if assigned(PDesktop) then
    begin
    PDesktop.GAllowView:=xMayViewDesktop.Checked;
    PDesktop.GAllowControl:=xMayControlDesktop.Checked;
    PDesktop.GAllowView_Super:=xSuperMayViewDesktop.Checked;
    PDesktop.GAllowControl_Super:=xSuperMayControlDesktop.Checked;

    if NewScreenConfig then
      begin
      PDesktop.GUseMirrorDriver:=xUseMirrorDriver.Checked;
      PDesktop.GUseMouseDriver:=xUseMouseDriver.Checked;
      PDesktop.GCaptureLayeredWindows:=xCaptureLayered.Checked;
      PDesktop.GCaptureAllMonitors:=xCaptureAllMonitors.Checked;
      PDesktop.GColorLimit:=TrdColorLimit(cbColorLimit.ItemIndex);
      PDesktop.GColorLowLimit:=TrdLowColorLimit(cbLowColorLimit.ItemIndex);
      PDesktop.GColorReducePercent:=cbReduceColors.Value;
      PDesktop.GFrameRate:=TrdFrameRate(cbFrameRate.ItemIndex);
      PDesktop.GSendScreenInBlocks:=TrdScreenBlocks(cbScreenBlocks.ItemIndex);
      PDesktop.GSendScreenRefineBlocks:=TrdScreenBlocks(cbScreenRefineBlocks.ItemIndex);
      PDesktop.GSendScreenRefineDelay:=cbScreenRefineDelay.ItemIndex;
      PDesktop.GSendScreenSizeLimit:=TrdScreenLimit(cbScreenLimit.ItemIndex);

      PDesktop.GFullScreen:=xShowFullScreen.Checked;
      if not ScreenRegionSet then
        PDesktop.ScreenRect:=R;

      if PClient.Active then
        PDesktop.Restart;
      end;
    end;

  Close;
  end;

procedure TrdHostSettings.btnCancelClick(Sender: TObject);
  begin
  Close;
  end;

procedure TrdHostSettings.lblMirrorClick(Sender: TObject);
  begin
  ShowMessage('Go to http://www.demoforge.com/DFMirage.htm to download the driver.'#13#10+
              'After you download DFMirage Setup exe, please install it manually.'#13#10+
              'Install and Uninstall buttons in Host Settings are only used when'#13#10+
              'the Video Mirror Driver is deployed together with the Host exe.');

  ShellExecute(handle, 'open', 'http://www.demoforge.com/dfmirage.htm',nil,nil,SW_SHOW);
  end;

procedure TrdHostSettings.btnMirrorInstallClick(Sender: TObject);
  var
    cnt:integer;
    found32,found64,done:boolean;
  begin
  ShellExecute(handle, 'open', PChar(ExtractFilePath(AppFileName)+'\VideoDriver\Install.bat'), nil,nil, SW_SHOW);

  { MirrInst32.exe or MirrInst64.exe will be used to install the mirror driver,
    so ... we will first wait up to 3 seconds for any exe to start ... }
  cnt:=3*5;
  repeat
    found32 := rtcGetProcessID('MirrInst32.exe')>0;
    found64 := rtcGetProcessID('MirrInst64.exe')>0;
    if found32 or found64 then Break;
    Sleep(200);
    Dec(cnt);
    until cnt=0;

  if found32 then
    begin
    { If the exe was started, we will wait up to 30 seconds
      for the mirror driver installation to finish ... }
    cnt:=60;
    repeat
      done := rtcGetProcessID('MirrInst32.exe')<=0;
      if done then Break;
      Sleep(500);
      Dec(cnt);
      until cnt=0;
    end
  else if found64 then
    begin
    { If the exe was started, we will wait up to 30 seconds
      for the mirror driver installation to finish ... }
    cnt:=60;
    repeat
      done := rtcGetProcessID('MirrInst64.exe')<=0;
      if done then Break;
      Sleep(500);
      Dec(cnt);
      until cnt=0;
    end
  else
    done:=True;

  { And at the end, we will check if the driver is installed and ready. }
  if not PDesktop.MirrorDriverInstalled(true) then
    begin
    lblDriverCheck.Caption:='(driver NOT ready)';
    btnMirrorInstall.Enabled:=False;
    btnMirrorDownload.Enabled:=False;
    btnMirrorUnInstall.Enabled:=False;
    if not (found32 or found64) then
      ShowMessage('Error locating installation files.')
    else if not done then
      ShowMessage('The installation seems to be taking too long.'#13#10+
                  'Please click OK when the installation completes.')
    else
      ShowMessage('Mirror Driver installation is not yet finished.'#13#10+
                  'To complete Video Mirror Driver installation,'#13#10+
                  'please Log OFF and back ON, or reboot Windows.');
    end;

  if PDesktop.MirrorDriverInstalled(true) then
    begin
    lblDriverCheck.Caption:='(installed and ready)';
    btnMirrorDownload.Enabled:=False;
    btnMirrorInstall.Enabled:=False;
    btnMirrorUninstall.Enabled:=File_Exists(ExtractFilePath(AppFileName)+'\VideoDriver\Uninstall.bat');
    ShowMessage('Mirror Driver is installed and ready.');
    end
  else if not done then
    ShowMessage('Installation failed.');
  end;

procedure TrdHostSettings.btnMirrorUninstallClick(Sender: TObject);
  begin
  ShellExecute(handle, 'open', PChar(ExtractFilePath(AppFileName)+'\VideoDriver\Uninstall.bat'), nil,nil, SW_SHOW);
  end;

end.
