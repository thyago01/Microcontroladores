;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICAÇÕES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                    FEVEREIRO DE 2016                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              	PROJETO RECEPTOR_IR	                         *
;*                WELLTON THYAGO DE SOUZA - 11325715               *
;*                    AGOSTO 2018                                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       NOME DO PROJETO                           *
;*                           CLIENTE                               *
;*         DESENVOLVIDO PELA MOSAICO ENGENHARIA E CONSULTORIA      *
;*   VERSÃO: 1.0                           DATA: 17/06/03          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     DESCRIÇÃO DO ARQUIVO                        *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;*                                                                 *
;*                                                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINIÇÕES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADRÃO MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINAÇÃO DE MEMÓRIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINIÇÃO DE COMANDOS DE USUÁRIO PARA ALTERAÇÃO DA PÁGINA DE MEMÓRIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEMÓRIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAMÓRIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARIÁVEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DOS NOMES E ENDEREÇOS DE TODAS AS VARIÁVEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDEREÇO INICIAL DA MEMÓRIA DE
					;USUÁRIO
		W_TEMP		;REGISTRADORES TEMPORÁRIOS PARA USO
		STATUS_TEMP	;JUNTO ÀS INTERRUPÇÕES

		;NOVAS VARIÁVEIS
		TEMP ;AUXILIAR PARA O DELAY
		TEMP3 ;AUXILIAR4 PARA O DELAY
		TEMP4 ;AUXILIAR4 PARA O DELAY
		CONT ;AUXILIAR PARA NUMERO DE INTERAÇÕES
		PILHA ;AUXILIAR QUE RECEBERÁ OS DADOS DA COMUNICAÇÃO
	ENDC			;FIM DO BLOCO DE MEMÓRIA
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SAÍDAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO SAÍDA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00			;ENDEREÇO INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    INÍCIO DA INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDEREÇO DE DESVIO DAS INTERRUPÇÕES. A PRIMEIRA TAREFA É SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERAÇÃO FUTURA

	ORG	0x04			;ENDEREÇO INICIAL DA INTERRUPÇÃO
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SERÁ ESCRITA AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUPÇÕES

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SAÍDA DA INTERRUPÇÃO                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUPÇÃO

SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRIÇÃO DE FUNCIONAMENTO
; E UM NOME COERENTE ÀS SUAS FUNÇÕES.
TIME1T
	MOVLW .12   ;PARA COMPLETAR OS 600MS FAZEMOS A CONTAGEM 12 VEZES
	MOVWF TEMP 
BARRO
	MOVLW .61
	MOVWF TMR0 ;
	BTFSS INTCON, T0IF ;  aqui eu testo o timer caso for 1 ele pula uma instrução
	GOTO $-1
	BCF INTCON, T0IF ; limpando o estouro do timer 0
	DECFSZ TEMP ;DECREMENTA O CONTADOR E VERIFICA SE ESTÁ EM ZERO
	GOTO BARRO
	NOP
	RETURN
	
	
TIME4T
	MOVLW .4   ;PARA COMPLETAR OS 2400MS FAZEMOS A CONTAGEM 4 VEZES
	MOVWF TEMP4 
BARRO4
	CALL TIME1T
	DECFSZ TEMP4 ;DECREMENTA O CONTADOR E VERIFICA SE ESTÁ EM ZERO
	GOTO BARRO4
	NOP
	RETURN
	
DELAY_LED
	MOVLW .2   ;PARA COMPLETAR OS 100MS FAZEMOS A CONTAGEM 2 VEZES
	MOVWF TEMP3 
BARRO3
	MOVLW .61
	MOVWF TMR0 ;
	BTFSS INTCON, T0IF ;  aqui eu testo o timer caso for 1 ele pula uma instrução
	GOTO $-1
	BCF INTCON, T0IF ; limpando o estouro do timer 0
	DECFSZ TEMP3 ;DECREMENTA O CONTADOR E VERIFICA SE ESTÁ EM ZERO
	GOTO BARRO3
	NOP
	RETURN
ADD0
	;NESTA ROTINA ADICIONAMOS O VALOR 0 A PILHA PARA FUTURAS COMPARAÇÕES
	BCF STATUS, C
	RRF PILHA
	DECF CONT
	GOTO ROTINA_PRINCIPAL
ADD1
	;NESTA ROTINA FAZEMOS A ADIÇÃO DO VALOR 1 A PILHA PARA FUTURAS COMPARAÇÕES
	BSF STATUS, C
	RRF PILHA
	DECF CONT
	GOTO ROTINA_PRINCIPAL
	
LED_ROTINA
	;NESTA ROTINA LIGAMOS O LED POR 100ms E DEPOIS RETORNAMOS AO CODIGO PRINCIPAL
	BSF GPIO,GP5
	CALL DELAY_LED
	BCF GPIO,GP5
	GOTO MAIN

