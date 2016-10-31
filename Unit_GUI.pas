unit Unit_GUI;
{$mode objfpc}{$H+}
interface

(*Las Varias principales son tres polinomios:
Pol_N_Main_Menu: Polinomio Normal: 0<= Grado N <=10
Pol_Div1: Polinomio Especial, Monico Divisor Grado 1: X+a,
Pol_Div2: Polinomio Especial Monico Divisor Grado 2: X^2+rX+s

internamente el vector de coeficientes se carga de la forma [A0...AN] siempre
pero se visualiza de forma predeterminada [An...A0]
se puede cambiar la visualizacion con la propiedad, band_A0 de cls_Polin
 *)

uses
    {$IFDEF UNIX}{$IFDEF UseCThreads}
    cthreads, cmem
    {$ENDIF}{$ENDIF}
    Classes, Forms, StdCtrls, Menus, PolinD, Controls;

type
  { TForm1 }
  TForm1 = class(TForm)
    X_Label: TLabel;
    MainMenu1: TMainMenu;
    Item_Editar: TMenuItem;
    Item_Limpiar: TMenuItem;
    Pol_N_Memo: TMemo;
    Salir: TMenuItem;
    Raices_Racionales_Item: TMenuItem;
    Raices_Enteras_Item: TMenuItem;
    Raices_Menu: TMenuItem;
    Cotas: TMenuItem;
    Bairstrow_Item: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    Sturm_Item: TMenuItem;
    Pol_N_Main_Menu: TMenuItem;
    item_invertir: TMenuItem;
    Item_Div1: TMenuItem;
    Item_Div2: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure Item_Div2Click(Sender: TObject);
    procedure Item_EditarClick(Sender: TObject);
    procedure Item_invertirClick(Sender: TObject);
    procedure Item_Div1Click(Sender: TObject);
    procedure Item_LimpiarClick(Sender: TObject);
    procedure Pol_N_MemoMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure Pol_N_MemoMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure Raices_Enteras_ItemClick(Sender: TObject);
    procedure SalirClick(Sender: TObject);
    Procedure Check_Enabled();
    procedure X_LabelClick(Sender: TObject);
    Function Calcular_Px(): extended; //Evalua el Polinomio en un X
  private
    { private declarations }
  public
     //Variables Principales
     Pol_N: cls_Polin; //Polinomio Principal de GradoN
     Pol_N_load: boolean;
     MIN_MASC: byte;
     MAX_MASC: byte;
     X: extended;  //Sirve para Evalua el Polinomio en un X --->Calcular_Px()
  end;

var
  Form1: TForm1;

implementation
{$R *.lfm}
USES
    Unit_GUI_Form2,  Unit_GUI_Form3, SysUtils, Dialogs, VectorD;

procedure TForm1.FormCreate(Sender: TObject);
begin
     Pol_N:= cls_Polin.Crear(3);
     Pol_N_load:= false;
     self.Pol_N_Memo.Lines.Text:= '<< Click para editar >>';
     self.Caption:= 'Tp3 - Linkin - Polinomio << Grado N >>';
     MIN_MASC:= 0;
     MAX_MASC:= 11;
     X:= 0;
     self.check_enabled();
end;

