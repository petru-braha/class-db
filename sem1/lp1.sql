/* Scrieți o interogare pentru a afișa numele, prenumele, anul de studiu si data nașterii pentru toți studenții. Editați în SQL*Plus și executați. Salvați apoi interogarea intr-un fișier numit p1.sql.
Scrieți și executați o interogare pentru a afișa în mod unic valorile burselor.
Încărcați fișierul p1.sql în buffer. Dați fiecărei coloane din clauza SELECT un alias. Executați înterogarea.
Afișați numele concatenat cu prenumele urmat de virgulă și anul de studiu. Ordonați crescător după anul de studiu. Denumiți coloana “Studenți pe ani de studiu”.
Afișați numele, prenumele și data de naștere a studenților născuți între 1 ianuarie 1995 si 10 iunie 1997. Ordonați descendent după anul de studiu.
Afișați numele și prenumele precum și anii de studiu pentru toți studenții născuți în 1995.
Afișați studenții (toate informațiile pentru aceștia) care nu iau bursă.
Afișați studenții (nume și prenume) care iau bursă și sunt în anii 2 și 3 de studiu. Ordonați alfabetic ascendent după nume și descendent după prenume.
Afișați studenții care iau bursă, precum și valoarea bursei dacă aceasta ar fi mărită cu 15%.
Afișați studenții al căror nume începe cu litera P și sunt în anul 1 de studiu.
Afișați toate informațiile despre studenții care au două apariții ale literei “a” în prenume.
Afișați toate informațiile despre studenții al căror prenume este “Alexandru”, “Ioana” sau “Marius”.
Afișați studenții bursieri din semianul A.
Afișați toate informatiile despre studentii ale caror prenume contine EXACT o singura data litera 'a' (se ignora litera 'A' de la inceputul unor prenume).
Afişaţi numele şi prenumele profesorilor a căror prenume se termină cu litera "n" (întrebare capcană).. */

-- 1
SPOOL p1.sql CREATE
SELECT nume, prenume, an, data_nastere FROM studenti;
SPOOL OUT;

-- 2
SELECT DISTINCT bursa FROM studenti; 

-- 3
GET p1
SELECT nume as nume1, prenume AS prenume1, an AS an1 FROM studenti;

-- 4
SELECT nume || prenume || ', ' || an "Studenti pe ani de studiu" FROM studenti ORDER BY an ASC;

-- 5
SELECT nume, prenume, data_nastere FROM studenti 
    WHERE data_nastere > TO_DATE('1-jan-95') AND data_nastere < TO_DATE('10-jun-97') 
    ORDER BY an DESC;

-- 6
SELECT nume, prenume, data_nastere FROM studenti WHERE data_nastere LIKE '%95';
SELECT nume, prenume, data_nastere FROM studenti WHERE data_nastere BETWEEN TO_DATE('1-jan-1995') AND ('31-dec-1995');

-- 7
SELECT * FROM studenti WHERE bursa IS NULL;

-- 8
SELECT nume, prenume FROM studenti WHERE bursa IS NOT NULL AND an IN (2 , 3) ORDER BY nume ASC, prenume DESC;

-- 9
SELECT nume, bursa, bursa + bursa * 3 / 20 "crestere potentiala" FROM studenti WHERE bursa IS NOT NULL;

-- 10
SELECT nume FROM studenti WHERE nume LIKE 'P%' AND an = 1;

-- 11
SELECT * FROM studenti WHERE prenume LIKE '%a%a%'
MINUS
SELECT * FROM studenti WHERE prenume LIKE '%a%a%a%';

-- 12
SELECT * FROM studenti WHERE prenume IN ('Alexandru', 'Ioana', 'Marius');

-- 13
SELECT nume, prenume FROM studenti WHERE bursa IS NOT NULL AND grupa LIKE 'A%';

-- 14
SELECT * FROM studenti WHERE prenume LIKE '_%a%'
MINUS
SELECT * FROM studenti WHERE prenume LIKE '_%a%a%';

-- 15 - homework
SELECT nume, prenume FROM profesori WHERE TRIM(prenume) LIKE '%n';
