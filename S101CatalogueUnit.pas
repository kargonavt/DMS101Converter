unit S101CatalogueUnit;

interface

uses
  SysUtils, Classes, Windows, Controls, Contnrs, StrUtils, DateUtils, variants,
      uLkJSON, S101TypesUnit;

type
  TItem = class
  public
    sCode: string;
  end;

  TCatalogueItems = class(TMyObjectList)
  public
    function GetKeyByIndex(index: Integer): string; override;
    function GetItemByName(sName: string): TItem;
  end;

  TAcronymPair = class
  public
    theirAcronym: string;
    ourAcronym: string;
  end;

  TAcronymKey = (KEY_THEIR, KEY_OUR);

  TAcronymPairs = class(TMyObjectList)
  public
    constructor Create(acronymKey: TAcronymKey = KEY_THEIR);
    procedure SortByTheir;
    procedure SortByOur;
    function GetIndexByTheir(their: string): Integer;
    function GetIndexByOur(our: string): Integer;
    function GetOurByTheir(their: string): string;
    function GetTheirByOur(our: string): string;
    function GetKeyByIndex(index: Integer): string; override;
  private
    m_AcronymKey: TAcronymKey;
  end;

  TAcronymDescendants = class
  public
    m_sParent: string;
    m_ssDescendants: TStrings;
    constructor Create(sParent: string);
  end;

  TAcronymsDescendants = class(TMyObjectList)
    function GetKeyByIndex(index: Integer): string; override;
    function AddDescendant(sParent, sDescendant: string): Boolean;
    function GetDescendantsOfParent(sParent: string): TStrings;
  end;

  TNamedItem = class(TItem)
  public
    sDefinition: string;
    sDefinitionSourceIdentifier: string;
    sCitationTitle: string;
    sName: string;
    sType: string;
  end;

  TListedValue = record
    iCode: Integer;
    sDefinition: string;
    sLabel: string;
  end;

  TAttributeItem = class(TNamedItem)
  public
    sUom: string;
    sQuantitySpecification: string;
    sValueType: string;
    lListedValues: array of TListedValue;
  end;

  TAttributeRef = record
    sCode: string;
    multiplicity: record
      lower: Integer;
      upper: Integer;
    end;
    bSequential: Boolean;
    bVoidable: Boolean;
    allowedValues: array of Integer;
  end;

  TAttributeRefArray = array of TAttributeRef;

  TAttributeValueConstraint = record
    sValidationRule: string;
    sDescription: string;
  end;

  TComplexAttributeItem = class(TNamedItem)
  public
    children: array of TAttributeRef;
    attributeValueConstraints: array of TAttributeValueConstraint;
  end;

  TRoleItem = class(TNamedItem)
  public
    isAbstract: Boolean;
  end;

  TObjectItem = class(TNamedItem)
  public
    attributes: array of TAttributeRef;
    attributeValueConstraints: array of TAttributeValueConstraint;
    isAbstract: Boolean;
    sParent: string;
  end;

  TAssociationItem = class(TObjectItem)
  public
    sRole1: string;
    sRole2: string;
  end;

  TBinding = class
  public
    association: string;
    multiplicity: record
      lower: Integer;
      upper: Integer;
    end;
    role: string;
    roletype: Integer;
    targetFeature: string;
    attributeValueConstraints: array of TAttributeValueConstraint;
  end;

  TFeatureOrInfoItem = class(TObjectItem)
  public
    informationBindings: array of TBinding;
  end;

  TTopologicConstraint = record
    sourceGeom: Integer;
    targetGeom: Integer;
    topologicRule: string;
    description: string;
  end;

  TFeatureBinding = class(TBinding)
  public
    topologicConstraints: array of TTopologicConstraint;
  end;

  TRoleTypeOfBinding = class
  public
    m_sSource: string;
    m_sTarget: string;
    m_sRole: string;
    m_sAssociation: string;
    m_iRoleType: Integer;
    constructor Create(sSource, sTarget, sRole, sAssociation: string; iRoleType: Integer); overload;
    constructor Create(other: TRoleTypeOfBinding); overload;
  end;

  TRoleTypesOfBindings = class(TMyObjectList)
    function GetKeyByIndex(index: Integer): string; override;
    function GetRoleTypeOfBinding(sSource, sTarget, sRole: string): Integer;
    function GetItem(sSource, sTarget, sRole: string): TRoleTypeOfBinding;
  end;

  TPermittedPrimitive = record
    code: Integer;
    name: string;
    description: string;
    id: Integer;
  end;

  TFeatureItem = class(TFeatureOrInfoItem)
    featureBindings: array of TFeatureBinding;
    featureUseType: string;
    permittedPrimitives: array of TPermittedPrimitive;
  end;

  TCRSDescription = record
    crsType: string;          // Тип референцной системы координат
    crsDimension: Integer;    // Размерность референцной системы координат
    csType: Integer;          // Тип системы координат:
                              //    1 - эллипсоидальная
                              //    2 - декартова
                              //    3 - вертикальная
    crsAxes: array[0..2] of string; // Оси координат референцной системы
    datumType: string;        // Тип датума
    crstValue: Integer;       // Индекс CRS
  end;

  TSupportedCRSs = array of TCRSDescription;

  TProjectionDescription = record
    projName: string;
    projMethod: Integer;
    projParam1: string;
    projParam2: string;
    projParam3: string;
    projParam4: string;
    projParam5: string;
    codeEPSG: Integer;
  end;

  TSupportedProjections = array of TProjectionDescription;

  TAxisDescription = record
    axisType: string;       // Тип оси координат
    axisDirection: string;  // Направление оси координат
    axtyValue: Integer;     // Код типа оси координат
  end;

  TSupportedAxes = array of TAxisDescription;

  TS101Catalogue = class
  public
    function ReadFromJSON(fileName, logName: string): Boolean;
    function ReadAllAcronymPairs(dirName: string): Boolean;
    function ReadAcronymPairsFromFile(fileName: string): Boolean;
    function ReadSupportedCRSs(fileName: string): Boolean;
    function ReadSupportedAxes(fileName: string): Boolean;
    function ReadSupportedProjections(fileName: string): Boolean;
    function ReadTopicCategories(fileName: string): Boolean;
    function ReadCSVFile(fileName: string; fieldTypes: array of string;
        var outArray: Pointer): Integer;
    function FillAcronymsDescendants: Boolean;
    function FillRoleTypesOfBindings: Boolean;
    function InheritAttributes: Boolean;
  public
    name: string;
    producer: string;
    scope: string;
    versionDate: TDate;
    versionNumber: string;
    items: TCatalogueItems;
    acronymPairs: TAcronymPairs;
    supportedCRSs: TSupportedCRSs;
    supportedAxes: TSupportedAxes;
    supportedProjections: TSupportedProjections;
    acronymsDescendants: TAcronymsDescendants;
    roleTypesOfBindings: TRoleTypesOfBindings;
    topicCategories: TTopicCategories;
  end;

