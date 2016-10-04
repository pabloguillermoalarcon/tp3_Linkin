unit MatrizD;

{$mode objfpc}{$H+}

interface
USES
    VectorD, Math;

CONST
     MASCARA = 2; //mascara para los reales con writeln

type

T_Matriz= class
       Private
               xCell: array of array of double;
               NF: integer; //Cantidad Filas
               NC: integer; //Cantidad Columnas
               Procedure setCell(i,j:integer; num:Double);//Fila/Columna
               Function getCell(i,j:integer):Double;

       Public
              Property cells[i, j: integer]:Double READ getcell WRITE setCell;
              Property NumF: integer READ NF WRITE NF;
              Property NumC: integer READ NC WRITE NC;
              constructor crear(filas:integer =10; columnas:integer = 10);
              constructor crearN(orden:integer);   //matriz de orden N
              Procedure Limpia(k: double = 0);//Llena de un num k, por defecto cero a la matriz
              Procedure Redimensionar(filas,columnas: integer);
              Function es_cuadrada():boolean;
              Function es_Simetrica(subN : integer):Boolean;//Sino se asigna N total evalua simetria sobre submatriz
              Function es_AntiSimetrica(subN : integer):Boolean;//Sino se asigna N total evalua simetria sobre submatriz
              Function det(max:integer):Double;
              Function es_estrictamente_diagonalmente_dominante(): boolean;
              Function es_definida_positiva(): boolean; //tmb false si la matriz no es cuadrada
              Function NO_es_Singular(subN: integer):Boolean; // Det <> 0
              Function esta_vacia():boolean;//--->true si numF=0 v numC=0
              Procedure elimina_fila(const fila: integer);
              Procedure elimina_columna(const columna: integer);
              Procedure insertarFila(const Vec: Cls_Vector; const fila: integer);
              Procedure insertarColumna(const Vec: Cls_Vector; const columna: integer);
              Procedure copiarFila(VAR Vec: Cls_Vector; const fila: integer);
              Procedure copiarColumna(VAR Vec: Cls_Vector; const columna: integer);
              Procedure intercambiar_filas(const filaA:integer; const filaB: integer);
              Procedure intercambiar_columnas(const columnaA:integer; const columnaB: integer);
              Procedure Suma(const B: T_Matriz);// A = A+B
              Procedure Suma(const VecA: T_Matriz; const VecB : T_Matriz); //Vec:= VecA + VecB;
              procedure sumaF(const filaA: integer; const filaB:integer; const escalar: double = 1);// filaA= filaA+ escalar*filaB
              procedure sumaC(const columnaA: integer; const columnaB:integer; const escalar: double = 1);// filaA= filaA+ escalar*filaB
              Procedure copiar(const V: T_Matriz); //A := V
              Procedure Opuesto(); //Mat:= -Mat;
              Procedure Opuesto(const V: T_Matriz); //mat:= -V;
              Function iguales(const V:T_matriz): boolean; //mat == V
              Procedure xEscalar(num: double);// mat:= num*mat, i,j=1..N;
              Procedure fila_xEscalar(const fila: integer; const num:double);
              Procedure columna_xEscalar(const columna: integer; const escalar: double);
              Procedure Indice_Mayor_abs(VAR i: integer; VAR j: integer); //devuelve el indice del mayor numero dentro de la matriz en abs
              Procedure Indice_Mayor_abs(const fila: integer; const columna: integer; VAR i: integer; VAR j: integer); //devuelve el indice del mayor numero dentro de la matriz en abs
              Procedure Indice_Mayor(VAR i: integer; VAR j: integer); //devuelve el indice del mayor numero dentro de la matriz
              Procedure Indice_Mayor_fila_abs(const fila: integer; VAR i: integer; VAR j: integer); //devuelve el indice del mayor numero dentro de la fila en abs
              Procedure Indice_Mayor_fila(const fila: integer; VAR i: integer; VAR j: integer); //devuelve el indice del mayor numero dentro de la fila
              Procedure Indice_Mayor_columna_abs(const columna: integer; VAR i: integer; VAR j: integer); //devuelve el indice del mayor numero dentro de la columna en abs
              Procedure Indice_Mayor_columna_abs(const columna: integer; const fila: integer; VAR i: integer; VAR j: integer); //devuelve el indice del mayor numero dentro de la columna en abs
              Procedure Indice_Mayor_columna(const columna: integer; VAR i: integer; VAR j: integer); //devuelve el indice del mayor numero dentro de la columna
              Procedure Indice_Mayor_columna(const columna: integer; const fila: integer; VAR i: integer; VAR j: integer); //devuelve el indice del mayor numero dentro de la columna

              Function Norma_1():Double;
              Function Norma_Frobenius():Double;
              Function Norma_Infinita():Double;
              Procedure Mostrar(titulo: string =''); //Limpiar pantalla antes de invocar

  end;


