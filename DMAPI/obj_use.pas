unit obj_use; interface

uses
  Windows,OTypes,dmw_use;

type
  PSimplePen = ^TSimplePen;
  TSimplePen = record case Integer of
0:  (what,cl: byte; f1,f2,f3,f4,f5: SmallInt);
1:  (i1,i2,i3: Integer)
  end;

  PExtPen = ^TExtPen;
  TExtPen = array[0..3] of TSimplePen;

function Obj_Edit(Path: PChar): Boolean; stdcall;

function Obj_Add_Item(Ind: Integer;
                      Code,Loc,Blank,Color: Integer;
                      name: PChar; ico: THandle): Integer; stdcall;

function Obj_Open(Path: PChar): Boolean; stdcall;
procedure Obj_Close; stdcall;

function Obj_Indexof(Code,Loc: Integer): Integer; stdcall;

function Obj_Count: Integer; stdcall;

function Obj_Owner(Ind: Integer): Integer; stdcall;

procedure Obj_Record(Ind: Integer; // > 0
                     out Code,Loc,Blank: Integer;
                     cl: PChar; name: PChar;
                     ico: Pointer); stdcall;

procedure obj_Item(Ind: Integer;  // > 0
                   out Code,Loc,Color: Integer;
                   Name: PChar); stdcall;

procedure obj_Disp(Ind: Integer; out h1,h2: Float); stdcall;

// mm < 0 -> style - Pen index
procedure obj_Color_to_Pen(Color: Integer;
                           out mm,tag,width: Integer;
                           out style,pcolor: Integer); stdcall;

procedure obj_Color_to_Brush(Color: Integer;
                             out fc,pc,msk: Integer); stdcall;

procedure obj_Color_to_Font(Color: Integer;
                            out fnt,cl: Integer;
                            out height: Float); stdcall;

procedure Obj_draw(dc: HDC; x1,y1,x2,y2, Ind: Integer); stdcall;

function Color_By_Code(Code,Loc: Integer; out Color: Integer): Integer; stdcall;

procedure obj_Icon(DC: HDC; x,y, i: Integer); stdcall;

function obj_Codeof(Code,Loc: Integer): Integer; stdcall;

function obj_chain(code: int; out cp: PChainArray): Integer; stdcall;

function obj_Goto_Root: longint; stdcall;
function obj_Goto_left: Boolean; stdcall;
function obj_Goto_right: Boolean; stdcall;
function obj_Goto_upper: Boolean; stdcall;
function obj_Goto_down: Boolean; stdcall;
function obj_Goto_home: longint; stdcall;
function obj_Goto_last: longint; stdcall;
function obj_menu_item: int; stdcall;
function obj_menu_seek(code,loc: int): Boolean; stdcall;

function obj_group_of(Code: int; List: PLPoly; MaxCount: int): int; stdcall;

function Pens_Count: Integer; stdcall;
function Get_Pen(Ind: Integer; out Pen: TExtPen): Integer; stdcall;

function Vgm_Open(Path: PChar): Boolean; stdcall;
procedure Vgm_Close; stdcall;

function Vgm_Count: Integer; stdcall;

function vgm_Index_Of_Code(Code: Integer): Integer; stdcall;

function Vgm_Sign(I: Integer; Buf: PBytes;
                  Size: Integer): Integer; stdcall;

function Vgm_Height(I: Integer): Double; stdcall;

// возвращает кол-во элементов
function vgm_Get_hdr(vgm_Ind: Integer;
                     out w,h: Integer): Integer; stdcall;

// Result= 2 - Полиния; 3- Полигон
function vgm_Get_poly(vgm_Ind,lp_i: Integer; out cl: Integer;
                      lp: PLLine; lp_Max: Integer): Integer; stdcall;

function vgm_Draw(DC: HDC; x,y,w,h,Ind: Integer): Integer; stdcall;
function vgm_gif(Dest: PChar; w,h,Ind: Integer): Integer; stdcall;

function obj_SetColor(Ind,Val: DWord): DWord; stdcall;

function obj_Get_Blank(I: Integer; lp: PWLine; max: Integer): Integer;
stdcall;

function idx_Open(Path: PChar): Boolean; stdcall;
procedure idx_Close; stdcall;

function idx_Count: Integer; stdcall;
function idx_Item(Ind: Integer;
                  out Tag: Id_Tag;
                  Name: PChar): Integer; stdcall;

function idx_Indexof(Nnn: Integer;
                     out Tag: Id_Tag;
                     Name: PChar): Integer; stdcall;

function init_obj: uint; stdcall;
procedure done_obj(h: uint); stdcall;

function icons_init: uint; stdcall;
procedure icons_done(h: uint); stdcall;
procedure icons_add(h: uint; key: int; ico: Pointer); stdcall;
function icons_draw(h: uint; DC: HDC; x,y,key: int): int; stdcall;

