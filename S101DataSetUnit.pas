unit S101DataSetUnit;

interface

uses
  StrUtils, Classes, Controls, SysUtils, Contnrs, Forms, Dialogs, SyncObjs, Windows,
      S101TypesUnit, S101BinaryAccessUnit, S101CatalogueUnit, S101IniFileUnit;

type
  TCalculationThread = class;

  TS101DataSet = class
  public
    m_nAgencyCode: Integer;
    lrFieldsDescriptions: TLRFieldDescriptionArray;
    fieldTagPairs: TLRFieldTagPairArray;
    dsGeneralInfo: TDataSetGeneralInformation;
    fieldCSID: TCSIDField;
    crsArray: array of TCoordinateReferenceSystem;
    infoTypeRecords: array of TInformationType;
    pointRecords: array of TPointRec;
    multiPointRecords: array of TMultiPointRec;
    curveRecords: array of TCurveRec;
    compositeCurveRecords: array of TCompositeCurveRec;
    surfaceRecords: array of TSurfaceRec;
    featureRecords: array of TFeatureRec;
    s101Catalogue: TS101Catalogue;
    sCurrentID: string;
    tfLog: TextFile;
    calculationThread: TCalculationThread;  // Рабочий поток
  public
    constructor Create(catalogue: TS101Catalogue);
    destructor Destroy; override;
    function RunInWorkingThread(reMethod: TReadExportMethod; sFileName, sLogName: string; var sError: string): Integer; virtual;
    function ReadS101Binary(fileName, logName: string; var sError: string;
        bS57: Boolean = False; bDSIDOnly: Boolean = False): Boolean;
    function ExportToBinary(fileName, logName: string; var sError: string): Boolean;
    function FillRawFieldValue(pField: Pointer; fieldTag: string; varCount: Integer;
        var rawValue: TArrayOfChar): Boolean;
    function FillLeaderAndDir(fieldSizeArray: TArrayOfFieldSize; var lrLeader: TLRLeader;
        var lrDir: TArrayOfChar): Boolean;
    function GetAttributeValue(attrCode: Integer; attrArray: array of TATTRField): string; overload;
    function GetAttributeValue(attrAcronym: string; attrArray: array of TATTRField): string; overload;
    function DeleteAttribute(attrCode: Integer; var attrArray: array of TATTRField): Boolean; overload;
    function DeleteAttribute(attrAcronym: string; var attrArray: array of TATTRField): Boolean; overload;
    function GenerateFOIDs: Boolean;
    function GetCellExtent(var latMin: Double; var lonMin: Double; var latMax: Double; var lonMax: Double): Boolean;
//    function UniteCommonGeometry: Boolean;
//    function UniteCurves(curve1, curve2: TCurveRec; var compositeCurve1, compositeCurve2: TCompositeCurveRec): Boolean;
  end;

// Класс рабочего потока, в котором выполняется расчет
  TCalculationThread = class(TThread)
  protected
    m_dsS101: TS101DataSet;
    m_reMethod: TReadExportMethod;
    m_sFileName, m_sLogName: string;
  public
    m_sError: string;
    m_nTermStatus: Integer;
  public
    constructor Create(dsS101: TS101DataSet; reMethod: TReadExportMethod;
        sFileName, sLogName: string; bCreateSuspended: Boolean = False);
  protected
    procedure Execute; override;
  end;

  TAttrElemArray = array of TAttrElem;
  TINASFieldArray = array of TINASField;
  TC2ILFieldArray = array of TC2ILField;
  TC3ILFieldArray = array of TC3ILField;
  TC2FLFieldArray = array of TC2FLField;
  TC3FLFieldArray = array of TC3FLField;

function IsEqual(arrayOfAttrElem1, arrayOfAttrElem2: array of TAttrElem): Boolean; overload;
function IsEqual(fATTRArray1, fATTRArray2: array of TATTRField): Boolean; overload;
//function IsEqual(fINASArray1, fINASArray2: array of TINASField): Boolean; overload;
function IsEqual(fINASArray1, fINASArray2: array of TINASField; ds1, ds2: TS101DataSet): Boolean; overload;
//function IsEqual(infoRec1, infoRec2: TInformationType): Boolean; overload;
function IsEqual(infoRec1, infoRec2: TInformationType; ds1, ds2: TS101DataSet): Boolean; overload;
//function IsEqual(pointRec1, pointRec2: TPointRec): Boolean; overload;
function IsEqual(pointRec1, pointRec2: TPointRec; ds1, ds2: TS101DataSet): Boolean; overload;
function IsEqual(fC2ILArray1, fC2ILArray2: array of TC2ILField): Boolean; overload;
function IsEqual(fC3ILArray1, fC3ILArray2: array of TC3ILField): Boolean; overload;
function IsEqual(fC2FLArray1, fC2FLArray2: array of TC2FLField): Boolean; overload;
function IsEqual(fC3FLArray1, fC3FLArray2: array of TC3FLField): Boolean; overload;
//function IsEqual(multiPointRec1, multiPointRec2: TMultiPointRec): Boolean; overload;
function IsEqual(multiPointRec1, multiPointRec2: TMultiPointRec; ds1, ds2: TS101DataSet): Boolean; overload;
function IsEqual(fPTAS1, fPTAS2: TPTASField; coordType: TCoordType; ds1, ds2: TS101DataSet): Boolean; overload;
function IsEqual(fSegmentArray1, fSegmentArray2: array of TSegmentElem; coordType: TCoordType): Boolean; overload;
function IsEqual(curveRec1, curveRec2: TCurveRec; ds1, ds2: TS101DataSet): Boolean; overload;
function IsEqual(compositeCurveRec1, compositeCurveRec2: TCompositeCurveRec; ds1, ds2: TS101DataSet): Boolean; overload;
function IsEqual(surfaceRec1, surfaceRec2: TSurfaceRec; ds1, ds2: TS101DataSet): Boolean; overload;
function IsEqual(fSPASArray1, fSPASArray2: array of TSPASField; ds1, ds2: TS101DataSet): Boolean; overload;
function IsEqual(featureRec1, featureRec2: TFeatureRec; ds1, ds2: TS101DataSet; bCheckGeometry: Boolean = True): Boolean; overload;
function IsEqual(index1, index2: Integer; recType: TRecordTypeCode; ds1, ds2: TS101DataSet): Boolean; overload;

procedure S101Copy(attrElemArray1: TAttrElemArray; var attrElemArray2: TAttrElemArray); overload;
procedure S101Copy(fINASArray1: TINASFieldArray; var fINASArray2: TINASFieldArray); overload;
procedure S101Copy(fC2ILFieldArray1: TC2ILFieldArray; var fC2ILFieldArray2: TC2ILFieldArray); overload;
procedure S101Copy(fC3ILFieldArray1: TC3ILFieldArray; var fC3ILFieldArray2: TC3ILFieldArray); overload;
procedure S101Copy(fC2FLFieldArray1: TC2FLFieldArray; var fC2FLFieldArray2: TC2FLFieldArray); overload;
procedure S101Copy(fC3FLFieldArray1: TC3FLFieldArray; var fC3FLFieldArray2: TC3FLFieldArray); overload;
procedure S101Copy(pointRec1: TPointRec; var pointRec2: TPointRec); overload;
procedure S101Copy(multipointRec1: TMultiPointRec; var multipointRec2: TMultiPointRec); overload;
procedure S101Copy(curveRec1: TCurveRec; var curveRec2: TCurveRec); overload;
procedure S101Copy(compositeCurveRec1: TCompositeCurveRec; var compositeCurveRec2: TCompositeCurveRec); overload;
procedure S101Copy(surfaceRec1: TSurfaceRec; var surfaceRec2: TSurfaceRec); overload;
procedure S101Copy(infoRec1: TInformationType; var infoRec2: TInformationType); overload;
procedure S101Copy(feature1: TFeatureRec; var feature2: TFeatureRec); overload;

procedure ClearRec(var infoRec: TInformationType); overload;
procedure ClearRec(var pointRec: TPointRec); overload;
procedure ClearRec(var multiPointRec: TMultiPointRec); overload;
procedure ClearRec(var curveRec: TCurveRec); overload;
procedure ClearRec(var compositeCurveRec: TCompositeCurveRec); overload;
procedure ClearRec(var surfaceRec: TSurfaceRec); overload;
procedure ClearRec(var featureRec: TFeatureRec); overload;

implementation

uses
  ProgressFormUnit, DMS101ConverterFormUnit;

{$I S101FunctionsIncl.pas}

// --------------------- TCalculationThread ---------------------

constructor TCalculationThread.Create(dsS101: TS101DataSet; reMethod: TReadExportMethod;
    sFileName, sLogName: string; bCreateSuspended: Boolean = False);
begin
  inherited Create(bCreateSuspended);
  m_dsS101 := dsS101;
  m_reMethod := reMethod;
  m_sFileName := sFileName;
  m_sLogName := sLogName;
  m_nTermStatus := TERM_STATUS_SUCCESS;
end;

procedure TCalculationThread.Execute;
begin
  case m_reMethod of
    // Для S-57
    //ReadS101Binary: m_dsS101.ReadS101Binary(m_sFileName, m_sLogName, m_sError, True);
    // Для S-101
    ReadS101Binary: m_dsS101.ReadS101Binary(m_sFileName, m_sLogName, m_sError);
    ExportToBinary: m_dsS101.ExportToBinary(m_sFileName, m_sLogName, m_sError);
  end;
  finishedEvent.SetEvent;
end;

// --------------------- TS101DataSet ---------------------

function TS101DataSet.RunInWorkingThread(reMethod: TReadExportMethod;
    sFileName, sLogName: string; var sError: string): Integer;
begin
  try
    // Создадим и запустим рабочий поток
    suspendEvent.SetEvent;
    finishedEvent.ResetEvent;
    breakEvent.ResetEvent;
    calculationThread := TCalculationThread.Create(self, reMethod, sFileName, sLogName);

    // Создадим и откроем в модальном режиме окно прогресса
    ProgressForm := TProgressForm.Create(Application);
    ProgressForm.ShowModal;
    ProgressForm.Release;

    // Сообщим, если что-то пошло не так, и выйдем
    if calculationThread.m_nTermStatus = TERM_STATUS_ERROR then
      sError := calculationThread.m_sError;
    Result := calculationThread.m_nTermStatus;
  finally
    calculationThread.Free;
    calculationThread := nil;
  end;
end;

constructor TS101DataSet.Create(catalogue: TS101Catalogue);
begin
  s101Catalogue := catalogue;
  ZeroMemory(@dsGeneralInfo, SizeOf(TDataSetGeneralInformation));
end;

destructor TS101DataSet.Destroy;
var
  i: Integer;
begin
  for i := 0 to Length(lrFieldsDescriptions) - 1 do begin
    SetLength(lrFieldsDescriptions[i].subfieldsDescriptions, 0);
    lrFieldsDescriptions[i].subfieldsDescriptions := nil;
  end;
  SetLength(lrFieldsDescriptions, 0);
  lrFieldsDescriptions := nil;
  SetLength(fieldTagPairs, 0);
  fieldTagPairs := nil;
  for i := 0 to Length(crsArray) - 1 do begin
    SetLength(crsArray[i].fCSAX, 0);
    crsArray[i].fCSAX := nil;
    if crsArray[i].pfPROJ <> nil then begin
      Dispose(crsArray[i].pfPROJ);
      crsArray[i].pfPROJ := nil;
    end;
    if crsArray[i].pfGDAT <> nil then begin
      Dispose(crsArray[i].pfGDAT);
      crsArray[i].pfGDAT := nil;
    end;
    if crsArray[i].pfVDAT <> nil then begin
      Dispose(crsArray[i].pfVDAT);
      crsArray[i].pfVDAT := nil;
    end;
  end;
  SetLength(crsArray, 0);
  crsArray := nil;
  for i := 0 to Length(infoTypeRecords) - 1 do
    ClearRec(infoTypeRecords[i]);
  SetLength(infoTypeRecords, 0);
  infoTypeRecords := nil;
  for i := 0 to Length(pointRecords) - 1 do
    ClearRec(pointRecords[i]);
  SetLength(pointRecords, 0);
  pointRecords := nil;
  for i := 0 to Length(multiPointRecords) - 1 do
    ClearRec(multiPointRecords[i]);
  SetLength(multiPointRecords, 0);
  multiPointRecords := nil;
  for i := 0 to Length(curveRecords) - 1 do
    ClearRec(curveRecords[i]);
  SetLength(curveRecords, 0);
  curveRecords := nil;
  for i := 0 to Length(compositeCurveRecords) - 1 do
    ClearRec(compositeCurveRecords[i]);
  SetLength(compositeCurveRecords, 0);
  compositeCurveRecords := nil;
  for i := 0 to Length(surfaceRecords) - 1 do
    ClearRec(surfaceRecords[i]);
  SetLength(surfaceRecords, 0);
  surfaceRecords := nil;
  for i := 0 to Length(featureRecords) - 1 do
    ClearRec(featureRecords[i]);
  SetLength(featureRecords, 0);
  featureRecords := nil;
  inherited;
end;

function TS101DataSet.FillLeaderAndDir(fieldSizeArray: TArrayOfFieldSize; var lrLeader: TLRLeader;
        var lrDir: TArrayOfChar): Boolean;
var
  i, fieldLenMax, fieldPosMax, fieldLenSize, fieldPosSize, fieldTagSize, fieldLength, fieldPos: Integer;
  nBaseAddress, nRecLen: Integer;
  sFieldDirectory, s: string;
