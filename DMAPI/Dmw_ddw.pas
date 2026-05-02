unit Dmw_ddw; interface

uses
  Windows,SysUtils,OTypes,dmw_use;

const
  pen_Code    = 21;
  pen_View    = 22;
  pen_Info    = 23;
  pen_Text    = 24;
  pen_First   = 25;
  pen_Color   = 26;
  pen_Move    = 27;
  pen_Copy    = 28;
  pen_Rotate  = 29;
  pen_Mirror  = 30;
  pen_Delete  = 31;
  pen_Access  = 32;
  pen_Calc    = 33;
  pen_Attr    = 34;

  pen_pmov    = 41;
  pen_pdel    = 42;
  pen_lmov    = 43;
  pen_ladd    = 44;
  pen_ldel    = 45;
  pen_lock    = 46;
  pen_swap    = 47;
  pen_ldiv    = 48;
  pen_Join    = 49;
  pen_pcls    = 50;
  pen_pline   = 51;
  pen_prect   = 52;
  pen_Scale   = 53;
  pen_Run     = 54;
  pen_Curve   = 55;

function dmw_connect: Boolean; stdcall;
procedure dmw_disconnect; stdcall;
function dmw_count: int; stdcall;

function dmw_Open(dm: PChar; rw: boolean): Integer;
function dmw_open_dm(rw: Boolean): Boolean;
procedure dmw_Done;

function dmw_Server_Exist: boolean; stdcall;
procedure dmw_dde_Abort; stdcall;

procedure dll_app_handle(Wnd: HWnd); stdcall;
                                                             
procedure dmw_register_wnd(Wnd: HWnd); stdcall;
procedure dmw_unregister_wnd(Wnd: HWnd); stdcall;

procedure dmw_Pick_wm(wm, w,h: Integer); stdcall;

function dmw_PickMessage(s: PChar): boolean; stdcall;
function dmw_PickCaption(s: PChar): boolean; stdcall;

function dmw_PickPoint(var ix,iy: longint; var gx,gy: double): boolean;
stdcall;
{Укажи точку -> <ix,iy> , <gx,gy> - координаты точки}

function dmw_PickGauss(locator: Boolean;
                       var ix,iy: longint;
                       var gx,gy,gz: double): boolean; stdcall;

function dmw_PickRect(var x1,y1,x2,y2: longint): boolean;
stdcall;
{Укажи фрагмент -> <x1 y1 x2 y2>}

function dmw_PickPort(w,h: longint; var x1,y1,x2,y2: longint): boolean;
stdcall;
{Укажи фрагмент с заданными шириной <w> и высотой <h> -> <x1 y1 x2 y2>}

function dmw_PickPoly(lock: boolean; lp: PLLine; max: word): boolean;
stdcall;
{Укажи полилинию/полигон -> <lp> - полилиния }
{ <max> - максимальное количество точек      }
{ <lock> =0 - полилиния; =1 - полигон        }

function dmw_PickVector(var x1,y1,x2,y2: longint): boolean;
stdcall; {Укажи вектор -> <x1 y1 x2 y2>}

function dmw_PickRing(var x,y,r: longint): boolean;
stdcall; {Укажи окружность -> <x,y,r>}

function dmw_PickObject(var offs,Code: longint; var Tag: byte;
                        var x1,y1,x2,y2: longint;
                        name: PChar; len: word): boolean;
stdcall;
{Укажи объект -> <offs Code Tag x1 y1 x2 y2 name>}

function dmw_PickImage(var x1,y1,x2,y2: longint): boolean;
stdcall;

function dmw_PickGeoid(w,h: longint; var x1,y1,x2,y2: longint): boolean;
stdcall;

function dmw_PickMove(w,h: longint; var x1,y1,x2,y2: longint): boolean;
stdcall;

function dmx_PickVector(vp: PLPoly; Capt: PChar): bool;

function dmw_ChooseObject(iCode: longint; iTag: byte;
                          var Code: longint; var Tag: byte;
                          name: PChar; len: word): boolean;
stdcall;
{Выбрать объект в меню -> <Code Tag Name>}

function dmw_GetColor(Index: Integer): Integer; stdcall;

function dmw_ChooseColor(iIndex: byte; var Index: byte;
                         var Color: longint): boolean;
stdcall;
{Выбрать цвет в палитре -> Index ColorRef}

function dmw_DialogInfo(p: longint): boolean; stdcall;

