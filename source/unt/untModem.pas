unit untModem;

interface

uses
  Windows, SysUtils, SyncObjs, DateUtils,Classes,Dialogs;

const
  CRLF = #$D#$A;
  BUFF_SIZE = $FF;

  END_CMD = #26;

  BEGIN_MESSAGE = '+CMGL: ';
  READING_MESSAGE = '+CMGR: ';

  END_MESSAGES = CRLF + 'OK';

  CMD_CMGF = 'AT+CMGF=%d' + #$D;
  CMD_CSMS = 'AT+CSMS=%d' + #$D;
  CMD_CMGS = 'AT+CMGS=%d' + #$D;
  CMD_CMGL = 'AT+CMGL=%s' + #$D;
  CMD_CMGD = 'AT+CMGD=%d' + #$D;
  CMD_CMGR = 'AT+CMGR=%d' + #$D;

type

  TArrayOfString =  array of AnsiString;

  TOnLog = procedure(AMessage: AnsiString) of object;

  TComPort = class
  private
    FHandle: THandle;
    FEvent: TEvent;
    FOverlapped: TOverlapped;
    FBuf: array [0..BUFF_SIZE - 1] of Byte;
    FCount: Cardinal;

    FPortNum: Cardinal;
    FTimeOut: Cardinal;

    FOnLog: TOnLog;
    function Write: Boolean;
    function Read: Boolean;
    function GetOverlappedResult: BOOL;
    procedure ClearBuf;
  protected
    function WriteStr(AStr: AnsiString): Boolean;
    function ReadStr(out AStr: AnsiString): Boolean;

    function Open: Boolean;
    procedure Close;

    procedure LogMessage(AMessage: AnsiString);
  public
    constructor Create();

    property OnLog: TOnLog read FOnLog write FOnLog;
    property PortNum: Cardinal read FPortNum write FPortNum;
    property TimeOut: Cardinal read FTimeOut write FTimeOut;
  end;


  TSMSMessage = record
    Number: AnsiString;
    Text: AnsiString;
    Time: AnsiString;
  end;

  TSMSMessages = array of TSMSMessage;

  TMode = (mdInt = 0, mdStr = 1);

  TGetSMS = (gRecUnRd = 0, gRecRd = 1, gStoUnSt = 2, gStoSt = 3, gAll = 4);

  TGSMComander = class(TComPort)
  protected
    function SetModemMode(AMode: TMode): Boolean;
    function SendSMSMessage(ASMS: TSMSMessage): Boolean;
    function GetSMSMessages(AGetSMS: TGetSMS): TSMSMessages;
    function GetSMSMessage(AIndex: Integer): TSMSMessage;
    function ReadToOK(var ARead: AnsiString): Boolean;
    function DeleteSMSMessage(AIndex: Integer): Boolean;
  public
    class function StringToSMS(AStr: AnsiString): TSMSMessage;
    class function AnsiToUCS(AStr: AnsiString): AnsiString;
    class function UCSToAnsi(AStr: AnsiString): AnsiString;
  end;

  TGsmSms = class(TGSMComander)
  public
    function SendSMS(ASms: TSMSMessage): Boolean;
    function GetSMS(AIndex: Integer): TSMSMessage;
    function GetAllSMS: TSMSMessages;
    function DeleteSMS(AIndex: Integer): Boolean;
  end;

const
  GET_SMS: array [TGetSMS] of Ansistring = (
    '"REC UNREAD"',
    '"REC READ"',
    '"STO UNSENT"',
    '"STO SENT"',
    '"ALL"'
  );

  var isWork:boolean;
      MySMSList : TList;

  function StrParse(AStr: AnsiString; ASep: AnsiString): TArrayOfString;
  function StrPart(ABegin, AEnd, Str: AnsiString): AnsiString;

implementation

function StrPart(ABegin, AEnd, Str: AnsiString): AnsiString;
var
  b, c: Integer;
  s: AnsiString;
