
// --------------------- IsEqual(overload) ---------------------

function IsEqual(arrayOfAttrElem1, arrayOfAttrElem2: array of TAttrElem): Boolean; overload;
var
  i: Integer;
begin
  Result := False;
  if Length(arrayOfAttrElem1) <> Length(arrayOfAttrElem2) then Exit;
  for i := 0 to Length(arrayOfAttrElem1) - 1 do
    with arrayOfAttrElem1[i] do
      if (NATC <> arrayOfAttrElem2[i].NATC) or (ATIX <> arrayOfAttrElem2[i].ATIX) or
          (PAIX <> arrayOfAttrElem2[i].PAIX) or (ATIN <> arrayOfAttrElem2[i].ATIN) or
          (ATVL <> arrayOfAttrElem2[i].ATVL) then Exit;
  Result := True;
end;

function IsEqual(fATTRArray1, fATTRArray2: array of TATTRField): Boolean; overload;
var
  i: Integer;
begin
  Result := False;
  if Length(fATTRArray1) <> Length(fATTRArray2) then Exit;
  for i := 0 to Length(fATTRArray1) - 1 do
    if not IsEqual(fATTRArray1[i].arrayOfAttrElem, fATTRArray2[i].arrayOfAttrElem) then Exit;
  Result := True;
end;

{
function IsEqual(fINASArray1, fINASArray2: array of TINASField): Boolean; overload;
var
  i: Integer;
begin
  Result := False;
  if Length(fINASArray1) <> Length(fINASArray2) then Exit;
  for i := 0 to Length(fINASArray1) - 1 do
    with fINASArray1[i] do begin
      if (RRNM <> fINASArray2[i].RRNM) or (RRID <> fINASArray2[i].RRID) or
          (NIAC <> fINASArray2[i].NIAC) or (NARC <> fINASArray2[i].NARC) or
          (IUIN <> fINASArray2[i].IUIN) then Exit;
      if not IsEqual(arrayOfAttrElem, fINASArray2[i].arrayOfAttrElem) then Exit;
    end;
  Result := True;
end;
}

function IsEqual(fINASArray1, fINASArray2: array of TINASField; ds1, ds2: TS101DataSet): Boolean;
var
  i: Integer;
begin
  Result := False;
  if Length(fINASArray1) <> Length(fINASArray2) then Exit;
  for i := 0 to Length(fINASArray1) - 1 do
    with fINASArray1[i] do begin
      if (RRNM <> fINASArray2[i].RRNM) or
          (NIAC <> fINASArray2[i].NIAC) or (NARC <> fINASArray2[i].NARC) or
          (IUIN <> fINASArray2[i].IUIN) then Exit;
      if not IsEqual(arrayOfAttrElem, fINASArray2[i].arrayOfAttrElem) then Exit;
      if ds1.GetAttributeValue('guID', ds1.infoTypeRecords[RRID].fATTRArray) <>
          ds2.GetAttributeValue('guID', ds2.infoTypeRecords[fINASArray2[i].RRID].fATTRArray) then Exit;
    end;
  Result := True;
end;

{
function IsEqual(infoRec1, infoRec2: TInformationType): Boolean; overload;
var
  i: Integer;
begin
  Result := False;
  with infoRec1 do begin
    with fIRID do
      if (RCNM <> infoRec2.fIRID.RCNM) or (RCID <> infoRec2.fIRID.RCID) or
          (NITC <> infoRec2.fIRID.NITC) or (RVER <> infoRec2.fIRID.RVER) or
          (RUIN <> infoRec2.fIRID.RUIN) then Exit;
    if not IsEqual(fATTRArray, infoRec2.fATTRArray) or
        not IsEqual(fINASArray, infoRec2.fINASArray) then Exit;
  end;
  Result := True;
end;
}

function IsEqual(infoRec1, infoRec2: TInformationType; ds1, ds2: TS101DataSet): Boolean;
var
  i: Integer;
begin
  Result := False;
  with infoRec1 do begin
    with fIRID do
      if (RCNM <> infoRec2.fIRID.RCNM) or
          (NITC <> infoRec2.fIRID.NITC) or (RVER <> infoRec2.fIRID.RVER) or
          (RUIN <> infoRec2.fIRID.RUIN) then Exit;
    if not IsEqual(fATTRArray, infoRec2.fATTRArray) or
        not IsEqual(fINASArray, infoRec2.fINASArray, ds1, ds2) then Exit;
  end;
  Result := True;
end;

{
function IsEqual(pointRec1, pointRec2: TPointRec): Boolean; overload;
begin
  Result := False;
  if pointRec1.ct <> pointRec2.ct then Exit;
  with pointRec1.fPRID do
    if (RCNM <> pointRec2.fPRID.RCNM) or (RVER <> pointRec2.fPRID.RVER) or
        (RUIN <> pointRec2.fPRID.RUIN) then Exit;
  if not IsEqual(pointRec1.fINASArray, pointRec2.fINASArray) then Exit;
  case pointRec1.ct of
    ct2I: with pointRec1.fC2IT do
      if (Abs(XCOO - pointRec2.fC2IT.XCOO) > horzEPS) or (Abs(YCOO - pointRec2.fC2IT.YCOO) > horzEPS) then Exit;
    ct3I: with pointRec1.fC3IT do
      if (Abs(XCOO - pointRec2.fC3IT.XCOO) > horzEPS) or (Abs(YCOO - pointRec2.fC3IT.YCOO) > horzEPS) or
          (Abs(ZCOO - pointRec2.fC3IT.ZCOO) > vertEPS) or (VCID <> pointRec2.fC3IT.VCID) then Exit;
    ct2F: with pointRec1.fC2FT do
      if (Abs(XCOO - pointRec2.fC2FT.XCOO) > horzEPS) or (Abs(YCOO - pointRec2.fC2FT.YCOO) > horzEPS) then Exit;
    ct3F: with pointRec1.fC3FT do
      if (Abs(XCOO - pointRec2.fC3FT.XCOO) > horzEPS) or (Abs(YCOO - pointRec2.fC3FT.YCOO) > horzEPS) or
          (Abs(ZCOO - pointRec2.fC3FT.ZCOO) > vertEPS) or (VCID <> pointRec2.fC3FT.VCID) then Exit;
  end;
  Result := True;
end;
}

function IsEqual(pointRec1, pointRec2: TPointRec; ds1, ds2: TS101DataSet): Boolean;
begin
  Result := False;
  if pointRec1.ct <> pointRec2.ct then Exit;
  with pointRec1.fPRID do
    if (RCNM <> pointRec2.fPRID.RCNM) or (RVER <> pointRec2.fPRID.RVER) or
        (RUIN <> pointRec2.fPRID.RUIN) then Exit;
  if not IsEqual(pointRec1.fINASArray, pointRec2.fINASArray, ds1, ds2) then Exit;
  case pointRec1.ct of
    ct2I: with pointRec1.fC2IT do
      if (XCOO <> pointRec2.fC2IT.XCOO) or (YCOO <> pointRec2.fC2IT.YCOO) then Exit;
    ct3I: with pointRec1.fC3IT do
      if (XCOO <> pointRec2.fC3IT.XCOO) or (YCOO <> pointRec2.fC3IT.YCOO) or
          (ZCOO <> pointRec2.fC3IT.ZCOO) or (VCID <> pointRec2.fC3IT.VCID) then Exit;
    ct2F: with pointRec1.fC2FT do
      if (Abs(XCOO - pointRec2.fC2FT.XCOO) > horzEPS) or (Abs(YCOO - pointRec2.fC2FT.YCOO) > horzEPS) then Exit;
    ct3F: with pointRec1.fC3FT do
      if (Abs(XCOO - pointRec2.fC3FT.XCOO) > horzEPS) or (Abs(YCOO - pointRec2.fC3FT.YCOO) > horzEPS) or
          (Abs(ZCOO - pointRec2.fC3FT.ZCOO) > vertEPS) or (VCID <> pointRec2.fC3FT.VCID) then Exit;
  end;
  Result := True;
end;

function IsEqual(fC2ILArray1, fC2ILArray2: array of TC2ILField): Boolean; overload;
var
  i, j: Integer;
begin
  Result := False;
  if Length(fC2ILArray1) <> Length(fC2ILArray2) then Exit;
  for i := 0 to Length(fC2ILArray1) - 1 do begin
    if Length(fC2ILArray1[i].C2ITArray) <> Length(fC2ILArray2[i].C2ITArray) then Exit;
    for j := 0 to Length(fC2ILArray1[i].C2ITArray) - 1 do
      with fC2ILArray1[i].C2ITArray[j] do
        if (XCOO <> fC2ILArray2[i].C2ITArray[j].XCOO) or
            (YCOO <> fC2ILArray2[i].C2ITArray[j].YCOO) then Exit;
  end;
  Result := True;
