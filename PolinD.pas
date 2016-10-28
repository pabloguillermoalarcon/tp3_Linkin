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
         Function SuperScript(indice: integer): AnsiString;
  Public
         band_A0: boolean; //indica si se visualiza [a0,...,aN]=TRUE; [aN,...,a0]=FALSE
         Masc: integer; //Mascara: guarda la cantidad de decimales para mostrar cuando se convierte con Coef_To_String()
         constructor Crear(Grado: integer = 5; Mascara: integer=0; Visualizar_A0:boolean = false);
         Property Coef: cls_Vector READ Coeficientes WRITE Coeficientes;
         Property Raices: Cls_Matriz READ Nraices WRITE Nraices;
         Function Grado(): integer; //Devuelve el grado del polinomio
         Procedure Redimensionar(Grad: integer);
         procedure Copiar(Polin2: cls_Polin); //pol:= polin2
         procedure Invertir_Coef(); //a0,...aN ---> aN...a0
         Function Coef_To_String(): AnsiString; //comienza a mostrar de X^0...X^n si Ban_A0= true sino muestra X^n...X^0
         Function Raices_To_String(): String;
         function subPolin(posini:integer;cant:integer):Cls_Polin;
         function horner(divisor:Cls_Polin;var cociente:Cls_Polin;var resto:Cls_Polin):boolean;
         function ruffini(divisor:Cls_Polin;var cociente:Cls_Polin;var resto:Cls_Polin):boolean;
         procedure PosiblesRaicesRacionales(Pol:Cls_Vector;var PRR:Cls_Vector);
         procedure PosiblesRaicesEnteras(P: Cls_Vector; var C: Cls_Vector);
         procedure raicesEnteras(P:Cls_Vector; var B:Cls_Vector);//Devuelve todas las raices enteras de un polinomio,en caso de no tener raices preguntar si B.N=-1
         procedure raicesRacionales(Pol:Cls_Vector; var RR:Cls_Vector);//Devuelve todas las racices racionales de un polinomio,en caso de no tener raices preguntar si B.N=0
         procedure Lagrangue(Pol:Cls_Vector;var cota:Cls_Vector);//Devuelve un vector con 4 valores que son las cotas, en caso de no tener una cota se retornara un 0(cero)
         procedure Laguerre(Pol:Cls_Vector;X:extended;var cota:Cls_Vector);//Devuelve un vector con 4 valores que son las cotas, en caso de no tener una cota se retornara un 0(cero)
         function determinante():extended;
         procedure cuadratica(r:extended;s:extended;var r1:extended; var i1:extended;var r2:extended;i2:extended);
         procedure horner_doble(var b:Cls_polin;var c:Cls_polin; r:extended; s:extended);// Despues de hacerlo vi el de arriba xD
         procedure bairstow(error:extended; r:extended; s:extended; max_iter:integer);
end;

implementation
USES
    sysutils;

Constructor Cls_Polin.Crear(Grado: integer= 5; Mascara: integer= 0; Visualizar_A0: boolean= false);
Begin
     self.Coeficientes:= Cls_Vector.Crear(Grado+1);
     self.NRaices:= Cls_Matriz.Crear(2,Grado);
     self.Masc:= Mascara; // si es 0 muestra todos los digitos decimales
     self.Band_A0:= Visualizar_A0;
end;

Procedure cls_Polin.Redimensionar(Grad: integer);
Begin
     self.Coef.Redimensionar(Grado+1);
     self.NRaices.Redimensionar(2,Grado+1);
end;

Function cls_Polin.SuperScript(indice: integer): AnsiString;
Begin
     case (indice) of
          2: RESULT:= '²';
          3: RESULT:= '³';
          4: RESULT:= '⁴';
          5: RESULT:= '⁵';
          6: RESULT:= '⁶';
          7: RESULT:= '⁷';
          8: RESULT:= '⁸';
          9: RESULT:= '⁹';
          10: RESULT:= '¹⁰';
          else RESULT:='';
     end;
end;

//si las mascara es 0 muestra todos los digitos
//comienza a mostrar de X^0...X^N
function cls_Polin.coef_To_String():AnsiString;
Var
   cad, expo, coefic,signo: AnsiString;
   i: integer;
   primer_signo: boolean;
