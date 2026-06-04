unit DMS101ConverterFormUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Dialogs, Forms,
  StdCtrls, IniFiles, StrUtils, ExtCtrls, SyncObjs, S101TypesUnit, S101CatalogueUnit,
  S101DataSetUnit, S101DataSetJSONUnit, S101DataSetUpdateUnit, DMChainToJSONUnit,
  S101DataSetDMUnit;


type
  TDMS101ConverterForm = class(TForm)
    btnConvertDMtoS101: TButton;
    btnConvertS101toDM: TButton;
    btnDMtoS101batch: TButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    procedure btnConvertBinaryToJSONClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnConvertJSONToBinaryClick(Sender: TObject);
    procedure cbxCompositeToCurveClick(Sender: TObject);
    procedure cbxSoundingMultipointToPointsClick(Sender: TObject);
    procedure btnMakeDeltaClick(Sender: TObject);
    procedure btnConvertDMtoJSONClick(Sender: TObject);
    procedure btnConvertJSONtoDMClick(Sender: TObject);
    procedure btnConvertDMtoS101Click(Sender: TObject);
    procedure btnConvertS101toDMClick(Sender: TObject);
    procedure btnDMtoS101batchClick(Sender: TObject);
  private
    m_s101Catalogue: TS101Catalogue;
    m_catalogueFolder: string;
    m_catalogueName: string;
  public
    { Public declarations }
  end;

var
  DMS101ConverterForm: TDMS101ConverterForm;
  tfDebugLog: TextFile;

implementation

uses
  FileCtrl, OTypes, dmw_Use;

{$R *.dfm}

procedure TDMS101ConverterForm.btnConvertBinaryToJSONClick(Sender: TObject);
var
  s101DataSet: TS101DataSetJSON;
  logPath, sError: string;
  rc : Integer;
begin
  s101DataSet := nil;
  try
    OpenDialog1.Filter := 'S101-файлы (*.000)|*.000';
    OpenDialog1.Title := 'Выберите исходный файл S101';
    if not OpenDialog1.Execute then Exit;
    logPath := ChangeFileExt(OpenDialog1.FileName, '.log');
    logPath := AnsiReplaceStr(logPath, '.log', '_to_JSON.log');
    s101DataSet := TS101DataSetJSON.Create(m_s101Catalogue);
    rc := s101DataSet.RunInWorkingThread(ReadS101Binary, OpenDialog1.FileName, logPath, sError);
    case rc of
      TERM_STATUS_USERSTOP: MessageDlg('Процесс преобразования прерван пользователем', mtWarning, [mbOK], 0);
      TERM_STATUS_ERROR: MessageDlg(sError, mtError, [mbOK], 0);
    end;
    if rc <> TERM_STATUS_SUCCESS then Exit;

    SaveDialog1.FileName := ChangeFileExt(OpenDialog1.FileName, '.json');
    SaveDialog1.Filter := 'JSON-файлы (*.json)|*.json';
    if not SaveDialog1.Execute then Exit;
    if FileExists(SaveDialog1.FileName) then
      if MessageDlg('Файл ' + SaveDialog1.FileName + ' существует. Перезаписать его?',
          mtConfirmation, [mbOK, mbCancel], 0) <> mrOk then Exit;
    rc := s101DataSet.RunInWorkingThread(ExportToJSON, SaveDialog1.FileName, logPath, sError);
    case rc of
      TERM_STATUS_SUCCESS: MessageDlg('Конвертирование успешно завершено', mtInformation, [mbOK], 0);
      TERM_STATUS_USERSTOP: MessageDlg('Процесс преобразования прерван пользователем', mtWarning, [mbOK], 0);
      TERM_STATUS_ERROR: MessageDlg(sError, mtError, [mbOK], 0);
    end;
  finally
    s101DataSet.Free;
  end;
end;

procedure TDMS101ConverterForm.btnConvertJSONToBinaryClick(Sender: TObject);
var
  s101DataSet: TS101DataSetJSON;
  logPath, sError: string;
  rc: Integer;
