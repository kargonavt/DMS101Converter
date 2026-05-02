unit OTypes; interface

uses
  Windows,Classes;

const
  rus_interface: bool = true;
  dos_interface: bool = true;

  debug_enabled: bool = false;
  debug_enabled1: bool = false;
  debug_enabled2: bool = false;

  drag_Enabled: bool = true;
  ver_english: bool = false;
  txt_english: bool = false;
  log_enabled: bool = false;
  gdi_enabled: bool = false;
  pop_enabled: bool = false;
  mem_enabled: bool = false;

  view_interface: bool = false;
  lite_interface: bool = false;
  stat_interface: bool = false;
  demo_interface: bool = false;
  test_interface: bool = false;

  cuba_enabled: bool = false;

  IsWin32: Boolean = true;
  IsOcx: Boolean = false;

  ansi_draw: Boolean = false;
  ansi_pack: Boolean = false;

  IsDlg: bool = false;

  InterfaceIndex: Integer = 0;

  ClsId_Null: TGUID = '{00000000-0000-0000-0000-000000000000}';

  sPlus: array[Boolean] of Char = '-+';

  ibool: array[Boolean] of Integer = (0,1);
  sbool: array[Boolean] of String[7] = ('FALSE','OK');

  ClientCount: Integer = 0;

  LPoly_Max = 511;
  fsNumStr = 16;

  Small = 1E-6;

  Orient_Max = 6;
  Value_Max  = 32;

  Unicode_Max = 1023;
  Vector_Max  = 1023;

  Int_NAN = -999999999;
  Int_NAN1 = Int_NAN+1;
  Int_NAN2 = Int_NAN+2;
  Int_NAN3 = Int_NAN+3;

  WinOS: Integer = 0;

  use_fastMM: longbool = false;

type
  b11 = Byte;
  b12 = Word;
  b14 = Cardinal;
  long = Longint;

  int   = Longint;
  uint  = DWord;
  Int16 = SmallInt;

  uint16 = Word;
  uint32 = DWord;
  int32 = Longint;

  ulong = DWord;
  ushort = Word;
  short = int16;

  Float = Single;
  PFloat = ^Float;

  Char = AnsiChar;
  PChar = PAnsiChar;

  tbyte_set = set of byte;
  tchar_set = set of char;

  alfa = array[1..8] of Char;
  alpha = array[1..16] of Char;
  Char2 = array[1..2] of Char;
  Char3 = array[1..3] of Char;
  Char4 = array[1..4] of Char;
  Char5 = array[1..5] of Char;
  Char6 = array[1..6] of Char;
  Char7 = array[1..7] of Char;
  Char8 = array[1..8] of Char;
  Char9 = array[1..9] of Char;

  char10 = array[1..10] of Char;
  char12 = array[1..12] of Char;
  char15 = array[1..15] of Char;
  char16 = array[1..16] of Char;
  char20 = array[1..20] of Char;
  char31 = array[1..31] of Char;
  char32 = array[1..32] of Char;
  char80 = array[1..80] of Char;

  TRational = record c1,c2: longint end;

  ttick = uint;

  PBools = ^TBools;
  TBools = array[0..63] of Boolean;

  PBytes = ^TBytes;
  TBytes = array[0..1023] of Byte;

  TByte8  = array[0..7] of Byte;
  TByte11 = Array[0..10] of byte;
  TByte16 = array[0..15] of Byte;
  TByte32 = Array[0..31] of byte;

  TWord8  = array[0..7] of Word;

  PWords = ^TWords;
  TWords = array[0..1023] of Word;

  PSmallints = ^TSmallints;
  TSmallints = array[0..1023] of Smallint;

  PIntegers = ^TIntegers;
  TIntegers = array[0..1023] of Integer;

  PUInts = ^TUInts;
  TUInts = array[0..1023] of uint;

  PDWords = ^TDWords;
  TDWords = array[0..1023] of DWord;

  PPointers = ^TPointers;
  TPointers = array[0..1023] of PBytes;

  PPointerArray = ^TPointerArray;
  TPointerArray = array[0..1023] of Pointer;

  TInt32 = Array[0..31] of uint;

  PInt64s = ^TInt64s;
  TInt64s = array[0..1023] of Int64;

  PPool = ^TPool;
  TPool = record Len: word; Buf: tbytes end;

  PHeights = ^THeights;
  THeights = array[0..LPoly_Max] of Integer;

  PLongBuf = ^TLongBuf;
  TLongBuf = array[0..4096] of Byte;

  TAlfaStr = array[0..31] of Char;
  TNameStr = array[0..31] of Char;
  TNameStr1 = array[0..63] of Char;
  TNameStr2 = array[0..127] of Char;
  TShortStr = array[0..255] of Char;
  TPathStr = array[0..511] of Char;

  TCmdStr = array[0..1023] of Char;
  THexStr = array[0..1023] of Char;

  TNameStrW  = array[0..31] of WideChar;
  TNameStrW1 = array[0..63] of WideChar;
  TWideStr   = array[0..255] of WideChar;
  TUnicode   = array[0..1023] of WideChar;

  PLongStr = ^TLongStr;
  TLongStr = array[0..8191] of Char;

  str8 = Array[0..7] of Char;
  str16 = Array[0..15] of Char;
  str32 = Array[0..31] of Char;
  str48 = Array[0..47] of Char;
  str64 = Array[0..63] of Char;
  str80 = Array[0..79] of Char;

  TMapView = record
    h: THandle; p: PBytes;
    size: Int64;
  end;

  PFloats = ^TFloats;
  TFloats = array[0..1023] of Float;

  PSingles = ^TSingles;
  TSingles = array[0..1023] of Single;

  PDoubles = ^TDoubles;
  TDoubles = array[0..1023] of Double;

  XRect = record x,y,w,h: Integer end;

  TRectf = record x1,y1,x2,y2: float end;

  TRectd = record x1,y1,x2,y2: double end;

  PGauss = ^TGauss;
  PVPoint = ^VPoint;
  PRange = ^TRange;

  WPoint = record x,y: Word end;
  IPoint = record x,y: SmallInt end;
  TGauss = record x,y: Double end;
  TRange = record min,max: Double end;
  TGeoid = record b,l: Double end;
  VPoint = record x,y,z: Integer end;
  TPoint64 = record x,y: Int64 end;

  PPort2d = ^TPort2d;
  TPort2d = record case Integer of
0:(x,y,w,h: Double); 1:(o,s: TGauss);
  end;

  PPort2i = ^TPort2i;
  TPort2i = record x,y,w,h: int end;

  PDatum = ^TDatum; TDatum = VPoint;

  PDatum7 = ^TDatum7;
  TDatum7 = record
    dX,dY,dZ,wX,wY,wZ,m: Double;
  end;

  PDatums = ^TDatums;
  TDatums = Array[0..255] of TDatum7;

  pxyf = ^txyf;
  txyf = record x,y: float end;

  pxyzf = ^txyzf;
  txyzf = record x,y,z: float end;

  pxyz = ^txyz;
  txyz = record x,y,z: Double end;

  pxyz_array = ^txyz_array;
  txyz_array = array[0..1023] of txyz;

  txyz_vector = array[0..1] of txyz;
  txyz_orient = array[0..7] of txyz;

  XPoint = record
    p: TPoint; g: TGauss
  end;

  psys3 = ^tsys3;
  tsys3 = record
    pps,prj,elp: Integer;
    b1,b2,lc: Double;
    dat: TDatum; rn: Double;
  end;

  psys = ^tsys; tsys = record
    pps,prj,elp: Integer;
    lc,b1,b2,b3,k0,rn,x0,y0: Double;
    dat: TDatum7
  end;

  xgeoid = record
    x,y: Double; s: tsys
  end;

  PGeoPoint = ^TGeoPoint;
  TGeoPoint = xgeoid;

  lxyz = record case integer of
0: (p: TPoint); 1: (v: VPoint)
  end;

  LRect = record case integer of
0: (Left,Top,Right,Bottom: Integer);
1: (lt,rb: TPoint);
  end;

  TVector = array[0..1] of TPoint;
  LVector = array[0..1] of TPoint;
  GVector = array[0..1] of TGauss;
  VVector = array[0..1] of VPoint;

  TDouble = record case integer of
0: (d: Double);
1: (f: single);
2: (l: Longint);
3: (i: SmallInt);
4: (x: Int64);
5: (w: Word);
6: (b: Byte);
7: (v: Array[0..7] of Byte);
  end;

  TInt64 = record case integer of
0: (x: Int64);
1: (c: array[0..1] of Cardinal);
2: (i: array[0..1] of Integer);
3: (p: array[0..1] of Pointer);
4: (w: array[0..3] of Word);
5: (s: array[0..3] of SmallInt);
6: (b: array[0..7] of Byte);
7: (w1: Word; c1: Cardinal; w2: Word);
8: (dx,dy,dz,dw: SmallInt);
9: (id,cn: Cardinal);
10:(i0,i1: int)
  end;

  tlong = record case integer of
0: (i: Longint);
1: (p: PBytes);
2: (c: Cardinal);
3: (w: array[0..1] of Word);
4: (s: array[0..1] of SmallInt);
5: (b: array[0..3] of Byte);
6: (f: single)
  end;

  TWord = record case integer of
0:  (b: array[0..1] of Byte);
1:  (w: Word)
  end;

  PString = ^TString;
  TString = record case integer of
