object Form1: TForm1
  Left = 192
  Top = 139
  Width = 289
  Height = 476
  Caption = 'RO Server Proxy'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label4: TLabel
    Left = 8
    Top = 288
    Width = 48
    Height = 13
    Caption = 'Messages'
  end
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 152
    Height = 24
    Caption = 'RO Server Proxy'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsItalic]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 8
    Top = 408
    Width = 145
    Height = 13
    Caption = #169' 2006 Tsusai, Kubia Systems'
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 160
    Width = 265
    Height = 121
    Caption = 'Client -> Proxy'
    TabOrder = 1
    object Hostname: TLabeledEdit
      Left = 8
      Top = 32
      Width = 121
      Height = 21
      EditLabel.Width = 98
      EditLabel.Height = 13
      EditLabel.Caption = 'WAN Hostname / IP'
      TabOrder = 0
    end
    object LocalLoginPort: TLabeledEdit
      Left = 136
      Top = 32
      Width = 121
      Height = 21
      EditLabel.Width = 79
      EditLabel.Height = 13
      EditLabel.Caption = 'Login Listen Port'
      TabOrder = 1
    end
    object LocalCharaPort: TLabeledEdit
      Left = 136
      Top = 80
      Width = 121
      Height = 21
      EditLabel.Width = 99
      EditLabel.Height = 13
      EditLabel.Caption = 'Character Listen Port'
      TabOrder = 2
    end
  end
  object Memo1: TMemo
    Left = 8
    Top = 304
    Width = 265
    Height = 65
    ReadOnly = True
    TabOrder = 2
  end
  object OnOff: TButton
    Left = 88
    Top = 376
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 4
    OnClick = OnOffClick
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 423
    Width = 281
    Height = 19
    Panels = <
      item
        Text = 'Users Routed: 0'
        Width = 150
      end
      item
        Text = 'Offline'
        Width = 50
      end>
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 40
    Width = 265
    Height = 113
    Caption = 'Proxy -> Server Settings (Usually LAN IPs and Ports)'
    TabOrder = 0
    object SLoginName: TLabeledEdit
      Left = 8
      Top = 32
      Width = 121
      Height = 21
      EditLabel.Width = 60
      EditLabel.Height = 13
      EditLabel.Caption = 'Login Server'
      TabOrder = 0
    end
    object SLoginPort: TLabeledEdit
      Left = 136
      Top = 32
      Width = 121
      Height = 21
      EditLabel.Width = 48
      EditLabel.Height = 13
      EditLabel.Caption = 'Login Port'
      TabOrder = 1
    end
    object SCharaPort: TLabeledEdit
      Left = 136
      Top = 72
      Width = 121
      Height = 21
      EditLabel.Width = 68
      EditLabel.Height = 13
      EditLabel.Caption = 'Character Port'
      TabOrder = 3
    end
    object SCharaName: TLabeledEdit
      Left = 8
      Top = 72
      Width = 121
      Height = 21
      EditLabel.Width = 80
      EditLabel.Height = 13
      EditLabel.Caption = 'Character Server'
      TabOrder = 2
    end
  end
  object Button2: TButton
    Left = 8
    Top = 376
    Width = 75
    Height = 25
    Caption = 'Clear'
    TabOrder = 3
    OnClick = Button2Click
  end
  object LoginProxy: TIdMappedPortTCP
    Bindings = <>
    CommandHandlers = <>
    DefaultPort = 6901
    Greeting.NumericCode = 0
    MaxConnectionReply.NumericCode = 0
    OnException = ProxyException
    OnListenException = ProxyListenException
    ReplyExceptionCode = 0
    ReplyTexts = <>
    ReplyUnknownCommand.NumericCode = 0
    MappedHost = 'localhost'
    MappedPort = 6900
    OnOutboundConnect = LoginProxyOutboundConnect
    Left = 16
    Top = 216
  end
  object LoginIntercept: TIdConnectionIntercept
    OnReceive = LoginInterceptReceive
    Left = 48
    Top = 216
  end
  object CharaProxy: TIdMappedPortTCP
    Bindings = <>
    CommandHandlers = <>
    DefaultPort = 0
    Greeting.NumericCode = 0
    MaxConnectionReply.NumericCode = 0
    OnException = ProxyException
    OnListenException = ProxyListenException
    ReplyExceptionCode = 0
    ReplyTexts = <>
    ReplyUnknownCommand.NumericCode = 0
    MappedPort = 0
    OnOutboundConnect = CharaProxyOutboundConnect
    Left = 16
    Top = 248
  end
  object CharaIntercept: TIdConnectionIntercept
    OnReceive = CharaInterceptReceive
    Left = 48
    Top = 248
  end
end
