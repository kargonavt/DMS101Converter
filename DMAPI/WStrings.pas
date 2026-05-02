unit WStrings; interface

uses
  Windows,Classes,
  Math,Sysutils,OTypes;

function WideCharToStr(Src: PWideChar; Dest: PChar; DestSize: int): PChar;

function StrCopyW(Dest: PWideChar; const Source: PWideChar; MaxLen: int): PWideChar;
function StrUCopyW(Dest: PWideChar; const Source: PWideChar; MaxLen: int): PWideChar;
function StrPCopyW(Dest: PWideChar; const Source: WideString; MaxLen: int): PWideChar;
function StrLatinW(Dest: PWideChar; const Source: String): PWideChar;

function StrCompW(S1,S2: PWideChar): int;

function StrLenW(Str: PWideChar): int;

function StrPasWW(Str: PWideChar): WideString;
function StrLPasWW(Str: PWideChar; len: int): WideString;
function StrPasAW(Str: PAnsiChar; len: int = 0): WideString;
function StrPasSW(const Str: String): WideString;

function StrCatWC(Dest,Str: PWideChar; MaxLen: int): PWideChar;
function PasCatWC(Dest,Str: PWideChar; MaxLen: int): PWideChar;

function PasCatWS(Dest: PWideChar;
                  const Str: WideString;
                  MaxLen: int): PWideChar;

function StrToMemoW(Str: PWideChar; Memo: TStrings): int;

function WideStringToString(const Src: WideString; out Dest: String): boolean;

function TextToStr(const w: WideString): WideString;

function VerifyEolW(var w: WideString): bool;

function StrReplaceW(const s: WideString; ch1,ch2: WideChar): WideString;
function StrTruncateW(const s: WideString; ch: WideChar): WideString;

function lstrW(const s: WideString): WideString;

function quoteStrW(const s: WideString): WideString;

function json_close_quotes(Str: WideString): WideString;
function jsonStrW(const s: WideString): WideString;

procedure simplifiedW(var s: WideString);

procedure trW(s: PWideChar; tr: PWords);

function splitW(Tokens: TStrings; const Str: WideString; delimiter: WideChar): int;

implementation

function WideCharToStr(Src: PWideChar; Dest: PChar; DestSize: int): PChar;
var
  len: int;
begin
  len:=StrLenW(Src);
  len:=WideCharToMultiByte(0,0, Src,len, Dest,DestSize, nil,nil);
  if len < 0 then len:=0; Dest[len]:=#0; Result:=Dest;
end;

function StrCopyW(Dest: PWideChar; const Source: PWideChar; MaxLen: int): PWideChar;
var
  Src: PWideChar;
