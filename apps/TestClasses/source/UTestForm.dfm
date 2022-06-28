object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 411
  ClientWidth = 852
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object EditGuest: TEdit
    Left = 152
    Top = 72
    Width = 121
    Height = 21
    TabOrder = 0
  end
  object EditRoom: TEdit
    Left = 152
    Top = 112
    Width = 121
    Height = 21
    TabOrder = 1
  end
  object Button1: TButton
    Left = 400
    Top = 216
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 2
    OnClick = Button1Click
  end
  object EditCheckIn: TEdit
    Left = 152
    Top = 152
    Width = 121
    Height = 21
    TabOrder = 3
  end
  object PanelStatus: TPanel
    Left = 240
    Top = 312
    Width = 457
    Height = 41
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 4
  end
end
