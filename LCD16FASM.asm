    
#include "p16F628A.inc"
    __CONFIG _FOSC_INTOSCIO & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
 ;Preprocesor directives    
 #define LCDdata PORTB
 #define TRISLCDdata TRISB
 #define bitsData b'00000000'	;Number of bits 4/8 in LCD transmision
 #define CLEARSCREEN 0x01	;Command to clear the screen in LCD
 #define FIRSTLINE 0x80	       ;Go to the first line in LCD
 #define SECONDLINE 0xC0	;Go to the second line in LCD 
 #define MODE8BIT5x8M 0x38	;To select 8 bit mode in LCD
 #define DISPLAYON 0x0C		;To turnON LCD
 #define TRISEnable TRISA	;TRIS of PORT in that Enable pin is. 
 #define PORTEnable PORTA	;Port in that pin Enable is.
 #define PORTRS	PORTA	;Port in that pin RS is.
 #define TRISRS	TRISA	;TRIS of PORT in that RS pin is.
 #define RS 0		;Command or data
 #define Enable 1		;Pin to latch the data in LCD mem
 
 ;****************************************************************VAR DEFINITION
    CBLOCK 0x20
    delayvar:3
    counter
    ENDC
    
 org 0
 goto main
;********************************************************************MAIN RUTINE
main:
    call initialconfig
    call initialmsgLCD
    goto main
;******************************************************INITIAL MESSAGE SUBRUTINE
initialmsgLCD:
    clrf counter
initmsg1:    
    movlw HIGH msg1
    movwf PCLATH
    movf counter,W
    call msg1
    iorlw 0x00 ; To modify STATUS Register
    btfsc STATUS,Z
    return
    call pData
    incf counter,F
    goto initmsg1
    
;*******************************************************Configuration SUBRUTINES    
initialconfig:
    movlw 0x07 ; 7=PORTS as digital I/O
    movwf CMCON 
    
    banksel TRISLCDdata ;Chosse bank of LCD TRIS data PORT
    movf TRISLCDdata,W
    andlw bitsData
    andwf TRISLCDdata,F ;Setting direction only of LCD data pins
    
    banksel LCDdata ;Choose bank of LCD data PORT
    movf LCDdata,W
    andlw bitsData
    andwf LCDdata,F ;Setting initial values for LCD data pins
    
    banksel TRISEnable ;Data direction of Enable pin
    bcf TRISEnable,Enable
    banksel PORTEnable
    bcf PORTEnable,Enable  ;Initial value for Enable pin
    
    banksel TRISRS ;Data direction of Enable pin
    bcf TRISRS,RS
    banksel PORTRS
    bcf PORTRS,RS  ;Initial value for Enable pin  
    
    movlw 0x02
    call delayW0ms ; Wait 10ms for Start up of LCD
    
    clrf counter
init1:    movlw high ctrLCD ; Calling LCD control SUBRUTINE 
    movwf PCLATH
    movf counter,W
    call ctrLCD
    iorlw 0x00    ;for modify STATUS
    btfsc STATUS,Z ;0 means end of the table
    return
    call command 
    incf counter,F
    goto init1 
    
;******************************************************************LCD SUBRUTINE
pulseEnable:
    bsf PORTEnable,Enable
    nop
    bcf PORTEnable,Enable
    return
pData:
    movwf LCDdata
    bsf PORTRS,RS
    call pulseEnable
    movlw 0x02
    call delayW0ms ; Wait for execute another command or intruction
    return
command:
    movwf LCDdata
    bcf PORTRS,RS
    call pulseEnable
    movlw 0x02
    call delayW0ms ; Wait for execute another command or instruction
    return
;***************************************************************DELAY SUBRUTINES    
delay10ms:  ;4MHz frecuency oscillator
    movlw d'84'  ;A Value
    movwf delayvar+1
d0:   movlw d'38' ;B Value
    movwf delayvar  
    nop
d1:  decfsz delayvar,F
    goto d1
    decfsz delayvar+1,F
    goto d0      
    return ;2+1+1+A[1+1+1+B+1+2B-2]+A+1+2A-2+2 => 5+A[5+3B]
    
delayW0ms: ;It is neccesary load a properly value in the acumulator before use 
	   ;this subrutine
    movwf delayvar+2
d2:    call delay10ms
    decfsz delayvar+2,F
    goto d2
    return
    
;****************************************************************Packages to LCD   
ctrLCD: addwf PCL,F
     dt MODE8BIT5x8M,DISPLAYON,CLEARSCREEN,FIRSTLINE,0
msg1:addwf PCL,F
     dt " WELCOME        ",0 ;to call charge the PCLATH (HIGH msg1)
msg2:addwf PCL,F    
     dt " Time:          ",0 
    
 END