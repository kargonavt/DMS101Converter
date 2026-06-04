unit DMChainToJSONUnit;

interface

uses
  Windows, SysUtils, Classes, StrUtils, Contnrs, Forms, Dialogs, SyncObjs,
      OTypes, dmw_Use, uLkJSON, S101TypesUnit, ProgressFormUnit;

type
  TOrientation = (toForward = 1, toBackward = 2, notApplicable = 255);
  TAssociationType = (atAssociation = 1, atAggregation = 2, atComposition = 3);
  TAssociationDirection = (adForward = 1, adBackward = 2);

  TNode = class
    id: Integer;
    sGUID: string;
    b, l, h: double;
    edges, objects: TObjectList;
    constructor Create(_id: Integer; _sGUID: string = ''; _b: Double = 0;
        _l: Double = 0; _h: Double = 0);
    destructor Destroy; override;
  end;

  TEdge = class
    id: Integer;
    sGUID: string;
    area: Double;
    nodes, objects: TObjectList;
    constructor Create(_id: Integer; _sGUID: string = '');
    destructor Destroy; override;
  end;

  T3DPoint = class
    id: Integer;
    sGUID: string;
    constructor Create(_id: Integer; _sGUID: string = '');
    destructor Destroy; override;
  end;

  TMultiPoint = class
    id: Integer;
    sGUID: string;
    objects: TObjectList;
    constructor Create(_id: Integer; _sGUID: string = '');
    destructor Destroy; override;
  end;

  TOrientedEdge = class
    edge: TEdge;
    orientation: TOrientation;
    constructor Create(_edge: TEdge; _orientation: TOrientation);
    destructor Destroy; override;
  end;

  TComposite = class
    id: Integer;
    sGUID: string;
    orientedEdges, objects: TObjectList;
    constructor Create(_id: Integer; _sGUID: string = '');
    destructor Destroy; override;
    function Area: Double;
  end;

  TOrientedComposite = class
    composite: TComposite;
    orientation: TOrientation;
    constructor Create(_composite: TComposite; _orientation: TOrientation);
    destructor Destroy; override;
  end;

  TSurface = class
    id: Integer;
    sGUID: string;
    orientedComposites, objects: TObjectList;
    constructor Create(_id: Integer; _sGUID: string = '');
    destructor Destroy; override;
  end;

  TFeature = class
    id, code, loc: Integer;
    name, sGUID: string;
    nodes, edges, multipoints, composites, surfaces, featureAssociations: TObjectList;
    constructor Create(_id: Integer);
    destructor Destroy; override;
  end;

  TFeatureAssociation = class
    id: Integer;
    name: string;
    assocType: TAssociationType;
    assocDir: TAssociationDirection;
    constructor Create(_id: Integer; _name: string; _assocType: TAssociationType;
        _assocDir: TAssociationDirection);
    destructor Destroy; override;
  end;

  TFeatureClass = class
    code, loc: Integer;
    name: string;
    childFeatureClasses, parentFeatureClasses: TObjectList;
    constructor Create(_code, _loc: Integer; _name: string);
    destructor Destroy; override;
  end;

  TWorkingThread = class;

  // Класс для экспорта цепочно-узловой структуры в JSON
  TDMChainToJSON = class
    nodes, edges, _3dPoints, multipoints, composites, surfaces, features, featureClasses: TObjectList;
    tfLog: TextFile;
    workingThread: TWorkingThread;
    constructor Create;
    destructor Destroy; override;
    function NodesToJSON(jsPatch: TlkJSONobject): Boolean;
    function EdgesToJSON(jsPatch: TlkJSONobject): Boolean;
    function MultiPointToJSON(multipoint: TMultiPoint; jsPatch: TlkJSONobject): Boolean;
    function CompositesToJSON(jsPatch: TlkJSONobject): Boolean;
    function SurfacesToJSON(jsPatch: TlkJSONobject): Boolean;
    function AttributesToJSON(jsAttributes: TlkJSONobject): Boolean;
    function GeometryToJSON(feature: TFeature; jlGeometry: TlkJSONlist; jsPatch: TlkJSONobject): Boolean;
    function ObjectsToJSON(mapPath, logName: string; var sError: string): Boolean;
    function ObjectsFromJSON(jsonPath, logPath: string; var sError: string): Boolean;
    function ChainDataFromDM(var sError: string): Boolean;
    function CreateAndOrderFeatureClasses: Boolean;
    function RunInWorkingThread(sFileName, sLogName: string; var sError: string): Integer; virtual;
    function UpdateProgress(sMessage: string; iPos, iMax: Integer): Boolean;
  end;

  TWorkingThread = class(TThread)
  protected
    m_dmChainToJSON: TDMChainToJSON;
    m_sFileName, m_sLogName: string;
  public
    m_sError: string;
    m_nTermStatus: Integer;
  public
    constructor Create(dmChainToJSON: TDMChainToJSON;
        sFileName, sLogName: string; bCreateSuspended: Boolean = False);
  protected
    procedure Execute; override;
  end;

implementation

uses
  DMS101ConverterFormUnit;

// --------------------- TWorkingThread ---------------------

constructor TWorkingThread.Create(dmChainToJSON: TDMChainToJSON;
    sFileName, sLogName: string; bCreateSuspended: Boolean = False);
begin
  inherited Create(bCreateSuspended);
  m_dmChainToJSON := dmChainToJSON;
  m_sFileName := sFileName;
  m_sLogName := sLogName;
  m_nTermStatus := TERM_STATUS_SUCCESS;
end;

procedure TWorkingThread.Execute;
begin
  m_dmChainToJSON.ObjectsToJSON(m_sFileName, m_sLogName, m_sError);
  finishedEvent.SetEvent;
end;

function TDMChainToJSON.RunInWorkingThread(sFileName, sLogName: string;
    var sError: string): Integer;
begin
  try
    // Создадим и запустим рабочий поток
    suspendEvent.SetEvent;
    finishedEvent.ResetEvent;
    breakEvent.ResetEvent;
    workingThread := TWorkingThread.Create(self, sFileName, sLogName);

    // Создадим и откроем в модальном режиме окно прогресса
    ProgressForm := TProgressForm.Create(Application);
    ProgressForm.ShowModal;
    ProgressForm.Release;

    // Сообщим, если что-то пошло не так, и выйдем
    if workingThread.m_nTermStatus = TERM_STATUS_ERROR then
      sError := workingThread.m_sError;
    Result := workingThread.m_nTermStatus;
  finally
    workingThread.Free;
    workingThread := nil;
  end;
end;

function TDMChainToJSON.UpdateProgress(sMessage: string; iPos, iMax: Integer): Boolean;
var
  progress: TProgress;
begin
  Result := False;
  suspendEvent.WaitFor($FFFFFFFF);
  if breakEvent.WaitFor(0) = wrSignaled then begin
    if workingThread <> nil then
      workingThread.m_nTermStatus := TERM_STATUS_USERSTOP;
    Result := True;
    Exit;
  end;
  progress := TProgress(threadList.LockList[0]);
  progress.m_max := iMax;
  progress.m_pos := iPos;
  progress.m_Message := sMessage;
  threadList.UnlockList;
end;

// Ориентированная площадь под ломаной. Если ломаная замкнута, значение больше 0
// при обходе по часовой стрелке и меньше 0 при обходе против.
function Square_Poly(lp: PLPoly; N: Integer): Double;
var
  i: int;
  x1, y1, x2, y2: Double;
  ax: Extended;
begin
  Result := 0;
  if N > 0 then begin
    ax := 0;
    x2 := lp[0].X;
    y2 := lp[0].Y;
    for i := 1 to N do begin
      x1 := x2;
      y1 := y2;
      x2 := lp[i].X;
      y2 := lp[i].Y;
      ax := ax + x1 * y2 - x2 * y1;
    end;
    Result := ax / 2;
  end;
end;

constructor TNode.Create(_id: Integer; _sGUID: string; _b: Double; _l: Double; _h: Double);
var
  guid: TGUID;
begin
  id := _id;
  if _sGUID = '' then begin
    CreateGUID(guid);
    sGUID := GUIDToString(guid);
    sGUID := MidStr(sGUID, 2, Length(sGUID) - 2);
  end
  else
    sGUID := _sGUID;
  b := _b;
  l := _l;
  h := _h;
  // Узел не владеет ребрами и объектами, только ссылается на них
  edges := TObjectList.Create(False);
  objects := TObjectList.Create(False);
end;

destructor TNode.Destroy;
begin
  sGUID := '';
  edges.Free;
  objects.Free;
end;

constructor TEdge.Create(_id: Integer; _sGUID: string);
var
  guid: TGUID;
begin
  id := _id;
  if _sGUID = '' then begin
    CreateGUID(guid);
    sGUID := GUIDToString(guid);
    sGUID := MidStr(sGUID, 2, Length(sGUID) - 2);
  end
  else
    sGUID := _sGUID;
  area := 0;
  // Ребро не владеет узлами и объектами, только ссылается на них
  nodes := TObjectList.Create(False);
  objects := TObjectList.Create(False);
end;

destructor TEdge.Destroy;
begin
  sGUID := '';
  nodes.Free;
  objects.Free;