begin
  Result := False;
  if Length(fieldSizeArray) = 0 then
    Exit;
  fieldLenMax := 0;
  fieldPosMax := 0;
  for i := 0 to Length(fieldSizeArray) - 1 do begin
    if fieldLenMax < fieldSizeArray[i].m_nSize then
      fieldLenMax := fieldSizeArray[i].m_nSize;
    if i < Length(fieldSizeArray) - 1 then
      fieldPosMax := fieldPosMax + fieldSizeArray[i].m_nSize;
  end;
  fieldLenSize := Length(Format('%d', [fieldLenMax]));
  fieldPosSize := Length(Format('%d', [fieldPosMax]));
  fieldTagSize := 4;
  Move(Format('%d%d0%d', [fieldLenSize, fieldPosSize, fieldTagSize])[1], lrLeader.entryMap[0], 4);
  fieldPos := 0;
  fieldLength := 0;
  for i := 0 to Length(fieldSizeArray) - 1 do begin
    fieldLength := fieldSizeArray[i].m_nSize;
    sFieldDirectory := sFieldDirectory + Format('%-*.*s%*.*d%*.*d',
        [fieldTagSize, fieldTagSize, fieldSizeArray[i].m_sTag,
        fieldLenSize, fieldLenSize, fieldLength,
        fieldPosSize, fieldPosSize, fieldPos]);
    fieldPos := fieldPos + fieldLength;
  end;
  sFieldDirectory := sFieldDirectory + #$1E;
  SetLength(lrDir, Length(sFieldDirectory));
  Move(sFieldDirectory[1], lrDir[0], Length(lrDir));
  nBaseAddress := SizeOf(lrLeader) + Length(sFieldDirectory);
  s := Format('%*.*d', [SizeOf(lrLeader.baseAddressOfFieldArea),
      SizeOf(lrLeader.baseAddressOfFieldArea), nBaseAddress]);
  Move(s[1], lrLeader.baseAddressOfFieldArea[0],
      SizeOf(lrLeader.baseAddressOfFieldArea));
  nRecLen := nBaseAddress + fieldPos;
  s := Format('%*.*d', [SizeOf(lrLeader.recordLength),
      SizeOf(lrLeader.recordLength), nRecLen]);
  Move(s[1], lrLeader.recordLength[0], SizeOf(lrLeader.recordLength));
  Result := True;
end;

function TS101DataSet.FillRawFieldValue(pField: Pointer; fieldTag: string; varCount: Integer;
    var rawValue: TArrayOfChar): Boolean;
var
  iField, iSubfield, iSourcePos, iDestPos, iLen, code, iCount, iFirstMulti: Integer;
  s: string;
  p: Pointer;
begin
  Result := False;
  for iField := 0 to Length(lrFieldsDescriptions) - 1 do
    if lrFieldsDescriptions[iField].fieldTag = fieldTag then
      Break;
  if iField = Length(lrFieldsDescriptions) then
    Exit;
  SetLength(rawValue, 100000);
  iSubfield := 0;
  iSourcePos := 0;
  iDestPos := 0;
  iCount := 0;
  iFirstMulti := -1;
  p := pField;
  repeat
    with lrFieldsDescriptions[iField].subfieldsDescriptions[iSubfield] do begin
      if sfMulti and (iFirstMulti < 0) then begin
        if varCount = 0 then
          Break;
        iFirstMulti := iSubfield;
        p := Pointer(PInteger(PChar(p) + iSourcePos)^);
        iSourcePos := 0;
      end;
      if sfType[1] = 'A' then begin
        s := PString(PChar(p) + iSourcePos)^;
        if sfType = 'A' then begin
          iLen := Length(s);
          Move(s[1], rawValue[iDestPos], iLen);
          iDestPos := iDestPos + iLen;
          rawValue[iDestPos] := #$1F;
          iDestPos := iDestPos + 1;
          iSourcePos := iSourcePos + SizeOf(string);
        end
        else begin
          Val(sfType[3], iLen, code);
          Move(s[1], rawValue[iDestPos], iLen);
          iDestPos := iDestPos + iLen;
          iSourcePos := iSourcePos + SizeOf(string);
        end;
      end
      else if sfType = 'b48' then begin
        Move(PDouble(PChar(p) + iSourcePos)^, rawValue[iDestPos], 8);
        iDestPos := iDestPos + 8;
        iSourcePos := iSourcePos + 8;
      end
      else begin
        Val(sfType[3], iLen, code);
        Move(PInteger(PChar(p) + iSourcePos)^, rawValue[iDestPos], iLen);
        iDestPos := iDestPos + iLen;
        iSourcePos := iSourcePos + 4;
      end;
      if iSubfield = Length(lrFieldsDescriptions[iField].subfieldsDescriptions) - 1 then begin
        if sfMulti then begin
          if iCount = varCount - 1 then
            Break
          else begin
            iSubfield := iFirstMulti;
            iCount := iCount + 1;
          end;
        end
        else
          Break;
      end
      else
        iSubfield := iSubfield + 1;
    end;
  until False;
  rawValue[iDestPos] := #$1E;
  iDestPos := iDestPos + 1;
  SetLength(rawValue, iDestPos);
  Result := True;
end;

function CheckLeader(lrLeader: TLRLeader; bDDR: Boolean): Boolean;
var
  code, recLen, intLevel, baseAddr: Integer;
  s: string;
  MyDigits1, MyDigits2: set of '1'..'9';
begin
  Result := False;
  Val(lrLeader.recordLength, recLen, code);
  if (code <> 0) or (recLen = 0) then
    Exit;
  Val(lrLeader.baseAddressOfFieldArea, baseAddr, code);
  if (code <> 0) or (baseAddr = 0) or (baseAddr >= recLen) then
    Exit;
  MyDigits1 := ['1', '2', '3', '4', '5', '6', '7', '8', '9'];
  MyDigits2 := ['1', '2', '3', '4', '5', '6', '7'];
  if not (lrLeader.entryMap[0] in MyDigits1) or not (lrLeader.entryMap[1] in MyDigits1) or
      (lrLeader.entryMap[2] <> '0') or not (lrLeader.entryMap[3] in MyDigits2) then
    Exit;
  if bDDR then begin
    if (lrLeader.interchangeLevel <> '1') and (lrLeader.interchangeLevel <> '2') and
        (lrLeader.interchangeLevel <> '3') then
      Exit;
    if lrLeader.leaderIdentifier <> 'L' then
      Exit;
    if (lrLeader.inlineCodeExtensionIndicator <> ' ') and
        (lrLeader.inlineCodeExtensionIndicator <> 'E') and
        (lrLeader.inlineCodeExtensionIndicator <> 'h') and
        (lrLeader.inlineCodeExtensionIndicator <> 'H') then
      Exit;
    if (lrLeader.versionNumber <> ' ') and (lrLeader.versionNumber <> '1') then
      Exit;
    s := Copy(lrLeader.fieldControlLength, 0, 2);
    if (s <> '00') and (s <> '03') and (s <> '06') and (s <> '09') then
      Exit;
  end
  else begin
    if lrLeader.interchangeLevel <> ' ' then
      Exit;
    if (lrLeader.leaderIdentifier <> 'D') and (lrLeader.leaderIdentifier <> 'R') then
      Exit;
    if lrLeader.inlineCodeExtensionIndicator <> ' ' then
      Exit;
    if lrLeader.versionNumber <> ' ' then
      Exit;
    if lrLeader.applicationIndicator <> ' ' then
      Exit;
    s := Copy(lrLeader.fieldControlLength, 0, 2);
    if s <> '  ' then
      Exit;
    s := Copy(lrLeader.extendedCharacterSetIndicator, 0, 3);
    if s <> '   ' then
      Exit;
  end;
  Result := True;
end;

const DSIDsubfields: array[0..13] of string = ('RCNM', 'RCID', 'ENSP', 'ENED', 'PRSP', 'PRED', 'PROF',
    'DSNM', 'DSTL', 'DSRD', 'DSLG', 'DSAB', 'DSED', 'DSTC');
const S57DSIDsubfields: array[0..15] of string = ('RCNM', 'RCID', 'EXPP', 'INTU', 'DSNM', 'EDTN', 'UPDN',
    'UADT', 'ISDT', 'STED', 'PRSP', 'PSDN', 'PRED', 'PROF', 'AGEN', 'COMT');

function CheckFieldsDescriptions(lrFieldsDescriptions: TLRFieldDescriptionArray; bS57: Boolean): Boolean;
var
  iField, iSubfield: Integer;
begin
  Result := False;
  for iField := 0 to Length(lrFieldsDescriptions) - 1 do
    if lrFieldsDescriptions[iField].fieldTag = 'DSID' then
      for iSubfield := 0 to Length(lrFieldsDescriptions[iField].subfieldsDescriptions) - 1 do
        if bS57 then begin
          if (iSubfield >= Length(S57DSIDsubfields)) or
              (lrFieldsDescriptions[iField].subfieldsDescriptions[iSubfield].sfTag <>
              S57DSIDsubfields[iSubfield]) then Exit;
        end
        else begin
          if (iSubfield >= Length(DSIDsubfields)) or
              (lrFieldsDescriptions[iField].subfieldsDescriptions[iSubfield].sfTag <>
              DSIDsubfields[iSubfield]) then Exit;
        end;
  Result := True;
end;

function TS101DataSet.ReadS101Binary(fileName, logName: string; var sError: string;
    bS57: Boolean; bDSIDOnly: Boolean): Boolean;
var
  fH: Integer;
  nBytesRead, code, curPos, recNo, iTag, iSubField, iFieldTagPair, nFileLength: Integer;
  lrRecLen, lrDirLen, addrFieldArea: Integer;
  i, j, fieldTagSize, fieldLengthSize, fieldPositionSize, fieldEntrySize: Integer;
  iCRS: Integer;
  lrLeader: TLRLeader;
  lrDirectoryRec: array of Char;
  lrFieldEntryBuffer: array[0..7] of Char;
  lrFieldValue, buffer: TDynamicCharArray;
  bEOF: Boolean;
  s, logPath, sfValue: string;
  fieldTag, sOwnerFieldTag: string;
  fieldLength: Integer;
  fieldPosition: Integer;
  subFields: TLRSubfieldArray;
  iInfoTypeRecNo, iATTRFieldNo, iINASFieldNo, iPointRecNo, iMultiPointRecNo: Integer;
  iCoordFieldNo, iCurveRecNo, iSegmentNo, iCompositeCurveRecNo, iCUCOFieldNo: Integer;
  iSurfaceRecNo, iRIASFieldNo, iFeatureRecNo, iSPASFieldNo, iFASCFieldNo: Integer;
  iTHASFieldNo, iMASKFieldNo: Integer;
//  s101IniFile: TS101IniFile;
  progress: TProgress;
  formatSettings: TFormatSettings;
begin
  try
    Result := False;
    if logName <> '' then begin
      AssignFile(tfLog, logName);
      if FileExists(logName) then
        Append(tfLog)
      else
        Rewrite(tfLog);
    end;
    fH := FileOpen(fileName, fmOpenRead);
    if fH = -1 then begin
      sError := 'Не удалось открыть файл "' + fileName + '"';
      if calculationThread <> nil then
        calculationThread.m_nTermStatus := TERM_STATUS_ERROR;
      Exit;
    end;
    nFileLength := FileSeek(fH, 0, 2);
    FileSeek(fH, 0, 0);

    if logName <> '' then begin
      WriteLn(tfLog, '');
      WriteLn(tfLog, '************************************************************');
      DateTimeToString(s, 'yyyy-mm-dd hh:mm:ss', Date + Time);
      WriteLn(tfLog, s);
      WriteLn(tfLog, 'Чтение набора данных S101 из файла ' + fileName);
    end;

    curPos := 0;
    recNo := 0;
    iSegmentNo := -1;
    bEOF := False;
//  s101IniFile := TS101IniFile.Create(ExtractFilePath(Application.ExeName) +
//      'S101Settings.ini');
    repeat
      suspendEvent.WaitFor($FFFFFFFF);
      if breakEvent.WaitFor(0) = wrSignaled then begin
        if calculationThread <> nil then
          calculationThread.m_nTermStatus := TERM_STATUS_USERSTOP;
        Exit;
      end
      else begin
        progress := TProgress(threadList.LockList[0]);
        progress.m_max := nFileLength;
        progress.m_pos := curPos;
        progress.m_Message := 'Анализ файла ' + fileName;
        threadList.UnlockList;
      end;
      // Читаем и разбираем лидер очередной записи
      nBytesRead := FileRead(fH, lrLeader, sizeof(lrLeader));
      if nBytesRead = sizeof(lrLeader) then begin
        if not CheckLeader(lrLeader, curPos = 0) then begin
          sError := 'Неизвестный формат файла "' + fileName + '"';
          if calculationThread <> nil then
            calculationThread.m_nTermStatus := TERM_STATUS_ERROR;
          Exit;
        end;
        // Определяем длину записи
        Val(lrLeader.recordLength, lrRecLen, code);
        if logName <> '' then
          WriteLn(tfLog, Format('recNo=%d, lrRecLen=%d', [recNo, lrRecLen]));
        // Определяем базовый адрес области полей
        Val(lrLeader.baseAddressOfFieldArea, addrFieldArea, code);
        // Определяем длину директории записи и размещаем массив для ее хранения
        lrDirLen := addrFieldArea - sizeof(lrLeader);
        SetLength(lrDirectoryRec, lrDirLen);
        // Определяем длины частей, составляющих директорный вход, и суммарную
        // длину директорного входа
        fieldLengthSize := Ord(lrLeader.entryMap[0]) - Ord('0');
        fieldPositionSize := Ord(lrLeader.entryMap[1]) - Ord('0');
        fieldTagSize := Ord(lrLeader.entryMap[3]) - Ord('0');
        fieldEntrySize := fieldLengthSize + fieldPositionSize + fieldTagSize;
        // Если запись описывает типы полей, размещаем память под описания полей
        if lrLeader.leaderIdentifier = 'L' then begin
          SetLength(lrFieldsDescriptions, lrDirLen div fieldEntrySize);
