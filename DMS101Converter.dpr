program DMS101Converter;

uses
  Forms,
  DMS101ConverterFormUnit in 'DMS101ConverterFormUnit.pas' {DMS101ConverterForm},
  Dmw_ddw in 'DMAPI\Dmw_ddw.pas',
  dmw_Use in 'DMAPI\dmw_Use.pas',
  obj_use in 'DMAPI\obj_use.pas',
  OTypes in 'DMAPI\OTypes.pas',
  WStrings in 'DMAPI\WStrings.pas',
  uLkJSON in 'uLkJSON.pas',
  S101CatalogueUnit in 'S101CatalogueUnit.pas',
  S101BinaryAccessUnit in 'S101BinaryAccessUnit.pas',
  S101DataSetUnit in 'S101DataSetUnit.pas',
  ProgressFormUnit in 'ProgressFormUnit.pas' {ProgressForm},
  S101DataSetUpdateUnit in 'S101DataSetUpdateUnit.pas',
  S101IniFileUnit in 'S101IniFileUnit.pas',
  S101TypesUnit in 'S101TypesUnit.pas',
  S101DataSetJSONUnit in 'S101DataSetJSONUnit.pas',
  DMChainToJSONUnit in 'DMChainToJSONUnit.pas',
  S101DataSetDMUnit in 'S101DataSetDMUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDMS101ConverterForm, DMS101ConverterForm);
  Application.Run;
end.
