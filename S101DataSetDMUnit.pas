unit S101DataSetDMUnit;

interface

uses
  Classes, Windows, SysUtils, StrUtils, Contnrs, OTypes, dmw_Use, obj_use, S101CatalogueUnit,
      S101TypesUnit, S101BinaryAccessUnit, S101DataSetUnit, DMChainToJSONUnit;

type
  TAttrElemArray = array of TAttrElem;
  TATTRFieldArray = array of TATTRField;
  TINASFieldArray = array of TINASField;
  TFASCFieldArray = array of TFASCField;

  TS101DataSetDM = class(TS101DataSet)
    orderedFeatures: TObjectList;
    constructor Create(catalogue: TS101Catalogue);
    destructor Destroy; override;
    function S101FromDM(mapPath: string; var sError: string): Boolean;
    function PointsFromDM(var dmChainToJSON: TDMChainToJSON): Boolean;
    function MultipointFromDM(var dmChainToJSON: TDMChainToJSON; multipointId: Integer): Boolean;
    function CurvesFromDM(var dmChainToJSON: TDMChainToJSON): Boolean;
    function CompositesFromDM(var dmChainToJSON: TDMChainToJSON): Boolean;
    function SurfacesFromDM(var dmChainToJSON: TDMChainToJSON): Boolean;
    function ObjectAttributesFromDM(var fATTRArray: TATTRFieldArray; curPAIX: Integer = 0): Boolean;
    function FeatureAssociationsFromDM(feature: TFeature; features: TObjectList;
        featuresPosIds: TPosIdPairList; var fINASArray: TINASFieldArray;
        var fFASCArray: TFASCFieldArray): Boolean;
//    function ObjectsFromDM(var dmChainToJSON: TDMChainToJSON): Boolean;
//    function InfoObjectsFromDM(var dmChainToJSON: TDMChainToJSON): Boolean;
    function Change2dTo3dPoint(pointId: Integer): Boolean;
    function S101ToDM(dmPath: string; var sError: string): Boolean;
    function GetCompositeGeometry(id, orient: Integer; compositesPosIds, curvesPosIds: TPosIdPairList;
        var pXYLine: PLLine): Boolean;
    function GetCurveGeometry(id, orient: Integer; curvesPosIds: TPosIdPairList;
        var pXYLine: PLLine): Boolean;
    function InsertAttributesInDM(attrElemArray: TAttrElemArray;
        atcsPosIds: TPosIdPairList; ssAttributes: TStringList): Boolean;
    function InsertAssociationsInDM(arcsPosIds: TPosIdPairList): Boolean;
    function OrderFeatures(dmChainToJSON: TDMChainToJSON; var sWarning: string): Boolean;
    function ObjectsFromDM2(dmChainToJSON: TDMChainToJSON; featuresPosIds: TPosIdPairList): Boolean;
    function InfoObjectsFromDM2(dmChainToJSON: TDMChainToJSON; featuresPosIds: TPosIdPairList): Boolean;
    function GetFOIDsFromS57(s57DataSet: TS101DataSet): Boolean;
  end;

const idShift: Integer = 1000000000;

implementation

uses
  DMS101ConverterFormUnit;

constructor TS101DataSetDM.Create(catalogue: TS101Catalogue);
begin
  inherited Create(catalogue);
  with dsGeneralInfo.fDSSI do begin
    DCOX := 0;
    DCOY := 0;
    DCOZ := 0;
    CMFX := 10000000;
    CMFY := 10000000;
    CMFZ := 100;
  end;
  orderedFeatures := TObjectList.Create(False);
end;

destructor TS101DataSetDM.Destroy;
begin
  orderedFeatures.Free;
  inherited;
end;

function TS101DataSetDM.S101FromDM(mapPath: string; var sError: string): Boolean;
var
  dmChainToJSON: TDMChainToJSON;
  pointsRefs, curvesRefs, compositesRefs, surfacesRefs, addCompositesRefs: TIntegerList;
  i, j, k, nSurfacesToLeave, nCompositesToLeave, nCurvesToLeave, nPointsToLeave: Integer;
  sWarning: string;
  featuresPosIds: TPosIdPairList;
begin
  Result := False;
  if dm_Open(PChar(mapPath), False) = 0 then begin
    sError := Format('Не удалось открыть файл %s', [mapPath]);
    Exit;
  end;
  dmChainToJSON := TDMChainToJSON.Create;
  featuresPosIds := TPosIdPairList.Create;
  try
    Writeln(tfDebugLog, Format('Экспорт карты %s в S-101', [mapPath]));
    Flush(tfDebugLog);
    if not dmChainToJSON.ChainDataFromDM(sError) then
      Exit;
//    dmChainToJSON.CreateAndOrderFeatureClasses;
    OrderFeatures(dmChainToJSON, sWarning);
    for i := 0 to dmChainToJSON.features.Count - 1 do
      featuresPosIds.Add(TPosIdPair.Create(i, TFeature(dmChainToJSON.features[i]).id));
    featuresPosIds.Sort;

//    InfoObjectsFromDM(dmChainToJSON);
    InfoObjectsFromDM2(dmChainToJSON, featuresPosIds);
    PointsFromDM(dmChainToJSON);
    CurvesFromDM(dmChainToJSON);
    CompositesFromDM(dmChainToJSON);
    SurfacesFromDM(dmChainToJSON);
//    ObjectsFromDM(dmChainToJSON);
    ObjectsFromDM2(dmChainToJSON, featuresPosIds);

    pointsRefs := TIntegerList.Create;
    curvesRefs := TIntegerList.Create;
    compositesRefs := TIntegerList.Create;
    surfacesRefs := TIntegerList.Create;
    addCompositesRefs := TIntegerList.Create;

    // Формируем массивы ссылок геообъектов на геометрические записи разнах типов
    for i := 0 to High(featureRecords) do
      for j := 0 to High(featureRecords[i].fSPASArray) do
        for k := 0 to High(featureRecords[i].fSPASArray[j].SPASArray) do
          with featureRecords[i].fSPASArray[j].SPASArray[k] do
            if RRNM = Ord(PointRecordType) then
              pointsRefs.Add(TInteger.Create(RRID))
            else if RRNM = Ord(CurveRecordType) then
              curvesRefs.Add(TInteger.Create(RRID))
            else if RRNM = Ord(CompositeCurveRecordType) then
              compositesRefs.Add(TInteger.Create(RRID))
            else if RRNM = Ord(SurfaceRecordType) then
              surfacesRefs.Add(TInteger.Create(RRID));

    // Удаляем записи массива поверхностей, на которые нет ссылок геообъектов
    surfacesRefs.Sort;
    nSurfacesToLeave := Length(surfaceRecords);
    for i := 0 to High(surfaceRecords) do
      if surfacesRefs.GetIndexByIKey(surfaceRecords[i].fSRID.RCID) < 0 then begin
        ClearRec(surfaceRecords[i]);
        nSurfacesToLeave := nSurfacesToLeave - 1;
      end;

    // Перемещаем на их место записи, на которые ссылки есть, и укорачиваем массив
    for i := 0 to High(surfaceRecords) do
      if surfaceRecords[i].fSRID.RCID = 0 then begin
        for j := i + 1 to High(surfaceRecords) do
          if surfaceRecords[j].fSRID.RCID > 0 then begin
            S101Copy(surfaceRecords[j], surfaceRecords[i]);
            ClearRec(surfaceRecords[j]);
            Break;
          end;
      end;
    SetLength(surfaceRecords, nSurfacesToLeave);

    // Добавляем в ссылочные массивы композитов и кривых ссылки оставшихся поверхностей
    for i := 0 to High(surfaceRecords) do
      for j := 0 to High(surfaceRecords[i].fRIASArray) do
        for k := 0 to High(surfaceRecords[i].fRIASArray[j].RIASArray) do
          with surfaceRecords[i].fRIASArray[j].RIASArray[k] do
            if RRNM = Ord(CompositeCurveRecordType) then
              compositesRefs.Add(TInteger.Create(RRID))
            else if RRNM = Ord(CurveRecordType) then
              curvesRefs.Add(TInteger.Create(RRID));

    // Добавляем в ссылочный массив композитов ссылки (если они еще не добавлены) других композитов,
    // на которые уже кто-то ссылается: геообъект, поверхность или композит.
    // Новые ссылки сначала добавляются во вспомогательный массив, который затем
    // объединяется с основным ссылочным массивом. Результирующий массив сортируется,
    // и процесс повторяется, пока вспомогательный массив не станет пустым.
    compositesRefs.Sort;
    while True do begin
      addCompositesRefs.Clear;
      for i := 0 to High(compositeCurveRecords) do begin
        if compositesRefs.GetIndexByIKey(compositeCurveRecords[i].fCCID.RCID) < 0 then
          Continue;
        for j := 0 to High(compositeCurveRecords[i].fCUCOArray) do
          for k := 0 to High(compositeCurveRecords[i].fCUCOArray[j].CUCOArray) do
            with compositeCurveRecords[i].fCUCOArray[j].CUCOArray[k] do
              if (RRNM = Ord(CompositeCurveRecordType)) and (compositesRefs.GetIndexByIKey(RRID) < 0) then
                addCompositesRefs.Add(TInteger.Create(RRID));
      end;
      if addCompositesRefs.Count = 0 then
        Break;
      for i := 0 to addCompositesRefs.Count - 1 do
        compositesRefs.Add(addCompositesRefs[i]);
      compositesRefs.Sort;
    end;


    // Удаляем записи массива compositeCurveRecords, на которые нет ссылок
    // геообъектов, поверхностей и других композитов, по которым можно добраться
    // до родительского геообъекта
    nCompositesToLeave := Length(compositeCurveRecords);
    for i := 0 to High(compositeCurveRecords) do
      if compositesRefs.GetIndexByIKey(compositeCurveRecords[i].fCCID.RCID) < 0 then begin
        ClearRec(compositeCurveRecords[i]);
        nCompositesToLeave := nCompositesToLeave - 1;
      end;

    // Перемещаем на их место записи, на которые ссылки есть, и укорачиваем массив
    for i := 0 to High(compositeCurveRecords) do
      if compositeCurveRecords[i].fCCID.RCID = 0 then begin
        for j := i + 1 to High(compositeCurveRecords) do
          if compositeCurveRecords[j].fCCID.RCID > 0 then begin
            S101Copy(compositeCurveRecords[j], compositeCurveRecords[i]);
            ClearRec(compositeCurveRecords[j]);
            Break;
          end;
      end;
    SetLength(compositeCurveRecords, nCompositesToLeave);

    // Добавляем в ссылочные массивы кривых ссылки оставшихся композитов
    for i := 0 to High(compositeCurveRecords) do
      for j := 0 to High(compositeCurveRecords[i].fCUCOArray) do
        for k := 0 to High(compositeCurveRecords[i].fCUCOArray[j].CUCOArray) do
          with compositeCurveRecords[i].fCUCOArray[j].CUCOArray[k] do
            if RRNM = Ord(CurveRecordType) then
              curvesRefs.Add(TInteger.Create(RRID));

    // Удаляем записи массива кривых, на которые нет ссылок других объектов
    // (геообъектов, поверхностей, композитов)
    curvesRefs.Sort;
    nCurvesToLeave := Length(curveRecords);
    for i := 0 to High(curveRecords) do
      if curvesRefs.GetIndexByIKey(curveRecords[i].fCRID.RCID) < 0 then begin
        ClearRec(curveRecords[i]);
        nCurvesToLeave := nCurvesToLeave - 1;
      end;

    // Перемещаем на их место записи, на которые ссылки есть, и укорачиваем массив
    for i := 0 to High(curveRecords) do
      if curveRecords[i].fCRID.RCID = 0 then begin
        for j := i + 1 to High(curveRecords) do
          if curveRecords[j].fCRID.RCID > 0 then begin
            S101Copy(curveRecords[j], curveRecords[i]);
            ClearRec(curveRecords[j]);
            Break;
          end;
      end;
    SetLength(curveRecords, nCurvesToLeave);

    // Добавим в ссылочный массив точек ссылки оставшихся кривых
    for i := 0 to High(curveRecords) do
      for j := 0 to High(curveRecords[i].fPTAS.PTASArray) do
        with curveRecords[i].fPTAS.PTASArray[j] do
          pointsRefs.Add(TInteger.Create(RRID));

    // Удаляем записи массива точек, на которые нет ссылок других объектов
    // (геообъектов, кривых)
    pointsRefs.Sort;
    nPointsToLeave := Length(pointRecords);
    for i := 0 to High(pointRecords) do
      if pointsRefs.GetIndexByIKey(pointRecords[i].fPRID.RCID) < 0 then begin
        ClearRec(pointRecords[i]);
        nPointsToLeave := nPointsToLeave - 1;
      end;

    // Перемещаем на их место записи, на которые ссылки есть, и укорачиваем массив
    for i := 0 to High(pointRecords) do
      if pointRecords[i].fPRID.RCID = 0 then begin
        for j := i + 1 to High(pointRecords) do
          if pointRecords[j].fPRID.RCID > 0 then begin
            S101Copy(pointRecords[j], pointRecords[i]);
            ClearRec(pointRecords[j]);
            Break;
          end;
      end;
    SetLength(pointRecords, nPointsToLeave);

    pointsRefs.Free;
    curvesRefs.Free;
    compositesRefs.Free;
    surfacesRefs.Free;
    addCompositesRefs.Free;

    Result := True;
  finally
    featuresPosIds.Free;
    dmChainToJSON.Free;
    dm_Done;
  end;