implementation

//**************************************************************
//***********************MATRICES*******************************
//**************************************************************
Procedure T_Matriz.Mostrar(titulo: string ='');
var
   i,j :integer;
Begin
     writeln();
     if (titulo <>'') then writeln(titulo);

     for i:=1 to NumF do
         for j:=1 to NumC do
             if (j = NumC) then writeln(cells[i,j]:0:MASCARA)
             else write(cells[i,j]:0:MASCARA,' ');
end;

Procedure T_Matriz.Limpia(k: double = 0);//Llena de un num k, por defecto cero a la matriz
var
   i,j : integer;
Begin
     for i:=1 to numF do
         for j:=1 to numC do
             cells[i,j]:= k;

end;

 { Calcula la determinante por el metodo de eliminacion de filas y columnas}
function T_Matriz.det(max:integer):Double;
var
   n,i,j:integer;
   deter:Double;
   Baux: T_Matriz;
begin
     Baux:= T_Matriz.crear(max-1,max-1);
     if (max=1) then Result:= cells[1,1]
     else if (max=2) then Begin { determinante de dos por dos, caso base }
             Result:= (cells[1,1] * cells[2,2]) - (cells[1,2] * cells[2,1]);
     end else
          begin//m >= 3
               deter:= 0;
               for n:= 1 to max do begin
               for i:= 2 to max do // carga la matriz B con los valores
               begin               // que quedan eliminando la fila y columna

                    for j:= 1 to n-1 do  // correspondiente de la matriz A
                        Baux.cells[i-1,j]:= cells[i,j];
                    for j:= n+1 to max do
                        Baux.cells[i-1,j-1]:= cells[i,j];
               end;
               if ((1+n) mod 2)= 0 then i:=1 // Signo del complemento algebraico
                  else i:= -1;
               deter:= deter + i * cells[1,n] * Baux.det(max-1); // Llamada recursiva
          end;
          RESULT:= deter;
     end;

          Baux.Destroy;

end;

Function T_Matriz.es_cuadrada():boolean;
Begin
     RESULT:= (NumF = NumC);
end;

Procedure T_Matriz.setCell(i,j:integer; num:Double);//Fila/Columna
Begin
     xCell[i-1,j-1] := num;
end;

Function T_Matriz.getCell(i,j:integer): Double;//Fila/Columna
Begin
     RESULT:= xCell[i-1,j-1];
end;

Function T_Matriz.es_Simetrica(subN : integer):Boolean;//Sino se asigna N total evalua simetria sobre submatriz
VAR
   R:boolean;
   i,j:integer;
Begin
     R:= True;
     if (numF = 1) then RESULT:= R else
     if es_cuadrada() then begin
        i:= 2;
        while ((i<= subN) and (R = true)) do begin
            j:= 1;
            while ((j < i) and (R = true)) do begin
                 if (cells[i, j] <> cells[j,i]) then
                    R:= FALSE;
                 j:= j+1;
            end;

            i:= i+1;
        end;

        RESULT:= R;
     end else
             RESULT:= false;
end;

Function T_Matriz.es_AntiSimetrica(subN : integer):Boolean;//Sino se asigna N total evalua simetria sobre submatriz
VAR
   R:boolean;
   i,j:integer;
Begin
     R:= True;
     if (numF = 1) then RESULT:= R else
     if es_cuadrada() then begin
        i:= 2;
        while ((i<= subN) and (R = true)) do begin
            j:= 1;
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


{estrictamente_dominante cuando, para todas las filas, el valor absoluto del elemento
de la diagonal de esa fila es estrictamente mayor que la suma de los valores absolutos
del resto de elementos de esa fila}

