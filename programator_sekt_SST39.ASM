; ZAPIS FLASH SST39SFxxx /128kB do 512kB/ 
; umieszczonej w plytce programatora 28Cxxx! pod zlacze "phil - 40 pinowe
; dostep do FLASH od 4000 do 7FFF - 16 KB
; pozostale 32 sektorow po 16 KB wybierane 
; portem PB ukladu 8255 -PB0 do PB4 /A14, A15, A16, A17 i A18
; zapis programow od poczatku sektora, program moze byc dluzszy niz
; tylko jeden sektor - sektor 0-FFF

; FD E1..E3..E5..E9 zajete jako instrukcje Z80 ! wolne E2, E4, E6, E7, E8
;include "D:\CA80\programy\moje\aktul_CA\CA_proced.asm"
HILO:      EQU 23bh      ;  w MONITORze CA80
PRINT:     EQU 01D4h     ; wysw. komunikatu /CA80/ wg (HL), koniec FF
PARAM:     EQU 01F4h     ; pobiera bajty do hl, podac PWYS
EXPR:      EQU 0213h     ; pobranie liczb szesnastkowych na stos
LADR:      EQU 20h       ; LADR - wyswietlenie rej. HL w postaci HEX
LBYTE:     EQU 18h       ; LBYTE - wyswietlenie rej. A w postaci HEX
KO3:       EQU 0A23h     ; "Error" z CA80
KOMERR:    EQU #34       ; "Err"
ERR:       EQU 0A23h     ; tekst "Err" ca80
CLR:       EQU 10h       ; CLR - kasowanie wyswietlacza
CLR1:      EQU 11h       ; CLR1 - kasowanie wyswietlacza bez zmiany PWYS
TI:        EQU 7         ; TI - pobranie znaku z echem na CA80
TI1:       EQU 8         ; j.w. lecz bez ustawiania PWYSW
PWYS:      EQU 0FFF6h    ; PWYS
;USPWYS:    EQU 28h       ; ustawienie paramet. wyswietlania
clr_buf:   EQU 0CA0h     ; zerowanie bufora z kalkulatora CA80
CO:        EQU 01E0h     ; wyswietlenie cyfry szesnastkowej umieszczonej w rej. C w/g PWYS
CSTS:      EQU 0FFC3h    ; czy klaw. wcisniety ?
CI:        EQU 0FFC6h    ; czekanie na puszczenie klawisza a potem na wcisniec
COM:       EQU #1AB      ; wysw. kodu znaku z rej. C
;NMIU:      EQU 0FFCCh    ; obsluga przerwania niemaskowalnego uzytkownika
CIM:       EQU 184H      ; jak CSTS
PLEW:      EQU 0C56h     ; przesuniecie bufora w lewo o 1/CA88
CYF0:      EQU 0FFF7h    ; wysw. cyfry na pozycji 0 wyswietlacza CA80
CYF1:      EQU 0FFF8h    ; wysw. cyfry na pozycji 1
CYF2:      EQU 0FFF9h
CYF3:      EQU 0FFFAh
CYF4:      EQU 0FFFBh
CYF5:      EQU 0FFFCh
CYF6:      EQU 0FFFDh
CYF7:      EQU 0FFFEh
TSIED:     EQU 0318h     ; tabl. zawieraj. kody 7-segm. cyfr szesnast.dla potrzeb wyswietl.

adr5:      EQU #5555    ; konfiguracja dla SST39FSxxx w plytce programatora 28Cxxx
adrA:      EQU #6AAA     ; konfiguracja j.w.
FL:        EQU #4000     ; adres pamieci FLASH na plytce  j.w., pod tym adresem, CA "widzi" FLASH
;BUFOR:     EQU #F000     ; poczatek bufora w RAM
SEKT:      EQU #EFFF      ; numer sektora - ustawiany przez (LS373), chodzi o najstarsza cyfre 5
max_zap:   EQU #DFFF      ; max zapis do RAM CA80
DL_SEKT:   EQU 0FFFh     ; dlugosc sektora 4 kB - koniec na FFFh
PR_CA:     EQU 0FE30h    ; tu beda zapisywane odczytane numery programow / 1,2 ...itd/ - na 144 programow
FL_DANE:   EQU 0FEC0h    ; tu adres zapisu do FLASH SST 39xxx   ; moze byc np. 5abc
end_sekt:  EQU #20       ; il. sektorow -1 po 16 KB dla 512 KB, F dla 256 KB i 8 dla 128 KB
end_S16:   eQU #80       ; koniec sektora 16 KB - 4000 - 7FFF
il_sekt_FL:EQU #80       ; il. sektorow dla 512 KB, 40 dla 256 a 20 dla 128 KB
SEKT_P:    EQU FL_DANE+4 ; tu aktualny nr sektora - FEC4
r_od:      EQU FL_DANE+5 ; pocz. programu w CA - FED5-FEC6
dl_zap:    EQU r_od+2    ; dlugosc zapisu - ile bajtow - FEC7-FEC8
r_do:      EQU r_od+4    ; koniec programu w CA - FEC9-FECA
buf_adr:   EQU dl_zap+6  ; 5. bajtow w RAM CA80 na adres FLASH -> FECC
p_pr_FL:   EQU dl_zap+11 ; FED2 -pocz. prog. w pam. FLASH podczas zap. nr programu
su_CA:     EQU p_pr_FL+2 ; przechowanie sumy kontrolnej programu z CA
A14_A18    EQU su_CA+4   ; ten bajt ustawia adres na A14-A18 - nr sekt. a' 16 KB
nr_sekt:   EQU A14_A18+1 ; ten bajt wysw. na 5. i 4. cyfrze CA jako adres - czyli to jest nr sektora FLASH
adr48:     EQU nr_sekt+1 ; wybor -czy do adresu FL dodac 4000 czy 8000     ; sektor FL 0 - FFF
mar_PR:    EQU 0FDE4h    ; marker pocz. programu FD E4
mar_NAZ:   EQU 0DDE2h    ; marker pocz. nazwy DD E2, moze byc inny, np. FD E4
KEY:       EQU #CA80     ; haslo do kasowania calej pamieci FLASH
  ; LCD
L1:        EQU 80h       ; pocz. 1. linii LCD
L2:        EQU 0C0h      ; pocz. 2. linii
L3:        EQU 94h       ; pocz. 3. linii
L4:        EQU 0D4h      ; pocz. 4. linii
ile_cyf:   EQU 0FEFCh    ; ile cyfr wywietlac na CA80
poz_wys:   EQU ile_cyf+1 ; 0FEFDh
poz_cyf:   EQU ile_cyf+2 ; 0FEFEh ; tu akt. pozycja CYF /od FFF7 do max FFFE /
nr_L:      EQU 0FEEAh    ; tu aktualnie wyswiet. nr linii
pr_ile:    EQU 0FE1Bh    ; ilosc znalezionych programow
nr_pr:     EQU pr_ile+1   ; tu nr programu podczas szukania
instr:     EQU 0E8h      ; INSTRUKCJA LCD
DANA:      EQU 0E9h      ; DANA
LCD_RDR    EQU 0EBh      ; odczyt pozycji kursora
LCD_BUSY   EQU 0EAh      ; odczyt
PW:        EQU #E1  ;PA-E0, PB-E1,PC-E2     ; port podlaczenia adresow A15 - A18 FLASH
                   ; na PC - PC0 i PC4 jest pamiec I2C z podciagnitymi SDA i SCL do +5 V
                   ; PA0-PA4 i PB0-PB4 sa wolne
CRTL:      EQU #E3  ; slowo kontrolone do 8255
WYJ:       EQU #80  ; PA, PB, PC jako WYJ
;WEJ:       EQU #82  ; PA-WEJ , PB, PC WYJ

  ;===
  ; ; format pliku z nr i nazwami programu w pamieci FLASH /przyklad/:
  ; FD E4 pocz. programu na pocz. sektora FL
  ; 00 - nr programu
  ; 00 C0 ; dwa bajty - pocz. programu w RAM CA80 - tu od C000h
  ; 00 C1 ; dwa bajty - koniec programu w CA
  ; 31 66 FF.. .. ..  - nasz program
  ; wewnatrz programu nazwa, po DD E2
  ; FD E4 pocz. nastepnego - programu na pocz. nastepnego sektora FL
  ; 01 .....program nr 1
  ; 00 D0  ; pocz. programu w CA80 - od D000h
  ; 00 d5  ; koniec programu w CA
  ; 21 11 22 .. .. ..  program
  ; FD E4 pocz. nastepnego - programu na pocz. nastepnego sektora FL.
  ; 02 ..... itd
  ; programator_sekt - kazdy program zaczyna sie od pocz. sektora FLASH :0000,  1000, 2000 itd

 ORG #E000 
 zap_FL:
  ld sp, 0FF66h
  ld HL,obs_przer  ; wlaczenie obslugi "F1" w NMI - dolny lewy
  ld (CI+1),HL
EEP_1:
  rst 10h
  defb 80h ; po powrocie, gdy wcis. klaw F1/Z/ , czysc wysw. CA
  ld hl, flash2
  call print ; "FlaSh_2" na CA
  defb 71h
  call ini_LCD
  call wpis_PLD ; duze polskie znaki diakrytyczne
  call wysw_kom_1
   ; ustaw port <PW> -- u mnie PB, na WYJ
  ld A, WYJ ; 80h
  out (CRTL), A
 ab:   ;
  call TI ; pobierz nr zlec.
  defb 17h
  ld E,A             ; nr zlecenia
  cp LCTX            ; czy "legalne"
  jp nc,ERFL ; nielegalne
  rst CLR
  defb 70H
  ld HL,CTBLX        ;tablica rozejsc
  ld D,0             ;w E numer zlecenia
  add HL,DE
  add HL,DE
  ld E,(HL)
  inc HL
  ld D,(HL)
  ex DE,HL
  jp (HL)            ;Pseudo CALL

