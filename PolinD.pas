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
         constructor Crear(Grad: integer = 5; Mascara: integer=0; Visualizar_A0:boolean = false);
         Property Coef: cls_Vector READ Coeficientes WRITE Coeficientes;
         Property Raices: Cls_Matriz READ Nraices WRITE Nraices;
         Procedure Redimensionar(Grad: integer);
         Function Grado(): integer; //Devuelve el grado del polinomio
         procedure Copiar(Polin2: cls_Polin); //pol:= polin2
         function Clon():cls_Polin; //polin2:= pol
         procedure Invertir_Coef(); //a0,...aN ---> aN...a0
         Function Coef_To_String(): AnsiString; //comienza a mostrar de X^0...X^n si Ban_A0= true sino muestra X^n...X^0
         Function Raices_To_String(): String;
         function evaluar(x:extended):extended;
         function derivada():cls_Polin; //devuelve la derivada primera del polinomio
         function horner(divisor:Cls_Polin;var cociente:Cls_Polin;var resto:Cls_Polin):boolean;
         function ruffini(divisor:Cls_Polin;var cociente:Cls_Polin;var resto:Cls_Polin):boolean;
         function hornerCuadratico(divisor:Cls_Polin;var cociente:Cls_Polin;var resto:Cls_Polin):boolean;
         procedure PosiblesRaicesRacionales(Pol:Cls_Vector;var PRR:Cls_Vector);
         procedure PosiblesRaicesEnteras(P: Cls_Vector; var C: Cls_Vector);
         procedure Lagrangue(Pol:Cls_Vector;var cota:Cls_Vector);//Devuelve un vector con 4 valores que son las cotas, en caso de no tener una cota se retornara un 0(cero)
         procedure Laguerre(Pol:Cls_Vector;X:extended;var cota:Cls_Vector);//Devuelve un vector con 4 valores que son las cotas, en caso de no tener una cota se retornara un 0(cero)
         function cotasNewton():cls_Vector;
         procedure bairstow(error:extended; r:extended; s:extended; max_iter:integer);
  private
         function determinante():extended;//Bairstow
         procedure horner_doble(var b:Cls_polin;var c:Cls_polin; r:extended; s:extended);// Despues de hacerlo vi el de arriba xD, es para Bairstow
         procedure cuadratica(r:extended;s:extended;var r1:extended; var i1:extended;var r2:extended;i2:extended);
         Function SuperScript(indice: integer): AnsiString;
         //hornerCuad es llamado por hornerCuadratico()
         function hornerCuad(divisor:Cls_Polin;var cociente:Cls_Polin;var resto:Cls_Polin):boolean;
         function subPolin(posini:integer;cant:integer):Cls_Polin; //no le veo la necesidad de q sea publico
         //metodos de cambio de variable...
         procedure polNew1(Pol:Cls_Vector; var newPol:Cls_Vector);
         procedure polNew2(Pol:Cls_Vector;var newPol:Cls_Vector);
         procedure polNew3(Pol:Cls_Vector;var newPol:Cls_Vector);
         //SubFunciones Cotas para Newton
         function cotaSupPosNewton():extended;
         function cotaInfPosNewton():extended;
         function cotaSupNegNewton():extended;
         function cotaInfNegNewton():extended;

         //SubFunciones Cotas para Lagrange
         function cotaInfPosLagrangue(Pol:Cls_Vector):extended;
         function cotaSupNegLagrangue(Pol:Cls_Vector):extended;
         function cotaInfNegLagrangue(Pol:Cls_Vector):extended;

         //SubFunciones Cotas para Laguerre
         function cotaSupPosLaguerre(Pol:Cls_Vector;X:Extended):extended;
         function cotaSupNegLaguerre(Pol:Cls_Vector;X:Extended):extended;
         function cotaInfPosLaguerre(Pol:Cls_Vector;X:Extended):extended;
         function cotaInfNegLaguerre(Pol:Cls_Vector;X:Extended):extended;

         const SALTO=0.5;
end;

implementation
USES
    sysutils;

Constructor Cls_Polin.Crear(Grad: integer= 5; Mascara: integer= 0; Visualizar_A0: boolean= false);
Begin
     self.Coeficientes:= Cls_Vector.Crear(Grad+1);
     self.NRaices:= Cls_Matriz.Crear(2,Grad);
     self.Masc:= Mascara; // si es 0 muestra todos los digitos decimales
     self.Band_A0:= Visualizar_A0;
