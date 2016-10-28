UNIT VectorD;
{$mode objfpc}{$H+}

INTERFACE
USES
    {$IFDEF UNIX}{$IFDEF UseCThreads}
    cthreads, cmem
    {$ENDIF}{$ENDIF}
    math, sysutils;

TYPE
Cls_Vector = class
  Private
       xCell: array of extended;
       OrdenN: integer;
       Function GetCell(i: integer): extended;
       Procedure SetCell(i: integer; num: extended);

  //en estos comentarios 'Vec' representa al objeto de la clase VectorD (this en C o self en objet pascal)
  {Advertencia: para el algebra de vectores como la suma o resta de vectores
  la clase Cls_Vector no realiza verificacion del ordenN de cada vector respectivamente
  queda a responsabilidad del usuario programador verificar que ambos sean del mismo orden
  para no producir salidas incorrectas
  Adv2: no olvidar inicializar orden N de los vectores y/o matrices antes de usar

  EJEMPLO de uso de vector:
  VAR
     A: Cls_Vector;
  BEGIN
       A:= Cls_Vector.CREAR(), por defecto N=10 // A:= Cls_Vector.crear(VALOR)
       A.cells[i]:= 4;
       A.free(); o A.destroy();

       OJO!!! si en vez de "crear" se utiliza el constructor por defecto create
       a:= Cls_Vector.create();
       a.redimensionar(VALOR); ---> si o si, sino el vector apunta a nill
  END.}


  Public
       //************************************************************/
       //************************************************************/
        constructor crear(cant: integer = 10); //por defecto crea un vector con 10 elementos, num es opcional
        Property cells[i: integer]: extended READ GetCell WRITE SetCell;
        Property N: integer READ OrdenN WRITE OrdenN; //N
        Function Norma_1(): extended;//SUM(abs(i)), i=1..N
        Function Norma_2(): extended;//euclidea sqrt(SUM(i^2)), i=1..N
        Function Norma_Infinita(): extended; //MAYOR(abs(i)), i=1..N
        Procedure Opuesto(); //Vec:= -Vec;
        Procedure Opuesto(vecX: Cls_Vector); //Vec:= -VecX;
        Procedure xEscalar(num: extended);//Vec:= num*Vec[i], i=1..N;
        Function Indice_Mayor_abs(): integer; //devuelve el indice del mayor numero dentro del vector en valor absoluto
        Function Indice_Mayor(): integer; //devuelve el indice del mayor numero dentro del vector
        Procedure Limpia(k: extended = 0);//Llena de un num k, por defecto cero al vector
        //Redimensiona vector dinamico agrandando el vector o perdiendo elementos al achicar segun sea el caso
        Procedure Redimensionar(cant: integer);
        Procedure Intercambiar(const i: integer; const j: integer);
        Procedure eliminaX(const pos: integer);
        Procedure insertarX(const elemento: extended; const pos: integer);
        function subVector(posini:integer; cant:integer):Cls_Vector; //retorna un sub-Vector (desde, cantidad);
        {Muestra el vector por consola (usando Write), por defecto en Horizontal, con opcion
        de mandar como parametro entero 1 para que lo muestre vertical al vector
        Ejemplos:
        vecA.mostrar(); ----> muestra horizontal
        vecA.mostrar(0); ----> muestra horizontal
        vecA.mostrar(cualquier valor entero <> 1); ----> muestra Horizontal
        vecA.mostrar(1); ----> muestra vertical        
        vecA.mostrar('titulo')----> muestra horizontal con titulo
        vecA.mostrar('titulo', cualquier valor entero <> 1); ----> muestra Horizontal con titulo
        vecA.mostrar('titulo',1)----> muestra vertical con titulo}
        Procedure mostrar(titulo: String = ''; s: byte = 0; mascara: integer =2); //consola
        procedure mostrar(s: byte); //consola

        {OJO!!! al ser un objetos si realizamos VecA:= VecB en el programa directamente,
        copia los punteros y no los atributos de los objetos respectivamente por eso
        es obligatorio usar el siguiente procedimiento}
        Procedure Copiar(VecX: Cls_Vector); //copia elemento a elemento---> Vec:= VecX;

        //Se pueden usar Para sumar o restar (usando Opuesto)
        Procedure Suma(VecA, VecB : Cls_Vector); //Vec:= VecA + VecB;
        Procedure Suma(VecX: Cls_Vector); //Vec:= Vec + VecX;
        Function ToString(mascara: byte = 0):String;
  end;



