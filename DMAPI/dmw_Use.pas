unit dmw_Use; interface

uses
  Windows,ActiveX,OTypes;

const
  fl_del  = 1;                                  
  fl_cl   = 2;                                              
  fl_mf   = 4;
  fl_hf   = 8;
  fl_draw = 16;
  fl_long = 32;
  fl_skip = 64;

  fl_xyz  = 128;

  ctrl_init  = 0;
  ctrl_start = 1;                                            
  ctrl_quest = 2;
  ctrl_exec  = 3;
  ctrl_setup = 4;
  ctrl_dial  = 5;
  ctrl_about = 6;
  ctrl_reset = 7;

  opt_load   = 8;
  opt_save   = 9;

  ctrl_auto  = 10;
  ctrl_call  = 11;

  ini_load   = 12;
  ini_save   = 13;

  ini_lock   = 14;
  dbf_lock   = 15;

  ctrl_pair  = 16;
  ctrl_up    = 17;

  ctrl_close = 18;
  ctrl_Batch = 19;
  pair_Batch = 20;
  ctrl_int64 = 21;

  ctrl_xdial = 22;
  ctrl_files = 23;

  ctrl_ip    = 24;
  ctrl_dp    = 25;
  
  ctrl_doc   = 26;

  ctrl_listp = 27;
  ctrl_listn = 28;

  ctrl_pair2 = 29;
  ctrl_begin = 30;

  ctrl_util  = 31;

  mode_quest = 64;
  mode_auto  = 128;
  mode_pkg   = 256;
  mode_cmd   = 512;

  mr_exec   = 1;
  mr_hide   = 2;
  mr_cancel = 4;
  mr_setup  = 8;
  mr_pair   = 16;

  mr_move  = 1;
  mr_del   = 2;
  mr_swap  = 4;
  mr_hf    = 8;
  mr_win   = 16;
  mr_inf   = 32;
  mr_join  = 64;
  mr_log   = 128;
  mr_tiff  = 256;
  mr_scale = 512;

  undo_mov = 0;
  undo_add = 1;
  undo_del = 2;
  undo_own = 3;

  cn_object = 0;
  cn_ident  = 1;
  cn_node   = 120;
  cn_edge   = 130;
  cn_group  = 100;

  loc_info   = 10;

  loc_attr   = 30;
  loc_role   = 40;
  loc_group  = 50;

  loc_cn     = [21..23];
  
  loc_attrs  = [30..33];
  loc_attrv  = [31..33];

  loc_attr1  = 31;
  loc_attr2  = 32;
  loc_attr3  = 33;

  loc_roles  = [40..43];

  loc_geom   = 100;

  tx_opt_Childs = 1;
  
  tx_edit_add = 1;
  tx_edit_del = 2;
  tx_edit_mf  = 4;
  tx_edit_hf  = 8;

  guid_key    = 999;

  flag_without_mf = $80;

  param_length_id = 1;

type
  dm_Hdr = record
    ver,scale,zzz,fot,srct: byte;
    nil1,nil2: byte; sys: tsys; r_div: Double;
    y_get,y_upd,y_mag,y_pab,dm_scale,dm_nnn: Integer;
    nom,idt,obj,loc,st_loc,own,access: string;
  end;

  dm_Rec = record
    Code,mind,hind: longint;
    Tag,View: byte; Color: word;

    case Integer of
  0:  (ox1,oy1,ox2,oy2: longint);
  1:  (o_lt,o_rb: TPoint);
  end;

  Id_Tag = (_byte,_word,_int,_long,_time,
            _date,_float,_real,_angle,
            _string,_dBase,_enum,_bool,
            _link,_double,_unicode,
            _list,_text,_unk,_color,
            _long64,_number,_enumw,
            _blank,_latin1,_rtf,
            _label);

  Id_Set = set of Id_Tag;

  PAbcRec1 = ^TAbcRec1;
  TAbcRec1 = record
    nnn,iv: int; rv: float;
    vmin,vmax: float; vrange: int64;
    count1,count2,flags: Byte;
    id: Id_Tag;
  end;
  
  TOnObject = function(ptr: int; const o: dm_Rec): Boolean of object;
  TOnObject1 = function(ptr,lev: int; const o: dm_Rec): Boolean of object;

  TObjectFunc2 = function(ptr,id,lev: Longint): Boolean; stdcall;
                       
  TStepItProc = function(IsBreak: Boolean): Boolean; stdcall;

  TBatchProc = function(cp: PIntegers; Count: Integer;
                        StepIt: TStepItProc): Integer; stdcall;

  TBatchPair = function(cp1,cp2: PIntegers; Count: Integer;
                        StepIt: TStepItProc): longint; stdcall;

  TFuncComment = function(i: int; s: PChar): PChar; stdcall;

  TOnAttrOut = procedure(Obj: Pointer;
                         lp: PLPoly; lp_n,color: int;
                         s: PWideChar; dos: int); stdcall;

  pcn_rec = ^tcn_rec;
  tcn_rec = record
    rcid: Cardinal;
    rver: Word;
    rcnm: Byte;
    bits: Byte;

    fe: Integer;

    case Integer of
  0:  (Pos: TPoint;
       zpos: Integer);

  1:  (VPos: VPoint);

  2:  (vc1: Cardinal;
       vc2: Cardinal;
       sgp: Integer);

  3:  (OBJL: Cardinal;
       mfp: Cardinal;
       hfp: Cardinal);
  end;

  PPolyPolygon = ^TPolyPolygon;

  TPolyPolygon = record
    Counters: PIntegers;
    Points: PLPoly;

    PointCount: Integer;
    Count: Integer;

    CounterCapacity: Integer;
    PointCapacity: Integer;
  end;

  PChainRec = ^TChainRec;
  TChainRec = record
    Id,Code: Integer; a,b: TGauss
  end;

  PChainArray = ^TChainArray;
  TChainArray = Array[0..255] of TChainRec;

  ICustomList = interface(IUnknown)
    ['{2FA100FE-6B39-49E9-867A-5E294931A3EE}']
    function GetCount: int; stdcall;
    function GetItemLen: int; stdcall;
    function GetItem(I: int; var rec): int; stdcall;
    function InsItem(I: int; var rec): int; stdcall;
    function ItemById(Id: int): int; stdcall;
  end;

const
  Id_Int: Id_Set = [_byte,_word,_int,_long,_time,_date,
                    _dBase,_enum,_bool,_link,_color];

  Id_Int1: Id_Set = [_byte,_word,_int,_long,
                     _dBase,_enum,_bool,_link];

  Id_Int2: Id_Set = [_byte,_word,_int,_long,_link];

  Id_dbase: Id_Set = [_byte,_word,_int,_long,_dBase,_enum];

  Id_Real: Id_Set = [_float,_real,_angle,_double];
  Id_Single: Id_Set = [_float,_real,_angle];

  Id_Value: Id_Set = [_byte,_word,_int,_long,
                      _float,_real,_angle,_double];

  Id_Str: Id_Set = [_string,_unicode,_list,_text];

  Id_Len: array[Id_Tag] of Integer =
  (1,2,2,4,4,4,4,4,4,0,2,2,1,4,8,0,0,0,1,4,8,0,0,0,0,0,0);

// 911,914 - Магнитное склонение
// 912 - Сближение меридианов
// 913 - Годовое изменение

type TProgressFunc = function(Pos, Max: Integer): Boolean; stdcall;
//function dm_operation(map1, map2, dest: PChar; operation: Integer; progress: TProgressFunc): Boolean; stdcall;
//function dm_operation(map1, map2, dest: PChar; operation: Integer): Boolean; stdcall;
function dm_operation(map1, map2, dest: PChar; operation, flags: int): Boolean;
procedure set_dm_scan_progress(f: TProgressFunc);

function GetPolybuf(out lp: PLLine;
                    out hp: PIntegers): int; stdcall;

function GetBinDir: PChar; stdcall;
procedure SetBinDir(dir: PChar); stdcall;
procedure SetSpaceDir(Dir: PChar); stdcall;
procedure iniSpaceDir(Ini: PChar); stdcall;

function dm_Open(path: PChar; edit: Boolean): word; stdcall;
procedure dm_Done; stdcall;
procedure dm_File; stdcall;

function dm_Handle: int; stdcall;
function dm_Enabled: int; stdcall;
function dm_Update: int; stdcall;

function alt_Open(Path: PChar; rw: Boolean): Boolean; stdcall;
procedure alt_Done; stdcall;
procedure alt_Swap; stdcall;
procedure alt_Swap1; stdcall;

function dm_Path(Path: PChar; MaxLen: int): PChar; stdcall;
function dm_Path1(Path: PChar; MaxLen: int): PChar; stdcall;

function dm_ms_unit: Integer; stdcall;
function dm_xy_rotate: Integer; stdcall;

function dmx_Get_Ellipsoid: int; stdcall;
function dmx_Get_Projection: int; stdcall;
function dmx_Get_Bound(G: PGPoly): int; stdcall;

procedure dm_gauss_bound(out lt,rb: TGauss); stdcall;

function dm_Get_sys(out pps,prj,elp: int;
                    out b1,b2,lc: Double;
                    out dx,dy,dz: int): int; stdcall;

procedure dm_Put_sys(pps,prj,elp: int;
                     b1,b2,lc: Double;
                     dx,dy,dz: int); stdcall;

function dm_Get_sys7(out sys: tsys): int; stdcall;
procedure dm_Put_sys7(sys: psys); stdcall;

procedure dm_Get_dm_Hdr(var Hdr: dm_Hdr); stdcall;
procedure dm_Put_dm_Hdr(var Hdr: dm_Hdr); stdcall;

function dm_Objects_Path(Path,Ext: PChar): PChar; stdcall;
function dm_Work_Path(Path,Dir,Name: PChar): PChar; stdcall;

function dm_get_scales(out list: PLPoly): int; stdcall;
function dm_put_scales(list: PLPoly; count: int): int; stdcall;

function dm_scan_level: int; stdcall;
function dm_scan_parent: int; stdcall;

procedure dm_Execute(Tool: TOnObject); stdcall;
procedure dm_Executev(Tool: TOnObject); stdcall;
procedure dm_Execute1(Tool: TOnObject1); stdcall;
procedure dm_Execute1v(Tool: TOnObject1); stdcall;
procedure dm_Execute2(Tool: TObjectFunc2); stdcall;

function dm_Get_Index_range(out minv,maxv: Integer): Integer;
stdcall;

function dm_Get_list(out Buf: PIntegers): Integer; stdcall;

function dm_Get_3d_list(Flags: Integer; Rgn: PLPoly;
                        out Buf: PIntegers): Integer; stdcall;

function dm_Get_func_list(func: TObjectFunc2;
                          out list: PIntegers): int; stdcall;
                        
function dm_FreePtr(P: Pointer): Pointer; stdcall;

procedure dm_GetRecord(var dRec: dm_Rec); stdcall;
procedure dm_PutRecord(var dRec: dm_Rec); stdcall;

function ok_Object(P: longint): Boolean; stdcall;

function dm_Object: longint; stdcall;
function dm_Goto_Root: longint; stdcall;

function dm_Goto_left: boolean; stdcall;
function dm_Goto_right: boolean; stdcall;
function dm_Goto_upper: boolean; stdcall;
function dm_Goto_down: boolean; stdcall;

function dm_Goto_home: longint; stdcall;
function dm_Goto_last: longint; stdcall;
function dm_Goto_node(p: longint): boolean; stdcall;
procedure dm_Jump_node(p: longint); stdcall;

function dm_Jump_id(id: longint): longint; stdcall;

procedure dm_Get_Position(out pos: TPoint); stdcall;
procedure dm_Set_Position(const pos: TPoint); stdcall;

function dm_Is_Childs(p: longint): Integer; stdcall;
function dm_Is_Child(par,ptr: Longint): Boolean; stdcall;

procedure dm_Mov_Child(run,dst: longint); stdcall;
function dm_Mov_Childs(dst,src: int): int; stdcall;
function dm_Move_Childs(dst,src: int; undo: Boolean): int; stdcall;

function dm_Is_Hole(run,par: longint): Boolean; stdcall;
function dm_Is_Next(prd,run: Longint): Boolean; stdcall;
function dm_Up_Object(ptr: longint): longint; stdcall;

function dm_Get_Holes(par: longint;
                      Holes: PIntegers;
                      MaxCount: int): int; stdcall;

function dm_Get_Stat(Stat: PIntegers;
                     StatMax: Integer): int; stdcall;

procedure dm_Put_Stat(Stat: PIntegers; Count: int); stdcall;

function dm_hf_x16: Boolean; stdcall;

function dm_this_object(ptr: int; Expr: PChar): Boolean; stdcall;

function dm_seek_dt(Expr: PChar): int; stdcall;
function dm_seek_dt1(Expr: PChar; List: PIntegers; MaxCount: int): int; stdcall;

function dm_hf_logic(Expr: PChar): bool; stdcall;