0: (x: TWideStr);
1: (s: ShortString);
2: (ci: TShortStr);
3: (d: Double);
4: (f: single);
5: (i64: int64);
6: (l: Longint);
7: (i: SmallInt);
8: (w: Word);
9: (b: Byte);
  end;

  TOrient = array[0..Orient_Max-1] of TPoint;
  WOrient = array[0..Orient_Max-1] of WPoint;
  LOrient = array[0..Orient_Max-1] of TPoint;
  GOrient = array[0..Orient_Max-1] of TGauss;
  VOrient = array[0..Orient_Max-1] of VPoint;
  XOrient = array[0..Orient_Max-1] of XGeoid;
  ZOrient = array[0..Orient_Max-1] of Longint;

  IValues = array[0..Orient_Max-1] of Integer;
  ZValues = array[0..Orient_Max-1] of Double;
  RValues = array[0..Orient_Max-1] of Float;
  DValues = array[0..Value_Max-1] of Double;

  TPoints4 = array[0..3] of TPoint;
  TPoints8 = array[0..7] of TPoint;
  TPoints16 = array[0..15] of TPoint;
  TPoints32 = array[0..31] of TPoint;
  TPoints64 = array[0..63] of TPoint;
  TPoints256 = array[0..255] of TPoint;

  word2  = Array[0..1] of word;

  int2s  = Array[0..1] of int;
  int3s  = Array[0..2] of int;
  int16s = Array[0..15] of int;

  IValues3 = array[0..2] of Integer;
  IValues4 = array[0..3] of Integer;
  IValues8 = array[0..7] of Integer;
  IValues16 = array[0..15] of Integer;
  IValues32 = array[0..31] of Integer;
  IValues64 = array[0..63] of Integer;
  IValues128 = array[0..127] of Integer;
  IValues256 = array[0..255] of Integer;

  LValues4 = array[0..3] of int64;
  LValues8 = array[0..7] of int64;
  LValues16 = array[0..15] of int64;
  LValues32 = array[0..31] of int64;
  LValues256 = array[0..255] of int64;

  floats3 = array[0..2] of float;
  floats4 = array[0..3] of float;
  floats8 = array[0..7] of float;
  floats9 = array[0..8] of float;
  floats16 = array[0..15] of float;

  doubles2 = array[0..1] of double;
  doubles3 = array[0..2] of double;
  doubles4 = array[0..3] of double;
  doubles6 = array[0..5] of double;
  doubles8 = array[0..7] of double;
  doubles16 = array[0..15] of double;
  doubles32 = array[0..31] of double;
  doubles64 = array[0..63] of double;
  doubles128 = array[0..127] of double;
  doubles256 = array[0..255] of double;

  TPoint3  = Array[0..2] of TPoint;
  TPoint4  = Array[0..3] of TPoint;
  TPoint8  = Array[0..7] of TPoint;
  TPoint16 = Array[0..15] of TPoint;
  TPoint32 = Array[0..31] of TPoint;

  VPoint3 = Array[0..2] of VPoint;
  VPoint4 = Array[0..3] of VPoint;
  VPoint8 = Array[0..7] of VPoint;
  VPoint16 = Array[0..15] of VPoint;

  TGauss3  = Array[0..2] of TGauss;
  TGauss4  = Array[0..3] of TGauss;
  TGauss16 = Array[0..15] of TGauss;
  TGauss32 = Array[0..31] of TGauss;

  tkvParams16 = record
    k: IValues16;
    v: doubles16
  end;

  xyz16 = Array[0..7] of txyz;

  TMoments = Array[0..2] of Double;

  XYZOrient = array[0..Orient_Max-1] of txyz;

  GCross = array[0..8] of TGauss;
  TCross = array[0..8] of TPoint;

  PXPoly = ^XOrient;

  PPoly = ^TPoly;
  TPoly = array[0..LPoly_Max] of TPoint;

  PWPoly = ^TWPoly;
  TWPoly = array[0..LPoly_Max] of WPoint;

  PIPoly = ^TIPoly;
  TIPoly = array[0..LPoly_Max] of IPoint;

  PLPoly = PPoly;
  TLPoly = array[0..LPoly_Max] of TPoint;

  PGPoly = ^TGPoly;
  TGPoly = array[0..LPoly_Max] of TGauss;

  PVPoly = ^TVPoly;
  TVPoly = array[0..LPoly_Max] of VPoint;

  PXyzPoly = pxyz_array;
  TXyzPoly = array[0..LPoly_Max] of txyz;

  PLine = ^TLine;
  TLine = record N: Integer; Pol: TPoly end;

  PWLine = ^TWLine;
  TWLine = record N: Integer; Pol: TWPoly end;

  PLLine = ^TLLine;
  TLLine = packed record N: SmallInt; Pol: TLPoly end;
  VLLine = packed record N: SmallInt; Pol: LOrient end;
  CLLine = packed record N: SmallInt; Pol: TCross end;

  PPolyLine = ^TPolyLine;
  TPolyLine = record N: Integer; Pol: TLPoly end;

  PVLine = ^TVLine;
  TVLine = record N: Integer; Pol: TVPoly end;

  PGLine = ^TGLine;
  TGLine = record N: Integer; Pol: GOrient end;

  PXLine = ^TXLine;
  TXLine = record N: Integer; Pol: TGPoly end;

  TVBound = record N: Integer; Pol: VOrient end;

  PRealVec = ^TRealVec;
  TRealVec = array[0..1023] of Float;

  TNumStr = array[0..fsNumStr-1] of Char;
  PNumStr = ^TNumStr;

  TChannel = array[0..255] of Byte;
  thChannel = array[0..15] of Byte;

  PIndex = ^TIndex;
  TIndex = array[0..4095] of Longint;

  TRGBQuads = array[0..255] of TRGBQuad;
  PRGBQuads = ^TRGBQuads;

  TRGB_Rec = packed record r,g,b: Byte end;
  TRGB_Tbl = packed array[0..255] of TRGB_Rec;
  PRGB_Tbl = ^TRGB_Tbl;

  PColors = ^TColors;
  TColors = array[0..255] of TColorRef;

  THexColors = array[0..15] of TColorRef;
  PHexColors = ^THexColors;

  TDmwColors = array[0..31] of TColorRef;
  PDmwColors = ^TDmwColors;

  PPaletteChanel = ^TPaletteChanel;
  TPaletteChanel = array[0..255] of Word;

  PFillMask = ^TFillMask;
  TFillMask = array[0..15] of Word;

  PFillMasks = ^TFillMasks;
  TFillMasks = array[0..63] of TFillMask;

  TRGB_hist = array[0..255] of Integer;

  TMixedColor = record cl,lo,hi: TColorRef end;

  PMixedColors = ^TMixedColors;
  TMixedColors = array[0..63] of TMixedColor;

  PHost = ^THost;
  THost = record IP,Port: dword end;

  TTriWord = array[0..2] of Word;
  TTriWords = array[0..1023] of TTriWord;
  PTriWords = ^TTriWords;

  TCmyk = record c,m,y,k: Double end;
  thsv = record h,s,v: Double end;

  TEventProc = procedure of object;
  TEventFunc = function(Sender: TObject): HResult of object;
  TPointerProc = procedure(p: Pointer) of object;
  TPointerProc1 = procedure(I: Integer; P: Pointer) of object;
  TPointerNext = function(p: Pointer): Pointer of object;
  TPointerFunc = function(p: Pointer): Boolean of object;

  TBufProc = procedure(Sender: TObject; bp: PBytes; len: int) of object;
  TBufProc1 = procedure(Buf: Pointer; len,typ,tick: int) of object;

  TBoolFunc = function(Sender: TObject): Boolean of object;
  TBoolProc = procedure(Sender: TObject; Fl: Boolean) of object;

  TLogProc = procedure(const Str: String) of object;

  TCharProc = procedure(Sender: TObject; Str: PChar) of object;
  TCharProcI = procedure(Id: Integer; Str: PChar) of object;
  TCharFuncI = function(Str: PChar; Id: int): PChar of object;
  TCharProc2 = procedure(Sender: TObject; Str1,Str2: PChar) of object;
  TDblProc = procedure(Sender: TObject; Dbl: Boolean) of object;

  TCharFunc = function(Str: PChar): PChar of object;
  TStrFuncI = function(Str: PChar): Integer of object;

  TPointProc = procedure(Sender: TObject; const p: TPoint) of object;

  TLPolyProc = procedure(lp: PLPoly; lp_n: Integer) of object;
  TLPolyFunc = function(lp: PLPoly; lp_n: Integer): Integer of object;

  TLPolyProc1 = procedure(lp: PLPoly; hp: PIntegers;
                          lp_n: Integer) of object;

  TLLineProc = procedure(lp: PLLine) of object;
  TLLineFunc = function(lp: PLLine): Integer of object;

  TLLineProc1 = procedure(lp: PLLine; hp: PIntegers) of object;

  TGetInteger = function(Sender: TObject): Integer of object;
  TSetInteger = procedure(Sender: TObject; V: Integer) of object;
  TValueProcI = procedure(Sender: TObject; V: PIntegers) of object;
  TDataProcI = procedure(Sender: TObject; V: PIntegers; N: int) of object;

  TGetIntv = function(ip: PIntegers; ipMax: int): int of object;
  TGetInt64v = function(ip: PInt64s; ipMax: int): int of object;

  TValueProc = procedure(Sender: TObject; V: Double) of object;
  TValueProc2 = procedure(Sender: TObject; V1,V2: Double) of object;
  TValueFunc = function(Sender: TObject; var V: Double): Boolean of object;

  TValueProcN = procedure(Sender: TObject; V: PDoubles) of object;
  TValueFuncN = function(Sender: TObject; V: PDoubles): int of object;

  TValueProcN1 = procedure(Sender: TObject;
                           V: PDoubles;
                           I: PIntegers) of object;

  THandleProc = procedure(H: THandle) of object;

  TFloatProc = procedure(V: Float) of object;
  TFloatProcN = procedure(VP: PFloats) of object;

  TIntegerProc = procedure(V: int) of object;
  TIntegerFunc = function(V: int): Boolean of object;
  TIntegerFunci = function(V: int): int of object;
  TIntegerFunc2 = function(V1,V2: int): int of object;
  TIntegerProc2 = procedure(V1,V2: int) of object;
  TIntegerProc3 = procedure(V1,V2,V3: int) of object;
  TIntegerProc4 = procedure(V1,V2,V3,V4: int) of object;
  TIntegerProcN = procedure(ip: PIntegers) of object;
  TPixelProc = procedure(X,Y: Integer) of object;

  TIntProcN = procedure(Sender: TObject; ip: PIntegers) of object;

  TRectProc = procedure(Sender: TObject; const Rect: TRect) of object;

  VPointFunc = function(vp: PVPoly; N: Integer): Integer of object;

  TGaussFunc = function(gp: PGPoly; N: Integer): Integer of object;

  TGaussProc = procedure(Sender: TObject; rgn: PGPoly; rgnN: int) of object;

  TXyzFunc = function(vp: pxyz_array; N: Integer): Integer of object;

  TProjectFunc = function(x,y: Double; pps: Integer): TPoint of object;

  TIntfFunc = function(out Obj): HResult of object;

  TGeoProc = procedure(const G: TGeoPoint) of object;
  TGeoProcp = procedure(Sender: TObject; G: PGeoPoint) of object;

  TAllocMem = function(size: int): Pointer; stdcall;
  TReallocMem = function(Ptr: Pointer; size: int): Pointer; stdcall;
  TFreeMem = function(Ptr: Pointer): int; stdcall;
  TSizeMem = function(Ptr: Pointer): int; stdcall;
  TSetError = function(Str: PChar; MaxLen: int): int; stdcall;

  TAbstractSocket = class
    procedure Send(Data: Pointer; DataLen: int); virtual; abstract;
  end;

  PMM = ^TMM;
  TMM = record
    alloc: TAllocMem;
    realloc: TReallocMem;
    free: TFreeMem;
    getSize: TSizeMem;
    error: TSetError
  end;

