read_joystick:
	push r16
	push r17
	push r18
	push r19
	push r20

read_inputs:
	in r16, PINB
	in r17, PINE
	or r16, r17

		ldi r20, 10
cek2:	ldi r19, 255
cek:	dec r19
		brne cek
		dec r20
		brne cek2

	in r17, PINE
	in r18, PINB
	or r17, r18

	cp r16, r17
	brne read_inputs

	mov r2, r16

	pop r20
	pop r19
	pop r18
	pop r17
	pop r16
ret


show_start:
	push r16
	push r17

	ldi r16, 'S'
	ldi r17, 2
	call show_char

	ldi r16, 'T'
	ldi r17, 3
	call show_char

	ldi r16, 'A'
	ldi r17, 4
	call show_char

	ldi r16, 'R'
	ldi r17, 5
	call show_char

	ldi r16, 'T'
	ldi r17, 6
	call show_char

	pop r17
	pop r16

ret

clear_display:
	push r16
	push r17

	ldi r16, 32
	ldi r17, 2
	call show_char

	ldi r16, 32
	ldi r17, 3
	call show_char

	ldi r16, 32
	ldi r17, 4
	call show_char

	ldi r16, 32
	ldi r17, 5
	call show_char

	ldi r16, 32
	ldi r17, 6
	call show_char

	ldi r16, 32
	ldi r17, 7
	call show_char

	pop r17
	pop r16

ret

show_looser:
	push r16
	push r17

	ldi r16, 'L'
	ldi r17, 2
	call show_char

	ldi r16, 'O'
	ldi r17, 3
	call show_char

	ldi r16, 'S'
	ldi r17, 4
	call show_char

	ldi r16, 'E'
	ldi r17, 5
	call show_char

	ldi r16, 'R'
	ldi r17, 6
	call show_char

	call cekaci_smycka
	call cekaci_smycka

	call clear_display

	call cekaci_smycka
	call cekaci_smycka

	ldi r16, 'L'
	ldi r17, 2
	call show_char

	ldi r16, 'O'
	ldi r17, 3
	call show_char

	ldi r16, 'S'
	ldi r17, 4
	call show_char

	ldi r16, 'E'
	ldi r17, 5
	call show_char

	ldi r16, 'R'
	ldi r17, 6
	call show_char

	call cekaci_smycka
	call cekaci_smycka

	call clear_display

	call cekaci_smycka
	call cekaci_smycka

	ldi r16, 'L'
	ldi r17, 2
	call show_char

	ldi r16, 'O'
	ldi r17, 3
	call show_char

	ldi r16, 'S'
	ldi r17, 4
	call show_char

	ldi r16, 'E'
	ldi r17, 5
	call show_char

	ldi r16, 'R'
	ldi r17, 6
	call show_char

	pop r17
	pop r16

ret

cekaci_smycka:
	push r16
	push r17

		ldi r17, 255
cekam2:	ldi r16, 255
cekam:	dec r16
		brne cekam
		dec r17
		brne cekam2

	pop r17
	pop r16

ret

;vypise cislo v r16
show_score:
	push r16
	push r17
	push r20
	push r21
	push r28

	mov r20, r16
	mov r21, r16

	lsr r21
	lsr r21
	lsr r21
	lsr r21

	lsl r20
	lsl r20
	lsl r20
	lsl r20
	lsr r20
	lsr r20
	lsr r20
	lsr r20

	;podminka na cislo A
	cpi r20, 0xA
	brlt cisloA

	;znakA:
	ldi r28, 55 ; case A(10) : add 55 = 65 = 'A' 
	add r20, r28

	jmp second

	cisloA:
	ldi r28, 48
	add r20, r28

	second:

	;podminka na cislo B
	cpi r21, 0xA
	brlt cisloB

	;znakB:
	ldi r28, 55 ; case A(10) : add 55 = 65 = 'A' 
	add r21, r28

	jmp print

	cisloB:
	ldi r28, 48
	add r21, r28

	print:
	mov r16, r21
	ldi r17, 4
	call show_char

	mov r16, r20
	ldi r17, 5
	call show_char

	pop r28
	pop r21
	pop r20
	pop r17
	pop r16

ret
