unit S101TypesUnit;

interface

uses
  Classes, Contnrs, SysUtils;

type
  PInteger = ^Integer;
  PString = ^string;
  PDouble = ^Double;

  TMyObjectList = class(TObjectList)
  public
    constructor Create;
    function GetKeyByIndex(index: Integer): string; virtual; abstract;
    function GetIndexByKey(sKey: string): Integer;
    procedure Sort(Compare: TListSortCompare); virtual;
  private
    m_bSorted: Boolean;
  end;

  TKeyIValue = class
    sGUID: string;
    iValue: Integer;
    constructor Create(_sGUID: string; _iValue: Integer);
  end;

  TKeyIValueList = class(TMyObjectList)
    function GetKeyByIndex(index: Integer): string; override;
    function GetIValueByKey(sKey: string): Integer;
    procedure SortByKey;
  end;

  TISortedList = class(TObjectList)
    function GetIKeyByIndex(index: Integer): Integer; virtual; abstract;
    function GetIndexByIKey(iKey: Integer): Integer;
    procedure Sort; virtual; abstract;
  end;

  TInteger = class
    iValue: Integer;
    constructor Create(_iValue: Integer = 0);
  end;

  TIntegerList = class(TISortedList)
    function GetIKeyByIndex(index: Integer): Integer; override;
    procedure Sort; override;
  end;

  TPosIdPair = class
    iPos, id: Integer;
    constructor Create(_iPos, _id: Integer);
  end;

  TPosIdPairList = class(TISortedList)
    function GetIKeyByIndex(index: Integer): Integer; override;
    procedure Sort; override;
    function GetPosById(id: Integer): Integer;
  end;

  TTopicCategory = record
    code: Integer;
    name: string;
  end;

  TTopicCategories = array of TTopicCategory;

  TReadExportMethod = (ReadS101Binary, ExportToJSON, ReadS101JSON, ExportToBinary);

// —татусы завершени€ потока
const TERM_STATUS_SUCCESS   = 0; // успешное завершение
const TERM_STATUS_USERSTOP  = 1; // расчет прерван оператором
const TERM_STATUS_ERROR     = 2; // ошибка при расчете

const CONVERT_CC_TO_C = True;
const CONVERT_SOUNDG_MP3_TO_P = True;
//const CLOSE_RING = True;
const horzEPS = 1e-7;
const vertEPS = 1e-2;
const AssociationTypes: array[0..2] of string = ('Association', 'Aggregation', 'Composition');

var
  g_convertCCtoC: Boolean;
  g_convertSoundgMP3toP: Boolean;
  g_unknownAcronymMarker: string;
  g_wrongValueMarker: string;

implementation

// --------------------- TMyObjectList ---------------------

constructor TMyObjectList.Create;
begin
  m_bSorted := False;
end;

function TMyObjectList.GetIndexByKey(sKey: string): Integer;
var
  i, i1, i2: Integer;
begin
  Result := -1;
  if Count = 0 then Exit;
  if m_bSorted then begin
    i1 := 0;
    i2 := Count - 1;
    while True do begin
      if i2 - i1 <= 1 then begin
        if GetKeyByIndex(i1) = sKey then
          Result := i1
        else if GetKeyByIndex(i2) = sKey then
            Result := i2;
        Exit;
      end;
      i := (i1 + i2) div 2;
      if GetKeyByIndex(i) < sKey then
        i1 := i
      else if GetKeyByIndex(i) > sKey then
        i2 := i
      else begin
        Result := i;
        Exit;
      end;
    end;
  end
  else
    for i := 0 to Count - 1 do begin
      if GetKeyByIndex(i) = sKey then begin
        Result := i;
        Exit;
      end;
    end;
end;

procedure TMyObjectList.Sort(Compare: TListSortCompare);
begin
  TObjectList(Self).Sort(Compare);
  m_bSorted := True;
end;

// --------------------- TKeyIValueList ---------------------

constructor TKeyIValue.Create(_sGUID: string; _iValue: Integer);
begin
  sGUID := _sGUID;
  iValue := _iValue;
end;

function TKeyIValueList.GetKeyByIndex(index: Integer): string;
begin
  Result := '';
  if (index < 0) or (index >= Count) then
    Exit;
  Result := TKeyIValue(Self[index]).sGUID;
end;

function TKeyIValueList.GetIValueByKey(sKey: string): Integer;
var
  index: Integer;
begin
  Result := -1;
  index := GetIndexByKey(sKey);
  if index < 0 then
    Exit;
  Result := TKeyIValue(Self[index]).iValue;
end;

function CompareKeyIValueItems(Item1, Item2: Pointer): Integer;
var
  keyIValueItem1, keyIValueItem2: TKeyIValue;
begin
  keyIValueItem1 := TKeyIValue(Item1);
  keyIValueItem2 := TKeyIValue(Item2);
  Result := CompareStr(keyIValueItem1.sGUID, keyIValueItem2.sGUID);
end;

procedure TKeyIValueList.SortByKey;
begin
  Sort(CompareKeyIValueItems);
end;

function TISortedList.GetIndexByIKey(iKey: Integer): Integer;
var
  i, i1, i2: Integer;
begin
  Result := -1;
  if Count = 0 then Exit;
  i1 := 0;
  i2 := Count - 1;
  while True do begin
    if i2 - i1 <= 1 then begin
      if GetIKeyByIndex(i1) = iKey then
        Result := i1
      else if GetIKeyByIndex(i2) = iKey then
          Result := i2;
      Exit;
    end;
    i := (i1 + i2) div 2;
    if GetIKeyByIndex(i) < iKey then
      i1 := i
    else if GetIKeyByIndex(i) > iKey then
      i2 := i
    else begin
      Result := i;
      Exit;
    end;
  end;
end;

constructor TInteger.Create(_iValue: Integer);
begin
  iValue := _iValue;
end;

function TIntegerList.GetIKeyByIndex(index: Integer): Integer;
begin
  Result := TInteger(Self[index]).iValue;
end;

function CompareIKeys(Item1, Item2: Pointer): Integer;
begin
  Result := TInteger(Item1).iValue - TInteger(Item2).iValue;
end;

procedure TIntegerList.Sort;
begin
  TList(Self).Sort(CompareIKeys);
end;

constructor TPosIdPair.Create(_iPos, _id: Integer);
begin
  iPos := _iPos;
  id := _id;
end;

function TPosIdPairList.GetIKeyByIndex(index: Integer): Integer;
begin
  Result := TPosIdPair(Self[index]).id;
end;

function ComparePosIdPairs(Item1, Item2: Pointer): Integer;
begin
  Result := TPosIdPair(Item1).id - TPosIdPair(Item2).id;
end;

procedure TPosIdPairList.Sort;
begin
  TList(Self).Sort(ComparePosIdPairs);
end;

function TPosIdPairList.GetPosById(id: Integer): Integer;
var
  index: Integer;
begin
  Result := -1;
  index := GetIndexByIKey(id);
  if index < 0 then
    Exit;
  Result := TPosIdPair(Self[index]).iPos;
end;

end.