function CompareCatalogueItems(Item1, Item2: Pointer): Integer;
function CompareAcronymsDescendants(Item1, Item2: Pointer): Integer;
function CompareRoleTypesOfBindings(Item1, Item2: Pointer): Integer;

implementation

//uses
//  MyS101ReaderFormUnit;

// --------------------- TS101Catalogue ---------------------

function ImportAttributesFromJSON(jlAttributes: TlkJSONlist;
    var attributes: TAttributeRefArray; var sError: string): Boolean;
var
  iAttribute, iAllowedValue: Integer;
  jsAttribute, jsMultiplicity: TlkJSONobject;
  jlAllowedValues: TlkJSONlist;
  bError: Boolean;
begin
  Result := False;
  sError := '';
  bError := False;
  SetLength(attributes, jlAttributes.Count);
  for iAttribute := 0 to jlAttributes.Count - 1 do begin
    jsAttribute := jlAttributes.Field[iAttribute] as TlkJSONobject;
    attributes[iAttribute].sCode := jsAttribute.Field['code'].Value;
    jsMultiplicity := jsAttribute.Field['multiplicity'] as TlkJSONobject;
    if (jsMultiplicity.Field['lower'] = nil) or (jsMultiplicity.Field['upper'] = nil) then begin
      sError := sError + 'Не задана множественность атрибута ' +
          attributes[iAttribute].sCode + #10;
      bError := True;
    end
    else begin
      attributes[iAttribute].multiplicity.lower := jsMultiplicity.Field['lower'].Value;
      if VarType(jsMultiplicity.Field['upper'].Value) = varOleStr then begin
        if jsMultiplicity.Field['upper'].Value = '*' then
          attributes[iAttribute].multiplicity.upper := -1;
      end
      else
        attributes[iAttribute].multiplicity.upper := jsMultiplicity.Field['upper'].Value;
    end;
    attributes[iAttribute].bSequential := jsAttribute.Field['sequential'].Value;
    attributes[iAttribute].bVoidable := jsAttribute.Field['voidable'].Value;
    jlAllowedValues := jsAttribute.Field['allowedValues'] as TlkJSONlist;
    if (jlAllowedValues <> nil) and (jlAllowedValues.Count > 0) then begin
      SetLength(attributes[iAttribute].allowedValues, jlAllowedValues.Count);
      for iAllowedValue := 0 to jlAllowedValues.Count - 1 do
        attributes[iAttribute].allowedValues[iAllowedValue] :=
            jlAllowedValues.getInt(iAllowedValue);
    end;
  end;
  Result := not bError;
end;

type
  TAttributeValueConstraintArray = array of TAttributeValueConstraint;

function ImportAttributeValueConstraintsFromJSON(jlAttributeValueConstraints: TlkJSONlist;
    var attributeValueConstraints: TAttributeValueConstraintArray; var sError: string): Boolean;
var
  bError: Boolean;
  jsAttributeValueConstraint: TlkJSONobject;
  iAttributeValueConstraint: Integer;
begin
  Result := False;
  sError := '';
  bError := False;
  SetLength(attributeValueConstraints, jlAttributeValueConstraints.Count);
  for iAttributeValueConstraint := 0 to jlAttributeValueConstraints.Count - 1 do begin
    jsAttributeValueConstraint := jlAttributeValueConstraints.Field[iAttributeValueConstraint] as TlkJSONobject;
    attributeValueConstraints[iAttributeValueConstraint].sValidationRule :=
        jsAttributeValueConstraint.Field['validationRule'].Value;
    if (jsAttributeValueConstraint.Field['description'] <> nil) and
        (jsAttributeValueConstraint.Field['description'].Value <> variants.Null) then
      attributeValueConstraints[iAttributeValueConstraint].sDescription :=
          jsAttributeValueConstraint.Field['description'].Value;
  end;
  Result := not bError;
end;

function ImportBindingFromJSON(jsBinding: TlkJSONobject; var binding: TBinding;
    var sError: string): Boolean;
var
  bError: Boolean;
  jsMultiplicity: TlkJSONobject;
  jlAttributeValueConstraints: TlkJSONlist;
  sValue: string;
