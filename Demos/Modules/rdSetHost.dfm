object rdHostSettings: TrdHostSettings
  Left = 538
  Top = 191
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'Host Settings'
  ClientHeight = 435
  ClientWidth = 267
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PrintScale = poNone
  Scaled = False
  PixelsPerInch = 120
  TextHeight = 14
  object PageControl1: TPageControl
    Left = 4
    Top = 4
    Width = 257
    Height = 389
    ActivePage = TabSheet3
    MultiLine = True
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'Users'
      object Label6: TLabel
        Left = 0
        Top = 192
        Width = 222
        Height = 14
        Caption = 'All connected users will be allowed to ...'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label12: TLabel
        Left = 23
        Top = 306
        Width = 25
        Height = 14
        Alignment = taRightJustify
        Caption = 'Files:'
      end
      object Label4: TLabel
        Left = 10
        Top = 326
        Width = 39
        Height = 14
        Alignment = taRightJustify
        Caption = 'Folders:'
      end
      object Label18: TLabel
        Left = 4
        Top = 288
        Width = 138
        Height = 14
        Caption = 'Direct Drive Access rights ...'
      end
      object xAllowUsersList: TCheckBox
        Left = 4
        Top = 3
        Width = 237
        Height = 17
        Caption = 'Make the Host accessible only to (userlist) ...'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OnClick = xAllowUsersListClick
      end
      object eUsers: TListView
        Left = 4
        Top = 24
        Width = 153
        Height = 165
        Color = clBtnFace
        Columns = <>
        Enabled = False
        IconOptions.Arrangement = iaLeft
        IconOptions.AutoArrange = True
        ReadOnly = True
        RowSelect = True
        SortType = stText
        TabOrder = 1
        ViewStyle = vsSmallIcon
        OnClick = eUsersClick
      end
      object btnAddUser: TButton
        Left = 164
        Top = 24
        Width = 77
        Height = 25
        Caption = 'Add User'
        Enabled = False
        TabOrder = 2
        OnClick = btnAddUserClick
      end
      object btnRemUser: TButton
        Left = 164
        Top = 52
        Width = 77
        Height = 25
        Caption = 'Remove User'
        Enabled = False
        TabOrder = 3
        OnClick = btnRemUserClick
      end
      object xMayUploadAnywhere: TCheckBox
        Left = 128
        Top = 248
        Width = 113
        Height = 17
        Caption = 'Upload Anywhere'
        TabOrder = 10
      end
      object xMayViewDesktop: TCheckBox
        Left = 4
        Top = 228
        Width = 117
        Height = 17
        Caption = 'View my Desktop'
        TabOrder = 5
      end
      object xMayControlDesktop: TCheckBox
        Left = 4
        Top = 248
        Width = 117
        Height = 17
        Caption = 'Control my Desktop'
        TabOrder = 6
      end
      object xMayUploadFiles: TCheckBox
        Left = 128
        Top = 228
        Width = 105
        Height = 17
        Caption = 'Upload their Files'
        TabOrder = 9
      end
      object xMayDownloadFiles: TCheckBox
        Left = 128
        Top = 208
        Width = 113
        Height = 17
        Caption = 'Download my Files'
        TabOrder = 8
      end
      object xMayJoinChat: TCheckBox
        Left = 4
        Top = 208
        Width = 117
        Height = 17
        Caption = 'Enter my Chatroom'
        TabOrder = 4
      end
      object xMayBrowseFiles: TCheckBox
        Left = 4
        Top = 268
        Width = 237
        Height = 17
        Caption = 'Browse through my Files and Folders (remote)'
        TabOrder = 7
      end
      object xMayDeleteFiles: TCheckBox
        Left = 180
        Top = 304
        Width = 57
        Height = 17
        Caption = 'Delete'
        TabOrder = 13
      end
      object xMayRenameFiles: TCheckBox
        Left = 52
        Top = 304
        Width = 65
        Height = 17
        Caption = 'Rename'
        TabOrder = 11
      end
      object xMayExecuteCommands: TCheckBox
        Left = 120
        Top = 344
        Width = 121
        Height = 17
        Caption = 'Execute Commands'
        TabOrder = 18
      end
      object xMayMoveFiles: TCheckBox
        Left = 120
        Top = 304
        Width = 49
        Height = 17
        Caption = 'Move'
        TabOrder = 12
      end
      object xMayRenameFolders: TCheckBox
        Left = 52
        Top = 324
        Width = 65
        Height = 17
        Caption = 'Rename'
        TabOrder = 14
      end
      object xMayDeleteFolders: TCheckBox
        Left = 180
        Top = 324
        Width = 57
        Height = 17
        Caption = 'Delete'
        TabOrder = 16
      end
      object xMayMoveFolders: TCheckBox
        Left = 120
        Top = 324
        Width = 49
        Height = 17
        Caption = 'Move'
        TabOrder = 15
      end
      object xMayCreateFolders: TCheckBox
        Left = 52
        Top = 344
        Width = 65
        Height = 17
        Caption = 'Create'
        TabOrder = 17
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Super Users'
      ImageIndex = 2
      object Label19: TLabel
        Left = 4
        Top = 192
        Width = 206
        Height = 14
        Caption = 'Super Users will also be allowed to ...'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label20: TLabel
        Left = 4
        Top = 4
        Width = 188
        Height = 14
        Caption = 'Super Users (more access rights)'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label7: TLabel
        Left = 23
        Top = 306
        Width = 25
        Height = 14
        Alignment = taRightJustify
        Caption = 'Files:'
      end
      object Label13: TLabel
        Left = 10
        Top = 326
        Width = 39
        Height = 14
        Alignment = taRightJustify
        Caption = 'Folders:'
      end
      object Label21: TLabel
        Left = 4
        Top = 288
        Width = 138
        Height = 14
        Caption = 'Direct Drive Access rights ...'
      end
      object eSuperUsers: TListView
        Left = 4
        Top = 24
        Width = 153
        Height = 165
        Columns = <>
        IconOptions.Arrangement = iaLeft
        IconOptions.AutoArrange = True
        ReadOnly = True
        RowSelect = True
        SortType = stText
        TabOrder = 0
        ViewStyle = vsSmallIcon
        OnClick = eSuperUsersClick
      end
      object btnAddSuperUser: TButton
        Left = 164
        Top = 24
        Width = 77
        Height = 25
        Caption = 'Add User'
        TabOrder = 1
        OnClick = btnAddSuperUserClick
      end
      object btnRemSuperUser: TButton
        Left = 164
        Top = 52
        Width = 77
        Height = 25
        Caption = 'Remove User'
        Enabled = False
        TabOrder = 2
        OnClick = btnRemSuperUserClick
      end
      object xSuperMayViewDesktop: TCheckBox
        Left = 4
        Top = 228
        Width = 117
        Height = 17
        Caption = 'View my Desktop'
        TabOrder = 4
      end
      object xSuperMayDownloadFiles: TCheckBox
        Left = 128
        Top = 208
        Width = 113
        Height = 17
        Caption = 'Download my Files'
        TabOrder = 7
      end
      object xSuperMayUploadAnywhere: TCheckBox
        Left = 128
        Top = 248
        Width = 113
        Height = 17
        Caption = 'Upload Anywhere'
        TabOrder = 9
      end
      object xSuperMayJoinChat: TCheckBox
        Left = 4
        Top = 208
        Width = 113
        Height = 17
        Caption = 'Enter my Chatroom'
        TabOrder = 3
      end
      object xSuperMayUploadFiles: TCheckBox
        Left = 128
        Top = 228
        Width = 105
        Height = 17
        Caption = 'Upload their Files'
        TabOrder = 8
      end
      object xSuperMayControlDesktop: TCheckBox
        Left = 4
        Top = 248
        Width = 117
        Height = 17
        Caption = 'Control my Desktop'
        TabOrder = 5
      end
      object xSuperMayBrowseFiles: TCheckBox
        Left = 4
        Top = 268
        Width = 237
        Height = 17
        Caption = 'Browse through my Files and Folders (remote)'
        TabOrder = 6
      end
      object xSuperMayRenameFiles: TCheckBox
        Left = 52
        Top = 304
        Width = 65
        Height = 17
        Caption = 'Rename'
        TabOrder = 10
      end
      object xSuperMayDeleteFiles: TCheckBox
        Left = 180
        Top = 304
        Width = 57
        Height = 17
        Caption = 'Delete'
        TabOrder = 12
      end
      object xSuperMayMoveFiles: TCheckBox
        Left = 120
        Top = 304
        Width = 49
        Height = 17
        Caption = 'Move'
        TabOrder = 11
      end
      object xSuperMayExecuteCommands: TCheckBox
        Left = 120
        Top = 344
        Width = 117
        Height = 17
        Caption = 'Execute Commands'
        TabOrder = 17
      end
      object xSuperMayRenameFolders: TCheckBox
        Left = 52
        Top = 324
        Width = 65
        Height = 17
        Caption = 'Rename'
        TabOrder = 13
      end
      object xSuperMayDeleteFolders: TCheckBox
        Left = 180
        Top = 324
        Width = 57
        Height = 17
        Caption = 'Delete'
        TabOrder = 15
      end
      object xSuperMayMoveFolders: TCheckBox
        Left = 120
        Top = 324
        Width = 49
        Height = 17
        Caption = 'Move'
        TabOrder = 14
      end
      object xSuperMayCreateFolders: TCheckBox
        Left = 52
        Top = 344
        Width = 65
        Height = 17
        Caption = 'Create'
        TabOrder = 16
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Desktop'
      ImageIndex = 2
      object Label5: TLabel
        Left = 4
        Top = 304
        Width = 142
        Height = 14
        Caption = 'Set Visible Screen Region'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label17: TLabel
        Left = 4
        Top = 28
        Width = 79
        Height = 14
        Caption = 'High Color depth'
      end
      object Label14: TLabel
        Left = 5
        Top = 196
        Width = 78
        Height = 14
        Caption = 'Max Frame Rate'
      end
      object Label10: TLabel
        Left = 4
        Top = 4
        Width = 158
        Height = 14
        Caption = 'Screen Capture Optimization'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label1: TLabel
        Left = 4
        Top = 52
        Width = 80
        Height = 14
        Caption = 'Low Color depth'
      end
      object Label2: TLabel
        Left = 0
        Top = 76
        Width = 189
        Height = 14
        Caption = 'Use Low Colors if it will reduce size by'
      end
      object Label8: TLabel
        Left = 5
        Top = 100
        Width = 74
        Height = 14
        Caption = 'Send Screen in'
      end
      object Label9: TLabel
        Left = 236
        Top = 76
        Width = 10
        Height = 14
        Caption = '%'
      end
      object Label3: TLabel
        Left = 5
        Top = 172
        Width = 77
        Height = 14
        Caption = 'Max Frame Size'
      end
      object Label11: TLabel
        Left = 5
        Top = 124
        Width = 69
        Height = 14
        Caption = 'Refine Screen'
      end
      object Label15: TLabel
        Left = 5
        Top = 148
        Width = 79
        Height = 14
        Caption = 'Scr.Refine delay'
      end
      object Label16: TLabel
        Left = 8
        Top = 260
        Width = 63
        Height = 14
        Caption = 'Mirror Driver:'
      end
      object lblDriverCheck: TLabel
        Left = 144
        Top = 237
        Width = 102
        Height = 14
        Caption = '(driver NOT installed)'
      end
      object xShowFullScreen: TCheckBox
        Left = 4
        Top = 340
        Width = 221
        Height = 17
        Caption = 'Send Full Screen (show everything I see)'
        TabOrder = 15
        OnClick = xShowFullScreenClick
      end
      object xUseMirrorDriver: TCheckBox
        Left = 4
        Top = 236
        Width = 133
        Height = 17
        Caption = 'Use Video Mirror Driver'
        TabOrder = 9
        OnClick = xUseMirrorDriverClick
      end
      object cbColorLimit: TComboBox
        Left = 88
        Top = 24
        Width = 153
        Height = 22
        Style = csDropDownList
        DropDownCount = 25
        ItemHeight = 14
        ItemIndex = 0
        TabOrder = 0
        Text = '8 bit = 256 colors'
        OnChange = cbColorLimitChange
        Items.Strings = (
          '8 bit = 256 colors'
          '16 bit = 65.536 colors'
          '4 bit = 16 colors'
          '6 bit = 64 colors'
          '9 bit = 512 colors'
          '12 bit = 4.096 colors'
          '15 bit = 32.768 colors'
          '18 bit = 262.144 colors'
          '21 bit = 2 Million colors'
          '32 bit = True Color')
      end
      object cbFrameRate: TComboBox
        Left = 88
        Top = 192
        Width = 153
        Height = 22
        Style = csDropDownList
        DropDownCount = 25
        ItemHeight = 14
        ItemIndex = 0
        TabOrder = 7
        Text = 'Maximum'
        OnChange = cbFrameRateChange
        Items.Strings = (
          'Maximum'
          '50 Frames per second'
          '40 Frames per second'
          '25 Frames per second'
          '20 Frames per second'
          '10 Frames per second'
          '8 Frames per second'
          '5 Frames per second'
          '4 Frames per second'
          '2 Frames per second'
          '1 Frames per second'
          '10 ms delay per Frame'
          '20 ms delay per Frame'
          '40 ms delay per Frame'
          '50 ms delay per Frame'
          '80 ms delay per Frame'
          '100 ms delay per Frame'
          '200 ms delay per Frame'
          '250 ms delay per Frame'
          '400 ms delay per Frame'
          '500 ms delay per Frame')
      end
      object xCaptureLayered: TCheckBox
        Left = 4
        Top = 216
        Width = 229
        Height = 17
        Caption = 'Capture layered and transparend windows'
        TabOrder = 8
        OnClick = xCaptureLayeredClick
      end
      object xCaptureAllMonitors: TCheckBox
        Left = 4
        Top = 320
        Width = 229
        Height = 17
        Caption = 'Capture Desktop from all Monitors/Displays'
        TabOrder = 14
        OnClick = xShowFullScreenClick
      end
      object xUseMouseDriver: TCheckBox
        Left = 4
        Top = 280
        Width = 241
        Height = 17
        Caption = 'Enable Virtual Mouse Driver for UAC control'
        TabOrder = 13
        OnClick = xUseMirrorDriverClick
      end
      object cbLowColorLimit: TComboBox
        Left = 88
        Top = 48
        Width = 153
        Height = 22
        Style = csDropDownList
        DropDownCount = 25
        ItemHeight = 14
        ItemIndex = 0
        TabOrder = 1
        Text = '= High Color depth'
        OnChange = cbLowColorLimitChange
        Items.Strings = (
          '= High Color depth'
          '6 bit = 64 colors'
          '9 bit = 512 colors'
          '12 bit = 4.096 colors'
          '15 bit = 32.768 colors'
          '18 bit = 262.144 colors'
          '21 bit = 2 Million colors'
          '= High Color @ 6 bit'
          '= High Color @ 9 bit'
          '= High Color @ 12 bit'
          '= High Color @ 15 bit'
          '= High Color @ 18 bit'
          '= High Color @ 21 bit')
      end
      object cbScreenBlocks: TComboBox
        Left = 88
        Top = 96
        Width = 153
        Height = 22
        Style = csDropDownList
        DropDownCount = 25
        ItemHeight = 14
        ItemIndex = 0
        TabOrder = 3
        Text = '1 complete Frame'
        OnChange = cbFrameRateChange
        Items.Strings = (
          '1 complete Frame'
          '2 partial Frames/Blocks'
          '3 partial Frames/Blocks'
          '4 partial Frames/Blocks'
          '5 partial Frames/Blocks'
          '6 partial Frames/Blocks'
          '7 partial Frames/Blocks'
          '8 partial Frames/Blocks'
          '9 partial Frames/Blocks'
          '10 partial Frames/Blocks'
          '11 partial Frames/Blocks'
          '12 partial Frames/Blocks')
      end
      object cbReduceColors: TSpinEdit
        Left = 192
        Top = 72
        Width = 41
        Height = 23
        Color = clBtnFace
        Enabled = False
        MaxValue = 99
        MinValue = 0
        TabOrder = 2
        Value = 0
        OnChange = cbColorLimitChange
      end
      object cbScreenLimit: TComboBox
        Left = 88
        Top = 168
        Width = 153
        Height = 22
        Style = csDropDownList
        DropDownCount = 25
        ItemHeight = 14
        ItemIndex = 0
        TabOrder = 6
        Text = 'Automatic (1 Frame)'
        OnChange = cbFrameRateChange
        Items.Strings = (
          'Automatic (1 Frame)'
          '8 Kbit = 1 KB'
          '16 Kbit = 2 KB'
          '32 Kbit = 4 KB'
          '64 Kbit = 8 KB'
          '96 Kbit = 12KB'
          '128 Kbit = 16 KB'
          '192 Kbit = 24 KB'
          '256 Kbit = 32 KB'
          '384 Kbit = 48 KB'
          '512 Kbit = 64 KB'
          '768 Kbit = 96 KB'
          '1024 Kbit = 128 KB'
          '1536 Kbit = 192 KB'
          '2048 Kbit = 256 KB'
          '3072 Kbit = 384 KB'
          '4096 Kbit = 512 KB')
      end
      object cbScreenRefineBlocks: TComboBox
        Left = 88
        Top = 120
        Width = 153
        Height = 22
        Style = csDropDownList
        DropDownCount = 25
        ItemHeight = 14
        ItemIndex = 0
        TabOrder = 4
        Text = 'Auto (2 * Send Frames)'
        OnChange = cbFrameRateChange
        Items.Strings = (
          'Auto (2 * Send Frames)'
          'in 2 Frames/Steps'
          'in 3 Frames/Steps'
          'in 4 Frames/Steps'
          'in 5 Frames/Steps'
          'in 6 Frames/Steps'
          'in 7 Frames/Steps'
          'in 8 Frames/Steps'
          'in 9 Frames/Steps'
          'in 10 Frames/Steps'
          'in 11 Frames/Steps'
          'in 12 Frames/Steps')
      end
      object cbScreenRefineDelay: TComboBox
        Left = 88
        Top = 144
        Width = 153
        Height = 22
        Style = csDropDownList
        DropDownCount = 25
        ItemHeight = 14
        ItemIndex = 0
        TabOrder = 5
        Text = '0.5 Seconds'
        OnChange = cbFrameRateChange
        Items.Strings = (
          '0.5 Seconds'
          '1 Second'
          '2 Seconds'
          '3 Seconds'
          '4 Seconds'
          '5 Seconds'
          '6 Seconds'
          '7 Seconds'
          '8 Seconds'
          '9 Seconds'
          '10 Seconds'
          '11 Seconds'
          '12 Seconds'
          '13 Seconds'
          '14 Seconds'
          '15 Seconds'
          '16 Seconds'
          '17 Seconds'
          '18 Seconds'
          '19 Seconds'
          '20 Seconds')
      end
      object btnMirrorInstall: TButton
        Left = 136
        Top = 256
        Width = 45
        Height = 21
        Caption = 'Install'
        TabOrder = 11
        OnClick = btnMirrorInstallClick
      end
      object btnMirrorUninstall: TButton
        Left = 184
        Top = 256
        Width = 57
        Height = 21
        Caption = 'Uninstall'
        TabOrder = 12
        OnClick = btnMirrorUninstallClick
      end
      object btnMirrorDownload: TButton
        Left = 72
        Top = 256
        Width = 61
        Height = 21
        Caption = 'Download'
        TabOrder = 10
        OnClick = lblMirrorClick
      end
    end
  end
  object btnOK: TBitBtn
    Left = 172
    Top = 400
    Width = 83
    Height = 29
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 1
    OnClick = btnOKClick
    Glyph.Data = {
      DE010000424DDE01000000000000760000002800000024000000120000000100
      0400000000006801000000000000000000001000000000000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      3333333333333333333333330000333333333333333333333333F33333333333
      00003333344333333333333333388F3333333333000033334224333333333333
      338338F3333333330000333422224333333333333833338F3333333300003342
      222224333333333383333338F3333333000034222A22224333333338F338F333
      8F33333300003222A3A2224333333338F3838F338F33333300003A2A333A2224
      33333338F83338F338F33333000033A33333A222433333338333338F338F3333
      0000333333333A222433333333333338F338F33300003333333333A222433333
      333333338F338F33000033333333333A222433333333333338F338F300003333
      33333333A222433333333333338F338F00003333333333333A22433333333333
      3338F38F000033333333333333A223333333333333338F830000333333333333
      333A333333333333333338330000333333333333333333333333333333333333
      0000}
    NumGlyphs = 2
  end
  object btnCancel: TBitBtn
    Left = 8
    Top = 400
    Width = 75
    Height = 29
    TabOrder = 2
    OnClick = btnCancelClick
    Kind = bkCancel
  end
end
