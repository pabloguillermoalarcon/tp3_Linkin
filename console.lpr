PROGRAM console;
{$mode objfpc}{$H+}

USES
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads, cmem
  {$ENDIF}{$ENDIF}
  PolinD, VectorD, MatrizD, Interfaces, Dialogs;

VAR
    M,M2,M3: cls_Matriz;
    V, V2: cls_vector;
    pol_n: cls_polin;
BEGIN

{************************* <<< Leeme.txt >>> ********************************

Clases:
1) VectorD.pas
2) MatrizD.pas
3) PolinD.pas
4) unit_GUI.pas(Interfaz Grafica de Usuario)

Propuesta: crear una clase (PolinD.pas) que con dos objetos un vector para coeficientes y una matriz de 2xN
para las N raices, la primera fila parte real y segunda fila con la parte imaginaria

Notas: 
N1: la 'D' en la que terminan las clases es para indicar que las estructuras son dinamicas. 
N2:Dentro de VectorD y MatrizD hay documentacion, fijense en el constructor y operaciones.
N3: existe un metodo para redimensionarlas en tiempo de ejecucion 
N4: vectord y matriz tienen metodos para mostrar su contenido con writeln
N5: PolinD basicamente es un vector dinamico de extended
  }

  //Pueden Utilizar ShowMessage para notificar de algun error en el metodo que esten construyendo
  //ShowMessage('Leer README.md para ver la propuesta de codigo, cualquier sugerencia manden al grupo de whatsapp');

   pol_N:= cls_Polin.Crear(2, 4,false);
   pol_N.Coef.cells[0]:= 1;
   pol_N.Coef.cells[1]:= 0;
   pol_N.Coef.cells[2]:= 2;
   if pol_N.band_A0 then writeln('True')
   else (writeln('False')) ;

   pol_N.Coef.mostrar('Coef: ');
   writeln('Pol= '+ Pol_N.Coef_To_String());
   readln;

END.
