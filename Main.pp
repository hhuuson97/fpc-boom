Program Boom;
{$mode objfpc}{$H+}
Uses ptc,Classes,sysutils,FPimage,FPImgCanv,FPReadPNG,crt,
     docfile,init,draw,math;
Var a:HD;
    nv:Thuoctinh;
    wai:Thuoctinh2;
    mousex,mousey,time,Stage,slw,scrx,scry,teleport,lenQE:Integer;
    console:IPTCConsole;
    surface:IPTCSurface;
    event:IPTCEvent;
    pixels:PUint32;
    color:Uint32;
    bt,maph,mapw:Byte;
    ex,enter,button,done,pc:Boolean;
    ms,vt,bo:nen;
    tbt,act:Array[1..4] of Boolean;
    dd:Array[1..maxw,1..maxh] of Boolean;
    rw:Array[1..maxw,1..maxh] of Byte;
    teletr:Telepos;
    queueEff:arrhpeff;
    skill:Array[0..7] of Skillinfo;
Procedure Wait;
Begin
  Repeat
    console.NextEvent(event,True,PTCAnyEvent);
  if Supports(event,IPTCKeyEvent) and (event as IPTCKeyEvent).press then
    begin
      case (event as IPTCKeyEvent).Code of
        PTCKEY_ESCAPE:Done:=True;
      End;
    End;
  Until Supports(event,IPTCKeyEvent) and (event as IPTCKeyEvent).press;
End;
Procedure CheckEvent;
Var i:Byte;
Begin
  console.NextEvent(event,False,PTCAnyEvent);
  if Supports(event, IPTCMouseEvent) then
    begin
      repeat
        mouseX:=(event as IPTCMouseEvent).X;
        mouseY:=(event as IPTCMouseEvent).Y;
        button:=PTCMouseButton1 in (event as IPTCMouseEvent).ButtonState;
      until not console.NextEvent(event,False,[PTCMouseEvent]);
    end;
  ex:=False;
  enter:=False;
  bt:=0;
  pc:=False;
  if Supports(event,IPTCKeyEvent) and (event as IPTCKeyEvent).release then
    begin
      case (event as IPTCKeyEvent).Code of
        PTCKEY_DOWN:tbt[1]:=False;
        PTCKEY_RIGHT:tbt[2]:=False;
        PTCKEY_UP:tbt[3]:=False;
        PTCKEY_LEFT:tbt[4]:=False;
        PTCKEY_Q:act[1]:=False;
        PTCKEY_W:act[2]:=False;
        PTCKEY_E:act[3]:=False;
        PTCKEY_R:act[4]:=False;
      end;
    end;
  if Supports(event,IPTCKeyEvent) and (event as IPTCKeyEvent).press then
    begin
      case (event as IPTCKeyEvent).Code of
        PTCKEY_DOWN:tbt[1]:=True;
        PTCKEY_RIGHT:tbt[2]:=True;
        PTCKEY_UP:tbt[3]:=True;
        PTCKEY_LEFT:tbt[4]:=True;
        PTCKEY_A:enter:=True;
        PTCKEY_Q:act[1]:=True;
        PTCKEY_W:act[2]:=True;
        PTCKEY_E:act[3]:=True;
        PTCKEY_R:act[4]:=True;
        PTCKEY_SPACE:ex:=True;
        PTCKEY_ESCAPE:Done:=True;
        PTCKEY_F1:pc:=True;
      end;
    end;
  For i:=1 to 4 do
    If tbt[i] then bt:=i;
End;
Procedure Attack(Var nvt1:Thuoctinh;Var nvt2:Thuoctinh;isgamer:boolean);
Var t,p,q:Integer;
Begin
  t:=nvt1.lc div 2+Random(nvt1.lc div 2)+nvt1.eff[4].val-nvt2.lt div 2-Random(nvt2.lt div 2)-nvt2.eff[8].val;
  t:=Round(t*(100-nvt2.eff[3].val)/100);
  If nvt1.li>0 then
    Begin
      q:=nvt2.eff[2].val;
      If q>0 then
        Begin
          inc(lenQE);
          queueEff[lenQE].x:=nvt1.x+10;
          queueEff[lenQE].y:=nvt1.y-10;
          queueEff[lenQE].cd:=50;
          queueEff[lenQE].val:=-q;
          queueEff[lenQE].color:=1;
        End;
      p:=Min(nvt1.eff[9].val,q);
      q:=q-p;
      nvt1.eff[9].val:=nvt1.eff[9].val-p;
      If nvt1.eff[9].val=0 then
        nvt1.eff[9].time:=0;
      nvt1.li:=nvt1.li-q;
      If nvt1.li<=0 then
        rw[nvt1.x div 20+1,nvt1.y div 20+1]:=1;
    End;
  If t<=0 then t:=1;
  inc(lenQE);
  queueEff[lenQE].x:=nvt2.x+10;
  queueEff[lenQE].y:=nvt2.y-10;
  queueEff[lenQE].cd:=50;
  queueEff[lenQE].val:=-t;
  If (isgamer) then
    queueEff[lenQE].color:=2
  else
    queueEff[lenQE].color:=1;
  If nvt2.li>0 then
    Begin
      p:=Min(nvt2.eff[9].val,t);
      t:=t-p;
      nvt2.eff[9].val:=nvt2.eff[9].val-p;
      If nvt2.eff[9].val=0 then
        nvt2.eff[9].time:=0;
      nvt2.li:=nvt2.li-t;
      If (not isgamer) and (nvt2.li<=0) then
        rw[nvt2.x div 20+1,nvt2.y div 20+1]:=1;
    End;
  If nv.li<=0 then
    Begin
      stage:=1;
      nv.x:=30;
      nv.y:=30;
      teleport:=200;
    End;