function dmw_HideMap: boolean; stdcall;
{Закрыть активную карту для редактирования}

function dmw_BackMap: boolean; stdcall;
{Открыть активную карту для редактирования}

function dmw_SetFocus: boolean; stdcall;
{Установить фокус ввода на рабочее окно}

function dmw_HideWindow: boolean;
stdcall; {Закрыть окно "Редактор"}

function dmw_BackWindow: boolean;
stdcall; {Вернуть окно "Редактор"}

function dmw_ShowWindow(x1,y1,x2,y2: longint): boolean;
stdcall; {Отобразить фрагмент карты <x1,y1,x2,y2> в рабочем окне}

function dmw_ShowPoint(gx,gy,scale: double): boolean; stdcall;
{Установить для рабочего окна центр <gx,gy> и масштаб <scale> }
{gx,gy - метры; scale - 1:xxxxx                               }

function dmw_ShowWGS(gx,gy,gz,scale: double): boolean; stdcall;

function dmw_ShowObject(offs: longint; scale: double): boolean;
stdcall;
{Предъявить объект <offs> на масштабе <scale> }
{offs - указатель на объект                   }

function dmw_SwapMap(fn: PChar): boolean; stdcall;
{Установить карту с именем <fn> активной}

function dmi_ShowLink(id: longint; scale: double): boolean;
stdcall;
{Предъявить объект <id> на масштабе <scale> }
{id - номер объекта                         }

function dmw_FreeObject: boolean; stdcall;
{Освободить выбранный в рабочем окне объект}

function dmw_FreeObjectB: boolean; stdcall;
{Освободить выбранный в рабочем окне объектB}

function dmw_DrawObject(offs: longint): boolean; stdcall;
{Отобразить объект <offs>, где offs - указатель на объект}

function dmw_HideObject(offs: longint): boolean; stdcall;
{Стереть объект <offs>, где offs - указатель на объект}

procedure dmw_DispObject(dm: PChar; p,mode: longint); stdcall;
{ mode = 0 рисовать
       = 1 стереть
}

function dmw_StackPush(gx,gy,scale: double; msg: PChar): boolean;
stdcall; {Добавить фрагмент в стек}

function dmw_StackClear: boolean; stdcall;
{Очистить стек}

function dmw_InsertMap(fn: PChar): boolean; stdcall;
{Добавить карту с именем <fn> в проект}

function dmw_UpdateMap(fn: PChar): boolean; stdcall;
{Обновить карту с именем <fn> в проекте}

function dmw_DeleteMap(fn: PChar): boolean; stdcall;
{Удалить карту с именем <fn> из проекта}

function dmw_ReplaceMap(fn1,fn2: PChar): boolean; stdcall;
{Заменить карту <fn1> в проекте картой <fn2>}

function dmw_OpenProject(fn: PChar): boolean; stdcall;
{Открыть проект <fn>}

function dmw_SaveProject(fn: PChar): boolean; stdcall;

function dmw_ChangeProject(fn: PChar): boolean; stdcall;
{Сменить проект <fn>}

function dmw_PcxPath(fn: PChar; len: Integer): PChar; stdcall;
{Возвращает имя растра}

function dmw_PcxOpen(fn: PChar): boolean; stdcall;
{Открыть растр <fn>}

function dmw_DrawPoly(lp: PLLine; Tag: byte; cl: longint): boolean;
stdcall;
{Нарисовать полилинию (Tag=2) / полигон (Tag = 3), cl - графика}

function dmw_DrawPgm(x,y: longint; i: word; pgm: PChar): boolean;
stdcall;
{Нарисовать растровый знак в точке  <x,y> }
{i - номер знака; pgm - имя библиотеки    }

function dmw_DrawVgm(x1,y1,x2,y2: longint; i: word; pgm: PChar): boolean;
stdcall;
{Нарисовать векторный знак в точке  <x1,y1> }
{i - номер знака; vgm - имя библиотеки      }

procedure dmw_DrawText(x1,y1,x2,y2, Code,Up: Integer; s: PChar);
stdcall;

function dmw_DrawVector(Id,Loc,Color: Integer;
                        lp: PLLine; txt: PChar): Integer; stdcall;

function dmw_DrawVector1(Id,Loc,Color: int; lp: PLPoly; N: int): int; stdcall;

function dmw_DrawVector2(Id,Loc,Color: int; mf,txt: PChar): int; stdcall;
                        