begin
  Result := False;
  sError := '';
  bError := False;
  if jsBinding.Field['association'].Value  <> variants.Null then
    binding.association := jsBinding.Field['association'].Value;
  jsMultiplicity := jsBinding.Field['multiplicity'] as TlkJSONobject;
  binding.multiplicity.lower := jsMultiplicity.Field['lower'].Value;
  if VarType(jsMultiplicity.Field['upper'].Value) = varOleStr then begin
    if jsMultiplicity.Field['upper'].Value = '*' then
      binding.multiplicity.upper := -1;
  end
  else
    binding.multiplicity.upper := jsMultiplicity.Field['upper'].Value;
  binding.role := jsBinding.Field['role'].Value;
  sValue := jsBinding.Field['roletype'].Value;
  if sValue = 'association' then
    binding.roletype := 0
  else if sValue = 'aggregation' then
    binding.roletype := 1
  else if sValue = 'composition' then
    binding.roletype := 2
  else begin
    sError := sError + 'Недопустимый тип роли ' + sValue + #10;
    bError := True;
  end;
  binding.targetFeature := jsBinding.Field['targetFeature'].Value;
  jlAttributeValueConstraints := jsBinding.Field['attributeValueConstraints'] as TlkJSONlist;
  if not ImportAttributeValueConstraintsFromJSON(jlAttributeValueConstraints,
      TAttributeValueConstraintArray(binding.attributeValueConstraints), sError) then begin
    sError := 'Ошибки в атрибутивных ограничениях:'#10 + sError;
    bError := True;
  end;
  Result := not bError;
end;

function TS101Catalogue.InheritAttributes: Boolean;
var
  iItem, iAttribute, iParentAttribute, iValue: Integer;
  objectItem, parentItem: TObjectItem;
begin
  Result := False;
  if (items = nil) or (items.Count = 0) then
    Exit;
  for iItem := 0 to items.Count - 1 do begin
    if items[iItem] is TObjectItem then begin
      objectItem := items[iItem] as TObjectItem;
      parentItem := objectItem;
      while parentItem.sParent <> '' do begin
        parentItem := items.GetItemByName(parentItem.sParent) as TObjectItem;
        iAttribute := Length(objectItem.attributes);
        SetLength(objectItem.attributes, Length(objectItem.attributes) + Length(parentItem.attributes));
        for iParentAttribute := 0 to Length(parentItem.attributes) - 1 do begin
          with parentItem.attributes[iParentAttribute] do begin
            objectItem.attributes[iAttribute].sCode := sCode;
            objectItem.attributes[iAttribute].multiplicity.lower := multiplicity.lower;
            objectItem.attributes[iAttribute].multiplicity.upper := multiplicity.upper;
            objectItem.attributes[iAttribute].bSequential := bSequential;
            objectItem.attributes[iAttribute].bVoidable := bVoidable;
            SetLength(objectItem.attributes[iAttribute].allowedValues, Length(allowedValues));
            for iValue := 0 to Length(allowedValues) - 1 do
              objectItem.attributes[iAttribute].allowedValues[iValue] := allowedValues[iValue];
          end;
          iAttribute := iAttribute + 1;
        end;
      end;
    end;
  end;
  Result := True;
end;

function TS101Catalogue.ReadFromJSON(fileName, logName: string): Boolean;
var
  fs, logs: TFileStream;
  size: Integer;
  buffer: array of Char;
  jsCatalogue, jsItem, jsListedValue: TlkJSONobject;
  jsInformationBinding, jsFeatureBinding, jsPermittedPrimitive: TlkJSONobject;
  jsTopologicConstraint: TlkJSONobject;
  jlItems, jlListedValues, jlChildren, jlAttributeValueConstraints: TlkJSONlist;
  jlAttributes, jlInformationBindings, jlFeatureBindings, jlPermittedPrimitives: TlkJSONlist;
  jlTopologicConstraints: TlkJSONlist;
  iYear, iMonth, iDay, code, iItem, iListedValue, iChild, iAllowedValue: Integer;
  iInformationBinding, iFeatureBinding: Integer;
  iPermittedPrimitive, iTopologicConstraint: Integer;
  sDate, sCode, sValue, sError: string;
  item: TItem;
  binding: TBinding;
  featureBinding: TFeatureBinding;
  bError: Boolean;