//        s101IniFile.WriteLRLeader(lrLeader);
        end;
        // Читаем директорию записи
        nBytesRead := FileRead(fH, Pointer(lrDirectoryRec)^, lrDirLen);
        if nBytesRead = lrDirLen then begin
          // Разбираем по частям каждый вход в директорию записи
          for i := 0 to lrDirLen div fieldEntrySize - 1 do begin
            // Выделяем тег поля
            Move(lrDirectoryRec[i * fieldEntrySize], lrFieldEntryBuffer, fieldTagSize);
            lrFieldEntryBuffer[fieldTagSize] := #0;
            fieldTag := lrFieldEntryBuffer;
            // Выделяем длину поля
            Move(lrDirectoryRec[i * fieldEntrySize + fieldTagSize], lrFieldEntryBuffer,
                fieldLengthSize);
            lrFieldEntryBuffer[fieldLengthSize] := #0;
            Val(lrFieldEntryBuffer, fieldLength, code);
            // Выделяем относительный адрес начала поля
            Move(lrDirectoryRec[i * fieldEntrySize + fieldTagSize + fieldLengthSize],
                lrFieldEntryBuffer, fieldPositionSize);
            lrFieldEntryBuffer[fieldPositionSize] := #0;
            Val(lrFieldEntryBuffer, fieldPosition, code);
            // Выделяем память под содержимое поля
            SetLength(lrFieldValue, fieldLength);
            // Читаем содержимое поля
            nBytesRead := FileRead(fH, Pointer(lrFieldValue)^, fieldLength);
            if nBytesRead <> fieldLength then begin
              sError := 'Ошибка чтения файла "' + fileName + '": неожиданный конец файла';
              if calculationThread <> nil then
                calculationThread.m_nTermStatus := TERM_STATUS_ERROR;
              Exit;
            end;
            // Если запись описывает типы полей, формируем описание очередного поля
            if lrLeader.leaderIdentifier = 'L' then begin
              lrFieldsDescriptions[i].fieldTag := fieldTag;
              SetLength(buffer, fieldLength + 1);
              Move(lrFieldValue[0], buffer[0], fieldLength);
              buffer[fieldLength] := #0;
              lrFieldsDescriptions[i].fieldDescription := PChar(buffer);
              SetLength(buffer, 0);
              Val(fieldTag, iTag, code);
              if (code = 0) and (iTag = 0) then begin
                // Если тег поля числовой, содержимое поля - это массив пар тегов
                // (parent, offspring). Формируем этот массив пар.
                MakeFieldTagPairs(fieldTagSize, lrFieldValue, fieldTagPairs);
