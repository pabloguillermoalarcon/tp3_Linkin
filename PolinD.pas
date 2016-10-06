UNIT PolinD;
{$mode objfpc}{$H+}

INTERFACE
USES
    {$IFDEF UNIX}{$IFDEF UseCThreads}
    cthreads, cmem
    {$ENDIF}{$ENDIF}
    VectorD, MatrizD, Dialogs;

Type

  Cls_Polin= class
  Private
         Coeficientes: cls_Vector; // vector de Coeficientes
         Nraices: cls_Matriz; //Matiz de 2 x N para las raices, Parte Real y Parte Im
  Public
         Constructor crear(Grado: integer = 5);
         Procedure MostrarRaices(titulo: string = '');
         Property Coef: cls_Vector READ Coeficientes WRITE Coeficientes;
         Property Raices: cls_Matriz READ Nraices WRITE Nraices;
         //llenar con los metodos
         //ej: function bairstrow(...);
end;

implementation

constructor Cls_Polin.crear(Grado: integer = 5);
Begin
     self.Coeficientes:= cls_vector.crear(Grado);
     self.NRaices:= cls_matriz.crear(2,Grado);
end;

Procedure cls_Polin.MostrarRaices(titulo: string = '');
var
   i,j :integer;
Begin
     writeln();
     if (titulo <>'') then writeln(titulo);
     for i:=0 to Raices.numF do
         for j:=0 to Raices.NumC do
             if (j = Raices.NumC) then writeln(Raices.cells[i,j]:0:MASCARA)
             else write(Raices.cells[i,j]:0:MASCARA,' ');
end;

BEGIN
END.