const
  gsSolid = 0;
  gsHorz  = 1;
  gsVert  = 2;
  gsBack  = 3;
  gsForw  = 4;
  gsGrid  = 5;
  gsCross = 6;

  HexBit: array[0..15] of Word =
  ($8000,$4000,$2000,$1000,$0800,$0400,$0200,$0100,
   $0080,$0040,$0020,$0010,$0008,$0004,$0002,$0001);

  cFillMask: array[0..15] of TFillMask =
    (($FFFF,$FFFF,$FFFF,$FFFF, {0}
      $FFFF,$FFFF,$FFFF,$FFFF,
      $FFFF,$FFFF,$FFFF,$FFFF,
      $FFFF,$FFFF,$FFFF,$FFFF),

     ($FFFF,$0000,$0000,$0000, {1}
      $0000,$0000,$0000,$0000,
      $FFFF,$0000,$0000,$0000,
      $0000,$0000,$0000,$0000),

     ($8080,$8080,$8080,$8080, {2}
      $8080,$8080,$8080,$8080,
      $8080,$8080,$8080,$8080,
      $8080,$8080,$8080,$8080),

     ($8080,$4040,$2020,$1010, {3}
      $0808,$0404,$0202,$0101,
      $8080,$4040,$2020,$1010,
      $0808,$0404,$0202,$0101),

     ($0101,$0202,$0404,$0808, {4}
      $1010,$2020,$4040,$8080,
      $0101,$0202,$0404,$0808,
      $1010,$2020,$4040,$8080),

     ($FFFF,$8080,$8080,$8080, {5}
      $8080,$8080,$8080,$8080,
      $FFFF,$8080,$8080,$8080,
      $8080,$8080,$8080,$8080),

     ($8181,$4242,$2424,$1818, {6}
      $1818,$2424,$4242,$8181,
      $8181,$4242,$2424,$1818,
      $1818,$2424,$4242,$8181),

     ($0000,$0000,$0000,$0000, {7}
      $0000,$0000,$0000,$0000,
      $0000,$0000,$0000,$0000,
      $0000,$0000,$0000,$0000),

     ($AAAA,$0000,$5555,$0000, {8}
      $AAAA,$0000,$5555,$0000,
      $AAAA,$0000,$5555,$0000,
      $AAAA,$0000,$5555,$0000),

     ($FFFF,$0000,$0000,$0000, {9}
      $FFFF,$0000,$0000,$0000,
      $FFFF,$0000,$0000,$0000,
      $FFFF,$0000,$0000,$0000),

     ($8888,$8888,$8888,$8888, {A}
      $8888,$8888,$8888,$8888,
      $8888,$8888,$8888,$8888,
      $8888,$8888,$8888,$8888),

     ($8888,$4444,$2222,$1111, {B}
      $8888,$4444,$2222,$1111,
      $8888,$4444,$2222,$1111,
      $8888,$4444,$2222,$1111),

     ($1111,$2222,$4444,$8888, {C}
      $1111,$2222,$4444,$8888,
      $1111,$2222,$4444,$8888,
      $1111,$2222,$4444,$8888),

     ($FFFF,$8888,$8888,$8888, {D}
      $FFFF,$8888,$8888,$8888,
      $FFFF,$8888,$8888,$8888,
      $FFFF,$8888,$8888,$8888),

     ($8888,$0000,$2222,$0000, {E}
      $8888,$0000,$2222,$0000,
      $8888,$0000,$2222,$0000,
      $8888,$0000,$2222,$0000),

     ($8080,$0000,$0000,$0000, {F}
      $0808,$0000,$0000,$0000,
      $8080,$0000,$0000,$0000,
      $0808,$0000,$0000,$0000));

  EGA_Colors: THexColors =
    ($00000000,
     $007F0000,
     $00007F00,
     $007F7F00,
     $0000007F,
     $007F007F,
     $00007F7F,
     $00C0C0C0,
     $007F7F7F,
     $00FF0000,
     $0000FF00,
     $00FFFF00,
     $000000FF,
     $00FF00FF,
     $0000FFFF,
     $00FFFFFF);

  EGA_Quads: array[0..15] of Longint =
    ($00000000,
     $0000007F,
     $00007F00,
     $00007F7F,
     $007F0000,
     $007F007F,
     $007F7F00,
     $00C0C0C0,
     $007F7F7F,
     $000000FF,
     $0000FF00,
     $0000FFFF,
     $00FF0000,
     $00FF00FF,
     $00FFFF00,
     $00FFFFFF);

var
  sys_CYCaption: Integer;
  sys_CXVScroll: Integer;
  sys_CYHScroll: Integer;

  heap_mem: int;
  alloc_mem: int;
  vfile_mem: int;

  winErrCode: uint;
  winErrStr: TShortstr;

  _ErrCode: int;

function Notify(Sender: TObject; ev: TNotifyEvent): Boolean;

procedure Reset_ansi;

function Host(IP,Port: dword): THost;

function xFloat(f: Double): float;

function xEqual(f1,f2: Double): Boolean;
function eps_Equal(f1,f2,eps: Double): Boolean;

function _mult(i1,i2: Integer): Int64;
function _int64(i0,i1: Integer): Int64;

function Long_Words(w1,w2: Integer): Integer;
function Long_Bytes(b0,b1,b2,b3: Integer): Integer;

function _Magic(Magic: PChar): int;

function _Range(min,max: Double): TRange;
procedure Range_inc(var r: TRange; v: Double);

function Gauss_nil: TGauss;

function _Geoid(b,l: Double): TGeoid;
function _Gauss(x,y: Double): TGauss;

function _XPoint(x,y: Integer): XPoint;
function _LPoint(x,y: Integer): TPoint;
function _VPoint(x,y,z: Integer): VPoint;
function _lxyz(x,y,z: Double): VPoint;

function _LGauss(x,y: Double): TPoint;
function _IGauss(const g: TGauss): TPoint;

function _XRect(x,y,w,h: Integer): XRect;
function XRectContains(const R: XRect; X,Y: int): bool;

function Rectf(x1,y1,x2,y2: float): TRectf;

function Port2i(x,y,w,h: int): TPort2i;

function Port2d(x,y,w,h: Double): TPort2d;

function _cmyk(c,m,y,k: Double): TCmyk;

function dat7_dat3(const dat: TDatum7): TDatum;
function dat3_dat7(const dat: TDatum): TDatum7;

function sys3_sys7(const s: tsys3): tsys;

function sys7(pps,prj,elp: int; b1,b2,lc: Double): tsys;

function sys_nil: tsys;
function sys3_nil: tsys3;

function sys_wgs84: tsys;
function sys_ru42: tsys;
function sys_ru95: tsys;

function sys_gk(lc: double): tsys;
function sys_utm(lc: double): tsys;

function GeoPoint(x,y: Double; sys: psys): TGeoPoint;
function GeoPoint_nil: TGeoPoint;

function _xyz(x,y,z: Double): txyz;
function _xyzf(x,y,z: float): txyzf;
function _xyf(x,y: float): txyf;

function xyz_xyzf(const v: txyz): txyzf;

function xy_Point(const v: vpoint): TPoint;

function _Locator(X,Y,R: Integer): TRect;

function Range_radius(const r: trange): Double;

procedure _GOrient(Dst,Src: PGPoly);

procedure Datum_norm(var v: TDatum7);
procedure Datum_disp(var v: TDatum7);

function Datum7(dX,dY,dZ,wx,wy,wz,m: Double): TDatum7;
function cDatum7(dX,dY,dZ,wx,wy,wz,m: Double): TDatum7;
function IsDatum7(Dat: PDatum7): Boolean;

function nil_Datum7: TDatum7;

function cu_Datum: TDatum7;

function ru42_Datum: TDatum7;
function ru42_Datum1: TDatum7;
function ru42_Datum2: TDatum7;

function ru95_Datum: TDatum7;

function swe_Datum: TDatum7;

function ru_elp: tsys;

function Is_ru42_Datum(const dat: TDatum7): Boolean;
function is_nil_Datum7(const dat: TDatum7): Boolean;

function datum_Equals(const d1,d2: TDatum7): Boolean;
function dat_Equal(const s1,s2: tsys): Boolean;
function elp_Equal(elp1,elp2: Integer): Boolean;
function sys_plan(const s: tsys): Boolean;

procedure begin_mem_stat(s: PIntegers);
function end_mem_stat(s: PIntegers): int;

function xGetMem(size: int): pointer;
function zGetMem(size: int): pointer;
function xFreeMem(p: pointer; size: int): pointer;

procedure setMM(const aMM: TMM); stdcall;
function VerifyMM: int;

function xAllocPtr(size: int): pointer;
function xReAllocPtr(P: Pointer; size: int): Pointer;
function xFreePtr(P: Pointer): pointer;

function xAllocInt(n: Integer): PIntegers;
function xReallocInt(P: PIntegers; n: Integer): PIntegers;

function xAllocWords(n: Integer): PWords;
function xAllocDWords(n: Integer): PDWords;
function xAllocInt64(n: Integer): PInt64s;
function xAllocDoubles(n: Integer): PDoubles;
function xAllocFloats(n: Integer): PFloats;

function xAllocLPoints(n: Integer): PLPoly;
function xReallocLPoints(P: PLPoly; n: Integer): PLPoly;

function xAllocVPoints(n: Integer): PVPoly;
function xReallocVPoints(P: PVPoly; n: Integer): PVPoly;

function xAllocGauss(n: Integer): PGPoly;
function xReallocGauss(P: PGPoly; n: Integer): PGPoly;

function Alloc_LLine(n: Integer): PLLine;
function Alloc_VLLine(n: Integer): PVLine;

function Realloc_LLine(lp: PLLine; n: Integer): PLLine;

function Alloc_PolyLine(n: Integer): PPolyLine;

function Alloc_ZLine(out lp_z: PIntegers;
                     lp_max: Integer): PLLine;

function xResizeBuf(Buf: Pointer; NewSize: Integer;
                    var BufSize: Integer): Pointer;

