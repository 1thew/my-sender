program GSM_SMS;

uses
  Forms,
  fmuMain in 'fmu\fmuMain.pas' {frmMain},
  untModem in 'unt\untModem.pas',
  fmuSMS in 'fmu\fmuSMS.pas' {frmSMS},
  GetVersion in 'unt\GetVersion.pas',
  Log in 'unt\Log.pas',
  registration in 'unt\registration.pas',
  Crypto in 'unt\Crypto.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmSMS, frmSMS);
  Application.Run;
end.
