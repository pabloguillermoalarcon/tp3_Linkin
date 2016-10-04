program console;
{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads, cmem
  {$ENDIF}{$ENDIF}
  PolinD, VectorD, MatrizD;

begin

{************************* <<< Leeme.txt >>> ********************************


Clases:
1) VectorD.pas ------> 2) PolinD.pas
3) MatrizD.pas
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

  write('Leeme.txt');
  readln;
end.

