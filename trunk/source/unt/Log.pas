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
    // нужно писать в файл с указанием времени
    // узнать время и дату
    // http://www.delphisources.ru/pages/faq/faq_delphi_basics/Time.php.html
    // сначала узнаём текущую дату, если файл с таким
    //   названием не создан - создаём его.
    // создадим название
    LogFileName:= GetDateStr+'.log';
    //проверим на запись
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
   // узнать время и дату
   // http://www.delphisources.ru/pages/faq/faq_delphi_basics/Time.php.html
  dateStr:=DateToStr(now);
  // преобразуем, убираем / и ставим -
  dateStr:=StringReplace(dateStr,'/','-',[rfReplaceAll, rfIgnoreCase]);
  result:=  dateStr;
end;

function TLog.GetTimeStr:Ansistring;
begin
  result:=TimeToStr(GetTime);
end;

end.