end;

Procedure cls_Polin.Redimensionar(Grad: integer);
Begin
     self.Coef.Redimensionar(Grad+1);
     self.NRaices.Redimensionar(2,Grad);
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

function cls_polin.clon():cls_polin;
var
	pAux:cls_Polin;
begin
	pAux:=cls_Polin.crear(self.Grado);
    pAux.copiar(self);
    result:=pAux;
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

function Cls_Polin.evaluar(x:extended):extended;
Var
   divi,coc,res: cls_Polin;
begin
    if (self.Grado() > 0) then Begin
        divi:= cls_Polin.Crear(1);
        divi.Coef.cells[1]:= 1;
        divi.Coef.cells[0]:= -X;
        coc:= cls_Polin.Crear(self.Grado() -1);
        res:= cls_Polin.Crear(0);
        self.ruffini(divi,coc,res);
        Result:= res.Coef.cells[0];
     end else Result:= self.Coef.cells[0];
end;

function cls_Polin.derivada():cls_Polin;
var
    polinAux:cls_Polin;
    i:byte;
begin
    if self.Grado>0 then
    begin
    	polinAux:=cls_Polin.crear(self.Grado-1);
        for i:=self.Grado downto 1 do
            polinAux.coef.cells[i-1]:=self.coef.cells[i]*i;
    end
    else
    begin
    	polinAux:=cls_Polin.crear(0);
    	polinAux.coef.cells[0]:=0;
    end;
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
    divAux:cls_Polin;
begin
    alfa:=divisor.Coef.cells[1];
    beta:=divisor.Coef.cells[0];
    divAux:=divisor.clon();
    divAux.Coef.xEscalar(1/alfa);
    if horner(divAux,cociente,resto) then
    begin
        cociente.Coef.xEscalar(1/alfa);
    	result:= true;
	end
	else
    	result:=false;
end;

function Cls_Polin.hornerCuad(divisor:Cls_Polin;var cociente:Cls_Polin;var resto:Cls_Polin):boolean;
//pagina 52 de la carpeta
var
    i:byte;
	alfa,beta:extended;
    polinC:cls_Polin;
begin
    if (self.Grado>=2) and (divisor.Grado=2) and (divisor.coef.cells[2]=1.0) then
    begin
    	alfa:=divisor.coef.cells[1];
        beta:=divisor.coef.cells[0];
        //definimos C(n+1) -Ver carpeta teórica
        polinC:=cls_Polin.crear(self.Grado);
        i:=self.Grado;	//i=n de la carpeta teorica
        polinC.coef.cells[i]:=self.coef.cells[i];
        polinC.Coef.cells[i-1]:=(-alfa)*polinC.coef.cells[i]+self.coef.cells[i-1];
        for i:=self.Grado-2 downto 1 do
            polinC.Coef.cells[i]:=	polinC.Coef.cells[i+1]*(-alfa)+
            						polinC.coef.cells[i+2]*(-beta)+
                                    self.Coef.cells[i];
        polinC.coef.cells[0]:=polinC.coef.cells[2]*(-beta)+self.Coef.cells[0];
        //polinC Guarda cociente(x)+resto(x)
        resto:=polinC.subPolin(0,2);
        cociente:=polinC.subPolin(2,self.Grado-1);
        result:=true;
    end
    else
    	result:= false;
end;

function Cls_Polin.hornerCuadratico(divisor:Cls_Polin;var cociente:Cls_Polin;var resto:Cls_Polin):boolean;
var
    alfa:extended;
    divAux:cls_polin;
begin
    alfa:=divisor.Coef.cells[2];
    divAux:=divisor.clon();
	divAux.Coef.xEscalar(1/alfa);
    if self.hornerCuad(divAux,cociente,resto) then
    begin
    	cociente.Coef.xEscalar(1/alfa);
        result:=true;
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
      B.cells[k]:= A.cells[k]+(B.cells[k-1]*X);
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
  i,j:integer;
begin
  j:=0;
  if (num<>1) and (num<>-1)then
    if num<>0 then
      begin
        Vec.cells[j]:=1;
        for i:=2 to num div 2 do
           if(num mod i = 0) then
           begin
             j:=j+1;
             Vec.cells[j]:=i;
           end;
        j:=j+1;
        Vec.cells[j]:=num;
      end
    else
      Vec.cells[j]:=0
  else
    Vec.cells[j]:=1;
  Vec.N:=j;