procedure TForm1.FormKeyPress(Sender: TObject; var Key: char);
begin
  if (key = #27) then
     Close;
end;

procedure TForm1.Item_EditarClick(Sender: TObject);
begin
     //Tambien accede aqui onClick--->Pol_N_Memo
     Form2:= TForm2.Crear(Nil, Pol_N, 0);
     Form2.ShowModal;
     if (Form2.ModalResult = mrOk) then Begin
         self.Pol_N_Memo.Lines.Text:= Pol_N.Coef_To_String();
         Self.Caption:='Tp3 - Linkin - Polinomio << Grado '+IntToStr(Pol_N.Grado())+' >>';
         X:= 0;
         X_Label.Caption:= 'P('+FloatToStr(X)+') = '+FloatToStr(Calcular_Px());
         Self.Pol_N_load:= true;
         self.check_enabled();
     end;
     Form2.Free;
     Form2:= nil; //FreeAndNil(Form2);
end;

procedure TForm1.Item_Div1Click(Sender: TObject);
begin
     Self.Visible:= False;
     Form3:= TForm3.Crear(nil,Pol_N,1);
     Form3.ShowModal;
     Form3.Free;
     Form3:= nil;
     Pol_N_Memo.Lines.Text:= Pol_N.Coef_To_String();
     X:= 0;
     X_Label.Caption:= 'P('+FloatToStr(X)+') = '+FloatToStr(Calcular_Px());
     Self.Visible:= True;
     self.check_enabled();
end;

procedure TForm1.Item_Div2Click(Sender: TObject);
begin
     Self.Visible:= False;
     Form3:= TForm3.Crear(nil,Pol_N,2);
     Form3.ShowModal;
     Form3.Free;
     Form3:= nil;
     Pol_N_Memo.Lines.Text:= Pol_N.Coef_To_String();
     X:= 0;
     X_Label.Caption:= 'P('+FloatToStr(X)+') = '+FloatToStr(Calcular_Px());
     Self.Visible:= True;
     self.check_enabled();
end;

procedure TForm1.item_invertirClick(Sender: TObject);
begin
     if (Pol_N_load)then begin
        Pol_N.band_A0:= not Pol_N.band_A0;
        self.Pol_N_Memo.Lines.Text:= Pol_N.Coef_To_String();
     end;
end;

procedure TForm1.Item_LimpiarClick(Sender: TObject);
begin
     Pol_N.Free;
     FormCreate(Self);
end;

procedure TForm1.Pol_N_MemoMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
     If (Pol_N.Masc > MIN_MASC) then
         Pol_N.Masc:= Pol_N.Masc -1
     else Pol_N.Masc:= self.MAX_MASC;
     self.Pol_N_Memo.Lines.Text:= Pol_N.Coef_To_String();
end;

procedure TForm1.Pol_N_MemoMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
     If (Pol_N.Masc < self.MAX_MASC) then
         Pol_N.Masc:= Pol_N.Masc +1
     else Pol_N.Masc:= self.MIN_MASC;
     self.Pol_N_Memo.Lines.Text:= Pol_N.Coef_To_String();
end;

procedure TForm1.Raices_Enteras_ItemClick(Sender: TObject);
Var
  enteras: cls_Vector;
begin
     enteras:= Cls_Vector.Crear();
     //Pol_N.raicesEnteras(Pol_N.Coef,enteras);
     Pol_N.PosiblesRaicesEnteras(Pol_N.Coef,enteras);
     showmessage('Posibles Raices Enteras: ' + enteras.ToString());
     enteras.Destroy;
end;

procedure TForm1.SalirClick(Sender: TObject);
begin
     self.Close;
end;

Procedure TForm1.check_enabled();
Begin
     if (not Pol_N_load) then Begin
         self.Item_invertir.Visible:= False;
         self.Item_invertir.Enabled:= False;
         self.Item_Limpiar.Visible:= False;
         self.Item_Limpiar.Enabled:= False;
         self.Item_Div1.Visible:= False;
         self.Item_Div1.Enabled:= False;
         self.Item_Div2.Visible:= False;
         self.Item_Div2.Enabled:= False;
         self.Raices_Menu.Visible:= False;
         self.X_Label.Visible:= False;
     end else Begin // Pol_N esta cargado
              self.Item_invertir.Visible:= True;
              self.Item_invertir.Enabled:= True;
              self.Item_Limpiar.Visible:= True;
              self.Item_Limpiar.Enabled:= True;
              self.Item_Div1.Visible:= True;
              self.Item_Div1.Enabled:= True;
              self.Item_Div2.Visible:= True;
              self.Item_Div2.Enabled:= True;
              self.Raices_Menu.Visible:= True;
              self.X_Label.Visible:= True;
     end;
end;

procedure TForm1.X_LabelClick(Sender: TObject);
var
  cad: string;
  pos: integer;
begin
     cad:= InputBox('Cambiar Valor P(X)','Ingrese X: ', FloatToStr(X));
     if (cad <> '') then Begin
        Val(cad,X,pos);
        if (pos=0) then
           X_Label.Caption:= 'P('+FloatToStr(X)+') = '+FloatToStr(Calcular_Px());
     end;
end;
Function TForm1.Calcular_Px(): extended;
var
  divi,coc,res: cls_polin;
Begin
     if (self.Pol_N.Grado() > 0) then Begin
        divi:= cls_Polin.Crear(1);
        divi.Coef.cells[1]:= 1;
        divi.Coef.cells[0]:= -X;
        coc:= cls_Polin.Crear(self.Pol_N.Grado() -1);
        res:= cls_Polin.Crear(0);
        Pol_N.ruffini(divi,coc,res);
        Result:= res.Coef.cells[0];
     end else Result:= Pol_N.Coef.cells[0];
end;

BEGIN
END.
