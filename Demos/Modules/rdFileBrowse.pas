unit rdFileBrowse;

interface

{$include rtcDefs.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes,
  Graphics, Controls, Forms, Dialogs, StdCtrls,
  Buttons, ComCtrls, ExtCtrls,

{$IFDEF IDE_XE3up}
  UITypes,
{$ENDIF}

  rtcpFileExplore, rtcpFileTransUI, ShellAPI, Menus;

type
  TrdFileBrowser = class(TForm)
    Panel1: TPanel;
    Panel3: TPanel;
    eDirectory: TEdit;
    eFilesList: TRtcPFileExplorer;
    btnReload: TSpeedButton;
    Panel5: TPanel;
    btnViewStyle: TSpeedButton;
    DownLabel: TLabel;
    btnBack: TSpeedButton;
    pmFiles: TPopupMenu;
    mnNewFolder: TMenuItem;
    mnRefresh: TMenuItem;
    N2: TMenuItem;
    mnDelete: TMenuItem;
    mnDownload: TMenuItem;
    N1: TMenuItem;
    Panel2: TPanel;
    eCommand: TEdit;
    btnExecute: TSpeedButton;
    eParams: TEdit;
    btnDownload: TImage;
    procedure FormCreate(Sender: TObject);
    procedure MyOnFileList(Sender:TRtcPFileTransferUI);
    procedure eFilesListDirectoryChange(Sender: TObject; const FileName: String);
    procedure btnReloadClick(Sender: TObject);
    procedure btnViewStyleClick(Sender: TObject);
    procedure eDirectoryKeyPress(Sender: TObject; var Key: Char);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure DownLabelDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure DownLabelDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure eFilesListDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure eFilesListFileOpen(Sender: TObject; const FileName: String);
    procedure btnBackClick(Sender: TObject);
    procedure mnRefreshClick(Sender: TObject);
    procedure mnNewFolderClick(Sender: TObject);
    procedure eFilesListEdited(Sender: TObject; Item: TListItem;
      var S: String);
    procedure eFilesListEditing(Sender: TObject; Item: TListItem;
      var AllowEdit: Boolean);
    procedure mnDownloadClick(Sender: TObject);
    procedure mnDeleteClick(Sender: TObject);
    procedure eFilesListSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure btnExecuteClick(Sender: TObject);
    procedure eFilesListDragDrop(Sender, Source: TObject; X, Y: Integer);

  private
    MyUI:TRtcPFileTransferUI;
    FBeforeClose: TNotifyEvent;
    function GetUI: TRtcPFileTransferUI;
    procedure SetUI(const Value: TRtcPFileTransferUI);
    { Private declarations }

  protected
    // declare our DROPFILES message handler
    procedure AcceptFiles( var msg : TMessage ); message WM_DROPFILES;
    procedure CreateParams(Var params: TCreateParams); override;

  public
    { Public declarations }
    property UI:TRtcPFileTransferUI read GetUI write SetUI;
    property BeforeClose:TNotifyEvent read FBeforeClose write FBeforeClose;
  end;

implementation

{$R *.dfm}

procedure TrdFileBrowser.CreateParams(Var params: TCreateParams);
  begin
  inherited CreateParams( params );
  params.ExStyle := params.ExStyle or WS_EX_APPWINDOW;
  params.WndParent := GetDeskTopWindow;
  end;

procedure TrdFileBrowser.AcceptFiles( var msg : TMessage );
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
        myUI.Send(myFileName,eDirectory.Text);
        end;
      end;
  finally
    // let Windows know that you're done
    DragFinish( msg.WParam );
    end;
  end;

procedure TrdFileBrowser.FormCreate(Sender: TObject);
  begin
  // tell Windows that you're
  // accepting drag and drop files
  DragAcceptFiles( Handle, True );

