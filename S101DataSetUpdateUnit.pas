unit S101DataSetUpdateUnit;

interface

uses
  S101TypesUnit, S101DataSetUnit, S101BinaryAccessUnit;

type
  TS101DataSetUpdate = class(TS101DataSet)
    function Add(infoRec: TInformationType; ds: TS101DataSet): Boolean; overload;
    function Add(feature: TFeatureRec; ds: TS101DataSet): Boolean; overload;
    function Add(pointRec: TPointRec; ds: TS101DataSet): Boolean; overload;
    function Add(multipointRec: TMultiPointRec; ds: TS101DataSet): Boolean; overload;
    function Add(curveRec: TCurveRec; ds: TS101DataSet): Boolean; overload;
    function Add(compositeCurveRec: TCompositeCurveRec; ds: TS101DataSet): Boolean; overload;
    function Add(surfaceRec: TSurfaceRec; ds: TS101DataSet): Boolean; overload;
    function Delete(infoRec: TInformationType; ds: TS101DataSet): Boolean; overload;
    function Delete(feature: TFeatureRec; ds: TS101DataSet): Boolean; overload;
    function Difference(ds1, ds2: TS101DataSet; logName: string; var sError: string): Boolean;
  end;

implementation

uses
  SysUtils;

// --------------------- TS101DataSetUpdate.Add(overload) ---------------------

function TS101DataSetUpdate.Add(pointRec: TPointRec; ds: TS101DataSet): Boolean;
var
  iPointRecNo: Integer;
begin
  Result := False;
  iPointRecNo := Length(pointRecords);
  SetLength(pointRecords, iPointRecNo + 1);
  S101Copy(pointRec, pointRecords[iPointRecNo]);
  Result := True;
end;

function TS101DataSetUpdate.Add(multipointRec: TMultiPointRec; ds: TS101DataSet): Boolean;
var
  iMultipointRec: Integer;
begin
  Result := False;
  iMultipointRec := Length(multiPointRecords);
  SetLength(multiPointRecords, iMultipointRec + 1);
  S101Copy(multipointRec, multiPointRecords[iMultipointRec]);
  Result := True;
end;

function TS101DataSetUpdate.Add(curveRec: TCurveRec; ds: TS101DataSet): Boolean;
var
  iCurveRec, i, j: Integer;
begin
  Result := False;
  iCurveRec := Length(curveRecords);
  SetLength(curveRecords, iCurveRec + 1);
  S101Copy(curveRec, curveRecords[iCurveRec]);
  for i := 0 to Length(curveRec.fPTAS.PTASArray) - 1 do begin
    for j := 0 to Length(ds.pointRecords) - 1 do
      if ds.pointRecords[j].fPRID.RCID = curveRec.fPTAS.PTASArray[i].RRID then begin
        Add(ds.pointRecords[j], ds);
        Break;
      end;
  end;
  Result := True;
end;

function TS101DataSetUpdate.Add(compositeCurveRec: TCompositeCurveRec; ds: TS101DataSet): Boolean;
var
  iCompositeCurveRec, i, j, k: Integer;
begin
  Result := False;
  iCompositeCurveRec := Length(compositeCurveRecords);
  SetLength(compositeCurveRecords, iCompositeCurveRec + 1);
  S101Copy(compositeCurveRec, compositeCurveRecords[iCompositeCurveRec]);
  with compositeCurveRec do
    for i := 0 to Length(fCUCOArray) - 1 do
      for j := 0 to Length(fCUCOArray[i].CUCOArray) - 1 do
        case TRecordTypeCode(fCUCOArray[i].CUCOArray[j].RRNM) of
          CurveRecordType:
            for k := 0 to Length(ds.curveRecords) - 1 do
              if ds.curveRecords[k].fCRID.RCID = fCUCOArray[i].CUCOArray[j].RRID then begin
                Add(ds.curveRecords[k], ds);
                Break;
              end;
          CompositeCurveRecordType:
            for k := 0 to Length(ds.compositeCurveRecords) - 1 do
              if ds.compositeCurveRecords[k].fCCID.RCID = fCUCOArray[i].CUCOArray[j].RRID then begin
                Add(ds.compositeCurveRecords[k], ds);
                Break;
              end;
        end;
  Result := True;
