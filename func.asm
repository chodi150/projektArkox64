;argumenty:
; RDI - wskaznik na rysunek
; RSI - szerokosc
; RDX - wysokosc
; XMM0 - dlugosc odcinka s
; XMM1 - wspolczynnik A
; XMM2 - wspolczynnik B
; XMM3 - wspolczynnik C
;zmienne:

;xmm11 - dx
;xmm12 - dy
;xmm14 - ilosc px na jednostke szeroksoci
;xmm15 - ilosc px na jednostke wysokosci


section .text
global func
func:
	push        rbp
	push        rbx
	push        r12
	push        r13
	push        r14
	push        r15
	mov         rbp, rsp
	sub         rsp, 8
	
	mov r14, rsi
	mov r15, rdx	
        shl r14, 1                              ;szerokosc *2
        shl r15, 1                              ;wysokosc * 2

        mov r12, 512            		;liczba pikseli obrazka
        cvtsi2sd xmm14, r12     		;konwersja 512 na double
        movsd xmm15, xmm14              	;zapamietanie 512 jako double
        cvtsi2sd xmm13, r14     		; konwersja szerokosci na double
        divsd xmm14, xmm13       		;ile px na jednostke szerokosc

	cvtsi2sd xmm13, r15 			; konwersja wysokosci na double
        divsd xmm15, xmm13 			; ile px na jednostke wysokosc

        mov r14, rsi                            ;kopia szerokosci
        neg r14 				; chcemy zaczac iteracje od -x
	cvtsi2sd xmm4, r14 
        mov r9,1

loop:
	movsd xmm10, xmm4 			;przeniesienie x
	movsd xmm11, xmm4 			;potrzebne 3 kopie x
	movsd xmm12, xmm4 			; zapisanie x do rysowania odcinku
        movsd xmm13, xmm4
        mulsd xmm10, xmm10                      ; x^2

        mulsd xmm10, xmm1           		; ax ^2
        mulsd xmm11, xmm2           		; bx
        addsd xmm10, xmm11                      ;ax^2 + bx

        addsd xmm10, xmm3         	 	;ax^2 + bx +c
        movsd xmm5, xmm10          		; y = xmm5

        mov r8, 2
        cvtsi2sd xmm6, r8
        mulsd xmm6, xmm1           		;2*a
        mulsd xmm6, xmm13           		;2*ax
        addsd xmm6, xmm2            		;2*ax+b





        movsd [rbp-8], xmm6         		; wartosc pochodne w punkcie
        fld qword [rbp-8]           		; wrzucenie jej na stos rejestrow
        mov r8, 1
        cvtsi2sd xmm6, r8
        movsd [rbp-8], xmm6        		 ;wczytanie 1 pod adres [rbp-8]
        fld qword [rbp-8]           		 ; wrzucenie jej na stos rejestrow
        fpatan                      		;st(0) = arctg(a)
        fsincos                     		;=sin/cos(arctg(a))
        fstp qword[rbp-8]         		 ;odczytanie ze stosu cos(a)
        movsd xmm11, [rbp-8]        		; xmm11=cos(a)

        fstp qword[rbp-8]
        movsd xmm12, [rbp-8]        		; xmm12=sin(a)

        ;**************************************;
	;**********INFO**********************;
	;xmm11 - cos(a) ;xmm12 = sin(a)****;
	;x = xmm4 ; y = xmm5 **************
	;*************************************;
	;*************************************;

        mov r8, 0
        cvtsi2sd xmm6, r8                       ;licznik petli
        mov r8, 1
        cvtsi2sd xmm13, r8
        mov r8, 1000
        cvtsi2sd xmm7, r8
        divsd xmm13, xmm7   			;skok 1/100
drawLoop:
	;wyliczenie pikseli xmm7, xmm8

        addsd xmm6, xmm13 			;inkrementacja licznika

	movsd xmm7, xmm4			;x i y
	movsd xmm8, xmm5
        mulsd xmm7, xmm14           		; wyliczenie pikseli
        mulsd xmm8, xmm15          		; wyliczenie pikseli
        cvtsd2si r13, xmm7       	  	; konwersja wyliczonego x na l.całk
        cvtsd2si r14, xmm8                      ; konwersja wyliczonego y na l.całk

	add r13, 256 
	add r14, 256
	lea r13, [r13 + r13*2] 
	lea r14, [r14 + r14*2]
	shl r14, 9
        add r13, r14

        cmp r13, 0
        jl next
        cmp r13, 786432
        jg next

	mov [rdi+r13], BYTE 255
	mov [rdi+ r13+1], BYTE 255
        mov [rdi+ r13+2], BYTE 255

next:	
	movsd xmm9, xmm11  			;zapamietanie cos
        movsd xmm10, xmm12 			; zapamietanie sin
	mulsd xmm9, xmm6 			; wyliczenie dx = ds cos
	mulsd xmm10, xmm6			; wyliczenie dy = ds sin

	
        addsd xmm4, xmm9 			; x'=x+dx
        addsd xmm5, xmm10			; y'=y+dy
	


        movsd [rbp-8], xmm6			 ;aktualny licznik
        fld qword [rbp-8] ;
        movsd [rbp-8], xmm0 			; docelowa dlugosc linii
        fld qword [rbp-8] ;
        fcomip
        fstp
        ja drawLoop
        cmp ecx, 0
        jz end
        ;dec ecx
        mov r8, rsi 					;kopia szerokosci
        cvtsi2sd xmm10, r8
        movsd [rbp-8], xmm10 			; wartosc pochodne w punkcie
        fld qword [rbp-8] ;
        movsd [rbp-8], xmm4			 ; wartosc pochodne w punkcie
        fld qword [rbp-8] ;
        fcomip
        fstp
        ja end
	
        jmp loop

end:
                                      ; zwracana wartosc
	mov     rsp, rbp
	pop     r15
	pop     r14
	pop     r13
	pop     r12
	pop     rbx
	pop	rbp

	ret
