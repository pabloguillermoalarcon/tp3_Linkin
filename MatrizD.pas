UNIT MatrizD;
{$mode objfpc}{$H+}

INTERFACE
USES
    {$IFDEF UNIX}{$IFDEF UseCThreads}
    cthreads, cmem
    {$ENDIF}{$ENDIF}
    VectorD, Math;

CONST
     MASCARA = 2; //mascara para los reales con writeln

TYPE

Cls_Matriz= class
       Private
               xCell: array of array of extended;
               NF: integer; //Cantidad Filas
               NC: integer; //Cantidad Columnas
               Procedure setCell(i,j:integer; num:extended);//Fila/Columna
               Function getCell(i,j:integer):extended;



  //en estos comentarios 'Mat' representa al objeto de la clase MatrizD (this en C o self en objet pascal)
  {Advertencia: para el algebra de matrices como la suma o resta de vectores
  la clase Cls_Matriz no realiza verificacion del ordenN de cada vector respectivamente
  queda a responsabilidad del usuario programador verificar que ambos sean del mismo orden
  para no producir salidas incorrectas
  Adv2: no olvidar inicializar orden N de los vectores y/o matrices antes de usar

  EJEMPLO de uso de Matriz:
  VAR
     A: Cls_Matriz;
  BEGIN
       A:= Cls_Matriz.CREAR(), por defecto N=10; M=10

       *Se puede utilizar tambien:
       A:= Cls_Matriz.crear(N, M);
       A:= Cls_Matriz.crearN(N,M); N:=Valor y M:= Valor
       //No se recomienda utilizar el constructor generico A:= cls_Matriz.create();

       *Asignacion de celdas
       A.cells[i,j]:= 4;
       A.free(); o A.destroy();

       OJO!!! si en vez de "crear" se utiliza el constructor por defecto create
       a:= Cls_Vector.create();
       a.redimensionar(N' ,M'); ---> si o si, sino el vector apunta a nill
  END.}

       Public
              Constructor crear(filas:integer; columnas:integer);
              Constructor crear(orden:integer);   //matriz de orden N
              Property cells[i, j: integer]:extended READ getcell WRITE setCell;
              Property NumF: integer READ NF WRITE NF;
              Property NumC: integer READ NC WRITE NC;
              Procedure Limpia(k: extended = 0);//Llena de un num k, por defecto cero a la matriz
              Procedure Redimensionar(filas,columnas: integer);
              Procedure copiar(const V: Cls_Matriz); //A := V
              Procedure copiarFila(VAR Vec: Cls_Vector; const fila: integer);
              Procedure copiarColumna(VAR Vec: Cls_Vector; const columna: integer);
              Procedure Opuesto(); //Mat:= -Mat;
              Procedure Opuesto(const V: Cls_Matriz); //mat:= -V;
              Procedure elimina_fila(const fila: integer);
              Procedure elimina_columna(const columna: integer);
              Procedure insertarFila(const Vec: Cls_Vector; const fila: integer);
              Procedure insertarColumna(const Vec: Cls_Vector; const columna: integer);
              Procedure intercambiar_filas(const filaA:integer; const filaB: integer);
              Procedure intercambiar_columnas(const columnaA:integer; const columnaB: integer);
              Function son_iguales(const V:Cls_Matriz): boolean; //mat == V
              Function es_cuadrada():boolean;
              Function det():extended;
              Function NO_es_Singular():Boolean; // Det <> 0
              Function es_Simetrica():Boolean;
              Function es_Simetrica(Orden_subMatriz: integer): boolean; //Ej: Orden comienza en 0 para matrices de 1x1 elementos
              Function es_AntiSimetrica():Boolean;
              Function es_AntiSimetrica(Orden_subMatriz : integer):Boolean; //Ej: Orden comienza en 0 para matrices de 1x1 elementos
              Function es_estrictamente_diagonalmente_dominante(): boolean; //REVISAR
              Function es_definida_positiva(): boolean; //tmb false si la matriz no es cuadrada  //REVISAR
              Procedure Suma(const B: Cls_Matriz);// A = A+B
              Procedure Suma(const VecA: Cls_Matriz; const VecB : Cls_Matriz); //Vec:= VecA + VecB;
              procedure sumaF(const filaA: integer; const filaB:integer; const escalar: extended = 1);// filaA= filaA+ escalar*filaB
              procedure sumaC(const columnaA: integer; const columnaB:integer; const escalar: extended = 1);// filaA= filaA+ escalar*filaB
              Procedure xEscalar(num: extended);// mat:= num*mat, i,j=1..N;
              Procedure fila_xEscalar(const fila: integer; const escalar: extended);
              Procedure columna_xEscalar(const columna: integer; const escalar: extended);
              Function Norma_1():extended;  //REVISAR
              Function Norma_Frobenius():extended; //REVISAR
              Function Norma_Infinita():extended; //REVISAR
              Procedure Indice_Mayor(VAR i: integer; VAR j: integer);//REVISAR //devuelve el indice del mayor numero dentro de la matriz
              Procedure Indice_Mayor_abs(VAR i: integer; VAR j: integer); //REVISAR//devuelve el indice del mayor numero dentro de la matriz en abs
              Procedure Mostrar(titulo: string =''); //Limpiar pantalla antes de invocar
              Procedure Indice_Mayor_fila(const fila: integer; VAR i: integer; VAR j: integer); //REVISAR//devuelve el indice del mayor numero dentro de la fila
              Procedure Indice_Mayor_fila_abs(const fila: integer; VAR i: integer; VAR j: integer); //REVISAR//devuelve el indice del mayor numero dentro de la fila en abs
              Procedure Indice_Mayor_columna(const columna: integer; VAR i: integer; VAR j: integer); //REVISAR//devuelve el indice del mayor numero dentro de la columna
              Procedure Indice_Mayor_columna(const columna: integer; const fila: integer; VAR i: integer; VAR j: integer); //REVISAR//devuelve el indice del mayor numero dentro de la columna a partir de una fila hacia abajo
              Procedure Indice_Mayor_columna_abs(const columna: integer; VAR i: integer; VAR j: integer); //REVISAR//devuelve el indice del mayor numero dentro de la columna en abs
              Procedure Indice_Mayor_columna_abs(const columna: integer; const fila: integer; VAR i: integer; VAR j: integer);//REVISAR //devuelve el indice del mayor numero dentro de la columna a partir de una fila hacia abajo en abs
  end;


