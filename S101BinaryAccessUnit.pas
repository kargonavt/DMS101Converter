unit S101BinaryAccessUnit;

interface

uses
  Classes, Controls, StrUtils, DateUtils, SysUtils, Windows;

type
  TRecordTypeCode = (
    FeatureRecordType = 100,
    PointRecordType = 110,
    MultiPointRecordType = 115,
    CurveRecordType = 120,
    CompositeCurveRecordType = 125,
    SurfaceRecordType = 130,
    InfoRecordType = 150
  );

  TLRLeader = record
    recordLength: array[0..4] of Char;
    interchangeLevel: Char;
    leaderIdentifier: Char;
    inlineCodeExtensionIndicator: Char;
    versionNumber: Char;
    applicationIndicator: Char;
    fieldControlLength: array[0..1] of Char;
    baseAddressOfFieldArea: array[0..4] of Char;
    extendedCharacterSetIndicator: array[0..2] of Char;
    entryMap: array[0..3] of Char;
  end;

  TLRSubfieldDescription = record
    sfTag: string;
    sfType: string;
    sfMulti: Boolean;
  end;

  TLRFieldDescription = record
    fieldTag: string;
    fieldDescription: string;
    subfieldsDescriptions: array of TLRSubfieldDescription;
  end;

  TLRFieldDescriptionArray = array of TLRFieldDescription;
  
  TLRSubfield = record
    descrIndex: Integer;
    iValue: Integer;
    dValue: Double;
    sValue: string;
  end;

  TLRSubfieldArray = array of TLRSubfield;

  TDynamicCharArray = array of Char;

  TLRFieldTagPair = record
    parentFieldTag: string;
    offspringFieldTag: string;
  end;

  TLRFieldTagPairArray = array of TLRFieldTagPair;

  // Идентификация набора данных S-101
  TDSIDField = record
		RCNM: Integer; // Имя записи {10}
		RCID: Integer; // Числовой идентификатор записи
		ENSP: string; // Спецификация кодирования
		ENED: string; // Версия спецификации кодирования
		PRSP: string; // Уникальный идентификатор информационного продукта, определенный в спецификации продукта
		PRED: string; // Версия спецификации информационного продукта
		PROF: string; // Идентификатор профиля внутри информационного продукта
		DSNM: string; // Имя файла набора данных
		DSTL: string; // Название набора данных
//		DSRD: TDate; // Базисная дата набора данных
		DSRD: string; // Базисная дата набора данных
		DSLG: string; // Основной язык набора данных
		DSAB: string; // Краткое описание набора данных
		DSED: string; // Версия набора данных
		DSTC: array of Integer; // Тематические категории набора данных
  end;

  // Идентификация набора данных S-57
  TS57DSIDField = record
		RCNM: Integer; // Имя записи {10}
		RCID: Integer; // Числовой идентификатор записи
		EXPP: Integer; // Назначение обмена
		INTU: Integer; // Предполагаемое использование
		DSNM: string; // Имя файла набора данных
		EDTN: string; // Номер издания
		UPDN: string; // Номер корректуры
		UADT: string; // Дата применения корректуры
		ISDT: string; // Дата выпуска
		STED: string; // Номер издания S-57
		PRSP: Integer; // Спецификация на производство
		PSDN: string; // Описание спецификации на производство
		PRED: string; // Версия спецификации информационного продукта
		PROF: Integer; // Идентификатор профиля внутри информационного продукта
		AGEN: Integer; // Агентство-производитель
		COMT: string; // Комментарий
  end;

  // Информация о структуре набора данных
  TDSSIField = record
		DCOX, DCOY, DCOZ: Double; // Смещения по осям координат
		CMFX, CMFY, CMFZ: Integer; // Множители для перевода целочисленных координат в значения долготы, широты и высоты
		NOIR: Integer; // Число информационных объектов в наборе данных
		NOPN: Integer; // Число точек в наборе данных
		NOMN: Integer; // Число мультиточек объектов в наборе данных
		NOCN: Integer; // Число кривых в наборе данных
		NOXN: Integer; // Число составных кривых в наборе данных
		NOSN: Integer; // Число поверхностей в наборе данных
		NOFR: Integer; // Число пространственных объектов в наборе данных
  end;

  // Информация о структуре набора данных S-57
  TS57DSSIField = record
    DSTR: Integer; // Структура данных = 2 (цепочно-узловая)
    AALL: Integer; // Лексический уровень ATTF (0 или 1)
    NALL: Integer; // Лексический уровень NATF (0, 1 или 2)
    NOMR: Integer; // Количество записей метаобъектов
    NOCR: Integer; // Количество записей картографических объектов = 0 (картографические записи не допукаются)
    NOGR: Integer; // Количество записей геообъектов
    NOLR: Integer; // Количесвто записей объектов-коллекций
    NOIN: Integer; // Количество записей изолированных узлов
    NOCN: Integer; // Количество записей связанных узлов
    NOED: Integer; // Количество записей ребер
    NOFA: Integer; // Количество записей граней
  end;

  TCodePair = record
    sCode: string;
    iCode: Integer;
  end;

  TCodesField = array of TCodePair;
  
  // Поле атрибута
  TAttrElem = record
    NATC: Integer;  // Числовой код атрибута в таблице ATCS
    ATIX: Integer;  // Индекс атрибута в массиве атрибутов одного кода одного
                    // и того же родительского элемента (начиная с 1)
    PAIX: Integer;  // Индекс родительского элемента (начиная с 1). Если атрибут
                    // не имеет родителя (атрибут верхнего уровня), индекс равен 0
    ATIN: Integer;  // Код инструкции обновления:
                    //    {1} - Insert
                    //    {2} - Delete
                    //    {3} - Modify
    ATVL: string;   // Значение атрибута
  end;

  TATTRField = record
    arrayOfAttrElem: array of TAttrElem;
  end;

  TDataSetGeneralInformation = record
    fDSID: TDSIDField;
    fS57DSID: TS57DSIDField;
    fDSSI: TDSSIField;
    fS57DSSI: TS57DSSIField;
    fATCS: TCodesField;
    fITCS: TCodesField;
    fFTCS: TCodesField;
    fIACS: TCodesField;
    fFACS: TCodesField;
    fARCS: TCodesField;
    // Поле ATTR было дочерним полем DSID в первой версии стандарта (атрибуты метаданных)
    // Оставим это поле, так как оно не мешает, а если встретится при чтении, обработаем
    fATTRArray: array of TATTRField;
  end;

  // Геодезический датум
  TGDATField = record
    fDTNM: string;  // Название геодезического датума
    fELNM: string;  // Название эллипсоида
    fESMA: double;  // Длина большой полуоси эллипсоида в метрах
    fESPT: integer; // Тип второго параметра эллипсоида:
                    //    1 - длина малой полуоси эллипсоида в метрах
                    //    2 - обратный коэффициент сжатия
    fESPM: double;  // Значение второго параметра эллипсоида
    fCMNM: string;  // Название центрального меридиана
    fCMGL: double;  // Долгота центрального меридиана в градусах
  end;

  PGDATField = ^TGDATField;

  // Вертикальный датум
  TVDATField = record
    fDTNM: string;  // Название вертикального датума
    fDTID: string;  // Идентификатор датума во внешнем источнике
    fDTSR: Integer; // Источник датума:
                    //    1 - реестр систем координат МГО
                    //    2 - каталог пространственных объектов
                    //    3 - EPSG
                    //    254 - другой источник
                    //    255 - не применим
    fSCRI: string;  // Информация об источнике системы координат,
                    // если тип источника - другой
  end;

  PVDATField = ^TVDATField;

  TPROJField = record
    PROM: Integer;  // Тип проекции
    PRP1: Double;   // 1-й параметр проекции
    PRP2: Double;   // 2-й параметр проекции
    PRP3: Double;   // 3-й параметр проекции
    PRP4: Double;   // 4-й параметр проекции
    PRP5: Double;   // 5-й параметр проекции
    FEAS: Double;   // Ложное восточное смещение
    FNOR: Double;   // Ложное северное смещение
  end;

  PPROJField = ^TPROJField;

  TAxis = record
    AXTY: Integer;  // Код типа оси координат (axtyValue из справочника TSupportedAxes)
    AXUM: Integer;  // Единица измерения вдоль оси координат:
                    //    1 - градус
                    //    2 - градиан (1/100 от 90 градусов)
                    //    3 - радиан
                    //    4 - метр
                    //    5 - международный фут
                    //    6 - геодезический фут
  end;

  TCSAXField = array of TAxis;

  TCRSHField = record
    CRIX: Integer;  // Индекс CRS: используется для идентификации вертикального датума
                    // в C3DI и C3DF
    CRST: Integer;  // Тип CRS (crstValue из справочника TCRSDescription)
    CSTY: Integer;  // Тип CS (csType из справочника TCRSDescription)
    CRNM: string;   // Название координатной референцной системы
    CRSI: string;   // Идентификатор CRS во внешнем источнике
    CRSS: Integer;  // Источник CRS:
                    //    1 - реестр CRS МГО
                    //    2 - каталог объектов
                    //    3 - EPSG
                    //    254 - другой источник
                    //    255 - не применим
    SCRI: string;   // Информация об источнике CRS, если CRSS=254
  end;

  TCSIDField = record
    RCNM: Integer;  // Имя записи: идентификатор CRS {15}
    RCID: Integer;  // Номер записи
    NCRC: Integer;  // Число компонентов CRS
  end;

  TCoordinateReferenceSystem = record
    fCRSH: TCRSHField;
    fCSAX: TCSAXField;
    pfPROJ: PPROJField;
    pfGDAT: PGDATField;
    pfVDAT: PVDATField;
  end;

  // Поле информационного типа
  TIRIDField = record
    RCNM: Integer;  // Кодовое имя поля {150}
    RCID: Integer;  // Числовой идентификатор поля
    NITC: Integer;  // Числовой код информационного типа в таблице ITCS
    RVER: Integer;  // Числовой номер версии поля
    RUIN: Integer;  // Код инструкции:
                    //    {1} - Insert
                    //    {2} - Delete
                    //    {3} - Modify
  end;

  // Поле информационной ассоциации
  TINASField = record
    RRNM: Integer;  // Кодовое имя поля по ссылке
    RRID: Integer;  // Числовой идентификатор поля по ссылке
    NIAC: Integer;  // Числовой код информационной ассоциации в таблице IACS
    NARC: Integer;  // Числовой код роли в таблице ARCS
    IUIN: Integer;  // Код инструкции обновления:
                    //    {1} - Insert
                    //    {2} - Delete
                    //    {3} - Modify
    arrayOfAttrElem: array of TAttrElem;
  end;

  TInformationType = record
    fIRID: TIRIDField;
    fATTRArray: array of TATTRField;
    fINASArray: array of TINASField;
    m_sGUID: string;
    m_sCode: string;
  end;

  // Поле двумерной точки с целочисленными координатами
  TC2ITField = record
    YCOO: Integer;  // Y-координата или широта
    XCOO: Integer;  // X-координата или долгота
  end;

  // Поле трехмерной точки с целочисленными координатами
  TC3ITField = record
    VCID: Integer;  // Внутренний идентификатор вертикальной CRS
    YCOO: Integer;  // Y-координата или широта
    XCOO: Integer;  // X-координата или долгота
    ZCOO: Integer;  // Z-координата (глубина или высота)
  end;

  // Поле двумерной точки с вещественными координатами
  TC2FTField = record
    YCOO: Double;  // Y-координата или широта
    XCOO: Double;  // X-координата или долгота
  end;

  // Поле трехмерной точки с вещественными координатами
  TC3FTField = record
    VCID: Integer;  // Внутренний идентификатор вертикальной CRS
    YCOO: Double;  // Y-координата или широта
    XCOO: Double;  // X-координата или долгота
    ZCOO: Double;  // Z-координата (глубина или высота)
  end;

  // Поле идентификатора точечной записи
  TPRIDField = record
    RCNM: Integer;  // Кодовое имя поля {110}
    RCID: Integer;  // Числовой идентификатор поля
    RVER: Integer;  // Серийный номер версии поля
    RUIN: Integer;  // Код инструкции:
                    //    {1} - Insert
                    //    {2} - Delete
                    //    {3} - Modify
  end;

  TCoordType = (ct2I, ct3I, ct2F, ct3F);

  TPointRec = record
    ct: TCoordType;  // Тип координат
    fPRID: TPRIDField;
    fINASArray: array of TINASField;
    fC2IT: TC2ITField;
    fC3IT: TC3ITField;
    fC2FT: TC2FTField;
    fC3FT: TC3FTField;
    sGUID: string;
  end;

  // Поле двумерной мультиточки с целочисленными координатами
  TC2ITElem = record
    YCOO: Integer;  // Y-координата или широта
    XCOO: Integer;  // X-координата или долгота
  end;

  TC2ILField = record
    C2ITArray: array of TC2ITElem;
  end;

  // Поле трехмерной мультиточки с целочисленными координатами
  TC3ITElem = record
    YCOO: Integer;  // Y-координата или широта
    XCOO: Integer;  // X-координата или долгота
    ZCOO: Integer;  // Z-координата (глубина или высота)
  end;

  TC3ILField = record
    VCID: Integer;  // Внутренний идентификатор вертикальной CRS
    C3ITArray: array of TC3ITElem;
  end;

  // Поле двумерной мультиточки с вещественными координатами
  TC2FTElem = record
    YCOO: Double;  // Y-координата или широта
    XCOO: Double;  // X-координата или долгота
  end;

  TC2FLField = record
    C2FTArray: array of TC2FTElem;
  end;

  // Поле трехмерной мультиточки с вещественными координатами
  TC3FTElem = record
    YCOO: Double;  // Y-координата или широта
    XCOO: Double;  // X-координата или долгота
    ZCOO: Double;  // Z-координата (глубина или высота)
  end;

  TC3FLField = record
    VCID: Integer;  // Внутренний идентификатор вертикальной CRS
    C3FTArray: array of TC3FTElem;
  end;

  // Поле идентификатора мультиточки
  TMRIDField = record
    RCNM: Integer;  // Кодовое имя поля {115}
    RCID: Integer;  // Числовой идентификатор поля
    RVER: Integer;  // Серийный номер версии поля
    RUIN: Integer;  // Код инструкции:
                    //    {1} - Insert
                    //    {2} - Delete
                    //    {3} - Modify
  end;

  // Поле управления координатами
  TCOCCField = record
    COUI: Integer;  // Код инструкции обновления координат:
                    //    {1} - Insert
                    //    {2} - Delete
                    //    {3} - Modify
    COIX: Integer;  // Индекс кортежа в целевой записи, начиная с которого
                    // выполняется операция (отсчет с 1)
    NCOR: Integer;  // Число кортежей в записи обновления
  end;

  PCOCCField = ^TCOCCField;

  TMultiPointRec = record
    ct: TCoordType;  // Тип координат
    fMRID: TMRIDField;
    fINASArray: array of TINASField;
    pfCOCC: PCOCCField;
    fC2ILArray: array of TC2ILField;
    fC3ILArray: array of TC3ILField;
    fC2FLArray: array of TC2FLField;
    fC3FLArray: array of TC3FLField;
    sGUID: string;
  end;

  // Поле идентификатора записи кривой
  TCRIDField = record
    RCNM: Integer;  // Кодовое имя поля {120}
    RCID: Integer;  // Числовой идентификатор поля
    RVER: Integer;  // Серийный номер версии поля
    RUIN: Integer;  // Код инструкции:
                    //    {1} - Insert
                    //    {2} - Delete
                    //    {3} - Modify
  end;

