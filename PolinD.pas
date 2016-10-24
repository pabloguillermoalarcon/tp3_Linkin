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
         function determinante():extended;
         procedure cuadratica(r:extended;s:extended;var r1:extended; var i1:extended;var r2:extended;i2:extended);
         procedure horner_doble(var b:Cls_polin;var c:Cls_polin; r:extended; s:extended);// Despues de hacerlo vi el de arriba xD
         procedure bairstow(error:extended; r:extended; s:extended; max_iter:integer);
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

procedure Cls_Polin.horner_doble(var b:Cls_polin;var c:Cls_polin; r:extended; s:extended);
var
    aux:cls_polin;
    m,i:integer;
begin
    m:=self.Grado();
    aux.Crear(m,2,false);
    aux.Copiar(self);
    b.Redimensionar(self.Grado());
    c.Redimensionar(self.Grado());
    b.Coef.Limpia(0);
    c.Coef.Limpia(0);
    b.Coef.cells[m]:=aux.Coef.cells[m];
    b.Coef.cells[m-1]:=aux.coef.cells[m-1]+r*b.Coef.cells[m];
    c.Coef.cells[m]:=b.Coef.cells[m];
    c.Coef.cells[m-1]:=b.coef.cells[m-1]+s*c.Coef.cells[m];

    for i:=m-2 downto 0 do
        begin
            b.Coef.cells[i]:=aux.Coef.cells[i]+r*b.Coef.cells[i+1]+s*b.Coef.cells[i+2];
            c.Coef.cells[i]:=b.Coef.cells[i]+r*c.Coef.cells[i+1]+s*c.Coef.cells[i+2];
        end;
end;

function cls_polin.determinante():extended;

begin
    result:=self.Coef.cells[2]*self.Coef.cells[2]-self.Coef.cells[3]*self.Coef.cells[1];
end;

procedure cls_polin.cuadratica(r:extended;s:extended;var r1:extended; var i1:extended;var r2:extended;i2:extended);

var
    disc:extended;
begin
    disc:=r*r-4*s;
    if disc >= 0 then
        begin
            r1:=(r+Sqrt(disc))/2;
            i1:=0;
            r2:=(r-Sqrt(disc))/2;
            i2:=0;
        end
    else
        begin
            r1:=r/2;
            r2:=r/2;
            i1:=Sqrt(abs(disc))/2;
            i2:=-i1;
        end;
end;

procedure Cls_Polin.bairstow(error:extended; r:extended; s:extended; max_iter:integer);

var
    a:cls_polin;
    b:cls_polin;
    c:cls_polin;
    err_a1:extended;
    err_a2:extended;
    det:extended;
    dr:extended;
    ds:extended;
    iter:integer;
    r1:extended;
    i1:extended;
    r2:extended;
    i2:extended;
    i:integer;

begin
    a.Crear(self.Grado(),2,false);
    b.Crear(self.Grado(),2,false);
    c.Crear(self.Grado(),2,false);
    a.Copiar(self);
    err_a1:=1;
    err_a2:=2;
    iter:=0;
    while ((a.Grado()>2)and(iter<max_iter))do
        begin
            iter:=0;
            repeat
                begin
                    iter:=iter+1;
                    a.horner_doble(b,c,r,s);
                    det:=c.determinante();
                    if det<>0 then
                        begin
                            dr:=(-b.Coef.cells[1]*c.Coef.cells[2]+b.Coef.cells[0]*c.Coef.cells[3])/det;
                            ds:=(-b.Coef.cells[0]*c.Coef.cells[2]+b.Coef.cells[1]*c.Coef.cells[1])/det;
                            r:=r+dr;
                            s:=s+ds;
                            if r<>0 then
                                err_a1:=abs(dr/r)*100;
                            if s<>0 then
                                err_a2:=abs(ds/s)*100;
                        end
                    else
                        begin
                            r:=r+1;
                            s:=s+1;
                            iter:=0;
                        end;
                end;
            until (((err_a1<=error)and(err_a2<=error))or(iter<max_iter));
            self.cuadratica(r,s,r1,i1,r2,i2);
            self.Nraices.cells[0,a.Grado()]:=r1;
            self.Nraices.cells[1,a.Grado()]:=i1;
            self.Nraices.cells[0,a.Grado()-1]:=r2;
            self.Nraices.cells[1,a.Grado()-1]:=i2;
            for i:=0 to a.Grado()-2 do;
                a.Coef.cells[i]:=b.Coef.cells[i+2];
            a.Redimensionar(a.Grado()-2);
        end;
    if iter<max_iter then
        begin
           if a.Grado()=2 then
               begin
                   r:=-a.Coef.cells[1]/a.Coef.cells[2];
                   s:=-a.Coef.cells[0]/a.Coef.cells[2];
                   self.cuadratica(r,s,r1,i1,r2,i2);
                   self.Nraices.cells[0,a.Grado()]:=r1;
                    self.Nraices.cells[1,a.Grado()]:=i1;
                    self.Nraices.cells[0,a.Grado()-1]:=r2;
                    self.Nraices.cells[1,a.Grado()-1]:=i2;
               end
           else
               begin
                   self.Nraices.cells[0,a.Grado()]:=-a.Coef.cells[0]/a.Coef.cells[1];
                   self.Nraices.cells[1,a.Grado()]:=0;
               end;
        end;
end;

BEGIN
END.
