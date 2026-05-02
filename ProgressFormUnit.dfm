object ProgressForm: TProgressForm
  Left = 235
  Top = 138
  BorderStyle = bsDialog
  Caption = #1054#1087#1077#1088#1072#1094#1080#1103' '#1074#1099#1087#1086#1083#1085#1103#1077#1090#1089#1103
  ClientHeight = 192
  ClientWidth = 297
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 8
    Top = 16
    Width = 281
    Height = 97
  end
  object lblProgressMessage: TLabel
    Left = 16
    Top = 24
    Width = 265
    Height = 81
    AutoSize = False
    WordWrap = True
  end
  object progressBar: TProgressBar
    Left = 8
    Top = 120
    Width = 281
    Height = 17
    TabOrder = 0
  end
  object btnInterrupt: TButton
    Left = 112
    Top = 152
    Width = 75
    Height = 25
    Caption = #1055#1088#1077#1088#1074#1072#1090#1100
    TabOrder = 1
    OnClick = btnInterruptClick
  end
  object timer: TTimer
    Interval = 100
    OnTimer = timerTimer
    Left = 256
    Top = 144
  end
end
