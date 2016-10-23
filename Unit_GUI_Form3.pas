unit Unit_GUI_Form3;
{$mode objfpc}{$H+}

interface
uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
    cthreads, cmem
  {$ENDIF}{$ENDIF}
  Classes, Forms, StdCtrls, PolinD;

type
  TForm3 = class(TForm)
    Pol_N_GroupBox: TGroupBox;
    Divisor_GroupBox: TGroupBox;
    Cociente_GroupBox: TGroupBox;
    Resto_GroupBox: TGroupBox;
    Pol_N_Memo: TMemo;
    Divisor_Memo: TMemo;
    Cociente_Memo: TMemo;
    Resto_Memo: TMemo;
    constructor Crear(Comp: Tcomponent; VAR Pol: cls_Polin; Tipo_Polinomio: byte);
    procedure Divisor_GroupBoxDblClick(Sender: TObject);
    procedure Divisor_MemoClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure Pol_N_MemoClick(Sender: TObject);
    Procedure dividir();
    Procedure Check_Enabled();
  private
    { private declarations }
  public
    Polin: cls_Polin;
    Divisor: cls_Polin;
    Cociente: cls_Polin;
    Resto: cls_Polin;
    Tipo_Polin: byte;
    (*Tipo_Polinomio
    0---> Normal: 0<= Grado_N <= 10
    1---> Especial Monico Divisor Grado 1: X+a
    2---> Especial Monico Divisor Grado 2: X^2+rX+s *)
    Puedo_Dividir: Boolean;
    Divisor_Load: Boolean;
  end;

var
  Form3: TForm3;

implementation
{$R *.lfm}
Uses
    Unit_GUI_Form2, Controls, Dialogs, sysutils;

Constructor TForm3.Crear(Comp: Tcomponent; VAR Pol: cls_Polin; Tipo_Polinomio: byte);
Begin
      inherited Create(Comp);
      Self.Tipo_Polin:= Tipo_Polinomio;
      (*Tipo_Polinomio
      0---> Normal: 0<= Grado N <=10
      1---> Especial Monico Divisor Grado 1: X+a
      2---> Especial Monico Divisor Grado 2: X^2+rX+s  *)
      self.Polin:= Pol;
      self.Cociente:= cls_Polin.Crear();
      self.Resto:= cls_Polin.Crear();
      self.Pol_N_GroupBox.Caption:= 'Polinomio << Grado '+IntToStr(Polin.Grado())+' >>';
      Pol_N_Memo.Lines.Text:= self.polin.Coef_To_String();
      self.Cociente_GroupBox.Caption:= 'Cociente';
      self.Resto_GroupBox.Caption:= 'Resto';
      case (Tipo_Polin) of
           1: Begin
                    Divisor_GroupBox.Caption:= 'Divisor << Grado 1 >> Monico X+a';
                    Divisor:= cls_Polin.Crear(1);
                    Divisor.Coef.cells[1]:= 1;
           end;
           2: Begin
                    Divisor_GroupBox.Caption:= 'Divisor << Grado 2 >> Monico X^2+rX+s';
                    Divisor:= cls_Polin.Crear(2);
                    Divisor.Coef.cells[2]:= 1;
           end;
      end;
      Divisor_Memo.Lines.Text:='<< Click para editar >>';
      Puedo_Dividir:= False;
      Divisor_Load:= False;
      Check_Enabled();
end;

procedure TForm3.Pol_N_MemoClick(Sender: TObject);
begin
      //Tambien accede aqui menuItem--->Editar (Pol_N)
     Form2:= TForm2.Crear(Nil, Polin, 0);
     Form2.ShowModal;
     if (Form2.ModalResult= mrOk) then Begin
        Pol_N_Memo.Lines.Text:= Polin.Coef_To_String();
        Pol_N_GroupBox.Caption:= 'Polinomio << Grado '+IntToStr(Polin.Grado())+' >>';
        if (Divisor_Load) then
           Dividir();
     end;
     Form2.Free;
     Form2:=nil; //FreeAndNil(Form2);
end;

procedure TForm3.Divisor_GroupBoxDblClick(Sender: TObject);
begin
     showmessage('Doble click');
     if (Tipo_Polin=1) then Begin
        Divisor_GroupBox.Caption:= 'Divisor << Grado 2 >> Monico X^2+rX+s';
        Divisor.Free;
        Divisor:= cls_Polin.crear(2);
        Divisor.Coef.cells[2]:= 1;
        Tipo_Polin:=2;
     end else Begin
         Divisor_GroupBox.Caption:= 'Divisor << Grado 1 >> Monico X+a';
         Divisor.Free;
         Divisor:= cls_Polin.crear(1);
         Divisor.Coef.cells[1]:= 1;
         Tipo_Polin:=1;
     end;
end;

procedure TForm3.Divisor_MemoClick(Sender: TObject);
begin
     case(Tipo_Polin) of
          1: Form2:= TForm2.Crear(Nil, Divisor, 1);
          2: Form2:= TForm2.Crear(Nil, Divisor, 2);
     end;
     Form2.ShowModal;
     if (Form2.ModalResult= mrOk) then Begin
        Divisor_Memo.Lines.Text:= Divisor.Coef_To_String();
        Divisor_Load:= True;
        dividir();
     end;
     Form2.Free;
     Form2:= nil; //FreeAndNil(Form2);
end;

Procedure TForm3.Dividir();
Begin
     if (Polin.Grado() >= Divisor.Grado()) then Begin
        Puedo_Dividir:= True;
     Case (Tipo_Polin) of
             1: Polin.ruffini(divisor, cociente,resto);
             2: Polin.ruffini(divisor,cociente,resto);
     end;
        Cociente_Memo.Lines.Text:= Cociente.Coef_To_String();
        Resto_Memo.Lines.Text:= Resto.Coef_To_String();
        Puedo_Dividir:= True;
     end else Begin
              Puedo_Dividir:= False;
              showmessage('El Polinomio tiene que ser de mayor o igual Grado que el Divisor...');
     end;
     Check_Enabled();
end;

procedure TForm3.FormKeyPress(Sender: TObject; var Key: char);
begin
     // #27 --> Tecla Escape
     if (key = #27) then
        self.ModalResult:= mrCancel;
end;
Procedure TForm3.Check_Enabled();
Begin
      if (Puedo_Dividir) then Begin
         Cociente_GroupBox.Visible:= True;
         Resto_GroupBox.Visible:= True;
      end else begin
                    Cociente_GroupBox.Visible:= False;
                    Resto_GroupBox.Visible:= False;
      end;
end;

Begin
end.
