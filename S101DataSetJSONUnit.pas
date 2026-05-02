unit S101DataSetJSONUnit;

interface

uses
  Classes, SysUtils, StrUtils, SyncObjs, Dialogs, Forms, Contnrs, Windows,
  uLkJSON, ProgressFormUnit, S101TypesUnit, S101CatalogueUnit, S101DataSetUnit,
  S101BinaryAccessUnit, S101IniFileUnit;

type
  TTreeNode = class
  public
    parent: TTreeNode;
    attrIndex: Integer;
    name: string;
    value: string;
    children: TObjectList;
    constructor Create;
  end;

  TReference = class
    m_sSourceGUID: string;
    m_sTargetGUID: string;
    m_Binding: TRoleTypeOfBinding;
    constructor Create(sSourceGUID, sTargetGUID: string; rtBinding: TRoleTypeOfBinding);
    destructor Destroy; override;
  end;

  TReferences = class(TMyObjectList)
    function GetKeyByIndex(index: Integer): string; override;
  end;

  TS101DataSetJSON = class(TS101DataSet)
  public
    references: TReferences;
    m_bPreserveUpdateStatus: Boolean;
  public
    constructor Create(catalogue: TS101Catalogue; bPreserveUpdateStatus: Boolean = False);
    destructor Destroy; override;
    function RunInWorkingThread(reMethod: TReadExportMethod; sFileName, sLogName: string; var sError: string): Integer; override;
    function ExportToJSON(fileName, logName: string; var sError: string): Boolean;
    function ReadS101JSON(fileName, logName: string; var sError: string): Boolean;
    procedure AttributesToJSON(sCode: string; attrArray: array of TATTRField;
        var jsAttributes: TlkJSONobject);
    procedure TreeNodesToJSON(parentNode: TTreeNode; jsParent: TlkJSONobject);
    procedure RemoveEmptyNodes(parentNode: TTreeNode);
    procedure InfoAssociationsToJSON(sGUID, sSourceCode: string;
        fINASArray: array of TINASField; var jlAssociations: TlkJSONlist);
    procedure FeatureAssociationsToJSON(sGUID, sSourceCode: string;
        fFASCArray: array of TFASCField; var jlAssociations: TlkJSONlist);
    procedure InfoAssociationsFromJSON(sCode: string; jlAssociations: TlkJSONlist;
        var fINASArray: TArrayOfINASField);
    procedure FeatureAssociationsFromJSON(sCode: string; jlAssociations: TlkJSONlist;
        var fFASCArray: TArrayOfFASCField);
    procedure AttributesFromJSON(sCode: string; jsAttributes: TlkJSONobject;
        var arrayOfAttrElem: TArrayOfAttrElem);
    function CurveRecordToJSON(curveRecord: TCurveRec; var jsStartPoint, jsEndPoint,
        jsCurve: TlkJSONobject): Boolean;
    function CompositeCurveRecordToJSON(compositeCurveRecord: TCompositeCurveRec;
        var jsSumStartPoint, jsSumEndPoint, jsSumCurve: TlkJSONobject; ccOrientation: Integer): Boolean;
    function CheckAndCloseRing(sGUID: string; jsPatch: TlkJSONobject; bClose: Boolean): Boolean;
    procedure FillCodeTables;
    function SoundingToMultiPoints(jsPatch: TlkJSONobject): Boolean;
    function AddMandatoryAttributes(sCode: string; ssAttributesNames: TStrings;
        var arrayOfAttrElem: TArrayOfAttrElem; curPAIX: Integer): Boolean;
  end;

  TCalculationJSONThread = class(TCalculationThread)
  protected
    procedure Execute; override;
  end;

implementation

//uses
//  MyS101ReaderFormUnit;

// --------------------- TTreeNode ---------------------

constructor TTreeNode.Create;
begin
  children := TObjectList.Create;
end;

// --------------------- References ---------------------

constructor TReference.Create(sSourceGUID, sTargetGUID: string; rtBinding: TRoleTypeOfBinding);
begin
  m_sSourceGUID := sSourceGUID;
  m_sTargetGUID := sTargetGUID;
  m_Binding := TRoleTypeOfBinding.Create(rtBinding);
end;

destructor TReference.Destroy;
begin
  m_Binding.Free;
  m_Binding := nil;
  inherited;
end;

function TReferences.GetKeyByIndex(index: Integer): string;
begin
  Result := '';
  if (index < 0) or (index >= Count) then
    Exit;
  Result := TReference(Self[index]).m_sSourceGUID + '_' + TReference(Self[index]).m_sTargetGUID;
end;

function CompareReferences(Item1, Item2: Pointer): Integer;
var
  referenceItem1, referenceItem2: TReference;
begin
  referenceItem1 := TReference(Item1);
  referenceItem2 := TReference(Item2);
  Result := CompareStr(referenceItem1.m_sSourceGUID + '_' + referenceItem1.m_sTargetGUID,
      referenceItem2.m_sSourceGUID + '_' + referenceItem2.m_sTargetGUID);
end;

// --------------------- TCalculationJSONThread ---------------------

procedure TCalculationJSONThread.Execute;
begin
  case m_reMethod of
    ReadS101Binary: begin
      inherited Execute;
      Exit;
    end;
    ExportToBinary: begin
      inherited Execute;
      Exit;
    end;
    ExportToJSON: TS101DataSetJSON(m_dsS101).ExportToJSON(m_sFileName, m_sLogName, m_sError);
    ReadS101JSON: TS101DataSetJSON(m_dsS101).ReadS101JSON(m_sFileName, m_sLogName, m_sError);
  end;
  finishedEvent.SetEvent;
end;

// --------------------- TS101DataSetJSON ---------------------

function TS101DataSetJSON.RunInWorkingThread(reMethod: TReadExportMethod;
    sFileName, sLogName: string; var sError: string): Integer;
begin
  try
    // Создадим и запустим рабочий поток
    suspendEvent.SetEvent;
    finishedEvent.ResetEvent;
    breakEvent.ResetEvent;
    calculationThread := TCalculationJSONThread.Create(self, reMethod, sFileName, sLogName);

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

constructor TS101DataSetJSON.Create(catalogue: TS101Catalogue; bPreserveUpdateStatus: Boolean = False);
begin
  inherited Create(catalogue);
  m_bPreserveUpdateStatus := bPreserveUpdateStatus;
end;

destructor TS101DataSetJSON.Destroy;
begin
  references.Free;
  references := nil;
  inherited;
end;

function CreateCopyJS(js: TlkJSONbase): TlkJSONbase;
var
  _jsNumber: TlkJSONnumber;
  _jsString: TlkJSONstring;
  _jsBoolean: TlkJSONboolean;
  _jsNull: TlkJSONnull;
  _jsSourceObject, _jsDestObject: TlkJSONobject;
  _jsSourceList, _jsDestList: TlkJSONlist;
  i : Integer;
  sName: string;
begin
  Result := nil;
  if js = nil then Exit;
  case js.SelfType of
    jsNumber: begin
      _jsNumber := TlkJSONnumber.Create;
      _jsNumber.Value := (js as TlkJSONnumber).Value;
      Result := _jsNumber;
    end;
    jsString: begin
      _jsString := TlkJSONstring.Create;
      _jsString.Value := (js as TlkJSONstring).Value;
      Result := _jsString;
    end;
    jsBoolean: begin
      _jsBoolean := TlkJSONboolean.Create;
      _jsBoolean.Value := (js as TlkJSONboolean).Value;
      Result := _jsBoolean;
    end;
    jsNull: begin
      _jsNull := TlkJSONnull.Create;
      _jsNull.Value := (js as TlkJSONnull).Value;
      Result := _jsNull;
    end;
    jsObject: begin
      _jsSourceObject := js as TlkJSONobject;
      _jsDestObject := TlkJSONobject.Create;
      for i := 0 to _jsSourceObject.Count - 1 do begin
        sName := _jsSourceObject.NameOf[i];
        _jsDestObject.Add(sName, CreateCopyJS(_jsSourceObject.Field[sName]));
      end;
      Result := _jsDestObject;
    end;
    jsList: begin
      _jsSourceList := js as TlkJSONlist;
      _jsDestList := TlkJSONlist.Create;
      for i := 0 to _jsSourceList.Count - 1 do
        _jsDestList.Add(CreateCopyJS(_jsSourceList.Child[i]));
      Result := _jsDestList;
    end;
  end;
end;

function TS101DataSetJSON.ExportToJSON(fileName, logName: string; var sError: string): Boolean;
var
  fs: TFileStream;
  tf1, tf2: TextFile;
  i, j, k, iFeature, iPair, nPointsInList, iCurveList, iCurveComponent, iSurfaceRec: Integer;
  iReference, nCurveComponents: Integer;
  reference: TReference;
  sContent, sCode, sLine, tempFile, s: string;
  js, jsPatch, jsFeature, jsAttributes, jsCompositeCurveObject, jsCurveComponentObject: TlkJSONobject;
  jl, jlGeometries, jlCoords, jlInternalPoints, jlStartEndPoint, jlSumInternalPoints: TlkJSONlist;
  jlCurveComponents, jlSurfaceRings, jlAssociations, jlComplexAttribute: TlkJSONlist;
  guid: TGUID;
  sGUID, sIdent, sMP3Ident, sDestIdent: string;
  iInfoObject, iPointRec, iMultiPointRec, iMultiPoint, iPointInMulti: Integer;
  iCurveRec, iSegmentElem, iCoordList, iPointInList, iCompositeCurveRec: Integer;
  iRIASFieldNo, iRingNo, iSPASFieldNo, iSPASElemNo, iAssociation: Integer;
  jsInfoObject, jsPointObject, jsMultiPointObject, jsCurveObject: TlkJSONobject;
  jsSurfaceObject, jsRing, jsGeometry, jsScaleRange, jsAssociation: TlkJSONobject;
  jsStartPoint, jsEndPoint, jsSumCurve, jsPoint, jsSumPoint, jsCopyPoint: TlkJSONobject;
  x, y, z: Double;
  iInfoObject2, iFeature2, iValue, index: Integer;
  slReferencedIdents, slIdentsToDelete: TStringList;
  keyIValueCurveList, keyIValueCompositeCurveList: TKeyIValueList;
  jsCopy, jsPatchCopy, jsCopyFeature, jsComplexAttribute, jsToAddPatch: TlkJSONobject;
  jsDestFeature: TlkJSONobject;
  bAdd: Boolean;
  progress: TProgress;
  bStop: Boolean;
begin
  try
    Result := False;
    if fileName = '' then begin
      sError := 'Не задан путь к JSON-файлу';
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

    i := 0;
    js := TlkJSONobject.Create;
    js.Add('branch', AnsiReplaceText(ExtractFileName(fileName), '.json', ''));
    js.Add('message', 'Imported from ' + AnsiReplaceText(ExtractFileName(fileName), '.json', '.000'));
    jsPatch := TlkJSONobject.Create;
    js.Add('patch', jsPatch);
    references := TReferences.Create;

    // Экспорт информационных объектов
    WriteLn(tfLog, 'Информационные объекты');
    for iInfoObject := 0 to Length(infoTypeRecords) - 1 do begin
      sGUID := AnsiUpperCase(GetAttributeValue('guID', infoTypeRecords[iInfoObject].fATTRArray));
      if sGUID = '' then begin
        CreateGUID(guid);
        sGUID := GUIDToString(guid);
        sGUID := MidStr(sGUID, 2, Length(sGUID) - 2);
      end;
      infoTypeRecords[iInfoObject].m_sGUID := sGUID;
      WriteLn(tfLog, Format(#9'RCID=%d, GUID=%s',
          [infoTypeRecords[iInfoObject].fIRID.RCID, infoTypeRecords[iInfoObject].m_sGUID]));
    end;
    for iInfoObject := 0 to Length(infoTypeRecords) - 1 do begin
      /////////////////////////////////////////////////////////
      // Проверка прерывания процесса пользователем
      suspendEvent.WaitFor($FFFFFFFF);
      if breakEvent.WaitFor(0) = wrSignaled then begin
        if calculationThread <> nil then
          calculationThread.m_nTermStatus := TERM_STATUS_USERSTOP;
        Exit;
      end
      else begin
        progress := TProgress(threadList.LockList[0]);
        progress.m_max := Length(infoTypeRecords);
        progress.m_pos := iInfoObject;
        progress.m_Message := 'Экспорт информационных объектов в JSON';
        threadList.UnlockList;
      end;
      /////////////////////////////////////////////////////////
      sGUID := infoTypeRecords[iInfoObject].m_sGUID;
      jl := TlkJSONlist.Create;
      jsInfoObject := TlkJSONobject.Create;
      sCode := '';
      for iPair := 0 to Length(dsGeneralInfo.fITCS) - 1 do
        if dsGeneralInfo.fITCS[iPair].iCode = infoTypeRecords[iInfoObject].fIRID.NITC then begin
          sCode := dsGeneralInfo.fITCS[iPair].sCode;
          Break;
        end;
      jsInfoObject.Add('id', infoTypeRecords[iInfoObject].fIRID.RCID);
      if sCode <> '' then
        jsInfoObject.Add('code', s101Catalogue.acronymPairs.GetOurByTheir(sCode));
      jsInfoObject.Add('globalId', sGUID);
      jsAttributes := TlkJSONobject.Create;