const InterpolationTypes: array[0..6] of string = (
  'linear',
  'arc3Points',
  'geodesic',
  'loxodromic',
  'elliptical',
  'conic',
  'circularArcCenterPointWithRadius');

type
  // Поле заголовка сегмента
  TSEGHField = record
    INTP: Integer;  // Метод интерполяции:
                    //    1 - линейная
                    //    2 - дуга по трем точкам
                    //    3 - геодезическая
                    //    4 - локсодромическая
                    //    5 - эллиптическая
                    //    6 - коническая
                    //    7 - дуга окружности с заданным центром и радиусом
    CIRC: Integer;  // Окружность или дуга (задается, если INTP=7):
                    //    1 - окружность
                    //    2 - дуга
    YCOO: Double;   // Координаты центра окружности (задаются, если INTP=7)
    XCOO: Double;
    DIST: Double;   // Радиус окружности (задается, если INTP=7)
    DISU: Integer;  // Единица измерения радиуса (задается, если INTP=7)
    SBRG: Double;   // Начало отсчета угла в градусах от 0 до 360°
                    // (задается, если INTP=7 и CIRC=2; не обязателен, если CIRC=1;
                    // иначе не используется)
    ANGL: Double;   // Угол раствора дуги в градусах от -360 до 360°
                    // (задается, если INTP=7 и CIRC=2; не обязателен, если CIRC=1;
                    // иначе не используется)
  end;

  // Поле управления сегментом
  TSECCField = record
    SEUI: Integer;  // Код инструкции обновления сегмента:
                    //    {1} - Insert
                    //    {2} - Delete
                    //    {3} - Modify
    SEIX: Integer;  // Индекс адресуемого сегмента в целевой записи
    NSEG: Integer;  // Число сегментов в записи обновления
  end;

  PSECCField = ^TSECCField;

  // Поле ассоциации с начальной и конечной точкой
  TPTASElem = record
    RRNM: Integer;  // Кодовое имя ссылочной записи
    RRID: Integer;  // Идентификатор ссылочной записи
    TOPI: Integer;  // Топологический индикатор:
                    //    1 - начальная точка
                    //    2 - конечная точка
                    //    3 - начальная (она же конечная) точка
  end;

  TPTASField = record
    PTASArray: array of TPTASElem;
  end;

  TSegmentElem = record
    fSEGH: TSEGHField;
    pfCOCC: PCOCCField;
    fC2ILArray: array of TC2ILField;
    fC3ILArray: array of TC3ILField;
    fC2FLArray: array of TC2FLField;
    fC3FLArray: array of TC3FLField;
  end;

  TCurveRec = record
    ct: TCoordType;  // Тип координат
    fCRID: TCRIDField;
    fINASArray: array of TINASField;
    fPTAS: TPTASField;
    pfSECC: PSECCField;
    fSegmentArray: array of TSegmentElem;
    sGUID: string;
  end;

  // Поле составной кривой
  TCCIDField = record
    RCNM: Integer;  // Кодовое имя поля {125}
    RCID: Integer;  // Числовой идентификатор поля
    RVER: Integer;  // Серийный номер версии поля
    RUIN: Integer;  // Код инструкции:
                    //    {1} - Insert
                    //    {2} - Delete
                    //    {3} - Modify
  end;

  // Поле управления компонентами кривой
  TCCOCField = record
    CCUI: Integer;  // Код инструкции обновления:
                    //    {1} - Insert
                    //    {2} - Delete
                    //    {3} - Modify
    CCIX: Integer;  // Индекс в массиве компонентов в поле CUCO целевой записи,
                    // начиная с которого пойдет обновление
    NCCO: Integer;  // Число компонентов: интерпретация зависит от инструкции:
                    //    Insert -  число компонентов в записи обновления, которые
                    //              надо вставить в целевую запись
                    //    Delete -  число компонентов, которые надо удалить из целевой записи
                    //    Modify -  число компонентов, которые надо заменить в целевой записи
  end;

  PCCOCField = ^TCCOCField;

