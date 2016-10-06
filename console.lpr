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
BEGIN

{************************* <<< Leeme.txt >>> ********************************

Clases:
1) VectorD.pas
2) MatrizD.pas
3) PolinD.pas
4) unit_GUI.pas(Interfaz Grafica de Usuario)

Propuesta: crear una clase (PolinD.pas) que herede de VectorD.pas,
donde se agreguen los metodos propios de los polinomios

Notas: 
N1: la 'D' en la que terminan las clases es para indicar que las estructuras son dinamicas. 
N2:Dentro de VectorD y MatrizD hay documentacion, fijense en el constructor y operaciones.
N3: existe un metodo para redimensionarlas en tiempo de ejecucion 
N4: vectord y matriz tienen metodos para mostrar su contenido con writeln
N5: PolinD basicamente es un vector dinamico de extended
N6: las raices deberian ser un objeto de la clase vectorD
N7: si son complejos, serian dos vectores, uno para la parte real y otro para la parte 
compleja respectivamente de las N raices
  }

  //Pueden Utilizar ShowMessage para notificar de algun error en el metodo que esten construyendo
  ShowMessage('Leer README.md para ver la propuesta de codigo, cualquier sugerencia manden al grupo de whatsapp');
  readln;
  M:= cls_Matriz.crear(4); M2:= cls_Matriz.crear(10); M3:= cls_Matriz.crear(4); V:= cls_Vector.crear(3);
  M.Limpia(3);
  M2.Limpia(4);
  M3.Limpia(6);

  M.Mostrar('M'); M2.Mostrar('M2'); M3.Mostrar('M3'); V.Mostrar('V');
  writeln('M1[',M.NumF,',',M.NumC,'] M2[',M2.NumF,',',M2.NumC,'] M3[',M3.NumF,',',M3.NumC,'] V[',V.N,']');

  Writeln;
  Writeln('Cambio...');
  m.copiar(m2);

  M.Mostrar('M'); M2.Mostrar('M2'); M3.Mostrar('M3'); V.Mostrar('V');
  writeln('M1[',M.NumF,',',M.NumC,'] M2[',M2.NumF,',',M2.NumC,'] M3[',M3.NumF,',',M3.NumC,'] V[',V.N,']');

  readln;


END.
