object DMS101ConverterForm: TDMS101ConverterForm
  Left = 192
  Top = 125
  Width = 349
  Height = 174
  Caption = #1050#1086#1085#1074#1077#1088#1090#1077#1088' DM/S101'
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
  object btnConvertDMtoS101: TButton
    Left = 76
    Top = 24
    Width = 185
    Height = 25
    Caption = 'DM ---> S-101'
    TabOrder = 0
    OnClick = btnConvertDMtoS101Click
  end
  object btnConvertS101toDM: TButton
    Left = 76
    Top = 56
    Width = 185
    Height = 25
    Caption = 'S-101 ---> DM'
    TabOrder = 1
    OnClick = btnConvertS101toDMClick
  end
  object btnDMtoS101batch: TButton
    Left = 50
    Top = 88
    Width = 233
    Height = 25
    Caption = #1055#1072#1082#1077#1090#1085#1086#1077' '#1087#1088#1077#1086#1073#1088#1072#1079#1086#1074#1072#1085#1080#1077' DM --> S-101'
    Enabled = False
    TabOrder = 2
  end
  object OpenDialog1: TOpenDialog
    Left = 8
    Top = 16
  end
  object SaveDialog1: TSaveDialog
    Left = 8
    Top = 48
  end
end