const Orientation: array[0..1] of string = ('forward', 'backward');

type
  TCUCOElem = record
    RRNM: Integer;  // Кодовое имя записи по ссылке
    RRID: Integer;  // Числовой идентификатор поля по ссылке
    ORNT: Integer;  // Ориентация, в которой используется компонент:
                    //    {1} - прямая
                    //    {2} - обратная
  end;

  TCUCOField = record
    CUCOArray: array of TCUCOElem;
  end;

  TCompositeCurveRec = record
    fCCID: TCCIDField;
    pfCCOC: PCCOCField;
    fINASArray: array of TINASField;
    fCUCOArray: array of TCUCOField;
    sGUID: string;
  end;

  TSRIDField = record
    RCNM: Integer;  // Кодовое имя поля {130}
    RCID: Integer;  // Числовой идентификатор поля
    RVER: Integer;  // Серийный номер версии поля
    RUIN: Integer;  // Код инструкции:
                    //    {1} - Insert
                    //    {2} - Delete
                    //    {3} - Modify
  end;

const ExteriorInterior: array[0..1] of string = ('exterior', 'interior');

type
  // Ассоциация с кольцом
  TRIASElem = record
    RRNM: Integer;  // Кодовое имя ссылочной записи
    RRID: Integer;  // Идентификатор ссылочной записи
    ORNT: Integer;  // Ориентация, в которой используется компонент:
                    //    {1} - прямая
                    //    {2} - обратная
    USAG: Integer;  // Индикатор использования:
                    //    {1} - внешнее
                    //    {2} - внутреннее
    RAUI: Integer;  // Инструкция обновления ассоциации с кольцом:
                    //    {1} - Insert
                    //    {2} - Delete
  end;

  TRIASField = record
    RIASArray: array of TRIASElem;
  end;

  TSurfaceRec = record
    fSRID: TSRIDField;
    fINASArray: array of TINASField;
    fRIASArray: array of TRIASField;
    sGUID: string;
  end;

  // Идентификационная запись типа пространственного объекта (feature type)
  TFRIDField = record
    RCNM: Integer;  // Кодовое имя поля {100}
    RCID: Integer;  // Числовой идентификатор поля
    NFTC: Integer;  // Числовой код типа пространственного объекта в таблице FTCS
    RVER: Integer;  // Серийный номер версии поля
    RUIN: Integer;  // Код инструкции:
                    //    {1} - Insert
                    //    {2} - Delete
                    //    {3} - Modify
  end;

  // Поле идентификатора пространственного объекта
  TFOIDField = record
    AGEN: Integer;  // Код производителя
    FIDN: Integer;  // Идентификатор пространственного объекта
    FIDS: Integer;  // Код подраздела пространственных объектов
  end;

  PFOIDField = ^TFOIDField;

  // Ассоциация с пространственным примитивом
  TSPASElem = record
    RRNM: Integer;  // Кодовое имя ссылочной записи
    RRID: Integer;  // Идентификатор ссылочной записи
    ORNT: Integer;  // Ориентация:
                    //    {1} - прямая
                    //    {2} - обратная
                    //    {255} - не применима
    SMIN: Integer;  // Знаменатель максимального масштаба, при котором
                    // пространственный объект (feature) может быть отображен
                    // с помощью данного простраственного примитива. Если значение
                    // равно 0, не применяется.
    SMAX: Integer;  // Знаменатель минимального масштаба, при котором
                    // пространственный объект (feature) может быть отображен
                    // с помощью данного простраственного примитива. Если значение
                    // равно 2**32-1, не применяется.
    SAUI: Integer;  // Инструкция обновления пространственной ассоциации:
                    //    {1} - Insert
                    //    {2} - Delete
  end;

  TSPASField = record
    SPASArray: array of TSPASElem;
  end;

  // Ассоциация с пространственным объектом
  TFASCField = record
    RRNM: Integer;  // Кодовое имя поля по ссылке
    RRID: Integer;  // Числовой идентификатор поля по ссылке
    NFAC: Integer;  // Числовой код ассоциации в таблице FACS
    NARC: Integer;  // Числовой код роли в таблице ARCS
    FAUI: Integer;  // Код инструкции обновления:
                    //    {1} - Insert
                    //    {2} - Delete
                    //    {3} - Modify
    arrayOfAttrElem: array of TAttrElem;
  end;

  // Тематическая ассоциация
  TTHASElem = record
    RRNM: Integer;  // Кодовое имя ссылочной записи
    RRID: Integer;  // Идентификатор ссылочной записи
    TAUI: Integer;  // Инструкция обновления тематической ассоциации:
                    //    {1} - Insert
                    //    {2} - Delete
  end;

  TTHASField = record
    THASArray: array of TTHASElem;
  end;

  // Маскированный пространственный тип
  TMASKElem = record
    RRNM: Integer;  // Кодовое имя ссылочной записи
    RRID: Integer;  // Идентификатор ссылочной записи
    MIND: Integer;  // Индикатор маски:
                    //    {1} - Обрезка границами набора данных
                    //    {2} - Подавление отображения
    MUIN: Integer;  // Инструкция обновления маски:
                    //    {1} - Insert
                    //    {2} - Delete
  end;

  TMASKField = record
    MASKArray: array of TMASKElem;
  end;

  TFeatureRec = record
    fFRID: TFRIDField;
    pfFOID: PFOIDField;
    fATTRArray: array of TATTRField;
    fINASArray: array of TINASField;
    fSPASArray: array of TSPASField;
    fFASCArray: array of TFASCField;
    fTHASArray: array of TTHASField;
    fMASKArray: array of TMASKField;
    m_sGUID: string;
    m_sCode: string;
  end;

  TFieldSize = record
    m_sTag: string;
    m_nSize: Integer;
  end;

  TArrayOfAttrElem = array of TAttrElem;
  TArrayOfINASField = array of TINASField;
  TArrayOfFASCField = array of TFASCField;
  TArrayOfChar = array of Char;
  TArrayOfFieldSize = array of TFieldSize;
  TPointRecords = array of TPointRec;

function MakeSubfieldsDescriptions(var lrFieldDescription: TLRFieldDescription): Boolean;
function ParseFieldValue(lrFieldDescription: TLRFieldDescription; fieldValue: TDynamicCharArray;
    var subFields: TLRSubfieldArray): Boolean;
function MakeFieldTagPairs(fieldTagSize: Integer; fieldValue: TDynamicCharArray;
    var fieldTagPairs: TLRFieldTagPairArray): Boolean;