function dmw_InsObject(Code: longint; Tag: byte; txt: PChar; lp: pLLine): boolean;
stdcall;
{Добавить объект, где Code - код, Tag - тип, txt - текст; lp - координаты}

function dmw_MoveObject(offs, dx,dy: longint): boolean;
stdcall;
{Переместить объект, где offs - указатель, <dx,dy> - смещение}

function dmw_MoveSign(offs, x1,y1,x2,y2: longint): boolean;
stdcall;
{Переместить знак,где offs - указатель, }
{<x1,y1> - точка, <x2,y2> - направление }

function info_SetInt(offs: longint; nn: word; equ: longint): boolean;
stdcall;
{Назначить объекту целую характеристику, где offs - указатель, }
{<nn,equ> - номер и значение характеристики                    }

function info_SetReal(offs: longint; nn: word; equ: float): boolean;
stdcall;
{Назначить объекту плавающую характеристику, где offs - указатель, }
{<nn,equ> - номер и значение характеристики                        }

function info_SetStr(offs: longint; nn: word; equ: PChar): boolean;
stdcall;
{Назначить объекту строковую характеристику, где offs - указатель, }
{<nn,equ> - номер и значение характеристики                        }

function dmw_ListAppend(offs: longint): boolean;
stdcall;

function dmw_SelPair(p1,p2: longint): Boolean; stdcall;

function dmw_ListContains(offs: longint): boolean;
stdcall;

function dmw_ListClear: boolean; stdcall;
function dmw_ListDelete: boolean; stdcall;
function dmw_ListCode(Code: longint; Loc: byte): boolean; stdcall;

function dmw_DrawMsg(Wnd: hWnd; Msg: word): boolean; stdcall;
function dmw_MoveMsg(Wnd: hWnd; Msg: word): boolean; stdcall;

function win_ChildShow(Wnd: hWnd; Msg: word): boolean; stdcall;
function win_ChildHide: boolean; stdcall;

function dmw_MainMinimize: boolean; stdcall;
function dmw_MainNormal: boolean; stdcall;
function dmw_MainClose: boolean; stdcall;

function dmw_GetRoot: longint; stdcall;
{Возвращает указатель на корень карты}

function dmw_AltProject(fn: PChar; len: word): PChar;
stdcall;
{Возвращает имя файла со списком карт в проекте}

function dmw_AllProject(fn: PChar; len: word): PChar;
stdcall;
{Возвращает имя файла с полным списком карт в проекте}

function dmw_ActiveMap(fn: PChar; len: word): PChar;
stdcall; {Возвращает имя активной карты}

function dmw_MapsCount: Integer; stdcall;
{Возвращает количество карт в проекте}

function dmw_ProjectMap(i: word; fn: PChar; len: word): PChar;
stdcall;
{Возвращает имя карты в проекте, где i - порядковый номер}

function dmw_MapContains(x,y: longint; fn: PChar; len: word): SmallInt;
stdcall;
{Возвращает порядковый номер и имя карты <fn> в проекте, }
{которая содержит точку с координатами <x,y>             }
{<len> - максимальная длина строки <fn>                  }

function dmw_GetWindow(var x1,y1,x2,y2: longint): boolean;
stdcall;
{Возвращает <x1,y1,x2,y2> - координаты рабочего окна}

function dmw_GetCentre(var gx,gy,sc: double): boolean;
stdcall;
{Возвращает <gx,gy,sc> - центр и масштаб рабочего окна}

function dmw_Offs_Id(offs: longint; var id: longint): boolean;
stdcall;
{Возвращает номер объекта,где offs - указатель, id - номер}

function dmw_Id_Offs(id: longint; var offs: longint): boolean;
stdcall;
{Возвращает указатель на объект,где id - номер, offs - указатель}

function dmw_IntObject(Code: longint; Tag: byte; nn: word; equ: longint): longint;
stdcall;
{Возвращает указатель на объект,где <Code,Tag> - код и тип объекта }
{<nn,equ> - номер и значение целой характеристики                  }

function dmw_StrObject(Code: longint; Tag: byte; nn: word; equ: PChar): longint;
stdcall;
{Возвращает указатель на объект,где <Code,Tag> - код и тип объекта }
{<nn,equ> - номер и значение строковой характеристики              }

function info_GetInt(offs: longint; nn: word; var equ: longint): boolean;
stdcall;
{Возвращает для объекта <offs> значение <equ>}
{целой характеристики с номером <nn>         }