End;
Procedure Attack2(Var nvt1:Thuoctinh;Var nvt2:Thuoctinh;val:Longint;isgamer:boolean);
Var t,p,q:Integer;
Begin
  t:=round(val*0.9)+Random(round(val*0.1))+nvt1.eff[4].val-nvt2.lg-nvt2.eff[8].val;
  t:=Round(t*(100-nvt2.eff[3].val)/100);
  If nvt1.li>0 then
    Begin
      q:=nvt2.eff[2].val;
      p:=Min(nvt1.eff[8].val,q);
      q:=q-p;
      nvt1.eff[8].val:=nvt1.eff[8].val-p;
      If nvt1.eff[8].val=0 then
        nvt1.eff[8].time:=0;
      nvt1.li:=nvt1.li-q;
    End;
  If t<=0 then t:=1;
  inc(lenQE);
  queueEff[lenQE].x:=nvt2.x+10;
  queueEff[lenQE].y:=nvt2.y-10;
  queueEff[lenQE].cd:=50;
  queueEff[lenQE].val:=-t;
  If (isgamer) then
    queueEff[lenQE].color:=2
  else
    queueEff[lenQE].color:=1;
  If nvt2.li>0 then
    Begin
      p:=Min(nvt2.eff[8].val,t);
      t:=t-p;
      nvt2.eff[8].val:=nvt2.eff[8].val-p;
      If nvt2.eff[8].val=0 then
        nvt2.eff[8].time:=0;
      nvt2.li:=nvt2.li-t;
      If (not isgamer) and (nvt2.li<=0) then
        rw[nvt2.x div 20+1,nvt2.y div 20+1]:=1;
    End;
  If nv.li<=0 then
    Begin
      stage:=1;
      nv.x:=30;
      nv.y:=30;
      teleport:=200;
    End;
End;
Function Ability(nv:Thuoctinh;i:Byte):Integer;
Begin
  Case i of
    1:Exit(nv.mal);
    2:Exit(nv.lc);
    3:Exit(nv.ls);
    4:Exit(nv.lt);
    5:Exit(nv.lg);
  End;
End;
Procedure Table(t,j:Byte);
Var i:Integer;
    x,y,z:Byte;
Begin
  x:=1;y:=1;z:=1;
  Case j of
    4:x:=2;
    5:y:=2;
    6:z:=2;
  End;
  Draw1(46,(time div 10) mod 3+1,1,3,1,t*160+10,120,1,a,surface,pixels);
  Draw1(47,(time div 10) mod 3+1,1,3,1,t*160+10,145,1,a,surface,pixels);
  Draw1(48,(time div 10) mod 3+1,1,3,1,t*160+10,170,1,a,surface,pixels);
  For i:=1 to 10 do
    Begin
      If i<=x then hcn(t*160+32+i*10,127,t*160+38+i*10,133,1,surface,pixels) else
        If i<=nangluc1[j] then hcn(t*160+32+i*10,127,t*160+38+i*10,133,2,surface,pixels);
      If i<=y then hcn(t*160+32+i*10,152,t*160+38+i*10,158,1,surface,pixels) else
        If i<=nangluc2[j] then hcn(t*160+32+i*10,152,t*160+38+i*10,158,2,surface,pixels);
      If i<=z then hcn(t*160+32+i*10,177,t*160+38+i*10,183,1,surface,pixels) else
        If i<=nangluc3[j] then hcn(t*160+32+i*10,177,t*160+38+i*10,183,2,surface,pixels);
    End;
End;
Procedure Minimap;
Var i,j:Byte;
Begin
  For i:=1 to mapw do
    For j:=1 to maph do
      Draw2(0,vt[i,j],i,j,time,2,160,10,a,surface,pixels);
  For i:=1 to mapw do
    For j:=1 to maph do
      If ms[i,j]>0 then
        Draw2(ms[i,j],bo[i,j],i,j,time,2,160,10,a,surface,pixels);
End;
Function Kt(i,j:Integer;isgamer:Boolean):Boolean;
Begin
  If (i<1) or (i>mapw) then Exit(False);
  If (j<1) or (j>maph) then Exit(False);
  If (ms[i,j]=0) and (bo[i,j]>0) and (bo[i,j]<=500) then Exit(False);
  Exit((ms[i,j]<2) or ((ms[i,j]=5) and isgamer));
End;
Procedure Qmove(Var nv:Thuoctinh;isgamer:Boolean);
Var tmx,tmy:Integer;
Begin
  tmx:=(nv.x-1) div 20+1;
  tmy:=(nv.y-1) div 20+1;
  If (nv.x>tmx*20-10) and (not Kt(tmx+1,tmy,isgamer)) then
    nv.x:=tmx*20-10;
  If (nv.x<tmx*20-10) and (not Kt(tmx-1,tmy,isgamer)) then
    nv.x:=tmx*20-10;
  If (nv.y>tmy*20-10) and (not Kt(tmx,tmy+1,isgamer)) then
    nv.y:=tmy*20-10;
  If (nv.y<tmy*20-10) and (not Kt(tmx,tmy-1,isgamer)) then
    nv.y:=tmy*20-10;
End;
Procedure Control(Var nv:Thuoctinh;bt:Byte;ex:boolean;isgamer:Boolean);
Var tmx,tmy,i,p,t:Integer;
Begin
  p:=time mod 4;
  t:=(nv.s+nv.Eff[5].val+p+2) div 4;
  If (0<bt) and  (bt<5) then
    nv.ha:=nv.ha+t;
  If nv.ha>200 then nv.ha:=nv.ha-200;
  Case bt of
    1:Begin
      If nv.Eff[6].time=0 then
        nv.y:=nv.y+t;
      Qmove(nv,isgamer);
    End;
    2:Begin
      If nv.Eff[6].time=0 then
        nv.x:=nv.x+t;
      Qmove(nv,isgamer);
    End;
    3:Begin
      If nv.Eff[6].time=0 then
        nv.y:=nv.y-t;
      Qmove(nv,isgamer);
    End;
    4:Begin
      If nv.Eff[6].time=0 then
        nv.x:=nv.x-t;
      Qmove(nv,isgamer);
    End;
  End;
  If nv.Eff[1].time>0 then
    Begin
      nv.li:=nv.li+nv.Eff[1].val;
      If nv.li>nv.mal then nv.li:=nv.mal;
      If nv.li<0 then nv.li:=0;
      inc(lenQE);
      queueEff[lenQE].x:=nv.x+10;
      queueEff[lenQE].y:=nv.y-10;
      queueEff[lenQE].cd:=50;
      queueEff[lenQE].val:=nv.Eff[1].val;
      If (isgamer) then
        queueEff[lenQE].color:=2
      else
        queueEff[lenQE].color:=1;
    End;
  For i:=1 to 9 do
    If nv.Eff[i].time>0 then
      dec(nv.Eff[i].time)
    Else
      nv.Eff[i].val:=0;
  tmx:=(nv.x-1) div 20+1;
  tmy:=(nv.y-1) div 20+1;
  If ex then
    If (nv.bo>0) and Kt(tmx,tmy,false) then
      Begin
        bo[tmx,tmy]:=1;
        Dec(nv.bo);
      End;