//      if GetAttributeValue('guID', infoTypeRecords[iInfoObject].fATTRArray) = '' then
//        jsAttributes.Add('guID', AnsiLowerCase(sGUID));
      AttributesToJSON(sCode, infoTypeRecords[iInfoObject].fATTRArray, jsAttributes);
      jsInfoObject.Add('attributes', jsAttributes);
      jlGeometries := TlkJSONlist.Create;
      jsInfoObject.Add('geometry', jlGeometries);

      // Добавление ссылок на информационные объекты
      jlAssociations := TlkJSONlist.Create;
      InfoAssociationsToJSON(sGUID, sCode, infoTypeRecords[iInfoObject].fINASArray, jlAssociations);
      jsInfoObject.Add('featureAssociations', jlAssociations);

      jl.Add(jsInfoObject);
      jsPatch.Add('O/F/' + sGUID, jl);
    end;

    // Экспорт точек
    WriteLn(tfLog, 'Точки');
    for iPointRec := 0 to Length(pointRecords) - 1 do begin
      CreateGUID(guid);
      sGUID := GUIDToString(guid);
      pointRecords[iPointRec].sGUID := MidStr(sGUID, 2, Length(sGUID) - 2);
      WriteLn(tfLog, Format(#9'RCID=%d, GUID=%s',
          [pointRecords[iPointRec].fPRID.RCID, pointRecords[iPointRec].sGUID]));
    end;
    for iPointRec := 0 to Length(pointRecords) - 1 do begin
      /////////////////////////////////////////////////////////
      // Проверка прерывания процесса пользователем
      suspendEvent.WaitFor($FFFFFFFF);
      if breakEvent.WaitFor(0) = wrSignaled then begin
        if calculationThread <> nil then
          calculationThread.m_nTermStatus := TERM_STATUS_USERSTOP;
        Exit;
      end
      else begin
        progress := TProgress(threadList.LockList[0]);
        progress.m_max := Length(pointRecords);
        progress.m_pos := iPointRec;
        progress.m_Message := 'Экспорт точек в JSON';
        threadList.UnlockList;
      end;
      sGUID := pointRecords[iPointRec].sGUID;
      jl := TlkJSONlist.Create;
      jsPointObject := TlkJSONobject.Create;
      jsPointObject.Add('id', pointRecords[iPointRec].fPRID.RCID);
      case pointRecords[iPointRec].ct of
        ct2I: begin
          x := dsGeneralInfo.fDSSI.DCOX + pointRecords[iPointRec].fC2IT.XCOO /
              dsGeneralInfo.fDSSI.CMFX;
          y := dsGeneralInfo.fDSSI.DCOY + pointRecords[iPointRec].fC2IT.YCOO /
              dsGeneralInfo.fDSSI.CMFY;
        end;
        ct3I: begin
          x := dsGeneralInfo.fDSSI.DCOX + pointRecords[iPointRec].fC3IT.XCOO /
              dsGeneralInfo.fDSSI.CMFX;
          y := dsGeneralInfo.fDSSI.DCOY + pointRecords[iPointRec].fC3IT.YCOO /
              dsGeneralInfo.fDSSI.CMFY;
          z := dsGeneralInfo.fDSSI.DCOZ + pointRecords[iPointRec].fC3IT.ZCOO /
              dsGeneralInfo.fDSSI.CMFZ;
        end;
        ct2F: begin
          x := dsGeneralInfo.fDSSI.DCOX + pointRecords[iPointRec].fC2FT.XCOO;
          y := dsGeneralInfo.fDSSI.DCOY + pointRecords[iPointRec].fC2FT.YCOO;
        end;
        ct3F: begin
          x := dsGeneralInfo.fDSSI.DCOX + pointRecords[iPointRec].fC3FT.XCOO;
          y := dsGeneralInfo.fDSSI.DCOY + pointRecords[iPointRec].fC3FT.YCOO;
          z := dsGeneralInfo.fDSSI.DCOZ + pointRecords[iPointRec].fC3FT.ZCOO;
        end;
      end;
      jsPointObject.Add('lon', x);
      jsPointObject.Add('lat', y);
      if (pointRecords[iPointRec].ct = ct3I) or (pointRecords[iPointRec].ct = ct3F) then begin
        jsPointObject.Add('height', z);
        if pointRecords[iPointRec].ct = ct3I then
          jsPointObject.Add('verticalCrs', pointRecords[iPointRec].fC3IT.VCID)
        else
          jsPointObject.Add('verticalCrs', pointRecords[iPointRec].fC3FT.VCID);
        jsPatch.Add('O/S/P3/' + sGUID, jl);
      end
      else
        jsPatch.Add('O/S/P/' + sGUID, jl);

      jl.Add(jsPointObject);
    end;

    // Экспорт мультиточек
    WriteLn(tfLog, 'Мультиточки');
    for iMultiPointRec := 0 to Length(multiPointRecords) - 1 do begin
      CreateGUID(guid);
      sGUID := GUIDToString(guid);
      multiPointRecords[iMultiPointRec].sGUID := MidStr(sGUID, 2, Length(sGUID) - 2);
      WriteLn(tfLog, Format(#9'RCID=%d, GUID=%s',
          [multiPointRecords[iMultiPointRec].fMRID.RCID, multiPointRecords[iMultiPointRec].sGUID]));
    end;
    for iMultiPointRec := 0 to Length(multiPointRecords) - 1 do begin
      /////////////////////////////////////////////////////////
      // Проверка прерывания процесса пользователем
      suspendEvent.WaitFor($FFFFFFFF);
      if breakEvent.WaitFor(0) = wrSignaled then begin
        if calculationThread <> nil then
          calculationThread.m_nTermStatus := TERM_STATUS_USERSTOP;
        Exit;
      end
      else begin
        progress := TProgress(threadList.LockList[0]);
        progress.m_max := Length(multiPointRecords);
        progress.m_pos := iMultiPointRec;
        progress.m_Message := 'Экспорт мультиточек в JSON';
        threadList.UnlockList;
      end;
      /////////////////////////////////////////////////////////
      sGUID := multiPointRecords[iMultiPointRec].sGUID;
      jl := TlkJSONlist.Create;
      jsMultiPointObject := TlkJSONobject.Create;
      jsMultiPointObject.Add('id', multiPointRecords[iMultiPointRec].fMRID.RCID);
      jlCoords := TlkJSONlist.Create;
      case multiPointRecords[iMultiPointRec].ct of
        ct2I:
          for iMultiPoint := 0 to Length(multiPointRecords[iMultiPointRec].fC2ILArray) - 1 do
            if iMultiPoint = 0 then // Пока обрабатываем только начальный массив, обновления игнорируем
              for iPointInMulti := 0 to Length(multiPointRecords[iMultiPointRec].fC2ILArray[iMultiPoint].C2ITArray) - 1 do
                with multiPointRecords[iMultiPointRec].fC2ILArray[iMultiPoint].C2ITArray[iPointInMulti] do begin
                  x := dsGeneralInfo.fDSSI.DCOX + XCOO / dsGeneralInfo.fDSSI.CMFX;
                  y := dsGeneralInfo.fDSSI.DCOY + YCOO / dsGeneralInfo.fDSSI.CMFY;
                  jsPointObject := TlkJSONobject.Create;
                  jsPointObject.Add('lat', y);
                  jsPointObject.Add('lon', x);
                  jlCoords.Add(jsPointObject);
                end;
        ct3I:
          for iMultiPoint := 0 to Length(multiPointRecords[iMultiPointRec].fC3ILArray) - 1 do begin
            if iMultiPoint = 0 then // Пока обрабатываем только начальный массив, обновления игнорируем
              for iPointInMulti := 0 to Length(multiPointRecords[iMultiPointRec].fC3ILArray[iMultiPoint].C3ITArray) - 1 do
                with multiPointRecords[iMultiPointRec].fC3ILArray[iMultiPoint].C3ITArray[iPointInMulti] do begin
                  x := dsGeneralInfo.fDSSI.DCOX + XCOO / dsGeneralInfo.fDSSI.CMFX;
                  y := dsGeneralInfo.fDSSI.DCOY + YCOO / dsGeneralInfo.fDSSI.CMFY;
                  z := dsGeneralInfo.fDSSI.DCOY + ZCOO / dsGeneralInfo.fDSSI.CMFZ;
                  jsPointObject := TlkJSONobject.Create;
                  jsPointObject.Add('lat', y);
                  jsPointObject.Add('lon', x);
                  jsPointObject.Add('height', z);
                  jlCoords.Add(jsPointObject);
                end;
          end;
        ct2F:
          for iMultiPoint := 0 to Length(multiPointRecords[iMultiPointRec].fC2FLArray) - 1 do
            if iMultiPoint = 0 then // Пока обрабатываем только начальный массив, обновления игнорируем
              for iPointInMulti := 0 to Length(multiPointRecords[iMultiPointRec].fC2FLArray[iMultiPoint].C2FTArray) - 1 do
                with multiPointRecords[iMultiPointRec].fC2FLArray[iMultiPoint].C2FTArray[iPointInMulti] do begin
                  x := dsGeneralInfo.fDSSI.DCOX + XCOO;
                  y := dsGeneralInfo.fDSSI.DCOY + YCOO;
                  jsPointObject := TlkJSONobject.Create;
                  jsPointObject.Add('lat', y);
                  jsPointObject.Add('lon', x);
                  jlCoords.Add(jsPointObject);
                end;
        ct3F:
          for iMultiPoint := 0 to Length(multiPointRecords[iMultiPointRec].fC3FLArray) - 1 do begin
            if iMultiPoint = 0 then // Пока обрабатываем только начальный массив, обновления игнорируем
              for iPointInMulti := 0 to Length(multiPointRecords[iMultiPointRec].fC3FLArray[iMultiPoint].C3FTArray) - 1 do
                with multiPointRecords[iMultiPointRec].fC3FLArray[iMultiPoint].C3FTArray[iPointInMulti] do begin
                  x := dsGeneralInfo.fDSSI.DCOX + XCOO;
                  y := dsGeneralInfo.fDSSI.DCOY + YCOO;
                  z := dsGeneralInfo.fDSSI.DCOY + ZCOO;
                  jsPointObject := TlkJSONobject.Create;
                  jsPointObject.Add('lat', y);
                  jsPointObject.Add('lon', x);
                  jsPointObject.Add('height', z);
                  jlCoords.Add(jsPointObject);
                end;
          end;
      end;
      jsMultiPointObject.Add('coordinates', jlCoords);

      jl.Add(jsMultiPointObject);

      if multiPointRecords[iMultiPointRec].ct = ct3I then begin
        jsMultiPointObject.Add('verticalCrs', multiPointRecords[iMultiPointRec].fC3ILArray[0].VCID);
        jsPatch.Add('O/S/MP3/' + sGUID, jl);
      end
      else if multiPointRecords[iMultiPointRec].ct = ct3F then begin
        jsMultiPointObject.Add('verticalCrs', multiPointRecords[iMultiPointRec].fC3FLArray[0].VCID);
        jsPatch.Add('O/S/MP3/' + sGUID, jl);
      end
      else
        jsPatch.Add('O/S/MP/' + sGUID, jl);
    end;

    // Экспорт кривых
    WriteLn(tfLog, 'Кривые');
    for iCurveRec := 0 to Length(curveRecords) - 1 do begin
      CreateGUID(guid);
      sGUID := GUIDToString(guid);
      curveRecords[iCurveRec].sGUID := MidStr(sGUID, 2, Length(sGUID) - 2);
      WriteLn(tfLog, Format(#9'RCID=%d, GUID=%s',
          [curveRecords[iCurveRec].fCRID.RCID, curveRecords[iCurveRec].sGUID]));
    end;
    for iCurveRec := 0 to Length(curveRecords) - 1 do begin
      jsStartPoint := nil;
      jsEndPoint := nil;
      jsCurveObject := nil;
      if CurveRecordToJSON(curveRecords[iCurveRec], jsStartPoint, jsEndPoint, jsCurveObject) then begin
        /////////////////////////////////////////////////////////
        // Проверка прерывания процесса пользователем
        suspendEvent.WaitFor($FFFFFFFF);
        if breakEvent.WaitFor(0) = wrSignaled then begin
          if calculationThread <> nil then
            calculationThread.m_nTermStatus := TERM_STATUS_USERSTOP;
          Exit;
        end
        else begin
          progress := TProgress(threadList.LockList[0]);
          progress.m_max := Length(curveRecords);
          progress.m_pos := iCurveRec;
          progress.m_Message := 'Экспорт кривых в JSON';
          threadList.UnlockList;
        end;
        /////////////////////////////////////////////////////////
        if jsStartPoint <> nil then begin
          jlStartEndPoint := TlkJSONlist.Create;
          jlStartEndPoint.Add(jsStartPoint);
          jsPatch.Add(jsCurveObject.Field['startPoint'].Value, jlStartEndPoint);
          if jsEndPoint <> nil then begin
            jlStartEndPoint := TlkJSONlist.Create;
            jlStartEndPoint.Add(jsEndPoint);
            jsPatch.Add(jsCurveObject.Field['endPoint'].Value, jlStartEndPoint);
          end;
        end;
        jl := TlkJSONlist.Create;
        jl.Add(jsCurveObject);
        jsPatch.Add('O/S/C/' + curveRecords[iCurveRec].sGUID, jl);
      end;
    end;

    // Экспорт композитных кривых
    WriteLn(tfLog, 'Композитные кривые');
    for iCompositeCurveRec := 0 to Length(compositeCurveRecords) - 1 do begin
      CreateGUID(guid);
      sGUID := GUIDToString(guid);
      compositeCurveRecords[iCompositeCurveRec].sGUID := MidStr(sGUID, 2, Length(sGUID) - 2);
      WriteLn(tfLog, Format(#9'RCID=%d, GUID=%s',
          [compositeCurveRecords[iCompositeCurveRec].fCCID.RCID, compositeCurveRecords[iCompositeCurveRec].sGUID]));
    end;
    if g_convertCCtoC then
      for iCompositeCurveRec := 0 to Length(compositeCurveRecords) - 1 do begin
        /////////////////////////////////////////////////////////
        // Проверка прерывания процесса пользователем
        suspendEvent.WaitFor($FFFFFFFF);
        if breakEvent.WaitFor(0) = wrSignaled then begin
          if calculationThread <> nil then
            calculationThread.m_nTermStatus := TERM_STATUS_USERSTOP;
          Exit;
        end
        else begin
          progress := TProgress(threadList.LockList[0]);
          progress.m_max := Length(compositeCurveRecords);
          progress.m_pos := iCompositeCurveRec;
          progress.m_Message := 'Экспорт композитных кривых в JSON';
          threadList.UnlockList;
        end;
        /////////////////////////////////////////////////////////
        jsStartPoint := nil;
        jsEndPoint := nil;
        jsCurveObject := nil;
        if CompositeCurveRecordToJSON(compositeCurveRecords[iCompositeCurveRec],
            jsStartPoint, jsEndPoint, jsCurveObject, 1) then begin
          jlStartEndPoint := TlkJSONlist.Create;
          jlStartEndPoint.Add(jsStartPoint);
          jsPatch.Add(jsCurveObject.Field['startPoint'].Value, jlStartEndPoint);
          jlStartEndPoint := TlkJSONlist.Create;
          jlStartEndPoint.Add(jsEndPoint);
          jsPatch.Add(jsCurveObject.Field['endPoint'].Value, jlStartEndPoint);
          jl := TlkJSONlist.Create;
          jl.Add(jsCurveObject);
          jsPatch.Add('O/S/C/' + compositeCurveRecords[iCompositeCurveRec].sGUID, jl);
        end;
      end
    else
      for iCompositeCurveRec := 0 to Length(compositeCurveRecords) - 1 do begin
        /////////////////////////////////////////////////////////
        // Проверка прерывания процесса пользователем
        suspendEvent.WaitFor($FFFFFFFF);
        if breakEvent.WaitFor(0) = wrSignaled then begin
          if calculationThread <> nil then
            calculationThread.m_nTermStatus := TERM_STATUS_USERSTOP;
          Exit;
        end
        else begin
          progress := TProgress(threadList.LockList[0]);
          progress.m_max := Length(compositeCurveRecords);
          progress.m_pos := iCompositeCurveRec;
          progress.m_Message := 'Экспорт композитных кривых в JSON';
          threadList.UnlockList;
        end;
        /////////////////////////////////////////////////////////
        jsCompositeCurveObject := TlkJSONobject.Create;
        jsCompositeCurveObject.Add('id', compositeCurveRecords[iCompositeCurveRec].fCCID.RCID);
        jlCurveComponents := TlkJSONlist.Create;
        for iCurveList := 0 to Length(compositeCurveRecords[iCompositeCurveRec].fCUCOArray) - 1 do
          for iCurveComponent := 0 to Length(compositeCurveRecords[iCompositeCurveRec].fCUCOArray[iCurveList].CUCOArray) - 1 do
            with compositeCurveRecords[iCompositeCurveRec].fCUCOArray[iCurveList].CUCOArray[iCurveComponent] do
              if RRNM = Ord(CompositeCurveRecordType) then
                for i := 0 to Length(compositeCurveRecords) - 1 do begin
                  if compositeCurveRecords[i].fCCID.RCID = RRID then begin
                    jsCurveComponentObject := TlkJSONobject.Create;
                    jsCurveComponentObject.Add('orientation', Orientation[ORNT - 1]);
                    jsCurveComponentObject.Add('ref', 'O/S/CC/' + compositeCurveRecords[i].sGUID);
                    jlCurveComponents.Add(jsCurveComponentObject);
                    Break;
                  end;
                end
              else
                for i := 0 to Length(curveRecords) - 1 do begin
                  if curveRecords[i].fCRID.RCID = RRID then begin
                    jsCurveComponentObject := TlkJSONobject.Create;
                    jsCurveComponentObject.Add('orientation', Orientation[ORNT - 1]);
                    jsCurveComponentObject.Add('ref', 'O/S/C/' + curveRecords[i].sGUID);
                    jlCurveComponents.Add(jsCurveComponentObject);
                    Break;
                  end;
                end;
        jsCompositeCurveObject.Add('components', jlCurveComponents);
        jl := TlkJSONlist.Create;
        jl.Add(jsCompositeCurveObject);
        jsPatch.Add('O/S/CC/' + compositeCurveRecords[iCompositeCurveRec].sGUID, jl);
      end;

    // Экспорт поверхностей
    WriteLn(tfLog, 'Поверхности');
    for iSurfaceRec := 0 to Length(surfaceRecords) - 1 do begin
      CreateGUID(guid);
      sGUID := GUIDToString(guid);
      surfaceRecords[iSurfaceRec].sGUID := MidStr(sGUID, 2, Length(sGUID) - 2);
      WriteLn(tfLog, Format(#9'RCID=%d, GUID=%s',
          [surfaceRecords[iSurfaceRec].fSRID.RCID, surfaceRecords[iSurfaceRec].sGUID]));
    end;
    for iSurfaceRec := 0 to Length(surfaceRecords) - 1 do begin
      /////////////////////////////////////////////////////////
      // Проверка прерывания процесса пользователем
      suspendEvent.WaitFor($FFFFFFFF);
      if breakEvent.WaitFor(0) = wrSignaled then begin
        if calculationThread <> nil then
          calculationThread.m_nTermStatus := TERM_STATUS_USERSTOP;
        Exit;
      end
      else begin
        progress := TProgress(threadList.LockList[0]);
        progress.m_max := Length(surfaceRecords);
        progress.m_pos := iSurfaceRec;
        progress.m_Message := 'Экспорт поверхностей в JSON';
        threadList.UnlockList;
      end;
      /////////////////////////////////////////////////////////
      jsSurfaceObject := TlkJSONobject.Create;
      jsSurfaceObject.Add('id', surfaceRecords[iSurfaceRec].fSRID.RCID);
      jlSurfaceRings := TlkJSONlist.Create;
      for iRIASFieldNo := 0 to Length(surfaceRecords[iSurfaceRec].fRIASArray) - 1 do
        for iRingNo := 0 to Length(surfaceRecords[iSurfaceRec].fRIASArray[iRIASFieldNo].RIASArray) - 1 do
          with surfaceRecords[iSurfaceRec].fRIASArray[iRIASFieldNo].RIASArray[iRingNo] do
            case TRecordTypeCode(RRNM) of
              CurveRecordType:
                for iCurveRec := 0 to Length(curveRecords) - 1 do
                  if curveRecords[iCurveRec].fCRID.RCID = RRID then begin
                    jsRing := TlkJSONobject.Create;
                    jsRing.Add('exteriorInterior', ExteriorInterior[USAG - 1]);
                    jsRing.Add('orientation', Orientation[ORNT - 1]);
                    jsRing.Add('ref', 'O/S/C/' + curveRecords[iCurveRec].sGUID);
                    jlSurfaceRings.Add(jsRing);
  //                  CheckAndCloseRing(curveRecords[iCurveRec].sGUID, jsPatch, CLOSE_RING);
                    Break;
                  end;
              CompositeCurveRecordType:
                for iCompositeCurveRec := 0 to Length(compositeCurveRecords) - 1 do
                  if compositeCurveRecords[iCompositeCurveRec].fCCID.RCID = RRID then begin
                    jsRing := TlkJSONobject.Create;
                    jsRing.Add('exteriorInterior', ExteriorInterior[USAG - 1]);
                    jsRing.Add('orientation', Orientation[ORNT - 1]);
                    if g_convertCCtoC then begin
                      jsRing.Add('ref', 'O/S/C/' + compositeCurveRecords[iCompositeCurveRec].sGUID);
  //                    CheckAndCloseRing(compositeCurveRecords[iCompositeCurveRec].sGUID,
  //                        jsPatch, CLOSE_RING);
                    end
                    else
                      jsRing.Add('ref', 'O/S/CC/' + compositeCurveRecords[iCompositeCurveRec].sGUID);
                    jlSurfaceRings.Add(jsRing);
                    Break;
                  end;
            end;
      jsSurfaceObject.Add('rings', jlSurfaceRings);

      jl := TlkJSONlist.Create;
      jl.Add(jsSurfaceObject);
      jsPatch.Add('O/S/S/' + surfaceRecords[iSurfaceRec].sGUID, jl);
    end;

    // Экспорт пространственных объектов (feature)
    WriteLn(tfLog, 'Геообъекты');
    for iFeature := 0 to Length(featureRecords) - 1 do begin
      sGUID := AnsiUpperCase(GetAttributeValue('guID', featureRecords[iFeature].fATTRArray));
      if sGUID = '' then begin
        CreateGUID(guid);
        sGUID := GUIDToString(guid);
        sGUID := MidStr(sGUID, 2, Length(sGUID) - 2);
      end;
      featureRecords[iFeature].m_sGUID := sGUID;
      WriteLn(tfLog, Format(#9'RCID=%d, GUID=%s',
          [featureRecords[iFeature].fFRID.RCID, featureRecords[iFeature].m_sGUID]));
      Flush(tfLog);
    end;
    for iFeature := 0 to Length(featureRecords) - 1 do begin
      /////////////////////////////////////////////////////////
      // Проверка прерывания процесса пользователем
      suspendEvent.WaitFor($FFFFFFFF);
      if breakEvent.WaitFor(0) = wrSignaled then begin
        if calculationThread <> nil then
          calculationThread.m_nTermStatus := TERM_STATUS_USERSTOP;
        Exit;
      end
      else begin
        progress := TProgress(threadList.LockList[0]);
        progress.m_max := Length(featureRecords);
        progress.m_pos := iFeature;
        progress.m_Message := 'Экспорт геообъектов в JSON';
        threadList.UnlockList;
      end;
      /////////////////////////////////////////////////////////
      sGUID := featureRecords[iFeature].m_sGUID;
      jl := TlkJSONlist.Create;
      jsFeature := TlkJSONobject.Create;
      jsFeature.Add('id', featureRecords[iFeature].fFRID.RCID);
      sCode := '';
      for iPair := 0 to Length(dsGeneralInfo.fFTCS) - 1 do
        if dsGeneralInfo.fFTCS[iPair].iCode = featureRecords[iFeature].fFRID.NFTC then begin
          sCode := dsGeneralInfo.fFTCS[iPair].sCode;
          Break;
        end;
      if sCode <> '' then
        jsFeature.Add('code', s101Catalogue.acronymPairs.GetOurByTheir(sCode));
      jsFeature.Add('globalId', sGUID);
      jsAttributes := TlkJSONobject.Create;
//      if GetAttributeValue('guID', featureRecords[iFeature].fATTRArray) = '' then
//        jsAttributes.Add('guID', AnsiLowerCase(sGUID));
      if featureRecords[iFeature].fFRID.RCID = 1741 then
        bStop := True;
      AttributesToJSON(sCode, featureRecords[iFeature].fATTRArray, jsAttributes);
      jsFeature.Add('attributes', jsAttributes);