begin
  Result := '0';
  if ABegin <> '' then
    b := pos(ABegin, Str) + length(ABegin)
  else
    b := 1;
  s := copy(Str, b, length(Str) - b + 1);
  if AEnd <> '' then
  begin
    c := pos(AEnd, s);
    Result := copy(Str, b , c-1);
  end
  else
    Result := s;
end;


function StrParse(AStr: AnsiString; ASep: AnsiString): TArrayOfString;
var
  LPos, LLen, LLenSep: Integer;

  procedure AddToResult(Value: AnsiString);
  var
    c: Integer;
  begin
    c := Length(Result);
    SetLength(Result, c + 1);
    Result[c] := Value;
  end;

begin
  SetLength(Result, 0);
  LPos := pos(ASep, AStr);
  LLenSep := Length(ASep);
  while LPos > 0 do
  begin
    AddToResult(copy(AStr, 1, LPos-1));
    LLen := LPos + LLenSep;
    AStr := copy(AStr, LLen, Length(AStr)-LLen+1);
    LPos := pos(ASep, AStr);
  end;
  AddToResult(AStr);
end;

{ TComPort }

constructor TComPort.Create;
begin
  inherited;
  FHandle := INVALID_HANDLE_VALUE;
  FEvent := TEvent.Create(nil, false, false, '');
  FOverlapped.Internal := 0;
  FOverlapped.InternalHigh := 0;
  FOverlapped.Offset := 0;
  FOverlapped.OffsetHigh := 0;
  FOverlapped.hEvent := FEvent.Handle;
end;

function TComPort.Open: Boolean;
var
  dcb: TDCB;
  CommTimeOuts: TCommTimeouts;
begin
  FHandle := CreateFile(PChar('\\.\COM'+IntToStr(FPortNum)),GENERIC_READ or GENERIC_WRITE,
    0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL or FILE_FLAG_OVERLAPPED, 0);

  if FHandle <> INVALID_HANDLE_VALUE then
  begin
    sleep(1);
    //com port settings
    SetupComm(FHandle, 512, 512);
    GetCommState(FHandle, dcb);
    with dcb do
    begin
      BaudRate := CBR_115200;
      ByteSize := 8;
      Parity := NOPARITY;
      StopBits := ONESTOPBIT;
      Flags := 4113;
      XonChar := #17;
      XoffChar := #19;
    end;
    //
    with CommTimeOuts do
    begin
      ReadIntervalTimeout := 2000;
      ReadTotalTimeoutConstant := FTimeOut;
      ReadTotalTimeoutMultiplier := 10;
      WriteTotalTimeoutConstant := FTimeOut;
      WriteTotalTimeoutMultiplier := 10;
    end;

    SetCommState(FHandle, dcb);
    SetCommTimeouts(FHandle, CommTimeOuts);
    PurgeComm(FHandle, PURGE_RXCLEAR);
    PurgeComm(FHandle, PURGE_TXCLEAR);
    
    LogMessage(' OPEN: Success');
    Result := True;
  end else
  begin
    LogMessage('  OPEN: Error');
    Result := False;
  end;
end;

procedure TComPort.Close;
begin
  if FHandle <> INVALID_HANDLE_VALUE then
  begin
    CloseHandle(FHandle);
    FHandle := INVALID_HANDLE_VALUE;
    LogMessage('CLOSE: Success');
  end else
    LogMessage('CLOSE: Error');
end;

function TComPort.Write: Boolean;
var
  LDT: TDateTime;
begin
  Result := False;
  Windows.WriteFile(FHandle, FBuf, FCount, FCount, @FOverlapped);
  LDT := IncMilliSecond(now, TimeOut);

  while (not Result) and (now < LDT)do
  begin
    Result := GetOverlappedResult;
    sleep(10);
  end;
  ClearBuf;
end;

function TComPort.Read: Boolean;
var
  LDT: TDateTime;
begin
  Result := False;
  ClearBuf;
  Windows.ReadFile(FHandle, Fbuf, FCount, FCount, @FOverlapped);

  LDT := IncMilliSecond(now, TimeOut);

  while (not Result) and (now < LDT)do
  begin
    Result := GetOverlappedResult;
    sleep(10);
  end;