function dm_Get_unk(n: word): Boolean; stdcall;

function dm_Get_Word(n,bln: word; var w: word): Boolean; stdcall;
function dm_Get_Int(n,bln: word; var i: SmallInt): Boolean; stdcall;
function dm_Get_Long(n,bln: word; var i: longint): Boolean; stdcall;
function dm_Get_Real(n,bln: word; var r: float): Boolean; stdcall;
function dm_Get_Angle(n,bln: word; var r: float): Boolean; stdcall;
function dm_Get_String(n,len: word; var str): Boolean; stdcall;
function dm_Get_Ansi(n,len: word; str: PChar): Boolean;

function dm_Str_dbase1(Str: PChar; nn,col: int): PChar; stdcall;
function dm_Str_dbase(Str: PChar; nn: word): PChar; stdcall;
procedure dm_hf_dbase(ptr: int); stdcall;

function dm_Get_SValue(nn: int; Str: PChar; MaxLen: int): Boolean; stdcall;

function dm_def_int(nn,def: int): int;
function dm_def_Real(nn: int; def: double): double;

procedure dm_Put_unk(n: word); stdcall;
procedure dm_Put_Byte(n: word; b: byte); stdcall;
procedure dm_Put_Word(n: word; w: word); stdcall;
procedure dm_Put_Enum(n: word; w: word); stdcall;
procedure dm_Put_dBase(n: word; w: word); stdcall;
procedure dm_Put_Int(n: word; i: SmallInt); stdcall;
procedure dm_Put_Long(n: word; i: longint); stdcall;
procedure dm_Put_Real(n: word; r: float); stdcall;
procedure dm_Put_Angle(n: word; r: float); stdcall;
procedure dm_Put_Time(n: word; t: longint); stdcall;
procedure dm_Put_Date(n: word; d: longint); stdcall;
procedure dm_Put_String(n: word; s: PChar); stdcall;
procedure dm_Put_Rus(n: int; s: PChar); stdcall;

procedure dm_Put_Str(nn: int; s: PChar);
procedure dm_Put_Text(nn: int; const S: WideString);

function dm_Assign_Index(p: longint): longint; stdcall;

procedure dm_Del_hf(n: word; id: Id_Tag); stdcall;

function dm_Get_hf_Pool(lp: PPool; max: word): word; stdcall;
procedure dm_Put_hf_Pool(lp: PPool); stdcall;

procedure dm_hf_Pool_Get_Max_Size(sz: uint); stdcall;

function dmx_hf_Pool_Get(lp: PPool; ind,x16: int;
                         var nn: int; var id: Id_Tag;
                         val: PBytes): int; stdcall;

function dm_hf_Pool_Get(lp: PPool; ind: word;
                        var nn: word; var id: Id_Tag;
                        info: PBytes): word; stdcall;

function dm_hf_Pool_Put(lp: PPool; size: word;
                        nn: word; id: Id_Tag;
                        info: PBytes): word; stdcall;

function dmx_hf_Pool_Put(hf: PPool; maxSize: int;
                         nn: int; id: Id_Tag; val: PBytes): int;
stdcall;

procedure dm_hf_Pool_Delete(hf: PPool; nn: word; id: Id_Tag);
stdcall;

function dm_def_hf_Pool(hf: PPool; max: int): int; stdcall;

procedure dm_Init_hf_tags(def: Id_Tag); stdcall;
function dm_get_id_tag(nn: int): Id_Tag; stdcall;

procedure dm_hf_dump(hf: PPool; size: Integer;
                     nn: Integer; sval: PChar); stdcall;

function dm_get_length: Double; stdcall;
function dm_get_square: Double; stdcall;
function dm_get_child_square: Double; stdcall;

function dm_poly_square(lp: PLLine): Double; stdcall;

procedure dm_Copy_info(srcp,dstp: longint); stdcall;

function dm_Find_Frst_Code(code: longint; loc: byte): longint; stdcall;
function dm_Find_Next_Code(code: longint; loc: byte): longint; stdcall;
function dm_Find_Next_Object(Code: longint; Loc: byte): longint; stdcall;

function dmx_Find_Frst_Code(Code,Loc: Integer): Integer; stdcall;
function dmx_Find_Next_Code(Code,Loc: Integer): Integer; stdcall;

procedure dm_Find_Char_Is_Words(Value: Boolean); stdcall;

function dm_Find_Frst_Char(nn: word; id: Id_Tag; i: longint;
                           f: float; s: PChar): longint; stdcall;

function dm_Find_Next_Char(nn: word; id: Id_Tag; i: longint;
                           f: float; s: PChar): longint; stdcall;

function dm_Find_Frst_Link_Point: longint; stdcall;
function dm_Find_Next_Link_Point: longint; stdcall;

procedure dm_Get_Bound(var a,b: TPoint); stdcall;
procedure dm_Set_Bound(a,b: TPoint); stdcall;

function dm_Port_Contains_Bound(x1,y1,x2,y2: longint): Boolean;
stdcall;

procedure dm_is_Doctor(fl: Boolean); stdcall;

function dm_Get_Poly_Count: SmallInt; stdcall;  
function dm_Get_Poly_Buf(lp: PLLine; max: word): SmallInt; stdcall;
function dm_Set_Poly_Buf(lp: PLLine): SmallInt; stdcall;

function dm_z_res: int; stdcall;

function dm_Get_Poly_xyz(lp: PLLine; hp: PIntegers; lp_Max: int): int; stdcall;

function dm_Set_xyz(lp: PLLine; hp: PIntegers): Integer; stdcall;
procedure dm_dup_points(fl: Boolean); stdcall;

function dm_Height_Object(p: Integer): double; stdcall;
function dm_Get_Height(p: Integer; out h: double): Boolean; stdcall;
procedure dm_Put_Height(p: Integer; h: double); stdcall;
function dm_Delete_Height(p: Integer): Boolean; stdcall;

function dm_z_axe_exist(p: Integer): Boolean; stdcall;
function dm_z_axe_exist1(p: Int64): Boolean; stdcall;

function dm_Trunc_z_axe(p: Integer): Boolean; stdcall;
function dm_Up_z_axe(p: Integer): Boolean; stdcall;

function dm_Get_Color: word; stdcall;
procedure dm_Set_Color(cl: word); stdcall;

function dm_Get_Code: longint; stdcall;
procedure dm_Set_Code(code: longint); stdcall;

function dm_Get_Local: byte; stdcall;
procedure dm_Set_Local(loc: byte); stdcall;

function dm_Get_Tag: byte; stdcall;
procedure dm_Set_Tag(t: byte); stdcall;

procedure dm_Set_Flag(fl: byte; up: boolean); stdcall;

function dm_Get_Flags: byte; stdcall;
procedure dm_Set_Flags(flags: byte); stdcall;

function dm_Get_Level: byte; stdcall;
procedure dm_Set_Level(lev: byte); stdcall;

function dm_Add_Layer(code: longint; v: word): longint;
stdcall;

function dm_Add_Object(code,loc,lev: int;
                       lp: PLLine; hp: PIntegers;
                       hf: PPool; down: Boolean): int; stdcall;

function dm_Add_xyz(code,loc,view: int;
                    lp: PLLine; hp: PIntegers;
                    down: Boolean): longint; stdcall;

function dm_Add_Sign(c: longint; a,b: TPoint; v: word;
                     down: Boolean): longint;
stdcall;

function dm_Add_Poly(c: longint; loc: byte; v: word;
                     lp: PLLine; down: Boolean): longint;
stdcall;

function dm_Add_Text(c: longint; loc: byte; v: word; lp: PLLine;
                     s: PChar; down: Boolean): longint;
stdcall;

function dm_Add_attr(nn,loc: int; lp: PLLine; hf: PPool): int;
stdcall;

function dm_Add_DataType(nn: int; hf: PPool): int; stdcall;
function dm_Copy_DataTypes(src,dst,this: int): int; stdcall;

function dm_Set_Metadata(ptr,typ,nn: int; hf: PPool): int; stdcall;
procedure dm_Set_Metadata1(ptr,typ,nn: int; const stm: IStream); stdcall;

function dm_Add_Rect(c: longint; a,b: TPoint;
                     v: word; down: boolean): longint;
stdcall;

function dm_First_Object(p: longint): longint; stdcall;

function dm_Move_Object(prd,mov: longint; down: boolean): longint;
stdcall;

function dm_Del_Object(prd,run: longint): longint;
stdcall;

function dm_Delete_Object(prd,run: longint): longint;
stdcall;

function dm_only_Delete_Object(prd,run: longint): longint;
stdcall;

function dm_Next_Object(run: longint): longint; stdcall;
function dm_Pred_Object(prd,run: longint): longint; stdcall;
function dm_Dup_Object(run: longint): longint; stdcall;
function dm_Dup_Object1(run: int; lp: PLLine; hp: PIntegers): int; stdcall;

function dm_Repeat_Object(run: longint; lp: PLLine;
                          hp: PIntegers): longint; stdcall;

function dm_Repeat_Object2(run,par: longint): longint; stdcall;
                          
function dm_Object_Count: Integer; stdcall;
function dm_Object_id(I: Integer): Integer; stdcall;
function dm_Object_offs(I: Integer): Integer; stdcall;

function dm_Id_Object(run: longint): longint; stdcall;
function dm_Id_Offset(id: longint): longint; stdcall;

procedure dm_Cls_Parent(par: longint); stdcall;
procedure dm_Up_Childs(par: longint); stdcall;
procedure dm_Delete_Childs(par: longint); stdcall;
function dm_copy_holes(src,dst,undo: int): int; stdcall;

procedure dm_L_to_G(lx,ly: longint; var gx,gy: double); stdcall;
procedure dm_G_to_L(gx,gy: double; var lx,ly: longint); stdcall;

procedure dm_G_to_P(gx,gy: double; out px,py: double); stdcall;
procedure dm_R_to_P(gx,gy: double; out px,py: double); stdcall;

procedure dm_to_sm(ix,iy: longint; var ox,oy: longint);

function dm_Get_Angle_Length(a,b: TPoint; var f: double): double;
stdcall;

procedure dm_Char_Bound(code,ch: longint; out lt,rb: TGauss); stdcall;

procedure dm_Text_Bound(code: longint; txt: PChar;
                        lp,bp: PLLine; max,up: word); stdcall;

procedure dm_vgm_Bound(Ind: Integer;
                       const a,b: TPoint;
                       bp: PLLine; max: int); stdcall;
                        
procedure dm_Sign_Bound(code: longint; a,b: TPoint;
                        bp: PLLine; max: word); stdcall;

function dm_This_Text_Bound(lp: PLLine; Max: Integer): Integer;
stdcall;

function dm_Get_Polygon(bp: PLLine; max: Integer): Integer; stdcall;

function dm_OpenFonts: Pointer; stdcall;
procedure dm_CloseFonts(Fonts: Pointer); stdcall;
function dm_Text_Extent(Fonts: Pointer;
                        cl: int; k: double; s: PWideChar;
                        out th: int): int; stdcall;

procedure dm_Line_Attr(Fonts: Pointer;

                       lp: PLLine; cl: uint;
                       k,dx,dy,ds: Double;
                       s: PWideChar;

                       Receiver: Pointer;
                       Func: TOnAttrOut); stdcall;
                        
function dm_Ind_Blank: word; stdcall;
function dm_Get_Blank(i: word; lp: PWLine; max: word): word; stdcall;

function dm_Def_Blank(i: int; lp: PLLine; max: int): int;
stdcall;

function dm_Get_blank2(bln,typ: int; out List: ICustomList): int; stdcall;

function dm_Seek_Blank1(Ind: int): int; stdcall;
function dm_Seek_attr1(nn: int): PAbcRec1; stdcall;
function dm_Get_attr1(Ind: int): PAbcRec1; stdcall;

function dm_Get_std_hf(bln: int; List: PIntegers; Capacity: int): int; stdcall;

function dm_Get_dbf(bln,nnn: int; dbf: PChar): int; stdcall;

function dm_Get_enum(bln,nnn,val: int; str: PChar): PChar; stdcall;
function dm_Get_enum2(bln,nnn,val,col: int; str: PChar): PChar; stdcall;
function dm_enum_Indexof(bln,nnn: int; str: PChar): int; stdcall;
function dm_enumw_Indexof(bln,nnn: int; str,id: PChar): PChar; stdcall;

function dm_str_list(Str: PChar; MaxLen: int;
                     nnn: int; val: PChar): PChar; stdcall;

function dm_str_enumw(Str: PChar; MaxLen: int;
                      nnn,col: int; val: PChar): PChar; stdcall;

procedure dm_mdb_values(open: Boolean); stdcall;

function dm_seek_domen(nn: int): int; stdcall;
function dm_get_domen(ind: int; Str: PChar; MaxLen: int): int; stdcall;

function dm_trunc_list(Val: PChar; nnn: int): Boolean; stdcall;
function dm_trunc_list1(Val: PChar; nnn: int): Boolean; stdcall;