begin
     if (band_A0) then Begin;
{[1,1,2,0] N=3;--->1+X+2*X^2+0*X^3
[0,0,2,0] N=3;---> 2*X^2}
     primer_signo:= True;
     for i:=0 to Coef.N do
         if (coef.cells[i]<>0) then Begin // si el coeficiente es 0 no muestra: 0*X^expo
            case Masc of
                 0: coefic:= FloatToStr(abs(coef.cells[i])); //Muestra solo los caracteres usados 1.0000--> 1
                 11: STR(abs(coef.cells[i]), coefic); //Muestra Todos
                 else STR(abs(coef.cells[i]):0:self.Masc, coefic);  // Muestra con Mascara
            end;
            //Agregar signo +/-
            signo:='';
            if (coef.cells[i]> 0) then begin //coef <>0 y positivo
               if (not primer_signo) then
                  signo:=' + ' //si es el primero no agrega un signo (+)
               else primer_signo:= False;
            end else Begin
                     if (not primer_signo) then
                        signo:=' - '//coef <>0 y negativo
                     else Begin
                               signo:='- '; //signo(-) sin espacio al comienzo
                               Primer_signo:= False;
                     end;
                     DELETE(coefic,0,1); //Elimino el sigo repetido de coefic y solo queda en vble signo
            end;
            case (i) of
                 0: cad:= signo + coefic; //coef*X^0 --->coef
                 else Begin
                      expo:= SuperScript(i);//Superindice
                         if ((((self.Coef.cells[i]= 1) or (self.Coef.cells[i]= -1)) and (masc=0))) then cad:= cad+signo+'x'+expo
                         else cad:= cad + signo + coefic + 'x' + expo;
                 end;
            end;//Case
         end; // si el coeficiente es 0 no muestra: 0*X^expo
end else Begin  (*band_A0=FALSE*)
{[1,1,2,0] N=3;--->0*X^3+2*X^2+X+1
[0,0,2,0] N=3;---> 2*X^2}
     for i:= Coef.N downto 0 do
         if (coef.cells[i]<>0) then Begin // si el coeficiente es 0 no muestra: 0*X^expo
            case Masc of
                 0: coefic:= FloatToStr(abs(coef.cells[i])); //Muestra solo los caracteres usados 1.0000--> 1
                 11: STR(abs(coef.cells[i]), coefic); //Muestra Todos
                 else STR(abs(coef.cells[i]):0:self.Masc, coefic);  // Muestra con Mascara
            end;
            //Agregar signo +/-
            signo:='';
            if (coef.cells[i]> 0) then begin //coef <>0 y positivo
               if (grado > i) then signo:=' + '; //si es el primero no agrega un signo (+)
            end else Begin
                     if (grado > i) then
                        signo:=' - '//coef <>0 y negativo
                     else signo:='- '; //signo(-) sin espacio al comienzo
                     DELETE(coefic,0,1); //Elimino el sigo repetido de coefic y solo queda en vble signo
            end;
            case (i) of
                 0: cad:= cad + signo + coefic; //coef*X^0 --->coef
                 else Begin
                      expo:= SuperScript(i);//Superindice
                      if ((((self.Coef.cells[i]= 1) or (self.Coef.cells[i]= -1)) and (masc=0))) then cad:= cad + signo+'x'+expo
                      else cad:= cad + signo + coefic + 'x' + expo;
                 end;
            end;//Case
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

function Cls_Polin.SubPolin(posini:integer;cant:integer):Cls_Polin;
var
	polinAux:Cls_Polin;
begin
	//no hacemos ningun tipo de control dado que
    //subVector() se encarga de esto y retorna "nil" si no cumple las cond.
	polinAux:=cls_Polin.crear(cant-1);	//polin.crear(grado)
    polinAux.Coef:=self.coef.subVector(posini,cant);
    result:=polinAux;
end;

function Cls_Polin.horner(divisor:Cls_Polin;var cociente:Cls_Polin;var resto:Cls_Polin):boolean;
var
    i:byte;
    alfa:Extended;
    //operaremos sobre polinAux para que los indices del algoritmo
    //concuerde con el de la carpeta teorica
    polinAux:cls_Polin;
begin
	if ((divisor.Grado=1) and (divisor.Coef.cells[1]=1.0)) then
	begin
        alfa:=divisor.Coef.cells[0];
		polinAux:=Cls_Polin.crear(self.grado);
   	    polinAux.Coef.cells[self.Grado]:=self.Coef.cells[self.Grado];
        for i:=self.grado-1 downto 0 do
        begin
        	polinAux.Coef.cells[i]:=-alfa*polinAux.coef.cells[i+1]+self.Coef.cells[i];
    	end;
        cociente:=polinAux.subPolin(1,self.Grado);
        resto:=polinAux.subPolin(0,1);
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

