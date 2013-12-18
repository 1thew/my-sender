object frmSMS: TfrmSMS
  Left = 740
  Top = 328
  Width = 252
  Height = 293
  Caption = 'SMS'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 96
    Width = 17
    Height = 13
    Caption = 'text'
  end
  object LabeledEdit1: TLabeledEdit
    Left = 16
    Top = 16
    Width = 201
    Height = 21
    EditLabel.Width = 32
    EditLabel.Height = 13
    EditLabel.Caption = 'sender'
    TabOrder = 0
  end
  object LabeledEdit2: TLabeledEdit
    Left = 16
    Top = 62
    Width = 201
    Height = 21
    EditLabel.Width = 51
    EditLabel.Height = 13
    EditLabel.Caption = 'date / time'
    TabOrder = 1
  end
  object Memo1: TMemo
    Left = 16
    Top = 112
    Width = 201
    Height = 129
    Lines.Strings = (
      'Memo1')
    TabOrder = 2
  end
end
