PROGRAM console;
{$mode objfpc}{$H+}

USES
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads, cmem
  {$ENDIF}{$ENDIF}
  PolinD, VectorD, MatrizD, Interfaces, Dialogs, sysutils;

VAR
    M,M2,M3: cls_Matriz;
    V, V2: cls_vector;
    pol_n, divi,coc,rest: cls_polin;
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

   pol_N:= cls_Polin.Crear(4);
   pol_N.Coef.cells[4]:= 1;
   pol_N.Coef.cells[3]:= 5;
   pol_N.Coef.cells[2]:= 15;
   pol_N.Coef.cells[1]:= 5;
   pol_N.Coef.cells[0]:= -26;

   Pol_N.Raices.Limpia(4);
   Pol_N.Raices.cells[0,0]:= -4;//Pol_N.bairstow(0.001,0,0,100);
   Pol_N.Raices.Mostrar('Raices');
   Writeln('Raices Bairstow: ',Pol_N.Raices_To_String());
   readln;
END.