function info_GetReal(offs: longint; nn: word; var equ: double): boolean;
stdcall;
{Возвращает для объекта <offs> значение <equ>}
{плавающей характеристики с номером <nn>     }

function info_GetStr(offs: longint; nn: word; equ: PChar; len: word): PChar;
stdcall;
{Возвращает для объекта <offs> значение <equ>}
{строковой характеристики с номером <nn>     }

function dmw_MenuObject(var Code: longint; var Tag: byte;
                        name: PChar; len: word): PChar;
stdcall;
{Возвращает для выбранного в меню объекта}
{код <Code>, тип <Tag>, название <name>  }

function dmw_OffsObject(var offs,Code: longint; var Tag: byte;
                        var x1,y1,x2,y2: longint;
                        name: PChar; len: word): PChar;
stdcall;
{Возвращает для выбранного в рабочем окне объекта}
{указатель <offs>, код <Code>, тип <Tag>,        }
{габаритную рамку <x1,y1,x2,y2>, название <name> }

function dmw_NextObject(var offs,Code: longint; var Tag: byte;
                        var x1,y1,x2,y2: longint;
                        name: PChar; len: word): PChar; stdcall;

function dmi_LinkObject(var id,Code: longint; var Tag: byte): boolean;
stdcall;
{Возвращает для выбранного в рабочем окне объекта}
{номер <id>, код <Code>, тип <Tag>               }

function dmi_PasteObject(id: longint; fn: PChar): longint;
stdcall;

function dmw_ListRect( var x1,y1,x2,y2: longint): boolean;
stdcall;

function dmw_L_to_G(ix,iy: longint; var gx,gy: double): boolean; stdcall;
function dmw_G_to_L(gx,gy: double; var ix,iy: longint): boolean; stdcall;

function dmw_L_to_B(ix,iy: longint; var ox,oy: longint): boolean; stdcall;
function dmw_B_to_L(ix,iy: longint; var ox,oy: longint): boolean; stdcall;

procedure dmw_lp_View(v: Integer); stdcall;

function sau_Track(fl: byte): boolean; stdcall;
function sau_Ctrl: boolean; stdcall;

function dmw_English: boolean; stdcall;

procedure dmw_dlg_Options; stdcall;

function dmw_Choose_Layer(out Code: int): int; stdcall;

procedure dmw_dlg_Layers; stdcall;
procedure dmw_dlg_Ground; stdcall;
procedure dmw_dlg_Object; stdcall;
procedure dmw_Restore_Graphics; stdcall;

function dmw_win_Objects_Count: int; stdcall;
function dmw_win_Objects(I: int): int; stdcall;

function dmw_sel_Objects_Count: int; stdcall;
function dmw_sel_Objects(I: int): int; stdcall;
procedure dmw_sel_Pair(I: int; out p1,p2: int); stdcall;

procedure dmw_Update_Object(p: int); stdcall;

procedure dmw_Change_Tool(pen: int); stdcall;

procedure dmw_Show_Gauss(lt_x,lt_y,rb_x,rb_y: Double; pps: int);
stdcall;

function dmw_Get_Gauss(out lt_x,lt_y,rb_x,rb_y: Double): int;
stdcall;

function dmw_Spy_Command(cmd: PChar): int; stdcall;

procedure dmw_ext_Draft(x1,y1,x2,y2, show: int); stdcall;

procedure dmw_ext_Draft1(id: int;
                         const a,b: TGauss;
                         const s: tsys); stdcall;

procedure dmw_ext_Draft2(id: int;
                         const g: TGauss3;
                         const s: tsys); stdcall;

procedure dmw_geoid_show(x,y: Double; pps, scale: int); stdcall;
procedure dmw_geoid_send(x,y: Double; pps: int); stdcall;

procedure dmw_d3_sync(const e,p: txyz; pps: int); stdcall;

procedure dmw_sdb_radius(r,f: Double; ed: Integer); stdcall;

function dmw_is_mm: Boolean; stdcall;

procedure dmw_Refresh; stdcall;

function dmw_Get_Play_dm(fn: PChar): PChar; stdcall;
procedure dmw_Set_Play_dm(dm: PChar); stdcall;
procedure dmw_Play_tick; stdcall;

procedure dmw_Movie_dm(Wnd: int; FName: PChar); stdcall;

// Предъявить объект в окне [Редактор]
function dmw_ext_ShowObject(cn,id: longint; scale: double): boolean;
stdcall;

// Предъявить объект в окне [Просмотр]
function dmw_ViewObject(cn,id: longint; scale: double): boolean;
stdcall;