Procedure ruffiniEvaluador(A: Cls_Vector;var B: Cls_Vector; X: extended);   // A es el vector con los coeficientes del polinomio ingresado
var                                                                       // en el vector B guardamos la solucion del  metodo de Ruffini lo que seria C(x)y resto
  k:byte;
begin
  B.cells[0]:= A.cells[0];
  For k:= 1 to A.N do
      B.cells[k]:= A.cells[k]+ (B.cells[k-1]*X);
  B.N:=k;
end;
//Funcion que Evalua un polinomio
Function EvaluarPolinomio(P: Cls_Vector; X: extended): extended;
var B:Cls_Vector;
begin
  B:=Cls_Vector.crear(P.N);
  ruffiniEvaluador(P,B,X);
  EvaluarPolinomio:= B.cells[B.N];
  B.destroy();
end;
PROCEDURE detDivPos(num:integer;var Vec:Cls_Vector);
var
  i,j:byte;
begin
  j:=0;
  Vec.cells[j]:=1;
  for i:=2 to num div 2 do
    if(num mod i = 0) then
      begin
        j:=j+1;
        Vec.cells[j]:=i;
      end;
  if num<>1 then
    begin
      j:=j+1;
      Vec.cells[Vec.N]:=num;
    end;
  Vec.N:=j;
end;

procedure Cls_Polin.PosiblesRaicesEnteras(P: Cls_Vector; var C: Cls_Vector);
var ult,i:byte;
begin
  detDivPos(trunc(P.cells[P.N]),C);
  ult:=C.N;
  //En este for se agrego los divisores negativos
  for i:=0 to C.N do
    begin
      ult:=ult+1;
      C.cells[ult]:=C.cells[i]*-1;
    end;
  C.N:=ult;
end;  
procedure cls_polin.raicesEnteras(P:Cls_Vector; var B:Cls_Vector);
var i,j:integer;
    C:Cls_Vector;
begin
  j:=0;
  C:= Cls_Vector.crear(100);
  PosiblesRaicesEnteras(P,C);
  For i:=0 to C.N do
     if (EvaluarPolinomio(P,C.cells[i])=0) then
        begin
           B.cells[j]:= C.cells[i];
           j:=j+1;
        end;
  B.N:=j-1;
  C.destroy();
end;
procedure Cls_Polin.PosiblesRaicesRacionales(Pol:Cls_Vector;var PRR:Cls_Vector);
var
  i,j,k:byte;
  DTI,DTP:Cls_Vector;
  TP,TI:integer;
  PR:double;
begin
  TP:=trunc(Pol.cells[0]);//La parte entera del Termino principal
  TI:=trunc(Pol.cells[Pol.N]);//La parte entera del Termino Independiente
  DTI:=Cls_Vector.crear(2*TI);//Se multiplica por 2 pensando en que a lo sumo un numero tendra el doble de divisores y no mas ej:2 es divisor de 1,2,-1,-2
  DTP:=Cls_Vector.crear(2*TP);
  detDivPos(TI,DTI);//Determina los Divisores positivos del termino Independiente
  detDivPos(TP,DTP);//Determina los Divisores positivos del termino Principal
  k:=0;//Inicializa indice k que me llevara las posiciones del vector de PRR:Posibles raices Racionales
  for i:=0 to DTI.N do//Este For maneja al vector DTI:Divisores del Termino Independiente
    for j:=0 to DTP.N do//Este for maneja al vector DTP:Divisores del Termino Principal
      begin
        PR:=DTI.cells[i]/DTP.cells[j];//calcula la PR:Posibles raiz
        if (PR<>trunc(PR)) then//Pregunta si el numero no es un entero entonces
          begin
            k:=k+2;//incrementa indice k
            PRR.cells[k]:=PR;//Asigna la posible raiz positiva al vector de PRR:Posibles raices Racionales
            PRR.cells[k+1]:=-PR;//Asigna la posible raiz negativa al vector de PRR:Posibles raices Racionales
          end;
      end;
  DTI.destroy();
  DTP.destroy();
  PRR.N:=k;//Asigna el tamaño o la cantidad de elementos del vector de PRR:posibles raices racionales
