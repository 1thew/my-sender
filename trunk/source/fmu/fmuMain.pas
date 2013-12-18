unit fmuMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, untModem, StdCtrls, Spin, ExtCtrls, Math, ActiveX, IdBaseComponent,
  IdComponent, IdCustomTCPServer, IdCustomHTTPServer, IdHTTPServer,
  IdContext,Registry, Menus, ActnPopup, AppEvnts,
  Vcl.PlatformDefaultStyleActnCtrls, Vcl.ComCtrls, GetVersion;

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
    PageControl1: TPageControl;
    SettingsTab: TTabSheet;
    LogsTab: TTabSheet;
    TestTab: TTabSheet;
    sePort: TSpinEdit;
    Label3: TLabel;
    DisableSMS: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure IdHTTPServer1CommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure ParserHTTP(S:Ansistring);
    procedure Timer1OnTimer(Sender: TObject);
    procedure TrayClick(Sender: TObject);
    procedure AboutBtnClick(Sender: TObject);
    procedure ExitBtnClick(Sender: TObject);
    procedure ClearMemoClick(Sender: TObject);
    procedure OnClose(Sender: TObject; var Action: TCloseAction);
  private
    FGsmSms: TGsmSms;
    procedure LoadConfig;
    procedure SaveConfig;
    function SetSMS(n,m:Ansistring):TSMSMessage;
    procedure WMSysCommand(var Msg: TWMSysCommand);message WM_SYSCOMMAND;
  public
    procedure MemoWrite(AMessage: AnsiString);
  end;

var
  frmMain: TfrmMain;

implementation

uses fmuSMS;

{$R *.dfm}

procedure TfrmMain.MemoWrite(AMessage: AnsiString);
begin
  Memo1.Lines.Add(TimeToStr(GetTime)+' '+AMessage);
end;

procedure TfrmMain.OnClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveConfig;
end;

procedure TfrmMain.AboutBtnClick(Sender: TObject);
const PERENOS = Char($0D)+Char($0A);
begin
  MessageBox(handle, PChar('Программа разработана для altzakroma.ru'+ PERENOS+
  'автор программы К.Абрамовский'+ PERENOS+
  '2013'+PERENOS),
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

procedure TfrmMain.ClearMemoClick(Sender: TObject);
begin
  Memo1.Clear;
end;

procedure TfrmMain.ExitBtnClick(Sender: TObject);
begin
   frmMain.Close;
end;

function TfrmMain.SetSMS(n,m:Ansistring):TSMSMessage;
begin
  Result.Number := n;
  Result.Text := m;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  s:AnsiString;
begin
  LoadConfig;

   // узнаём версию и пишем в caption
  s:=FileVersion(Paramstr(0));
  frmMain.Caption:=(frmMain.Caption+' '+'ver.'+ s);
end;

procedure TfrmMain.IdHTTPServer1CommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  // функция для преобразования 1252 в 1251 (сервер получает данные в 1252)
  // function for convetring 1252 in 1251
  function FixString(const AData: String): String;
  var
    S: RawByteString;
    X: Integer;
  begin
    SetLength(S, Length(AData));    // выделили память под ANSI-буфер
    for X := 1 to Length(AData) do  // переносим данные из вида 00A400B700E700D5 в A4B7E7D5
      S[X] := AnsiChar(AData[X]);
    SetCodePage(S, 1251, False);    // пометим, что данные A4B7E7D5имеют кодировку Win1251.
                                    // False указывает на то, что сами данные менять не надо -
                                    // мы просто указываем, в какой они кодировке
    Result := S;                    // здесь компилятор автоматически преобразует строку из ANSI/Win1251 в unicode
  end;
  // конец
  // end
begin
    If Length (ARequestInfo.Params.Text) <1 then exit;

    ARequestInfo.Params.Text:= Utf8ToString(FixString(ARequestInfo.Params.Text));
    frmMain.ParserHTTP(ARequestInfo.Params.Text);
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

procedure TfrmMain.ParserHTTP(s:Ansistring);
var
  number, // номер строкой
  message:Ansistring; // сообщение строкой
  LSMS1: TSMSMessage;
begin
   // s - строка вхождения, переменные разделяются знаком =
   // tel=89612377997?Msg="asdasd"
   //// конец места для доп проверок
   number:=copy(s,5,11);
   message:=copy(s,21,(Length(s)-21));
   Memo1.Lines.Add(s);

   if DisableSMS.Checked then exit;
   LSMS1:=SetSMS(number,message);
   FGsmSms.SendSMS(LSMS1);
end;

procedure TfrmMain.LoadConfig;
var reg: TRegistry;
begin
  reg := TRegistry.Create();
  reg.RootKey := HKEY_LOCAL_MACHINE;
  if reg.OpenKey('\Software\altzakroma', True) then
  begin
    if reg.ValueExists('seCOM') then
      seCOM.value := reg.ReadInteger('seCOM');
    if reg.ValueExists('seTimeOut') then
      seTimeOut.value := reg.ReadInteger('seTimeOut');
    if reg.ValueExists('sePort') then
      sePort.value := reg.ReadInteger('sePort');
  end;
  reg.CloseKey;
  reg.Destroy;

  //прописываем веб-порт
  if sePort.Value >0 then  IdHTTPServer1.DefaultPort:=sePort.Value;
  // прописываем настройки по классу
  FGsmSms := TGsmSms.Create;
  FGsmSms.OnLog := MemoWrite;
  //seCOMChange(Sender);
  FGsmSms.PortNum := seCOM.Value;
  FGsmSms.TimeOut := seTimeOut.Value;
end;

procedure TfrmMain.SaveConfig;
var
  reg: TRegistry;
begin
  reg := TRegistry.Create();
  reg.RootKey := HKEY_LOCAL_MACHINE;
  if reg.OpenKey('\Software\altzakroma', True) then
  begin
    reg.WriteInteger('seCOM', seCOM.Value);
    reg.WriteInteger('seTimeOut', seTimeOut.Value);
    reg.WriteInteger('sePort', sePort.Value);
  end;
  reg.CloseKey;
  reg.Destroy;
end;


end.