function xResizeInt(Buf: Pointer; NewCount: Integer;
                    var BufCount: Integer): Pointer;

function xAllocFile(len: Integer; out vm: TMapView): pointer;
function xReadOnlyFile(h: Integer; out vm: TMapView): pointer;
function xUpdateFile(h: Integer; out vm: TMapView): Pointer;
procedure xFreeFile(var vm: TMapView);

function xCreateFileMap(len: Integer; fn: PChar;
                        out vm: TMapView): Pointer;

function xOpenFileMap(fn: PChar; out vm: TMapView): Pointer;

function GetTotalMemorySize: DWord;
function GetAvailMemorySize: DWord;

function xResolution(w,h: Double): Double;

function xDeviceRatio(Dev: HDC): Double;
function xDevice_dpi(DC: HDC): Integer;
function xDeviceAspect(DC: HDC): Double;

function MetersPerPixel(DC: HDC): Double;
function xMetersPerPixel: Double;

function PixelsPerMeter(DC: HDC): TGauss;
function xPixelsPerMeter: TGauss;
function xDeviceDpi: Integer;

function xDeviceStep(Dev: HDC; st: Integer): Integer;

function BitsPerPixel(DC: hDC): Integer;
function xBitsPerPixel: Integer;

function xCreateCompatibleBitMap(Width,Height: integer): hBitMap;

function xPixels(dist,scale: Double): Longint;
function xPenThick(DC: HDC; mm: Float): Integer;

function Param_key(key: PChar): Boolean;

function Param_Option(opt: PChar): Boolean;
function xParamCount: Integer;

function Param_valuei(def,min,max: int; Name: PChar): int;
function Param_valuef(def,min,max: float; Name: PChar): float;

function xRange(i, a,b: Double): Double;
function iRange(i, a,b: Integer): Integer;

function iIndex(ind,max: Integer): Integer;

procedure xmove(si,di: PBytes; len: Integer);

function Int3(P: Pointer): Integer;

procedure oSwap(var o1,o2);
procedure pSwap(var p1,p2: Pointer);
procedure iSwap(var a,b: Integer);
procedure cSwap(var a,b: Cardinal);
procedure wSwap(var a,b: Word);
procedure sSwap(var a,b: Smallint);
procedure xSwap(var a,b: Double);
procedure fSwap(var a,b: Float);
procedure bSwap(var a,b: Byte);
procedure iSwap64(var a,b: int64);

function Long2i(a,b: Integer): Longint;

function xBytesCount(bp: PBytes; N: Integer): Integer;

function xCountersCount(cp: PIntegers; N: Integer): Int64;

function CountersCount(cp: PIntegers; N: Integer): Integer;
function CountersMax(cp: PIntegers; N: Integer): Integer;

function IntegersAve(lp: PIntegers; N: Integer): Integer;

function Channel_Indexof(Chan: PBytes; Count: Integer;
                         Item: Integer): Integer;

function Int_Contains(Items: PIntegers; Count: Integer;
                      Item: Integer): Integer;

function Int_Delete(Items: PIntegers; Count,Index: int): int;

function lp_Contains_Index(lp: PLLine;
                           Id: Integer): Integer;

function Index_Contains(Items: PInt64s; Count: Integer;
                        Id: Integer): Integer;

function x_Index_Contains(Items: PInt64s; Count: Integer;
                          Id: Integer): Integer;

procedure int_MinMax(vp: PIntegers; N: Integer;
                     min,max: PInteger);

procedure words_MinMax(vp: PWords; N: Integer;
                       out vmin,vmax: Integer);

procedure small_MinMax(vp: PSmallInts; N: Integer;
                       out vmin,vmax: Integer);

procedure bytes_MinMax(vp: PBytes; N: Integer;
                       out vmin,vmax: Integer);
                       
function z_axe_ptr(hp: PIntegers; N: Integer): PIntegers;

function int_Compare(p1: PIntegers; Count1: Integer;
                     p2: PIntegers; Count2: Integer): Boolean;

function x_Index_Sort(Items: PInt64s; Count: Integer): Integer;

procedure Inc_vector(X: PIntegers; Count,dX: Integer);
procedure Inc_array(X,dX: PIntegers; Count: Integer);

function SwapInt(i: Integer): Integer;
function SwapInt64(i: int64): int64;
function SwapColor(i: Integer): Integer;
function SwapSingle(f: Single): Single;
function SwapDouble(v: double): double;
function SwapWord(w: Word): Word;

procedure SwapInts(cp: PIntegers; N: Integer);
procedure SetInts(cp: PIntegers; N,V: Integer);

function int_Time(T: TDateTime): Integer;

procedure byte_set_Checked(var s: tbyte_set;
                           v: Integer; chk: Boolean);

function ByteInt(b: Byte): Integer;

function tick_delta(var t: ttick; Delta: uint): bool;

procedure time_beg(var dt: Integer);
procedure time_end(var dt: Integer);

procedure stat_inc(var P: TPoint; t: int);
procedure stat_dt(var P: TPoint; dt: int);

function pack_brush(pw,pc, msk,bc: int): int;

procedure set_view_intf(fl: Boolean); stdcall;

implementation

uses
  Math,SysUtils;

function Notify(Sender: TObject; ev: TNotifyEvent): Boolean;
begin
  if Assigned(ev) then ev(Sender);
  Result:=Assigned(ev)
end;

procedure Reset_ansi;
begin
  ansi_draw:=false;
  ansi_pack:=false;
end;

function Host(IP,Port: dword): THost;
var
  h: THost;
begin
  h.IP:=IP; h.Port:=Port;
  Result:=h
end;

function xFloat(f: Double): float;
begin
  Result:=f
end;

function xEqual(f1,f2: Double): Boolean;
begin
  Result:=Abs(f1-f2) <= Small
end;

function eps_Equal(f1,f2,eps: Double): Boolean;
begin
  Result:=Abs(f1-f2) <= eps
end;

function _mult(i1,i2: Integer): Int64;
begin
  Result:=i1; Result:=Result * i2
end;

function _int64(i0,i1: Integer): Int64;
var
  v: TInt64;
begin
  v.i[0]:=i0; v.i[1]:=i1;
  //Result:=Int64(v)
  Result:=v.x;
end;

function Long_Words(w1,w2: Integer): Integer;
asm
  shl  EDx,16
  add  EAx,EDx
end;

function Long_Bytes(b0,b1,b2,b3: Integer): Integer;
var
  ax: tlong;
begin
  ax.b[0]:=b0; ax.b[1]:=b1;
  ax.b[2]:=b2; ax.b[3]:=b3;
  Result:=ax.i
end;

function _Magic(Magic: PChar): int;
var
  ax: tlong; i,l: int;
begin
  ax.i:=0;

  l:=Min(Strlen(Magic),4);
  for i:=0 to l-1 do ax.b[i]:=ord(Magic[i]);

  Result:=ax.i
end;

function _Geoid(b,l: Double): TGeoid;
begin
  Result.b:=b; Result.l:=l
end;

function _Range(min,max: Double): TRange;
begin
  Result.min:=min; Result.max:=max;
end;

procedure Range_inc(var r: TRange; v: Double);
begin
  if v < r.min then r.min:=v;
  if v > r.max then r.max:=v;
end;

function Gauss_nil: TGauss;
begin
  Result.x:=0; Result.y:=0
end;

function _Gauss(x,y: Double): TGauss;
begin
  Result.x:=x; Result.y:=y
end;

function _LPoint(x,y: Integer): TPoint;
begin
  Result.X:=x; Result.Y:=y
end;

function _XPoint(x,y: Integer): XPoint;
begin
  Result.p.x:=x; Result.p.y:=y;
  Result.g.x:=x; Result.g.y:=y;
end;

function _VPoint(x,y,z: Integer): VPoint;
begin
  Result.x:=x; Result.y:=y; Result.z:=z;
end;

function _lxyz(x,y,z: Double): VPoint;
begin
  Result.x:=Round(x);
  Result.y:=Round(y);
  Result.z:=Round(z);
end;

function _LGauss(x,y: Double): TPoint;
begin
  Result.x:=Round(x);
  Result.y:=Round(y);
end;

function _IGauss(const g: TGauss): TPoint;
begin
  Result.x:=Round(g.x);
  Result.y:=Round(g.y);
end;

function _XRect(x,y,w,h: Integer): XRect;
begin
  Result.x:=x; Result.y:=y;
  Result.w:=w; Result.h:=h;
end;

function XRectContains(const R: XRect; X,Y: int): bool;
begin
  Result:=(X > R.x) and (X < R.x+R.w) and
          (Y > R.y) and (Y < R.y+R.h)
end;

function Rectf(x1,y1,x2,y2: float): TRectf;
var
  r: TRectf;
begin
  r.x1:=x1; r.y1:=y1; r.x2:=x2; r.y2:=y2;
  Result:=r
end;

function Port2i(x,y,w,h: int): TPort2i;
begin
  Result.x:=x; Result.y:=y;
  Result.w:=w; Result.h:=h;
end;

function Port2d(x,y,w,h: Double): TPort2d;
begin
  Result.x:=x; Result.y:=y;
  Result.w:=w; Result.h:=h;
end;

function _cmyk(c,m,y,k: Double): TCmyk;
begin
  Result.c:=c;
  Result.m:=m;
  Result.y:=y;
  Result.k:=k;
end;

function _xyz(x,y,z: Double): txyz;
begin
  Result.x:=x; Result.y:=y; Result.z:=z;
end;

function _xyf(x,y: float): txyf;
begin
  Result.x:=x; Result.y:=y; 
end;

function _xyzf(x,y,z: float): txyzf;
begin
  Result.x:=x; Result.y:=y; Result.z:=z;
end;

function xyz_xyzf(const v: txyz): txyzf;
begin
  Result.x:=v.x; Result.y:=v.y; Result.z:=v.z;
end;

function Datum7(dX,dY,dZ,wX,wY,wZ,m: Double): TDatum7;
begin
  Result.dX:=dX; Result.dY:=dY; Result.dZ:=dZ;
  Result.wX:=wX; Result.wY:=wY; Result.wZ:=wZ;
  Result.m:=m
end;

function dat7_dat3(const dat: TDatum7): TDatum;
begin
  Result.x:=Round(dat.dX);
  Result.y:=Round(dat.dY);
  Result.z:=Round(dat.dZ);
end;

function dat3_dat7(const dat: TDatum): TDatum7;
begin
  with dat do
  Result:=Datum7(x,y,z, 0,0,0,0)