function dm_OpenDbaseValueGetter: Boolean; stdcall;
procedure dm_CloseDbaseValueGetter; stdcall;
procedure dm_SetDbaseValueComma(comma: PChar); stdcall;
function dm_StrDbaseValue(ptr,nn,column,Id: int; Str: PWideChar): Boolean; stdcall;

function dm_Get_Unicode1(n: word; s: PWideChar; maxLen: int): Boolean; stdcall;

function dm_Get_Unicode(n: word; s: PWideChar): boolean; stdcall;
procedure dm_Put_Unicode(n: word; s: PWideChar); stdcall;

function dm_Draw_HF(nn: int; s: PWideChar): PWideChar; stdcall;

function dm_Get_Double(n,bln: word; var r: double): boolean; stdcall;
procedure dm_Put_Double(n: word; r: double); stdcall;

function dm_Get_Range(nn: int; out op: int;
                      out v1,v2: double): Boolean; stdcall;

function dm_obj_open: int; stdcall;
procedure dm_obj_close; stdcall;

function dm_obj_attr(nn: int): int; stdcall;

function obj_Get_Count: int; stdcall;

function obj_Get_Object(i: int; var Code,Loc: int; ps: PChar): PChar;
stdcall;

function obj_get_color(code,loc: int): int; stdcall;
function obj_get_flags(code,loc: int): int; stdcall;

function obj_Code_by_Color(Code,Loc,Color: int): int; stdcall;

function obj_Ind_Blank(Code: longint; Loc: byte): word; stdcall;
function obj_Get_Blank(Code: longint; Loc: byte; lp: PWLine; max: word): word;
stdcall;

function obj_Get_Name(Code: longint; Loc: byte; s: PChar): PChar;
stdcall;

function obj_Get_Icon(Code,Loc: int;
                      Name: PChar; Ico: Pointer): int; stdcall;

function dm_open_idx: Boolean; stdcall;
procedure dm_close_idx; stdcall;

function idx_Get_Name(nn: int; s: PChar): PChar; stdcall;
function idx_get_tag(nn: int): Id_Tag; stdcall;

function id_Parent: longint; stdcall;

function dm_Get_Pen(var mm,tag,width,style: byte): byte; stdcall;
procedure dm_Set_Pen(mm,tag,width,style,pc: byte); stdcall;
procedure dmw_Set_Pen(r,g,b,mm: byte); stdcall;

function dm_Get_Brush(var fc,pc: byte): byte; stdcall;
procedure dm_Set_Brush(fc,pc,msk: byte); stdcall;

function dmw_Get_Brush(var r,g,b: byte): byte; stdcall;
procedure dmw_Set_Brush(r,g,b,msk: byte); stdcall;
procedure dmw_alfa_Brush(r,g,b,alfa: byte); stdcall;

function dm_Get_Graphics(Code: longint; Loc: byte): longint; stdcall;
procedure dm_Set_Graphics(cl: longint); stdcall;
procedure dm_Restore_Graphics; stdcall;

function dmw_Get_Color: int; stdcall;
procedure dmw_Set_Color(cl: int); stdcall;

procedure dm_Get_Text_Color(out blank,lt,up: Integer;
                            out font,height,fc: Integer); stdcall;

procedure dm_Set_Text_Color(blank,lt,up: Integer;
                            font,height,fc: Integer); stdcall;

function dm_decode_text_color(color: int; Font: PChar;
                              out height,fcolor: int): int; stdcall;
                            
procedure dmw_load_palette(nm: PChar); stdcall;
function dmw_get_rgb(var r,g,b: byte): Longint; stdcall;

function dm_Goto_by_Code(code: longint): longint; stdcall;

function dm_Get_Layer(code: longint): longint; stdcall;

function dm_New1(path,obj: PChar; sys: psys;
                 xmin,ymin,xmax,ymax: double;
                 ed: int): int; stdcall;

function dm_New(Path,Obj: PChar;

                pps,prj,elp, dx,dy,dz: int;
                b1,b2, lc: Double;

                xmin,ymin,xmax,ymax: double;
                ed: int): int; stdcall;

function dm_Frame(path,obj: PChar; pps,ed: int;
                  xmin,ymin,xmax,ymax: double): int;
stdcall;

function dm_Make(path,obj: PChar; pps: byte;
                 xmin,ymin,xmax,ymax: double): word;
stdcall;

function bl_Make(path,obj,nom: PChar): word; stdcall;
function bl_Make1(path,obj,nom: PChar; elp: int): int; stdcall;
function avia_Make(path,obj,nom: PChar): word; stdcall;

function wgs_Make(path,obj: PChar; const lt,rb: TGauss): Boolean;
stdcall;

function wgs_tdm(Dest,obj: PChar; const lt,rb: TGauss): Boolean;
stdcall;

// Создать новую карту в проекции UTM [WGS84]
function utm_Create(Dest: PChar;                    // имя файла
                    Obj: PChar;                     // Классификатор
                    bmin,lmin,bmax,lmax: Double;    // Габарит
                    Nzone: Integer;                 // Номер зоны, =37 Москва
                    Scale: Integer): Boolean;       // Масштаб
stdcall;

// Создать новую карту в проекции "меркатор цилиндрический" [WGS84]
function merc_Create(Dest: PChar;                   // имя файла
                     Obj: PChar;                    // Классификатор
                     bmin,lmin,bmax,lmax: Double;   // Габарит
                     bc: Double;                    // Базовая широта
                     elp: int;                      // Эллипсоид
                     Scale: int): Boolean;          // Масштаб
stdcall;

// Создать мировую карту в проекции "меркатор цилиндрический" [WGS84]
function wmerc_Create(Dest,Obj: PChar): Boolean;

procedure dm_Cls; stdcall;

function dm_Copy(src,dst,obj: PChar): Boolean; stdcall;
function dm_add_grid(code,mm: int): int; stdcall;

// Изменить габарит карты <x1,y1,x2,y2> метры / градусы
// в зависимости от СК карты
procedure dm_map_bound(x1,y1,x2,y2: Double); stdcall;

// Изменить габарит карты <x1,y1,x2,y2> pps= 0=метры, 1=радианы
procedure dm_map_bound1(x1,y1,x2,y2: Double; pps: int); stdcall;

function dm_rebound2(margin: double; extend: Boolean): int; stdcall;

// Рассчитать габарит карты по объектам
// [extend]=true - только увеличивать габарит
function dm_rebound(extend: Boolean): int; stdcall;

function dm_Cut_Polygon(dst: PChar; lp: PLLine): Boolean; stdcall;

procedure dm_set_param(Id: int; v: double); stdcall;

procedure dm_Poly_params(lp: PLPoly; N: int; out s,l: Double); stdcall;

function dm_lpoly_length(lp: PLPoly; hp: PIntegers; N: int): Double; stdcall;
function dm_Poly_length(lp: PLLine; hp: PIntegers): Double; stdcall;

function dm_lg_transit(l,g: PGPoly): Integer; stdcall;

procedure dm_L_to_R(x,y: longint; var b,l: double); stdcall;
procedure dm_R_to_L(b,l: double; var x,y: longint); stdcall;
procedure dm_X_to_L(x,y: double; bl: Integer; var lx,ly: longint); stdcall;

procedure dm_to_wgs(x,y,z: Integer; out w: txyz); stdcall;
procedure wgs_to_dm(x,y,z: Double; out v: VPoint); stdcall;

function lc_zone(lc: double): word; stdcall;
function dm_zone: longint; stdcall;
function dm_pps: byte; stdcall;
function dm_prj: byte; stdcall;
function dm_elp: byte; stdcall;

procedure dm_BL_XY(b,l: double; var x,y: double); stdcall;
procedure dm_XY_BL(x,y: double; var b,l: double); stdcall;

function dm_azimuth(const a,b: TPoint;
                    out fi: Double): double; stdcall;

function dm_Contains(x,y: Double; pps: Integer): boolean; stdcall;

function dm_Filter_region(Filter: PChar): byte; stdcall;

function dm_Filter(Filter,Dst: PChar; lp: PLLine; rgn: byte): PChar;
stdcall;

function dm_Filter2(Filter,Dst,dm1,dm2: PChar; mode: int): PChar;
stdcall;

function dm_Filter_list(Dbf: PChar;
                        lp: PLLine; rgn: int;
                        out Buf: PInt64s): int; stdcall;

procedure dm_apply_pkg(map,pkg,cmd: PChar); stdcall;

function dm_Objects_Count: longint; stdcall;

procedure dm_Undo_More(fl: Boolean); stdcall;
procedure dm_Undo_Push(run: longint; cmd: byte); stdcall;
procedure dm_Undo_childs(p: int); stdcall;
function dm_Undo_Pop(ins: Boolean): longint; stdcall;
function dm_Undo_Hide: longint; stdcall;

function dm_Undo_Object(out Code,Loc,x1,y1,x2,y2: int): longint; stdcall;

function dm_Undo_Last(out code,loc,cmd,modify: int;
                      out code1: int; out pos: TPoint): int64; stdcall;

function dm_Undo_Last_Pool(lp: PPool; maxLen: int): int; stdcall;

function Link_Open(path: PChar): Integer; stdcall;
procedure Link_Done; stdcall;

procedure Link_pair(i: Integer; var ix,iy, gx,gy: longint); stdcall;
procedure Link_add(ix,iy, gx,gy: longint); stdcall;
function Link_Count: Integer; stdcall;

procedure dm_to_bit(ix,iy: longint; var ox,oy: longint); stdcall;
procedure bit_to_dm(ix,iy: longint; var ox,oy: longint); stdcall;

procedure link_a_to_b(ix,iy: longint; var ox,oy: longint); stdcall;
procedure link_b_to_a(ix,iy: longint; var ox,oy: longint); stdcall;

procedure dm_Bin_Dir(dir: PChar); stdcall;
procedure dm_AutoSave(Count: Integer); stdcall;
function dm_Scale: Integer; stdcall;

function dm_Object_Icon(Code,Loc: Integer): HBitMap; stdcall;

procedure dm_Polygon_Square(Value: Boolean); stdcall;

function dm_cn_to_dm(p: Integer): Boolean; stdcall;

function batch_cn_to_dm(loc1,loc2: Integer;
                        cp: PIntegers; Count: Integer;
                        StepIt: TStepItProc): Integer; stdcall;

function dm_is_cn: Boolean; stdcall;
// true - если файл поддерживает цепочно-узловую структуру

function dm_Get_vc_Count: Integer; stdcall;
// счетчик узлов

function dm_Get_vc_Id(I: Integer): Integer; stdcall;
// идентификатор узла

function dm_Get_vc(Id: Cardinal; out v: tcn_rec): Boolean;
stdcall; // узел

function dm_Get_ve_Count: Integer; stdcall;
// счетчик ребер

function dm_Get_ve_Id(I: Integer): Integer; stdcall;
// идентификатор ребра

function dm_Get_ve(Id: Cardinal; out v: tcn_rec): Boolean;
stdcall; // ребро

function dm_Get_vc_attv(id: Cardinal): Cardinal; stdcall;
function dm_Get_ve_attv(id: Cardinal): Cardinal; stdcall;
procedure dm_Set_vc_attv(id,attv: Cardinal); stdcall;
procedure dm_Set_ve_attv(id,attv: Cardinal); stdcall;

function dm_Get_vc_lab(id: Cardinal): Cardinal;
function dm_Get_ve_lab(id: Cardinal): Cardinal;
procedure dm_Set_vc_lab(id,lab: Cardinal);
procedure dm_Set_ve_lab(id,lab: Cardinal);

function dm_Get_ve_Poly(Id: Cardinal;
                        lp: PLLine; hp: PIntegers;
                        lp_Max: Integer): Integer; stdcall;
// метрика ребра

function dm_Get_vc_ref(Id: Cardinal; vc: PIntegers;
                       vc_Max: Integer): Integer; stdcall;
// ссылки ребер на узел

function dm_Get_ve_ref(Id: Cardinal; ve: PIntegers;
                       ve_Max: Integer): Integer; stdcall;
// ссылки объектов на ребро

function dm_Get_vi_ref(Id: Cardinal; vi: PIntegers;
                       vi_Max: Integer): Integer; stdcall;
// ссылки объектов на узел

function dm_add_vc(Id: Cardinal; X,Y: Integer;
                   Z: PInteger): Cardinal;
stdcall; // Добавить узел

function dm_add_ve(Id, Vc1,Vc2: Cardinal; lp: PLLine;
                   hp: PIntegers): Cardinal; stdcall;
// Добавить ребро

function dm_Delete_vc(Id: Cardinal): Boolean; stdcall;
// Удалить узел
function dm_Delete_ve(Id: Cardinal): Boolean; stdcall;
// Удалить ребро

procedure dm_Update_vc(Id: Cardinal; X,Y: Integer;
                       Z: PInteger); stdcall;
// Изменить узел