procedure dmw_SetBitmap(Path: PChar); stdcall;

function dmw_GetRelief(Path: PChar; len: Integer): PChar; stdcall;
procedure dmw_SetRelief(Path: PChar); stdcall;

procedure dmw_Open_ext(Path,Ext: PChar); stdcall;

procedure dmw_lock; stdcall;
procedure dmw_unlock; stdcall;

procedure dmw_win_lock(fl: Integer); stdcall;

function dmw_GetIValue(Typ,Ind: Integer): Integer; stdcall;
{  Typ = 0
   Ind = 0  - кол-во карт
         1  - кол-во рельефа
         2  - кол-во фотопланов
         98 - кол-во точек локальной системы
              хранения в пикселе экрана (x1000)
         99 - идентификатор активного элемента
              в списке рисования
         11 - X координата указанной точки объекта
         12 - Y координата указанной точки объекта
         13 - индекс точки, если < 0, значит ребро
         14 - индекс активного инструмеента
}

function dmw_GetSValue(Typ,Ind: Integer; val: PChar): PChar; stdcall;
{
   Typ = 0 - вернуть имя карты [Ind]
   Typ = 1 - вернуть имя рельефа [Ind]
   Typ = 2 - вернуть имя фотоплана [Ind]
}

function dmw_GetOccupeC(out c: TPoint): Integer; stdcall;

procedure dmw_XY_BL(x,y: Double; out b,l: Double); stdcall;
procedure dmw_BL_XY(b,l: Double; out x,y: Double); stdcall;
procedure dmw_WGS_BL(wb,wl: Double; out gb,gl: Double); stdcall;

procedure dmw_Exec(Cmd: PChar); stdcall;
procedure dmw_gps(t,b,l,h,up: Integer); stdcall;

procedure dmw_log(log: PChar); stdcall;
procedure dmw_filter(Path,Options: PChar); stdcall;

procedure dmw_cmd_wait(v: Boolean); stdcall;

procedure dmw_movep(ptr: int); stdcall;

procedure dmw_user_data(param,value: PChar); stdcall;

procedure dmw_profile(x1,y1,x2,y2: int); stdcall;

function dmw_map_of(Path: PChar): int;

implementation

const
  dll_dde = 'dll_ddw.dll';

function dmw_connect: Boolean; external dll_dde;
procedure dmw_disconnect; external dll_dde;
function dmw_count: int; external dll_dde;

function dmw_Open(dm: PChar; rw: boolean): Integer;
begin
  Result:=0; if dmw_HideMap then
  Result:=dm_Open(dm,rw)
end;

function dmw_open_dm(rw: Boolean): Boolean;
var
  dm: TShortstr;
begin
  Result:=false;
  if dmw_ActiveMap(dm,255) <> nil then begin
    dmw_HideMap; Result:=dm_Open(dm,rw) > 0
  end
end;

procedure dmw_Done;
begin
  dm_Done; dmw_BackMap
end;

function dmw_Server_Exist: boolean; external dll_dde;
procedure dmw_dde_Abort; external dll_dde;

procedure dll_app_handle(Wnd: HWnd); external dll_dde;

procedure dmw_register_wnd(Wnd: HWnd); external dll_dde;
procedure dmw_unregister_wnd(Wnd: HWnd); external dll_dde;

procedure dmw_Pick_wm(wm, w,h: Integer); external dll_dde;

function dmw_PickMessage(s: PChar): boolean; external dll_dde;
function dmw_PickCaption(s: PChar): boolean; external dll_dde;

function dmw_PickPoint(var ix,iy: longint; var gx,gy: double): boolean;
external dll_dde;

function dmw_PickGauss(locator: Boolean;
                       var ix,iy: longint;
                       var gx,gy,gz: double): boolean;
external dll_dde;

function dmw_PickRect(var x1,y1,x2,y2: longint): boolean;
external dll_dde;

function dmw_PickPort(w,h: longint; var x1,y1,x2,y2: longint): boolean;
external dll_dde;

function dmw_PickPoly(lock: boolean; lp: pLLine; max: word): boolean;
external dll_dde;

function dmw_PickVector(var x1,y1,x2,y2: longint): boolean;
external dll_dde;

function dmw_PickRing(var x,y,r: longint): boolean;
external dll_dde;

function dmw_PickObject(var offs,Code: longint; var Tag: byte;
                        var x1,y1,x2,y2: longint;
                        name: PChar; len: word): boolean;
