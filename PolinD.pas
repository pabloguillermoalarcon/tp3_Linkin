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
         Coeficientes: cls_Vector; // vector de Coeficientes [Ao,...,An]
         Nraices: cls_Matriz; //Matriz de 2 x N para las raices, Parte Real y Parte Im
  Public
         band_A0: boolean; //indica si se visualiza [a0,...,aN]=TRUE; [aN,...,a0]=FALSE
         Masc: integer; //Mascara: guarda la cantidad de decimales para mostrar cuando se convierte con Coef_To_String()
         constructor Crear(Grado: integer = 5; Mascara: integer=2; Visualizar_A0:boolean = false);
         Property Coef: cls_Vector READ Coeficientes WRITE Coeficientes;
         Property Raices: Cls_Matriz READ Nraices WRITE Nraices;
         procedure Copiar(Polin2: cls_Polin); //pol:= polin2
         Procedure Redimensionar(Grado: integer);
         procedure Invertir_Coef(); //a0,...aN ---> aN...a0
         Function Grado(): integer; //Devuelve el grado del polinomio
         Function Coef_To_String(): string; //comienza a mostrar de X^0...X^n si Ban_A0= true sino muestra X^n...X^0
         //llenar con los metodos
         function horner(divisor:Cls_Polin;var cociente:Cls_Polin;var resto:Cls_Polin):boolean;//Horner Doble
         function ruffini(divisor:Cls_Polin;var cociente:Cls_Polin;var resto:Cls_Polin):boolean;//Horner
         //ej: Procedure bairstrow(r,s); Tiene que cargar las raices directamente en la matriz Raices
end;

implementation
USES
    sysutils;

Constructor Cls_Polin.Crear(Grado: integer= 5; Mascara: integer= 2; Visualizar_A0: boolean= false);
Begin
     self.Coeficientes:= Cls_Vector.Crear(Grado+1);
     self.NRaices:= Cls_Matriz.Crear(2,Grado+1);
     self.Masc:= Mascara; // si es 0 muestra todos los digitos decimales
     self.Band_A0:= Visualizar_A0;
end;

Procedure cls_Polin.Redimensionar(Grado: integer);
Begin
     self.Coef.Redimensionar(Grado+1);
     self.NRaices.Redimensionar(2,Grado+1);
end;

//si las mascara es 0 muestra todos los digitos
//comienza a mostrar de X^0...X^N
function cls_Polin.coef_To_String():string;
Var
   cad, expo, coefic: string;
   i: integer;
begin
     if (band_A0) then Begin;
{[1,1,2,0] N=3;--->1+X+2*X^2+0*X^3
[0,0,2,0] N=3;---> 2*X^2}
     for i:=0 to Coef.N do
         if (coef.cells[i]<>0) then Begin // si el coeficiente es 0 no muestra: 0*X^expo
            if (self.Masc = 0) then
               coefic:= FloatToStr(abs(coef.cells[i]))//Convierte de extended a string(coefic)
            else STR(abs(coef.cells[i]):0:self.Masc, coefic);//Convierte de extended a string(coefic)

            //Agregar signo +/-
            if (coef.cells[i]> 0) then begin //coef <>0 y positivo
               if (0<i) then coefic:=' + ' + coefic; //si es el primero no agrega un signo (+)
            end else if (0<i) then coefic:=' - '+coefic //coef <>0 y negativo
                 else coefic:='- '; //signo(-) sin espacio al comienzo

            case (i) of
                 0: cad:= coefic; //coef*X^0 --->coef
                 1: Begin
                         if (self.Coef.cells[i] = 1) then cad:= cad+'+ X'
                         else cad:= cad + coefic + '*X'; //coef*X^1 --->coef*X
                 end else begin //coef*X^i
                          STR(i,expo);
                          if (self.Coef.cells[i] = 1) then cad:= cad + '+ X^'+expo
                          else cad:= cad + coefic+'*X^'+expo;
                 end;
            end;//end case
         end; // si el coeficiente es 0 no muestra: 0*X^expo
