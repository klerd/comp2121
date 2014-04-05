/*
 * lab01Code.asm
 *
 *  Created: 25/03/2014 11:05:17 AM
 *   Author: lerdwichagul
 */ 
 string: .db '1', '2', '$'

 .include "m64def.inc"
 //register definitions
.def c = r18
.def n1 = r20
.def n2 = r21
.def ten = r22
.def result1 = r16;and r17
.def result2=r17
.equ zero = 0x30 ; ascii for 0
.equ tenAscii = 0x40 ; ascii for 9


.macro mul2      ; a * b
mul @0, @2  ; al * bl
movw @5:@4, r1:r0
mul @1, @2          ; ah * bl 
add @5, r0
mul @0, @3        ; bh * al
add @5, r0
.endmacro

//begin program
ldi r29,high(RAMEND)  ;RAMEND is the  highest SRAM address
ldi r28,low(RAMEND)   ;setting the pointers to SRAM RAMEND address
out SPH,r29             ;setting the stack pointers SP high 
out SPL,r28             ;setting the stack pointers SP low

;main body
ldi ZH, high(string<<1)
ldi ZL, low(string<<1)
rcall atoi

end:
rjmp end

atoi:
;prologue
push r29
push r28 ;store Y register address
push r31 ;store z register address
push r30
push c ;store current state of local variables
push n1
push n2
push result1
push result2
push ten

in r29,SPH
in r28,SPL ;update our pointer to the top of the stack


ldi ten,10
;sbiw r29:r28,1
;out SPH, r29
;out SPL, r28
;std Y+1,n

loop:

clr c
clr result1
clr result2
lpm c,Z+
cpi c,zero ;c>=0
brlo done
cpi c,tenAscii ;c && <=0
brge done
;ldd n, Y+1
mul n1,ten ; r1:r0 = n*10
movw result2:result1, r1:r0
mul n2, ten
add result2,r0
subi c,zero ;c = c - '0'
add result1,c ; n*10 + c - '0'
brcc not_add_c
ldi r23,1 
adc result2,r23
not_add_c:

movw n2:n1,result2:result1
;std Y+1, n
rjmp loop

done:
movw r25:r24,n2:n1

;pop stack stuff

pop ten
pop result2
pop result1
pop n2
pop n1
pop c
pop r30
pop r31
pop r28
pop r29
ret