End;
Function Seach(x1,y1,k,x2,y2:Integer):Integer;
Var i:Integer;
Begin
  If x1=x2 then
    Begin
      For i:=1 to k do
        If Kt(x1,y1+i,false) then
          Begin
            If y1+i=y2 then Exit(1);
          End
        Else Break;
      For i:=1 to k do
        If Kt(x1,y1-i,false) then
          Begin
            If y1-i=y2 then Exit(3);
          End
        Else Break;
    End;
  If y1=y2 then
    Begin
      For i:=1 to k do
        If Kt(x1+i,y1,false) then
          Begin
            If x1+i=x2 then Exit(2);
          End
        Else Break;
      For i:=1 to k do
        If Kt(x1-i,y1,false) then
          Begin
            If x1-i=x2 then Exit(4);
          End
        Else Break;
    End;
  Exit(0);
End;
Procedure Automove;
Var i,j,tmx,tmy,tx,ty,bt,t,num,k:Integer;
Begin
  num:=0;
  For i:=1 to mapw do
    For j:=1 to maph do
      If (rw[i,j]=1) and (ms[i,j]=0) and ((bo[i,j]>250) or (bo[i,j]=0)) then
        Begin
          If Random(2)>0 then
            Begin
              ms[i,j]:=1;
              bo[i,j]:=Random(5) mod 3+1;
            End;
          rw[i,j]:=0;
        End;
  For i:=1 to slw do
    If wai[i].li>0 then
      Begin
        inc(num);
        If wai[i].bo>0 then wai[i].bo:=wai[i].bo-1;
        tmx:=(wai[i].x-1) div 20+1;
        tmy:=(wai[i].y-1) div 20+1;
        tx:=(nv.x-1) div 20+1;
        ty:=(nv.y-1) div 20+1;
        If (tmx=tx) and (tmy=ty) and (wai[i].bo=0) then
          Begin
            Attack(wai[i],nv,true);
            Attack2(wai[i],nv,wai[i].ls,true);
            wai[i].bo:=20;
          End;
        If (ms[tmx,tmy]=0) then
          If (bo[tmx,tmy]>500) and (bo[tmx,tmy]<750) and (bo[tmx,tmy] mod 50<10) then
            Attack(nv,wai[i],false);
        k:=Seach(tmx,tmy,wai[i].p,tx,ty);
        If k>0 then wai[i].tt:=k;
        If Kt(tmx,tmy+1,false) or Kt(tmx,tmy-1,false) or Kt(tmx+1,tmy,false) or Kt(tmx-1,tmy,false) then
          Case wai[i].tt of
            1:Begin
              If (wai[i].y>=tmy*20-10) and (not Kt(tmx,tmy+1,false)) then
                wai[i].ha:=1;
            End;
            2:Begin
              If (wai[i].x>=tmx*20-10) and (not Kt(tmx+1,tmy,false)) then
                wai[i].ha:=1;
            End;
            3:Begin
              If (wai[i].y<=tmy*20-10) and (not Kt(tmx,tmy-1,false)) then
                wai[i].ha:=1;
            End;
            4:Begin
              If (wai[i].x<=tmx*20-10) and (not Kt(tmx-1,tmy,false)) then
                wai[i].ha:=1;
            End;
          End;
        If wai[i].ha=1 then
          Begin
            Case Random(3) of
              0:wai[i].tt:=(wai[i].tt+2) mod 4+1;
              2:wai[i].tt:=wai[i].tt mod 4+1;
            End;
          End;
        Control(wai[i],wai[i].tt,false,false);
      End;
End;
Procedure Draw3(k,x,y:Integer);
Var i,j,wi,he:Integer;
    t,r,g,b:Uint32;
    c:TFPColor;
Begin
  wi:=surface.width;
  he:=surface.height;
  For i:=x to x+a[k].width-1 do
    If (i<wi) and (i>=0) then
      For j:=y to y+a[k].height-1 do
        If (j<he) and (j>=0) then
          Begin
            c:=a[k].colors[x+a[k].width-i-1,j-y];
            r:=c.red div 256;
            g:=c.green div 256;
            b:=c.blue div 256;
            t:=(r shl 16) or (g shl 8) or b;
            If t>0 then pixels[i+j*wi]:=t;
          End;
End;
Procedure Drawnv(nv:Thuoctinh);
Var i:Real;
    j:Integer;
    hp:Longint;
Begin
  Case nv.tt of
    1:Draw1(nv.nv*6-5+(nv.ha div 5) mod 2,1,1,1,1,nv.x-16-scrx,nv.y-25-scry,1,a,surface,pixels);
    2:Draw1(nv.nv*6-3+(nv.ha div 5) mod 2,1,1,1,1,nv.x-16-scrx,nv.y-25-scry,1,a,surface,pixels);
    3:Draw1(nv.nv*6-1+(nv.ha div 5) mod 2,1,1,1,1,nv.x-16-scrx,nv.y-25-scry,1,a,surface,pixels);
    4:Draw3(nv.nv*6-3+(nv.ha div 5) mod 2,nv.x-16-scrx,nv.y-25-scry);
  End;
  i:=0;
  j:=0;
  hp:=nv.mal+nv.eff[9].val;
  Repeat
    i:=i+hp/32;
    j:=j+1;
    If (i<=nv.li) or (nv.eff[9].val=0) then
      Draw1(55,j,1,32,1,nv.x-16+j-scrx,nv.y-25-scry,1,a,surface,pixels)
    Else
      Draw1(56,j,1,32,1,nv.x-16+j-scrx,nv.y-25-scry,1,a,surface,pixels);
  Until i>=nv.li+nv.eff[9].val;
End;
//Ve bang ki nang
Procedure SkillWindow;
Var i:Byte;
Begin
  For i:=0 to 15 do
    Draw1(64,1,1,1,1,i*20,180,1,a,surface,pixels);
  Draw1(48,1,1,3,1,302,185,2,a,surface,pixels);
  DrawNum(nv.s,302,186,1,a,surface,pixels);
  Draw1(47,1,1,3,1,272,185,2,a,surface,pixels);
  DrawNum(nv.p,272,186,1,a,surface,pixels);
  Draw1(46,1,1,3,1,242,185,2,a,surface,pixels);
  DrawNum(nv.m,242,186,1,a,surface,pixels);
  Draw1(66,1,1,1,1,212,185,1,a,surface,pixels);
  DrawNum(nv.d,212,186,1,a,surface,pixels);
  For i:=0 to 7 do
    If nv.skl[i]=0 then
      Draw1(65,1,1,2,1,8+i*20,182,1,a,surface,pixels)
    Else
      Begin
        Draw1(62,nv.ele,i+1,5,8,8+i*20,182,1,a,surface,pixels);
        hcn(8+i*20,198-round(nv.sklcd[i]/skill[i].cd*17+0.49),23+i*20,198,5,surface,pixels);
        If (nv.sklcd[i]>0) then nv.sklcd[i]:=nv.sklcd[i]-1;
      End;
  Draw1(63,1,1,1,1,0,180,1,a,surface,pixels);
  For i:=1 to 9 do
    If nv.eff[i].time>0 then
      Draw1(60,i,1,9,1,(i-1)*20,160,1,a,surface,pixels);