end;

function TS101DataSetUpdate.Add(surfaceRec: TSurfaceRec; ds: TS101DataSet): Boolean;
var
  iSurfaceRecNo, i, j, k: Integer;
begin
  Result := False;
  iSurfaceRecNo := Length(surfaceRecords);
  SetLength(surfaceRecords, iSurfaceRecNo + 1);
  S101Copy(surfaceRec, surfaceRecords[iSurfaceRecNo]);
  with surfaceRec do
    for i := 0 to Length(fRIASArray) - 1 do
      for j := 0 to Length(fRIASArray[i].RIASArray) do
        case TRecordTypeCode(fRIASArray[i].RIASArray[j].RRNM) of
          CurveRecordType:
            for k := 0 to Length(ds.curveRecords) - 1 do
              if ds.curveRecords[k].fCRID.RCID = fRIASArray[i].RIASArray[j].RRID then begin
                Add(ds.surfaceRecords[k], ds);
                Break;
              end;
          CompositeCurveRecordType:
            for k := 0 to Length(ds.compositeCurveRecords) - 1 do
              if ds.compositeCurveRecords[k].fCCID.RCID = fRIASArray[i].RIASArray[j].RRID then begin
                Add(ds.compositeCurveRecords[k], ds);
                Break;
              end;
        end;
  Result := True;
end;

function TS101DataSetUpdate.Add(infoRec: TInformationType; ds: TS101DataSet): Boolean;
var
  iInfoRecNo: Integer;
begin
  Result := False;
  iInfoRecNo := Length(infoTypeRecords);
  SetLength(infoTypeRecords, iInfoRecNo + 1);
  S101Copy(infoRec, infoTypeRecords[iInfoRecNo]);
  Result := True;
end;

function TS101DataSetUpdate.Add(feature: TFeatureRec; ds: TS101DataSet): Boolean;
var
  iFeatureRecNo, i, j, k: Integer;
begin
  Result := False;
  iFeatureRecNo := Length(featureRecords);
  SetLength(featureRecords, iFeatureRecNo + 1);
  S101Copy(feature, featureRecords[iFeatureRecNo]);
  for i := 0 to Length(feature.fSPASArray) - 1 do
    for j := 0 to Length(feature.fSPASArray[i].SPASArray) - 1 do
      with feature.fSPASArray[i].SPASArray[j] do
        case TRecordTypeCode(RRNM) of
          PointRecordType:
            for k := 0 to Length(ds.pointRecords) - 1 do
              if ds.pointRecords[k].fPRID.RCID = RRID then begin
                Add(ds.pointRecords[k], ds);
                Break;
              end;
          MultiPointRecordType: begin
            for k := 0 to Length(ds.multiPointRecords) - 1 do
              if ds.multiPointRecords[k].fMRID.RCID = RRID then begin
                Add(ds.multiPointRecords[k], ds);
                Break;
              end;
          end;
          CurveRecordType:
            for k := 0 to Length(ds.curveRecords) - 1 do
              if ds.curveRecords[k].fCRID.RCID = RRID then begin
                Add(ds.curveRecords[k], ds);
                Break;
              end;
          CompositeCurveRecordType:
            for k := 0 to Length(ds.compositeCurveRecords) - 1 do
              if ds.compositeCurveRecords[k].fCCID.RCID = RRID then begin
                Add(ds.compositeCurveRecords[k], ds);
                Break;
              end;
          SurfaceRecordType:
            for k := 0 to Length(ds.surfaceRecords) - 1 do
              if ds.surfaceRecords[k].fSRID.RCID = RRID then begin
                Add(ds.surfaceRecords[k], ds);
                Break;
              end;
        end;
  Result := True;
end;

// --------------------- TS101DataSetUpdate.Delete(overload) ---------------------

function TS101DataSetUpdate.Delete(infoRec: TInformationType; ds: TS101DataSet): Boolean;
var
  iInfoRecNo: Integer;
