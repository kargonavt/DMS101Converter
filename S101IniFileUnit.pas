unit S101IniFileUnit;

interface

uses
  Classes, SysUtils, StrUtils, IniFiles, S101TypesUnit, S101BinaryAccessUnit;

type
  TS101IniFile = class(TIniFile)
    procedure WriteLRLeader(lrLeader: TLRLeader);
    function ReadLRLeader(var lrLeader: TLRLeader): Boolean;
    procedure WriteFieldTagPairs(fieldTagPairs: TLRFieldTagPairArray);
    function ReadFieldTagPairs(var fieldTagPairs: TLRFieldTagPairArray): Boolean;
    procedure WriteFieldDescriptions(lrFieldDescriptions: TLRFieldDescriptionArray);
    function ReadFieldDescriptions(var lrFieldDescriptions: TLRFieldDescriptionArray): Boolean;
    procedure WriteCodeTable(tableName: string; codesField: TCodesField);
    function ReadCodeTable(tableName: string; var codesField: TCodesField): Boolean;
    procedure WriteDSIDField(fDSID: TDSIDField; topicCategories: TTopicCategories);
    function ReadDSIDField(var fDSID: TDSIDField; topicCategories: TTopicCategories): Boolean;
    function ReadDSSIField(var fDSSI: TDSSIField): Boolean;
    procedure WriteCSIDField(fCSID: TCSIDField);
    function ReadCSIDField(var fCSID: TCSIDField): Boolean;
    procedure WriteCRSHField(fCRSH: TCRSHField; iCRS: Integer);
    function ReadCRSHField(var fCRSH: TCRSHField; iCRS: Integer): Boolean;
    procedure WriteCSAXField(fCSAX: TCSAXField; iCRS: Integer);
    function ReadCSAXField(var fCSAX: TCSAXField; iCRS: Integer): Boolean;
    procedure WritePROJField(fPROJ: TPROJField; iCRS: Integer);
    function ReadPROJField(var fPROJ: TPROJField; iCRS: Integer): Boolean;
    procedure WriteGDATField(fGDAT: TGDATField; iCRS: Integer);
    function ReadGDATField(var fGDAT: TGDATField; iCRS: Integer): Boolean;
    procedure WriteVDATField(fVDAT: TVDATField; iCRS: Integer);
    function ReadVDATField(var fVDAT: TVDATField; iCRS: Integer): Boolean;
  end;

implementation

procedure TS101IniFile.WriteLRLeader(lrLeader: TLRLeader);
var
  buffer: array[0..255] of Char;
  i: Integer;
begin
  EraseSection('LRLeader');
  for i := 0 to SizeOf(buffer) - 1 do buffer[i] := #0;
  Move(lrLeader.interchangeLevel, buffer, SizeOf(lrLeader.interchangeLevel));
  WriteString('LRLeader', 'InterchangeLevel', buffer);
  for i := 0 to SizeOf(buffer) - 1 do buffer[i] := #0;
  Move(lrLeader.leaderIdentifier, buffer, SizeOf(lrLeader.leaderIdentifier));
  WriteString('LRLeader', 'LeaderIdentifier', buffer);
  for i := 0 to SizeOf(buffer) - 1 do buffer[i] := #0;
  Move(lrLeader.inlineCodeExtensionIndicator, buffer, SizeOf(lrLeader.inlineCodeExtensionIndicator));
  WriteString('LRLeader', 'InlineCodeExtensionIndicator', buffer);
  for i := 0 to SizeOf(buffer) - 1 do buffer[i] := #0;
  Move(lrLeader.versionNumber, buffer, SizeOf(lrLeader.versionNumber));
  WriteString('LRLeader', 'VersionNumber', buffer);
  for i := 0 to SizeOf(buffer) - 1 do buffer[i] := #0;
  Move(lrLeader.applicationIndicator, buffer, SizeOf(lrLeader.applicationIndicator));
  WriteString('LRLeader', 'ApplicationIndicator', AnsiReplaceStr(buffer, ' ', '#$20'));
  for i := 0 to SizeOf(buffer) - 1 do buffer[i] := #0;
  Move(lrLeader.fieldControlLength, buffer, SizeOf(lrLeader.fieldControlLength));
  WriteString('LRLeader', 'FieldControlLength', buffer);
  for i := 0 to SizeOf(buffer) - 1 do buffer[i] := #0;
  Move(lrLeader.extendedCharacterSetIndicator, buffer, SizeOf(lrLeader.extendedCharacterSetIndicator));
  WriteString('LRLeader', 'ExtendedCharacterSetIndicator', AnsiReplaceStr(buffer, ' ', '#$20'));
  for i := 0 to SizeOf(buffer) - 1 do buffer[i] := #0;
  Move(lrLeader.entryMap, buffer, SizeOf(lrLeader.entryMap));
  WriteString('LRLeader', 'EntryMap', buffer);