end;

function IsEqual(fC3ILArray1, fC3ILArray2: array of TC3ILField): Boolean; overload;
var
  i, j: Integer;
begin
  Result := False;
  if Length(fC3ILArray1) <> Length(fC3ILArray2) then Exit;
  for i := 0 to Length(fC3ILArray1) - 1 do begin
    if fC3ILArray1[i].VCID <> fC3ILArray2[i].VCID then Exit;
    if Length(fC3ILArray1[i].C3ITArray) <> Length(fC3ILArray2[i].C3ITArray) then Exit;
    for j := 0 to Length(fC3ILArray1[i].C3ITArray) - 1 do
      with fC3ILArray1[i].C3ITArray[j] do
        if (XCOO <> fC3ILArray2[i].C3ITArray[j].XCOO) or
            (YCOO <> fC3ILArray2[i].C3ITArray[j].YCOO) or
            (ZCOO <> fC3ILArray2[i].C3ITArray[j].ZCOO) then Exit;
  end;
  Result := True;
end;

function IsEqual(fC2FLArray1, fC2FLArray2: array of TC2FLField): Boolean; overload;
var
  i, j: Integer;
begin
  Result := False;
  if Length(fC2FLArray1) <> Length(fC2FLArray2) then Exit;
  for i := 0 to Length(fC2FLArray1) - 1 do begin
    if Length(fC2FLArray1[i].C2FTArray) <> Length(fC2FLArray2[i].C2FTArray) then Exit;
    for j := 0 to Length(fC2FLArray1[i].C2FTArray) - 1 do
      with fC2FLArray1[i].C2FTArray[j] do
        if (Abs(XCOO - fC2FLArray2[i].C2FTArray[j].XCOO) > horzEPS) or
            (Abs(YCOO - fC2FLArray2[i].C2FTArray[j].YCOO) > horzEPS) then Exit;
  end;
  Result := True;
end;

function IsEqual(fC3FLArray1, fC3FLArray2: array of TC3FLField): Boolean; overload;
var
  i, j: Integer;
begin
  Result := False;
  if Length(fC3FLArray1) <> Length(fC3FLArray2) then Exit;
  for i := 0 to Length(fC3FLArray1) - 1 do begin
    if fC3FLArray1[i].VCID <> fC3FLArray2[i].VCID then Exit;
    if Length(fC3FLArray1[i].C3FTArray) <> Length(fC3FLArray2[i].C3FTArray) then Exit;
    for j := 0 to Length(fC3FLArray1[i].C3FTArray) - 1 do
      with fC3FLArray1[i].C3FTArray[j] do
        if (Abs(XCOO - fC3FLArray2[i].C3FTArray[j].XCOO) > horzEPS) or
            (Abs(YCOO - fC3FLArray2[i].C3FTArray[j].YCOO) > horzEPS) or
            (Abs(ZCOO - fC3FLArray2[i].C3FTArray[j].ZCOO) > vertEPS) then Exit;
  end;
  Result := True;
end;

{
function IsEqual(multiPointRec1, multiPointRec2: TMultiPointRec): Boolean; overload;
begin
  Result := False;
  if multiPointRec1.ct <> multiPointRec2.ct then Exit;
  with multiPointRec1.fMRID do
    if (RCNM <> multiPointRec2.fMRID.RCNM) or (RVER <> multiPointRec2.fMRID.RVER) or
        (RUIN <> multiPointRec2.fMRID.RUIN) then Exit;
  if not IsEqual(multiPointRec1.fINASArray, multiPointRec2.fINASArray) then Exit;
  if (multiPointRec1.pfCOCC = nil) and (multiPointRec2.pfCOCC <> nil) or
      (multiPointRec1.pfCOCC <> nil) and (multiPointRec2.pfCOCC = nil) then Exit;
  if multiPointRec1.pfCOCC <> nil then begin
    if (multiPointRec1.pfCOCC^.COUI <> multiPointRec2.pfCOCC^.COUI) or
        (multiPointRec1.pfCOCC^.COIX <> multiPointRec2.pfCOCC^.COIX) or
        (multiPointRec1.pfCOCC^.NCOR <> multiPointRec2.pfCOCC^.NCOR) then Exit;
  end;
  case multiPointRec1.ct of
    ct2I: if not IsEqual(multiPointRec1.fC2ILArray, multiPointRec2.fC2ILArray) then Exit;
    ct3I: if not IsEqual(multiPointRec1.fC3ILArray, multiPointRec2.fC3ILArray) then Exit;
    ct2F: if not IsEqual(multiPointRec1.fC2FLArray, multiPointRec2.fC2FLArray) then Exit;
    ct3F: if not IsEqual(multiPointRec1.fC3FLArray, multiPointRec2.fC3FLArray) then Exit;
  end;
  Result := True;
end;
}

function IsEqual(multiPointRec1, multiPointRec2: TMultiPointRec; ds1, ds2: TS101DataSet): Boolean;
begin
  Result := False;
  if multiPointRec1.ct <> multiPointRec2.ct then Exit;
  with multiPointRec1.fMRID do
    if (RCNM <> multiPointRec2.fMRID.RCNM) or (RVER <> multiPointRec2.fMRID.RVER) or
        (RUIN <> multiPointRec2.fMRID.RUIN) then Exit;
  if not IsEqual(multiPointRec1.fINASArray, multiPointRec2.fINASArray, ds1, ds2) then Exit;
{
  if (multiPointRec1.pfCOCC = nil) and (multiPointRec2.pfCOCC <> nil) or
      (multiPointRec1.pfCOCC <> nil) and (multiPointRec2.pfCOCC = nil) then Exit;
  if multiPointRec1.pfCOCC <> nil then begin
    if (multiPointRec1.pfCOCC^.COUI <> multiPointRec2.pfCOCC^.COUI) or
        (multiPointRec1.pfCOCC^.COIX <> multiPointRec2.pfCOCC^.COIX) or
        (multiPointRec1.pfCOCC^.NCOR <> multiPointRec2.pfCOCC^.NCOR) then Exit;
  end;
}
  case multiPointRec1.ct of
    ct2I: if not IsEqual(multiPointRec1.fC2ILArray, multiPointRec2.fC2ILArray) then Exit;
    ct3I: if not IsEqual(multiPointRec1.fC3ILArray, multiPointRec2.fC3ILArray) then Exit;
    ct2F: if not IsEqual(multiPointRec1.fC2FLArray, multiPointRec2.fC2FLArray) then Exit;
    ct3F: if not IsEqual(multiPointRec1.fC3FLArray, multiPointRec2.fC3FLArray) then Exit;
  end;
  Result := True;
end;

function IsEqual(fPTAS1, fPTAS2: TPTASField; coordType: TCoordType;
    ds1, ds2: TS101DataSet): Boolean; overload;
var
  i, j, iPoint1, iPoint2: Integer;
begin
  Result := False;
  if Length(fPTAS1.PTASArray) <> Length(fPTAS2.PTASArray) then Exit;
  for i := 0 to Length(fPTAS1.PTASArray) - 1 do begin
    if (fPTAS1.PTASArray[i].RRNM <> fPTAS2.PTASArray[i].RRNM) or
        (fPTAS1.PTASArray[i].TOPI <> fPTAS2.PTASArray[i].TOPI) then Exit;
    iPoint1 := -1;
    for j := 0 to Length(ds1.pointRecords) - 1 do
      if ds1.pointRecords[j].fPRID.RCID = fPTAS1.PTASArray[i].RRID then begin
        iPoint1 := j;
        Break;
      end;
    if (iPoint1 = -1) or (ds1.pointRecords[iPoint1].ct <> coordType) then Exit;
    iPoint2 := -1;
    for j := 0 to Length(ds2.pointRecords) - 1 do
      if ds2.pointRecords[j].fPRID.RCID = fPTAS2.PTASArray[i].RRID then begin
        iPoint2 := j;
        Break;
      end;
    if (iPoint2 = -1) or (ds2.pointRecords[iPoint2].ct <> coordType) then Exit;
    if not IsEqual(ds1.pointRecords[iPoint1], ds2.pointRecords[iPoint2], ds1, ds2) then Exit;
  end;
  Result := True;
end;