End;
//man hinh tro choi
Procedure Maincreen;
Var i,j,k:Byte;
    mx,my:Integer;
Begin
  //tinh vi tri toa do 2 nhan vat
  mx:=nv.x div 20+1;
  my:=nv.y div 20+1;
  //Ve nen dat
  Background(vt,mapw,maph,scrx,scry,a,surface,pixels);
  //ve cac vat the
  For i:=1 to mapw do
    For j:=1 to maph do
      If ms[i,j]>0 then
        Draw2(ms[i,j],bo[i,j],i,j,time,1,-scrx,-scry,a,surface,pixels)
      Else
        Begin
          //vi tri boom no
          If (bo[i,j]>500) and (bo[i,j]<750) then
            Draw1(52,bo[i,j] mod 10,1,9,1,(i-1)*20-scrx,(j-1)*20-scry,1,a,surface,pixels);
          //vi tri boom chua no
          If ((bo[i,j]>0) and (bo[i,j]<250)) then
            Draw1(51,(bo[i,j] div 10) mod 5+1,1,5,1,(i-1)*20-scrx,(j-1)*20-scry,1,a,surface,pixels);
        End;
  //Ve quai vat
  For i:=1 to slw do
    If wai[i].li>0 then Drawnv(wai[i]);
  Drawnv(nv);
  //Ve hieu ung dich chuyen
  If ms[mx,my]=5 then
    Draw1(59,(teleport div 10) mod 4+1,1,4,1,nv.x-scrx-15,nv.y-scry-15,1,a,surface,pixels);
  //ve hieu ung mat mau
  For i:=1 to lenQE do
    Drawnum(queueEff[i].val,queueEff[i].x-scrx,queueEff[i].y-scry,queueEff[i].color,a,surface,pixels);
  //ve bang ky nang
  SkillWindow;
  //Ve con chuot
  Draw1(57,(time div 40) mod 2+1,1,2,1,mousex,mousey,1,a,surface,pixels);
End;
Procedure Option;
Var i,j,k,d:Longint;
    tm:Array[1..10] of Integer;
    p:Array[1..5] of Integer=(5,2,1,2,1);
    cd:Array[1..5] of Integer=(3,5,1,2,4);
    Change:Boolean;
    point,coin:String;
Begin
  i:=1;
  k:=0;
  change:=false;
  Fillchar(tm,sizeof(tm),0);
  Repeat
    pixels:=surface.lock;
    try
      Maincreen;
      hcn(0,0,319,199,5,surface,pixels);
      Draw1(67,1,1,1,1,10,10,1,a,surface,pixels);
      Delay(50);
      CheckEvent;
      If ex then
        Begin
          change:=not change;
          If change then k:=1
          Else
            Begin
              i:=1;
              k:=0;
            End;
        End;
      If (not change) then
        Begin
          If i>1 then If tbt[3] then i:=i-1;
          If i<5 then If tbt[1] then i:=i+1;
          If tbt[2] then
            If (nv.d>=(tm[i]+Ability(nv,i) div p[i]+1)) and (6000*p[i]>(tm[i]*p[i]+Ability(nv,i))) then
              Begin
                inc(tm[i]);
                nv.d:=nv.d-tm[i]-Ability(nv,i) div p[i];
              End;
          If tbt[4] then
            If tm[i]>0 then
              Begin
                dec(tm[i]);
                nv.d:=nv.d+1+tm[i]+Ability(nv,i) div p[i];
              End;
          hcn(60,i*25-6,130,i*25+6,2,surface,pixels);
        End
      Else
        Begin
          If tbt[1] then k:=k+2;
          If k>8 then k:=8;
          If tbt[3] then k:=k-2;
          If k<1 then k:=1;
          If tbt[2] and ((k=2) or (k=4) or (k=6)) then k:=k+1;
          If tbt[4] and ((k=3) or (k=5) or (k=7)) then k:=k-1;
          If (k=8) or (k=1) then d:=0
          Else If (k=2) or (k=4) or (k=6) then d:=-1
          Else d:=1;
          hcn(175+d*16,28+(k shr 1)*28,193+d*16-1,47+(k shr 1)*28-1,3,surface,pixels);
        End;
      For j:=1 to 5 do
        DrawNum(Ability(nv,j)+tm[j]*p[j],125,j*25-4,1,a,surface,pixels);
      DrawStr('HP',25,21,a,surface,pixels);
      DrawStr('VC',25,46,a,surface,pixels);
      DrawStr('TC',25,71,a,surface,pixels);
      DrawStr('VP',25,96,a,surface,pixels);
      DrawStr('TCP',25,121,a,surface,pixels);
      DrawNum(nv.d,125,146,1,a,surface,pixels);
      Draw1(66,1,1,1,1,125,145,1,a,surface,pixels);
      Draw1(71,1,1,1,1,160,30,1,a,surface,pixels);
      If nv.ele>0 then
        Begin
          Draw1(61,nv.ele,1,5,1,200,20,1,a,surface,pixels);
          For j:=1 to 8 do
            If (nv.skl[j-1]>0) then
            If (j=1) or (j=8) then
              Draw1(62,nv.ele,j,5,8,176,30+(j shr 1)*28,1,a,surface,pixels)
            Else
              If (j=2) or (j=4) or (j=6) then
                Draw1(62,nv.ele,j,5,8,160,30+(j shr 1)*28,1,a,surface,pixels)
              Else
                Draw1(62,nv.ele,j,5,8,192,30+(j shr 1)*28,1,a,surface,pixels);
          If k=0 then
            //Drawstr10(sklinfo[nv.ele,k],220,20,a,surface,pixels)
          Else
            Begin
              If (Ability(nv,cd[nv.ele])>=(needpoint[k-1]*p[cd[nv.ele]])) and (nv.d>=(needpoint[k-1]*k)) and (nv.skl[k-1]<10) and enter then
                Begin
                  nv.d:=nv.d-needpoint[k-1]*k;
                  nv.skl[k-1]:=nv.skl[k-1]+1;
                End;
              If nv.skl[k-1]>0 then
                //Drawstr10(sklinfo[nv.ele,k],220,20,a,surface,pixels)
              Else
                Begin
                  str(needpoint[k-1]*p[cd[nv.ele]],point);
                  str(needpoint[k-1]*k,coin);
                  Drawstr10('NEED '+point+' POINT AND '+coin+' COIN TO LEVER UP',220,20,a,surface,pixels);
                End;
            End;
        End
      Else
        Draw1(65,2,1,2,1,200,20,1,a,surface,pixels);
      //Ve con chuot
      Draw1(57,(time div 40) mod 2+1,1,2,1,mousex,mousey,1,a,surface,pixels);
    finally
      surface.unlock;
    end;
    surface.copy(console);
    console.update;
  Until pc or Done;
  nv.mal:=nv.mal+tm[1]*5;
  nv.li:=nv.li+tm[1]*5;
  nv.lc:=nv.lc+tm[2]*2;
  nv.ls:=nv.ls+tm[3];
  nv.lt:=nv.lt+tm[4]*2;
  nv.lg:=nv.lg+tm[5];