implementation

//************************************************************************
//***********************MATRICES*****************************************
//************************************************************************
constructor Cls_Matriz.crear(filas:integer; columnas:integer);
Begin
     setlength(xCell,filas,columnas);
     NumF:= filas-1;
     NumC:= columnas-1;
     limpia();
end;

constructor Cls_Matriz.crear(orden:integer);
Begin
     setlength(xCell, orden, orden);
     NumF:= orden-1;
     NumC:= orden-1;
     limpia();
end;

Procedure Cls_Matriz.setCell(i,j:integer; num:extended);//Fila/Columna
Begin
     xCell[i,j] := num;
end;

Function Cls_Matriz.getCell(i,j:integer): extended;//Fila/Columna
Begin
     RESULT:= xCell[i,j];
end;

Procedure Cls_Matriz.Redimensionar(filas, columnas: integer);
Begin
     setlength(xCell,filas,columnas);
     NumF:= filas-1;
     NumC:= columnas-1;
end;

Procedure Cls_Matriz.Mostrar(titulo: string ='');
var
   i,j :integer;
Begin
     writeln();
     if (titulo <>'') then writeln(titulo);

     for i:=0 to NumF do
         for j:=0 to NumC do
             if (j = NumC) then writeln(cells[i,j]:0:MASCARA)
             else write(cells[i,j]:0:MASCARA,' ');
end;


Procedure Cls_Matriz.Limpia(k: extended = 0);//Llena de un num k, por defecto cero a la matriz
var
   i,j : integer;
Begin
     for i:=0 to numF do
         for j:=0 to numC do
             cells[i,j]:= k;

end;


 { Calcula la determinante por el metodo de eliminacion de filas y columnas}
function Cls_Matriz.det():extended;
//function determinante (cells:Matriz;numF:integer): real;

Var
   n,i,j:integer;
   deter:extended;
   Baux: cls_Matriz;