end;

// Импорт точек из DM
function TS101DataSetDM.PointsFromDM(var dmChainToJSON: TDMChainToJSON): Boolean;
var
  i, iCurPoint: Integer;
  node: TNode;
begin
  Result := False;
  if dmChainToJSON = nil then
    Exit;
  SetLength(pointRecords, dmChainToJSON.nodes.Count);
  iCurPoint := 0;
  for i := 0 to dmChainToJSON.nodes.Count - 1 do begin
    node := TNode(dmChainToJSON.nodes[i]);
    if (node.edges.Count = 0) and (node.objects.Count = 0) then
      Continue;
    with pointRecords[iCurPoint] do begin
      ct := ct2I;
      with fPRID do begin
        RCNM := Ord(PointRecordType);
        RCID := node.id;
        RVER := 1;
        RUIN := 1;
      end;
      ct := ct2I;
      fC2IT.XCOO := Round((node.l - dsGeneralInfo.fDSSI.DCOX) * dsGeneralInfo.fDSSI.CMFX);
      fC2IT.YCOO := Round((node.b - dsGeneralInfo.fDSSI.DCOY) * dsGeneralInfo.fDSSI.CMFY);
    end;
    iCurPoint := iCurPoint + 1;
  end;
  SetLength(pointRecords, iCurPoint);
  Result := True;
end;

function TS101DataSetDM.MultipointFromDM(var dmChainToJSON: TDMChainToJSON;
    multipointId: Integer): Boolean;
var
  i, j, nSize, nPoints: Integer;
  multiPoint: TMultiPoint;
  x, y, z: Double;
  pXYLine: PLLine;
  pZLine: PIntegers;
begin
  Result := False;
  if dmChainToJSON = nil then
    Exit;
  SetLength(multiPointRecords, Length(multiPointRecords) + 1);
  with multiPointRecords[High(multiPointRecords)] do begin
    ct := ct3I;
    with fMRID do begin
      RCNM := Ord(MultiPointRecordType);
      RCID := multipointId;
      RVER := 1;
      RUIN := 1;
    end;
    SetLength(fC3ILArray, 1);
    with fC3ILArray[0] do begin
      VCID := 2;
      // Чтобы получить локальные x, y, z координаты массива глубин, необходимо
      // перед входом в этот метод перейти к объекту
      nSize := SizeOf(SmallInt) + High(SmallInt) * SizeOf(TPoint);
      pXYLine := PLLine(AllocMem(nSize));
      pZLine := PIntegers(AllocMem(High(SmallInt) * SizeOf(Integer)));
      nPoints := dm_Get_Poly_xyz(pXYLine, pZLine, High(SmallInt));
      SetLength(C3ITArray, nPoints + 1);
      for j := 0 to nPoints do begin
        dm_L_to_G(pXYLine.Pol[j].X, pXYLine.Pol[j].Y, x, y);
        dm_XY_BL(x, y, x, y);
        x := x / PI * 180;
        y := y / PI * 180;
        z := pZLine[j] / dm_z_res;
        C3ITArray[j].XCOO := Round((y - dsGeneralInfo.fDSSI.DCOX) * dsGeneralInfo.fDSSI.CMFX);
        C3ITArray[j].YCOO := Round((x - dsGeneralInfo.fDSSI.DCOY) * dsGeneralInfo.fDSSI.CMFY);
        C3ITArray[j].ZCOO := Round((z - dsGeneralInfo.fDSSI.DCOZ) * dsGeneralInfo.fDSSI.CMFZ);
      end;
      FreeMem(pXYLine);
      FreeMem(pZLine);
    end;
  end;
  Result := True;
end;

// Импорт кривых из DM
function TS101DataSetDM.CurvesFromDM(var dmChainToJSON: TDMChainToJSON): Boolean;
var
  i, j, nSize: Integer;
  x, y: Double;
  edge: TEdge;
  pPolyLine: PLLine;
begin
  Result := False;
  if dmChainToJSON = nil then
    Exit;
  // Выделяем память под массив вершин ломаной максимального размера
  nSize := SizeOf(SmallInt) + High(SmallInt) * SizeOf(TPoint);
  pPolyLine := PLLine(AllocMem(nSize));
  try
    SetLength(curveRecords, dmChainToJSON.edges.Count);
    for i := 0 to dmChainToJSON.edges.Count - 1 do begin
      edge := TEdge(dmChainToJSON.edges[i]);
      with curveRecords[i] do begin
        ct := ct2I;
        with fCRID do begin
          RCNM := Ord(CurveRecordType);
          RCID := edge.id;
          RVER := 1;
          RUIN := 1;
        end;
        with fPTAS do
          case edge.nodes.Count of
            1: begin
              SetLength(PTASArray, 1);
              with PTASArray[0] do begin
                RRNM := Ord(PointRecordType);
                RRID := TNode(edge.nodes[0]).id;
                TOPI := 3;
              end;
            end;
            2: begin
              SetLength(PTASArray, 2);
              with PTASArray[0] do begin
                RRNM := Ord(PointRecordType);
                RRID := TNode(edge.nodes[0]).id;
                TOPI := 1;
              end;
              with PTASArray[1] do begin
                RRNM := Ord(PointRecordType);
                RRID := TNode(edge.nodes[1]).id;
                TOPI := 2;
              end;
            end
            else
              Exit;
          end;
        dm_Get_ve_Poly(edge.id, pPolyLine, nil, High(SmallInt));
        SetLength(fSegmentArray, 1);
        with fSegmentArray[0] do begin
          fSEGH.INTP := 4;
          SetLength(fC2ILArray, 1);
          with fC2ILArray[0] do begin
            SetLength(C2ITArray, pPolyLine.N + 1);
            for j := 0 to pPolyLine^.N do begin
              dm_L_to_G(pPolyLine.Pol[j].X, pPolyLine.Pol[j].Y, x, y);
              dm_XY_BL(x, y, x, y);
              x := x / PI * 180;
              y := y / PI * 180;
              C2ITArray[j].XCOO := Round((y - dsGeneralInfo.fDSSI.DCOX) * dsGeneralInfo.fDSSI.CMFX);
              C2ITArray[j].YCOO := Round((x - dsGeneralInfo.fDSSI.DCOY) * dsGeneralInfo.fDSSI.CMFY);
            end;
          end;
        end;
      end;
    end;
    Result := True;
  finally
    FreeMem(pPolyLine);
  end;
end;

// Импорт композитных кривых из DM
function TS101DataSetDM.CompositesFromDM(var dmChainToJSON: TDMChainToJSON): Boolean;
var
  i, j, iCurCompositeCurve: Integer;
  orientedEdge: TOrientedEdge;
  composite: TComposite;
begin
  Result := False;
  if dmChainToJSON = nil then
    Exit;
  SetLength(compositeCurveRecords, dmChainToJSON.composites.Count);
  iCurCompositeCurve := 0;
  for i := 0 to dmChainToJSON.composites.Count - 1 do begin
    composite := TComposite(dmChainToJSON.composites[i]);
    if composite.orientedEdges.Count = 1 then
      Continue;
    with compositeCurveRecords[iCurCompositeCurve] do begin
      with fCCID do begin
        RCNM := Ord(CompositeCurveRecordType);
        RCID := composite.id;
        RVER := 1;
        RUIN := 1;
      end;
      SetLength(fCUCOArray, 1);
      with fCUCOArray[0] do begin
        SetLength(CUCOArray, composite.orientedEdges.Count);
        for j := 0 to composite.orientedEdges.Count - 1 do begin
          orientedEdge := TOrientedEdge(composite.orientedEdges[j]);
          with CUCOArray[j] do begin
            RRNM := Ord(CurveRecordType);
            RRID := orientedEdge.edge.id;
            ORNT := Ord(orientedEdge.orientation);
          end;
        end;
      end;
    end;
    iCurCompositeCurve := iCurCompositeCurve + 1;
  end;
  SetLength(compositeCurveRecords, iCurCompositeCurve);
  Result := True;
end;

// Импорт поверхностей из DM
function TS101DataSetDM.SurfacesFromDM(var dmChainToJSON: TDMChainToJSON): Boolean;
var
  i, j: Integer;
  surface: TSurface;
  orientedComposite: TOrientedComposite;
  orientedEdge: TOrientedEdge;
begin
  Result := False;
  if dmChainToJSON = nil then
    Exit;
  SetLength(surfaceRecords, dmChainToJSON.surfaces.Count);
  for i := 0 to dmChainToJSON.surfaces.Count - 1 do begin
    surface := TSurface(dmChainToJSON.surfaces[i]);
    with surfaceRecords[i] do begin
      with fSRID do begin
        RCNM := Ord(SurfaceRecordType);
        RCID := surface.id;
        RVER := 1;
        RUIN := 1;
      end;
      SetLength(fRIASArray, 1);
      with fRIASArray[0] do begin
        SetLength(RIASArray, surface.orientedComposites.Count);
        for j := 0 to surface.orientedComposites.Count - 1 do begin
          orientedComposite := TOrientedComposite(surface.orientedComposites[j]);
          with RIASArray[j] do begin
            if orientedComposite.composite.orientedEdges.Count = 1 then begin
              RRNM := Ord(CurveRecordType);
              with TOrientedEdge(orientedComposite.composite.orientedEdges[0]) do begin
                RRID := edge.id;
                if orientation = toForward then
                  ORNT := Ord(orientedComposite.orientation)
                else
                  if orientedComposite.orientation = toForward then
                    ORNT := Ord(toBackward)
                  else
                    ORNT := Ord(toForward);
              end;
            end
            else begin
              RRNM := Ord(CompositeCurveRecordType);
              RRID := orientedComposite.composite.id;
              ORNT := Ord(orientedComposite.orientation);
            end;
            if j = 0 then
              USAG := 1   // Exterior
            else
              USAG := 2;  // Interior
            RAUI := 1;    // Insert
          end;
        end;
      end;
    end;
  end;
  Result := True;
end;

function TS101DataSetDM.ObjectAttributesFromDM(var fATTRArray: TATTRFieldArray; curPAIX: Integer = 0): Boolean;
var
  formatSettings: TFormatSettings;
  attributesPool: TPool;
  pAttribute, i, iPos, iPos2, iValue, iCode, pOld, attributeTypeCode, curATIX, maxATIX: Integer;
  attrBuffer: TBytes;
  attrType, attrTypeFromClassifier: Id_Tag;
  attrNumber, blankNumber: Word;
  pAttrProperties: PAbcRec1;
  multiByteStr: TShortStr;
  wideCharStr: TWideStr;
  sValue, s, sOurAcronym, s101AttributeName: string;
  iDate, iYear, iMonth, iDay: Integer;
  sYear, sMonth, sDay: string;
  item: TItem;
  attributeItem: TAttributeItem;
  dValue: Double;
