/***************************************************************************************
Example.3.2: This example demonstrates on how TIMER0 OVERFLOW interrupt can be used
to switch the speaker and motor on and off for approximately one second
The STACK POINTER is needed to keep track of the return address
***********************************************************************/
; connections:
; PB0-PB3 -> LED0 - LED3
; PB4 -> Mot
; Ain(Audio) -> OpD
; ASD -> Speaker (PIN 1)
; PB0(Switch) -> OpE
/**************************************************************************************/

.include "m64def.inc"

.def temp=r16
.def counter=r17
.def counter2=r18
.def counter3=r19
.def ledval=r20
.def offCounter = r22
.def repCounter = r23
;setting up the interrupt vector

jmp RESET
jmp Default ; IRQ0 Handler
jmp EXT_INT1 ;DEFINE what the interupt do
jmp Default ; IRQ2 Handler
jmp Default ; IRQ3 Handler
jmp Default ; IRQ4 Handler
jmp Default ; IRQ5 Handler
jmp Default ; IRQ6 Handler
jmp Default ; IRQ7 Handler
jmp Default ; Timer2 Compare Handler
jmp Default ; Timer2 Overflow Handler
jmp Default ; Timer1 Capture Handler
jmp Default ; Timer1 CompareA Handler
jmp Default ; Timer1 CompareB Handler
jmp Default ; Timer1 Overflow Handler
jmp Default ; Timer0 Compare Handler
jmp Timer0 ; Timer0 Overflow Handler]

Default: reti

RESET: ldi temp, high(RAMEND) ; Initialize stack pointer
out SPH, temp
ldi temp, low(RAMEND)
out SPL, temp
ldi counter,0
ldi counter2,0
ldi counter3,0
ldi temp,255
out DDRB,temp
ldi ledval,0
ldi offCounter, 0
ldi repCounter,0

//at the moment only experimenting with INT1
ldi temp, (2 << ISC10) ;setting the interrupts for falling edge
sts EICRA, temp ;storing them into EICRA 
in temp, EIMSK ;taking the values inside the EIMSK 
ori temp, (1<<INT1) ; oring the values with INT0 and INT1 
out EIMSK, temp ; enabling interrput0 and interrupt1
sei ; enabling the global interrupt..(MUST)

in ledval, PORTB
ori ledval, 0x0D
out PORTB,ledval

rjmp main

EXT_INT1:
push temp
in temp, SREG
push temp


ldi ledval, 255
ldi temp,1

//stuff

out PORTB,temp
pop temp
out SREG, temp
pop temp

reti

Timer0: ; Prologue starts.
push r29 ; Save all conflict registers in the prologue.
push r28
in r24, SREG
push r24 ; Prologue ends.

/**** a counter for 3597 is needed to get one second-- Three counters are used in this example **************/
; 3597 (1 interrupt 278microseconds therefore 3597 interrupts needed for 1 sec)
cpi repCounter, 3
breq stopProg
cpi counter, 97 ; counting for 97
brne notsecond

cpi counter2, 35 ; counting for 35
brne secondloop ; jumping into count 100

cpi ledval,0 ; compare the current ledval for zero
breq setFF ; if it is zero jump to set it to FF
cpi offCounter, 1
breq turnOff
inc offCounter 
rjmp outmot ; jump to out put value

stopProg: ;To be filled in

turnOff: ldi offCounter,0
ldi ledval,0
rjmp outmot

setFF: ldi ledval,0x0D ; set the ledval to FF
inc repCounter
rjmp outmot

outmot: ldi counter,0 ; clearing the counter values after counting 3597 interrupts which gives us one second
ldi counter2,0
ldi counter3,0
out PORTB,ledval ; sending the ledval to port
rjmp exit ; go to exit

notsecond: inc counter ; if it is not a second, increment the counter
rjmp exit

secondloop: inc counter3 ; counting 100 for every 35 times := 35*100 := 3500
cpi counter3,100
brne exit
inc counter2
ldi counter3,0
exit:
pop r24 ; Epilogue starts;
out SREG, r24 ; Restore all conflict registers from the stack.
pop r28
pop r29
reti ; Return from the interrupt.

main:
ldi temp, 0b00000010 ;
out TCCR0, temp ; Prescaling value=8 ;256*8/7.3728( Frequency of the clock 7.3728MHz, for the overflow it should go for 256 times)
ldi temp, 1<<TOIE0 ; =278 microseconds
out TIMSK, temp ; T/C0 interrupt enable
sei ; Enable global interrupt
loop: rjmp loop ; loop forever