end;

function sys3_sys7(const s: tsys3): tsys;
var
  sys: tsys;
begin
  Fillchar(sys,Sizeof(sys),0);
  sys.pps:=s.pps;
  sys.prj:=s.prj;
  sys.elp:=s.elp;
  sys.b1:=s.b1;
  sys.b2:=s.b2;
  sys.lc:=s.lc;
  sys.rn:=s.rn;
  sys.dat:=dat3_dat7(s.dat);
  Result:=sys
end;

function sys7(pps,prj,elp: int; b1,b2,lc: Double): tsys;
var
  s: tsys;
begin
  FillChar(s,SizeOf(s),0);
  s.pps:=pps; s.prj:=prj; s.elp:=elp;
  s.b1:=b1; s.b2:=b2; s.lc:=lc;

  if (pps = 1) and (elp = 1) then
  s.dat:=ru42_Datum; Result:=s
end;

function sys_nil: tsys;
begin
  Fillchar(Result,Sizeof(tsys),0);
end;

function sys3_nil: tsys3;
begin
  Fillchar(Result,Sizeof(tsys),0);
end;

function sys_wgs84: tsys;
begin
  Fillchar(Result,Sizeof(tsys),0);
  Result.elp:=9
end;

function sys_ru42: tsys;
begin
  Result:=sys_nil; Result.elp:=1;
  Result.dat:=ru42_Datum
end;

function sys_ru95: tsys;
begin
  Result:=sys_nil; Result.elp:=1;
  Result.dat:=ru95_Datum
end;

function sys_gk(lc: double): tsys;
var
  s: tsys;
begin
  s:=sys7(1,1,1,0,0,lc);
  s.dat:=ru95_Datum;
  Result:=s
end;

function sys_utm(lc: double): tsys;
begin
  Result:=sys7(1,2,9,0,0,lc)
end;

function GeoPoint_nil: TGeoPoint;
begin
  FillChar(Result,SizeOf(TGeoPoint),0);
end;

function GeoPoint(x,y: Double; sys: psys): TGeoPoint;
var
  g: TGeoPoint;
begin
  FillChar(g,SizeOf(g),0);
  g.x:=x; g.y:=y; if Assigned(sys) then
  g.s:=sys^; Result:=g
end;

procedure Datum_norm(var v: TDatum7);
begin
  v.wx:=v.wx / 60 / 60 / 180 * Pi;
  v.wy:=v.wy / 60 / 60 / 180 * Pi;
  v.wz:=v.wz / 60 / 60 / 180 * Pi;
  v.m:=v.m * 1E-6;
end;

procedure Datum_disp(var v: TDatum7);
begin
  v.wx:=v.wx * 60 * 60 * 180 / Pi;
  v.wy:=v.wy * 60 * 60 * 180 / Pi;
  v.wz:=v.wz * 60 * 60 * 180 / Pi;
  v.m:=v.m / 1E-6;
end;

function cDatum7(dX,dY,dZ,wx,wy,wz,m: Double): TDatum7;
var
  d: TDatum7;
begin
  d:=Datum7(dX,dY,dZ,wx,wy,wz,m);
  Datum_norm(d); Result:=d
end;

function IsDatum7(Dat: PDatum7): Boolean;
begin
  Result:=false;
  if Assigned(Dat) then
  if (Abs(Dat.dX) >= 0.01)
  or (Abs(Dat.dY) >= 0.01)
  or (Abs(Dat.dZ) >= 0.01)
  or (Abs(Dat.wx) >= 0.01)
  or (Abs(Dat.wy) >= 0.01)
  or (Abs(Dat.wz) >= 0.01) then
  Result:=true
end;

function nil_Datum7: TDatum7;
var
  dat: TDatum7;
begin
  Fillchar(dat,Sizeof(dat),0);
  Result:=dat
end;

function cu_Datum: TDatum7;
var
  s: TDatum7;
begin
  s.dX:=2.478;
  s.dY:=149.752;
  s.dZ:=197.726;
  s.wX:=-0.526356;
  s.wY:=-0.497970;
  s.wZ:=0.500831;
  s.m:=0.685238;

  Datum_norm(s); Result:=s
end;

function ru42_Datum: TDatum7;
begin
  Result:=Datum7(28,-130,-95, 0,0,0,0)
end;

function ru42_Datum1: TDatum7;
var
  s: TDatum7;
begin
  s.dX:=23.9;
  s.dY:=-141.3;
  s.dZ:=-80.9;
  s.wX:=0;
  s.wY:=-0.371277;
  s.wZ:=-0.849811;
  s.m:=-0.12;

  Datum_norm(s); Result:=s
end;

function ru42_Datum2: TDatum7;
var
  s: TDatum7;
begin
  s.dX:=23.57;
  s.dY:=-140.95;
  s.dZ:=-79.80;
  s.wX:=0;
  s.wY:=-0.35;
  s.wZ:=-0.79;
  s.m:=-0.22;

  Datum_norm(s); Result:=s
end;

function ru95_Datum: TDatum7;
var
  s: TDatum7;
begin
  s.dX:=24.8;
  s.dY:=-131.24;
  s.dZ:=-82.66;
  s.wX:=0;
  s.wY:=0;
  s.wZ:=-0.169137;
  s.m:=-0.12;

  Datum_norm(s); Result:=s
end;

function swe_Datum: TDatum7;
begin
  Result:=cDatum7(414.1,41.34,603.06, 1.45,-0.442,0.177, 0);
end;

function Is_ru42_Datum(const dat: TDatum7): Boolean;
begin
  Result:=is_nil_Datum7(dat);
  if not Result then with dat do
  if Round(dX) = 28 then
  if Round(dY) = -130 then
  if Round(dZ) = -95 then
  Result:=true
end;

function is_nil_Datum7(const dat: TDatum7): Boolean;
begin
  Result:=false; with dat do
  if Round(dX) = 0 then
  if Round(dY) = 0 then
  if Round(dZ) = 0 then
  Result:=true
end;

function ru_elp: tsys;
var
  s: tsys;
begin
  FillChar(s,Sizeof(s),0);
  s.elp:=1; s.dat:=ru42_Datum;
  Result:=s
end;

function datum_Equals(const d1,d2: TDatum7): Boolean;
begin
  Result:=false;
  if Abs(d1.dX - d2.dX) < 1 then
  if Abs(d1.dY - d2.dY) < 1 then
  if Abs(d1.dZ - d2.dZ) < 1 then
  Result:=true
end;

function dat_Equal(const s1,s2: tsys): Boolean;
begin
  Result:=false;
  if s1.elp = s2.elp then
  Result:=datum_Equals(s1.dat,s2.dat)
end;

function elp_Equal(elp1,elp2: Integer): Boolean;
begin
  if elp1 = 0 then elp1:=elp2;
  if elp2 = 0 then elp2:=elp1;
  Result:=elp1 = elp2
end;

function sys_plan(const s: tsys): Boolean;
begin
  with s do
  Result:=(pps = 0) and
          (elp = 0) and
          (prj = 0)
end;

function xy_Point(const v: vpoint): TPoint;
begin
  Result.x:=v.x; Result.y:=v.y;
end;

function _Locator(X,Y,R: Integer): TRect;
begin
  Result:=Rect(X-R,Y-R,X+R,Y+R)
end;

function Range_radius(const r: trange): Double;
begin
  Result:=(r.max - r.min) / 2
end;

procedure _GOrient(Dst,Src: PGPoly);
var
  I: Integer;
begin
  for I:=0 to Orient_Max-1 do Dst[I]:=Src[I]
end;

procedure begin_mem_stat(s: PIntegers);
begin
  s[0]:=heap_mem;
  s[1]:=alloc_mem;
  s[2]:=vfile_mem;
end;

function end_mem_stat(s: PIntegers): int;
begin
  s[0]:=heap_mem-s[0];
  s[1]:=alloc_mem-s[1];
  s[2]:=vfile_mem-s[2];
  Result:=s[0]+s[1]+s[2]
end;

function xGetMem(size: int): pointer;
begin
  Result:=nil;
  try
    GetMem(Result,size);
    Inc(heap_mem,size)
  except
    on EOutOfMemory do Result:=nil
  end
end;

function zGetMem(size: int): pointer;
begin
  Result:=xGetMem(size);
  if Result <> nil then
  FillChar(Result^,size,0)
end;

function xFreeMem(p: pointer; size: int): pointer;
begin
  if p <> nil then begin
    FreeMem(p,size);
    Dec(heap_mem,size)
  end;

  Result:=nil
end;

procedure SetErrorCode;
begin
  winErrCode:=GetLastError;
  FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM,nil,
                winErrCode,0,winErrStr,127,nil);
end;

function __AllocMem(size: int): Pointer; stdcall;
begin
  Result:=GlobalAllocPtr(0,size)
end;

function __ReallocMem(Ptr: Pointer; size: int): Pointer; stdcall;
begin
  Result:=GlobalReAllocPtr(Ptr,size,0)
end;

function __FreeMem(Ptr: Pointer): int; stdcall;
begin
  Result:=GlobalFreePtr(Ptr)
end;

function __SizeMem(Ptr: Pointer): int; stdcall;
begin
  Result:=GlobalSize(GlobalHandle(Ptr))
end;

function __SetError(Str: PChar; MaxLen: int): int; stdcall;
begin
  Result:=GetLastError;
  FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM,nil,
                Result,0,Str,MaxLen,nil);
end;

const
  MM: TMM = (alloc:   __AllocMem;
             realloc: __ReallocMem;
             free:    __FreeMem;
             getSize: __SizeMem;
             error:   __SetError);

procedure setMM(const aMM: TMM); stdcall;
begin
  MM:=aMM
end;

function VerifyMM: int;
var
  i: int; p: TPointers;
begin
  Result:=alloc_mem;

  for i:=0 to 1000-1 do
  p[i]:=xAllocPtr((i+1)*4096);

  for i:=0 to 1000-1 do
  xFreePtr(p[i]);

  Result:=alloc_mem-Result
end;

function xAllocPtr(size: int): Pointer;
begin
  Result:=nil;

  if size > 0 then begin
    Result:=MM.alloc(size);
    if Result = nil then
      winErrCode:=MM.error(winErrStr,127)
    else begin
      FillChar(Result^,size,0);
      if mem_enabled then
      Inc(alloc_mem,MM.getSize(Result))
    end
  end
end;

function xReAllocPtr(P: Pointer; size: int): Pointer;
var
  old: uint;