end;
procedure cls_Polin.PosiblesRaicesEnteras(P: Cls_Vector; var C: Cls_Vector);
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
procedure cls_Polin.PosiblesRaicesRacionales(Pol:Cls_Vector;var PRR:Cls_Vector);
var
  i,j,k:byte;
  DTI,DTP:Cls_Vector;
  TP,TI:integer;
  PR:extended;
begin
  TP:=trunc(Pol.cells[0]);//La parte entera del Termino principal
  TI:=trunc(Pol.cells[Pol.N]);//La parte entera del Termino Independiente
  if TI<>0 then
    begin
      DTI:=Cls_Vector.crear(TI+2);
      DTP:=Cls_Vector.crear(TP+2);
      detDivPos(TI,DTI);//Determina los Divisores positivos del termino Independiente
      detDivPos(TP,DTP);//Determina los Divisores positivos del termino Principal
      k:=0;//Inicializa indice k que me llevara las posiciones del vector de PRR:Posibles raices Racionales
      for i:=0 to DTI.N do//Este For maneja al vector DTI:Divisores del Termino Independiente
        for j:=0 to DTP.N do//Este for maneja al vector DTP:Divisores del Termino Principal
          begin
            PR:=DTI.cells[i]/DTP.cells[j];//calcula la PR:Posibles raiz
            if (PR<>trunc(PR)) then//Pregunta si el numero no es un entero entonces
              begin
                PRR.cells[k]:=PR;//Asigna la posible raiz positiva al vector de PRR:Posibles raices Racionales
                PRR.cells[k+1]:=-PR;//Asigna la posible raiz negativa al vector de PRR:Posibles raices Racionales
                k:=k+2;//incrementa indice k
              end;
          end;
      DTI.destroy();
      DTP.destroy();
      PRR.N:=k-1;//Asigna el tamaño o la cantidad de elementos del vector de PRR:posibles raices racionales
    end
  else
    begin
      PRR.cells[0]:=0;
      PRR.N:=0;
    end;
end;
//Este metodo se encargar de realizar el cambio de variable 1/t y multiplicarla por t^n y asi obtener un nuevo polinomio en funcion de t
procedure cls_polin.polNew1(Pol:Cls_Vector; var newPol:Cls_Vector);
var
  i:byte;
begin
  for i:=Pol.N downto 0 do
    newPol.cells[Pol.N-i]:=Pol.cells[i];
  if newPol.cells[0]<0 then
    for i:=Pol.N downto 0 do
      newPol.cells[i]:=newPol.cells[i]*-1;
end;
//Este metodo se encargar de realizar el cambio de variable -1/t y multiplicarla por t^n y asi obtener un nuevo polinomio en funcion de t
procedure cls_Polin.polNew2(Pol:Cls_Vector;var newPol:Cls_Vector);
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
  if newPol.cells[0]<0 then
    for i:=Pol.N downto 0 do
      newPol.cells[i]:=newPol.cells[i]*-1;
end;
//Este metodo se encargar de realizar el cambio de variable -t asi obtener un nuevo polinomio en funcion de t
procedure cls_Polin.polNew3(Pol:Cls_Vector;var newPol:Cls_Vector);
var
  i:byte;
begin
  for i:=0 to Pol.N do
    if (i mod 2) = 0 then
      newPol.cells[i]:=Pol.cells[i]
    else
       newPol.cells[i]:=Pol.cells[i]*-1;
  if newPol.cells[0]<0 then
    for i:=Pol.N downto 0 do
      newPol.cells[i]:=newPol.cells[i]*-1;
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
     cotaSupPosLagrangue:=1+exp((1/K)*ln(M/TP))
  else
     cotaSupPosLagrangue:=0;
end;
function cls_Polin.cotaInfPosLagrangue(Pol:Cls_Vector):extended;
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
function cls_Polin.cotaSupNegLagrangue(Pol:Cls_Vector):extended;
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
function cls_Polin.cotaInfNegLagrangue(Pol:Cls_Vector):extended;
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
procedure cls_Polin.Lagrangue(Pol:Cls_Vector;var cota:Cls_Vector);
begin
  cota.cells[0]:=cotaSupPosLagrangue(Pol);
  cota.cells[1]:=cotaInfPosLagrangue(Pol);
  cota.cells[2]:=cotaInfNegLagrangue(Pol);
  cota.cells[3]:=cotaSupNegLagrangue(Pol);
  cota.N:=3;
