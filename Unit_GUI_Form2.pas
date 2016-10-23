Unit Unit_GUI_Form2;
{$mode objfpc}{$H+}

interface
(* En un formulario modal se guarda la salida en una variable del propio formulario,
llamada ResulModal, que entre varios valores pueden ser los sgtes...
mrNone   0   None. Used as a default value before the user exits.
mrOk    idOK(1) The user exited with OK button.
mrCancel
mrIgnore
*)
USES
    {$IFDEF UNIX}{$IFDEF UseCThreads}
    cthreads, cmem
    {$ENDIF}{$ENDIF}
    Classes, Forms, Controls, StdCtrls, Grids, ComCtrls,  PolinD, Types;

type

  { TForm2 }
TForm2 = class(TForm)
    Aceptar: TButton;
    Cancel_Buttom: TButton;
    Preview_Memo: TMemo;
    Preview_GroupBox: TGroupBox;
    Label_Mascara: TLabel;
    Menos: TButton;
    Mas: TButton;
    Matriz_String: TStringGrid;
    Mascara_TrackBar: TTrackBar;
    (*Tipo_Polinomio
    0---> Normal: 0<= Grado N <=10
    1---> Especial Monico Divisor Grado 1: X+a
    2---> Especial Monico Divisor Grado 2: X^2+rX+s  *)
    constructor Crear(Comp: Tcomponent; VAR Pol: cls_Polin; Tipo_Polinomio: byte);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure MasClick(Sender: TObject);
    procedure Matriz_StringEditingDone(Sender: TObject);
    procedure MenosClick(Sender: TObject);
    //detecta cuando se tiene que invertir la visualizacion a0-->An
    procedure Matriz_StringHeaderClick(Sender: TObject; IsColumn: Boolean; Index: Integer);
    procedure Invertir_Matriz(); //cambia [AN,...,A0] ---> [A0,...,AN]
    procedure AceptarClick(Sender: TObject);
    procedure Cancel_ButtomClick(Sender: TObject);
    Procedure Load_Matriz(); //Carga coefic de Polin en Matriz_Grid
    Procedure Load_Coef(VAR Pol: cls_Polin);
    procedure Mascara_TrackBarChange(Sender: TObject);
    procedure Preview_MemoMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure Preview_MemoMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    Function Valida(col: integer): boolean; //Revisa una celda de la matriz[col,1] valida la conversion a extended
    Procedure Preview(); //Revisa todas las celdas y devuelve el resultado sobre preview_Label y avisa si hay Errores si es FALSE
    Function Preview_Aceptar(): Boolean; //Revisa todas las celdas y devuelve el resultado sobre preview_Label y avisa si hay Errores si es FALSE
  private
    { private declarations }
  public{ public declarations }
    Polin: Cls_Polin;
    Esta_Correcto: boolean; //Se carga el resultado de self.Preview()
    Tipo_Polin: byte;
    (*Tipo_Polinomio
    0---> Normal: 0<= Grado_N <= 10
    1---> Especial Monico Divisor Grado 1: X+a
    2---> Especial Monico Divisor Grado 2: X^2+rX+s *)
    Ban_CoefA0: Boolean;

    (*Primera columna de Matriz_String no se utiliza y se necesita
     al Menos un coeficiente para un polinomio de Grado 0*)
     MAX_COL: integer;//= 12;
     MIN_COL: integer;//= 2;
end;

var
  Form2: TForm2;

implementation
{$R *.lfm}
USES
    SysUtils, Dialogs, Unit_GUI;
(*Tipo_Polinomio
0---> Normal: 0<= Grado N <=10
1---> Especial Monico Divisor Grado 1: X+a
2---> Especial Monico Divisor Grado 2: X^2+rX+s  *)

constructor TForm2.Crear(Comp: Tcomponent; var Pol: cls_Polin; Tipo_Polinomio: byte);