begin
  Result := False;
  if (fileName = '') or not FileExists(fileName) then Exit;
  if logName = '' then Exit;
  bError := False;
  logs := TFileStream.Create(logName, fmCreate);
  fs := TFileStream.Create(fileName, fmOpenRead	or fmShareDenyWrite);
  size := fs.Seek(0, soFromEnd);
  SetLength(buffer, size + 1);
  fs.Seek(0, soFromBeginning);
  fs.Read(buffer[0], size);
  buffer[size] := #0;
  fs.Free;
  jsCatalogue := TlkJSONobject(TlkJSON.ParseText(PChar(buffer)));
  name := jsCatalogue.Field['name'].Value;
  producer := jsCatalogue.Field['producer'].Value;
  scope := jsCatalogue.Field['scope'].Value;
  sDate := jsCatalogue.Field['versionDate'].Value;
  if sDate <> '' then begin
    Val(sDate, iYear, code);
    Val(PChar(@sDate[6]), iMonth, code);
    Val(PChar(@sDate[9]), iDay, code);
    versionDate := EncodeDateTime(iYear, iMonth, iDay, 0, 0, 0, 0);
  end;
  versionNumber := jsCatalogue.Field['versionNumber'].Value;
  jlItems := jsCatalogue.Field['items'] as TlkJSONlist;
  items := TCatalogueItems.Create;
  items.Capacity := jlItems.Count;
  for iItem := 0 to jlItems.Count - 1 do begin
    jsItem := jlItems.Field[iItem] as TlkJSONobject;
    sCode := jsItem.NameOf[0];
    jsItem := jsItem.FieldByIndex[0] as TlkJSONobject;
    if jsItem.Field['name'] <> nil then begin
      if jsItem.Field['type'].Value = 'Attribute' then
        item := TAttributeItem.Create
      else if jsItem.Field['type'].Value = 'ComplexAttribute' then
        item := TComplexAttributeItem.Create
      else if jsItem.Field['type'].Value = 'Role' then
        item := TRoleItem.Create
      else if jsItem.Field['type'].Value = 'InformationAssociation' then
        item := TAssociationItem.Create
      else if jsItem.Field['type'].Value = 'FeatureAssociation' then
        item := TAssociationItem.Create
      else if jsItem.Field['type'].Value = 'Information' then
        item := TFeatureOrInfoItem.Create
      else if jsItem.Field['type'].Value = 'Feature' then
        item := TFeatureItem.Create
      else
        item := TNamedItem.Create;
      if (jsItem.Field['definition'] <> nil) and (jsItem.Field['definition'].Value <> variants.Null) then
        TNamedItem(item).sDefinition := jsItem.Field['definition'].Value;
      if (jsItem.Field['definitionSourceIdentifier'] <> nil) and
          (jsItem.Field['definitionSourceIdentifier'].Value <> variants.Null) then
        TNamedItem(item).sDefinitionSourceIdentifier := jsItem.Field['definitionSourceIdentifier'].Value;
      if (jsItem.Field['citationTitle'] <> nil) and (jsItem.Field['citationTitle'].Value <> variants.Null) then
        TNamedItem(item).sCitationTitle := jsItem.Field['citationTitle'].Value;
      TNamedItem(item).sName := jsItem.Field['name'].Value;
      TNamedItem(item).sType := jsItem.Field['type'].Value;
      if item is TAttributeItem then begin
        if (jsItem.Field['uom'] <> nil) and (jsItem.Field['uom'].Value <> variants.Null) then
          TAttributeItem(item).sUom := jsItem.Field['uom'].Value;
        if (jsItem.Field['quantitySpecification'] <> nil) and
            (jsItem.Field['quantitySpecification'].Value <> variants.Null) then
          TAttributeItem(item).sQuantitySpecification := jsItem.Field['quantitySpecification'].Value;
        TAttributeItem(item).sValueType := jsItem.Field['valueType'].Value;
        if TAttributeItem(item).sValueType = 'enumeration' then begin
          jlListedValues := jsItem.Field['listedValues'] as TlkJSONlist;
          if (jlListedValues <> nil) and (jlListedValues.Count > 0) then begin
            SetLength(TAttributeItem(item).lListedValues, jlListedValues.Count);
            for iListedValue := 0 to jlListedValues.Count - 1 do begin
              jsListedValue := jlListedValues.Field[iListedValue] as TlkJSONobject;
              TAttributeItem(item).lListedValues[iListedValue].iCode :=
                  jsListedValue.Field['code'].Value;
              TAttributeItem(item).lListedValues[iListedValue].sLabel :=
                  jsListedValue.Field['label'].Value;
              if (jsListedValue.Field['definition'] <> nil) and
                  (jsListedValue.Field['definition'].Value <> variants.Null) then
                TAttributeItem(item).lListedValues[iListedValue].sDefinition :=
                    jsListedValue.Field['definition'].Value;
            end;
          end;
        end;
      end
      else if item is TComplexAttributeItem then begin
        jlChildren := jsItem.Field['children'] as TlkJSONlist;
        if not ImportAttributesFromJSON(jlChildren,
            TAttributeRefArray(TComplexAttributeItem(item).children), sError) then begin
          sError := 'Ошибки в дочерних атрибутах составного атрибута ' + sCode + ':'#10 + sError;
          logs.Write(PChar(sError)^, Length(sError));
          bError := True;
        end;
        jlAttributeValueConstraints := jsItem.Field['attributeValueConstraints'] as TlkJSONlist;
        if not ImportAttributeValueConstraintsFromJSON(jlAttributeValueConstraints,
            TAttributeValueConstraintArray(TComplexAttributeItem(item).attributeValueConstraints),
            sError) then begin
          sError := 'Ошибки в атрибутивных ограничениях составного атрибута ' + sCode + ':'#10 + sError;
          logs.Write(PChar(sError)^, Length(sError));
          bError := True;
        end;
      end
      else if item is TRoleItem then begin
        TRoleItem(item).isAbstract := jsItem.Field['isAbstract'].Value;
      end
      else if item is TObjectItem then begin
        jlAttributes := jsItem.Field['attributes'] as TlkJSONlist;
        if not ImportAttributesFromJSON(jlAttributes,
            TAttributeRefArray(TObjectItem(item).attributes), sError) then begin
          sError := 'Ошибки в атрибутах класса ' + sCode + ':'#10 + sError;
          logs.Write(PChar(sError)^, Length(sError));
          bError := True;
        end;
        jlAttributeValueConstraints := jsItem.Field['attributeValueConstraints'] as TlkJSONlist;
        if not ImportAttributeValueConstraintsFromJSON(jlAttributeValueConstraints,
            TAttributeValueConstraintArray(TObjectItem(item).attributeValueConstraints),
            sError) then begin
          sError := 'Ошибки в атрибутивных ограничениях класса ' + sCode + ':'#10 + sError;
          logs.Write(PChar(sError)^, Length(sError));
          bError := True;
        end;
        TObjectItem(item).isAbstract := jsItem.Field['isAbstract'].Value;
        TObjectItem(item).sParent := jsItem.Field['parent'].Value;
        if item is TAssociationItem then begin
          TAssociationItem(item).sRole1 := jsItem.Field['role1'].Value;
          TAssociationItem(item).sRole2 := jsItem.Field['role2'].Value;
        end
        else if item is TFeatureOrInfoItem then begin
          jlInformationBindings := jsItem.Field['informationBindings'] as TlkJSONlist;
          SetLength(TFeatureOrInfoItem(item).informationBindings, jlInformationBindings.Count);
          for iInformationBinding := 0 to jlInformationBindings.Count - 1 do begin
            jsInformationBinding := jlInformationBindings.Field[iInformationBinding] as TlkJSONobject;
            binding := TBinding.Create;
            if not ImportBindingFromJSON(jsInformationBinding, binding, sError) then begin
              sError := 'Ошибки в связи ' + binding.role + ':'#10 + sError;
              logs.Write(PChar(sError)^, Length(sError));
              bError := True;
            end;
            TFeatureOrInfoItem(item).informationBindings[iInformationBinding] := binding;
          end;
          if item is TFeatureItem then begin
            jlFeatureBindings := jsItem.Field['featureBindings'] as TlkJSONlist;
            SetLength(TFeatureItem(item).featureBindings, jlFeatureBindings.Count);
            for iFeatureBinding := 0 to jlFeatureBindings.Count - 1 do begin
              jsFeatureBinding := jlFeatureBindings.Field[iFeatureBinding] as TlkJSONobject;
              featureBinding := TFeatureBinding.Create;
              if not ImportBindingFromJSON(jsFeatureBinding, TBinding(featureBinding), sError) then begin
                sError := 'Ошибки в связи ' + featureBinding.role + ':'#10 + sError;
                logs.Write(PChar(sError)^, Length(sError));
                bError := True;
              end;
              jlTopologicConstraints := jsFeatureBinding.Field['topologicConstraints'] as TlkJSONlist;
              SetLength(featureBinding.topologicConstraints, jlTopologicConstraints.Count);
              for iTopologicConstraint := 0 to jlTopologicConstraints.Count - 1 do begin
                jsTopologicConstraint := jlTopologicConstraints.Field[iTopologicConstraint] as TlkJSONobject;
                with featureBinding.topologicConstraints[iTopologicConstraint] do begin
                  sValue := jsTopologicConstraint.Field['sourceGeom'].Value;
                  if sValue = 'Point' then
                    sourceGeom := 0
                  else if sValue = 'Curve' then
                    sourceGeom := 1
                  else if sValue = 'Surface' then
                    sourceGeom := 2
                  else
                    sourceGeom := -1;
                  sValue := jsTopologicConstraint.Field['targetGeom'].Value;
                  if sValue = 'Point' then
                    targetGeom := 0
                  else if sValue = 'Curve' then
                    targetGeom := 1
                  else if sValue = 'Surface' then
                    targetGeom := 2
                  else
                    targetGeom := -1;
                  topologicRule := jsTopologicConstraint.Field['topologicRule'].Value;
                  if (jsTopologicConstraint.Field['description'] <> nil) and
                      (jsTopologicConstraint.Field['description'].Value <> variants.Null) then
                    description := jsTopologicConstraint.Field['description'].Value;
                end;
              end;
              TFeatureItem(item).featureBindings[iFeatureBinding] := featureBinding;
            end;
            TFeatureItem(item).featureUseType := jsItem.Field['featureUseType'].Value;
            jlPermittedPrimitives := jsItem.Field['permittedPrimitives'] as TlkJSONlist;
            SetLength(TFeatureItem(item).permittedPrimitives, jlPermittedPrimitives.Count);
            for iPermittedPrimitive := 0 to jlPermittedPrimitives.Count - 1 do begin
              jsPermittedPrimitive := jlPermittedPrimitives.Field[iPermittedPrimitive] as TlkJSONobject;
              with TFeatureItem(item).permittedPrimitives[iPermittedPrimitive] do begin
                code := jsPermittedPrimitive.Field['Code'].Value;
                name := jsPermittedPrimitive.Field['Name'].Value;
                if jsPermittedPrimitive.Field['Description'].Value <> variants.Null then
                  description := jsPermittedPrimitive.Field['Description'].Value;
                id := jsPermittedPrimitive.Field['Id'].Value;
              end;
            end;
          end;
        end;
      end;
    end
    else
      item := TItem.Create;
    item.sCode := sCode;
    items.Add(item);
  end;
  if not bError then begin
    items.Sort(CompareCatalogueItems);
    InheritAttributes;
    sError := 'Каталог успешно загружен'#10;
    logs.Write(PChar(sError)^, Length(sError));
  end;
  Result := not bError;
