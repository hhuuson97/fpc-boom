unit Docfile;

interface

uses Classes,sysutils,FPimage,FPImgCanv,FPReadPNG,Init;

Var Reader:TFPReaderPNG;

Procedure Doc(Var a:HD;Var nv:Thuoctinh);

Procedure Loadfile(Var mapw,maph:Byte;Var m,n,o:nen;Var pos:telepos;Var d:Longint;Var x:Thuoctinh2;stage:Longint);

Procedure Dong(Var a:HD);

Procedure Save(a:Thuoctinh);

Procedure Savelog(x:Longint);

implementation

Procedure Doc(Var a:HD;Var nv:Thuoctinh);
Var k,i,j:Byte;
    ch:String;
Begin
  For k:=1 to maximg do
  Begin
    a[k]:=TFPMemoryImage.Create(0,0);
    Reader:=TFPReaderPNG.create;
    str(k,ch);
    a[k].LoadFromFile('PNG\'+ch+'.png',Reader);
    Reader.Free;
  End;
  Assign(Input,'dl.bin');
  Reset(Input);
  Readln(nv.nv);
  Readln(nv.mal);
  Readln(nv.lc);
  Readln(nv.ls);
  Readln(nv.lt);
  Readln(nv.lg);
  Readln(nv.d);
  Readln(nv.ele);
  For i:=0 to 7 do
    Readln(nv.skl[i]);
  Close(Input);
End;

Procedure Loadfile(Var mapw,maph:Byte;Var m,n,o:nen;Var pos:telepos;Var d:Longint;Var x:Thuoctinh2;stage:Longint);
Var i,j,k,t:Integer;
    st:String;
Begin
  str(stage,st);
  Assign(Input,'Stage '+st+'.txt');
  Reset(Input);
  Readln(maph,mapw);
  For j:=1 to maph do
    Begin
      For i:=1 to mapw do
        Read(m[i,j]);
      Readln;
    End;
  For j:=1 to maph do
    Begin
      For i:=1 to mapw do
        Read(n[i,j]);
      Readln;
    End;
  For j:=1 to maph do
    Begin
      For i:=1 to mapw do
        Read(o[i,j]);
      Readln;
    End;
  Readln(k);
  For i:=1 to k do
    Begin
      Read(t);
      Readln(pos[t].x,pos[t].y);
    End;
  Readln(d);
  For i:=1 to d do
    Begin
      Readln(x[i].x,x[i].y,x[i].mal,x[i].lc,x[i].ls,x[i].lt,x[i].lg,x[i].p,x[i].s);
      x[i].li:=x[i].mal;
      x[i].nv:=1;
      x[i].tt:=1;
    End;
  Close(Input);
End;

Procedure Dong(Var a:HD);
Var k:Byte;
Begin
  For k:=1 to maximg do a[k].free;
End;

Procedure Save(a:Thuoctinh);
Var i:Longint;
Begin
  Assign(Output,'dl.bin');
  Rewrite(Output);
  Writeln(a.nv);
  Writeln(a.mal);
  Writeln(a.lc);
  Writeln(a.ls);
  Writeln(a.lt);
  Writeln(a.lg);
  Writeln(a.d);
  Writeln(a.ele);
  For i:=0 to 7 do
    Writeln(a.skl[i]);
  Close(Output);
End;

Procedure Savelog(x:Longint);
Var f:text;
Begin
  Assign(f,'log.txt');
  Append(f);
  Writeln(f,x);
  Close(f);
End;

end.