end;
PROCEDURE cls_polin.raicesRacionales(Pol:Cls_Vector; var RR:Cls_Vector);
var
  i,j:byte;
  E:double;
  PRR:Cls_Vector;
begin
  E:=0.000001;//Error tomado en caso de que no me de exactamente cero el resto
  j:=0;//Inicia la posicion del vector RR:Raices Racionales
  PRR:=Cls_Vector.crear(100);
  PosiblesRaicesRacionales(Pol,PRR);//se devuelve un vector cargado PRR: de las Posibles Raices Racionales
  For i:=0 to PRR.N do
     if ( (EvaluarPolinomio(Pol,PRR.cells[i])>=0) and (EvaluarPolinomio(Pol,PRR.cells[i])<E) ) then
        begin
          j:=j+1;
          RR.cells[j]:=PRR.cells[i];
        end;
  PRR.destroy();
  RR.N:=j;
end;
//Este metodo se encargar de realizar el cambio de variable 1/t y multiplicarla por t^n y asi obtener un nuevo polinomio en funcion de t
procedure polNew1(Pol:Cls_Vector; var newPol:Cls_Vector);
var
  i:byte;
begin
  for i:=Pol.N downto 0 do
    newPol.cells[Pol.N-i]:=Pol.cells[i];
end;
//Este metodo se encargar de realizar el cambio de variable -1/t y multiplicarla por t^n y asi obtener un nuevo polinomio en funcion de t
procedure polNew2(Pol:Cls_Vector;var newPol:Cls_Vector);
var
  i,j:byte;
begin
  for i:=Pol.N downto 0 do
    begin
      j:=Pol.N-i;
      if (j mod 2)=0 then
        newPol.cells[j]:=Pol.cells[i]
      else
         newPol.cells[j]:=Pol.cells[i]*-1;
    end;
end;
//Este metodo se encargar de realizar el cambio de variable -t asi obtener un nuevo polinomio en funcion de t
procedure polNew3(Pol:Cls_Vector;var newPol:Cls_Vector);
var
  i:byte;
begin
  for i:=0 to Pol.N do
    if (i mod 2) = 0 then
      newPol.cells[i]:=Pol.cells[i]
    else
       newPol.cells[i]:=Pol.cells[i]*-1;
end;

//funcion que devuelve el menor coegficiente negativo del polinomio
function coefNegMenor(Pol:Cls_Vector):integer;
var
   i:byte;
   menor:integer;
begin
  menor:=0;
  for i:=0 to Pol.N do
    if Pol.cells[i] < menor then
       menor:=trunc(Pol.cells[i]);
  coefNegMenor:=menor;
end;
//funcion que devuelve el indice del primer coeficiente negativo del polinomio
function indPriCoefNeg(Pol:Cls_Vector):byte;
var
   menor,m:integer;
   i:byte;
begin
   menor:=0;
   m:=-1;
   for i:=0 to Pol.N do
     if Pol.cells[i]<menor then
        begin
          menor:=trunc(Pol.cells[i]);
          m:=i;
        end;
   indPriCoefNeg:=m;
end;
function cotaSupPosLagrangue(Pol:Cls_Vector):extended;
var
   M,K,TP:extended;
begin
  K:=indPriCoefNeg(Pol);
  M:=abs(coefNegMenor(Pol));
  TP:=Pol.cells[0];
  if (K<>-1) and (M<>0) and (TP<>0) then
     cotaSupPosLagrangue:=1+exp(1/K*ln(M/TP))
  else
     cotaSupPosLagrangue:=0;
end;
function cotaInfPosLagrangue(Pol:Cls_Vector):extended;
var
  newPol:Cls_Vector;
  t:extended;
begin
  newPol:=Cls_Vector.crear(100);
  polNew1(Pol,newPol);
  t:=cotaSupPosLagrangue(newPol);
  if t<>0 then
     cotaInfPosLagrangue:=1/t
  else
     cotaInfPosLagrangue:=0;
end;
function cotaSupNegLagrangue(Pol:Cls_Vector):extended;
var
  newPol:Cls_Vector;
  t:extended;
begin
  newPol:=Cls_Vector.crear(100);
  polNew2(Pol,newPol);
  t:=cotaSupPosLagrangue(NewPol);
  if t<>0 then
     cotaSupNegLagrangue:=-1/t
  else
     cotaSupNegLagrangue:=0;