end;

function TS101Catalogue.ReadAcronymPairsFromFile(fileName: string): Boolean;
var
  fs: TFileStream;
  bufLen, bytesRead, nLines, iLine, code, iStart, iStop: Integer;
  pcBuffer: array of Char;
  sLines: TStrings;
  acronymPair: TAcronymPair;
begin
  Result := False;
  if (fileName = '') or not FileExists(fileName) then Exit;
  fs := TFileStream.Create(fileName, fmOpenRead	or fmShareDenyWrite);
  bufLen := fs.Seek(0, soFromEnd);
  SetLength(pcBuffer, bufLen + 1);
  ZeroMemory(pcBuffer, bufLen + 1);
  fs.Seek(0, soFromBeginning);
  bytesRead := fs.Read(PChar(pcBuffer)^, bufLen);
  fs.Free;
  if bytesRead <> bufLen then Exit;
  sLines := TStringList.Create;
  nLines := ExtractStrings([], [], PChar(pcBuffer), sLines);
  acronymPairs.Capacity := acronymPairs.Count + nLines;
  for iLine := 0 to nLines - 1 do begin
    acronymPair := TAcronymPair.Create;
    iStart := 1;
    iStop := PosEx(';', sLines[iLine], iStart);
    acronymPair.theirAcronym := MidStr(sLines[iLine], iStart, iStop - iStart);
    iStart := iStop + 1;
    iStop := Length(sLines[iLine]) + 1;
    acronymPair.ourAcronym := MidStr(sLines[iLine], iStart, iStop - iStart);
    acronymPairs.Add(acronymPair);
  end;
  sLines.Free;
  SetLength(pcBuffer, 0);
  Result := True;
end;

const fileNames: array[0..7] of string = (
  'Associations',
  'Attributes',
  'ComplexAttributes',
  'Features',
  'InfoTypes',
  'MetaAttributes',
  'MetadataFeatures',
  'Roles'
);

function TS101Catalogue.ReadAllAcronymPairs(dirName: string): Boolean;
var
  i: Integer;
  s: string;