end;

function cls_Polin.cotaSupPosLaguerre(Pol:Cls_Vector;X:Extended):extended;
var
   B: Cls_Vector;
   i,band:byte;
begin
  B:=Cls_Vector.crear(100);
  ruffiniEvaluador(Pol,B,X);
  band:=0;
  for i:=0 to B.N-1 do
    if B.cells[i]<0 then
      band:=1;
  if band=1 then
    cotaSupPosLaguerre:=0
  else
     CotaSupPosLaguerre:=X;
  B.destroy();
end;
function cls_Polin.cotaInfPosLaguerre(Pol:Cls_Vector;X:Extended):extended;
var
   i,band:byte;
   newPol,B:Cls_Vector;
begin
  newPol:=Cls_Vector.crear(100);
  B:=Cls_Vector.crear(100);
  polNew1(Pol,newPol);
  ruffiniEvaluador(newPol,B,1/X);
  band:=0;
  for i:=0 to B.N-1 do
    if B.cells[i]<0 then
      band:=1;
  if band=1 then
    cotaInfPosLaguerre:=0
  else
     CotaInfPosLaguerre:=X;
end;

function cls_Polin.cotaSupNegLaguerre(Pol:Cls_Vector;X:Extended):extended;
var
   i,band:byte;
   newPol,B:Cls_Vector;
begin
  newPol:=Cls_Vector.crear(100);
  B:=Cls_Vector.crear(100);
  polNew2(Pol,newPol);
  ruffiniEvaluador(newPol,B,-1/X);
  band:=0;
  for i:=0 to B.N-1 do
    if B.cells[i]<0 then
      band:=1;
  if band=1 then
    cotaSupNegLaguerre:=0
  else
     CotaSupNegLaguerre:=X;
end;
function cls_Polin.cotaInfNegLaguerre(Pol:Cls_Vector;X:Extended):extended;
var
  i,band:byte;
  newPol,B:Cls_Vector;
begin
  newPol:=Cls_Vector.crear(100);
  B:=Cls_Vector.crear(100);
  polNew3(Pol,newPol);
  ruffiniEvaluador(newPol,B,-1*X);
  writeln(b.N);
  writeln(b.cells[0]);
  writeln(b.cells[1]);
  writeln(b.cells[2]);
  writeln(b.cells[3]);
  writeln(b.cells[4]);
  band:=0;
  for i:=0 to B.N-1 do
    if B.cells[i]<0 then
      band:=1;
  if band=1 then
    cotaInfNegLaguerre:=0
  else
     CotaInfNegLaguerre:=X;
end;
procedure cls_Polin.Laguerre(Pol:Cls_Vector;X:extended;var cota:Cls_Vector);
begin
  cota.cells[0]:=cotaSupPosLaguerre(Pol,X);
  cota.cells[1]:=cotaInfPosLaguerre(Pol,X);
  cota.cells[2]:=cotaSupNegLaguerre(Pol,X);
  cota.cells[3]:=cotaInfNegLaguerre(Pol,X);
  cota.N:=3;
end;  
function cls_Polin.cotaSupPosNewton():extended;
var
	pAux:cls_Polin;
    band:boolean;
    x:extended;
begin
	band:=false;
    x:=0;
    while (not band) do
    begin
    	pAux:=self.clon();
	    while (pAux.evaluar(x)>0) and (pAux.Grado > 0)do
        	pAux:=pAux.derivada;
        if (pAux.evaluar(x)>0) and (pAux.Grado=0) then
        	band:=true
        else
        	x:=x+SALTO; //SALTO: constante definida en la clase cls_Polin
        pAux.destroy;
	end;
	result:=x;
end;

function cls_Polin.cotaInfPosNewton():extended;
var
    pAux:cls_Vector;
    cota:extended;
begin
     pAux:= cls_Vector.crear(self.Grado()+1);
     PolNew1(self.Coef,Paux);
    if (pAux.cells[pAux.N]<0) then
    	pAux.xEscalar(-1);
    cota:=self.cotaSupPosNewton();
    if cota>0 then
    	result:=1/cota
    else
        result:=0;
end;

function cls_Polin.cotaSupNegNewton():extended;
var
    pAux:cls_vector;
    cota:extended;
begin
     pAux:= cls_Vector.crear(self.Grado()+1);
     polNew2(self.coef,Paux);
    if (pAux.cells[pAux.N]<0) then
    	pAux.xEscalar(-1);
    cota:=self.cotaSupPosNewton();
    if cota>0 then
    	result:=-1/cota
    else
        result:=0;