{
      // Добавление комплексного атрибута locID
      jlComplexAttribute := TlkJSONlist.Create;
      jsComplexAttribute := TlkJSONobject.Create;
      jsComplexAttribute.Add('valID', featureRecords[iFeature].fFRID.RCID);
      jsComplexAttribute.Add('mapNam', dsGeneralInfo.fDSID.DSNM);
      jlComplexAttribute.Add(jsComplexAttribute);
      jsAttributes.Add('locID', jlComplexAttribute);
}

      // Добавление ссылок на геометрические примитивы
      jlGeometries := TlkJSONlist.Create;
      jsFeature.Add('geometry', jlGeometries);
      for iSPASFieldNo := 0 to Length(featureRecords[iFeature].fSPASArray) - 1 do
        for iSPASElemNo := 0 to Length(featureRecords[iFeature].fSPASArray[iSPASFieldNo].SPASArray) - 1 do
          with featureRecords[iFeature].fSPASArray[iSPASFieldNo].SPASArray[iSPASElemNo] do begin
            case TRecordTypeCode(RRNM) of
              PointRecordType:
                for iPointRec := 0 to Length(pointRecords) - 1 do
                  if pointRecords[iPointRec].fPRID.RCID = RRID then begin
                    jsGeometry := TlkJSONobject.Create;
                    jsScaleRange := TlkJSONobject.Create;
                    jsScaleRange.Add('lower', SMIN);
                    jsScaleRange.Add('upper', SMAX);
                    jsGeometry.Add('scaleRange', jsScaleRange);
                    if (pointRecords[iPointRec].ct = ct3I) or (pointRecords[iPointRec].ct = ct3F) then
                      jsGeometry.Add('ref', 'O/S/P3/' + pointRecords[iPointRec].sGUID)
                    else
                      jsGeometry.Add('ref', 'O/S/P/' + pointRecords[iPointRec].sGUID);
                    jlGeometries.Add(jsGeometry);
                    Break;
                  end;
              MultiPointRecordType:
                for iMultiPointRec := 0 to Length(multiPointRecords) - 1 do
                  if multiPointRecords[iMultiPointRec].fMRID.RCID = RRID then begin
                    jsGeometry := TlkJSONobject.Create;
                    if ORNT <> 255 then
                      jsGeometry.Add('orientation', Orientation[ORNT - 1]);
                    jsScaleRange := TlkJSONobject.Create;
                    jsScaleRange.Add('lower', SMIN);
                    jsScaleRange.Add('upper', SMAX);
                    jsGeometry.Add('scaleRange', jsScaleRange);
                    if (multiPointRecords[iMultiPointRec].ct = ct3I) or (multiPointRecords[iMultiPointRec].ct = ct3F) then
                      jsGeometry.Add('ref', 'O/S/MP3/' + multiPointRecords[iMultiPointRec].sGUID)
                    else
                      jsGeometry.Add('ref', 'O/S/MP/' + multiPointRecords[iMultiPointRec].sGUID);
                    jlGeometries.Add(jsGeometry);
                    Break;
                  end;
              CurveRecordType:
                for iCurveRec := 0 to Length(curveRecords) - 1 do
                  if curveRecords[iCurveRec].fCRID.RCID = RRID then begin
                    jsGeometry := TlkJSONobject.Create;
                    if ORNT <> 255 then
                      jsGeometry.Add('orientation', Orientation[ORNT - 1]);
                    jsScaleRange := TlkJSONobject.Create;
                    jsScaleRange.Add('lower', SMIN);
                    jsScaleRange.Add('upper', SMAX);
                    jsGeometry.Add('scaleRange', jsScaleRange);
                    jsGeometry.Add('ref', 'O/S/C/' + curveRecords[iCurveRec].sGUID);
                    jlGeometries.Add(jsGeometry);
                    Break;
                  end;
              CompositeCurveRecordType:
                for iCompositeCurveRec := 0 to Length(compositeCurveRecords) - 1 do
                  if compositeCurveRecords[iCompositeCurveRec].fCCID.RCID = RRID then begin
                    jsGeometry := TlkJSONobject.Create;
                    if ORNT <> 255 then
                      jsGeometry.Add('orientation', Orientation[ORNT - 1]);
                    jsScaleRange := TlkJSONobject.Create;
                    jsScaleRange.Add('lower', SMIN);
                    jsScaleRange.Add('upper', SMAX);
                    jsGeometry.Add('scaleRange', jsScaleRange);
                    if g_convertCCtoC then
                      jsGeometry.Add('ref', 'O/S/C/' + compositeCurveRecords[iCompositeCurveRec].sGUID)
                    else
                      jsGeometry.Add('ref', 'O/S/CC/' + compositeCurveRecords[iCompositeCurveRec].sGUID);
                    jlGeometries.Add(jsGeometry);
                    Break;
                  end;
              SurfaceRecordType:
                for iSurfaceRec := 0 to Length(surfaceRecords) - 1 do
                  if surfaceRecords[iSurfaceRec].fSRID.RCID = RRID then begin
                    jsGeometry := TlkJSONobject.Create;
                    if ORNT <> 255 then
                      jsGeometry.Add('orientation', Orientation[ORNT - 1]);
                    jsScaleRange := TlkJSONobject.Create;
                    jsScaleRange.Add('lower', SMIN);
                    jsScaleRange.Add('upper', SMAX);
                    jsGeometry.Add('scaleRange', jsScaleRange);
                    jsGeometry.Add('ref', 'O/S/S/' + surfaceRecords[iSurfaceRec].sGUID);
                    jlGeometries.Add(jsGeometry);
                    Break;
                  end;
            end;
          end;

      // Добавление ссылок на информационные и пространственные объекты
      jlAssociations := TlkJSONlist.Create;
      InfoAssociationsToJSON(sGUID, sCode, featureRecords[iFeature].fINASArray, jlAssociations);
      FeatureAssociationsToJSON(sGUID, sCode, featureRecords[iFeature].fFASCArray, jlAssociations);
      references.Sort(CompareReferences);
      jsFeature.Add('featureAssociations', jlAssociations);

      jl.Add(jsFeature);
      jsPatch.Add('O/F/' + sGUID, jl);
    end;

    // Преобразование мультиточечных объектов SOUNDG в точечные
    slIdentsToDelete := TStringList.Create;
    slReferencedIdents := TStringList.Create;

    if g_convertSoundgMP3toP then begin
      for i := 0 to jsPatch.Count - 1 do begin
        sIdent := jsPatch.NameOf[i];
        if AnsiContainsStr(sIdent, 'O/F/') then begin
          /////////////////////////////////////////////////////////
          // Проверка прерывания процесса пользователем
          suspendEvent.WaitFor($FFFFFFFF);
          if breakEvent.WaitFor(0) = wrSignaled then begin
            if calculationThread <> nil then
              calculationThread.m_nTermStatus := TERM_STATUS_USERSTOP;
            Exit;
          end
          else begin
            progress := TProgress(threadList.LockList[0]);
            progress.m_max := jsPatch.Count;
            progress.m_pos := i;
            progress.m_Message := 'Преобразование мультиточечных объектов SOUNDG в точечные';
            threadList.UnlockList;
          end;
          /////////////////////////////////////////////////////////
          jsFeature := (jsPatch.Field[sIdent] as TlkJSONlist).Child[0] as TlkJSONobject;
          if (jsFeature.Field['code'] <> nil) and (jsFeature.Field['code'].Value = 'SOUNDG') then begin
            jlGeometries := jsFeature.Field['geometry'] as TlkJSONlist;
            if jlGeometries.Count = 1 then begin
              jsGeometry := jlGeometries.Child[0] as TlkJSONobject;
              sMP3Ident := jsGeometry.Field['ref'].Value;
              if AnsiContainsStr(sMP3Ident, 'O/S/MP3/') then begin
                jsMultiPointObject := (jsPatch.Field[sMP3Ident] as TlkJSONlist).Child[0] as TlkJSONobject;
                jlCoords := jsMultiPointObject.Field['coordinates'] as TlkJSONlist;
                jsToAddPatch := TlkJSONobject.Create;
                for iPointInMulti := 0 to jlCoords.Count - 1 do begin
                  jsPointObject := jlCoords.Child[iPointInMulti] as TlkJSONobject;
                  CreateGUID(guid);
                  sGUID := GUIDToString(guid);
                  sGUID := MidStr(sGUID, 2, Length(sGUID) - 2);
                  jl := TlkJSONlist.Create;
                  jsCopyPoint := TlkJSONobject.Create;
                  jsCopyPoint.Add('lat', Double(jsPointObject.Field['lat'].Value));
                  jsCopyPoint.Add('lon', Double(jsPointObject.Field['lon'].Value));
                  jl.Add(jsCopyPoint);
                  jsToAddPatch.Add('O/S/P/' + sGUID, jl);
                  jsCopyFeature := CreateCopyJS(jsFeature) as TlkJSONobject;
                  jsAttributes := jsCopyFeature.Field['attributes'] as TlkJSONobject;
                  jl := TlkJSONlist.Create;
                  jsComplexAttribute := TlkJSONobject.Create;
                  jl.Add(jsComplexAttribute);
                  jsComplexAttribute.Add('VALSOU', Double(jsPointObject.Field['height'].Value));
                  jsAttributes.Add('VALSOU_', jl);
                  jlGeometries := jsCopyFeature.Field['geometry'] as TlkJSONlist;
                  jsGeometry := jlGeometries.Child[0] as TlkJSONobject;
                  jsGeometry.Field['ref'].Value := 'O/S/P/' + sGUID;
                  CreateGUID(guid);
                  sGUID := GUIDToString(guid);
                  sGUID := MidStr(sGUID, 2, Length(sGUID) - 2);
                  jl := TlkJSONlist.Create;
                  jl.Add(jsCopyFeature);
                  jsToAddPatch.Add('O/F/' + sGUID, jl);
                end;
                jlAssociations := jsFeature.Field['featureAssociations'] as TlkJSONlist;
                for j := 0 to jlAssociations.Count - 1 do begin
                  jsAssociation := jlAssociations.Child[j] as TlkJSONobject;
                  sDestIdent := jsAssociation.Field['ref'].Value;
                  jl := jsPatch.Field[sDestIdent] as TlkJSONlist;
                  jsDestFeature := jl.Child[0] as TlkJSONobject;
                  index := references.GetIndexByKey(AnsiReplaceStr(sIdent, 'O/F/', '') + '_' +
                      AnsiReplaceStr(sDestIdent, 'O/F/', ''));
                  reference := references[index] as TReference;
                  for k := 0 to jsToAddPatch.Count - 1 do
                    if Odd(k) then
                      references.Add(TReference.Create(AnsiReplaceStr(jsToAddPatch.NameOf[k], 'O/F/', ''),
                          AnsiReplaceStr(sDestIdent, 'O/F/', ''), TRoleTypeOfBinding.Create(reference.m_Binding)));
                  references.Delete(index);
                  references.Sort(CompareReferences);
                end;
                slIdentsToDelete.Add(sIdent);
                slIdentsToDelete.Add(sMP3Ident);
                for j := 0 to jsToAddPatch.Count - 1 do begin
                  sIdent := jsToAddPatch.NameOf[j];
                  jsPatch.Add(sIdent, CreateCopyJS(jsToAddPatch.Field[sIdent]));
                end;
                jsToAddPatch.Free;
                jsToAddPatch := nil;
              end;
            end;
          end;
        end;
      end;
    end;

    // Формирование списков кривых, на которые есть ссылки, и конечных точек кривых,
    // на которые ссылок нет
    /////////////////////////////////////////////////////////
    // Проверка прерывания процесса пользователем
    suspendEvent.WaitFor($FFFFFFFF);
    if breakEvent.WaitFor(0) = wrSignaled then begin
      if calculationThread <> nil then
        calculationThread.m_nTermStatus := TERM_STATUS_USERSTOP;
      Exit;
    end
    else begin
      progress := TProgress(threadList.LockList[0]);
      progress.m_max := 0;
      progress.m_pos := 0;
      progress.m_Message := 'Удаление лишних JSON-объектов';
      threadList.UnlockList;
    end;
    /////////////////////////////////////////////////////////
    if g_convertCCtoC then begin
      for iSurfaceRec := 0 to Length(surfaceRecords) - 1 do begin
        jsSurfaceObject := (jsPatch.Field['O/S/S/' + surfaceRecords[iSurfaceRec].sGUID]
            as TlkJSONlist).Child[0] as TlkJSONobject;
        jlSurfaceRings := jsSurfaceObject.Field['rings'] as TlkJSONlist;
        for iRingNo := 0 to jlSurfaceRings.Count - 1 do begin
          sIdent := (jlSurfaceRings.Child[iRingNo] as TlkJSONobject).Field['ref'].Value;
          slReferencedIdents.Add(sIdent);
        end;
      end;
      for iFeature := 0 to Length(featureRecords) - 1 do begin
        jsFeature := (jsPatch.Field['O/F/' + featureRecords[iFeature].m_sGUID]
            as TlkJSONlist).Child[0] as TlkJSONobject;
        jlGeometries := jsFeature.Field['geometry'] as TlkJSONlist;
        for iReference := 0 to jlGeometries.Count - 1 do begin
          sIdent := (jlGeometries.Child[iReference] as TlkJSONobject).Field['ref'].Value;
          if AnsiContainsStr(sIdent, 'O/S/C/') then
            slReferencedIdents.Add(sIdent);
        end;
      end;
      slReferencedIdents.Sort;
// Нельзя удалять концевые точки только потому, что на них ссылаются неиспользуемые кривые 
{
      for i := 0  to jsPatch.Count - 1 do begin
        sIdent := jsPatch.NameOf[i];
        if AnsiContainsStr(sIdent, 'O/S/C/') and (slReferencedIdents.IndexOf(sIdent) < 0) then begin
          jsCurveObject := (jsPatch.Field[sIdent] as TlkJSONlist).Child[0] as TlkJSONobject;
          slIdentsToDelete.Add(string(jsCurveObject.Field['startPoint'].Value));
          slIdentsToDelete.Add(string(jsCurveObject.Field['endPoint'].Value));
        end;
      end;
}
    end;
    slIdentsToDelete.Sort;

    // Копирование элементов в выходной массив с исключением лишних элементов
    jsCopy := TlkJSONobject.Create;
    jsCopy.Add('branch', string(js.Field['branch'].Value));
    jsCopy.Add('message', string(js.Field['message'].Value));
    jsPatchCopy := TlkJSONobject.Create;
    jsCopy.Add('patch', jsPatchCopy);
    for i := 0 to jsPatch.Count - 1 do begin
      sIdent := jsPatch.NameOf[i];
      bAdd := False;
      if AnsiContainsStr(sIdent, 'O/S/C/') then begin
        if g_convertCCtoC then begin
          if slReferencedIdents.IndexOf(sIdent) >= 0 then
            bAdd := True;
        end
        else
          bAdd := True;
      end
      else if slIdentsToDelete.IndexOf(sIdent) < 0 then
        bAdd := True;
      if bAdd then
        jsPatchCopy.Add(sIdent, CreateCopyJS(jsPatch.Field[sIdent]));
    end;

    js.Free;
    js := jsCopy;

    // Добавление обратных ссылок
    jsPatch := js.Field['patch'] as TlkJSONobject;
    for iReference := 0 to references.Count - 1 do begin
      /////////////////////////////////////////////////////////
      // Проверка прерывания процесса пользователем
      suspendEvent.WaitFor($FFFFFFFF);
      if breakEvent.WaitFor(0) = wrSignaled then begin
        if calculationThread <> nil then
          calculationThread.m_nTermStatus := TERM_STATUS_USERSTOP;
        Exit;
      end
      else begin
        progress := TProgress(threadList.LockList[0]);
        progress.m_max := references.Count;
        progress.m_pos := iReference;
        progress.m_Message := 'Добавление обратных ссылок';
        threadList.UnlockList;
      end;
      /////////////////////////////////////////////////////////
      reference := references[iReference] as TReference;
      jl := jsPatch.Field['O/F/' + reference.m_sTargetGUID] as TlkJSONlist;
      jsFeature := jl.Child[0] as TlkJSONobject;
      jlAssociations := jsFeature.Field['featureAssociations'] as TlkJSONlist;
      jsAssociation := TlkJSONobject.Create;
      jsAssociation.Add('rref', 'O/F/' + reference.m_sSourceGUID);
      if reference.m_Binding <> nil then begin
        jsAssociation.Add('associationCode', reference.m_Binding.m_sSource + '@' + reference.m_Binding.m_sRole);
        jsAssociation.Add('roleCode', AssociationTypes[reference.m_Binding.m_iRoleType]);
      end;
      jlAssociations.Add(jsAssociation);
    end;
{
    // Проверка замкнутости колец поверхностей
    if g_convertCCtoC then begin
      keyIValueCurveList := TKeyIValueList.Create;
      for iCurveRec := 0 to Length(curveRecords) - 1 do
        keyIValueCurveList.Add(TKeyIValue.Create('O/S/C/' + curveRecords[iCurveRec].sGUID,
            iCurveRec));
      keyIValueCurveList.SortByKey;
      keyIValueCompositeCurveList := TKeyIValueList.Create;
      for iCompositeCurveRec := 0 to Length(compositeCurveRecords) - 1 do
        keyIValueCompositeCurveList.Add(TKeyIValue.Create(
            'O/S/C/' + compositeCurveRecords[iCompositeCurveRec].sGUID, iCompositeCurveRec));
      keyIValueCompositeCurveList.SortByKey;
      for iSurfaceRec := 0 to Length(surfaceRecords) - 1 do begin
        sIdent := 'O/S/S/' + surfaceRecords[iSurfaceRec].sGUID;
        jsSurfaceObject := (jsPatch.Field[sIdent] as TlkJSONlist).Child[0] as TlkJSONobject;
        jlSurfaceRings := jsSurfaceObject.Field['rings'] as TlkJSONlist;
        if jlSurfaceRings <> nil then
          for iRingNo := 0 to jlSurfaceRings.Count - 1 do begin
            jsRing := jlSurfaceRings.Child[iRingNo] as TlkJSONobject;
            sIdent := jsRing.Field['ref'].Value;
            jsCurveObject := (jsPatch.Field[sIdent] as TlkJSONlist).Child[0] as TlkJSONobject;
            sIdent := jsCurveObject.Field['startPoint'].Value;
            jsStartPoint := (jsPatch.Field[sIdent] as TlkJSONlist).Child[0] as TlkJSONobject;
            sIdent := jsCurveObject.Field['endPoint'].Value;
            jsEndPoint := (jsPatch.Field[sIdent] as TlkJSONlist).Child[0] as TlkJSONobject;
            if (jsStartPoint.Field['lon'].Value <> jsEndPoint.Field['lon'].Value) or
                (jsStartPoint.Field['lat'].Value <> jsEndPoint.Field['lat'].Value) then begin
              sIdent := jsRing.Field['ref'].Value;
              iValue := keyIValueCurveList.GetIValueByKey(sIdent);
              if iValue <> -1 then
                WriteLn(tfDebugLog, Format('Кривая %s, %d', [sIdent, iValue]));
              iValue := keyIValueCompositeCurveList.GetIValueByKey(sIdent);
              if iValue <> -1 then
                WriteLn(tfDebugLog, Format('Композитная кривая %s, %d', [sIdent, iValue]));
              Flush(tfDebugLog);
            end;
          end;
      end;
    end;
}
    /////////////////////////////////////////////////////////
    // Проверка прерывания процесса пользователем
    suspendEvent.WaitFor($FFFFFFFF);
    if breakEvent.WaitFor(0) = wrSignaled then begin
      if calculationThread <> nil then
        calculationThread.m_nTermStatus := TERM_STATUS_USERSTOP;
      Exit;
    end
    else begin
      progress := TProgress(threadList.LockList[0]);
      progress.m_max := 0;
      progress.m_pos := 0;
      progress.m_Message := 'Формирование JSON-файла';
      threadList.UnlockList;
    end;
    /////////////////////////////////////////////////////////

    i := 0;
    sContent := GenerateReadableText(js, i);

    tempFile := ExtractFilePath(fileName) + 'temp.json';
    fs := TFileStream.Create(tempFile, fmCreate);
    fs.Write(PChar(sContent)^, Length(sContent));
    fs.Size := fs.Position;
    fs.Free;

    /////////////////////////////////////////////////////////
    // Проверка прерывания процесса пользователем
    suspendEvent.WaitFor($FFFFFFFF);
    if breakEvent.WaitFor(0) = wrSignaled then begin
      if calculationThread <> nil then
        calculationThread.m_nTermStatus := TERM_STATUS_USERSTOP;
      Exit;
    end;
    
    // Заменим "\/" на "/"
    AssignFile(tf1, tempFile);
    Reset(tf1);
    AssignFile(tf2, fileName);
    Rewrite(tf2);
    while not Eof(tf1) do begin
      ReadLn(tf1, sLine);
      sLine := StringReplace(sLine, '\/', '/', [rfReplaceAll]);
      WriteLn(tf2, sLine);
    end;
    CloseFile(tf1);
    CloseFile(tf2);
    DeleteFile(PChar(tempFile));
    Result := True;
  finally
    slIdentsToDelete.Free;
    slReferencedIdents.Free;
    js.Free;
    Close(tfLog);
  end;
end;

function TS101DataSetJSON.SoundingToMultiPoints(jsPatch: TlkJSONobject): Boolean;
var
  iFeature, iSounding, iPoint, iPointInMulti, iMultiPoint, index: Integer;
  soundingFeatures: array of TFeatureRec;
  soundingMultiPoints: array of TMultiPointRec;
  guid: TGUID;
  jsObject, jsAttributes: TlkJSONobject;
  jlComplexAttribute: TlkJSONlist;
  sID: string;
  slPointsToDelete, slFeaturesToDelete: TStringList;
  tempPointRecords: array of TPointRec;
  tempFeatureRecords: array of TFeatureRec;
begin
  Result := False;
  soundingFeatures := nil;
  soundingMultiPoints := nil;
  tempPointRecords := nil;
  tempFeatureRecords := nil;
  slPointsToDelete := TStringList.Create;
  slFeaturesToDelete := TStringList.Create;
  try
    for iFeature := 0 to Length(featureRecords) - 1 do begin
      if not (featureRecords[iFeature].m_sCode = 'SOUNDG') then Continue;
      for iPoint := 0 to Length(pointRecords) - 1 do
        if pointRecords[iPoint].fPRID.RCID =
            featureRecords[iFeature].fSPASArray[0].SPASArray[0].RRID then Break;
      if iPoint = Length(pointRecords) then Exit;
      DeleteAttribute('guID', featureRecords[iFeature].fATTRArray);
      for iSounding := 0 to Length(soundingFeatures) - 1 do
        if IsEqual(featureRecords[iFeature].fATTRArray, soundingFeatures[iSounding].fATTRArray) then Break;
      if iSounding = Length(soundingFeatures) then begin
        SetLength(soundingFeatures, iSounding + 1);
        S101Copy(featureRecords[iFeature], soundingFeatures[iSounding]);
        SetLength(soundingMultiPoints, iSounding + 1);
        with soundingMultiPoints[iSounding] do begin
          ct := ct3I;
          fMRID.RCNM := Ord(MultiPointRecordType);
          fMRID.RCID := pointRecords[iPoint].fPRID.RCID;
          fMRID.RVER := 1;
          fMRID.RUIN := 1;
          S101Copy(TINASFieldArray(pointRecords[iPoint].fINASArray),
              TINASFieldArray(fINASArray));
          pfCOCC := nil;
          SetLength(fC3ILArray, 1);
          CreateGUID(guid);
          sGUID := GUIDToString(guid);
          sGUID := MidStr(sGUID, 2, Length(sGUID) - 2);
        end;
      end;
      with soundingMultiPoints[iSounding].fC3ILArray[0] do begin
        VCID := 2; // Соответствует системе координат с высотной составляющей "lowest astronomical tide"
        iPointInMulti := Length(C3ITArray);
        SetLength(C3ITArray, iPointInMulti + 1);
        C3ITArray[iPointInMulti].XCOO := pointRecords[iPoint].fC2IT.XCOO;
        C3ITArray[iPointInMulti].YCOO := pointRecords[iPoint].fC2IT.YCOO;
        sID := 'O/F/' + featureRecords[iFeature].m_sGUID;
        try
          jsObject := (jsPatch.Field[sID] as TlkJSONlist).Child[0] as TlkJSONobject;
          jsAttributes := jsObject.Field['attributes'] as TlkJSONobject;
          jlComplexAttribute := jsAttributes.Field['VALSOU_'] as TlkJSONlist;
          if jlComplexAttribute <> nil then
            C3ITArray[iPointInMulti].ZCOO := ((jlComplexAttribute.Child[0] as TlkJSONobject).Field['VALSOU'].Value -
                dsGeneralInfo.fDSSI.DCOZ) * dsGeneralInfo.fDSSI.CMFZ;
        except
           on E: Exception do begin
            MessageDlg(E.Message, mtError, [mbOK], 0);
            Exit;
           end;
        end;
      end;
      slPointsToDelete.Add(pointRecords[iPoint].sGUID);
      slFeaturesToDelete.Add(featureRecords[iFeature].m_sGUID);
    end;
    slPointsToDelete.Sort;
    slFeaturesToDelete.Sort;
    SetLength(tempPointRecords, Length(pointRecords));
    for iPoint := 0 to Length(pointRecords) - 1 do begin
      S101Copy(pointRecords[iPoint], tempPointRecords[iPoint]);
      ClearRec(pointRecords[iPoint]);
    end;
    index := 0;
    for iPoint := 0 to Length(tempPointRecords) - 1 do begin
      if slPointsToDelete.IndexOf(tempPointRecords[iPoint].sGUID) < 0 then begin
        S101Copy(tempPointRecords[iPoint], pointRecords[index]);
        index := index + 1;
      end;
      ClearRec(tempPointRecords[iPoint]);
    end;
    SetLength(pointRecords, index);
    SetLength(tempPointRecords, 0);
    SetLength(tempFeatureRecords, Length(featureRecords));
    for iFeature := 0 to Length(featureRecords) - 1 do begin
      S101Copy(featureRecords[iFeature], tempFeatureRecords[iFeature]);
      ClearRec(featureRecords[iFeature]);
    end;
    index := 0;
    for iFeature := 0 to Length(tempFeatureRecords) - 1 do begin
      if slFeaturesToDelete.IndexOf(tempFeatureRecords[iFeature].m_sGUID) < 0 then begin
        S101Copy(tempFeatureRecords[iFeature], featureRecords[index]);
        index := index + 1;
      end;
      ClearRec(tempFeatureRecords[iFeature]);
    end;
    SetLength(featureRecords, index);
    SetLength(tempFeatureRecords, 0);
    for iSounding := 0 to Length(soundingFeatures) - 1 do begin
      soundingFeatures[iSounding].fSPASArray[0].SPASArray[0].RRNM := Ord(MultiPointRecordType);
      iFeature := Length(featureRecords);
      SetLength(featureRecords, iFeature + 1);
      S101Copy(soundingFeatures[iSounding], featureRecords[iFeature]);
      ClearRec(soundingFeatures[iSounding]);
    end;
    SetLength(soundingFeatures, 0);
    soundingFeatures := nil;
    for iSounding := 0 to Length(soundingMultiPoints) - 1 do begin
      iMultiPoint := Length(multiPointRecords);
      SetLength(multiPointRecords, iMultiPoint + 1);
      S101Copy(soundingMultiPoints[iSounding], multiPointRecords[iMultiPoint]);
      ClearRec(soundingMultiPoints[iSounding]);
    end;
    SetLength(soundingMultiPoints, 0);
    soundingMultiPoints := nil;
    Result := True;
  finally
    slPointsToDelete.Free;
    slFeaturesToDelete.Free;
    for iSounding := 0 to Length(soundingFeatures) - 1 do
      ClearRec(soundingFeatures[iSounding]);
    SetLength(soundingFeatures, 0);
    for iSounding := 0 to Length(soundingMultiPoints) - 1 do
      ClearRec(soundingMultiPoints[iSounding]);
    SetLength(soundingMultiPoints, 0);
  end;