procedure dm_Update_ve(Id, Vc1,Vc2: Cardinal;
                       lp: PLLine; hp: PIntegers); stdcall;
// Изменить ребро

function dm_merge_vc(vc1,vc2: Cardinal): Boolean; stdcall;
// Притянуть узлы - второй к первому

procedure dm_ve_oref(ve,vc1,vc2: Cardinal;
                     List: PIntegers; Count: Integer); stdcall;
// Заменить ребро на список [List - Count]
// vc1,vc2 - узлы ребра до операции

function dm_ve_Split(ve,vc: Cardinal): Cardinal; stdcall;

function dm_Get_fc_Count: Integer; stdcall;
// счетчик коллекций

function dm_Get_fc_Id(I: Integer): Integer; stdcall;
// идентификатор коллекции

function dm_Get_fc(Id: Cardinal; out v: tcn_rec): Boolean;
stdcall; // коллекция

function dm_fc_Get_code(Id: Cardinal): int; stdcall;
// Получить код коллекции

function dm_fc_Get_list(Id: Cardinal; lp: PLLine; lp_Max: Int): int;
stdcall;
// Получить список коллекции
// x - идентификатор объекта
// y - тип идентификатор, код связи

procedure dm_fc_Update(Id, OBJL: Cardinal; lp: PLLine); stdcall;
// Изменить коллекцию
// OBJL - код
// lp - список

function dm_fc_Get_hf(Id: Cardinal; lp: PPool; BufSize: Int): int; stdcall;
// Получить семантику коллекции

procedure dm_fc_Put_hf(Id: Cardinal; lp: PPool); stdcall;
// Изменить семантику коллекции

function dm_lp_fill(Items: PInt64s; Count: int;
                    lp: PLLine; lp_max: int;
                    const p, lt,rb: TPoint;
                    cut: Boolean): int; stdcall;

function dm_group_fill(Items: PInt64s; Count: int;
                       lp: PLLine; lp_max: int): int; stdcall;
                    
function dm_Up_lndare(code: int; lp,buf: PLLine;
                      ptr: PIntegers; ptr_Max: Int): Int;
stdcall;

function dm_Out_lndare(ptr: int; list: PIntegers; listMax: int): int;
stdcall;

function dm_this_hf(ptr: Integer; Expr: PChar): boolean;
stdcall;

function dm_Init_pp(out pp: TPolyPolygon;
                    ACounterCapacity: Integer;
                    APointCapacity: Integer): Boolean;
stdcall;

procedure dm_Free_pp(var pp: TPolyPolygon); stdcall;

function dm_Load_pp(var pp: TPolyPolygon): Integer; stdcall;

function dm_Get_pp_lp(pp: PPolyPolygon; pp_Ind: Integer;
                      lp: PPolyLine; lp_Max: Integer): Integer;
stdcall;

function dm_fe_Get_Contour(lp_Ind: Integer; lp: PLLine;
                           dst: PPolyLine; dst_Max: Integer): Integer;
stdcall;

function dm_Add_Polyline(code,loc,lev: Integer;
                         lp: PPolyLine; down: Boolean): longint;
stdcall;

function xyz_Add_Polyline(code,loc,lev: Integer;
                         lp: PPolyLine; hp: PIntegers;
                         down: Boolean): longint;
stdcall;

function dm_Size: tgauss;
function dm_Resolution: double;
function dm_dist(d: double; ed: int): double;
function dm_z_dist(d: double; ed: int): double;
function dm_res_m: int;

function dm_az_to_map(const p: TPoint; az: double): double;

function dm_Vector_Length(lp: PLPoly): Double;

function dm_Get_mf: PLLine;
function dm_Get_Polyline: PLLine;
function lp_to_xy(lp: PLLine; ed: Double): PLLine;

function StrToCode(const s: string): longint;
function CodeToStr(code: longint): string;

function cn_ptr(rcid,rcnm,ornt,usag,mask: Integer): TPoint;

function dm_Get_xsys(out sys: tsys): Integer;
procedure dm_Put_xsys(const sys: tsys);

function dm_GFrame(Path: PChar; L: PLPoly;
                   G,B: PGPoly; out s: tsys): Integer;

function dm_Get_max_ival(nn: Integer): Integer;

function dbase_open(Path: PChar): Boolean; stdcall;
procedure dbase_close; stdcall;
function dbase_RowCount: Integer; stdcall;
function dbase_ivalue(Row,Col: Integer): Integer; stdcall;
function dbase_value(Row,Col: Integer; val: PChar): PChar; stdcall;

function dm_Get_scale_list(buf: PIntegers; MaxSize: Integer): Integer;
stdcall;

function mf_init(MinCount: Integer): Pointer; stdcall;
procedure mf_done(mf: Pointer); stdcall;
procedure mf_clear(mf: Pointer); stdcall;
procedure mf_next(mf: Pointer; const p: TPoint; z: PInteger); stdcall;
function mf_end_contour(mf: Pointer): Integer; stdcall;
function mf_add_contour(mf: Pointer;
                        lp: PLPoly; hp: PIntegers;
                        Count: int): int; stdcall;

function mf_add_holes(mf: Pointer; Ptr: int): int; stdcall;

function mf_pop_holes(mf: Pointer; Ptr: int): int; stdcall;

function mf_break(mf: Pointer; lp: PLLine; lpMax: Integer): Integer; stdcall;

function mf_break1(lp: PLPoly; cp: PIntegers; n: int;
                   dst: PLLine; dstMax: int): int; stdcall;

function mf_load_poly(mf: Pointer; Ptr: Int64): Integer; stdcall;

function mf_get_part(mf: Pointer; Ind: Integer;
                     lp: PLLine; hp: PIntegers;
                     lpMax: Integer): Integer; stdcall;

function dm_Get_mesh(out vp: PVPoly;
                     out vn: Integer;
                     out fp: PIntegers;
                     out fn: Integer): Integer; stdcall;

function alt_Copy_Object(Ptr: int): int; stdcall;
function alt_Copy_Layer(Ptr: int): int; stdcall;

function dm_down_level: Boolean; stdcall;
                     
procedure dm_Seek_layer(Code: DWord); stdcall;
procedure dm_seek_layerp(P: int); stdcall;

function dm_Clean_Layers: longint; stdcall;

function dm_Update_User(User,Data: PChar): Boolean; stdcall;

function dm_trk_new(Dest,Obj: PChar; z_ed: int): pointer; stdcall;
procedure dm_trk_done(trk: pointer); stdcall;
procedure dm_trk_name(obj: pointer; Name: PChar); stdcall;
procedure dm_trk_pos(trk: pointer; pt: PDoubles); stdcall;

function dm_pickupList(const lt,rb: TPoint;
                       out List: PInt64s): int; stdcall;

function dm_GetAttrList(nn: int; out List: ICustomList): int; stdcall;

function dm_Get_role(ptr: int; v: PIntegers): uint; stdcall;
function dm_role_plus_guid(ptr: int): Boolean; stdcall;
function dm_role_restore(up,ptr: int): Boolean; stdcall;

function dm_Is_link_objects(ptr1,ptr2: int): Boolean; stdcall;
function dm_link_objects(ptr1,ptr2,mode: int; Name: PChar): int; stdcall;
function dm_unlink_objects(ptr1,ptr2: int; Name: PChar): Boolean; stdcall;
function dm_is_unk_role(ptr,run: int): Boolean; stdcall;

function dm_recode_roles(ptr: int): int; stdcall;
function dm_role_rename(ptr1,ptr2: int; Name: PChar): Boolean; stdcall;
function dm_role_owner(ptr1,ptr2,run: int): Boolean; stdcall;

function dm_filter_datatypes(ptr: int; undo: Boolean): int; stdcall;
function dm_sync_attrs(up1,up2: int; undo: Boolean): int; stdcall;
function dm_after_join_polylines(ptr: int; const e1,e2: TPoint; undo: Boolean): int; stdcall;

function dm_seek_frst_guid(ptr: int; ptop: pint): int; stdcall;
function dm_seek_next_guid(ptr,top: int): int; stdcall;
function dm_read_guid(ptr: int; id,rev: PChar): PChar; stdcall;
procedure dm_add_guid(ptr: int; id,rev: PChar); stdcall;
function dm_offset_by_guid(guid: PChar): int; stdcall;

function dm_seek_frst_locid(ptr: int; ptop: pint): int; stdcall;
function dm_seek_next_locid(ptr,top: int): int; stdcall;
function dm_read_locid(ptr: int; map,map1: PChar): int; stdcall;
function dm_add_locid(ptr: int): int; stdcall;

function get_locid1(ptr: int; map,map1: PChar; out id: int): bool;

function dm_frst_relation(ptr: int; out top: int): int; stdcall;
function dm_next_relation(ptr, top: int): int; stdcall;

function dm_get_relation(ptr: int;
                         out dir,typ: int;
                         guid,acronym,name: PChar): int; stdcall;

function dm_frst_datatype(ptr,nn: int; out top: int): int; stdcall;
function dm_next_datatype(ptr, nn, top: int): int; stdcall;

function dm_GetInterface(const IID: TGUID; out Obj): HResult; stdcall;

function dm_get_datatype_count(ptr,nn: int): int;

function Id_Equal(itag,otag: Id_Tag): Boolean;

function dm_seek_node(ptr,loc: int): Boolean;

function dm_to_fe(ptr: int): Int64;

procedure StrObjName(Str: PChar; code,loc: int);
function ObjNameStr(code,loc: int): String;

function dm_update_layer(Code: DWord): int;
function dm_update_layer1(const pos: TPoint; code: uint): bool;
function dm_update_layer2(code: uint): bool;

function code_to_attr(code: int): int;

implementation

uses
  Math,
  Classes,
  Sysutils,
  WStrings;

const
  dll_dm = 'dll_dm.dll';
  dll_util = 'dm_util.dll';

function GetPolybuf(out lp: PLLine;
                    out hp: PIntegers): int;
external dll_dm;

//function dm_operation(map1, map2, dest: PChar; operation: Integer; progress: TProgressFunc): Boolean; external dll_util;
//function dm_operation(map1, map2, dest: PChar; operation: Integer): Boolean; external dll_util;
function dm_operation(map1, map2, dest: PChar; operation, flags: int): Boolean;  external dll_util;
procedure set_dm_scan_progress(f: TProgressFunc);  external dll_util;

function GetBinDir: PChar; external dll_dm;
procedure SetBinDir(dir: PChar); external dll_dm;
procedure SetSpaceDir(Dir: PChar); external dll_dm;
procedure iniSpaceDir(Ini: PChar); external dll_dm;

function dm_Open(path: PChar; edit: boolean): word;
external dll_dm index 1;

procedure dm_Done; external dll_dm index 2;
procedure dm_File; external dll_dm index 3;

function dm_Handle: Integer; external dll_dm;
function dm_Enabled: Integer; external dll_dm;
function dm_Update: Integer; external dll_dm;

function alt_Open(Path: PChar; rw: Boolean): Boolean;
external dll_dm;

procedure alt_Done; external dll_dm;
procedure alt_Swap; external dll_dm;
procedure alt_Swap1; external dll_dm;

function dm_Path(Path: PChar; MaxLen: int): PChar;
external dll_dm;

function dm_Path1(Path: PChar; MaxLen: int): PChar; 
external dll_dm;

function dm_ms_unit: Integer; external dll_dm;
function dm_xy_rotate: Integer; external dll_dm;

function dmx_Get_Ellipsoid: int; external dll_dm;
function dmx_Get_Projection: int; external dll_dm;
function dmx_Get_Bound(G: PGPoly): int; external dll_dm;

procedure dm_gauss_bound(out lt,rb: TGauss); external dll_dm;

function dm_Get_sys(out pps,prj,elp: Integer;
                    out b1,b2,lc: Double;
                    out dx,dy,dz: Integer): Integer; external dll_dm;

procedure dm_Put_sys(pps,prj,elp: Integer;
                     b1,b2,lc: Double;
                     dx,dy,dz: Integer); external dll_dm;

function dm_Get_sys7(out sys: tsys): Integer; external dll_dm;
procedure dm_Put_sys7(sys: psys); external dll_dm;

procedure dm_Get_dm_Hdr(var Hdr: dm_Hdr); external dll_dm index 4;
procedure dm_Put_dm_Hdr(var Hdr: dm_Hdr); external dll_dm index 5;

function dm_Objects_Path(Path,Ext: PChar): PChar;
external dll_dm index 6;

function dm_Work_Path(Path,Dir,Name: PChar): PChar;
external dll_dm;

function dm_get_scales(out list: PLPoly): int;
external dll_dm;

function dm_put_scales(list: PLPoly; count: int): int; 
external dll_dm;

function dm_scan_level: Integer; external dll_dm;
function dm_scan_parent: int; external dll_dm;

