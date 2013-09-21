object Form1: TForm1
  Left = 397
  Top = 211
  Width = 268
  Height = 356
  BorderStyle = bsSizeToolWin
  Caption = 'vData / REED Converter'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 32
    Top = 0
    Width = 200
    Height = 24
    Caption = 'vData / REED Converter'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 64
    Top = 176
    Width = 117
    Height = 16
    Caption = 'Conversion Options'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentFont = False
  end
  object Label11: TLabel
    Left = 8
    Top = 304
    Width = 167
    Height = 13
    Caption = 'Copyright (c) 2005 Kubia Systems '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsItalic]
    ParentFont = False
  end
  object Button1: TButton
    Left = 120
    Top = 232
    Width = 75
    Height = 25
    Caption = 'Begin'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 0
    Top = 24
    Width = 257
    Height = 145
    Lines.Strings = (
      'ATTENTION!'
      'As with all conversion software, I HIGHLY, '
      'EXTREMELY, IMPLORE, and BEG you to '
      'back up all your vData or gamedata FIRST!')
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object GroupBox1: TGroupBox
    Left = 120
    Top = 192
    Width = 113
    Height = 33
    Ctl3D = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = 0
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 2
    object vData2REED: TRadioButton
      Left = 0
      Top = 0
      Width = 113
      Height = 17
      Caption = 'vData -> REED'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
    end
    object REED2vData: TRadioButton
      Left = 0
      Top = 16
      Width = 113
      Height = 17
      Caption = 'REED -> vData'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
    end
  end
  object GuildCheck: TCheckBox
    Left = 8
    Top = 192
    Width = 97
    Height = 17
    Caption = 'Guilds'
    TabOrder = 3
  end
  object PartyCheck: TCheckBox
    Left = 8
    Top = 240
    Width = 97
    Height = 17
    Caption = 'Parties'
    TabOrder = 4
  end
  object CastleCheck: TCheckBox
    Left = 8
    Top = 216
    Width = 97
    Height = 17
    Caption = 'Castles'
    TabOrder = 5
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 264
    Width = 145
    Height = 33
    Color = clBtnFace
    Ctl3D = False
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 6
    object AccOnlyCheck: TRadioButton
      Left = 0
      Top = 16
      Width = 145
      Height = 17
      Caption = 'Accounts Only'
      TabOrder = 0
    end
    object AccCharaCheck: TRadioButton
      Left = 0
      Top = 0
      Width = 153
      Height = 17
      Caption = 'Accounts and Characters'
      TabOrder = 1
    end
  end
end