begin
  Result := False;
  iInfoRecNo := Length(infoTypeRecords);
  SetLength(infoTypeRecords, iInfoRecNo + 1);
  with infoTypeRecords[iInfoRecNo] do begin
    fIRID.RCNM := infoRec.fIRID.RCNM;
    fIRID.RCID := infoRec.fIRID.RCID;
    fIRID.NITC := infoRec.fIRID.NITC;
    fIRID.RVER := infoRec.fIRID.RVER;
    fIRID.RUIN := 2;
  end;
  Result := True;
end;

function TS101DataSetUpdate.Delete(feature: TFeatureRec; ds: TS101DataSet): Boolean;
var
  iFeatureRecNo: Integer;
begin
  Result := False;
  iFeatureRecNo := Length(featureRecords);
  SetLength(featureRecords, iFeatureRecNo + 1);
  with featureRecords[iFeatureRecNo].fFRID do begin
    RCNM := feature.fFRID.RCNM;
    RCID := feature.fFRID.RCID;
    NFTC := feature.fFRID.NFTC;
    RVER := feature.fFRID.RVER;
    RUIN := 2;
  end;
  Result := True;
end;

// --------------------- TS101DataSetUpdate.Difference ---------------------

type
  TRecIdType = record
    recIndex1, recIndex2: Integer;
    recId: Integer;
    recType: TRecordTypeCode;
  end;

function TS101DataSetUpdate.Difference(ds1, ds2: TS101DataSet; logName: string; var sError: string): Boolean;
var
  s: string;
  i, iObject1, iObject2, id, nToAdd, nToUpdate, nToDelete: Integer;
  toAdd, toUpdate, toDelete: array of TRecIdType;
  bInfoFound, bFeatureFound: array of Boolean;