external dll_dde;

function dmw_PickImage(var x1,y1,x2,y2: longint): boolean;
external dll_dde;

function dmw_PickGeoid(w,h: longint; var x1,y1,x2,y2: longint): boolean;
external dll_dde;

function dmw_PickMove(w,h: longint; var x1,y1,x2,y2: longint): boolean;
external dll_dde;

function dmx_PickVector(vp: PLPoly; Capt: PChar): bool;
begin
  if Assigned(Capt) then dmw_PickCaption(Capt);
  Result:=dmw_PickVector(vp[0].X,vp[0].Y,vp[1].X,vp[1].Y);
  if Assigned(Capt) then dmw_PickCaption('');
end;

function dmw_ChooseObject(iCode: longint; iTag: byte;
                          var Code: longint; var Tag: byte;
                          name: PChar; len: word): boolean;
external dll_dde;

function dmw_ChooseColor(iIndex: byte; var Index: byte;
                         var Color: longint): boolean;
external dll_dde;

function dmw_GetColor(Index: Integer): Integer;
external dll_dde;

function dmw_DialogInfo(p: longint): boolean;
external dll_dde;

function dmw_HideMap: boolean; external dll_dde;
function dmw_BackMap: boolean; external dll_dde;

function dmw_SetFocus: boolean; external dll_dde;

function dmw_CopyWindow(x1,y1,x2,y2: longint; fn: PChar): boolean;
external dll_dde;

function dmw_HideWindow: boolean; external dll_dde;
function dmw_BackWindow: boolean; external dll_dde;

function dmw_ShowWindow(x1,y1,x2,y2: longint): boolean; external dll_dde;
function dmw_ShowPoint(gx,gy,scale: double): boolean; external dll_dde;
function dmw_ShowWGS(gx,gy,gz,scale: double): boolean; external dll_dde;
function dmw_ShowObject(offs: longint; scale: double): boolean; external dll_dde;

function dmw_SwapMap(fn: PChar): boolean; external dll_dde;

function dmi_ShowLink(id: longint; scale: double): boolean; external dll_dde;

function dmw_FreeObject: boolean; external dll_dde;
function dmw_FreeObjectB: boolean; external dll_dde;

function dmw_DrawObject(offs: longint): boolean; external dll_dde;
function dmw_HideObject(offs: longint): boolean; external dll_dde;

procedure dmw_DispObject(dm: PChar; p,mode: longint); external dll_dde;

function dmw_StackPush(gx,gy,scale: double; msg: PChar): boolean; external dll_dde;
function dmw_StackClear: boolean; external dll_dde;

function dmw_InsertMap(fn: PChar): boolean; external dll_dde;
function dmw_UpdateMap(fn: PChar): boolean; external dll_dde;
function dmw_DeleteMap(fn: PChar): boolean; external dll_dde;
function dmw_ReplaceMap(fn1,fn2: PChar): boolean; external dll_dde;

function dmw_OpenProject(fn: PChar): boolean; external dll_dde;
function dmw_SaveProject(fn: PChar): boolean; external dll_dde;
function dmw_ChangeProject(fn: PChar): boolean; external dll_dde;

function dmw_PcxPath(fn: PChar; len: Integer): PChar; external dll_dde;
function dmw_PcxOpen(fn: PChar): boolean; external dll_dde;

function dmw_DrawPoly(lp: pLLine; Tag: byte; cl: longint): boolean;
external dll_dde;

function dmw_DrawPgm(x,y: longint; i: word; pgm: PChar): boolean;
external dll_dde;

function dmw_DrawVgm(x1,y1,x2,y2: longint; i: word; pgm: PChar): boolean;
external dll_dde;

procedure dmw_DrawText(x1,y1,x2,y2, Code,Up: Integer; s: PChar);
external dll_dde;

function dmw_DrawVector(Id,Loc,Color: Integer;
                        lp: PLLine; txt: PChar): Integer;
external dll_dde;

function dmw_DrawVector1(Id,Loc,Color: int; lp: PLPoly; N: int): int;
external dll_dde;

function dmw_DrawVector2(Id,Loc,Color: int; mf,txt: PChar): int;
external dll_dde;

function dmw_InsObject(Code: longint; Tag: byte; txt: PChar; lp: pLLine): boolean;
external dll_dde;

function dmw_MoveObject(offs, dx,dy: longint): boolean; external dll_dde;
function dmw_MoveSign(offs, x1,y1,x2,y2: longint): boolean; external dll_dde;