procedure dm_Execute(Tool: TOnObject); external dll_dm index 7;
procedure dm_Executev(Tool: TOnObject); external dll_dm;
procedure dm_Execute1(Tool: TOnObject1); external dll_dm;
procedure dm_Execute1v(Tool: TOnObject1); external dll_dm;
procedure dm_Execute2(Tool: TObjectFunc2); external dll_dm;

function dm_Get_Index_range(out minv,maxv: Integer): Integer;
external dll_dm;

function dm_Get_list(out Buf: PIntegers): Integer; external dll_dm;

function dm_Get_3d_list(Flags: Integer; Rgn: PLPoly;
                        out Buf: PIntegers): Integer; external dll_dm;

function dm_Get_func_list(func: TObjectFunc2;
                          out list: PIntegers): int; external dll_dm;

function dm_FreePtr(P: Pointer): Pointer; external dll_dm;

procedure dm_GetRecord(var dRec: dm_Rec); external dll_dm index 8;
procedure dm_PutRecord(var dRec: dm_Rec); external dll_dm index 9;

function ok_Object(P: longint): Boolean; external dll_dm;

function dm_Object: longint; external dll_dm index 10;
function dm_Goto_Root: longint; external dll_dm index 11;
function dm_Goto_left: boolean;  external dll_dm index 12;
function dm_Goto_right: boolean; external dll_dm index 13;
function dm_Goto_upper: boolean; external dll_dm index 14;
function dm_Goto_down: boolean;  external dll_dm index 15;
function dm_Goto_home: longint;  external dll_dm index 16;
function dm_Goto_last: longint;  external dll_dm index 17;
function dm_Goto_node(p: longint): boolean; external dll_dm index 18;
procedure dm_Jump_node(p: longint); external dll_dm index 19;

function dm_Jump_id(id: longint): longint; external dll_dm;

procedure dm_Get_Position(out pos: TPoint); external dll_dm;
procedure dm_Set_Position(const pos: TPoint); external dll_dm;

function dm_Is_Childs(p: longint): Integer; external dll_dm;
function dm_Is_Child(par,ptr: Longint): Boolean; external dll_dm;

procedure dm_Mov_Child(run,dst: longint); external dll_dm;
function dm_Mov_Childs(dst,src: int): int; external dll_dm;
function dm_Move_Childs(dst,src: int; undo: Boolean): int; external dll_dm;

function dm_Is_Hole(run,par: longint): Boolean; external dll_dm;
function dm_Is_Next(prd,run: Longint): Boolean; external dll_dm;
function dm_Up_Object(ptr: longint): longint; external dll_dm;

function dm_Get_Holes(par: longint;
                      Holes: PIntegers;
                      MaxCount: Integer): Integer; external dll_dm;

function dm_Get_Stat(Stat: PIntegers;
                     StatMax: Integer): Integer; external dll_dm;

procedure dm_Put_Stat(Stat: PIntegers; Count: Integer);
external dll_dm;

function dm_hf_x16: Boolean; external dll_dm;

function dm_this_object(ptr: int; Expr: PChar): Boolean;
external dll_dm;

function dm_seek_dt(Expr: PChar): int; external dll_dm;
function dm_seek_dt1(Expr: PChar; List: PIntegers; MaxCount: int): int;
external dll_dm;

function dm_hf_logic(Expr: PChar): bool; external dll_dm;

function dm_Get_unk(n: word): Boolean; external dll_dm;

function dm_Get_Word(n,bln: word; var w: word): boolean;
external dll_dm index 20;
function dm_Get_Int(n,bln: word; var i: SmallInt): boolean;
external dll_dm index 21;
function dm_Get_Long(n,bln: word; var i: longint): boolean;
external dll_dm index 22;
function dm_Get_Real(n,bln: word; var r: float): boolean;
external dll_dm index 23;
function dm_Get_Angle(n,bln: word; var r: float): boolean;
external dll_dm index 24;
function dm_Get_String(n,len: word; var str): boolean;
external dll_dm index 25;

function dm_Get_Ansi(n,len: word; str: PChar): boolean;
var
  s: ShortString;
begin
  StrCopy(str,''); 
  Result:=dm_Get_String(n,len,s);
  if Result then StrPCopy(str,s)
end;

function dm_Str_dbase1(Str: PChar; nn,col: int): PChar; external dll_dm;
function dm_Str_dbase(Str: PChar; nn: word): PChar; external dll_dm;
procedure dm_hf_dbase(ptr: int); external dll_dm;

function dm_Get_SValue(nn: int; Str: PChar; MaxLen: int): Boolean;
external dll_dm;

function dm_def_int(nn,def: int): int;
var
  v: int;
begin
  Result:=def;
  if dm_get_long(nn,0,v) then
  Result:=v
end;

function dm_def_Real(nn: int; def: double): double;
var
  v: double;
begin
  Result:=def;
  if dm_get_double(nn,0,v) then
  Result:=v
end;

procedure dm_Put_unk(n: word); external dll_dm;
procedure dm_Put_Byte(n: word; b: byte); external dll_dm index 26;
procedure dm_Put_Word(n: word; w: word); external dll_dm index 27;
procedure dm_Put_Enum(n: word; w: word); external dll_dm index 28;
procedure dm_Put_dBase(n: word; w: word); external dll_dm index 29;
procedure dm_Put_Int(n: word; i: SmallInt); external dll_dm index 30;
procedure dm_Put_Long(n: word; i: longint); external dll_dm index 31;
procedure dm_Put_Real(n: word; r: float); external dll_dm index 32;
procedure dm_Put_Angle(n: word; r: float); external dll_dm index 33;
procedure dm_Put_Time(n: word; t: longint); external dll_dm index 34;
procedure dm_Put_Date(n: word; d: longint); external dll_dm index 35;
procedure dm_Put_String(n: word; s: PChar); external dll_dm index 36;

procedure dm_Put_Rus(n: int; s: PChar); external dll_dm;

procedure dm_Put_Str(nn: int; s: PChar);
begin
  if s[0] = #0 then
    dm_del_hf(nn,_string)
  else
    dm_Put_String(nn,s)
end;

procedure dm_Put_Text(nn: int; const S: WideString);
var
  w: TUnicode; t: TShortstr;
begin
  if length(S) = 0 then
    dm_del_hf(nn,_string)
  else
  if length(S) < 200 then begin
    StrPCopy(t,S);
    dm_Put_rus(nn,t)
  end
  else begin
    StrPCopyW(w,S,sizeOf(w) div 2 - 1);
    dm_Put_unicode(nn,w)
  end
end;

function dm_Assign_Index(p: longint): longint; external dll_dm;

procedure dm_Del_hf(n: word; id: Id_Tag); external dll_dm;

function dm_Get_hf_Pool(lp: PPool; max: word): word;
external dll_dm index 37;
procedure dm_Put_hf_Pool(lp: PPool);
external dll_dm index 38;

procedure dm_hf_Pool_Get_Max_Size(sz: uint);
external dll_dm;

function dmx_hf_Pool_Get(lp: PPool; ind,x16: int;
                         var nn: int; var id: Id_Tag;
                         val: PBytes): int;
external dll_dm;

function dm_hf_Pool_Get(lp: PPool; ind: word;
                        var nn: word; var id: Id_Tag; info: PBytes): word;
external dll_dm index 39;

function dm_hf_Pool_Put(lp: PPool; size: word;
                        nn: word; id: Id_Tag; info: PBytes): word;
external dll_dm index 40;

function dmx_hf_Pool_Put(hf: PPool; maxSize: int;
                         nn: int; id: Id_Tag; val: PBytes): int;
external dll_dm;

procedure dm_hf_Pool_Delete(hf: PPool; nn: word; id: Id_Tag);
external dll_dm;

function dm_def_hf_Pool(hf: PPool; max: int): int;
external dll_dm;

procedure dm_Init_hf_tags(def: Id_Tag);
external dll_dm;

function dm_get_id_tag(nn: int): Id_Tag;
external dll_dm;

procedure dm_hf_dump(hf: PPool; size: Integer;
                     nn: Integer; sval: PChar);
external dll_dm;

function dm_get_length: Double; external dll_dm;
function dm_get_square: Double; external dll_dm;
function dm_get_child_square: Double; external dll_dm;

function dm_poly_square(lp: PLLine): Double;
external dll_dm;

procedure dm_Copy_info(srcp,dstp: longint);
external dll_dm;

function dm_Find_Frst_Code(code: longint; loc: byte): longint;
external dll_dm index 41;
function dm_Find_Next_Code(code: longint; loc: byte): longint;
external dll_dm index 42;

function dm_Find_Next_Object(Code: longint; Loc: byte): longint;
external dll_dm;

function dmx_Find_Frst_Code(Code,Loc: Integer): Integer;
external dll_dm;

function dmx_Find_Next_Code(Code,Loc: Integer): Integer;
external dll_dm;

procedure dm_Find_Char_Is_Words(Value: Boolean);
external dll_dm;

function dm_Find_Frst_Char(nn: word; id: Id_Tag; i: longint;
                           f: float; s: PChar): longint;
external dll_dm index 43;

function dm_Find_Next_Char(nn: word; id: Id_Tag; i: longint;
                           f: float; s: PChar): longint;
external dll_dm index 44;

function dm_Find_Frst_Link_Point: longint; external dll_dm;
function dm_Find_Next_Link_Point: longint; external dll_dm;

procedure dm_Get_Bound(var a,b: TPoint); external dll_dm index 50;
procedure dm_Set_Bound(a,b: TPoint); external dll_dm index 51;

function dm_Port_Contains_Bound(x1,y1,x2,y2: longint): boolean;
external dll_dm;

procedure dm_is_Doctor(fl: Boolean); external dll_dm;

function dm_Get_Poly_Count: SmallInt;
external dll_dm index 52;
function dm_Get_Poly_buf(lp: PLLine; max: word): SmallInt;
external dll_dm index 53;
function dm_Set_Poly_Buf(lp: PLLine): SmallInt;
external dll_dm index 54;

function dm_z_res: Integer; external dll_dm;

function dm_Get_Poly_xyz(lp: PLLine; hp: PIntegers;
                         lp_Max: Integer): Integer;
external dll_dm;

function dm_Set_xyz(lp: PLLine; hp: PIntegers): Integer;
external dll_dm;

procedure dm_dup_points(fl: Boolean);
external dll_dm;

function dm_Height_Object(p: Integer): double; external dll_dm;
function dm_Get_Height(p: Integer; out h: double): Boolean; external dll_dm;
procedure dm_Put_Height(p: Integer; h: double); external dll_dm;
function dm_Delete_Height(p: Integer): Boolean; external dll_dm;

function dm_z_axe_exist(p: Integer): Boolean; external dll_dm;
function dm_z_axe_exist1(p: Int64): Boolean; external dll_dm;

function dm_Trunc_z_axe(p: Integer): Boolean; external dll_dm;
function dm_Up_z_axe(p: Integer): Boolean; external dll_dm;

function dm_Get_Color: word; external dll_dm index 55;
procedure dm_Set_Color(cl: word); external dll_dm index 56;

function dm_Get_Code: longint; external dll_dm index 57;
procedure dm_Set_Code(code: longint); external dll_dm index 58;

function dm_Get_Local: byte; external dll_dm index 59;
procedure dm_Set_Local(loc: byte); external dll_dm index 60;

function dm_Get_Tag: byte; external dll_dm index 61;
procedure dm_Set_Tag(t: byte); external dll_dm index 62;
procedure dm_Set_Flag(fl: byte; up: boolean); external dll_dm index 63;

function dm_Get_Flags: byte; external dll_dm;
procedure dm_Set_Flags(flags: byte); external dll_dm;

function dm_Get_Level: byte; external dll_dm;
procedure dm_Set_Level(lev: byte); external dll_dm;

function dm_Add_Layer(code: longint; v: word): longint;
external dll_dm index 71;

function dm_Add_Object(code,loc,lev: int;
                       lp: PLLine; hp: PIntegers;
                       hf: PPool; down: Boolean): int;
external dll_dm;

function dm_Add_xyz(code,loc,view: int;
                    lp: PLLine; hp: PIntegers;
                    down: Boolean): longint;
external dll_dm;

function dm_Add_Sign(c: longint; a,b: TPoint; v: word;
                     down: boolean): longint;
external dll_dm index 72;

function dm_Add_Poly(c: longint; loc: byte; v: word;
                     lp: PLLine; down: boolean): longint;
external dll_dm index 73;

function dm_Add_Text(c: longint; loc: byte; v: word; lp: PLLine;
                     s: PChar; down: boolean): longint;
external dll_dm index 74;

function dm_Add_attr(nn,loc: int; lp: PLLine; hf: PPool): int;
external dll_dm;

function dm_Add_DataType(nn: int; hf: PPool): int;
external dll_dm;

function dm_Copy_DataTypes(src,dst,this: int): int;
external dll_dm;

function dm_Set_Metadata(ptr,typ,nn: int; hf: PPool): int;
external dll_dm;

procedure dm_Set_Metadata1(ptr,typ,nn: int; const stm: IStream);
external dll_dm;

