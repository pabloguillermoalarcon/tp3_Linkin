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
}
   pol_N:= cls_Polin.Crear(4);
   pol_N.Coef.cells[4]:= 4;
   pol_N.Coef.cells[3]:= 0;
   pol_N.Coef.cells[2]:= -5;
   pol_N.Coef.cells[1]:= 0;
   pol_N.Coef.cells[0]:= 1;
   {
   Pol_N.band_A0:= False;
   Pol_N.Coef.mostrar('<<Dividendo>>');
   WriteLN(Pol_N.Coef_To_String());
   writeln('Grado: ',Pol_N.Grado());

   writeln;
   divi:= cls_Polin.Crear(2);
   //divi.Coef.cells[1]:= 16;
   divi.Coef.cells[2]:= 1;
   divi.Coef.cells[1]:= -10;
   divi.Coef.cells[0]:= 0;
   divi.band_A0:= False;
   divi.Coef.mostrar('<<Divisor>>');
   WriteLN(divi.Coef_To_String());
   writeln('Grado: ',divi.Grado());
   if (pol_N.hornerCuadratico(divi,coc,rest)) then begin

   coc.band_A0:= False;
   coc.Coef.mostrar('<<Coc>>');
   WriteLN(coc.Coef_To_String());
   writeln('Grado: ',coc.Grado());

   rest.band_A0:= False;
   rest.Coef.mostrar('<<Rest>>');
   WriteLN(rest.Coef_To_String());
   writeln('Grado: ',rest.Grado());
   end else writeln('No HornerCuad...');
    }
   V:= cls_Vector.crear(4);
  V:= Pol_N.cotasNewton();
   V.mostrar('V');

END.