End;
Procedure GetSkillInfo;
Var i:Longint;
Begin
  Case nv.ele of
    1:Begin
      //skill 1 tang dame
      skill[0].r:=150;
      skill[0].val:=nv.ls*nv.skl[0] div 100;
      skill[0].cd:=500;
      For i:=1 to nv.skl[0] do
        skill[0].r:=skill[0].r+i div 2*6;
      //skill 2 tan cong phia truoc
      skill[1].r:=3+nv.skl[1] div 5;
      skill[1].val:=50+round(nv.ls*1.5);
      skill[1].cd:=500;
      For i:=1 to nv.skl[1] do
        skill[1].val:=skill[1].val+50;
      //skill 3 tang phong thu
      skill[2].r:=150;
      skill[2].val:=25+Round(nv.ls*0.7);
      skill[2].cd:=400;
      For i:=1 to nv.skl[2] do
        skill[2].val:=skill[2].val+5+Round(nv.ls*0.02);
      //skill 4 tang dame tan cong 4 huong
      skill[3].r:=2+nv.skl[3] div 5;
      skill[3].val:=round(nv.ls*1.4);
      skill[3].cd:=750;
      For i:=1 to nv.skl[3] do
        skill[3].val:=skill[3].val+round(nv.ls*0.02);
      //skill 5 tang ho thuan
      skill[4].r:=200+nv.skl[4] div 5*50;
      skill[4].val:=100+round(nv.ls*1.1);
      skill[4].cd:=400-nv.skl[4] div 5*50;
      For i:=1 to nv.skl[4] do
        skill[4].val:=skill[4].val+round(nv.ls*0.01)+15;
      //skill 6 tang cong phia truoc
      skill[5].r:=10+nv.skl[5] div 2;
      skill[5].val:=350+round(nv.ls*2.5);
      skill[5].cd:=1000;
      For i:=1 to nv.skl[5] do
        skill[5].val:=skill[5].val+round(nv.ls*0.05)+30;
      //skill 7 phan don
      skill[6].r:=200;
      skill[6].val:=100+round(nv.ls*0.7);
      skill[6].cd:=250;
      For i:=1 to nv.skl[6] do
        skill[6].val:=skill[6].val+round(nv.ls*0.03)+10;
      //skill cuoi tan cong phia truoc
      skill[7].r:=1+nv.skl[7] div 10;
      skill[7].val:=1000+round(nv.ls*5);
      skill[7].cd:=2500;
      For i:=1 to nv.skl[7] do
        skill[7].val:=skill[7].val+round(nv.ls*0.5)+200;
    End;
    2:Begin
      //skill 1 tang toc do di chuyen
      skill[0].r:=225;
      skill[0].val:=(nv.skl[i]+1) div 2;
      skill[0].cd:=750+nv.skl[0] div 2*10;
      For i:=1 to nv.skl[0] do
        skill[0].r:=skill[0].r+i*5;
      //skill 2 tang cong tu xa
      skill[1].r:=2+nv.skl[1] div 5;
      skill[1].val:=45+Round(nv.lg*1.2)+nv.s*10;
      skill[1].cd:=300;
      For i:=1 to nv.skl[1] do
        skill[1].val:=skill[1].val+25+nv.s*(i div 3);
      //skill 3 ho giap
      skill[2].r:=200+nv.skl[2] div 5*50;
      skill[2].val:=100+Round(nv.lg*(1.3+nv.skl[2]*0.02)+nv.s*(10+nv.skl[2] div 2));
      skill[2].cd:=450;
      //skill 4
      skill[3].r:=0; skill[3].val:=0; skill[3].cd:=1;
      //skill 5 hoi luong mau
      skill[4].r:=0; skill[4].val:=0; skill[4].cd:=1;
      skill[5].r:=0; skill[5].val:=0; skill[5].cd:=1;
      //skill 7 tang phong thu
      skill[6].r:=0; skill[6].val:=0; skill[6].cd:=1;
      skill[7].r:=0; skill[7].val:=0; skill[7].cd:=1;
    End;
    3:Begin
      //skill 1 hoi mau
      skill[0].r:=1+nv.skl[0] div 5;
      skill[0].val:=nv.mal div (100-nv.skl[0]*5);
      skill[0].cd:=1000+nv.skl[0]*250 div 5;
      //skill 2 gay choang phia truoc
      skill[1].r:=3+nv.skl[1] div 5;
      skill[1].val:=150+(nv.skl[1] div 5)*25;
      skill[1].cd:=1000;
      For i:=1 to nv.skl[1] do
        skill[1].cd:=skill[1].cd-20*(i div 3);
      //skill 3 hoi luong mau
      skill[2].r:=1+nv.skl[2] div 10;
      skill[2].val:=nv.mal div (20-nv.skl[2]);
      skill[2].cd:=300;
      //skill 4
      skill[3].r:=0; skill[3].val:=0; skill[3].cd:=1;
      //skill 5 phan dame
      skill[4].r:=0; skill[4].val:=0; skill[4].cd:=1;
      skill[5].r:=0; skill[5].val:=0; skill[5].cd:=1;
      //skill 7 tang phong thu
      skill[6].r:=0; skill[6].val:=0; skill[6].cd:=1;
      skill[7].r:=0; skill[7].val:=0; skill[7].cd:=1;
    End;
    4:Begin
      //skill 1 tang no
      skill[0].r:=300;
      skill[0].val:=1;
      skill[0].cd:=500;
      For i:=1 to nv.skl[0] do
        Begin
          skill[0].r:=skill[0].r+i div 2*4;
          skill[0].cd:=skill[0].cd-i div 2*4;
        End;
      //skill 2 tang cong phia truoc
      skill[1].r:=3+nv.skl[1] div 3;
      skill[1].val:=100+Round(nv.lc*0.7);
      skill[1].cd:=500;
      For i:=1 to nv.skl[1] do
        skill[1].val:=skill[1].val+25+Round(nv.lc*0.01);
      //skill 3 hoi mau
      skill[2].r:=1;
      skill[2].val:=nv.lc div (20-nv.skl[2]);
      skill[2].cd:=750;
      //skill 4
      skill[3].r:=0; skill[3].val:=0; skill[3].cd:=1;
      //skill 5 tang dame
      skill[4].r:=0; skill[4].val:=0; skill[4].cd:=1;
      skill[5].r:=0; skill[5].val:=0; skill[5].cd:=1;
      //skill 7 mien nhiem sat thuong vat ly
      skill[6].r:=0; skill[6].val:=0; skill[6].cd:=1;
      skill[7].r:=0; skill[7].val:=0; skill[7].cd:=1;
    End;
    5:Begin
      //skill 1 giam sat thuong %
      skill[0].r:=300;
      skill[0].val:=25;
      skill[0].cd:=1500;
      For i:=1 to nv.skl[0] do
        Begin
          skill[0].r:=skill[0].r+i div 2*6;
          skill[0].val:=skill[0].val+i div 2;
        End;
      //skill 2 tan cong hang ngang
      skill[1].r:=2+nv.skl[1] div 5;
      skill[1].val:=round(nv.lt*0.9);
      skill[1].cd:=900;
      For i:=1 to nv.skl[1] do
        skill[1].val:=skill[1].val+Round(nv.lc*0.02);
      //skill 3 tang dame
      skill[2].r:=1+nv.skl[2] div 5;
      skill[2].val:=50+Round(nv.lt*0.15);
      For i:=1 to nv.skl[2] do
        skill[2].val:=skill[2].val+Round(nv.lt*0.01)+5;
      skill[2].cd:=350;
      //skill 4
      skill[3].r:=0; skill[3].val:=0; skill[3].cd:=1;
      //skill 5 phan don
      skill[4].r:=0; skill[4].val:=0; skill[4].cd:=1;
      skill[5].r:=0; skill[5].val:=0; skill[5].cd:=1;
      //skill 7 tang ho thuan
      skill[6].r:=0; skill[6].val:=0; skill[6].cd:=1;
      skill[7].r:=0; skill[7].val:=0; skill[7].cd:=1;
    End;
  End;