function IsEqual(fSegmentArray1, fSegmentArray2: array of TSegmentElem;
    coordType: TCoordType): Boolean; overload;
var
  i: Integer;
begin
  Result := False;
  if Length(fSegmentArray1) <> Length(fSegmentArray2) then Exit;
  for i := 0 to Length(fSegmentArray1) - 1 do begin
    with fSegmentArray1[i].fSEGH do begin
      if INTP <> fSegmentArray2[i].fSEGH.INTP then Exit;
      if INTP = 7 then begin
        if (CIRC <> fSegmentArray2[i].fSEGH.CIRC) or (DIST <> fSegmentArray2[i].fSEGH.DIST) or
            (DISU <> fSegmentArray2[i].fSEGH.DISU) or (XCOO <> fSegmentArray2[i].fSEGH.XCOO) or
            (YCOO <> fSegmentArray2[i].fSEGH.YCOO) then Exit;
        if CIRC = 2 then begin
          if (SBRG <> fSegmentArray2[i].fSEGH.SBRG) or
              (ANGL <> fSegmentArray2[i].fSEGH.ANGL) then Exit;
        end;
      end;
    end;
{
    if (fSegmentArray1[i].pfCOCC = nil) and (fSegmentArray2[i].pfCOCC <> nil) or
        (fSegmentArray1[i].pfCOCC <> nil) and (fSegmentArray2[i].pfCOCC = nil) then Exit;
    if fSegmentArray1[i].pfCOCC <> nil then begin
      with fSegmentArray1[i].pfCOCC^ do
        if (COUI <> fSegmentArray2[i].pfCOCC^.COUI) or (COIX <> fSegmentArray2[i].pfCOCC^.COIX) or
            (NCOR <> fSegmentArray2[i].pfCOCC^.NCOR) then Exit;
    end;
}    
    case coordType of
      ct2I: if not IsEqual(fSegmentArray1[i].fC2ILArray, fSegmentArray2[i].fC2ILArray) then Exit;
      ct3I: if not IsEqual(fSegmentArray1[i].fC3ILArray, fSegmentArray2[i].fC3ILArray) then Exit;
      ct2F: if not IsEqual(fSegmentArray1[i].fC2FLArray, fSegmentArray2[i].fC2FLArray) then Exit;
      ct3F: if not IsEqual(fSegmentArray1[i].fC3FLArray, fSegmentArray2[i].fC3FLArray) then Exit;
    end;
  end;
  Result := True;
end;

function IsEqual(curveRec1, curveRec2: TCurveRec; ds1, ds2: TS101DataSet): Boolean; overload;
begin
  Result := False;
  if curveRec1.ct <> curveRec2.ct then Exit;
  with curveRec1.fCRID do
    if (RCNM <> curveRec2.fCRID.RCNM) or (RVER <> curveRec2.fCRID.RVER) or
        (RUIN <> curveRec2.fCRID.RUIN) then Exit;
  if not IsEqual(curveRec1.fINASArray, curveRec2.fINASArray, ds1, ds2) then Exit;
  if not IsEqual(curveRec1.fPTAS, curveRec2.fPTAS, curveRec1.ct, ds1, ds2) then Exit;
{
  if (curveRec1.pfSECC = nil) and (curveRec2.pfSECC <> nil) or
      (curveRec1.pfSECC <> nil) and (curveRec2.pfSECC = nil) then Exit;
  if curveRec1.pfSECC <> nil then
    with curveRec1.pfSECC^ do
      if (SEUI <> curveRec2.pfSECC^.SEUI) or (SEIX <> curveRec2.pfSECC^.SEIX) or
          (NSEG <> curveRec2.pfSECC^.NSEG) then Exit;
}          
  if not IsEqual(curveRec1.fSegmentArray, curveRec2.fSegmentArray, curveRec1.ct) then Exit;
  Result := True;
end;

function IsEqual(compositeCurveRec1, compositeCurveRec2: TCompositeCurveRec;
    ds1, ds2: TS101DataSet): Boolean; overload;
var
  i, j, k, iCompositeCurve1, iCompositeCurve2, iCurve1, iCurve2: Integer;
begin
  Result := False;
  with compositeCurveRec1.fCCID do
    if (RCNM <> compositeCurveRec2.fCCID.RCNM) or (RVER <> compositeCurveRec2.fCCID.RVER) or
        (RUIN <> compositeCurveRec2.fCCID.RUIN) then Exit;
{
  if (compositeCurveRec1.pfCCOC = nil) and (compositeCurveRec2.pfCCOC <> nil) or
      (compositeCurveRec1.pfCCOC <> nil) and (compositeCurveRec2.pfCCOC = nil) then Exit;
  if compositeCurveRec1.pfCCOC <> nil then
    with compositeCurveRec1.pfCCOC^ do
      if (CCUI <> compositeCurveRec2.pfCCOC^.CCUI) or (CCIX <> compositeCurveRec2.pfCCOC^.CCIX) or
          (NCCO <> compositeCurveRec2.pfCCOC^.NCCO) then Exit;
}
  if not IsEqual(compositeCurveRec1.fINASArray, compositeCurveRec2.fINASArray, ds1, ds2) then Exit;
  if Length(compositeCurveRec1.fCUCOArray) <> Length(compositeCurveRec2.fCUCOArray) then Exit;
  for i := 0 to Length(compositeCurveRec1.fCUCOArray) - 1 do begin
    if Length(compositeCurveRec1.fCUCOArray[i].CUCOArray) <>
        Length(compositeCurveRec2.fCUCOArray[i].CUCOArray) then Exit;
    for j := 0 to Length(compositeCurveRec1.fCUCOArray[i].CUCOArray) - 1 do begin
      with compositeCurveRec1.fCUCOArray[i].CUCOArray[j] do begin
        if (RRNM <> compositeCurveRec2.fCUCOArray[i].CUCOArray[j].RRNM) or
            (ORNT <> compositeCurveRec2.fCUCOArray[i].CUCOArray[j].ORNT) then Exit;
        case RRNM of
          Ord(CompositeCurveRecordType): begin
            iCompositeCurve1 := -1;
            for k := 0 to Length(ds1.compositeCurveRecords) - 1 do
              if ds1.compositeCurveRecords[k].fCCID.RCID = RRID then begin
                iCompositeCurve1 := k;
                Break;
              end;
            if iCompositeCurve1 = -1 then Exit;
            iCompositeCurve2 := -1;
            for k := 0 to Length(ds2.compositeCurveRecords) - 1 do
              if ds2.compositeCurveRecords[k].fCCID.RCID =
                  compositeCurveRec2.fCUCOArray[i].CUCOArray[j].RRID then begin
                iCompositeCurve2 := k;
                Break;
              end;
            if iCompositeCurve2 = -1 then Exit;
            if not IsEqual(ds1.compositeCurveRecords[iCompositeCurve1],
                ds2.compositeCurveRecords[iCompositeCurve2], ds1, ds2) then Exit;
          end;
          Ord(CurveRecordType): begin
            iCurve1 := -1;
            for k := 0 to Length(ds1.curveRecords) - 1 do
              if ds1.curveRecords[k].fCRID.RCID = RRID then begin
                iCurve1 := k;
                Break;
              end;
            if iCurve1 = -1 then Exit;
            iCurve2 := -1;
            for k := 0 to Length(ds2.curveRecords) - 1 do
              if ds2.curveRecords[k].fCRID.RCID =
                  compositeCurveRec2.fCUCOArray[i].CUCOArray[j].RRID then begin
                iCurve2 := k;
                Break;
              end;
            if iCurve2 = -1 then Exit;
            if not IsEqual(ds1.curveRecords[iCurve1], ds2.curveRecords[iCurve2], ds1, ds2) then Exit;
          end;
        end;
      end;
    end;
  end;
  Result := True;
end;

function IsEqual(surfaceRec1, surfaceRec2: TSurfaceRec;
    ds1, ds2: TS101DataSet): Boolean; overload;
var
  i, j, k, iCurve1, iCurve2, iCompositeCurve1, iCompositeCurve2: Integer;