implementation

//**************************************************************
//***********************VECTORES*******************************
//**************************************************************
constructor Cls_Vector.crear(cant: integer = 10);
Begin
     SetLength(xCell, cant); //crea elementos desde 0 hasta Len-1
     OrdenN:= cant-1;
     limpia();
end;

Procedure Cls_Vector.setCell(i: integer; num: extended);
Begin
     xCell[i]:= num
end;

Function Cls_Vector.getCell(i: integer): extended;
Begin
     RESULT:= xCell[i];
end;

Procedure Cls_Vector.Redimensionar(cant: integer);
Begin
     setlength(xCell, cant);
     N:= cant -1;

end;

Procedure Cls_Vector.Intercambiar(const i: integer; const j: integer);
VAR
   aux: extended;
Begin
     if ((0<= i) and (i<= N)) then Begin
        if ((0<= j) and (j<= N)) then Begin
           if (i<>j) then begin
              aux:= cells[i];
              cells[i]:= cells[j];
              cells[j]:= aux;
           end
        end else writeln('Error intercambiar... posicion j = ',j,' incorrecta...');
     end else writeln('Error intercambiar... posicion i = ',i,' incorrecta...');

end;

Procedure Cls_Vector.eliminaX(const pos: integer);
VAR
   i:integer;
Begin
     if ((0<= pos) and (pos<= N)) then begin
        for i:= pos to N-1 do
            cells[i]:= cells[i+1];
        Redimensionar(N);
     end else writeln('Error eliminaX... posicion: ',pos,' incorrecta...')
end;

Procedure Cls_Vector.insertarX(const elemento: extended; const pos: integer);
VAR
   i: integer;
Begin
     if ((0<= pos) and (pos<= N)) then begin
        Redimensionar(N+2);
        for i:=N downto pos+1 do
            cells[i]:= cells[i-1];
        cells[pos]:= elemento;
     end else writeln('Error insertarX... posicion: ',pos,' incorrecta...')


end;

Procedure Cls_Vector.Limpia(k: extended = 0);//Llena de un num k, por defecto cero al vector
var
   i: integer;
Begin
     for i:=0 to N do
         cells[i]:= k;
end;

procedure Cls_Vector.mostrar(titulo:String=''; s: byte = 0; mascara: integer =2); //consola
VAR
   i:integer;
Begin
     writeln;
     if (titulo <>'') then writeln(titulo);
     if (s = 1) then //muestra vertical
        for i:= 0 to N do
            writeln(cells[i]:0:MASCARA)
     else begin//muestra horizontal por defecto, con cualquier valor en s <>1
        for i:= 0 to N do
            write(cells[i]:0:MASCARA,' ');
        writeln;
        end;
end;
procedure Cls_Vector.mostrar(s: byte); //consola
VAR
   i:integer;
Begin
     writeln;
     if (s = 1) then //muestra vertical
        for i:= 0 to N do
            writeln(cells[i]:0:2)
     else begin//muestra horizontal por defecto, con cualquier valor en s <>1
        for i:= 0 to N do
            write(cells[i]:0:2,' ');
        writeln;
     end;
end;

{Calculo de la norma infinita}
function Cls_Vector.Norma_Infinita ():extended;
var
	i:integer;
	mayor : extended;
begin
	mayor:=0;
	for i:=0 to N do
		if (Abs(cells[i]) > mayor) then
			mayor:=Abs(cells[i]);

	Result:= mayor;
end;

function Cls_Vector.Norma_2 ():extended;
var
	i:integer;
	resu:extended;
