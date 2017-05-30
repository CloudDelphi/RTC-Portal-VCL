object MainForm: TMainForm
  Left = 610
  Top = 152
  ActiveControl = eUserName
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsNone
  Caption = 'RTC Host v5'
  ClientHeight = 485
  ClientWidth = 273
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefault
  PrintScale = poNone
  Scaled = False
  ShowHint = True
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 14
  object pMaster: TPanel
    Left = 0
    Top = 28
    Width = 273
    Height = 457
    Align = alClient
    ParentBackground = False
    TabOrder = 0
    object lblStatusPanel: TPanel
      Left = 1
      Top = 423
      Width = 271
      Height = 33
      Align = alBottom
      BevelInner = bvLowered
      Color = clGray
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      object lblStatus: TLabel
        Left = 2
        Top = 2
        Width = 267
        Height = 29
        Align = alClient
        Alignment = taCenter
        AutoSize = False
        Caption = 'Click "START" to log in and start Hosting.'
        Color = clGray
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        Transparent = False
        Layout = tlCenter
        WordWrap = True
      end
    end
    object Pages: TPageControl
      Left = 1
      Top = 1
      Width = 271
      Height = 422
      ActivePage = Page_Setup
      Align = alClient
      MultiLine = True
      TabOrder = 0
      TabStop = False
      object Page_Setup: TTabSheet
        Caption = 'Setup'
        object Label3: TLabel
          Left = 13
          Top = 200
          Width = 49
          Height = 14
          Alignment = taRightJustify
          Caption = 'Username'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          ParentFont = False
        end
        object Label4: TLabel
          Left = 12
          Top = 224
          Width = 50
          Height = 14
          Alignment = taRightJustify
          Caption = 'Password'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          ParentFont = False
        end
        object Label12: TLabel
          Left = 16
          Top = 170
          Width = 45
          Height = 14
          Caption = 'Gateway'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          ParentFont = False
        end
        object btnGateway: TSpeedButton
          Left = 68
          Top = 164
          Width = 181
          Height = 25
          Caption = '< Click to set up connection >'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          ParentFont = False
          OnClick = btnGatewayClick
        end
        object Label1: TLabel
          Left = 11
          Top = 248
          Width = 51
          Height = 14
          Alignment = taRightJustify
          Caption = 'Real Name'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          ParentFont = False
        end
        object btnLogin: TButton
          Left = 188
          Top = 268
          Width = 73
          Height = 41
          Caption = 'START'
          Default = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          ParentFont = False
          TabOrder = 6
          OnClick = btnLoginClick
        end
        object eUserName: TEdit
          Left = 68
          Top = 195
          Width = 181
          Height = 22
          TabOrder = 0
          OnChange = eUserNameChange
        end
        object ePassword: TEdit
          Left = 68
          Top = 219
          Width = 125
          Height = 22
          PasswordChar = '*'
          TabOrder = 1
          OnChange = ePasswordChange
        end
        object xAdvanced: TCheckBox
          Left = 68
          Top = 268
          Width = 117
          Height = 17
          Hint = 
            'Check this box if you want to change settings before you start h' +
            'osting'
          TabStop = False
          Caption = 'Change Settings'
          TabOrder = 4
          OnClick = xAdvancedClick
        end
        object xSavePassword: TCheckBox
          Left = 200
          Top = 220
          Width = 61
          Height = 21
          Hint = 
            'Check this box if you want your password to be saved for the nex' +
            't time'
          TabStop = False
          Caption = 'Save'
          TabOrder = 2
        end
        object xAutoConnect: TCheckBox
          Left = 68
          Top = 292
          Width = 117
          Height = 17
          Hint = 
            'Check thix box if you want to be logged in automatically after a' +
            'ny kind of connection problems'
          TabStop = False
          Caption = 'Auto Re-Login'
          TabOrder = 5
        end
        object Panel1: TPanel
          Left = 0
          Top = 316
          Width = 261
          Height = 77
          BevelInner = bvRaised
          BevelOuter = bvLowered
          TabOrder = 8
          object Label25: TLabel
            Left = 4
            Top = 4
            Width = 221
            Height = 14
            Caption = 'RTC Host can also run as a Windows Service'
          end
          object Label2: TLabel
            Left = 8
            Top = 26
            Width = 40
            Height = 14
            Caption = 'Service:'
          end
          object btnInstall: TSpeedButton
            Left = 52
            Top = 20
            Width = 53
            Height = 25
            Caption = 'Install'
            OnClick = btnInstallClick
          end
          object btnRun: TSpeedButton
            Left = 104
            Top = 20
            Width = 41
            Height = 25
            Caption = 'Run'
            OnClick = btnRunClick
          end
          object btnStop: TSpeedButton
            Left = 144
            Top = 20
            Width = 41
            Height = 25
            Caption = 'Stop'
            OnClick = btnStopClick
          end
          object btnUninstall: TSpeedButton
            Left = 184
            Top = 20
            Width = 61
            Height = 25
            Caption = 'Uninstall'
            OnClick = btnUninstallClick
          end
          object btnSaveSetup: TSpeedButton
            Left = 13
            Top = 46
            Width = 93
            Height = 25
            Caption = 'Save Setup'
            OnClick = btnSaveSetupClick
          end
          object btnRestartService: TSpeedButton
            Left = 104
            Top = 46
            Width = 140
            Height = 25
            Caption = 'Restart Service && Exit'
            OnClick = btnRestartServiceClick
          end
        end
        object Panel2: TPanel
          Left = 0
          Top = 4
          Width = 261
          Height = 157
          Cursor = crHandPoint
          BevelInner = bvRaised
          BevelOuter = bvLowered
          Color = clWhite
          ParentBackground = False
          TabOrder = 7
          OnClick = RtcCopyrightClick
          object Label7: TLabel
            Left = 4
            Top = 92
            Width = 253
            Height = 17
            Cursor = crHandPoint
            Alignment = taCenter
            AutoSize = False
            Caption = 'Copyright (c) RealThinClient components'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Arial'
            Font.Style = []
            ParentFont = False
            OnClick = RtcCopyrightClick
          end
          object Label11: TLabel
            Left = 4
            Top = 22
            Width = 253
            Height = 17
            Cursor = crHandPoint
            Alignment = taCenter
            AutoSize = False
            Caption = 'Created with RTC SDK and RTC Portal for Delphi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Arial'
            Font.Style = []
            ParentFont = False
            OnClick = RtcCopyrightClick
          end
          object Image1: TImage
            Left = 60
            Top = 39
            Width = 127
            Height = 50
            Cursor = crHandPoint
            AutoSize = True
            Picture.Data = {
              0A544A504547496D616765C40B0000FFD8FFE000104A46494600010101006000
              600000FFE1002245786966000049492A00080000000100005104000100000000
              00000000000000FFDB004300080606070605080707070909080A0C140D0C0B0B
              0C1912130F141D1A1F1E1D1A1C1C20242E2720222C231C1C2837292C30313434
              341F27393D38323C2E333432FFDB0043010909090C0B0C180D0D1832211C2132
              3232323232323232323232323232323232323232323232323232323232323232
              3232323232323232323232323232323232FFC00011080032007F030122000211
              01031101FFC4001F000001050101010101010000000000000000010203040506
              0708090A0BFFC400B5100002010303020403050504040000017D010203000411
              05122131410613516107227114328191A1082342B1C11552D1F0243362728209
              0A161718191A25262728292A3435363738393A434445464748494A5354555657
              58595A636465666768696A737475767778797A838485868788898A9293949596
              9798999AA2A3A4A5A6A7A8A9AAB2B3B4B5B6B7B8B9BAC2C3C4C5C6C7C8C9CAD2
              D3D4D5D6D7D8D9DAE1E2E3E4E5E6E7E8E9EAF1F2F3F4F5F6F7F8F9FAFFC4001F
              0100030101010101010101010000000000000102030405060708090A0BFFC400
              B511000201020404030407050404000102770001020311040521310612415107
              61711322328108144291A1B1C109233352F0156272D10A162434E125F1171819
              1A262728292A35363738393A434445464748494A535455565758595A63646566
              6768696A737475767778797A82838485868788898A92939495969798999AA2A3
              A4A5A6A7A8A9AAB2B3B4B5B6B7B8B9BAC2C3C4C5C6C7C8C9CAD2D3D4D5D6D7D8
              D9DAE2E3E4E5E6E7E8E9EAF2F3F4F5F6F7F8F9FAFFDA000C0301000211031100
              3F00F7FAF2DF8CDE20B7B4D12D6CECF5358B558EF12511C32E24450ADC9C723A
              8AD5F881E29BDB18CE91A3394BD75066B81FF2C54F403FDA3D7D87D457925A78
              39AFAE81B9924796562703E6773DCE4FEA4D095F4406E785FE35EA56052DF5F8
              7EDF6E303CF8C05957EBD9BF43EF5ED5A56BBA7EB3123DA4DF3B207F2A4528E0
              1F553CD7905AFC3782D658EE3ECC8ED19DC15EE54E4FB8C63F5AD746759C81B9
              2789867190CADD8FB7B107F1A6E325BA15D33D6A8AC2F0EEB2FA8426DEE8FF00
              A520CEEC637AFAFD477FC3F0DDA430A2BE64BFD7BC5526BF736D6FAEEAABBAE9
              A38D45EC800CB10075E2B5F56D33E25F876C4EA17BAA6A42DD085675D44C8173
              C0C8DC7BD7B2F28B594AA24DEC71FD6EF7B45E87D09457957C32F19EB3AE8BFD
              275491AE278ADDA6827C61F008054E3AF2C307AF5AE126B7F8976F0493CD71E2
              28E28D4BBBB5C4A02A81924F359432B93A92A739A4D5BE77EC5BC4AE55249BB9
              F48515F2FDA6ABE35BFBA4B6B4D635A9A77CED8E3BC94938193C67D01AF41F87
              71F8C6CBC4735C78925D5C69E9692331BC964640410738638CE33555F2A7460E
              4EA2BAE9D49A78B537648F5FA2BE7CF12FC42F12F893556B6D1E5B9B3B467D90
              436C48964F4248E727D071F5EB54AFAD7E22785E38EFAEEE755B78D88C3FDACC
              8BEC1806207D0D547279D973CD293E80F16AEF95368FA428AE1FE1B78DA4F16E
              973437DB06A5664094A8C0914F4603B1E08207F5C57715E656A33A351D39EE8E
              984D4E3CC8F2BBAD9731CD7AE3F79732193777018E47E4BC0FA5713A178881BD
              D46E5890CCE15147F0C638503FCF7AEE6744821368ED8784F9647BAE54FF005A
              F23109D2B599EDA61B4A39C1F6CE41AF4F26A74EA549296F6FF87387319CE14D
              381DADD78A6439108EA30CC6B1D3C4932F88AC199CB066F2641EAADD3F23FD6A
              6892D2E2D03AB7CC7A91EB5876566D7FE27821888291481E471D02AF3FFD6AF7
              2B51A0A8CAEB64CF1B058EAB5AAF2F547BEE9D001A7C1A92637C4D9623B80DB5
              BFF1DC9AEA6B9DB589EDFC250C0C36C97184C1EBFBC7FE81BF4AE8ABE2CFA93E
              70BABBB05F114E2095DEE16EDB6AAC64FCDBF81EFCD6F6BBE2CD5AF524D2B586
              B9450C0C90B5B2C64F719E871DEB97B1B61278CD9B1FF2FE4FFE44AF64F883E1
              F8EFACD3548E3CCF6C36C981CB47FF00D63FCCD7D5579D2A7569C66AF7EBD99E
              0CAA4DD2A92A7F67A771BF0FBC336BA6DB36AD1CD1CD25CC7B14C67215739233
              EB903F2AE9F5EDA7C3BA9EE04AFD925C81E9B0D705E00D5858EA0DA748D886E7
              94CF6907F88E3F015DF6B9FF0022FEA5FF005EB2FF00E806BC5C5C66B15EFBBD
              EDF71D983C4C2B611CE0AD64EFEA793F82153FE136D3CC70EC51E6727AFF00AB
              6AF51F1436DF0BEA47E623C86076F5C11CFE95E75E0BFF0091B6C7FEDA7FE8B6
              AF579E18EE6DE58251BA3910A30F50460D6B98C9471119764BF3673E515275B0
              B36F7BBFC91E43E04834F6F185ABA86F342B940CBDF69FE99AF58D48581D3E5F
              ED316E6CC60C9F6803CBE082339E3AE2BCA2FF0049D43C2BAC24E8ACBE5BEE86
              E00CAB0FFF005704526BDE26D5BC4561FD9F2089637237242841908E80E49EF5
              D188C33C4D58D484BDDEE7361F3458784A9578B534F63D66C4597D954D80B7FB
              39FBBF67DBB3F0C71566B82F86BE129F4182EAFEF11A39EE805489BAA20E7247
              A93DBB62BBDAF231108C2A38C65CCBB9EF509B9D3526AD7E879E7C42D0AE915B
              5AD394B803FD22251CF1FC63F0C67E99F5AF2BBAD434DD5A358F514749506127
              8BEF0F623BD7D2F5C7EADF0E344BFD41751B7812DEE95B7E02E6373EEBFE1F91
              ACE139425CD07666928A92B33CA20F05DC1B7445BDBBF29FE7C2DB10483EE7A5
              76DE18F0A59692A1E58D5235218A33067908EEE7A01ED57350B5D4B4C6FF0049
              8CAA76914E50FE3DBF1C56B78734A835381EEAF4BCA125D8B031C47C007247F1
              75EF91ED5BD6C657ACB96A4AE8CA9E1E95377846C6C5948DABDCC57A462CE1CF
              9191FEB5CF05FF00DD03207AE49E98ACAD43C57A959CBAF5C2693692697A23E2
              EA66BE659D94411CEE522F28A92164C005C648E48EB5D674AE3E7F0259DE6B5A
              9EB13DBD88D51F508EF34FBD6B712BC3B208A30AE08195DC8E7683FC4194AB80
              CBCC6C6C7FC251A4FF0068FD8BCE9F779BE479FF006497ECFE6676ECF3F6F97B
              B77C98DD9DFF002FDEE2A49BC41A7DB6A834F9FED714A5D504AF6532C059B1B4
              79C53CBC924281BB96217AF15C9D8F82F514BF8CDDDBC0D0B6A07519241ADDE3
              22399CDC6D5B501633B58ED0C48CE04857394A9353F0A6B97DABA48EF1CF1AEA
              705DFDA9F58B98C0892759427D9150C39545D80E7E62039C313401625F15EBD1
              699F6F8749D36E60FED3934FCBDF3C0C1BEDAD6D1FCA227046361277776C2F00
              1934EF1B08EFB56B2F102C169756376B1B2D909AE6386230C520926942008A4B
              BFCEE1170ADD7631AB1FF08DDE7FC239FD9DE641E77F6DFF00686EDC76F97FDA
              1F69C74FBDB38C74DDDF1CD1A8786EF2EF47F19D9C724024D6FCCFB3166384DD
              6914037F1C7CC84F19E31DF8A00B973E27D334D96E56FF00508C6DBD1671A25B
              C9B84A6059445C677B95248DA06772A005BA92789ED24B2864D3D24B8BBB8B8F
              B2416B323DBBF9DB0C9B640EA1A30114B92573B705431650D4FF00E11BBCFF00
              848FFB47CC83C9FEDBFED0DBB8EEF2FF00B3FECD8E9F7B7F38E9B7BE78A25F0D
              DE7F685FEA30C901BA1AAAEA5648EC76362CD2D99242065723CCC119DB956C36
              0A10091F59D660D4349B3D474BB4B6FB6DE981DA1B93711B47F679E4F9495460
              E1A25C82BB76B0C1249DA41E25D1EDEC2C27DEF7735DDA4773BF4ED2E790B238
              CAC86345768D5BE6DA1CF6619254D0D61AF6A5A8E9179A8C5A6DAA585E99FC8B
              79DE6254DBCF193BD91324B4A9F2ED180AC771C8039F8FC0FAA595BE94D188EE
              A78347B4D3A748F5ABAD3D55A00FF3068549903190FDE036EDE33B8E0B8AC8EA
              2E7C5FA1DB5C25B8BB92E6792DE3BA8E3B2B796E59E172C1645112B129952370
              E065738DCB9A6DE3AD3575CB8D3C417D3C31DA5BDCC77567637172928977E306
              38D86DC2290C0907710395356342F0F3E8BA8B3AB41F655D2ACAC2358830C180
              CD9E18B10B891719663C1C9EE72F48D035EF0E5BE9ED650E9B7D3AE8F67A75CA
              4D76F02A35B893E646113970C653D42E368EB9E019DA51451400840652AC0104
              6083DEA9E9B0456F1DC470C491A09DBE5450076EC28A2802ED14514005145140
              051451400514514005145140051451401FFFD9}
            OnClick = RtcCopyrightClick
          end
          object Label8: TLabel
            Left = 4
            Top = 4
            Width = 253
            Height = 17
            Cursor = crHandPoint
            Alignment = taCenter
            AutoSize = False
            Caption = 'RTC Portal Host'
            Color = clBlack
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWhite
            Font.Height = -12
            Font.Name = 'Arial'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            Transparent = False
            Layout = tlCenter
            WordWrap = True
            OnClick = RtcCopyrightClick
          end
          object Label5: TLabel
            Left = 4
            Top = 108
            Width = 253
            Height = 45
            Cursor = crHandPoint
            Alignment = taCenter
            AutoSize = False
            Caption = 
              'Get the component version to completely redesign the user interf' +
              'ace and rebrand everything to make it look-and-feel like your ot' +
              'her applications.'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clNavy
            Font.Height = -11
            Font.Name = 'Arial'
            Font.Style = []
            ParentFont = False
            WordWrap = True
            OnClick = RtcCopyrightClick
          end
        end
        object eRealName: TEdit
          Left = 68
          Top = 243
          Width = 181
          Height = 22
          TabOrder = 3
          OnChange = eRealNameChange
        end
      end
      object Page_Hosting: TTabSheet
        Caption = 'Hosting'
        ImageIndex = 1
        object Label9: TLabel
          Left = 36
          Top = 8
          Width = 143
          Height = 14
          Caption = 'Users connected to this Host:'
        end
        object sStatus1: TShape
          Left = 8
          Top = 8
          Width = 15
          Height = 15
          Brush.Color = clSilver
          Shape = stCircle
        end
        object sStatus2: TShape
          Left = 16
          Top = 8
          Width = 15
          Height = 15
          Brush.Color = clSilver
          Shape = stCircle
        end
        object Label21: TLabel
          Left = 8
          Top = 315
          Width = 36
          Height = 14
          Caption = 'Priority:'
        end
        object btnLogout: TSpeedButton
          Left = 192
          Top = 348
          Width = 65
          Height = 33
          Caption = 'LOG OUT'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          ParentFont = False
          OnClick = btnLogOutClick
        end
        object btnSettings: TSpeedButton
          Left = 148
          Top = 308
          Width = 109
          Height = 29
          Caption = 'Change Settings'
          OnClick = btnSettingsClick
        end
        object eConnected: TListView
          Left = 8
          Top = 28
          Width = 249
          Height = 274
          Columns = <>
          IconOptions.Arrangement = iaLeft
          IconOptions.AutoArrange = True
          ReadOnly = True
          RowSelect = True
          SortType = stText
          TabOrder = 1
          ViewStyle = vsSmallIcon
        end
        object cPriority: TComboBox
          Left = 48
          Top = 311
          Width = 97
          Height = 22
          Style = csDropDownList
          ItemHeight = 14
          ItemIndex = 1
          TabOrder = 0
          TabStop = False
          Text = 'NORMAL'
          OnChange = cPriorityChange
          Items.Strings = (
            'HIGH'
            'NORMAL'
            'LOW')
        end
        object pSendFiles: TPanel
          Left = 4
          Top = 344
          Width = 181
          Height = 41
          BorderWidth = 5
          Color = clTeal
          ParentBackground = False
          TabOrder = 2
          Visible = False
          object Label16: TLabel
            Left = 6
            Top = 6
            Width = 169
            Height = 29
            Align = alClient
            Alignment = taCenter
            AutoSize = False
            Caption = 
              'To download Files or Folders, drag them here from Windows Explor' +
              'er.'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWhite
            Font.Height = -11
            Font.Name = 'Arial'
            Font.Style = []
            ParentFont = False
            Transparent = True
            WordWrap = True
          end
        end
      end
    end
  end
  object pTitlebar: TPanel
    Left = 0
    Top = 0
    Width = 273
    Height = 28
    Align = alTop
    Color = clMoneyGreen
    ParentBackground = False
    TabOrder = 1
    OnMouseDown = pTitlebarMouseDown
    OnMouseMove = pTitlebarMouseMove
    OnMouseUp = pTitlebarMouseUp
    object cTitleBar: TLabel
      Left = 1
      Top = 1
      Width = 271
      Height = 26
      Align = alClient
      Caption = '  RTC Portal Host v5'
      Color = clMoneyGreen
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -14
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      Transparent = False
      Layout = tlCenter
      OnMouseDown = pTitlebarMouseDown
      OnMouseMove = pTitlebarMouseMove
      OnMouseUp = pTitlebarMouseUp
    end
    object btnMinimize: TSpeedButton
      Left = 224
      Top = 4
      Width = 25
      Height = 21
      Caption = '--'
      OnClick = btnMinimizeClick
    end
    object btnClose: TSpeedButton
      Left = 248
      Top = 4
      Width = 21
      Height = 21
      Caption = 'X'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = btnCloseClick
    end
  end
  object PClient: TRtcHttpPortalClient
    UserVisible = True
    GwStoreParams = True
    OnLogIn = PClientLogIn
    OnLogOut = PClientLogOut
    OnParams = PClientParams
    OnStart = PClientStart
    OnError = PClientError
    OnFatalError = PClientFatalError
    AutoSyncEvents = True
    DataEncrypt = 16
    DataForceEncrypt = True
    RetryOtherCalls = 5
    MultiThreaded = True
    Gate_Timeout = 300
    OnStatusGet = PClientStatusGet
    OnStatusPut = PClientStatusPut
    Left = 4
    Top = 456
  end
  object PFileTrans: TRtcPFileTransfer
    Client = PClient
    BeTheHost = True
    GwStoreParams = True
    OnUserJoined = PModuleUserJoined
    OnUserLeft = PModuleUserLeft
    OnNewUI = PFileTransNewUI
    Left = 36
    Top = 456
  end
  object PChat: TRtcPChat
    Client = PClient
    BeTheHost = True
    GwStoreParams = True
    OnNewUI = PChatNewUI
    OnUserJoined = PModuleUserJoined
    OnUserLeft = PModuleUserLeft
    Left = 68
    Top = 456
  end
  object PDesktopHost: TRtcPDesktopHost
    Client = PClient
    GwStoreParams = True
    FileTransfer = PFileTrans
    OnUserJoined = PModuleUserJoined
    OnUserLeft = PModuleUserLeft
    Left = 100
    Top = 456
  end
  object PDesktopControl: TRtcPDesktopControl
    Client = PClient
    OnNewUI = PDesktopControlNewUI
    Left = 132
    Top = 456
  end
end