begin
  s101DataSet := nil;
  try
    OpenDialog1.Filter := 'JSON-файлы (*.json)|*.json';
    OpenDialog1.Title := 'Выберите исходный JSON-файл';
    if not OpenDialog1.Execute then Exit;
    logPath := ChangeFileExt(OpenDialog1.FileName, '.log');
    logPath := AnsiReplaceStr(logPath, '.log', '_from_JSON.log');
    s101DataSet := TS101DataSetJSON.Create(m_s101Catalogue);
    rc := s101DataSet.RunInWorkingThread(ReadS101JSON, OpenDialog1.FileName, logPath, sError);
    case rc of
      TERM_STATUS_USERSTOP: MessageDlg('Процесс преобразования прерван пользователем', mtWarning, [mbOK], 0);
      TERM_STATUS_ERROR: MessageDlg(sError, mtError, [mbOK], 0);
    end;
    if rc <> TERM_STATUS_SUCCESS then Exit;

    SaveDialog1.FileName := ChangeFileExt(OpenDialog1.FileName, '.000');
    SaveDialog1.Filter := 'S101-файлы (*.000)|*.000';
    if not SaveDialog1.Execute then Exit;
    if FileExists(SaveDialog1.FileName) then
      if MessageDlg('Файл ' + SaveDialog1.FileName + ' существует. Перезаписать его?',
          mtConfirmation, [mbOK, mbCancel], 0) <> mrOk then Exit;
    rc := s101DataSet.RunInWorkingThread(ExportToBinary, SaveDialog1.FileName, logPath, sError);
    case rc of
      TERM_STATUS_SUCCESS: MessageDlg('Конвертирование успешно завершено', mtInformation, [mbOK], 0);
      TERM_STATUS_USERSTOP: MessageDlg('Процесс преобразования прерван пользователем', mtWarning, [mbOK], 0);
      TERM_STATUS_ERROR: MessageDlg(sError, mtError, [mbOK], 0);
    end;
  finally
    s101DataSet.Free;
  end;
end;

procedure TDMS101ConverterForm.FormCreate(Sender: TObject);
var
  iniFile: TIniFile;
  exeFolder, cataloguePath, fullCatalogueFolder, logPath: string;
  bError: Boolean;
  sError: string;
begin
  m_s101Catalogue := TS101Catalogue.Create;
  bError := False;

  exeFolder := ExtractFilePath(Application.ExeName);
  iniFile := TIniFile.Create(exeFolder + 'DMS101Converter.ini');
  m_catalogueFolder := iniFile.ReadString('Params', 'CatalogueFolder', 'Catalogue');
  fullCatalogueFolder := exeFolder + m_catalogueFolder + '\';
  m_catalogueName := iniFile.ReadString('Params', 'CatalogueName', 'S101_Catalogue');
  cataloguePath := fullCatalogueFolder + m_catalogueName + '.json';
  logPath := ChangeFileExt(cataloguePath, '.log');
  g_convertCCtoC := iniFile.ReadBool('Params', 'ConvertCCtoC', CONVERT_CC_TO_C);
  g_convertSoundgMP3toP := iniFile.ReadBool('Params', 'ConvertSoundgMP3toP', CONVERT_SOUNDG_MP3_TO_P);
  g_unknownAcronymMarker := iniFile.ReadString('Params', 'UnknownAcronymMarker', '_UNKNOWN');
  g_wrongValueMarker := iniFile.ReadString('Params', 'WrongValueMarker', '_WRONG_VALUE');
  iniFile.Free;