Function T_Matriz.es_estrictamente_diagonalmente_dominante(): boolean;
VAR
   R: Boolean;
   i,j :integer;
   sum:Double;
Begin
     R:= True;
     i:= 1;
     while((i<= NumF) and (R = true)) do begin
         sum:= 0;
         for j:=1 to numC do
             if (i<>j) then
                sum:= sum + abs(Cells[i,j]);
         if (abs(cells[i,i]) <= abs(sum)) then
            R:= False;
         i:= i+1;
     end;
     Result:= R;
end;

Function T_MAtriz.NO_es_Singular(subN: integer):Boolean; // No es singular -->Det <> 0 => es inversible
Begin
     RESULT:= (det(subN) <> 0);
end;

Procedure T_Matriz.Suma(const B: T_Matriz);// A = A+B
VAR
   i,j :integer;

Begin
     if ((numF = B.numF) and (numC = B.numC)) then
             for i:= 1 to numF do
                 for j:=1 to numC do
                     cells[i,j]:= cells[i,j] + B.cells[i,j];

end;

Procedure T_Matriz.Suma(const VecA: T_Matriz; const VecB : T_Matriz); //Vec:= VecA + VecB;
VAR
   i,j :integer;

Begin
     if ((numF = VecA.numF) and (numC = VecA.numC) and (numF = vecB.numF) and (numC = vecB.numC)) then
             for i:= 1 to numF do
                 for j:=1 to numC do
                     cells[i,j]:= cells[i,j] + VecA.cells[i,j] + VecB.cells[i,j];

end;

procedure T_Matriz.sumaF(const filaA: integer; const filaB:integer; const escalar: double = 1);// filaA= filaA+ escalar*filaB
VAR
   j: integer;
Begin
     if ((1<= filaA) and (filaA<= numF)) then
        if ((1<= filaB) and (filaB<= numF)) then
           for j:=1 to numC do
               cells[filaA, j]:= cells[filaA,j] + escalar*cells[filaB,j]
        else writeln('Error SumarF...FilaB incorrecta...')
     else writeln('Error SumarF...FilaA incorrecta...');
end;

procedure T_Matriz.sumaC(const columnaA: integer; const columnaB:integer; const escalar: double = 1);// filaA= filaA+ escalar*filaB
VAR
   i: integer;
Begin
     if ((1<= columnaA) and (columnaA<= numC)) then
        if ((1<= columnaB) and (columnaB<= numC)) then Begin
           for i:= 1 to numC do
               cells[i, columnaA]:= cells[i, columnaA] + escalar*cells[i,columnaB];
        end else writeln('Error SumarC...ColumnaB incorrecta...')
     else writeln('Error SumarC...ColumnaA incorrecta...');

end;

Procedure T_Matriz.copiar(const V: T_Matriz); //A := V
VAR
   i,j: integer;
Begin
     redimensionar(V.numF, V.numC);
     for i:= 1 to numF do
         for j:=1 to numC do
             cells[i,j]:= V.cells[i,j];
end;

{Normas Matriciales}

function T_Matriz.Norma_1 ():Double;
var
	i,j:integer;
	may,mayorF: Double;
begin
	mayorF:= 0;
        for j:= 1 to numC do begin
            may:= 0;
	    for i:=1 to numF do
                may:= may + abs(cells[i,j]);
            if (may> mayorF) then
               mayorF:= may;
        end;
        RESULT:= mayorF;
end;

function T_Matriz.Norma_Frobenius():Double;
var
	i,j:integer;
	resu:Double;
begin
	resu:= 0;
	for i:=1 to numF do
		for j:=1 to numC do
			resu:= resu + Power(cells[i,j],2);
	Result:= Power(resu,(1/2));
end;

function T_Matriz.Norma_Infinita ():Double;
var
	i,j: integer;
	may,mayorC: Double;
begin
	mayorC:= 0;
        for i:= 1 to numF do begin
            may:= 0;
	    for j:= 1 to numC do
                may:= may + abs(cells[i,j]);
            if (may> mayorC) then
               mayorC:= may;
        end;
        RESULT:= mayorC;
end;

//Todos los determinantes de los menores principales de M son positivos
Function T_Matriz.es_definida_positiva(): boolean; //tmb false si la matriz no es cuadrada
VAR
        z: boolean;
        i: integer;