end;

function TComPort.GetOverlappedResult: BOOL;
begin
  Result := Windows.GetOverlappedResult(FHandle, FOverlapped, FCount, false);
end;

procedure TComPort.ClearBuf;
begin
  FillMemory(@FBuf[0], BUFF_SIZE, 0);
end;

function TComPort.WriteStr(AStr: AnsiString): Boolean;
begin
  FCount := Length(AStr);
  Move(AStr[1], FBuf[0], FCount);
  Result := Write;
  if Result then
    LogMessage('WRITE: ' + AStr);
end;

function TComPort.ReadStr(out AStr: AnsiString): Boolean;
begin
  AStr := '';
  FCount := BUFF_SIZE;
  Result := Read;
  SetLength(AStr, FCount);
  Move(FBuf[0], AStr[1], FCount);
  if Result then
    LogMessage('  READ: ' + AStr);
end;

procedure TComPort.LogMessage(AMessage: AnsiString);
begin
  if Assigned(FOnLog) then
    FOnLog(AMessage);
end;

{ TGSMComander }

class function TGSMComander.UCSToAnsi(AStr: AnsiString): AnsiString;


function CharToAnsiChar(Ch: Char): AnsiChar; inline;
begin
{$IFDEF UNICODE}
  WideCharToMultiByte({CP_ACP}DefaultSystemCodePage, 0, @Ch, 1, @Result, 1, nil, nil);
{$ELSE}
  Result := Ch;
{$ENDIF}
end;

  function Convert(ACnvStr: AnsiString): AnsiChar;
  var
    j: integer;
  begin
    j := StrToIntDef('$' + ACnvStr, 0);
    case j of
      1040..1103: j := j - 848;
      1105: j := 184;
    end;
    Result :=CharToAnsiChar(Chr(j));
  end;

var
  c, i: integer;
begin
  Result := '';
  c := Length(AStr) div 4;
  for i := 0 to c - 1 do
    Result := Result + Convert(Copy(AStr, i * 4 + 1, 4));
end;

class function TGSMComander.AnsiToUCS(AStr: AnsiString): AnsiString;

  function Convert(AChar: AnsiChar): AnsiString;
  var
    j: integer;
  begin
    Result := '';
    j := ord(AChar);
    case j of
      192..255: j := j + 848;
      184: j := 1105;
    end;
    Result := IntToHex(j, 4)
  end;

var
  c, i: integer;
begin
  Result := '';
  c := Length(AStr);
  for i := 1 to C do
    Result := Result + Convert(AStr[i]);
end;

class function TGSMComander.StringToSMS(AStr: AnsiString): TSMSMessage;
var
  LMess: TArrayOfString;
  LHeader: TArrayOfString;
begin
  LMess := StrParse(AStr, CRLF);
  if Length(LMess) >= 2 then
  begin
    LMess[0] := StringReplace(LMess[0], '"', '', [rfReplaceAll]);
    LHeader := StrParse(LMess[0], ',');

    if Length(LHeader) >= 6 then
    begin
      Result.Number := LHeader[2];
      Result.Time := LHeader[4] + ',' + LHeader[5];
      Result.Text := UCSToAnsi(LMess[1]);
    end;
  end;
end;

function TGSMComander.ReadToOK(var ARead: AnsiString): Boolean;
var
  LRead: AnsiString;
begin
  while (pos(END_MESSAGES, LRead) = 0) and ReadStr(LRead) do
    ARead := ARead + LRead;
  Result := True;
end;

function TGSMComander.SetModemMode(AMode: TMode): Boolean;
var
  LRead: AnsiString;
begin
  LRead := '';
  WriteStr(Format(CMD_CMGF, [ord(AMode)]));
  Result := ReadToOK(LRead);
end;

function TGSMComander.DeleteSMSMessage(AIndex: Integer): Boolean;
var
  LRead: AnsiString;
begin
  LRead := '';
  WriteStr(Format(CMD_CMGD, [AIndex]));
  Result := ReadToOK(LRead);
end;