End;
Procedure Start;
Var i,t:Byte;
    c:Boolean;
Begin
  GetSkillInfo;
  If nv.nv=0 then
    Begin
      t:=1;
      c:=False;
      pixels:=surface.lock;
      try
        Draw1(45,1,1,1,1,0,0,1,a,surface,pixels);
      finally
        surface.unlock;
      end;
      surface.copy(console);
      console.update;
      Wait;
      Repeat
        time:=time+1;
        If time>150 then time:=time-150;
        CheckEvent;
        If pc then Option;
        pixels:=surface.lock;
        try
          Draw1(45,1,1,1,1,0,0,1,a,surface,pixels);
          Delay(50);
          If not c then c:=ex;
          If c then Draw1(49,1,1,1,1,20,130,1,a,surface,pixels)
          Else
          Begin
            Case bt of
              1:If t<4 then t:=t+3;
              2:If t<6 then t:=t+1;
              3:If t>3 then t:=t-3;
              4:If t>1 then t:=t-1;
            End;
            If t<=3 then
              hcn(t*50-31,20,t*50+1,60,1,surface,pixels)
            Else
              hcn((t-3)*50-31,80,(t-3)*50+1,120,1,surface,pixels);
            For i:=1 to 3 do
              Draw1(i*6-4,1,1,1,1,i*50-31,20,1,a,surface,pixels);
            For i:=1 to 3 do
              Draw1((i+3)*6-4,1,1,1,1,i*50-31,80,1,a,surface,pixels);
            Table(0,t);
          End;
          //Ve con chuot
          Draw1(57,(time div 40) mod 2+1,1,2,1,mousex,mousey,1,a,surface,pixels);
        finally
          surface.unlock;
        end;
        surface.copy(console);
        console.update;
      Until c or Done;
      nv.nv:=t;
    End;
  If nv.li<=0 then
    Begin
      nv.m:=1;nv.p:=1;nv.s:=1;
      Case nv.nv of
        4:nv.m:=2;
        5:nv.p:=2;
        6:nv.s:=2;
      End;
      nv.ha:=0;
      nv.li:=nv.mal;
    End;
  teleport:=0;
  nv.bo:=nv.m;
  lenQE:=0;
End;
Procedure Explore(i,j:Byte);
Const tu:Array[1..4] of Integer=(-1,1,0,0);
      tv:Array[1..4] of Integer=(0,0,-1,1);
Var z,l,tx,ty,k:Integer;
Begin
  //lay do dai cua qua boom
  z:=nv.p;
  bo[i,j]:=501;
  //danh dau nhung o qua boom se no theo 4 huong
  For l:=1 to 4 do
    Begin
      tx:=i;ty:=j;
      For k:=1 to z do
        Begin
          tx:=tx+tu[l];
          ty:=ty+tv[l];
          //kiem tra vat can
          If Kt(tx,ty,false) then
            Begin
              bo[tx,ty]:=500+2*l+k div z;
              ms[tx,ty]:=0;
            End
          Else
            If (tx<=mapw) and (tx>0) and (ty<=maph) and (ty>0) then
              Begin
                If ms[tx,ty]=2 then dd[tx,ty]:=true;
                If (bo[tx,ty]>0) and (ms[tx,ty]=0) then
                  Begin
                    //tam no qua boom cham phai qua boom khac
                    inc(nv.bo);
                    Explore(tx,ty);
                  End;
                Break;
              End;
        End;
    End;
End;
Procedure Dropitem;
Var i,j:Integer;
Begin
  For i:=1 to mapw do
    For j:=1 to maph do
      If dd[i,j] then
        Begin
          If (ms[i,j]=0) and (bo[i,j]<=250) then
            inc(nv.bo);
          If Random(2)>0 then
            Begin
              ms[i,j]:=1;
              bo[i,j]:=(3+Random(9)) mod 6+1;
            End
          Else
            Begin
              ms[i,j]:=0;
              bo[i,j]:=0;
            End;
        End;
