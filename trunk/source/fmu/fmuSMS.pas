unit fmuSMS;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, untModem, StdCtrls, ExtCtrls;

type
  TfrmSMS = class(TForm)
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    Memo1: TMemo;
    Label1: TLabel;
  private
    { Private declarations }
  public
    procedure ShowSMS(ASMS: TSMSMessage);
    function GetSMS: TSMSMessage;
  end;

var
  frmSMS: TfrmSMS;

implementation


{$R *.dfm}

{ TfrmSMS }

function TfrmSMS.GetSMS: TSMSMessage;
begin
  LabeledEdit2.Enabled := False;
  LabeledEdit2.Text := '';
  LabeledEdit1.Text := '';
  Memo1.Text := 'бла бла бла';
  ShowModal;
  Result.Number := LabeledEdit1.Text;
  Result.Text := Memo1.Text;
end;

procedure TfrmSMS.ShowSMS(ASMS: TSMSMessage);
begin
  LabeledEdit2.Enabled := True;
  LabeledEdit1.Text := ASMS.Number;
  LabeledEdit2.Text := ASMS.Time;
  Memo1.Text := ASMS.Text;
  ShowModal;
end;

end.