begin
  Result := False;
  GetLocaleFormatSettings(LOCALE_USER_DEFAULT, formatSettings);
  formatSettings.DecimalSeparator := '.';

  // Обработка простых атрибутов
  // Читаем атрибуты в буфер
  if dm_Get_hf_Pool(@attributesPool, SizeOf(attributesPool.Buf)) > 0 then begin

    // Последовательно анализируем атрибуты в буфере
    pAttribute := 0;
    while True do begin
      ZeroMemory(@attrBuffer, SizeOf(TBytes));
      pAttribute := dm_hf_Pool_Get(@attributesPool, pAttribute, attrNumber, attrType, @attrBuffer);

      // Заканчиваем, если достигли конца буфера, иначе продолжаем
      if attrNumber = 0 then
        Break;
      // Если это служебные атрибуты, идем дальше
      if (attrNumber = 1000) or (attrNumber = 1007) or (attrNumber = 999) then
        Continue;

      // Извлекаем акроним из имени атрибута
      idx_Get_Name(attrNumber, multiByteStr);
      s := AnsiString(multiByteStr);
      iPos := AnsiPos('/', s);
      // Если акроним пустой, ничего не делаем и идем дальше
      if iPos < 2 then begin
        Writeln(tfDebugLog, Format('Атрибут %d не описан в классификаторе S-101', [attrNumber]));
        Flush(tfDebugLog);
        Continue;
      end;
      sOurAcronym := AnsiLeftStr(s, iPos - 1);

      // Определяем акроним атрибута по каталогу S-101
      s101AttributeName := s101Catalogue.acronymPairs.GetTheirByOur(sOurAcronym);
      Writeln(tfDebugLog, Format('name=%s, code=%d, s101Name=%s', [sOurAcronym, attrNumber, s101AttributeName]));
      Flush(tfDebugLog);
      if s101AttributeName = '' then
        Continue;
      item := s101Catalogue.items.GetItemByName(sOurAcronym);
      if item is TAttributeItem then
        attributeItem := item as TAttributeItem;

      // Определяем числовой код типа атрибута
      attributeTypeCode := 0;
      for i := 0 to Length(dsGeneralInfo.fATCS) - 1 do begin
        with dsGeneralInfo.fATCS[i] do
          if sCode = s101AttributeName then begin
            attributeTypeCode := iCode;
            Break;
          end;
      end;
      if attributeTypeCode = 0 then begin
        SetLength(dsGeneralInfo.fATCS, Length(dsGeneralInfo.fATCS) + 1);
        with dsGeneralInfo.fATCS[Length(dsGeneralInfo.fATCS) - 1] do begin
          sCode := s101AttributeName;
          iCode := Length(dsGeneralInfo.fATCS);
          attributeTypeCode := iCode;
        end;
      end;

      // Определяем тип атрибута по общему списку атрибутов idx
      attrTypeFromClassifier := idx_get_tag(attrNumber);

      // Если атрибут имеет тип dbase, уточняем тип атрибута по бланку
      // (в бланке он может иметь тип list)
      if attrTypeFromClassifier = _dBase then begin
        blankNumber := dm_Ind_Blank;
        if (blankNumber > 0) and (dm_Seek_Blank1(blankNumber) > 0) then begin
          pAttrProperties := dm_Seek_attr1(attrNumber);
          if pAttrProperties <> nil then
            attrTypeFromClassifier := pAttrProperties^.id;
        end;
      end;

      if Length(fATTRArray) = 0 then
        SetLength(fATTRArray, 1);
      SetLength(fATTRArray[0].arrayOfAttrElem, Length(fATTRArray[0].arrayOfAttrElem) + 1);

      // Используем уточненный тип атрибута для формирования его значения
      with fATTRArray[0].arrayOfAttrElem[Length(fATTRArray[0].arrayOfAttrElem) - 1] do
        case attrType of
          _byte, _word, _int, _long, _dbase: begin
            NATC := attributeTypeCode;
            ATIX := 1;
            PAIX := curPAIX;
            ATIN := 1;
            if attrTypeFromClassifier = _bool then
              if PLongint(@attrBuffer)^ = 1 then
                ATVL := 'true'
              else
                ATVL := 'false'
            else if sOurAcronym = 'lenge' then begin
              iValue := PLongint(@attrBuffer)^;
              for i := 0 to High(attributeItem.lListedValues) do
                with attributeItem.lListedValues[i] do begin
                  if iCode = iValue then begin
                    ATVL := sDefinition;
                    Break;
                  end;
                end;
            end
            else
              ATVL := Format('%d', [PLongint(@attrBuffer)^]);
            Writeln(tfDebugLog, Format('NATC=%d, ATIX=%d, PAIX=%d, ATIN=%d, ATVL=%s',
                [NATC, ATIX, PAIX, ATIN, ATVL]));
            Flush(tfDebugLog);
          end;
          _string, _text, _latin1: begin
            sValue := PShortString(@attrBuffer)^;
            // Если строковый атрибут имеет тип list, формируется массив целочисленных значений
            if attrTypeFromClassifier = _list then begin
              curATIX := 1;
              iPos := 1;
              while True do begin
                iPos2 := PosEx(',', sValue, iPos);
                if iPos2 > 0 then
                  Val(AnsiMidStr(sValue, iPos, iPos2 - iPos), iValue, iCode)
                else
                  Val(AnsiRightStr(sValue, Length(sValue) - iPos + 1), iValue, iCode);
                // Если в целочисленном списке встретился недопустимый элемент или он пуст,
                // удаляем последний элемент из массива атрибутов
                if iCode <> 0 then begin
                  SetLength(fATTRArray[0].arrayOfAttrElem, Length(fATTRArray[0].arrayOfAttrElem) - 1);
                  Break;
                end;
                with fATTRArray[0].arrayOfAttrElem[Length(fATTRArray[0].arrayOfAttrElem) - 1] do begin
                  NATC := attributeTypeCode;
                  ATIX := curATIX;
                  PAIX := curPAIX;
                  ATIN := 1;
                  ATVL := Format('%d', [iValue]);
                  Writeln(tfDebugLog, Format('NATC=%d, ATIX=%d, PAIX=%d, ATIN=%d, ATVL=%s',
                      [NATC, ATIX, PAIX, ATIN, ATVL]));
                  Flush(tfDebugLog);
                end;
                if iPos2 = 0 then Break;
                SetLength(fATTRArray[0].arrayOfAttrElem, Length(fATTRArray[0].arrayOfAttrElem) + 1);
                curATIX := curATIX + 1;
                iPos := iPos2 + 1;
              end;
            end
            // В противном случае строка перекодируется из кодировки OEM в Unicode
            else begin
              ZeroMemory(@wideCharStr, SizeOf(TWideStr));
              MultiByteToWideChar(CP_OEMCP, MB_PRECOMPOSED, PChar(sValue),
                  Length(sValue), wideCharStr, SizeOf(TWideStr) div SizeOf(WideChar));
              NATC := attributeTypeCode;
              ATIX := 1;
              PAIX := curPAIX;
              ATIN := 1;
              ATVL := UTF8Encode(WideString(wideCharStr));
              Writeln(tfDebugLog, Format('NATC=%d, ATIX=%d, PAIX=%d, ATIN=%d, ATVL=%s',
                  [NATC, ATIX, PAIX, ATIN, ATVL]));
              Flush(tfDebugLog);
            end;
          end;
          _unicode: begin
            ZeroMemory(@wideCharStr, SizeOf(TWideStr));
            Move((PChar(@attrBuffer) + SizeOf(SmallInt))^, wideCharStr, PSmallInt(@attrBuffer)^ * SizeOf(WideChar));
            NATC := attributeTypeCode;
            ATIX := 1;
            PAIX := curPAIX;
            ATIN := 1;
            ATVL := UTF8Encode(WideString(wideCharStr));
            Writeln(tfDebugLog, Format('NATC=%d, ATIX=%d, PAIX=%d, ATIN=%d, ATVL=%s',
                [NATC, ATIX, PAIX, ATIN, ATVL]));
            Flush(tfDebugLog);
          end;
          _float, _real, _angle: begin
            NATC := attributeTypeCode;
            ATIX := 1;
            PAIX := curPAIX;
            ATIN := 1;
//            ATVL := Format('%.6e', [PSingle(@attrBuffer)^], formatSettings);
            ATVL := Format('%g', [PSingle(@attrBuffer)^], formatSettings);
            Writeln(tfDebugLog, Format('NATC=%d, ATIX=%d, PAIX=%d, ATIN=%d, ATVL=%s',
                [NATC, ATIX, PAIX, ATIN, ATVL]));
            Flush(tfDebugLog);
          end;
          _double: begin
            NATC := attributeTypeCode;
            ATIX := 1;
            PAIX := curPAIX;
            ATIN := 1;
            dValue := PDouble(@attrBuffer)^;
            if attributeItem.sValueType = 'integer' then
              ATVL := Format('%d', [Round(dValue)])
            else if attributeItem.sValueType = 'real' then
//              ATVL := Format('%.6e', [dValue], formatSettings)
              ATVL := Format('%g', [dValue], formatSettings)
            else
              Exit;
            Writeln(tfDebugLog, Format('NATC=%d, ATIX=%d, PAIX=%d, ATIN=%d, ATVL=%s',
                [NATC, ATIX, PAIX, ATIN, ATVL]));
            Flush(tfDebugLog);
          end;
          _date: begin
            NATC := attributeTypeCode;
            ATIX := 1;
            PAIX := curPAIX;
            ATIN := 1;
            iDate := (System.PInteger(@attrBuffer))^;
            iYear := iDate div 10000;
            iMonth := (iDate mod 10000) div 100;
            iDay := iDate mod 100;
            if iYear = 0 then
              sYear := '----'
            else
              sYear := Format('%.4d', [iYear]);
            if iMonth = 0 then
              sMonth := '--'
            else
              sMonth := Format('%.2d', [iMonth]);
            if iDay = 0 then
              sDay := '--'
            else
              sDay := Format('%.2d', [iDay]);
            ATVL := sYear + sMonth + sDay;
            Writeln(tfDebugLog, Format('NATC=%d, ATIX=%d, PAIX=%d, ATIN=%d, ATVL=%s',
                [NATC, ATIX, PAIX, ATIN, ATVL]));
            Flush(tfDebugLog);
          end;
        end;
      // Заканчиваем, если достигли конца буфера
      if pAttribute >= attributesPool.Len then Break;
    end;
  end;

  // Обработка составных атрибутов
  pOld := dm_Object;
  if dm_Goto_down then begin
    while True do begin
      if dm_Get_Local = 30 then begin
        iCode := dm_Get_Code mod 100000;
        if iCode <> 32000 then begin
          idx_Get_Name(iCode, multiByteStr);
          s := AnsiString(multiByteStr);
          iPos := AnsiPos('/', s);
          if iPos < 2 then
            Writeln(tfLog, Format('Комплексный атрибут %d не описан в классификаторе S-101', [iCode]))
          else begin
            sOurAcronym := AnsiLeftStr(s, iPos - 1);
            // Определяем акроним атрибута по каталогу S-101
            s101AttributeName := s101Catalogue.acronymPairs.GetTheirByOur(sOurAcronym);
            Writeln(tfDebugLog, Format('name=%s, code=%d, s101Name=%s', [sOurAcronym, iCode, s101AttributeName]));
            Flush(tfDebugLog);
            if s101AttributeName = '' then begin
              if not dm_Goto_right then Break;
              Continue;
            end;
            // Определяем числовой код типа атрибута
            attributeTypeCode := 0;
            for i := 0 to Length(dsGeneralInfo.fATCS) - 1 do begin
              with dsGeneralInfo.fATCS[i] do
                if sCode = s101AttributeName then begin
                  attributeTypeCode := iCode;
                  Break;
                end;
            end;
            if attributeTypeCode = 0 then begin
              SetLength(dsGeneralInfo.fATCS, Length(dsGeneralInfo.fATCS) + 1);
              with dsGeneralInfo.fATCS[Length(dsGeneralInfo.fATCS) - 1] do begin
                sCode := s101AttributeName;
                iCode := Length(dsGeneralInfo.fATCS);
                attributeTypeCode := iCode;
              end;
            end;

            // Записываем комплексный атрибут в массив arrayOfAttrElem
            if Length(fATTRArray) = 0 then
              SetLength(fATTRArray, 1);
            // Ищем другие экземпляры этого комплексного атрибута с текущим родителем
            // и находим среди них максимальный ATIX
            maxATIX := 0;
            for i := 0 to Length(fATTRArray[0].arrayOfAttrElem) - 1 do
              with fATTRArray[0].arrayOfAttrElem[i] do
                if (NATC = attributeTypeCode) and (PAIX = curPAIX) and (ATIX > maxATIX) then
                  maxATIX := ATIX;
            // Добавляем комплексный атрибут в массив атрибутов
            SetLength(fATTRArray[0].arrayOfAttrElem, Length(fATTRArray[0].arrayOfAttrElem) + 1);
            with fATTRArray[0].arrayOfAttrElem[Length(fATTRArray[0].arrayOfAttrElem) - 1] do begin
              NATC := attributeTypeCode;
              ATIX := maxATIX + 1;
              PAIX := curPAIX;
              ATIN := 1;
              ATVL := '';
              Writeln(tfDebugLog, Format('NATC=%d, ATIX=%d, PAIX=%d, ATIN=%d, ATVL=%s',
                  [NATC, ATIX, PAIX, ATIN, ATVL]));
              Flush(tfDebugLog);
            end;
            // Рекурсивно вызываем ObjectAttributesFromDM для обработки вложенных атрибутов,
            // передав в качестве параметра curPAIX индекс нового комплексного атрибута
            ObjectAttributesFromDM(fATTRArray, Length(fATTRArray[0].arrayOfAttrElem));
          end;
        end;
      end;
      if not dm_Goto_right then Break;
    end;
  end;
  dm_Goto_node(pOld);
  Result := True;