end;

function TS101DataSetJSON.ReadS101JSON(fileName, logName: string; var sError: string): Boolean;
var
  fs: TFileStream;
  size, arrayLen: Integer;
  buffer: array of Char;
  jsS101, jsPatch, jsObject, jsCoordinate, jsInternalPoint, jsComponent, jsRing, jsLocID: TlkJSONobject;
  jsPoint, jsStartPoint, jsEndPoint, jsGeometry, jsScaleRange, jsAttributes, jsAttribute: TlkJSONobject;
  iStartPoint, iEndPoint: Integer;
  jlObject, jlCoordinates, jlInternalPoints, jlComponents, jlRings: TlkJSONlist;
  jlAssociations, jlGeometry, jlComplexAttribute, jlLocID: TlkJSONlist;
  iObject, iCoord, i, ii, iRCID, iRCIDmax, iPos: Integer;
  sID, sCode, sCodeTheir, sInterpolationType, sOrientation, sExteriorInterior, s: string;
  iCurInfoRecord, iCurPointRecord, iCurMultiPointRecord, iCurCurveRecord,
      iCurCompositeCurveRecord, iCurCompositeCurveRecord2, iCurSurfaceRecord, iCurFeatureRecord: Integer;
  iCurITCIndex: Integer;
  item: TItem;
  namedItem: TNamedItem;
  featureItem: TFeatureItem;
  b3D, bSame, bComposite: Boolean;
  keyIValuePointList, keyIValueMultiPointList, keyIValueCurveList,
      keyIValueCompositeCurveList, keyIValueSurfaceList: TKeyIValueList;
  s101IniFile: TS101IniFile;
  sGUID: string;
  tempPointRecords: array of TPointRec;
  depth: Double;
  guid: TGUID;
  progress: TProgress;
  bStartPointAdded, bEndPointAdded: Boolean;
  iX, iY: Integer;
  bMustHaveGeometry: Boolean;
  iCurrentGeometry: Integer;