end;

constructor T3DPoint.Create(_id: Integer; _sGUID: string = '');
var
  guid: TGUID;
begin
  id := _id;
  if _sGUID = '' then begin
    CreateGUID(guid);
    sGUID := GUIDToString(guid);
    sGUID := MidStr(sGUID, 2, Length(sGUID) - 2);
  end
  else
    sGUID := _sGUID;
end;

destructor T3DPoint.Destroy;
begin
  sGUID := '';
end;

constructor TMultiPoint.Create(_id: Integer; _sGUID: string = '');
var
  guid: TGUID;
begin
  id := _id;
  if _sGUID = '' then begin
    CreateGUID(guid);
    sGUID := GUIDToString(guid);
    sGUID := MidStr(sGUID, 2, Length(sGUID) - 2);
  end
  else
    sGUID := _sGUID;
  // Мультиточка не владеет объектами, только ссылается на них
  objects := TObjectList.Create(False);
end;

destructor TMultiPoint.Destroy;
begin
  sGUID := '';
  objects.Free;
end;

constructor TOrientedEdge.Create(_edge: TEdge; _orientation: TOrientation);
begin
  edge := _edge;
  orientation := _orientation;
end;

destructor TOrientedEdge.Destroy;
begin
  edge := nil;
end;

constructor TComposite.Create(_id: Integer; _sGUID: string = '');
var
  guid: TGUID;
begin
  id := _id;
  if _sGUID = '' then begin
    CreateGUID(guid);
    sGUID := GUIDToString(guid);
    sGUID := MidStr(sGUID, 2, Length(sGUID) - 2);
  end
  else
    sGUID := _sGUID;
  // Композит владеет ориентированными ребрами. Они существуют только в рамках композита.
  orientedEdges := TObjectList.Create;
  // Композит не владеет объектами, только ссылается на них
  objects := TObjectList.Create(False);
end;

destructor TComposite.Destroy;
begin
  sGUID := '';
  orientedEdges.Free;
  objects.Free;
end;

// Ориентированная площадь композита - алгебраическая сумма ориентированных площадей ребер,
// при этом обратная ориентация ребра меняет знак ориентированной площади ребра на противоположный
function TComposite.Area: Double;
var
  i: Integer;
  orientedEdge: TOrientedEdge;
begin
  Result := 0;
  for i := 0 to orientedEdges.Count - 1 do begin
    orientedEdge := TOrientedEdge(orientedEdges[i]);
    if orientedEdge.orientation = toForward then
      Result := Result + orientedEdge.edge.area
    else
      Result := Result - orientedEdge.edge.area
  end;
end;

constructor TOrientedComposite.Create(_composite: TComposite; _orientation: TOrientation);
begin
  composite := _composite;
  orientation := _orientation;
end;

destructor TOrientedComposite.Destroy;
begin
  composite := nil;
end;

constructor TSurface.Create(_id: Integer; _sGUID: string = '');
var
  guid: TGUID;
begin
  id := _id;
  if _sGUID = '' then begin
    CreateGUID(guid);
    sGUID := GUIDToString(guid);
    sGUID := MidStr(sGUID, 2, Length(sGUID) - 2);
  end
  else
    sGUID := _sGUID;
  // Поверхность владеет ориентированными композитами. Они существуют только в рамках поверхности.
  orientedComposites := TObjectList.Create;
  // Поверхность не владеет объектами, только ссылается на них
  objects := TObjectList.Create(False);
end;

destructor TSurface.Destroy;
begin
  sGUID := '';
  orientedComposites.Free;
  objects.Free;
end;

constructor TFeature.Create(_id: Integer);
begin
  id := _id;
  loc := 0;
  sGUID := '';
  name := '';
  // Объект не владеет геометрическими примитивами, только ссылается на них
  edges := TObjectList.Create(False);
  nodes := TObjectList.Create(False);
  multipoints := TObjectList.Create(False);
  composites := TObjectList.Create(False);
  surfaces := TObjectList.Create(False);
  // Объект владеет ассоциациями с другими объектами. Они существуют, пока существует
  // сам объект.
  featureAssociations := TObjectList.Create;
end;

destructor TFeature.Destroy;
begin
  sGUID := '';
  name := '';
  edges.Free;
  nodes.Free;
  multipoints.Free;
  composites.Free;
  surfaces.Free;
  featureAssociations.Free;
end;

constructor TFeatureAssociation.Create(_id: Integer; _name: string; _assocType: TAssociationType;
    _assocDir: TAssociationDirection);
begin
  id := _id;
  name := _name;
  assocType := _assocType;
  assocDir := _assocDir;
end;

destructor TFeatureAssociation.Destroy;
begin
  name := '';
end;

constructor TFeatureClass.Create(_code, _loc: Integer; _name: string);
begin
  code := _code;
  loc := _loc;
  name := _name;
  childFeatureClasses := TObjectList.Create(False);
  parentFeatureClasses := TObjectList.Create(False);
end;

destructor TFeatureClass.Destroy;
begin
  childFeatureClasses.Free;
  parentFeatureClasses.Free;
  name := '';
end;

constructor TDMChainToJSON.Create;
begin
  nodes := TObjectList.Create;
  edges := TObjectList.Create;
  _3dPoints := TObjectList.Create;
  multipoints := TObjectList.Create;
  composites := TObjectList.Create;
  surfaces := TObjectList.Create;
  features := TObjectList.Create;
  featureClasses := TObjectList.Create;
end;

destructor TDMChainToJSON.Destroy;
begin
  nodes.Free;
  edges.Free;
  _3dPoints.Free;
  multipoints.Free;
  composites.Free;
  surfaces.Free;
  features.Free;
  featureClasses.Free;
end;

// Экспортируем все узлы в JSON
function TDMChainToJSON.NodesToJSON(jsPatch: TlkJSONobject): Boolean;
var
  i: Integer;
  node: TNode;
  nodeRec: tcn_rec;
  jsPoint: TlkJSONobject;
  jl: TlkJSONlist;
  x, y: Double;
begin
  Result := False;
  if (nodes = nil) or (jsPatch = nil) then
    Exit;
  for i := 0 to nodes.Count - 1 do begin
    node := TNode(nodes[i]);
    jsPoint := TlkJSONobject.Create;
    jsPoint.Add('id', node.id);
    jsPoint.Add('lat', node.b);
    jsPoint.Add('lon', node.l);
    jl := TlkJSONlist.Create;
    jl.Add(jsPoint);
    jsPatch.Add('O/S/P/' + node.sGUID, jl);
  end;
  Result := True;
end;

// Экспортируем все ребра (кривые) в JSON
function TDMChainToJSON.EdgesToJSON(jsPatch: TlkJSONobject): Boolean;
var
  i, j, nSize: Integer;
  edge: TEdge;
  pPolyLine: PLLine;
  x, y: Double;
  jsPoint, jsCurve: TlkJSONobject;
  jl, jlInternalPoints: TlkJSONlist;
begin
  Result := False;
  if (edges = nil) or (jsPatch = nil) then
    Exit;
  // Выделяем память под массив вершин ломаной максимального размера
  nSize := SizeOf(SmallInt) + (High(SmallInt) + 1) * SizeOf(TPoint);
  pPolyLine := PLLine(AllocMem(nSize));
  for i := 0 to edges.Count - 1 do begin
    edge := TEdge(edges[i]);
    jsCurve := TlkJSONobject.Create;
    jsCurve.Add('id', edge.id);
    jsCurve.Add('interpolationType', 'loxodromic');
    // Экспортируем ссылки на начальную и конечную точки кривой. Для этого используем
    // соединительные узлы ребра. Код работает как для одного узла (замкнутая кривая),
    // так и двух (незамкнутая кривая).
    if edge.nodes.Count > 0 then begin
      jsCurve.Add('startPoint', 'O/S/P/' + TNode(edge.nodes[0]).sGUID);
      jsCurve.Add('endPoint', 'O/S/P/' + TNode(edge.nodes[edge.nodes.Count - 1]).sGUID);
    end;
    // Экспортируем внутренние точки кривой
    jlInternalPoints := TlkJSONlist.Create;
    ZeroMemory(pPolyLine, nSize);
    dm_Get_ve_Poly(edge.id, pPolyLine, nil, High(SmallInt));
    for j := 1 to pPolyLine^.N - 1 do begin
      dm_L_to_G(pPolyLine^.Pol[j].X, pPolyLine^.Pol[j].Y, x, y);
      dm_XY_BL(x, y, x, y);
      jsPoint := TlkJSONobject.Create;
      jsPoint.Add('lat', x * 180 / Pi);
      jsPoint.Add('lon', y * 180 / Pi);
      jlInternalPoints.Add(jsPoint);
    end;
    jsCurve.Add('internalPoints', jlInternalPoints);
    jl := TlkJSONlist.Create;
    jl.Add(jsCurve);
    jsPatch.Add('O/S/C/' + edge.sGUID, jl);
  end;
  FreeMem(pPolyLine);
  Result := True;
end;