Begin
     Baux:= cls_Matriz.crear(numF,numF);

     Case NumF of
     0: begin
              RESULT:= cells[0,0](*el caso más básico*)
     end; (*case 1*)
     1: begin
         RESULT:= cells[0,0] * cells[1,1] - cells[0,1] * cells[1,0] (*caso base para la recursividad*)
     end; (*case 1*)
     else begin (*case >= 3*)
               deter:= 0;
               for n:= 0 to numF do begin
               (*carga la matriz B con los valores, que quedan eliminando la fila y columna*)
                   for i:= 1 to numF do begin
                             for j:= 0 to n-1 do (*correspondiente de la matriz cells*)
                                 Baux.cells[i-1,j]:= cells[i,j];
                                 for j:= n+1 to numF do
                                     Baux.cells[i-1,j-1]:= cells[i,j];
                   end;
                   if (1+n) mod 2= 0 then i:=1 (*Signo del complemento algebraico*)
                   else i:= -1;
                   deter:= deter + i * cells[0,n] * Baux.det(); (*Llamada recursiva*)
               end;
               RESULT:= deter;
          end; (*Else Case >= 3*)
     end; (*Case-of*)
End; (*Determinante*)


Function Cls_Matriz.es_cuadrada():boolean;
Begin
     RESULT:= (NumF = NumC);
end;


Function Cls_Matriz.es_Simetrica():Boolean;//Sino se asigna N total evalua simetria sobre TODA Matriz
VAR
   R:boolean;
   i,j:integer;
Begin
     R:= True;
     if (numF = 0) then RESULT:= R else
     if es_cuadrada() then begin
        i:= 0;
        while ((i<= numF) and (R = true)) do begin
            j:= 0;
            while ((j < i) and (R = true)) do begin
                 if (cells[i, j] <> cells[j,i]) then
                    R:= FALSE;
                 j:= j+1;
            end;

            i:= i+1;
        end;

        RESULT:= R;
     end else RESULT:= false; //No es cuadrada
end;

Function Cls_Matriz.es_Simetrica(Orden_subMatriz : integer):Boolean;//Sino se asigna N total evalua simetria sobre TODA Matriz
VAR
   R:boolean;
   i,j:integer;
Begin
     if ((0 <= Orden_subMatriz) and (Orden_subMatriz <= numF)) then begin
     R:= True;
     if (numF = 0) then RESULT:= R else
     if es_cuadrada() then begin
        i:= 0;
        while ((i<= Orden_subMatriz) and (R = true)) do begin
            j:= 0;
            while ((j < i) and (R = true)) do begin
                 if (cells[i, j] <> cells[j,i]) then
                    R:= FALSE;
                 j:= j+1;
            end;

            i:= i+1;
        end;

        RESULT:= R;
     end else RESULT:= false; //No es cuadrada

     end else Begin
         writeln('cls_Matriz: Error es Simetrica: Orden_subMatriz = ',Orden_subMatriz,' inexistente...');
         RESULT:= FALSE;
     end;
end;

Function Cls_Matriz.es_AntiSimetrica():Boolean;//Sino se asigna N total evalua simetria sobre toda matriz
VAR
   R:boolean;
   i,j:integer;
Begin
     R:= True;
     if (numF = 0) then RESULT:= R else
     if es_cuadrada() then begin
        i:= 0;
        while ((i<= numF) and (R = true)) do begin
            j:= 0;
            while ((j < i) and (R = true)) do begin
                 if (cells[i, j] <> -cells[j,i]) then
                    R:= FALSE;
                 j:= j+1;
            end;
            i:= i+1;
        end;

        RESULT:= R;
     end else
             RESULT:= false;
end;

Function Cls_Matriz.es_AntiSimetrica(Orden_subMatriz : integer):Boolean;//Sino se asigna N total evalua simetria sobre submatriz
VAR
   R:boolean;
   i,j:integer;
Begin
     if ((0 <= Orden_subMatriz) and (Orden_subMatriz <= numF)) then begin
     R:= True;
     if (numF = 0) then RESULT:= R else
     if es_cuadrada() then begin
        i:= 0;
        while ((i<= Orden_subMatriz) and (R = true)) do begin
            j:= 0;
            while ((j < i) and (R = true)) do begin
                 if (cells[i, j] <> -cells[j,i]) then
                    R:= FALSE;
                 j:= j+1;
            end;
            i:= i+1;
        end;

        RESULT:= R;
     end else
             RESULT:= false;

     end else Begin
         writeln('cls_Matriz: Error es Anti Simetrica: Orden_subMatriz = ',Orden_subMatriz,' inexistente...');
         RESULT:= FALSE;
     end;
