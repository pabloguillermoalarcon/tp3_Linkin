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
    Classes, Forms, Dialogs, StdCtrls, Menus, SysUtils, PolinD;

type
  { TForm1 }
  TForm1 = class(TForm)
    Editar_Div1: TButton;
    MainMenu1: TMainMenu;
    Item_Editar: TMenuItem;
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
    Pol_N_Label: TLabel;
    procedure Item_EditarClick(Sender: TObject);
    procedure Editar_Div1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    function  Load(Polin: cls_Polin):boolean;
    procedure item_invertirClick(Sender: TObject);
    procedure Pol_N_LabelClick(Sender: TObject);
    procedure Raices_Enteras_ItemClick(Sender: TObject);
    procedure SalirClick(Sender: TObject);
  private
    { private declarations }
  public
     //Variables Principales
     Pol_N: cls_Polin; //Polinomio Principal de GradoN
     Pol_Div1: cls_Polin; //X+a monico
     Pol_Div2: cls_Polin; //X^2+rX+s monico
  end;

var
  Form1: TForm1;

implementation
{$R *.lfm}
{ TForm1 }
USES
    Unit_GUI_Form2;

procedure TForm1.Editar_Div1Click(Sender: TObject);
begin
     if (Pol_Div1 = nil) then
        Pol_Div1:= cls_Polin.Crear(1,2,false);

     Form2:= TForm2.Crear(Nil, Pol_Div1, 1);
     Form2.ShowModal;
     Form2.Free;
     Form2:=nil; //FreeAndNil(Form2);
     showmessage(Pol_Div1.Coef_To_String());

end;

procedure TForm1.Item_EditarClick(Sender: TObject);
begin
     if (not self.Load(Pol_N)) then
        Pol_N:= cls_Polin.Crear(3,2,false);
     Form2:= TForm2.Crear(Nil, Pol_N, 0);
     Form2.ShowModal;
     Form2.Free;
     Form2:=nil; //FreeAndNil(Form2);
     if (self.Load(Pol_N)) then Begin
         self.Pol_N_Label.Caption:= Pol_N.Coef_To_String();
         Self.Caption:='Tp3 - Linkin - Polinomio << Grado '+IntToStr(Pol_N.Grado())+' >>';
     end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
     self.Pol_N_Label.Caption:= '<< Click para editar >>';
     self.Caption:= 'Tp3 - Linkin - Polinomio << Grado N >>';
end;

function TForm1.Load(Polin: cls_Polin):boolean;
Begin
     Result:=not (Polin=nil);
end;

procedure TForm1.item_invertirClick(Sender: TObject);
begin
     if self.Load(Pol_N)then begin
        Pol_N.band_A0:= not Pol_N.band_A0;
        self.Pol_N_Label.Caption:= Pol_N.Coef_To_String();
     end;
end;

procedure TForm1.Pol_N_LabelClick(Sender: TObject);
begin
     if (not self.Load(Pol_N)) then
        Pol_N:= cls_Polin.Crear(3,2,false);
     Form2:= TForm2.Crear(Nil, Pol_N, 0);
     Form2.ShowModal;
     Form2.Free;
     Form2:=nil; //FreeAndNil(Form2);
     if (self.Load(Pol_N)) then Begin
         self.Pol_N_Label.Caption:= Pol_N.Coef_To_String();
         Self.Caption:='Tp3 - Linkin - Polinomio << Grado '+IntToStr(Pol_N.Grado())+' >>';
     end;
end;

procedure TForm1.Raices_Enteras_ItemClick(Sender: TObject);
begin

end;

procedure TForm1.SalirClick(Sender: TObject);
begin
     self.Close;
end;

BEGIN
END.
