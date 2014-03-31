unit fmuSMS;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, untModem, StdCtrls, ExtCtrls;

type
  TfrmSMS = class(TForm)
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    Label1: TLabel;
    MemoSMS:Tmemo;
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
  MemoSMS.Text := 'текст сообщения';
  ShowModal;
  Result.Number := LabeledEdit1.Text;
  Result.Text := MemoSMS.Text;
end;

procedure TfrmSMS.ShowSMS(ASMS: TSMSMessage);
begin
  LabeledEdit2.Enabled := True;
  LabeledEdit1.Text := ASMS.Number;
  LabeledEdit2.Text := ASMS.Time;
  MemoSMS.Text := ASMS.Text;
  ShowModal;
end;

end.