ERFL:
        rst CLR
        defb 80H
        ld HL,KOMERR
        call PRINT
        defb 35H
        jr zap_FL

CTBLX:
        defw Z0  ;kasuj cala pamiec lub wybrany sektor - 4 KB
        defw Z1  ;Szukaj pierwszy wolny nr programu /przy zapisie programu
        defw Z2  ;Kasuj sektor
        ;defw Z3  ;suma kontrolna FLASH, od 0 do konca programow FD E4 FF  
        defw Z3  ;Zapisz RAM do FLASH
        defw Z4  ;szukaj programow/wysw. nr i nazwe
        defw Z5 ;przepisz obzar z  LASH  do RAM
   ;     defw Z7  ; umiejscowienie programu w pam. FLASH i CA 
   ;     defw Z8
 
LCTX:   EQU ($-CTBLX)/2

OBS_PRZER: ; obsluga, gdy wcisniemy klawisz F1 - powrot na pocz. programu
  call CIM   ;jak CD F3 FF
  push AF
  cp 17H     ; kod klaw. "F1"
  jp z, EEP_1
  pop AF
  ret

Z0:
ERASE: ; kasowanie CALEJ pamieci SST39EExxx "FF" 128 -512 kB
   ld a, 1               ;lub sektora /4 kB/
   out (instr), A
   call busy
   ld a, L4
   out (instr), A
   ld hl, erase_FL ;  "KASOWAC FLASH ?"
   call wys_tekst
   call busy
   ld hl, klaw_C ; "KLAW. C CALA PAMIEC"
   call wys_tekst
   ld hl, klaw_2 ; "KLAW. 2 SEKT nr 0-7F",
   call wys_tekst
   call op_100ms
   defb 7 ; opozn. ok. 0,7 sek
 er12:
   ld a, 8 ; wylacz LCD
   out (instr), a
   call op_100ms
   defb 7 ; opozn. ok. 0,7 sek
   ld a, 0Ch
   out (instr), A
   call op_100ms
   defb 7
   call CSTS ;  wcis. klaw.
   cp 2  ; czy klaw. 2 - kasuj tylko jeden sektor
   jr z, wyb_sekt
   cp 0Ch ; czy klaw. C
   jr nz, er12
   ;jr er12

 er13:
   ld a, L3 ; linia 3.
   ld b, 20  ; wszystkie znaki
   call CLR_LCD_ZN ;
   ld HL, klaw_C1
   call wys_tekst
 er131:
   call CSTS
   cp 10h ; " G " ; powrot do Z0
   jr z, Z0
   cp 0Eh ; " E " ? - kasuj cala pamiec
   jr nz, er131
   ;jr er131
 er132:
   call er11 ; kasuj cala pamiec
 er133:
   ld hl, er_ok ; "ERASE OK"  po skasowaniu
   call print
   defb 80h
   rst 8 ; CF
   jp zap_FL
    ; KASOWANIE CALEJ PAMIECI !!!
 er11:  ; zabezpieczone haslem
  ld HL, haslo
  call print 
  defb #53
  call PARAM ; pobierz haslo
  defb #40
  or A ; CY=0 
  ld DE, key ; nasze haslo to "CA80" , zmien w KEY
  sbc HL, DE
  jr nz, er11
   ld A, #80
   out (CRTL), A ; slowo  kontroln: porty PA, Pb PC jako WYJ
  ld hl, adr5  ; HL - 5555h- tak "widzi" moj CA, gdy A14 = 1 -moja wersja !  oryg #5555
  ld de, adrA  ; DE - 6AAAh - tak "widzi" moj CA  oryg #2AAA
               ; po wybraniu pierwszych 16 KB FLASH
   ld A, 1   ; na port B 
   out (PW), A
  ld B, #55
  ld (hl), E       ; 1 cykl pod 5555 dana AA
  xor A ; 0
  out (PW), A
  ld A, B ; 55
  ld (de), A       ; 2 cykl pod 6AAA ->   55
   ld A, 1
   out (PW), A
  ld (hl), #80     ; 3 cykl pod 5555 ->   80
  ld (hl), E     ; 4 cykl pod  5555 =>   AA
  xor A ; 0
  out (PW), A
  ld A, B
  ld (de), a       ; 5 cykl pod 6AAA ->   55
   ld A, 1
   out (PW), A
  ld (hl), #10     ; 6 cykl pod 5555 ->   10
  ld b, 11  ; nota katalog. Tsce max 20ms
 er2:
  halt ; 2 ms
  djnz er2
  ret
         ; wcisnisnieto klaw. 2 - kasowanie tylko jednego sektora
wyb_sekt: ; sektora FLASH 0-7F
  ld a, L1 ; wpisz normalnie nr sektora 
  ld b, 20 ; tyle znakow skasowac na LCD
  call CLR_LCD_ZN
  halt
 wyb1A:
  rst 10h
  defb 80h
  ld HL, nr_sect ;"nr.SEct" na CA
  call print
  defb 62h
  ld a, L1
  out (INSTR), A
  ld hl, sekt_wyb  ; "podaj nr sektora" na LCD
  call wys_tekst
  ld c, 1 ; jeden parametr
  call EXPR ; pobierz na stos
  defb 20h
  pop bc ; C nr sektora
  ld a, c
  cp 80h ; sektory 0 - 7F !!! dl a FLASH SST 39 SF 040
  jr nc, wyb1A        ; 3F dla ..020 i 1F dla ..010
  push AF ; przechowaj
  call kas_sekt
  ld A,IXH
  ld H, A
  xor A
  ld L, A
  ld A, (HL)
  cp #FF
  jp z, er133 ; "Erase OK" ma CA
  ld HL, KO3  ; "Error" na CA80
  call print
  defb #53
  rst 8 ; CF
  jp EEP_1

kas_sekt: ; nr sektora wpisz normalnie 0-7F, kazde 16 KB ma 4. sektory
  ld IXL, A ;  ochrona nr sektora do kasowania
  push AF ; do wyswietlenia na CA
  EXX ; chron rejestry
  call set_sekt_FL  ; oblicz adres sektora FL: ustaw <adr14_A18> i sektor FL w tym obszarze
   ;
  ld HL, adr5    ; adres 5555h - sektor nr 1  - 16 KB
  ld DE, adrA    ; adres 6AAAh - sektor 0 - 16 KB!
  ld A, 1 ; dla HL = 5555
  out (PW), A ; dla adr.  5555 - "drugie" 16 KB
  ld (HL),E   ; 1. cykl - dana AA pod adres 5555 - moja wersja programatora 28Cxxx!
  xor A ; A =  dla DE
  out (PW), A  ;
  ld A, L ; 55
  ld (DE), A     ; 2. cykl - dana 55 -> 6AAA
  ld A, 1 ; dla HL
  out (PW), A
  ld (HL), 80H   ; 3. cykl -dana 80 -> 5555
  ld (HL), E  ; 4. cykl -dana AA -> 5555
  xor A ; A = 0
  out (PW), A
  ld A, L    
  ld (DE), A     ; 5. cykl -dana 55 -> 6AAA
     ; teraz 6. cykl - pod dowolny adres w wybranym /kasowanym/ sektorzse wpisz 30h
  ld A, C ; nr sektora
  out (PW), A ; wybierz sektor 16 KB

  ld H, B  ; teraz adres HL, wazne tylko najstarsze bajty adresu czyli H , L nie jest wazne
          ; nota katalogowa s.10 / wyzsze bajty ustawia 8255 na porcie PB , bity 0-3
  ld (HL), 30H   ; 6. cykl -dana 30 -> pod starszy polbajt to nr sektora  
                 ;  a mlodszy to 55h
  ld B,0FH       ; op. ok. 32 ms
 op3:
  halt           ; 2 ms
  djnz  op3      ; max 25 ms
  EXX
  pop AF ; do wyswietlenia na CA
  ret

set_sekt_FL: ; oblicz adres sektora FL: ustaw <adr14_A18> i sektor FL w tym obszarze
  ld A, IXL ; nr sektora             ; sek FL 41xx 42xx 43xx lub 44xx
  and #7 ;
  ld H, #40
  res 2,A
  rla
  rla
  rla
  rla
  add A, H ; adres 40xx, 41xx, 42xx, 43xx
  ld B, A ; zapamietanie starszych bajtow adr. HL
  ld IXH, A ; do kontroli kasowania
  ; teraz ustalmy ktory to sektor 16 KB
  ld A, IXL
  rrca
  rrca
  and #1F 
  ld C, A ; nr sektora po 16 KB
  ld (A14_A18), A
     ; WYJ B = starsze bajty adr. HL = 40.. 50.. 60.. 70..
     ;     C = nr sek a '16 KB
  ret
;==
Z1:    ; szukaj pierwszy wolny numer programu
  call CLR_OB   ; "zerowanie" / FF/ obszaru do wpisywania odczytanych numerow programu
  xor A
  out (PW), A ; zaczynamy od sekt. 0
  ld (A14_A18), A
  call szuk_numer ; znajdz numery progr. i wpisz do RAM CA80 
    ; ktory numer programu jest wolny oraz ile programow znaleziono
  call free_1_nr   
 nr2:  ; znaleziono nr nieuzywany - pierwszy wolny
   ld E, A; dla CA
   call wys_1_free
   ld A, E ; zapamietanie do porownania
   rst LBYTE ; wysw. rej. A PWYS 20  wolny numer
   defb 20h
   ld HL, nr_fr ; nrFree
   call print
   defb 62h
   ld A, 0Fh ; kursor jako mrugajacy blok, dla zwrocenia uwagi
   out (INSTR), A
   halt
   ld A, L4+17
   out (INSTR), A
   rst 8 ; CF czekaj na klawisz
   ld a, 0Eh ; kurosor jako belka
   out (INSTR), A
   jp EEP_1
   ;====