end;

function TS101DataSetDM.FeatureAssociationsFromDM(feature: TFeature; features: TObjectList;
    featuresPosIds: TPosIdPairList; var fINASArray: TINASFieldArray;
    var fFASCArray: TFASCFieldArray): Boolean;
var
  i, j, id, index: Integer;
  assocFeature: TFeature;
  featureAssociation: TFeatureAssociation;
  s101Target, s101Role, s101Association: string;
  roleTypeOfBinding: TRoleTypeOfBinding;
  roleCode, associationCode: Integer;
  bSourceIsFeature, bTargetIsFeature: Boolean;
  sourceItem, targetItem: TItem;
begin
  Result := False;
  if (feature = nil) or (features = nil) then
    Exit;
  sourceItem := s101Catalogue.items.GetItemByName(feature.name);
  if not (sourceItem is TFeatureOrInfoItem) then
    Exit;
  for i := 0 to feature.featureAssociations.Count - 1 do begin
    featureAssociation := TFeatureAssociation(feature.featureAssociations[i]);

    // Находим фичу по ассоциации
    index := featuresPosIds.GetPosById(featureAssociation.id);
    if index < 0 then
      Continue;
    assocFeature := TFeature(features[index]);
    targetItem := s101Catalogue.items.GetItemByName(assocFeature.name);
    if not (targetItem is TFeatureOrInfoItem) then
      Exit;

    // Импортируем свойства ассоциации, учитывая направление связи
    if featureAssociation.assocDir = adForward then begin
      roleTypeOfBinding := s101Catalogue.roleTypesOfBindings.GetItem(feature.name,
          assocFeature.name, featureAssociation.name);
      if roleTypeOfBinding = nil then
        Continue;
      s101Target := s101Catalogue.acronymPairs.GetTheirByOur(roleTypeOfBinding.m_sTarget);
      s101Role := s101Catalogue.acronymPairs.GetTheirByOur(roleTypeOfBinding.m_sRole);
      s101Association := s101Catalogue.acronymPairs.GetTheirByOur(roleTypeOfBinding.m_sAssociation);
      if (s101Target = '') or (s101Role = '') or (s101Association = '') then
        Continue;

      // Определяем числовые коды имен
      roleCode := 0;
      for j := 0 to Length(dsGeneralInfo.fARCS) - 1 do begin
        with dsGeneralInfo.fARCS[j] do
          if sCode = s101Role then begin
            roleCode := iCode;
            Break;
          end;
      end;
      if roleCode = 0 then begin
        SetLength(dsGeneralInfo.fARCS, Length(dsGeneralInfo.fARCS) + 1);
        with dsGeneralInfo.fARCS[Length(dsGeneralInfo.fARCS) - 1] do begin
          sCode := s101Role;
          iCode := Length(dsGeneralInfo.fARCS);
          roleCode := iCode;
        end;
      end;

      associationCode := 0;
      if (sourceItem is TFeatureItem) and (targetItem is TFeatureItem) then begin
        // Для ассоциаций с геообъектами пополняем массив пар FACS
        for j := 0 to Length(dsGeneralInfo.fFACS) - 1 do begin
          with dsGeneralInfo.fFACS[j] do
            if sCode = s101Association then begin
              associationCode := iCode;
              Break;
            end;
        end;
        if associationCode = 0 then begin
          SetLength(dsGeneralInfo.fFACS, Length(dsGeneralInfo.fFACS) + 1);
          with dsGeneralInfo.fFACS[Length(dsGeneralInfo.fFACS) - 1] do begin
            sCode := s101Association;
            iCode := Length(dsGeneralInfo.fFACS);
            associationCode := iCode;
          end;
        end;
        // Добавляем ассоциацию с геообъектом в массив FASC
        SetLength(fFASCArray, Length(fFASCArray) + 1);
        with fFASCArray[Length(fFASCArray) - 1] do begin
          RRNM := Ord(FeatureRecordType);
          RRID := assocFeature.id;
          NFAC := associationCode;
          NARC := roleCode;
          FAUI := 1;
          SetLength(arrayOfAttrElem, 0);
          Writeln(tfDebugLog, Format('target=%s, role=%s, association=%s',
              [s101Target, s101Role, s101Association]));
          Writeln(tfDebugLog, Format('RRNM=%d, RRID=%d, NFAC=%d, NARC=%d, FAUI=%d',
              [RRNM, RRID, NFAC, NARC, FAUI]));
          Flush(tfDebugLog);
        end;
      end
      else begin
        // Для ассоциаций с инфообъектами пополняем массив пар IACS
        for j := 0 to Length(dsGeneralInfo.fIACS) - 1 do begin
          with dsGeneralInfo.fIACS[j] do
            if sCode = s101Association then begin
              associationCode := iCode;
              Break;
            end;
        end;
        if associationCode = 0 then begin
          SetLength(dsGeneralInfo.fIACS, Length(dsGeneralInfo.fIACS) + 1);
          with dsGeneralInfo.fIACS[Length(dsGeneralInfo.fIACS) - 1] do begin
            sCode := s101Association;
            iCode := Length(dsGeneralInfo.fIACS);
            associationCode := iCode;
          end;
        end;
        // Добавляем ассоциацию с инфообъектом в массив INAS
        SetLength(fINASArray, Length(fINASArray) + 1);
        with fINASArray[Length(fINASArray) - 1] do begin
          RRNM := Ord(InfoRecordType);
          id := assocFeature.id;
          if id > idShift then
            id := id - idShift;
          RRID := id;
          NIAC := associationCode;
          NARC := roleCode;
          IUIN := 1;
          SetLength(arrayOfAttrElem, 0);
          Writeln(tfDebugLog, Format('target=%s, role=%s, association=%s',
              [s101Target, s101Role, s101Association]));
          Writeln(tfDebugLog, Format('RRNM=%d, RRID=%d, NIAC=%d, NARC=%d, IUIN=%d',
              [RRNM, RRID, NIAC, NARC, IUIN]));
          Flush(tfDebugLog);
        end;
      end;
    end;
  end;
  Result := True;
end;

{
function TS101DataSetDM.ObjectsFromDM(var dmChainToJSON: TDMChainToJSON): Boolean;
var
  iClass, offset, id, i, iCurFeatureRec, featureTypeCode: Integer;
  featureClass: TFeatureClass;
  feature: TFeature;
  s101FeatureName: string;
  bStop: Boolean;
begin
  Result := False;
  if dmChainToJSON = nil then
    Exit;
  try
    // Распределим максимальный объем памяти, который может потребоваться
    // Лишнюю память потом освободим
    SetLength(featureRecords, dmChainToJSON.features.Count);

    // Цикл по типам геообъектов
    iCurFeatureRec := 0;
    for iClass := 0 to dmChainToJSON.featureClasses.Count - 1 do begin
      featureClass := TFeatureClass(dmChainToJSON.featureClasses[iClass]);
      if not (s101Catalogue.items.GetItemByName(featureClass.name) is TFeatureItem) then
        Continue;
      s101FeatureName := s101Catalogue.acronymPairs.GetTheirByOur(featureClass.name);
      Writeln(tfDebugLog, Format('i=%d, name=%s, loc=%d, code=%d, s101Name=%s',
          [iClass, featureClass.name, featureClass.loc, featureClass.code, s101FeatureName]));
      Flush(tfDebugLog);
      if s101FeatureName = '' then
        Continue;

      // Определяем числовой код типа геообъекта
      featureTypeCode := 0;
      for i := 0 to Length(dsGeneralInfo.fFTCS) - 1 do begin
        with dsGeneralInfo.fFTCS[i] do
          if sCode = s101FeatureName then begin
            featureTypeCode := iCode;
            Break;
          end;
      end;
      if featureTypeCode = 0 then begin
        SetLength(dsGeneralInfo.fFTCS, Length(dsGeneralInfo.fFTCS) + 1);
        with dsGeneralInfo.fFTCS[Length(dsGeneralInfo.fFTCS) - 1] do begin
          sCode := s101FeatureName;
          iCode := Length(dsGeneralInfo.fFTCS);
          featureTypeCode := iCode;
        end;
      end;

      // Цикл по объектам с заданным кодом и характером локализации
      offset := dm_Find_Frst_Code(featureClass.code, featureClass.loc);
      while offset > 0 do begin
        dm_Get_Long(1000, 0, id);

        if id = 352 then
          bStop := True;

        // Ищем соответствующую фичу в массиве
        feature := nil;
        for i := 0 to dmChainToJSON.features.Count - 1 do begin
          feature := TFeature(dmChainToJSON.features[i]);
          if feature.id = id then
            Break;
        end;
        if (feature = nil) or (feature.id <> id) then begin
          Writeln(tfDebugLog, Format('Объект %d не найден в массиве объектов', [id]));
          Flush(tfDebugLog);
          offset := dm_Find_Next_Code(featureClass.code, featureClass.loc);
          Continue;
        end;

        // Импортируем объект
        Writeln(tfDebugLog, Format('Импортируем объект %d, %s(%s)', [feature.id, s101FeatureName, featureClass.name]));
        Flush(tfDebugLog);

        if feature.id = 27 then
          bStop := True;

        with featureRecords[iCurFeatureRec] do begin
          with fFRID do begin
            RCNM := Ord(FeatureRecordType);
            RCID := feature.id;
            NFTC := featureTypeCode;
            RVER := 1;
            RUIN := 1;
          end;

          SetLength(fATTRArray, 0);
          ObjectAttributesFromDM(TATTRFieldArray(fATTRArray));

          // Импортируем геометрию объекта
          if feature.loc <> 50 then begin
            SetLength(fSPASArray, 1);
            SetLength(fSPASArray[0].SPASArray, 1);
            with fSPASArray[0].SPASArray[0] do begin
              SMIN := 0;
              SMAX := 2147483647;
              SAUI := 1;
              case feature.loc of
                11: begin
                  RRNM := Ord(MultiPointRecordType);
                  RRID := TMultiPoint(feature.multipoints[0]).id;
                  ORNT := 255;
                  MultipointFromDM(dmChainToJSON, RRID);
                end;
                21: begin
                  RRNM := Ord(PointRecordType);
                  RRID := TNode(feature.nodes[0]).id;
                  ORNT := 255;
                  if featureClass.name = 'SOUNDG' then
                    Change2dTo3dPoint(RRID);
                end;
                22: begin
                  if feature.composites.Count = 0 then begin
                    RRNM := Ord(CurveRecordType);
                    RRID := TEdge(feature.edges[0]).id;
                  end
                  else if TComposite(feature.composites[0]).orientedEdges.Count = 1 then begin
                    RRNM := Ord(CurveRecordType);
                    RRID := TOrientedEdge(TComposite(feature.composites[0]).orientedEdges[0]).edge.id;
                  end
                  else begin
                    RRNM := Ord(CompositeCurveRecordType);
                    RRID := TComposite(feature.composites[0]).id;
                  end;
                  ORNT := 1;
                end;
                23: begin
                  RRNM := Ord(SurfaceRecordType);
                  RRID := TSurface(feature.surfaces[0]).id;
                  ORNT := 1;
                end;
              end;
            end;
          end;
          FeatureAssociationsFromDM(feature, dmChainToJSON.features,
              TINASFieldArray(featureRecords[iCurFeatureRec].fINASArray),
              TFASCFieldArray(featureRecords[iCurFeatureRec].fFASCArray));
        end;
        iCurFeatureRec := iCurFeatureRec + 1;

        // Переходим к следующему геообъекту
        offset := dm_Find_Next_Code(featureClass.code, featureClass.loc);
      end;
    end;

    // Освобождаем лишнюю память
    SetLength(featureRecords, iCurFeatureRec);

    Result := True;
  finally
  end;
end;

function TS101DataSetDM.InfoObjectsFromDM(var dmChainToJSON: TDMChainToJSON): Boolean;
var
  iClass, offset, id, i, iCurInfoRec, featureTypeCode: Integer;
  featureClass: TFeatureClass;
  feature: TFeature;
  s101FeatureName: string;
  fFASCArray: array of TFASCField;
begin
  Result := False;
  if dmChainToJSON = nil then
    Exit;
  try
    // Цикл по типам объектов
    iCurInfoRec := 0;
    for iClass := 0 to dmChainToJSON.featureClasses.Count - 1 do begin
      featureClass := TFeatureClass(dmChainToJSON.featureClasses[iClass]);
      // Геообъекты пропускаем
      if s101Catalogue.items.GetItemByName(featureClass.name) is TFeatureItem then
        Continue;
      s101FeatureName := s101Catalogue.acronymPairs.GetTheirByOur(featureClass.name);
      Writeln(tfDebugLog, Format('i=%d, name=%s, loc=%d, code=%d, s101Name=%s',
          [iClass, featureClass.name, featureClass.loc, featureClass.code, s101FeatureName]));
      Flush(tfDebugLog);
      if s101FeatureName = '' then
        Continue;

      // Определяем числовой код типа геообъекта
      featureTypeCode := 0;
      for i := 0 to Length(dsGeneralInfo.fITCS) - 1 do begin
        with dsGeneralInfo.fITCS[i] do
          if sCode = s101FeatureName then begin
            featureTypeCode := iCode;
            Break;
          end;
      end;
      if featureTypeCode = 0 then begin
        SetLength(dsGeneralInfo.fITCS, Length(dsGeneralInfo.fITCS) + 1);
        with dsGeneralInfo.fITCS[Length(dsGeneralInfo.fITCS) - 1] do begin
          sCode := s101FeatureName;
          iCode := Length(dsGeneralInfo.fITCS);
          featureTypeCode := iCode;
        end;
      end;

      // Цикл по объектам с заданным кодом и характером локализации
      offset := dm_Find_Frst_Code(featureClass.code, featureClass.loc);
      while offset > 0 do begin
        dm_Get_Long(1000, 0, id);

        // Ищем этот объект в массиве dmChainToJSON.features
        feature := nil;
        for i := 0 to dmChainToJSON.features.Count - 1 do begin
          feature := TFeature(dmChainToJSON.features[i]);
          if feature.id = id then
            Break;
        end;
        if (feature = nil) or (feature.id <> id) then begin
          Writeln(tfDebugLog, Format('Объект %d не найден в массиве объектов', [id]));
          Flush(tfDebugLog);
          offset := dm_Find_Next_Code(featureClass.code, featureClass.loc);
          Continue;
        end;

        // Импортируем объект
        Writeln(tfDebugLog, Format('Импортируем объект %d, %s(%s)', [feature.id, s101FeatureName, featureClass.name]));
        Flush(tfDebugLog);
        SetLength(infoTypeRecords, iCurInfoRec + 1);
        with infoTypeRecords[iCurInfoRec] do begin
          with fIRID do begin
            RCNM := Ord(InfoRecordType);
            if id > idShift then
              id := id - idShift;
            RCID := id;
            NITC := featureTypeCode;
            RVER := 1;
            RUIN := 1;
          end;
          SetLength(fATTRArray, 0);
          ObjectAttributesFromDM(TATTRFieldArray(fATTRArray));
          SetLength(fFASCArray, 0);
          FeatureAssociationsFromDM(feature, dmChainToJSON.features,
              TINASFieldArray(infoTypeRecords[iCurInfoRec].fINASArray), TFASCFieldArray(fFASCArray));
        end;
        iCurInfoRec := iCurInfoRec + 1;

        // Переходим к следующему геообъекту
        offset := dm_Find_Next_Code(featureClass.code, featureClass.loc);
      end;
    end;
    Result := True;
  finally
  end;
end;
}

