unit rdDesktopSave;

interface

uses
  Windows, SysUtils, Classes, Graphics, jpeg,

  rtcSystem, rtcInfo, rtcpDesktopControlUI,
  rtcPortalMod, rtcpDesktopControl;

type
  TrdDesktopSaver = class(TDataModule)
    myUI: TRtcPDesktopControlUI;
    procedure myUIData(Sender: TRtcPDesktopControlUI);
    procedure myUIClose(Sender: TRtcPDesktopControlUI);
    procedure myUIError(Sender: TRtcPDesktopControlUI);
    procedure myUILogOut(Sender: TRtcPDesktopControlUI);
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);

  private
    { Private declarations }
    FToFolder: string;
    FBmpImage:TBitmap;
    FJpgImage:TJPEGImage;
    FImageFile: string;
    FQuality: integer;
    procedure SetToFolder(const Value: string);

  public
    { Public declarations }
    property ToFolder:string read FToFolder write SetToFolder;
    property Quality:integer read FQuality write FQuality;
    property UI:TRtcPDesktopControlUI read myUI;
  end;

implementation

{$R *.dfm}

procedure TrdDesktopSaver.DataModuleCreate(Sender: TObject);
  begin
  ToFolder:='';
  Quality:=80;
  end;

procedure TrdDesktopSaver.SetToFolder(const Value: string);
  begin
  FToFolder := Value;
  if FToFolder='' then
    FToFolder:=ExtractFilePath(AppFileName)+'\SAVE';
  if not DirectoryExists(FToFolder) then
    ForceDirectories(FToFolder);
  if Copy(FToFolder,length(FToFolder),1)<>'\' then
    FToFolder:=FToFolder+'\';
  end;

procedure TrdDesktopSaver.myUIData(Sender: TRtcPDesktopControlUI);
  begin
  if Sender.HaveScreen then
    begin
    { save Desktop image to a file ... }

    if not assigned(FBmpImage) then
      begin
      FBmpImage:=TBitmap.Create;
      FbmpImage.PixelFormat:=pf32bit;
      end;
    FbmpImage.Width:=Sender.ScreenWidth;
    FbmpImage.Height:=Sender.ScreenHeight;
    Sender.DrawScreen(FbmpImage.Canvas, FbmpImage.Width, FBmpImage.Height);

    if not assigned(FjpgImage) then
      FjpgImage:=TJPEGImage.Create;

    FjpgImage.CompressionQuality:=FQuality;
    FjpgImage.Assign(FbmpImage);
    FImageFile := ToFolder+Sender.UserName+'.jpg';

    FjpgImage.SaveToFile(ChangeFileExt(FImageFile,'.new'));
    Delete_File(FImageFile);
    Rename_File(ChangeFileExt(FImageFile,'.new'),FImageFile);
    end;
  end;

procedure TrdDesktopSaver.myUIClose(Sender: TRtcPDesktopControlUI);
  begin
  if Sender.CloseAndClear then Free;
  end;

procedure TrdDesktopSaver.myUIError(Sender: TRtcPDesktopControlUI);
  begin
  if Sender.CloseAndClear then Free;
  end;

procedure TrdDesktopSaver.myUILogOut(Sender: TRtcPDesktopControlUI);
  begin
  if Sender.CloseAndClear then Free;
  end;

procedure TrdDesktopSaver.DataModuleDestroy(Sender: TObject);
  begin
  if assigned(FbmpImage) then
    begin
    FBmpImage.Free;
    FBmpImage:=nil;
    end;
  if assigned(FJpgImage) then
    begin
    FJpgImage.Free;
    FJpgImage:=nil;
    end;
  if FImageFile<>'' then
    DeleteFile(FImageFile);
  end;

end.
