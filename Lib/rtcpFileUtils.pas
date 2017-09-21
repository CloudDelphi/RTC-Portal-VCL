{ Copyright 2004-2017 (c) RealThinClient.com (http://www.realthinclient.com)
  Copyright © 1999,2003 Michal Mutl (http://www.mitec.cz) }

unit rtcpFileUtils;

interface

{$INCLUDE rtcPortalDefs.inc}
{$INCLUDE rtcDefs.inc}

uses
  Windows, SysUtils, Classes, Math, ShellAPI, rtcInfo;

type
  TRtcPMediaType = (dtUnknown, dtNotExists, dtRemovable, dtFixed, dtRemote,
    dtCDROM, dtRAMDisk);

function FileSetDate(const FileName: String; Age: Integer): Integer;

function Folder_Size(const FolderName: String): int64;

function Folder_Content(const FolderName, SubFolderName: String;
  Folder: TRtcDataSet): int64;

function File_Content(const FileName: String; Folder: TRtcDataSet): int64;

procedure GetFilesList(const FolderName, FileMask: String; Folder: TRtcDataSet);

function FormatFileSize(const Number: int64): String;

Function DelFolderTree(DirName: String): Boolean;

function FileTimeToDateTime(FT: FILETIME): TDateTime;

implementation

const
  FILE_SUPPORTS_ENCRYPTION = 32;
  FILE_SUPPORTS_OBJECT_IDS = 64;
  FILE_SUPPORTS_REPARSE_POINTS = 128;
  FILE_SUPPORTS_SPARSE_FILES = 256;
  FILE_VOLUME_QUOTAS = 512;

type
  TDiskSign = String;

  TDiskInfo = record
    MediaType: TRtcPMediaType;
    SectorsPerCluster, BytesPerSector, FreeClusters, TotalClusters,
      Serial: DWORD;
    Capacity, FreeSpace: int64;
    VolumeLabel, SerialNumber, FileSystem: String;
  end;

function FormatFileSize(const Number: int64): String;
begin
  if Number < int64(1024) * 100 then // below 100 KB - in Bytes
    Result := Format('%.0n B', [Number / 1])
  else if Number < int64(1024) * 1024 * 100 then // below 100 MB - in KB
    Result := Format('%.0n KB', [Number / 1024])
  else if Number < int64(1024) * 1024 * 1024 * 100 then // below 100 GB - in MB
    Result := Format('%.0n MB', [Number / (1024 * 1024)])
  else // above 100 GB - in GB
    Result := Format('%.0n GB', [Number / (1024 * 1024 * 1024)])
end;

Function DelFolderTree(DirName: String): Boolean;
var
  SHFileOpStruct: TSHFileOpStruct;
  DirBuf: array [0 .. 255] of char;
begin
  try
    Fillchar(SHFileOpStruct, Sizeof(SHFileOpStruct), 0);
    Fillchar(DirBuf, Sizeof(DirBuf), 0);
    StrPCopy(DirBuf, DirName);
    with SHFileOpStruct do
    begin
      Wnd := 0;
      pFrom := @DirBuf;
      wFunc := FO_DELETE;
      fFlags := FOF_ALLOWUNDO;
      fFlags := fFlags or FOF_NOCONFIRMATION;
      fFlags := fFlags or FOF_SILENT;
    end;
    Result := (SHFileOperation(SHFileOpStruct) = 0);
  except
    Result := False;
  end;
end;

function FileTimeToDateTime(FT: FILETIME): TDateTime;
var
  st: SYSTEMTIME;
  dt1, dt2: TDateTime;
begin
  FileTimeToSystemTime(FT, st);
  try
    dt1 := EncodeTime(st.whour, st.wminute, st.wsecond, st.wMilliseconds);
  except
    dt1 := 0;
  end;
  try
    dt2 := EncodeDate(st.wyear, st.wmonth, st.wday);
  except
    dt2 := 0;
  end;
  Result := dt1 + dt2;
end;

function FileSetDate(const FileName: String; Age: Integer): Integer;
var
  f: THandle;
begin
  f := FileOpen(FileName, fmOpenWrite);
  if f = THandle(-1) then
    Result := GetLastError
  else
  begin
    Result := SysUtils.FileSetDate(f, Age);
    FileClose(f);
  end;
end;

function Folder_Size(const FolderName: String): int64;
var
  sr: TSearchRec;
begin
  try
    Result := 0;
    if FindFirst(FolderName + '\*.*', faAnyFile, sr) = 0 then
      repeat
        if (sr.Name <> '.') and (sr.Name <> '..') then
        begin
          if (sr.Attr and faDirectory) = faDirectory then
            Result := Result + Folder_Size(FolderName + '\' + sr.Name)
          else
          begin
            // Result := Result + File_Size(FolderName+'\'+sr.Name);
            Result := Result + (int64(sr.FindData.nFileSizeHigh) shl 32) or
              (sr.FindData.nFileSizeLow);
          end;
        end;
      until (FindNext(sr) <> 0);
  finally
    FindClose(sr);
  end;
end;

function Folder_Content(const FolderName, SubFolderName: String;
  Folder: TRtcDataSet): int64;
var
  sr: TSearchRec;
  TempResult: int64;
begin
  try
    Result := 0;
    if FindFirst(FolderName + '\*.*', faAnyFile, sr) = 0 then
      repeat
        if (sr.Name <> '.') and (sr.Name <> '..') then
        begin
          if (sr.Attr and faDirectory) = faDirectory then
            begin
            TempResult := Folder_Content(FolderName + '\' + sr.Name, SubFolderName + sr.Name + '\', Folder);
            if TempResult = 0 then
              begin
              Folder.Append;
              Folder.asText['name'] := SubFolderName + sr.Name + '\';
              try
                Folder.asDateTime['age'] := FileDateToDateTime(sr.Time);
              except
                Folder.isNull['age'] := True;
                end;
              Folder.asInteger['attr'] := sr.Attr;
              end
            else
              Result := Result + TempResult;
            end
          else
          begin
            Folder.Append;
            Folder.asText['name'] := SubFolderName + sr.Name;
            try
              Folder.asDateTime['age'] := FileDateToDateTime(sr.Time);
            except
              Folder.isNull['age'] := True;
            end;
            Folder.asInteger['attr'] := sr.Attr;
            // Folder.asLargeInt['size']:= File_Size(FolderName+'\'+sr.Name);
            Folder.asLargeInt['size'] :=
              (int64(sr.FindData.nFileSizeHigh) shl 32) or
              (sr.FindData.nFileSizeLow);
            Result := Result + Folder.asLargeInt['size'];
          end;
        end;
      until (FindNext(sr) <> 0);
  finally
    FindClose(sr);
  end;
end;

function File_Content(const FileName: String; Folder: TRtcDataSet): int64;
var
  sr: TSearchRec;
  FolderName: String;
  TempResult: int64;
begin
  if Copy(FileName, length(FileName), 1) = '\' then
    Result := File_Content(FileName + '*.*', Folder)
  else
  begin
    FolderName := ExtractFilePath(FileName);
    if Copy(FolderName, length(FolderName), 1) = '\' then
      Delete(FolderName, length(FolderName), 1);
    try
      Result := 0;
      if FindFirst(FileName, faAnyFile, sr) = 0 then
        repeat
          if (sr.Name <> '.') and (sr.Name <> '..') then
          begin
            if (sr.Attr and faDirectory) = faDirectory then
              begin
              TempResult := Folder_Content(FolderName + '\' + sr.Name, sr.Name + '\', Folder);
              if TempResult = 0 then
                begin
                Folder.Append;
                Folder.asText['name'] := sr.Name + '\';
                try
                  Folder.asDateTime['age'] := FileDateToDateTime(sr.Time);
                except
                  Folder.isNull['age'] := True;
                  end;
                Folder.asInteger['attr'] := sr.Attr;
                end
              else
                Result := Result + TempResult;
              end
            else
            begin
              Folder.Append;
              Folder.asText['name'] := sr.Name;
              try
                Folder.asDateTime['age'] := FileDateToDateTime(sr.Time);
              except
                Folder.isNull['age'] := True;
              end;
              Folder.asInteger['attr'] := sr.Attr;
              // Folder.asLargeInt['size']:= File_Size(FolderName+'\'+sr.Name);
              Folder.asLargeInt['size'] :=
                (int64(sr.FindData.nFileSizeHigh) shl 32) or
                (sr.FindData.nFileSizeLow);
              Result := Result + Folder.asLargeInt['size'];
            end;
          end;
        until (FindNext(sr) <> 0);
    finally
      FindClose(sr);
    end;
  end;
end;

function GetDiskInfo(Value: TDiskSign): TDiskInfo;
var
  ErrorMode: Word;
  BPS, TC, FC, SPC: Integer;
  T, f: TLargeInteger;
  TF: PLargeInteger;
  bufRoot, bufVolumeLabel, bufFileSystem: pchar;
  MCL, Size, Flags: DWORD;
  s: String;
begin
  with Result do
  begin
    // Initialize structure ...
    SectorsPerCluster := 0;
    BytesPerSector := 0;
    FreeClusters := 0;
    TotalClusters := 0;
    Capacity := 0;
    FreeSpace := 0;
    VolumeLabel := '';
    SerialNumber := '';
    FileSystem := '';
    Serial := 0;

    // Try to get Drive information ...
    Size := 255;
    bufRoot := AllocMem(Size);
    try
      StrPCopy(bufRoot, Value + '\');
      case GetDriveType(bufRoot) of
        DRIVE_UNKNOWN:
          MediaType := dtUnknown;
        DRIVE_NO_ROOT_DIR:
          MediaType := dtNotExists;
        DRIVE_REMOVABLE:
          MediaType := dtRemovable;
        DRIVE_FIXED:
          MediaType := dtFixed;
        DRIVE_REMOTE:
          MediaType := dtRemote;
        DRIVE_CDROM:
          MediaType := dtCDROM;
        DRIVE_RAMDISK:
          MediaType := dtRAMDisk;
      end;
      // if (MediaType in [dtFixed,dtRemote,dtRAMDisk] ) then
      begin
        ErrorMode := SetErrorMode(SEM_FailCriticalErrors);
        try
          if GetDiskFreeSpace(bufRoot, SectorsPerCluster, BytesPerSector,
            FreeClusters, TotalClusters) then
          begin
            New(TF);
            try
              try
                SysUtils.GetDiskFreeSpaceEx(bufRoot, f, T, TF);
                Capacity := T;
                FreeSpace := f;
              except
                BPS := BytesPerSector;
                TC := TotalClusters;
                FC := FreeClusters;
                SPC := SectorsPerCluster;
                Capacity := TC * SPC * BPS;
                FreeSpace := FC * SPC * BPS;
              end;
            finally
              Dispose(TF);
            end;
            bufVolumeLabel := AllocMem(Size);
            bufFileSystem := AllocMem(Size);
            try
              if GetVolumeInformation(bufRoot, bufVolumeLabel, Size, @Serial,
                MCL, Flags, bufFileSystem, Size) then
              begin;
                VolumeLabel := bufVolumeLabel;
                FileSystem := bufFileSystem;
                s := IntToHex(Serial, 8);
                SerialNumber := Copy(s, 1, 4) + '-' + Copy(s, 5, 4);
              end;
            finally
              FreeMem(bufVolumeLabel);
              FreeMem(bufFileSystem);
            end;
          end;
        finally
          SetErrorMode(ErrorMode);
        end;
      end;
    finally
      FreeMem(bufRoot);
    end;
  end;
end;

procedure GetFilesList(const FolderName, FileMask: String; Folder: TRtcDataSet);
var
  sr: TSearchRec;
  ErrorMode: Word;
  fm: String;

  procedure AddDrives;
  var
    shInfo: TSHFileInfo;
    i: Integer;
    Drv: String;
    DI: TDiskInfo;
    Drives: set of 0 .. 25;
  begin
    Integer(Drives) := GetLogicalDrives;
    for i := 0 to 25 do
      if (i in Drives) then
      begin
        Drv := char(i + Ord('A')) + ':';

        DI := GetDiskInfo(TDiskSign(Drv));
        Folder.Append;
        Folder.asText['drive'] := Drv;
        Folder.asLargeInt['size'] := DI.Capacity;
        Folder.asLargeInt['free'] := DI.FreeSpace;
        Folder.asInteger['type'] := Ord(DI.MediaType);
        SHGetFileInfo(pchar(Drv + '\'), 0, shInfo, Sizeof(shInfo),
          SHGFI_SYSICONINDEX or SHGFI_DISPLAYNAME or SHGFI_TYPENAME);
        Folder.asText['label'] := StrPas(shInfo.szDisplayName);
        // Folder.asText['label']:=DI.VolumeLabel;
      end;
  end;
  procedure AddFolders;
  begin
    if FileMask <> '' then
      fm := IncludeTrailingBackslash(FolderName) + FileMask
    else
      fm := IncludeTrailingBackslash(FolderName) + '*.*';
    ErrorMode := SetErrorMode(SEM_FailCriticalErrors);
    try
      if FindFirst(fm, faAnyFile, sr) = 0 then
        try
          repeat
            if (sr.Name <> '.') and (sr.Name <> '..') then
            begin
              Folder.Append;
              Folder.asText['file'] := sr.Name;
              try
                Folder.asDateTime['age'] := FileDateToDateTime(sr.Time);
              except
                Folder.isNull['age'] := True;
              end;
              Folder.asInteger['attr'] := sr.Attr;
              if (sr.Attr and faDirectory) <> faDirectory then
              begin
                // Folder.asLargeInt['size']:= File_Size(FolderName+'\'+sr.Name);
                Folder.asLargeInt['size'] :=
                  (int64(sr.FindData.nFileSizeHigh) shl 32) or
                  (sr.FindData.nFileSizeLow);
              end;
            end;
          until (FindNext(sr) <> 0);
        finally
          FindClose(sr);
        end;
    finally
      SetErrorMode(ErrorMode);
    end;
  end;

begin
  if FolderName = '' then
    AddDrives
  else
    AddFolders;
end;

end.