begin
  Result:=nil;

  if size <= 0 then
    Result:=xFreePtr(P)
  else
  if P = nil then
    Result:=xAllocPtr(size)
  else begin

    if mem_enabled then begin
      old:=MM.getSize(P);
      Dec(alloc_mem,old)
    end;

    Result:=MM.realloc(P,size);

    if Assigned(Result) then begin
      if mem_enabled then Inc(alloc_mem,size)
    end
    else begin
      Result:=xAllocPtr(size);

      if Assigned(P) then begin
        old:=MM.getSize(P);

        if (old > 0) and (old < size) then
        if Assigned(Result) then
        Move(P^,Result^,old);

        xFreePtr(P)
      end
    end
  end
end;

function xFreePtr(P: Pointer): pointer;
var
  len: uint;
begin
  if p <> nil then begin

    if mem_enabled then begin
      len:=MM.getSize(P);
      Dec(alloc_mem,len)
    end;

    if MM.free(P) <> 0 then
    winErrCode:=MM.error(winErrStr,127)
  end;

  Result:=nil
end;

function xAllocWords(n: Integer): PWords;
begin
  Result:=xAllocPtr(n * SizeOf(Word))
end;

function xAllocDWords(n: Integer): PDWords;
begin
  Result:=xAllocPtr(n * SizeOf(DWord))
end;

function xAllocInt(n: Integer): PIntegers;
begin
  Result:=xAllocPtr(n * SizeOf(Integer))
end;

function xReallocInt(P: PIntegers; n: Integer): PIntegers;
begin
  Result:=xReallocPtr(P,n * SizeOf(Integer))
end;

function xAllocInt64(n: Integer): PInt64s;
begin
  Result:=xAllocPtr(n * SizeOf(Int64))
end;

function xAllocDoubles(n: Integer): PDoubles;
begin
  Result:=xAllocPtr(n * SizeOf(Double))
end;

function xAllocFloats(n: Integer): PFloats;
begin
  Result:=xAllocPtr(n * SizeOf(Float))
end;

function xAllocLPoints(n: Integer): PLPoly;
begin
  Result:=xAllocPtr(n * SizeOf(TPoint))
end;

function xReallocLPoints(P: PLPoly; n: Integer): PLPoly;
begin
  Result:=xReAllocPtr(P,n * SizeOf(TPoint))
end;

function xAllocVPoints(n: Integer): PVPoly;
begin
  Result:=xAllocPtr(n * SizeOf(VPoint))
end;

function xReallocVPoints(P: PVPoly; n: Integer): PVPoly;
begin
  Result:=xReAllocPtr(P,n * SizeOf(VPoint))
end;

function xAllocGauss(n: Integer): PGPoly;
begin
  Result:=xAllocPtr(n * SizeOf(TGauss))
end;

function xReallocGauss(P: PGPoly; n: Integer): PGPoly;
begin
  Result:=xReallocPtr(P,n * SizeOf(TGauss))
end;

function Alloc_LLine(n: Integer): PLLine;
begin
  Result:=xAllocPtr((n+1)*SizeOf(TPoint));
  if Result <> nil then Result.N:=n-1
end;

function Realloc_LLine(lp: PLLine; n: Integer): PLLine;
var
  cx: Integer;
begin
  cx:=(n+1)*SizeOf(TPoint);
  Result:=xReallocPtr(lp,cx);
end;

function Alloc_VLLine(n: Integer): PVLine;
begin
  Result:=xAllocPtr((n+1) * SizeOf(VPoint));
  if Result <> nil then Result.N:=n-1
end;

function Alloc_PolyLine(n: Integer): PPolyLine;
begin
  Result:=xAllocPtr((n+1)*SizeOf(TPoint));
  if Result <> nil then Result.N:=n-1
end;

function Alloc_ZLine(out lp_z: PIntegers;
                     lp_max: Integer): PLLine;
var
  cx: Integer;
begin
  cx:=lp_max+1; lp_z:=nil;
  Result:=Alloc_LLine(cx + (cx div 2));
  if Assigned(Result) then begin
    lp_z:=@Result.Pol[cx];
    Result.N:=-1;
  end
end;

function xResizeBuf(Buf: Pointer; NewSize: Integer;
                    var BufSize: Integer): Pointer;
begin
  if NewSize > 0 then

  if Buf = nil then begin
    Buf:=xAllocPtr(NewSize);
    BufSize:=NewSize
  end else
  if NewSize > BufSize then begin
    Buf:=xReallocPtr(Buf,NewSize);
    BufSize:=NewSize
  end;

  Result:=Buf
end;

function xResizeInt(Buf: Pointer; NewCount: Integer;
                    var BufCount: Integer): Pointer;
var
  sz: Integer;
begin
  sz:=BufCount*4;
  Result:=xResizeBuf(Buf,NewCount*4,sz);
  BufCount:=sz div 4
end;

function xAllocFile(len: Integer; out vm: TMapView): Pointer;
begin
  Result:=nil; with vm do begin
    h:=CreateFileMappingA($FFFFFFFF,nil,PAGE_READWRITE,0,len,nil);
    if h <> 0 then Result:=MapViewOfFile(h,FILE_MAP_WRITE,0,0,0);
    p:=Result; size:=0; if Result <> nil then size:=len;

    if mem_enabled then
    if Result <> nil then Inc(vfile_mem,len)
  end
end;

function xReadOnlyFile(h: Integer; out vm: TMapView): Pointer;
begin
  Result:=nil; vm.p:=nil; vm.size:=FileSeek(h,0,2);
  vm.h:=CreateFileMappingA(h,nil,PAGE_READONLY,0,0,nil);

  if vm.h <> 0 then begin
    Result:=MapViewOfFile(vm.h,FILE_MAP_READ,0,0,0);
    if Result = nil then begin
      CloseHandle(vm.h); vm.h:=0
    end;

    if mem_enabled then
    if Result <> nil then Inc(vfile_mem,vm.size)
  end;

  vm.p:=Result;
end;

function xUpdateFile(h: Integer; out vm: TMapView): Pointer;
begin
  Result:=nil; vm.p:=nil; vm.size:=FileSeek(h,0,2);
  vm.h:=CreateFileMappingA(h,nil,PAGE_READWRITE,0,0,nil);
  if vm.h <> 0 then Result:=MapViewOfFile(vm.h,FILE_MAP_WRITE,0,0,0);

  if mem_enabled then
  if Result <> nil then Inc(vfile_mem,vm.size);

  vm.p:=Result
end;

procedure xFreeFile(var vm: TMapView);
begin
  with vm do if h <> 0 then begin

    if mem_enabled then Dec(vfile_mem,size);

    if p <> nil then
    if not UnmapViewOfFile(p) then
    SetErrorCode;

    CloseHandle(h);
  end;

  vm.h:=0; vm.p:=nil; vm.size:=0;
end;

function xCreateFileMap(len: Integer; fn: PChar;
                        out vm: TMapView): Pointer;
begin
  Result:=nil; with vm do begin
    h:=CreateFileMappingA($FFFFFFFF,nil,PAGE_READWRITE,0,len,fn);
    if h <> 0 then Result:=MapViewOfFile(h,FILE_MAP_WRITE,0,0,0);
    p:=Result; size:=0; if Result <> nil then size:=len
  end
end;

function xOpenFileMap(fn: PChar; out vm: TMapView): Pointer;
begin
  Result:=nil; with vm do begin
    h:=OpenFileMappingA(FILE_MAP_WRITE, False, fn);
    if h <> 0 then Result:=MapViewOfFile(h,FILE_MAP_WRITE,0,0,0);
    p:=Result; size:=0;
  end
end;

function GetTotalMemorySize: DWord;
var
  mst: TMEMORYSTATUS;
begin
  GlobalMemoryStatus(mst);
  Result:=mst.dwTotalPhys div 1024 div 1024
end;

function GetAvailMemorySize: DWord;
var
  mst: TMEMORYSTATUS;
begin
  GlobalMemoryStatus(mst);
  Result:=mst.dwAvailPhys div 1024 div 1024
end;

function xResolution(w,h: Double): Double;
var
  DC: hDC; kx,ky: Double;
begin
  DC:=GetDC(0);
  kx:=w/GetDeviceCaps(DC,HorzRes);
  ky:=h/GetDeviceCaps(DC,VertRes);
  Result:=Math.Max(kx,ky);
  ReleaseDC(0,DC);
end;

function xDeviceRatio(Dev: HDC): Double;
var
  DC: HDC; dev_ppi,dc_ppi: Integer;
begin
  Result:=1;

  DC:=GetDC(0);
  if DC <> 0 then begin
    dev_ppi:=GetDeviceCaps(DC,LogPixelSx);
    dc_ppi:=GetDeviceCaps(DC,LogPixelSx);
    if (dev_ppi > 0) and (dc_ppi > 0) then
    Result:=dev_ppi / dc_ppi
  end
end;

function xDevice_dpi(DC: HDC): Integer;
begin
  Result:=GetDeviceCaps(DC,LogPixelSx)
end;

function xDeviceAspect(DC: HDC): Double;
var
  mpp,mpp0: Double;
begin
  Result:=1;
  if DC <> 0 then begin
    mpp:=MetersPerPixel(DC);
    mpp0:=xMetersPerPixel;
    if mpp > 1E-8 then
    Result:=mpp0 / mpp
  end
end;

function MetersPerPixel(DC: HDC): Double;
var
  ppi: Integer;
begin
  Result:=0;
  ppi:=GetDeviceCaps(DC,LogPixelSx);
  if ppi > 0 then Result:=0.0254 / ppi
end;

function xMetersPerPixel: Double;
var
  DC: hDC;
begin
  DC:=GetDC(0);
  Result:=MetersPerPixel(DC);
  ReleaseDC(0,DC)
end;

function xDeviceDpi: Integer;
var
  DC: hDC;
begin
  DC:=GetDC(0);
  Result:=GetDeviceCaps(DC,LogPixelSx);
  ReleaseDC(0,DC)
end;

function PixelsPerMeter(DC: HDC): TGauss;
begin
  Result.x:=GetDeviceCaps(DC,LogPixelSx) / 0.0254;
  Result.y:=GetDeviceCaps(DC,LogPixelSy) / 0.0254;
end;

function xPixelsPerMeter: TGauss;
var
  DC: hDC;
begin
  DC:=GetDC(0);
  Result:=PixelsPerMeter(DC);
  ReleaseDC(0,DC)
end;

