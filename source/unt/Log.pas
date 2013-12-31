unit Log;

interface
uses SysUtils,Dialogs;

type
  TLog = class
  private
    { Private declarations }
    FAllowSaveInFile:boolean;
    LogFile:TextFile;
    LogFileName:AnsiString;
    function GetDateStr:Ansistring;
    function GetTimeStr:Ansistring;
    procedure SetFAllowSaveInFile(i:boolean);
  public
    procedure AddLogInFile(msg:Ansistring);
    property AllowSaveInFile:boolean write SetFAllowSaveInFile;
  end;



implementation


procedure TLog.SetFAllowSaveInFile(i:boolean);
begin
   FAllowSaveInFile:=i;
end;

procedure TLog.AddLogInFile(msg:Ansistring);
begin
    if FAllowSaveInFile=false then exit;
    // ����� ������ � ���� � ��������� �������
    // ������ ����� � ����
    // http://www.delphisources.ru/pages/faq/faq_delphi_basics/Time.php.html
    // ������� ����� ������� ����, ���� ���� � �����
    //   ��������� �� ������ - ������ ���.
    // �������� ��������
    LogFileName:= GetDateStr+'.log';
    //�������� �� ������
    try
      AssignFile(LogFile, LogFileName);
      if not FileExists(LogFileName) then
      begin
        Rewrite(LogFile);
        CloseFile(LogFile);
      end;
      Append(LogFile);
      WriteLn(LogFile, GetTimeStr+'  '+msg);
      CloseFile(LogFile);
    finally
    end;

end;



function TLog.GetDateStr:Ansistring;
var dateStr:ansistring;
begin
   // ������ ����� � ����
   // http://www.delphisources.ru/pages/faq/faq_delphi_basics/Time.php.html
  dateStr:=DateToStr(now);
  // �����������, ������� / � ������ -
  dateStr:=StringReplace(dateStr,'/','-',[rfReplaceAll, rfIgnoreCase]);
  result:=  dateStr;
end;

function TLog.GetTimeStr:Ansistring;
begin
  result:=TimeToStr(GetTime);
end;

end.