end;


{estrictamente_dominante cuando, para todas las filas, el valor absoluto del elemento
de la diagonal de esa fila es estrictamente mayor que la suma de los valores absolutos
del resto de elementos de esa fila}

Function Cls_Matriz.es_estrictamente_diagonalmente_dominante(): boolean;
VAR
   R: Boolean;
   i,j :integer;
   sum:extended;
Begin
     R:= True;
     i:= 0;
     while((i<= NumF) and (R = true)) do begin
         sum:= 0;
         for j:=0 to numC do
             if (i<>j) then
                sum:= sum + abs(Cells[i,j]);
         if (abs(cells[i,i]) <= abs(sum)) then
            R:= False;
         i:= i+1;
     end;
     Result:= R;
end;

Function Cls_Matriz.NO_es_Singular():Boolean; // No es singular -->Det <> 0 => es inversible
Begin
     RESULT:= (det() <> 0);
end;

Procedure Cls_Matriz.Suma(const B: Cls_Matriz);// A = A+B
VAR
   i,j :integer;

Begin
     if ((numF = B.numF) and (numC = B.numC)) then
             for i:= 0 to numF do
                 for j:=0 to numC do
                     cells[i,j]:= cells[i,j] + B.cells[i,j]
     else writeln('cls_matriz: Error Suma, Matrices de distintas dimensiones...');

end;

Procedure Cls_Matriz.Suma(const VecA: Cls_Matriz; const VecB : Cls_Matriz); //Vec:= VecA + VecB;
VAR
   i,j :integer;

Begin
     if ((numF = VecA.numF) and (numC = VecA.numC) and (numF = vecB.numF) and (numC = vecB.numC)) then
             for i:= 0 to numF do
                 for j:=0 to numC do
                     cells[i,j]:= VecA.cells[i,j] + VecB.cells[i,j]
     else writeln('cls_matriz: Error Suma, Matrices de distintas dimensiones...');

end;

procedure Cls_Matriz.sumaF(const filaA: integer; const filaB:integer; const escalar: extended = 1);// filaA= filaA+ escalar*filaB
VAR
   j: integer;
Begin
     if ((0<= filaA) and (filaA<= numF)) then
        if ((0<= filaB) and (filaB<= numF)) then
           for j:=0 to numC do
               cells[filaA, j]:= cells[filaA,j] + escalar*cells[filaB,j]
        else writeln('Error SumarF...FilaB incorrecta...')
     else writeln('Error SumarF...FilaA incorrecta...');
end;

procedure Cls_Matriz.sumaC(const columnaA: integer; const columnaB:integer; const escalar: extended = 1);// filaA= filaA+ escalar*filaB
VAR
   i: integer;
Begin
     if ((0<= columnaA) and (columnaA<= numC)) then
        if ((0<= columnaB) and (columnaB<= numC)) then Begin
           for i:= 0 to numC do
               cells[i, columnaA]:= cells[i, columnaA] + escalar*cells[i,columnaB];
        end else writeln('Error SumarC...ColumnaB incorrecta...')
     else writeln('Error SumarC...ColumnaA incorrecta...');

end;

Procedure Cls_Matriz.copiar(const V: Cls_Matriz); //A := V
VAR
   i,j: integer;
Begin
     redimensionar(V.numF +1 , V.numC +1);
     for i:= 0 to numF do
         for j:= 0 to numC do
             cells[i,j]:= V.cells[i,j];
end;

{Normas Matriciales}

function Cls_Matriz.Norma_1 ():extended;
var
	i,j:integer;
	may,mayorF: extended;
begin
	mayorF:= 0;
        for j:= 0 to numC do begin
            may:= 0;
	    for i:=0 to numF do
                may:= may + abs(cells[i,j]);
            if (may> mayorF) then
               mayorF:= may;
        end;
        RESULT:= mayorF;
end;

function Cls_Matriz.Norma_Frobenius():extended;
var
	i,j:integer;
	resu:extended;
begin
	resu:= 0;
	for i:=0 to numF do
		for j:=0 to numC do
			resu:= resu + Power(cells[i,j],2);
	Result:= Power(resu,(1/2));
end;