function GetDSIDField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fDSID: TDSIDField): Boolean;
function GetS57DSIDField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fS57DSID: TS57DSIDField): Boolean;
function GetDSSIField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fDSSI: TDSSIField): Boolean;
function GetS57DSSIField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fDSSI: TS57DSSIField): Boolean;
function GetCodesField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var codesField: TCodesField): Boolean;
function GetPROJField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fPROJ: TPROJField): Boolean;
function GetCSAXField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fCSAX: TCSAXField): Boolean;
function GetCRSHField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fCRSH: TCRSHField): Boolean;
function GetCSIDField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fCSID: TCSIDField): Boolean;
function GetGDATField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fGDAT: TGDATField): Boolean;
function GetVDATField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fVDAT: TVDATField): Boolean;
function GetIRIDField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fIRID: TIRIDField): Boolean;
function GetATTRField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fATTR: TATTRField): Boolean;
function GetINASField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fINAS: TINASField): Boolean;
function GetPRIDField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fPRID: TPRIDField): Boolean;
function GetC2ITField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fC2IT: TC2ITField): Boolean;
function GetC3ITField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fC3IT: TC3ITField): Boolean;
function GetC2FTField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fC2FT: TC2FTField): Boolean;
function GetC3FTField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fC3FT: TC3FTField): Boolean;
function GetC2ILField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fC2IL: TC2ILField): Boolean;
function GetC3ILField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fC3IL: TC3ILField): Boolean;
function GetC2FLField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fC2FL: TC2FLField): Boolean;
function GetC3FLField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fC3FL: TC3FLField): Boolean;
function GetMRIDField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fMRID: TMRIDField): Boolean;
function GetCOCCField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fCOCC: TCOCCField): Boolean;
function GetSEGHField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fSEGH: TSEGHField): Boolean;
function GetSECCField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fSECC: TSECCField): Boolean;
function GetPTASField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fPTAS: TPTASField): Boolean;
function GetCRIDField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fCRID: TCRIDField): Boolean;
function GetCCIDField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fCCID: TCCIDField): Boolean;
function GetCCOCField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fCCOC: TCCOCField): Boolean;
function GetCUCOField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fCUCO: TCUCOField): Boolean;
function GetSRIDField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fSRID: TSRIDField): Boolean;
function GetRIASField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fRIAS: TRIASField): Boolean;
function GetFRIDField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fFRID: TFRIDField): Boolean;
function GetFOIDField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fFOID: TFOIDField): Boolean;
function GetSPASField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fSPAS: TSPASField): Boolean;
function GetFASCField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fFASC: TFASCField): Boolean;
function GetTHASField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fTHAS: TTHASField): Boolean;
function GetMASKField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fMASK: TMASKField): Boolean;

implementation

function MakeSubfieldsDescriptions(var lrFieldDescription: TLRFieldDescription): Boolean;
var
  utPos1, utPos2, ftPos, nTags, nTypes, iTag, iType, nTypeCount, code, nDigits: Integer;
  sfTags, sfTypes: string;
  sfTagsList, sfTypesList: TStrings;
  bMulti: Boolean;