end;

function TS101IniFile.ReadLRLeader(var lrLeader: TLRLeader): Boolean;
var
  s: string;
  i: Integer;
begin
  Result := False;
  for i := 0 to SizeOf(lrLeader) - 1 do
    (PChar(@lrLeader) + i)^ := #0;
  s := ReadString('LRLeader', 'InterchangeLevel', '3');
  Move(s[1], lrLeader.interchangeLevel, SizeOf(lrLeader.interchangeLevel));
  s := ReadString('LRLeader', 'LeaderIdentifier', 'L');
  Move(s[1], lrLeader.leaderIdentifier, SizeOf(lrLeader.leaderIdentifier));
  s := ReadString('LRLeader', 'InlineCodeExtensionIndicator', 'E');
  Move(s[1], lrLeader.inlineCodeExtensionIndicator, SizeOf(lrLeader.inlineCodeExtensionIndicator));
  s := ReadString('LRLeader', 'VersionNumber', '1');
  Move(s[1], lrLeader.versionNumber, SizeOf(lrLeader.versionNumber));
  s := ReadString('LRLeader', 'ApplicationIndicator', ' ');
  s := AnsiReplaceStr(s, '#$20', ' ');
  Move(s[1], lrLeader.applicationIndicator, SizeOf(lrLeader.applicationIndicator));
  s := ReadString('LRLeader', 'FieldControlLength', '09');
  Move(s[1], lrLeader.fieldControlLength, SizeOf(lrLeader.fieldControlLength));
  s := ReadString('LRLeader', 'ExtendedCharacterSetIndicator', ' ! ');
  s := AnsiReplaceStr(s, '#$20', ' ');
  Move(s[1], lrLeader.extendedCharacterSetIndicator, SizeOf(lrLeader.extendedCharacterSetIndicator));
  s := ReadString('LRLeader', 'EntryMap', '3404');
  Move(s[1], lrLeader.entryMap, SizeOf(lrLeader.entryMap));
  Result := True;
end;

procedure TS101IniFile.WriteFieldTagPairs(fieldTagPairs: TLRFieldTagPairArray);
var
  i: Integer;
begin
  EraseSection('FieldTagPairs');
  for i := 0 to Length(fieldTagPairs) - 1 do
    WriteString('FieldTagPairs', Format('TagPair%d', [i + 1]),
        fieldTagPairs[i].parentFieldTag + ',' + fieldTagPairs[i].offspringFieldTag);
end;

function TS101IniFile.ReadFieldTagPairs(var fieldTagPairs: TLRFieldTagPairArray): Boolean;
var
  s: string;
  i: Integer;
  keys: TStringList;
  tags: TStringList;
begin
  Result := False;
  keys := TStringList.Create;
  tags := TStringList.Create;
  ReadSection('FieldTagPairs', keys);
  SetLength(fieldTagPairs, keys.Count);
  for i := 0 to keys.Count - 1 do begin
    s := ReadString('FieldTagPairs', keys[i], '');
    tags.Clear;
    ExtractStrings([','], [' '], PChar(s), tags);
    fieldTagPairs[i].parentFieldTag := tags[0];
    fieldTagPairs[i].offspringFieldTag := tags[1];
  end;
  tags.Free;
  keys.Free;
  Result := True;
end;

procedure TS101IniFile.WriteFieldDescriptions(lrFieldDescriptions: TLRFieldDescriptionArray);
var
  s: string;
  i, iTag, code: Integer;