function Cls_Matriz.Norma_Infinita ():extended;
var
	i,j: integer;
	may,mayorC: extended;
begin
	mayorC:= 0;
        for i:= 0 to numF do begin
            may:= 0;
	    for j:=0 to numC do
                may:= may + abs(cells[i,j]);
            if (may> mayorC) then
               mayorC:= may;
        end;
        RESULT:= mayorC;
end;

//Todos los determinantes de los menores principales de M son positivos
Function Cls_Matriz.es_definida_positiva(): boolean; //tmb false si la matriz no es cuadrada
VAR
        z: boolean;
        i: integer;
Begin
        z:= true;
        if (es_cuadrada()) then begin
           i:=0;
           while ((i<= numF) and (z = true)) do begin
                 if (det() < 0) then // determinante de orden i es decir de la submatiz superior izquierda
                    Z:= false;
                 i:= i+1;
           end
        end else Z:= false;

        Result:= Z;
end;


Procedure Cls_Matriz.elimina_fila(const fila: integer);
VAR
        i,j: integer;
Begin
     if ((0<= fila) and (fila<= numF)) then begin
        for i:=fila to numF-1 do
            for j:=0 to numC do
                cells[i,j]:= cells[i+1,j];
        redimensionar(numF, numC+1);
     end else writeln('cls_Matriz: elimina fila: Fila = ',fila,' incorrecta...');

end;

Procedure Cls_Matriz.elimina_columna(const columna: integer);
VAR
        i,j: integer;
Begin
     if ((0<= columna) and (columna<= numC)) then begin
        for j:= columna to numC-1 do
            for i:=0 to numF do
                cells[i,j]:= cells[i,j+1];
        redimensionar(numF+1, numC);
     end else writeln('cls_Matriz: elimina columna: Columna = ',columna,' incorrecta...');
end;

Procedure Cls_Matriz.intercambiar_filas(const filaA:integer; const filaB: integer);
VAR
        AUX: Cls_Vector;
        j: integer;
Begin
     AUX:= Cls_Vector.crear(numF);
     if ((0<= filaA) and (filaA<= numF)) then
        if ((0<= filaB) and (filaB<= numF)) then Begin

        for j:=0 to numC do begin
            AUX.cells[j]:= cells[filaA,j];
            cells[filaA,j]:= cells[filaB,j];
            cells[filaB,j]:= AUX.cells[j];
        end
     end else writeln('cls_Matriz: intercambiar fila: FilaB = ',filaB,' incorrecta...')
     else writeln('cls_Matriz: intercambiar fila: FilaA = ',filaA,' incorrecta...');

     AUX.Destroy();
end;

Procedure Cls_Matriz.intercambiar_columnas(const columnaA:integer; const columnaB: integer);
VAR
        AUX: Cls_Vector;
        i: integer;
Begin
     AUX:= Cls_Vector.crear(numC);
     if ((0<= columnaA) and (columnaA<= numC)) then
        if ((0<= columnaB) and (columnaB<= numC)) then Begin

        for i:=0 to numF do begin
            AUX.cells[i]:= cells[i, columnaA];
            cells[i, columnaA]:= cells[i, columnaB];
            cells[i, columnaB]:= AUX.cells[i];
        end
     end else writeln('cls_Matriz: intercambiar columna: ColumnaB = ',ColumnaB,' incorrecta...')
     else writeln('cls_Matriz: intercambiar columna: ColumnaA = ',columnaA,' incorrecta...');

     AUX.Destroy();
end;

Procedure Cls_Matriz.Opuesto(); //Mat:= -Mat;
var
        i,j: integer;
Begin
     for i:=0 to numF do
         for j:=0 to numC do
             cells[i,j]:= -cells[i,j]
end;

Procedure Cls_Matriz.Opuesto(const V: Cls_Matriz); //mat:= -V;
Begin
     self.copiar(V);
     self.Opuesto();
end;

Function Cls_Matriz.son_iguales(const V:Cls_Matriz): boolean; //mat == V
VAR
        i,j: integer;
        band: boolean;
Begin
     band:= true;
     i:= 0;
     while ((i<= numF) and (band = true)) do begin
         j:= 0;
         while ((j<= numC) and (band = true)) do begin
               if (cells[i,j] <> V.cells[i,j]) then
                  band:= false;
               j:= j+1;
             end;

         i:= i+1;
     end;

     RESULT:= band;