end;
function cotaInfNegLagrangue(Pol:Cls_Vector):extended;
var
   newPol:Cls_Vector;
   t:extended;
begin
  newPol:=Cls_Vector.crear(100);
  polNew3(Pol,newPol);
  t:=cotaSupPosLagrangue(NewPol);
  if t<>0 then
     cotaInfNegLagrangue:=-t
  else
     cotaInfNegLagrangue:=0;
end;
procedure cls_polin.Lagrangue(Pol:Cls_Vector;var cota:Cls_Vector);
begin
  cota.cells[0]:=cotaSupPosLagrangue(Pol);
  cota.cells[1]:=cotaSupNegLagrangue(Pol);
  cota.cells[2]:=cotaInfNegLagrangue(Pol);
  cota.cells[3]:=cotaSupNegLagrangue(Pol);
end;




function cotaSupPosLaguerre(Pol:Cls_Vector;X:Extended):extended;
var
   B: Cls_Vector;
   i:byte;
begin
  B:=Cls_Vector.crear(100);
  ruffiniEvaluador(Pol,B,X);
  i:=0;
  while(i<=B.N-1) and (B.cells[i]<0) do//Ponemos B.N-1 porque no quiero analizar el resto
      i:=i+1;
  if i>B.N-1 then
     CotaSupPosLaguerre:=X
  else
     cotaSupPosLaguerre:=0;
end;
function cotaInfPosLaguerre(Pol:Cls_Vector;X:Extended):extended;
var
   i:byte;
   newPol,B:Cls_Vector;
begin
  newPol:=Cls_Vector.crear(100);
  B:=Cls_Vector.crear(100);
  polNew1(Pol,newPol);
  ruffiniEvaluador(newPol,B,1/X);
  i:=0;
  while(i<=B.N-1) and (B.cells[i]<0) do//Ponemos B.N-1 porque no quiero analizar el resto
      i:=i+1;
  if i>B.N-1 then
     CotaInfPosLaguerre:=X
  else
     cotaInfPosLaguerre:=0;
end;
function cotaSupNegLaguerre(Pol:Cls_Vector;X:Extended):extended;
var
   i:byte;
   newPol,B:Cls_Vector;
begin
  newPol:=Cls_Vector.crear(100);
  B:=Cls_Vector.crear(100);
  polNew2(Pol,newPol);
  ruffiniEvaluador(newPol,B,-1/X);
  i:=0;
  while(i<=B.N-1) and (B.cells[i]<0) do//Ponemos B.N-1 porque no quiero analizar el resto
      i:=i+1;
  if i>B.N-1 then
     CotaSupNegLaguerre:=X
  else
     cotaSupNegLaguerre:=0;
end;
function cotaInfNegLaguerre(Pol:Cls_Vector;X:Extended):extended;
var
  i:byte;
  newPol,B:Cls_Vector;
begin
  newPol:=Cls_Vector.crear(100);
  B:=Cls_Vector.crear(100);
  polNew2(Pol,newPol);
  ruffiniEvaluador(newPol,B,-1*X);
  i:=0;
  while(i<=B.N-1) and (B.cells[i]<0) do//Ponemos B.N-1 porque no quiero analizar el resto
      i:=i+1;
  if i>B.N-1 then
     CotaInfNegLaguerre:=X
  else
     cotaInfNegLaguerre:=0;
end;
procedure cls_polin.Laguerre(Pol:Cls_Vector;X:extended;var cota:Cls_Vector);
begin
  cota.cells[0]:=cotaSupPosLaguerre(Pol,X);
  cota.cells[1]:=cotaSupNegLaguerre(Pol,X);
  cota.cells[2]:=cotaInfNegLaguerre(Pol,X);
  cota.cells[3]:=cotaSupNegLaguerre(Pol,X);

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

Function cls_Polin.Raices_To_String(): String;
Var
    cad, real, imag: String;
    i: integer;
Begin
    for i:=0 to Grado do Begin
       if (Raices.cells[0,i] <>0) then //Parte Real
          cad:= cad + '  '+FloatToStr(Raices.cells[0,i]);
       if (Raices.cells[1,i] <>0) then //Parte Imag
           if Raices.cells[1,i]>0 then
               cad:= cad + '+'+FloatToStr(Raices.cells[1,i])+'i'
            else cad:= cad + FloatToStr(Raices.cells[1,i])+'i';
    end;
    Result:= cad;
end;

BEGIN
END.