end;

function cls_Polin.cotaInfNegNewton():extended;
var
    pAux:cls_vector;
    cota:extended;
begin
     pAux:= cls_Vector.crear(self.Grado()+1);
	self.polNew3(self.Coef, pAux);
    if (pAux.cells[pAux.N]<0) then
    	pAux.xEscalar(-1);
    cota:=self.cotaSupPosNewton();
    if cota>0 then
    	result:=cota*(-1)
    else
        result:=0;
end;

function cls_Polin.cotasNewton():cls_Vector;
var
    vector:cls_Vector;
    cotaSupPos,cotaInfPos,cotaSupNeg,cotaInfNeg:extended;
begin
	vector:=cls_Vector.crear(4);
    cotaSupPos:=self.cotaSupPosNewton();
    cotaInfPos:=self.cotaInfPosNewton();
    cotaSupNeg:=self.cotaSupNegNewton();
    cotaInfNeg:=self.cotaInfNegNewton();
    if (cotaSupPos<cotaInfPos) then //cotas cruzadas
    begin
    	cotaSupPos:=0;
        cotaInfPos:=0;
	end;
    if (cotaSupNeg<cotaInfNeg) then //cotas cruzadas
    begin
    	cotaSupPos:=0;
        cotaInfPos:=0;
	end;
    vector.cells[3]:=cotaSupPos;
    vector.cells[2]:=cotaInfPos;
    vector.cells[1]:=cotaSupNeg;
    vector.cells[0]:=cotaInfNeg;
    result:=vector;
end;

procedure Cls_Polin.horner_doble(var b:Cls_polin;var c:Cls_polin; r:extended; s:extended);
var
    aux:cls_polin;
    m,i:integer;
    num,num2,num3:extended;
begin
    m:=self.Grado();
    aux:=self.Clon();
    b.Coef.Limpia(0);
    c.Coef.Limpia(0);
    b.Coef.cells[m]:=aux.Coef.cells[m];
    c.Coef.cells[m]:=b.Coef.cells[m];
    num:=r*b.Coef.cells[m];
    b.Coef.cells[m-1]:=aux.coef.cells[m-1]+num;
    num2:=(s)*c.Coef.cells[m];
    c.Coef.cells[m-1]:=b.coef.cells[m-1]+num2;

    for i:=m-2 downto 0 do
        begin
            num:=aux.Coef.cells[i];
            num2:=r*b.Coef.cells[i+1];
            num3:=s*b.Coef.cells[i+2];
            b.Coef.cells[i]:=num+num2+num3;
            num:=b.Coef.cells[i];
            num2:=r*c.Coef.cells[i+1];
            num3:=s*c.Coef.cells[i+2];
            c.Coef.cells[i]:=num+num2+num3;
        end;
    aux.Destroy;
end;

function cls_polin.determinante():extended;

begin
    result:=self.Coef.cells[2]*self.Coef.cells[2]-self.Coef.cells[3]*self.Coef.cells[1];
end;

procedure cls_polin.cuadratica(r:extended;s:extended;var r1:extended; var i1:extended;var r2:extended;i2:extended);

var
    disc:extended;
begin
    disc:=r*r+4*s;
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
    bu:boolean;
    num,num2:extended;
begin
    a:=cls_polin.Crear(self.Grado(),0,false);
    b:=cls_polin.Crear(self.Grado()+1,0,false);
    c:=cls_polin.Crear(self.Grado()+1,0,false);
    a:=self.Clon();
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
            r1:=0;
            i1:=0;
            r2:=0;
            i2:=0;
            self.cuadratica(r,s,r1,i1,r2,i2);
            self.Nraices.cells[0,a.Grado()]:=r1;
            self.Nraices.cells[1,a.Grado()]:=i1;
            self.Nraices.cells[0,a.Grado()-1]:=r2;
            self.Nraices.cells[1,a.Grado()-1]:=i2;

            for i:=0 to a.Grado()-2 do;
                a.Coef.cells[i]:=b.Coef.cells[i+2];
            a.Coef.Redimensionar(Grado()-1);
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
    a.Destroy;
    b.Destroy;
    c.Destroy;
end;

Function cls_Polin.Raices_To_String(): String;
Var
    cad: String;
    i: integer;
Begin
    for i:=1 to Grado do Begin
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