Begin
        z:= true;
        if (es_cuadrada()) then begin
           i:= 1;
           while ((i<= numF) and (z = true)) do begin
                 if (det(i) < 0) then // determinante de orden i es decir de la submatiz superior izquierda
                    Z:= false;
                 i:= i+1;
           end
        end else Z:= false;

        Result:= Z;
end;

Function T_Matriz.esta_vacia():boolean;//--->true si numF=0 v numC=0
Begin
     RESULT:= ((numF=0) or (numC=0));
end;

Procedure T_Matriz.elimina_fila(const fila: integer);
VAR
        i,j: integer;
Begin
     if ((1<= fila) and (fila<= numF)) then begin
        for i:=fila to numF-1 do
            for j:=1 to numC do
                cells[i,j]:= cells[i+1,j];
        redimensionar(numF-1, numC);
     end; // fila incorrecta...

end;

Procedure T_Matriz.elimina_columna(const columna: integer);
VAR
        i,j: integer;
Begin
     if ((1<= columna) and (columna<= numC)) then begin
        for j:= columna to numC-1 do
            for i:=1 to numF do
                cells[i,j]:= cells[i,j+1];
        redimensionar(numF, numC-1);
     end; // fila incorrecta...

end;

Procedure T_Matriz.intercambiar_filas(const filaA:integer; const filaB: integer);
VAR
        AUX: Cls_Vector;
        j: integer;
Begin
     AUX:= Cls_Vector.crear(numF);
     if ((1<= filaA) and (filaA<= numF)) then
        if ((1<= filaB) and (filaB<= numF)) then Begin

        for j:=1 to numC do begin
            AUX.cells[j]:= cells[filaA,j];
            cells[filaA,j]:= cells[filaB,j];
            cells[filaB,j]:= AUX.cells[j];
        end
     end else writeln('Intercambiar Filas...FilaB incorrecta...')
     else writeln('Intercambiar Filas...FilaA incorrecta...');

     AUX.Destroy();
end;

Procedure T_Matriz.intercambiar_columnas(const columnaA:integer; const columnaB: integer);
VAR
        AUX: Cls_Vector;
        i: integer;
Begin
     AUX:= Cls_Vector.crear(numC);
     if ((1<= columnaA) and (columnaA<= numC)) then
        if ((1<= columnaB) and (columnaB<= numC)) then Begin

        for i:=1 to numF do begin
            AUX.cells[i]:= cells[i, columnaA];
            cells[i, columnaA]:= cells[i, columnaB];
            cells[i, columnaB]:= AUX.cells[i];
        end
     end else writeln('Intercambiar Columnas...ColumnaB incorrecta...')
     else writeln('Intercambiar columnas...ColumnaA incorrecta...');

     AUX.Destroy();
end;

Procedure T_Matriz.Opuesto(); //Mat:= -Mat;
var
        i,j: integer;
Begin
     for i:=1 to numF do
         for j:=1 to numC do
             cells[i,j]:= -cells[i,j]
end;

Procedure T_Matriz.Opuesto(const V: T_Matriz); //mat:= -V;
var
        i,j: integer;
Begin
     redimensionar(V.numF,V.numC);
     for i:=1 to numF do
         for j:=1 to numC do
             cells[i,j]:= -V.cells[i,j]
end;

Function T_Matriz.iguales(const V:T_matriz): boolean; //mat == V
VAR
        i,j: integer;
        band: boolean;
Begin
     band:= true;
     i:= 1;
     while ((i<= numF) and (band = true)) do begin
         j:= 1;
         while ((j<= numC) and (band = true)) do begin
               if (cells[i,j] <> V.cells[i,j]) then
                  band:= false;
               j:= j+1;
             end;

         i:= i+1;
     end;

     RESULT:= band;
end;

Procedure T_Matriz.xEscalar(num: double);// mat:= num*mat, i,j=1..N;
VAR
        i,j: integer;
Begin
     for i:=1 to numF do
         for j:=1 to numC do
             cells[i,j]:= cells[i,j] * num;
end;

Procedure T_matriz.fila_xEscalar(const fila: integer; const num:double);
VAR
        j: integer;