begin
	resu:=0;
	for i:=0 to N do
		resu:= resu + power(cells[i],2);

	Result:= power(resu,(1/2));
end;

function Cls_Vector.Norma_1():extended;
var
	i:integer;
	resu:extended;
begin
	resu:= 0;
	for i:= 0 to N do
	    resu:= resu + Abs(cells[i]);

	Result:= resu;
end;

//El procedimiento modifica el vector cambiandolo por su opuesto
//vec:= -vec
procedure Cls_Vector.Opuesto();
var
	i: integer;
begin
	for i:=0 to N do
		cells[i]:= (-1)*cells[i];
end;

//vec:= -VecX
Procedure Cls_Vector.Opuesto(vecX: Cls_Vector); //Vec:= -VecX;
begin
        self.copiar(vecX);
        self.opuesto();
end;

//VecX:= VecA + VecB;
Procedure Cls_Vector.Suma(VecA, VecB : Cls_Vector);
var
	i: integer;
begin
     if (VecA.N = VecB.N) then begin
     for i:= 0 to N do
		cells[i] := vecA.cells[i] + vecB.cells[i];

     end else writeln('cls_Vector: Error Suma :Los vectores son de distinto tam. ');
end;

//VecX:= VecX + Vec;
Procedure Cls_Vector.Suma(VecX: Cls_Vector);
Var
     i: integer;
begin
     if (N = VecX.N) then begin
     for i:=0 to N do
                cells[i]:= cells[i] + vecX.cells[i];
     end else writeln('cls_Vector: Error Suma :Los vectores son de distinto tam.');
end;

Function Cls_Vector.ToString(mascara: byte = 0):String;
Var
     i: integer;
     cad,aux: string;
Begin
     case mascara of
     0: Begin
             for i:=0 to N do
                 cad:= cad + ' ' + FloatToStr(cells[i]);
     end;
     11: Begin
             for i:=0 to N do Begin
                 STR(cells[i],aux);
                 cad:= cad + ' ' +aux;
             end;
     end;
     else Begin
             for i:=0 to N do Begin
                 STR(cells[i]:0:Mascara, aux);
                 cad:= cad + ' ' + aux;
             end;
     end;
     end; //case
     RESULT:= cad;
end;

//efectua la suma componente a componente
Procedure Cls_Vector.copiar(vecX: Cls_Vector);
VAR
        i:integer;
Begin
     redimensionar(vecX.N+1);
     for i:=0 to N do
         cells[i]:= vecX.Cells[i];
end;

function Cls_Vector.indice_mayor_abs(): integer;
VAR
   m,i:integer;
   mayor:extended;
Begin
     m:= 0;
     mayor:= 0;
     for i:=0 to N do
         if (abs(cells[i]) > mayor) then Begin
             mayor:= abs(cells[i]);
             m:=i;
         end;

     Result:= m;
end;

function Cls_Vector.indice_mayor(): integer;
VAR
   m,i:integer;
   mayor:extended;
Begin
     m:= 0;
     mayor:= 0;
     for i:=0 to N do
         if (cells[i] > mayor) then Begin
             mayor:= cells[i];
             m:=i;
         end;

     Result:= m;
end;

Procedure Cls_Vector.xEscalar(num: extended);//Vec:= num*Vec[i], i=1..N;
var
   i:integer;
Begin
     for i:=0 to N do
         cells[i]:= num*cells[i];
end;

function Cls_Vector.subVector(posini:integer; cant:integer):Cls_Vector;
var
	vectorAux:cls_Vector;
    i:byte;
begin
	if (cant>0) and (posini>=0) and (posini+cant<=self.N+1) then
    begin
	    vectorAux:=cls_Vector.crear(cant); //vector.crear(cantidad) cantidad>=1
        for i:=0 to cant-1 do
            vectorAux.cells[i]:=self.cells[i+posini];
        result:=vectorAux;
	end
    else
    	result:=nil;
end;

BEGIN
END.