end else Begin  (*band_A0=FALSE*)
{[1,1,2,0] N=3;--->0*X^3+2*X^2+X+1
[0,0,2,0] N=3;---> 2*X^2}
     for i:= Coef.N downto 0 do
         if (coef.cells[i]<>0) then Begin // si el coeficiente es 0 no muestra: 0*X^expo
            if (self.Masc = 0) then
               coefic:= FloatToStr(abs(coef.cells[i]))//Convierte de extended a string(coefic)
            else STR(abs(coef.cells[i]):0:self.Masc, coefic);//Convierte de extended a string(coefic)

            //Agregar signo +/-
            if (coef.cells[i]> 0) then begin //coef <>0 y positivo
               if (i < coef.N) then coefic:=' + ' + coefic; //si no es el primero agrega un signo (+)
            end else if (i < coef.N) then coefic:=' - ' + coefic //coef <>0 y negativo
                 else coefic:='- ' + coefic; //signo(-) sin espacio al comienzo

            case (i) of
                 0: cad:= cad + coefic; //coef*X^0 --->coef
                 1: Begin
                      if (self.Coef.cells[i]=1) then cad:= cad + '+ X'
                      else cad:= cad + coefic + '*X'; //coef*X^1 --->coef*X
                 end else begin //coef*X^i
                         STR(i,expo);
                         if (self.Coef.cells[i]=1) then
                            if i<coef.N then
                               cad:= cad + '+ X^'+expo
                            else cad:= cad + 'X^'+expo
                         else cad:= cad + coefic+'*X^'+expo;
                 end;
            end;//end case
         end; // si el coeficiente es 0 no muestra: 0*X^expo
end;
    RESULT:= cad;
end;

procedure cls_polin.invertir_coef(); //a0,...aN ---> aN...a0
var
   i, lim: integer;
Begin
     //el vec comienza en el sub indice 0
     if (Coef.N MOD 2) = 0 then //sig cantidad impar de elementos
        lim:= (Coef.N DIV 2) -1 //lim es un elemento antes de la mitad par
     else lim:= (Coef.N DIV 2); //sig cant par de elemtos
     for i:=0 to lim do
         Coef.Intercambiar(i, coef.N - i);
end;

procedure cls_polin.copiar(polin2: cls_Polin); //pol:= pol2
Begin
          self.Coef.Copiar(polin2.Coef);
          self.Raices.copiar(polin2.Raices);
end;

function cls_polin.Grado():integer;
Begin
     RESULT:= self.Coef.N;
end;

function Cls_Polin.horner(divisor:Cls_Polin;var cociente:Cls_Polin;var resto:Cls_Polin):boolean;
var
    i:byte;
    alfa:Extended;
begin
	if ((divisor.coef.N=1) and (divisor.Coef.cells[1]=1.0)) then
	begin
        alfa:=divisor.Coef.cells[0];
		cociente:=Cls_Polin.crear(self.coef.N);
        i:=self.coef.N;
   	    cociente.Coef.cells[i-1]:=self.Coef.cells[i];
        for i:=i-1 downto 1 do
        begin
        	cociente.Coef.cells[i-1]:=-alfa*cociente.coef.cells[i]+self.Coef.cells[i];
    	end;

		resto:=Cls_Polin.crear(1);
        resto.Coef.cells[0]:=-alfa*cociente.coef.cells[0]+self.Coef.cells[0];
		result:=true;
	end
	else
		result:=false;
end;

function Cls_Polin.ruffini(divisor:Cls_Polin;var cociente:Cls_Polin;var resto:Cls_Polin):boolean;
var
    beta,alfa:extended;
begin
    alfa:=divisor.Coef.cells[1];
    beta:=divisor.Coef.cells[0];

    divisor.coef.cells[1]:=1;
    divisor.coef.cells[0]:=beta/alfa;
    if horner(divisor,cociente,resto) then
    begin
        cociente.Coef.xEscalar(alfa);
        resto.Coef.xEscalar(alfa);
    	result:= true;
	end
	else
    	result:=false;
end;

BEGIN
END.