free_1_nr: ; ktory pierwszy wolny
  ld e, 0 ; zaczynamy od 0 moze byc 1
 nr0:
   ld a, e ; szukamy tego numeru od <PR_CA> FC-FC7d
   ld HL, pr_ca ; pocz. szukania
   ld bc, 7Dh ; koniec obszaru, numery prog. 1 do 99, FD, FE, FF to markery
   cpir ; porownuje (HL) z A, HL+1, BC-1
   ret PO ;jp po, nr2
   ld a, e
   inc a
   nop ; daa ;  27  ; tu ograniczamy numery programów do liczb dziesietnych 1-99
   ld e, a    ; jesli chcesz wiecej, wykresl DAA
   jr nr0

wys_1_free:
   push af ; dla LCD
   ld a, L4
   out (INSTR), a
   ld HL, nr_1WOL; tekst na LCD "pierwszy wolny nr " <rej.A>
   call wys_tekst ; bez INC (IX) = przeskok na nastepna linie
   pop af               
   call wysw_A ; na LCD
   ret

CLR_OB:; "zerowanie" / FF/ obszaru do wpisywania odczytanych numerow programu
  ld B, 7Dh ; max il. programow - 99 , tyle przyjalem
  ld HL, PR_CA ; FE30h
  ld a, 0FFh
 pr1:
  ld (HL), A
  inc hl
  djnz PR1
  ret

szuk_numer:   ; zaczynamy od sektora 0 w pam. FL
  ld IY, PR_CA ; tu zapisuj /RAM CA80/ odczytane numery programow
;Z11:
  ;LD DE, mar_PR ;w DE marker pocz. programu /po FD E4 jest nr programu/
  ld IXL, 0 ;nr pierwszego sektora, pozniej, podczas szukania, bedzie zwiekszany o 1
  call set_sekt_FL ; ustaw CA na pocz. szukania - 0. sektor
     
 szuk_wnr:  ; szukanie numerow programow w pam. FL
  ld Hl, FL ; 4000 - 
  ld E, 0 ; #FF 
 z12: 
  ld A, (HL) ; jesli  FF FF - sektor "pusty"
  cp #FF
  jr nz, to_program
  inc HL
  ld A, (HL)
  cp #FF
  jr nz, to_program
  jr wn ; wolny numer programu

 to_program:
  ld (IY+0), E ; wpis do RAM CA80
  inc E
  inc IY
 wn:
  inc IXL ; nastepny sektor FL a' 4 KB /0-FFF
  ld A, IXL
  cp il_sekt_FL ; 7F dla 512 KB, 40 dla 256 i 20 dl 128 KB
  ret z 
  call set_sekt_FL ; sektor FL 40.. 50.. 60.. lub 70..
  ld A, C        ;  C = nr sek a' 16 KB
  out (PW), A        ;     B = starsze bajty adr. HL 40.. 50.. 60.. 70..
  ld H, B
  xor A
  ld L, A          
  jr z12 

 ;==============
Z2:  ; przeglad FLASH  SST39SFxxx
  ld a, 1
  out (instr), A ; czysc LCD  ; D7 80
  call busy
  ld a, L4
  out (instr), A
  halt
  ld hl, przeg
  call wys_tekst
 P21:
  rst 10h ; D7 czysc wysw. CA
  defb 40h          ; ; np. adres 65432 : FECF-32, FED0-54, FED1-06
                      ;         i rowniez FEC0 i FEC1 <FL_DANE>
  call zap_FL39_od ; pobranie adr. /i kontrola/ pocz. przegladania
  jr nc, P21 ; adres FL prawidlowy /dla 512 kB -max to 7.FFFF
                        ; dla 128 kB - 1.FFFF, 256 kB - 3.FFFF
   ; ADRES OK                
 P22:
  ld hl, (buf_adr+2)
  PUSH  HL
  POP   IX  ; potrzebne do <set_adr>
  LD    (FL_DANE),HL   ; przechowanie
  call sek16 ; "OUT (PW), A" - sektor 16 KB
  CALL  set_adr  ; ustaw adres FL na podstawie adresu, adres moze byc 5. cyfrowy
 ; PUSH IX
 ; POP HL
  rst 10h ; D7 czysc wysw. CA 
  defb #30
  jr PU0

 P22a: ;przy "cofaniu", przekracznie 0000 na FFFF - ustawienie adresu
  ld a, L
  cp 0FFh
  jr nz, PU0
  ld a, H
  cp #BF
  push AF ; ochrona flagi
  ld A, (nr_sekt) ; 0-FFF
  dec A
  ld (nr_sekt), A
  pop AF 
  jr nz, PU0
  ld H, #40
  dec a ; ??
  cp 0FFh ; ??
  jr nz, P22b
  ld a, 7Fh ; ostatni sektor /dla FLASH 512 kB, 1F - 128 kB, 3F - 256 kB
 P22b:
 PU0:
  RST   LADR      ; wysw. adresu poczatk.
  DEFB  43H
  ld a, (nr_sekt) ; wysw. sektora i nadpisanie starszego polbajtu H
  ;ld A, (SEKT) ; **
  rst LBYTE
  defb #26 ; "nadpisz"  dwie najstarsze cyfry adresu
  LD    A,(HL)    ; pobranie danej
  RST   LBYTE     ; wyswietlenie (HL)
  DEFB  20H
  RST   TI1       ; pobr. znaku
  JR    C,PU1     ; wcisnieto CR / = /
  DEC   HL        ; do tylu
  JR    Z, P22A; SU0     ; wcisnieto SPAC / . /
  INC   HL        ; odtworzenie HL
  CP    10H       ;klaw. G - nowy adres
  jr z, P21
    ; wprowadzanie zakonczono klawiszem CR/=/, zwieksz adres
 PU1:
  INC   HL        ; do przodu
  ld A, L
  cp 0
  jr nz, pu11
  ld A, H
  and #0F
  cp 0
  jr nz, pu11
  ld A, (nr_sekt); 0-FFF
  inc A
  ld (nr_sekt), A      
 pu11:
  call spr_adr_prz ; sprawdz adres, czy koniec sektora - z 7FFF przeskok na 8000
  JR    PU0
; pu12:  
spr_adr_prz: ; przeskok na nastepny sektor ?
  ld A, H  ;  bylo 7FFF a jest po INC HL 8000
  cp end_S16
  ret nz ; adres < od 8000
    ; adres - zmiana sektora na nastepne 16 KB
  ld a, (A14_A18)  ; (A14_A18) - 0 do 1F , 32 sekt. po 16 KB
  inc a
  cp #20 ; 09 dla SST39_SF010 /128kB/, 10h-...020 /256kB/, 20h -..40 /512 kB/
  jr nz, spr12
 spr12a:
  xor A ; zaczynamy od sektora 0 /
 spr12:
  ld (A14_A18), a ; wybranie sektora na plytce FLASH by ZEGAR  
  cp #20
  jp z, END_SZUK
  ld Hl, 0   ; ld HL, FL ; od poczatku FLASH od 0 w CA od 4000h
  call SET_ADR
  ;xor A
  call sek32_1 ; OUT (PW), A
  ret

;===
Z3:      ; kl. E - zapisz program [CAod][.][CAdo][.][nr_progamu] do FLASH
         ; kl. 7 - zapisz obszar [CAod][.][CAdo][.][od_flash] CA80 -> FLASH
         ; PRZED ZAPISEM OBSZARU MUSIMY SKASOWAC SEKTOR/SEKTORY !!!!, robi to podprogram <spr_sektFF>
  ld ix, FL ; na plytce FLASH = od 4000h !
  ld IY, SEKT_P ; do zwiekszania sektora o 1 gdy przekroczymy adres  6FFF
  ld (IY), 0 ; zaczynamy od sektora 0
  call ini_lcd
  halt
  ld a, L3
  out (instr), A
  halt
  ld hl, zap_progr
  call wys_tekst
  halt
  ld a, L4
  out (instr), A
  halt
  ld hl, zap_obsz
  call wys_tekst
 Z41:
  call TI
  defb 20h
  cp 0Eh ; klawisz E
  jp z, progr ; zapis programu [od] [do] [nr]
  cp 7 ;
  jr nz, Z41
;===
obsz: ; zapisanie obszaru FLASH - SKASUJ SEKTOR, od ktorego chcesz zapisac obszar !
  ld a, L3 ; pozycja
  ld b, 20 ; ile skasowac
  call CLR_LCD_ZN
  ld hl, zap_39SF ; "ZAP.FLA.39"
  call print
  defb 80h
  call op_100ms
  defb 15 ; opozn. ok. 1,5 sek
  rst 10h ; D7 czysc wysw. CA
  defb 40h
  push IY ; = FEC4 (FEC4)=0
  call pob_adr_CA  ; pobranie adresow [CA_OD] i [CA_DO]
 zap1:             ; R_OD, R_DO i wylicz. DLUG
                ;   FEC5   FEC9           FEC7
  call zap_FL39_od   ; pobranie adresu
  jr nc, zap1 ; adres FL prawidlowy /dla 512 kB -max to 7.FFFF
  ;
 zap2:
  pop IY
  ld IX, (buf_adr+2)
  push ix
  pop hl
  ld (FL_DANE), HL ; przechowanie
  call sek16 ; oblicz nr sektora a' 16 KB na podstawie adr. HL
  call set_adr ; ustaw adres (HL)na podstawie   pobranego adresu zapisu do FLASH
  ld A, H
  ld IXH, A ; bo <ld (IX+0), C> powoduje zapis do FLASH
  call spr_sektFF ; sprawdz, czy sektor wolny /FF/
  jr z, zap3 ; sektor/y wolne, zapisuj 
     ; sektor zajety, podaj nowy adres
  
  jr obsz
 
   ; jesli zapisujemy od 0 (FLASH) - to odczyt od 4000 w CA