function TS101DataSetDM.Change2dTo3dPoint(pointId: Integer): Boolean;
var
  objectPtr, datatypePtr, top, i: Integer;
  depth: Single;
begin
  Result := False;
  if pointId <= 0 then
    Exit;
  objectPtr := dm_Object;
  if objectPtr = 0 then
    Exit;
  try
    datatypePtr := dm_frst_datatype(objectPtr, 524, top);
    if datatypePtr = 0 then
      Exit;
    if not dm_Goto_node(datatypePtr) then
      Exit;
    if not dm_Get_Real(179, 0, depth) then
      Exit;
    for i := 0 to High(pointRecords) do
      if pointRecords[i].fPRID.RCID = pointId  then begin
        with pointRecords[i] do begin
          ct := ct3I;
          fC3IT.VCID := 2;
          fC3IT.YCOO := fC2IT.YCOO;
          fC3IT.XCOO := fC2IT.XCOO;
          fC3IT.ZCOO := Round((depth - dsGeneralInfo.fDSSI.DCOZ) * dsGeneralInfo.fDSSI.CMFZ);
        end;
        Result := True;
      end;
  finally
    dm_Goto_node(objectPtr);
  end;
end;

type
  TObjRec = class
    count, code, loc, color: Integer;
    name: string;
    constructor Create;
  end;
  TAttrRec = class
    attrNum: Integer;
    tag: Id_Tag;
    name: string;
    attrItem: TNamedItem;
    constructor Create;
  end;

constructor TObjRec.Create;
begin
    count := 0;
    code := 0;
    loc := 0;
    color := 0;
    name := '';
end;

constructor TAttrRec.Create;
begin
    attrNum := 0;
    tag := Id_Tag(0);
    name := '';
    attrItem := nil;
end;

function TS101DataSetDM.GetCurveGeometry(id, orient: Integer; curvesPosIds: TPosIdPairList;
    var pXYLine: PLLine): Boolean;
var
  index, i, j, nSize, nPoints, nPointsOld, iFirst, iLast, iStep: Integer;
  lon, lat, x, y: Double;
begin
  Result := False;
  if (id <= 0) or (curvesPosIds = nil) then
    Exit;
  index := curvesPosIds.GetPosById(id);
  if index < 0 then
    Exit;
  with curveRecords[index] do begin
    case ct of
      ct2I: begin
        if (Length(fSegmentArray) > 0) and (Length(fSegmentArray[0].fC2ILArray) > 0) and
            (Length(fSegmentArray[0].fC2ILArray[0].C2ITArray) > 0) then begin
          nPoints := Length(fSegmentArray[0].fC2ILArray[0].C2ITArray);
          if pXYLine <> nil then begin
            nPointsOld := pXYLine.N + 1;
            nSize := SizeOf(SmallInt) + (nPointsOld + nPoints - 1) * SizeOf(TPoint);
            ReallocMem(pXYLine, nSize);
            pXYLine.N := nPointsOld + nPoints - 2;
          end
          else begin
            nPointsOld := 0;
            nSize := SizeOf(SmallInt) + nPoints * SizeOf(TPoint);
            pXYLine := PLLine(AllocMem(nSize));
            pXYLine.N := nPoints - 1;
          end;
          if orient = 1 then begin
            if nPointsOld = 0 then
              iFirst := 0
            else
              iFirst := 1;
            iLast := nPoints - 1;
            iStep := 1;
          end
          else begin
            if nPointsOld = 0 then
              iFirst := nPoints - 1
            else
              iFirst := nPoints - 2;
            iLast := 0;
            iStep := -1;
          end;
          i := iFirst;
          j := 0;
          while True do begin
            with dsGeneralInfo.fDSSI do
            with fSegmentArray[0].fC2ILArray[0].C2ITArray[i] do begin
              lon := (DCOX + XCOO / CMFX);
              lat := (DCOY + YCOO / CMFY);
            end;
            x := lat / 180 * Pi;
            y := lon / 180 * Pi;
            dm_BL_XY(x, y, x, y);
            dm_G_to_L(x, y, pXYLine.Pol[nPointsOld + j].X, pXYLine.Pol[nPointsOld + j].Y);
            if i = iLast then
              Break;
            i := i + iStep;
            j := j + 1;
          end;
          Result := True;
        end;
      end;
    end;
  end;
end;

function TS101DataSetDM.GetCompositeGeometry(id, orient: Integer; compositesPosIds,
    curvesPosIds: TPosIdPairList; var pXYLine: PLLine): Boolean;
var
  index, i, j, elemOrient: Integer;
begin
  Result := False;
  if (id <= 0) or (compositesPosIds = nil) then
    Exit;
  index := compositesPosIds.GetPosById(id);
  if index < 0 then
    Exit;
  if orient = 1 then
    with compositeCurveRecords[index] do begin
      for i := 0 to High(fCUCOArray) do begin
        for j := 0 to High(fCUCOArray[i].CUCOArray) do begin
          with fCUCOArray[i].CUCOArray[j] do begin
            if RRNM = Ord(CurveRecordType) then begin
              if not GetCurveGeometry(RRID, ORNT, curvesPosIds, pXYLine) then
                Exit;
            end
            else if RRNM = Ord(CompositeCurveRecordType) then begin
              if not GetCompositeGeometry(RRID, ORNT, compositesPosIds, curvesPosIds, pXYLine) then
                Exit;
            end
            else
              Exit;
          end;
        end;
      end;
    end
  else
    with compositeCurveRecords[index] do begin
      for i := High(fCUCOArray) downto 0 do begin
        for j := High(fCUCOArray[i].CUCOArray) downto 0 do begin
          with fCUCOArray[i].CUCOArray[j] do begin
            if ORNT = 1 then
              elemOrient := 2
            else
              elemOrient := 1;
            if RRNM = Ord(CurveRecordType) then begin
              if not GetCurveGeometry(RRID, elemOrient, curvesPosIds, pXYLine) then
                Exit;
            end
            else if RRNM = Ord(CompositeCurveRecordType) then begin
              if not GetCompositeGeometry(RRID, elemOrient, compositesPosIds, curvesPosIds, pXYLine) then
                Exit;
            end
            else
              Exit;
          end;
        end;
      end;
    end;
  Result := True;
end;

function TS101DataSetDM.InsertAttributesInDM(attrElemArray: TAttrElemArray;
    atcsPosIds: TPosIdPairList; ssAttributes: TStringList): Boolean;
var
  i, j, curPAIX, acronymIndex, code, intValue, pdt: Integer;
  boolValue: Boolean;
  realValue: Double;
  s101Acronym, sOurAcronym, sList: string;
  item: TItem;
  paixStack: TObjectStack;
  attrRec: TAttrRec;
  attrItem: TAttributeItem;
  multiByteStr: TShortStr;
  iDate, iYear, iMonth, iDay: Integer;
  sYear, sMonth, sDay: string;
begin
  Result := False;
  paixStack := TObjectStack.Create;
  try
    i := 0;
    while i <= High(attrElemArray) do begin
      with attrElemArray[i] do begin
        if NATC <= 0 then
          Exit;
        if PAIX < 0 then
          Exit;
        if not paixStack.AtLeast(1) then
          curPAIX := 0
        else
          curPAIX := TInteger(paixStack.Peek).iValue;
