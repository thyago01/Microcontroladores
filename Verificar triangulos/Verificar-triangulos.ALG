Algoritmo "Verificar Triangulo"
// Autor(a)    : Wellton Thyago de Souza
// Data atual  : 16/7/2018
Var
// Seção de Declarações das variáveis 
x1,x2,x3,W:inteiro

Inicio
// Seção de Comandos, procedimento, funções, operadores, etc... 
escreval("Este programa tem como finalidade classificar o triangulo a partir dos valores de seus três lados")
escreval("Informe o valor do primeiro lado")
leia(x1)
escreval("Informe o valor do segundo lado")
leia(x2)
escreval("Informe o valor do segundo lado")
leia(x3)
se  NAO((x1<(x2+x3)) E  (x2<(x1+x3)) E (x3<(x1+x2))) entao
W<-4
senao
     se NAO(x1=x2) E NAO(x2=x3) E NAO(x1=x3) entao
     W<-1
     fimse
     se ((x1=x2) E NAO(x2=x3))  OU ((x1=x3) E NAO(x2=x3)) OU ((x2=x3) E NAO(x1=x3))entao
     W<-2
     fimse
     se (x1=x2)E (x2=x3)entao
     W<-3
     fimse
fimse

escreval("W =",W)
Fimalgoritmo