function dm_Add_Rect(c: longint; a,b: TPoint;
                     v: word; down: boolean): longint;
external dll_dm;

function dm_First_Object(p: longint): longint;
external dll_dm;

function dm_Move_Object(prd,mov: longint; down: boolean): longint;
external dll_dm index 75;

function dm_Del_Object(prd,run: longint): longint;
external dll_dm index 76;

function dm_Delete_Object(prd,run: longint): longint; external dll_dm;

function dm_only_Delete_Object(prd,run: longint): longint;
external dll_dm;

function dm_Next_Object(run: longint): longint; external dll_dm;
function dm_Pred_Object(prd,run: longint): longint; external dll_dm;

function dm_Dup_Object(run: longint): longint; external dll_dm;
function dm_Dup_Object1(run: int; lp: PLLine; hp: PIntegers): int;
external dll_dm;

function dm_Repeat_Object(run: longint; lp: PLLine;
                          hp: PIntegers): longint; external dll_dm;

function dm_Repeat_Object2(run,par: longint): longint; external dll_dm;

function dm_Object_Count: Integer; external dll_dm;
function dm_Object_id(I: Integer): Integer; external dll_dm;
function dm_Object_offs(I: Integer): Integer; external dll_dm;

function dm_Id_Object(run: longint): longint; external dll_dm;
function dm_Id_Offset(id: longint): longint; external dll_dm;

procedure dm_Cls_Parent(par: longint); external dll_dm;
procedure dm_Up_Childs(par: longint); external dll_dm;
procedure dm_Delete_Childs(par: longint); external dll_dm;
function dm_copy_holes(src,dst,undo: int): int; external dll_dm;

procedure dm_L_to_G(lx,ly: longint; var gx,gy: double);
external dll_dm index 81;
procedure dm_G_to_L(gx,gy: double; var lx,ly: longint);
external dll_dm index 82;

procedure dm_G_to_P(gx,gy: double; out px,py: double); external dll_dm;
procedure dm_R_to_P(gx,gy: double; out px,py: double); external dll_dm;

procedure dm_to_sm(ix,iy: longint; var ox,oy: longint);
var
  g: TGauss;
begin
  dm_L_to_G(ix,iy,g.x,g.y);
  ox:=Round(g.x*100); oy:=Round(g.y*100)
end;

function dm_Get_Angle_Length(a,b: TPoint; var f: double): double;
external dll_dm index 83;

procedure dm_Char_Bound(code,ch: longint; out lt,rb: TGauss);
external dll_dm;

procedure dm_Text_Bound(code: longint; txt: PChar;
                        lp,bp: PLLine; max,up: word);
external dll_dm index 91;

procedure dm_vgm_Bound(Ind: Integer;
                       const a,b: TPoint;
                       bp: PLLine; max: Integer);
external dll_dm;

procedure dm_Sign_Bound(code: longint; a,b: TPoint;
                        bp: PLLine; max: word);
external dll_dm index 92;

function dm_This_Text_Bound(lp: PLLine; Max: Integer): Integer;
external dll_dm;

function dm_Get_Polygon(bp: PLLine; max: Integer): Integer;
external dll_dm;

function dm_OpenFonts: Pointer; external dll_dm;
procedure dm_CloseFonts(Fonts: Pointer); external dll_dm;
function dm_Text_Extent(Fonts: Pointer;
                        cl: int; k: double; s: PWideChar;
                        out th: int): int;
external dll_dm;

procedure dm_Line_Attr(Fonts: Pointer;

                       lp: PLLine; cl: uint;
                       k,dx,dy,ds: Double;
                       s: PWideChar;

                       Receiver: Pointer;
                       Func: TOnAttrOut); stdcall;
external dll_dm;

function dm_Ind_Blank: word;
external dll_dm;

function dm_Get_Blank(i: word; lp: PWLine; max: word): word;
external dll_dm;

function dm_Def_Blank(i: Integer; lp: PLLine; max: Integer): Integer;
external dll_dm;

function dm_Get_blank2(bln,typ: int; out List: ICustomList): int;
external dll_dm;

function dm_Seek_Blank1(Ind: int): int; external dll_dm;
function dm_Seek_attr1(nn: int): PAbcRec1; external dll_dm;
function dm_Get_attr1(Ind: int): PAbcRec1; external dll_dm;

function dm_Get_std_hf(bln: Integer; List: PIntegers;
                       Capacity: Integer): Integer;
external dll_dm;

function dm_Get_dbf(bln,nnn: Integer; dbf: PChar): Integer;
external dll_dm;

function dm_Get_enum(bln,nnn,val: int; str: PChar): PChar;
external dll_dm;

function dm_Get_enum2(bln,nnn,val,col: int; str: PChar): PChar;
external dll_dm;

function dm_enum_Indexof(bln,nnn: Integer; str: PChar): Integer;
external dll_dm;

function dm_enumw_Indexof(bln,nnn: int; str,id: PChar): PChar;
external dll_dm;

function dm_str_list(Str: PChar; MaxLen: int;
                     nnn: int; val: PChar): PChar;
external dll_dm;

function dm_str_enumw(Str: PChar; MaxLen: int;
                      nnn,col: int; val: PChar): PChar;
external dll_dm;

procedure dm_mdb_values(open: Boolean);
external dll_dm;

function dm_seek_domen(nn: int): int;
external dll_dm;

function dm_get_domen(ind: int; Str: PChar; MaxLen: int): int;
external dll_dm;

function dm_trunc_list(Val: PChar; nnn: int): Boolean;
external dll_dm;

function dm_trunc_list1(Val: PChar; nnn: int): Boolean;
external dll_dm;

function dm_OpenDbaseValueGetter: Boolean; external dll_dm;
procedure dm_CloseDbaseValueGetter; external dll_dm;
procedure dm_SetDbaseValueComma(comma: PChar); external dll_dm;
function dm_StrDbaseValue(ptr,nn,column,Id: int; Str: PWideChar): Boolean;
external dll_dm;

function dm_Get_Unicode1(n: word; s: PWideChar; maxLen: int): Boolean;
external dll_dm;

function dm_Get_Unicode(n: word; s: PWideChar): Boolean; external dll_dm;
procedure dm_Put_Unicode(n: word; s: PWideChar); external dll_dm;

function dm_Draw_HF(nn: int; s: PWideChar): PWideChar;
external dll_dm;

function dm_Get_Double(n,bln: word; var r: double): Boolean;
external dll_dm;

procedure dm_Put_Double(n: word; r: double);
external dll_dm;

function dm_Get_Range(nn: int; out op: int;
                      out v1,v2: double): Boolean; 
external dll_dm;

function dm_obj_open: int; external dll_dm;
procedure dm_obj_close; external dll_dm;

function dm_obj_attr(nn: int): int; external dll_dm;

function obj_Get_Count: Integer; external dll_dm;

function obj_Get_Object(i: Integer; var Code,Loc: Integer; ps: PChar): PChar;
external dll_dm;

function obj_get_color(code,loc: int): int; external dll_dm;
function obj_get_flags(code,loc: int): int; external dll_dm;

function obj_Code_by_Color(Code,Loc,Color: int): int;
external dll_dm;

function obj_Ind_Blank(Code: longint; Loc: byte): word;
external dll_dm;

function obj_Get_Blank(Code: longint; Loc: byte; lp: PWLine; max: word): word;
external dll_dm;

function obj_Get_Name(Code: longint; Loc: byte; s: PChar): PChar;
external dll_dm;

function obj_Get_Icon(Code,Loc: int;
                      Name: PChar; Ico: POinter): int; 
external dll_dm;

function dm_open_idx: Boolean; external dll_dm;
procedure dm_close_idx; external dll_dm;

function idx_Get_Name(nn: Integer; s: PChar): PChar;
external dll_dm;

function idx_get_tag(nn: int): Id_Tag;
external dll_dm;

function id_Parent: longint; external dll_dm;

function dm_Get_Pen(var mm,tag,width,style: byte): byte; external dll_dm;
procedure dm_Set_Pen(mm,tag,width,style,pc: byte); external dll_dm;
procedure dmw_Set_Pen(r,g,b,mm: byte); external dll_dm;

function dm_Get_Brush(var fc,pc: byte): byte; external dll_dm;
procedure dm_Set_Brush(fc,pc,msk: byte); external dll_dm;

function dmw_Get_Brush(var r,g,b: byte): byte; external dll_dm;
procedure dmw_Set_Brush(r,g,b,msk: byte); external dll_dm;
procedure dmw_alfa_Brush(r,g,b,alfa: byte); external dll_dm;

function dm_Get_Graphics(Code: longint; Loc: byte): longint; external dll_dm;
procedure dm_Set_Graphics(cl: longint); external dll_dm;
procedure dm_Restore_Graphics; external dll_dm;

function dmw_Get_Color: Integer; external dll_dm;
procedure dmw_Set_Color(cl: Integer); external dll_dm;

procedure dm_Get_Text_Color(out blank,lt,up: Integer;
                            out font,height,fc: Integer);
external dll_dm;

procedure dm_Set_Text_Color(blank,lt,up: Integer;
                            font,height,fc: Integer);
external dll_dm;

function dm_decode_text_color(color: int; Font: PChar;
                              out height,fcolor: int): int;
external dll_dm;

procedure dmw_load_palette(nm: PChar); external dll_dm;
function dmw_get_rgb(var r,g,b: byte): Longint; external dll_dm;

function dm_Goto_by_Code(code: longint): longint; external dll_dm;

function dm_Get_Layer(code: longint): longint; external dll_dm;

function dm_New1(path,obj: PChar; sys: psys;
                 xmin,ymin,xmax,ymax: double;
                 ed: Integer): Integer; external dll_dm;

function dm_New(path,obj: PChar;

                pps,prj,elp, dx,dy,dz: Integer;
                b1,b2, lc: Double;

                xmin,ymin,xmax,ymax: double;
                ed: Integer): Integer; external dll_dm;

function dm_Frame(path,obj: PChar; pps,ed: Integer;
                  xmin,ymin,xmax,ymax: double): Integer;
external dll_dm;

function dm_Make(path,obj: PChar; pps: byte;
                 xmin,ymin,xmax,ymax: double): word;
external dll_dm;

function bl_Make(path,obj,nom: PChar): word; external dll_dm;
function bl_Make1(path,obj,nom: PChar; elp: int): int; external dll_dm;
function avia_Make(path,obj,nom: PChar): word; external dll_dm;

function wgs_Make(path,obj: PChar;
                  const lt,rb: TGauss): Boolean;
external dll_dm;

function wgs_tdm(Dest,obj: PChar;
                 const lt,rb: TGauss): Boolean;
external dll_dm;

function utm_Create(Dest,Obj: PChar;
                    bmin,lmin,bmax,lmax: Double;
                    Nzone,Scale: Integer): Boolean;
external dll_dm;

function merc_Create(Dest,Obj: PChar;
                     bmin,lmin,bmax,lmax: Double;
                     bc: Double; elp,Scale: int): Boolean;
external dll_dm;

function wmerc_Create(Dest,Obj: PChar): Boolean;
var
  lt,rb: TGauss;
begin
  lt.x:=-85 / 180 * PI;
  lt.y:=-180 / 180 * PI;
  rb.x:=-lt.x; rb.y:=-lt.y;
  Result:=merc_Create(Dest,Obj,lt.x,lt.y,rb.x,rb.y,0,9,1000000)
end;

procedure dm_Cls; external dll_dm;

function dm_Copy(src,dst,obj: PChar): Boolean; external dll_dm;
function dm_add_grid(code,mm: int): int; external dll_dm;

procedure dm_map_bound(x1,y1,x2,y2: Double); external dll_dm;
procedure dm_map_bound1(x1,y1,x2,y2: Double; pps: int); external dll_dm;
function dm_rebound(extend: Boolean): int; external dll_dm;
function dm_rebound2(margin: double; extend: Boolean): int; external dll_dm;

function dm_Cut_Polygon(dst: PChar; lp: PLLine): Boolean; external dll_dm;

procedure dm_set_param(Id: int; v: double); external dll_dm;

procedure dm_Poly_params(lp: PLPoly; N: int;
                         out s,l: Double); external dll_dm;

function dm_lpoly_length(lp: PLPoly; hp: PIntegers; N: int): Double;
external dll_dm;

function dm_Poly_length(lp: PLLine; hp: PIntegers): Double;
external dll_dm;

function dm_lg_transit(l,g: PGPoly): Integer; external dll_dm;

procedure dm_L_to_R(x,y: longint; var b,l: double); external dll_dm;
procedure dm_R_to_L(b,l: double; var x,y: longint); external dll_dm;

procedure dm_X_to_L(x,y: double; bl: Integer; var lx,ly: longint);
external dll_dm;

procedure dm_to_wgs(x,y,z: Integer; out w: txyz); 
external dll_dm;
procedure wgs_to_dm(x,y,z: Double; out v: VPoint);
external dll_dm;