begin
  Result := False;
  if lrFieldDescription.fieldDescription = '' then Exit;
  utPos1 := PosEx(#31, lrFieldDescription.fieldDescription, 1);
  if utPos1 = 0 then Exit;
  utPos2 := PosEx(#31, lrFieldDescription.fieldDescription, utPos1 + 1);
  if utPos2 = 0 then Exit;
  ftPos := PosEx(#30, lrFieldDescription.fieldDescription, utPos2 + 1);
  if ftPos = 0 then Exit;
  sfTags := MidStr(lrFieldDescription.fieldDescription, utPos1 + 1, utPos2 - utPos1 - 1);
  sfTypes := MidStr(lrFieldDescription.fieldDescription, utPos2 + 1, ftPos - utPos2 - 1);
  if (sfTags = '') or (sfTypes = '') or (sfTypes[1] <> '(') or (sfTypes[Length(sfTypes)] <> ')') then Exit;
  sfTypes := MidStr(sfTypes, 2, Length(sfTypes) - 2);
  sfTagsList := TStringList.Create;
  sfTypesList := TStringList.Create;
  nTags := ExtractStrings(['!', '\'], [' '], PChar(sfTags), sfTagsList);
  nTypes := ExtractStrings([','], [' '], PChar(sfTypes), sfTypesList);
  for iType := 0 to nTypes - 1 do begin
    if sfTypesList[iType][1] = '{' then
      sfTypesList[iType] := MidStr(sfTypesList[iType], 2, Length(sfTypesList[iType]) - 1);
    if sfTypesList[iType][Length(sfTypesList[iType])] = '}' then
      sfTypesList[iType] := LeftStr(sfTypesList[iType], Length(sfTypesList[iType]) - 1);
  end;
  SetLength(lrFieldDescription.subfieldsDescriptions, nTags);
  bMulti := False;
  iType := 0;
  nTypeCount := 0;
  for iTag := 0 to nTags - 1 do begin
    if sfTagsList[iTag][1] = '*' then begin
      sfTagsList[iTag] := MidStr(sfTagsList[iTag], 2, Length(sfTagsList[iTag]) - 1);
      bMulti := True;
    end;
    if nTypeCount = 0 then begin
      Val(sfTypesList[iType], nTypeCount, code);
      if code > 1 then begin
        nDigits := code - 1;
        Val(LeftStr(sfTypesList[iType], nDigits), nTypeCount, code);
        sfTypesList[iType] := MidStr(sfTypesList[iType], nDigits + 1, Length(sfTypesList[iType]) - nDigits);
      end
      else
        nTypeCount := 1;
    end;
    lrFieldDescription.subfieldsDescriptions[iTag].sfTag := sfTagsList[iTag];
    lrFieldDescription.subfieldsDescriptions[iTag].sfType := sfTypesList[iType];
    lrFieldDescription.subfieldsDescriptions[iTag].sfMulti := bMulti;
    nTypeCount := nTypeCount - 1;
    if nTypeCount = 0 then
      iType := iType + 1;
  end;
  sfTagsList.Free;
  sfTypesList.Free;
  Result := True;
end;

function ParseFieldValue(lrFieldDescription: TLRFieldDescription; fieldValue: TDynamicCharArray;
    var subFields: TLRSubfieldArray): Boolean;
var
  bEndOfField: Boolean;
  iSubfield, sfSize, code, iCurPos, i, nBytesToRead, utPos: Integer;
  nValuesCount, iFirstMultiSubfield, nSubfields: Integer;
  buffer: array of Char;
  s: string;
begin
  Result := False;
  nSubfields := Length(lrFieldDescription.subfieldsDescriptions);
  if (nSubfields = 0) or (Length(fieldValue) = 0) then Exit;
  iFirstMultiSubfield := -1;
  for i := 0 to nSubfields - 1 do
    if lrFieldDescription.subfieldsDescriptions[i].sfMulti then begin
      iFirstMultiSubfield := i;
      Break;
    end;
  bEndOfField := False;
  iSubfield := 0;
  iCurPos := 0;
  nValuesCount := 0;
  repeat
    nBytesToRead := Length(fieldValue) - iCurPos;
    if fieldValue[Length(fieldValue) - 1] = #30 then
      nBytesToRead := nBytesToRead - 1;
    if nBytesToRead > 0 then begin
      sfSize := 0;
      with lrFieldDescription.subfieldsDescriptions[iSubfield] do begin
        if (sfType = 'b11') or (sfType = 'b21') then
          sfSize := 1
        else if (sfType = 'b12') or (sfType = 'b22') then
          sfSize := 2
        else if (sfType = 'b14') or (sfType = 'b24') then
          sfSize := 4
        else if (sfType = 'b48') or (sfType = 'b48') then
          sfSize := 8
        else if sfType[1] = 'A' then begin
          if Length(sfType) > 1 then
            Val(MidStr(sfType, 3, Length(sfType) - 3), sfSize, code);
        end
        else if sfType[1] = 'R' then begin
          if Length(sfType) > 1 then
            Val(MidStr(sfType, 3, Length(sfType) - 3), sfSize, code);
        end
        else
          Exit;
      end;
      if sfSize > 0 then
        if nBytesToRead >= sfSize then
          nBytesToRead := sfSize
        else
          Exit
      else begin
        utPos := -1;
        for i := iCurPos to Length(fieldValue) - 1 do
          if (fieldValue[i] = #31) or (fieldValue[i] = #30) then begin
            utPos := i;
            Break;
          end;
        if (utPos > 0) and (utPos - iCurPos < nBytesToRead) then
          nBytesToRead := utPos - iCurPos;
      end;
      SetLength(buffer, nBytesToRead + 1);
      for i := 0 to nBytesToRead do
        buffer[i] := #0;
      SetLength(subFields, nValuesCount + 1);
      with subFields[nValuesCount] do begin
        iValue := 0;
        dValue := 0.0;
        sValue := '';
        with lrFieldDescription.subfieldsDescriptions[iSubfield] do begin
          if (sfType[1] = 'b') then
            if (sfType[2] = '4') then
              Move(fieldValue[iCurPos], dValue, nBytesToRead)
            else
              Move(fieldValue[iCurPos], iValue, nBytesToRead)
          else if (sfType[1] = 'R') then begin
            s := Copy(string(fieldValue), iCurPos + 1, nBytesToRead);
            Val(s, dValue, code);
          end
          else begin
            Move(fieldValue[iCurPos], buffer[0], nBytesToRead);
            sValue := PChar(buffer);
          end;
          descrIndex := iSubfield;
        end;
      end;
      nValuesCount := nValuesCount + 1;
      iCurPos := iCurPos + nBytesToRead;
      if (fieldValue[iCurPos] = #31) and (sfSize = 0) then
        iCurPos := iCurPos + 1;
      if ((iCurPos = Length(fieldValue) - 1) and (fieldValue[iCurPos] = #30)) or
          (iCurPos = Length(fieldValue)) then
        bEndOfField := True
      else begin
        iSubfield := iSubfield + 1;
        if iSubfield = nSubfields then
          if iFirstMultiSubfield >= 0 then
            iSubfield := iFirstMultiSubfield
          else
            Exit;
      end;
    end
    else
      bEndOfField := True;
  until bEndOfField;
  Result := True;
end;

function MakeFieldTagPairs(fieldTagSize: Integer; fieldValue: TDynamicCharArray;
    var fieldTagPairs: TLRFieldTagPairArray): Boolean;
var
  buffer: array of Char;
  i, utPos, ftPos, nFieldTagPairsCount: Integer;
begin
  Result := False;
  if (fieldTagSize <= 0) or (Length(fieldValue) < fieldTagSize) or
      (fieldTagPairs <> nil) then Exit;
  SetLength(buffer, fieldTagSize + 1);
  for i := 0 to fieldTagSize do buffer[i] := #0;
  Move(fieldValue[0], buffer[0], fieldTagSize);
  if PChar(buffer) <> '0000' then Exit;
  utPos := -1;
  for i := 0 to Length(fieldValue) - 1 do
    if fieldValue[i] = #31 then begin
      utPos := i;
      Break;
    end;
  if utPos = -1 then Exit;
  ftPos := -1;
  for i := 0 to Length(fieldValue) - 1 do
    if fieldValue[i] = #30 then begin
      ftPos := i;
      Break;
    end;
  if ftPos = -1 then Exit;
  nFieldTagPairsCount := (ftPos - utPos - 1) div (2 * fieldTagSize);
  SetLength(fieldTagPairs, nFieldTagPairsCount);
  for i := 0 to nFieldTagPairsCount - 1 do begin
    Move(fieldValue[utPos + 1 + 2 * i * fieldTagSize], buffer[0], fieldTagSize);
    fieldTagPairs[i].parentFieldTag := PChar(buffer);
    Move(fieldValue[utPos + 1 + (2 * i + 1) * fieldTagSize], buffer[0], fieldTagSize);
    fieldTagPairs[i].offspringFieldTag := PChar(buffer);
  end;
  Result := True;
end;

function GetDSIDField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fDSID: TDSIDField): Boolean;
var
  iDate, code, iSubField, iDSTC: Integer;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'DSID' then Exit;
  for iSubField := 0 to Length(subFields) - 1 do begin
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'RCNM' then
        fDSID.RCNM := subFields[iSubField].iValue
      else if sfTag = 'RCID' then
        fDSID.RCID := subFields[iSubField].iValue
      else if sfTag = 'ENSP' then
        fDSID.ENSP := subFields[iSubField].sValue
      else if sfTag = 'ENED' then
        fDSID.ENED := subFields[iSubField].sValue
      else if sfTag = 'PRSP' then
        fDSID.PRSP := subFields[iSubField].sValue
      else if sfTag = 'PRED' then
        fDSID.PRED := subFields[iSubField].sValue
      else if sfTag = 'PROF' then
        fDSID.PROF := subFields[iSubField].sValue
      else if sfTag = 'DSNM' then
        fDSID.DSNM := subFields[iSubField].sValue
      else if sfTag = 'DSTL' then
        fDSID.DSTL := subFields[iSubField].sValue
{
      else if sfTag = 'DSRD' then begin
        Val(subFields[iSubField].sValue, iDate, code);
        if code = 0 then
          fDSID.DSRD := EncodeDateTime(iDate div 10000,
              (iDate mod 10000) div 100, iDate mod 100, 0, 0, 0, 0)
        else
          Exit;
      end
}
      else if sfTag = 'DSRD' then
        fDSID.DSRD := subFields[iSubField].sValue
      else if sfTag = 'DSLG' then
        fDSID.DSLG := subFields[iSubField].sValue
      else if sfTag = 'DSAB' then
        fDSID.DSAB := subFields[iSubField].sValue
      else if sfTag = 'DSED' then
        fDSID.DSED := subFields[iSubField].sValue
      else if sfTag = 'DSTC' then begin
        if fDSID.DSTC = nil then begin
          SetLength(fDSID.DSTC, Length(subFields) - iSubField);
          iDSTC := 0;
        end;
        fDSID.DSTC[iDSTC] := subFields[iSubField].iValue;
        iDSTC := iDSTC + 1;
      end
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetS57DSIDField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fS57DSID: TS57DSIDField): Boolean;
var
  iSubField: Integer;
  formatSettings: TFormatSettings;
  s: string;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'DSID' then Exit;
  for iSubField := 0 to Length(subFields) - 1 do begin
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'RCNM' then
        fS57DSID.RCNM := subFields[iSubField].iValue
      else if sfTag = 'RCID' then
        fS57DSID.RCID := subFields[iSubField].iValue
      else if sfTag = 'EXPP' then
        fS57DSID.EXPP := subFields[iSubField].iValue
      else if sfTag = 'INTU' then
        fS57DSID.INTU := subFields[iSubField].iValue
      else if sfTag = 'DSNM' then
        fS57DSID.DSNM := subFields[iSubField].sValue
      else if sfTag = 'EDTN' then
        fS57DSID.EDTN := subFields[iSubField].sValue
      else if sfTag = 'UPDN' then
        fS57DSID.UPDN := subFields[iSubField].sValue
      else if sfTag = 'UADT' then
        fS57DSID.UADT := subFields[iSubField].sValue
      else if sfTag = 'ISDT' then
        fS57DSID.ISDT := subFields[iSubField].sValue
      else if sfTag = 'STED' then begin
        GetLocaleFormatSettings(LOCALE_USER_DEFAULT, formatSettings);
        formatSettings.DecimalSeparator := '.';
        s := Format('%4.1f', [subFields[iSubField].dValue], formatSettings);
        fS57DSID.STED := AnsiReplaceStr(s, ' ', '0');
      end
      else if sfTag = 'PRSP' then
        fS57DSID.PRSP := subFields[iSubField].iValue
      else if sfTag = 'PSDN' then
        fS57DSID.PSDN := subFields[iSubField].sValue
      else if sfTag = 'PRED' then
        fS57DSID.PRED := subFields[iSubField].sValue
      else if sfTag = 'PROF' then
        fS57DSID.PROF := subFields[iSubField].iValue
      else if sfTag = 'AGEN' then
        fS57DSID.AGEN := subFields[iSubField].iValue
      else if sfTag = 'COMT' then
        fS57DSID.COMT := subFields[iSubField].sValue
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetDSSIField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fDSSI: TDSSIField): Boolean;
var
  iSubField: Integer;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'DSSI' then Exit;
  for iSubField := 0 to Length(subFields) - 1 do begin
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'DCOX' then
        fDSSI.DCOX := subFields[iSubField].dValue
      else if sfTag = 'DCOY' then
        fDSSI.DCOY := subFields[iSubField].dValue
      else if sfTag = 'DCOZ' then
        fDSSI.DCOZ := subFields[iSubField].dValue
      else if sfTag = 'CMFX' then
        fDSSI.CMFX := subFields[iSubField].iValue
      else if sfTag = 'CMFY' then
        fDSSI.CMFY := subFields[iSubField].iValue
      else if sfTag = 'CMFZ' then
        fDSSI.CMFZ := subFields[iSubField].iValue
      else if sfTag = 'NOIR' then
        fDSSI.NOIR := subFields[iSubField].iValue
      else if sfTag = 'NOPN' then
        fDSSI.NOPN := subFields[iSubField].iValue
      else if sfTag = 'NOMN' then
        fDSSI.NOMN := subFields[iSubField].iValue
      else if sfTag = 'NOCN' then
        fDSSI.NOCN := subFields[iSubField].iValue
      else if sfTag = 'NOXN' then
        fDSSI.NOXN := subFields[iSubField].iValue
      else if sfTag = 'NOSN' then
        fDSSI.NOSN := subFields[iSubField].iValue
      else if sfTag = 'NOFR' then
        fDSSI.NOFR := subFields[iSubField].iValue
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetS57DSSIField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fDSSI: TS57DSSIField): Boolean;
var
  iSubField: Integer;
begin
  if lrFieldDescription.fieldTag <> 'DSSI' then Exit;
  for iSubField := 0 to Length(subFields) - 1 do begin
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'DSTR' then
        fDSSI.DSTR := subFields[iSubField].iValue
      else if sfTag = 'AALL' then
        fDSSI.AALL := subFields[iSubField].iValue
      else if sfTag = 'NALL' then
        fDSSI.NALL := subFields[iSubField].iValue
      else if sfTag = 'NOMR' then
        fDSSI.NOMR := subFields[iSubField].iValue
      else if sfTag = 'NOCR' then
        fDSSI.NOCR := subFields[iSubField].iValue
      else if sfTag = 'NOGR' then
        fDSSI.NOGR := subFields[iSubField].iValue
      else if sfTag = 'NOLR' then
        fDSSI.NOLR := subFields[iSubField].iValue
      else if sfTag = 'NOIN' then
        fDSSI.NOIN := subFields[iSubField].iValue
      else if sfTag = 'NOCN' then
        fDSSI.NOCN := subFields[iSubField].iValue
      else if sfTag = 'NOED' then
        fDSSI.NOED := subFields[iSubField].iValue
      else if sfTag = 'NOFA' then
        fDSSI.NOFA := subFields[iSubField].iValue
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetCodesField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var codesField: TCodesField): Boolean;
var
  iSubField, iPair: Integer;
begin
  Result := False;
  if (lrFieldDescription.fieldTag <> 'ATCS') and ((lrFieldDescription.fieldTag <> 'ITCS') and
      (lrFieldDescription.fieldTag <> 'FTCS') and (lrFieldDescription.fieldTag <> 'IACS') and
      (lrFieldDescription.fieldTag <> 'FACS') and (lrFieldDescription.fieldTag <> 'ARCS')) then
    Exit;
  SetLength(codesField, Length(subFields) div 2);
  iPair := 0;
  for iSubField := 0 to Length(subFields) - 1 do begin
    if Odd(iSubField) then begin
      codesField[iPair].iCode := subFields[iSubField].iValue;
      iPair := iPair + 1;
    end
    else
      codesField[iPair].sCode := subFields[iSubField].sValue;
  end;
  Result := True;
end;

function GetPROJField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fPROJ: TPROJField): Boolean;
var
  iSubField: Integer;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'PROJ' then Exit;
  for iSubField := 0 to Length(subFields) - 1 do begin
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'PROM' then
        fPROJ.PROM := subFields[iSubField].iValue;
      if sfTag = 'PRP1' then
        fPROJ.PRP1 := subFields[iSubField].dValue;
      if sfTag = 'PRP2' then
        fPROJ.PRP2:= subFields[iSubField].dValue;
      if sfTag = 'PRP3' then
        fPROJ.PRP3 := subFields[iSubField].dValue;
      if sfTag = 'PRP4' then
        fPROJ.PRP1 := subFields[iSubField].dValue;
      if sfTag = 'PRP5' then
        fPROJ.PRP5 := subFields[iSubField].dValue;
      if sfTag = 'FEAS' then
        fPROJ.FEAS := subFields[iSubField].dValue;
      if sfTag = 'FNOR' then
        fPROJ.FNOR := subFields[iSubField].dValue;
    end;
  end;
  Result := True;
end;

function GetCSAXField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fCSAX: TCSAXField): Boolean;
var
  iSubField, iAxis: Integer;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'CSAX' then Exit;
  SetLength(fCSAX, Length(subFields) div 2);
  iAxis := 0;
  for iSubField := 0 to Length(subFields) - 1 do begin
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'AXTY' then
        fCSAX[iAxis].AXTY := subFields[iSubField].iValue
      else if sfTag = 'AXUM' then
        fCSAX[iAxis].AXUM := subFields[iSubField].iValue;
      if Odd(iSubField) then
        iAxis := iAxis + 1;
    end;
  end;
  Result := True;
end;

function GetCRSHField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fCRSH: TCRSHField): Boolean;
var
  iSubField: Integer;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'CRSH' then Exit;
  for iSubField := 0 to Length(subFields) - 1 do begin
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'CRIX' then
        fCRSH.CRIX := subFields[iSubField].iValue
      else if sfTag = 'CRST' then
        fCRSH.CRST := subFields[iSubField].iValue
      else if sfTag = 'CSTY' then
        fCRSH.CSTY := subFields[iSubField].iValue
      else if sfTag = 'CRNM' then
        fCRSH.CRNM := subFields[iSubField].sValue
      else if sfTag = 'CRSI' then
        fCRSH.CRSI := subFields[iSubField].sValue
      else if sfTag = 'CRSS' then
        fCRSH.CRSS := subFields[iSubField].iValue
      else if sfTag = 'SCRI' then
        fCRSH.SCRI := subFields[iSubField].sValue
    end;
  end;
  Result := True;
end;

function GetCSIDField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fCSID: TCSIDField): Boolean;
var
  iSubField: Integer;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'CSID' then Exit;
  for iSubField := 0 to Length(subFields) - 1 do begin
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'RCNM' then
        fCSID.RCNM := subFields[iSubField].iValue
      else if sfTag = 'RCID' then
        fCSID.RCID := subFields[iSubField].iValue
      else if sfTag = 'NCRC' then
        fCSID.NCRC := subFields[iSubField].iValue
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetGDATField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fGDAT: TGDATField): Boolean;
var
  iSubField: Integer;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'GDAT' then Exit;
  for iSubField := 0 to Length(subFields) - 1 do begin
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'DTNM' then
        fGDAT.fDTNM := subFields[iSubField].sValue
      else if sfTag = 'ELNM' then
        fGDAT.fELNM := subFields[iSubField].sValue
      else if sfTag = 'ESMA' then
        fGDAT.fESMA := subFields[iSubField].dValue
      else if sfTag = 'ESPT' then
        fGDAT.fESPT := subFields[iSubField].iValue
      else if sfTag = 'ESPM' then
        fGDAT.fESPM := subFields[iSubField].dValue
      else if sfTag = 'CMNM' then
        fGDAT.fCMNM := subFields[iSubField].sValue
      else if sfTag = 'CMGL' then
        fGDAT.fCMGL := subFields[iSubField].dValue
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetVDATField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fVDAT: TVDATField): Boolean;
var
  iSubField: Integer;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'VDAT' then Exit;
  for iSubField := 0 to Length(subFields) - 1 do begin
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'DTNM' then
        fVDAT.fDTNM := subFields[iSubField].sValue
      else if sfTag = 'DTID' then
        fVDAT.fDTID := subFields[iSubField].sValue
      else if sfTag = 'DTSR' then
        fVDAT.fDTSR := subFields[iSubField].iValue
      else if sfTag = 'SCRI' then
        fVDAT.fSCRI := subFields[iSubField].sValue
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetIRIDField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fIRID: TIRIDField): Boolean;
var
  iSubField: Integer;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'IRID' then Exit;
  for iSubField := 0 to Length(subFields) - 1 do begin
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'RCNM' then
        fIRID.RCNM := subFields[iSubField].iValue
      else if sfTag = 'RCID' then
        fIRID.RCID := subFields[iSubField].iValue
      else if sfTag = 'NITC' then
        fIRID.NITC := subFields[iSubField].iValue
      else if sfTag = 'RVER' then
        fIRID.RVER := subFields[iSubField].iValue
      else if sfTag = 'RUIN' then
        fIRID.RUIN := subFields[iSubField].iValue
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetATTRField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fATTR: TATTRField): Boolean;
var
  iSubField, iElem: Integer;