begin
  EraseSection('FieldDescriptions');
  for i := 0 to Length(lrFieldDescriptions) - 1 do begin
    Val(lrFieldDescriptions[i].fieldTag, iTag, code);
    if code <> 0 then begin
      s := AnsiReplaceStr(lrFieldDescriptions[i].fieldDescription, #$1E, '#$1E');
      s := AnsiReplaceStr(s, #$1F, '#$1F');
      WriteString('FieldDescriptions', lrFieldDescriptions[i].fieldTag, s);
    end;
  end;
end;

function TS101IniFile.ReadFieldDescriptions(var lrFieldDescriptions: TLRFieldDescriptionArray): Boolean;
var
  s: string;
  i: Integer;
  keys: TStringList;
begin
  Result := False;
  keys := TStringList.Create;
  ReadSection('FieldDescriptions', keys);
  SetLength(lrFieldDescriptions, keys.Count);
  for i := 0 to keys.Count - 1 do begin
    lrFieldDescriptions[i].fieldTag := keys[i];
    s := ReadString('FieldDescriptions', keys[i], '');
    s := AnsiReplaceStr(s, '#$1E', #$1E);
    lrFieldDescriptions[i].fieldDescription := AnsiReplaceStr(s, '#$1F', #$1F);
  end;
  keys.Free;
  Result := True;
end;

procedure TS101IniFile.WriteCodeTable(tableName: string; codesField: TCodesField);
var
  i: Integer;
  sName, sNumber: string;
begin
  EraseSection(tableName);
  for i := 0 to Length(codesField) - 1 do
    WriteString(tableName, Format('%d', [codesField[i].iCode]), codesField[i].sCode);
end;

function TS101IniFile.ReadCodeTable(tableName: string; var codesField: TCodesField): Boolean;
var
  s: string;
  i, code: Integer;
  keys: TStringList;
begin
  Result := False;
  keys := TStringList.Create;
  ReadSection(tableName, keys);
  SetLength(codesField, keys.Count);
  for i := 0 to keys.Count - 1 do begin
    Val(keys[i], codesField[i].iCode, code);
    codesField[i].sCode := ReadString(tableName, keys[i], '');
  end;
  keys.Free;
  Result := True;
end;

procedure TS101IniFile.WriteDSIDField(fDSID: TDSIDField; topicCategories: TTopicCategories);
var
  i, j: Integer;
begin
  EraseSection('DSID');
  with fDSID do begin
    WriteInteger('DSID', 'RCID', RCID);
    WriteString('DSID', 'ENSP', ENSP);
    WriteString('DSID', 'ENED', ENED);
    WriteString('DSID', 'PRSP', PRSP);
    WriteString('DSID', 'PRED', PRED);
    WriteString('DSID', 'PROF', PROF);
    WriteString('DSID', 'DSNM', DSNM);
    WriteString('DSID', 'DSTL', DSTL);
    WriteString('DSID', 'DSRD', DSRD);
    WriteString('DSID', 'DSLG', DSLG);
    WriteString('DSID', 'DSAB', DSAB);
    WriteString('DSID', 'DSED', DSED);
    for i := 0 to Length(DSTC) - 1 do
      for j := 0 to Length(topicCategories) - 1 do
        if topicCategories[j].code = DSTC[i] then begin
          WriteString('DSID', Format('TopicCategory%d', [i + 1]), topicCategories[j].name);
          Break;
        end;
  end;
end;

function TS101IniFile.ReadDSIDField(var fDSID: TDSIDField; topicCategories: TTopicCategories): Boolean;
var
  s: string;
  i, j: Integer;
begin
  Result := False;
  with fDSID do begin
    RCNM := 10;
    RCID := ReadInteger('DSID', 'RCID', 1);
    ENSP := ReadString('DSID', 'ENSP', 'S-100 Part 10a');
    ENED := ReadString('DSID', 'ENED', '1.1');
    PRSP := ReadString('DSID', 'PRSP', 'INT.IHO.S-101.1.0');
    PRED := ReadString('DSID', 'PRED', '1.0');
    PROF := ReadString('DSID', 'PROF', '1');
    DSLG := ReadString('DSID', 'DSLG', 'EN');
    DSAB := ReadString('DSID', 'DSAB', '');
    i := 0;
    repeat
      s := ReadString('DSID', Format('TopicCategory%d', [i + 1]), '');
      if s = '' then Break;
      SetLength(DSTC, i + 1);
      for j := 0 to Length(topicCategories) - 1 do
        if topicCategories[j].name = s then begin
          DSTC[i] := topicCategories[j].code;
          Break;
        end;
      i := i + 1;
    until False;
  end;
  Result := True;
end;

function TS101IniFile.ReadDSSIField(var fDSSI: TDSSIField): Boolean;
begin
  Result := False;
  with fDSSI do begin
    DCOX := ReadFloat('DSSI', 'DCOX', 0);
    DCOY := ReadFloat('DSSI', 'DCOY', 0);
    DCOZ := ReadFloat('DSSI', 'DCOZ', 0);
    CMFX := ReadInteger('DSSI', 'CMFX', 10000000);
    CMFY := ReadInteger('DSSI', 'CMFY', 10000000);
    CMFZ := ReadInteger('DSSI', 'CMFZ', 100);
  end;
  Result := True;
end;

procedure TS101IniFile.WriteCSIDField(fCSID: TCSIDField);
var
  nCRS, iCRS: Integer;
begin
  nCRS := ReadInteger('CSID', 'NCRC', 0);
  for iCRS := 0 to nCRS - 1 do begin
    EraseSection(Format('CRSH%d', [iCRS + 1]));
    EraseSection(Format('CSAX%d', [iCRS + 1]));
    EraseSection(Format('PROJ%d', [iCRS + 1]));
    EraseSection(Format('GDAT%d', [iCRS + 1]));
    EraseSection(Format('VDAT%d', [iCRS + 1]));
  end;
  EraseSection('CSID');
  WriteInteger('CSID', 'NCRC', fCSID.NCRC);
end;

function TS101IniFile.ReadCSIDField(var fCSID: TCSIDField): Boolean;
begin
  Result := False;
  fCSID.RCNM := 15;
  fCSID.RCID := 1;
  fCSID.NCRC := ReadInteger('CSID', 'NCRC', 1);
  Result := True;
end;

procedure TS101IniFile.WriteCRSHField(fCRSH: TCRSHField; iCRS: Integer);
var
  section: string;
begin
  section := Format('CRSH%d', [iCRS + 1]);
  EraseSection(section);
  with fCRSH do begin
    WriteInteger(section, 'CRIX', CRIX);
    WriteInteger(section, 'CRST', CRST);
    WriteInteger(section, 'CSTY', CSTY);
    WriteString(section, 'CRNM', CRNM);
    WriteString(section, 'CRSI', CRSI);
    WriteInteger(section, 'CRSS', CRSS);
    WriteString(section, 'SCRI', SCRI);
  end;
end;

function TS101IniFile.ReadCRSHField(var fCRSH: TCRSHField; iCRS: Integer): Boolean;
var
  keys: TStringList;
  section: string;
begin
  Result := False;
  section := Format('CRSH%d', [iCRS + 1]);
  keys := TStringList.Create;
  ReadSection(section, keys);
  if keys.Count = 0 then
    Exit;
  fCRSH.CRIX := ReadInteger(section, 'CRIX', 1);
  fCRSH.CRST := ReadInteger(section, 'CRST', 1);
  fCRSH.CSTY := ReadInteger(section, 'CSTY', 1);
  fCRSH.CRNM := ReadString(section, 'CRNM', 'WGS84');
  fCRSH.CRSI := ReadString(section, 'CRSI', '4326');
  fCRSH.CRSS := ReadInteger(section, 'CRSS', 2);
  fCRSH.SCRI := ReadString(section, 'SCRI', '');
  keys.Free;
  Result := True;
end;

procedure TS101IniFile.WriteCSAXField(fCSAX: TCSAXField; iCRS: Integer);
var
  section: string;
  iAxis: Integer;
begin
  section := Format('CSAX%d', [iCRS + 1]);
  EraseSection(section);
  for iAxis := 0 to Length(fCSAX) - 1 do begin
    WriteInteger(section, Format('AXTY%d', [iAxis + 1]), fCSAX[iAxis].AXTY);
    WriteInteger(section, Format('AXUM%d', [iAxis + 1]), fCSAX[iAxis].AXUM);
  end;
end;

function TS101IniFile.ReadCSAXField(var fCSAX: TCSAXField; iCRS: Integer): Boolean;
var
  section: string;
  keys: TStringList;
  iAxis: Integer;
begin
  Result := False;
  section := Format('CSAX%d', [iCRS + 1]);
  keys := TStringList.Create;
  ReadSection(section, keys);
  if keys.Count = 0 then begin
    keys.Free;
    Exit;
  end;
  SetLength(fCSAX, keys.Count div 2);
  for iAxis := 0 to Length(fCSAX) - 1 do begin
    fCSAX[iAxis].AXTY := ReadInteger(section, Format('AXTY%d', [iAxis]), 12);
    fCSAX[iAxis].AXUM := ReadInteger(section, Format('AXUM%d', [iAxis]), 4);
  end;
  keys.Free;
  Result := True;
end;

procedure TS101IniFile.WritePROJField(fPROJ: TPROJField; iCRS: Integer);
var
  section: string;
begin
  section := Format('PROJ%d', [iCRS + 1]);
  EraseSection(section);
  with fPROJ do begin
    WriteInteger(section, 'PROM', PROM);
    WriteFloat(section, 'PRP1', PRP1);
    WriteFloat(section, 'PRP2', PRP2);
    WriteFloat(section, 'PRP3', PRP3);
    WriteFloat(section, 'PRP4', PRP4);
    WriteFloat(section, 'PRP5', PRP5);
    WriteFloat(section, 'FEAS', FEAS);
    WriteFloat(section, 'FNOR', FNOR);
  end;
end;

function TS101IniFile.ReadPROJField(var fPROJ: TPROJField; iCRS: Integer): Boolean;
var
  section: string;
  keys: TStringList;
begin
  Result := False;
  section := Format('PROJ%d', [iCRS + 1]);
  keys := TStringList.Create;
  ReadSection(section, keys);
  if keys.Count = 0 then begin
    keys.Free;
    Exit;
  end;
  fPROJ.PROM := ReadInteger(section, 'PROM', 1);
  fPROJ.PRP1 := ReadFloat(section, 'PRP1', 0.0);
  fPROJ.PRP2 := ReadFloat(section, 'PRP2', 0.0);
  fPROJ.PRP3 := ReadFloat(section, 'PRP3', 0.0);
  fPROJ.PRP4 := ReadFloat(section, 'PRP4', 0.0);
  fPROJ.PRP5 := ReadFloat(section, 'PRP5', 0.0);
  fPROJ.FEAS := ReadFloat(section, 'FEAS', 0.0);
  fPROJ.FNOR := ReadFloat(section, 'FNOR', 0.0);
  keys.Free;
  Result := True;
end;

procedure TS101IniFile.WriteGDATField(fGDAT: TGDATField; iCRS: Integer);
var
  section: string;
begin
  section := Format('GDAT%d', [iCRS + 1]);
  EraseSection(section);
  with fGDAT do begin
    WriteString(section, 'DTNM', fDTNM);
    WriteString(section, 'ELNM', fELNM);
    WriteFloat(section, 'ESMA', fESMA);
    WriteInteger(section, 'ESPT', fESPT);
    WriteFloat(section, 'ESPM', fESPM);
    WriteString(section, 'CMNM', fCMNM);
    WriteFloat(section, 'CMGL', fCMGL);
  end;
end;

function TS101IniFile.ReadGDATField(var fGDAT: TGDATField; iCRS: Integer): Boolean;
var
  section: string;
  keys: TStringList;
begin
  Result := False;
  section := Format('GDAT%d', [iCRS + 1]);
  keys := TStringList.Create;
  ReadSection(section, keys);
  if keys.Count = 0 then begin
    keys.Free;
    Exit;
  end;
  fGDAT.fDTNM := ReadString(section, 'DTNM', '');
  fGDAT.fELNM := ReadString(section, 'ELNM', '');
  fGDAT.fESMA := ReadFloat(section, 'ESMA', 0.0);
  fGDAT.fESPT := ReadInteger(section, 'ESPT', 0);
  fGDAT.fESPM := ReadFloat(section, 'ESPM', 0.0);
  fGDAT.fCMNM := ReadString(section, 'CMNM', '');
  fGDAT.fCMGL := ReadFloat(section, 'CMGL', 0.0);
  keys.Free;
  Result := True;
end;

procedure TS101IniFile.WriteVDATField(fVDAT: TVDATField; iCRS: Integer);
var
  section: string;
begin
  section := Format('VDAT%d', [iCRS + 1]);
  EraseSection(section);
  with fVDAT do begin
    WriteString(section, 'DTNM', fDTNM);
    WriteString(section, 'DTID', fDTID);
    WriteInteger(section, 'DTSR', fDTSR);
    WriteString(section, 'SCRI', fSCRI);
  end;
end;

function TS101IniFile.ReadVDATField(var fVDAT: TVDATField; iCRS: Integer): Boolean;
var
  section: string;
  keys: TStringList;
begin
  Result := False;
  section := Format('VDAT%d', [iCRS + 1]);
  keys := TStringList.Create;
  ReadSection(section, keys);
  if keys.Count = 0 then begin
    keys.Free;
    Exit;
  end;
  fVDAT.fDTNM := ReadString(section, 'DTNM', '');
  fVDAT.fDTID := ReadString(section, 'DTID', '');
  fVDAT.fDTSR := ReadInteger(section, 'DTSR', 0);
  fVDAT.fSCRI := ReadString(section, 'SCRI', '');
  keys.Free;
  Result := True;
end;

end.