// Экспортируем все мультиточки в JSON
function TDMChainToJSON.MultiPointToJSON(multipoint: TMultiPoint; jsPatch: TlkJSONobject): Boolean;
var
  i, nPoints, nSize: Integer;
  jsMultiPoint, jsPoint: TlkJSONobject;
  jl, jlPoints: TlkJSONlist;
  xyLine: TLLine;
  zLine: TIntegers;
  x, y: Double;
begin
  Result := False;
  if (multipoint = nil) or (jsPatch = nil) then
    Exit;
  // Максимальное число точек в массивах глубин, которые формирует функция
  // "Собрать массивы глубин" из dll_cn.dll - 512. Поэтому размещаем массивы xyLine и zLine на стеке.
  // Получаем локальные x, y, z координаты массива глубин.
  nSize := SizeOf(TLPoly) div SizeOf(TPoint);
  nPoints := dm_Get_Poly_xyz(@xyLine, @zLine, nSize - 1);
  jlPoints := TlkJSONlist.Create;
  // Преобразуем и экспортируем координаты мультиточки в JSON
  for i := 0 to nPoints do begin
    dm_L_to_G(xyLine.Pol[i].X, xyLine.Pol[i].Y, x, y);
    dm_XY_BL(x, y, x, y);
    jsPoint := TlkJSONobject.Create;
    jsPoint.Add('lat', x * 180 / Pi);
    jsPoint.Add('lon', y * 180 / Pi);
    jsPoint.Add('height', zLine[i] / dm_z_res);
    jlPoints.Add(jsPoint);
  end;
  jsMultiPoint := TlkJSONobject.Create;
  jsMultiPoint.Add('id', multipoint.id);
  jsMultiPoint.Add('verticalCrs', 2);
  jsMultiPoint.Add('coordinates', jlPoints);
  jl := TlkJSONlist.Create;
  jl.Add(jsMultiPoint);
  jsPatch.Add('O/S/MP3/' + multipoint.sGUID, jl);
  Result := True;
end;

// Экспортируем все композиты в JSON
function TDMChainToJSON.CompositesToJSON(jsPatch: TlkJSONobject): Boolean;
var
  i, j: Integer;
  composite: TComposite;
  orientedEdge: TOrientedEdge;
  jsComposite, jsComponent: TlkJSONobject;
  jlComponents, jlComposite: TlkJSONlist;
begin
  Result := False;
  if (composites = nil) or (jsPatch = nil) then
    Exit;
  for i := 0 to composites.Count - 1 do begin
    composite := TComposite(composites[i]);
    jsComposite := TlkJSONobject.Create;
    jsComposite.Add('id', composite.id);
    jlComponents := TlkJSONlist.Create;
    for j := 0 to composite.orientedEdges.Count - 1 do begin
      orientedEdge := TOrientedEdge(composite.orientedEdges[j]);
      jsComponent := TlkJSONobject.Create;
      if orientedEdge.orientation = toForward then
        jsComponent.Add('orientation', 'forward')
      else
        jsComponent.Add('orientation', 'backward');
      jsComponent.Add('ref', 'O/S/C/' + orientedEdge.edge.sGUID);
      jlComponents.Add(jsComponent);
    end;
    jsComposite.Add('components', jlComponents);
    jlComposite := TlkJSONlist.Create;
    jlComposite.Add(jsComposite);
    jsPatch.Add('O/S/CC/' + composite.sGUID, jlComposite);
  end;
  Result := True;
end;

// Экспортируем все композиты в JSON
function TDMChainToJSON.SurfacesToJSON(jsPatch: TlkJSONobject): Boolean;
var
  i, j: Integer;
  surface: TSurface;
  orientedComposite: TOrientedComposite;
  jsSurface, jsRing: TlkJSONobject;
  jlRings, jlSurface: TlkJSONlist;
begin
  Result := False;
  if (surfaces = nil) or (jsPatch = nil) then
    Exit;
  for i := 0 to surfaces.Count - 1 do begin
    surface := TSurface(surfaces[i]);
    jsSurface := TlkJSONobject.Create;
    jsSurface.Add('id', surface.id);
    jlRings := TlkJSONlist.Create;
    for j := 0 to surface.orientedComposites.Count - 1 do begin
      jsRing := TlkJSONobject.Create;
      if j = 0 then
        jsRing.Add('exteriorInterior', 'exterior')
      else
        jsRing.Add('exteriorInterior', 'interior');
      orientedComposite := TOrientedComposite(surface.orientedComposites[j]);
      if orientedComposite.orientation = toForward then
        jsRing.Add('orientation', 'forward')
      else
        jsRing.Add('orientation', 'backward');
      // Этот код приводит к образованию композитов, на которые никто не ссылается
      // Потому будем всегда делать кольца из композитов
{
      // Если число ориентированных ребер больше 1, кольцо - композит,
      // в противном случае - обычная кривая
      if orientedComposite.composite.orientedEdges.Count > 1 then
        jsRing.Add('ref', 'O/S/CC/' + orientedComposite.composite.sGUID)
      else
        jsRing.Add('ref', 'O/S/C/' + TOrientedEdge(orientedComposite.composite.orientedEdges[0]).edge.sGUID);
}
      jsRing.Add('ref', 'O/S/CC/' + orientedComposite.composite.sGUID);
      jlRings.Add(jsRing);
    end;
    jsSurface.Add('rings', jlRings);
    jlSurface := TlkJSONlist.Create;
    jlSurface.Add(jsSurface);
    jsPatch.Add('O/S/S/' + surface.sGUID, jlSurface);
  end;
  Result := True;
end;

// Экспортируем атрибуты объекта в JSON
function TDMChainToJSON.AttributesToJSON(jsAttributes: TlkJSONobject): Boolean;
var
  attributesPool: TPool;
  pAttribute, i, iPos, iPos2, iValue, iCode, pOld: Integer;
  attrBuffer: TBytes;
  attrType, attrTypeFromClassifier: Id_Tag;
  attrNumber, blankNumber: Word;
  pAttrProperties: PAbcRec1;
  multiByteStr: TShortStr;
  wideCharStr: TWideStr;
  jl: TlkJSONlist;
  jsDatatype: TlkJSONobject;
  s, sValue: string;
  dValue: Double;
  formatSettings: TFormatSettings;
begin
  Result := False;
  if jsAttributes = nil then Exit;
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
      // Если это идентификатор объекта
      if (attrNumber = 1000) or (attrNumber = 1007) or (attrNumber = 999) then begin
  //      jsAttributes.Add('id', PLongint(@attrBuffer)^);
        // Заканчиваем, если достигли конца буфера, иначе продолжаем
        if pAttribute >= attributesPool.Len then
          Break;
        Continue;
      end;
      // Извлекаем акроним из имени атрибута
      idx_Get_Name(attrNumber, multiByteStr);
      s := AnsiString(multiByteStr);
      iPos := AnsiPos('/', s);
      // Если акроним пустой, ничего не делаем и идем дальше
      if iPos < 2 then begin
        Writeln(tfLog, Format('Атрибут %d не описан в классификаторе S-101', [attrNumber]));
        if pAttribute >= attributesPool.Len then
          Break;
        Continue;
      end;
      s := AnsiLeftStr(s, iPos - 1);
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
      // Используем уточненный тип атрибута для формирования его значения в JSON
      case attrType of
        _byte, _word, _int, _long, _dbase: begin
          // Если целый атрибут имеет уточненный тип list, целочисленное значение
          // выводится как массив.
          if attrTypeFromClassifier = _list then begin
            jl := TlkJSONlist.Create;
            jl.Add(PLongint(@attrBuffer)^);
            jsAttributes.Add(s, jl);
          end
          // Если Boolean, true или false
          else if attrTypeFromClassifier = _bool then
            jsAttributes.Add(s, Boolean(PLongint(@attrBuffer)^))
          else
            jsAttributes.Add(s, PLongint(@attrBuffer)^);
        end;
        _string, _text, _latin1: begin
          sValue := PShortString(@attrBuffer)^;
          // Если строковый атрибут имеет тип list, формируется массив целочисленных значений
          if attrTypeFromClassifier = _list then begin
            jl := TlkJSONlist.Create;
            iPos := 1;
            while True do begin
              iPos2 := PosEx(',', sValue, iPos);
              if iPos2 > 0 then
                Val(AnsiMidStr(sValue, iPos, iPos2 - iPos), iValue, iCode)
              else
                Val(AnsiRightStr(sValue, Length(sValue) - iPos + 1), iValue, iCode);
              if iCode <> 0 then Break;
              jl.Add(iValue);
              if iPos2 = 0 then Break;
              iPos := iPos2 + 1;
            end;
            if iCode = 0 then
              jsAttributes.Add(s, jl)
            else begin
              jl.Free;
              jsAttributes.Add(s, sValue);
            end;
          end
          // В противном случае строка перекодируется из кодировки OEM в Unicode
          else begin
            ZeroMemory(@wideCharStr, SizeOf(TWideStr));
            MultiByteToWideChar(CP_OEMCP, MB_PRECOMPOSED, PChar(sValue),
                Length(sValue), wideCharStr, SizeOf(TWideStr) div SizeOf(WideChar));
            sValue := AnsiString(WideString(wideCharStr));
            jsAttributes.Add(s, sValue);
          end;
        end;
        _unicode: begin
          ZeroMemory(@wideCharStr, SizeOf(TWideStr));
          Move((PChar(@attrBuffer) + SizeOf(SmallInt))^, wideCharStr, PSmallInt(@attrBuffer)^ * SizeOf(WideChar));
          sValue := AnsiString(WideString(wideCharStr));
          jsAttributes.Add(s, sValue);
        end;
        _float, _real, _angle: begin
          sValue := Format('%.6e', [PSingle(@attrBuffer)^], formatSettings);
          Val(sValue, dValue, iCode);
          jsAttributes.Add(s, dValue);
        end;
        _double: begin
          sValue := Format('%.6e', [PDouble(@attrBuffer)^], formatSettings);
          Val(sValue, dValue, iCode);
          jsAttributes.Add(s, dValue);
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
            s := AnsiLeftStr(s, iPos - 1);
            jl := jsAttributes.Field[s] as TlkJSONlist;
            if jl = nil then begin
              jl := TlkJSONlist.Create;
              jsAttributes.Add(s, jl);
            end;
            jsDatatype := TlkJSONobject.Create;
            AttributesToJSON(jsDatatype);
            jl.Add(jsDatatype);
          end;
        end;
      end;
      if not dm_Goto_right then Break;
    end;
  end;
  dm_Goto_node(pOld);
  Result := True;