implementation

const
  obj_dll = 'dll_obj.dll';

function Obj_Edit(Path: PChar): Boolean; external obj_dll;

function Obj_Add_Item(Ind: Integer;
                      Code,Loc,Blank,Color: Integer;
                      name: PChar; ico: THandle): Integer;
external obj_dll;

function Obj_Open(Path: PChar): Boolean; external obj_dll;
procedure Obj_Close; external obj_dll;

function Obj_Indexof(Code,Loc: Integer): Integer;
external obj_dll;

function Obj_Count: Integer; external obj_dll;

function Obj_Owner(Ind: Integer): Integer;
external obj_dll;

procedure Obj_Record(Ind: Integer;
                     out Code,Loc,Blank: Integer;
                     cl: PChar; name: PChar;
                     ico: Pointer);
external obj_dll;

procedure obj_Item(Ind: Integer;
                   out Code,Loc,Color: Integer;
                   Name: PChar);
external obj_dll;

procedure obj_Disp(Ind: Integer; out h1,h2: Float); 
external obj_dll;

procedure obj_Color_to_Pen(Color: Integer;
                           out mm,tag,width: Integer;
                           out style,pcolor: Integer);
external obj_dll;

procedure obj_Color_to_Brush(Color: Integer;
                             out fc,pc,msk: Integer);
external obj_dll;

procedure obj_Color_to_Font(Color: Integer;
                            out fnt,cl: Integer;
                            out height: Float);
external obj_dll;

procedure Obj_draw(dc: HDC; x1,y1,x2,y2, Ind: Integer);
external obj_dll;

function Color_By_Code(Code,Loc: Integer; out Color: Integer): Integer;
external obj_dll;

procedure obj_Icon(DC: HDC; x,y, i: Integer);
external obj_dll;

function obj_Codeof(Code,Loc: Integer): Integer;
external obj_dll;

function obj_chain(code: int; out cp: PChainArray): Integer;
external obj_dll;

function obj_Goto_Root: longint; external obj_dll;
function obj_Goto_left: Boolean; external obj_dll;
function obj_Goto_right: Boolean; external obj_dll;
function obj_Goto_upper: Boolean; external obj_dll;
function obj_Goto_down: Boolean; external obj_dll;
function obj_Goto_home: longint; external obj_dll;
function obj_Goto_last: longint; external obj_dll;
function obj_menu_item: int; external obj_dll;
function obj_menu_seek(code,loc: int): Boolean; external obj_dll;

function obj_group_of(Code: int; List: PLPoly; MaxCount: int): int;
external obj_dll;

function Pens_Count: Integer;
external obj_dll;

function Get_Pen(Ind: Integer; out Pen: TExtPen): Integer;
external obj_dll;

function Vgm_Open(Path: PChar): Boolean;
external obj_dll;

procedure Vgm_Close;
external obj_dll;

function Vgm_Count: Integer;
external obj_dll;

function vgm_Index_Of_Code(Code: Integer): Integer;
external obj_dll;

function Vgm_Sign(I: Integer; Buf: PBytes;
                  Size: Integer): Integer;
external obj_dll;

function Vgm_Height(I: Integer): Double;
external obj_dll;

function vgm_Get_hdr(vgm_Ind: Integer;
                     out w,h: Integer): Integer;
external obj_dll;

function vgm_Get_poly(vgm_Ind,lp_i: Integer; out cl: Integer;
                      lp: PLLine; lp_Max: Integer): Integer;
external obj_dll;

function vgm_Draw(DC: HDC; x,y,w,h,Ind: Integer): Integer;
external obj_dll;

function vgm_gif(Dest: PChar; w,h,Ind: Integer): Integer;
external obj_dll;

function obj_SetColor(Ind,Val: DWord): DWord;
external obj_dll;

function obj_Get_Blank(I: Integer; lp: PWLine; max: Integer): Integer;
external obj_dll;

function idx_Open(Path: PChar): Boolean;
external obj_dll;
procedure idx_Close;
external obj_dll;

function idx_Count: Integer;
external obj_dll;

function idx_Item(Ind: Integer;
                  out Tag: Id_Tag;
                  Name: PChar): Integer;
external obj_dll;

function idx_Indexof(Nnn: Integer;
                     out Tag: Id_Tag;
                     Name: PChar): Integer;
external obj_dll;

function init_obj: uint;
external obj_dll;

procedure done_obj(h: uint);
external obj_dll;

function icons_init: uint;
external obj_dll;

procedure icons_done(h: uint);
external obj_dll;

procedure icons_add(h: uint; key: int; ico: Pointer);
external obj_dll;

function icons_draw(h: uint; DC: HDC; x,y,key: int): int; stdcall;
external obj_dll;

end.
