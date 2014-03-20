unit fmuMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, untModem, StdCtrls, Spin, ExtCtrls, Math, ActiveX, IdBaseComponent,
  IdComponent, IdCustomTCPServer, IdCustomHTTPServer, IdHTTPServer,
  IdContext,Registry, Menus, ActnPopup, AppEvnts,
  Vcl.PlatformDefaultStyleActnCtrls, Vcl.ComCtrls, GetVersion, Log,
  registration, IdTCPConnection, IdTCPClient, IdHTTP, Crypto;

type
  TfrmMain = class(TForm)
    ConnectOpt: TPanel;
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
    MemoLog: TMemo;
    Apply: TButton;
    SaveInFile: TCheckBox;
    GroupBox2: TGroupBox;
    ActivationTab: TTabSheet;
    MbHWEdit: TEdit;
    KeyEdit: TEdit;
    Label4: TLabel;
    Activation: TButton;
    HTTPClient: TIdHTTP;
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
    procedure ApplyClick(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure ActivationClick(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private
    KeyString:Ansistring;
    FGsmSms: TGsmSms;
    procedure LoadConfig;
    procedure SaveConfig;
    procedure SaveLic(b:bool);
    function CheckLic: bool;   // ���� tru �� �� ���������, ����� - �������� �� �������������
    function SetSMS(n,m:Ansistring):TSMSMessage;
    procedure WMSysCommand(var Msg: TWMSysCommand);message WM_SYSCOMMAND;
  public
    procedure MemoWrite(AMessage: AnsiString);
  end;

var
  frmMain: TfrmMain;
  Log:TLog;


implementation

uses fmuSMS;

{$R *.dfm}

procedure TfrmMain.MemoWrite(AMessage: AnsiString);
begin
  MemoLog.Lines.Add(TimeToStr(GetTime)+' '+AMessage);
  Log.AddLogInFile(AMessage);
end;

procedure TfrmMain.OnClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveConfig;
end;

procedure TfrmMain.AboutBtnClick(Sender: TObject);
const PERENOS = Char($0D)+Char($0A);
begin
  MessageBox(handle, PChar('��������� ����������� ctr-it.ru'+ PERENOS+
  '������������ support@ctr-it.ru'+ PERENOS+
  '2014'+PERENOS),
   PChar('� ��������� SMSSender'), MB_ICONQUESTION);
end;

procedure TfrmMain.ActivationClick(Sender: TObject);
var dataStr:TStringList; // ������ ��� POST �������
const URL='http://ctr-it.ru/sms/registration.php';
begin
//*********************************
// �������� ���������� ����
  if Length(KeyEdit.Text)<16 then
  begin
    ShowMessage('��������� ����!');
    exit;
  end;

// ����� ����������  WHID + KEY
// ��� ������ ��������� POST ������
  dataStr:=TStringList.Create();
  dataStr.Values['hwid'] := MbHW;
  dataStr.Values['key'] := frmMain.KeyEdit.Text;
  try
    try
      HttpResponse:=HTTPClient.Post(URL, dataStr); //���������� POST ������
    except
      begin
        ShowMEssage('������ �� ��������.');
        Exit;
      end;
    end;
  finally
    begin
      dataStr.Free;
    end;
  end;
  //************************************
  //      �������� �� �����������
  //************************************
  if AnsiPos(HttpResponse,AES256(MbHW)) > 0 then SaveLic(true)
  else SaveLic(false);          // false - ��������
  // -----------------------------------



end;

procedure TfrmMain.ApplyClick(Sender: TObject);
begin
  SaveConfig;
  LoadConfig;
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

procedure TfrmMain.Button5Click(Sender: TObject);
var a,b,Key:Ansistring;
begin
end;



procedure TfrmMain.Button6Click(Sender: TObject);
var a,b: ansistring;
begin
  if CheckLic=true then ShowMEssage('CheckLic=true');
end;

procedure TfrmMain.WMSysCommand(var Msg: TWMSysCommand);
begin
if Msg.CmdType = SC_MINIMIZE
  then
    {����� ������ ��� �����}
    frmMain.Visible:=false
  else
   inherited;
end;

function TfrmMain.CheckLic: bool;
var s,version:AnsiString;
  f: TextFile; // ����
  buf: string[80]; // ����� ��� ������ �� �����
  stringlist:TStringlist;
const
  fName= 'key.lic'; // ��� �����
begin
result:=false;
try
  stringList:=TStringList.Create;
  stringList.LoadFromFile(fName);
  version:=FileVersion(Paramstr(0));
  s:=AES256(version+MbHW+KeyEdit.Text);
  if stringList.IndexOf(s) =0 then
    result := true
  else result:=false;
finally stringList.Free;
end;
end;

procedure TfrmMain.ClearMemoClick(Sender: TObject);
begin
  MemoLog.Clear;
end;

procedure TfrmMain.SaveLic(b:bool);
var
  version: ansistring;
  s:Ansistring;
  keyFileStringList:TStringList;
// ����� ���������� �������������� ������ � ����
const
   namekeyfile= 'key.lic';
begin
   keyFileStringList:=TstringList.Create;
   keyFileStringList.Clear;
   version:=FileVersion(Paramstr(0));   // ������ ������
   if b=false then version:=version+version;

   s:=AES256(version+MbHW+KeyEdit.Text);
   //keyFileStringList.Add(CryptoAES192(KeyEdit.text,KinderSupriseMD(version)));// ���������� ������ � �����
   keyFileStringList.Add(s);
   keyFileStringList.SaveToFile(namekeyfile,TEncoding.ASCII);
   FreeAndNil(keyFileStringList);
   ShowMessage('�������� ���������. ������� ���� ���������!');
   ShowMessage('������������� ���������!');
   Application.Terminate;
end;


procedure TfrmMain.ExitBtnClick(Sender: TObject);
begin
   frmMain.Close;
end;

function TfrmMain.SetSMS(n,m:Ansistring):TSMSMessage;
var r:integer;
begin
if CheckLic=false then
  begin
    Randomize;
    r:=random(100);
    if r<20 then
    begin
      ShowMessage('��������� �� ������������.');
      Application.Terminate;
    end;

  end;
  Result.Number := n;
  Result.Text := m;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  s:AnsiString;
begin
  // ������� HW ID
  GetCompUIN;
  MbHWEdit.Text:=MbHW;

  LoadConfig;

   // ����� ������ � ����� � caption
  s:=FileVersion(Paramstr(0));
  frmMain.Caption:=(frmMain.Caption+' '+'ver.'+ s);

  // �������� ��������
  if CheckLic=false then
  begin
    ShowMEssage('��������� �� ����������������! ���������...');
    Sleep(10000);
    PageControl1.ActivePage:=ActivationTab;
  end
  else PageControl1.ActivePage:=SettingsTab;

  Log:=TLog.Create;
  if frmMain.SaveInFile.Checked = true then Log.AllowSaveInFile:=true;

end;

procedure TfrmMain.IdHTTPServer1CommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  // ������� ��� �������������� 1252 � 1251 (������ �������� ������ � 1252)
  // function for convetring 1252 in 1251
  function FixString(const AData: String): String;
  var
    S: RawByteString;
    X: Integer;
  begin
    SetLength(S, Length(AData));    // �������� ������ ��� ANSI-�����
    for X := 1 to Length(AData) do  // ��������� ������ �� ���� 00A400B700E700D5 � A4B7E7D5
      S[X] := AnsiChar(AData[X]);
    SetCodePage(S, 1251, False);    // �������, ��� ������ A4B7E7D5����� ��������� Win1251.
                                    // False ��������� �� ��, ��� ���� ������ ������ �� ���� -
                                    // �� ������ ���������, � ����� ��� ���������
    Result := S;                    // ����� ���������� ������������� ����������� ������ �� ANSI/Win1251 � unicode
  end;
  // �����
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
  number, // ����� �������
  message:Ansistring; // ��������� �������
  LSMS1: TSMSMessage;
begin
   // s - ������ ���������, ���������� ����������� ������ =
   // tel=89612377997?Msg="asdasd"
   //// ����� ����� ��� ��� ��������
   number:=copy(s,5,11);
   message:=copy(s,21,(Length(s)-21));
   MemoWrite(s);

   if DisableSMS.Checked=true then exit;
   LSMS1:=SetSMS(number,message);
   FGsmSms.SendSMS(LSMS1);
end;

procedure TfrmMain.LoadConfig;
var reg: TRegistry;
begin
  try
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
    // �������, ���� 1 - ������
    if reg.ValueExists('SaveInFile') then
    begin
      if reg.ReadInteger('SaveInFile')=1 then
          frmMain.SaveInFile.Checked := true;
    end;

  end;
  reg.CloseKey;
  reg.Destroy;

  //����������� ���-����
  if sePort.Value >0 then  IdHTTPServer1.DefaultPort:=sePort.Value;
  // ����������� ��������� �� ������
  FGsmSms := TGsmSms.Create;
  FGsmSms.OnLog := MemoWrite;
  //seCOMChange(Sender);
  FGsmSms.PortNum := seCOM.Value;
  FGsmSms.TimeOut := seTimeOut.Value;
  Except
    ShowMessage('����������� ������ LoadConfig');
  end;
end;

procedure TfrmMain.SaveConfig;
var
  reg: TRegistry;
begin
try
  reg := TRegistry.Create();
  reg.RootKey := HKEY_LOCAL_MACHINE;
  if reg.OpenKey('\Software\altzakroma', True) then
  begin
    reg.WriteInteger('seCOM', seCOM.Value);
    reg.WriteInteger('seTimeOut', seTimeOut.Value);
    reg.WriteInteger('sePort', sePort.Value);
    if frmMain.SaveInFile.Checked=true then reg.WriteInteger('SaveInFile', 1)
    else  reg.WriteInteger('SaveInFile', 0)
  end;
  reg.CloseKey;
  reg.Destroy;
Except
    ShowMessage('����������� ������ SaveConfig');
end;
end;


end.
