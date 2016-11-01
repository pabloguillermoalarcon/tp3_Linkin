unit Unit_GUI;
{$mode objfpc}{$H+}
interface
(*Las Varias principales son tres polinomios:
Pol_N_Main_Menu: Polinomio Normal: 0<= Grado N <=10
Pol_Div1: Polinomio Especial, Monico Divisor Grado 1: X-a,
Pol_Div2: Polinomio Especial Monico Divisor Grado 2: X^2-rX-s

internamente el vector de coeficientes se carga de la forma [A0...AN] siempre
pero se visualiza de forma predeterminada [An...A0]
se puede cambiar la visualizacion con la propiedad, band_A0 de cls_Polin
 *)
uses
    {$IFDEF UNIX}{$IFDEF UseCThreads}
    cthreads, cmem
    {$ENDIF}{$ENDIF}
    Classes, Forms, StdCtrls, Menus, PolinD, Controls, Types;

type
  { TForm1 }
  TForm1 = class(TForm)
    Bairstrow_Item: TMenuItem;
    Cotas: TMenuItem;
    Enteras_GroupBox: TGroupBox;
    Item_Div1: TMenuItem;
    Item_Div2: TMenuItem;
    Item_Editar: TMenuItem;
    item_invertir: TMenuItem;
    Item_Limpiar: TMenuItem;
    MainMenu1: TMainMenu;
    Racionales_GroupBox: TGroupBox;
    enteras_Memo: TMemo;
    Racionales_Memo: TMemo;
    Raices_Menu: TMenuItem;
    Salir: TMenuItem;
    X_Label: TLabel;
    Pol_N_Memo: TMemo;
    Pol_N_Main_Menu: TMenuItem;
    procedure Bairstrow_ItemClick(Sender: TObject);
    procedure CotasClick(Sender: TObject);
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
    procedure Racionales_MemoMouseWheelDown(Sender: TObject;
      Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure Racionales_MemoMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure SalirClick(Sender: TObject);
    Procedure Check_Enabled();
    procedure X_LabelClick(Sender: TObject);
  private
    { private declarations }
  public
     //Variables Principales
     Pol_N: cls_Polin; //Polinomio Principal de GradoN
     Pol_N_load: boolean;

     X: extended;  //Sirve para Evalua el Polinomio en un X --->Calcular_Px()
     MASC_RAC: byte; //Guarda la Mascara para Posibles Raices Racionales
     const
          MIN_MASC = 0;
          MAX_MASC = 11;
  end;

var
  Form1: TForm1;

implementation
{$R *.lfm}
USES
    Unit_GUI_Form2,  Unit_GUI_Form3, Unit_GUI_Form4_Cotas, SysUtils, Dialogs, VectorD;

procedure TForm1.FormCreate(Sender: TObject);
begin
     Pol_N:= cls_Polin.Crear(3);
     Pol_N_load:= false;
     self.Pol_N_Memo.Lines.Text:= '<< Click para editar >>';
     self.Caption:= 'Tp3 - Linkin - Polinomio << Grado N >>';
     X:= 0;
     MASC_RAC:= 2;
     self.check_enabled();
end;

procedure TForm1.Bairstrow_ItemClick(Sender: TObject);
begin
     if Pol_N_load then Begin;
        if Pol_N.Grado()>2 then Begin
           Pol_N.bairstow(0.0000000001, 0, 0, 1000);
           showmessage(Pol_N.Raices_To_String());
        end else ShowMessage('Bairstow: Tiene que ingresar un Polinomio de grado mayor a 2');
     end;
end;

procedure TForm1.CotasClick(Sender: TObject);
begin
     if (Form4=nil) then Begin
        Form4:= TForm4.Crear(nil,Pol_N);
        Form4.Show;
     end;
end;

procedure TForm1.FormKeyPress(Sender: TObject; var Key: char);
begin
  if (key = #27) then
     Close;
end;

procedure TForm1.Item_EditarClick(Sender: TObject);
Var
    raices: cls_Vector;
begin
     //Tambien accede aqui onClick--->Pol_N_Memo
     Form2:= TForm2.Crear(Nil, Pol_N, 0);
     Form2.ShowModal;
     if (Form2.ModalResult = mrOk) then Begin
         self.Pol_N_Memo.Lines.Text:= Pol_N.Coef_To_String();
         Self.Caption:='Tp3 - Linkin - Polinomio << Grado '+IntToStr(Pol_N.Grado())+' >>';
         X:= 0;
         X_Label.Caption:= 'P('+FloatToStr(X)+') = '+FloatToStr(Pol_N.evaluar(X));
         Self.Pol_N_load:= true;

         raices:= Cls_Vector.Crear();
         Pol_N.PosiblesRaicesEnteras(Pol_N.Coef,raices);
         enteras_Memo.Lines.Text:= raices.ToString();
         raices.Free;

         raices:= Cls_Vector.Crear();
         Pol_N.PosiblesRaicesRacionales(Pol_N.Coef,raices);
         Racionales_Memo.Lines.Text:= raices.ToString(2);
         raices.Free;

         self.check_enabled();
     end;
     Form2.Free;
     Form2:= nil; //FreeAndNil(Form2);
end;

procedure TForm1.Item_Div1Click(Sender: TObject);
Var
    Raices: cls_Vector;
begin
     Self.Visible:= False;
     Form3:= TForm3.Crear(nil,Pol_N,1);
     Form3.ShowModal;
     Form3.Free;
     Form3:= nil;
     Pol_N_Memo.Lines.Text:= Pol_N.Coef_To_String();
     X:= 0;
     X_Label.Caption:= 'P('+FloatToStr(X)+') = '+FloatToStr(Pol_N.evaluar(X));
     Self.Visible:= True;
     //Posibles Raices Enteras
     raices:= Cls_Vector.Crear();
     Pol_N.PosiblesRaicesEnteras(Pol_N.Coef,raices);
     enteras_Memo.Lines.Text:= raices.ToString();
     raices.Free;
     //Posibles Raices Racionales
     raices:= Cls_Vector.Crear();
     Pol_N.PosiblesRaicesRacionales(Pol_N.Coef,raices);
     Racionales_Memo.Lines.Text:= raices.ToString(2);
     raices.Free;
     self.check_enabled();
end;

procedure TForm1.Item_Div2Click(Sender: TObject);
Var
    Raices: cls_Vector;
begin
     Self.Visible:= False;
     Form3:= TForm3.Crear(nil,Pol_N,2);
     Form3.ShowModal;
     Form3.Free;
     Form3:= nil;
     Pol_N_Memo.Lines.Text:= Pol_N.Coef_To_String();
     X:= 0;
     X_Label.Caption:= 'P('+FloatToStr(X)+') = '+FloatToStr(Pol_N.evaluar(X));
     Self.Visible:= True;
     //Posibles Raices Enteras
     raices:= Cls_Vector.Crear();
     Pol_N.PosiblesRaicesEnteras(Pol_N.Coef,raices);
     enteras_Memo.Lines.Text:= raices.ToString();
     raices.Free;
     //Posibles Raices Racionales
     raices:= Cls_Vector.Crear();
     Pol_N.PosiblesRaicesRacionales(Pol_N.Coef,raices);
     Racionales_Memo.Lines.Text:= raices.ToString(2);
     raices.Free;
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
         self.Enteras_GroupBox.Visible:= False;
         self.Racionales_GroupBox.Visible:= False;
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
              self.Enteras_GroupBox.Visible:= True;
              self.Racionales_GroupBox.Visible:= True;
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
           X_Label.Caption:= 'P('+FloatToStr(X)+') = '+FloatToStr(Pol_N.evaluar(X));
     end;
end;

BEGIN
END.