//        if PAIX > curPAIX then
//          Exit;
        if PAIX > curPAIX then begin
          i := i + 1;
          Continue;
        end;
        while (curPAIX > 0) and (PAIX < curPAIX) do begin
          dm_Goto_Upper;
          paixStack.Pop;
          if paixStack.AtLeast(1) then
            curPAIX := TInteger(paixStack.Peek).iValue
          else
            curPAIX := 0;
        end;
        s101Acronym := dsGeneralInfo.fATCS[atcsPosIds.GetPosById(NATC)].sCode;
        if s101Acronym = '' then
          Exit;
        sOurAcronym := s101Catalogue.acronymPairs.GetOurByTheir(s101Acronym);
        acronymIndex := ssAttributes.IndexOf(sOurAcronym);
        if acronymIndex < 0 then begin
          i := i + 1;
          Continue;
        end;
        attrRec := TAttrRec(ssAttributes.Objects[acronymIndex]);
        if attrRec.attrItem is TAttributeItem then begin
          attrItem := TAttributeItem(attrRec.attrItem);
          if (attrItem.sValueType = 'integer') or (attrItem.sValueType = 'enumeration') then begin
            if attrRec.tag = _list then begin
              sList := ATVL;
              j := i + 1;
              while j <= High(attrElemArray) do begin
                if (attrElemArray[j].NATC = NATC) and (attrElemArray[j].ATIX > 1) then
                  sList := sList + ',' + attrElemArray[j].ATVL
                else
                  Break;
                j := j + 1;
              end;
              dm_Put_String(attrRec.attrNum, PChar(sList));
              i := j;
              Continue;
            end;
            if sOurAcronym = 'lenge' then begin
              for j := 0 to High(attrItem.lListedValues) do
                with attrItem.lListedValues[j] do begin
                  if sDefinition = ATVL then begin
                    dm_Put_Int(attrRec.attrNum, iCode);
                    Break;
                  end;
                end;
              i := i + 1;
              Continue;
            end;
            Val(ATVL, intValue, code);
            if code <> 0 then begin
              i := i + 1;
              Continue;
            end;
            case attrRec.tag of
              _byte: dm_Put_Byte(attrRec.attrNum, intValue);
              _word: dm_Put_Word(attrRec.attrNum, intValue);
              _int: dm_Put_Int(attrRec.attrNum, intValue);
              _long: dm_Put_Long(attrRec.attrNum, intValue);
              _dBase: dm_Put_dBase(attrRec.attrNum, intValue);
            end
          end
          else if attrItem.sValueType = 'real' then begin
            Val(ATVL, realValue, code);
            if code <> 0 then begin
              i := i + 1;
              Continue;
            end;
            case attrRec.tag of
              _float, _real: dm_Put_Real(attrRec.attrNum, realValue);
              _angle: dm_Put_Angle(attrRec.attrNum, realValue);
              _double: dm_Put_Double(attrRec.attrNum, realValue);
            end
          end
          else if attrItem.sValueType = 'boolean' then begin
            if ATVL = '' then begin
              i := i + 1;
              Continue;
            end;
            if AnsiUpperCase(ATVL) = 'TRUE' then
              boolValue := True
            else if AnsiUpperCase(ATVL) = 'FALSE' then
              boolValue := False
            else begin
              Val(ATVL, intValue, code);
              if (code <> 0) or (intValue <> 0) and (intValue <> 1) then begin
                Writeln(tfDebugLog, Format('ATVL=%s', [ATVL]));
                Flush(tfDebugLog);
                Exit;
              end;
              boolValue := Boolean(intValue);
            end;
            dm_Put_Byte(attrRec.attrNum, Byte(boolValue));
          end
          else if attrItem.sValueType = 'text' then begin
            case attrRec.tag of
              _string, _latin1: begin
                WideCharToMultiByte(CP_OEMCP, 0, PWideChar(UTF8Decode(ATVL)), -1,
                    multiByteStr, SizeOf(TShortStr), PChar(0), PBOOL(0));
                dm_Put_String(attrRec.attrNum, multiByteStr);
              end;
              _text, _unicode:
                dm_Put_Text(attrRec.attrNum, UTF8Decode(ATVL));
            end;
          end
          else if attrItem.sValueType = 'S100_CodeList' then begin
            case attrRec.tag of
              _date: begin
                sYear := LeftStr(ATVL, 4);
                sMonth := MidStr(ATVL, 5, 2);
                sDay := RightStr(ATVL, 2);
                if sYear = '----' then
                  iYear := 0
                else
                  Val(sYear, iYear, code);
                if sMonth = '--' then
                  iMonth := 0
                else
                  Val(sMonth, iMonth, code);
                if sDay = '--' then
                  iDay := 0
                else
                  Val(sDay, iDay, code);
                iDate := iYear * 10000 + iMonth * 100 + iDay;
                dm_Put_Int(attrRec.attrNum, iDate);
              end;
            end;
          end;
        end
        else if attrRec.attrItem is TComplexAttributeItem then begin
          pdt := dm_Add_DataType(attrRec.attrNum, nil);
          dm_Goto_Node(pdt);
          paixStack.Push(TInteger.Create(i + 1));
        end
        else
          Exit;
      end;
      i := i + 1;
    end;
    while paixStack.AtLeast(1) do begin
      paixStack.Pop;
      dm_Goto_Upper;
    end;
    Result := True;
  finally
    paixStack.Free;
  end;
end;

function TS101DataSetDM.InsertAssociationsInDM(arcsPosIds: TPosIdPairList): Boolean;
var
  i, j, index, ptr1, ptr2, id: Integer;
  sRole: string;
begin
  Result := False;
  for i := 0 to High(infoTypeRecords) do begin
    with infoTypeRecords[i] do begin
      for j := 0 to High(fINASArray) do begin
        index := arcsPosIds.GetPosById(fINASArray[j].NARC);
        sRole := dsGeneralInfo.fARCS[index].sCode;
        sRole := s101Catalogue.acronymPairs.GetOurByTheir(sRole);
        if sRole = '' then
          Continue;
        id := fIRID.RCID;
        if id < idShift then
          id := id + idShift;
        ptr1 := dm_Id_Offset(id);
        id := fINASArray[j].RRID;
        if id < idShift then
          id := id + idShift;
        ptr2 := dm_Id_Offset(id);
        if (ptr1 = 0) or (ptr2 = 0) then
          Continue;
        dm_link_objects(ptr1, ptr2, 0, PChar(sRole));
      end;
    end;
  end;
  for i := 0 to High(featureRecords) do begin
    with featureRecords[i] do begin
      for j := 0 to High(fINASArray) do begin
        index := arcsPosIds.GetPosById(fINASArray[j].NARC);
        sRole := dsGeneralInfo.fARCS[index].sCode;
        sRole := s101Catalogue.acronymPairs.GetOurByTheir(sRole);
        if sRole = '' then
          Continue;
        ptr1 := dm_Id_Offset(fFRID.RCID);
        id := fINASArray[j].RRID;
        if id < idShift then
          id := id + idShift;
        ptr2 := dm_Id_Offset(id);
        if (ptr1 = 0) or (ptr2 = 0) then
          Continue;
        dm_link_objects(ptr1, ptr2, 0, PChar(sRole));
      end;
      for j := 0 to High(fFASCArray) do begin
        index := arcsPosIds.GetPosById(fFASCArray[j].NARC);
        sRole := dsGeneralInfo.fARCS[index].sCode;
        sRole := s101Catalogue.acronymPairs.GetOurByTheir(sRole);
        if sRole = '' then
          Continue;
        ptr1 := dm_Id_Offset(fFRID.RCID);
        ptr2 := dm_Id_Offset(fFASCArray[j].RRID);
        if (ptr1 = 0) or (ptr2 = 0) then
          Continue;
        dm_link_objects(ptr1, ptr2, 0, PChar(sRole));
      end;
    end;
  end;
  Result := True;
end;

function TS101DataSetDM.S101ToDM(dmPath: string; var sError: string): Boolean;
var
  latMin, lonMin, latMax, lonMax, lat, lon, x, y, z: Double;
  i, j, k, ix, iy, iz, iPos, index, nSize, nPoints, ringNo: Integer;
  curATIX, curPAIX: Integer;
  objPath, sIdxName: string;
  pointsPosIds, multipointsPosIds, curvesPosIds, compositesPosIds, surfacesPosIds,
      featuresPosIds, infosPosIds, atcsPosIds, itcsPosIds, ftcsPosIds,
      iacsPosIds, facsPosIds, arcsPosIds: TPosIdPairList;
  sTheir, sOur, sAttrName: string;
  ssObjects, ssAttributes: TStringList;
  objRec: TObjRec;
  attrRec: TAttrRec;
  pcBuffer: TShortStr;
  geomRCNM, geomRCID, geomORNT: Integer;
  point: TPoint;
  pXYLine: PLLine;
  pZLine: PIntegers;
  bStop: Boolean;