function info_SetInt(offs: longint; nn: word; equ: longint): boolean;
external dll_dde;

function info_SetReal(offs: longint; nn: word; equ: float): boolean;
external dll_dde;

function info_SetStr(offs: longint; nn: word; equ: PChar): boolean;
external dll_dde;

function dmw_ListAppend(offs: longint): boolean; external dll_dde;
function dmw_ListContains(offs: longint): boolean; external dll_dde;

function dmw_SelPair(p1,p2: longint): Boolean; external dll_dde;

function dmw_ListClear: boolean; external dll_dde;
function dmw_ListDelete: boolean; external dll_dde;
function dmw_ListCode(Code: longint; Loc: byte): boolean; external dll_dde;

function dmw_DrawMsg(Wnd: hWnd; Msg: word): boolean; external dll_dde;
function dmw_MoveMsg(Wnd: hWnd; Msg: word): boolean; external dll_dde;

function win_ChildShow(Wnd: hWnd; Msg: word): boolean; external dll_dde;
function win_ChildHide: boolean; external dll_dde;

function dmw_MainMinimize: boolean; external dll_dde;
function dmw_MainNormal: boolean; external dll_dde;
function dmw_MainClose: boolean; external dll_dde;

function dmw_GetRoot: longint; external dll_dde;

function dmw_AltProject(fn: PChar; len: word): PChar; external dll_dde;
function dmw_AllProject(fn: PChar; len: word): PChar; external dll_dde;

function dmw_ActiveMap(fn: PChar; len: word): PChar; external dll_dde;

function dmw_MapsCount: Integer; external dll_dde;

function dmw_ProjectMap(i: word; fn: PChar; len: word): PChar;
external dll_dde;

function dmw_MapContains(x,y: longint; fn: PChar; len: word): SmallInt;
external dll_dde;

function dmw_GetWindow(var x1,y1,x2,y2: longint): boolean; external dll_dde;
function dmw_GetCentre(var gx,gy,sc: double): boolean; external dll_dde;

function dmw_Offs_Id(offs: longint; var id: longint): boolean; external dll_dde;
function dmw_Id_Offs(id: longint; var offs: longint): boolean; external dll_dde;

function dmw_IntObject(Code: longint; Tag: byte; nn: word; equ: longint): longint;
external dll_dde;

function dmw_StrObject(Code: longint; Tag: byte; nn: word; equ: PChar): longint;
external dll_dde;

function info_GetInt(offs: longint; nn: word; var equ: longint): boolean;
external dll_dde;

function info_GetReal(offs: longint; nn: word; var equ: double): boolean;
external dll_dde;

function info_GetStr(offs: longint; nn: word; equ: PChar; len: word): PChar;
external dll_dde;

function dmw_MenuObject(var Code: longint; var Tag: byte;
                        name: PChar; len: word): PChar;
external dll_dde;

function dmw_OffsObject(var offs,Code: longint; var Tag: byte;
                        var x1,y1,x2,y2: longint;
                        name: PChar; len: word): PChar;
external dll_dde;

function dmw_NextObject(var offs,Code: longint; var Tag: byte;
                        var x1,y1,x2,y2: longint;
                        name: PChar; len: word): PChar;
external dll_dde;

function dmi_LinkObject(var id,Code: longint; var Tag: byte): boolean;
external dll_dde;

function dmi_PasteObject(id: longint; fn: PChar): longint;
external dll_dde;

function dmw_ListRect(var x1,y1,x2,y2: longint): boolean;
external dll_dde;

function dmw_L_to_G(ix,iy: longint; var gx,gy: double): boolean; external dll_dde;
function dmw_G_to_L(gx,gy: double; var ix,iy: longint): boolean; external dll_dde;
function dmw_L_to_B(ix,iy: longint; var ox,oy: longint): boolean; external dll_dde;
function dmw_B_to_L(ix,iy: longint; var ox,oy: longint): boolean; external dll_dde;

procedure dmw_lp_View(v: Integer); external dll_dde;

function sau_Track(fl: byte): boolean; external dll_dde;
function sau_Ctrl: boolean; external dll_dde;

function dmw_English: boolean; external dll_dde;

procedure dmw_dlg_Options; external dll_dde;

function dmw_Choose_Layer(out Code: Integer): Integer;
external dll_dde;