End;
Function Sign(x:Longint):Longint;
Begin
  If x>0 then Exit(1)
  Else If x<0 then Exit(-1)
  Else Exit(0);
End;
Procedure ActiveEffect(Var x:Effect;a:Skillinfo);
Begin
  If (Sign(x.val)*Sign(a.val)>=0) then
    Begin
      x.val:=x.val+a.val;
      x.time:=max(x.time,a.r);
    End
  Else
    Begin
      x.val:=a.val;
      x.time:=min(x.time,a.r);
    End;
End;
Procedure SkillAttack(a:Skillinfo;num:Integer);
Var i,j,k,tmx,tmy,tx,ty:Integer;
Begin
  Case nv.tt of
    2:Begin
      tx:=1;
      ty:=0;
    End;
    1:Begin
      ty:=1;
      tx:=0;
    End;
    4:Begin
      tx:=-1;
      ty:=0;
    End;
    3:Begin
      ty:=-1;
      tx:=0;
    End;
  End;
  Case num of
    1:Begin
      For i:=0 to a.r do
        Begin
          tmx:=nv.x div 20+tx*i+1;
          tmy:=nv.y div 20+ty*i+1;
          For k:=1 to slw do
            If (tmx=wai[k].x div 20+1) and (tmy=wai[k].y div 20+1) and (wai[k].li>0) then
              Attack2(nv,wai[k],a.val,false);
          If kt(tmx,tmy,false) then
            Begin
              ms[tmx,tmy]:=0;
              bo[tmx,tmy]:=711;
            End;
          If (0<tmx) and (tmx<=mapw) and (0<tmy) and (tmy<=maph) then
            If ms[tmx,tmy]=2 then
              dd[tmx,tmy]:=true;
        End;
    End;
    2:Begin
      For i:=-1 to 1 do
        For j:=-1 to 1 do
          Begin
            tmx:=nv.x div 20+tx*a.r+i+1;
            tmy:=nv.y div 20+ty*a.r+j+1;
            For k:=1 to slw do
              If (tmx=wai[k].x div 20+1) and (tmy=wai[k].y div 20+1) and (wai[k].li>0) then
                Attack2(nv,wai[k],a.val,false);
            If kt(tmx,tmy,false) then
              Begin
                ms[tmx,tmy]:=0;
                bo[tmx,tmy]:=711;
              End;
            If (0<tmx) and (tmx<=mapw) and (0<tmy) and (tmy<=maph) then
              If ms[tmx,tmy]=2 then
                dd[tmx,tmy]:=true;
          End;
    End;
    3:Begin
      For i:=0 to a.r do
        Begin
          tmx:=nv.x div 20+tx*i+1;
          tmy:=nv.y div 20+ty*i+1;
          For k:=1 to slw do
            If (tmx=wai[k].x div 20+1) and (tmy=wai[k].y div 20+1) and (wai[k].li>0) then
              wai[k].eff[6].time:=a.val;
          If kt(tmx,tmy,false) then
            Begin
              ms[tmx,tmy]:=0;
              bo[tmx,tmy]:=711;
            End;
          If (0<tmx) and (tmx<=mapw) and (0<tmy) and (tmy<=maph) then
            If ms[tmx,tmy]=2 then
              dd[tmx,tmy]:=true;
        End;
    End;
    4:Begin
      For i:=-a.r to a.r do
        Begin
          tmx:=nv.x div 20+ty*i+tx*a.r+1;
          tmy:=nv.y div 20+tx*i+ty*a.r+1;
          For k:=1 to slw do
            If (tmx=wai[k].x div 20+1) and (tmy=wai[k].y div 20+1) and (wai[k].li>0) then
              Attack2(nv,wai[k],a.val,false);
          If kt(tmx,tmy,false) then
            Begin
              ms[tmx,tmy]:=0;
              bo[tmx,tmy]:=711;
            End;
          If (0<tmx) and (tmx<=mapw) and (0<tmy) and (tmy<=maph) then
            If ms[tmx,tmy]=2 then
              dd[tmx,tmy]:=true;
        End;
    End;
    5:Begin
      j:=a.r;
      k:=nv.tt;
      For i:=0 to j do
        Begin
          a.r:=i;
          nv.tt:=1;
          SkillAttack(a,1);
          nv.tt:=2;
          SkillAttack(a,1);
          nv.tt:=3;
          SkillAttack(a,1);
          nv.tt:=4;
          SkillAttack(a,1);
        End;
      nv.tt:=k;
    End;
    6:Begin
      k:=nv.tt;
      nv.tt:=1;
      SkillAttack(a,1);
      nv.tt:=2;
      SkillAttack(a,1);
      nv.tt:=3;
      SkillAttack(a,1);
      nv.tt:=4;
      SkillAttack(a,1);
      nv.tt:=k;
    End;
  End;