end;

// Экспортируем геометрию объекта в JSON
function TDMChainToJSON.GeometryToJSON(feature: TFeature; jlGeometry: TlkJSONlist;
    jsPatch: TlkJSONobject): Boolean;
var
  jsGeometry: TlkJSONobject;
  multipoint: TMultiPoint;
  poly: TLLine;
  nPoints, i, maxId: Integer;
  x, y: Double;
  z: Single;
  jsPoint: TlkJSONobject;
  jl: TlkJSONlist;
  _3dPoint: T3DPoint;
  node: TNode;
begin
  Result := False;
  if (feature = nil) or (jlGeometry = nil) then Exit;
  jsGeometry := TlkJSONobject.Create;
  jsGeometry.Add('scaleRange', TlkJSONobject.Create);
  // В зависимости от характера локализации
  case feature.loc of
    // Точечные SOUNDG
    1: begin
      if feature.name = 'SOUNDG' then begin
        nPoints := dm_Get_Poly_Buf(@poly, LPoly_Max) + 1;
        if nPoints = 1 then begin
          dm_L_to_G(poly.Pol[0].X, poly.Pol[0].Y, x, y);
          dm_XY_BL(x, y, x, y);
          if dm_Get_Real(1007, 0, z) then begin
            if _3dPoints.Count = 0 then begin
              maxId := 0;
              for i := 0 to nodes.Count - 1 do begin
                node := TNode(nodes[i]);
                if node.id > maxId then
                  maxId := node.id;
              end;
            end
            else
              maxId := T3DPoint(_3dPoints[_3dPoints.Count - 1]).id;
            _3dPoint := T3DPoint.Create(maxId + 1);
            jsPoint := TlkJSONobject.Create;
            jsPoint.Add('id', _3dPoint.id);
            jsPoint.Add('lat', x * 180 / Pi);
            jsPoint.Add('lon', y * 180 / Pi);
            jsPoint.Add('height', z);
            jsPoint.Add('verticalCrs', 2);
            jl := TlkJSONlist.Create;
            jl.Add(jsPoint);
            jsPatch.Add('O/S/P3/' + _3dPoint.sGUID, jl);
            _3dPoints.Add(_3dPoint);
            jsGeometry.Add('ref', 'O/S/P3/' + _3dPoint.sGUID);
          end;
        end;
      end;
    end;
    // Массив глубин
    11: begin
      multipoint := TMultiPoint(feature.multipoints[0]);
      MultiPointToJSON(multipoint, jsPatch);
      jsGeometry.Add('ref', 'O/S/MP3/' + multipoint.sGUID);
    end;
    // Узел
    21: jsGeometry.Add('ref', 'O/S/P/' + TNode(feature.nodes[0]).sGUID);
    // Ребро (кривая) или композит
    22: begin
      jsGeometry.Add('orientation', 'forward');
      if feature.composites.Count > 0 then
        jsGeometry.Add('ref', 'O/S/CC/' + TComposite(feature.composites[0]).sGUID)
      else
        jsGeometry.Add('ref', 'O/S/C/' + TEdge(feature.edges[0]).sGUID);
    end;
    // Поверхность
    23: begin
      jsGeometry.Add('orientation', 'forward');
      jsGeometry.Add('ref', 'O/S/S/' + TSurface(feature.surfaces[0]).sGUID);
    end;
  end;
  jlGeometry.Add(jsGeometry);
  Result := True;
end;

function IsFeatureAncestor(feature, descendant: TFeatureClass): Boolean;
var
  i: Integer;
  parent: TFeatureClass;
begin
  Result := False;
  if (feature = nil) or (descendant = nil) then Exit;
  for i := 0 to descendant.parentFeatureClasses.Count - 1 do begin
    parent := TFeatureClass(descendant.parentFeatureClasses[i]);
    if feature = parent then begin
      Result := True;
      Exit;
    end;
    if IsFeatureAncestor(feature, parent) then begin
      Result := True;
      Exit;
    end;
  end;
end;

function TDMChainToJSON.CreateAndOrderFeatureClasses: Boolean;
var
  feature, associatedFeature: TFeature;
  rawFeatureClasses, oneGenerationFeatureClasses, tempFeatureClasses: TObjectList;
  featureAssociation: TFeatureAssociation;
  featureClass, associatedFeatureClass, parentFeatureClass: TFeatureClass;
  suspectedAncestor, suspectedDescendant: TFeatureClass;
  i, j, k, iSOUNDG_1, iSOUNDG_11: Integer;
  bFound: Boolean;
  bExcludedArray: array of Boolean;
  bStop: Boolean;
begin
  Result := False;
  if featureClasses = nil then
    featureClasses := TObjectList.Create
  else
    featureClasses.Clear;
  rawFeatureClasses := TObjectList.Create(False);
  for i := 0 to features.Count - 1 do begin
    feature := TFeature(features[i]);

    if feature.id = 29 then
      bStop := True;

    bFound := False;
    for j := 0 to rawFeatureClasses.Count - 1 do begin
      featureClass := TFeatureClass(rawFeatureClasses[j]);
      if (feature.code = featureClass.code) and (feature.loc = featureClass.loc) then begin
        bFound := True;
        Break;
      end;
    end;
    if not bFound then begin
      featureClass := TFeatureClass.Create(feature.code, feature.loc, feature.name);
      rawFeatureClasses.Add(featureClass);
    end;
    for j := 0 to feature.featureAssociations.Count - 1 do begin
      featureAssociation := TFeatureAssociation(feature.featureAssociations[j]);
      if featureAssociation.assocDir = adBackward then
        Continue;
      bFound := False;
      for k := 0 to features.Count - 1 do begin
        associatedFeature := TFeature(features[k]);
        if associatedFeature.id = featureAssociation.id then begin
          bFound := True;
          Break;
        end;
      end;
      if not bFound then Exit;
      bFound := False;
      for k := 0 to rawFeatureClasses.Count - 1 do begin
        associatedFeatureClass := TFeatureClass(rawFeatureClasses[k]);
        if (associatedFeature.code = associatedFeatureClass.code) and
            (associatedFeature.loc = associatedFeatureClass.loc) then begin
          bFound := True;
          Break;
        end;
      end;
      if not bFound then begin
        associatedFeatureClass := TFeatureClass.Create(associatedFeature.code,
            associatedFeature.loc, associatedFeature.name);
        rawFeatureClasses.Add(associatedFeatureClass);
      end;
      if featureClass.childFeatureClasses.IndexOf(associatedFeatureClass) < 0 then
        featureClass.childFeatureClasses.Add(associatedFeatureClass);
    end;
  end;
  for i := 0 to rawFeatureClasses.Count - 1 do begin
    featureClass := TFeatureClass(rawFeatureClasses[i]);
    for j := 0 to featureClass.childFeatureClasses.Count - 1 do begin
      associatedFeatureClass := TFeatureClass(featureClass.childFeatureClasses[j]);
      associatedFeatureClass.parentFeatureClasses.Add(featureClass);
    end;
  end;
  oneGenerationFeatureClasses := TObjectList.Create(False);
  for i := 0 to rawFeatureClasses.Count - 1 do begin
    featureClass := TFeatureClass(rawFeatureClasses[i]);
    if featureClass.childFeatureClasses.Count = 0 then
      oneGenerationFeatureClasses.Add(featureClass);
  end;
  while oneGenerationFeatureClasses.Count > 0 do begin
    tempFeatureClasses := TObjectList.Create(False);
    for i := 0 to oneGenerationFeatureClasses.Count - 1 do begin
      featureClass := TFeatureClass(oneGenerationFeatureClasses[i]);
      if featureClass.name = 'LitSec' then
        bStop := True;
      featureClasses.Add(featureClass);
      for j := 0 to featureClass.parentFeatureClasses.Count - 1 do begin
        parentFeatureClass := TFeatureClass(featureClass.parentFeatureClasses[j]);
        if tempFeatureClasses.IndexOf(parentFeatureClass) < 0 then
          tempFeatureClasses.Add(parentFeatureClass);
      end;
    end;
    oneGenerationFeatureClasses.Clear;
    SetLength(bExcludedArray, tempFeatureClasses.Count);
    for i := 0 to tempFeatureClasses.Count - 1 do
      bExcludedArray[i] := False;
    for i := 0 to tempFeatureClasses.Count - 1 do
      for j := 0 to tempFeatureClasses.Count - 1 do
        if (i <> j) and not bExcludedArray[i] and not bExcludedArray[j] then begin
          suspectedAncestor := TFeatureClass(tempFeatureClasses[i]);
          suspectedDescendant := TFeatureClass(tempFeatureClasses[j]);
          if IsFeatureAncestor(suspectedAncestor, suspectedDescendant) then
            bExcludedArray[i] := True;
        end;
    for i := 0 to tempFeatureClasses.Count - 1 do
      if not bExcludedArray[i] then
        oneGenerationFeatureClasses.Add(tempFeatureClasses[i]);
    SetLength(bExcludedArray, 0);
    tempFeatureClasses.Free;
  end;
  oneGenerationFeatureClasses.Free;
  rawFeatureClasses.Free;
{
  // Если в массиве классов есть (SOUNDG, 1), то класс (SOUNDG, 11) удаляется.
  // Это необходимо, так как функция dm_Find_Frst_Code/dm_Find_Next_Code на
  // запрос объектов класса (SOUNDG, 1) возвращает также и объекты класса (SOUNDG, 11).
  iSOUNDG_1 := -1;
  iSOUNDG_11 := -1;
  for i := 0 to featureClasses.Count - 1 do begin
    featureClass := TFeatureClass(featureClasses[i]);
    if featureClass.name = 'SOUNDG' then
      if featureClass.loc = 1 then
        iSOUNDG_1 := i
      else
        iSOUNDG_11 := i;
  end;
  if (iSOUNDG_1 >= 0) and (iSOUNDG_11 >= 0) then
    featureClasses.Delete(iSOUNDG_11);
}    
  Result := True;
