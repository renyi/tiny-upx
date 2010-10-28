object frmMain: TfrmMain
  Left = 742
  Top = 243
  Hint = 'Drag files here to pack.'
  BorderStyle = bsDialog
  Caption = 'tiny-upx | Drag files here to pack.'
  ClientHeight = 159
  ClientWidth = 316
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  PopupMenu = PopupMenu1
  ShowHint = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object edtOutput: TMemo
    Left = 0
    Top = 0
    Width = 316
    Height = 159
    Hint = 'Drag file here to pack.'
    Align = alClient
    ParentShowHint = False
    ReadOnly = True
    ScrollBars = ssVertical
    ShowHint = False
    TabOrder = 0
  end
  object PopupMenu1: TPopupMenu
    Left = 16
    Top = 16
    object AddtoExplorerShell1: TMenuItem
      AutoCheck = True
      Caption = 'Shell Context Menu'
      OnClick = AddtoExplorerShell1Click
    end
    object Close1: TMenuItem
      Caption = 'Close'
      OnClick = Close1Click
    end
  end
end