zap3:
  ld hl, (r_od) ; pocz. obszaru RAM do przepisania
  ld de, (r_do) ; koniec RAM do przepisania,  potrzebne do HILO
     ; ZAPIS !
 licz: ; zapis FLASH
  ld c, (hl) ; pobranie danej
  call SST_B_KEY ; odblokowanie FLASH
  ld (ix+0), c ; wpis do FLASH
  inc ix
      ; sprawdz czy koniec 16KB /4000 do 7FFF
  ld a, IXH
  cp end_S16 ; lub #C0 gdy mamy tylko 32 KB od 4000 do 7FFF
  call z, spr_end_sekt ; jesli koniec /7FFF na 8000/ zwieksz (A14_A18)
    ; jeszcze nie koniec , zapisuj dalej   
 licz2:
  rst 20h ; E7 wysw. HL
  defb 44h
  call hilo ;  HL+1, czy HL = DE ?
  jr nc, licz ; zapisuj dalej
 licz3:   ; koniec zapisu - dopisz jeszcze FD E4 (FF) jako koniec programu
  call spr_end_sekt ; czy IXH = 80jesli tak - przeskocz na nastepny 
 
 licz21:
  rst #10 ; czysc 4. cyfry na CA 
  defb #44
  ld HL, end_wr ; "end write" na CA
  call print
  defb 40h
  ld a, L3
  out (INSTR), A
  halt
  ld hl, end_wr1 ;"KONIEC ZAPISU" na LCD
  call wys_tekst
  rst 8 ; CF czekaj na wcisniecie klawisza
  jp EEP_1 ; pocz. programu