begin
  try
    Result := False;
    if (fileName = '') or not FileExists(fileName) then begin
      sError := 'Файл "' + fileName + '" не существует ';
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
    AssignFile(tfLog, logName);
    if FileExists(logName) then
      Append(tfLog)
    else
      Rewrite(tfLog);
    WriteLn(tfLog, '');
    WriteLn(tfLog, '************************************************************');
    DateTimeToString(s, 'yyyy-mm-dd hh:mm:ss', Date + Time);
    WriteLn(tfLog, s);
    WriteLn(tfLog, 'Чтение набора данных S101 из файла ' + fileName);
    fs := TFileStream.Create(fileName, fmOpenRead	or fmShareDenyWrite);
    size := fs.Seek(0, soFromEnd);
    SetLength(buffer, size + 1);
    fs.Seek(0, soFromBeginning);
    fs.Read(buffer[0], size);
    buffer[size] := #0;
    fs.Free;
    /////////////////////////////////////////////////////////
    progress := TProgress(threadList.LockList[0]);
    progress.m_max := 0;
    progress.m_pos := 0;
    progress.m_Message := 'Разбор JSON-файла';
    threadList.UnlockList;
    /////////////////////////////////////////////////////////
    jsS101 := TlkJSONobject(TlkJSON.ParseText(PChar(buffer)));
    if jsS101 = nil then begin
      sError := 'Не удалось разобрать файл ' + fileName;
      WriteLn(tfLog, sError);
      if calculationThread <> nil then
        calculationThread.m_nTermStatus := TERM_STATUS_ERROR;
      Exit;
    end;
    jsPatch := jsS101.Field['patch'] as TlkJSONobject;
    if jsPatch = nil then begin
      sError := 'В файле ' + fileName + ' отсутствует объект patch';
      WriteLn(tfLog, sError);
      if calculationThread <> nil then
        calculationThread.m_nTermStatus := TERM_STATUS_ERROR;
      Exit;
    end;
    /////////////////////////////////////////////////////////
    // Проверка прерывания процесса пользователем
    suspendEvent.WaitFor($FFFFFFFF);
    if breakEvent.WaitFor(0) = wrSignaled then begin
      if calculationThread <> nil then
        calculationThread.m_nTermStatus := TERM_STATUS_USERSTOP;
      Exit;
    end;
    /////////////////////////////////////////////////////////
    s101IniFile := TS101IniFile.Create(ExtractFilePath(Application.ExeName) +
        'S101Settings.ini');
    s101IniFile.ReadDSSIField(dsGeneralInfo.fDSSI);
    s101IniFile.ReadCodeTable('ATCS', dsGeneralInfo.fATCS);
    s101IniFile.ReadCodeTable('ITCS', dsGeneralInfo.fITCS);
    s101IniFile.ReadCodeTable('FTCS', dsGeneralInfo.fFTCS);
    s101IniFile.ReadCodeTable('IACS', dsGeneralInfo.fIACS);
    s101IniFile.ReadCodeTable('FACS', dsGeneralInfo.fFACS);
    s101IniFile.ReadCodeTable('ARCS', dsGeneralInfo.fARCS);
    s101IniFile.Free;

    // Первый проход. Подсчитываем число объектов каждого вида.

    WriteLn(tfLog, 'Первый проход. Подсчет числа объектов каждого вида.');
    iCurPointRecord := 0;
    iCurMultiPointRecord := 0;
    iCurCurveRecord := 0;
    iCurCompositeCurveRecord := 0;
    iCurSurfaceRecord := 0;
    iCurInfoRecord := 0;
    iCurFeatureRecord := 0;
    for iObject := 0 to jsPatch.Count do begin
      jlObject := jsPatch.FieldByIndex[iObject] as TlkJSONlist;
      sID := jsPatch.NameOf[iObject];
      if AnsiContainsStr(sID, 'O/S/P') then
        iCurPointRecord := iCurPointRecord + 1
      else if AnsiContainsStr(sID, 'O/S/MP') then
        iCurMultiPointRecord := iCurMultiPointRecord + 1
      else if AnsiContainsStr(sID, 'O/S/C/') then
        iCurCurveRecord := iCurCurveRecord + 1
      else if AnsiContainsStr(sID, 'O/S/CC') then
        iCurCompositeCurveRecord := iCurCompositeCurveRecord + 1
      else if AnsiContainsStr(sID, 'O/S/S') then
        iCurSurfaceRecord := iCurSurfaceRecord + 1
      else if AnsiContainsStr(sID, 'O/F') then begin
        jsObject := jlObject.Child[0] as TlkJSONobject;
        sCode := jsObject.Field['code'].Value;
        item := s101Catalogue.items.GetItemByName(sCode);
        if (item = nil) or not (item is TNamedItem) then
          WriteLn(tfLog, 'Объект ' + sID + ' класса ' + sCode + 'в каталоге не найден')
        else begin
          namedItem := item as TNamedItem;
          if namedItem.sType = 'Information' then
            iCurInfoRecord := iCurInfoRecord + 1
          else if namedItem.sType = 'Feature' then
            iCurFeatureRecord := iCurFeatureRecord + 1
          else
            WriteLn(tfLog, 'Объект ' + sID + ' имеет недопустимый тип ' + namedItem.sType);
        end;
      end;
    end;
    SetLength(pointRecords, iCurPointRecord);
    SetLength(multiPointRecords, iCurMultiPointRecord);
    SetLength(curveRecords, iCurCurveRecord);
    SetLength(compositeCurveRecords, iCurCompositeCurveRecord);
    SetLength(surfaceRecords, iCurSurfaceRecord);
    SetLength(infoTypeRecords, iCurInfoRecord);
    SetLength(featureRecords, iCurFeatureRecord);
    WriteLn(tfLog, Format('Число точек: %d', [iCurPointRecord]));
    WriteLn(tfLog, Format('Число мультиточек: %d', [iCurMultiPointRecord]));
    WriteLn(tfLog, Format('Число кривых: %d', [iCurCurveRecord]));
    WriteLn(tfLog, Format('Число композитных кривых: %d', [iCurCompositeCurveRecord]));
    WriteLn(tfLog, Format('Число поверхностей: %d', [iCurSurfaceRecord]));
    WriteLn(tfLog, Format('Число информационных объектов: %d', [iCurInfoRecord]));
    WriteLn(tfLog, Format('Число геообъектов: %d', [iCurFeatureRecord]));

    // Второй проход. Формируем массивы объектов.

    WriteLn(tfLog, 'Второй проход. Формирование массивов объектов.');
    iCurPointRecord := 0;
    iCurMultiPointRecord := 0;
    iCurCurveRecord := 0;
    iCurCompositeCurveRecord := 0;
    iCurSurfaceRecord := 0;
    iCurInfoRecord := 0;
    iCurFeatureRecord := 0;
    iCurITCIndex := 0;
    for iObject := 0 to jsPatch.Count - 1 do begin
      /////////////////////////////////////////////////////////
      // Проверка прерывания процесса пользователем
      suspendEvent.WaitFor($FFFFFFFF);
      if breakEvent.WaitFor(0) = wrSignaled then begin
        if calculationThread <> nil then
          calculationThread.m_nTermStatus := TERM_STATUS_USERSTOP;
        Exit;
      end
      else begin
        progress := TProgress(threadList.LockList[0]);
        progress.m_max := jsPatch.Count;
        progress.m_pos := iObject;
        progress.m_Message := 'Анализ JSON и формирование массивов объектов';
        threadList.UnlockList;
      end;
      /////////////////////////////////////////////////////////
      sID := jsPatch.NameOf[iObject];
      if not (jsPatch.FieldByIndex[iObject] is TlkJSONlist) then begin
        WriteLn(tfLog, 'Объект ' + sID + ' не является массивом');
        Continue;
      end;
      jlObject := jsPatch.FieldByIndex[iObject] as TlkJSONlist;
      jsObject := jlObject.Child[0] as TlkJSONobject;
      if AnsiContainsStr(sID, 'O/S/P') then begin
        with pointRecords[iCurPointRecord].fPRID do begin
          RCNM := 110;
          if (jsObject.Field['id'] <> nil) and (jsObject.Field['id'] is TlkJSONnumber) then
            RCID := jsObject.Field['id'].Value
          else
            RCID := iCurPointRecord + 1;
          RVER := 1;
          RUIN := 1;
        end;
        b3D := AnsiContainsStr(sID, 'O/S/P3');
        if b3D then begin
          with pointRecords[iCurPointRecord] do begin
            ct := ct3I;
            sGUID := StringReplace(sID, 'O/S/P3/', '', []);
          end;
          with pointRecords[iCurPointRecord].fC3IT do begin
            if jsObject.Field['verticalCrs'] <> nil then
              VCID := jsObject.Field['verticalCrs'].Value
            else
              WriteLn(tfLog, '3D-точка ' + sID + ' не имеет свойства verticalCrs');
            if jsObject.Field['lon'] <> nil then
              XCOO := (jsObject.Field['lon'].Value - dsGeneralInfo.fDSSI.DCOX) * dsGeneralInfo.fDSSI.CMFX
            else
              WriteLn(tfLog, '3D-точка ' + sID + ' не имеет свойства lon');
            if jsObject.Field['lat'] <> nil then
              YCOO := (jsObject.Field['lat'].Value - dsGeneralInfo.fDSSI.DCOY) * dsGeneralInfo.fDSSI.CMFY
            else
              WriteLn(tfLog, '3D-точка ' + sID + ' не имеет свойства lat');
            if jsObject.Field['height'] <> nil then
              ZCOO := (jsObject.Field['height'].Value - dsGeneralInfo.fDSSI.DCOZ) * dsGeneralInfo.fDSSI.CMFZ
            else
              WriteLn(tfLog, '3D-точка ' + sID + ' не имеет свойства height');
          end;
        end
        else begin
          with pointRecords[iCurPointRecord] do begin
            ct := ct2I;
            sGUID := StringReplace(sID, 'O/S/P/', '', []);
          end;
          with pointRecords[iCurPointRecord].fC2IT do begin
            if jsObject.Field['lon'] <> nil then
              XCOO := (jsObject.Field['lon'].Value - dsGeneralInfo.fDSSI.DCOX) * dsGeneralInfo.fDSSI.CMFX
            else
              WriteLn(tfLog, '2D-точка ' + sID + ' не имеет свойства lon');
            if jsObject.Field['lat'] <> nil then
              YCOO := (jsObject.Field['lat'].Value - dsGeneralInfo.fDSSI.DCOY) * dsGeneralInfo.fDSSI.CMFY
            else
              WriteLn(tfLog, '2D-точка ' + sID + ' не имеет свойства lat');
          end;
        end;
        iCurPointRecord := iCurPointRecord + 1;
      end
      else if AnsiContainsStr(sID, 'O/S/MP') then begin
        with multiPointRecords[iCurMultiPointRecord].fMRID do begin
          RCNM := 115;
          if (jsObject.Field['id'] <> nil) and (jsObject.Field['id'] is TlkJSONnumber) then
            RCID := jsObject.Field['id'].Value
          else
            RCID := iCurMultiPointRecord + 1;
          RVER := 1;
          RUIN := 1;
        end;
        if (jsObject.Field['coordinates'] <> nil) and (jsObject.Field['coordinates'] is TlkJSONlist) then
          jlCoordinates := jsObject.Field['coordinates'] as TlkJSONlist
        else begin
          WriteLn(tfLog, 'Мультиточка ' + sID + ' не имеет свойства coordinates или coordinates не является массивом');
          Continue;
        end;
        b3D := AnsiContainsStr(sID, 'O/S/MP3');
        with multiPointRecords[iCurMultiPointRecord] do
          if b3D then begin
            ct := ct3I;
            sGUID := StringReplace(sID, 'O/S/MP3/', '', []);
            SetLength(fC3ILArray, 1);
            if (jsObject.Field['verticalCrs'] <> nil) and (jsObject.Field['verticalCrs'] is TlkJSONnumber) then
              fC3ILArray[0].VCID := jsObject.Field['verticalCrs'].Value
            else begin
              WriteLn(tfLog, '3D-мультиточка ' + sID + ' не имеет свойства verticalCrs или verticalCrs не является числовым');
              fC3ILArray[0].VCID := 2;
            end;
            SetLength(fC3ILArray[0].C3ITArray, jlCoordinates.Count);
          end
          else begin
            ct := ct2I;
            sGUID := StringReplace(sID, 'O/S/MP/', '', []);
            SetLength(fC2ILArray, 1);
            SetLength(fC2ILArray[0].C2ITArray, jlCoordinates.Count);
          end;
        for iCoord := 0 to jlCoordinates.Count - 1 do begin
          jsCoordinate := jlCoordinates.Child[iCoord] as TlkJSONobject;
          if b3D then
            with multiPointRecords[iCurMultiPointRecord].fC3ILArray[0].C3ITArray[iCoord] do begin
              if (jsCoordinate.Field['lon'] <> nil) and (jsCoordinate.Field['lon'] is TlkJSONnumber) then
                XCOO := (jsCoordinate.Field['lon'].Value - dsGeneralInfo.fDSSI.DCOX) * dsGeneralInfo.fDSSI.CMFX
              else
                WriteLn(tfLog, '3D-мультиточка ' + sID + ' содержит точку, не имеющую свойства lon, или lon не является числовым');
              if (jsCoordinate.Field['lat'] <> nil) and (jsCoordinate.Field['lat'] is TlkJSONnumber) then
                YCOO := (jsCoordinate.Field['lat'].Value - dsGeneralInfo.fDSSI.DCOY) * dsGeneralInfo.fDSSI.CMFY
              else
                WriteLn(tfLog, '3D-мультиточка ' + sID + ' содержит точку, не имеющую свойства lat, или lat не является числовым');
              if (jsCoordinate.Field['height'] <> nil) and (jsCoordinate.Field['height'] is TlkJSONnumber) then
                ZCOO := (jsCoordinate.Field['height'].Value - dsGeneralInfo.fDSSI.DCOZ) * dsGeneralInfo.fDSSI.CMFZ
              else
                WriteLn(tfLog, '3D-мультиточка ' + sID + ' содержит точку, не имеющую свойства height, или height не является числовым');
            end
          else
            with multiPointRecords[iCurMultiPointRecord].fC2ILArray[0].C2ITArray[iCoord] do begin
              if (jsCoordinate.Field['lon'] <> nil) and (jsCoordinate.Field['lon'] is TlkJSONnumber) then
                XCOO := (jsCoordinate.Field['lon'].Value - dsGeneralInfo.fDSSI.DCOX) * dsGeneralInfo.fDSSI.CMFX
              else
                WriteLn(tfLog, '2D-мультиточка ' + sID + ' содержит точку, не имеющую свойства lon, или lon не является числовым');
              if (jsCoordinate.Field['lat'] <> nil) and (jsCoordinate.Field['lat'] is TlkJSONnumber) then
                YCOO := (jsCoordinate.Field['lat'].Value - dsGeneralInfo.fDSSI.DCOY) * dsGeneralInfo.fDSSI.CMFY
              else
                WriteLn(tfLog, '2D-мультиточка ' + sID + ' содержит точку, не имеющую свойства lat, или lat не является числовым');
            end;
        end;
        iCurMultiPointRecord := iCurMultiPointRecord + 1;
      end
      else if AnsiContainsStr(sID, 'O/S/C/') then begin
        with curveRecords[iCurCurveRecord] do begin
          ct := ct2I;
          sGUID := StringReplace(sID, 'O/S/C/', '', []);
        end;
        with curveRecords[iCurCurveRecord].fCRID do begin
          RCNM := 120;
          if (jsObject.Field['id'] <> nil) and (jsObject.Field['id'] is TlkJSONnumber) then
            RCID := jsObject.Field['id'].Value
          else
            RCID := iCurCurveRecord + 1;
          RVER := 1;
          RUIN := 1;
        end;
        SetLength(curveRecords[iCurCurveRecord].fSegmentArray, 1);
        if (jsObject.Field['interpolationType'] <> nil) and (jsObject.Field['interpolationType'] is TlkJSONstring) then
          sInterpolationType := jsObject.Field['interpolationType'].Value
        else
          WriteLn(tfLog, 'Кривая ' + sID + ' не имеет свойства interpolationType или interpolationType не является строковым');
        with curveRecords[iCurCurveRecord].fSegmentArray[0] do begin
          for i := 0 to Length(InterpolationTypes) - 1 do
            if InterpolationTypes[i] = sInterpolationType then begin
              fSEGH.INTP := i + 1;
              Break;
            end;
          if (jsObject.Field['internalPoints'] <> nil) and (jsObject.Field['internalPoints'] is TlkJSONlist) then begin
            jlInternalPoints := jsObject.Field['internalPoints'] as TlkJSONlist;
            SetLength(fC2ILArray, 1);
            SetLength(fC2ILArray[0].C2ITArray, jlInternalPoints.Count + 2);
          end
          else begin
            WriteLn(tfLog, 'Кривая ' + sID + ' не имеет свойства internalPoints или internalPoints не является массивом');
            Continue;
          end;
        end;
        for i := 0 to jlInternalPoints.Count - 1 do begin
          jsInternalPoint := jlInternalPoints.Child[i] as TlkJSONobject;
          // Первая и последняя точка заполняются при следующем проходе по startPoint и endPoint
          with curveRecords[iCurCurveRecord].fSegmentArray[0].fC2ILArray[0].C2ITArray[i + 1] do begin
            if (jsInternalPoint.Field['lon'] <> nil) and (jsInternalPoint.Field['lon'] is TlkJSONnumber) then
              XCOO := (jsInternalPoint.Field['lon'].Value - dsGeneralInfo.fDSSI.DCOX) * dsGeneralInfo.fDSSI.CMFX
            else
              WriteLn(tfLog, 'Кривая ' + sID + ' содержит внутреннюю точку, не имеющую свойства lon, или lon не является числовым');
            if (jsInternalPoint.Field['lat'] <> nil) and (jsInternalPoint.Field['lat'] is TlkJSONnumber) then
              YCOO := (jsInternalPoint.Field['lat'].Value - dsGeneralInfo.fDSSI.DCOY) * dsGeneralInfo.fDSSI.CMFY
            else
              WriteLn(tfLog, 'Кривая ' + sID + ' содержит внутреннюю точку, не имеющую свойства lat, или lat не является числовым');
          end;
        end;
        iCurCurveRecord := iCurCurveRecord + 1;
      end
      else if AnsiContainsStr(sID, 'O/S/CC') then begin
        compositeCurveRecords[iCurCompositeCurveRecord].sGUID := StringReplace(sID, 'O/S/CC/', '', []);
        with compositeCurveRecords[iCurCompositeCurveRecord].fCCID do begin
          RCNM := 125;
          if (jsObject.Field['id'] <> nil) and (jsObject.Field['id'] is TlkJSONnumber) then
            RCID := jsObject.Field['id'].Value
          else
            RCID := iCurCompositeCurveRecord + 1;
          RVER := 1;
          RUIN := 1;
        end;
        if (jsObject.Field['components'] <> nil) and (jsObject.Field['components'] is TlkJSONlist) then
          jlComponents := jsObject.Field['components'] as TlkJSONlist
        else begin
          WriteLn(tfLog, 'Композитная кривая ' + sID + ' не имеет свойства components или components не является массивом');
          Continue;
        end;
        SetLength(compositeCurveRecords[iCurCompositeCurveRecord].fCUCOArray, 1);
        SetLength(compositeCurveRecords[iCurCompositeCurveRecord].fCUCOArray[0].CUCOArray, jlComponents.Count);
        for i := 0 to jlComponents.Count - 1 do begin
          jsComponent := jlComponents.Child[i] as TlkJSONobject;
          if (jsComponent.Field['orientation'] <> nil) and (jsComponent.Field['orientation'] is TlkJSONstring) then
            sOrientation := jsComponent.Field['orientation'].Value
          else begin
            WriteLn(tfLog, 'Композитная кривая ' + sID + ' содержит компонент, не имеющий свойства orientation или orientation не является строковым');
            sOrientation := Orientation[0];
          end;
          with compositeCurveRecords[iCurCompositeCurveRecord].fCUCOArray[0].CUCOArray[i] do begin
            RRNM := 120;
            for ii := 0 to Length(Orientation) - 1 do
              if Orientation[ii] = sOrientation then begin
                ORNT := ii + 1;
                Break;
              end;
            // Поле RRID определяется и записывается при следующем проходе
          end;
        end;
        iCurCompositeCurveRecord := iCurCompositeCurveRecord + 1;
      end
      else if AnsiContainsStr(sID, 'O/S/S/') then begin
        surfaceRecords[iCurSurfaceRecord].sGUID := StringReplace(sID, 'O/S/S/', '', []);
        with surfaceRecords[iCurSurfaceRecord].fSRID do begin
          RCNM := 130;
          if (jsObject.Field['id'] <> nil) and (jsObject.Field['id'] is TlkJSONnumber) then
            RCID := jsObject.Field['id'].Value
          else
            RCID := iCurSurfaceRecord + 1;
          RVER := 1;
          RUIN := 1;
        end;
        if (jsObject.Field['rings'] <> nil) and (jsObject.Field['rings'] is TlkJSONlist) then
          jlRings := jsObject.Field['rings'] as TlkJSONlist
        else begin
          WriteLn(tfLog, 'Поверхность ' + sID + ' не имеет свойства rings или rings не является массивом');
          Continue;
        end;
        SetLength(surfaceRecords[iCurSurfaceRecord].fRIASArray, 1);
        SetLength(surfaceRecords[iCurSurfaceRecord].fRIASArray[0].RIASArray, jlRings.Count);
        for i := 0 to jlRings.Count - 1 do begin
          jsRing := jlRings.Child[i] as TlkJSONobject;
          if (jsRing.Field['orientation'] <> nil) and (jsRing.Field['orientation'] is TlkJSONstring) then
            sOrientation := jsRing.Field['orientation'].Value
          else begin
            WriteLn(tfLog, 'Поверхность ' + sID + ' содержит кольцо, не имеющее свойства orientation, или orientation не является строковым');
            sOrientation := Orientation[0];
          end;
          if (jsRing.Field['exteriorInterior'] <> nil) and (jsRing.Field['exteriorInterior'] is TlkJSONstring) then
            sExteriorInterior := jsRing.Field['exteriorInterior'].Value
          else begin
            WriteLn(tfLog, 'Поверхность ' + sID + ' содержит кольцо, не имеющее свойства exteriorInterior, или exteriorInterior не является строковым');
            sExteriorInterior := ExteriorInterior[0];
          end;
          with surfaceRecords[iCurSurfaceRecord].fRIASArray[0].RIASArray[i] do begin
            RAUI := 1;
            for ii := 0 to Length(Orientation) - 1 do
              if Orientation[ii] = sOrientation then begin
                ORNT := ii + 1;
                Break;
              end;
            for ii := 0 to Length(ExteriorInterior) - 1 do
              if ExteriorInterior[ii] = sExteriorInterior then begin
                USAG := ii + 1;
                Break;
              end;
            // Поля RRNM и RRID определяются и записываются при следующем проходе
          end;
        end;
        iCurSurfaceRecord := iCurSurfaceRecord + 1;
      end
      else if AnsiContainsStr(sID, 'O/F/') then begin
        if (jsObject.Field['code'] = nil) or not (jsObject.Field['code'] is TlkJSONstring) then begin
          WriteLn(tfLog, 'Объект ' + sID + ' не имееет свойства code или code не является строковым');
          Continue;
        end;
        sCode := jsObject.Field['code'].Value;
        item := s101Catalogue.items.GetItemByName(sCode);
        if (item = nil) or not (item is TNamedItem) then begin
          WriteLn(tfLog, 'Класс ' + sCode + 'объекта ' + sID + ' не найден в каталоге');
          Continue;
        end;
        namedItem := item as TNamedItem;
        sCodeTheir := s101Catalogue.acronymPairs.GetTheirByOur(sCode);
        if sCodeTheir = '' then begin
          WriteLn(tfLog, 'Классу ' + sCode + ' объекта ' + sID + ' не найдено соответствия в стандарте S101');
          Continue;
        end;
        sCurrentID := sID;
        if (jsObject.Field['id'] <> nil) and (jsObject.Field['id'] is TlkJSONnumber) then
          iRCID := jsObject.Field['id'].Value
        else begin
          iRCID := 0;
          jsAttributes := jsObject.Field['attributes'] as TlkJSONobject;
          if jsAttributes <> nil then begin
            jlLocID := jsAttributes.Field['locID'] as TlkJSONlist;
            if jlLocID <> nil then
              for i := 0 to jlLocID.Count - 1 do begin
                jsLocID := jlLocID.Child[i] as TlkJSONobject;
                if jsLocID.Field['mapNam'] <> nil then begin
                  s := jsLocID.Field['mapNam'].Value;
                  iPos := AnsiPos('.', s);
                  if iPos > 0 then
                    s := AnsiLeftStr(s, iPos - 1);
                  if AnsiContainsText(fileName, s) then begin
                    if jsLocID.Field['valID'] <> nil then
                      iRCID := jsLocID.Field['valID'].Value;
                    Break;
                  end;
                end;
              end;
          end;
        end;
        if namedItem.sType = 'Information' then begin
          infoTypeRecords[iCurInfoRecord].m_sGUID := StringReplace(sID, 'O/F/', '', []);
          infoTypeRecords[iCurInfoRecord].m_sCode := sCode;
          for i := 0 to Length(dsGeneralInfo.fITCS) - 1 do
            if dsGeneralInfo.fITCS[i].sCode = sCodeTheir then
              Break;
          if i = Length(dsGeneralInfo.fITCS) then begin
            WriteLn(tfLog, 'Для класса ' + sCodeTheir + ' объекта ' + sID + ' не найден соответствующий числовой код');
            Continue;
          end;
          with infoTypeRecords[iCurInfoRecord].fIRID do begin
            RCNM := Ord(InfoRecordType);
            RCID := iRCID;
            NITC := dsGeneralInfo.fITCS[i].iCode;
            RVER := 1;
            RUIN := 1;
          end;
          SetLength(infoTypeRecords[iCurInfoRecord].fATTRArray, 1);
          AttributesFromJSON(sCode, TlkJSONobject(jsObject.Field['attributes']),
              TArrayOfAttrElem(infoTypeRecords[iCurInfoRecord].fATTRArray[0].arrayOfAttrElem));
          // Ассоциации определяются и записываются при следующем проходе
          iCurInfoRecord := iCurInfoRecord + 1;
        end
        else if namedItem.sType = 'Feature' then begin
          featureRecords[iCurFeatureRecord].m_sGUID := StringReplace(sID, 'O/F/', '', []);
          featureRecords[iCurFeatureRecord].m_sCode := sCode;
          for i := 0 to Length(dsGeneralInfo.fFTCS) - 1 do
            if dsGeneralInfo.fFTCS[i].sCode = sCodeTheir then
              Break;
          if i = Length(dsGeneralInfo.fFTCS) then begin
            WriteLn(tfLog, 'Для класса ' + sCodeTheir + ' объекта ' + sID + ' не найден соответствующий числовой код');
            Continue;
          end;
          with featureRecords[iCurFeatureRecord].fFRID do begin
            RCNM := Ord(FeatureRecordType);
            RCID := iRCID;
            NFTC := dsGeneralInfo.fFTCS[i].iCode;
            RVER := 1;
            RUIN := 1;
          end;
          SetLength(featureRecords[iCurFeatureRecord].fATTRArray, 1);
          AttributesFromJSON(sCode, TlkJSONobject(jsObject.Field['attributes']),
              TArrayOfAttrElem(featureRecords[iCurFeatureRecord].fATTRArray[0].arrayOfAttrElem));
          // Ассоциации определяются и записываются при следующем проходе
          iCurFeatureRecord := iCurFeatureRecord + 1;
        end
        else
          WriteLn(tfLog, 'Объект ' + sID + ' имеет недопустимый тип ' + namedItem.sType);
      end;
    end;
    SetLength(infoTypeRecords, iCurInfoRecord);
    SetLength(featureRecords, iCurFeatureRecord);

    // Присвоение числового идентификатора информационным и геообъектам,
    // у которых RCID=0
    iRCIDmax := 0;
    for i := 0 to Length(infoTypeRecords) - 1 do
      with infoTypeRecords[i].fIRID do
        if RCID > iRCIDmax then
          iRCIDmax := RCID;
    iRCID := iRCIDmax + 1;
    for i := 0 to Length(infoTypeRecords) - 1 do
      with infoTypeRecords[i].fIRID do
        if RCID = 0 then begin
          RCID := iRCID;
          iRCID := iRCID + 1;
        end;
    iRCIDmax := 0;
    for i := 0 to Length(featureRecords) - 1 do
      with featureRecords[i].fFRID do
        if RCID > iRCIDmax then
          iRCIDmax := RCID;
    iRCID := iRCIDmax + 1;
    for i := 0 to Length(featureRecords) - 1 do
      with featureRecords[i].fFRID do
        if RCID = 0 then begin
          RCID := iRCID;
          iRCID := iRCID + 1;
        end;

    // Третий проход. Записываем недостающие ссылки.

    WriteLn(tfLog, 'Третий проход. Добавление ссылок.');
    // Формируем упорядоченные пары sGUID-IValue
    keyIValuePointList := TKeyIValueList.Create;
    for iCurPointRecord := 0 to Length(pointRecords) - 1 do
      keyIValuePointList.Add(TKeyIValue.Create(pointRecords[iCurPointRecord].sGUID,
          iCurPointRecord));
    if keyIValuePointList.Count > 1 then keyIValuePointList.SortByKey;
    keyIValueMultiPointList := TKeyIValueList.Create;
    for iCurMultiPointRecord := 0 to Length(multiPointRecords) - 1 do
      keyIValueMultiPointList.Add(TKeyIValue.Create(
          multiPointRecords[iCurMultiPointRecord].sGUID, iCurMultiPointRecord));
    if keyIValueMultiPointList.Count > 1 then keyIValueMultiPointList.SortByKey;
    keyIValueCurveList := TKeyIValueList.Create;
    for iCurCurveRecord := 0 to Length(curveRecords) - 1 do
      keyIValueCurveList.Add(TKeyIValue.Create(curveRecords[iCurCurveRecord].sGUID,
          iCurCurveRecord));
    if keyIValueCurveList.Count > 1 then keyIValueCurveList.SortByKey;
    keyIValueCompositeCurveList := TKeyIValueList.Create;
    for iCurCompositeCurveRecord := 0 to Length(compositeCurveRecords) - 1 do
      keyIValueCompositeCurveList.Add(TKeyIValue.Create(
          compositeCurveRecords[iCurCompositeCurveRecord].sGUID, iCurCompositeCurveRecord));
    if keyIValueCompositeCurveList.Count > 1 then keyIValueCompositeCurveList.SortByKey;
    keyIValueSurfaceList := TKeyIValueList.Create;
    for iCurSurfaceRecord := 0 to Length(surfaceRecords) - 1 do
      keyIValueSurfaceList.Add(TKeyIValue.Create(
          surfaceRecords[iCurSurfaceRecord].sGUID, iCurSurfaceRecord));
    if keyIValueSurfaceList.Count > 1 then keyIValueSurfaceList.SortByKey;

    // Записываем начальную и конечную точку кривой
    WriteLn(tfLog, 'Добавление координат начальной и конечной точек кривой');
    for iCurCurveRecord := 0 to Length(curveRecords) - 1 do begin
      /////////////////////////////////////////////////////////
      // Проверка прерывания процесса пользователем
      suspendEvent.WaitFor($FFFFFFFF);
      if breakEvent.WaitFor(0) = wrSignaled then begin
        if calculationThread <> nil then
          calculationThread.m_nTermStatus := TERM_STATUS_USERSTOP;
        Exit;
      end
      else begin
        progress := TProgress(threadList.LockList[0]);
        progress.m_max := Length(curveRecords);
        progress.m_pos := iCurCurveRecord;
        progress.m_Message := 'Добавление координат начальной и конечной точек кривой';
        threadList.UnlockList;
      end;
      /////////////////////////////////////////////////////////
      sID := 'O/S/C/' + curveRecords[iCurCurveRecord].sGUID;
      sCurrentID := sID;
      if (jsPatch.Field[sID] = nil) or not (jsPatch.Field[sID] is TlkJSONlist) then begin
        WriteLn(tfLog, 'Кривая ' + sID + ' не найдена или не является массивом');
        Continue;
      end;
      jlObject := jsPatch.Field[sID] as TlkJSONlist;
      jsObject := jlObject.Child[0] as TlkJSONobject;
      if jsObject.Field['startPoint'] = nil then begin
        WriteLn(tfLog, 'Кривая ' + sID + ' не имеет свойства startPoint');
        Continue;
      end;
      jlObject := jsPatch.Field[jsObject.Field['startPoint'].Value] as TlkJSONlist;
      if jlObject = nil then begin
        WriteLn(tfLog, Format('Начальная точка %s кривой %s не найдена',
            [string(jsObject.Field['startPoint'].Value), sID]));
        Continue;
      end;
      jsStartPoint := jlObject.Child[0] as TlkJSONobject;
      jlObject := jsPatch.Field[jsObject.Field['endPoint'].Value] as TlkJSONlist;
      if jlObject = nil then begin
        WriteLn(tfLog, Format('Конечная точка %s кривой %s не найдена',
            [string(jsObject.Field['endPoint'].Value), sID]));
        Continue;
      end;
      jsEndPoint := jlObject.Child[0] as TlkJSONobject;

      // Добавляем начальную и конечную точку, если их координаты отличаются
      // от соседних внутренних точек кривой
      bStartPointAdded := False;
      bEndPointAdded := False;
      with curveRecords[iCurCurveRecord].fSegmentArray[0].fC2ILArray[0] do begin
        arrayLen := Length(C2ITArray);
        if (jsStartPoint.Field['lon'] <> nil) and (jsStartPoint.Field['lat'] <> nil) then begin
          iX := (jsStartPoint.Field['lon'].Value - dsGeneralInfo.fDSSI.DCOX) * dsGeneralInfo.fDSSI.CMFX;
          iY := (jsStartPoint.Field['lat'].Value - dsGeneralInfo.fDSSI.DCOY) * dsGeneralInfo.fDSSI.CMFY;
          if (iX <> C2ITArray[1].XCOO) or (iY <> C2ITArray[1].YCOO) then begin
            C2ITArray[0].XCOO := iX;
            C2ITArray[0].YCOO := iY;
            bStartPointAdded := True;
          end;
        end
        else
          WriteLn(tfLog, 'Начальная точка кривой ' + sID + ' не имеет свойства lat/lon');
        if not bStartPointAdded then begin
          Move(C2ITArray[1], C2ITArray[0], SizeOf(TC2ITElem) * (arrayLen - 1));
          arrayLen := arrayLen - 1;
        end;
        if (jsEndPoint.Field['lon'] <> nil) and (jsEndPoint.Field['lat'] <> nil) then begin
          iX := (jsEndPoint.Field['lon'].Value - dsGeneralInfo.fDSSI.DCOX) * dsGeneralInfo.fDSSI.CMFX;
          iY := (jsEndPoint.Field['lat'].Value - dsGeneralInfo.fDSSI.DCOY) * dsGeneralInfo.fDSSI.CMFY;
          if (iX <> C2ITArray[arrayLen - 2].XCOO) or (iY <> C2ITArray[arrayLen - 2].YCOO) then begin
            C2ITArray[arrayLen - 1].XCOO := iX;
            C2ITArray[arrayLen - 1].YCOO := iY;
            bEndPointAdded := True;
          end;
        end
        else
          WriteLn(tfLog, 'Конечная точка кривой ' + sID + ' не имеет свойства lat/lon');
        if not bEndPointAdded then
          arrayLen := arrayLen - 1;
        SetLength(C2ITArray, arrayLen);
      end;

      // Создание вспомогательного массива PTASArray концевых точек кривой
      sID := jsObject.Field['startPoint'].Value;
      sGUID := AnsiReplaceStr(sID, 'O/S/P/', '');
      iStartPoint := keyIValuePointList.GetIValueByKey(sGUID);
      sID := jsObject.Field['endPoint'].Value;
      sGUID := AnsiReplaceStr(sID, 'O/S/P/', '');
      iEndPoint := keyIValuePointList.GetIValueByKey(sGUID);
      if (iStartPoint >= 0) and (iEndPoint >= 0) then begin
        bSame := iStartPoint = iEndPoint;
        with curveRecords[iCurCurveRecord].fPTAS do
          if bSame then begin
            SetLength(PTASArray, 1);
            PTASArray[0].RRNM := Ord(PointRecordType);
            PTASArray[0].RRID := pointRecords[iStartPoint].fPRID.RCID;
            PTASArray[0].TOPI := 3;
          end
          else begin
            SetLength(PTASArray, 2);
            PTASArray[0].RRNM := Ord(PointRecordType);
            PTASArray[0].RRID := pointRecords[iStartPoint].fPRID.RCID;
            PTASArray[0].TOPI := 1;
            PTASArray[1].RRNM := Ord(PointRecordType);
            PTASArray[1].RRID := pointRecords[iEndPoint].fPRID.RCID;
            PTASArray[1].TOPI := 2;
          end;
      end
      else
        raise EInvalidPointer.Create('Начальная или конечная точка кривой ' + sCurrentID +
            ' не обнаружена в ассоциативном массиве keyIValuePointList');
    end;

    // Записываем ссылки на компоненты композитной кривой
    WriteLn(tfLog, 'Добавление ссылок на компоненты композитной кривой');
    for iCurCompositeCurveRecord := 0 to Length(compositeCurveRecords) - 1 do begin
      /////////////////////////////////////////////////////////
      // Проверка прерывания процесса пользователем
      suspendEvent.WaitFor($FFFFFFFF);
      if breakEvent.WaitFor(0) = wrSignaled then begin
        if calculationThread <> nil then
          calculationThread.m_nTermStatus := TERM_STATUS_USERSTOP;
        Exit;
      end
      else begin
        progress := TProgress(threadList.LockList[0]);
        progress.m_max := Length(compositeCurveRecords);
        progress.m_pos := iCurCompositeCurveRecord;
        progress.m_Message := 'Добавление ссылок на компоненты композитной кривой';
        threadList.UnlockList;
      end;
      /////////////////////////////////////////////////////////
      sID := 'O/S/CC/' + compositeCurveRecords[iCurCompositeCurveRecord].sGUID;
      sCurrentID := sID;
      if (jsPatch.Field[sID] = nil) or not (jsPatch.Field[sID] is TlkJSONlist) then begin
        WriteLn(tfLog, 'Композитная кривая ' + sID + ' не найдена или не является массивом');
        Continue;
      end;
      jlObject := jsPatch.Field[sID] as TlkJSONlist;
      jsObject := jlObject.Child[0] as TlkJSONobject;
      jlComponents := jsObject.Field['components'] as TlkJSONlist;
      if jlComponents = nil then begin
        WriteLn(tfLog, 'Композитная кривая ' + sID + ' не имеет свойства components');
        Continue;
      end;
      for i := 0 to jlComponents.Count - 1 do begin
        jsComponent := jlComponents.Child[i] as TlkJSONobject;
        if jsComponent.Field['ref'] = nil then begin
          WriteLn(tfLog, Format('Компонент %d композитной кривой %s не имеет свойства ref', [i, sID]));
          Continue;
        end;
        sID := jsComponent.Field['ref'].Value;
        if AnsiContainsStr(sID, 'O/S/C/') then begin
          iCurCurveRecord := keyIValueCurveList.GetIValueByKey(AnsiReplaceStr(sID, 'O/S/C/', ''));
          if iCurCurveRecord < 0 then
            raise EInvalidPointer.Create('Компонент ' + sID +
                ' композитной кривой ' + sCurrentID + ' не обнаружен в ассоциативном массиве keyIValueCurveList');
          with compositeCurveRecords[iCurCompositeCurveRecord].fCUCOArray[0].CUCOArray[i] do begin
            RRNM := Ord(CurveRecordType);
            RRID := curveRecords[iCurCurveRecord].fCRID.RCID;
          end;
        end
        else if AnsiContainsStr(sID, 'O/S/CC/') then begin
          iCurCompositeCurveRecord2 := keyIValueCompositeCurveList.GetIValueByKey(AnsiReplaceStr(sID, 'O/S/CC/', ''));
          if iCurCompositeCurveRecord2 < 0 then
            raise EInvalidPointer.Create('Компонент ' + sID +
                ' композитной кривой ' + sCurrentID + ' не обнаружен в ассоциативном массиве keyIValueCompositeCurveList');
          with compositeCurveRecords[iCurCompositeCurveRecord].fCUCOArray[0].CUCOArray[i] do begin
            RRNM := Ord(CompositeCurveRecordType);
            RRID := compositeCurveRecords[iCurCompositeCurveRecord2].fCCID.RCID;
          end;
        end
        else
          raise EInvalidPointer.Create('Идентификатор компонента ' + sID +
              ' композитной кривой ' + sCurrentID + ' имеет недопустимый префикс');
      end;
    end;

    // Записываем ссылки на кривые, в т.ч. композитные, составляющие поверхность
    WriteLn(tfLog, 'Добавление ссылок на кривые, в т.ч. композитные, в поверхности');
    for iCurSurfaceRecord := 0 to Length(surfaceRecords) - 1 do begin
      /////////////////////////////////////////////////////////
      // Проверка прерывания процесса пользователем
      suspendEvent.WaitFor($FFFFFFFF);
      if breakEvent.WaitFor(0) = wrSignaled then begin
        if calculationThread <> nil then
          calculationThread.m_nTermStatus := TERM_STATUS_USERSTOP;
        Exit;
      end
      else begin
        progress := TProgress(threadList.LockList[0]);
        progress.m_max := Length(surfaceRecords);
        progress.m_pos := iCurSurfaceRecord;
        progress.m_Message := 'Добавление ссылок на кривые, в т.ч. композитные, в поверхности';
        threadList.UnlockList;
      end;
      /////////////////////////////////////////////////////////
      sID := 'O/S/S/' + surfaceRecords[iCurSurfaceRecord].sGUID;
      sCurrentID := sID;
      if (jsPatch.Field[sID] = nil) or not (jsPatch.Field[sID] is TlkJSONlist) then begin
        WriteLn(tfLog, 'Поверхность ' + sID + ' не найдена или не является массивом');
        Continue;
      end;
      jlObject := jsPatch.Field[sID] as TlkJSONlist;
      jsObject := jlObject.Child[0] as TlkJSONobject;
      jlRings := jsObject.Field['rings'] as TlkJSONlist;
      if jlRings = nil then begin
        WriteLn(tfLog, 'Поверхность ' + sID + ' не имеет свойства rings');
        Continue;
      end;
      for i := 0 to jlRings.Count - 1 do begin
        jsRing := jlRings.Child[i] as TlkJSONobject;
        if jsRing.Field['ref'] = nil then begin
          WriteLn(tfLog, Format('Кольцо %d поверхности %s не имеет свойства ref', [i, sID]));
          Continue;
        end;
        sID := jsRing.Field['ref'].Value;
        if AnsiContainsStr(sID, 'O/S/CC/') then begin
          iCurCompositeCurveRecord := keyIValueCompositeCurveList.GetIValueByKey(
              AnsiReplaceStr(sID, 'O/S/CC/', ''));
          if iCurCompositeCurveRecord < 0 then
            raise EInvalidPointer.Create('Кольцо ' + sID +
                ' поверхности ' + sCurrentID + ' не обнаружено в ассоциативном массиве keyIValueCompositeCurveList');
          with surfaceRecords[iCurSurfaceRecord].fRIASArray[0].RIASArray[i] do begin
            RRNM := Ord(CompositeCurveRecordType);
            RRID := compositeCurveRecords[iCurCompositeCurveRecord].fCCID.RCID;
          end;
        end
        else if AnsiContainsStr(sID, 'O/S/C/') then begin
          iCurCurveRecord := keyIValueCurveList.GetIValueByKey(AnsiReplaceStr(sID, 'O/S/C/', ''));
          if iCurCurveRecord < 0 then
            raise EInvalidPointer.Create('Кольцо ' + sID +
                ' поверхности ' + sCurrentID + ' не обнаружено в ассоциативном массиве keyIValueCurveList');
          with surfaceRecords[iCurSurfaceRecord].fRIASArray[0].RIASArray[i] do begin
            RRNM := Ord(CurveRecordType);
            RRID := curveRecords[iCurCurveRecord].fCRID.RCID;
          end;
        end;
      end;
    end;

    // Добавляем информационные ассоциации в информационные объекты
    WriteLn(tfLog, 'Добавление информационных ассоциаций в информационные объекты');
    for iCurInfoRecord := 0 to Length(infoTypeRecords) - 1 do begin
      /////////////////////////////////////////////////////////
      // Проверка прерывания процесса пользователем
      suspendEvent.WaitFor($FFFFFFFF);
      if breakEvent.WaitFor(0) = wrSignaled then begin
        if calculationThread <> nil then
          calculationThread.m_nTermStatus := TERM_STATUS_USERSTOP;
        Exit;
      end
      else begin
        progress := TProgress(threadList.LockList[0]);
        progress.m_max := Length(infoTypeRecords);
        progress.m_pos := iCurInfoRecord;
        progress.m_Message := 'Добавление информационных ассоциаций в информационные объекты';
        threadList.UnlockList;
      end;
      /////////////////////////////////////////////////////////
      sID := 'O/F/' + infoTypeRecords[iCurInfoRecord].m_sGUID;
      sCurrentID := sID;
      if (jsPatch.Field[sID] = nil) or not (jsPatch.Field[sID] is TlkJSONlist) then begin
        WriteLn(tfLog, 'Информационный объект ' + sID + ' не найден или не является массивом');
        Continue;
      end;
      jlObject := jsPatch.Field[sID] as TlkJSONlist;
      jsObject := jlObject.Child[0] as TlkJSONobject;
      jlAssociations := jsObject.Field['featureAssociations'] as TlkJSONlist;
      InfoAssociationsFromJSON(infoTypeRecords[iCurInfoRecord].m_sCode, jlAssociations,
          TArrayOfINASField(infoTypeRecords[iCurInfoRecord].fINASArray));
    end;

    // Добавляем ссылки геообъектов
    WriteLn(tfLog, 'Добавление ссылок геообъектов на другие объекты и геометрию');
    for iCurFeatureRecord := 0 to Length(featureRecords) - 1 do begin
      /////////////////////////////////////////////////////////
      // Проверка прерывания процесса пользователем
      suspendEvent.WaitFor($FFFFFFFF);
      if breakEvent.WaitFor(0) = wrSignaled then begin
        if calculationThread <> nil then
          calculationThread.m_nTermStatus := TERM_STATUS_USERSTOP;
        Exit;
      end
      else begin
        progress := TProgress(threadList.LockList[0]);
        progress.m_max := Length(featureRecords);
        progress.m_pos := iCurFeatureRecord;
        progress.m_Message := 'Добавление ссылок геообъектов на другие объекты и геометрию';
        threadList.UnlockList;
      end;
      /////////////////////////////////////////////////////////
      sID := 'O/F/' + featureRecords[iCurFeatureRecord].m_sGUID;
      sCurrentID := sID;
      if (jsPatch.Field[sID] = nil) or not (jsPatch.Field[sID] is TlkJSONlist) then begin
        WriteLn(tfLog, 'Геообъект ' + sID + ' не найден или не является массивом');
        Continue;
      end;
      jlObject := jsPatch.Field[sID] as TlkJSONlist;
      jsObject := jlObject.Child[0] as TlkJSONobject;
      jlAssociations := jsObject.Field['featureAssociations'] as TlkJSONlist;
      InfoAssociationsFromJSON(featureRecords[iCurFeatureRecord].m_sCode, jlAssociations,
          TArrayOfINASField(featureRecords[iCurFeatureRecord].fINASArray));
      FeatureAssociationsFromJSON(featureRecords[iCurFeatureRecord].m_sCode, jlAssociations,
          TArrayOfFASCField(featureRecords[iCurFeatureRecord].fFASCArray));
      featureItem := TFeatureItem(s101Catalogue.items.GetItemByName(featureRecords[iCurFeatureRecord].m_sCode));
      bMustHaveGeometry := True;
      for i := 0 to Length(featureItem.permittedPrimitives) - 1 do
        if featureItem.permittedPrimitives[i].code = 50 then begin
          bMustHaveGeometry := False;
          Break;
        end;
      jlGeometry := jsObject.Field['geometry'] as TlkJSONlist;
      if jlGeometry = nil then begin
        if bMustHaveGeometry then
          WriteLn(tfLog, 'Геообъект ' + sID + ' не имеет свойства geometry');
        Continue;
      end;
      SetLength(featureRecords[iCurFeatureRecord].fSPASArray, 1);
      iCurrentGeometry := 0;
      for i := 0 to jlGeometry.Count - 1 do begin
        jsGeometry := jlGeometry.Child[i] as TlkJSONobject;
        if jsGeometry.Field['ref'] = nil then begin
          if bMustHaveGeometry then
            WriteLn(tfLog, Format('Геообъект %s: элемент %d массива geometry не имеет свойства ref', [sID, i]));
          Continue;
        end;
        sID := jsGeometry.Field['ref'].Value;
        if AnsiContainsStr(sID, 'O/S/P') then begin
          if AnsiContainsStr(sID, 'O/S/P3/') then
            sGUID := AnsiReplaceStr(sID, 'O/S/P3/', '')
          else
            sGUID := AnsiReplaceStr(sID, 'O/S/P/', '');
          iCurPointRecord := keyIValuePointList.GetIValueByKey(sGUID);
          if iCurPointRecord < 0 then begin
            WriteLn(tfLog, Format('Геообъект %s: элемент %d массива geometry ссылается на несуществующую геометрию %s',
                [sCurrentID, i, sID]));
            Continue;
          end;
          SetLength(featureRecords[iCurFeatureRecord].fSPASArray[0].SPASArray, iCurrentGeometry + 1);
          with featureRecords[iCurFeatureRecord].fSPASArray[0].SPASArray[iCurrentGeometry] do begin
            RRNM := Ord(PointRecordType);
            RRID := pointRecords[iCurPointRecord].fPRID.RCID;
            ORNT := 255;
            jsScaleRange := jsGeometry.Field['scaleRange'] as TlkJSONobject;
            if jsScaleRange <> nil then begin
              if jsScaleRange.Field['lower'] <> nil then
                SMIN := jsScaleRange.Field['lower'].Value;
              if jsScaleRange.Field['upper'] <> nil then
                SMAX := jsScaleRange.Field['upper'].Value;
            end;
            SAUI := 1;
          end;
          iCurrentGeometry := iCurrentGeometry + 1;
        end
        else if AnsiContainsStr(sID, 'O/S/MP') then begin
          if AnsiContainsStr(sID, 'O/S/MP3/') then
            iCurMultiPointRecord := keyIValueMultiPointList.GetIValueByKey(AnsiReplaceStr(sID, 'O/S/MP3/', ''))
          else
            iCurMultiPointRecord := keyIValueMultiPointList.GetIValueByKey(AnsiReplaceStr(sID, 'O/S/MP/', ''));
          if iCurMultiPointRecord < 0 then begin
            WriteLn(tfLog, Format('Геообъект %s: элемент %d массива geometry ссылается на несуществующую геометрию %s',
                [sCurrentID, i, sID]));
            Continue;
          end;
          SetLength(featureRecords[iCurFeatureRecord].fSPASArray[0].SPASArray, iCurrentGeometry + 1);
          with featureRecords[iCurFeatureRecord].fSPASArray[0].SPASArray[iCurrentGeometry] do begin
            RRNM := Ord(MultiPointRecordType);
            RRID := multiPointRecords[iCurMultiPointRecord].fMRID.RCID;
            if jsGeometry.Field['orientation'] <> nil then
              if jsGeometry.Field['orientation'].Value = 'forward' then
                ORNT := 1
              else
                ORNT := 2
            else
                ORNT := 255;
            jsScaleRange := jsGeometry.Field['scaleRange'] as TlkJSONobject;
            if jsScaleRange <> nil then begin
              if jsScaleRange.Field['lower'] <> nil then
                SMIN := jsScaleRange.Field['lower'].Value;
              if jsScaleRange.Field['upper'] <> nil then
                SMAX := jsScaleRange.Field['upper'].Value;
            end;
            SAUI := 1;
          end;
          iCurrentGeometry := iCurrentGeometry + 1;
        end
        else if AnsiContainsStr(sID, 'O/S/C/') then begin
          iCurCurveRecord := keyIValueCurveList.GetIValueByKey(AnsiReplaceStr(sID, 'O/S/C/', ''));
          if iCurCurveRecord < 0 then begin
            WriteLn(tfLog, Format('Геообъект %s: элемент %d массива geometry ссылается на несуществующую геометрию %s',
                [sCurrentID, i, sID]));
            Continue;
          end;
          SetLength(featureRecords[iCurFeatureRecord].fSPASArray[0].SPASArray, iCurrentGeometry + 1);
          with featureRecords[iCurFeatureRecord].fSPASArray[0].SPASArray[iCurrentGeometry] do begin
            RRNM := Ord(CurveRecordType);
            RRID := curveRecords[iCurCurveRecord].fCRID.RCID;
            if (jsGeometry.Field['orientation'] = nil) or
                (jsGeometry.Field['orientation'].Value = 'forward') then
              ORNT := 1
            else
              ORNT := 2;
            jsScaleRange := jsGeometry.Field['scaleRange'] as TlkJSONobject;
            if jsScaleRange <> nil then begin
              if jsScaleRange.Field['lower'] <> nil then
                SMIN := jsScaleRange.Field['lower'].Value;
              if jsScaleRange.Field['upper'] <> nil then
                SMAX := jsScaleRange.Field['upper'].Value;
            end;
            SAUI := 1;
          end;
          iCurrentGeometry := iCurrentGeometry + 1;
        end
        else if AnsiContainsStr(sID, 'O/S/CC/') then begin
          iCurCompositeCurveRecord := keyIValueCompositeCurveList.GetIValueByKey(
              AnsiReplaceStr(sID, 'O/S/CC/', ''));
          if iCurCompositeCurveRecord < 0 then begin
            WriteLn(tfLog, Format('Геообъект %s: элемент %d массива geometry ссылается на несуществующую геометрию %s',
                [sCurrentID, i, sID]));
            Continue;
          end;
          SetLength(featureRecords[iCurFeatureRecord].fSPASArray[0].SPASArray, iCurrentGeometry + 1);
          with featureRecords[iCurFeatureRecord].fSPASArray[0].SPASArray[iCurrentGeometry] do begin
            RRNM := Ord(CompositeCurveRecordType);
            RRID := compositeCurveRecords[iCurCompositeCurveRecord].fCCID.RCID;
            if jsGeometry.Field['orientation'].Value = 'forward' then
              ORNT := 1
            else
              ORNT := 2;
            jsScaleRange := jsGeometry.Field['scaleRange'] as TlkJSONobject;
            if jsScaleRange <> nil then begin
              if jsScaleRange.Field['lower'] <> nil then
                SMIN := jsScaleRange.Field['lower'].Value;
              if jsScaleRange.Field['upper'] <> nil then
                SMAX := jsScaleRange.Field['upper'].Value;
            end;
            SAUI := 1;
          end;
          iCurrentGeometry := iCurrentGeometry + 1;
        end
        else if AnsiContainsStr(sID, 'O/S/S/') then begin
          iCurSurfaceRecord := keyIValueSurfaceList.GetIValueByKey(
              AnsiReplaceStr(sID, 'O/S/S/', ''));
          if iCurSurfaceRecord < 0 then begin
            WriteLn(tfLog, Format('Геообъект %s: элемент %d массива geometry ссылается на несуществующую геометрию %s',
                [sCurrentID, i, sID]));
            Continue;
          end;
          SetLength(featureRecords[iCurFeatureRecord].fSPASArray[0].SPASArray, iCurrentGeometry + 1);
          with featureRecords[iCurFeatureRecord].fSPASArray[0].SPASArray[iCurrentGeometry] do begin
            RRNM := Ord(SurfaceRecordType);
            RRID := surfaceRecords[iCurSurfaceRecord].fSRID.RCID;
            if (jsGeometry.Field['orientation'] = nil) or
                (jsGeometry.Field['orientation'].Value = 'forward') then
              ORNT := 1
            else
              ORNT := 2;
            jsScaleRange := jsGeometry.Field['scaleRange'] as TlkJSONobject;
            if jsScaleRange <> nil then begin
              if jsScaleRange.Field['lower'] <> nil then
                SMIN := jsScaleRange.Field['lower'].Value;
              if jsScaleRange.Field['upper'] <> nil then
                SMAX := jsScaleRange.Field['upper'].Value;
            end;
            SAUI := 1;
          end;
          iCurrentGeometry := iCurrentGeometry + 1;
        end;
      end;
      if iCurrentGeometry = 0 then
        SetLength(featureRecords[iCurFeatureRecord].fSPASArray, 0);
    end;

    // Обратное преобразование значения глубины в трехмерную мультиточку
    if g_convertSoundgMP3toP then begin
      WriteLn(tfLog, 'Обратное преобразование значения глубины в трехмерную мультиточку');
      SoundingToMultiPoints(jsPatch);
    end;
{
    // Исключаем концевые точки кривых из массива точек
    WriteLn(tfLog, 'Удаление лишних точек');
    /////////////////////////////////////////////////////////
    progress := TProgress(threadList.LockList[0]);
    progress.m_max := 0;
    progress.m_pos := 0;
    progress.m_Message := 'Удаление лишних точек';
    threadList.UnlockList;
    /////////////////////////////////////////////////////////
    SetLength(tempPointRecords, Length(pointRecords));
    for i := 0 to Length(pointRecords) - 1 do begin
      S101Copy(pointRecords[i], tempPointRecords[i]);
      ClearRec(pointRecords[i]);
    end;
    iCurPointRecord := 0;
    for i := 0 to Length(tempPointRecords) - 1 do begin
      sGUID := tempPointRecords[i].sGUID;
      if not ((slPointsToDelete.IndexOf(sGUID) >= 0) and
          (slFeaturePoints.IndexOf(sGUID) < 0)) then begin
        S101Copy(tempPointRecords[i], pointRecords[iCurPointRecord]);
        iCurPointRecord := iCurPointRecord + 1;
      end;
      ClearRec(tempPointRecords[i]);
    end;
    SetLength(pointRecords, iCurPointRecord);
    SetLength(tempPointRecords, 0);
}
    /////////////////////////////////////////////////////////
    // Проверка прерывания процесса пользователем
    suspendEvent.WaitFor($FFFFFFFF);
    if breakEvent.WaitFor(0) = wrSignaled then begin
      if calculationThread <> nil then
        calculationThread.m_nTermStatus := TERM_STATUS_USERSTOP;
      Exit;
    end;
    /////////////////////////////////////////////////////////
    Result := True;
  finally
    keyIValuePointList.Free;
    keyIValueMultiPointList.Free;
    keyIValueCurveList.Free;
    keyIValueCompositeCurveList.Free;
    keyIValueSurfaceList.Free;
    jsS101.Free;
    SetLength(buffer, 0);
    CloseFile(tfLog);
  end;