begin
  Result := False;
  if (lrFieldDescription.fieldTag <> 'ATTR') or (Length(subFields) = 0) then
    Exit;
  SetLength(fATTR.arrayOfAttrElem, Length(subFields) div 5);
  iElem := 0;
  for iSubField := 0 to Length(subFields) - 1 do begin
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'NATC' then
        fATTR.arrayOfAttrElem[iElem].NATC := subFields[iSubField].iValue
      else if sfTag = 'ATIX' then
        fATTR.arrayOfAttrElem[iElem].ATIX := subFields[iSubField].iValue
      else if sfTag = 'PAIX' then
        fATTR.arrayOfAttrElem[iElem].PAIX := subFields[iSubField].iValue
      else if sfTag = 'ATIN' then
        fATTR.arrayOfAttrElem[iElem].ATIN := subFields[iSubField].iValue
      else if sfTag = 'ATVL' then begin
        fATTR.arrayOfAttrElem[iElem].ATVL := subFields[iSubField].sValue;
        iElem := iElem + 1;
      end
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetINASField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fINAS: TINASField): Boolean;
var
  iSubField, iElem: Integer;
begin
  Result := False;
  if (lrFieldDescription.fieldTag <> 'INAS') or (Length(subFields) = 0) then
    Exit;
  SetLength(fINAS.arrayOfAttrElem, (Length(subFields) - 5) div 5);
  iElem := 0;
  for iSubField := 0 to Length(subFields) - 1 do begin
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'RRNM' then
        fINAS.RRNM := subFields[iSubField].iValue
      else if sfTag = 'RRID' then
        fINAS.RRID := subFields[iSubField].iValue
      else if sfTag = 'NIAC' then
        fINAS.NIAC := subFields[iSubField].iValue
      else if sfTag = 'NARC' then
        fINAS.NARC := subFields[iSubField].iValue
      else if sfTag = 'IUIN' then
        fINAS.IUIN := subFields[iSubField].iValue
      else if sfTag = 'NATC' then
        fINAS.arrayOfAttrElem[iElem].NATC := subFields[iSubField].iValue
      else if sfTag = 'ATIX' then
        fINAS.arrayOfAttrElem[iElem].ATIX := subFields[iSubField].iValue
      else if sfTag = 'PAIX' then
        fINAS.arrayOfAttrElem[iElem].PAIX := subFields[iSubField].iValue
      else if sfTag = 'ATIN' then
        fINAS.arrayOfAttrElem[iElem].ATIN := subFields[iSubField].iValue
      else if sfTag = 'ATVL' then begin
        fINAS.arrayOfAttrElem[iElem].ATVL := subFields[iSubField].sValue;
        iElem := iElem + 1;
      end
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetPRIDField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fPRID: TPRIDField): Boolean;
var
  iSubField: Integer;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'PRID' then Exit;
  for iSubField := 0 to Length(subFields) - 1 do begin
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'RCNM' then
        fPRID.RCNM := subFields[iSubField].iValue
      else if sfTag = 'RCID' then
        fPRID.RCID := subFields[iSubField].iValue
      else if sfTag = 'RVER' then
        fPRID.RVER := subFields[iSubField].iValue
      else if sfTag = 'RUIN' then
        fPRID.RUIN := subFields[iSubField].iValue
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetC2ITField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fC2IT: TC2ITField): Boolean;
var
  iSubField: Integer;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'C2IT' then Exit;
  for iSubField := 0 to Length(subFields) - 1 do begin
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'YCOO' then
        fC2IT.YCOO := subFields[iSubField].iValue
      else if sfTag = 'XCOO' then
        fC2IT.XCOO := subFields[iSubField].iValue
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetC3ITField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fC3IT: TC3ITField): Boolean;
var
  iSubField: Integer;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'C3IT' then Exit;
  for iSubField := 0 to Length(subFields) - 1 do begin
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'VCID' then
        fC3IT.VCID := subFields[iSubField].iValue
      else if sfTag = 'YCOO' then
        fC3IT.YCOO := subFields[iSubField].iValue
      else if sfTag = 'XCOO' then
        fC3IT.XCOO := subFields[iSubField].iValue
      else if sfTag = 'ZCOO' then
        fC3IT.ZCOO := subFields[iSubField].iValue
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetC2FTField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fC2FT: TC2FTField): Boolean;
var
  iSubField: Integer;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'C2FT' then Exit;
  for iSubField := 0 to Length(subFields) - 1 do begin
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'YCOO' then
        fC2FT.YCOO := subFields[iSubField].dValue
      else if sfTag = 'XCOO' then
        fC2FT.XCOO := subFields[iSubField].dValue
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetC3FTField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fC3FT: TC3FTField): Boolean;
var
  iSubField: Integer;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'C3FT' then Exit;
  for iSubField := 0 to Length(subFields) - 1 do begin
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'VCID' then
        fC3FT.VCID := subFields[iSubField].iValue
      else if sfTag = 'YCOO' then
        fC3FT.YCOO := subFields[iSubField].dValue
      else if sfTag = 'XCOO' then
        fC3FT.XCOO := subFields[iSubField].dValue
      else if sfTag = 'ZCOO' then
        fC3FT.ZCOO := subFields[iSubField].dValue
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetC2ILField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fC2IL: TC2ILField): Boolean;
var
  iSubField, iTuple: Integer;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'C2IL' then Exit;
  SetLength(fC2IL.C2ITArray, Length(subFields) div 2);
  iTuple := -1;
  for iSubField := 0 to Length(subFields) - 1 do begin
    if not Odd(iSubField) then
      iTuple := iTuple + 1;
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'YCOO' then
        fC2IL.C2ITArray[iTuple].YCOO := subFields[iSubField].iValue
      else if sfTag = 'XCOO' then
        fC2IL.C2ITArray[iTuple].XCOO := subFields[iSubField].iValue
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetC3ILField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fC3IL: TC3ILField): Boolean;
var
  iSubField, iTuple: Integer;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'C3IL' then Exit;
  fC3IL.VCID := subFields[0].iValue;
  SetLength(fC3IL.C3ITArray, (Length(subFields) - 1) div 3);
  iTuple := -1;
  for iSubField := 1 to Length(subFields) - 1 do begin
    if ((iSubField - 1) mod 3) = 0 then
      iTuple := iTuple + 1;
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'YCOO' then
        fC3IL.C3ITArray[iTuple].YCOO := subFields[iSubField].iValue
      else if sfTag = 'XCOO' then
        fC3IL.C3ITArray[iTuple].XCOO := subFields[iSubField].iValue
      else if sfTag = 'ZCOO' then
        fC3IL.C3ITArray[iTuple].ZCOO := subFields[iSubField].iValue
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetC2FLField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fC2FL: TC2FLField): Boolean;
var
  iSubField, iTuple: Integer;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'C2FL' then Exit;
  SetLength(fC2FL.C2FTArray, Length(subFields) div 2);
  iTuple := -1;
  for iSubField := 0 to Length(subFields) - 1 do begin
    if not Odd(iSubField) then
      iTuple := iTuple + 1;
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'YCOO' then
        fC2FL.C2FTArray[iTuple].YCOO := subFields[iSubField].dValue
      else if sfTag = 'XCOO' then
        fC2FL.C2FTArray[iTuple].XCOO := subFields[iSubField].dValue
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetC3FLField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fC3FL: TC3FLField): Boolean;
var
  iSubField, iTuple: Integer;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'C3FL' then Exit;
  fC3FL.VCID := subFields[0].iValue;
  SetLength(fC3FL.C3FTArray, (Length(subFields) - 1) div 3);
  iTuple := -1;
  for iSubField := 1 to Length(subFields) - 1 do begin
    if ((iSubField - 1) mod 3) = 0 then
      iTuple := iTuple + 1;
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'YCOO' then
        fC3FL.C3FTArray[iTuple].YCOO := subFields[iSubField].dValue
      else if sfTag = 'XCOO' then
        fC3FL.C3FTArray[iTuple].XCOO := subFields[iSubField].dValue
      else if sfTag = 'ZCOO' then
        fC3FL.C3FTArray[iTuple].ZCOO := subFields[iSubField].dValue
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetMRIDField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fMRID: TMRIDField): Boolean;
var
  iSubField: Integer;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'MRID' then Exit;
  for iSubField := 0 to Length(subFields) - 1 do begin
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'RCNM' then
        fMRID.RCNM := subFields[iSubField].iValue
      else if sfTag = 'RCID' then
        fMRID.RCID := subFields[iSubField].iValue
      else if sfTag = 'RVER' then
        fMRID.RVER := subFields[iSubField].iValue
      else if sfTag = 'RUIN' then
        fMRID.RUIN := subFields[iSubField].iValue
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetCOCCField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fCOCC: TCOCCField): Boolean;
var
  iSubField: Integer;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'COCC' then Exit;
  for iSubField := 0 to Length(subFields) - 1 do begin
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'COUI' then
        fCOCC.COUI := subFields[iSubField].iValue
      else if sfTag = 'COIX' then
        fCOCC.COIX := subFields[iSubField].iValue
      else if sfTag = 'NCOR' then
        fCOCC.NCOR := subFields[iSubField].iValue
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetSEGHField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fSEGH: TSEGHField): Boolean;
var
  iSubField: Integer;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'SEGH' then Exit;
  for iSubField := 0 to Length(subFields) - 1 do begin
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'INTP' then
        fSEGH.INTP := subFields[iSubField].iValue
      else if sfTag = 'CIRC' then
        fSEGH.CIRC := subFields[iSubField].iValue
      else if sfTag = 'YCOO' then
        fSEGH.YCOO := subFields[iSubField].dValue
      else if sfTag = 'XCOO' then
        fSEGH.XCOO := subFields[iSubField].dValue
      else if sfTag = 'DIST' then
        fSEGH.DIST := subFields[iSubField].dValue
      else if sfTag = 'DISU' then
        fSEGH.DISU := subFields[iSubField].iValue
      else if sfTag = 'SBRG' then
        fSEGH.SBRG := subFields[iSubField].dValue
      else if sfTag = 'ANGL' then
        fSEGH.ANGL := subFields[iSubField].dValue
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetSECCField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fSECC: TSECCField): Boolean;
var
  iSubField: Integer;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'SEСС' then Exit;
  for iSubField := 0 to Length(subFields) - 1 do begin
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'SEUI' then
        fSECC.SEUI := subFields[iSubField].iValue
      else if sfTag = 'SEIX' then
        fSECC.SEIX := subFields[iSubField].iValue
      else if sfTag = 'NSEG' then
        fSECC.NSEG := subFields[iSubField].iValue
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetPTASField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fPTAS: TPTASField): Boolean;
var
  iSubField, iElemNo: Integer;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'PTAS' then Exit;
  SetLength(fPTAS.PTASArray, Length(subFields) div 3);
  iElemNo := -1;
  for iSubField := 0 to Length(subFields) - 1 do begin
    if (iSubField mod 3) = 0 then
      iElemNo := iElemNo + 1;
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'RRNM' then
        fPTAS.PTASArray[iElemNo].RRNM := subFields[iSubField].iValue
      else if sfTag = 'RRID' then
        fPTAS.PTASArray[iElemNo].RRID := subFields[iSubField].iValue
      else if sfTag = 'TOPI' then
        fPTAS.PTASArray[iElemNo].TOPI := subFields[iSubField].iValue
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetCRIDField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fCRID: TCRIDField): Boolean;
var
  iSubField: Integer;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'CRID' then Exit;
  for iSubField := 0 to Length(subFields) - 1 do begin
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'RCNM' then
        fCRID.RCNM := subFields[iSubField].iValue
      else if sfTag = 'RCID' then
        fCRID.RCID := subFields[iSubField].iValue
      else if sfTag = 'RVER' then
        fCRID.RVER := subFields[iSubField].iValue
      else if sfTag = 'RUIN' then
        fCRID.RUIN := subFields[iSubField].iValue
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetCCIDField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fCCID: TCCIDField): Boolean;
var
  iSubField: Integer;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'CCID' then Exit;
  for iSubField := 0 to Length(subFields) - 1 do begin
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'RCNM' then
        fCCID.RCNM := subFields[iSubField].iValue
      else if sfTag = 'RCID' then
        fCCID.RCID := subFields[iSubField].iValue
      else if sfTag = 'RVER' then
        fCCID.RVER := subFields[iSubField].iValue
      else if sfTag = 'RUIN' then
        fCCID.RUIN := subFields[iSubField].iValue
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetCCOCField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fCCOC: TCCOCField): Boolean;
var
  iSubField: Integer;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'CCOC' then Exit;
  for iSubField := 0 to Length(subFields) - 1 do begin
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'CCUI' then
        fCCOC.CCUI := subFields[iSubField].iValue
      else if sfTag = 'CCIX' then
        fCCOC.CCIX := subFields[iSubField].iValue
      else if sfTag = 'NCCO' then
        fCCOC.NCCO := subFields[iSubField].iValue
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetCUCOField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fCUCO: TCUCOField): Boolean;
var
  iSubField, iElemNo: Integer;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'CUCO' then Exit;
  SetLength(fCUCO.CUCOArray, Length(subFields) div 3);
  iElemNo := -1;
  for iSubField := 0 to Length(subFields) - 1 do begin
    if (iSubField mod 3) = 0 then
      iElemNo := iElemNo + 1;
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'RRNM' then
        fCUCO.CUCOArray[iElemNo].RRNM := subFields[iSubField].iValue
      else if sfTag = 'RRID' then
        fCUCO.CUCOArray[iElemNo].RRID := subFields[iSubField].iValue
      else if sfTag = 'ORNT' then
        fCUCO.CUCOArray[iElemNo].ORNT := subFields[iSubField].iValue
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetSRIDField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fSRID: TSRIDField): Boolean;
var
  iSubField: Integer;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'SRID' then Exit;
  for iSubField := 0 to Length(subFields) - 1 do begin
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'RCNM' then
        fSRID.RCNM := subFields[iSubField].iValue
      else if sfTag = 'RCID' then
        fSRID.RCID := subFields[iSubField].iValue
      else if sfTag = 'RVER' then
        fSRID.RVER := subFields[iSubField].iValue
      else if sfTag = 'RUIN' then
        fSRID.RUIN := subFields[iSubField].iValue
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetRIASField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fRIAS: TRIASField): Boolean;
var
  iSubField, iElemNo: Integer;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'RIAS' then Exit;
  SetLength(fRIAS.RIASArray, Length(subFields) div 5);
  iElemNo := -1;
  for iSubField := 0 to Length(subFields) - 1 do begin
    if (iSubField mod 5) = 0 then
      iElemNo := iElemNo + 1;
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'RRNM' then
        fRIAS.RIASArray[iElemNo].RRNM := subFields[iSubField].iValue
      else if sfTag = 'RRID' then
        fRIAS.RIASArray[iElemNo].RRID := subFields[iSubField].iValue
      else if sfTag = 'ORNT' then
        fRIAS.RIASArray[iElemNo].ORNT := subFields[iSubField].iValue
      else if sfTag = 'USAG' then
        fRIAS.RIASArray[iElemNo].USAG := subFields[iSubField].iValue
      else if sfTag = 'RAUI' then
        fRIAS.RIASArray[iElemNo].RAUI := subFields[iSubField].iValue
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetFRIDField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fFRID: TFRIDField): Boolean;
var
  iSubField: Integer;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'FRID' then Exit;
  for iSubField := 0 to Length(subFields) - 1 do begin
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'RCNM' then
        fFRID.RCNM := subFields[iSubField].iValue
      else if sfTag = 'RCID' then
        fFRID.RCID := subFields[iSubField].iValue
      else if sfTag = 'NFTC' then
        fFRID.NFTC := subFields[iSubField].iValue
      else if sfTag = 'RVER' then
        fFRID.RVER := subFields[iSubField].iValue
      else if sfTag = 'RUIN' then
        fFRID.RUIN := subFields[iSubField].iValue
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetFOIDField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fFOID: TFOIDField): Boolean;
var
  iSubField: Integer;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'FOID' then Exit;
  for iSubField := 0 to Length(subFields) - 1 do begin
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'AGEN' then
        fFOID.AGEN := subFields[iSubField].iValue
      else if sfTag = 'FIDN' then
        fFOID.FIDN := subFields[iSubField].iValue
      else if sfTag = 'FIDS' then
        fFOID.FIDS := subFields[iSubField].iValue
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetSPASField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fSPAS: TSPASField): Boolean;
var
  iSubField, iElemNo: Integer;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'SPAS' then Exit;
  SetLength(fSPAS.SPASArray, Length(subFields) div 6);
  iElemNo := -1;
  for iSubField := 0 to Length(subFields) - 1 do begin
    if (iSubField mod 6) = 0 then
      iElemNo := iElemNo + 1;
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'RRNM' then
        fSPAS.SPASArray[iElemNo].RRNM := subFields[iSubField].iValue
      else if sfTag = 'RRID' then
        fSPAS.SPASArray[iElemNo].RRID := subFields[iSubField].iValue
      else if sfTag = 'ORNT' then
        fSPAS.SPASArray[iElemNo].ORNT := subFields[iSubField].iValue
      else if sfTag = 'SMIN' then
        fSPAS.SPASArray[iElemNo].SMIN := subFields[iSubField].iValue
      else if sfTag = 'SMAX' then
        fSPAS.SPASArray[iElemNo].SMAX := subFields[iSubField].iValue
      else if sfTag = 'SAUI' then
        fSPAS.SPASArray[iElemNo].SAUI := subFields[iSubField].iValue
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetFASCField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fFASC: TFASCField): Boolean;
var
  iSubField, iElem: Integer;