begin
  Result := False;
  if (dirName = '') or not DirectoryExists(dirName) then Exit;
  if acronymPairs = nil then
    acronymPairs := TAcronymPairs.Create;
  acronymPairs.Clear;
  for i := 0 to Length(fileNames) - 1 do
    if not ReadAcronymPairsFromFile(dirName + fileNames[i] + '.csv') then Exit;
  if not FillAcronymsDescendants then Exit;
  if not FillRoleTypesOfBindings then Exit;
  Result := True;
end;

const crsFieldTypes: array[0..7] of string = ('string', 'Integer', 'Integer',
    'string', 'string', 'string', 'string', 'Integer');

function TS101Catalogue.ReadSupportedCRSs(fileName: string): Boolean;
var
  nLines: Integer;
begin
  nLines := ReadCSVFile(fileName, crsFieldTypes, Pointer(supportedCRSs));
  if nLines > 0 then
    SetLength(supportedCRSs, nLines);
  Result := nLines > 0;
end;

const axesFieldTypes: array[0..2] of string = ('string', 'string', 'Integer');

function TS101Catalogue.ReadSupportedAxes(fileName: string): Boolean;
var
  nLines: Integer;
begin
  nLines := ReadCSVFile(fileName, axesFieldTypes, Pointer(supportedAxes));
  if nLines > 0 then
    SetLength(supportedAxes, nLines);
  Result := nLines > 0;
end;

const projFieldTypes: array[0..7] of string = ('string', 'Integer', 'string',
    'string', 'string', 'string', 'string', 'Integer');

function TS101Catalogue.ReadSupportedProjections(fileName: string): Boolean;
var
  nLines: Integer;
begin
  nLines := ReadCSVFile(fileName, projFieldTypes, Pointer(supportedProjections));
  if nLines > 0 then
    SetLength(supportedProjections, nLines);
  Result := nLines > 0;
end;

const topicCategoriesTypes: array[0..1] of string = ('Integer', 'string');

function TS101Catalogue.ReadTopicCategories(fileName: string): Boolean;
var
  nLines: Integer;
begin
  nLines := ReadCSVFile(fileName, topicCategoriesTypes, Pointer(topicCategories));
  if nLines > 0 then
    SetLength(topicCategories, nLines);
  Result := nLines > 0;
end;

const emptyStr = 'empty';

function TS101Catalogue.ReadCSVFile(fileName: string; fieldTypes: array of string;
    var outArray: Pointer): Integer;
var
  tfCSV: TextFile;
  sLine, sLineMod: string;
  sValues: TStrings;
  iStart, iStop, nValues, i, recSize, code, nLines: Integer;
  curP: Pointer;
  pInt: PInteger;
  pStr: PString;
begin
  Result := 0;
  if (fileName = '') or not FileExists(fileName) then
    Exit;
  nLines := 0;
  AssignFile(tfCSV, fileName);
  Reset(tfCSV);
  while not Eof(tfCSV) do begin
    ReadLn(tfCSV, sLine);
    if sLine = '' then
      Continue;
    nLines := nLines + 1;
  end;
  CloseFile(tfCSV);
  if nLines = 0 then
    Exit;
  Reset(tfCSV);
  recSize := 0;
  for i := 0 to Length(fieldTypes) - 1 do
    if fieldTypes[i] = 'string' then
      recSize := recSize + sizeof(PChar)
    else if fieldTypes[i] = 'Integer' then
      recSize := recSize + sizeof(Integer);
  outArray := AllocMem(recSize * nLines);
  sValues := TStringList.Create;
  curP := outArray;
  while not Eof(tfCSV) do begin
    ReadLn(tfCSV, sLine);
    if sLine = '' then
      Continue;
    sLineMod := '';
    iStart := 1;
    while True do begin
      iStop := PosEx(';', sLine, iStart);
      if iStop = 0 then
        iStop := Length(sLine) + 1;
      if iStop = iStart then
        sLineMod := sLineMod + emptyStr
      else
        sLineMod := sLineMod + MidStr(sLine, iStart, iStop - iStart);
      if iStop <= Length(sLine) then
        sLineMod := sLineMod + ';';
      if iStop = Length(sLine) then
        sLineMod := sLineMod + emptyStr;
      if iStop >= Length(sLine) then
        Break;
      iStart := iStop + 1;
    end;
    sValues.Clear;
    nValues := ExtractStrings([';'], [], PChar(sLineMod), sValues);
    if nValues <> Length(fieldTypes) then
      Exit;
    for i := 0 to nValues - 1 do begin
      if sValues[i] = emptyStr then
        sValues[i] := '';
      if fieldTypes[i] = 'string' then begin
        pStr := PString(curP);
        pStr^ := sValues[i];
        curP := PChar(curP) + sizeof(PChar);
      end
      else if fieldTypes[i] = 'Integer' then begin
        pInt := PInteger(curP);
        Val(sValues[i], pInt^, code);
        if code <> 0 then
          Exit;
        curP := PChar(curP) + sizeof(Integer);
      end
      else
        Exit;
    end;
  end;
  CloseFile(tfCSV);
  sValues.Free;
  Result := nLines;
end;

function TS101Catalogue.FillAcronymsDescendants: Boolean;
var
  iItem, i, ii: Integer;
  sParent: string;
  featureOrInfoItem, curFeatureOrInfoItem: TFeatureOrInfoItem;
  acronymDescendants: TAcronymDescendants;
begin
  Result := False;
  if acronymsDescendants = nil then
    acronymsDescendants := TAcronymsDescendants.Create
  else
    acronymsDescendants.Clear;
  for iItem := 0 to items.Count - 1 do begin
    if items[iItem] is TFeatureOrInfoItem then begin
      featureOrInfoItem := items[iItem] as TFeatureOrInfoItem;
      if acronymPairs.GetTheirByOur(featureOrInfoItem.sCode) <> '' then begin
        curFeatureOrInfoItem := featureOrInfoItem;
        while curFeatureOrInfoItem.sParent <> '' do begin
          acronymsDescendants.AddDescendant(curFeatureOrInfoItem.sParent, featureOrInfoItem.sCode);
          curFeatureOrInfoItem := items.GetItemByName(curFeatureOrInfoItem.sParent) as TFeatureOrInfoItem;
        end;
      end;
    end;
  end;
  acronymsDescendants.Sort(CompareAcronymsDescendants);
  Result := True;