function xDeviceStep(Dev: HDC; st: Integer): Integer;
var
  ppm1,ppm2: TGauss;
begin
  Result:=st;

  ppm1:=xPixelsPerMeter;
  ppm2:=PixelsPerMeter(Dev);

  if ppm1.x >= 1 then
  if ppm2.x >= 1 then
  Result:=Round(st / ppm1.x * ppm2.x);
end;

function BitsPerPixel(DC: hDC): Integer;
begin
  Result:=GetDeviceCaps(DC, BITSPIXEL) *
          GetDeviceCaps(DC, PLANES);
end;

function xBitsPerPixel: Integer;
var
  DC: hDC;
begin
  DC:=GetDC(0);
  Result:=BitsPerPixel(DC);
  ReleaseDC(0,DC)
end;

function xCreateCompatibleBitMap(Width,Height: Integer): hBitMap;
var
  DC: hDC;
begin
  DC:=GetDC(0);
  Result:=CreateCompatibleBitMap(DC,Width,Height);
  ReleaseDC(0,DC)
end;

function xPixels(dist,scale: Double): Longint;
begin
  Result:=0; if scale > 0.1 then
  Result:=Round(dist / scale / xMetersPerPixel + 0.5)
end;

function xPenThick(DC: HDC; mm: Float): Integer;
var
  dpi: Integer;
begin
  dpi:=GetDeviceCaps(DC,LogPixelSx);
  Result:=Round(dpi / 25.4 * mm);
end;

function Param_key(key: PChar): Boolean;
var
  i: Integer; s: TShortstr;
begin
  Result:=false;

  for i:=1 to ParamCount do
  if StrPCopy(s,ParamStr(i)) <> nil then
  if StrIComp(s,key) = 0 then begin
    Result:=true; Break
  end
end;

function Param_Option(opt: PChar): Boolean;
var
  i: Integer;
begin
  Result:=false;

  for i:=1 to ParamCount do
  if ParamStr(i) = StrPas(opt) then begin
    Result:=true; Break
  end

end;

function xParamCount: Integer;
var
  i: Integer;
begin
  Result:=ParamCount;

  for i:=1 to ParamCount do
  if ParamStr(i)[1] = '/' then Dec(Result)
  else Break
end;

function Param_valuei(def,min,max: int; Name: PChar): int;
var
  i,rc,v: int; p: PChar; s: TShortstr;
begin
  Result:=def; rc:=StrLen(Name);

  for i:=1 to ParamCount do begin
    StrPCopy(s,ParamStr(i));
    if s[0] = '/' then begin
      p:=@s[1];
      if StrLIComp(p,Name,rc) = 0 then begin

        p:=@p[rc];
        val(p,v,rc);
        if rc = 0 then
        if v >= min then
        if v >= max then
        Result:=v;

        Break
      end
    end
  end
end;

function Param_valuef(def,min,max: float; Name: PChar): float;
var
  i,rc: int; v: float; p: PChar; s: TShortstr;
begin
  Result:=def; rc:=StrLen(Name);

  for i:=1 to ParamCount do begin
    StrPCopy(s,ParamStr(i));
    if s[0] = '/' then begin
      p:=@s[1];
      if StrLIComp(p,Name,rc) = 0 then begin

        p:=@p[rc];
        val(p,v,rc);
        if rc = 0 then
        if v >= min then
        if v <= max then
        Result:=v;

        Break
      end
    end
  end
end;

function xRange(i, a,b: Double): Double;
begin
  Result:=Min(Max(i,a),b)
end;

function iRange(i, a,b: Integer): Integer;
begin
  if i < a then i:=a;
  if i > b then i:=a;
  Result:=i;
end;

function iIndex(ind,max: Integer): Integer;
asm
  cmp  EAx,0
  jl   @err
  cmp  EAx,EDx
  jl   @exit

@err:
  mov  EAx,0
@exit:
end;

procedure xmove(si,di: PBytes; len: Integer);
var
  cx: Integer;
begin
  si:=@si[len]; di:=@di[len];

  while len > 0 do begin cx:=Min(4096,len);
    Dec(Longint(si),cx); Dec(Longint(di),cx);
    Move(si^,di^,cx); Dec(len,cx)
  end
end;

procedure oSwap(var o1,o2);
asm
  push ESi
  mov  ESi,EAx
  mov  EAx,DWord PTR [ESi]
  mov  ECx,DWord PTR [EDx]
  mov  DWord PTR [ESi],ECx
  mov  DWord PTR [EDx],EAx
  pop  ESi
end;

procedure pSwap(var p1,p2: Pointer);
asm
  push ESi
  mov  ESi,EAx
  mov  EAx,DWord PTR [ESi]
  mov  ECx,DWord PTR [EDx]
  mov  DWord PTR [ESi],ECx
  mov  DWord PTR [EDx],EAx
  pop  ESi
end;

procedure iSwap(var a,b: Integer);
asm
  push ESi
  mov  ESi,EAx
  mov  EAx,DWord PTR [ESi]
  mov  ECx,DWord PTR [EDx]
  mov  DWord PTR [ESi],ECx
  mov  DWord PTR [EDx],EAx
  pop  ESi
end;

procedure cSwap(var a,b: Cardinal);
asm
  push ESi
  mov  ESi,EAx
  mov  EAx,DWord PTR [ESi]
  mov  ECx,DWord PTR [EDx]
  mov  DWord PTR [ESi],ECx
  mov  DWord PTR [EDx],EAx
  pop  ESi
end;

procedure wSwap(var a,b: Word);
asm
  push ESi
  mov  ESi,EAx
  mov  Ax,Word PTR [ESi]
  mov  Cx,Word PTR [EDx]
  mov  Word PTR [ESi],Cx
  mov  Word PTR [EDx],Ax
  pop  ESi
end;

procedure sSwap(var a,b: Smallint); var ax: Smallint;
begin ax:=a; a:=b; b:=ax end;

procedure xSwap(var a,b: Double); var ax: Double;
begin ax:=a; a:=b; b:=ax end;

procedure fSwap(var a,b: Float); var ax: FLoat;
begin ax:=a; a:=b; b:=ax end;

procedure bSwap(var a,b: Byte); var ax: Byte;
begin ax:=a; a:=b; b:=ax end;

procedure iSwap64(var a,b: int64); var ax: int64;
begin ax:=a; a:=b; b:=ax end;

function Long2i(a,b: Integer): Longint;
begin
  tlong(Result).w[0]:=a;
  tlong(Result).w[1]:=b;
end;

function xBytesCount(bp: PBytes; N: Integer): Integer;
var
  i: Integer;
begin
  Result:=0;
  for i:=1 to N do begin
    Inc(Result,bp[0]); bp:=@bp[1]
  end
end;

function xCountersCount(cp: PIntegers; N: Integer): Int64;
var
  i: int; ax: int64;
begin
  ax:=0;
  for i:=1 to N do begin
    Inc(ax,cp[0]); cp:=@cp[1]
  end; Result:=ax
end;

function CountersCount(cp: PIntegers; N: Integer): Integer;
asm
  push EBx
  push ESi

  mov  ESi,EAx
  mov  ECx,EDx

  cld
  mov  EBx,0
@loop:
  lodsd
  add  EBx,EAx
  loop @loop

  mov  EAx,EBx

  pop  ESi
  pop  EBx
end;

function CountersMax(cp: PIntegers; N: Integer): Integer;
asm
  push EBx
  push ESi

  mov  ESi,EAx
  mov  ECx,EDx

  cld
  mov  EBx,0
@loop:
  lodsd
  cmp  EBx,EAx
  jg   @next
  mov  EBx,EAx
@next:
  loop @loop

  mov  EAx,EBx

  pop  ESi
  pop  EBx
end;

function IntegersAve(lp: PIntegers; N: Integer): Integer;
var
  ax: Int64; i: Integer;
begin
  ax:=0; for i:=1 to N do begin
    Inc(ax,lp[0]); lp:=@lp[1];
  end; Result:=ax div N
end;

procedure int_MinMax(vp: PIntegers; N: Integer;
                     min,max: PInteger);
begin
  asm
    push EAx
    push EBx
    push ECx
    push EDx
    push ESi
    push EDi

    cld
    mov  ESi,[vp]
    mov  ECx,[N]

    mov  EBx,DWord PTR [ESi]
    mov  EDx,DWord PTR [ESi]

    cmp  ECx,0
    jle  @skip
  @loop:
    lodsd
    cmp  EAx,EBx
    jl   @less
    cmp  EAx,EDx
    jg   @larger
    jmp  @next
@less:
    mov  EBx,EAx
    jmp  @next
@larger:
    mov  EDx,EAx
  @next:
    loop @loop

@skip:
    mov  EDi,[min]
    mov  DWord PTR [EDi],EBx
    mov  EDi,[max]
    mov  DWord PTR [EDi],EDx

    pop  EDi
    pop  ESi
    pop  EDx
    pop  ECx
    pop  EBx
    pop  EAx
  end
end;

procedure words_MinMax(vp: PWords; N: Integer;
                       out vmin,vmax: Integer);
var
  v1,v2,v: Integer;
begin
  vmin:=0; vmax:=0;
  if N > 0 then begin
    v1:=vp[0]; v2:=v1; Dec(N);

    while N > 0 do begin
      vp:=@vp[1]; Dec(N); v:=vp[0];
      if v < v1 then v1:=v;
      if v > v2 then v2:=v;
    end;

    vmin:=v1; vmax:=v2;
  end
end;

procedure small_MinMax(vp: PSmallInts; N: Integer;
                       out vmin,vmax: Integer);
var
  v1,v2,v: Integer;
begin
  vmin:=0; vmax:=0;
  if N > 0 then begin
    v1:=vp[0]; v2:=v1; Dec(N);

    while N > 0 do begin
      vp:=@vp[1]; Dec(N); v:=vp[0];
      if v < v1 then v1:=v;
      if v > v2 then v2:=v;
    end;

    vmin:=v1; vmax:=v2;
  end
end;

procedure bytes_MinMax(vp: PBytes; N: Integer;
                       out vmin,vmax: Integer);
var
  v1,v2,v: Integer;
begin
  vmin:=0; vmax:=0;
  if N > 0 then begin
    v1:=vp[0]; v2:=v1; Dec(N);

    while N > 0 do begin
      vp:=@vp[1]; Dec(N); v:=vp[0];
      if v < v1 then v1:=v;
      if v > v2 then v2:=v;
    end;

    vmin:=v1; vmax:=v2;
  end