begin
  Result := False;
  if (lrFieldDescription.fieldTag <> 'FASC') or (Length(subFields) = 0) then
    Exit;
  SetLength(fFASC.arrayOfAttrElem, (Length(subFields) - 5) div 5);
  iElem := 0;
  for iSubField := 0 to Length(subFields) - 1 do begin
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'RRNM' then
        fFASC.RRNM := subFields[iSubField].iValue
      else if sfTag = 'RRID' then
        fFASC.RRID := subFields[iSubField].iValue
      else if sfTag = 'NFAC' then
        fFASC.NFAC := subFields[iSubField].iValue
      else if sfTag = 'NARC' then
        fFASC.NARC := subFields[iSubField].iValue
      else if sfTag = 'FAUI' then
        fFASC.FAUI := subFields[iSubField].iValue
      else if sfTag = 'NATC' then
        fFASC.arrayOfAttrElem[iElem].NATC := subFields[iSubField].iValue
      else if sfTag = 'ATIX' then
        fFASC.arrayOfAttrElem[iElem].ATIX := subFields[iSubField].iValue
      else if sfTag = 'PAIX' then
        fFASC.arrayOfAttrElem[iElem].PAIX := subFields[iSubField].iValue
      else if sfTag = 'ATIN' then
        fFASC.arrayOfAttrElem[iElem].ATIN := subFields[iSubField].iValue
      else if sfTag = 'ATVL' then begin
        fFASC.arrayOfAttrElem[iElem].ATVL := subFields[iSubField].sValue;
        iElem := iElem + 1;
      end
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetTHASField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fTHAS: TTHASField): Boolean;
var
  iSubField, iElemNo: Integer;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'THAS' then Exit;
  SetLength(fTHAS.THASArray, Length(subFields) div 3);
  iElemNo := -1;
  for iSubField := 0 to Length(subFields) - 1 do begin
    if (iSubField mod 3) = 0 then
      iElemNo := iElemNo + 1;
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'RRNM' then
        fTHAS.THASArray[iElemNo].RRNM := subFields[iSubField].iValue
      else if sfTag = 'RRID' then
        fTHAS.THASArray[iElemNo].RRID := subFields[iSubField].iValue
      else if sfTag = 'TAUI' then
        fTHAS.THASArray[iElemNo].TAUI := subFields[iSubField].iValue
      else
        Exit;
    end;
  end;
  Result := True;
end;

function GetMASKField(lrFieldDescription: TLRFieldDescription; subFields: TLRSubfieldArray;
    var fMASK: TMASKField): Boolean;
var
  iSubField, iElemNo: Integer;
begin
  Result := False;
  if lrFieldDescription.fieldTag <> 'MASK' then Exit;
  SetLength(fMASK.MASKArray, Length(subFields) div 4);
  iElemNo := -1;
  for iSubField := 0 to Length(subFields) - 1 do begin
    if (iSubField mod 4) = 0 then
      iElemNo := iElemNo + 1;
    with lrFieldDescription.subfieldsDescriptions[subFields[iSubField].descrIndex] do begin
      if sfTag = 'RRNM' then
        fMASK.MASKArray[iElemNo].RRNM := subFields[iSubField].iValue
      else if sfTag = 'RRID' then
        fMASK.MASKArray[iElemNo].RRID := subFields[iSubField].iValue
      else if sfTag = 'MIND' then
        fMASK.MASKArray[iElemNo].MIND := subFields[iSubField].iValue
      else if sfTag = 'MUIN' then
        fMASK.MASKArray[iElemNo].MUIN := subFields[iSubField].iValue
      else
        Exit;
    end;
  end;
  Result := True;
end;

end.
