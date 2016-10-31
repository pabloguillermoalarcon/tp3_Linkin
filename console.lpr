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
    pol_n, divi,coc,rest, B,C: cls_polin;
    i: integer;
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
   writeln('Grado: ',Pol_N.Grado());
   writeln('Coef_N: ',Pol_N.coef.N);
   Pol_N.band_A0:= False;
   Pol_N.Coef.mostrar('Coef');
   WriteLN(Pol_N.Coef_To_String());

<<<<<<< HEAD
   Pol_N.Raices.Limpia(4);
   Pol_N.Raices.cells[0,0]:= -4;
   Writeln(Pol_N.Grado());
   Writeln('Raices Bairstow: ',Pol_N.Raices_To_String());
   Pol_N.Raices.Mostrar('Raices');
   Writeln('Raices Bairstow: ',Pol_N.Raices_To_String());
   Pol_N.bairstow(0.000001,-1.01,2.01,100);
   Pol_N.Raices.Mostrar('Raices');
   Writeln('Raices Bairstow: ',Pol_N.Raices_To_String());
=======
   divi:= cls_Polin.Crear(2);
   divi.Coef.cells[2]:= 1;
   divi.Coef.cells[1]:= -1;
   divi.Coef.cells[0]:= 1;
   writeln('Grado: ',divi.Grado());
   writeln('Coef_N: ',divi.coef.N);
   divi.band_A0:= False;
   divi.Coef.mostrar('Coef');
   WriteLN(divi.Coef_To_String());

   Rest:= cls_Polin.Crear(divi.Grado()-1);
   Rest.Band_A0:= False;
   Coc:= cls_Polin.Crear(Pol_N.Grado() - Divi.Grado());
   Coc.Band_A0:= False;

   Pol_N.hornerCuadratico(divi,coc,rest);

   Writeln('<<< Coc >>>');
   writeln('GradoCoc: ',coc.Grado());
   writeln('cocoef_N: ',coc.coef.N);
   coc.coef.mostrar('coef');
   WriteLN(coc.coef_To_String());

   Writeln('<<< rest >>>');
   writeln('GradoRest: ',rest.Grado());
   writeln('RestoCoef_N: ',rest.Coef.N);
   rest.Coef.mostrar('restCoef');
   WriteLN(rest.coef_To_String());
>>>>>>> 13463774332a4dc0de4ca4a65f03439f231292c6
   readln;
END.