procedure dmw_dlg_Layers; external dll_dde;
procedure dmw_dlg_Ground; external dll_dde;
procedure dmw_dlg_Object; external dll_dde;
procedure dmw_Restore_Graphics; external dll_dde;

function dmw_win_Objects_Count: Integer; external dll_dde;
function dmw_win_Objects(I: Integer): Integer; external dll_dde;

function dmw_sel_Objects_Count: Integer; external dll_dde;
function dmw_sel_Objects(I: Integer): Integer; external dll_dde;
procedure dmw_sel_Pair(I: Integer; out p1,p2: Integer); external dll_dde;

procedure dmw_Update_Object(p: Integer); external dll_dde;

procedure dmw_Change_Tool(pen: Integer); external dll_dde;

procedure dmw_Show_Gauss(lt_x,lt_y,rb_x,rb_y: Double; pps: Integer);
external dll_dde;

function dmw_Get_Gauss(out lt_x,lt_y,rb_x,rb_y: Double): Integer;
external dll_dde;

function dmw_Spy_Command(cmd: PChar): Integer; external dll_dde;

procedure dmw_ext_Draft(x1,y1,x2,y2, show: Integer); external dll_dde;

procedure dmw_ext_Draft1(id: int;
                         const a,b: TGauss;
                         const s: tsys); external dll_dde;

procedure dmw_ext_Draft2(id: int;
                         const g: TGauss3;
                         const s: tsys); external dll_dde;

procedure dmw_geoid_show(x,y: Double; pps, scale: Integer);
external dll_dde;

procedure dmw_geoid_send(x,y: Double; pps: int);
external dll_dde;

procedure dmw_d3_sync(const e,p: txyz; pps: int);
external dll_dde;

procedure dmw_sdb_radius(r,f: Double; ed: Integer);
external dll_dde;

function dmw_is_mm: Boolean; external dll_dde;

procedure dmw_Refresh; external dll_dde;

function dmw_Get_Play_dm(fn: PChar): PChar; external dll_dde;
procedure dmw_Set_Play_dm(dm: PChar); external dll_dde;
procedure dmw_Play_tick; external dll_dde;

procedure dmw_Movie_dm(Wnd: Integer; FName: PChar);
external dll_dde;

function dmw_ext_ShowObject(cn,id: longint; scale: double): boolean;
external dll_dde;

function dmw_ViewObject(cn,id: longint; scale: double): boolean;
external dll_dde;

procedure dmw_SetBitmap(Path: PChar); external dll_dde;

function dmw_GetRelief(Path: PChar; len: Integer): PChar;
external dll_dde;
procedure dmw_SetRelief(Path: PChar);
external dll_dde;

procedure dmw_Open_ext(Path,Ext: PChar);
external dll_dde;

procedure dmw_lock; external dll_dde;
procedure dmw_unlock; external dll_dde;

procedure dmw_win_lock(fl: Integer); external dll_dde;

function dmw_GetIValue(Typ,Ind: Integer): Integer;
external dll_dde;

function dmw_GetSValue(Typ,Ind: Integer; val: PChar): PChar;
external dll_dde;

function dmw_GetOccupeC(out c: TPoint): Integer;
external dll_dde;

procedure dmw_XY_BL(x,y: Double; out b,l: Double);
external dll_dde;
procedure dmw_BL_XY(b,l: Double; out x,y: Double);
external dll_dde;

procedure dmw_WGS_BL(wb,wl: Double; out gb,gl: Double);
external dll_dde;

procedure dmw_Exec(Cmd: PChar); external dll_dde;
procedure dmw_gps(t,b,l,h,up: int); external dll_dde;

procedure dmw_log(log: PChar); external dll_dde;
procedure dmw_filter(Path,Options: PChar); external dll_dde;

procedure dmw_movep(ptr: int); external dll_dde;

procedure dmw_cmd_wait(v: Boolean); external dll_dde;

procedure dmw_user_data(param,value: PChar); external dll_dde;

procedure dmw_profile(x1,y1,x2,y2: int); external dll_dde;

function dmw_map_of(Path: PChar): int;
var
  i,n: int; fn1,fn2: TShortstr;
begin
  Result:=-1;

  StrLCopy(fn1,Path,255);
  StrUpper(fn1);

  n:=dmw_MapsCount;
  for i:=0 to n-1 do begin
    dmw_ProjectMap(i,fn2,255);
    StrUpper(fn2);

    if StrComp(fn1,fn2) = 0 then begin
      Result:=i; Break
    end
  end
end;

end.