begin
  Result:=Dest;

  if Assigned(Dest) and (MaxLen > 0) then begin
    Src:=Source; if Assigned(Src) then
    while (MaxLen > 0) and (Src^ <> #0) do begin
      Dest^:=Src^; Inc(Src); Inc(Dest); Dec(MaxLen);
    end;

    Dest^:=#0;
  end;
end;

function StrUCopyW(Dest: PWideChar; const Source: PWideChar; MaxLen: int): PWideChar;
var
  si,di: PWideChar; cx: int;
begin
  Result:=Dest;

  if Assigned(Dest) and (MaxLen > 0) then begin

    si:=Source; di:=Dest; cx:=0;

    if Assigned(si) then
    while (MaxLen > 0) and (si^ <> #0) do begin
      di^:=si^; Inc(si); Inc(di);
      Inc(cx); Dec(MaxLen);
    end;

    di^:=#0; if cx > 0 then
    CharUpperBuffW(Dest,cx);
  end;
end;

function StrPCopyW(Dest: PWideChar; const Source: WideString; MaxLen: int): PWideChar;
var
  len: int; si: PWideChar;
begin
  Result:=nil;
  if MaxLen = 0 then MaxLen:=255;
  len:=Length(Source);
  if len > MaxLen then len:=MaxLen;

  if len > 0 then begin
    si:=@Source[1];
    Move(si^,Dest^,len+len);
    Result:=Dest
  end;

  Dest[len]:=#0
end;

function StrLatinW(Dest: PWideChar; const Source: String): PWideChar;
var
  i,len: int; di: PWideChar;
begin
  Result:=nil;

  len:=Length(Source);
  if len > 0 then begin

    di:=Dest;
    for i:=1 to len do begin
      di[0]:=WideChar( byte(Source[i]) );
      Inc(di)
    end;

    Result:=Dest
  end;

  Dest[len]:=#0
end;

function StrCompW(S1,S2: PWideChar): int;
var
  i,c1,c2: int;
begin
  Result:=0;
  for i:=1 to 256 do begin
    c1:=int(S1[0]);
    c2:=int(S2[0]);

    if c1 = 0 then begin
      if c2 <> 0 then Result:=-1;
      Break
    end else
    if c2 = 0 then begin
      Result:=+1; Break
    end else
    if c1 < c2 then begin
      Result:=-1; Break
    end else
    if c1 > c2 then begin
      Result:=+1; Break
    end;

    Inc(S1); Inc(S2)
  end
end;

function StrLenW(Str: PWideChar): int;
var
  i: int;
begin
  Result:=0;
  for i:=1 to 1024*8 do begin
    if Str^ = #0 then Break;
    Inc(Str); Inc(Result)
  end
end;

function StrPasWW(Str: PWideChar): WideString;
begin
  Result:=Str
end;

function StrLPasWW(Str: PWideChar; len: int): WideString;
var
  i: int; ch: WideChar; w: WideString;
begin
  SetLength(w,len); w:='';
  for i:=0 to len-1 do begin
    ch:=Str[i];
    if ch = #0 then Break;
    w:=w + ch;
  end;

  Result:=w;
end;

function StrPasAW(Str: PAnsiChar; len: int): WideString;
var
  w: WideString;
begin
  if len = 0 then
  len:=StrLen(Str);

  w:=''; if len > 0 then begin
    SetLength(w,len); w:='';
    while len > 0 do begin
      w:=w+Str^; Dec(len); Inc(Str)
    end
  end;

  Result:=w
end;

function StrPasSW(const Str: String): WideString;
var
  i,len: int; w: WideString;
begin
  len:=Length(Str);
  SetLength(w,len); w:='';

  for i:=1 to len do
  w:=w + WideChar( byte(Str[i]) );

  Result:=w
end;

function StrCatWC(Dest,Str: PWideChar; MaxLen: int): PWideChar;
var
  di,si: PWideChar; len: int;
begin
  Result:=Dest;

  len:=0; di:=Dest;
  while di[0] <> #0 do begin
    Inc(di); Inc(len);
    if len >= MaxLen then Break
  end;

  si:=Str;
  while si[0] <> #0 do begin
    if len < MaxLen then begin
      di[0]:=si[0]; Inc(di); Inc(len);
    end;

    Inc(si)
  end;

  Inc(len); di[len]:=#0
end;

function PasCatWC(Dest,Str: PWideChar; MaxLen: int): PWideChar;
var
  di,si: PWideChar; len: int;
begin
  Result:=Dest;

  di:=Dest;
  len:=Ord(di[0]); Inc(di);
  di:=@di[len];

  si:=Str;
  while si[0] <> #0 do begin
    if len < MaxLen then begin
      di[0]:=si[0]; Inc(di); Inc(len);
    end;

    Inc(si)
  end;

  Dest[0]:=WideChar(len)
end;

function PasCatWS(Dest: PWideChar;
                  const Str: WideString;
                  MaxLen: int): PWideChar;
var
  di: PWideChar; i,len: int;
begin
  Result:=Dest;

  di:=Dest;
  len:=Ord(di[0]); Inc(di);
  di:=@di[len];

  for i:=1 to Length(Str) do
  if len < MaxLen then begin
    di[0]:=Str[i]; Inc(di); Inc(len);
  end;

  Dest[0]:=WideChar(len)
end;

function StrToMemoW(Str: PWideChar; Memo: TStrings): int;
var
  k: int; p: PWideChar; ch: WideChar; s: WideString;
begin
  Memo.Clear;

  k:=0; p:=Str; s:='';
  while p[0] <> #0 do begin

    ch:=p[0]; Inc(p); Inc(k);
    if (ch = #10) or (ch = #13) then begin

      Memo.Add(s); s:='';

      ch:=p[0]; Inc(p); Inc(k);
      if (ch = #10) or (ch = #13) then begin
        ch:=p[0]; Inc(p); Inc(k);
      end
    end;

    if ch = #0 then Break;
    s:=s+ch;

    if k = 10000 then Break;
  end;

  if Length(s) > 0 then
  Memo.Add(s);

  Result:=Memo.Count
end;

function WideStringToString(const Src: WideString;
                            out Dest: String): boolean;
var
  i,n,rc: int; s: String; ch: Char; c1,c2: WideChar;
begin
  Result:=false; Dest:='';

  n:=Length(Src);
  if n < 256 then begin

    s:=''; Result:=true;
    for i:=1 to n do begin
      c1:=Src[i]; Result:=false;

      if WideCharToMultiByte(0, 0, @c1,1, @ch,1, nil,nil) = 1 then
      if MultiByteToWideChar(0,0, @ch,1, @c2,1) = 1 then
      Result:=c1 = c2;

      if not Result then Break;
      s:=s+ch
    end;

    Dest:=s
  end
end;

function TextToStr(const w: WideString): WideString;
var
  i,p: int; s,t: WideString;
begin
  s:=''; t:=w;
  for i:=1 to 256 do begin
    p:=Pos(#13#10,t);
    if p = 0 then Break;
    if p > 1 then
    s:=s+Copy(t,1,p-1);
    s:=s+'^';

    Delete(t,1,p+1);
  end;

  s:=s+t; Result:=s
end;

function VerifyEolW(var w: WideString): bool;
var
  i: int; t: WideString; ch: WideChar; waitN: bool;
begin
  Result:=false;

  t:=''; waitN:=false;
  for i:=1 to Length(w) do begin
    ch:=w[i];
    if waitN and (ch <> #10) then
    t:=t + #10;

    waitN:=ch = #13;
    t:=t + ch
  end;

  if waitN then t:=t + #10;

  if Length(t) > Length(w) then begin
    w:=t; Result:=true
  end
end;

function StrReplaceW(const s: WideString; ch1,ch2: WideChar): WideString;
var
  i: int; t: WideString;
begin
  t:=s;
  for i:=1 to Length(t) do
  if t[i] = ch1 then t[i]:=ch2;
  Result:=t
end;

function StrTruncateW(const s: WideString; ch: WideChar): WideString;
var
  i: int; t: WideString;
begin
  t:=s;
  for i:=1 to Length(t) do
  if t[i] = ch then begin
    SetLength(t,i-1); Break
  end;

  Result:=t
end;

function lstrW(const s: WideString): WideString;
var
  i,k,l: int; t: WideString;
begin
  t:=s; k:=0;

  l:=length(t);
  for i:=1 to l do begin
    if not (t[i] in [WideChar(' '),
                     WideChar(10),
                     WideChar(13)]) then Break;
    Inc(k)
  end;

  if k > 0 then
  if k = l then t:='' else
  Delete(t,1,k);

  Result:=t;
end;

function quoteStrW(const s: WideString): WideString;
begin
  Result:='"' + s + '"'
end;

function json_close_quotes(Str: WideString): WideString;
var
  i,len: int; s: WideString; ch: WideChar;
begin
  s:='';

  i:=1; len:=Length(Str);
  while i <= len do begin

    ch:=Str[i]; Inc(i);

    if ch = '"' then
      s:=s+'\'+ch
    else
    if ch = '\' then
      s:=s+'\'+ch
    else
    if ch = #10 then
      s:=s+'\n'
    else
    if ch = #9 then
      s:=s+'\t'
     else
    if ch = #13 then
    else s:=s+ch
  end;

  Result:=s
end;

function jsonStrW(const s: WideString): WideString;
begin
  Result:='"'+json_close_quotes(s)+'"'
end;

procedure simplifiedW(var s: WideString);
var
  i,k,l: int;
begin
  k:=0; l:=length(s);
  for i:=1 to l do begin
    if not (s[i] in [WideChar(' '),
                     WideChar(10),
                     WideChar(13)]) then Break;
    Inc(k)
  end;

  if k > 0 then
  if k = l then s:='' else
  Delete(s,1,k);

  l:=length(s);
  while l > 0 do begin
    if not (s[l] in [WideChar(' '),
                     WideChar(10),
                     WideChar(13)]) then Break;
    Dec(l)
  end;

  SetLength(s,l)
end;

procedure trW(s: PWideChar; tr: PWords);
var
  i,ch: int;
begin
  for i:=1 to 64000 do begin
    ch:=word(s^);
    if ch = 0 then Break;
    ch:=tr[ch];
    if ch > 0 then
    s^:=WideChar(ch);
    Inc(s)
  end
end;

function splitW(Tokens: TStrings; const Str: WideString; delimiter: WideChar): int;
var
  i: int; t: WideString; ch: WideChar;
begin
  Result:=0;

  t:='';
  for i:=1 to Length(Str) do begin
    ch:=Str[i];
    if ch <> delimiter then
      t:=t + ch
    else begin
      Tokens.Add(t); t:=''
    end
  end;

  if Length(t) > 0 then Tokens.Add(t)
end;

end.
