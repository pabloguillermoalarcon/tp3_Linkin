unit Unit_GUI_Form4_Cotas;
{$mode objfpc}{$H+}

interface
uses
    {$IFDEF UNIX}{$IFDEF UseCThreads}
    cthreads, cmem
    {$ENDIF}{$ENDIF}
  Classes, SysUtils, Forms, Controls, StdCtrls, PolinD;

type

  { TForm4 }

  TForm4 = class(TForm)
       Lagrange_GroupBox: TGroupBox;
       Lagrange_Memo: TMemo;
       Laguerre_GroupBox: TGroupBox;
       Laguerre_Memo: TMemo;
       Newton_GroupBox: TGroupBox;
       Newton_Memo: TMemo;
       Sturm_GroupBox: TGroupBox;
       Sturm_Memo: TMemo;
       constructor crear(Comp: Tcomponent; Pol: cls_Polin);
       procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
       Procedure actualiza();
       Procedure Cerrar();
  Public
       Polin: cls_Polin;
  const
       MIN_MASC = 0;
       MAX_MASC = 11;
  end;
var
  Form4: TForm4;

implementation
{$R *.lfm}
USES
    VectorD;

Procedure TForm4.Cerrar();
Begin
     self.Close;
end;

procedure TForm4.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
     CloseAction:= caFree;
     Form4:= nil;
end;

constructor TForm4.Crear(Comp: Tcomponent; Pol: cls_Polin);
Begin
     inherited create(comp);
     Polin:= Pol;
     self.actualiza();
end;
Procedure TForm4.actualiza();
Var
   vector: cls_Vector;
Begin
     Vector:= cls_Vector.crear(4);
     polin.Lagrange(vector);
     Lagrange_Memo.Lines.Text:= Vector.ToString(4);
     polin.Laguerre(0,vector);
     Laguerre_Memo.Lines.Text:= Vector.ToString(4);
     Vector.Free;
     vector:= polin.cotasNewton();
     Newton_Memo.Lines.Text:= Vector.ToString(4);
     //polin.sturm(polin.Coef,vector,vector);
end;

{
procedure TForm1.Racionales_MemoMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
VAR
    raices: cls_Vector;
begin
     //Posibles Raices Racionales
     raices:= Cls_Vector.Crear();
     Pol_N.PosiblesRaicesRacionales(Pol_N.Coef,raices);

     if (MASC_RAC=MIN_MASC+1) then MASC_RAC:= MAX_MASC
     else dec(MASC_RAC);
     Racionales_Memo.Lines.Text:= raices.ToString(MASC_RAC);
     //showmessage(IntToStr(Masc_RAC));
     raices.Free;
end;

procedure TForm1.Racionales_MemoMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
VAR
    raices: cls_Vector;
begin
     //Posibles Raices Racionales
     raices:= Cls_Vector.Crear();
     Pol_N.PosiblesRaicesRacionales(Pol_N.Coef,raices);

     if (MASC_RAC=MAX_MASC) then MASC_RAC:= MIN_MASC +1
     else inc(MASC_RAC);
     Racionales_Memo.Lines.Text:= raices.ToString(MASC_RAC);
     raices.Free;
end;
}

BEGIN
END.