spr_end_sekt: ; jesli koniec 16  KB
  ld a, IXH
  cp end_S16
  ret nz
  ld IXH, #40 ; zapis od 4000 /CA
 ; 
 zw_sek16: ; nastepny sektor 16 KB  
  ld A, (A14_A18)
  inc A
  ld (A14_A18), A
  cp end_sekt ; ostatni sektor 16 KB to 1F !
  jp z, end_szuk 
  out (PW), A ; ustaw adres   nastepnych 16 KB 
  ret
  ;
 sek16: ; dwie najstarsze /np. 45/ cyfry adresu FLASH np. adr. 45678
  xor A
  ld A, (BUF_ADR+4);  ;(#FED1) - najstarsza cyfra /0-7
  and #0F
  rla
  rla
  rla
  rla
  ld B, A
  ld A, (BUF_ADR+3)  ;(#FED0) 0-FF
  and #F0
  ld (ADR48), A
  rra
  rra
  rra
  rra
  add A, B
  ld (nr_sekt), A ; do wysw. dwoch najstarszych bajtow adresu FLASH
  rra             ; 0-FFF
  rra
  and #1F ; ktory sektor 16 KB
  ld (A14_A18), A ; nr sektora 16 KB
 sek32_1:
  out (PW), A ; wyslij "1" na odpowiednie linie A18-A14
  ret         
        ;tak CA "widzi" Flash
  ;    FLASH       CA80
  ;   0-3FFF       4000-7FFF ; 7FFF - koniec pierwszych 16 KB
  ;  4000-7FFF     4000-7FFF ;  poczatek drugich 16 KB - <SEK16> = 1
  ;  8000-BFFF     4000-7FFF ; pocz. nastepnych <SEK16> = 2
  ;  C000-FFFF     4000-7FFF   <SEK16> = 3, itd
  ;====
set_adr: ; ustaw adres CA /tylko 4000-7FFF/ wg pobranego adresu 
         ; zapisu do FLASH, wczesniej USTAW <sek16>
  res 7, H
  set 6, H
  ret
  
   ;==========
progr: ; zapis programu [OD_CA] . [DO_CA] . [NR] = /nr programu
  rst 10h ; D7 czysc wysw. CA
  defb 10h ; jedna cyfra
  ld a, L4 ; pozycja
  ld b, 14 ; ile skasowac
  call CLR_LCD_ZN
  push IY ; = SEKT_P
    ; zapisz obszar w CA /wpisywania  numerow/ bajtami FF
  call CLR_OB ; wpisz FF do obszaru w CA
  call szuk_numer ; odczyt numerow programow i wpis do RAM CA80 od FE40
  call free_1_nr
     ; A - pierwszy wolny numer programu - sektora
  call wys_1_free
  call pob_adr_CA  ; pobranie adresow: pocz - koniec w CA
  pop IY
  jr Z42_1
  ;
 Z42: ; gdy error przy wpisywaniu nr sektora, max 7F
  rst 10h
  defb 50h
  ld hl, er_1
  call print
  defb 35h
  call op_100ms
  defb 6
 Z42_1:
  rst 10h ; D7 czysc dwa znaki na CA
  defb 20h
  ld hl, nr_prog ; na CA "nrProg."
  call print
  defb 62h
 Z43:
  ld a, L2
  out (instr), a
  halt
  ld hl,kon_pr2 ; "PODAJ NR PROGRAMU" _LCD
  call wys_tekst
  call param ; pobierz nr programu /do HL/
  defb 20h; PWYSW
  ld a, L ; nr programu
  cp 80h
  jr nc, Z42 ; max sektor to 7F
  call spr_NR ; sprawdz, czy numer wolny /od FE30 w CA
  jr nz, Z43b ; numer wolny
    ; numer zajety, wpisz inny
  push AF
  ld HL, NR_NF ; na CA "nr.no.Fr."
  call print
  defb 62h
  pop AF
  rst 18h ; DF wysw. A
  defb 20h
  rst 8 ; CF
  jr Z42

 Z43b: ; numer wolny - odpowiada nr sektora - numeracja dziesietna
  rst 18h ; wysw. A
  defb 20h
  push af
  call wysw_A1 ; wysw. nr programu, bez zera poczatkowego
  pop af
  ld (NR_PR), A ; zapamietanie
  ld IXL, A
   ; 
 Z431:
  call set_sekt_FL ; na podstawie numeru sektora
  ld H, B ; na pocz. sektora FD E4 FF
  ld A, C
  out (PW), A
  xor A
  ld L, A
  ld C, #FD
  call SST_B_KEY ; odblokowanie FLASH 
  ld (HL), C  ; wpis do FASHL
  inc HL
  ld C, #E4
  call SST_B_KEY ; odblokowanie FLASH
  ld (HL), C  ; wpis do FASHL
  inc HL
  ld C, IXL
  call SST_B_KEY ; odblokowanie FLASH  
  ld (HL), C  ; wpis do FASHL
 z431A:
  inc HL
  ld DE, (R_OD) ; pocz. programu w CA
  call SST_B_KEY
  ld (HL), E
  inc HL
  ; 
  call SST_B_KEY
  ld (HL), D               
  inc HL
  ld DE, (R_DO) ; koniec programu w CA
  call SST_B_KEY  ; potrzebne podczas szukania nazwy
  ld (HL), E    ; jesli brak nazwy w obszarze miedzy <R_OD> a <R_DO> 
  inc HL        ; to wysw. " ? ? ?"
   ;
  call SST_B_KEY
  ld (HL), D
  inc HL
   ; 
  push HL
  pop IX  ; pocz. zapisu programu w pam. FLASH
  ;call dane_sumy
  ld (P_PR_FL), HL ; pocz. programu w pam. FLASH - przechowanie w FED2
  jp zap3

pob_adr_CA:
  call pob_CAod  ; pobranie adresu
  ld (r_od), hl
  push HL ; do obl. dlugosci zapisu
  call pob_CAdo  ; pobranie adresu
  ld (r_do), hl   ; adres RAM do ..
  pop DE
  sbc hl, de
  inc HL
  ld (dl_zap), HL ; dlugosc bloku do zapisu
  ret
          ; do kasowania i zapisu 
op_100ms:; opozn. x 0,1s+ podac param. /cd xx yy zz/
   EX (sp), hl    ; zz - wielkosc opoznienia
   ld a, (hl)
   inc hl
   ex (sp), hl
   push hl
   push bc
   ld L,a
  op_licz:
   call op_2x50
   dec L
   jr nz, op_licz
   pop bc
   pop hl
   ret
    ; ponizej op. trwajace ok. 0,1 sek
op_2x50:  ld b, 50
 op_2ms2:    halt  ;trwa 2 ms
   djnz op_2ms2
   ret
;=============
pob_adr: ; pobranie adresu do bufora FEDF-FEE1, np. adr. 12345
         ; FEDF-45, ..E0-23, ..E1-01
  ld hl, buf_adr ; od FEDD
  call clr_buf ; zerowanie obszaru / w CA88 kalkulator
  call pob_kl_dat
  jr c, pob_adr ; blednie wpisano adres
 pob_adr1:
  call pob_kl_dat ;
  jr c, pob_adr
  jr z, pob_adr1
  cp 0Ah
  jr c, pob_adr1
 pob_kl_dat: ; pobranie
  call CI  ; cd C6FF
  call test_kl ; tylko cyfry 0-9
  ret c
  jr nz, pob_kl_dat1
  ld a, (hl)
  or a
  ret nz
  jr pob_kl_dat

 pob_kl_dat1:  ;
  or a
  ld c, a ; przechowanie pobranej liczby
  jr nz, pob_kl_dat2
  ld a, (hl)
  or a
  jr nz, pob_kl_dat2
  rst 10h ; czysc wysw. CA
  defb 80h
  ld c, 0
  call CO
  defb 50h ; ## ile miejsc wyswietlac ##
  jr pob_kl_dat

 pob_kl_dat2:
  ld a, (hl)
  cp 0Fh ; max il. cyfr pobranych, wyswietl tylko 5, patrz ##
  jr nc, pob_kl_dat     ; liczy sie tylko 5 ostatnich, na wypadek,
  ld a, c               ; gdybysmy sie pomylili przy wciskaniu klawiszy
  cp 10h ; jakie znaki - tylko 0-F !
  jr nc, pob_kl_dat
  ld a, (hl)
  or a
  jr nz, pob_kl_dat3
  rst 10h
  defb 80h
 pob_kl_dat3: ;
  call CO ; wysw. cyfry z rej. C na CA
  defb 50h ; ## ile miejsc wyswietlac, ##
  push hl
  call PLEW ; wpis pobranej cyfry (rej. C) do bufora /kalkul. CA80
  call C4 ; konwersja znakow z BUF_WYSW i wysw. na LCD
  pop hl
  jr pob_kl_dat

test_kl:
  cp 10h ; czy "G" - nowa adres
  scf
  cp 12h ; klawisz "="
  jr z, set_stos
  or a
  ret nz
  ld c, 0
  inc c
  ret
set_stos: ; wyrownanie stosu
  pop bc
  pop bc
  ret ;   jp zap11

PARAM_LCD:  ; pobieranie znakow /max 4 /HL/, adresow z jednoczesnym wysw. na lcd
  rst 28h   ; EF ustawienie parametrow wyswietlacza ca80 PWYS=FFF6
  ld a, (PWYS)
  push af
  and 0F0h ;kasuj mlodsze bity /od ktorej poz. na CA wysw
  rlca      ; zostaw ile miejsc wyswietlac
  rlca
  rlca
  rlca
  ld (ile_cyf), a ; (ile_cyfr) tyle cyfr wyswietlaj
  ld hl, CYF0; CYF0 !!!
  dec a
  ld e, a ; przechowanie
  pop af
  and 0Fh ; od ktorej pozycji na CA beda wyswietlane znaki
  add a, e
  add a, L
  ld L, a
  ld (poz_cyf), HL ; najstarsza cyfra do wyswietlania
           ; wyswietlane bedzie tylko (ile_cyf)

param1:  ; to ponizej pobiera tylko 4. znaki do HL, jesli wiecej-korzystaj z kalkulatora
  rst 8h  ; CF pobierz znak klawisza
  jr z, param1
  ld hl, 0 ; czysc hl
     par1:
  push af
  cp 10h ; czy cyfra szesnastkowa 0 - F
  jr nc, par2
  pop af
  add hl, hl
  add hl, hl
  add hl, hl
  add hl, hl ; przesun w lewo o 4 bity
  or L ; dopisz ostatnia pobrana cyfre
  ld L, A
  push hl ;ochrona zawartosci
  call C4 ; wysw. na LCD pobrany znak
  pop hl
    par3:
  rst 8h ; pobierz nastepny znak
  jr par1
    par2:
  pop af
  jr nz, par3
  push af
  call CLR1
  pop af
  ret
    ; po kazdym wpisie pobranej cyfry jest wyswietl. piec cyfr na LCD
C4: ; i konwersja cyfr z wysw. CA na kod LCD, nastepnie wysw. na LCD,
  ld a, (poz_wys) ; gdzie wyswietlac - pozycja
  out (instr), A
  ld hl, (poz_CYF) ; najbardziej znaczaca pozycja na CA80 /tu FB - CYFx/
  ld a, (ile_cyf) ; ile cyfr wyswietlac  - tu 5
  ld b, a ; ile cyfr
 c41:
  halt
  halt
  ld a, (hl)
  dec hl ; nastepna CYFRA
  call konw
  djnz c41
  ret

KONW:  ; konwersja znaku z CYFx /wysw. CA/ na kod LCD
  PUSH  HL
  PUSH  BC
  CP 0   ; jesli wyswietlacz "ciemny" - brak cyfry
  JR Z, C44 ;przeskocz, nie wyswietlaj na LCD
  LD    IY, TLCD ; tablica do konwersji znakow - moja wersja
  LD    HL, TSIED ; adres tablicy kodow 7. segm. w CA80 - od 0318h
  LD    B,10H ; dlugosc tablicy
 C42:
  CP    (HL)      ; czy to ten ?
  JR    Z, C43    ; znaleziono !
  INC   HL ; na nastepny kod rzeczyw.
  INC   IY ; na nastepny kod konwersji
  DJNZ  C42      ; szukaj dalej
C43:  ; znak znaleziony
  OR    A
  LD    A, (IY); kod na LCD
  halt
  OUT (DANA), A
C44:
  POP   BC
  POP   HL ;?
  RET
          ; odpowiedniki cyfr do wysw. na LCD /po znalezieniu cyfry z wysw. CA
TLCD:     DEFB  30h, 31h, 32h ,33h ; 0, 1, 2, 3      ; tablica TSIED - od 318h
          DEFB  34h, 35h, 36h, 37h ; 4, 5, 6, 7
          DEFB  38H, 39H, 41H, 42H ; 8, 9, A, B
          DEFB  43H, 44H, 45H, 46H ; C, D, E, F
;=====
Z4: ; szukanie programu i jego nazwy w pam. FLASH i wysw. na CA i LCD
szuk_progr: ; szukamy nr programu, po markerze FD E4/, zaczynamy od sektora 0
  call ini_LCD  
  xor A ;  zaczynamy od poczatku
  out (PW), A ; od pierwszych 16 KB
  ld (A14_A18), A
  ld (nr_sekt), A ; ten bajt to numer sektora w pam. FLASH !
  inc a
  ld (nr_L), a ; startujemy od 1. linii na LCD
  ld HL, FL
  rst #10
  defb #17
    ; poczatek szukania programow
 FL_SZ3: ; na poczatek HL = 4000h
  LD DE, mar_PR ;w DE marker pocz. programu /po FD E4 jest nr programu/
  call szuk_mar ; szukaj markera 
     ; znaleziono marker pocz. programu - FD E4
 FL_SZ31:
 wysw_adr: ; wysw. akt. adresu FLASH podczas szuk. programow
  rst #20 ; LADR        wysw. adres / na CA/ pocz. programu - nr sektora + HL- trzy cyfry
  defb #43
  ld A, (nr_sekt) ; 0-FFF
  rst #18 ; LBYTE
  defb #26 
  call obl_linie  ; w ktorej linii wyswietlic
  out (instr), a ; ustaw kursor na LCD
 ;FL_SZ2:
  ld a, (A14_A18) ; ??
  cp end_sekt ; ostatni sektor po 16 KB /1F->20/ ; w 7F sa dane odnosnie SUMY KONTROLNEJ !!
  jr z, END_SZUK
  inc HL
  ld a, (HL); nr program
  push AF
  rst 18h ; DF wysw. A /zmienia rej. C na CA/, nr programu
  defb 20h ;nop ; call wys_nr_pr
  pop AF ; nr programu
  call wysw_A ; nr programu na LCD
  ld A, (HL) ; nr programu
  cp #FF
  jr z, end_szuk
  call adr_szuk
     ; teraz znajdz nazwe programu, po FD E4
  ;ld DE, mar_NAZ ; DD E2 - po nim nazwa programu
  call szuk_mar_naz
  inc HL
  xor A
  cp E ; E = 0 gdy brak nazwy
  jr nz, nazwa_ok
    ; nie znaleziono nazwy
  ld A, " "
  out (DANA), A
  halt
  ld A, "?"
  out (DANA), A
  call wys2 ; nastepna linia na LCD
  jr nazwa1

 nazwa_ok:
  call wys_t2 ; wyswietl nazwe-max 17 znakow i sprawdz czy koniec sektora
 nazwa1:
   call obl_linie ; czy juz 4. linia, jesli 5. przeskok na 1. linie
      ; jesli wcisnieto klaw. 1-9 to szukaj programu 
  ac:    
  call next_sekt
  push HL
  ld A, (HL)
  cp #FF
  jr nz, ab1
  inc hl
  ld A, (HL)
  cp #FF
  dec HL
  jr nz, ab1
  pop HL
  jr ac
ab1:    
  pop HL
  jr FL_SZ3
    
 END_SZUK:
  ld hl, kon_PR ; na LCD "KONIEC PROGRAMOW"
  ld a, (nr_L)
  call obl_linie
  out (instr), A
  call wys_t2
  call op_100ms
  defb 15 ; ok. 1,5 sek
  rst 8 ; CF 
  call czysc_LCD   
  ld hl, pr_END
  ld a, L1 ; ustaw kursor 1. linia
  out (instr), A
  call wys_tekst
  rst 8 ; CF- czekaj na wcisn. klawisza
  cp 0Fh ; 0-F to pobierz nr programu i przepisz do RAM
  jp nc, szuk_progr ; FLASH_SZUK1 ; wyswietlaj nazwy od nowa, jesli F1, pocz. programu FLASH
   ; wcisnieto nr programu
 SZUK2:
  call czysc_LCD
  ld hl, kon_pr2 ; "podaj nr programu"
  call wys_tekst
  rst 10h ; D7 czysc wysw. CA
  defb 20h ; dwa pierwsze znaki
  ld hl, nr_prog ; "nrProg" na CA80
  call print
  defb 62h
  call param
  defb 20h ; nr programu/sektora w L - wysw. na CA
  ld C, L ; do porownania podczas szukania
  ld A, L ; do wyswietlenia na LCD
  call wysw_A1 ; na LCD nr programu, bez zera poczatkowego
  xor A ; A=0
  out (PW), A ; szukanie zaczynanmy od pierwszego sektora
  ld (A14_A18), A
  ld DE, mar_PR ; marker programu FD E4
  ld hl, FL ; zacznij od 4000h
 sz21:     ; szukaj numer programu - rej. C
  call szuk_mar
  inc HL
  ld a, (HL); odczytany nr programu
  cp C  ; zapamietany nr programu
  inc HL
  jr nz, sz21 ; numer nie znaleziony
     ; znaleziono nr programu
 sz22:   ; dwa nastepne bajty to pocz. programu w CA
  ld C, (HL) ; ld c, (hl) - 4E
  inc HL
  ld B, (HL)   ; ld B, (hl) - 46
  ld (r_od), BC ; pocz. programu w CA80
  inc HL
  ld A, (HL)
  inc HL
  push HL
  ld H, (HL)
  ld L, A ; koniec programu w CA
  sbc HL, BC ; dlugosc
  inc HL
  ld E, L
  ld D, H
        ; przepisanie pobranego programu do CA
  ld a, (A14_A18) ; zapamietany nr sektora podczas szukania
  out (PW), a  ; teraz CA80 ma dostep do FLASH gdzie pocz. programu
  ld bc, (R_OD) ; pocz. wpisu do RAM
  pop HL
  inc HL
  s24:
  LD A, (HL) ; odczyt z pam. FLASH
  ld (bc), A ; wpis do RAM
  inc BC
  inc HL  ; sprawdz koniec sektora
  ld a, H
  cp end_S16 ; czy 80h/8000
  jr nz, sz241 
  call zw_sek16 
  ld H, #40
 sz241:
  dec DE
  ld a, D
  or E
  jr nz, s24
  ld HL, (R_OD)
  jp (HL) ; skok do programu

  ;===========
szuk_mar: ; szukanie markera FD E4 /DD E2
 ; call wysw_kw
  ld a, (HL)
  cp D ; czy FD - program lub DD - nazwa
  push af
  inc IX ; tu bedzie dl. prog. podczas szukania numeru programu do przepisania da CA
  inc HL                               ; podczas nazwy - bezuzyteczne
  call adr_szuk
  ld a, H
  cp end_S16 ; przekroczono 7FFF na 8000
  jr nz, sz1
  call zw_sek16 ;sz3 ; przejdz na nastepny sektor
  ld H, #40
 sz1:
  pop af
  jr nz,szuk_mar
  ld a, (HL)
  cp E ; czy E4 -szuk. programu czy E2 - szuk. nazwy

  ret z  ; jr z, sz4 ;  jr nz, szuk_mar
  cp 0E2h ; jesli brak nazwy w programie, to po FD E4 tez bedzie FD E4
  jr nz, szuk_mar
    ; ????
 ; ld A, (NR_L) ; linia na LCD
 ; inc A
 ; ld (NR_L), A
 ; call obl_linie
 ; pop AF ; wyrownanie stosu
 ; jp FL_SZ31

 sz4:
  inc HL
  ld a, H
  cp end_S16
  call z, zw_sek16 ; SET nastepny sektor 16 KB
  ret
  ;===============
NUM_LINII:  ; tablica adresow poczatkow linii LCD
  defb 0, L1, L2, L3, L4  ; musi byc na jednej stronie

obl_linie:      ; wpis do rej. A pocz. linii do wyswietlana
  ld a,(nr_L)  ; aktualnie nr linii do wyswietlania
  push HL
  ld HL,NUM_LINII ; (HL) wskazuje na zero
  add A,L
  ld L,A
  ld A,(HL)     ; HL wskazuje nr linii
  out (INSTR), A
  pop HL
set_linie: ; jesli byla 4. linia, przejdz na 1.
  ld a,(nr_L) ;
  cp 5 ; czy byla wyswietl. 4. linia?
  ret nz
 spr_L1:
  ld a,1 ; ustaw wyswietlanie na 1. linie LCD
  ld (nr_L), a
  rst 8 ; CF czekaj na wcis. klawisza i wysw. nastepne
  push af ; zapamietaj klawisz
  call czysc_LCD
  pop af
  cp 10h ; czy > niz F np. G, . = , F1-F4
  ret nc  ; inny niz 0-F / jesli 0 do F do przepisuje sektor do RAM
   ; przepisz program/sektor
  pop af ; pseudo RET - bo bylo przedtem CALL !!
  jp SZUK2 ; podaj numer programu i szukaj, przepisz i uruchom go

wys_t2: ; wysw. na LCD max 17 znakow i przeskok na nastepna linie
  ld E, 18 ; max il. znakow do wysw
 wys_t21:
  ld a,(hl) ; pobierz litere
  cp 0FFh
  jr z,wys2
  halt
  out (DANA),a
     ; sprawdz, czy koniec sektora - podczas wyswietlania nazwy
  inc HL
  ld a, H
  cp end_S16
  jr nz, wyst1
  call z, zw_sek16
  ld H, #40 ; L = 00
 wyst1:
  dec E
  jr nz, wys_t21 ; wysw. nastepny znak
 wys2: ; wszystkie znaki wyswietlone
  push HL
  ld HL, nr_L
  inc (HL); nastepna linia LCD
  pop HL
  ret

  ;=================
Z5: ; przepisanie FLASH do RAM w CA80
   ld A, 1   ; czysc LCD
   out (instr), A
   ld a, L4
   call busy
   out (instr), A
   ld hl, odcz ; "ODCZYT"
   call wys_tekst
 Od6:
  call zap_FL39_od ; pobranie adresu "OD" FLASH
  jr nc, Od6
  ;jr Od6
   ; adres prawidlowy
 Od3: ; zapisz ten adres
  ld HL, (buf_adr+2)
  push HL ;4. bajty pocz. adr. FLASH , najstarszy 5.bajt zapisany w <zap15>
  ld (FL_DANE+1), HL ; zapis adresu pocz. FL
  ld A, (buf_adr+4) ; najstarsza cyfra adresu
  ld (FL_DANE+3), A
 Od3_1:
  ld a, L2+15
  ld b, 5
  call CLR_LCD_ZN
  call zap_EE29_do; pobranie adresu "DO" FLASH
  jr nc, Od3_1 
     ; adres OK, < 7.FFFF /dla 512 kB/ 3.FFFF-256 kB, 1.FFFF - 128 kB/   
 Od3_2:
  pop de ; 4. bajty pocz. adr. FLASH /liczac od najmloszej pozycji/
  ld hl, (buf_adr+2)   ; adres FLASH do ..
  or A ;
  sbc hl, de
  inc hl
  ld (dl_zap), HL
  push HL
  ld a, L3
  out (instr), A
  ld hl, dlug1 ; wysw. ilosc bajtow
  call wys_tekst
  pop HL
  call wys_adr_lcd ; wysw. ilosc bajtow
  ld bc, max_zap ; max wolne bajty od 8000-FCFF, /w moim CA80 - SK/
  sbc hl, bc
  jr c, Od4 ; jest OK, zmiesci sie w CA
  ;  zbyt dlugi, moze zniszczyc stos i inne dane
  ld a, L2
  out (instr), a
  ld hl, dlug ; "zapis przekroczy FD00"
  call wys_tekst
Od31:
  call CI
  cp 12h ; = OK
  jr nz, Od3_1
 Od4: ; pobierz adres zapisu do RAM
  rst 10h ; D7
  defb 40h
  call pob_CAod ; RAM "od"
  ld a, h
  cp 80h ; adres wpisu do CA musi byc >= 8000h !! /4000-7FFF FLASH/
  jr nc, Od5 ; jest OK
    ; adres bledny
  ld a, L3
  out (instr), A
  ld hl, pop_adr ; "popraw adres > 8000"
  call wys_tekst
  call op_100ms
  defb 15 ; opozn. ok. 1,5 sek
  rst 10h
  defb 40h
  ld b, 17
  ld a, L3
  call CLR_LCD_ZN
  jr Od4
Od5: ;przepisz obszar z FLASH do CA /adr. pocz.  >=8000h
    ; HL-pocz. zapisu w CA, pocz. w FLASH ( BUF_ADR+4)
  push hl       
  ld HL, (FL_DANE+1)
  push HL
  pop IX         ; IX  pocz. odczyt FLash
  ld A, H
  res 7, A
  set 6, A
  ld IXH, A ; (IX) odczyt z FLash
  ld HL, (FL_DANE+2)
  ld (BUF_ADR+3), HL
  call sek16   
  pop HL ; adres pocz, zapisu do CA
  ld de, (DL_ZAP)
 Od51:
  ld c, (IX) ; adres w FLASH; max to 6FFF, przeskok na 7000 to zmiana seltora
  ld (HL), c ; wpis do CA
  inc ix
  ld a, IXH
  cp end_S16 ; lub CP 70h - jeden takt mniej
  jr nz, Od52; bo IXL = 00
  ld IXH, #40 
  call sek16
Od52:  ; sprawdz, czy koniec zapisu /DL_ZAP/
  inc hl
  dec de
  XOR A
  CP E
  jr NZ, Od51 ; zapisuj dalej
  CP D
  jr nz, Od51
  dec HL
  push HL
  rst 20h ; E7 -wysw. rej. HL
  defb 41h
  ld hl, end_wr
  call print
  defb 35h
  ld a, L1+12
  out (instr), A
  ld hl, RAM_do ; "do"
  call wys_tekst
  pop HL
  call wys_adr_LCD
  rst 8 ; CF czekaj na wcis. klaw
  jp zap_FL ; koniec obszaru zapisu RAM, wroc na pocz. programu
;==

;==
CLR_LCD_ZN:
 ; kasuje znaki na lcd: ilosc w rej. B, rej. A - od pozycji
  push af
  call busy
  out (instr), A ; ustawia kursor
  push hl
  ld a, 20h ; kod spacj1
  kas:
  call busy
  out (DANA), A
  djnz kas
  pop hl
  pop af
  call busy
  out (instr), A ; powrot kursora na pocz. kasowanych znakow
  ret
;===============
; obsluga LCD
ini_lcd:
  ld a, 30h ;
  out (instr),a
  halt
  halt
  halt
  ld a, 30h
  out (instr),a
  call op_100us
  call op_100us
  ld a, 30h
  out (instr),a
  call op_100us
  ld a, 38h ; sterowanie 8-bit
  out (instr),a
  call busy
  ld a, 1 ; czysc LCD
  out (instr),a
  halt
  halt
  call op_100us
  ld a, 0Eh ; kursor na dole i wlacz LCD
  out (instr),a
  call op_100us
  ld a, 6
  out (instr),a
  halt
  ret    ; powrot z podprogramu ini_lcd

op_100uS:
  ld a, 50h
  op2:
  dec a
  jr nz, op2
  ret

busy: ; czy LCD gotowe na dalsze instrukcje
   push af
  busy1:
   ld A, #A0 ; in a,(LCD_BUSY)
   call op2   ; and 80h
   nop ;  jr nz, busy1
   pop af
   ret

WYS_tekst: ; wysw. tekst wg (hl), koniec tekstu FF
 ld a, (hl)
 cp 0FFH
 ret z
 call busy
 out (DANA), A
 inc hl
 jr WYS_tekst

CZYSC_LCD: ; czysci lcd i ustawia kursor na pozycji poczatkowej LCD
  LD        A,1
  OUT       (instr),A
  HALT                     ; opoznienie
  HALT
 U_K_HOME:                                      ; ustaw kursor na poczatek LCD
  LD        A,L1           ; 1. linia/
  OUT       (instr),A
  HALT                     ; opoznienie
  HALT
  RET

WYS_ADR_LCD: ; wyswietla 4. znaki z rej. HL, wg aktualnej pozycji kursora
  PUSH BC
  LD A, H
  CALL wysw_A ; rozdziela rej. A na dwa bajty i wyswietla na lcd
  LD A, L
  CALL wysw_A ; HL na kody liter/cyfr na lcd
  POP BC
  RET

ROZDZIEL: ; dzieli rej. A na dwie liczby/znaki i umieszcza w HL
  PUSH AF
  AND 0F0H; usun mlodsze bity
  RRCA ; na prawo
  RRCA
  RRCA
  RRCA
  CALL ZAMIEN; zamienia litery na cyfry, cyfry bez zmian
  LD L, A
  POP AF
  AND 0FH ; usun starsze bity
  CALL ZAMIEN
  LD H, A
  RET

ZAMIEN: ; zamiana cyfr hex na ASCII, wg ZEGAR
     ; do wyswietlania na LCD
  CP 0AH    ; litera czy cyfra - cyfry <= 9, litery > 9
  SBC A,69H
  DAA
  RET

wysw_A: ; wyswietla zaw. rej A na lcd, wg aktualn. stanu lcd
  push hl
  call rozdziel
  ld a, L
  call busy
  out (DANA), A
  ld a, H
  call busy
  out (DANA), A
  pop hl
  ret

wysw_A1:; wyswietlenie rej. A na LCD bez zera poczatkowego, np. godzina 7:55:25
  push hl
  call rozdziel
  ld a, L ;
  cp 30h
  jr z, WA1
  call busy
  out (DANA), A
 WA1:
  ld a, H
  call busy
  out (DANA), A
 wys1:
  pop hl
  ret

wpis_PLD: ; wpis duzych liter PL
   ld hl, ZNAKI_PLD
   jr wp_1
;wpis_PLM: ; wpis malych liter PL do LCD
 ;  ld hl, znaki_plm
  wp_1:
   ld a, 40h
   out (instr), A
;wpis_CGRAM: ; wpis znakow do LCD
   ld b, 64 ; 40h
 wp_2:
   ld a, (hl)
   call busy
   out (DANA), A
   inc hl
   djnz wp_2
   halt
   ret
;ZNAKI_PLM: ; male litery  /diakrytyczne/
;       defb 0,0,0Eh,1,0Fh,11h,0Fh,2   ; -> 0 /a z "ogonkiem"
;       defb 2,4,0Eh,10h,10h,11h,0Eh,0 ; c -> 1
;       defb 0,0Eh,11h,1Fh,10h,0Eh,2,0 ; e
;       defb 0Ch,4,6,4,0Ch,4,0Eh,0     ; l
;       defb 2,4,16h,19h,11h,11h,11h,0 ; n
;       defb 2,4,0Eh,11h,11h,11h,0Eh,0 ; o
;       defb 2,4,0Eh,10h,0Eh,1,1Eh,0   ; s
;       defb 0,4,1Fh,2,4,8,1Fh,0       ; z -> 7
ZNAKI_PLD:  ; duze litery
       defb 0Eh,11h,11h,1Fh,11h,11h,2,0  ; -> 0  /A z "ogonkiem"
       defb 4,0Eh,11h,10h,10h,11h,0Eh,0  ; C -> 1
       defb 1Fh,10h,10h,1Ch,10h,10h,1Fh,2 ;E
       defb 10h,10h,14h,18h,10h,10h,1Fh,0; L
       defb 4,15h,19h,15h,13h,11h,11h,0  ; N
       defb 4,0Eh,11h,11h,11h,11h,0Eh,0  ; O
       defb 4,0Fh,10h,1Fh,1,11h,1Fh,0    ; S
       defb 4,1Fh,11H,2,0Ch,11H,1Fh,0    ; Z -> 7

pob_CAod:
  ld hl, CA_od ; RAM od....
  call print
  defb 44h
  ld a, L1
  out (instr), a
  halt
  ld hl, ram_od
  call wys_tekst
  halt
  ld a, L1+7 ; tu pocz. wysw. pobieranego adresu "od"
 pob1:
  ld (poz_wys), a
  call param_LCD ; pobiera adres, max 4. cyfry /HL/
  defb 40h ; PWYSW
  ret

pob_CAdo:
  ld hl, CA_do ; RAM do ....
  call print
  defb 44h
  ld a, L1+12; tu pocz. wysw. pobieranego adresu "do"
  out (instr), A
  halt
  ld hl, ram_do
  call wys_tekst
  ld a, L1+15
  jr pob1

zap_FL39_od:
  ld hl, FLod ; zapis do SST 39SF od sektora....
  call print
  defb 44h
  ld a, L2
  out (instr), A
  halt
  ld hl, FL_od
  call wys_tekst
  ld a, L2+6
  ld (poz_wys), a
  ld a, 5 ; bedzie teraz 5. liczb
  ld (ile_cyf), a
  ld HL, CYF4 ; /FFFB/
  ld (poz_cyf), HL
  jr zap22

zap_EE29_do:   ; np. adres 65432 : FEDF-32, FEE0-54, FEE1-06
  ld hl, FLdo ; FLdo ....  np. 7654  FEDF-54 FEE0-76
  call print
  defb 44h
  rst 10h
  defb 40h
  ld a, L2+12; tu pocz. wysw. pobieranego adresu "do"
  out (instr), A
  halt
  ld hl, ram_do ; "do"
  call wys_tekst
  ld a, L2+15
  ld (poz_wys), a
 zap22:
  halt
  call pob_adr ; pobiera adres
  ld a, (buf_adr) ; jesli wcisnieto tylko 0
  cp 0
  jr nz, zap23 ; wcisnieto inna niz 0
  ld a, L2+6
  out (instr), A ; ustaw kursor
  halt
  ld a, 30h ; "0"
  out (DANA), A
zap23:
  ld a, (buf_adr+4)
  and 0Fh
  cp 8 ;2 - dla SST39010/max 1.FFFF/, 4-SST29020 /max 3.FFFF, 8-SST29040 max 7.FFFF
  ret c   ; zap2
     ; adres >1FFFF - /SST29010/lub >3FFF lub > 7FFFF  = ERROR
  ld hl, KO3 ; "ERROR"
  call print
  defb 50h
  call op_100ms
  defb 10 ; opozn. ok. 1 sek
  rst 10h ; D7 czysc wysw. CA
  defb 50h
  XOR A ; CY=0  ret
  ret

END_PROGR: ; koniec obszaru z programami
  ld a, L3
  out (instr), a
  ld hl,kon_pr
  call wys_tekst
  ld hl, end_wr
  call print
  defb 30h
  rst 8 ; CF czekaj na klawisz
  jp Z5
   
 adr_szuk: ; ma sens, gdy dlugosc programu > niz FFF / 4 KB
  ;INC   HL
  ld A, L
  cp 0
  ret nz
  ld A, H
  and #0F
  cp 0
  ret nz
 adr1:
  ld A, (nr_sekt); 0-FFF
  inc A
  ld (nr_sekt), A
  ret  

next_sekt: ; po znalezieniu nazwy porgramu, przeskocz na nastepny
  xor A                      ; sektor FL - poczatek nastepnych 4 KB 
  ld L, A
  ld A, H
  and #F0
  ld B, #10
  add A, B
  ld H, A
  bit 7, A
  jr z, adr1 ; adres <80xx
    ; przeskok na 8000
  call adr1
  ld H, #40 ; od poczatku
  call zw_sek16
  ret

SST_B_KEY:                 ; odblokowanie flash (SST39SF040) wg ZEGAR
        push AF
        EXX
        ld A, 0 ; PB = 0
        out (PW), A 
           ; zapis do Flash Tbp MAX 20 us
        ld b, 9          ; wait 170 * 0.125us (8 MHz > 20 us)
 op4:                    ; czekamy na koniec zapisu poprzedniego bajtu
        djnz  op4        ; 9*13 taktow = 117
        ld A, #55 ;      ; 7 taktow
        ld DE, adrA      ; adres  10
        ld HL, adr5      ; adres 10 taktow
          ld A, 1        ; dla HL = 5555
          out (PW), A    ; dla adr.  5555 - "drugie" 16 KB
        ld (HL), E       ; 1. cykl zapisu -  7 taktow
          xor A
          out (PW), A
        ld A, #55
        ld (DE), A       ; 2. cykl zap. dana 55 pod 2AAA   7 taktow
        ld A, 1 ; dla HL = 5555
          out (PW), A ; dla adr.  5555 - "drugie" 16 KB  
        ld (HL),0A0H  ; 3.  cykl zapisu - 10 taktow - klucz
           ; odtworz stan portu - aktualny adres sektora 16 KB
        ld A, (A14_A18)
        out (PW), A             ; 10
        EXX
        pop AF
        ret    ; 10 taktow ; razem ok. 255 taktow - 63,75 us
 ; ===========
wysw_kom_1:  ; wyswietl komunikaty po uruchomieniu programu
   ld a, L1
   call busy
   out (instr), A
   ld hl, CA_EE2 ; "ZAP-ODCZ PROG FLASH"
   call wys_tekst; i przeskocz na nastepna linie LCD
   ret

spr_sektFF: ; czy wolne miejsce / FF / na zapis
   call sek16 ; ustaw sektor ' 16 KB na podstawie HL
   call set_adr
   ld C, #FF
             ; HL i IX pocz. zapisu FLASH
   ld DE, (dl_zap) 
 s_FF:  
   ld a, (HL)
   cp C
   ret nz ; obszar zajety , bajt  rozny od FF
   inc HL
   call adr_szuk
   bit 7, H
   jr z, s_1
     ; ustaw na nastepny sektor 16 KB
   ld A, (A14_A18)
   inc A
   ld (A14_A18), A
   out (PW), A
   ld H, #40
s_1:
   dec DE
   ld A, D
   or E
   jr nz, s_FF
   ret

 ;=========
szuk_wol: ; pokaz adres gdzie zaczynaja sie FF FF FF ...
  ld A, L4
  out (INSTR), A
  ld HL, _wol
  call wys_tekst
  halt
  ld A, L4+15
  out (INSTR), A
  pop HL
  call wys_adr_LCD ; wysw. rej. HL
  ld A, L4+14
  halt
  out (INSTR), A
  ld A, (IY)
  call wysw_A ; sektor 0 - 7F
  rst 20h
  defb 40h
  rst 8 ; CF
  ret
;===
spr_nr: ;rej. A - nr programu - czy podany numer programu juz wykorzystany
   cp 0FEh  ; nr zabroniony, po FD E4 FE oznacza koniec programów w EEPROM
   ret z
   cp 0FFh  ; nr zabroniony , po FD E4 FF oznacza "pusty obszar" - wypelniony FF
   ret z
   ld bc, 64h ; max il. programów  99     ; jesli nie to przepisz program do EEPROM
   ld HL, pr_ca ; pocz. obszaru szukania numer programu w RAM
   CPIR ; szukaj
   ret ;Z=0 -> numer juz wykorzystany, Z = 1 -> nie znaleziono wsrod wpisanych -OK, jest wolny, przepisz program do EEPROM

   ; teksty na CA80
CA_od:    defb 39h, 77h, 5Ch, 0DEh, 255 ; napis "CAod."
CA_do:    defb 39h, 77h, 5eh, 0DCh, 255 ; "CAdo."
FLod:     defb 71h, 38h, 5ch, 5eh, 255 ; "FLod" - 0FFh koniec tekstu
FLdo:     defb 71h, 38h, 5eh, 5ch, 255;
nr_sect:  defb 54h, 0D0h, 6dh, 79h, 58h, 31h, 255 ; "nr.sect" - 0FFh koniec tekstu
er_1:     defb 79H, 50H, 50H, 255; "ERR"
er_ok:    defb 79H,50H,77H,6DH,79H,0 ; "ERASE"
;EE_OK:    defb 5Ch, 78H, 255 ; "OK:
zap_39SF: defb 5bh,77h,0F3h, 71h,38h,0F7h,4Fh, 6Fh,  255; "ZAP.FLA.39" na CA
end_wr:   defb 0,79h, 54h, 0DEh,255 ; tekst "End" dla ca80
sekt_z:   defb 6Dh, 79h, 0D8h, 54h, 0DCh,71h, 50h, 0F9h, 255; "sec.no.Fre"
;flash2:   defb 71h, 38h, 77h, 6dh, 74h, 8, 5Bh, 255 ; "FLASH_2"
flash2:   defb #71, #38, #77, 8, #5B, 255
nr_prog:  defb 54h, 50h, 73h,50h,5ch, 0bdh, 255 ; "nrProg. " na CA
;err_fl:   defb 79H,50h,0D0H,71h,38h,77h,6dh,74h, 255  ; "Err.Flash" na CA80
;SEKT_ERR: defb 6dh, 79h, 0D8h, 79h, 50h, 50h, 5Ch, 50h, 255
;suma:     defb 6Dh, 9Ch,255 ; "Su." 6Dh, 1Ch, 54h, 0F7h,255 ; "Suma"
;su_NOK:   defb 6Dh, 1Ch, 54h, 0F7h, 54h,0DCh, 5Ch, 78h, 255 ; "suma. no. oK"
;zap_NOK:  defb 5Bh, 77h, 73h, 0, 54h, 0DCh, 5Ch, 78h, 255 ; "ZAP. NO.OK
;zap_OK:   defb 5Bh, 77h, 73h, 6, 6Dh, 0, 5Ch, 78h, 255 ; "ZAPIS OK"
;su_NOK:   defb 54h, 0DCh, 255 ; "no."
nr_fr:    defb 54h, 50h, 71h, 50h, 79h, 0F9h, 255 ; "nrFree" na CA
nr_nf:    defb 54h, 5Ch, 71h, 50h, 79h, 0F9h, 255 ; "noFree" na CA
;wr_FD:    defb #1C, #50, 4, #B1, #71, #5E, #D3,255; "write FD"
haslo:    defb #74, #77, #6D, #B8,#5C,255 ; "haSLo" na CA to "CA80", mozna zmienic 
    ; tekst na LCD
erase_FL: defm "  KASOWA",1,"  FLASH ?   ", 255
klaw_C:   defm "KLAW. C  CA",3,"A PAMI",2,1,255; WSZYSTKO", 255
klaw_C1:  defm "JESTE",6, " PEWIEN ? E OK",255
klaw_2:   defm "KLAW. 2 SEKT nr 0-7F", 255
RAM_od:   defm "RAMod:        ", 255 ; 5x spacja, gdy bledny adres, skasowanie cyfr na LCD
RAM_do:   defm "do:", 255
FL_od:   defm "FL_od:     ", 255 ; 5x spacj, jesli bedzie blad pobierania
dlug:     defm "zapis przekr. FDFF", 255
dlug1:    defm "IL. BAJT", 5, "W ", 255 ; ilosc bajtow
pop_adr:  defm "popraw ADR > 8000",255
;CA_EE2:   defm "ZAP-ODCZ PROG  FLASH" ;,255 ;
CA_EE2:   defm "0-KASUJ  1-WOLNY NR " ; w L1
KL_3:     defm "4-SZUK PROGR 5-ODCZY";,255; w L3
kl_1:     defm "2-PRZEGL  3-ZAPIS   ",255 ; w L2
;kl_0:     defm "5-ODCZ  7-POZYCJA PR",255       ; w L4
odcz:     defm " ODCZYT BAJT",5, "W", 255
sekt_wyb: defm "PODAJ NR SEKTORA",255
;kasOD:    defm "kasOD:", 255
potw:     defm "POTWIERD",7," KL. = !!!",255
zap_progr:defm "ZAPIS PROG [nr] kl E", 255
zap_obsz: defm "ZAPIS OBSZARU  kl 7", 255
kon_pr2:  defm "PODAJ NR PROGRAMU " ,255
kon_pr:   defm "KONIEC PROGRAM",5,"W" ,255 ;..M" defb 5 "W"
przeg:    defm "PRZEG. FLASH SST39xx", 255
end_wr1:  defm "KONIEC ZAPISU FLASH ",255
sekt_noF: defm "SEKTOR ZAJ",2 ,"TY !", 255
usun_sekt:defm "KASUJ SEKTOR ?", 255
sekt_kas: defm "DO KASOW OD ", 255
pr_END:   defm "END-nrPROG lub .lub=", 255 ; na LCD
kon_sek:  defm " KONIEC SEKTOROW", 255
_IL:      defm " IL",255
_wol:     defm "WOLNY OBSZ od ", 255
;find:     defm "  SZUKAM KONCA" ,255
;find2:    defm " PROGRAMOW W EEPROM" ,255
nr_1WOL:  defm "PIERWSZY WOLNY NR " ,255
;nr_nf1:   defm " NUMER ZAJETY" ,255
;ile_pro:  defm "ZNALEZIONO " ,255
;szu_dl:   defm "SZUK DLUG PROGRAMU", 255
;dl_pr:    defm "dlug ", 255
;FLA:      defm "FL od-do",255
;CA_DL:    defm "PROGRAM CA ",255    ;
;wp_su_ko: defm "KL F4/W - WPISZ SUME",255
;suma_od:  defm "SUMA 0-", 255
;zapisana: defm "ZAPISANA ",255

;======
szuk_mar_naz: ; szukanie markera DD E2
 ; call wysw_kw
  push HL
  inc HL
  ld E, (HL)
  inc HL
  ld D, (HL) ; w DE pocz. programu w CA
  inc HL
  ld A, (HL)
  inc HL
  ld H, (HL)
  ld L, A
  inc HL
  sbc HL, DE
  ld D, H  ; w DE dlugosc programu
  ld E, L
  pop HL
   ;
 sz_n1:
  ld a, (HL)
  cp #DD ; czy DD - nazwa programu  
  push AF
  dec DE
  ld A, E
  or D
  jr nz, sz_n11 ; koniec programu, brak nazwy
  pop AF
  ret 
  ;
 sz_n11:
  inc HL                              
  call adr_szuk
  ld a, H
  cp end_S16 ; przekroczono 7FFF na 8000
  jr nz, sz_n2
  call zw_sek16 ;sz3 ; przejdz na nastepny sektor
  ld H, #40
 sz_n2:
  pop af
  jr nz,sz_n1
  ld a, (HL)
  cp #E2 ;  E2 - szuk. nazwy
  ret z  ; nazwa znaleziona !
  jr sz_n1

; br_naz: 
; defm " ? ? ?", 255  

 defb #DD, #E2 ; marker nazwy programu
 zap_SST:  defm " SST39SF w U9-sekt",255    