begin
  Result := False;
  with surfaceRec1.fSRID do
    if (RCNM <> surfaceRec2.fSRID.RCNM) or (RVER <> surfaceRec2.fSRID.RVER) or
        (RUIN <> surfaceRec2.fSRID.RUIN) then Exit;
  if not IsEqual(surfaceRec1.fINASArray, surfaceRec2.fINASArray, ds1, ds2) then Exit;
  if Length(surfaceRec1.fRIASArray) <> Length(surfaceRec2.fRIASArray) then Exit;
  for i := 0 to Length(surfaceRec1.fRIASArray) - 1 do begin
    if Length(surfaceRec1.fRIASArray[i].RIASArray) <> Length(surfaceRec2.fRIASArray[i].RIASArray) then Exit;
    for j := 0 to Length(surfaceRec1.fRIASArray[i].RIASArray) - 1 do
      with surfaceRec1.fRIASArray[i].RIASArray[j] do begin
        if (RRNM <> surfaceRec2.fRIASArray[i].RIASArray[j].RRNM) or
            (ORNT <> surfaceRec2.fRIASArray[i].RIASArray[j].ORNT) or
            (USAG <> surfaceRec2.fRIASArray[i].RIASArray[j].USAG) or
            (RAUI <> surfaceRec2.fRIASArray[i].RIASArray[j].RAUI) then Exit;
        case RRNM of
          Ord(CurveRecordType): begin
            iCurve1 := -1;
            for k := 0 to Length(ds1.curveRecords) - 1 do
              if ds1.curveRecords[k].fCRID.RCID = RRID then begin
                iCurve1 := k;
                Break;
              end;
            if iCurve1 = -1 then Exit;
            iCurve2 := -1;
            for k := 0 to Length(ds2.curveRecords) - 1 do
              if ds2.curveRecords[k].fCRID.RCID =
                  surfaceRec2.fRIASArray[i].RIASArray[j].RRID then begin
                iCurve2 := k;
                Break;
              end;
            if iCurve2 = -1 then Exit;
            if not IsEqual(ds1.curveRecords[iCurve1], ds2.curveRecords[iCurve2], ds1, ds2) then Exit;
          end;
          Ord(CompositeCurveRecordType): begin
            iCompositeCurve1 := -1;
            for k := 0 to Length(ds1.compositeCurveRecords) - 1 do
              if ds1.compositeCurveRecords[k].fCCID.RCID = RRID then begin
                iCompositeCurve1 := k;
                Break;
              end;
            if iCompositeCurve1 = -1 then Exit;
            iCompositeCurve2 := -1;
            for k := 0 to Length(ds2.compositeCurveRecords) - 1 do
              if ds2.compositeCurveRecords[k].fCCID.RCID =
                  surfaceRec2.fRIASArray[i].RIASArray[j].RRID then begin
                iCompositeCurve2 := k;
                Break;
              end;
            if iCompositeCurve2 = -1 then Exit;
            if not IsEqual(ds1.compositeCurveRecords[iCompositeCurve1],
                ds2.compositeCurveRecords[iCompositeCurve2], ds1, ds2) then Exit;
          end;
        end;
      end;
  end;
  Result := True;
end;

function IsEqual(fSPASArray1, fSPASArray2: array of TSPASField;
    ds1, ds2: TS101DataSet): Boolean; overload;
var
  i, j, k, iGeom1, iGeom2: Integer;
begin
  Result := False;
  if Length(fSPASArray1) <> Length(fSPASArray2) then Exit;
  for i := 0 to Length(fSPASArray1) - 1 do begin
    if Length(fSPASArray1[i].SPASArray) <> Length(fSPASArray2[i].SPASArray) then Exit;
    for j := 0 to Length(fSPASArray1[i].SPASArray) - 1 do begin
      if (fSPASArray1[i].SPASArray[j].RRNM <> fSPASArray2[i].SPASArray[j].RRNM) or
          (fSPASArray1[i].SPASArray[j].ORNT <> fSPASArray2[i].SPASArray[j].ORNT) or
          (fSPASArray1[i].SPASArray[j].SMIN <> fSPASArray2[i].SPASArray[j].SMIN) or
          (fSPASArray1[i].SPASArray[j].SMAX <> fSPASArray2[i].SPASArray[j].SMAX) or
          (fSPASArray1[i].SPASArray[j].SAUI <> fSPASArray2[i].SPASArray[j].SAUI) then Exit;
      case TRecordTypeCode(fSPASArray1[i].SPASArray[j].RRNM) of
        PointRecordType: begin
          iGeom1 := -1;
          for k := 0 to Length(ds1.pointRecords) - 1 do
            if ds1.pointRecords[k].fPRID.RCID = fSPASArray1[i].SPASArray[j].RRID then begin
              iGeom1 := k;
              Break;
            end;
          if iGeom1 = -1 then Exit;
          iGeom2 := -1;
          for k := 0 to Length(ds2.pointRecords) - 1 do
            if ds2.pointRecords[k].fPRID.RCID = fSPASArray2[i].SPASArray[j].RRID then begin
              iGeom2 := k;
              Break;
            end;
          if iGeom2 = -1 then Exit;
          if not IsEqual(ds1.pointRecords[iGeom1], ds2.pointRecords[iGeom2], ds1, ds2) then Exit;
        end;
        MultiPointRecordType: begin
          iGeom1 := -1;
          for k := 0 to Length(ds1.multiPointRecords) - 1 do
            if ds1.multiPointRecords[k].fMRID.RCID = fSPASArray1[i].SPASArray[j].RRID then begin
              iGeom1 := k;
              Break;
            end;
          if iGeom1 = -1 then Exit;
          iGeom2 := -1;
          for k := 0 to Length(ds2.multiPointRecords) - 1 do
            if ds2.multiPointRecords[k].fMRID.RCID = fSPASArray2[i].SPASArray[j].RRID then begin
              iGeom2 := k;
              Break;
            end;
          if iGeom2 = -1 then Exit;
          if not IsEqual(ds1.multiPointRecords[iGeom1], ds2.multiPointRecords[iGeom2], ds1, ds2) then Exit;
        end;
        CurveRecordType: begin
          iGeom1 := -1;
          for k := 0 to Length(ds1.curveRecords) - 1 do
            if ds1.curveRecords[k].fCRID.RCID = fSPASArray1[i].SPASArray[j].RRID then begin
              iGeom1 := k;
              Break;
            end;
          if iGeom1 = -1 then Exit;
          iGeom2 := -1;
          for k := 0 to Length(ds2.curveRecords) - 1 do
            if ds2.curveRecords[k].fCRID.RCID = fSPASArray2[i].SPASArray[j].RRID then begin
              iGeom2 := k;
              Break;
            end;
          if iGeom2 = -1 then Exit;
          if not IsEqual(ds1.curveRecords[iGeom1], ds2.curveRecords[iGeom2], ds1, ds2) then Exit;
        end;
        CompositeCurveRecordType: begin
          iGeom1 := -1;
          for k := 0 to Length(ds1.compositeCurveRecords) - 1 do
            if ds1.compositeCurveRecords[k].fCCID.RCID = fSPASArray1[i].SPASArray[j].RRID then begin
              iGeom1 := k;
              Break;
            end;
          if iGeom1 = -1 then Exit;
          iGeom2 := -1;
          for k := 0 to Length(ds2.compositeCurveRecords) - 1 do
            if ds2.compositeCurveRecords[k].fCCID.RCID = fSPASArray2[i].SPASArray[j].RRID then begin
              iGeom2 := k;
              Break;
            end;
          if iGeom2 = -1 then Exit;
          if not IsEqual(ds1.compositeCurveRecords[iGeom1], ds2.compositeCurveRecords[iGeom2],
              ds1, ds2) then Exit;
        end;
        SurfaceRecordType: begin
          iGeom1 := -1;
          for k := 0 to Length(ds1.surfaceRecords) - 1 do
            if ds1.surfaceRecords[k].fSRID.RCID = fSPASArray1[i].SPASArray[j].RRID then begin
              iGeom1 := k;
              Break;
            end;
          if iGeom1 = -1 then Exit;
          iGeom2 := -1;
          for k := 0 to Length(ds2.surfaceRecords) - 1 do
            if ds2.surfaceRecords[k].fSRID.RCID = fSPASArray2[i].SPASArray[j].RRID then begin
              iGeom2 := k;
              Break;
            end;
          if iGeom2 = -1 then Exit;
          if not IsEqual(ds1.surfaceRecords[iGeom1], ds2.surfaceRecords[iGeom2],
              ds1, ds2) then Exit;
        end;
      end;
    end;
  end;
  Result := True;
end;

function IsEqual(featureRec1, featureRec2: TFeatureRec; ds1, ds2: TS101DataSet;
    bCheckGeometry: Boolean = True): Boolean; overload;
var
  i, j: Integer;
begin
  Result := False;
  if (featureRec1.fFRID.RCNM <> featureRec2.fFRID.RCNM) or
