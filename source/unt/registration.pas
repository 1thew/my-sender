unit registration;

interface

uses
  SysUtils,
  ActiveX,
  ComObj,
  Variants;

var
  MbHW:Ansistring;
  HttpResponse:Ansistring;

  procedure GetCompUIN;
  //procedure  GetWin32_ComputerSystemProductInfo;
  procedure  GetWin32_CSPI;


//-----------------------------------------------------------------------------------------------------
//     This code was generated by the Wmi Delphi Code Creator (WDCC) Version 1.8.3.0
//     http://code.google.com/p/wmi-delphi-code-creator/
//     Blog http://theroadtodelphi.wordpress.com/wmi-delphi-code-creator/
//     Author Rodrigo Ruz V. (RRUZ) Copyright (C) 2011-2013
//-----------------------------------------------------------------------------------------------------
//
//     LIABILITY DISCLAIMER
//     THIS GENERATED CODE IS DISTRIBUTED "AS IS". NO WARRANTY OF ANY KIND IS EXPRESSED OR IMPLIED.
//     YOU USE IT AT YOUR OWN RISK. THE AUTHOR NOT WILL BE LIABLE FOR DATA LOSS,
//     DAMAGES AND LOSS OF PROFITS OR ANY OTHER KIND OF LOSS WHILE USING OR MISUSING THIS CODE.
//
//      ******* wmi delphi code creator *********
//----------------------------------------------------------------------------------------------------
implementation

procedure GetCompUIN;
begin
 try
    CoInitialize(nil);
    try
      GetWin32_CSPI;
    finally
      CoUninitialize;
    end;
 except    // ���������� ������
 end;
end;



procedure  GetWin32_CSPI;
const
  WbemUser            ='';
  WbemPassword        ='';
  WbemComputer        ='localhost';
  wbemFlagForwardOnly = $00000020;
var
  FSWbemLocator : OLEVariant;
  FWMIService   : OLEVariant;
  FWbemObjectSet: OLEVariant;
  FWbemObject   : OLEVariant;
  oEnum         : IEnumvariant;
  iValue        : LongWord;
begin;
  FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
  FWMIService   := FSWbemLocator.ConnectServer(WbemComputer, 'root\CIMV2', WbemUser, WbemPassword);
  FWbemObjectSet:= FWMIService.ExecQuery('SELECT * FROM Win32_ComputerSystemProduct','WQL',wbemFlagForwardOnly);
  oEnum         := IUnknown(FWbemObjectSet._NewEnum) as IEnumVariant;
  while oEnum.Next(1, FWbemObject, iValue) = 0 do
  begin
    MbHW:= FWbemObject.UUID;
    FWbemObject:=Unassigned;
  end;
end;
end.