DISPLAY_ROTINA
	;AQUI FAZEMOS A COMPARAÇÃO DO VALOR ARMAZENADO NA PILHA COM ALGUM DOS 9 DIGITOS TRABALHADOS
	;TODA A COMPARAÇÃO É FEITA COM A COMPARAÇÃO POR SUBTRAÇÃO. SE O RESULTADO BATE COM O CÓDIGO DO DATASHET
	;LIGAMOS O DISPLAY
	MOVLW .9
	SUBWF PILHA,W
	BTFSC STATUS, Z
	GOTO DISPLAY_0
    
	MOVLW .8
	SUBWF PILHA,W
	BTFSC STATUS, Z
	GOTO DISPLAY_9
	
	MOVLW .7
	SUBWF PILHA,W
	BTFSS STATUS, Z
	GOTO DISPLAY_8
	
	MOVLW .6
	SUBWF PILHA,W
	BTFSS STATUS, Z
	GOTO DISPLAY_7
	
	MOVLW .5
	SUBWF PILHA,W
	BTFSS STATUS, Z
	GOTO DISPLAY_6
	
	MOVLW .4
	SUBWF PILHA,W
	BTFSS STATUS, Z
	GOTO DISPLAY_5
	
	MOVLW .3
	SUBWF PILHA,W
	BTFSS STATUS, Z
	GOTO DISPLAY_4
	
	MOVLW .2
	SUBWF PILHA,W
	BTFSS STATUS, Z
	GOTO DISPLAY_3
	
	MOVLW .1
	SUBWF PILHA,W
	BTFSS STATUS, Z
	GOTO DISPLAY_2
	GOTO DISPLAY_1
	
	DISPLAY_9
	BSF GPIO,GP0   
	BCF GPIO,GP1  
	BCF GPIO,GP2   
	BSF GPIO,GP4   
	GOTO MAIN
	
	DISPLAY_8
	BSF GPIO,GP0   
	BCF GPIO,GP1  
	BCF GPIO,GP2   
	BCF GPIO,GP4   
	GOTO MAIN
	
	DISPLAY_7
	BCF GPIO,GP0   
	BSF GPIO,GP1  
	BSF GPIO,GP2   
	BSF GPIO,GP4   
	GOTO MAIN
	
	DISPLAY_6
	BCF GPIO,GP0   
	BSF GPIO,GP1  
	BSF GPIO,GP2   
	BCF GPIO,GP4   
	GOTO MAIN
	
	DISPLAY_5
	BCF GPIO,GP0   
	BSF GPIO,GP1  
	BCF GPIO,GP2   
	BSF GPIO,GP4   
	GOTO MAIN
	
	DISPLAY_4
	BCF GPIO,GP0   
	BSF GPIO,GP1  
	BCF GPIO,GP2   
	BCF GPIO,GP4   
	GOTO MAIN
	
	DISPLAY_3
	BCF GPIO,GP0   
	BCF GPIO,GP1  
	BsF GPIO,GP2   
	BSF GPIO,GP4   
	GOTO MAIN
	
	DISPLAY_2
	BCF GPIO,GP0   
	BCF GPIO,GP1  
	BSF GPIO,GP2   
	BCF GPIO,GP4   
	GOTO MAIN
	
	DISPLAY_1
	BCF GPIO,GP0   
	BCF GPIO,GP1  
	BCF GPIO,GP2   
	BSF GPIO,GP4
	GOTO MAIN
	
	DISPLAY_0
	BCF GPIO,GP0   
	BCF GPIO,GP1  
	BCF GPIO,GP2   
	BCF GPIO,GP4   
	GOTO MAIN
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00001000' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS, Exceto o gp3
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000111'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

MAIN
	;ROTINA STARTBIT
	BTFSC GPIO,GP3 ;VERIFICA O STATUS DO GP3, QUE SERÁ NOSSA ENTRADA
	CALL TIME4T ;ESPERA 2400ms
	NOP
	BTFSS GPIO,GP3
	CALL TIME1T ;TEMPO OCIOSO ESPERA 600MS
	NOP
	
	MOVLW   .7 ; NUMERO DE INTERAÇÕES
	MOVWF   CONT ;ADICIONADA ESTE NUMERO A VARIAVEL AUXILIAR CONT
	
ROTINA_PRINCIPAL
	;É REALIZADA A TODO INSTANTE UMA VERIFICAÇÃO QUANTO AO VALOR DE ENTRADA GP3
	;ISSO PARA RESPEITAR O PROTOCOLO. DESTA FORMA A LOGICA SEGUE DA SEGUINTE FORMA
	;QUANDO TEMOS A SEQUENCIA DE VALORES PARA O GP3 1 E 0, DIZEMOS QUE PASSOU 2T E 
	;PORTANTO ADICIONAMOS O VALOR 0 A PILHA. QUANDO TEMOS 110 SETAMOS O VALOR UM A PILHA
	;SEQUENCIA DIFERENTES DESSSAS NÃO CORRESPONDEM AOS BOTÕES TRABALHADOS E PORTANTO
	;LIGAMOS O LED EM GP5
	MOVLW .1
	SUBWF CONT,W ;AQUI REALIZAMOS OPERAÇÕES DE SUBTRAÇÃO AO CONTADOR PARA ALCANÇAR AS 7 INTERAÇÕES DESEJADAS
	BTFSS STATUS, Z
	GOTO DISPLAY_ROTINA
	BTFSS GPIO,GP3
	NOP
	CALL TIME1T
	BTFSS GPIO,GP3
	GOTO ADD0
	CALL TIME1T
	BTFSS GPIO,GP3
	GOTO ADD1
	GOTO LED_ROTINA
	
	GOTO MAIN
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