end;

procedure TS101DataSetJSON.TreeNodesToJSON(parentNode: TTreeNode; jsParent: TlkJSONobject);
var
  i, ii, code: Integer;
  childNode: TTreeNode;
  jsChild: TlkJSONobject;
  jsonList, jlComplexAttr: TlkJSONlist;
  sPreviousName: string;
  iBegin, iEnd: Integer;
  attributeItem: TAttributeItem;
  parentItem: TNamedItem;
  complexAttributeItem: TComplexAttributeItem;
  objectItem: TObjectItem;
  dValue: Double;
  iValue: Integer;
  bWrongValue: Boolean;
begin
  iBegin := 0;
  while iBegin < parentNode.children.Count do begin
    sPreviousName := TTreeNode(parentNode.children[iBegin]).name;
    iEnd := iBegin;
    for i := iBegin + 1 to parentNode.children.Count - 1 do
      if TTreeNode(parentNode.children[i]).name = sPreviousName then
        iEnd := i
      else
        Break;
    childNode := TTreeNode(parentNode.children[iBegin]);
    if iBegin < iEnd then begin
      bWrongValue := False;
      jsonList := TlkJSONlist.Create;
      if childNode.value = '' then begin
        for i := iBegin to iEnd do begin
          childNode := TTreeNode(parentNode.children[i]);
          jsChild := TlkJSONobject.Create;
          TreeNodesToJSON(childNode, jsChild);
          jsonList.Add(jsChild);
        end;
      end
      else begin
        for i := iBegin to iEnd do begin
          childNode := TTreeNode(parentNode.children[i]);
          // Требуется обработка значения типа enumeration
          attributeItem := s101Catalogue.items.GetItemByName(childNode.name) as TAttributeItem;
          if attributeItem.sValueType = 'enumeration' then begin
            Val(childNode.value, iValue, code);
            if code = 0 then
              jsonList.Add(iValue)
            else
              // Требуется отдельная обработка атрибутов lenge и NATION
              if (childNode.name = 'lenge') or ((childNode.name = 'NATION')) then
                for ii := 0 to Length(attributeItem.lListedValues) - 1 do begin
                  if attributeItem.lListedValues[ii].sDefinition = childNode.value then begin
                    jsonList.Add(attributeItem.lListedValues[ii].iCode);
                    Break;
                  end;
                end
              else begin
                jsonList.Add(childNode.value);
                bWrongValue := True;
              end;
          end
          else begin
            bWrongValue := True;
            jsonList.Add(childNode.value);
          end;
        end;
      end;
      if bWrongValue then
        jsParent.Add(childNode.name + g_wrongValueMarker, jsonList)
      else
        jsParent.Add(childNode.name, jsonList);
    end
    else begin
      if childNode.value <> '' then begin
        if s101Catalogue.items.GetItemByName(childNode.name) is TAttributeItem then begin
          attributeItem := s101Catalogue.items.GetItemByName(childNode.name) as TAttributeItem;
          if attributeItem <> nil then begin
            if attributeItem.sValueType = 'real' then begin
              Val(childNode.value, dValue, code);
              jsParent.Add(childNode.name, dValue);
            end
            else if attributeItem.sValueType = 'integer' then begin
              Val(childNode.value, iValue, code);
              jsParent.Add(childNode.name, iValue);
            end
            else if attributeItem.sValueType = 'boolean' then begin
              Val(childNode.value, iValue, code);
              jsParent.Add(childNode.name, iValue <> 0);
            end
            else if attributeItem.sValueType = 'enumeration' then begin
              Val(childNode.value, iValue, code);
              parentItem := s101Catalogue.items.GetItemByName(childNode.parent.name) as TNamedItem;
              if parentItem is TComplexAttributeItem then begin
                complexAttributeItem := parentItem as TComplexAttributeItem;
                for i := 0 to Length(complexAttributeItem.children) - 1 do
                  if complexAttributeItem.children[i].sCode = childNode.name then begin
                    if complexAttributeItem.children[i].multiplicity.upper = 1 then
                      if code = 0 then
                        jsParent.Add(childNode.name, iValue)
                      else
                        // Требуется отдельная обработка атрибутов lenge и NATION
                        if (childNode.name = 'lenge') or ((childNode.name = 'NATION')) then
                          for ii := 0 to Length(attributeItem.lListedValues) - 1 do begin
                            if attributeItem.lListedValues[ii].sDefinition = childNode.value then begin
                              jsParent.Add(childNode.name, attributeItem.lListedValues[ii].iCode);
                              Break;
                            end;
                          end
                        else
                          jsParent.Add(childNode.name + g_wrongValueMarker, childNode.value)
                    else begin
                      jsonList := TlkJSONlist.Create;
                      if code = 0 then begin
                        jsonList.Add(iValue);
                        jsParent.Add(childNode.name, jsonList);
                      end
                      else
                        // Требуется отдельная обработка атрибутов lenge и NATION
                        if (childNode.name = 'lenge') or ((childNode.name = 'NATION')) then
                          for ii := 0 to Length(attributeItem.lListedValues) - 1 do begin
                            if attributeItem.lListedValues[ii].sDefinition = childNode.value then begin
                              jsonList.Add(attributeItem.lListedValues[ii].iCode);
                              jsParent.Add(childNode.name, jsonList);
                              Break;
                            end;
                          end
                        else begin
                          jsonList.Add(childNode.value);
                          jsParent.Add(childNode.name + g_wrongValueMarker, jsonList);
                        end;
                    end;
                    Break;
                  end;
              end
              else if parentItem is TObjectItem then begin
                objectItem := parentItem as TObjectItem;
                for i := 0 to Length(objectItem.attributes) - 1 do
                  if objectItem.attributes[i].sCode = childNode.name then begin
                    if objectItem.attributes[i].multiplicity.upper = 1 then
                      if code = 0 then
                        jsParent.Add(childNode.name, iValue)
                      else
                        // Требуется отдельная обработка атрибутов lenge и NATION
                        if (childNode.name = 'lenge') or ((childNode.name = 'NATION')) then
                          for ii := 0 to Length(attributeItem.lListedValues) - 1 do begin
                            if attributeItem.lListedValues[ii].sDefinition = childNode.value then begin
                              jsParent.Add(childNode.name, attributeItem.lListedValues[ii].iCode);
                              Break;
                            end;
                          end
                        else
                          jsParent.Add(childNode.name + g_wrongValueMarker, childNode.value)
                    else begin
                      jsonList := TlkJSONlist.Create;
                      if code = 0 then begin
                        jsonList.Add(iValue);
                        jsParent.Add(childNode.name, jsonList);
                      end
                      else
                        // Требуется отдельная обработка атрибутов lenge и NATION
                        if (childNode.name = 'lenge') or ((childNode.name = 'NATION')) then
                          for ii := 0 to Length(attributeItem.lListedValues) - 1 do begin
                            if attributeItem.lListedValues[ii].sDefinition = childNode.value then begin
                              jsonList.Add(attributeItem.lListedValues[ii].iCode);
                              jsParent.Add(childNode.name, jsonList);
                              Break;
                            end;
                          end
                        else begin
                          jsonList.Add(childNode.value);
                          jsParent.Add(childNode.name + g_wrongValueMarker, jsonList);
                        end;
                    end;
                    Break;
                  end;
              end;
            end
            else
              jsParent.Add(childNode.name, childNode.value);
          end
          else
            jsParent.Add(childNode.name, childNode.value);
        end;
      end
      else begin
        jlComplexAttr := TlkJSONlist.Create;
        jsChild := TlkJSONobject.Create;
        jlComplexAttr.Add(jsChild);
        jsParent.Add(childNode.name, jlComplexAttr);
        TreeNodesToJSON(childNode, jsChild);
      end;
    end;
    iBegin := iEnd + 1;
  end;
