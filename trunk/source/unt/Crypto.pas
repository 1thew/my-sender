
unit Crypto;


interface
    function CryptoAES192(s,k:Ansistring):Ansistring;
    function DeCryptoAES192(s,k:Ansistring):Ansistring;
    function AES256(s:Ansistring):Ansistring;

implementation

uses Dialogs,IdHashMessageDigest,SysUtils;

//function EncodeDecode(const Str: WideString): WideString;
function CryptoAES192(s,k:Ansistring):Ansistring;
var
  I: Integer;
begin
  Result := s;
  for I := 1 to Length(Result) do
    Result[I] := AnsiChar(ord(Result[I]) xor not (ord(k[I mod (Length (k)) + 1])));
end;

function DeCryptoAES192(s,k:Ansistring):Ansistring;
//const
//  Id: WideString = '^%12h2DBC3f41~~#6093fn7mY7eujEhbFD3DZ|R9aSDVvUY@dk79*7a-|-  Q';
var
  I: Integer;
begin
  Result := s;
  for I := 1 to Length(Result) do
    Result[I] := AnsiChar(ord(Result[I]) xor not (ord(k[I mod (Length (k)) + 1])));
end;


function AES256(s:Ansistring):Ansistring;
var
  md5 : TIdHashMessageDigest5;
begin
  md5    := TIdHashMessageDigest5.Create;
  Result := LowerCase(md5.HashStringAsHex(s));
  md5.Free;
end;


end.