Begin
     inherited create(Comp);
     self.Polin:= Pol;
     self.Tipo_Polin:= Tipo_Polinomio;
     self.Preview_GroupBox.Caption:='Vista Previa';
     self.Esta_Correcto:= FALSE;
     self.Load_Matriz();
     (*Limites Cantidad de digitos decimal a mostrar *)
     self.Mascara_TrackBar.Max:= Form1.MAX_MASC;
     self.Mascara_TrackBar.Min:= Form1.MIN_MASC;
     MAX_COL:= 12;
     MIN_COL:= 2;
end;

procedure TForm2.FormKeyPress(Sender: TObject; var Key: char);
begin
     // #27 --> Tecla Escape
     if (key = #27) then
        self.ModalResult:= mrCancel;
end;

//Se asume q Pol esta creado
procedure TForm2.Load_Matriz;
Var
   i:integer;
Begin
     self.Matriz_String.ColCount:= Polin.Grado()+2;
     self.Mascara_TrackBar.Position:= Polin.Masc;
     self.Ban_CoefA0:= Polin.band_A0;
     self.Preview_Memo.Lines.Text:= Polin.Coef_To_String();

     if ((Polin.Masc=0) or (Polin.Masc=11)) then self.Label_mascara.Caption:= 'Optima'
     else self.Label_mascara.Caption:= 'Mascara: ' + IntToStr(Polin.Masc);
     case (Tipo_Polin) of
             0: self.Caption:= 'Editar Polinomio << Grado '+IntToStr(Polin.Grado())+' >>'; //Normal: 0<= Grado N <=10, Por Defecto Grado 3 (creacion de uno nuevo)
             1: Begin
                     self.Mas.Visible:= False;
                     self.Menos.Visible:= False;
                     self.Caption:= 'Editar Polinomio << Grado 1 >> Monico X+a'; //Especial Monico Divisor Grado 1: X+a
             end;
             2: Begin
                      self.Mas.Visible:= False;
                      self.Menos.Visible:= False;
                      self.Caption:= 'Editar Polinomio << Grado 2 >> Monico X^2+rX+s'; //Especial Monico Divisor Grado 2: X^2+rX+s
             end;
     end;
     if (Polin.band_A0)then Begin //Transmite a la Matriz d la Forma [A0,..An]
        for i:=0 to Polin.Grado() do begin//Primera Columna de Matriz_String no se utiliza
            self.Matriz_String.Cells[i+1,0]:= 'a'+IntToStr(i);
            self.Matriz_String.Cells[i+1,1]:= FloatToStr(Polin.Coef.cells[i]);
        end;
     end else //Transmite a la Matriz d la Forma [An,..A0]
             for i:=0 to Polin.Grado() do begin//Primera Columna de Matriz_String no se utiliza
                 self.Matriz_String.Cells[i+1,0]:= 'a'+IntToStr(Polin.Grado() -i);
                 self.Matriz_String.Cells[i+1,1]:= FloatToStr(Polin.Coef.cells[Polin.Grado() -i]);
             end;
end;

procedure TForm2.Load_Coef(Var Pol: cls_Polin);
Var
   i, j: integer;
Begin
     if (Pol=nil) then Pol:= cls_Polin.Crear(Matriz_String.ColCount-2)
     else Pol.Redimensionar(Matriz_String.ColCount-2);
     Pol.band_A0:= self.Ban_CoefA0;
     if ((Mascara_TrackBar.Position= Mascara_TrackBar.Min) or (self.Mascara_TrackBar.Position= self.Mascara_TrackBar.Max)) then
        Pol.Masc:= 0
     else Pol.Masc:= self.Mascara_TrackBar.Position;
     if Pol.band_A0 then Begin
        for i:=1 to self.Matriz_String.ColCount-1 do
            if valida(i) then
               pol.Coef.cells[i-1]:= StrToFloat(self.Matriz_String.Cells[i,1])
            else pol.Coef.cells[i-1]:= 0;
     end else Begin //Muestra [An..A0] pero se guarda [A0..aN] en el vector de coeficientes
         j:= 0;
         for i:=self.Matriz_String.ColCount-1 downto 1 do Begin
            if valida(i) then
               pol.Coef.cells[j]:= StrToFloat(self.Matriz_String.Cells[i,1])
            else pol.Coef.cells[j]:= 0;
            inc(j);
         end;
     end;
  end;
procedure TForm2.MenosClick(Sender: TObject);
(*Matriz_String: tiene los atributos colcount que tiene la cant de columnas pero el subindice comienza en 0
por eso si tengo 4 columnas --> colcount=4 y los subindices de las columnas van de 0..3
ademas la primera columna y primera fila nose utilizan, se reservan para etiquetas de celdas, como en ms excel*)
var
   i:integer;
begin
     if (Matriz_String.ColCount > MIN_COL) then begin
        if (not self.Ban_CoefA0) then begin //el vector esta ordenado en la INTERFAZ como [aN..a0]
           for i:=1 to Matriz_String.ColCount -2 do begin  //Realizo un corrimiento de las columnas porque se muestra en orden invertido en la INTERFAZ
               Matriz_String.cells[i,0]:= Matriz_String.cells[i+1,0];//fila0: etiquetas coeficiente (a0...)
               Matriz_String.cells[i,1]:= Matriz_String.cells[i+1,1];//fila1: valor de los coeficientes en string
           end;
        end;
        Matriz_String.ColCount:= Matriz_String.ColCount -1; //Elimino la columna del final
        Caption:= 'Editar Polinomio << Grado ' + IntToStr(Matriz_String.ColCount-2) + ' >>'; //titulo ventana
     end
     else showmessage('No se pueden eliminar mas coeficientes (cant = '+ IntToStr(Matriz_String.ColCount -1)+')');
     self.Preview();
end;

procedure TForm2.MasClick(Sender: TObject);
(*Matriz_String: tiene los atributos colcount que tiene la cant de columnas pero el subindice comienza en 0
por eso si tengo 4 columnas --> colcount=4 y los subindices de las columnas van de 0..3
ademas la primera columna y primera fila nose utilizan, se reservan para etiquetas de celdas, como en ms excel*)
var
   i:integer;
begin
     if (Matriz_String.ColCount < MAX_COL) then begin
        Matriz_String.ColCount:= Matriz_String.ColCount +1;//Agrego columna nueva al final
        if (self.Ban_CoefA0) then begin //el vector esta ordenado en la INTERFAZ como [a0..aN]
           Matriz_String.Cells[Matriz_String.ColCount-1,0]:= 'a'+IntToStr(Matriz_String.ColCount -2);
           // Es -2 porque la col0 no se utiliza y colcount tiene la CANTIDAD de columnas, no los subindices
        end else begin //el vector esta ordenado en la INTERFAZ como [aN..a0]
               //Realizo un corrimiento de las columnas porque se muestra en orden invertido en la INTERFAZ
               for i:= Matriz_String.ColCount-1 downto 2 do begin
                   Matriz_String.cells[i,0]:= Matriz_String.cells[i-1,0];//fila0: etiquetas coeficiente (a0...)
                   Matriz_String.cells[i,1]:= Matriz_String.cells[i-1,1];//fila1: valor de los coeficientes en string
               end;
               Matriz_String.cells[1,0]:='a'+IntToStr(Matriz_String.ColCount -2); //Agrego etiqueta aN a la nueva columna
               Matriz_String.cells[1,1]:=''; //Limpio el valor del nuevo coeficiente
        end;
        Caption:= 'Editar Polinomio << Grado ' + IntToStr(Matriz_String.ColCount-2) + ' >>'; //titulo ventana
     end
     else showmessage('No se pueden agregar mas coeficientes (cant = '+ IntToStr(Matriz_String.ColCount -1)+')');
     self.Preview();
end;

procedure TForm2.Matriz_StringEditingDone(Sender: TObject);
begin
     self.Preview();
end;

procedure TForm2.Matriz_StringHeaderClick(Sender: TObject; IsColumn: Boolean;
  Index: Integer);
begin //click barra de titulos de la matriz invierte la visualizacion del polinomio
     self.invertir_Matriz();
     self.Ban_CoefA0:= not Ban_CoefA0;
     self.Preview();
end;
// Analiza una celda y establece si esta correcta
Function TForm2.Valida(col: integer): boolean;
VAR
   valor: extended;
   Pos: integer;
   Pol:cls_Polin;
Begin
     Pol:= Cls_Polin.Crear(Polin.Grado() +1);
     if (Matriz_String.Cells[Col,1] <> '') then
        VAL(self.Matriz_String.Cells[Col,1], Valor, Pos)
     else Pos:= -1;
     Pol.Destroy;
     RESULT:= (POS = 0);
end;

Function TForm2.Preview_Aceptar(): Boolean;
VAR
   i: integer;
   Es_Correcto: Boolean;

Begin
     Es_Correcto:= TRUE;
     i:= 1;
     while((Es_Correcto) and (i<= Matriz_String.ColCount -1)) do Begin
           Es_Correcto:= Valida(i);
           if (not Es_Correcto) then
              if (Matriz_String.Cells[i,1] = '') then Begin
                 Matriz_String.Cells[i,1]:= '0';
                 Es_Correcto:= TRUE;
              end;
           inc(i);
     end;
     if (not Es_Correcto) then Begin
     //Indicar el primer coeficiente que hay q corregir...
        if (self.Ban_CoefA0) then
           self.Preview_Memo.Lines.Text:= 'Error en coef: a' + IntToStr(i -2)
        else self.Preview_Memo.Lines.Text:= 'Error en coef: a' +IntToStr(Matriz_String.Colcount -i);
     end else Begin //Es_Correcto=TRUE: ahora reviso si el coeficiente del grado Mayor es <> 0 0 sii = 1 por ser monico
              if (self.Ban_CoefA0) then Begin //preview [a0...aN]
                 if ((self.Tipo_Polin=1) or (Tipo_Polin=2)) then Begin
                     if (StrToFloat(Matriz_String.cells[Matriz_String.ColCount -1,1]) <> 1) then Begin
                        self.Preview_Memo.Lines.Text:= 'Coef: a' +IntToStr(Matriz_String.ColCount -2) + ' tiene que ser 1, porque el polinomio es monico';
                        Matriz_string.Cells[Matriz_String.ColCount-1,1]:= '1';
                        Es_Correcto:= FALSE;
                     end;
                 end else
                         if (StrToFloat(Matriz_String.cells[Matriz_String.ColCount -1,1]) = 0) then Begin
                            self.Preview_Memo.Lines.Text:= 'Coef: a' + IntToStr(Matriz_String.ColCount -2)+ ' tiene que ser distinto de 0';
                            Es_Correcto:= FALSE;
                         end;
              end else Begin //preview [aN...a0]
                             if ((self.Tipo_Polin=1) or (Tipo_Polin=2)) then Begin
                                if (StrToFloat(Matriz_String.cells[1,1]) <> 1) then Begin
                                   self.Preview_Memo.Lines.Text:= 'Coef: a' +IntToStr(Matriz_String.ColCount -2) + ' tiene que ser 1, porque el polinomio es monico';
                                   Matriz_string.Cells[1,1]:= '1';
                                   Es_Correcto:= FALSE;
                                end;
                             end else
                                     if (StrToFloat(Matriz_String.cells[1,1]) = 0) then Begin
                                        self.Preview_Memo.Lines.Text:= 'Coef: a' +IntToStr(Matriz_String.ColCount -2) + ' tiene que ser distinto de 0';
                                        Es_Correcto:= FALSE;
                                     end;
              end;
              RESULT:= Es_Correcto;
     end;
end;

Procedure TForm2.Preview();
VAR
   Pol:cls_Polin;
   i: integer;
   Es_Correcto: Boolean;

Begin
     Pol:= Cls_Polin.Crear(Matriz_String.ColCount -2);
     Es_Correcto:= TRUE;
     i:= 1;
     while((Es_Correcto) and (i<= Matriz_String.ColCount -1)) do Begin
           Es_Correcto:= Valida(i);
           if (not Es_Correcto) then
              if (Matriz_String.Cells[i,1] = '') then Begin
                 Matriz_String.Cells[i,1]:= '0';
                 Es_Correcto:= TRUE;
              end;
           inc(i);
     end;
     if (not Es_Correcto) then Begin
     //Indicar el primer coeficiente que hay q corregir...
        if (self.Ban_CoefA0) then
           self.Preview_Memo.Lines.Text:= 'Error en coef: a' + IntToStr(i -2)
        else self.Preview_Memo.Lines.Text:= 'Error en coef: a' +IntToStr(Matriz_String.Colcount -i);
     end else Begin //Es_Correcto=TRUE: ahora reviso si el coeficiente del grado Mayor es <> 0
         self.Load_Coef(Pol);
         Pol.band_A0:= self.Ban_CoefA0;
         if ((Mascara_TrackBar.Position= Mascara_TrackBar.Min) or (Mascara_TrackBar.Position= Mascara_TrackBar.Max)) then
            Pol.Masc:= 0
         else Pol.Masc:= self.Mascara_TrackBar.Position;
         self.Preview_Memo.Lines.Text:= Pol.Coef_To_String();
     end;
     Pol.Destroy();
end;

procedure TForm2.AceptarClick(Sender: TObject);
begin
     ESTA_CORRECTO:= self.Preview_Aceptar();
     if (Esta_Correcto) then Begin
        Self.Load_Coef(Polin);
        Form2.ModalResult:= MrOk; //Esta Correcto
     end;
end;

procedure TForm2.Cancel_ButtomClick(Sender: TObject);
begin
     Form2.ModalResult:= MrCancel;
end;

procedure TForm2.Mascara_TrackBarChange(Sender: TObject);
begin
      if ((Mascara_TrackBar.Position = Mascara_TrackBar.Min) or (Mascara_TrackBar.Position = Mascara_TrackBar.Max)) then
         Label_mascara.Caption:='Optima'
      else Label_mascara.Caption:='Mascara: '+intToStr(Mascara_TrackBar.Position);
      self.Preview();
end;

procedure TForm2.Preview_MemoMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
     If (Polin.Masc > self.Mascara_TrackBar.Min) then Begin
         Polin.Masc:= Polin.Masc -1
     end else Polin.Masc:= self.Mascara_TrackBar.Max -1;
     Mascara_TrackBar.Position:= Polin.Masc;
     self.Preview();
end;

procedure TForm2.Preview_MemoMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
     If (Polin.Masc < self.Mascara_TrackBar.Max) then Begin
         Polin.Masc:= Polin.Masc +1;
         Mascara_TrackBar.Position:= Polin.Masc;
         if Polin.Masc=self.Mascara_TrackBar.Max then Polin.Masc:= 0;
         self.Preview();
     end;
end;

procedure TForm2.Invertir_Matriz; //cambia [AN,...,A0] ---> [A0,...,AN]
var
   i, lim: integer;
   aux: string;
Begin
     //Matriz_String comienza en el subindice 0, pero la primera columna no se utiliza
     //colcount guarda la cant. de columnas, para un subind de 0..3 --> colcount =4
     if (Matriz_String.ColCount MOD 2) = 0 then //significa cantidad par de columnas de la Matriz_String
        lim:= (Matriz_String.ColCount DIV 2) -1 //lim es un elemento antes de la mitad par, porque la primera columna no se utiliza
     else lim:= (Matriz_String.ColCount DIV 2); //signifca cant impar de columnas, como no se utiliza la 0, lim queda exacto en la mitad impar de columnas
     for i:=1 to lim do begin   //i comienza en 1, porque la columna 0 no se utiliza
         //fila0: etiquetas a0..aN
         aux:= Matriz_String.cells[i,0];
         Matriz_String.cells[i,0]:= Matriz_String.cells[Matriz_String.ColCount - i,0];
         Matriz_String.cells[Matriz_String.ColCount - i,0]:= aux;
         //fila1: valores en string de los coeficientes
         aux:= Matriz_String.cells[i,1];
         Matriz_String.cells[i,1]:= Matriz_String.cells[Matriz_String.ColCount - i,1];
         Matriz_String.cells[Matriz_String.ColCount - i,1]:= aux;
     end;
end;

BEGIN
END.