end;

procedure TS101DataSetJSON.AttributesToJSON(sCode: string; attrArray: array of TATTRField;
    var jsAttributes: TlkJSONobject);
var
  rootNode, currentNode, newCurrentNode: TTreeNode;
  iATTR, iAttrElem, iPair: Integer;
  bFound: Boolean;
begin
  rootNode := TTreeNode.Create;
  rootNode.name := s101Catalogue.acronymPairs.GetOurByTheir(sCode);
  for iATTR := 0 to Length(attrArray) - 1 do begin
    currentNode := rootNode;
    for iAttrElem := 0 to Length(attrArray[iATTR].arrayOfAttrElem) - 1 do begin
      with attrArray[iATTR].arrayOfAttrElem[iAttrElem] do begin
        newCurrentNode := TTreeNode.Create;
        bFound := False;
        while not bFound do
          if currentNode.attrIndex = PAIX then
            bFound := True
          else
            currentNode := currentNode.parent;
        newCurrentNode.parent := currentNode;
        newCurrentNode.attrIndex := iAttrElem + 1;
        for iPair := 0 to Length(dsGeneralInfo.fATCS) - 1 do
          if dsGeneralInfo.fATCS[iPair].iCode = NATC then begin
            newCurrentNode.name := s101Catalogue.acronymPairs.GetOurByTheir(
                dsGeneralInfo.fATCS[iPair].sCode);
            Break;
          end;
        newCurrentNode.value := UTF8Decode(ATVL);
        currentNode.children.Add(newCurrentNode);
        currentNode := newCurrentNode;
      end;
    end;
  end;
  RemoveEmptyNodes(rootNode);
  TreeNodesToJSON(rootNode, jsAttributes);
end;

procedure TS101DataSetJSON.InfoAssociationsToJSON(sGUID, sSourceCode: string; fINASArray: array of TINASField;
    var jlAssociations: TlkJSONlist);
var
  jsAssociation: TlkJSONobject;
  iAssociation, iInfoObject, iPair, iBinding: Integer;
  sAssocCodeOur, sSourceCodeOur, sTargetCodeOur: string;
  featureOrInfoItem: TFeatureOrInfoItem;
  roleTypeOfBinding: TRoleTypeOfBinding;
begin
  for iAssociation := 0 to Length(fINASArray) - 1 do
    with fINASArray[iAssociation] do
      for iInfoObject := 0 to Length(infoTypeRecords) - 1 do
        if infoTypeRecords[iInfoObject].fIRID.RCID = RRID then begin
          jsAssociation := TlkJSONobject.Create;
          for iPair := 0 to Length(dsGeneralInfo.fARCS) - 1 do
            if dsGeneralInfo.fARCS[iPair].iCode = NARC then begin
              sAssocCodeOur := s101Catalogue.acronymPairs.GetOurByTheir(dsGeneralInfo.fARCS[iPair].sCode);
              jsAssociation.Add('associationCode', sAssocCodeOur);
              Break;
            end;
          sSourceCodeOur := s101Catalogue.acronymPairs.GetOurByTheir(sSourceCode);
          for iPair := 0 to Length(dsGeneralInfo.fITCS) - 1 do
            if dsGeneralInfo.fITCS[iPair].iCode = infoTypeRecords[iInfoObject].fIRID.NITC then begin
              sTargetCodeOur := s101Catalogue.acronymPairs.GetOurByTheir(dsGeneralInfo.fITCS[iPair].sCode);
              Break;
            end;
          roleTypeOfBinding := s101Catalogue.roleTypesOfBindings.GetItem(
              sSourceCodeOur, sTargetCodeOur, sAssocCodeOur);
          if roleTypeOfBinding = nil then
            raise Exception.CreateFmt('В каталоге не удалось найти связь %s->%s (%s)',
                [sSourceCodeOur, sTargetCodeOur, sAssocCodeOur]);
          jsAssociation.Add('roleCode', AssociationTypes[roleTypeOfBinding.m_iRoleType]);
          jsAssociation.Add('ref', 'O/F/' + infoTypeRecords[iInfoObject].m_sGUID);
          jlAssociations.Add(jsAssociation);
          references.Add(TReference.Create(sGUID, infoTypeRecords[iInfoObject].m_sGUID, roleTypeOfBinding));
          Break;
        end;
end;

procedure TS101DataSetJSON.FeatureAssociationsToJSON(sGUID, sSourceCode: string; fFASCArray: array of TFASCField;
    var jlAssociations: TlkJSONlist);
var
  jsAssociation: TlkJSONobject;
  iAssociation, iFeature, iPair, iBinding: Integer;
  sAssocCodeOur, sSourceCodeOur, sTargetCodeOur: string;
  featureItem: TFeatureItem;
  roleTypeOfBinding: TRoleTypeOfBinding;
begin
  for iAssociation := 0 to Length(fFASCArray) - 1 do
    with fFASCArray[iAssociation] do
      for iFeature := 0 to Length(featureRecords) - 1 do
        if featureRecords[iFeature].fFRID.RCID = RRID then begin
          jsAssociation := TlkJSONobject.Create;
          for iPair := 0 to Length(dsGeneralInfo.fARCS) - 1 do
            if dsGeneralInfo.fARCS[iPair].iCode = NARC then begin
              sAssocCodeOur := s101Catalogue.acronymPairs.GetOurByTheir(dsGeneralInfo.fARCS[iPair].sCode);
              jsAssociation.Add('associationCode', sAssocCodeOur);
              Break;
            end;
          sSourceCodeOur := s101Catalogue.acronymPairs.GetOurByTheir(sSourceCode);
          for iPair := 0 to Length(dsGeneralInfo.fFTCS) - 1 do
            if dsGeneralInfo.fFTCS[iPair].iCode = featureRecords[iFeature].fFRID.NFTC then begin
              sTargetCodeOur := s101Catalogue.acronymPairs.GetOurByTheir(dsGeneralInfo.fFTCS[iPair].sCode);
              Break;
            end;
          roleTypeOfBinding := s101Catalogue.roleTypesOfBindings.GetItem(
              sSourceCodeOur, sTargetCodeOur, sAssocCodeOur);
          if roleTypeOfBinding <> nil then begin
            jsAssociation.Add('roleCode', AssociationTypes[roleTypeOfBinding.m_iRoleType]);
            jsAssociation.Add('ref', 'O/F/' + featureRecords[iFeature].m_sGUID);
            jlAssociations.Add(jsAssociation);
            references.Add(TReference.Create(sGUID, featureRecords[iFeature].m_sGUID, roleTypeOfBinding));
          end;
          Break;
        end;
end;

function TS101DataSetJSON.CurveRecordToJSON(curveRecord: TCurveRec; var jsStartPoint,
    jsEndPoint, jsCurve: TlkJSONobject): Boolean;
var
  jlInternalPoints: TlkJSONlist;
  jsPoint: TlkJSONobject;
  nPointsInCurve, iPoint, nLists, i, startPointId, endPointId, iFound: Integer;
  x, y, xStart, yStart: Double;
  guid: TGUID;
  sGUID: string;
begin
  Result := False;
  if (Length(curveRecord.fSegmentArray) <> 1) or
      (curveRecord.fSegmentArray[0].fSEGH.INTP <> 4) then Exit;
  case curveRecord.ct of
    ct2I: nLists := Length(curveRecord.fSegmentArray[0].fC2ILArray);
    ct3I: nLists := Length(curveRecord.fSegmentArray[0].fC3ILArray);
    ct2F: nLists := Length(curveRecord.fSegmentArray[0].fC2FLArray);
    ct3F: nLists := Length(curveRecord.fSegmentArray[0].fC3FLArray);
  end;
  if nLists <> 1 then Exit;

  jsCurve := TlkJSONobject.Create;
  jsCurve.Add('id', curveRecord.fCRID.RCID);

  startPointId := -1;
  endPointId := -1;
  for i := 0 to Length(curveRecord.fPTAS.PTASArray) - 1 do
    if i = 0 then
      startPointId := curveRecord.fPTAS.PTASArray[i].RRID
    else
      endPointId := curveRecord.fPTAS.PTASArray[i].RRID;
  if startPointId > 0 then begin
    iFound := 0;
    for i := 0 to Length(pointRecords) - 1 do begin
      if pointRecords[i].fPRID.RCID = startPointId then begin
        jsCurve.Add('startPoint', 'O/S/P/' + pointRecords[i].sGUID);
        iFound := iFound + 1;
        if endPointId < 0 then begin
          jsCurve.Add('endPoint', 'O/S/P/' + pointRecords[i].sGUID);
          Break;
        end;
      end
      else if pointRecords[i].fPRID.RCID = endPointId then begin
        jsCurve.Add('endPoint', 'O/S/P/' + pointRecords[i].sGUID);
        iFound := iFound + 1;
      end;
      if iFound = 2 then
        Break;
    end;
  end;

  jlInternalPoints := TlkJSONlist.Create;
  case curveRecord.ct of
    ct2I: nPointsInCurve := Length(curveRecord.fSegmentArray[0].fC2ILArray[0].C2ITArray);
    ct3I: nPointsInCurve := Length(curveRecord.fSegmentArray[0].fC3ILArray[0].C3ITArray);
    ct2F: nPointsInCurve := Length(curveRecord.fSegmentArray[0].fC2FLArray[0].C2FTArray);
    ct3F: nPointsInCurve := Length(curveRecord.fSegmentArray[0].fC3FLArray[0].C3FTArray);
  end;
  for iPoint := 0 to nPointsInCurve - 1 do begin
    case curveRecord.ct of
      ct2I:
        with curveRecord.fSegmentArray[0].fC2ILArray[0].C2ITArray[iPoint] do begin
          x := dsGeneralInfo.fDSSI.DCOX + XCOO / dsGeneralInfo.fDSSI.CMFX;
          y := dsGeneralInfo.fDSSI.DCOY + YCOO / dsGeneralInfo.fDSSI.CMFY;
        end;
      ct3I:
        with curveRecord.fSegmentArray[0].fC3ILArray[0].C3ITArray[iPoint] do begin
          x := dsGeneralInfo.fDSSI.DCOX + XCOO / dsGeneralInfo.fDSSI.CMFX;
          y := dsGeneralInfo.fDSSI.DCOY + YCOO / dsGeneralInfo.fDSSI.CMFY;
        end;
      ct2F:
        with curveRecord.fSegmentArray[0].fC2FLArray[0].C2FTArray[iPoint] do begin
          x := dsGeneralInfo.fDSSI.DCOX + XCOO;
          y := dsGeneralInfo.fDSSI.DCOY + YCOO;
        end;
      ct3F:
        with curveRecord.fSegmentArray[0].fC3FLArray[0].C3FTArray[iPoint] do begin
          x := dsGeneralInfo.fDSSI.DCOX + XCOO;
          y := dsGeneralInfo.fDSSI.DCOY + YCOO;
        end;
    end;
    if (iPoint = nPointsInCurve - 1) and (x = xStart) and (y = yStart) then begin
      if startPointId < 0 then
        jsCurve.Add('endPoint', string(jsCurve.Field['startPoint'].Value));
    end
    else begin
      jsPoint := TlkJSONobject.Create;
      jsPoint.Add('lat', y);
      jsPoint.Add('lon', x);
      if (iPoint = 0) or (iPoint = nPointsInCurve - 1) then begin
        if iPoint = 0 then
          jsStartPoint := jsPoint
        else
          jsEndPoint := jsPoint;
        if startPointId < 0 then begin
          CreateGUID(guid);
          sGUID := GUIDToString(guid);
          sGUID := MidStr(sGUID, 2, Length(sGUID) - 2);
          if iPoint = 0 then begin
            //jsStartPoint := jsPoint;
            jsCurve.Add('startPoint', 'O/S/P/' + sGUID);
            xStart := x;
            yStart := y;
          end
          else begin
            //jsEndPoint := jsPoint;
            jsCurve.Add('endPoint', 'O/S/P/' + sGUID);
          end;
        end;
      end
      else
        jlInternalPoints.Add(jsPoint);
    end;
  end;
  jsCurve.Add('interpolationType', InterpolationTypes[curveRecord.fSegmentArray[0].fSEGH.INTP - 1]);
  jsCurve.Add('internalPoints', jlInternalPoints);
  Result := True;
end;

function TS101DataSetJSON.CompositeCurveRecordToJSON(compositeCurveRecord: TCompositeCurveRec;
    var jsSumStartPoint, jsSumEndPoint, jsSumCurve: TlkJSONobject; ccOrientation: Integer): Boolean;
var
  i, nCurveComponents, iCurveComponent, iCurveRec, iCompositeCurveRec: Integer;
  jsPoint, jsStartPoint, jsEndPoint, jsCurve, jsSumPoint: TlkJSONobject;
  jlInternalPoints, jlSumInternalPoints: TlkJSONlist;
  ccComponentOrientation: Integer;
begin
  Result := False;
  if Length(compositeCurveRecord.fCUCOArray) <> 1 then Exit;
  nCurveComponents := Length(compositeCurveRecord.fCUCOArray[0].CUCOArray);
  if ccOrientation = 1 then
    iCurveComponent := 0
  else
    iCurveComponent := nCurveComponents - 1;
  while (iCurveComponent >= 0) and (iCurveComponent < nCurveComponents) do
    with compositeCurveRecord.fCUCOArray[0].CUCOArray[iCurveComponent] do begin
      if ccOrientation = 1 then
        ccComponentOrientation := ORNT
      else if ORNT = 1 then
        ccComponentOrientation := 2
      else
        ccComponentOrientation := 1;
      if RRNM = Ord(CompositeCurveRecordType) then begin
        for iCompositeCurveRec := 0 to Length(compositeCurveRecords) - 1 do
          if compositeCurveRecords[iCompositeCurveRec].fCCID.RCID = RRID then begin
            if not CompositeCurveRecordToJSON(compositeCurveRecords[iCompositeCurveRec],
              jsSumStartPoint, jsSumEndPoint, jsSumCurve, ccComponentOrientation) then Exit;
            Break;
          end;
      end
      else if RRNM = Ord(CurveRecordType) then begin
        for iCurveRec := 0 to Length(curveRecords) - 1 do
          if (curveRecords[iCurveRec].fCRID.RCID = RRID) then begin
            jsCurve := nil;
            jsStartPoint := nil;
            jsEndPoint := nil;
            if not CurveRecordToJSON(curveRecords[iCurveRec], jsStartPoint, jsEndPoint, jsCurve) then
              Exit;
            if jsSumCurve = nil then begin
              jsSumCurve := TlkJSONobject.Create;
              jlSumInternalPoints := TlkJSONlist.Create;
              jsSumCurve.Add('internalPoints', jlSumInternalPoints);
            end
            else
              jlSumInternalPoints := jsSumCurve.Field['internalPoints'] as TlkJSONlist;
            if ccComponentOrientation = 1 then begin
              if jsSumStartPoint = nil then begin
                jsSumStartPoint := jsStartPoint;
                jsStartPoint := nil;
                jsSumCurve.Add('startPoint', string(jsCurve.Field['startPoint'].Value));
              end
              else begin
                jlSumInternalPoints.Add(jsStartPoint);
                jsStartPoint := nil;
              end;
            end
            else begin
              if jsSumStartPoint = nil then begin
                jsSumStartPoint := jsEndPoint;
                jsEndPoint := nil;
                jsSumCurve.Add('startPoint', string(jsCurve.Field['endPoint'].Value));
              end
              else begin
                jlSumInternalPoints.Add(jsEndPoint);
                jsEndPoint := nil;
              end;
            end;
            jlInternalPoints := jsCurve.Field['internalPoints'] as TlkJSONlist;
            if ccComponentOrientation = 1 then begin
              for i := 0 to jlInternalPoints.Count - 1 do begin
                jsPoint := jlInternalPoints.Child[i] as TlkJSONobject;
                jsSumPoint := TlkJSONobject.Create;
                jsSumPoint.Add('lat', Double(jsPoint.Field['lat'].Value));
                jsSumPoint.Add('lon', Double(jsPoint.Field['lon'].Value));
                jlSumInternalPoints.Add(jsSumPoint);
              end;
              if jsSumEndPoint = nil then
                jsSumCurve.Add('endPoint', string(jsCurve.Field['endPoint'].Value))
              else begin
                jsSumEndPoint.Free;
                jsSumEndPoint := nil;
                jsSumCurve.Field['endPoint'].Value := jsCurve.Field['endPoint'].Value;
              end;
              jsSumEndPoint := jsEndPoint;
              jsEndPoint := nil;
            end
            else begin
              for i := jlInternalPoints.Count - 1 downto 0 do begin
                jsPoint := jlInternalPoints.Child[i] as TlkJSONobject;
                jsSumPoint := TlkJSONobject.Create;
                jsSumPoint.Add('lat', Double(jsPoint.Field['lat'].Value));
                jsSumPoint.Add('lon', Double(jsPoint.Field['lon'].Value));
                jlSumInternalPoints.Add(jsSumPoint);
              end;
              if jsSumEndPoint = nil then
                jsSumCurve.Add('endPoint', string(jsCurve.Field['startPoint'].Value))
              else begin
                jsSumEndPoint.Free;
                jsSumEndPoint := nil;
                jsSumCurve.Field['endPoint'].Value := jsCurve.Field['startPoint'].Value;
              end;
              jsSumEndPoint := jsStartPoint;
              jsStartPoint := nil;
            end;
            if jsSumCurve.Field['interpolationType'] <> nil then
              jsSumCurve.Field['interpolationType'].Value := jsCurve.Field['interpolationType'].Value
            else
              jsSumCurve.Add('interpolationType', string(jsCurve.Field['interpolationType'].Value));
            jsCurve.Free;
            jsStartPoint.Free;
            jsEndPoint.Free;
            Break;
          end;
      end
      else
        Exit;
      if ccOrientation = 1 then
        iCurveComponent := iCurveComponent + 1
      else
        iCurveComponent := iCurveComponent - 1;
    end;
  Result := True;
end;

procedure TS101DataSetJSON.InfoAssociationsFromJSON(sCode: string; jlAssociations: TlkJSONlist;
    var fINASArray: TArrayOfINASField);
var
  iAssoc, iInfoAssoc, iInfo, iIACS, iARCS, iPos: Integer;
  jsAssociation: TlkJSONobject;
  sID, sAssociation, sAssociationTheir, sRoleTheir: string;
  roleTypeOfBinding: TRoleTypeOfBinding;
begin
  if (jlAssociations = nil) or (jlAssociations.Count = 0) then
    Exit;
  iInfoAssoc := 0;
  for iAssoc := 0 to jlAssociations.Count - 1 do begin
    if not (jlAssociations.Child[iAssoc] is TlkJSONobject) then begin
      WriteLn(tfLog, Format('Объект %s: ассоциация %d не является объектом', [sCurrentID, iAssoc]));
      Continue;
    end;
    jsAssociation := jlAssociations.Child[iAssoc] as TlkJSONobject;
    if jsAssociation.Field['ref'] = nil then begin
//      WriteLn(tfLog, Format('Объект %s: ассоциация %d не имеет свойства ref', [sCurrentID, iAssoc]));
      Continue;
    end;
    sID := jsAssociation.Field['ref'].Value;
    for iInfo := 0 to Length(infoTypeRecords) - 1 do
      if sID = 'O/F/' + infoTypeRecords[iInfo].m_sGUID then
        Break;
    if iInfo = Length(infoTypeRecords) then begin