  DownLabel.Caption:=DownLabel.Caption+#13#10+
                     'Drag Files or Folders from the remote File Explorer (above) HERE to download them to your INBOX folder.';
  end;

function TrdFileBrowser.GetUI: TRtcPFileTransferUI;
  begin
  Result:=MyUI;
  end;

procedure TrdFileBrowser.SetUI(const Value: TRtcPFileTransferUI);
  begin
  if Value<>MyUI then
    begin
    if assigned(myUI) then
      MyUI.OnFileList:=nil;
    myUI:=Value;
    if assigned(myUI) then
      begin
      Caption:=myUI.UserName+' - File Explorer';
      MyUI.OnFileList:=MyOnFileList;
      myUI.GetFileList('',''); // load remote drives list to initialize
      end;
    end;
  end;

procedure TrdFileBrowser.MyOnFileList(Sender: TRtcPFileTransferUI);
  begin
  eDirectory.Text:=Sender.FolderName;
  eFilesList.UpdateFileList(Sender.FolderName,Sender.FolderData);
  end;

procedure TrdFileBrowser.eFilesListDirectoryChange(Sender: TObject; const FileName: String);
  begin
  if assigned(myUI) then
    myUI.GetFileList(FileName,'');
  end;

procedure TrdFileBrowser.btnReloadClick(Sender: TObject);
  begin
  if assigned(myUI) then
    myUI.GetFileList(eDirectory.Text,'');
  end;

procedure TrdFileBrowser.btnViewStyleClick(Sender: TObject);
  begin
  eFilesList.RefreshColumns; // a work-around for D2009 AV bug
  case eFilesList.ViewStyle of
    vsIcon: eFilesList.ViewStyle:=vsSmallIcon;
    vsSmallIcon: eFilesList.ViewStyle:=vsList;
    vsList: eFilesList.ViewStyle:=vsReport;
    else eFilesList.ViewStyle:=vsIcon;
    end;
  eFilesList.RefreshColumns; // a work-around for D2009 non-updating view
  end;

procedure TrdFileBrowser.eDirectoryKeyPress(Sender: TObject; var Key: Char);
  begin
  if Key=#13 then
    begin
    Key:=#0;
    btnReloadClick(Sender);
    end;
  end;

procedure TrdFileBrowser.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  begin
  if assigned(FBeforeClose) then
    FBeforeClose(Self);
  CanClose:=True;
  end;

procedure TrdFileBrowser.FormClose(Sender: TObject; var Action: TCloseAction);
  begin
  Action:=caFree;
  end;

procedure TrdFileBrowser.FormDestroy(Sender: TObject);
  begin
  DragAcceptFiles(Handle, False);
  end;

procedure TrdFileBrowser.DownLabelDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
  begin
  Accept:=(Source=eFilesList) and (eFilesList.Directory<>'');
  end;

procedure TrdFileBrowser.DownLabelDragDrop(Sender, Source: TObject; X, Y: Integer);
  var
    myFiles:TStringList;
    a:integer;
  begin
  if assigned(myUI) then
    begin
    myFiles:=eFilesList.SelectedFiles;
    if myFiles.Count>0 then
      for a:=0 to myFiles.Count-1 do
        myUI.Fetch(myFiles.Strings[a]);
    end;
  end;

procedure TrdFileBrowser.eFilesListFileOpen(Sender: TObject; const FileName: String);
  begin
  if assigned(myUI) then
    if MessageDlg('Download file'#13#10+'"'+FileName+'"?',mtConfirmation,[mbYes,mbNo],0)=mrYes then
      myUI.Fetch(FileName);
  end;

procedure TrdFileBrowser.btnBackClick(Sender: TObject);
  begin
  eFilesList.OneLevelUp;
  end;

procedure TrdFileBrowser.mnRefreshClick(Sender: TObject);
  begin
  btnReloadClick(Sender);
  end;

procedure TrdFileBrowser.mnNewFolderClick(Sender: TObject);
  begin
  if assigned(myUI) and (eFilesList.Directory<>'') then
    begin
    myUI.Cmd_NewFolder(IncludeTrailingBackslash(eFilesList.Directory)+'New Folder');
    myUI.GetFileList(eFilesList.Directory,'');
    end;
  end;

procedure TrdFileBrowser.eFilesListEdited(Sender: TObject; Item: TListItem; var S: String);
  var
    dir, newS:String;
  begin
  if assigned(myUI) then
    begin
    dir:=eFilesList.GetFileName(Item);
    if (dir<>'') and (dir<>'..') then
      begin
      eFilesList.SetFileName(Item,S);
      newS:=ExtractFilePath(dir)+S;
      myUI.Cmd_FileRename(dir, newS);
      eCommand.Text:=S;
      end;
    end;
  end;

procedure TrdFileBrowser.eFilesListEditing(Sender: TObject; Item: TListItem; var AllowEdit: Boolean);
  begin
  AllowEdit:=assigned(myUI) and (eFilesList.Directory<>'') and (Item.Caption<>'..');
  end;

procedure TrdFileBrowser.mnDownloadClick(Sender: TObject);
  var
    myFiles:TStringList;
    a:integer;
  begin
  if assigned(myUI) then
    begin
    myFiles:=eFilesList.SelectedFiles;
    if myFiles.Count>0 then
      for a:=0 to myFiles.Count-1 do
        myUI.Fetch(myFiles.Strings[a]);
    end;
  end;

procedure TrdFileBrowser.mnDeleteClick(Sender: TObject);
  var
    myFiles:TStringList;
    s:String;
    a:integer;
  begin
  if assigned(myUI) then
    begin
    myFiles:=eFilesList.SelectedFiles;
    if myFiles.Count>0 then
      begin
      s:='Delete the following File(s) and/or Folder(s)?';
      for a:=0 to myFiles.Count-1 do
        s:=s+#13#10+ExtractFileName(myFiles.Strings[a]);

      if MessageDlg(s,mtWarning,[mbYes,mbNo],0)=mrYes then
        begin
        for a:=0 to myFiles.Count-1 do
          myUI.Cmd_FileDelete(myFiles.Strings[a]);
        myUI.GetFileList(eFilesList.Directory,'');
        end;
      end;
    end;
  end;

procedure TrdFileBrowser.eFilesListSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
  begin
  if Selected and (eFilesList.GetFileName(Item)<>'..') then
    eCommand.Text:=ExtractFileName(eFilesList.GetFileName(Item))
  else
    eCommand.Text:='';
  end;

procedure TrdFileBrowser.btnExecuteClick(Sender: TObject);
  begin
  if assigned(myUI) then
    myUI.Cmd_Execute(IncludeTrailingBackslash(eFilesList.Directory)+eCommand.Text,eParams.Text);
  end;

procedure TrdFileBrowser.eFilesListDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
  begin
  Accept:=(Source=eFilesList) and (eFilesList.Directory<>'');
  end;

procedure TrdFileBrowser.eFilesListDragDrop(Sender, Source: TObject; X, Y: Integer);
  var
    myFiles:TStringList;
    newDir:String;
    a:integer;
  begin
  if assigned(myUI) then
    begin
    newDir:=eFilesList.GetFileName(eFilesList.GetItemAt(X,Y));
    if newDir<>'' then
      begin
      if newDir='..' then
        newDir:=IncludeTrailingBackslash(eFilesList.Directory)+'..\'
      else
        newDir:=IncludeTrailingBackslash(newDir);
      myFiles:=eFilesList.SelectedFiles;
      if myFiles.Count>0 then
        begin
        for a:=0 to myFiles.Count-1 do
          myUI.Cmd_FileMove(myFiles.Strings[a],newDir+ExtractFileName(myFiles.Strings[a]));
        myUI.GetFileList(eFilesList.Directory,'');
        end;
      end;
    end;
  end;

end.