//      (featureRec1.fFRID.RCID <> featureRec2.fFRID.RCID) or
      (featureRec1.fFRID.NFTC <> featureRec2.fFRID.NFTC) or
      (featureRec1.fFRID.RVER <> featureRec2.fFRID.RVER) or
      (featureRec1.fFRID.RUIN <> featureRec2.fFRID.RUIN) then Exit;
  if (featureRec1.pfFOID = nil) and (featureRec2.pfFOID <> nil) or
      (featureRec1.pfFOID <> nil) and (featureRec2.pfFOID = nil) then Exit;
  if featureRec1.pfFOID <> nil then
    if (featureRec1.pfFOID^.AGEN <> featureRec2.pfFOID^.AGEN) or
        (featureRec1.pfFOID^.FIDN <> featureRec2.pfFOID^.FIDN) or
        (featureRec1.pfFOID^.FIDS <> featureRec2.pfFOID^.FIDS) then Exit;
  if not IsEqual(featureRec1.fATTRArray, featureRec2.fATTRArray) then Exit;
  if not IsEqual(featureRec1.fINASArray, featureRec2.fINASArray, ds1, ds2) then Exit;
  if bCheckGeometry then
    if not IsEqual(featureRec1.fSPASArray, featureRec2.fSPASArray, ds1, ds2) then Exit;
  if Length(featureRec1.fFASCArray) <> Length(featureRec2.fFASCArray) then Exit;
  for i := 0 to Length(featureRec1.fFASCArray) - 1 do begin
    if (featureRec1.fFASCArray[i].RRNM <> featureRec2.fFASCArray[i].RRNM) or
//        (featureRec1.fFASCArray[i].RRID <> featureRec2.fFASCArray[i].RRID) or
        (featureRec1.fFASCArray[i].NFAC <> featureRec2.fFASCArray[i].NFAC) or
        (featureRec1.fFASCArray[i].NARC <> featureRec2.fFASCArray[i].NARC) or
        (featureRec1.fFASCArray[i].FAUI <> featureRec2.fFASCArray[i].FAUI) then Exit;
    if not IsEqual(featureRec1.fFASCArray[i].arrayOfAttrElem,
        featureRec2.fFASCArray[i].arrayOfAttrElem) then Exit;
    if ds1.GetAttributeValue('guID', ds1.featureRecords[featureRec1.fFASCArray[i].RRID].fATTRArray) <>
        ds2.GetAttributeValue('guID', ds2.featureRecords[featureRec2.fFASCArray[i].RRID].fATTRArray) then Exit;
  end;
{
  if Length(featureRec1.fTHASArray) <> Length(featureRec2.fTHASArray) then Exit;
  for i := 0 to Length(featureRec1.fTHASArray) - 1 do begin
    if Length(featureRec1.fTHASArray[i].THASArray) <>
        Length(featureRec2.fTHASArray[i].THASArray) then Exit;
    for j := 0 to Length(featureRec1.fTHASArray[i].THASArray) - 1 do
      if (featureRec1.fTHASArray[i].THASArray[j].RRNM <> featureRec2.fTHASArray[i].THASArray[j].RRNM) or
          (featureRec1.fTHASArray[i].THASArray[j].RRID <> featureRec2.fTHASArray[i].THASArray[j].RRID) or
          (featureRec1.fTHASArray[i].THASArray[j].TAUI <> featureRec2.fTHASArray[i].THASArray[j].TAUI) then Exit;
  end;
  if Length(featureRec1.fMASKArray) <> Length(featureRec2.fMASKArray) then Exit;
  for i := 0 to Length(featureRec1.fMASKArray) - 1 do begin
    if Length(featureRec1.fMASKArray[i].MASKArray) <>
        Length(featureRec2.fMASKArray[i].MASKArray) then Exit;
    for j := 0 to Length(featureRec1.fMASKArray[i].MASKArray) - 1 do
      if (featureRec1.fMASKArray[i].MASKArray[j].RRNM <> featureRec2.fMASKArray[i].MASKArray[j].RRNM) or
          (featureRec1.fMASKArray[i].MASKArray[j].RRID <> featureRec2.fMASKArray[i].MASKArray[j].RRID) or
          (featureRec1.fMASKArray[i].MASKArray[j].MIND <> featureRec2.fMASKArray[i].MASKArray[j].MIND) or
          (featureRec1.fMASKArray[i].MASKArray[j].MUIN <> featureRec2.fMASKArray[i].MASKArray[j].MUIN) then Exit;
  end;
}
  Result := True;
end;

function IsEqual(index1, index2: Integer; recType: TRecordTypeCode;
    ds1, ds2: TS101DataSet): Boolean; overload;
begin
  Result := False;
  if (index1 < 0) or (index2 < 0) then Exit;
  case recType of
    FeatureRecordType: if index1 >= Length(ds1.featureRecords) then Exit;
    PointRecordType: if index1 >= Length(ds1.pointRecords) then Exit;
    MultiPointRecordType: if index1 >= Length(ds1.multiPointRecords) then Exit;
    CurveRecordType: if index1 >= Length(ds1.curveRecords) then Exit;
    CompositeCurveRecordType: if index1 >= Length(ds1.compositeCurveRecords) then Exit;
    SurfaceRecordType: if index1 >= Length(ds1.surfaceRecords) then Exit;
    InfoRecordType: if index1 >= Length(ds1.infoTypeRecords) then Exit;
  end;
  case recType of
    FeatureRecordType: if index2 >= Length(ds2.featureRecords) then Exit;
    PointRecordType: if index2 >= Length(ds2.pointRecords) then Exit;
    MultiPointRecordType: if index2 >= Length(ds2.multiPointRecords) then Exit;
    CurveRecordType: if index2 >= Length(ds2.curveRecords) then Exit;
    CompositeCurveRecordType: if index2 >= Length(ds2.compositeCurveRecords) then Exit;
    SurfaceRecordType: if index2 >= Length(ds2.surfaceRecords) then Exit;
    InfoRecordType: if index2 >= Length(ds2.infoTypeRecords) then Exit;
  end;
  case recType of
    FeatureRecordType:
      if not IsEqual(ds1.featureRecords[index1], ds2.featureRecords[index2], ds1, ds2) then Exit;
    PointRecordType:
      if not IsEqual(ds1.pointRecords[index1], ds2.pointRecords[index2], ds1, ds2) then Exit;
    MultiPointRecordType:
      if not IsEqual(ds1.multiPointRecords[index1], ds2.multiPointRecords[index2], ds1, ds2) then Exit;
    CurveRecordType:
      if not IsEqual(ds1.curveRecords[index1], ds2.curveRecords[index2], ds1, ds2) then Exit;
    CompositeCurveRecordType:
      if not IsEqual(ds1.compositeCurveRecords[index1], ds2.compositeCurveRecords[index2], ds1, ds2) then Exit;
    SurfaceRecordType:
      if not IsEqual(ds1.surfaceRecords[index1], ds2.surfaceRecords[index2], ds1, ds2) then Exit;
    InfoRecordType:
      if not IsEqual(ds1.infoTypeRecords[index1], ds2.infoTypeRecords[index2], ds1, ds2) then Exit;
  end;
  Result := True;
end;

// --------------------- S101Copy(overload) ---------------------

procedure S101Copy(attrElemArray1: TAttrElemArray; var attrElemArray2: TAttrElemArray); overload;
var
  i: Integer;
begin
  SetLength(attrElemArray2, Length(attrElemArray1));
  for i := 0 to High(attrElemArray2) do
    with attrElemArray2[i] do begin
      NATC := attrElemArray1[i].NATC;
      ATIX := attrElemArray1[i].ATIX;
      PAIX := attrElemArray1[i].PAIX;
      ATIN := attrElemArray1[i].ATIN;
      ATVL := attrElemArray1[i].ATVL;
    end;
end;

procedure S101Copy(fINASArray1: TINASFieldArray; var fINASArray2: TINASFieldArray); overload;
var
  i: Integer;
begin
  SetLength(fINASArray2, Length(fINASArray1));
  for i := 0 to High(fINASArray2) do begin
    with fINASArray2[i] do begin
      RRNM := fINASArray1[i].RRNM;
      RRID := fINASArray1[i].RRID;
      NIAC := fINASArray1[i].NIAC;
      NARC := fINASArray1[i].NARC;
      IUIN := fINASArray1[i].IUIN;
    end;
    S101Copy(TAttrElemArray(fINASArray1[i].arrayOfAttrElem),
        TAttrElemArray(fINASArray2[i].arrayOfAttrElem));
  end;
end;