end;

const sAssocTypeArray: array[0..2] of string = ('Association', 'Aggregation', 'Composition');

// Экспортируем объекты в JSON
function TDMChainToJSON.ObjectsToJSON(mapPath, logName: string; var sError: string): Boolean;
var
  js, jsPatch, jsObject, jsAttributes, jsAssociation: TlkJSONobject;
  jl: TlkJSONlist;
  i, j, objLevel, iPos, id, iClass, iLoc, offset: Integer;
  sContent, tempFile, s, sOutFileName: string;
  tf, tf2: TextFile;
  multiByteStr: TShortStr;
  feature, assocFeature: TFeature;
  featureAssociation: TFeatureAssociation;
  featureClass: TFeatureClass;
begin
  Result := False;
  // Открываем карту DM
  if dm_Open(PChar(mapPath), False) = 0 then begin
    sError := Format('Не удалось открыть файл %s', [mapPath]);
    Exit;
  end;
  try
    // Создаем файл протокола
    AssignFile(tfLog, logName);
    Rewrite(tfLog);

    // Формирование JSON
    js := TlkJSONobject.Create;
    js.Add('branch', AnsiReplaceText(AnsiUpperCase(ExtractFileName(mapPath)), '.DM', ''));
    DateTimeToString(s, 'yyyy-mm-dd hh:mm:ss', Date + Time);
    js.Add('message', s);
    jsPatch := TlkJSONobject.Create;

    // Импортируем цепочно-узловую структуру из DM-файла
    if UpdateProgress('Импортируем цепочно-узловую структуру из DM-файла', 0, 0) then
      Exit;
    if not ChainDataFromDM(sError) then
      Exit;
    CreateAndOrderFeatureClasses;

    // Экспортируем геометрические примитивы в JSON
    if UpdateProgress('Экспортируем геометрические примитивы в JSON', 0, 0) then
      Exit;
    NodesToJSON(jsPatch);
    EdgesToJSON(jsPatch);
    CompositesToJSON(jsPatch);
    SurfacesToJSON(jsPatch);

    // Экспортируем в JSON объекты карты
    Writeln(tfLog, Format('Всего %d классов объектов', [featureClasses.Count]));
    for iClass := 0 to featureClasses.Count - 1 do begin
      if UpdateProgress('Экспортируем в JSON объекты карты', iClass, featureClasses.Count - 1) then
        Exit;
      featureClass := TFeatureClass(featureClasses[iClass]);
      Writeln(tfLog, Format('i=%d, name=%s, loc=%d, code=%d',
          [iClass, featureClass.name, featureClass.loc, featureClass.code]));
      Flush(tfLog);
      offset := dm_Find_Frst_Code(featureClass.code, featureClass.loc);
      while offset > 0 do begin
        dm_Get_Long(1000, 0, id);
        // Ищем соответствующую фичу в массиве
        feature := nil;
        for i := 0 to features.Count - 1 do begin
          feature := TFeature(features[i]);
          if feature.id = id then
            Break;
        end;
        if (feature = nil) or (feature.id <> id) then begin
          Writeln(tfLog, Format('Объект %d не найден в массиве объектов', [id]));
          Flush(tfLog);
          offset := dm_Find_Next_Code(featureClass.code, featureClass.loc);
          Continue;
        end;
        // Экспортируем объект
        Writeln(tfLog, Format('Экспортируем объект %d', [feature.id]));
        Flush(tfLog);
        jsObject := TlkJSONobject.Create;
        jsObject.Add('id', feature.id);
        jsObject.Add('code', feature.name);
        jsObject.Add('globalId', feature.sGUID);
        // Экспортируем атрибуты
        jsAttributes := TlkJSONobject.Create;
        AttributesToJSON(jsAttributes);
        jsObject.Add('attributes', jsAttributes);
        // Экспортируем геометрию объекта
        jl := TlkJSONlist.Create;
        GeometryToJSON(feature, jl, jsPatch);
        jsObject.Add('geometry', jl);
        // Экспортируем ассоциации объекта
        jl := TlkJSONlist.Create;
        for i := 0 to feature.featureAssociations.Count - 1 do begin
          featureAssociation := TFeatureAssociation(feature.featureAssociations[i]);
          // Находим фичу по ассоциации
          jsAssociation := TlkJSONobject.Create;
          for j := 0 to features.Count - 1 do begin
            assocFeature := TFeature(features[j]);
            if assocFeature.id = featureAssociation.id then Break;
          end;
          // Экспортируем свойства ассоциации, учитывая направление связи
          if featureAssociation.assocDir = adForward then begin
            jsAssociation.Add('ref', 'O/F/' + assocFeature.sGUID);
            jsAssociation.Add('associationCode', assocFeature.name + '$' + featureAssociation.name);
          end
          else begin
            jsAssociation.Add('rref', 'O/F/' + assocFeature.sGUID);
            jsAssociation.Add('associationCode', assocFeature.name + '@' + featureAssociation.name);
          end;
          jsAssociation.Add('roleCode', sAssocTypeArray[Ord(featureAssociation.assocType)]);
          jl.Add(jsAssociation);
        end;
        jsObject.Add('featureAssociations', jl);
        jl := TlkJSONlist.Create;
        jl.Add(jsObject);
        jsPatch.Add(Format('O/F/%s', [feature.sGUID]), jl);
        offset := dm_Find_Next_Code(featureClass.code, featureClass.loc);
      end;
    end;
    js.Add('patch', jsPatch);
    if UpdateProgress('Сохраняем JSON в файл', 0, 0) then
      Exit;
    // Генерируем текст из JSON и сохраняем во временном файле
    i := 0;
    sContent := GenerateReadableText(js, i);
    tempFile := ExtractFilePath(mapPath) + 'temp.json';
    AssignFile(tf, tempFile);
    Rewrite(tf);
    WriteLn(tf, sContent);
    CloseFile(tf);
    // Заменяем "\/" на "/"
    Reset(tf);
    sOutFileName := AnsiReplaceStr(mapPath, ExtractFileExt(mapPath), '.json');
    AssignFile(tf2, sOutFileName);
    Rewrite(tf2);
    while not Eof(tf) do begin
      ReadLn(tf, s);
      s := StringReplace(s, '\/', '/', [rfReplaceAll]);
      WriteLn(tf2, s);
    end;
    CloseFile(tf);
    CloseFile(tf2);
    // Удаляем временный файл
    DeleteFile(PChar(tempFile));
    Result := True;
  finally
    // Закрываем карту
    dm_Done;
    // Закрываем протокол
    Close(tfLog);
    js.Free;
  end;
end;