function TGSMComander.GetSMSMessage(AIndex: Integer): TSMSMessage;
var
  LRead: AnsiString;
begin
  LRead := '';
  WriteStr(Format(CMD_CMGR, [AIndex]));
  if ReadToOK(LRead) then
    Result := StringToSMS('0,' + StrPart(READING_MESSAGE, END_MESSAGES, LRead));
end;

function TGSMComander.GetSMSMessages(AGetSMS: TGetSMS): TSMSMessages;
var
  LReadALL: AnsiString;
  LList: TArrayOfString;
  i: Integer;
begin
  WriteStr(Format(CMD_CMGL, [GET_SMS[AGetSMS]]));
  LReadALL := '';

  ReadToOK(LReadALL);

  LReadALL := StrPart('', END_MESSAGES, LReadALL);

  if pos(BEGIN_MESSAGE, LReadALL) > 0 then
  begin
    LReadALL := StrPart(BEGIN_MESSAGE, '', LReadALL);
    LList := StrParse(LReadALL, BEGIN_MESSAGE);
    SetLength(Result, Length(LList));
    for i := 0 to Length(LList) - 1 do
      Result[i] := TGsmSms.StringToSMS(LList[i]);
  end;
end;

function TGSMComander.SendSMSMessage(ASMS: TSMSMessage): Boolean;
var
  Lng, i,r:  Integer;
  LRead, LText, LMes, LTel, ANum: AnsiString;
begin

  ANum := ASms.Number;
  if (Length(ANum) mod 2) = 1 then
    ANum := ANum + 'F';

  for i := 1 to Length(ANum) do
    if i mod 2 = 0 then
      LTel := LTel + ANum[i] + ANum[i-1];

  LText := AnsiToUCS(ASms.Text);
  LMes := '00'; // Длина и номер SMS центра. 0 - означает, что будет использоваться дефолтный номер.
  LMes := LMes + '11'; // SMS-SUBMIT
  LMes := LMes + '00'; // Длина и номер отправителя. 0 - означает что будет использоваться дефолтный номер.
  LMes := LMes + IntToHex(Length(ASms.Number), 2); // Длина номера получателя
  LMes := LMes + '91'; // Тип-адреса. (91 указывает международный формат телефонного номера, 81 - местный формат).
  LMes := LMes + LTel; // Телефонный номер получателя в международном формате.
  LMes := LMes + '00'; // Идентификатор протокола
  LMes := LMes + '08'; // Старший полубайт означает сохранять SMS у получателя или нет (FLASH sms),  Младший полубайт - кодировка(0 - латиница 8 - кирилица).
  LMes := LMes + 'C1'; // Срок доставки сообщения. С1 - неделя
  LMes := LMes + IntToHex(Trunc(Length(LText)/2),2); // Длина текста сообщения.
  LMes := LMes + LText; // TP-User-Data. Эти октеты представляют сообщение "hellohello", преобразованное в 7 битку.
  Lng := Round((Length(LMes)-2)/2);

  WriteStr(Format(CMD_CMGS, [Lng]));
  WriteStr(LMes + END_CMD);

  Result := ReadToOK(LRead)
end;


{ TGsmSms }

function TGsmSms.GetSMS(AIndex: Integer): TSMSMessage;
begin
  Open;
  try
    SetModemMode(mdStr);
    Result := GetSMSMessage(AIndex);
  finally
    Close;
  end;
end;

function TGsmSms.SendSMS(ASms: TSMSMessage): Boolean;
begin
  Open;
  try
    SetModemMode(mdInt);
    Result := SendSMSMessage(ASms);
  finally
    Close;
  end;
end;

function TGsmSms.DeleteSMS(AIndex: Integer): Boolean;
begin
  Open;
  try
    SetModemMode(mdStr);
    Result := DeleteSMSMessage(AIndex);
  finally
    Close;
  end;
end;

function TGsmSms.GetAllSMS: TSMSMessages;
begin
  Open;
  try
    SetModemMode(mdStr);
    Result := GetSMSMessages(gAll);
  finally
    Close;
  end;
end;

end.