procedure S101Copy(fC2ILFieldArray1: TC2ILFieldArray; var fC2ILFieldArray2: TC2ILFieldArray); overload;
var
  i, j: Integer;
begin
  SetLength(fC2ILFieldArray2, Length(fC2ILFieldArray1));
  for i := 0 to High(fC2ILFieldArray2) do begin
    SetLength(fC2ILFieldArray2[i].C2ITArray, Length(fC2ILFieldArray1[i].C2ITArray));
    for j := 0 to High(fC2ILFieldArray2[i].C2ITArray) do
      with fC2ILFieldArray2[i].C2ITArray[j] do begin
        XCOO := fC2ILFieldArray1[i].C2ITArray[j].XCOO;
        YCOO := fC2ILFieldArray1[i].C2ITArray[j].YCOO;
      end;
  end;
end;

procedure S101Copy(fC3ILFieldArray1: TC3ILFieldArray; var fC3ILFieldArray2: TC3ILFieldArray); overload;
var
  i, j: Integer;
begin
  SetLength(fC3ILFieldArray2, Length(fC3ILFieldArray1));
  for i := 0 to High(fC3ILFieldArray2) do begin
    fC3ILFieldArray2[i].VCID := fC3ILFieldArray1[i].VCID;
    SetLength(fC3ILFieldArray2[i].C3ITArray, Length(fC3ILFieldArray1[i].C3ITArray));
    for j := 0 to High(fC3ILFieldArray2[i].C3ITArray) do
      with fC3ILFieldArray2[i].C3ITArray[j] do begin
        XCOO := fC3ILFieldArray1[i].C3ITArray[j].XCOO;
        YCOO := fC3ILFieldArray1[i].C3ITArray[j].YCOO;
        ZCOO := fC3ILFieldArray1[i].C3ITArray[j].ZCOO;
      end;
  end;
end;

procedure S101Copy(fC2FLFieldArray1: TC2FLFieldArray; var fC2FLFieldArray2: TC2FLFieldArray); overload;
var
  i, j: Integer;
begin
  SetLength(fC2FLFieldArray2, Length(fC2FLFieldArray1));
  for i := 0 to High(fC2FLFieldArray2) do begin
    SetLength(fC2FLFieldArray2[i].C2FTArray, Length(fC2FLFieldArray1[i].C2FTArray));
    for j := 0 to High(fC2FLFieldArray2[i].C2FTArray) do
      with fC2FLFieldArray2[i].C2FTArray[j] do begin
        XCOO := fC2FLFieldArray1[i].C2FTArray[j].XCOO;
        YCOO := fC2FLFieldArray1[i].C2FTArray[j].YCOO;
      end;
  end;
end;

procedure S101Copy(fC3FLFieldArray1: TC3FLFieldArray; var fC3FLFieldArray2: TC3FLFieldArray); overload;
var
  i, j: Integer;
begin
  SetLength(fC3FLFieldArray2, Length(fC3FLFieldArray1));
  for i := 0 to High(fC3FLFieldArray1) do begin
    fC3FLFieldArray2[i].VCID := fC3FLFieldArray1[i].VCID;
    SetLength(fC3FLFieldArray2[i].C3FTArray, Length(fC3FLFieldArray1[i].C3FTArray));
    for j := 0 to High(fC3FLFieldArray2[i].C3FTArray) do
      with fC3FLFieldArray2[i].C3FTArray[j] do begin
        XCOO := fC3FLFieldArray1[i].C3FTArray[j].XCOO;
        YCOO := fC3FLFieldArray1[i].C3FTArray[j].YCOO;
        ZCOO := fC3FLFieldArray1[i].C3FTArray[j].ZCOO;
      end;
  end;
end;

procedure S101Copy(pointRec1: TPointRec; var pointRec2: TPointRec); overload;
begin
  with pointRec2 do begin
    ct := pointRec1.ct;
    with fPRID do begin
      RCNM := pointRec1.fPRID.RCNM;
      RCID := pointRec1.fPRID.RCID;
      RVER := pointRec1.fPRID.RVER;
      RUIN := pointRec1.fPRID.RUIN;
    end;
    S101Copy(TINASFieldArray(pointRec1.fINASArray), TINASFieldArray(fINASArray));
    case ct of
      ct2I: begin
        fC2IT.XCOO := pointRec1.fC2IT.XCOO;
        fC2IT.YCOO := pointRec1.fC2IT.YCOO;
      end;
      ct3I: begin
        fC3IT.VCID := pointRec1.fC3IT.VCID;
        fC3IT.XCOO := pointRec1.fC3IT.XCOO;
        fC3IT.YCOO := pointRec1.fC3IT.YCOO;
        fC3IT.ZCOO := pointRec1.fC3IT.ZCOO;
      end;
      ct2F: begin
        fC2FT.XCOO := pointRec1.fC2FT.XCOO;
        fC2FT.YCOO := pointRec1.fC2FT.YCOO;
      end;
      ct3F: begin
        fC3FT.VCID := pointRec1.fC3FT.VCID;
        fC3FT.XCOO := pointRec1.fC3FT.XCOO;
        fC3FT.YCOO := pointRec1.fC3FT.YCOO;
        fC3FT.ZCOO := pointRec1.fC3FT.ZCOO;
      end;
    end;
    sGUID := pointRec1.sGUID;
  end;
end;

procedure S101Copy(multipointRec1: TMultiPointRec; var multipointRec2: TMultiPointRec); overload;
begin
  with multipointRec2 do begin
    ct := multipointRec1.ct;
    with fMRID do begin
      RCNM := multipointRec1.fMRID.RCNM;
      RCID := multipointRec1.fMRID.RCID;
      RVER := multipointRec1.fMRID.RVER;
      RUIN := multipointRec1.fMRID.RUIN;
    end;
    S101Copy(TINASFieldArray(multipointRec1.fINASArray), TINASFieldArray(fINASArray));
    if multipointRec1.pfCOCC <> nil then begin
      New(pfCOCC);
      with pfCOCC^ do begin
        COUI := multipointRec1.pfCOCC^.COUI;
        COIX := multipointRec1.pfCOCC^.COIX;
        NCOR := multipointRec1.pfCOCC^.NCOR;
      end;
    end
    else
      pfCOCC := nil;
    case ct of
      ct2I: S101Copy(TC2ILFieldArray(multipointRec1.fC2ILArray), TC2ILFieldArray(fC2ILArray));
      ct3I: S101Copy(TC3ILFieldArray(multipointRec1.fC3ILArray), TC3ILFieldArray(fC3ILArray));
      ct2F: S101Copy(TC2FLFieldArray(multipointRec1.fC2FLArray), TC2FLFieldArray(fC2FLArray));
      ct3F: S101Copy(TC3FLFieldArray(multipointRec1.fC3FLArray), TC3FLFieldArray(fC3FLArray));
    end;
    sGUID := multipointRec1.sGUID;
  end;
end;

procedure S101Copy(curveRec1: TCurveRec; var curveRec2: TCurveRec); overload;
var
  i: Integer;
