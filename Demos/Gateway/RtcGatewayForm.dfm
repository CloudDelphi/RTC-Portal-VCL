object MainForm: TMainForm
  Left = 462
  Top = 158
  ActiveControl = ePort
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsNone
  Caption = 'RTC Gateway v5'
  ClientHeight = 502
  ClientWidth = 276
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
  ShowHint = True
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 14
  object pMaster: TPanel
    Left = 0
    Top = 28
    Width = 276
    Height = 441
    Align = alClient
    TabOrder = 0
    object Pages: TPageControl
      Left = 1
      Top = 1
      Width = 274
      Height = 439
      ActivePage = Page_Setup
      Align = alClient
      TabOrder = 0
      TabStop = False
      object Page_Setup: TTabSheet
        Caption = 'Setup'
        object Label2: TLabel
          Left = 12
          Top = 152
          Width = 48
          Height = 14
          Caption = 'Local Port'
        end
        object Label7: TLabel
          Left = 12
          Top = 180
          Width = 57
          Height = 14
          Caption = 'Secure Key'
        end
        object lblSelect: TLabel
          Left = 12
          Top = 128
          Width = 213
          Height = 14
          Caption = 'Gateway Setup (how to run your Server) ...'
        end
        object ePort: TEdit
          Left = 84
          Top = 148
          Width = 73
          Height = 22
          Hint = 'Enter the TCP Port you want to use'
          TabOrder = 0
        end
        object btnLogin: TButton
          Left = 173
          Top = 281
          Width = 77
          Height = 33
          Caption = 'START'
          Default = True
          TabOrder = 8
          OnClick = btnLoginClick
        end
        object eSecureKey: TEdit
          Left = 84
          Top = 176
          Width = 165
          Height = 22
          Hint = 
            'Enter the Secure Key you want to use. Hosts, Viewers and Control' +
            's will need to use the same.'
          PasswordChar = '*'
          TabOrder = 2
        end
        object xSSL: TCheckBox
          Left = 168
          Top = 148
          Width = 45
          Height = 21
          TabStop = False
          Caption = 'SSL'
          Enabled = False
          TabOrder = 1
          Visible = False
          OnClick = xSSLClick
        end
        object eAddress: TEdit
          Left = 84
          Top = 204
          Width = 165
          Height = 22
          Hint = 'Enter the IP Address of the Network Addapter you want to use'
          Color = clGray
          Enabled = False
          TabOrder = 4
        end
        object xISAPI: TCheckBox
          Left = 12
          Top = 232
          Width = 65
          Height = 21
          Hint = 
            'You want to emulate the Gateway as if it was running as an ISAPI' +
            ' DLL?'
          TabStop = False
          Caption = 'as ISAPI'
          TabOrder = 5
          OnClick = xISAPIClick
        end
        object eISAPI: TEdit
          Left = 84
          Top = 232
          Width = 165
          Height = 22
          Hint = 'Enter the PATH on which the ISAPI DLL would be accessible'
          Color = clGray
          Enabled = False
          TabOrder = 6
        end
        object xBindIP: TCheckBox
          Left = 12
          Top = 204
          Width = 69
          Height = 21
          Hint = 'You do not want to Listen on all Network Addapters?'
          TabStop = False
          Caption = 'Bind to IP'
          TabOrder = 3
          OnClick = xBindIPClick
        end
        object Panel2: TPanel
          Left = 3
          Top = 318
          Width = 257
          Height = 86
          BevelInner = bvLowered
          TabOrder = 9
          object Label25: TLabel
            Left = 5
            Top = 10
            Width = 244
            Height = 14
            Caption = 'RTC Gateway can also run as a Windows Service'
          end
          object Label24: TLabel
            Left = 12
            Top = 36
            Width = 40
            Height = 14
            Caption = 'Service:'
          end
          object btnInstall: TSpeedButton
            Left = 56
            Top = 30
            Width = 53
            Height = 25
            Caption = 'Install'
            OnClick = btnInstallClick
          end
          object btnRun: TSpeedButton
            Left = 108
            Top = 30
            Width = 41
            Height = 25
            Caption = 'Run'
            OnClick = btnRunClick
          end
          object btnStop: TSpeedButton
            Left = 148
            Top = 30
            Width = 41
            Height = 25
            Caption = 'Stop'
            OnClick = btnStopClick
          end
          object btnUninstall: TSpeedButton
            Left = 188
            Top = 30
            Width = 61
            Height = 25
            Caption = 'Uninstall'
            OnClick = btnUninstallClick
          end
          object btnRestartService: TSpeedButton
            Left = 108
            Top = 56
            Width = 141
            Height = 25
            Caption = 'Restart Service && Exit'
            OnClick = btnRestartServiceClick
          end
          object btnSaveSetup: TSpeedButton
            Left = 16
            Top = 56
            Width = 93
            Height = 25
            Caption = 'Save Setup'
            OnClick = btnSaveSetupClick
          end
        end
        object Panel3: TPanel
          Left = 4
          Top = 4
          Width = 253
          Height = 117
          BevelInner = bvRaised
          BevelOuter = bvLowered
          Color = clWhite
          TabOrder = 10
          OnClick = RtcCopyrightClick
          object Label1: TLabel
            Left = 4
            Top = 97
            Width = 241
            Height = 15
            Cursor = crHandPoint
            Alignment = taCenter
            AutoSize = False
            Caption = 'Copyright (c) RealThinClient components'
            OnClick = RtcCopyrightClick
          end
          object Label3: TLabel
            Left = 4
            Top = 26
            Width = 245
            Height = 13
            Alignment = taCenter
            AutoSize = False
            Caption = 'Created with RTC SDK ad RTC Portal for Delphi'
            OnClick = RtcCopyrightClick
          end
          object Image1: TImage
            Left = 60
            Top = 42
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
            Width = 245
            Height = 19
            Cursor = crHandPoint
            Alignment = taCenter
            AutoSize = False
            Caption = 'RTC Portal Gateway'
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
        end
        object xNoAutoRegUsers: TCheckBox
          Left = 12
          Top = 259
          Width = 221
          Height = 21
          Hint = 
            'You want to disable automatic user registration (unregitered use' +
            'rs will not be able to connect)?'
          TabStop = False
          Caption = 'Disable Automatic User Registration'
          TabOrder = 7
          OnClick = xISAPIClick
        end
      end
      object Page_Active: TTabSheet
        Caption = 'Active'
        ImageIndex = 1
        object Label5: TLabel
          Left = 8
          Top = 10
          Width = 83
          Height = 14
          Caption = 'Logged-in Users:'
        end
        object btnLogout: TSpeedButton
          Left = 180
          Top = 370
          Width = 77
          Height = 37
          Caption = 'STOP'
          OnClick = btnLogoutClick
        end
        object eUsers: TListView
          Left = 8
          Top = 28
          Width = 249
          Height = 336
          Color = clBtnFace
          Columns = <>
          Enabled = False
          IconOptions.Arrangement = iaLeft
          IconOptions.AutoArrange = True
          ReadOnly = True
          RowSelect = True
          SortType = stText
          TabOrder = 0
          ViewStyle = vsSmallIcon
        end
      end
    end
  end
  object pTitlebar: TPanel
    Left = 0
    Top = 0
    Width = 276
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
      Width = 274
      Height = 26
      Align = alClient
      Caption = '  RTC Portal Gateway v5'
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
      Left = 232
      Top = 4
      Width = 20
      Height = 21
      Caption = '--'
      OnClick = btnMinimizeClick
    end
    object btnClose: TSpeedButton
      Left = 252
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
  object lblStatusPanel: TPanel
    Left = 0
    Top = 469
    Width = 276
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
    TabOrder = 2
    object lblStatus: TLabel
      Left = 2
      Top = 2
      Width = 272
      Height = 29
      Align = alClient
      Alignment = taCenter
      AutoSize = False
      Caption = 'Click "START" to start the Gateway.'
      Transparent = False
      Layout = tlCenter
      WordWrap = True
    end
  end
  object HttpServer: TRtcHttpServer
    MultiThreaded = True
    Timeout.AfterConnecting = 300
    OnListenLost = HttpServerListenLost
    OnListenError = HttpServerListenError
    FixupRequest.RemovePrefix = True
    MaxRequestSize = 16000
    MaxHeaderSize = 64000
    Left = 16
    Top = 459
  end
  object RtcGateTestProvider: TRtcDataProvider
    Server = HttpServer
    OnCheckRequest = RtcGateTestProviderCheckRequest
    OnDataReceived = RtcGateTestProviderDataReceived
    Left = 96
    Top = 460
  end
  object Gateway: TRtcPortalGateway
    Server = HttpServer
    WriteLog = True
    AutoRegisterUsers = True
    AutoSaveInfo = True
    OnUserLogin = GatewayUserLogin
    OnUserLogout = GatewayUserLogout
    AutoSyncUserEvents = True
    EncryptionKey = 16
    ForceEncryption = True
    AutoSessionsLive = 600
    AutoSessions = True
    ModuleFileName = '/$rdgate'
    Left = 56
    Top = 460
  end
end