Begin
     if ((1<= fila) and (fila<= numF)) then
        if (num<>0) then
           for j:=1 to numC do
               cells[fila,j]:= num*cells[fila,j]
        else writeln('Error fila_xEscalar... constante = 0')
     else writeln('Error fila_xEscalar... fila inexistente...');
end;

Procedure T_matriz.columna_xEscalar(const columna: integer; const escalar: double);
VAR
        i: integer;
Begin
     if ((1<= columna) and (columna<= numC)) then
        if (escalar <> 0) then
           for i:=1 to numF do
               cells[i,columna]:= escalar*cells[i,columna]
        else writeln('Error columna_xEscalar... escalar = 0')
     else writeln('Error columna_xEscalar... columna inexistente...');
end;

Procedure T_Matriz.Indice_Mayor(VAR i: integer; VAR j: integer); //devuelve el indice del mayor numero dentro de la matriz
VAR
        k, s : integer;
        num: double;
Begin
        i:= 0; j:= 0;
        num:= 0;
        for k:= 1 to numF do
            for s:= 1 to numC do
                if (cells[k, s]> num) then begin
                   num:= cells[k, s];
                   i:= k;
                   j:= s;
                end;
end;

Procedure T_Matriz.Indice_Mayor_abs(VAR i: integer; VAR j: integer); //devuelve el indice del mayor numero dentro de la matriz
VAR
        k, s : integer;
        num: double;
Begin
        i:= 0; j:= 0;
        num:= 0;
        for k:= 1 to numF do
            for s:= 1 to numC do
                if (abs(cells[k,s]) > num) then begin
                   num:= abs(cells[k,s]);
                   i:= k;
                   j:= s;
                end;
end;

Procedure T_Matriz.Indice_Mayor_abs(const fila: integer; const columna: integer; VAR i: integer; VAR j: integer); //devuelve el indice del mayor numero dentro de la matriz en abs
VAR
        k, s : integer;
        num: double;
Begin
       if ((1<= fila) and (fila<= numF)) then begin
          i:= 0; j:= 0;
          num:= 0;
          for k:= fila to numF do
              for s:= fila to columna do
                  if (abs(cells[k,s]) > num) then begin
                     num:= abs(cells[k,s]);
                     i:= k;
                     j:= s;
                  end;
       end else writeln('Error Indice Mayor abs... Indice Incorrecto...');
end;

Procedure T_Matriz.Indice_Mayor_fila_abs(const fila: integer; VAR i: integer; VAR j: integer); //devuelve el indice del mayor numero dentro de la matriz en abs
VAR
   mayor: double;
   s: integer;

Begin
     i:= 0; j:= 0; mayor:= 0;
     if ((1<= fila) and (fila<= numF)) then begin
        for s:=1 to numC do
            if (abs(cells[fila,s]) > mayor) then begin
               mayor:= abs(cells[fila,s]);
               i:= fila;
               j:= s;
            end;
     end; // fila incorrecta...
end;


Procedure T_Matriz.Indice_Mayor_fila(const fila: integer; VAR i: integer; VAR j: integer); //devuelve el indice del mayor numero dentro de la matriz en abs
VAR
   mayor: double;
   s: integer;
Begin
     i:= 0; j:= 0; mayor:= 0;
     if ((1<= fila) and (fila<= numF)) then begin
        for s:=1 to numC do
            if (cells[fila,s] > mayor) then begin
               mayor:= cells[fila,s];
               i:= fila;
               j:= s;
            end;
     end; // fila incorrecta...
end;

Procedure T_Matriz.Indice_Mayor_columna_abs(const columna: integer; VAR i: integer; VAR j: integer); //devuelve el indice del mayor numero dentro de la columna en abs
VAR
   k: integer;
   mayor: double;
Begin
     i:= 0; j:= 0; mayor:= 0;
     if ((1<= columna) and (columna<= numC)) then begin
        for k:= 1 to numF do
            if (abs(cells[k,columna]) >mayor) then begin
               mayor:= abs(cells[k,columna]);
               i:= k;
               j:= columna;
            end;
     end; // columna incorrecta...
end;


Procedure T_Matriz.Indice_Mayor_columna_abs(const columna: integer; const fila: integer; VAR i: integer; VAR j: integer); //devuelve el indice del mayor numero dentro de la columna en abs
VAR
   k: integer;
   mayor: double;
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