end;

function Int3(P: Pointer): Integer;
asm
  push EBx
  push ESi

  mov  ESi,EAx
  mov  EBx,0

  lodsw
  mov  Bx,Ax

  mov  EAx,0
  lodsb
  shl  EAx,16
  or   EAx,EBx

  pop  ESi
  pop  EBx
end;

function Channel_Indexof(Chan: PBytes; Count: Integer;
                         Item: Integer): Integer;
asm
  push EBx
  push ESi

  mov  ESi,EAx
  mov  EBx,ECx
  mov  ECx,EDx

  cmp  ECx,0
  je   @not_found

  mov  EDx,0

  cld
@loop:
  lodsb
  cmp  Bl,Al
  je   @exit
  inc  EDx
  loop @loop

@not_found:
  mov  EDx,-1
@exit:
  mov  EAx,EDx

  pop  ESi
  pop  EBx
end;

function Int_Contains(Items: PIntegers; Count: Integer;
                      item: Integer): Integer;
asm
  push EBx
  push ESi

  mov  ESi,EAx
  mov  EBx,ECx
  mov  ECx,EDx

  cmp  ECx,0
  je   @not_found

  mov  EDx,0

  cld
@loop:
  lodsd
  cmp  EBx,EAx
  je   @exit
  inc  EDx
  loop @loop

@not_found:
  mov  EDx,-1
@exit:
  mov  EAx,EDx

  pop  ESi
  pop  EBx
end;

function Int_Delete(Items: PIntegers; Count,Index: int): int;
begin
  if Index >= 0 then
  if Index < Count then begin
    Dec(Count); while Index < Count do begin
      Items[Index]:=Items[Index+1]; Inc(Index)
    end;
  end; Result:=Count
end;

function lp_Contains_Index(lp: PLLine;
                           Id: Integer): Integer;
begin
  Result:=-1; with lp^ do if N >= 0 then
  Result:=Index_Contains(@Pol,N+1, Id)
end;

function Index_Contains(Items: PInt64s; Count: Integer;
                        Id: Integer): Integer;
asm
  push EBx
  push ESi

  mov  ESi,EAx
  mov  EBx,ECx
  mov  ECx,EDx

  mov  EDx,-1

  cmp  ECx,0
  jle  @exit

  mov  EDx,0

  cld
@loop:
  lodsd
  cmp  EBx,EAx
  je   @exit
  add  ESi,4
  inc  EDx
  loop @loop


  mov  EDx,-1
@exit:
  mov  EAx,EDx

  pop  ESi
  pop  EBx
end;

function x_Index_Contains(Items: PInt64s; Count: Integer;
                          Id: Integer): Integer;
asm
  push EBx
  push ESi
  push EDi

  mov  ESi,EAx
  mov  EBx,ECx

  mov  ECx,0
  dec  EDx

@loop:
  cmp  ECx,EDx
  jg   @false

  mov  EAx,ECx
  add  EAx,EDx
  shr  EAx,1

  mov  EDi,EAx
  shl  EDi,3
  add  EDi,ESi

  cmp  EBx,DWord PTR [EDi]
  jb   @less
  je   @exit

@more:
  mov  ECx,EAx
  inc  ECx
  jmp  @loop

@less:
  mov  EDx,EAx
  dec  EDx
  jmp  @loop

@false:
  mov  EAx,-1

@exit:
  pop  EDi
  pop  ESi
  pop  EBx
end;

function z_axe_ptr(hp: PIntegers; N: Integer): PIntegers;
var
  zmin,zmax: Integer;
begin
  Result:=nil; if Assigned(hp) then begin
    int_MinMax(hp,N, @zmin,@zmax);
    if (zmin <> 0) or (zmax <> 0) then
    Result:=hp
  end;
end;

function int_Compare(p1: PIntegers; Count1: Integer;
                     p2: PIntegers; Count2: Integer): Boolean;
var
  i: Integer;
begin
  Result:=Count1 = Count2;

  if Result then
  for i:=0 to Count1-1 do
  if p1[i] <> p2[i] then begin
    Result:=false; Break
  end
end;

function x_Index_Sort(Items: PInt64s; Count: Integer): Integer;
var
  i,j: Integer; p1,p2: PInt64s; ax,bx: TInt64;
begin
  p1:=Items;
  for i:=0 to Count-2 do begin

    ax.x:=p1[0]; p2:=@p1[1];

    for j:=i+1 to Count-1 do begin
      bx.x:=p2[0];
      if bx.c[0] < ax.c[0] then begin
        p2[0]:=ax.x; ax:=bx;
      end; p2:=@p2[1]
    end;

    p1[0]:=ax.x; p1:=@p1[1]
  end;

  Result:=Count
end;

function SwapInt(i: Integer): Integer;
asm
  BSWAP EAx
end;

function SwapInt64(i: int64): int64;
var
  v1,v2: TInt64;
begin
  v1.x:=i;
  v2.b[0]:=v1.b[7];
  v2.b[1]:=v1.b[6];
  v2.b[2]:=v1.b[5];
  v2.b[3]:=v1.b[4];
  v2.b[4]:=v1.b[3];
  v2.b[5]:=v1.b[2];
  v2.b[6]:=v1.b[1];
  v2.b[7]:=v1.b[0];
  Result:=v2.x
end;

function SwapColor(i: Integer): Integer;
var
  ax: tlong;
begin
  ax.i:=i;
  ax.b[0]:=tlong(i).b[2];
  ax.b[2]:=tlong(i).b[0];
  Result:=ax.i
end;

function SwapSingle(f: Single): Single;
var
  v: Longint;
begin
  v:=PLongint(@f)^;

  asm
    mov   EAx,[v]
    BSWAP EAx;
    mov   [v],EAx
  end;

  Result:=PSingle(@v)^
end;

function SwapDouble(v: double): double;
var
  t: TDouble; bp: PBytes;
begin
  bp:=@v;
  t.v[0]:=bp[7]; t.v[1]:=bp[6];
  t.v[2]:=bp[5]; t.v[3]:=bp[4];
  t.v[4]:=bp[3]; t.v[5]:=bp[2];
  t.v[6]:=bp[1]; t.v[7]:=bp[0];
  Result:=t.d
end;

function SwapWord(w: Word): Word;
asm
  BSWAP EAx
  shr   EAx,16
end;

procedure SwapInts(cp: PIntegers; N: Integer);
asm
  push ESi

  mov  ESi,EAx
  mov  ECx,EDx

@loop:
  mov  EAx,DWord PTR [ESi]
  BSWAP EAx
  mov  DWord PTR [ESi],EAx
  add  ESi,4
  loop @loop

  pop  ESi
end;

procedure SetInts(cp: PIntegers; N,V: Integer);
asm
  push ESi

  mov  ESi,EAx
  mov  EAx,ECx
  mov  ECx,EDx

@loop:
  mov  DWord PTR [ESi],EAx
  add  ESi,4
  loop @loop

  pop  ESi
end;

procedure Inc_vector(X: PIntegers; Count,dX: Integer);
var
  i: Integer;
begin
  for i:=1 to Count do begin
    Inc(X[0],dX); X:=@X[1]
  end
end;

procedure Inc_array(X,dX: PIntegers; Count: Integer);
var
  i: Integer;
begin
  for i:=1 to Count do begin
    Inc(X[0],dX[0]); X:=@X[1]; dX:=@dX[1]
  end
end;

function int_Time(T: TDateTime): Integer;
var
  Hour, Min, Sec, MSec: Word;
begin
  DecodeTime(T, Hour,Min,Sec,MSec);
  Result:=Hour; Result:=Result * 3600;
  Inc(Result, Min*60 + Sec)
end;

procedure byte_set_Checked(var s: tbyte_set;
                           v: Integer; chk: Boolean);
begin
  if chk then s:=s + [v]
  else        s:=s - [v]
end;

function ByteInt(b: Byte): Integer;
begin
  Result:=b; if b and $80 <> 0 then
  Result:=Result or $FFFFFF00;
end;

function tick_delta(var t: ttick; Delta: uint): bool;
var
  ct: uint;
begin
  Result:=false;
  ct:=GetTickCount;
  if Abs(ct-t) > Delta then begin
    t:=ct; Result:=true
  end
end;

procedure time_beg(var dt: Integer);
begin
  Dec(dt,GetTickCount)
end;

procedure time_end(var dt: Integer);
begin
  Inc(dt,GetTickCount)
end;

procedure stat_inc(var P: TPoint; t: int);
begin
  Inc(P.X,GetTickCount-t); Inc(P.Y)
end;

procedure stat_dt(var P: TPoint; dt: int);
begin
  Inc(P.X,dt); Inc(P.Y)
end;

function pack_brush(pw,pc, msk,bc: int): int;
begin
  Result:=(pw shl 16) or (msk shl 10) or
          (pc shl 5) or bc;
end;

// 5=WinXP; 6=Vista
function GetWinOS: Integer;
var
  ver: TOSVERSIONINFO;
begin
  Result:=0;

  Fillchar(ver,Sizeof(ver),0);
  ver.dwOSVersionInfoSize:=Sizeof(ver);
  if GetVersionEx(ver) then
  Result:=ver.dwMajorVersion
end;

procedure set_view_intf(fl: Boolean); stdcall;
begin
  view_interface:=fl
end;

begin
  sys_CYCaption:=GetSystemMetrics(sm_CYCaption);
  sys_CXVScroll:=GetSystemMetrics(sm_CXVScroll);
  sys_CYHScroll:=GetSystemMetrics(sm_CYHScroll);

  IsWin32:=Win32Platform = Ver_Platform_Win32_NT;

  WinOS:=GetWinOS;

  if rus_interface then
  rus_interface:=not Param_Option('/t');

  debug_enabled:=Param_Option('/d');
  debug_enabled1:=Param_Option('/d1');
  debug_enabled2:=Param_Option('/d2');

  log_enabled:=Param_Option('/log');
  gdi_enabled:=Param_Option('/gdi');
  pop_enabled:=Param_Option('/pop');
  view_interface:=Param_Option('/v');
  mem_enabled:=Param_Option('/m');
  lite_interface:=Param_Option('/lite');
  stat_interface:=Param_Option('/stat');
  demo_interface:=Param_Option('/demo');
  test_interface:=Param_Option('/test');

  alloc_mem:=0;
  vfile_mem:=0;
  heap_mem:=0;

  winErrCode:=0;
  StrCopy(winErrStr,'');

  _ErrCode:=0
end.