End;
Procedure SkillUpdate;
Var i:Longint;
Begin
  If (nv.skl[0]>0) and (nv.sklcd[0]=0) then
    Begin
      nv.sklcd[0]:=skill[0].cd;
      Case nv.ele of
        1:ActiveEffect(nv.Eff[4],skill[0]);
        2:ActiveEffect(nv.Eff[5],skill[0]);
        3:ActiveEffect(nv.Eff[1],skill[0]);
        4:ActiveEffect(nv.Eff[7],skill[0]);
        5:ActiveEffect(nv.Eff[3],skill[0]);
      End;
    End;
  If (nv.skl[2]>0) and (nv.sklcd[2]=0) then
    Begin
      nv.sklcd[2]:=skill[2].cd;
      Case nv.ele of
        1:ActiveEffect(nv.Eff[8],skill[2]);
        2:ActiveEffect(nv.Eff[9],skill[2]);
        3:SkillAttack(skill[2],5);
        4:ActiveEffect(nv.Eff[1],skill[2]);
        5:SkillAttack(skill[2],5);
      End;
    End;
  If (nv.skl[4]>0) and (nv.sklcd[4]=0) then
    Begin
      nv.sklcd[4]:=skill[4].cd;
      Case nv.ele of
        1:ActiveEffect(nv.Eff[9],skill[4]);
        //2:ActiveEffect(nv.Eff[9],skill[2]);
        //3:SkillAttack(skill[2],5);
        //4:ActiveEffect(nv.Eff[1],skill[2]);
        //5:SkillAttack(skill[2],5);
      End;
    End;
  If (nv.skl[6]>0) and (nv.sklcd[6]=0) then
    Begin
      nv.sklcd[6]:=skill[6].cd;
      Case nv.ele of
        1:ActiveEffect(nv.Eff[2],skill[2]);
        //2:ActiveEffect(nv.Eff[9],skill[2]);
        //3:SkillAttack(skill[2],5);
        //4:ActiveEffect(nv.Eff[1],skill[2]);
        //5:SkillAttack(skill[2],5);
      End;
    End;
  If (nv.skl[1]>0) and (nv.sklcd[1]=0) and act[1] then
    Begin
      nv.sklcd[1]:=skill[1].cd;
      Case nv.ele of
        1:SkillAttack(skill[1],1);
        2:SkillAttack(skill[1],2);
        3:SkillAttack(skill[1],3);
        4:SkillAttack(skill[1],1);
        5:SkillAttack(skill[1],4);
      End;
    End;
  If (nv.skl[3]>0) and (nv.sklcd[3]=0) and act[2] then
    Begin
      nv.sklcd[3]:=skill[3].cd;
      Case nv.ele of
        1:Begin
          ActiveEffect(nv.Eff[4],skill[0]);
          SkillAttack(skill[3],6);
        End;
        //2:SkillAttack(skill[1],2);
        //3:SkillAttack(skill[1],3);
        //4:SkillAttack(skill[1],1);
        //5:SkillAttack(skill[1],4);
      End;
    End;
  If (nv.skl[5]>0) and (nv.sklcd[5]=0) and act[3] then
    Begin
      nv.sklcd[5]:=skill[5].cd;
      Case nv.ele of
        1:Begin
          ActiveEffect(nv.Eff[4],skill[0]);
          SkillAttack(skill[5],1);
        End;
        //2:SkillAttack(skill[1],2);
        //3:SkillAttack(skill[1],3);
        //4:SkillAttack(skill[1],1);
        //5:SkillAttack(skill[1],4);
      End;
    End;
  If (nv.skl[7]>0) and (nv.sklcd[7]=0) and act[4] then
    Begin
      nv.sklcd[7]:=skill[7].cd;
      Case nv.ele of
        1:SkillAttack(skill[7],1);
        //2:SkillAttack(skill[1],2);
        //3:SkillAttack(skill[1],3);
        //4:SkillAttack(skill[1],1);
        //5:SkillAttack(skill[1],4);
      End;
    End;
End;
Procedure XulySuKien;
Var mx,my,i,j,l:Longint;
    tmp:arrhpeff;
Begin
  Fillchar(dd,sizeof(dd),False);
  mx:=nv.x div 20+1;
  my:=nv.y div 20+1;
  For i:=1 to mapw do
    For j:=1 to maph do
      If ms[i,j]=0 then
        Begin
          //vi tri boom no
          If (bo[i,j]>500) and (bo[i,j]<750) then
            Begin
              If (mx=i) and (my=j) and (bo[i,j]<510) then
                Attack(nv,nv,true);
              bo[i,j]:=bo[i,j]+10;
              If bo[i,j]>750 then bo[i,j]:=0;
            End;
          //vi tri chua no
          If ((bo[i,j]>0) and (bo[i,j]<250)) then inc(bo[i,j]);
          If bo[i,j]=250 then
            Begin
              inc(nv.bo);
              Explore(i,j);
            End;
        End;
  //nhan vat o diem dich chuyen
  If ms[mx,my]=5 then
    Begin
      teleport:=teleport+1;
      If teleport>=200 then
        Begin
          stage:=(bo[mx,my]-1) div 4+1;
          nv.x:=teletr[stage].x;
          nv.y:=teletr[stage].y;
        End;
    End
  Else If teleport<200 then teleport:=0;
  l:=0;
  For i:=1 to lenQE do
    Begin
      queueEff[i].cd:=queueEff[i].cd-1;
      If queueEff[i].cd mod 5=0 then
        queueEff[i].y:=queueEff[i].y-1;
      If queueEff[i].cd>0 then
        Begin
          l:=l+1;
          tmp[l]:=queueEff[i];
        End;
    End;
  For i:=1 to l do
    queueEff[i]:=tmp[i];
  lenQE:=l;
  SkillUpdate;
  DropItem;
End;
Procedure Checkplayer(Var nv:Thuoctinh);
Var mx,my:Integer;
Begin
  mx:=nv.x div 20+1;
  my:=nv.y div 20+1;
  If ms[mx,my]=1 then
    Begin
      Case bo[mx,my] of
        1:nv.d:=nv.d+stage;
        2:nv.d:=nv.d+stage*2;
        3:nv.d:=nv.d+stage*4;
        4:If nv.m<nangluc1[nv.nv] then
            Begin
              inc(nv.m);
              inc(nv.bo);
            End;
        5:If nv.p<nangluc2[nv.nv] then inc(nv.p);
        6:If nv.s<nangluc3[nv.nv] then inc(nv.s);
      End;
      ms[mx,my]:=0;
      bo[mx,my]:=0;
    End;
End;
Procedure Screenmove;
Begin
  If (nv.x-80<scrx) then
    scrx:=max(0,nv.x-80);
  If (nv.y-80<scry) then
    scry:=max(0,nv.y-80);
  If (nv.x-260>scrx) then
    scrx:=min(mapw*20-320,nv.x-260);
  If (nv.y-100>scry) then
    scry:=min(maph*20-180,nv.y-100);
End;
Procedure Main;
Begin
  nv.tt:=1;
  Repeat
    time:=time+1;
    If time>1050 then time:=time-1050;
    CheckEvent;
    If pc then Option;
    pixels:=surface.lock;
    try
      hcn(0,0,319,199,4,surface,pixels);
      Checkplayer(nv);
      Control(nv,bt,ex,true);
      Automove;
      Screenmove;
      XulySukien;
      Maincreen;
      If bt>0 then nv.tt:=bt;
    finally
      surface.unlock;
    end;
    surface.copy(console);
    console.update;
  Until (teleport>=200) or Done;
End;
Procedure Endgame;
Begin
  Repeat
    Checkevent;
  Until ex or Done;
End;
Begin
  Randomize;
  Doc(a,nv);
  scrx:=0;
  scry:=0;
  time:=0;
  stage:=1;
  nv.x:=30;
  nv.y:=30;
  Done:=False;
  Fillchar(tbt,sizeof(tbt),False);
  Fillchar(act,sizeof(act),False);
  try
    try
      Initg(console,surface);
      repeat
        Loadfile(mapw,maph,ms,vt,bo,teletr,slw,wai,stage);
        Start;
        If not done then Main;
        Save(nv);
      until Done;
    finally
      if Assigned(console) then
        console.close;
    end;
  except
    on error: TPTCError do
     error.report;
  end;
  Dong(a);
End.
