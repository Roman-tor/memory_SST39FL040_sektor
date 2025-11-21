Program „programator_sekt_SST39” to zmodyfikowana wersja programatora pamięci FLASH SST39SF 040 – 512 KB, wg Kol. #Zegar, opisanego na <microgeek.eu> <CA80-system plików>
https://microgeek.eu/viewtopic.php?f=82&t=2435

 W mojej wersji, płytka PCB jest znacznie mniejsza (ok. 50x90 mm), brak dodatkowych układów scalonych (oczywiście oprócz samej pamięci), podłączana jest podobnie jak ta powyżej ale sterowanie jest inne: adresy A0-A13 z linii adresowej CA80 a A14-A18 z portu PB0-PB4 układu 8255 (port użytkownika), linia danych, sygnały CE, WR. RD „pobierane” są z podstawki U10 (tam gdzie RAM od 4000h). Dzięki temu zabiegowi, nie potrzebujemy dodatkowych chipów do wybierania adresów w całym zakresie 512 KB. Mam wyprowadzony kabel płaski, taki jak od dawnych dysków HDD, 34-pinowy, dolutowany do płytki PCB MIK290 /U10/. Dodatkowo, wyjście CE_ U10 /pin 10 U4-74138/ jest rozdzielone - przecięta ścieżka i dołożona zworka 3-piny/. Sygnał idzie na zewnątrz - do FLASH albo do U10. Dzięki temu, nie musimy wyciągać pamięci RAM jeśli tam jest włożona.
Każdy program jest zapisywany w sektorze /sektor liczy 4 KB, 0-FFF/, jeśli jest dłuższy to w większej ilości sektorów, np. MONITOR CA80, wersja 8 KB zajmuje dwa sektory.
 
Format zapisywanych plików: 
 FDE4 – początek programu
 00       - numer programu
 00C0 - dwa następne bajty to początek programu w CA80 – np. C000,
 FFC0 - następne dwa to koniec programu w CA80 - C0FF
 3166FF itd.;  to nasz program;  programie powinniśmy umieścić nazwę poprzedzoną znacznikiem   
             DDE2, np. DDE2 „MOJ PROGRAM”, szczegóły w pliku *.ASM 

Można w ten sposób zapisać 128 programów! Oczywiście, jeśli programy są krótsze niż FFFh, mamy przestrzeń niezapisaną ale do tego sposobu zapisu jest inny program, będzie też zamieszczony w moim repozytorium. W tym przypadku, programy są zapisywane „jeden za drugim”.

MENU programu pojawia się na wyświetlaczu LCD 4x20, mamy do wyboru 5. pozycji:
 						
						 FOTO

0 – kasowanie całej pamięci lub sektora 4 KB
1 – pierwszy wolny numer programu
2 – przegląd pamięci, podobnie jak zlec. *D w CA80 jednakże  bez możliwości zapisu
3 – zapis do FLASH: albo programu [CA-od] [.] [CA_do] [nr_programu] [=]
      lub zapis obszaru  z CA do FLASH  [CA-od] [.] [CA_do]  [=]
4 – szukanie programu-wyświetla się nr programu i jego nazwa, jeśli była wpisana;
5 – przepisanie obszaru z FLASH do CA  

ZLEC. *0 – mamy możliwość skasowanie jednego, wybranego sektor /sektor to 4 KB/ lub całej  
             pamięci FLASH – dla zabezpieczenia przed nieautoryzowanym skasowaniem, musimy 
             podać hasło, które przyjąłem jako „CA80” ale można je ustawić dowolnie /4 znaki z 
             klawiatury/ w pliku ASM przed kompilacją.  

ZLEC. *1 – przed zapisaniem naszego programu w pamięci FLASH, możemy sprawdzić , który nr programu jest wolny; numer programu odpowiada tym samym numerowi sektora po 4 KB.

ZLEC. *2 – wpisujemy adres początkowy od którego chcemy przeglądać zawartość pamięci

ZLEC. -3 – możemy zapisać do pamięci program z CA80 lub jakiś określony obszar pamięci  z  
                  CA80; po wciśnięciu klaw. 3, pojawi się podmenu z możliwością wyboru: program lub 
                obszar i postępujemy zgodnie z komunikatami na wyświetlaczu CA. Przy zapisie 
                programu, w prawym dolnym rogu LCD pojawi się wolny numer programu, możemy go 
                wybrać lub wpisać inny.

ZLEC. *4 – program wyszukuje nr programu, wyświetla go na CA i LCD i szuka nazwy i jeśli była 
                 wpisana to się wyświetli na LCD, jeśli nazwy brak to pojawią się znaki zapytania za 
                 numerem programu. Ponieważ LCD ma 4. linie, po wyświetleniu czterech programów 
                 możemy wcisnąć „=”, wtedy szuka i wyświetla następne programy lub możemy wcisnąć 
                 numer programu. 
                 Gdy wyświetli  wszystkie znalezione programy, pojawi się napis „koniec programów”. 
                 Możemy wówczas wpisać numer programu (możemy też wpisać nr programu po 
                 wyświetleniu 4. programów), i nacisnąć „=” . Program zostanie znaleziony, przepisany do 
                 CA80 i uruchomiony.

ZLEC *5 – przepisanie obszaru pamięci z FLASH do CA80. Przyjąłem obszar do zapisu w CA tylko   
                 w zakresie 8000 – DFFF, 24 KB. Od E000 jest ten pogam do FLASH i 
                 aby bajty nie uległy nadpisaniu, ograniczyłem ten obszar do DFFF. Można to zmienić w  
                 deklaracji „max_zap”  pliku ASM.






