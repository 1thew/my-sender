unit fmuSMS;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs;

type
  TfrmSMS = class(TForm)
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    MemoSMS: TMemo;
    Label1: TLabel;
  private
    { Private declarations }
  public
    procedure ShowSMS
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

end.
