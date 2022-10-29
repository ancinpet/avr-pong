#define left 2 ;left button
#define right 3 ;right button
#define up 6 ;up button
#define down 7 ;down button
#define middle 4 ;middle button
#define kulicka 42
#define true 1
#define false 0

;read_joystick -> r2:stav
;show_char <- r16:znak, <- r17:pozice


.include "m169def.inc"
; podprogramy pro praci s displejem
.org 0x1000
.include "print.inc"
.include "read.inc"

.dseg
.org 0x100
sekundy: .byte 1

.cseg
.org 0x0000
jmp start
.org 0x000A
jmp int_T2
.org 0x0100


start:

; Inicializace zasobniku
	ldi r16, 0xFF
	out SPL, r16
	ldi r16, 0x04
	out SPH, r16
    ; Inicializace displeje
	call init_disp
	 
ldi r16, 0x00
out SPL, r16
ldi r16, 0x04
out SPH, r16 
cli ; globální zakázání prerušení
ldi r16, 0b00001000
sts ASSR, r16 ; vyber hodiny od
; krystalového
; oscilátoru 32768 Hz
ldi r16, 0b00000001
sts TIMSK2, r16 ; povolení prerušení
; od casovace 2
ldi r16, 0b00000101 ;101 - 1 sekunda, 011 - 0.25 sekundy, 111 - 8 sekund - dobre v simulatoru
sts TCCR2A, r16 ; spuštení cítace s
; delicím pomerem 128
clr r16 ; zákaz prerušení od
out EIMSK, r16 ; joysticku
sei ; globální povolení prerušení

;joystick
in r17, DDRE
andi r17, 0b11110011
in r16, PORTE
ori r16, 0b00001100
out DDRE, r17
out PORTE, r16
ldi r16, 0b00000000
sts DIDR1, r16
in r17, DDRB
andi r17, 0b00101111
in r16, PORTB
ori r16, 0b11010000
out DDRB, r17
out PORTB, r16

;konec inicializace
jmp zacatek

;obsluha preruseni, 1x za sekundu
int_T2: 
push r16 
in r16, SREG 
push r16 
lds r16, sekundy 
inc r16 
sts sekundy, r16 
ldi r16, 1
mov r0, r16
pop r16
out SREG, r16
pop r16
reti


zacatek:							;/////////////////////////////////////////////////// ZACATEK PROGRAMU
call clear_display
call show_start

menu:								;/////////////////////////////////////////////////// MAIN MENU
call read_joystick ; -> r2

sbrs r2, middle
jmp game_start

call clear_display ;vycisti display

mov r16, r2 ;pro test vypis registr r2 - stav joysticku na display
call show_score ;vypise registr r16 na display

jmp menu

;r0 - nastal pohyb
;r1 - pozice kulicky
;r2 - stav joysticku
;r3 - skore
;r4 - druh kulicky
;r5 - smer pohybu - 0 = vlevo, 1 = vpravo

game_start:							;/////////////////////////////////////////////////// NOVA HRA
;resetuj pohyb
clr r0

;nastav kulicku na pozici 5
ldi r17, 5
mov r1, r17

;vynuluj skore
ldi r16, -1
mov r3, r16

;nastav typ kulicky
ldi r16, kulicka
mov r4, r16

;zaciname pohybem vlevo
clr r5

;vycisti displej a zobraz
call clear_display
call show_char

jmp game


game:								;/////////////////////////////////////////////////// HLAVNI LOOP HRY
call read_joystick
ldi r16, true
cp r0, r16
breq nastal_pohyb

jmp game

nastal_pohyb:						;/////////////////////////////////////////////////// UBEHL CASOVY INTERVAL
clr r0

;jestli jsem na kraji
ldi r16, 2
cp r1, r16
breq kraj_levo

;jestli jsem na kraji
ldi r16, 7
cp r1, r16
breq kraj_pravo

;nejsem na kraji
jmp nekraj

konec_pohyb:						;/////////////////////////////////////////////////// DOKONCENI POHYBU

;vycisti display a vykresli novou pozici kulicky
call clear_display
mov r16, r4
mov r17, r1
call show_char

;vycisti joystick
clr r2

jmp game

kraj_levo:							;/////////////////////////////////////////////////// JSEM NA LEVEM KRAJI

;jestli jsem zmackl vlevo, konec hry
sbrs r2, left
jmp konec_hry

;jestli jsem nezmackl vpravo, konec hry
sbrc r2, right
jmp konec_hry

;zmen smer pohybu doprava
ldi r16, 1
mov r5, r16

;zvys pozici
inc r1

jmp konec_pohyb

kraj_pravo:							;/////////////////////////////////////////////////// JSEM NA PRAVEM KRAJI

;jestli jsem zmackl vpravo, konec hry
sbrs r2, right
jmp konec_hry

;jestli jsem nezmackl vlevo, konec hry
sbrc r2, left
jmp konec_hry

;zmen smer pohybu doleva
clr r5

;sniz pozici
dec r1

jmp konec_pohyb

nekraj:   							;/////////////////////////////////////////////////// NEJSEM NA KRAJI

;zvys skore jestli jsem na pozici 5 a smer je vlevo r1 = 5 a r5 = 0
mov r16, r1
cpi r16, 5
brne nezvysuj

mov r16, r5
cpi r16, 0
brne nezvysuj

inc r3

nezvysuj:

;jestli jsem neco zmackl konec hry
sbrs r2, left
jmp konec_hry

sbrs r2, right
jmp konec_hry

;jestli neni smer vlevo, neubirej pozici
ldi r16, 0
cp r5, r16
brne neubirej

dec r1

neubirej:

;jestli neni smer vpravo, nepridavej pozici
ldi r16, 1
cp r5, r16
brne nepridavej

inc r1

nepridavej:

jmp konec_pohyb


konec_hry:
call clear_display
call show_looser

cekej_na_score:
call read_joystick
sbrc r2, middle
jmp cekej_na_score

;ukaz skore
call clear_display

mov r16, r3
call show_score

call cekaci_smycka
call cekaci_smycka
call cekaci_smycka
call cekaci_smycka
call cekaci_smycka

cekej_na_novou_hru:
call read_joystick
sbrc r2, middle
jmp cekej_na_novou_hru

jmp zacatek
