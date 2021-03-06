;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICA��ES PARA USO COM 12F675                   *
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
;*   VERS�O: 1.0                           DATA: 17/06/03          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     DESCRI��O DO ARQUIVO                        *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;*                                                                 *
;*                                                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINI��ES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADR�O MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINA��O DE MEM�RIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINI��O DE COMANDOS DE USU�RIO PARA ALTERA��O DA P�GINA DE MEM�RIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEM�RIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAM�RIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARI�VEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DOS NOMES E ENDERE�OS DE TODAS AS VARI�VEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDERE�O INICIAL DA MEM�RIA DE
					;USU�RIO
		W_TEMP		;REGISTRADORES TEMPOR�RIOS PARA USO
		STATUS_TEMP	;JUNTO �S INTERRUP��ES

		;NOVAS VARI�VEIS
		TEMP ;AUXILIAR PARA O DELAY
		TEMP3 ;AUXILIAR4 PARA O DELAY
		TEMP4 ;AUXILIAR4 PARA O DELAY
		CONT ;AUXILIAR PARA NUMERO DE INTERA��ES
		PILHA ;AUXILIAR QUE RECEBER� OS DADOS DA COMUNICA��O
	ENDC			;FIM DO BLOCO DE MEM�RIA
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SA�DAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO SA�DA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00			;ENDERE�O INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    IN�CIO DA INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDERE�O DE DESVIO DAS INTERRUP��ES. A PRIMEIRA TAREFA � SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERA��O FUTURA

	ORG	0x04			;ENDERE�O INICIAL DA INTERRUP��O
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SER� ESCRITA AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUP��ES

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SA�DA DA INTERRUP��O                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUP��O

SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRI��O DE FUNCIONAMENTO
; E UM NOME COERENTE �S SUAS FUN��ES.
TIME1T
	MOVLW .12   ;PARA COMPLETAR OS 600MS FAZEMOS A CONTAGEM 12 VEZES
	MOVWF TEMP 
BARRO
	MOVLW .61
	MOVWF TMR0 ;
	BTFSS INTCON, T0IF ;  aqui eu testo o timer caso for 1 ele pula uma instru��o
	GOTO $-1
	BCF INTCON, T0IF ; limpando o estouro do timer 0
	DECFSZ TEMP ;DECREMENTA O CONTADOR E VERIFICA SE EST� EM ZERO
	GOTO BARRO
	NOP
	RETURN
	
	
TIME4T
	MOVLW .4   ;PARA COMPLETAR OS 2400MS FAZEMOS A CONTAGEM 4 VEZES
	MOVWF TEMP4 
BARRO4
	CALL TIME1T
	DECFSZ TEMP4 ;DECREMENTA O CONTADOR E VERIFICA SE EST� EM ZERO
	GOTO BARRO4
	NOP
	RETURN
	
DELAY_LED
	MOVLW .2   ;PARA COMPLETAR OS 100MS FAZEMOS A CONTAGEM 2 VEZES
	MOVWF TEMP3 
BARRO3
	MOVLW .61
	MOVWF TMR0 ;
	BTFSS INTCON, T0IF ;  aqui eu testo o timer caso for 1 ele pula uma instru��o
	GOTO $-1
	BCF INTCON, T0IF ; limpando o estouro do timer 0
	DECFSZ TEMP3 ;DECREMENTA O CONTADOR E VERIFICA SE EST� EM ZERO
	GOTO BARRO3
	NOP
	RETURN
ADD0
	;NESTA ROTINA ADICIONAMOS O VALOR 0 A PILHA PARA FUTURAS COMPARA��ES
	BCF STATUS, C
	RRF PILHA
	DECF CONT
	GOTO ROTINA_PRINCIPAL
ADD1
	;NESTA ROTINA FAZEMOS A ADI��O DO VALOR 1 A PILHA PARA FUTURAS COMPARA��ES
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
	;AQUI FAZEMOS A COMPARA��O DO VALOR ARMAZENADO NA PILHA COM ALGUM DOS 9 DIGITOS TRABALHADOS
	;TODA A COMPARA��O � FEITA COM A COMPARA��O POR SUBTRA��O. SE O RESULTADO BATE COM O C�DIGO DO DATASHET
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
	MOVWF	TRISIO		;COMO SA�DAS, Exceto o gp3
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000111'
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

MAIN
	;ROTINA STARTBIT
	BTFSC GPIO,GP3 ;VERIFICA O STATUS DO GP3, QUE SER� NOSSA ENTRADA
	CALL TIME4T ;ESPERA 2400ms
	NOP
	BTFSS GPIO,GP3
	CALL TIME1T ;TEMPO OCIOSO ESPERA 600MS
	NOP
	
	MOVLW   .7 ; NUMERO DE INTERA��ES
	MOVWF   CONT ;ADICIONADA ESTE NUMERO A VARIAVEL AUXILIAR CONT
	
ROTINA_PRINCIPAL
	;� REALIZADA A TODO INSTANTE UMA VERIFICA��O QUANTO AO VALOR DE ENTRADA GP3
	;ISSO PARA RESPEITAR O PROTOCOLO. DESTA FORMA A LOGICA SEGUE DA SEGUINTE FORMA
	;QUANDO TEMOS A SEQUENCIA DE VALORES PARA O GP3 1 E 0, DIZEMOS QUE PASSOU 2T E 
	;PORTANTO ADICIONAMOS O VALOR 0 A PILHA. QUANDO TEMOS 110 SETAMOS O VALOR UM A PILHA
	;SEQUENCIA DIFERENTES DESSSAS N�O CORRESPONDEM AOS BOT�ES TRABALHADOS E PORTANTO
	;LIGAMOS O LED EM GP5
	MOVLW .1
	SUBWF CONT,W ;AQUI REALIZAMOS OPERA��ES DE SUBTRA��O AO CONTADOR PARA ALCAN�AR AS 7 INTERA��ES DESEJADAS
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