function lc_zone(lc: double): word; external dll_dm;
function dm_zone: longint; external dll_dm;
function dm_pps: byte; external dll_dm;
function dm_prj: byte; external dll_dm;
function dm_elp: byte; external dll_dm;

procedure dm_BL_XY(b,l: double; var x,y: double);
external dll_dm;

procedure dm_XY_BL(x,y: double; var b,l: double);
external dll_dm;

function dm_azimuth(const a,b: TPoint; out fi: Double): double;
external dll_dm;

function dm_Contains(x,y: Double; pps: int): boolean;
external dll_dm;

function dm_Filter_region(Filter: PChar): byte;
external dll_dm;

function dm_Filter(Filter,Dst: PChar; lp: PLLine; rgn: byte): PChar;
external dll_dm;

function dm_Filter2(Filter,Dst,dm1,dm2: PChar; mode: int): PChar;
external dll_dm;

function dm_Filter_list(Dbf: PChar;
                        lp: PLLine; rgn: int;
                        out Buf: PInt64s): int;
external dll_dm;

procedure dm_apply_pkg(map,pkg,cmd: PChar);
external dll_dm;

function dm_Objects_Count: longint;
external dll_dm;

procedure dm_Undo_More(fl: Boolean); external dll_dm;
procedure dm_Undo_Push(run: longint; cmd: byte); external dll_dm;
procedure dm_Undo_childs(p: int); external dll_dm;
function dm_Undo_Pop(ins: boolean): longint; external dll_dm;
function dm_Undo_Hide: longint; external dll_dm;

function dm_Undo_Object(out Code,Loc,x1,y1,x2,y2: Integer): longint;
external dll_dm;

function dm_Undo_Last(out code,loc,cmd,modify: int;
                      out code1: int; out pos: TPoint): int64;
external dll_dm;

function dm_Undo_Last_Pool(lp: PPool; maxLen: int): int;
external dll_dm;

function Link_Open(path: PChar): Integer; external dll_dm;
procedure Link_Done; external dll_dm;

procedure Link_pair(i: Integer; var ix,iy, gx,gy: longint);
external dll_dm;
procedure Link_add(ix,iy, gx,gy: longint); external dll_dm;
function Link_Count: Integer; external dll_dm;

procedure dm_to_bit(ix,iy: longint; var ox,oy: longint); external dll_dm;
procedure bit_to_dm(ix,iy: longint; var ox,oy: longint); external dll_dm;

procedure link_a_to_b(ix,iy: longint; var ox,oy: longint); external dll_dm;
procedure link_b_to_a(ix,iy: longint; var ox,oy: longint); external dll_dm;

procedure dm_Bin_Dir(dir: PChar); external dll_dm;
procedure dm_AutoSave(Count: Integer); external dll_dm;

function dm_Scale: Integer; external dll_dm;

function dm_Object_Icon(Code,Loc: Integer): HBitMap; external dll_dm;

procedure dm_Polygon_Square(Value: Boolean); external dll_dm;

function dm_cn_to_dm(p: Integer): Boolean; external dll_dm;

function batch_cn_to_dm(loc1,loc2: Integer;
                        cp: PIntegers; Count: Integer;
                        StepIt: TStepItProc): Integer;
external dll_dm;

function dm_is_cn: Boolean; external dll_dm;

function dm_Get_vc_Count: Integer; external dll_dm;
function dm_Get_vc_Id(I: Integer): Integer; external dll_dm;
function dm_Get_vc(Id: Cardinal; out v: tcn_rec): Boolean;
external dll_dm;

function dm_Get_ve_Count: Integer; external dll_dm;
function dm_Get_ve_Id(I: Integer): Integer; external dll_dm;
function dm_Get_ve(Id: Cardinal; out v: tcn_rec): Boolean;
external dll_dm;

function dm_Get_vc_attv(id: Cardinal): Cardinal; external dll_dm;
function dm_Get_ve_attv(id: Cardinal): Cardinal; external dll_dm;
procedure dm_Set_vc_attv(id,attv: Cardinal); external dll_dm;
procedure dm_Set_ve_attv(id,attv: Cardinal); external dll_dm;

function dm_Get_vc_lab(id: Cardinal): Cardinal;
var
  ax: tlong;
begin
  ax.i:=dm_Get_vc_attv(id);
  Result:=ax.b[3]
end;

function dm_Get_ve_lab(id: Cardinal): Cardinal;
var
  ax: tlong;
begin
  ax.i:=dm_Get_ve_attv(id);
  Result:=ax.b[3]
end;

procedure dm_Set_vc_lab(id,lab: Cardinal);
var
  ax: tlong;
begin
  ax.i:=dm_Get_vc_attv(id); ax.b[3]:=lab;
  dm_Set_vc_attv(id,ax.i)
end;

procedure dm_Set_ve_lab(id,lab: Cardinal);
var
  ax: tlong;
begin
  ax.i:=dm_Get_ve_attv(id); ax.b[3]:=lab;
  dm_Set_ve_attv(id,ax.i)
end;

function dm_Get_ve_Poly(Id: Cardinal;
                        lp: PLLine; hp: PIntegers;
                        lp_Max: Integer): Integer;
external dll_dm;

function dm_Get_vc_ref(Id: Cardinal; vc: PIntegers;
                       vc_Max: Integer): Integer;
external dll_dm;

function dm_Get_ve_ref(Id: Cardinal; ve: PIntegers;
                       ve_Max: Integer): Integer;
external dll_dm;

function dm_Get_vi_ref(Id: Cardinal; vi: PIntegers;
                       vi_Max: Integer): Integer;
external dll_dm;

function dm_add_vc(Id: Cardinal; X,Y: Integer;
                   Z: PInteger): Cardinal;
external dll_dm;

function dm_add_ve(Id, Vc1,Vc2: Cardinal; lp: PLLine;
                   hp: PIntegers): Cardinal;
external dll_dm;

function dm_Delete_vc(Id: Cardinal): Boolean; external dll_dm;
function dm_Delete_ve(Id: Cardinal): Boolean; external dll_dm;

procedure dm_Update_vc(Id: Cardinal; X,Y: Integer;
                       Z: PInteger); stdcall;
external dll_dm;

procedure dm_Update_ve(Id, Vc1,Vc2: Cardinal;
                       lp: PLLine; hp: PIntegers);
external dll_dm;

function dm_merge_vc(vc1,vc2: Cardinal): Boolean;
external dll_dm;

procedure dm_ve_oref(ve,vc1,vc2: Cardinal;
                     List: PIntegers; Count: Integer);
external dll_dm;

function dm_ve_Split(ve,vc: Cardinal): Cardinal;
external dll_dm;

function dm_Get_fc_Count: Integer; external dll_dm;
function dm_Get_fc_Id(I: Integer): Integer; external dll_dm;
function dm_Get_fc(Id: Cardinal; out v: tcn_rec): Boolean;
external dll_dm;

function dm_fc_Get_code(Id: Cardinal): Integer; external dll_dm;

function dm_fc_Get_list(Id: Cardinal;
                        lp: PLLine; lp_Max: Integer): Integer;
external dll_dm;

procedure dm_fc_Update(Id, OBJL: Cardinal; lp: PLLine);
external dll_dm;

function dm_fc_Get_hf(Id: Cardinal; lp: PPool;
                      BufSize: Integer): Integer; external dll_dm;

procedure dm_fc_Put_hf(Id: Cardinal; lp: PPool); external dll_dm;

function dm_lp_fill(Items: PInt64s; Count: int;
                    lp: PLLine; lp_max: int;
                    const p, lt,rb: TPoint;
                    cut: Boolean): int;
external dll_dm;

function dm_group_fill(Items: PInt64s; Count: int;
                       lp: PLLine; lp_max: int): int;
external dll_dm;

function dm_Up_lndare(code: Integer; lp,buf: PLLine;
                      ptr: PIntegers; ptr_Max: Integer): Integer;
external dll_dm;

function dm_Out_lndare(ptr: int; list: PIntegers; listMax: int): int;
external dll_dm;

function dm_this_hf(ptr: int; Expr: PChar): boolean;
external dll_dm;

function dm_Init_pp(out pp: TPolyPolygon;
                    ACounterCapacity: Integer;
                    APointCapacity: Integer): Boolean;
external dll_dm;

procedure dm_Free_pp(var pp: TPolyPolygon); external dll_dm;

function dm_Load_pp(var pp: TPolyPolygon): Integer;
external dll_dm;

function dm_Get_pp_lp(pp: PPolyPolygon; pp_Ind: Integer;
                      lp: PPolyLine; lp_Max: Integer): Integer;
external dll_dm;

function dm_fe_Get_Contour(lp_Ind: Integer; lp: PLLine;
                           dst: PPolyLine; dst_Max: Integer): Integer;
external dll_dm;

function dm_Add_Polyline(code,loc,lev: Integer;
                         lp: PPolyLine; down: Boolean): longint;
external dll_dm;

function xyz_Add_Polyline(code,loc,lev: Integer;
                         lp: PPolyLine; hp: PIntegers;
                         down: Boolean): longint;
external dll_dm;

function dm_Size: tgauss;
var
  lt,rb: TPoint; gx1,gy1,gx2,gy2: double;
begin
  dm_Goto_Root;
  dm_Get_Bound(lt,rb);

  dm_L_to_G(lt.x,lt.y, gx1,gy1);
  dm_L_to_G(rb.x,lt.y, gx2,gy2);

  Result.x:=Hypot(gx2-gx1,gy2-gy1);

  dm_L_to_G(lt.x,lt.y, gx1,gy1);
  dm_L_to_G(lt.x,rb.y, gx2,gy2);

  Result.y:=Hypot(gx2-gx1,gy2-gy1);
end;

function dm_Resolution: double;
var
  p1,p2,pos: TPoint;
  gx1,gy1,gx2,gy2,dist: double;
begin
  Result:=1;

  dm_Get_Position(pos);

  dm_Goto_Root; dm_Get_Bound(p1,p2);

  dm_L_to_G(p1.X,p1.Y, gx1,gy1);
  dm_L_to_G(p2.X,p2.Y, gx2,gy2);

  dist:=Max(1,Hypot(p2.X-p1.X,p2.Y-p1.Y));

  if dist > 1 then
  Result:=Hypot(gx2-gx1,gy2-gy1)/dist;

  dm_Set_Position(pos);
end;

function dm_res_m: int;
var
  res: Double;
begin
  Result:=0; res:=dm_Resolution;
  while (Result < 3) and (res < 1) do begin
    Inc(Result); res:=res * 10
  end
end;

function dm_dist(d: double; ed: int): double;
var
  res: Double;
begin
  if ed = 2 then d:=d*1852.6 else
  if ed = 1 then d:=d*dm_Scale/1000;

  Result:=d; res:=dm_Resolution;
  if res > 0 then Result:=d/res
end;

function dm_z_dist(d: double; ed: int): double;
begin
  if ed = 1 then d:=d*dm_Scale/1000;
  Result:=d * dm_z_res
end;

function dm_az_to_map(const p: TPoint; az: double): double;
var
  g: TGauss; s,c: Extended; q: TPoint;
begin
  dm_L_to_G(p.X,p.Y,g.x,g.y);
  SinCos(az,s,c);
  dm_G_to_L(g.x + 100*c, g.y + 100*s, q.X,q.Y);
  Result:=ArcTan2(q.Y-p.Y, q.X-p.X)
end;

function dm_Vector_Length(lp: PLPoly): Double;
var
  g1,g2: TGauss;
begin
  with lp[0] do dm_L_to_G(x,y,g1.x,g1.y);
  with lp[1] do dm_L_to_G(x,y,g2.x,g2.y);
  Result:=Hypot(g2.x-g1.x,g2.y-g1.y);
end;

const
  LPolyMax = 32000-1;

function dm_Get_mf: PLLine;
var
  n: Integer;
begin
  Result:=nil;

  n:=dm_Get_Poly_Count;
  if n >= 0 then begin
    Result:=Alloc_LLine(n+1);
    if Assigned(Result) then begin

      dm_Get_Poly_Buf(Result,n);
      if Result.N < 0 then
      Result:=xFreePtr(Result)
    end
  end
end;

function dm_Get_Polyline: PLLine;
var
  lp1,lp2: PLLine;
begin
  if dm_Get_Local in [22,23] then begin
    Result:=Alloc_LLine(LPolyMax+1);
    lp1:=dm_Get_mf; lp2:=Alloc_LLine(LPolyMax+1);

    if Assigned(Result) then begin
      Result.N:=-1;

      if Assigned(lp1) then
      if lp1.N >= 0 then
      if Assigned(lp2) then
    end;

    xFreePtr(lp2); xFreePtr(lp1);
  end
  else Result:=dm_Get_mf;
end;

function lp_to_xy(lp: PLLine; ed: Double): PLLine;
var
  i: Integer; g: tgauss;