//      WriteLn(tfLog, Format('Объект %s: целевой объект ассоциации %s не найден в массиве информационных объектов',
//          [sCurrentID, sID]));
      Continue;
    end;
    SetLength(fINASArray, iInfoAssoc + 1);
    with fINASArray[iInfoAssoc] do begin
      RRNM := Ord(InfoRecordType);
      RRID := infoTypeRecords[iInfo].fIRID.RCID;
      if jsAssociation.Field['associationCode'] = nil then begin
        WriteLn(tfLog, Format('Объект %s: ассоциация с объектом %s не имеет свойства associationCode',
            [sCurrentID, sID]));
        Continue;
      end;
      sAssociation := jsAssociation.Field['associationCode'].Value;
      iPos := AnsiPos('$', sAssociation);
      if iPos > 0 then
        sAssociation := AnsiMidStr(sAssociation, iPos + 1, Length(sAssociation) - iPos);
      roleTypeOfBinding := s101Catalogue.roleTypesOfBindings.GetItem(sCode,
          infoTypeRecords[iInfo].m_sCode, sAssociation);
      if roleTypeOfBinding = nil then begin
        WriteLn(tfLog, Format('Объект %s: связь (%s, %s, %s) не найдена в ассоциативном массиве roleTypeOfBinding',
            [sCurrentID, sCode, infoTypeRecords[iInfo].m_sCode, sAssociation]));
        Continue;
      end;
      sAssociationTheir := s101Catalogue.acronymPairs.GetTheirByOur(roleTypeOfBinding.m_sAssociation);
      if sAssociationTheir = '' then begin
        WriteLn(tfLog, Format('Объект %s: ассоциация %s отсутствует в S-101',
            [sCurrentID, roleTypeOfBinding.m_sAssociation]));
        Continue;
      end;
      for iIACS := 0 to Length(dsGeneralInfo.fIACS) - 1 do
        if dsGeneralInfo.fIACS[iIACS].sCode = sAssociationTheir then begin
          NIAC := dsGeneralInfo.fIACS[iIACS].iCode;
          Break;
        end;
      if iIACS = Length(dsGeneralInfo.fIACS) then begin
        WriteLn(tfLog, Format('Объект %s: для ассоциации %s не найден числовой код',
            [sCurrentID, sAssociationTheir]));
        Continue;
      end;
      sRoleTheir := s101Catalogue.acronymPairs.GetTheirByOur(roleTypeOfBinding.m_sRole);
      if sRoleTheir = '' then begin
        WriteLn(tfLog, Format('Объект %s: роль %s отсутствует в S-101',
            [sCurrentID, roleTypeOfBinding.m_sRole]));
        Continue;
      end;
      for iARCS := 0 to Length(dsGeneralInfo.fARCS) - 1 do
        if dsGeneralInfo.fARCS[iARCS].sCode = sRoleTheir then begin
          NARC := dsGeneralInfo.fARCS[iARCS].iCode;
          Break;
        end;
      if iARCS = Length(dsGeneralInfo.fARCS) then begin
        WriteLn(tfLog, Format('Объект %s: для роли %s не найден числовой код',
            [sCurrentID, sRoleTheir]));
        Continue;
      end;
      IUIN := 1;
      AttributesFromJSON(sCode, TlkJSONobject(jsAssociation.Field['attributes']),
          TArrayOfAttrElem(arrayOfAttrElem));
      iInfoAssoc := iInfoAssoc + 1;
    end;
  end;
end;

procedure TS101DataSetJSON.FeatureAssociationsFromJSON(sCode: string; jlAssociations: TlkJSONlist;
    var fFASCArray: TArrayOfFASCField);
var
  iAssoc, iFeatureAssoc, iFeature, iFACS, iARCS, iPos: Integer;
  jsAssociation: TlkJSONobject;
  sID, sAssociation, sAssociationTheir, sRoleTheir: string;
  roleTypeOfBinding: TRoleTypeOfBinding;
begin
  if (jlAssociations = nil) or (jlAssociations.Count = 0) then
    Exit;
  iFeatureAssoc := 0;
  for iAssoc := 0 to jlAssociations.Count - 1 do begin
    if not (jlAssociations.Child[iAssoc] is TlkJSONobject) then begin
      WriteLn(tfLog, Format('Объект %s: ассоциация %d не является объектом', [sCurrentID, iAssoc]));
      Continue;
    end;
    jsAssociation := jlAssociations.Child[iAssoc] as TlkJSONobject;
    if jsAssociation.Field['ref'] = nil then begin
//      WriteLn(tfLog, Format('Объект %s: ассоциация %d не имеет свойства ref', [sCurrentID, iAssoc]));
      Continue;
    end;
    sID := jsAssociation.Field['ref'].Value;
    for iFeature := 0 to Length(featureRecords) - 1 do
      if sID = 'O/F/' + featureRecords[iFeature].m_sGUID then
        Break;
    if iFeature = Length(featureRecords) then begin
//      WriteLn(tfLog, Format('Объект %s: целевой объект ассоциации %s не найден в массиве геообъектов',
//          [sCurrentID, sID]));
      Continue;
    end;
    SetLength(fFASCArray, iFeatureAssoc + 1);
    with fFASCArray[iFeatureAssoc] do begin
      RRNM := Ord(FeatureRecordType);
      RRID := featureRecords[iFeature].fFRID.RCID;
      if jsAssociation.Field['associationCode'] = nil then begin
        WriteLn(tfLog, Format('Объект %s: ассоциация с объектом %s не имеет свойства associationCode',
            [sCurrentID, sID]));
        Continue;
      end;
      sAssociation := jsAssociation.Field['associationCode'].Value;
      iPos := AnsiPos('$', sAssociation);
      if iPos > 0 then
        sAssociation := AnsiMidStr(sAssociation, iPos + 1, Length(sAssociation) - iPos);
      roleTypeOfBinding := s101Catalogue.roleTypesOfBindings.GetItem(sCode,
          featureRecords[iFeature].m_sCode, sAssociation);
      if roleTypeOfBinding = nil then begin
        WriteLn(tfLog, Format('Объект %s: связь (%s, %s, %s) не найдена в ассоциативном массиве roleTypeOfBinding',
            [sCurrentID, sCode, featureRecords[iFeature].m_sCode, sAssociation]));
        Continue;
      end;
      if roleTypeOfBinding.m_sAssociation = '' then begin
        WriteLn(tfLog, Format('Объект %s: связь с объектом %s не входит в какую-либо ассоциацию', [sCurrentID, sID]));
        Continue;
      end;
      sAssociationTheir := s101Catalogue.acronymPairs.GetTheirByOur(roleTypeOfBinding.m_sAssociation);
      if sAssociationTheir = '' then begin
        WriteLn(tfLog, Format('Объект %s: ассоциация %s отсутствует в S-101',
            [sCurrentID, roleTypeOfBinding.m_sAssociation]));
        Continue;
      end;
      for iFACS := 0 to Length(dsGeneralInfo.fFACS) - 1 do
        if dsGeneralInfo.fFACS[iFACS].sCode = sAssociationTheir then begin
          NFAC := dsGeneralInfo.fFACS[iFACS].iCode;
          Break;
        end;
      if iFACS = Length(dsGeneralInfo.fFACS) then begin
        WriteLn(tfLog, Format('Объект %s: для ассоциации %s не найден числовой код',
            [sCurrentID, sAssociationTheir]));
        Continue;
      end;
      sRoleTheir := s101Catalogue.acronymPairs.GetTheirByOur(roleTypeOfBinding.m_sRole);
      if sRoleTheir = '' then begin
        WriteLn(tfLog, Format('Объект %s: роль %s отсутствует в S-101',
            [sCurrentID, roleTypeOfBinding.m_sRole]));
        Continue;
      end;
      for iARCS := 0 to Length(dsGeneralInfo.fARCS) - 1 do
        if dsGeneralInfo.fARCS[iARCS].sCode = sRoleTheir then begin
          NARC := dsGeneralInfo.fARCS[iARCS].iCode;
          Break;
        end;
      if iARCS = Length(dsGeneralInfo.fARCS) then begin
        WriteLn(tfLog, Format('Объект %s: для роли %s не найден числовой код',
            [sCurrentID, sRoleTheir]));
        Continue;
      end;
      FAUI := 1;
      AttributesFromJSON(sCode, TlkJSONobject(jsAssociation.Field['attributes']),
          TArrayOfAttrElem(arrayOfAttrElem));
      iFeatureAssoc := iFeatureAssoc + 1;
    end;
  end;
end;

function TS101DataSetJSON.AddMandatoryAttributes(sCode: string; ssAttributesNames: TStrings;
    var arrayOfAttrElem: TArrayOfAttrElem; curPAIX: Integer): Boolean;
var
  item: TItem;
  attributes: TAttributeRefArray;
  i, nAttributes, nATCS, iATCS: Integer;
  sAttrNameTheir: string;
begin
  Result := False;
  if (sCode = '') or (curPAIX < 0) then
    Exit;
  item := s101Catalogue.items.GetItemByName(sCode);
  if item = nil then
    Exit;
  if item is TObjectItem then
    attributes := TAttributeRefArray(TObjectItem(item).attributes)
  else if item is TComplexAttributeItem then
    attributes := TAttributeRefArray(TComplexAttributeItem(item).children)
  else
    Exit;
  for i := 0 to Length(attributes) - 1 do
    if (attributes[i].multiplicity.lower >= 1) and ((ssAttributesNames = nil) or
        (ssAttributesNames.IndexOf(attributes[i].sCode) < 0)) then begin
      item := s101Catalogue.items.GetItemByName(attributes[i].sCode);
      if item = nil then
        Exit;
      if not (item is TAttributeItem) and not (item is TComplexAttributeItem) then
        Exit;
      sAttrNameTheir := s101Catalogue.acronymPairs.GetTheirByOur(attributes[i].sCode);
      if sAttrNameTheir = '' then
        Continue;
      nATCS := Length(dsGeneralInfo.fATCS);
      for iATCS := 0 to nATCS - 1 do
        if dsGeneralInfo.fATCS[iATCS].sCode = sAttrNameTheir then
          Break;
      if iATCS = nATCS then
        Continue;
      nAttributes := Length(arrayOfAttrElem);
      SetLength(arrayOfAttrElem, nAttributes + 1);
      with arrayOfAttrElem[nAttributes] do begin
        NATC := dsGeneralInfo.fATCS[iATCS].iCode;
        ATIX := 1;
        PAIX := curPAIX;
        ATIN := 1;
        ATVL := '';
      end;
      if item is TComplexAttributeItem then
        if not AddMandatoryAttributes(attributes[i].sCode, nil, arrayOfAttrElem,
            Length(arrayOfAttrElem)) then
          Exit;
    end;
    Result := True;
end;

procedure TS101DataSetJSON.AttributesFromJSON(sCode: string; jsAttributes: TlkJSONobject;
    var arrayOfAttrElem: TArrayOfAttrElem);
var
  i, ii, iValue, nAttributes, iATCS, nATCS, curPAIX, iListedValue: Integer;
  sAttrName, sAttrNameTheir: string;
  bValue: Boolean;
  dValue: Double;
  jlAttrArray: TlkJSONlist;
  attributeItem: TAttributeItem;
  ssFoundAttributes: TStrings;
  formatSettings: TFormatSettings;
begin
  if jsAttributes = nil then
    Exit;
  ssFoundAttributes := TStringList.Create;
  curPAIX := Length(arrayOfAttrElem);
  for i := 0 to jsAttributes.Count - 1 do begin
    sAttrName := jsAttributes.NameOf[i];
    if (sAttrName = 'updStatus') and not m_bPreserveUpdateStatus then
      Continue;
    sAttrNameTheir := s101Catalogue.acronymPairs.GetTheirByOur(sAttrName);
    if sAttrNameTheir = '' then begin
//      if (sAttrName <> 'locID') and not ((sCode = 'SOUNDG') and (sAttrName = 'VALSOU_')) then
      WriteLn(tfLog, 'Объект ' + sCurrentID + ': атрибуту ' + sAttrName + ' не найдено соответствие в S101');
      Continue;
    end;
    nATCS := Length(dsGeneralInfo.fATCS);
    for iATCS := 0 to nATCS - 1 do
      if dsGeneralInfo.fATCS[iATCS].sCode = sAttrNameTheir then
        Break;
    if iATCS = nATCS then begin
      WriteLn(tfLog, 'Объект ' + sCurrentID + ': для атрибута ' + sAttrNameTheir + ' не найден числовой код');
      Continue;
    end;
    ssFoundAttributes.Add(sAttrName);
    if jsAttributes.FieldByIndex[i] is TlkJSONlist then begin
      jlAttrArray := jsAttributes.FieldByIndex[i] as TlkJSONlist;
      for ii := 0 to jlAttrArray.Count - 1 do begin
        nAttributes := Length(arrayOfAttrElem);
        SetLength(arrayOfAttrElem, nAttributes + 1);
        with arrayOfAttrElem[nAttributes] do begin
          NATC := dsGeneralInfo.fATCS[iATCS].iCode;
          ATIX := ii + 1;
          PAIX := curPAIX;
          ATIN := 1;
          if jlAttrArray.Child[ii] is TlkJSONnumber then begin
            iValue := TlkJSONnumber(jlAttrArray.Child[ii]).Value;
            // Требуется отдельная обработка атрибута NATION
            if sAttrName = 'NATION' then begin
              attributeItem := s101Catalogue.items.GetItemByName(sAttrName) as TAttributeItem;
              for iListedValue := 0 to Length(attributeItem.lListedValues) - 1 do
                if attributeItem.lListedValues[iListedValue].iCode = iValue then begin
                  ATVL := attributeItem.lListedValues[iListedValue].sDefinition;
                  Break;
                end;
              if iListedValue = Length(attributeItem.lListedValues) then begin
                WriteLn(tfLog, Format('Объект %s: в списке возможных значений атрибута %s не найден числовой код %d',
                    [sCurrentID, sAttrName, iValue]));
                ATVL := '';
              end;
            end
            else
              Str(iValue, ATVL);
          end
          else if jlAttrArray.Child[ii] is TlkJSONstring then
            ATVL := UTF8Encode(WideString(TlkJSONstring(jlAttrArray.Child[ii]).Value))
          else if (jlAttrArray.Child[ii] is TlkJSONobject) then begin
            ATVL := '';
            AttributesFromJSON(sAttrName, TlkJSONobject(jlAttrArray.Child[ii]), arrayOfAttrElem);
          end;
        end;
      end;
    end
    else begin
      nAttributes := Length(arrayOfAttrElem);
      SetLength(arrayOfAttrElem, nAttributes + 1);
      with arrayOfAttrElem[nAttributes] do begin
        NATC := dsGeneralInfo.fATCS[iATCS].iCode;
        ATIX := 1;
        PAIX := curPAIX;
        ATIN := 1;
        if jsAttributes.FieldByIndex[i] is TlkJSONnumber then begin
          dValue := TlkJSONnumber(jsAttributes.FieldByIndex[i]).Value;
          // Требуется отдельная обработка атрибута lenge
          if sAttrName = 'lenge' then begin
            attributeItem := s101Catalogue.items.GetItemByName(sAttrName) as TAttributeItem;
            for iListedValue := 0 to Length(attributeItem.lListedValues) - 1 do
              if attributeItem.lListedValues[iListedValue].iCode = iValue then begin
                ATVL := attributeItem.lListedValues[iListedValue].sDefinition;
                Break;
              end;
            if iListedValue = Length(attributeItem.lListedValues) then begin
              WriteLn(tfLog, Format('Объект %s: в списке возможных значений атрибута %s не найден числовой код %d',
                  [sCurrentID, sAttrName, iValue]));
              ATVL := '';
            end;
          end
          else begin
            GetLocaleFormatSettings(LOCALE_USER_DEFAULT, formatSettings);
            formatSettings.DecimalSeparator := '.';
            ATVL := Format('%g', [dValue], formatSettings);
          end;
        end
        else if jsAttributes.FieldByIndex[i] is TlkJSONboolean then begin
          bValue := TlkJSONboolean(jsAttributes.FieldByIndex[i]).Value;
          Str(Integer(bValue), ATVL);
        end
        else if jsAttributes.FieldByIndex[i] is TlkJSONstring then
          ATVL := UTF8Encode(WideString(jsAttributes.FieldByIndex[i].Value))
        else if jsAttributes.FieldByIndex[i] is TlkJSONnull then
          ATVL := ''
        else if jsAttributes.FieldByIndex[i] is TlkJSONobject then begin
          ATVL := '';
          AttributesFromJSON(sAttrName, TlkJSONobject(jsAttributes.FieldByIndex[i]), arrayOfAttrElem);
        end;
      end;
    end;
  end;
  AddMandatoryAttributes(sCode, ssFoundAttributes, arrayOfAttrElem, curPAIX);
  ssFoundAttributes.Free;
end;

procedure TS101DataSetJSON.RemoveEmptyNodes(parentNode: TTreeNode);
var
  i: Integer;
  childNode: TTreeNode;
begin
  for i := parentNode.children.Count - 1 downto 0 do begin
    childNode := TTreeNode(parentNode.children[i]);
    if childNode.value = '' then begin
      if childNode.children.Count > 0 then
        RemoveEmptyNodes(childNode);
      if childNode.children.Count = 0 then
        parentNode.children.Delete(i);
    end;
  end;
end;

function TS101DataSetJSON.CheckAndCloseRing(sGUID: string; jsPatch: TlkJSONobject; bClose: Boolean): Boolean;
var
  jl: TlkJSONlist;
  jsCurve, jsStartPoint, jsEndPoint, jsPoint: TlkJSONobject;
begin
  Result := False;
  if (sGUID = '') or (jsPatch = nil) then Exit;
  jl := jsPatch.Field['O/S/C/' + sGUID] as TlkJSONlist;
  if jl = nil then Exit;
  jsCurve := jl.Child[0] as TlkJSONobject;
  jl := jsPatch.Field[jsCurve.Field['startPoint'].Value] as TlkJSONlist;
  if jl = nil then Exit;
  jsStartPoint := jl.Child[0] as TlkJSONobject;
  jl := jsPatch.Field[jsCurve.Field['endPoint'].Value] as TlkJSONlist;
  if jl = nil then Exit;
  jsEndPoint := jl.Child[0] as TlkJSONobject;
  if (jsStartPoint.Field['lon'].Value <> jsEndPoint.Field['lon'].Value) or
      (jsStartPoint.Field['lat'].Value <> jsEndPoint.Field['lat'].Value) then begin
    if not bClose then Exit;
    jl := jsCurve.Field['internalPoints'] as TlkJSONlist;
    jsPoint := TlkJSONobject.Create;
    jsPoint.Add('lat', Double(jsEndPoint.Field['lat'].Value));
    jsPoint.Add('lon', Double(jsEndPoint.Field['lon'].Value));
    jl.Add(jsPoint);
    jsEndPoint.Field['lat'].Value := jsStartPoint.Field['lat'].Value;
    jsEndPoint.Field['lon'].Value := jsStartPoint.Field['lon'].Value;
  end;
  Result := True;
end;

procedure TS101DataSetJSON.FillCodeTables;
var
  iItem: Integer;
  namedItem: TNamedItem;
  nATCS, nITCS, nFTCS, nIACS, nFACS, nARCS: Integer;
  sCode: string;
begin
  nATCS := 0;
  nITCS := 0;
  nFTCS := 0;
  nIACS := 0;
  nFACS := 0;
  nARCS := 0;
  for iItem := 0 to s101Catalogue.items.Count - 1 do begin
    if s101Catalogue.items[iItem] is TNamedItem then begin
      namedItem := s101Catalogue.items[iItem] as TNamedItem;
      sCode := s101Catalogue.acronymPairs.GetTheirByOur(namedItem.sCode);
      if sCode = '' then
        Continue;
      if (namedItem.sType = 'Attribute') or (namedItem.sType = 'ComplexAttribute') then begin
        SetLength(dsGeneralInfo.fATCS, nATCS + 1);
        dsGeneralInfo.fATCS[nATCS].iCode := nATCS + 1;
        dsGeneralInfo.fATCS[nATCS].sCode := sCode;
        nATCS := nATCS + 1;
      end
      else if namedItem.sType = 'Information' then begin
        SetLength(dsGeneralInfo.fITCS, nITCS + 1);
        dsGeneralInfo.fITCS[nITCS].iCode := nITCS + 1;
        dsGeneralInfo.fITCS[nITCS].sCode := sCode;
        nITCS := nITCS + 1;
      end
      else if namedItem.sType = 'Feature' then begin
        SetLength(dsGeneralInfo.fFTCS, nFTCS + 1);
        dsGeneralInfo.fFTCS[nFTCS].iCode := nFTCS + 1;
        dsGeneralInfo.fFTCS[nFTCS].sCode := sCode;
        nFTCS := nFTCS + 1;
      end
      else if namedItem.sType = 'InformationAssociation' then begin
        SetLength(dsGeneralInfo.fIACS, nIACS + 1);
        dsGeneralInfo.fIACS[nIACS].iCode := nIACS + 1;
        dsGeneralInfo.fIACS[nIACS].sCode := sCode;
        nIACS := nIACS + 1;
      end
      else if namedItem.sType = 'FeatureAssociation' then begin
        SetLength(dsGeneralInfo.fFACS, nFACS + 1);
        dsGeneralInfo.fFACS[nFACS].iCode := nFACS + 1;
        dsGeneralInfo.fFACS[nFACS].sCode := sCode;
        nFACS := nFACS + 1;
      end
      else if namedItem.sType = 'Role' then begin
        SetLength(dsGeneralInfo.fARCS, nARCS + 1);
        dsGeneralInfo.fARCS[nARCS].iCode := nARCS + 1;
        dsGeneralInfo.fARCS[nARCS].sCode := sCode;
        nARCS := nARCS + 1;
      end;
    end;
  end;
end;

end.