end;

function TS101Catalogue.FillRoleTypesOfBindings: Boolean;
var
  iItem, iBinding, iDescendant, i: Integer;
  featureOrInfoItem, curFeatureOrInfoItem: TFeatureOrInfoItem;
  curFeatureItem: TFeatureItem;
  binding: TBinding;
  roleTypeOfBinding: TRoleTypeOfBinding;
  descendants: TStrings;
begin
  Result := False;
  if roleTypesOfBindings = nil then
    roleTypesOfBindings := TRoleTypesOfBindings.Create
  else
    roleTypesOfBindings.Clear;
  for iItem := 0 to items.Count - 1 do begin
    if items[iItem] is TFeatureOrInfoItem then begin
      featureOrInfoItem := items[iItem] as TFeatureOrInfoItem;
      if acronymPairs.GetTheirByOur(featureOrInfoItem.sCode) <> '' then begin
        curFeatureOrInfoItem := featureOrInfoItem;
        repeat
          for iBinding := 0 to Length(curFeatureOrInfoItem.informationBindings) - 1 do begin
            binding := curFeatureOrInfoItem.informationBindings[iBinding];
            if acronymPairs.GetTheirByOur(binding.targetFeature) <> '' then begin
              roleTypeOfBinding := TRoleTypeOfBinding.Create(featureOrInfoItem.sCode,
                  binding.targetFeature, binding.role, binding.association, binding.roletype);
              roleTypesOfBindings.Add(roleTypeOfBinding);
            end
            else begin
              descendants := acronymsDescendants.GetDescendantsOfParent(binding.targetFeature);
              if descendants <> nil then
                for iDescendant := 0 to descendants.Count - 1 do begin
                  roleTypeOfBinding := TRoleTypeOfBinding.Create(featureOrInfoItem.sCode,
                      descendants[iDescendant], binding.role, binding.association, binding.roletype);
                  roleTypesOfBindings.Add(roleTypeOfBinding);
                end;
            end;
          end;
          if curFeatureOrInfoItem is TFeatureItem then begin
            curFeatureItem := curFeatureOrInfoItem as TFeatureItem;
            for iBinding := 0 to Length(curFeatureItem.featureBindings) - 1 do begin
              binding := curFeatureItem.featureBindings[iBinding];
              if acronymPairs.GetTheirByOur(binding.targetFeature) <> '' then begin
                roleTypeOfBinding := TRoleTypeOfBinding.Create(featureOrInfoItem.sCode,
                    binding.targetFeature, binding.role, binding.association, binding.roletype);
                roleTypesOfBindings.Add(roleTypeOfBinding);
              end
              else begin
                descendants := acronymsDescendants.GetDescendantsOfParent(binding.targetFeature);
                if descendants <> nil then
                  for iDescendant := 0 to descendants.Count - 1 do begin
                    roleTypeOfBinding := TRoleTypeOfBinding.Create(featureOrInfoItem.sCode,
                        descendants[iDescendant], binding.role, binding.association, binding.roletype);
                    roleTypesOfBindings.Add(roleTypeOfBinding);
                  end;
              end;
            end;
          end;
          if curFeatureOrInfoItem.sParent = '' then
            Break;
          curFeatureOrInfoItem := items.GetItemByName(curFeatureOrInfoItem.sParent) as TFeatureOrInfoItem
        until False;
      end;
    end;
  end;
  roleTypesOfBindings.Sort(CompareRoleTypesOfBindings);
  Result := True;
end;

// --------------------- TCatalogueItems ---------------------

function TCatalogueItems.GetKeyByIndex(index: Integer): string;
begin
  Result := TItem(Self[index]).sCode;
end;

function TCatalogueItems.GetItemByName(sName: string): TItem;
var
  index: Integer;
begin
  index := GetIndexByKey(sName);
  if index >= 0 then
    Result := Self[index] as TItem
  else
    Result := nil;
end;

function CompareCatalogueItems(Item1, Item2: Pointer): Integer;
var
  catalogueItem1, catalogueItem2: TItem;
begin
  catalogueItem1 := TItem(Item1);
  catalogueItem2 := TItem(Item2);
  Result := CompareStr(catalogueItem1.sCode, catalogueItem2.sCode);
end;

// --------------------- TAcronymPairs ---------------------

constructor TAcronymPairs.Create(acronymKey: TAcronymKey = KEY_THEIR);
begin
  m_AcronymKey := acronymKey;
end;

function TAcronymPairs.GetKeyByIndex(index: Integer): string;
begin
  if m_AcronymKey = KEY_THEIR then
    Result := TAcronymPair(Self[index]).theirAcronym
  else
    Result := TAcronymPair(Self[index]).ourAcronym;
end;

function CompareByTheir(Item1, Item2: Pointer): Integer;
var
  pair1, pair2: TAcronymPair;
begin
  pair1 := TAcronymPair(Item1);
  pair2 := TAcronymPair(Item2);
  Result := CompareStr(pair1.theirAcronym, pair2.theirAcronym);
end;

function CompareByOur(Item1, Item2: Pointer): Integer;
var
  pair1, pair2: TAcronymPair;
begin
  pair1 := TAcronymPair(Item1);
  pair2 := TAcronymPair(Item2);
  Result := CompareStr(pair1.ourAcronym, pair2.ourAcronym);
end;

procedure TAcronymPairs.SortByTheir;
begin
  Sort(CompareByTheir);
  m_AcronymKey := KEY_THEIR;
end;