function TDMChainToJSON.ChainDataFromDM(var sError: string): Boolean;
var
  nNodes, nEdges, nObjects, nRefs, id, i, j, k, objLevel, loc, nPolyCount, nSize: Integer;
  iEdgeInComposite, iNode1, iNode2, compositeID, surfaceID, nEqualNodes, iTemp, iPos: Integer;
  multipointID, code: Integer;
  refs: TIntegers;
  s: string;
  feature: TFeature;
  node, node1, node2: TNode;
  neighborNodes: array[0..3] of TNode;
  edge, edge1, edge2: TEdge;
  objects: array of Integer;
  pPolyLine: PLLine;
  bFound: Boolean;
  composite: TComposite;
  orientation, orientation1, orientation2: TOrientation;
  buffer: ShortString;
  surface: TSurface;
  area: Double;
  orientedEdge: TOrientedEdge;
  orientedComposite: TOrientedComposite;
  nodeRec: tcn_rec;
  featureAssociation: TFeatureAssociation;
  assocType: TAssociationType;
  assocDir: TAssociationDirection;
  multiByteStr: TShortStr;
  guid: TGUID;
  multipoint: TMultiPoint;
  x, y: Double;
  bNewComposite: Boolean;
  bStop: Boolean;
begin
  Result := False;
  // Обрабатываем узлы
  nNodes := dm_Get_vc_Count;
  for i := 0 to nNodes - 1 do begin
    id := dm_Get_vc_Id(i);
    ZeroMemory(@nodeRec, SizeOf(tcn_rec));
    if not dm_Get_vc(id, nodeRec) then
      Continue;
    dm_L_to_G(nodeRec.Pos.X, nodeRec.Pos.Y, x, y);
    dm_XY_BL(x, y, x, y);
    x := x * 180 / Pi;
    y := y * 180 / Pi;
    node := TNode.Create(id, '', x, y);
    nodes.Add(node);
    // Ссылки объектов на узел
    nRefs := dm_Get_vi_ref(id, @refs, 1024);
    for j := 0 to nRefs - 1 do begin
      for k := 0 to features.Count - 1 do
        if TFeature(features[k]).id = refs[j] then Break;
      if k < features.Count then
        feature := TFeature(features[k])
      else begin
        feature := TFeature.Create(refs[j]);
        features.Add(feature);
      end;
      node.objects.Add(feature);
      feature.nodes.Add(node);
    end;
    // Ссылки ребер на узел
    nRefs := dm_Get_vc_ref(id, @refs, 1024);
    for j := 0 to nRefs - 1 do begin
      for k := 0 to edges.Count - 1 do
        if TEdge(edges[k]).id = refs[j] then Break;
      if k < edges.Count then
        edge := TEdge(edges[k])
      else begin
        edge := TEdge.Create(refs[j]);
        edges.Add(edge);
      end;
      node.edges.Add(edge);
      edge.nodes.Add(node);
    end;
  end;

  // Обрабатываем ребра
  nEdges := dm_Get_ve_Count;
  for i := 0 to nEdges - 1 do begin
    id := dm_Get_ve_Id(i);
    for j := 0 to edges.Count - 1 do
      if TEdge(edges[j]).id = id then Break;
    if j < edges.Count then
      edge := TEdge(edges[j])
    else begin
      edge := TEdge.Create(id);
      edges.Add(edge);
    end;
    // Ссылки объектов на ребро
    nRefs := dm_Get_ve_ref(id, @refs, 1024);
    for j := 0 to nRefs - 1 do begin
      for k := 0 to features.Count - 1 do
        if TFeature(features[k]).id = refs[j] then Break;
      if k < features.Count then
        feature := TFeature(features[k])
      else begin
        feature := TFeature.Create(refs[j]);
        features.Add(feature);
      end;
      edge.objects.Add(feature);
      //feature.edges.Add(edge);
    end;
  end;

  // Собираем "живые" объекты с карты
  if not dm_open_idx then begin
    sError := 'Классификатор карты не найден';
    Exit;
  end;
  nObjects := 0;
  multipointID := 1;
  if (dm_Goto_Root > 0) and dm_Goto_down then begin
    objLevel := 1;
    while True do begin
      if objLevel = 1 then
        if dm_Goto_down then
          objLevel := 2
        else if not dm_Goto_right then Break;
      if objLevel = 2 then begin
        // Обработка
        loc := dm_Get_Local;
        code := dm_Get_Code;
        obj_Get_Name(code, loc, multiByteStr);
        s := AnsiString(multiByteStr);
        iPos := AnsiPos('/', s);
        // Если есть акроним
        if iPos > 0 then begin
          dm_Get_Long(1000, 0, id);
          nObjects := nObjects + 1;
          SetLength(objects, nObjects);
          objects[nObjects - 1] := id;
          for i := 0 to features.Count - 1 do begin
            feature := TFeature(features[i]);
            if feature.id = id then Break;
          end;
          if i = features.Count then begin
            feature := TFeature.Create(id);
            features.Add(feature);
          end;
          feature.code := code;
          feature.loc := loc;
          feature.name := AnsiLeftStr(s, iPos - 1);
          if dm_Get_String(999, SizeOf(buffer), buffer) then
            feature.sGUID := AnsiUpperCase(buffer)
          else begin
            CreateGUID(guid);
            s := GUIDToString(guid);
            feature.sGUID := MidStr(s, 2, Length(s) - 2);
          end;
          // Если объект - это массив глубин
          if loc = 11 then begin
            multipoint := TMultiPoint.Create(multipointID);
            multipoints.Add(multipoint);
            feature.multipoints.Add(multipoint);
            multipoint.objects.Add(feature);
            multipointID := multipointID + 1;
          end;

          // Составим список ребер объекта
          if (loc = 22) or (loc = 23) then begin
            nPolyCount := dm_Get_Poly_Count;
            nSize := SizeOf(SmallInt) + (nPolyCount + 1) * SizeOf(TPoint);
            pPolyLine := PLLine(AllocMem(nSize));
            dm_Get_Poly_Buf(pPolyLine, nPolyCount);
            for i := 0 to nPolyCount do
              for j := 0 to edges.Count - 1 do begin
                edge := TEdge(edges[j]);
                if edge.id = pPolyLine^.Pol[i].X then begin
                  orientation := TOrientation((pPolyLine^.Pol[i].Y and $FF00) shr 8);
                  feature.edges.Add(edge);
                  Break;
                end;
              end;
            FreeMem(pPolyLine);
          end;

          // Сборка ассоциаций с другими объектами
          if dm_Goto_down then
            while True do begin
              if dm_Get_Local = 40 then begin
                dm_Get_Long(1001, 0, id);
                dm_Get_Long(1002, 0, iTemp);
                case iTemp of
                  1: assocDir := adForward;
                  2: assocDir := adBackward;
                end;
                dm_Get_Long(1003, 0, iTemp);
                case iTemp of
                  1: assocType := atAssociation;
                  2: assocType := atAggregation;
                  3: assocType := atComposition;
                end;
                dm_Get_String(9, SizeOf(buffer), buffer);
                s := AnsiString(buffer);
                iPos := AnsiPos('/', s);
                s := AnsiLeftStr(s, iPos - 1);
                featureAssociation := TFeatureAssociation.Create(id, s, assocType, assocDir);
                feature.featureAssociations.Add(featureAssociation);
              end;
              if not dm_Goto_right then begin
                dm_Goto_upper;
                Break;
              end;
            end;
        end;

        // Переход к следующему объекту слоя или наверх, если объекты кончились
        if not dm_Goto_right then begin
          dm_Goto_upper;
          objLevel := 1;
          if not dm_Goto_right then Break;
        end;
      end;
    end;
  end;
  dm_close_idx;

  // Удаляем "умершие" объекты
  for i := features.Count - 1 downto 0 do begin
    feature := TFeature(features[i]);
    for j := 0 to nObjects - 1 do
      if objects[j] = feature.id then Break;
    if j = nObjects then begin
      for j := feature.nodes.Count - 1 downto 0 do begin
        node := TNode(feature.nodes[j]);
        for k := 0 to nodes.Count - 1 do begin
          if TNode(nodes[k]).id = node.id then begin
            node.objects.Remove(feature);
            feature.nodes.Delete(j);
            Break;
          end;
        end;
      end;
      for j := feature.edges.Count - 1 downto 0 do begin
        edge := TEdge(feature.edges[j]);
        for k := 0 to edges.Count - 1 do begin
          if TEdge(edges[k]).id = edge.id then begin
            edge.objects.Remove(feature);
            feature.edges.Delete(j);
            Break;
          end;
        end;
      end;
      features.Delete(i);
    end;
  end;

  // Удаляем узлы и ребра, на которые нет ссылок
  for i := edges.Count - 1 downto 0 do begin
    edge := TEdge(edges[i]);
    if edge.objects.Count = 0 then begin
      for j := edge.nodes.Count - 1 downto 0 do begin
        node := TNode(edge.nodes[j]);
        node.edges.Remove(edge);
        edge.nodes.Delete(j);
      end;
      edges.Delete(i);
    end;
  end;
  for i := nodes.Count - 1 downto 0 do begin
    node := TNode(nodes[i]);
    if (node.edges.Count = 0) and (node.objects.Count = 0) then
      nodes.Delete(i);
  end;

  // Определяем ориентированные площади ребер. Для незамкнутых ребер площади
  // считаем тоже, так как они могут входить в замкнутые композиты. И тогда
  // площадь замкнутого композита равна алгебраической сумме площадей ребер,
  // входящих в композит.
  nSize := SizeOf(SmallInt) + (High(SmallInt) + 1) * SizeOf(TPoint);
  pPolyLine := PLLine(AllocMem(nSize));
  for i := 0 to edges.Count - 1 do begin
    edge := TEdge(edges[i]);
    ZeroMemory(pPolyLine, nSize);
    dm_Get_ve_Poly(edge.id, pPolyLine, nil, High(SmallInt));
    edge.area := Square_Poly(@pPolyLine^.Pol, pPolyLine^.N);
    // Упорядочиваем узлы ребра (начальный-конечный)
    dm_Get_vc(TNode(edge.nodes[0]).id, nodeRec);
    if (nodeRec.Pos.X <> pPolyLine^.Pol[0].X) or (nodeRec.Pos.Y <> pPolyLine^.Pol[0].Y) then
      edge.nodes.Exchange(0, 1);
  end;
  FreeMem(pPolyLine);

  // Формирование композитов
{
  // Если предполагалось, что линейный объект всегда ссылается на композит, в алгоритме
  // явная ошибка в случае, когда объект ссылается на одно незамкнутое ребро. В этом
  // случае композит не создается. Проще учесть это в вызывающем коде, чем разбираться здесь.
  compositeID := 1;
  for i := 0 to features.Count - 1 do begin
    feature := TFeature(features[i]);
    iEdgeInComposite := 0;
    for j := 0 to feature.edges.Count - 1 do begin
      edge := TEdge(feature.edges[j]);
      if edge.nodes.Count = 2 then begin
        if iEdgeInComposite = 0 then begin
          neighborNodes[0] := TNode(edge.nodes[0]);
          neighborNodes[1] := TNode(edge.nodes[1]);
        end
        else begin
          neighborNodes[2] := TNode(edge.nodes[0]);
          neighborNodes[3] := TNode(edge.nodes[1]);
          bFound := False;
          for iNode1 := 1 downto 0 do begin
            for iNode2 := 2 to 3 do
              if neighborNodes[iNode1] = neighborNodes[iNode2] then begin
                bFound := True;
                Break;
              end;
            if bFound then Break;
          end;
          if not bFound then begin
            composites.Add(composite);
            feature.composites.Add(composite);
            composite := nil;
            compositeID := compositeID + 1;
            neighborNodes[0] := neighborNodes[2];
            neighborNodes[1] := neighborNodes[3];
            iEdgeInComposite := 1;
            Continue;
          end;
          if iEdgeInComposite = 1 then begin
            composite := TComposite.Create(compositeID);
            if iNode1 = 1 then
              orientation := toForward
            else
              orientation := toBackward;
            composite.orientedEdges.Add(TOrientedEdge.Create(TEdge(feature.edges[j - 1]), orientation));
          end;
          if iNode2 = 2 then begin
            orientation := toForward;
            neighborNodes[0] := neighborNodes[2];
            neighborNodes[1] := neighborNodes[3];
          end
          else begin
            orientation := toBackward;
            neighborNodes[0] := neighborNodes[3];
            neighborNodes[1] := neighborNodes[2];
          end;
          composite.orientedEdges.Add(TOrientedEdge.Create(edge, orientation));
        end;
        iEdgeInComposite := iEdgeInComposite + 1;
      end
      else begin
        if iEdgeInComposite > 0 then begin
          composites.Add(composite);
          feature.composites.Add(composite);
          composite := nil;
          compositeID := compositeID + 1;
          iEdgeInComposite := 0;
        end;
        composite := TComposite.Create(compositeID);
        if edge.area > 0 then
          orientation := toForward
        else
          orientation := toBackward;
        composite.orientedEdges.Add(TOrientedEdge.Create(edge, orientation));
        composites.Add(composite);
        feature.composites.Add(composite);
        composite := nil;
        compositeID := compositeID + 1;
      end;
    end;
    if composite <> nil then begin
      composites.Add(composite);
      feature.composites.Add(composite);
      composite := nil;
      compositeID := compositeID + 1;
    end;
  end;
}

  Writeln(tfDebugLog, 'Формирование композитов');
  Flush(tfDebugLog);

  compositeID := 0;
  for i := 0 to features.Count - 1 do begin
    feature := TFeature(features[i]);
    if (feature.loc <> 22) and (feature.loc <> 23) then
      Continue;

    Writeln(tfDebugLog, Format('i=%d, id=%d, name=%s', [i, feature.id, feature.name]));
    Flush(tfDebugLog);

    if feature.id = 2017 then
      bStop := True;

    bNewComposite := True;
    dm_Jump_id(feature.id);
    nPolyCount := dm_Get_Poly_Count;
    nSize := SizeOf(SmallInt) + (nPolyCount + 1) * SizeOf(TPoint);
    pPolyLine := PLLine(AllocMem(nSize));
    dm_Get_Poly_Buf(pPolyLine, nPolyCount);
    for j := 0 to nPolyCount do
      for k := 0 to edges.Count - 1 do begin
        edge := TEdge(edges[k]);
        if edge.id = pPolyLine^.Pol[j].X then begin

          if i = 801 then begin
            Writeln(tfDebugLog, Format('j=%d, k=%d, id=%d', [j, k, edge.id]));
            Flush(tfDebugLog);
          end;

          orientation := TOrientation((pPolyLine^.Pol[j].Y and $FF00) shr 8);
          if bNewComposite then begin
            compositeID := compositeID + 1;
            composite := TComposite.Create(compositeID);
            composite.orientedEdges.Add(TOrientedEdge.Create(edge, orientation));
            feature.composites.Add(composite);
            composites.Add(composite);
          end
          else begin
            composite := TComposite(feature.composites[feature.composites.Count - 1]);
            composite.orientedEdges.Add(TOrientedEdge.Create(edge, orientation));
          end;
          orientedEdge := TOrientedEdge(composite.orientedEdges[0]);
          edge1 := orientedEdge.edge;
          orientation1 := orientedEdge.orientation;
          orientedEdge := TOrientedEdge(composite.orientedEdges[composite.orientedEdges.Count - 1]);
          edge2 := orientedEdge.edge;
          orientation2 := orientedEdge.orientation;
          if (orientation1 = toForward) or (edge1.nodes.Count = 1) then
            node1 := TNode(edge1.nodes[0])
          else
            node1 := TNode(edge1.nodes[1]);
          if (orientation2 = toBackward) or (edge2.nodes.Count = 1) then
            node2 := TNode(edge2.nodes[0])
          else
            node2 := TNode(edge2.nodes[1]);
          if (node1.b = node2.b) and (node1.l = node2.l) then
            bNewComposite := True
          else
            bNewComposite := False;
        end;
      end;
    FreeMem(pPolyLine);
  end;

  // Формирование поверхностей
  surfaceID := 1;
  for i := 0 to features.Count - 1 do begin
    feature := TFeature(features[i]);

    if feature.id = 2017 then
      bStop := True;

    if feature.loc = 23 then begin
      surface := TSurface.Create(surfaceID);
      for j := 0 to feature.composites.Count - 1 do begin
        composite := TComposite(feature.composites[j]);