begin
  Result := False;
  if dmPath = '' then
    Exit;

  Writeln(tfDebugLog, Format('Импорт карты %s из S-101', [dmPath]));
  Flush(tfDebugLog);

  // Инициализируем ускорители поиска объектовых записей по id
  pointsPosIds := TPosIdPairList.Create;
  multipointsPosIds := TPosIdPairList.Create;
  curvesPosIds := TPosIdPairList.Create;
  compositesPosIds := TPosIdPairList.Create;
  surfacesPosIds := TPosIdPairList.Create;
  featuresPosIds := TPosIdPairList.Create;
  infosPosIds := TPosIdPairList.Create;
  for i := 0 to High(pointRecords) do
    pointsPosIds.Add(TPosIdPair.Create(i, pointRecords[i].fPRID.RCID));
  pointsPosIds.Sort;
  for i := 0 to High(multiPointRecords) do
    multipointsPosIds.Add(TPosIdPair.Create(i, multiPointRecords[i].fMRID.RCID));
  multipointsPosIds.Sort;
  for i := 0 to High(curveRecords) do
    curvesPosIds.Add(TPosIdPair.Create(i, curveRecords[i].fCRID.RCID));
  curvesPosIds.Sort;
  for i := 0 to High(compositeCurveRecords) do
    compositesPosIds.Add(TPosIdPair.Create(i, compositeCurveRecords[i].fCCID.RCID));
  compositesPosIds.Sort;
  for i := 0 to High(surfaceRecords) do
    surfacesPosIds.Add(TPosIdPair.Create(i, surfaceRecords[i].fSRID.RCID));
  surfacesPosIds.Sort;
  for i := 0 to High(featureRecords) do
    featuresPosIds.Add(TPosIdPair.Create(i, featureRecords[i].fFRID.RCID));
  featuresPosIds.Sort;
  for i := 0 to High(infoTypeRecords) do
    infosPosIds.Add(TPosIdPair.Create(i, infoTypeRecords[i].fIRID.RCID));
  infosPosIds.Sort;

  // Инициализируем ускорители поиска в массивах fATCS, fITCS, fFTCS, fIACS, fFACS, fARCS
  atcsPosIds := TPosIdPairList.Create;
  itcsPosIds := TPosIdPairList.Create;
  ftcsPosIds := TPosIdPairList.Create;
  iacsPosIds := TPosIdPairList.Create;
  facsPosIds := TPosIdPairList.Create;
  arcsPosIds := TPosIdPairList.Create;
  with dsGeneralInfo do begin
    for i := 0 to High(fATCS) do
      atcsPosIds.Add(TPosIdPair.Create(i, fATCS[i].iCode));
    atcsPosIds.Sort;
    for i := 0 to High(fITCS) do
      itcsPosIds.Add(TPosIdPair.Create(i, fITCS[i].iCode));
    itcsPosIds.Sort;
    for i := 0 to High(fFTCS) do
      ftcsPosIds.Add(TPosIdPair.Create(i, fFTCS[i].iCode));
    ftcsPosIds.Sort;
    for i := 0 to High(fIACS) do
      iacsPosIds.Add(TPosIdPair.Create(i, fIACS[i].iCode));
    iacsPosIds.Sort;
    for i := 0 to High(fFACS) do
      facsPosIds.Add(TPosIdPair.Create(i, fFACS[i].iCode));
    facsPosIds.Sort;
    for i := 0 to High(fARCS) do
      arcsPosIds.Add(TPosIdPair.Create(i, fARCS[i].iCode));
    arcsPosIds.Sort;
  end;

  try
    // Формирование списка классов объектов по классификатору
    objPath := AnsiReplaceStr(GetBinDir, '\bin', '\obj\s100.obj');
    if not Obj_Open(PChar(objPath)) then begin
      sError := Format('Не удалось открыть файл %s', [objPath]);
      Exit;
    end;
    ssObjects := TStringList.Create;
    for i := 1 to Obj_Count do begin
      objRec := TObjRec.Create;
      obj_Item(i, objRec.code, objRec.loc, objRec.color, pcBuffer);
      objRec.name := pcBuffer;
      iPos := Pos('/', objRec.name);
      if iPos > 0 then
        ssObjects.AddObject(AnsiLeftStr(objRec.name, iPos - 1), objRec);
     end;
    ssObjects.Sort;
    Obj_Close;

    // Формирование списка атрибутов
    sIdxName := AnsiReplaceStr(GetBinDir, '\bin', '\obj\s100.idx');
    if not idx_Open(PChar(sIdxName)) then begin
      sError := Format('Не удалось открыть файл %s', [sIdxName]);
      Exit;
    end;
    ssAttributes := TStringList.Create;
    for i := 1 to idx_Count do begin
      attrRec := TAttrRec.Create;
      attrRec.attrNum := idx_Item(i, attrRec.tag, pcBuffer);
      attrRec.name := pcBuffer;
      iPos := Pos('/', attrRec.name);
      if iPos > 0 then begin
        sAttrName := AnsiLeftStr(attrRec.name, iPos - 1);
        attrRec.attrItem := s101Catalogue.items.GetItemByName(sAttrName) as TNamedItem;
        if attrRec.attrItem <> nil then
          ssAttributes.AddObject(sAttrName, attrRec)
        else
          attrRec.Free;
      end
      else
        attrRec.Free;
    end;
    ssAttributes.Sort;
    idx_Close;

    // Создание DM-карты
    GetCellExtent(latMin, lonMin, latMax, lonMax);
    if not merc_Create(PChar(dmPath), PChar(objPath), latMin / 180 * Pi,
        lonMin / 180 * Pi, latMax / 180 * Pi, lonMax / 180 * Pi,
        (latMin + latMax) / 360 * Pi, 9, 180000) then begin
      sError := Format('Не удалось создать карту %s', [dmPath]);
      Exit;
    end;
    dm_Open(PChar(dmPath), True);

    // Добавление информационных объектов на карту
    with dsGeneralInfo do
      for i := 0 to High(infoTypeRecords) do begin
        with infoTypeRecords[i] do begin
          sTheir := fITCS[itcsPosIds.GetPosById(fIRID.NITC)].sCode;
          sOur := s101Catalogue.acronymPairs.GetOurByTheir(sTheir);
          if sOur = '' then
            Continue;
          index := ssObjects.IndexOf(sOur);
          if index < 0 then
            Continue;
          objRec := ssObjects.Objects[index] as TObjRec;
          dm_Add_Object(objRec.code, 10, 2, nil, nil, nil, False);
          //////////////////////////////////////////////////////////////////////
          // Идентификаторы информационных объектов могут совпадать с идентификаторами
          // геообъектов, поэтому их нельзя использовать в качестве индекса объекта в DM
          dm_Put_Long(1000, fIRID.RCID + idShift);
          //////////////////////////////////////////////////////////////////////
          if (Length(fATTRArray) > 0) and (Length(fATTRArray[0].arrayOfAttrElem) > 0) then
            if not InsertAttributesInDM(TAttrElemArray(fATTRArray[0].arrayOfAttrElem),
                atcsPosIds, ssAttributes) then begin
              sError := Format('Не удалось добавить в карту атрибуты информационного объекта %s(%d)', [sTheir, fIRID.RCID]);
              Exit;
            end;
        end;
      end;

    // Добавление геообъектов на карту
    with dsGeneralInfo do
      for i := 0 to High(featureRecords) do begin
        with featureRecords[i] do begin
          sTheir := fFTCS[ftcsPosIds.GetPosById(fFRID.NFTC)].sCode;
          sOur := s101Catalogue.acronymPairs.GetOurByTheir(sTheir);
          if sOur = '' then
            Continue;
          index := ssObjects.IndexOf(sOur);
          if index < 0 then
            Continue;
          objRec := ssObjects.Objects[index] as TObjRec;
          if (Length(fSPASArray) > 0) and (Length(fSPASArray[0].SPASArray) > 0) then begin
            with fSPASArray[0].SPASArray[0] do begin
              geomRCNM := RRNM;
              geomRCID := RRID;
              geomORNT := ORNT;
            end;
            case TRecordTypeCode(geomRCNM) of
              PointRecordType: begin
                index := pointsPosIds.GetPosById(geomRCID);
                if index < 0 then
                  Exit;
                with pointRecords[index] do begin
                  case ct of
                    ct2I:
                      with fC2IT do begin
                        lon := (fDSSI.DCOX + XCOO / fDSSI.CMFX);
                        lat := (fDSSI.DCOY + YCOO / fDSSI.CMFY);
                      end;
                    ct3I:
                      with fC3IT do begin
                        lon := fDSSI.DCOX + XCOO / fDSSI.CMFX;
                        lat := fDSSI.DCOY + YCOO / fDSSI.CMFY;
                        z := fDSSI.DCOZ + ZCOO / fDSSI.CMFZ;
                      end;
                  end;
                  lon := lon / 180 * Pi;
                  lat := lat / 180 * Pi;
                  dm_BL_XY(lat, lon, x, y);
                  dm_G_to_L(x, y, point.X, point.Y);
                  iz := Round(z * dm_z_res);
                  dm_Add_Sign(objRec.code, point, point, 0, False);
                end;
              end;
              MultiPointRecordType: begin
                index := multipointsPosIds.GetPosById(geomRCID);
                if index < 0 then begin
                  sError := Format('Ошибка при обработке геообъекта %s(%d). ' +
                      'Не удалось найти в массиве multipointsPosIds идентификатор %d',
                      [sTheir, fFRID.RCID, geomRCID]);
                  Exit;
                end;
                with multiPointRecords[index] do begin
                  case ct of
                    ct3I:
                      if (Length(fC3ILArray) > 0) and (Length(fC3ILArray[0].C3ITArray) > 0) then begin
                        nPoints := Length(fC3ILArray[0].C3ITArray);
                        nSize := SizeOf(SmallInt) + nPoints * SizeOf(TPoint);
                        pXYLine := PLLine(AllocMem(nSize));
                        pZLine := PIntegers(AllocMem(nPoints * SizeOf(Integer)));
                        pXYLine.N := High(fC3ILArray[0].C3ITArray);
                        for j := 0 to pXYLine.N do begin
                          with fC3ILArray[0].C3ITArray[j] do begin
                            lon := (fDSSI.DCOX + XCOO / fDSSI.CMFX);
                            lat := (fDSSI.DCOY + YCOO / fDSSI.CMFY);
                            z := fDSSI.DCOZ + ZCOO / fDSSI.CMFZ;
                          end;
                          lon := lon / 180 * Pi;
                          lat := lat / 180 * Pi;
                          dm_BL_XY(lat, lon, x, y);
                          dm_G_to_L(x, y, pXYLine.Pol[j].X, pXYLine.Pol[j].Y);
                          pZLine[j] := Round(z * dm_z_res);
                        end;
                      end;
                  end;
                  dm_Add_xyz(objRec.code, 11, 0, pXYLine, pZLine, False);
                  FreeMem(pXYLine);
                  FreeMem(pZLine);
                end;
              end;
              CurveRecordType: begin
                pXYLine := nil;
                if not GetCurveGeometry(geomRCID, geomORNT, curvesPosIds, pXYLine) then begin
                  sError := Format('Ошибка при обработке геообъекта %s(%d). ' +
                      'Ошибка при выполнении функции GetCurveGeometry',
                      [sTheir, fFRID.RCID]);
                  Exit;
                end;
                dm_Add_Poly(objRec.code, 2, 0, pXYLine, False);
                FreeMem(pXYLine);
              end;
              CompositeCurveRecordType: begin
                pXYLine := nil;
                if not GetCompositeGeometry(geomRCID, geomORNT, compositesPosIds, curvesPosIds, pXYLine) then begin
                  sError := Format('Ошибка при обработке геообъекта %s(%d). ' +
                      'Ошибка при выполнении функции GetCompositeGeometry',
                      [sTheir, fFRID.RCID]);
                  Exit;
                end;
                dm_Add_Poly(objRec.code, 2, 0, pXYLine, False);
                FreeMem(pXYLine);
              end;
              SurfaceRecordType: begin
                index := surfacesPosIds.GetPosById(geomRCID);
                if index < 0 then begin
                  sError := Format('Ошибка при обработке геообъекта %s(%d). ' +
                      'Не удалось найти в массиве surfacesPosIds идентификатор %d',
                      [sTheir, fFRID.RCID, geomRCID]);
                  Exit;
                end;
                ringNo := 0;
                with surfaceRecords[index] do begin
                  for j := 0 to High(fRIASArray) do begin
                    for k := 0 to High(fRIASArray[j].RIASArray) do begin
                      pXYLine := nil;
                      with fRIASArray[j].RIASArray[k] do begin
                        if RRNM = Ord(CompositeCurveRecordType) then begin
                          if not GetCompositeGeometry(RRID, ORNT, compositesPosIds, curvesPosIds, pXYLine) then begin
                            sError := Format('Ошибка при обработке геообъекта %s(%d). ' +
                                'Ошибка при выполнении функции GetCompositeGeometry при обработке поверхности %d',
                                [sTheir, fFRID.RCID, geomRCID]);
                            Exit;
                          end;
                        end
                        else if RRNM = Ord(CurveRecordType) then begin
                          if not GetCurveGeometry(RRID, ORNT, curvesPosIds, pXYLine) then begin
                            sError := Format('Ошибка при обработке геообъекта %s(%d). ' +
                                'Ошибка при выполнении функции GetCurveGeometry при обработке поверхности %d',
                                [sTheir, fFRID.RCID, geomRCID]);
                            Exit;
                          end;
                        end
                        else begin
                          sError := Format('Ошибка при обработке геообъекта %s(%d). ' +
                              'Ссылка на недопустимый тип %d при обработке поверхности %d',
                              [sTheir, fFRID.RCID, RRNM, geomRCID]);
                          Exit;
                        end;
                      end;
                      // Внутренние кольца - дочерние объекты. Они располагаются на уровне 3.
                      // Для первого внутреннего кольца (ringNo = 2) мы должны перейти
                      // на вложенный уровень (последний параметр = True)
                      ringNo := ringNo + 1;
                      dm_Add_Poly(objRec.code, 3, 0, pXYLine, ringNo = 2);
                      // Для дырок удаляем 1000-ю характеристику
                      if ringNo > 1 then
                        dm_del_hf(1000, _int);
                      FreeMem(pXYLine);
                    end;
                  end;
                  // После добавления внутренних колец мы должны подняться на уровень головного объекта
                  if ringNo > 1 then
                    dm_Goto_upper;
                end;
              end;
            end;
          end
          else begin
            dm_Add_Object(objRec.code, 50, 2, nil, nil, nil, False);
          end;
          dm_Put_Long(1000, fFRID.RCID);
          if fFRID.RCID = 3 then
            bStop := True;
          if (Length(fATTRArray) > 0) and (Length(fATTRArray[0].arrayOfAttrElem) > 0) then
            if not InsertAttributesInDM(TAttrElemArray(fATTRArray[0].arrayOfAttrElem),
                atcsPosIds, ssAttributes) then begin
              sError := Format('Не удалось добавить в карту атрибуты геообъекта %s(%d)', [sTheir, fFRID.RCID]);
              Exit;
            end;
        end;
      end;
    InsertAssociationsInDM(arcsPosIds);

    dm_Done;
    Result := True;
  finally
    pointsPosIds.Free;
    multipointsPosIds.Free;
    curvesPosIds.Free;
    compositesPosIds.Free;
    surfacesPosIds.Free;
    featuresPosIds.Free;
    infosPosIds.Free;
    atcsPosIds.Free;
    itcsPosIds.Free;
    ftcsPosIds.Free;
    iacsPosIds.Free;
    facsPosIds.Free;
    arcsPosIds.Free;
  end;
end;

function TS101DataSetDM.OrderFeatures(dmChainToJSON: TDMChainToJSON; var sWarning: string): Boolean;
var
  bExcluded: array of Boolean;
  i, j, index: Integer;
  featuresPosIds: TPosIdPairList;
  feature: TFeature;
  featureAssociation: TFeatureAssociation;
  bFoundToExclude, bDepends, bInfoFirst, bIsGeo: Boolean;
