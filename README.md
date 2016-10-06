# tp3_Linkin - Raices Polinomios

V0.2: cls_Vector y cls_Matriz comienzan en 0, cls_Polin esta modificado, tiene un vector para coeficientes y una matriz de 2xN paras las N raices, primera fila raices reales y segunda fila parte img respectivamente


V0.1
Clases: 
1) VectorD.pas
2) MatrizD.pas
3) PolinD.pas
4) unit_GUI.pas(Interfaz Grafica de Usuario)


Propuesta: crear una clase (PolinD.pas) que herede de VectorD.pas,
donde se agreguen los metodos propios de los polinomios


Notas: 
N1: la 'D' en la que terminan las clases es para indicar que las estructuras son dinamicas. 
N2: Dentro de VectorD y MatrizD hay documentacion, fijense en el constructor y operaciones.
N3: existe un metodo para redimensionarlas en tiempo de ejecucion 
N4: vectord y matriz tienen metodos para mostrar su contenido con writeln
N5: PolinD basicamente es un vector dinamico de extended y una matriz
N6: las raices deberian ser un objeto de la clase vectorD
N7: si son complejos, serian dos vectores, uno para la parte real y otro para la parte 
compleja respectivamente de las N raices

https://github.com/cristianux88/tp3_Linkin.git