procedure TAcronymPairs.SortByOur;
begin
  Sort(CompareByOur);
  m_AcronymKey := KEY_OUR;
end;

function TAcronymPairs.GetIndexByTheir(their: string): Integer;
begin
  Result := -1;
  if Count = 0 then Exit;
  if m_AcronymKey <> KEY_THEIR then
    SortByTheir;
  Result := GetIndexByKey(their);
end;

function TAcronymPairs.GetIndexByOur(our: string): Integer;
begin
  Result := -1;
  if Count = 0 then Exit;
  if m_AcronymKey <> KEY_OUR then
    SortByOur;
  Result := GetIndexByKey(our);
end;

{
function TAcronymPairs.GetOurByTheir(their: string): string;
var
  index: Integer;
begin
  index := GetIndexByTheir(their);
  if index < 0 then begin
    Result := their + g_unknownAcronymMarker;
    Exit;
  end;
  Result := (Self[index] as TAcronymPair).ourAcronym;
end;

function TAcronymPairs.GetTheirByOur(our: string): string;
var
  index: Integer;
begin
  Result := '';
  index := GetIndexByOur(our);
  if index < 0 then begin
    //Result := our + g_unknownAcronymMarker;
    Exit;
  end;
  Result := (Self[index] as TAcronymPair).theirAcronym;
end;
}

function TAcronymPairs.GetOurByTheir(their: string): string;
begin
  Result := their;
end;

function TAcronymPairs.GetTheirByOur(our: string): string;
begin
  Result := our;
end;

// --------------------- TAcronymsDescendants ---------------------

constructor TAcronymDescendants.Create(sParent: string);
begin
  m_sParent := sParent;
  m_ssDescendants := TStringList.Create;
end;

function TAcronymsDescendants.GetKeyByIndex(index: Integer): string;
begin
  Result := TAcronymDescendants(Self[index]).m_sParent;
end;

function TAcronymsDescendants.AddDescendant(sParent, sDescendant: string): Boolean;
var
  iParent, iDescendant: Integer;
  acronymDescendants: TAcronymDescendants;
begin
  Result := False;
  for iParent := 0 to Count - 1 do begin
    acronymDescendants := Self[iParent] as TAcronymDescendants;
    if acronymDescendants.m_sParent = sParent then
    begin
      for iDescendant := 0 to acronymDescendants.m_ssDescendants.Count - 1 do
        if acronymDescendants.m_ssDescendants[iDescendant] = sDescendant then
          Exit;
      Result := acronymDescendants.m_ssDescendants.Add(sDescendant) >= 0;
      Exit;
    end;
  end;
  acronymDescendants := TAcronymDescendants.Create(sParent);
  acronymDescendants.m_ssDescendants.Add(sDescendant);
  Result := Add(acronymDescendants) >= 0;
end;

function TAcronymsDescendants.GetDescendantsOfParent(sParent: string): TStrings;
var
  index: Integer;
begin
  index := GetIndexByKey(sParent);
  if index >= 0 then
    Result := TAcronymDescendants(Self[index]).m_ssDescendants
  else
    Result := nil;
end;

function CompareAcronymsDescendants(Item1, Item2: Pointer): Integer;
var
  acronymDescendantsItem1, acronymDescendantsItem2: TAcronymDescendants;
begin
  acronymDescendantsItem1 := TAcronymDescendants(Item1);
  acronymDescendantsItem2 := TAcronymDescendants(Item2);
  Result := CompareStr(acronymDescendantsItem1.m_sParent, acronymDescendantsItem2.m_sParent);
end;

// --------------------- TRoleTypeOfBinding ---------------------

constructor TRoleTypeOfBinding.Create(sSource, sTarget, sRole, sAssociation: string; iRoleType: Integer);
begin
  m_sSource := sSource;
  m_sTarget := sTarget;
  m_sRole := sRole;
  m_sAssociation := sAssociation;
  m_iRoleType := iRoleType;
end;

constructor TRoleTypeOfBinding.Create(other: TRoleTypeOfBinding);
begin
  m_sSource := other.m_sSource;
  m_sTarget := other.m_sTarget;
  m_sRole := other.m_sRole;
  m_sAssociation := other.m_sAssociation;
  m_iRoleType := other.m_iRoleType;
end;

// --------------------- TRoleTypesOfBindings ---------------------

function TRoleTypesOfBindings.GetKeyByIndex(index: Integer): string;
begin
  with TRoleTypeOfBinding(Self[index]) do
    Result := m_sSource + '_' + m_sTarget + '_' + m_sRole;
end;

function TRoleTypesOfBindings.GetRoleTypeOfBinding(sSource, sTarget, sRole: string): Integer;
var
  index: Integer;
begin
  index := GetIndexByKey(sSource + '_' + sTarget + '_' + sRole);
  if index >= 0 then
    Result := TRoleTypeOfBinding(Self[index]).m_iRoleType
  else
    Result := -1;
end;

function TRoleTypesOfBindings.GetItem(sSource, sTarget, sRole: string): TRoleTypeOfBinding;
var
  index: Integer;
begin
  index := GetIndexByKey(sSource + '_' + sTarget + '_' + sRole);
  if index >= 0 then
    Result := TRoleTypeOfBinding(Self[index])
  else
    Result := nil;
end;

function CompareRoleTypesOfBindings(Item1, Item2: Pointer): Integer;
var
  roleTypeItem1, roleTypeItem2: TRoleTypeOfBinding;
begin
  roleTypeItem1 := TRoleTypeOfBinding(Item1);
  roleTypeItem2 := TRoleTypeOfBinding(Item2);
  Result := CompareStr(roleTypeItem1.m_sSource + '_' + roleTypeItem1.m_sTarget + '_' + roleTypeItem1.m_sRole,
      roleTypeItem2.m_sSource + '_' + roleTypeItem2.m_sTarget + '_' + roleTypeItem2.m_sRole);
end;

end.