begin
  for i:=0 to lp.N do
  with lp.Pol[i] do begin
    dm_L_to_G(x,y, g.x,g.y);
    x:=Round(g.x * ed);
    y:=Round(g.y * ed);
  end;

  Result:=lp
end;

function AtoI(const fa; Len: Integer): Integer;
var
  a: array[0..31] of char absolute fa;
  i: Integer; sign: Boolean;
begin
  i:=0; Result:=0; sign:=false;

  if Len > 0 then begin
    while (i < Len) and (a[i] = ' ') do Inc(i);

    if a[i] = '+' then Inc(i) else
    if a[i] = '-' then begin Inc(i); sign:=true end;

    while i < Len do begin
      Result:=(Result*10)+ord(a[i])-ord('0'); Inc(i)
    end;

    if sign then Result:=-Result
  end
end;

function StrToCode(const s: string): longint;
var
  t: String;
begin
  t:=s;
  while length(t) < 8 do t:=t+'0';
  Result:=AtoI(t[1],length(t))
end;

function CodeToStr(code: longint): string;
var
  i: int; a: alfa;
begin
  if code < 0 then
    Result:=IntToStr(code)
  else begin
    for i:=8 downto 2 do begin
      a[i]:=Chr(code mod 10 + ord('0'));
      code:=code div 10
    end;

    code:=code + ord('0'); if code > ord('Z') then
    code:=ord('0'); a[1]:=chr(code); Result:=a
  end
end;

function cn_ptr(rcid,rcnm,ornt,usag,mask: Integer): TPoint;
begin
  Result.x:=rcid;
  Result.y:=Long_bytes(rcnm,ornt,usag,mask)
end;

function dm_Get_xsys(out sys: tsys): Integer;
var
  s: tsys3;
begin
  Fillchar(s,Sizeof(s),0); with s do
  Result:=dm_Get_sys(pps,prj,elp, b1,b2,lc,
                     dat.x,dat.y,dat.z);
  sys:=sys3_sys7(s)
end;

procedure dm_Put_xsys(const sys: tsys);
begin
  with sys,dat do
  dm_Put_sys(pps,prj,elp, b1,b2,lc,
             Round(dX),Round(dY),Round(dZ))
end;

function dm_GFrame(Path: PChar; L: PLPoly;
                   G,B: PGPoly; out s: tsys): Integer;

procedure l_to_g(L: PLPoly; G: PGPoly);
var
  i: Integer;
begin
  for i:=0 to 3 do with L[i] do
  dm_L_to_R(x,y, G[i].x,G[i].y);
end;

var
  lt,rb: TPoint; vl: LOrient;
begin
  Result:=-1;
  Fillchar(s,Sizeof(s),0); s.pps:=-1;

  if dm_Open(Path,false) > 0 then begin

    if Assigned(L) then
    if Assigned(G) then l_to_g(L,G);

    if Assigned(B) then begin
      dm_Goto_Root; dm_Get_Bound(lt,rb);

      vl[0].X:=lt.X; vl[0].Y:=lt.Y;
      vl[1].X:=rb.X; vl[1].Y:=lt.Y;
      vl[2].X:=rb.X; vl[2].Y:=rb.Y;
      vl[3].X:=lt.X; vl[3].Y:=rb.Y;
      l_to_g(@vl,B);
    end;

    Result:=dm_Get_xsys(s); dm_Done
  end
end;

type
  TMaxIValue = class
    constructor Create(Ann: Integer);

    function ObjectProc(p: Integer;
                       const dRec: dm_Rec): Boolean;
  private
    fnn: Integer;
    fval: Integer;
  public
    property val: Integer read fval;
  end;

constructor TMaxIValue.Create(Ann: Integer);
begin
  inherited Create; fnn:=Ann;
end;

function TMaxIValue.ObjectProc(p: Integer;
                              const dRec: dm_Rec): Boolean;
var
  v: Longint;
begin
  Result:=false;
  if dm_Get_long(fnn,0,v) then
  fval:=Max(fval,v)
end;

function dm_Get_max_ival(nn: Integer): Integer;
var
  max: TMaxIValue;
begin
  Result:=0;

  max:=TMaxIValue.Create(nn);
  try
    dm_Execute(max.ObjectProc);
    Result:=max.val
  finally
    max.Free
  end
end;

function dbase_open(Path: PChar): Boolean; external dll_dm;
procedure dbase_close; external dll_dm;

function dbase_RowCount: Integer; external dll_dm;
function dbase_ivalue(Row,Col: Integer): Integer;
external dll_dm;

function dbase_value(Row,Col: Integer; val: PChar): PChar;
external dll_dm;

function dm_Get_scale_list(buf: PIntegers; MaxSize: Integer): Integer;
external dll_dm;

function mf_init(MinCount: Integer): Pointer; external dll_dm;
procedure mf_done(mf: Pointer); external dll_dm;
procedure mf_clear(mf: Pointer); external dll_dm;

procedure mf_next(mf: Pointer; const p: TPoint; z: PInteger);
external dll_dm;

function mf_end_contour(mf: Pointer): Integer;
external dll_dm;

function mf_add_contour(mf: Pointer;
                        lp: PLPoly; hp: PIntegers;
                        Count: int): int;
external dll_dm;

function mf_add_holes(mf: Pointer; Ptr: int): int;
external dll_dm;

function mf_pop_holes(mf: Pointer; Ptr: int): int;
external dll_dm;

function mf_break(mf: Pointer; lp: PLLine; lpMax: Integer): Integer;
external dll_dm;

function mf_break1(lp: PLPoly; cp: PIntegers; n: int;
                   dst: PLLine; dstMax: int): int;
external dll_dm;

function mf_load_poly(mf: Pointer; Ptr: Int64): Integer;
external dll_dm;

function mf_get_part(mf: Pointer; Ind: Integer;
                     lp: PLLine; hp: PIntegers;
                     lpMax: Integer): Integer;
external dll_dm;

function dm_Get_mesh(out vp: PVPoly;
                     out vn: Integer;
                     out fp: PIntegers;
                     out fn: Integer): Integer;
external dll_dm;

function alt_Copy_Object(Ptr: int): Integer;
external dll_dm;

function alt_Copy_Layer(Ptr: int): Integer;
external dll_dm;

function dm_down_level: Boolean;
external dll_dm;

procedure dm_Seek_layer(Code: DWord); external dll_dm;
procedure dm_seek_layerp(P: int); external dll_dm;

function dm_Clean_Layers: longint;
external dll_dm;

function dm_Update_User(User,Data: PChar): Boolean;
external dll_dm;

function dm_trk_new(Dest,Obj: PChar; z_ed: int): pointer;
external dll_dm;

procedure dm_trk_done(trk: pointer);
external dll_dm;

procedure dm_trk_name(obj: pointer; Name: PChar);
external dll_dm;

procedure dm_trk_pos(trk: pointer; pt: PDoubles);
external dll_dm;

function dm_pickupList(const lt,rb: TPoint;
                       out List: PInt64s): int;
external dll_dm;

function dm_GetAttrList(nn: int; out List: ICustomList): int;
external dll_dm;

function dm_Get_role(ptr: int; v: PIntegers): uint;
external dll_dm;

function dm_role_plus_guid(ptr: int): Boolean;
external dll_dm;

function dm_role_restore(up,ptr: int): Boolean;
external dll_dm;

function dm_Is_link_objects(ptr1,ptr2: int): Boolean;
external dll_dm;

function dm_link_objects(ptr1,ptr2,mode: int; Name: PChar): int;
external dll_dm;

function dm_unlink_objects(ptr1,ptr2: int; Name: PChar): Boolean;
external dll_dm;

function dm_is_unk_role(ptr,run: int): Boolean; 
external dll_dm;

function dm_recode_roles(ptr: int): int;
external dll_dm;

function dm_role_rename(ptr1,ptr2: int; Name: PChar): Boolean;
external dll_dm;

function dm_role_owner(ptr1,ptr2,run: int): Boolean; 
external dll_dm;

function dm_filter_datatypes(ptr: int; undo: Boolean): int;
external dll_dm;

function dm_sync_attrs(up1,up2: int; undo: Boolean): int;
external dll_dm;

function dm_after_join_polylines(ptr: int; const e1,e2: TPoint; undo: Boolean): int;
external dll_dm;

function dm_seek_frst_guid(ptr: int; ptop: pint): int; 
external dll_dm;

function dm_seek_next_guid(ptr,top: int): int;
external dll_dm;

function dm_read_guid(ptr: int; id,rev: PChar): PChar;
external dll_dm;

procedure dm_add_guid(ptr: int; id,rev: PChar);
external dll_dm;

function dm_offset_by_guid(guid: PChar): int;
external dll_dm;

function dm_seek_frst_locid(ptr: int; ptop: pint): int;
external dll_dm;

function dm_seek_next_locid(ptr,top: int): int;
external dll_dm;

function dm_read_locid(ptr: int; map,map1: PChar): int;
external dll_dm;

function dm_add_locid(ptr: int): int;
external dll_dm;

function get_locid1(ptr: int; map,map1: PChar; out id: int): bool;
var
  ptr1: int;
begin
  Result:=false;
  ptr1:=dm_seek_frst_locid(ptr,nil);
  if ptr1 > 0 then begin
    id:=dm_read_locid(ptr1,map,map1);
    if id <> 0 then
    Result:=map[0] <> #0
  end
end;

function dm_frst_relation(ptr: int; out top: int): int;
external dll_dm;

function dm_next_relation(ptr, top: int): int;
external dll_dm;

function dm_get_relation(ptr: int;
                         out dir,typ: int;
                         guid,acronym,name: PChar): int;
external dll_dm;

function dm_frst_datatype(ptr,nn: int; out top: int): int;
external dll_dm;

function dm_next_datatype(ptr, nn, top: int): int;
external dll_dm;

function dm_GetInterface(const IID: TGUID; out Obj): HResult;
external dll_dm;

function dm_get_datatype_count(ptr,nn: int): int;
var
  run,top: int;
begin
  Result:=0;
  run:=dm_frst_datatype(ptr,nn,top);
  while run > 0 do begin
    Inc(Result);
    run:=dm_next_datatype(run,nn,top)
  end
end;

function Id_Equal(itag,otag: Id_Tag): Boolean;
begin
  Result:=false;

  case itag of
_byte,
_int,
_word,
_long:
    Result:=otag in [_byte,_int,_word,_long,_dBase,
                     _enum,_time,_date,_bool,_link,
                     _real,_double,_color];

_dBase,
_enum,
_Bool,
_link:
    Result:=otag in [_byte,_int,_word,_long,
                     _dBase,_enum,_bool,_link];

_time,
_date:
    Result:=otag in [_int,_word,_long,_time,_date,
                     _real,_double];
_real,
_float,
_double:
    Result:=otag in [_byte,_int,_word,_long,_time,_date,
                     _real,_float,_angle,_double];

_angle:
    Result:=otag in [_real,_float,_angle,_double];

_number:
    Result:=otag in Id_Value+[_string];

_enumw:
    Result:=otag in Id_Int1+[_string];

_string,
_unicode,
_text,
_list:
    Result:=otag in [_string,_unicode,_text,_list];

_unk:
    Result:=true;

  end
end;

function dm_seek_node(ptr,loc: int): Boolean;
begin
  Result:=false;
  if ptr > 0 then begin
    dm_Jump_Node(ptr);
    if dm_Object = ptr then
    if loc = 0 then Result:=true else
    Result:=dm_Get_Local = loc
  end
end;

function dm_to_fe(ptr: int): Int64;
var
  p: TInt64; id: Integer;
begin
  p.x:=ptr;
  if dm_seek_node(ptr,0) then
  if dm_get_long(1000,0,id) then
  p.x:=_Int64(id,cn_ident);
  Result:=p.x
end;

procedure StrObjName(Str: PChar; code,loc: int);
begin
  obj_Get_Name(code,loc,Str);
  if Strlen(Str) = 0 then
  StrFmt(Str,'{%s-%d}',[CodeToStr(code),loc]);
end;

function ObjNameStr(code,loc: int): String;
var
  s: TShortStr;
begin
  StrObjName(s, code,loc);
  Result:=Strpas(s)
end;

function dm_update_layer(Code: DWord): int;
begin
  Result:=dm_Goto_by_Code(Code);

  if dm_Update <= 0 then
    Result:=0
  else
  if Result = 0 then
    Result:=dm_Goto_by_Code(Code);
end;

function dm_update_layer1(const pos: TPoint; code: uint): bool;
begin
  dm_Set_Position(pos);
  if dm_Get_Local <> 0 then
    Result:=true
  else
    Result:=dm_Goto_by_Code(code) > 0
end;

function dm_update_layer2(code: uint): bool;
var
  pos: TPoint;
begin
  Result:=false;

  dm_Goto_by_code(code);
  dm_Get_Position(pos);

  if dm_Update > 0 then begin
    dm_update_layer1(pos,code);
    Result:=true
  end
end;

function code_to_attr(code: int): int;
begin
  Result:=code mod 100000
end;

end.