begin
  with curveRec2 do begin
    ct := curveRec1.ct;
    with fCRID do begin
      RCNM := curveRec1.fCRID.RCNM;
      RCID := curveRec1.fCRID.RCID;
      RVER := curveRec1.fCRID.RVER;
      RUIN := curveRec1.fCRID.RUIN;
    end;
    S101Copy(TINASFieldArray(curveRec1.fINASArray), TINASFieldArray(fINASArray));
    SetLength(fPTAS.PTASArray, Length(curveRec1.fPTAS.PTASArray));
    for i := 0 to High(fPTAS.PTASArray) do
      with fPTAS.PTASArray[i] do begin
        RRNM := curveRec1.fPTAS.PTASArray[i].RRNM;
        RRID := curveRec1.fPTAS.PTASArray[i].RRID;
        TOPI := curveRec1.fPTAS.PTASArray[i].TOPI;
      end;
    if curveRec1.pfSECC <> nil then begin
      New(pfSECC);
      with pfSECC^ do begin
        SEUI := curveRec1.pfSECC^.SEUI;
        SEIX := curveRec1.pfSECC^.SEIX;
        NSEG := curveRec1.pfSECC^.NSEG;
      end;
    end
    else
      pfSECC := nil;
    SetLength(fSegmentArray, Length(curveRec1.fSegmentArray));
    for i := 0 to High(fSegmentArray) do begin
      with fSegmentArray[i].fSEGH do begin
        INTP := curveRec1.fSegmentArray[i].fSEGH.INTP;
        if INTP = 7 then begin
          CIRC := curveRec1.fSegmentArray[i].fSEGH.CIRC;
          XCOO := curveRec1.fSegmentArray[i].fSEGH.XCOO;
          YCOO := curveRec1.fSegmentArray[i].fSEGH.YCOO;
          DIST := curveRec1.fSegmentArray[i].fSEGH.DIST;
          DISU := curveRec1.fSegmentArray[i].fSEGH.DISU;
          if CIRC = 2 then begin
            SBRG := curveRec1.fSegmentArray[i].fSEGH.SBRG;
            ANGL := curveRec1.fSegmentArray[i].fSEGH.ANGL;
          end;
        end;
      end;
      if curveRec1.fSegmentArray[i].pfCOCC <> nil then begin
        New(fSegmentArray[i].pfCOCC);
        with fSegmentArray[i].pfCOCC^ do begin
          COUI := curveRec1.fSegmentArray[i].pfCOCC^.COUI;
          COIX := curveRec1.fSegmentArray[i].pfCOCC^.COIX;
          NCOR := curveRec1.fSegmentArray[i].pfCOCC^.NCOR;
        end;
      end
      else
        fSegmentArray[i].pfCOCC := nil;
      with fSegmentArray[i] do
        case ct of
          ct2I: S101Copy(TC2ILFieldArray(curveRec1.fSegmentArray[i].fC2ILArray), TC2ILFieldArray(fC2ILArray));
          ct3I: S101Copy(TC3ILFieldArray(curveRec1.fSegmentArray[i].fC3ILArray), TC3ILFieldArray(fC3ILArray));
          ct2F: S101Copy(TC2FLFieldArray(curveRec1.fSegmentArray[i].fC2FLArray), TC2FLFieldArray(fC2FLArray));
          ct3F: S101Copy(TC3FLFieldArray(curveRec1.fSegmentArray[i].fC3FLArray), TC3FLFieldArray(fC3FLArray));
        end;
    end;
    sGUID := curveRec1.sGUID;
  end;
end;

procedure S101Copy(compositeCurveRec1: TCompositeCurveRec; var compositeCurveRec2: TCompositeCurveRec); overload;
var
  i, j: Integer;
begin
  with compositeCurveRec2 do begin
    with fCCID do begin
      RCNM := compositeCurveRec1.fCCID.RCNM;
      RCID := compositeCurveRec1.fCCID.RCID;
      RVER := compositeCurveRec1.fCCID.RVER;
      RUIN := compositeCurveRec1.fCCID.RUIN;
    end;
    if compositeCurveRec1.pfCCOC <> nil then begin
      New(pfCCOC);
      with pfCCOC^ do begin
        CCUI := compositeCurveRec1.pfCCOC^.CCUI;
        CCIX := compositeCurveRec1.pfCCOC^.CCIX;
        NCCO := compositeCurveRec1.pfCCOC^.NCCO;
      end;
    end
    else
      pfCCOC := nil;
    S101Copy(TINASFieldArray(compositeCurveRec1.fINASArray), TINASFieldArray(fINASArray));
    SetLength(fCUCOArray, Length(compositeCurveRec1.fCUCOArray));
    for i := 0 to High(fCUCOArray) do begin
      SetLength(fCUCOArray[i].CUCOArray, Length(compositeCurveRec1.fCUCOArray[i].CUCOArray));
      for j := 0 to High(fCUCOArray[i].CUCOArray) do
        with fCUCOArray[i].CUCOArray[j] do begin
          RRNM := compositeCurveRec1.fCUCOArray[i].CUCOArray[j].RRNM;
          RRID := compositeCurveRec1.fCUCOArray[i].CUCOArray[j].RRID;
          ORNT := compositeCurveRec1.fCUCOArray[i].CUCOArray[j].ORNT;
        end;
    end;
    sGUID := compositeCurveRec1.sGUID;
  end;
end;

procedure S101Copy(surfaceRec1: TSurfaceRec; var surfaceRec2: TSurfaceRec); overload;
var
  i, j: Integer;
begin
  with surfaceRec2 do begin
    with fSRID do begin
      RCNM := surfaceRec1.fSRID.RCNM;
      RCID := surfaceRec1.fSRID.RCID;
      RVER := surfaceRec1.fSRID.RVER;
      RUIN := surfaceRec1.fSRID.RUIN;
    end;
    S101Copy(TINASFieldArray(surfaceRec1.fINASArray), TINASFieldArray(fINASArray));
    SetLength(fRIASArray, Length(surfaceRec1.fRIASArray));
    for i := 0 to High(fRIASArray) do begin
      SetLength(fRIASArray[i].RIASArray, Length(surfaceRec1.fRIASArray[i].RIASArray));
      for j := 0 to High(fRIASArray[i].RIASArray) do
        with fRIASArray[i].RIASArray[j] do begin
          RRNM := surfaceRec1.fRIASArray[i].RIASArray[j].RRNM;
          RRID := surfaceRec1.fRIASArray[i].RIASArray[j].RRID;
          ORNT := surfaceRec1.fRIASArray[i].RIASArray[j].ORNT;
          USAG := surfaceRec1.fRIASArray[i].RIASArray[j].USAG;
          RAUI := surfaceRec1.fRIASArray[i].RIASArray[j].RAUI;
        end;
    end;
    sGUID := surfaceRec1.sGUID;
  end;
end;

procedure S101Copy(infoRec1: TInformationType; var infoRec2: TInformationType); overload;
var
  i: Integer;
begin
  with infoRec2 do begin
    with fIRID do begin
      RCNM := infoRec1.fIRID.RCNM;
      RCID := infoRec1.fIRID.RCID;
      NITC := infoRec1.fIRID.NITC;
      RVER := infoRec1.fIRID.RVER;
      RUIN := infoRec1.fIRID.RUIN;
    end;
    SetLength(fATTRArray, Length(infoRec1.fATTRArray));
    for i := 0 to High(fATTRArray) do
      S101Copy(TAttrElemArray(infoRec1.fATTRArray[i].arrayOfAttrElem),
          TAttrElemArray(fATTRArray[i].arrayOfAttrElem));
    S101Copy(TINASFieldArray(infoRec1.fINASArray), TINASFieldArray(fINASArray));
    m_sGUID := infoRec1.m_sGUID;
    m_sCode := infoRec1.m_sCode;
  end;
end;

procedure S101Copy(feature1: TFeatureRec; var feature2: TFeatureRec); overload;
var
  i, j: Integer;
begin
  with feature2 do begin
    with fFRID do begin
      RCNM := feature1.fFRID.RCNM;
      RCID := feature1.fFRID.RCID;
      NFTC := feature1.fFRID.NFTC;
      RVER := feature1.fFRID.RVER;
      RUIN := feature1.fFRID.RUIN;
    end;
    if feature1.pfFOID <> nil then begin
      New(pfFOID);
      with pfFOID^ do begin
        AGEN := feature1.pfFOID^.AGEN;
        FIDN := feature1.pfFOID^.FIDN;
        FIDS := feature1.pfFOID^.FIDS;
      end;
    end
    else
      pfFOID := nil;
    SetLength(fATTRArray, Length(feature1.fATTRArray));
    for i := 0 to High(fATTRArray) do
      S101Copy(TAttrElemArray(feature1.fATTRArray[i].arrayOfAttrElem),
          TAttrElemArray(fATTRArray[i].arrayOfAttrElem));
    S101Copy(TINASFieldArray(feature1.fINASArray), TINASFieldArray(fINASArray));
    SetLength(fSPASArray, Length(feature1.fSPASArray));
    for i := 0 to High(fSPASArray) do begin
      SetLength(fSPASArray[i].SPASArray, Length(feature1.fSPASArray[i].SPASArray));
      for j := 0 to High(fSPASArray[i].SPASArray) do begin
        with fSPASArray[i].SPASArray[j] do begin
          RRNM := feature1.fSPASArray[i].SPASArray[j].RRNM;
          RRID := feature1.fSPASArray[i].SPASArray[j].RRID;
          ORNT := feature1.fSPASArray[i].SPASArray[j].ORNT;
          SMIN := feature1.fSPASArray[i].SPASArray[j].SMIN;
          SMAX := feature1.fSPASArray[i].SPASArray[j].SMAX;
          SAUI := feature1.fSPASArray[i].SPASArray[j].SAUI;
        end;
      end;
    end;
    SetLength(fFASCArray, Length(feature1.fFASCArray));
    for i := 0 to High(fFASCArray) do
      with fFASCArray[i] do begin
        RRNM := feature1.fFASCArray[i].RRNM;
        RRID := feature1.fFASCArray[i].RRID;
        NFAC := feature1.fFASCArray[i].NFAC;
        NARC := feature1.fFASCArray[i].NARC;
        FAUI := feature1.fFASCArray[i].FAUI;
        S101Copy(TAttrElemArray(feature1.fFASCArray[i].arrayOfAttrElem),
            TAttrElemArray(arrayOfAttrElem));
      end;
    SetLength(fTHASArray, Length(feature1.fTHASArray));
    for i := 0 to High(fTHASArray) do begin
      SetLength(fTHASArray[i].THASArray, Length(feature1.fTHASArray[i].THASArray));
      for j := 0 to High(fTHASArray[i].THASArray) do
        with fTHASArray[i].THASArray[j] do begin
          RRNM := feature1.fTHASArray[i].THASArray[j].RRNM;
          RRID := feature1.fTHASArray[i].THASArray[j].RRID;
          TAUI := feature1.fTHASArray[i].THASArray[j].TAUI;
        end;
    end;
    SetLength(fMASKArray, Length(feature1.fMASKArray));
    for i := 0 to High(fMASKArray) do begin
      SetLength(fMASKArray[i].MASKArray, Length(feature1.fMASKArray[i].MASKArray));
      for j := 0 to High(fMASKArray[i].MASKArray) - 1 do
        with fMASKArray[i].MASKArray[j] do begin
          RRNM := feature1.fMASKArray[i].MASKArray[j].RRNM;
          RRID := feature1.fMASKArray[i].MASKArray[j].RRID;
          MIND := feature1.fMASKArray[i].MASKArray[j].MIND;
          MUIN := feature1.fMASKArray[i].MASKArray[j].MUIN;
        end;
    end;
    m_sGUID := feature1.m_sGUID;
    m_sCode := feature1.m_sCode;
  end;