Procedure T_Matriz.Indice_Mayor_columna(const columna: integer; VAR i: integer; VAR j: integer); //devuelve el indice del mayor numero dentro de la columna
VAR
   k: integer;
   mayor: double;
Begin
     i:= 0; j:= 0; mayor:= 0;
     if ((1<= columna) and (columna<= numC)) then begin
        for k:= 1 to numF do
            if (cells[k,columna] >mayor) then begin
               mayor:= cells[k,columna];
               i:= k;
               j:= columna;
            end;
     end; // columna incorrecta...

end;


Procedure T_Matriz.Indice_Mayor_columna(const columna: integer; const fila: integer; VAR i: integer; VAR j: integer); //devuelve el indice del mayor numero dentro de la columna
VAR
   k: integer;
   mayor: double;
Begin
     i:= 0; j:= 0; mayor:= 0;
     if ((1<= columna) and (columna<= numC)) then
        if ((1 <= fila) and (fila <= numF)) then begin
           for k:= fila to numF do
               if (cells[k,columna] >mayor) then begin
                  mayor:= abs(cells[k,columna]);
                  i:= k;
                  j:= columna;
               end;
        end else writeln('Error Indice Mayor Columna -->fila hacia abajo... fila= ',fila,' incorrecta...')
     else writeln('Error Indice Mayor Columna -->fila hacia abajo... columna incorrecta...'); // columna incorrecta...
end;

Procedure T_Matriz.CopiarColumna(VAR Vec: Cls_Vector; const columna: integer);
VAR
   i:integer;
Begin
     if ((1<= columna) and (columna<= numC)) then begin
        Vec.Redimensionar(numF);
        for i:=1 to numF do
            Vec.cells[i]:= cells[i,columna]
     end else writeln('Error Copiar Columna--> columna: ',columna,' inexistente...')


end;

Procedure T_Matriz.CopiarFila(VAR Vec: Cls_Vector; const fila: integer);
VAR
   i:integer;
Begin
     if ((1<= fila) and (fila<= numF)) then begin
        Vec.Redimensionar(numC);
        for i:=1 to numC do
            Vec.cells[i]:= cells[fila,i]
     end else writeln('Error Copiar Fila--> fila: ',fila,' inexistente...')

end;

Procedure T_Matriz.insertarFila(const Vec: Cls_Vector; const fila: integer);
VAR
   i,j:integer;
Begin

     if ((1<= fila) and (fila<= numF)) then begin
        if (vec.N = numF) then begin
           Redimensionar(numF+1,NumC);

           for i:= numF downto fila+1 do
               for j:=1 to numC do
                   cells[i,j]:= cells[i-1,j];

           for i:=1 to numC do
               cells[fila,i]:= Vec.cells[i];

        end else writeln('Error InsertarFila--> vector tiene distinta cantidad de elementos que las filas de la matriz...');
     end else writeln('Error InsertarFila--> fila: ',fila,' inexistente...')
end;


Procedure T_Matriz.insertarColumna(const Vec: Cls_Vector; const columna: integer);
VAR
   i,j:integer;
Begin

     if ((1<= columna) and (columna<= numC)) then begin
        if (vec.N = numC) then begin
           Redimensionar(numF,NumC+1);

           for j:= numC downto columna+1 do
               for i:=1 to numF do
                   cells[i,j]:= cells[i,j-1];

           for i:=1 to numF do
               cells[i,columna]:= Vec.cells[i];

        end else writeln('Error InsertarColumna--> vector tiene distinta cantidad de elementos que las filas de la matriz...');
     end else writeln('Error InsertarColumna--> columna: ',columna,' inexistente...')
end;

constructor T_Matriz.crear(filas:integer =10; columnas:integer = 10);
Begin
     setlength(xCell,filas,columnas);
     NumF:= filas;
     NumC:= columnas;
     limpia();
end;

constructor T_Matriz.crearN(orden:integer);
Begin
     setlength(xCell, orden, orden);
     NumF:= orden;
     NumC:= orden;
     limpia();
end;

Procedure T_Matriz.Redimensionar(filas, columnas: integer);
Begin
     setlength(xCell,filas,columnas);
     NumF:= filas;
     NumC:= columnas;
end;

BEGIN
END.