//  cbxCompositeToCurve.Checked := g_convertCCtoC;
//  cbxSoundingMultipointToPoints.Checked := g_convertSoundgMP3toP;

  if not FileExists(cataloguePath) then begin
    bError := True;
    sError := 'Файл каталога объектов "' + cataloguePath + '" не найден';
  end
  else if not m_s101Catalogue.ReadFromJSON(cataloguePath, logPath) then begin
    bError := True;
    sError := 'Обнаружены ошибки при загрузке файла каталога "' + cataloguePath +
        '". Протокол ошибок находится в файле "' + logPath + '".';
  end
  else if not m_s101Catalogue.ReadAllAcronymPairs(fullCatalogueFolder) or
      not m_s101Catalogue.ReadSupportedCRSs(fullCatalogueFolder + 'Supported_CRS.csv') or
      not m_s101Catalogue.ReadSupportedAxes(fullCatalogueFolder + 'Supported_Axes.csv') or
      not m_s101Catalogue.ReadSupportedProjections(fullCatalogueFolder + 'Supported_Projections.csv') or
      not m_s101Catalogue.ReadTopicCategories(fullCatalogueFolder + 'Topic_Categories.csv') then begin
    bError := True;
    sError := 'Не удалось загрузить CSV-файлы из папки "' + fullCatalogueFolder + '"';
  end;

  if bError then begin
    MessageDlg(sError, mtError, [mbOK], 0);
    Application.Terminate;
    Exit;
  end;
end;

procedure TDMS101ConverterForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  exeFolder: string;
  iniFile: TIniFile;
begin
//  g_convertCCtoC := cbxCompositeToCurve.Checked;
//  g_convertSoundgMP3toP := cbxSoundingMultipointToPoints.Checked;
  exeFolder := ExtractFilePath(Application.ExeName);
  iniFile := TIniFile.Create(exeFolder + 'DMS101Converter.ini');
  iniFile.WriteString('Params', 'CatalogueFolder', m_catalogueFolder);
  iniFile.WriteString('Params', 'CatalogueName', m_catalogueName);
  iniFile.WriteBool('Params', 'ConvertCCtoC', g_convertCCtoC);
  iniFile.WriteBool('Params', 'ConvertSoundgMP3toP', g_convertSoundgMP3toP);
  iniFile.WriteString('Params', 'UnknownAcronymMarker', g_unknownAcronymMarker);
  iniFile.WriteString('Params', 'WrongValueMarker', g_wrongValueMarker);
  iniFile.Free;
end;

procedure TDMS101ConverterForm.cbxCompositeToCurveClick(Sender: TObject);
begin
//  g_convertCCtoC := cbxCompositeToCurve.Checked;
end;

procedure TDMS101ConverterForm.cbxSoundingMultipointToPointsClick(
  Sender: TObject);
begin
//  g_convertSoundgMP3toP := cbxSoundingMultipointToPoints.Checked;
end;

procedure TDMS101ConverterForm.btnMakeDeltaClick(Sender: TObject);
var
  logPath, sError: string;
  oldDS, newDS: TS101DataSetJSON;
  deltaDS: TS101DataSetUpdate;
  rc: Integer;
begin
  try
    oldDS := nil;
    newDS := nil;
    deltaDS := nil;
    OpenDialog1.Filter := 'S101-файлы (*.000)|*.000';
    OpenDialog1.Title := 'Выберите исходный файл S101';
    if not OpenDialog1.Execute then Exit;
    logPath := ChangeFileExt(OpenDialog1.FileName, '.log');
    logPath := AnsiReplaceStr(logPath, '.log', '_to_delta.log');
    oldDS := TS101DataSetJSON.Create(m_s101Catalogue);
    rc := oldDS.RunInWorkingThread(ReadS101Binary, OpenDialog1.FileName, logPath, sError);
    case rc of
      TERM_STATUS_USERSTOP: MessageDlg('Процесс преобразования прерван пользователем', mtWarning, [mbOK], 0);
      TERM_STATUS_ERROR: MessageDlg(sError, mtError, [mbOK], 0);
    end;
    if rc <> TERM_STATUS_SUCCESS then Exit;

    OpenDialog1.Filter := 'JSON-файлы (*.json)|*.json';
    OpenDialog1.Title := 'Выберите разностный JSON-файл';
    if not OpenDialog1.Execute then Exit;
    newDS := TS101DataSetJSON.Create(m_s101Catalogue, True);
    rc := newDS.RunInWorkingThread(ReadS101JSON, OpenDialog1.FileName, logPath, sError);
    case rc of
      TERM_STATUS_USERSTOP: MessageDlg('Процесс преобразования прерван пользователем', mtWarning, [mbOK], 0);
      TERM_STATUS_ERROR: MessageDlg(sError, mtError, [mbOK], 0);
    end;
    if rc <> TERM_STATUS_SUCCESS then Exit;

    deltaDS := TS101DataSetUpdate.Create(m_s101Catalogue);
    if not deltaDS.Difference(oldDS, newDS, logPath, sError) then begin
      MessageDlg(sError, mtError, [mbOK], 0);
      Exit;
    end;
    MessageDlg('Формирование корректуры успешно завершено', mtInformation, [mbOK], 0);
  finally
    oldDS.Free;
    newDS.Free;
    deltaDS.Free;
  end;