begin
  try
    Result := False;
    if logName = '' then begin
      sError := 'Не задан путь к Log-файлу';
      Exit;
    end;
    if (ds1.s101Catalogue <> ds2.s101Catalogue) or (s101Catalogue <> ds1.s101Catalogue) then begin
      sError := 'Наборы данных имеют разные каталоги';
      Exit;
    end;
    nToAdd := 0;
    nToUpdate := 0;
    nToDelete := 0;
    SetLength(toAdd, 0);
    SetLength(toUpdate, 0);
    SetLength(toDelete, 0);
    SetLength(bInfoFound, Length(ds1.infoTypeRecords));
    for i := 0 to Length (bInfoFound) - 1 do
      bInfoFound[i] := False;
    SetLength(bFeatureFound, Length(ds1.featureRecords));
    for i := 0 to Length (bFeatureFound) - 1 do
      bFeatureFound[i] := False;
    AssignFile(tfLog, logName);
    if FileExists(logName) then
      Append(tfLog)
    else
      Rewrite(tfLog);
    WriteLn(tfLog, '');
    WriteLn(tfLog, '************************************************************');
    DateTimeToString(s, 'yyyy-mm-dd hh:mm:ss', Date + Time);
    WriteLn(tfLog, s);
    WriteLn(tfLog, 'Формирование корректуры по двум наборам данных');
    for iObject2 := 0 to Length(ds2.infoTypeRecords) - 1 do begin
      for iObject1 := 0 to Length(ds1.infoTypeRecords) - 1 do
        if (ds1.infoTypeRecords[iObject1].fIRID.RCID =
            ds2.infoTypeRecords[iObject2].fIRID.RCID) then begin
          bInfoFound[iObject1] := True;
          if not IsEqual(ds1.infoTypeRecords[iObject1], ds2.infoTypeRecords[iObject2], ds1, ds2) then begin
            id := ds1.infoTypeRecords[iObject1].fIRID.RCID;
            SetLength(toUpdate, nToUpdate + 1);
            toUpdate[nToUpdate].recIndex1 := iObject1;
            toUpdate[nToUpdate].recIndex2 := iObject2;
            toUpdate[nToUpdate].recId := id;
            toUpdate[nToUpdate].recType := InfoRecordType;
            nToUpdate := nToUpdate + 1;
            WriteLn(tfLog, Format('Инфообъект с RCID=%d изменен', [id]));
          end;
          Break;
        end;
      if iObject1 = Length(ds1.infoTypeRecords) then begin
        id := ds2.infoTypeRecords[iObject2].fIRID.RCID;
        SetLength(toAdd, nToAdd + 1);
        toAdd[nToAdd].recIndex1 := -1;
        toAdd[nToAdd].recIndex2 := iObject2;
        toAdd[nToAdd].recId := id;
        toAdd[nToAdd].recType := InfoRecordType;
        nToAdd := nToAdd + 1;
        WriteLn(tfLog, Format('Инфообъект с RCID=%d добавлен', [id]));
      end;
    end;
    for iObject2 := 0 to Length(ds2.featureRecords) - 1 do begin
      for iObject1 := 0 to Length(ds1.featureRecords) - 1 do
        if (ds1.featureRecords[iObject1].fFRID.RCID =
            ds2.featureRecords[iObject2].fFRID.RCID) then begin
          bFeatureFound[iObject1] := True;
          if not IsEqual(ds1.featureRecords[iObject1], ds2.featureRecords[iObject2], ds1, ds2) then begin
            id := ds1.featureRecords[iObject1].fFRID.RCID;
            SetLength(toUpdate, nToUpdate + 1);
            toUpdate[nToUpdate].recIndex1 := iObject1;
            toUpdate[nToUpdate].recIndex2 := iObject2;
            toUpdate[nToUpdate].recId := id;
            toUpdate[nToUpdate].recType := FeatureRecordType;
            nToUpdate := nToUpdate + 1;
            WriteLn(tfLog, Format('Геообъект с RCID=%d изменен', [id]));
          end;
          Break;
        end;
      if iObject1 = Length(ds1.featureRecords) then begin
        id := ds2.featureRecords[iObject2].fFRID.RCID;
        SetLength(toAdd, nToAdd + 1);
        toAdd[nToAdd].recIndex1 := -1;
        toAdd[nToAdd].recIndex2 := iObject2;
        toAdd[nToAdd].recId := id;
        toAdd[nToAdd].recType := FeatureRecordType;
        nToAdd := nToAdd + 1;
        WriteLn(tfLog, Format('Геообъект с RCID=%d добавлен', [id]));
      end;
    end;
    for iObject1 := 0 to Length(ds1.infoTypeRecords) - 1 do
      if not bInfoFound[iObject1] then begin
        id := ds1.infoTypeRecords[iObject1].fIRID.RCID;
        SetLength(toDelete, nToDelete + 1);
        toDelete[nToDelete].recIndex1 := iObject1;
        toDelete[nToDelete].recIndex2 := -1;
        toDelete[nToDelete].recId := id;
        toDelete[nToDelete].recType := InfoRecordType;
        nToDelete := nToDelete + 1;
        WriteLn(tfLog, Format('Инфообъект с RCID=%d удален', [id]));
      end;
    for iObject1 := 0 to Length(ds1.featureRecords) - 1 do
      if not bFeatureFound[iObject1] then begin
        id := ds1.featureRecords[iObject1].fFRID.RCID;
        SetLength(toDelete, nToDelete + 1);
        toDelete[nToDelete].recIndex1 := iObject1;
        toDelete[nToDelete].recIndex2 := -1;
        toDelete[nToDelete].recId := id;
        toDelete[nToDelete].recType := InfoRecordType;
        nToDelete := nToDelete + 1;
        WriteLn(tfLog, Format('Геообъект с RCID=%d удален', [id]));
      end;
    for i := 0 to Length(toAdd) - 1 do
      case toAdd[i].recType of
        InfoRecordType: Add(ds2.infoTypeRecords[toAdd[i].recIndex2], ds2);
        FeatureRecordType: Add(ds2.featureRecords[toAdd[i].recIndex2], ds2);
      end;
    Result := True;
  finally
    SetLength(toAdd, 0);
    SetLength(toUpdate, 0);
    SetLength(toDelete, 0);
    SetLength(bInfoFound, 0);
    SetLength(bFeatureFound, 0);
    CloseFile(tfLog);
  end;
end;

end.