end;

Procedure Cls_Matriz.xEscalar(num: extended);// mat:= num*mat, i,j=1..N;
VAR
        i,j: integer;
Begin
     for i:=0 to numF do
         for j:=0 to numC do
             cells[i,j]:= cells[i,j] * num;
end;

Procedure Cls_Matriz.fila_xEscalar(const fila: integer; const escalar: extended);
VAR
        j: integer;
Begin
     if ((0<= fila) and (fila<= numF)) then
           for j:=0 to numC do
               cells[fila,j]:= escalar*cells[fila,j]
     else writeln('cls_Matriz: Error fila_xEscalar... fila inexistente = ',fila);
end;

Procedure Cls_Matriz.columna_xEscalar(const columna: integer; const escalar: extended);
VAR
        i: integer;
Begin
     if ((0<= columna) and (columna<= numC)) then
           for i:=0 to numF do
               cells[i,columna]:= escalar*cells[i,columna]
     else writeln('cls_Matriz: Error columna_xEscalar... columna inexistente = ',columna);
end;

Procedure Cls_Matriz.Indice_Mayor(VAR i: integer; VAR j: integer); //devuelve el indice del mayor numero dentro de la matriz
VAR
        k, s : integer;
        num: extended;
Begin
        i:= 0; j:= 0;
        num:= 0;
        for k:= 0 to numF do
            for s:= 0 to numC do
                if (cells[k, s]> num) then begin
                   num:= cells[k, s];
                   i:= k;
                   j:= s;
                end;
end;

Procedure Cls_Matriz.Indice_Mayor_abs(VAR i: integer; VAR j: integer); //devuelve el indice del mayor numero dentro de la matriz
VAR
        k, s : integer;
        num: extended;
Begin
        i:= 0; j:= 0;
        num:= 0;
        for k:= 0 to numF do
            for s:= 0 to numC do
                if (abs(cells[k,s]) > num) then begin
                   num:= abs(cells[k,s]);
                   i:= k;
                   j:= s;
                end;
end;


Procedure Cls_Matriz.Indice_Mayor_fila_abs(const fila: integer; VAR i: integer; VAR j: integer); //devuelve el indice del mayor numero dentro de la matriz en abs
VAR
   mayor: extended;
   s: integer;

Begin
     i:= 0; j:= 0; mayor:= 0;
     if ((0<= fila) and (fila<= numF)) then begin
        for s:=0 to numC do
            if (abs(cells[fila,s]) > mayor) then begin
               mayor:= abs(cells[fila,s]);
               i:= fila;
               j:= s;
            end;
     end; // fila incorrecta...
end;


Procedure Cls_Matriz.Indice_Mayor_fila(const fila: integer; VAR i: integer; VAR j: integer); //devuelve el indice del mayor numero dentro de la matriz en abs
VAR
   mayor: extended;
   s: integer;
Begin
     i:= 0; j:= 0; mayor:= 0;
     if ((0<= fila) and (fila<= numF)) then begin
        for s:=0 to numC do
            if (cells[fila,s] > mayor) then begin
               mayor:= cells[fila,s];
               i:= fila;
               j:= s;
            end;
     end; // fila incorrecta...
end;

Procedure Cls_Matriz.Indice_Mayor_columna_abs(const columna: integer; VAR i: integer; VAR j: integer); //devuelve el indice del mayor numero dentro de la columna en abs
VAR
   k: integer;
   mayor: extended;
Begin
     i:= 0; j:= 0; mayor:= 0;
     if ((0<= columna) and (columna<= numC)) then begin
        for k:= 0 to numF do
            if (abs(cells[k,columna]) >mayor) then begin
               mayor:= abs(cells[k,columna]);
               i:= k;
               j:= columna;
            end;
     end; // columna incorrecta...
end;


Procedure Cls_Matriz.Indice_Mayor_columna_abs(const columna: integer; const fila: integer; VAR i: integer; VAR j: integer); //devuelve el indice del mayor numero dentro de la columna en abs
VAR
   k: integer;
   mayor: extended;