end;

procedure ClearRec(var infoRec: TInformationType); overload;
var
  i: Integer;
begin
  with infoRec do begin
    for i := 0 to High(fATTRArray) do
      SetLength(fATTRArray[i].arrayOfAttrElem, 0);
    SetLength(fATTRArray, 0);
    for i := 0 to High(fINASArray) do
      SetLength(fINASArray[i].arrayOfAttrElem, 0);
    SetLength(fINASArray, 0);
    m_sGUID := '';
    m_sCode := '';
  end;
  ZeroMemory(@infoRec, SizeOf(TInformationType));
end;

procedure ClearRec(var pointRec: TPointRec); overload;
var
  i: Integer;
begin
  with pointRec do begin
    for i := 0 to High(fINASArray) do
      SetLength(fINASArray[i].arrayOfAttrElem, 0);
    SetLength(fINASArray, 0);
    sGUID := '';
  end;
  ZeroMemory(@pointRec, SizeOf(TPointRec));
end;

procedure ClearRec(var multiPointRec: TMultiPointRec); overload;
var
  i: Integer;
begin
  with multiPointRec do begin
    for i := 0 to High(fINASArray) do
      SetLength(fINASArray[i].arrayOfAttrElem, 0);
    SetLength(fINASArray, 0);
    if pfCOCC <> nil then begin
      Dispose(pfCOCC);
      pfCOCC := nil;
    end;
    case ct of
      ct2I: begin
        for i := 0 to High(fC2ILArray) do
          SetLength(fC2ILArray[i].C2ITArray, 0);
        SetLength(fC2ILArray, 0);
      end;
      ct3I: begin
        for i := 0 to High(fC3ILArray) do
          SetLength(fC3ILArray[i].C3ITArray, 0);
        SetLength(fC3ILArray, 0);
      end;
      ct2F: begin
        for i := 0 to High(fC2FLArray) do
          SetLength(fC2FLArray[i].C2FTArray, 0);
        SetLength(fC2FLArray, 0);
      end;
      ct3F: begin
        for i := 0 to High(fC3FLArray) do
          SetLength(fC3FLArray[i].C3FTArray, 0);
        SetLength(fC3FLArray, 0);
      end;
    end;
    sGUID := '';
  end;
  ZeroMemory(@multiPointRec, SizeOf(TMultiPointRec));
end;

procedure ClearRec(var curveRec: TCurveRec); overload;
var
  i, j: Integer;
begin
  with curveRec do begin
    for i := 0 to High(fINASArray) do
      SetLength(fINASArray[i].arrayOfAttrElem, 0);
    SetLength(fINASArray, 0);
    SetLength(fPTAS.PTASArray, 0);
    if pfSECC <> nil then begin
      Dispose(pfSECC);
      pfSECC := nil;
    end;
    for i := 0 to High(fSegmentArray) do begin
      if fSegmentArray[i].pfCOCC <> nil then begin
        Dispose(fSegmentArray[i].pfCOCC);
        fSegmentArray[i].pfCOCC := nil;
      end;
      case ct of
        ct2I: begin
          for j := 0 to High(fSegmentArray[i].fC2ILArray) do
            SetLength(fSegmentArray[i].fC2ILArray[j].C2ITArray, 0);
          SetLength(fSegmentArray[i].fC2ILArray, 0);
        end;
        ct3I: begin
          for j := 0 to High(fSegmentArray[i].fC3ILArray) do
            SetLength(fSegmentArray[i].fC3ILArray[j].C3ITArray, 0);
          SetLength(fSegmentArray[i].fC3ILArray, 0);
        end;
        ct2F: begin
          for j := 0 to High(fSegmentArray[i].fC2FLArray) do
            SetLength(fSegmentArray[i].fC2FLArray[j].C2FTArray, 0);
          SetLength(fSegmentArray[i].fC2FLArray, 0);
        end;
        ct3F: begin
          for j := 0 to High(fSegmentArray[i].fC3FLArray) do
            SetLength(fSegmentArray[i].fC3FLArray[j].C3FTArray, 0);
          SetLength(fSegmentArray[i].fC3FLArray, 0);
        end;
      end;
    end;
    SetLength(fSegmentArray, 0);
  end;
  ZeroMemory(@curveRec, SizeOf(TCurveRec));
end;

procedure ClearRec(var compositeCurveRec: TCompositeCurveRec); overload;
var
  i: Integer;
begin
  with compositeCurveRec do begin
    if pfCCOC <> nil then begin
      Dispose(pfCCOC);
      pfCCOC := nil;
    end;
    for i := 0 to High(fINASArray) do
      SetLength(fINASArray[i].arrayOfAttrElem, 0);
    SetLength(fINASArray, 0);
    for i := 0 to High(fCUCOArray) do
      SetLength(fCUCOArray[i].CUCOArray, 0);
    SetLength(fCUCOArray, 0);
  end;
  ZeroMemory(@compositeCurveRec, SizeOf(TCompositeCurveRec));
end;

procedure ClearRec(var surfaceRec: TSurfaceRec); overload;
var
  i: Integer;
begin
  with surfaceRec do begin
    for i := 0 to High(fINASArray) do
      SetLength(fINASArray[i].arrayOfAttrElem, 0);
    SetLength(fINASArray, 0);
    for i := 0 to High(fRIASArray) do
      SetLength(fRIASArray[i].RIASArray, 0);
    SetLength(fRIASArray, 0);
  end;
  ZeroMemory(@surfaceRec, SizeOf(TSurfaceRec));
end;

procedure ClearRec(var featureRec: TFeatureRec); overload;
var
  i: Integer;
begin
  with featureRec do begin
    if pfFOID <> nil then begin
      Dispose(pfFOID);
      pfFOID := nil;
    end;
    for i := 0 to High(fATTRArray) do
      SetLength(fATTRArray[i].arrayOfAttrElem, 0);
    SetLength(fATTRArray, 0);
    for i := 0 to High(fINASArray) do
      SetLength(fINASArray[i].arrayOfAttrElem, 0);
    SetLength(fINASArray, 0);
    for i := 0 to High(fSPASArray) do
      SetLength(fSPASArray[i].SPASArray, 0);
    SetLength(fSPASArray, 0);
    for i := 0 to High(fFASCArray) do
      SetLength(fFASCArray[i].arrayOfAttrElem, 0);
    SetLength(fFASCArray, 0);
    for i := 0 to High(fTHASArray) do
      SetLength(fTHASArray[i].THASArray, 0);
    SetLength(fTHASArray, 0);
    for i := 0 to High(fMASKArray) do
      SetLength(fMASKArray[i].MASKArray, 0);
    SetLength(fMASKArray, 0);
  end;
  ZeroMemory(@featureRec, SizeOf(TFeatureRec));
end;