//        area := composite.Area;
//        if ((j = 0) and (area > 0)) or ((j > 0) and (area < 0)) then
//          orientation := toForward
//        else
//          orientation := toBackward;
//        surface.orientedComposites.Add(TOrientedComposite.Create(composite, orientation));
        surface.orientedComposites.Add(TOrientedComposite.Create(composite, toForward));
      end;
      surface.objects.Add(feature);
      feature.surfaces.Add(surface);
      surfaces.Add(surface);
      surfaceID := surfaceID + 1;
    end;
  end;

  // Вывод в Log узлов, ребер, объектов
  WriteLn(tfDebugLog, Format('Всего узлов %d', [nodes.Count]));
  Flush(tfDebugLog);
  for i := 0 to nodes.Count - 1 do begin
    node := TNode(nodes[i]);
    id := node.id;
    WriteLn(tfDebugLog, Format('i=%d, id=%d', [i, id]));
    Flush(tfDebugLog);
    nRefs := node.edges.Count;
    s := '';
    for j := 0 to nRefs - 1 do begin
      if j > 0 then
        s := s + ',';
      s := s + Format('%d', [TEdge(node.edges[j]).id]);
    end;
    WriteLn(tfDebugLog, Format(#9'Ребра=(%s)', [s]));
    Flush(tfDebugLog);
    nRefs := node.objects.Count;
    s := '';
    for j := 0 to nRefs - 1 do begin
      if j > 0 then
        s := s + ',';
      s := s + Format('%d', [TFeature(node.objects[j]).id]);
    end;
    WriteLn(tfDebugLog, Format(#9'Объекты=(%s)', [s]));
    Flush(tfDebugLog);
  end;

  WriteLn(tfDebugLog, Format('Всего ребер %d', [edges.Count]));
  Flush(tfDebugLog);
  for i := 0 to edges.Count - 1 do begin
    edge := TEdge(edges[i]);
    id := edge.id;
    WriteLn(tfDebugLog, Format('i=%d, id=%d', [i, id]));
    Flush(tfDebugLog);
    nRefs := edge.nodes.Count;
    s := '';
    for j := 0 to nRefs - 1 do begin
      if j > 0 then
        s := s + ',';
      s := s + Format('%d', [TNode(edge.nodes[j]).id]);
    end;
    WriteLn(tfDebugLog, Format(#9'Узлы=(%s)', [s]));
    Flush(tfDebugLog);
    nRefs := edge.objects.Count;
    s := '';
    for j := 0 to nRefs - 1 do begin
      if j > 0 then
        s := s + ',';
      s := s + Format('%d', [TFeature(edge.objects[j]).id]);
    end;
    WriteLn(tfDebugLog, Format(#9'Объекты=(%s)', [s]));
    Flush(tfDebugLog);
  end;

  WriteLn(tfDebugLog, Format('Всего композитов %d', [composites.Count]));
  Flush(tfDebugLog);
  for i := 0 to composites.Count - 1 do begin
    composite := TComposite(composites[i]);
    WriteLn(tfDebugLog, Format('i=%d, id=%d', [i, composite.id]));
    Flush(tfDebugLog);

    if i = 349 then
      bStop := True;

    nRefs := composite.orientedEdges.Count;
    s := '';
    for j := 0 to nRefs - 1 do begin
      orientedEdge := TOrientedEdge(composite.orientedEdges[j]);
      if j > 0 then
        s := s + ',';
      id := orientedEdge.edge.id;
      if orientedEdge.orientation = toBackward then
        id := -id;
      s := s + Format('%d', [id]);
    end;
    WriteLn(tfDebugLog, Format(#9'Ребра=(%s)', [s]));
    Flush(tfDebugLog);
    nRefs := composite.objects.Count;
    s := '';
    for j := 0 to nRefs - 1 do begin
      feature := TFeature(composite.objects[j]);
      if j > 0 then
        s := s + ',';
      s := s + Format('%d', [feature.id]);
    end;
    WriteLn(tfDebugLog, Format(#9'Объекты=(%s)', [s]));
    Flush(tfDebugLog);
  end;

  WriteLn(tfDebugLog, Format('Всего поверхностей %d', [surfaces.Count]));
  Flush(tfDebugLog);
  for i := 0 to surfaces.Count - 1 do begin
    surface := TSurface(surfaces[i]);
    WriteLn(tfDebugLog, Format('i=%d, id=%d', [i, surface.id]));
    Flush(tfDebugLog);
    nRefs := surface.orientedComposites.Count;
    s := '';
    for j := 0 to nRefs - 1 do begin
      orientedComposite := TOrientedComposite(surface.orientedComposites[j]);
      if j > 0 then
        s := s + ',';
      id := orientedComposite.composite.id;
      if orientedComposite.orientation = toBackward then
        id := -id;
      s := s + Format('%d', [id]);
    end;
    WriteLn(tfDebugLog, Format(#9'Композиты=(%s)', [s]));
    Flush(tfDebugLog);
    nRefs := surface.objects.Count;
    s := '';
    for j := 0 to nRefs - 1 do begin
      feature := TFeature(surface.objects[j]);
      if j > 0 then
        s := s + ',';
      s := s + Format('%d', [feature.id]);
    end;
    WriteLn(tfDebugLog, Format(#9'Объекты=(%s)', [s]));
    Flush(tfDebugLog);
  end;

  WriteLn(tfDebugLog, Format('Всего объектов %d', [features.Count]));
  Flush(tfDebugLog);
  for i := 0 to features.Count - 1 do begin
    feature := TFeature(features[i]);
    WriteLn(tfDebugLog, Format('i=%d, id=%d, loc=%d, name=%s', [i, feature.id, feature.loc, feature.name]));
    Flush(tfDebugLog);
    case feature.loc of
      21: begin
        s := '';
        for j := 0 to feature.nodes.Count - 1 do begin
          if j > 0 then
            s := s + ',';
          s := s + Format('%d', [TNode(feature.nodes[j]).id]);
        end;
        WriteLn(tfDebugLog, Format(#9'Узлы=(%s)', [s]));
        Flush(tfDebugLog);
      end;
      22, 23: begin
        s := '';
        for j := 0 to feature.edges.Count - 1 do begin
          if j > 0 then
            s := s + ',';
          s := s + Format('%d', [TEdge(feature.edges[j]).id]);
        end;
        WriteLn(tfDebugLog, Format(#9'Ребра=(%s)', [s]));
        Flush(tfDebugLog);
        case feature.loc of
          22: begin
            if feature.edges.Count > 1 then begin
              s := '';
              for j := 0 to feature.composites.Count - 1 do begin
                if j > 0 then
                  s := s + ',';
                s := s + Format('%d', [TComposite(feature.composites[j]).id]);
              end;
              WriteLn(tfDebugLog, Format(#9'Композиты=(%s)', [s]));
              Flush(tfDebugLog);
            end;
          end;
          23: begin
            s := '';
            for j := 0 to feature.surfaces.Count - 1 do begin
              if j > 0 then
                s := s + ',';
              s := s + Format('%d', [TSurface(feature.surfaces[j]).id]);
            end;
            WriteLn(tfDebugLog, Format(#9'Поверхности=(%s)', [s]));
            Flush(tfDebugLog);
          end;
        end;
      end;
    end;
  end;
  Result := True;
end;

function TDMChainToJSON.ObjectsFromJSON(jsonPath, logPath: string; var sError: string): Boolean;
var
  s, sID, mapPath, objPath: string;
  fs: TFileStream;
  buffer: array of Char;
  size, iObject, iNode, ix, iy: Integer;
  jsS101, jsPatch, jsObject: TlkJSONobject;
  jlObject: TlkJSONlist;
  node: TNode;
  bmin, lmin, bmax, lmax, b, l, x, y: Double;
  pcPath, pcDir, pcName: TPathStr;
begin
  try
    Result := False;
    if (jsonPath = '') or not FileExists(jsonPath) then begin
      sError := 'Файл "' + jsonPath + '" не существует ';
      Exit;
    end;
    if logPath = '' then begin
      sError := 'Не задан путь к Log-файлу';
      Exit;
    end;
    AssignFile(tfLog, logPath);
    if FileExists(logPath) then
      Append(tfLog)
    else
      Rewrite(tfLog);
    WriteLn(tfLog, '');
    WriteLn(tfLog, '************************************************************');
    DateTimeToString(s, 'yyyy-mm-dd hh:mm:ss', Date + Time);
    WriteLn(tfLog, s);
    WriteLn(tfLog, 'Чтение набора данных S101 из файла ' + jsonPath);
    fs := TFileStream.Create(jsonPath, fmOpenRead	or fmShareDenyWrite);
    size := fs.Seek(0, soFromEnd);
    SetLength(buffer, size + 1);
    fs.Seek(0, soFromBeginning);
    fs.Read(buffer[0], size);
    buffer[size] := #0;
    fs.Free;
    jsS101 := TlkJSONobject(TlkJSON.ParseText(PChar(buffer)));
    if jsS101 = nil then begin
      sError := 'Не удалось разобрать файл ' + jsonPath;
      WriteLn(tfLog, sError);
      Exit;
    end;
    jsPatch := jsS101.Field['patch'] as TlkJSONobject;
    if jsPatch = nil then begin
      sError := 'В файле ' + jsonPath + ' отсутствует объект patch';
      WriteLn(tfLog, sError);
      Exit;
    end;
    bmin := Pi / 2;
    bmax := -Pi / 2;
    lmin := Pi;
    lmax := -Pi;
    for iObject := 0 to jsPatch.Count - 1 do begin
      jlObject := jsPatch.FieldByIndex[iObject] as TlkJSONlist;
      jsObject := jlObject.Child[0] as TlkJSONobject;
      sID := jsPatch.NameOf[iObject];
      if AnsiContainsStr(sID, 'O/S/P/') then begin
        b := jsObject.Field['lat'].Value / 180 * Pi;
        l := jsObject.Field['lon'].Value / 180 * Pi;
        node := TNode.Create(jsObject.Field['id'].Value,
            StringReplace(sID, 'O/S/P/', '', []), b, l);
        nodes.Add(node);
        if b < bmin then bmin := b;
        if b > bmax then bmax := b;
        if l < lmin then lmin := l;
        if l > lmax then lmax := l;
      end;
    end;
    mapPath := ChangeFileExt(jsonPath, '.dm');
    ZeroMemory(@pcPath, SizeOf(TPathStr));
    ZeroMemory(@pcDir, SizeOf(TPathStr));
    ZeroMemory(@pcName, SizeOf(TPathStr));
    dm_Work_Path(pcPath, pcDir, pcName);
    objPath := AnsiString(pcPath) + 'obj\' + 's101.obj';
    if not merc_Create(PChar(mapPath), PChar(objPath), bmin, lmin, bmax, lmax,
        (bmin + bmax) / 2, 9, 180000) then Exit;
    dm_Open(PChar(mapPath), true);
    for iNode := 0 to nodes.Count - 1 do begin
      node := TNode(nodes[iNode]);
      dm_BL_XY(node.b, node.l, x, y);
      dm_G_to_L(x, y, ix, iy);
      dm_add_vc(node.id, ix, iy, nil);
    end;
    dm_Done;
    Result := True;
  finally
    jsS101.Free;
    SetLength(buffer, 0);
    CloseFile(tfLog);
  end;
end;

end.