begin
  Result := False;
  if (dmChainToJSON = nil) or (dmChainToJSON.features = nil) or (dmChainToJSON.features.Count = 0) then
    Exit;
  sWarning := '';
  bExcluded := nil;
  featuresPosIds := nil;
  try
    orderedFeatures.Clear;
    with dmChainToJSON do begin
      SetLength(bExcluded, features.Count);
      for i := 0 to High(bExcluded) do
        bExcluded[i] := False;
      featuresPosIds := TPosIdPairList.Create;
      for i := 0 to features.Count - 1 do
        featuresPosIds.Add(TPosIdPair.Create(i, TFeature(features[i]).id));
      featuresPosIds.Sort;

      bInfoFirst := True;
      while True do begin
        bFoundToExclude := False;
        for i := 0 to features.Count - 1 do begin
          feature := TFeature(features[i]);
          if bExcluded[i] then
            Continue;
          bIsGeo := s101Catalogue.items.GetItemByName(feature.name) is TFeatureItem;
          if bInfoFirst and bIsGeo or not bInfoFirst and not bIsGeo then
            Continue;
          bDepends := False;
          for j := 0 to feature.featureAssociations.Count - 1 do begin
            featureAssociation := TFeatureAssociation(feature.featureAssociations[j]);
            if featureAssociation.assocDir = adBackward then
              Continue;
            index := featuresPosIds.GetPosById(featureAssociation.id);
            if index = -1 then
              Continue;
            if not bExcluded[index] then begin
              bDepends := True;
              Break;
            end;
          end;
          if not bDepends then begin
            bFoundToExclude := True;
            orderedFeatures.Add(feature);
            bExcluded[i] := True;
            Continue;
          end;
        end;
        if not bFoundToExclude then
          if bInfoFirst then
            bInfoFirst := not bInfoFirst
          else
            Break;
      end;
      for i := 0 to High(bExcluded) do
        if not bExcluded[i] then begin
          feature := TFeature(features[i]);
          sWarning := sWarning + Format('Объект %d (%s) не может быть экспортирован в S-101, так как участвует в циклических ссылках'#10,
              [feature.id, feature.name]);
        end;
    end;
    Result := True;
  finally
    SetLength(bExcluded, 0);
    featuresPosIds.Free;
  end;
end;

function TS101DataSetDM.InfoObjectsFromDM2(dmChainToJSON: TDMChainToJSON; featuresPosIds: TPosIdPairList): Boolean;
var
  i, j, featureTypeCode, iCurInfoRec, id: Integer;
  feature: TFeature;
  s101FeatureName: string;
  empty: TFASCFieldArray;
begin
  Result := False;
  if (orderedFeatures = nil) or (orderedFeatures.Count = 0) then
    Exit;
  try
    // Закажем массив записей инфо-объектов максимального размера
    SetLength(infoTypeRecords, orderedFeatures.Count);

    // Индекс текущего инфо-объекта
    iCurInfoRec := 0;

    for i := 0 to orderedFeatures.Count - 1 do begin
      feature := TFeature(orderedFeatures[i]);

      // Если мы дошли до геообъектов, выходим из цикла
      if s101Catalogue.items.GetItemByName(feature.name) is TFeatureItem then
        Break;

      // Определяем акроним S-101
      s101FeatureName := s101Catalogue.acronymPairs.GetTheirByOur(feature.name);
      if s101FeatureName = '' then
        Continue;

      // Определяем числовой код акронима инфо-объекта
      featureTypeCode := 0;
      for j := 0 to Length(dsGeneralInfo.fITCS) - 1 do begin
        with dsGeneralInfo.fITCS[j] do
          if sCode = s101FeatureName then begin
            featureTypeCode := iCode;
            Break;
          end;
      end;
      // Если не нашли, добавляем очередной элемент в массив пар
      if featureTypeCode = 0 then begin
        SetLength(dsGeneralInfo.fITCS, Length(dsGeneralInfo.fITCS) + 1);
        with dsGeneralInfo.fITCS[Length(dsGeneralInfo.fITCS) - 1] do begin
          sCode := s101FeatureName;
          iCode := Length(dsGeneralInfo.fITCS);
          featureTypeCode := iCode;
        end;
      end;

      // Заполним очередную запись инфо-объекта с учетом числового сдвига идентификатора
      with infoTypeRecords[iCurInfoRec] do begin
        with fIRID do begin
          RCNM := Ord(InfoRecordType);
          id := feature.id;
          if id > idShift then
            id := id - idShift;
          RCID := id;
          NITC := featureTypeCode;
          RVER := 1;
          RUIN := 1;
        end;

        // Перед заполнением атрибутов и ассоциаций объекта перейдем к объекту на карте
        // по его идентификатору
        dm_Jump_id(feature.id);

        // Заполним атрибуты объекта
        SetLength(fATTRArray, 0);
        ObjectAttributesFromDM(TATTRFieldArray(fATTRArray));

        // Заполним ассоциации объекта
        empty := nil;
        FeatureAssociationsFromDM(feature, dmChainToJSON.features, featuresPosIds,
            TINASFieldArray(fINASArray), empty);
      end;
      iCurInfoRec := iCurInfoRec + 1;
    end;

    // Укоротим массив записей инфо-объектов с учетом числа фактически заполненных записей
    SetLength(infoTypeRecords, iCurInfoRec);

    Result := True;
  finally
  end;
end;

function TS101DataSetDM.ObjectsFromDM2(dmChainToJSON: TDMChainToJSON; featuresPosIds: TPosIdPairList): Boolean;
var
  i, j, featureTypeCode, iCurGeoRec: Integer;
  feature: TFeature;
  s101FeatureName: string;
  bNoGeometry: Boolean;
  bStop: Boolean;
begin
  Result := False;
  if (orderedFeatures = nil) or (orderedFeatures.Count = 0) then
    Exit;
  try
    // Закажем массив записей геообъектов максимального размера
    SetLength(featureRecords, orderedFeatures.Count);

    Writeln(tfDebugLog, 'Экспорт объектов, атрибутов, ассоциаций');
    Flush(tfDebugLog);

    // Индекс текущего геообъекта
    iCurGeoRec := 0;

    for i := 0 to orderedFeatures.Count - 1 do begin
      feature := TFeature(orderedFeatures[i]);
      Writeln(tfDebugLog, Format('i=%d, id=%d, name=%s, loc=%d, code=%d',
          [i, feature.id, feature.name, feature.loc, feature.code]));
      Flush(tfDebugLog);

      // Если это инфо-объект, пропускаем
      if not (s101Catalogue.items.GetItemByName(feature.name) is TFeatureItem) then
        Continue;

      // Определяем акроним S-101
      s101FeatureName := s101Catalogue.acronymPairs.GetTheirByOur(feature.name);
      if s101FeatureName = '' then
        Continue;

      // Определяем числовой код акронима геообъекта
      featureTypeCode := 0;
      for j := 0 to Length(dsGeneralInfo.fFTCS) - 1 do begin
        with dsGeneralInfo.fFTCS[j] do
          if sCode = s101FeatureName then begin
            featureTypeCode := iCode;
            Break;
          end;
      end;
      // Если не нашли, добавляем очередной элемент в массив пар
      if featureTypeCode = 0 then begin
        SetLength(dsGeneralInfo.fFTCS, Length(dsGeneralInfo.fFTCS) + 1);
        with dsGeneralInfo.fFTCS[Length(dsGeneralInfo.fFTCS) - 1] do begin
          sCode := s101FeatureName;
          iCode := Length(dsGeneralInfo.fFTCS);
          featureTypeCode := iCode;
        end;
      end;

      // Заполним очередную запись геообъекта
      with featureRecords[iCurGeoRec] do begin
        with fFRID do begin
          RCNM := Ord(FeatureRecordType);
          RCID := feature.id;
          NFTC := featureTypeCode;
          RVER := 1;
          RUIN := 1;
        end;

        // Перед заполнением геометрии, атрибутов и ассоциаций объекта перейдем
        // к объекту на карте по его идентификатору
        dm_Jump_id(feature.id);

        // Заполним геометрию объекта, если это не объект без метрики
        if feature.loc <> 50 then begin
          SetLength(fSPASArray, 1);
          SetLength(fSPASArray[0].SPASArray, 1);
          bNoGeometry := False;
          with fSPASArray[0].SPASArray[0] do begin
            SMIN := 0;
            SMAX := 2147483647;
            SAUI := 1;
            case feature.loc of
              11: begin
                if feature.multipoints.Count > 0 then begin
                  RRNM := Ord(MultiPointRecordType);
                  RRID := TMultiPoint(feature.multipoints[0]).id;
                  ORNT := 255;
                  MultipointFromDM(dmChainToJSON, RRID);
                end
                else
                  bNoGeometry := True;
              end;
              21: begin
                if feature.nodes.Count > 0 then begin
                  RRNM := Ord(PointRecordType);
                  RRID := TNode(feature.nodes[0]).id;
                  ORNT := 255;
                  if feature.name = 'SOUNDG' then
                    Change2dTo3dPoint(RRID);
                end
                else
                  bNoGeometry := True;
              end;
              22: begin
                if feature.composites.Count = 0 then begin
                  if feature.edges.Count > 0 then begin
                    RRNM := Ord(CurveRecordType);
                    RRID := TEdge(feature.edges[0]).id;
                  end
                  else
                    bNoGeometry := True;
                end
                else if TComposite(feature.composites[0]).orientedEdges.Count = 1 then begin
                  RRNM := Ord(CurveRecordType);
                  RRID := TOrientedEdge(TComposite(feature.composites[0]).orientedEdges[0]).edge.id;
                end
                else begin
                  RRNM := Ord(CompositeCurveRecordType);
                  RRID := TComposite(feature.composites[0]).id;
                end;
                ORNT := 1;
              end;
              23: begin
                if feature.surfaces.Count > 0 then begin
                  RRNM := Ord(SurfaceRecordType);
                  RRID := TSurface(feature.surfaces[0]).id;
                  ORNT := 1;
                end
                else
                  bNoGeometry := True;
              end;
            end;
          end;
          if bNoGeometry then begin
            SetLength(fSPASArray[0].SPASArray, 0);
            SetLength(fSPASArray, 0);
            Writeln(tfDebugLog, 'Геометрия отсутствует');
            Flush(tfDebugLog);
          end;
        end;

        if feature.id = 22056 then
          bStop := True;

        // Заполним атрибуты объекта
        SetLength(fATTRArray, 0);
        ObjectAttributesFromDM(TATTRFieldArray(fATTRArray));

        // Заполним ассоциации объекта
        FeatureAssociationsFromDM(feature, dmChainToJSON.features, featuresPosIds,
            TINASFieldArray(fINASArray), TFASCFieldArray(fFASCArray));
      end;
      iCurGeoRec := iCurGeoRec + 1;
    end;

    // Укоротим массив записей геообъектов с учетом числа фактически заполненных записей
    SetLength(featureRecords, iCurGeoRec);

    Result := True;
  finally
  end;
end;

// Заимствуем FOID-ы из одноименной ячейки S-57
function TS101DataSetDM.GetFOIDsFromS57(s57DataSet: TS101DataSet): Boolean;
var
  featuresPosIds: TPosIdPairList;
  i, index: Integer;
begin
  Result := False;
  if s57DataSet = nil then
    Exit;
  featuresPosIds := TPosIdPairList.Create;
  try
    for i := 0 to Length(s57DataSet.featureRecords) - 1 do
      featuresPosIds.Add(TPosIdPair.Create(i, s57DataSet.featureRecords[i].fFRID.RCID));
    featuresPosIds.Sort;
    for i := 0 to Length(featureRecords) - 1 do begin
      index := featuresPosIds.GetPosById(featureRecords[i].fFRID.RCID);
      if index < 0 then
        Continue;
      if s57DataSet.featureRecords[index].pfFOID = nil then
        Continue;
      if featureRecords[i].pfFOID <> nil then
        Dispose(featureRecords[i].pfFOID);
      New(featureRecords[i].pfFOID);
      featureRecords[i].pfFOID^.AGEN := s57DataSet.featureRecords[index].pfFOID^.AGEN;
      featureRecords[i].pfFOID^.FIDN := s57DataSet.featureRecords[index].pfFOID^.FIDN;
      featureRecords[i].pfFOID^.FIDS := s57DataSet.featureRecords[index].pfFOID^.FIDS;
    end;
    Result := True;
  finally
    featuresPosIds.Free;
  end;
end;

end.
