{ Copyright 2004-2017 (c) RealThinClient.com (http://www.realthinclient.com) }

unit uSysTray;

interface

{$I rtcPortalDefs.inc}

uses
  ShellApi,
  Windows,
  Messages,
  Forms,
  Menus,
  Classes;

Const
  FMyCallbackMessage = 'TSystrayCallback';

Type
  TSystrayIcon = Class

    FHandle: THandle;
    WM_TASKBAREVENT: Cardinal;
    WM_TASKBARCREATED: Cardinal;

    FTrayicon: TNotifyIconData;
    FTrayDescription: AnsiString;
    FPopupMenu: TPopupMenu;

    Constructor Create(IconHint: AnsiString);
    Destructor newDestroy;

  private
    Procedure MessageHandler(Var Msg: TMessage);
    Procedure AddIconToSystray(Description: AnsiString);
    Procedure RemoveIconFromSystray;
  end;

implementation

Constructor TSystrayIcon.Create(IconHint: AnsiString);
Begin
  Inherited Create;
  FHandle := AllocateHWnd(MessageHandler);
  WM_TASKBAREVENT := RegisterWindowMessage(FMyCallbackMessage);
  WM_TASKBARCREATED := RegisterWindowMessage('TaskbarCreated');
  FTrayDescription := IconHint;
  AddIconToSystray(FTrayDescription);
End;

Destructor TSystrayIcon.newDestroy;
Begin
  DeallocateHWnd(FHandle);
  RemoveIconFromSystray;
  Inherited Destroy;
End;

Procedure TSystrayIcon.MessageHandler(Var Msg: TMessage);
Var
  ptCursor: Tpoint;

Begin
  if Msg.Msg = WM_TASKBAREVENT then
  begin
    GetCursorPos(ptCursor);
    if Assigned(FPopupMenu) then
      FPopupMenu.Popup(ptCursor.X, ptCursor.Y);
  end
  else if Msg.Msg = WM_TASKBARCREATED then
  begin
    AddIconToSystray(FTrayDescription);
  end;
End;

Procedure TSystrayIcon.AddIconToSystray(Description: AnsiString);
begin
  Fillchar(FTrayicon.szTip, SizeOf(FTrayicon.szTip), 0);

  Move(Description[1], FTrayicon.szTip, Length(Description));
  FTrayicon.cbSize := SizeOf(FTrayicon);
  FTrayicon.Wnd := Application.Handle;
  FTrayicon.uFlags := NIF_ICON or NIF_TIP or NIF_MESSAGE;
  FTrayicon.hIcon := Application.Icon.Handle;
  FTrayicon.uID := 27787552;
  FTrayicon.uCallbackMessage := WM_TASKBAREVENT;

  Shell_NotifyIcon(NIM_DELETE, @FTrayicon);
  Shell_NotifyIcon(NIM_ADD, @FTrayicon);
end;

(* *****************************************************************************
  Datum der Erstellung := 07-06-2005
  Datum der letzten Änderung := 07-06-2005

  Entfernt das Trayicon aus dem Systray.
  ***************************************************************************** *)
Procedure TSystrayIcon.RemoveIconFromSystray;
Begin
  Shell_NotifyIcon(NIM_DELETE, @FTrayicon);
End;

end.