end;

procedure TDMS101ConverterForm.btnConvertDMtoJSONClick(Sender: TObject);
var
  sError: string;
  dmChainToJSON: TDMChainToJSON;
begin
  OpenDialog1.Filter := 'DM-файлы (*.dm)|*.dm';
  OpenDialog1.Title := 'Выберите DM-файл с цепочно-узловой структурой';
  if not OpenDialog1.Execute then Exit;
  dmChainToJSON := TDMChainToJSON.Create;
  case dmChainToJSON.RunInWorkingThread(OpenDialog1.FileName,
      ChangeFileExt(OpenDialog1.FileName, '.log'), sError) of
    TERM_STATUS_SUCCESS: MessageDlg(Format('Обработка файла %s успешно завершена',
        [OpenDialog1.FileName]), mtInformation, [mbOK], 0);
    TERM_STATUS_USERSTOP: MessageDlg('Процесс преобразования прерван пользователем', mtWarning, [mbOK], 0);
    TERM_STATUS_ERROR: MessageDlg(Format('При обработке файла %s возникла ошибка: %s',
        [OpenDialog1.FileName, sError]), mtError, [mbOK], 0);
  end;
  dmChainToJSON.Free;
end;

procedure TDMS101ConverterForm.btnConvertJSONtoDMClick(Sender: TObject);
var
  sError: string;
  dmChainToJSON: TDMChainToJSON;
begin
  OpenDialog1.Filter := 'JSON-файлы (*.json)|*.json';
  OpenDialog1.Title := 'Выберите JSON-файл в стандарте S-101';
  if not OpenDialog1.Execute then Exit;
  dmChainToJSON := TDMChainToJSON.Create;
  if dmChainToJSON.ObjectsFromJSON(OpenDialog1.FileName,
      ChangeFileExt(OpenDialog1.FileName, '.log'), sError) then
    MessageDlg(Format('Файл %s успешно преобразован в формат DM',
        [OpenDialog1.FileName]), mtInformation, [mbOK], 0)
  else
    MessageDlg(Format('При обработке файла %s возникла ошибка: %s',
            [OpenDialog1.FileName, sError]), mtError, [mbOK], 0);
  dmChainToJSON.Free;
end;

procedure TDMS101ConverterForm.btnConvertDMtoS101Click(Sender: TObject);
var
  s101DataSetDM: TS101DataSetDM;
  s57DataSet: TS101DataSet;
  s101FileName, s57FileName, sLogName, sError: string;
