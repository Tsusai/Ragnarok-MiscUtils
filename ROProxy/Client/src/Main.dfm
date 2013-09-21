object Form1: TForm1
  Left = 192
  Top = 139
  Width = 289
  Height = 355
  Caption = 'RO Client Proxy'
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
    Top = 168
    Width = 48
    Height = 13
    Caption = 'Messages'
  end
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 144
    Height = 24
    Caption = 'RO Client Proxy'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsItalic]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 8
    Top = 288
    Width = 145
    Height = 13
    Caption = #169' 2006 Tsusai, Kubia Systems'
  end
  object OnOffLight: TShape
    Left = 8
    Top = 256
    Width = 25
    Height = 25
    Brush.Color = clRed
    Shape = stCircle
    OnMouseDown = OnOffLightMouseDown
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 40
    Width = 265
    Height = 121
    Caption = 'Client -> Proxy'
    TabOrder = 0
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
      TabOrder = 3
    end
    object SLoginPort: TLabeledEdit
      Left = 8
      Top = 80
      Width = 121
      Height = 21
      EditLabel.Width = 101
      EditLabel.Height = 13
      EditLabel.Caption = 'RO Server Login Port'
      TabOrder = 2
    end
  end
  object Memo1: TMemo
    Left = 8
    Top = 184
    Width = 265
    Height = 65
    ReadOnly = True
    TabOrder = 1
  end
  object OnOff: TButton
    Left = 40
    Top = 256
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 2
    OnClick = OnOffClick
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 309
    Width = 281
    Height = 19
    Panels = <
      item
        Text = 'Offline'
        Width = 50
      end>
  end
  object ClearBtn: TButton
    Left = 120
    Top = 256
    Width = 75
    Height = 25
    Caption = 'Clear'
    TabOrder = 3
    OnClick = ClearBtnClick
  end
  object LoginProxy: TIdMappedPortTCP
    Bindings = <>
    DefaultPort = 6901
    OnConnect = LoginProxyConnect
    OnException = ProxyException
    OnListenException = ProxyListenException
    MappedHost = 'localhost'
    MappedPort = 6900
    OnOutboundConnect = LoginProxyOutboundConnect
    Left = 152
  end
  object LoginIntercept: TIdConnectionIntercept
    OnReceive = LoginInterceptReceive
    Left = 184
  end
  object CharaProxy: TIdMappedPortTCP
    Bindings = <>
    DefaultPort = 0
    OnConnect = CharaProxyConnect
    OnException = ProxyException
    OnListenException = ProxyListenException
    MappedPort = 0
    OnOutboundConnect = CharaProxyOutboundConnect
    Left = 216
  end
  object CharaIntercept: TIdConnectionIntercept
    OnReceive = CharaInterceptReceive
    Left = 248
  end
end
