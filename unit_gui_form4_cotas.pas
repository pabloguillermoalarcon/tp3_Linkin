unit Unit_GUI_Form4_Cotas;
{$mode objfpc}{$H+}

interface
uses
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
       procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  public
       const
       MIN_MASC = 0;
       MAX_MASC = 11;
       constructor crear(Comp: Tcomponent; Polin: cls_Polin);

  end;

var
  Form4: TForm4;

implementation
{$R *.lfm}
USES
    VectorD;

procedure TForm4.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
     CloseAction:= caFree;
     Form4:= nil;
end;

constructor TForm4.Crear(Comp: Tcomponent; Polin: cls_Polin);
Var
   vector: cls_Vector;
   pol_N:cls_Polin;
Begin
     Vector:= cls_Vector.crear(4);
     inherited create(comp);
     polin.Lagrange(vector);
     Lagrange_Memo.Lines.Text:= Vector.ToString(2);
     polin.Laguerre(0,vector);
     Laguerre_Memo.Lines.Text:= Vector.ToString(2);
     vector:= polin.cotasNewton();
     Newton_Memo.Lines.Text:= Vector.ToString(2);
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
