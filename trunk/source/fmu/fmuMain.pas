unit fmuMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, untModem, StdCtrls, Spin, ExtCtrls, Math, ActiveX, IdBaseComponent,
  IdComponent, IdCustomTCPServer, IdCustomHTTPServer, IdHTTPServer,
  IdContext,Registry, Menus, ActnPopup, AppEvnts,
  Vcl.PlatformDefaultStyleActnCtrls;

type
  TfrmMain = class(TForm)
    Memo1: TMemo;
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    seCOM: TSpinEdit;
    seTimeOut: TSpinEdit;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Timer1: TTimer;
    IdHTTPServer1: TIdHTTPServer;
    Button5: TButton;
    TrayIcon1: TTrayIcon;
    TrayPopupActionBar1: TPopupActionBar;
    ExitBtn: TMenuItem;
    AboutBtn: TMenuItem;
    ClearMemo: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure seCOMChange(Sender: TObject);
    procedure IdHTTPServer1CommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure ParserHTTP(S:string);
    procedure Timer1OnTimer(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure TrayClick(Sender: TObject);
    procedure AboutBtnClick(Sender: TObject);
    procedure ExitBtnClick(Sender: TObject);
    procedure ClearMemoClick(Sender: TObject);
  private
    FGsmSms: TGsmSms;
    function SetSMS(n,m:string):TSMSMessage;
    procedure WMSysCommand(var Msg: TWMSysCommand);message WM_SYSCOMMAND;
  public
    procedure MemoWrite(AMessage: String);
  end;

var
  frmMain: TfrmMain;

implementation

uses fmuSMS;

{$R *.dfm}

procedure TfrmMain.MemoWrite(AMessage: String);
begin
  Memo1.Lines.Add(TimeToStr(GetTime)+' '+AMessage);
end;

procedure TfrmMain.AboutBtnClick(Sender: TObject);
const PERENOS = Char($0D)+Char($0A);
begin
  MessageBox(handle, PChar('Программа разработана для altzakroma.ru'+ PERENOS+
  'автор программы К.Абрамовский'+ PERENOS+
  '2013'),
   PChar('О программе SMSSender'), MB_ICONQUESTION);
end;

procedure TfrmMain.Button1Click(Sender: TObject);
var
  LSMS: TSMSMessage;
begin
  LSMS := frmSMS.GetSMS;
  FGsmSms.SendSMS(LSMS);
end;

procedure TfrmMain.Button2Click(Sender: TObject);
var
  LSMS: TSMSMessage;
begin
  LSMS := FGsmSms.GetSMS(StrToInt(InputBox('Input number of message for read', 'number', '0')));
  frmSMS.ShowSMS(LSMS);
end;

procedure TfrmMain.Button3Click(Sender: TObject);
begin
  FGsmSms.DeleteSMS(StrToInt(InputBox('Input number of message for delete', 'number', '0')));
end;

procedure TfrmMain.Button4Click(Sender: TObject);
var
  LSMSs: TSMSMessages;
  i: Integer;
begin
  LSMSs := FGsmSms.GetAllSMS;

  for i := 0 to Length(LSMSs) - 1 do
    frmSMS.ShowSMS(LSMSs[i]);
end;

procedure TfrmMain.WMSysCommand(var Msg: TWMSysCommand);
begin
if Msg.CmdType = SC_MINIMIZE
  then
    {Сдесь делаем что нужно}
    frmMain.Visible:=false
  else
   inherited;
end;

procedure TfrmMain.Button5Click(Sender: TObject);
var number, message : string;
  LSMS: TSMSMessage;
begin
//      Edit1.Text:=TimeToStr(GetTime);
end;

procedure TfrmMain.ClearMemoClick(Sender: TObject);
begin
  Memo1.Clear;
end;

procedure TfrmMain.ExitBtnClick(Sender: TObject);
begin
   frmMain.Close;
end;

function TfrmMain.SetSMS(n,m:string):TSMSMessage;
begin
  Result.Number := n;
  Result.Text := m;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var reg: TRegistry;
begin
  FGsmSms := TGsmSms.Create;
  FGsmSms.OnLog := MemoWrite;
  seCOMChange(Sender);

  reg := TRegistry.Create();
  reg.RootKey := HKEY_CURRENT_USER;
  if reg.OpenKey('\Software\altzakroma', True) then
  begin
    if reg.ValueExists('seCOM') then
    begin
       seCOM.value := reg.ReadInteger('seCOM');
    end;

  end;
  reg.CloseKey;
  reg.Destroy;
end;

procedure TfrmMain.IdHTTPServer1CommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
    If Length (ARequestInfo.Params.Text) <1 then exit;
    ARequestInfo.Params.Text:=Utf8ToAnsi(ARequestInfo.Params.Text);
    frmMain.ParserHTTP(ARequestInfo.Params.Text);
end;

procedure TfrmMain.seCOMChange(Sender: TObject);
var
  reg: TRegistry;
begin
  if seCOM.Value<1 then exit;
  if seCOM.Value>99 then exit;
  

  reg := TRegistry.Create();
  reg.RootKey := HKEY_CURRENT_USER;
  if reg.OpenKey('\Software\altzakroma', True) then
  begin
    reg.WriteInteger('seCOM', seCOM.Value);
  end;
  reg.CloseKey;
  reg.Destroy;

  FGsmSms.PortNum := seCOM.Value;
  FGsmSms.TimeOut := seTimeOut.Value;
end;


procedure TfrmMain.Timer1OnTimer(Sender: TObject);
begin
  if isWork=true then exit;

  //if mySMSList.Count>1 then 
end;

procedure TfrmMain.TrayClick(Sender: TObject);
begin
   frmMain.Show;
end;

procedure TfrmMain.ParserHTTP(s:string);
var
  number:string; // номер строкой
  message:string; // сообщение строкой
  LSMS1: TSMSMessage;
begin
   // s - строка вхождения, переменные разделяются знаком =
   // tel=89612377997?Msg="asdasd"
   //// конец места для доп проверок
   number:=copy(s,5,11);
   message:=copy(s,21,(Length(s)-21));
   LSMS1:=SetSMS(number,message);
   Memo1.Lines.Add(s);
   FGsmSms.SendSMS(LSMS1);
end;

end.