begin
  OpenDialog1.Filter := 'DM-файлы (*.dm)|*.dm';
  OpenDialog1.Title := 'Выберите DM-файл с классификатором S-101 и цепочно-узловой структурой';
  if not OpenDialog1.Execute then Exit;
  try
    s101DataSetDM := TS101DataSetDM.Create(m_s101Catalogue);
    if not s101DataSetDM.S101FromDM(OpenDialog1.FileName, sError) then begin
      MessageDlg(Format('При обработке файла %s возникла ошибка: %s',
              [OpenDialog1.FileName, sError]), mtError, [mbOK], 0);
      Exit;
    end;

    // Если рядом с DM-файлом есть одноименная ячейка S-57, возьмем из нее FOID-ы
    s57FileName := ChangeFileExt(OpenDialog1.FileName, '.000');
    if FileExists(s57FileName) then begin
      s57DataSet := TS101DataSet.Create(m_s101Catalogue);
      sLogName := ChangeFileExt(s57FileName, '.log');
      if not s57DataSet.ReadS101Binary(s57FileName, sLogName, sError, true, false) then begin
        MessageDlg(Format('При чтении файла %s возникла ошибка: %s',
                [s57FileName, sError]), mtError, [mbOK], 0);
        Exit;
      end;
      s101DataSetDM.GetFOIDsFromS57(s57DataSet);
    end;

    s101FileName :=  ChangeFileExt(ExtractFilePath(OpenDialog1.FileName) + '101' +
        ExtractFileName(OpenDialog1.FileName), '.000');
    sLogName := ChangeFileExt(s101FileName, '.log');
    if not s101DataSetDM.ExportToBinary(s101FileName, sLogName, sError) then begin
      MessageDlg(Format('При экспорте файла %s возникла ошибка: %s',
              [s101FileName, sError]), mtError, [mbOK], 0);
      Exit;
    end;
    MessageDlg(Format('Файл %s успешно преобразован в формат S-101',
        [OpenDialog1.FileName]), mtInformation, [mbOK], 0);
  finally
    s101DataSetDM.Free;
    s57DataSet.Free;
  end;
end;

procedure TDMS101ConverterForm.btnConvertS101toDMClick(Sender: TObject);
var
  s101DataSetDM: TS101DataSetDM;
  sLogName, sError, sDMFileName: string;
begin
  OpenDialog1.Filter := 'S101-файлы (*.000)|*.000';
  OpenDialog1.Title := 'Выберите S101-файл';
  if not OpenDialog1.Execute then Exit;
  try
    s101DataSetDM := TS101DataSetDM.Create(m_s101Catalogue);
    sLogName := ChangeFileExt(OpenDialog1.FileName, '.log');
    if not s101DataSetDM.ReadS101Binary(OpenDialog1.FileName, sLogName, sError) then begin
      MessageDlg(Format('При чтении файла %s возникла ошибка: %s',
              [OpenDialog1.FileName, sError]), mtError, [mbOK], 0);
      Exit;
    end;
    sDMFileName :=  ChangeFileExt(OpenDialog1.FileName, '.dm');
    if not s101DataSetDM.S101ToDM(sDMFileName, sError) then begin
      MessageDlg(Format('При преобразовании файла %s в формат DM возникла ошибка: %s',
              [OpenDialog1.FileName, sError]), mtError, [mbOK], 0);
      Exit;
    end;
    MessageDlg(Format('Файл %s успешно преобразован в формат DM',
        [OpenDialog1.FileName]), mtInformation, [mbOK], 0);
  finally
    s101DataSetDM.Free;
  end;
end;

type
  TPackageThread = class(TThread)
  protected
    m_sMapPath, m_sPkgPath, m_sFuncName: string;
  public
    constructor Create(mapPath, pkgPath, funcName: string; bCreateSuspended: Boolean = False);
  protected
    procedure Execute; override;
  end;

constructor TPackageThread.Create(mapPath, pkgPath, funcName: string; bCreateSuspended: Boolean = False);
begin
  inherited Create(bCreateSuspended);
  m_sMapPath := mapPath;
  m_sPkgPath := pkgPath;
  m_sFuncName := funcName;
end;

procedure TPackageThread.Execute;
begin
  dm_apply_pkg(PChar(m_sMapPath), PChar(m_sPkgPath), PChar(m_sFuncName));
end;

procedure TDMS101ConverterForm.btnDMtoS101batchClick(Sender: TObject);
var
  directory, mapPath, workDir, pkgPath, funcName, s101FileName, sLogName, sError: string;
  pcPath, pcDir, pcName: TPathStr;
  fsr: TSearchRec;
  pkgThread: TPackageThread;
  funcNames: array[0..2] of string;
  i: Integer;
  s101DataSetDM: TS101DataSetDM;