Begin
     i:= 0; j:= 0; mayor:= 0;
     if ((1<= columna) and (columna<= numC)) then
        if ((1 <= fila) and (fila <= numF)) then begin
           for k:= fila to numF do
               if (abs(cells[k,columna]) >mayor) then begin
                  mayor:= abs(cells[k,columna]);
                  i:= k;
                  j:= columna;
               end;
        end else writeln('Error Indice Mayor Columna abs -->fila hacia abajo... fila= ',fila,' incorrecta...')
     else writeln('Error Indice Mayor Columna abs -->fila hacia abajo... columna incorrecta...'); // columna incorrecta...



end;


Procedure Cls_Matriz.Indice_Mayor_columna(const columna: integer; VAR i: integer; VAR j: integer); //devuelve el indice del mayor numero dentro de la columna
VAR
   k: integer;
   mayor: extended;
Begin
     i:= 0; j:= 0; mayor:= 0;
     if ((0<= columna) and (columna<= numC)) then begin
        for k:= 0 to numF do
            if (cells[k,columna] >mayor) then begin
               mayor:= cells[k,columna];
               i:= k;
               j:= columna;
            end;
     end; // columna incorrecta...

end;


Procedure Cls_Matriz.Indice_Mayor_columna(const columna: integer; const fila: integer; VAR i: integer; VAR j: integer); //devuelve el indice del mayor numero dentro de la columna
VAR
   k: integer;
   mayor: extended;
Begin
     i:= 0; j:= 0; mayor:= 0;
     if ((0<= columna) and (columna<= numC)) then
        if ((0<= fila) and (fila <= numF)) then begin
           for k:= fila to numF do
               if (cells[k,columna] >mayor) then begin
                  mayor:= abs(cells[k,columna]);
                  i:= k;
                  j:= columna;
               end;
        end else writeln('Error Indice Mayor Columna -->fila hacia abajo... fila= ',fila,' incorrecta...')
     else writeln('Error Indice Mayor Columna -->fila hacia abajo... columna incorrecta...'); // columna incorrecta...
end;

Procedure Cls_Matriz.CopiarColumna(VAR Vec: Cls_Vector; const columna: integer);
VAR
   i:integer;
Begin
     if ((0<= columna) and (columna<= numC)) then begin
        Vec.Redimensionar(self.NumF+1);
        for i:=0 to numF do
            Vec.cells[i]:= cells[i,columna]
     end else writeln('cls_Matriz: Error Copiar Columna--> columna: ',columna,' inexistente...');


end;

Procedure Cls_Matriz.CopiarFila(VAR Vec: Cls_Vector; const fila: integer);
VAR
   i:integer;
Begin
     if ((0<= fila) and (fila<= numF)) then begin
        Vec.Redimensionar(self.NumC+1);
        for i:=0 to numC do
            Vec.cells[i]:= cells[fila,i]
     end else writeln('cls_Matriz: Error Copiar Fila--> fila: ',fila,' inexistente...');

end;

Procedure Cls_Matriz.insertarFila(const Vec: Cls_Vector; const fila: integer);
VAR
   i,j:integer;
Begin

     if ((0<= fila) and (fila<= numF)) then begin
        if (vec.N = numC) then begin
           Redimensionar(numF+2,NumC+1);
           for i:= numF downto fila+1 do
               for j:=0 to numC do
                   cells[i,j]:= cells[i-1,j];

           for i:=0 to numC do
               cells[fila,i]:= Vec.cells[i];

        end else writeln('cls_Matriz: Error InsertarFila--> vector tiene distinta cantidad de elementos que las filas de la matriz...');
     end else writeln('cls_Matriz: Error InsertarFila--> fila: ',fila,' inexistente = ',fila);
end;


Procedure Cls_Matriz.insertarColumna(const Vec: Cls_Vector; const columna: integer);
VAR
   i,j:integer;
Begin

     if ((0<= columna) and (columna<= numC)) then begin
        if (vec.N = numF) then begin
           Redimensionar(numF+1,NumC+2);
           for j:= numC downto columna+1 do
               for i:=0 to numF do
                   cells[i,j]:= cells[i,j-1];

           for i:=0 to numF do
               cells[i,columna]:= Vec.cells[i];

        end else writeln('cls_Matriz: Error InsertarColumna--> vector tiene distinta cantidad de elementos que las filas de la matriz...');
     end else writeln('cls_Matriz: Error InsertarColumna--> columna: ',columna,' inexistente = ',columna);
end;

BEGIN
END.