//              s101IniFile.WriteFieldTagPairs(fieldTagPairs);
              end
              else begin
                // В противном случае содержимое поля - описание поля. Формируем
                // описание поля в виде набора подполей соответствующего типа и
                // множественности.
                MakeSubfieldsDescriptions(lrFieldsDescriptions[i]);
              end;
            end;
            if logName <> '' then begin
              WriteLn(tfLog, Format(#9'fieldNo=%d, fieldTag=%s, fieldLength=%d, fieldPosition=%d',
                  [i, fieldTag, fieldLength, fieldPosition]));
              Flush(tfLog);
              if lrLeader.leaderIdentifier = 'L' then begin
                if i = 0 then begin
                  for iFieldTagPair := 0 to Length(fieldTagPairs) - 1 do begin
                    WriteLn(tfLog, Format(#9#9'(%s,%s)',
                        [fieldTagPairs[iFieldTagPair].parentFieldTag,
                        fieldTagPairs[iFieldTagPair].offspringFieldTag]));
                    Flush(tfLog);
                  end;
                end
                else
                  for iSubField := 0 to Length(lrFieldsDescriptions[i].subfieldsDescriptions) - 1 do begin
                    WriteLn(tfLog, Format(#9#9'(%s, %s, %d)',
                        [lrFieldsDescriptions[i].subfieldsDescriptions[iSubField].sfTag,
                        lrFieldsDescriptions[i].subfieldsDescriptions[iSubField].sfType,
                        Integer(lrFieldsDescriptions[i].subfieldsDescriptions[iSubField].sfMulti)]));
                    Flush(tfLog);
                  end;
              end;
            end;
            if lrLeader.leaderIdentifier <> 'L' then begin
              // Если это запись с данными, разбираем поля согласно их описаниям
              subFields := nil;
              for j := 0 to Length(lrFieldsDescriptions) - 1 do
                // Находим описание поля по его тегу
                if lrFieldsDescriptions[j].fieldTag = fieldTag then begin
                  // Разбираем поле на значения подполей
                  ParseFieldValue(lrFieldsDescriptions[j], lrFieldValue, subFields);
                  if logName <> '' then
                    for iSubField := 0 to Length(subFields) - 1 do begin
                      with lrFieldsDescriptions[j].subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
                        if sfType[1] = 'A' then
                          sfValue := subFields[iSubField].sValue
                        else if (sfType = 'b48') or (sfType[1] = 'R') then begin
                          GetLocaleFormatSettings(LOCALE_USER_DEFAULT, formatSettings);
                          formatSettings.DecimalSeparator := '.';
                          sfValue := Format('%g', [subFields[iSubField].dValue], formatSettings);
                        end
                        else
                          Str(subFields[iSubField].iValue, sfValue);
                        WriteLn(tfLog, Format(#9#9'%s=%s', [sfTag, UTF8Decode(sfValue)]));
                      end;
                    end;
                  // Разбор полей по тегам
                  if fieldTag = 'DSID' then begin
//                  s101IniFile.WriteFieldDescriptions(lrFieldsDescriptions);
                    if bS57 then
                      GetS57DSIDField(lrFieldsDescriptions[j], subFields, dsGeneralInfo.fS57DSID)
                    else
                      GetDSIDField(lrFieldsDescriptions[j], subFields, dsGeneralInfo.fDSID);
                    if bDSIDOnly then begin
                      Result := True;
                      Exit;
                    end;
//                  s101IniFile.WriteDSIDField(dsGeneralInfo.fDSID, s101Catalogue.topicCategories);
                    sOwnerFieldTag := fieldTag;
                  end
                  else if fieldTag = 'DSSI' then begin
                    if bS57 then begin
                      GetS57DSSIField(lrFieldsDescriptions[j], subFields, dsGeneralInfo.fS57DSSI);
                    end
                    else begin
                      GetDSSIField(lrFieldsDescriptions[j], subFields, dsGeneralInfo.fDSSI);
                      SetLength(infoTypeRecords, dsGeneralInfo.fDSSI.NOIR);
                      iInfoTypeRecNo := -1;
                      SetLength(pointRecords, dsGeneralInfo.fDSSI.NOPN);
                      iPointRecNo := -1;
                      SetLength(multiPointRecords, dsGeneralInfo.fDSSI.NOMN);
                      iMultiPointRecNo := -1;
                      SetLength(curveRecords, dsGeneralInfo.fDSSI.NOCN);
                      iCurveRecNo := -1;
                      SetLength(compositeCurveRecords, dsGeneralInfo.fDSSI.NOXN);
                      iCompositeCurveRecNo := -1;
                      SetLength(surfaceRecords, dsGeneralInfo.fDSSI.NOSN);
                      iSurfaceRecNo := -1;
                      SetLength(featureRecords, dsGeneralInfo.fDSSI.NOFR);
                      iFeatureRecNo := -1;
                    end
                  end
                  else if fieldTag = 'ATCS' then begin
                    GetCodesField(lrFieldsDescriptions[j], subFields, dsGeneralInfo.fATCS);
//                  s101IniFile.WriteCodeTable(fieldTag, dsGeneralInfo.fATCS);
                  end
                  else if fieldTag = 'ITCS' then begin
                    GetCodesField(lrFieldsDescriptions[j], subFields, dsGeneralInfo.fITCS);
//                  s101IniFile.WriteCodeTable(fieldTag, dsGeneralInfo.fITCS);
                  end
                  else if fieldTag = 'FTCS' then begin
                    GetCodesField(lrFieldsDescriptions[j], subFields, dsGeneralInfo.fFTCS);
//                  s101IniFile.WriteCodeTable(fieldTag, dsGeneralInfo.fFTCS);
                  end
                  else if fieldTag = 'IACS' then begin
                    GetCodesField(lrFieldsDescriptions[j], subFields, dsGeneralInfo.fIACS);
//                  s101IniFile.WriteCodeTable(fieldTag, dsGeneralInfo.fIACS);
                  end
                  else if fieldTag = 'FACS' then begin
                    GetCodesField(lrFieldsDescriptions[j], subFields, dsGeneralInfo.fFACS);
//                  s101IniFile.WriteCodeTable(fieldTag, dsGeneralInfo.fFACS);
                  end
                  else if fieldTag = 'ARCS' then begin
                    GetCodesField(lrFieldsDescriptions[j], subFields, dsGeneralInfo.fARCS);
//                  s101IniFile.WriteCodeTable(fieldTag, dsGeneralInfo.fARCS);
                  end
                  else if fieldTag = 'CSID' then begin
                    GetCSIDField(lrFieldsDescriptions[j], subFields, fieldCSID);
//                  s101IniFile.WriteCSIDField(fieldCSID);
                    SetLength(crsArray, fieldCSID.NCRC);
                    iCRS := -1;
                  end
                  else if fieldTag = 'CRSH' then begin
                    if iCRS = Length(crsArray) - 1 then begin
                      sError := Format('Ошибка чтения файла "%s": число систем координат превысило CSID.NCRC=%d',
                          [fileName, Length(crsArray)]);
                      if calculationThread <> nil then
                        calculationThread.m_nTermStatus := TERM_STATUS_ERROR;
                      Exit;
                    end;
                    iCRS := iCRS + 1;
                    GetCRSHField(lrFieldsDescriptions[j], subFields, crsArray[iCRS].fCRSH);
//                  s101IniFile.WriteCRSHField(crsArray[iCRS].fCRSH, iCRS);
                  end
                  else if fieldTag = 'CSAX' then begin
                    GetCSAXField(lrFieldsDescriptions[j], subFields, crsArray[iCRS].fCSAX);
//                  s101IniFile.WriteCSAXField(crsArray[iCRS].fCSAX, iCRS);
                  end
                  else if fieldTag = 'PROJ' then begin
                    if crsArray[iCRS].pfPROJ = nil then
                      New(crsArray[iCRS].pfPROJ);
                    GetPROJField(lrFieldsDescriptions[j], subFields, crsArray[iCRS].pfPROJ^);
//                  s101IniFile.WritePROJField(crsArray[iCRS].pfPROJ^, iCRS);
                  end
                  else if fieldTag = 'GDAT' then begin
                    if crsArray[iCRS].pfGDAT = nil then
                      New(crsArray[iCRS].pfGDAT);
                    GetGDATField(lrFieldsDescriptions[j], subFields, crsArray[iCRS].pfGDAT^);
//                  s101IniFile.WriteGDATField(crsArray[iCRS].pfGDAT^, iCRS);
                  end
                  else if fieldTag = 'VDAT' then begin
                    if crsArray[iCRS].pfVDAT = nil then
                      New(crsArray[iCRS].pfVDAT);
                    GetVDATField(lrFieldsDescriptions[j], subFields, crsArray[iCRS].pfVDAT^);
//                  s101IniFile.WriteVDATField(crsArray[iCRS].pfVDAT^, iCRS);
                  end
                  else if fieldTag = 'IRID' then begin
                    iInfoTypeRecNo := iInfoTypeRecNo + 1;
                    GetIRIDField(lrFieldsDescriptions[j], subFields, infoTypeRecords[iInfoTypeRecNo].fIRID);
                    sOwnerFieldTag := fieldTag;
                  end
                  // У поля ATTR могут быть различные родительские поля. Разбор
                  // выполняем в зависимости от типа родительского поля.
                  // (см. описание стандарта S-100)
                  else if fieldTag = 'ATTR' then
                    if sOwnerFieldTag = 'IRID' then begin
                      iATTRFieldNo := Length(infoTypeRecords[iInfoTypeRecNo].fATTRArray);
                      SetLength(infoTypeRecords[iInfoTypeRecNo].fATTRArray, iATTRFieldNo + 1);
                      GetATTRField(lrFieldsDescriptions[j], subFields,
                          infoTypeRecords[iInfoTypeRecNo].fATTRArray[iATTRFieldNo]);
                    end
                    else if sOwnerFieldTag = 'DSID' then begin
                      iATTRFieldNo := Length(dsGeneralInfo.fATTRArray);
                      SetLength(dsGeneralInfo.fATTRArray, iATTRFieldNo + 1);
                      GetATTRField(lrFieldsDescriptions[j], subFields,
                          dsGeneralInfo.fATTRArray[iATTRFieldNo]);
                    end
                    else if sOwnerFieldTag = 'FRID' then begin
                      iATTRFieldNo := Length(featureRecords[iFeatureRecNo].fATTRArray);
                      SetLength(featureRecords[iFeatureRecNo].fATTRArray, iATTRFieldNo + 1);
                      GetATTRField(lrFieldsDescriptions[j], subFields,
                          featureRecords[iFeatureRecNo].fATTRArray[iATTRFieldNo]);
                    end
                    else begin
                      sError := Format('Ошибка чтения файла "%s": ATTR имеет недопустимое родительское поле %s',
                          [fileName, sOwnerFieldTag]);
                      if calculationThread <> nil then
                        calculationThread.m_nTermStatus := TERM_STATUS_ERROR;
                      Exit;
                    end
                  // У поля INAS могут быть различные родительские поля. Разбор
                  // выполняем в зависимости от типа родительского поля.
                  // (см. описание стандарта S-100)
                  else if fieldTag = 'INAS' then
                    if sOwnerFieldTag = 'IRID' then begin
                      iINASFieldNo := Length(infoTypeRecords[iInfoTypeRecNo].fINASArray);
                      SetLength(infoTypeRecords[iInfoTypeRecNo].fINASArray, iINASFieldNo + 1);
                      GetINASField(lrFieldsDescriptions[j], subFields,
                          infoTypeRecords[iInfoTypeRecNo].fINASArray[iINASFieldNo]);
                    end
                    else if sOwnerFieldTag = 'PRID' then begin
                      iINASFieldNo := Length(pointRecords[iPointRecNo].fINASArray);
                      SetLength(pointRecords[iPointRecNo].fINASArray, iINASFieldNo + 1);
                      GetINASField(lrFieldsDescriptions[j], subFields,
                          pointRecords[iPointRecNo].fINASArray[iINASFieldNo]);
                    end
                    else if sOwnerFieldTag = 'MRID' then begin
                      iINASFieldNo := Length(multiPointRecords[iMultiPointRecNo].fINASArray);
                      SetLength(multiPointRecords[iMultiPointRecNo].fINASArray, iINASFieldNo + 1);
                      GetINASField(lrFieldsDescriptions[j], subFields,
                          multiPointRecords[iMultiPointRecNo].fINASArray[iINASFieldNo]);
                    end
                    else if sOwnerFieldTag = 'CRID' then begin
                      iINASFieldNo := Length(curveRecords[iCurveRecNo].fINASArray);
                      SetLength(curveRecords[iCurveRecNo].fINASArray, iINASFieldNo + 1);
                      GetINASField(lrFieldsDescriptions[j], subFields,
                          curveRecords[iCurveRecNo].fINASArray[iINASFieldNo]);
                    end
                    else if sOwnerFieldTag = 'CCID' then begin
                      iINASFieldNo := Length(compositeCurveRecords[iCompositeCurveRecNo].fINASArray);
                      SetLength(compositeCurveRecords[iCompositeCurveRecNo].fINASArray, iINASFieldNo + 1);
                      GetINASField(lrFieldsDescriptions[j], subFields,
                          compositeCurveRecords[iCompositeCurveRecNo].fINASArray[iINASFieldNo]);
                    end
                    else if sOwnerFieldTag = 'SRID' then begin
                      iINASFieldNo := Length(surfaceRecords[iSurfaceRecNo].fINASArray);
                      SetLength(surfaceRecords[iSurfaceRecNo].fINASArray, iINASFieldNo + 1);
                      GetINASField(lrFieldsDescriptions[j], subFields,
                          surfaceRecords[iSurfaceRecNo].fINASArray[iINASFieldNo]);
                    end
                    else if sOwnerFieldTag = 'FRID' then begin
                      iINASFieldNo := Length(featureRecords[iFeatureRecNo].fINASArray);
                      SetLength(featureRecords[iFeatureRecNo].fINASArray, iINASFieldNo + 1);
                      GetINASField(lrFieldsDescriptions[j], subFields,
                          featureRecords[iFeatureRecNo].fINASArray[iINASFieldNo]);
                    end
                    else begin
                      sError := Format('Ошибка чтения файла "%s": INAS имеет недопустимое родительское поле %s',
                          [fileName, sOwnerFieldTag]);
                      if calculationThread <> nil then
                        calculationThread.m_nTermStatus := TERM_STATUS_ERROR;
                      Exit;
                    end
                  else if fieldTag = 'PRID' then begin
                    iPointRecNo := iPointRecNo + 1;
                    GetPRIDField(lrFieldsDescriptions[j], subFields,
                        pointRecords[iPointRecNo].fPRID);
                    sOwnerFieldTag := fieldTag;
                  end
                  else if fieldTag = 'MRID' then begin
                    iMultiPointRecNo := iMultiPointRecNo + 1;
                    GetMRIDField(lrFieldsDescriptions[j], subFields,
                        multiPointRecords[iMultiPointRecNo].fMRID);
                    sOwnerFieldTag := fieldTag;
                  end
                  else if fieldTag = 'CRID' then begin
                    iCurveRecNo := iCurveRecNo + 1;
                    GetCRIDField(lrFieldsDescriptions[j], subFields,
                        curveRecords[iCurveRecNo].fCRID);
                    sOwnerFieldTag := fieldTag;
                  end
                  else if fieldTag = 'CCID' then begin
                    iCompositeCurveRecNo := iCompositeCurveRecNo + 1;
                    GetCCIDField(lrFieldsDescriptions[j], subFields,
                        compositeCurveRecords[iCompositeCurveRecNo].fCCID);
                    sOwnerFieldTag := fieldTag;
                  end
                  else if fieldTag = 'CCOC' then begin
                    if compositeCurveRecords[iCompositeCurveRecNo].pfCCOC = nil then
                      New(compositeCurveRecords[iCompositeCurveRecNo].pfCCOC);
                    GetCCOCField(lrFieldsDescriptions[j], subFields,
                        compositeCurveRecords[iCompositeCurveRecNo].pfCCOC^);
                  end
                  else if fieldTag = 'CUCO' then begin
                    iCUCOFieldNo := Length(compositeCurveRecords[iCompositeCurveRecNo].fCUCOArray);
                    SetLength(compositeCurveRecords[iCompositeCurveRecNo].fCUCOArray, iCUCOFieldNo + 1);
                    GetCUCOField(lrFieldsDescriptions[j], subFields,
                        compositeCurveRecords[iCompositeCurveRecNo].fCUCOArray[iCUCOFieldNo]);
                  end
                  else if fieldTag = 'PTAS' then begin
                    GetPTASField(lrFieldsDescriptions[j], subFields,
                        curveRecords[iCurveRecNo].fPTAS);
                  end
                  else if fieldTag = 'SECC' then begin
                    if curveRecords[iCurveRecNo].pfSECC = nil then
                      New(curveRecords[iCurveRecNo].pfSECC);
                    GetSECCField(lrFieldsDescriptions[j], subFields,
                        curveRecords[iCurveRecNo].pfSECC^);
                  end
                  else if fieldTag = 'SEGH' then begin
                    iSegmentNo := Length(curveRecords[iCurveRecNo].fSegmentArray);
                    SetLength(curveRecords[iCurveRecNo].fSegmentArray, iSegmentNo + 1);
                    GetSEGHField(lrFieldsDescriptions[j], subFields,
                        curveRecords[iCurveRecNo].fSegmentArray[iSegmentNo].fSEGH);
                    sOwnerFieldTag := fieldTag;
                  end
                  else if fieldTag = 'COCC' then begin
                    if sOwnerFieldTag = 'SEGH' then begin
                      if curveRecords[iCurveRecNo].fSegmentArray[iSegmentNo].pfCOCC = nil then
                        New(curveRecords[iCurveRecNo].fSegmentArray[iSegmentNo].pfCOCC);
                      GetCOCCField(lrFieldsDescriptions[j], subFields,
                          curveRecords[iCurveRecNo].fSegmentArray[iSegmentNo].pfCOCC^);
                    end
                    else if sOwnerFieldTag = 'MRID' then begin
                      if multiPointRecords[iMultiPointRecNo].pfCOCC = nil then
                        New(multiPointRecords[iMultiPointRecNo].pfCOCC);
                      GetCOCCField(lrFieldsDescriptions[j], subFields,
                          multiPointRecords[iMultiPointRecNo].pfCOCC^);
                    end
                  end
                  else if fieldTag = 'C2IT' then begin
                    pointRecords[iPointRecNo].ct := ct2I;
                    GetC2ITField(lrFieldsDescriptions[j], subFields,
                        pointRecords[iPointRecNo].fC2IT);
                  end
                  else if fieldTag = 'C3IT' then begin
                    pointRecords[iPointRecNo].ct := ct3I;
                    GetC3ITField(lrFieldsDescriptions[j], subFields,
                        pointRecords[iPointRecNo].fC3IT);
                  end
                  else if fieldTag = 'C2FT' then begin
                    pointRecords[iPointRecNo].ct := ct2F;
                    GetC2FTField(lrFieldsDescriptions[j], subFields,
                        pointRecords[iPointRecNo].fC2FT);
                  end
                  else if fieldTag = 'C3FT' then begin
                    pointRecords[iPointRecNo].ct := ct3F;
                    GetC3FTField(lrFieldsDescriptions[j], subFields,
                        pointRecords[iPointRecNo].fC3FT);
                  end
                  // У поля C2IL могут быть различные родительские поля. Разбор
                  // выполняем в зависимости от типа родительского поля.
                  // (см. описание стандарта S-100)
                  else if fieldTag = 'C2IL' then begin
                    if sOwnerFieldTag = 'MRID' then begin
                      multiPointRecords[iMultiPointRecNo].ct := ct2I;
                      iCoordFieldNo := Length(multiPointRecords[iMultiPointRecNo].fC2ILArray);
                      SetLength(multiPointRecords[iMultiPointRecNo].fC2ILArray, iCoordFieldNo + 1);
                      GetC2ILField(lrFieldsDescriptions[j], subFields,
                          multiPointRecords[iMultiPointRecNo].fC2ILArray[iCoordFieldNo]);
                    end
                    else if sOwnerFieldTag = 'SEGH' then begin
                      curveRecords[iCurveRecNo].ct := ct2I;
                      iCoordFieldNo := Length(curveRecords[iCurveRecNo].fSegmentArray[iSegmentNo].fC2ILArray);
                      SetLength(curveRecords[iCurveRecNo].fSegmentArray[iSegmentNo].fC2ILArray, iCoordFieldNo + 1);
                      GetC2ILField(lrFieldsDescriptions[j], subFields,
                          curveRecords[iCurveRecNo].fSegmentArray[iSegmentNo].fC2ILArray[iCoordFieldNo]);
                    end;
                  end
                  // У поля C3IL могут быть различные родительские поля. Разбор
                  // выполняем в зависимости от типа родительского поля.
                  // (см. описание стандарта S-100)
                  else if fieldTag = 'C3IL' then begin
                    if sOwnerFieldTag = 'MRID' then begin
                      multiPointRecords[iMultiPointRecNo].ct := ct3I;
                      iCoordFieldNo := Length(multiPointRecords[iMultiPointRecNo].fC3ILArray);
                      SetLength(multiPointRecords[iMultiPointRecNo].fC3ILArray, iCoordFieldNo + 1);
                      GetC3ILField(lrFieldsDescriptions[j], subFields,
                          multiPointRecords[iMultiPointRecNo].fC3ILArray[iCoordFieldNo]);
                    end
                    else if sOwnerFieldTag = 'SEGH' then begin
                      curveRecords[iCurveRecNo].ct := ct3I;
                      iCoordFieldNo := Length(curveRecords[iCurveRecNo].fSegmentArray[iSegmentNo].fC3ILArray);
                      SetLength(curveRecords[iCurveRecNo].fSegmentArray[iSegmentNo].fC3ILArray, iCoordFieldNo + 1);
                      GetC3ILField(lrFieldsDescriptions[j], subFields,
                          curveRecords[iCurveRecNo].fSegmentArray[iSegmentNo].fC3ILArray[iCoordFieldNo]);
                    end;
                  end
                  // У поля C2FL могут быть различные родительские поля. Разбор
                  // выполняем в зависимости от типа родительского поля.
                  // (см. описание стандарта S-100)
                  else if fieldTag = 'C2FL' then begin
                    if sOwnerFieldTag = 'MRID' then begin
                      multiPointRecords[iMultiPointRecNo].ct := ct2F;
                      iCoordFieldNo := Length(multiPointRecords[iMultiPointRecNo].fC2FLArray);
                      SetLength(multiPointRecords[iMultiPointRecNo].fC2FLArray, iCoordFieldNo + 1);
                      GetC2FLField(lrFieldsDescriptions[j], subFields,
                          multiPointRecords[iMultiPointRecNo].fC2FLArray[iCoordFieldNo]);
                    end
                    else if sOwnerFieldTag = 'SEGH' then begin
                      curveRecords[iCurveRecNo].ct := ct2F;
                      iCoordFieldNo := Length(curveRecords[iCurveRecNo].fSegmentArray[iSegmentNo].fC2FLArray);
                      SetLength(curveRecords[iCurveRecNo].fSegmentArray[iSegmentNo].fC2FLArray, iCoordFieldNo + 1);
                      GetC2FLField(lrFieldsDescriptions[j], subFields,
                          curveRecords[iCurveRecNo].fSegmentArray[iSegmentNo].fC2FLArray[iCoordFieldNo]);
                    end;
                  end
                  // У поля C3FL могут быть различные родительские поля. Разбор
                  // выполняем в зависимости от типа родительского поля.
                  // (см. описание стандарта S-100)
                  else if fieldTag = 'C3FL' then begin
                    if sOwnerFieldTag = 'MRID' then begin
                      multiPointRecords[iMultiPointRecNo].ct := ct3F;
                      iCoordFieldNo := Length(multiPointRecords[iMultiPointRecNo].fC3FLArray);
                      SetLength(multiPointRecords[iMultiPointRecNo].fC3FLArray, iCoordFieldNo + 1);
                      GetC3FLField(lrFieldsDescriptions[j], subFields,
                          multiPointRecords[iMultiPointRecNo].fC3FLArray[iCoordFieldNo]);
                    end
                    else if sOwnerFieldTag = 'SEGH' then begin
                      curveRecords[iCurveRecNo].ct := ct3F;
                      iCoordFieldNo := Length(curveRecords[iCurveRecNo].fSegmentArray[iSegmentNo].fC3FLArray);
                      SetLength(curveRecords[iCurveRecNo].fSegmentArray[iSegmentNo].fC3FLArray, iCoordFieldNo + 1);
                      GetC3FLField(lrFieldsDescriptions[j], subFields,
                          curveRecords[iCurveRecNo].fSegmentArray[iSegmentNo].fC3FLArray[iCoordFieldNo]);
                    end;
                  end
                  else if fieldTag = 'SRID' then begin
                    iSurfaceRecNo := iSurfaceRecNo + 1;
                    GetSRIDField(lrFieldsDescriptions[j], subFields,
                        surfaceRecords[iSurfaceRecNo].fSRID);
                    sOwnerFieldTag := fieldTag;
                  end
                  else if fieldTag = 'RIAS' then begin
                    iRIASFieldNo := Length(surfaceRecords[iSurfaceRecNo].fRIASArray);
                    SetLength(surfaceRecords[iSurfaceRecNo].fRIASArray, iRIASFieldNo + 1);
                    GetRIASField(lrFieldsDescriptions[j], subFields,
                        surfaceRecords[iSurfaceRecNo].fRIASArray[iRIASFieldNo]);
                  end
                  else if (fieldTag = 'FRID') then begin
                    iFeatureRecNo := iFeatureRecNo + 1;
                    //////////////////////////////////////////////////////////////
                    // Костыль
                    if Length(featureRecords) < iFeatureRecNo + 1 then
                      SetLength(featureRecords, iFeatureRecNo + 1);
                    //////////////////////////////////////////////////////////////
                    GetFRIDField(lrFieldsDescriptions[j], subFields,
                        featureRecords[iFeatureRecNo].fFRID);
                    sOwnerFieldTag := fieldTag;
                  end
                  else if (fieldTag = 'FOID') then begin
                    if featureRecords[iFeatureRecNo].pfFOID = nil then
                      New(featureRecords[iFeatureRecNo].pfFOID);
                    GetFOIDField(lrFieldsDescriptions[j], subFields,
                        featureRecords[iFeatureRecNo].pfFOID^);
                  end
                  else if (fieldTag = 'SPAS') then begin
                    iSPASFieldNo := Length(featureRecords[iFeatureRecNo].fSPASArray);
                    SetLength(featureRecords[iFeatureRecNo].fSPASArray, iSPASFieldNo + 1);
                    GetSPASField(lrFieldsDescriptions[j], subFields,
                        featureRecords[iFeatureRecNo].fSPASArray[iSPASFieldNo]);
                  end
                  else if (fieldTag = 'FASC') then begin
                    iFASCFieldNo := Length(featureRecords[iFeatureRecNo].fFASCArray);
                    SetLength(featureRecords[iFeatureRecNo].fFASCArray, iFASCFieldNo + 1);
                    GetFASCField(lrFieldsDescriptions[j], subFields,
                        featureRecords[iFeatureRecNo].fFASCArray[iFASCFieldNo]);
                  end
                  else if (fieldTag = 'THAS') then begin
                    iTHASFieldNo := Length(featureRecords[iFeatureRecNo].fTHASArray);
                    SetLength(featureRecords[iFeatureRecNo].fTHASArray, iTHASFieldNo + 1);
                    GetTHASField(lrFieldsDescriptions[j], subFields,
                        featureRecords[iFeatureRecNo].fTHASArray[iTHASFieldNo]);
                  end
                  else if (fieldTag = 'MASK') then begin
                    iMASKFieldNo := Length(featureRecords[iFeatureRecNo].fMASKArray);
                    SetLength(featureRecords[iFeatureRecNo].fMASKArray, iMASKFieldNo + 1);
                    GetMASKField(lrFieldsDescriptions[j], subFields,
                        featureRecords[iFeatureRecNo].fMASKArray[iMASKFieldNo]);
                  end;
                  Break;
                end;
            end;
          end;
        end;
        if not CheckFieldsDescriptions(lrFieldsDescriptions, bS57) then begin
          if bS57 then
            sError := Format('Ошибка чтения файла "%s": описания полей не соответствуют стандарту S-57',
                [fileName])
          else
            sError := Format('Ошибка чтения файла "%s": описания полей не соответствуют стандарту S-101',
                [fileName]);
          if calculationThread <> nil then
            calculationThread.m_nTermStatus := TERM_STATUS_ERROR;
          Exit;
        end;
        recNo := recNo + 1;
        curPos := curPos + lrRecLen;
        FileSeek(fH, curPos, 0);
      end
      else
        bEOF := True;
    until bEOF;
    Result := True;
  finally
//    s101IniFile.Free;
    FileClose(fH);
    if logName <> '' then 
      CloseFile(tfLog);
  end;
end;

function TS101DataSet.ExportToBinary(fileName, logName: string; var sError: string): Boolean;
var
  s101IniFile: TS101IniFile;
  fs: TFileStream;
  ms: TMemoryStream;
  lrLeader: TLRLeader;
  fieldTagPairs: TLRFieldTagPairArray;
  i, j, iPair, iCurField, iCRS, iRecord, nAllFields: Integer;
  sFieldValues: string;
  lrDir, rawFieldValue: TArrayOfChar;
  fieldSizeArray: TArrayOfFieldSize;
  progress: TProgress;
  s: string;
  N: Integer;
begin
  Result := False;
  if fileName = '' then begin
    sError := 'Экспорт в S101-binary: не задан путь к выходному файлу';
    if calculationThread <> nil then
      calculationThread.m_nTermStatus := TERM_STATUS_ERROR;
    Exit;
  end;
  if logName = '' then begin
    sError := 'Не задан путь к Log-файлу';
    if calculationThread <> nil then
      calculationThread.m_nTermStatus := TERM_STATUS_ERROR;
    Exit;
  end;
  try
    AssignFile(tfLog, logName);
    if FileExists(logName) then
      Append(tfLog)
    else
      Rewrite(tfLog);
    WriteLn(tfLog, '');
    WriteLn(tfLog, '************************************************************');
    DateTimeToString(s, 'yyyy-mm-dd hh:mm:ss', Date + Time);
    WriteLn(tfLog, s);
    WriteLn(tfLog, 'Запись набора данных S101 в файл ' + fileName);
    /////////////////////////////////////////////////////////
    progress := TProgress(threadList.LockList[0]);
    progress.m_max := 0;
    progress.m_pos := 0;
    progress.m_Message := 'Экспорт в S101-binary';
    threadList.UnlockList;
    /////////////////////////////////////////////////////////
    fs := TFileStream.Create(fileName, fmCreate);
    ms := TMemoryStream.Create;

    s101IniFile := TS101IniFile.Create(ExtractFilePath(Application.ExeName) +
        'S101Settings.ini');
    s101IniFile.ReadLRLeader(lrLeader);
    s101IniFile.ReadFieldTagPairs(fieldTagPairs);
    s101IniFile.ReadFieldDescriptions(lrFieldsDescriptions);

    // Заполняем запись с описаниями полей
    SetLength(fieldSizeArray, Length(lrFieldsDescriptions) + 1);

    sFieldValues := '0000;&   '#$1F;
    for iPair := 0 to Length(fieldTagPairs) - 1 do
      sFieldValues := sFieldValues + fieldTagPairs[iPair].parentFieldTag +
          fieldTagPairs[iPair].offspringFieldTag;
    sFieldValues := sFieldValues + #$1E;
    ms.Write(sFieldValues[1], Length(sFieldValues));
    fieldSizeArray[0].m_sTag := '0000';
    fieldSizeArray[0].m_nSize := Length(sFieldValues);

    sFieldValues := '';
    for i := 0 to Length(lrFieldsDescriptions) - 1 do begin
      sFieldValues := sFieldValues + lrFieldsDescriptions[i].fieldDescription;
      fieldSizeArray[i + 1].m_sTag := lrFieldsDescriptions[i].fieldTag;
      fieldSizeArray[i + 1].m_nSize := Length(lrFieldsDescriptions[i].fieldDescription);
      MakeSubfieldsDescriptions(lrFieldsDescriptions[i]);
    end;
    ms.Write(sFieldValues[1], Length(sFieldValues));

    FillLeaderAndDir(fieldSizeArray, lrLeader, lrDir);
    fs.Write(lrLeader, SizeOf(lrLeader));
    fs.Write(lrDir[0], Length(lrDir));
    ms.SaveToStream(fs);

    // Заполняем запись с полями DSID, DSSI, ATCS, ITCS, FTCS, IACS, FACS, ARCS
    ms.Clear;
    Move(StringOfChar(' ', SizeOf(lrLeader))[1], lrLeader, SizeOf(lrLeader));
    lrLeader.leaderIdentifier := 'D';

    SetLength(fieldSizeArray, 8);

    s101IniFile.ReadDSIDField(dsGeneralInfo.fDSID, s101Catalogue.topicCategories);
    with dsGeneralInfo.fDSID do begin
      DSNM := ExtractFileName(fileName);
      DSTL := 'Converted from JSON';
      DateTimeToString(DSRD, 'yyyymmdd', Date);
      DSED := '1';
    end;

    FillRawFieldValue(@dsGeneralInfo.fDSID, 'DSID', Length(dsGeneralInfo.fDSID.DSTC), rawFieldValue);
    ms.Write(rawFieldValue[0], Length(rawFieldValue));
    fieldSizeArray[0].m_sTag := 'DSID';
    fieldSizeArray[0].m_nSize := Length(rawFieldValue);

    s101IniFile.ReadDSSIField(dsGeneralInfo.fDSSI);
    with dsGeneralInfo.fDSSI do begin
      NOIR := Length(infoTypeRecords);
      NOPN := Length(pointRecords);
      NOMN := Length(multiPointRecords);
      NOCN := Length(curveRecords);
      NOXN := Length(compositeCurveRecords);
      NOSN := Length(surfaceRecords);
      NOFR := Length(featureRecords);
    end;
    FillRawFieldValue(@dsGeneralInfo.fDSSI, 'DSSI', 1, rawFieldValue);
    ms.Write(rawFieldValue[0], Length(rawFieldValue));
    fieldSizeArray[1].m_sTag := 'DSSI';
    fieldSizeArray[1].m_nSize := Length(rawFieldValue);

    FillRawFieldValue(@dsGeneralInfo.fATCS, 'ATCS', Length(dsGeneralInfo.fATCS), rawFieldValue);
    ms.Write(rawFieldValue[0], Length(rawFieldValue));
    fieldSizeArray[2].m_sTag := 'ATCS';
    fieldSizeArray[2].m_nSize := Length(rawFieldValue);

    FillRawFieldValue(@dsGeneralInfo.fITCS, 'ITCS', Length(dsGeneralInfo.fITCS), rawFieldValue);
    ms.Write(rawFieldValue[0], Length(rawFieldValue));
    fieldSizeArray[3].m_sTag := 'ITCS';
    fieldSizeArray[3].m_nSize := Length(rawFieldValue);

    FillRawFieldValue(@dsGeneralInfo.fFTCS, 'FTCS', Length(dsGeneralInfo.fFTCS), rawFieldValue);
    ms.Write(rawFieldValue[0], Length(rawFieldValue));
    fieldSizeArray[4].m_sTag := 'FTCS';
    fieldSizeArray[4].m_nSize := Length(rawFieldValue);

    FillRawFieldValue(@dsGeneralInfo.fIACS, 'IACS', Length(dsGeneralInfo.fIACS), rawFieldValue);
    ms.Write(rawFieldValue[0], Length(rawFieldValue));
    fieldSizeArray[5].m_sTag := 'IACS';
    fieldSizeArray[5].m_nSize := Length(rawFieldValue);

    FillRawFieldValue(@dsGeneralInfo.fFACS, 'FACS', Length(dsGeneralInfo.fFACS), rawFieldValue);
    ms.Write(rawFieldValue[0], Length(rawFieldValue));
    fieldSizeArray[6].m_sTag := 'FACS';
    fieldSizeArray[6].m_nSize := Length(rawFieldValue);

    FillRawFieldValue(@dsGeneralInfo.fARCS, 'ARCS', Length(dsGeneralInfo.fARCS), rawFieldValue);
    ms.Write(rawFieldValue[0], Length(rawFieldValue));
    fieldSizeArray[7].m_sTag := 'ARCS';
    fieldSizeArray[7].m_nSize := Length(rawFieldValue);

    FillLeaderAndDir(fieldSizeArray, lrLeader, lrDir);
    fs.Write(lrLeader, SizeOf(lrLeader));
    fs.Write(lrDir[0], Length(lrDir));
    ms.SaveToStream(fs);

    // Заполняем запись с параметрами систем координат и проекций
    ms.Clear;
    s101IniFile.ReadCSIDField(fieldCSID);
    SetLength(fieldSizeArray, 1 + fieldCSID.NCRC * 5);
    FillRawFieldValue(@fieldCSID, 'CSID', 1, rawFieldValue);
    ms.Write(rawFieldValue[0], Length(rawFieldValue));
    fieldSizeArray[0].m_sTag := 'CSID';
    fieldSizeArray[0].m_nSize := Length(rawFieldValue);
    SetLength(crsArray, fieldCSID.NCRC);
    iCurField := 1;
    for iCRS := 0 to fieldCSID.NCRC - 1 do begin
      s101IniFile.ReadCRSHField(crsArray[iCRS].fCRSH, iCRS);
      FillRawFieldValue(@crsArray[iCRS].fCRSH, 'CRSH', 1, rawFieldValue);
      ms.Write(rawFieldValue[0], Length(rawFieldValue));
      fieldSizeArray[iCurField].m_sTag := 'CRSH';
      fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
      iCurField := iCurField + 1;
      if s101IniFile.ReadCSAXField(crsArray[iCRS].fCSAX, iCRS) then begin
        FillRawFieldValue(@crsArray[iCRS].fCSAX, 'CSAX', Length(crsArray[iCRS].fCSAX), rawFieldValue);
        ms.Write(rawFieldValue[0], Length(rawFieldValue));
        fieldSizeArray[iCurField].m_sTag := 'CSAX';
        fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
        iCurField := iCurField + 1;
      end;
      New(crsArray[iCRS].pfPROJ);
      if s101IniFile.ReadPROJField(crsArray[iCRS].pfPROJ^, iCRS) then begin
        FillRawFieldValue(crsArray[iCRS].pfPROJ, 'PROJ', 1, rawFieldValue);
        ms.Write(rawFieldValue[0], Length(rawFieldValue));
        fieldSizeArray[iCurField].m_sTag := 'PROJ';
        fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
        iCurField := iCurField + 1;
      end
      else begin
        Dispose(crsArray[iCRS].pfPROJ);
        crsArray[iCRS].pfPROJ := nil;
      end;
      New(crsArray[iCRS].pfGDAT);
      if s101IniFile.ReadGDATField(crsArray[iCRS].pfGDAT^, iCRS) then begin
        FillRawFieldValue(crsArray[iCRS].pfGDAT, 'GDAT', 1, rawFieldValue);
        ms.Write(rawFieldValue[0], Length(rawFieldValue));
        fieldSizeArray[iCurField].m_sTag := 'GDAT';
        fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
        iCurField := iCurField + 1;
      end
      else begin
        Dispose(crsArray[iCRS].pfGDAT);
        crsArray[iCRS].pfGDAT := nil;
      end;
      New(crsArray[iCRS].pfVDAT);
      if s101IniFile.ReadVDATField(crsArray[iCRS].pfVDAT^, iCRS) then begin
        FillRawFieldValue(crsArray[iCRS].pfVDAT, 'VDAT', 1, rawFieldValue);
        ms.Write(rawFieldValue[0], Length(rawFieldValue));
        fieldSizeArray[iCurField].m_sTag := 'VDAT';
        fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
        iCurField := iCurField + 1;
      end
      else begin
        Dispose(crsArray[iCRS].pfVDAT);
        crsArray[iCRS].pfVDAT := nil;
      end;
    end;
    SetLength(fieldSizeArray, iCurField);
    FillLeaderAndDir(fieldSizeArray, lrLeader, lrDir);
    fs.Write(lrLeader, SizeOf(lrLeader));
    fs.Write(lrDir[0], Length(lrDir));
    ms.SaveToStream(fs);

    // Выводим записи с информационными объектами
    for iRecord := 0 to Length(infoTypeRecords) - 1 do begin
      ms.Clear;
      nAllFields := 1;
      nAllFields := nAllFields + Length(infoTypeRecords[iRecord].fATTRArray);
      nAllFields := nAllFields + Length(infoTypeRecords[iRecord].fINASArray);
      SetLength(fieldSizeArray, nAllFields);
      iCurField := 0;
      FillRawFieldValue(@infoTypeRecords[iRecord].fIRID, 'IRID', 1, rawFieldValue);
      ms.Write(rawFieldValue[0], Length(rawFieldValue));
      fieldSizeArray[iCurField].m_sTag := 'IRID';
      fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
      iCurField := iCurField + 1;
      for i := 0  to Length(infoTypeRecords[iRecord].fATTRArray) - 1 do begin
        FillRawFieldValue(@infoTypeRecords[iRecord].fATTRArray[i], 'ATTR',
            Length(infoTypeRecords[iRecord].fATTRArray[i].arrayOfAttrElem), rawFieldValue);
        ms.Write(rawFieldValue[0], Length(rawFieldValue));
        fieldSizeArray[1].m_sTag := 'ATTR';
        fieldSizeArray[1].m_nSize := Length(rawFieldValue);
        iCurField := iCurField + 1;
      end;
      for i := 0 to Length(infoTypeRecords[iRecord].fINASArray) - 1 do begin
        FillRawFieldValue(@infoTypeRecords[iRecord].fINASArray[i], 'INAS',
            Length(infoTypeRecords[iRecord].fINASArray[i].arrayOfAttrElem), rawFieldValue);
        ms.Write(rawFieldValue[0], Length(rawFieldValue));
        fieldSizeArray[iCurField].m_sTag := 'INAS';
        fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
        iCurField := iCurField + 1;
      end;
      FillLeaderAndDir(fieldSizeArray, lrLeader, lrDir);
      fs.Write(lrLeader, SizeOf(lrLeader));
      fs.Write(lrDir[0], Length(lrDir));
      ms.SaveToStream(fs);
    end;

    // Выводим записи с точками
    for iRecord := 0 to Length(pointRecords) - 1 do begin
      ms.Clear;
      nAllFields := 2;
      nAllFields := nAllFields + Length(pointRecords[iRecord].fINASArray);
      SetLength(fieldSizeArray, nAllFields);
      iCurField := 0;
      FillRawFieldValue(@pointRecords[iRecord].fPRID, 'PRID', 1, rawFieldValue);
      ms.Write(rawFieldValue[0], Length(rawFieldValue));
      fieldSizeArray[iCurField].m_sTag := 'PRID';
      fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
      iCurField := iCurField + 1;
      case pointRecords[iRecord].ct of
        ct2I: begin
          FillRawFieldValue(@pointRecords[iRecord].fC2IT, 'C2IT', 1, rawFieldValue);
          fieldSizeArray[iCurField].m_sTag := 'C2IT';
        end;
        ct3I: begin
          FillRawFieldValue(@pointRecords[iRecord].fC3IT, 'C3IT', 1, rawFieldValue);
          fieldSizeArray[iCurField].m_sTag := 'C3IT';
        end;
        ct2F: begin
          FillRawFieldValue(@pointRecords[iRecord].fC2FT, 'C2FT', 1, rawFieldValue);
          fieldSizeArray[iCurField].m_sTag := 'C2FT';
        end;
        ct3F: begin
          FillRawFieldValue(@pointRecords[iRecord].fC3FT, 'C3FT', 1, rawFieldValue);
          fieldSizeArray[iCurField].m_sTag := 'C3FT';
        end;
      end;
      ms.Write(rawFieldValue[0], Length(rawFieldValue));
      fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
      iCurField := iCurField + 1;
      for i := 0 to Length(pointRecords[iRecord].fINASArray) - 1 do begin
        FillRawFieldValue(@pointRecords[iRecord].fINASArray[i], 'INAS',
            Length(pointRecords[iRecord].fINASArray[i].arrayOfAttrElem), rawFieldValue);
        ms.Write(rawFieldValue[0], Length(rawFieldValue));
        fieldSizeArray[iCurField].m_sTag := 'INAS';
        fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
        iCurField := iCurField + 1;
      end;
      FillLeaderAndDir(fieldSizeArray, lrLeader, lrDir);
      fs.Write(lrLeader, SizeOf(lrLeader));
      fs.Write(lrDir[0], Length(lrDir));
      ms.SaveToStream(fs);
    end;

    // Выводим записи с мультиточками
    for iRecord := 0 to Length(multiPointRecords) - 1 do begin
      ms.Clear;
      nAllFields := 1;
      if multiPointRecords[iRecord].pfCOCC <> nil then
        nAllFields := nAllFields + 1;
      case multiPointRecords[iRecord].ct of
        ct2I: nAllFields := nAllFields + Length(multiPointRecords[iRecord].fC2ILArray);
        ct3I: nAllFields := nAllFields + Length(multiPointRecords[iRecord].fC3ILArray);
        ct2F: nAllFields := nAllFields + Length(multiPointRecords[iRecord].fC2FLArray);
        ct3F: nAllFields := nAllFields + Length(multiPointRecords[iRecord].fC3FLArray);
      end;
      nAllFields := nAllFields + Length(multiPointRecords[iRecord].fINASArray);
      SetLength(fieldSizeArray, nAllFields);
      iCurField := 0;
      FillRawFieldValue(@multiPointRecords[iRecord].fMRID, 'MRID', 1, rawFieldValue);
      ms.Write(rawFieldValue[0], Length(rawFieldValue));
      fieldSizeArray[iCurField].m_sTag := 'MRID';
      fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
      iCurField := iCurField + 1;
      if multiPointRecords[iRecord].pfCOCC <> nil then begin
        FillRawFieldValue(multiPointRecords[iRecord].pfCOCC, 'COCC', 1, rawFieldValue);
        ms.Write(rawFieldValue[0], Length(rawFieldValue));
        fieldSizeArray[iCurField].m_sTag := 'COCC';
        fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
        iCurField := iCurField + 1;
      end;
      case multiPointRecords[iRecord].ct of
        ct2I:
          for i := 0 to Length(multiPointRecords[iRecord].fC2ILArray) - 1 do begin
            FillRawFieldValue(@multiPointRecords[iRecord].fC2ILArray[i],
                'C2IL', Length(multiPointRecords[iRecord].fC2ILArray[i].C2ITArray), rawFieldValue);
            ms.Write(rawFieldValue[0], Length(rawFieldValue));
            fieldSizeArray[iCurField].m_sTag := 'C2IL';
            fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
            iCurField := iCurField + 1;
          end;
        ct3I:
          for i := 0 to Length(multiPointRecords[iRecord].fC3ILArray) - 1 do begin
            FillRawFieldValue(@multiPointRecords[iRecord].fC3ILArray[i],
                'C3IL', Length(multiPointRecords[iRecord].fC3ILArray[i].C3ITArray), rawFieldValue);
            ms.Write(rawFieldValue[0], Length(rawFieldValue));
            fieldSizeArray[iCurField].m_sTag := 'C3IL';
            fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
            iCurField := iCurField + 1;
          end;
        ct2F:
          for i := 0 to Length(multiPointRecords[iRecord].fC2FLArray) - 1 do begin
            FillRawFieldValue(@multiPointRecords[iRecord].fC2FLArray[i],
                'C2FL', Length(multiPointRecords[iRecord].fC2FLArray[i].C2FTArray), rawFieldValue);
            ms.Write(rawFieldValue[0], Length(rawFieldValue));
            fieldSizeArray[iCurField].m_sTag := 'C2FL';
            fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
            iCurField := iCurField + 1;
          end;
        ct3F:
          for i := 0 to Length(multiPointRecords[iRecord].fC3FLArray) - 1 do begin
            FillRawFieldValue(@multiPointRecords[iRecord].fC3FLArray[i],
                'C3FL', Length(multiPointRecords[iRecord].fC3FLArray[i].C3FTArray), rawFieldValue);
            ms.Write(rawFieldValue[0], Length(rawFieldValue));
            fieldSizeArray[iCurField].m_sTag := 'C3FL';
            fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
            iCurField := iCurField + 1;
          end;
      end;
      for i := 0 to Length(multiPointRecords[iRecord].fINASArray) - 1 do begin
        FillRawFieldValue(@multiPointRecords[iRecord].fINASArray[i], 'INAS',
            Length(multiPointRecords[iRecord].fINASArray[i].arrayOfAttrElem), rawFieldValue);
        ms.Write(rawFieldValue[0], Length(rawFieldValue));
        fieldSizeArray[iCurField].m_sTag := 'INAS';
        fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
        iCurField := iCurField + 1;
      end;
      FillLeaderAndDir(fieldSizeArray, lrLeader, lrDir);
      fs.Write(lrLeader, SizeOf(lrLeader));
      fs.Write(lrDir[0], Length(lrDir));
      ms.SaveToStream(fs);
    end;

    // Выводим записи с кривыми
    for iRecord := 0 to Length(curveRecords) - 1 do begin
      ms.Clear;
      nAllFields := 1;
      if Length(curveRecords[iRecord].fPTAS.PTASArray) > 0 then
        nAllFields := nAllFields + 1;
      if curveRecords[iRecord].pfSECC <> nil then
        nAllFields := nAllFields + 1;
      nAllFields := nAllFields + Length(curveRecords[iRecord].fINASArray);
      for i := 0 to Length(curveRecords[iRecord].fSegmentArray) - 1 do begin
        nAllFields := nAllFields + 1;
        if curveRecords[iRecord].fSegmentArray[i].pfCOCC <> nil then
          nAllFields := nAllFields + 1;
        case curveRecords[iRecord].ct of
          ct2I: nAllFields := nAllFields + Length(curveRecords[iRecord].fSegmentArray[i].fC2ILArray);
          ct3I: nAllFields := nAllFields + Length(curveRecords[iRecord].fSegmentArray[i].fC3ILArray);
          ct2F: nAllFields := nAllFields + Length(curveRecords[iRecord].fSegmentArray[i].fC2FLArray);
          ct3F: nAllFields := nAllFields + Length(curveRecords[iRecord].fSegmentArray[i].fC3FLArray);
        end;
      end;
      SetLength(fieldSizeArray, nAllFields);
      iCurField := 0;
      FillRawFieldValue(@curveRecords[iRecord].fCRID, 'CRID', 1, rawFieldValue);
      ms.Write(rawFieldValue[0], Length(rawFieldValue));
      fieldSizeArray[iCurField].m_sTag := 'CRID';
      fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
      iCurField := iCurField + 1;
      if Length(curveRecords[iRecord].fPTAS.PTASArray) > 0 then begin
        FillRawFieldValue(@curveRecords[iRecord].fPTAS, 'PTAS',
            Length(curveRecords[iRecord].fPTAS.PTASArray), rawFieldValue);
        ms.Write(rawFieldValue[0], Length(rawFieldValue));
        fieldSizeArray[iCurField].m_sTag := 'PTAS';
        fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
        iCurField := iCurField + 1;
      end;
      if curveRecords[iRecord].pfSECC <> nil then begin
        FillRawFieldValue(curveRecords[iRecord].pfSECC, 'SECC', 1, rawFieldValue);
        ms.Write(rawFieldValue[0], Length(rawFieldValue));
        fieldSizeArray[iCurField].m_sTag := 'SECC';
        fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
        iCurField := iCurField + 1;
      end;
      for i := 0 to Length(curveRecords[iRecord].fSegmentArray) - 1 do begin
        FillRawFieldValue(@curveRecords[iRecord].fSegmentArray[i].fSEGH, 'SEGH', 1, rawFieldValue);
        ms.Write(rawFieldValue[0], Length(rawFieldValue));
        fieldSizeArray[iCurField].m_sTag := 'SEGH';
        fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
        iCurField := iCurField + 1;
        if curveRecords[iRecord].fSegmentArray[i].pfCOCC <> nil then begin
          FillRawFieldValue(curveRecords[iRecord].fSegmentArray[i].pfCOCC, 'COCC', 1, rawFieldValue);
          ms.Write(rawFieldValue[0], Length(rawFieldValue));
          fieldSizeArray[iCurField].m_sTag := 'COCC';
          fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
          iCurField := iCurField + 1;
        end;
        case curveRecords[iRecord].ct of
          ct2I:
            for j := 0 to Length(curveRecords[iRecord].fSegmentArray[i].fC2ILArray) - 1 do begin
              FillRawFieldValue(@curveRecords[iRecord].fSegmentArray[i].fC2ILArray[j],
                  'C2IL', Length(curveRecords[iRecord].fSegmentArray[i].fC2ILArray[j].C2ITArray), rawFieldValue);
              ms.Write(rawFieldValue[0], Length(rawFieldValue));
              fieldSizeArray[iCurField].m_sTag := 'C2IL';
              fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
              iCurField := iCurField + 1;
            end;
          ct3I:
            for j := 0 to Length(curveRecords[iRecord].fSegmentArray[i].fC3ILArray) - 1 do begin
              FillRawFieldValue(@curveRecords[iRecord].fSegmentArray[i].fC3ILArray[j],
                  'C3IL', Length(curveRecords[iRecord].fSegmentArray[i].fC3ILArray[j].C3ITArray), rawFieldValue);
              ms.Write(rawFieldValue[0], Length(rawFieldValue));
              fieldSizeArray[iCurField].m_sTag := 'C3IL';
              fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
              iCurField := iCurField + 1;
            end;
          ct2F:
            for j := 0 to Length(curveRecords[iRecord].fSegmentArray[i].fC2FLArray) - 1 do begin
              FillRawFieldValue(@curveRecords[iRecord].fSegmentArray[i].fC2FLArray[j],
                  'C2FL', Length(curveRecords[iRecord].fSegmentArray[i].fC2FLArray[j].C2FTArray), rawFieldValue);
              ms.Write(rawFieldValue[0], Length(rawFieldValue));
              fieldSizeArray[iCurField].m_sTag := 'C2FL';
              fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
              iCurField := iCurField + 1;
            end;
          ct3F:
            for j := 0 to Length(curveRecords[iRecord].fSegmentArray[i].fC3FLArray) - 1 do begin
              FillRawFieldValue(@curveRecords[iRecord].fSegmentArray[i].fC3FLArray[j],
                  'C3FL', Length(curveRecords[iRecord].fSegmentArray[i].fC3FLArray[j].C3FTArray), rawFieldValue);
              ms.Write(rawFieldValue[0], Length(rawFieldValue));
              fieldSizeArray[iCurField].m_sTag := 'C3FL';
              fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
              iCurField := iCurField + 1;
            end;
        end;
      end;
      for i := 0 to Length(curveRecords[iRecord].fINASArray) - 1 do begin
        FillRawFieldValue(@curveRecords[iRecord].fINASArray[i], 'INAS',
            Length(curveRecords[iRecord].fINASArray[i].arrayOfAttrElem), rawFieldValue);
        ms.Write(rawFieldValue[0], Length(rawFieldValue));
        fieldSizeArray[iCurField].m_sTag := 'INAS';
        fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
        iCurField := iCurField + 1;
      end;
      FillLeaderAndDir(fieldSizeArray, lrLeader, lrDir);
      fs.Write(lrLeader, SizeOf(lrLeader));
      fs.Write(lrDir[0], Length(lrDir));
      ms.SaveToStream(fs);
    end;

    // Выводим записи с композитными кривыми
    for iRecord := 0 to Length(compositeCurveRecords) - 1 do begin
      ms.Clear;
      nAllFields := 1;
      if compositeCurveRecords[iRecord].pfCCOC <> nil then
        nAllFields := nAllFields + 1;
      nAllFields := nAllFields + Length(compositeCurveRecords[iRecord].fINASArray);
      nAllFields := nAllFields + Length(compositeCurveRecords[iRecord].fCUCOArray);
      SetLength(fieldSizeArray, nAllFields);
      iCurField := 0;
      FillRawFieldValue(@compositeCurveRecords[iRecord].fCCID, 'CCID', 1, rawFieldValue);
      ms.Write(rawFieldValue[0], Length(rawFieldValue));
      fieldSizeArray[iCurField].m_sTag := 'CCID';
      fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
      iCurField := iCurField + 1;
      if compositeCurveRecords[iRecord].pfCCOC <> nil then begin
        FillRawFieldValue(compositeCurveRecords[iRecord].pfCCOC, 'CCOC', 1, rawFieldValue);
        ms.Write(rawFieldValue[0], Length(rawFieldValue));
        fieldSizeArray[iCurField].m_sTag := 'CCOC';
        fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
        iCurField := iCurField + 1;
      end;
      for i := 0 to Length(compositeCurveRecords[iRecord].fINASArray) - 1 do begin
        FillRawFieldValue(@compositeCurveRecords[iRecord].fINASArray[i], 'INAS',
            Length(compositeCurveRecords[iRecord].fINASArray[i].arrayOfAttrElem), rawFieldValue);
        ms.Write(rawFieldValue[0], Length(rawFieldValue));
        fieldSizeArray[iCurField].m_sTag := 'INAS';
        fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
        iCurField := iCurField + 1;
      end;
      for i := 0 to Length(compositeCurveRecords[iRecord].fCUCOArray) - 1 do begin
        FillRawFieldValue(@compositeCurveRecords[iRecord].fCUCOArray[i], 'CUCO',
            Length(compositeCurveRecords[iRecord].fCUCOArray[i].CUCOArray), rawFieldValue);
        ms.Write(rawFieldValue[0], Length(rawFieldValue));
        fieldSizeArray[iCurField].m_sTag := 'CUCO';
        fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
        iCurField := iCurField + 1;
      end;
      FillLeaderAndDir(fieldSizeArray, lrLeader, lrDir);
      fs.Write(lrLeader, SizeOf(lrLeader));
      fs.Write(lrDir[0], Length(lrDir));
      ms.SaveToStream(fs);
    end;

    // Выводим записи с поверхностями
    N := Length(surfaceRecords);
    for iRecord := 0 to Length(surfaceRecords) - 1 do begin
      ms.Clear;
      nAllFields := 1;
      nAllFields := nAllFields + Length(surfaceRecords[iRecord].fINASArray);
      nAllFields := nAllFields + Length(surfaceRecords[iRecord].fRIASArray);
      SetLength(fieldSizeArray, nAllFields);
      iCurField := 0;
      FillRawFieldValue(@surfaceRecords[iRecord].fSRID, 'SRID', 1, rawFieldValue);
      ms.Write(rawFieldValue[0], Length(rawFieldValue));
      fieldSizeArray[iCurField].m_sTag := 'SRID';
      fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
      iCurField := iCurField + 1;
      for i := 0 to Length(surfaceRecords[iRecord].fINASArray) - 1 do begin
        FillRawFieldValue(@surfaceRecords[iRecord].fINASArray[i], 'INAS',
            Length(surfaceRecords[iRecord].fINASArray[i].arrayOfAttrElem), rawFieldValue);
        ms.Write(rawFieldValue[0], Length(rawFieldValue));
        fieldSizeArray[iCurField].m_sTag := 'INAS';
        fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
        iCurField := iCurField + 1;
      end;
      for i := 0 to Length(surfaceRecords[iRecord].fRIASArray) - 1 do begin
        FillRawFieldValue(@surfaceRecords[iRecord].fRIASArray[i], 'RIAS',
            Length(surfaceRecords[iRecord].fRIASArray[i].RIASArray), rawFieldValue);
        ms.Write(rawFieldValue[0], Length(rawFieldValue));
        fieldSizeArray[iCurField].m_sTag := 'RIAS';
        fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
        iCurField := iCurField + 1;
      end;
      FillLeaderAndDir(fieldSizeArray, lrLeader, lrDir);
      fs.Write(lrLeader, SizeOf(lrLeader));
      fs.Write(lrDir[0], Length(lrDir));
      ms.SaveToStream(fs);
    end;

    // Выводим записи с геообъектами
    m_nAgencyCode := s101IniFile.ReadInteger('Common', 'AgencyCode', 0);
    GenerateFOIDs;
    for iRecord := 0 to Length(featureRecords) - 1 do begin
      ms.Clear;
      nAllFields := 1;
      if featureRecords[iRecord].pfFOID <> nil then
        nAllFields := nAllFields + 1;
      nAllFields := nAllFields + Length(featureRecords[iRecord].fATTRArray);
      nAllFields := nAllFields + Length(featureRecords[iRecord].fINASArray);
      nAllFields := nAllFields + Length(featureRecords[iRecord].fSPASArray);
      nAllFields := nAllFields + Length(featureRecords[iRecord].fFASCArray);
      nAllFields := nAllFields + Length(featureRecords[iRecord].fTHASArray);
      nAllFields := nAllFields + Length(featureRecords[iRecord].fMASKArray);
      SetLength(fieldSizeArray, nAllFields);
      iCurField := 0;
      FillRawFieldValue(@featureRecords[iRecord].fFRID, 'FRID', 1, rawFieldValue);
      ms.Write(rawFieldValue[0], Length(rawFieldValue));
      fieldSizeArray[iCurField].m_sTag := 'FRID';
      fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
      iCurField := iCurField + 1;
      if featureRecords[iRecord].pfFOID <> nil then begin
        FillRawFieldValue(featureRecords[iRecord].pfFOID, 'FOID', 1, rawFieldValue);
        ms.Write(rawFieldValue[0], Length(rawFieldValue));
        fieldSizeArray[iCurField].m_sTag := 'FOID';
        fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
        iCurField := iCurField + 1;
      end;
      for i := 0 to Length(featureRecords[iRecord].fINASArray) - 1 do begin
        FillRawFieldValue(@featureRecords[iRecord].fINASArray[i], 'INAS',
            Length(featureRecords[iRecord].fINASArray[i].arrayOfAttrElem), rawFieldValue);
        ms.Write(rawFieldValue[0], Length(rawFieldValue));
        fieldSizeArray[iCurField].m_sTag := 'INAS';
        fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
        iCurField := iCurField + 1;
      end;
      for i := 0 to Length(featureRecords[iRecord].fATTRArray) - 1 do begin
        FillRawFieldValue(@featureRecords[iRecord].fATTRArray[i], 'ATTR',
            Length(featureRecords[iRecord].fATTRArray[i].arrayOfAttrElem), rawFieldValue);
        ms.Write(rawFieldValue[0], Length(rawFieldValue));
        fieldSizeArray[iCurField].m_sTag := 'ATTR';
        fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
        iCurField := iCurField + 1;
      end;
      for i := 0 to Length(featureRecords[iRecord].fSPASArray) - 1 do begin
        FillRawFieldValue(@featureRecords[iRecord].fSPASArray[i], 'SPAS',
            Length(featureRecords[iRecord].fSPASArray[i].SPASArray), rawFieldValue);
        ms.Write(rawFieldValue[0], Length(rawFieldValue));
        fieldSizeArray[iCurField].m_sTag := 'SPAS';
        fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
        iCurField := iCurField + 1;
      end;
      for i := 0 to Length(featureRecords[iRecord].fFASCArray) - 1 do begin
        FillRawFieldValue(@featureRecords[iRecord].fFASCArray[i], 'FASC',
            Length(featureRecords[iRecord].fFASCArray[i].arrayOfAttrElem), rawFieldValue);
        ms.Write(rawFieldValue[0], Length(rawFieldValue));
        fieldSizeArray[iCurField].m_sTag := 'FASC';
        fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
        iCurField := iCurField + 1;
      end;
      for i := 0 to Length(featureRecords[iRecord].fTHASArray) - 1 do begin
        FillRawFieldValue(@featureRecords[iRecord].fTHASArray[i], 'THAS',
            Length(featureRecords[iRecord].fTHASArray[i].THASArray), rawFieldValue);
        ms.Write(rawFieldValue[0], Length(rawFieldValue));
        fieldSizeArray[iCurField].m_sTag := 'THAS';
        fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
        iCurField := iCurField + 1;
      end;
      for i := 0 to Length(featureRecords[iRecord].fMASKArray) - 1 do begin
        FillRawFieldValue(@featureRecords[iRecord].fMASKArray[i], 'MASK',
            Length(featureRecords[iRecord].fMASKArray[i].MASKArray), rawFieldValue);
        ms.Write(rawFieldValue[0], Length(rawFieldValue));
        fieldSizeArray[iCurField].m_sTag := 'MASK';
        fieldSizeArray[iCurField].m_nSize := Length(rawFieldValue);
        iCurField := iCurField + 1;
      end;
      FillLeaderAndDir(fieldSizeArray, lrLeader, lrDir);
      fs.Write(lrLeader, SizeOf(lrLeader));
      fs.Write(lrDir[0], Length(lrDir));
      ms.SaveToStream(fs);
    end;
  Result := True;
  finally
    ms.Free;
    fs.Free;
    s101IniFile.Free;
    Close(tfLog);
  end;
end;

function TS101DataSet.GetAttributeValue(attrCode: Integer; attrArray: array of TATTRField): string;
var
  iATTR, iAttrElem: Integer;
begin
  Result := '';
  for iATTR := 0 to Length(attrArray) - 1 do
    for iAttrElem := 0 to Length(attrArray[iATTR].arrayOfAttrElem) - 1 do
      with attrArray[iATTR].arrayOfAttrElem[iAttrElem] do
        if NATC = attrCode then begin
          Result := ATVL;
          Exit;
        end;
end;

function TS101DataSet.GetAttributeValue(attrAcronym: string; attrArray: array of TATTRField): string;
var
  iPair, attrCode: Integer;
begin
  Result := '';
  for iPair := 0 to Length(dsGeneralInfo.fATCS) - 1 do
    if dsGeneralInfo.fATCS[iPair].sCode = attrAcronym then begin
      attrCode := dsGeneralInfo.fATCS[iPair].iCode;
      Break;
    end;
  if iPair = Length(dsGeneralInfo.fATCS) then Exit;
  Result := GetAttributeValue(attrCode, attrArray);
end;

function TS101DataSet.DeleteAttribute(attrCode: Integer; var attrArray: array of TATTRField): Boolean;
var
  iATTR, iAttrElem, iAttrElem2, nAttrElemCount, nElemsToDelete: Integer;
  bExtendDeleted: Boolean;
begin
  Result := False;
  for iATTR := 0 to Length(attrArray) - 1 do begin
    nAttrElemCount := Length(attrArray[iATTR].arrayOfAttrElem);
    iAttrElem := 0;
    while iAttrElem < nAttrElemCount - 1 do begin
      if attrArray[iATTR].arrayOfAttrElem[iAttrElem].NATC = attrCode then begin
        nElemsToDelete := 1;
        bExtendDeleted := True;
        for iAttrElem2 := iAttrElem + 1 to nAttrElemCount - 1 do
          with attrArray[iATTR].arrayOfAttrElem[iAttrElem2] do
            if bExtendDeleted then begin
              if PAIX >= iAttrElem then
                nElemsToDelete := nElemsToDelete + 1
              else
                bExtendDeleted := False;
            end
            else begin
              if PAIX > iAttrElem then
                PAIX := PAIX - nElemsToDelete;
            end;
        if iAttrElem < nAttrElemCount - nElemsToDelete then begin
          for iAttrElem2 := iAttrElem to iAttrElem + nElemsToDelete - 1 do
            attrArray[iATTR].arrayOfAttrElem[iAttrElem2].ATVL := '';
          Move(attrArray[iATTR].arrayOfAttrElem[iAttrElem + nElemsToDelete],
              attrArray[iATTR].arrayOfAttrElem[iAttrElem],
              SizeOf(TAttrElem) * (nAttrElemCount - iAttrElem - nElemsToDelete));
          FillChar(attrArray[iATTR].arrayOfAttrElem[nAttrElemCount - nElemsToDelete], SizeOf(TAttrElem) * nElemsToDelete, 0);
        end;
        nAttrElemCount := nAttrElemCount - nElemsToDelete;
        SetLength(attrArray[iATTR].arrayOfAttrElem, nAttrElemCount);
      end
      else
        iAttrElem := iAttrElem + 1;
    end;
  end;
  Result := True;
end;

function TS101DataSet.DeleteAttribute(attrAcronym: string; var attrArray: array of TATTRField): Boolean;
var
  iPair, attrCode: Integer;
begin
  Result := False;
  for iPair := 0 to Length(dsGeneralInfo.fATCS) - 1 do
    if dsGeneralInfo.fATCS[iPair].sCode = attrAcronym then begin
      attrCode := dsGeneralInfo.fATCS[iPair].iCode;
      Break;
    end;
  if iPair = Length(dsGeneralInfo.fATCS) then Exit;
  Result := DeleteAttribute(attrCode, attrArray);
end;

function TS101DataSet.GenerateFOIDs: Boolean;
var
  iFeature: Integer;
begin
  Result := False;
  for iFeature := 0 to Length(featureRecords) - 1 do
    with featureRecords[iFeature] do begin
      if pfFOID = nil then begin
        New(pfFOID);
        pfFOID^.AGEN := m_nAgencyCode;
        pfFOID^.FIDN := iFeature + 1;
        pfFOID^.FIDS := 1;
      end;
    end;
  Result := True;
end;

function TS101DataSet.GetCellExtent(var latMin: Double; var lonMin: Double;
    var latMax: Double; var lonMax: Double): Boolean;
var
  i, j, k, l: Integer;
  lat, lon: Double;
begin
  Result := False;
  latMin := 90;
  lonMin := 180;
  latMax := -90;
  lonMax := -180;
  with dsGeneralInfo.fDSSI do begin
    for i := 0 to High(pointRecords) do begin
      with pointRecords[i] do
        case ct of
          ct2I:
            with fC2IT do begin
              lon := DCOX + XCOO / CMFX;
              lat := DCOY + YCOO / CMFY;
            end;
          ct3I:
            with fC3IT do begin
              lon := DCOX + XCOO / CMFX;
              lat := DCOY + YCOO / CMFY;
            end;
        end;
      if lat < latMin then
        latMin := lat;
      if lon < lonMin then
        lonMin := lon;
      if lat > latMax then
        latMax := lat;
      if lon > lonMax then
        lonMax := lon;
    end;
    for i := 0 to High(multiPointRecords) do begin
      with multiPointRecords[i] do
        case ct of
          ct2I:
            for j := 0 to High(fC2ILArray) do
              for k := 0 to High(fC2ILArray[j].C2ITArray) do
                with fC2ILArray[j].C2ITArray[k] do begin
                  lon := DCOX + XCOO / CMFX;
                  lat := DCOY + YCOO / CMFY;
                end;
          ct3I:
            for j := 0 to High(fC3ILArray) do
              for k := 0 to High(fC3ILArray[j].C3ITArray) do
                with fC3ILArray[j].C3ITArray[k] do begin
                  lon := DCOX + XCOO / CMFX;
                  lat := DCOY + YCOO / CMFY;
                end;
        end;
      if lat < latMin then
        latMin := lat;
      if lon < lonMin then
        lonMin := lon;
      if lat > latMax then
        latMax := lat;
      if lon > lonMax then
        lonMax := lon;
    end;
    for i := 0 to High(curveRecords) do begin
      with curveRecords[i] do
        for j := 0 to High(fSegmentArray) do
          for k := 0 to High(fSegmentArray[j].fC2ILArray) do
            for l := 0 to High(fSegmentArray[j].fC2ILArray[k].C2ITArray) do
              with fSegmentArray[j].fC2ILArray[k].C2ITArray[l] do begin
                lon := DCOX + XCOO / CMFX;
                lat := DCOY + YCOO / CMFY;
              end;
      if lat < latMin then
        latMin := lat;
      if lon < lonMin then
        lonMin := lon;
      if lat > latMax then
        latMax := lat;
      if lon > lonMax then
        lonMax := lon;
    end;
  end;
  Result := True;
end;

{
function TS101DataSet.UniteCommonGeometry: Boolean;
var
  iFeature1, iFeature2: Integer;
  iSPASField1, iSPASElem1, iSPASField2, iSPASElem2, iRecordType1, iRecordType2: Integer;
  iRecordId1, iRecordId2, iRecordIndex, iRecordIndex1, iRecordIndex2: Integer;
begin
  Result := False;
  for iFeature1 := 0 to Length(featureRecords) - 1 do
    for iFeature2 := 0 to Length(featureRecords) - 1 do begin
      if iFeature1 = iFeature2 then Continue;
      for iSPASField1 := 0 to Length(featureRecords[iFeature1].fSPASArray) - 1 do
        for iSPASElem1 := 0 to Length(featureRecords[iFeature1].fSPASArray[iSPASField1].SPASArray) - 1 do
          for iSPASField2 := 0 to Length(featureRecords[iFeature2].fSPASArray) - 1 do
            for iSPASElem2 := 0 to Length(featureRecords[iFeature2].fSPASArray[iSPASField2].SPASArray) - 1 do begin
              iRecordType1 := featureRecords[iFeature1].fSPASArray[iSPASField1].SPASArray[iSPASElem1].RRNM;
              iRecordType2 := featureRecords[iFeature2].fSPASArray[iSPASField2].SPASArray[iSPASElem2].RRNM;
              if iRecordType1 = iRecordType2 then begin
                if iRecordType1 = Ord(MultiPointRecordType) then Continue;
              end
              else if (iRecordType1 = Ord(PointRecordType)) or (iRecordType1 = Ord(MultiPointRecordType)) or
                  (iRecordType2 = Ord(PointRecordType))  or (iRecordType2 = Ord(MultiPointRecordType)) then Continue;
              iRecordId1 := featureRecords[iFeature1].fSPASArray[iSPASField1].SPASArray[iSPASElem1].RRID;
              iRecordId2 := featureRecords[iFeature2].fSPASArray[iSPASField2].SPASArray[iSPASElem2].RRID;
              if iRecordId1 = iRecordId2 then Continue;
              iRecordIndex1 := -1;
              iRecordIndex2 := -1;
              if iRecordType1 = Ord(PointRecordType) then begin
                for iRecordIndex := 0 to  Length(pointRecords) - 1 do begin
                  if (iRecordIndex1 >= 0) and (iRecordIndex2 >= 0) then Break;
                  if (iRecordIndex1 = -1) and (pointRecords[iRecordIndex].fPRID.RCID = iRecordId1) then begin
                    iRecordIndex1 := iRecordIndex;
                    Continue;
                  end;
                  if (iRecordIndex2 = -1) and (pointRecords[iRecordIndex].fPRID.RCID = iRecordId2) then begin
                    iRecordIndex2 := iRecordIndex;
                    Continue;
                  end;
                end;
                if (iRecordIndex1 = -1) or (iRecordIndex2 = -1) then Exit;
                if IsEqual(pointRecords[iRecordIndex1], pointRecords[iRecordIndex2], Self, Self) then
                  featureRecords[iFeature2].fSPASArray[iSPASField2].SPASArray[iSPASElem2].RRID := iRecordId1;
              end
              else begin
                if iRecordType1 = Ord(CurveRecordType) then
                  for iRecordIndex := 0 to  Length(curveRecords) - 1 do begin
                    if curveRecords[iRecordIndex].fCRID.RCID = iRecordId1 then begin
                      iRecordIndex1 := iRecordIndex;
                      Break;
                    end;
                  end
                else if iRecordType1 = Ord(CompositeCurveRecordType) then
                  for iRecordIndex := 0 to  Length(compositeCurveRecords) - 1 do begin
                    if compositeCurveRecords[iRecordIndex].fCCID.RCID = iRecordId1 then begin
                      iRecordIndex1 := iRecordIndex;
                      Break;
                    end;
                  end
                else
                  for iRecordIndex := 0 to  Length(surfaceRecords) - 1 do begin
                    if surfaceRecords[iRecordIndex].fSRID.RCID = iRecordId1 then begin
                      iRecordIndex1 := iRecordIndex;
                      Break;
                    end;
                  end;
                if iRecordIndex1 = -1 then Exit;
                if iRecordType2 = Ord(CurveRecordType) then
                  for iRecordIndex := 0 to  Length(curveRecords) - 1 do begin
                    if curveRecords[iRecordIndex].fCRID.RCID = iRecordId2 then begin
                      iRecordIndex2 := iRecordIndex;
                      Break;
                    end;
                  end
                else if iRecordType2 = Ord(CompositeCurveRecordType) then
                  for iRecordIndex := 0 to  Length(compositeCurveRecords) - 1 do begin
                    if compositeCurveRecords[iRecordIndex].fCCID.RCID = iRecordId2 then begin
                      iRecordIndex2 := iRecordIndex;
                      Break;
                    end;
                  end
                else
                  for iRecordIndex := 0 to  Length(surfaceRecords) - 1 do begin
                    if surfaceRecords[iRecordIndex].fSRID.RCID = iRecordId2 then begin
                      iRecordIndex2 := iRecordIndex;
                      Break;
                    end;
                  end;
                if iRecordIndex2 = -1 then Exit;
                if iRecordType1 = iRecordType2 then
                  if iRecordType1 = Ord(CurveRecordType) then begin
                    if IsEqual(curveRecords[iRecordIndex1], curveRecords[iRecordIndex2], Self, Self) then begin
                      featureRecords[iFeature2].fSPASArray[iSPASField2].SPASArray[iSPASElem2].RRID := iRecordId1;
                      Continue;
                    end;
                    // Объединяем геометрии...
                  end
                  else if iRecordType1 = Ord(CompositeCurveRecordType) then begin
                    if IsEqual(compositeCurveRecords[iRecordIndex1], compositeCurveRecords[iRecordIndex2], Self, Self) then begin
                      featureRecords[iFeature2].fSPASArray[iSPASField2].SPASArray[iSPASElem2].RRID := iRecordId1;
                      Continue;
                    end;
                    // Объединяем геометрии...
                  end
                  else begin
                    if IsEqual(surfaceRecords[iRecordIndex1], surfaceRecords[iRecordIndex2], Self, Self) then begin
                      featureRecords[iFeature2].fSPASArray[iSPASField2].SPASArray[iSPASElem2].RRID := iRecordId1;
                      Continue;
                    end;
                    // Объединяем геометрии...
                  end;
              end;
            end;
    end;
  Result := True;
end;

function TS101DataSet.UniteCurves(curve1, curve2: TCurveRec; var compositeCurve1,
    compositeCurve2: TCompositeCurveRec): Boolean;
var
  iPoint1, iPoint2, ix1, iy1, ix2, iy2, nCurves: Integer;
  bFound: Boolean;
begin
  Result := False;
  if curve1.ct = ct2I then begin
    bFound := False;
    for iPoint1 := 0 to Length(curve1.fSegmentArray[0].fC2ILArray[0].C2ITArray) - 1 do begin
      ix1 := curve1.fSegmentArray[0].fC2ILArray[0].C2ITArray[iPoint1].XCOO;
      iy1 := curve1.fSegmentArray[0].fC2ILArray[0].C2ITArray[iPoint1].YCOO;
      for iPoint2 := 0 to Length(curve2.fSegmentArray[0].fC2ILArray[0].C2ITArray) - 1 do begin
        ix2 := curve2.fSegmentArray[0].fC2ILArray[0].C2ITArray[iPoint2].XCOO;
        iy2 := curve2.fSegmentArray[0].fC2ILArray[0].C2ITArray[iPoint2].YCOO;
        if (ix1 = ix2) and (iy1 = iy2) then begin
          bFound := True;
          Break;
        end;
      end;
      if bFound then Break;
    end;
    if not bFound then Exit;
    if iPoint1 =
    ClearRec(compositeCurve1);
    compositeCurve1.fCCID.RCNM := Ord(CompositeCurveRecordType);
    compositeCurve1.fCCID.RVER := 1;
    compositeCurve1.fCCID.RUIN := 1;
    nCurves := Length(curveRecords);
    SetLength(curveRecords, nCurves + 1);
    ClearRec(curveRecords[nCurves]);
    curveRecords[nCurves].ct := curve1.ct;
    curveRecords[nCurves].fCRID.RCNM := Ord(CurveRecordType);
    curveRecords[nCurves].fCRID.RCID := curveRecords[nCurves - 1].fCRID.RCID + 1;
    curveRecords[nCurves].fCRID.RVER := 1;
    curveRecords[nCurves].fCRID.RUIN := 1;
    S101Copy(curve1.fINASArray, curveRecords[nCurves].fINASArray);
  end
  else if curve1.ct = ct2F then begin
  end
  else Exit;
  Result := True;
end;
}

end.