begin
  ZeroMemory(@pcPath, sizeof(TPathStr));
  ZeroMemory(@pcDir, sizeof(TPathStr));
  ZeroMemory(@pcName, sizeof(TPathStr));
  workDir := dm_Work_Path(pcPath, pcDir, pcName);
  if not SelectDirectory(directory, [], 0) then
    Exit;
  directory := directory + '\';
  if FindFirst(directory + '*.dm', faAnyFile, fsr) <> 0 then begin
    MessageDlg(Format('В директории %s не найдены DM-файлы', [directory]), mtError, [mbOK], 0);
    Exit;
  end;
  repeat
    mapPath := directory + fsr.Name;
    if dm_Open(PChar(mapPath), True) = 0 then begin
      MessageDlg(Format('Не удалось открыть файл %s на редактирование', [mapPath]), mtError, [mbOK], 0);
      Exit;
    end;

{
    pkgPath := workDir + 'pkg\my_s101.pkg';
    if not FileExists(pkgPath) then begin
      MessageDlg(Format('Пакетный файл %s не существует', [pkgPath]), mtError, [mbOK], 0);
      Exit;
    end;
    funcNames[0] := '1. Цепочно-узловая структура';
    funcNames[1] := '2. Массивы глубин';
    funcNames[2] := '3. inform и feaNam';
}

    try
{
      for i := 0 to 2 do begin
        funcName := funcNames[i];
        pkgThread := TPackageThread.Create(mapPath, pkgPath, funcName);
        pkgThread.WaitFor;
        pkgThread.Free;
      end;
}
      pkgThread := TPackageThread.Create(mapPath, workDir + 'pkg\%S100_ЭНК.pkg', 'Нормализация S57');
      pkgThread.WaitFor;
      pkgThread.Free;
      pkgThread := TPackageThread.Create(mapPath, workDir + 'pkg\%S100_ЭНК.pkg', 'Модель S100');
      pkgThread.WaitFor;
      pkgThread.Free;
      pkgThread := TPackageThread.Create(mapPath, workDir + 'pkg\my_s101.pkg', '1. Цепочно-узловая структура');
      pkgThread.WaitFor;
      pkgThread.Free;
      pkgThread := TPackageThread.Create(mapPath, workDir + 'pkg\my_s101.pkg', '2. Массивы глубин');
      pkgThread.WaitFor;
      pkgThread.Free;
      pkgThread := TPackageThread.Create(mapPath, workDir + 'pkg\my_s101.pkg', '3. inform и feaNam');
      pkgThread.WaitFor;
      pkgThread.Free;

      s101DataSetDM := TS101DataSetDM.Create(m_s101Catalogue);
      if not s101DataSetDM.S101FromDM(mapPath, sError) then begin
        MessageDlg(Format('При обработке файла %s возникла ошибка: %s',
                [mapPath, sError]), mtError, [mbOK], 0);
        Exit;
      end;
      s101FileName :=  ChangeFileExt(ExtractFilePath(mapPath) + '101' + ExtractFileName(mapPath), '.000');
      sLogName := ChangeFileExt(s101FileName, '.log');
      if not s101DataSetDM.ExportToBinary(s101FileName, sLogName, sError) then begin
        MessageDlg(Format('При экспорте файла %s возникла ошибка: %s',
                [s101FileName, sError]), mtError, [mbOK], 0);
        Exit;
      end;
    except
      on E: Exception do MessageDlg(Format('Ошибка %s при выполнении пакетной функции %s',
          [E.Message, funcName]), mtError, [mbOK], 0);
    end;
    dm_Done;
  until FindNext(fsr) <> 0;
  FindClose(fsr);
  MessageDlg(Format('Пакетное преобразование файлов %s завершено', [directory + '*.dm']), mtInformation, [mbOK], 0);
end;

begin
  AssignFile(tfDebugLog, ExtractFilePath(Application.ExeName) + 'DMS101Converter.log');
  Rewrite(tfDebugLog);
end.

