/* Scrieți o interogare pentru a afișa data de azi. Etichetați coloana "Astazi".
Pentru fiecare student afișați numele, data de nastere si numărul de luni între data curentă și data nașterii.
Afișați ziua din săptămână în care s-a născut fiecare student.
Utilizând functia de concatenare, obțineți pentru fiecare student textul 'Elevul <prenume> este in grupa <grupa>'.
Afisati valoarea bursei pe 10 caractere, completand valoarea numerica cu caracterul $.
Pentru profesorii al căror nume începe cu B, afișați numele cu prima litera mică si restul mari, precum și lungimea (nr. de caractere a) numelui.
Pentru fiecare student afișați numele, data de nastere, data la care studentul urmeaza sa isi sarbatoreasca ziua de nastere si prima zi de duminică de dupa.
Ordonați studenții care nu iau bursă în funcție de luna cand au fost născuți; se va afișa doar numele, prenumele și luna corespunzătoare datei de naștere.
Pentru fiecare student afișati numele, valoarea bursei si textul: 'premiul 1' pentru valoarea 450, 'premiul 2' pentru valoarea 350, 'premiul 3' pentru valoarea 250 și 'mentiune' pentru cei care nu iau bursa. Pentru cea de a treia coloana dati aliasul "Premiu".
Afişaţi numele tuturor studenților înlocuind apariţia literei i cu a şi apariţia literei a cu i.
Afișați pentru fiecare student numele, vârsta acestuia la data curentă sub forma '<x> ani <y> luni și <z> zile' (de ex '19 ani 3 luni și 2 zile') și numărul de zile până își va sărbători (din nou) ziua de naștere.
Presupunând că în următoarea lună bursa de 450 RON se mărește cu 10%, cea de 350 RON cu 15% și cea de 250 RON cu 20%, afișați pentru fiecare student numele acestuia, data corespunzătoare primei zile din luna urmatoare și valoarea bursei pe care o va încasa luna următoare. Pentru cei care nu iau bursa, se va afisa valoarea 0.
Pentru studentii bursieri (doar pentru ei) afisati numele studentului si bursa in stelute: fiecare steluta valoreaza 50 RON. In tabel, alineati stelutele la dreapta. */

-- 1
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD')"Astazi" FROM DUAL;
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD') AS Astazi FROM DUAL;
SELECT CURRENT_TIMESTAMP"Astazi" FROM DUAL;
SELECT SYSDATE"Astazi" FROM DUAL;

-- 2
SELECT nume, data_nastere, CEIL(MONTHS_BETWEEN(SYSDATE, data_nastere))"diferenta de luni" FROM studenti;

-- 3
SELECT nume, prenume, TO_CHAR(data_nastere, 'day')"ziua nasterii" FROM studenti;

-- 4
SELECT CONCAT(CONCAT(CONCAT('Elevul ', prenume), ' este in grupa '), grupa)"propozitie" FROM studenti;
SELECT 'Elevul ' || prenume || ' este in grupa ' || grupa"propozitie" FROM studenti;

-- 5
SELECT nume, RPAD(bursa,10,'$')"bursa" FROM studenti;

-- 6
SELECT 'b' || UPPER(SUBSTR(nume, 1))"nume prof"  FROM profesori WHERE UPPER(nume) LIKE 'B%'; 

-- 7
SELECT nume, 
    data_nastere, 
    ADD_MONTHS(data_nastere, 
        12*(FLOOR(MONTHS_BETWEEN(SYSDATE, data_nastere)/12 + 1)))"urmatoarea aniv",
    NEXT_DAY(ADD_MONTHS(data_nastere, 
        12*(FLOOR(MONTHS_BETWEEN(SYSDATE, data_nastere)/12 + 1))), 'sunday')"dum"
FROM studenti;

-- 8
SELECT nume, prenume, 
    TO_CHAR(data_nastere, 'mon') 
FROM studenti 
    WHERE bursa IS NULL
    ORDER BY (data_nastere - FLOOR(MONTHS_BETWEEN(SYSDATE, data_nastere)/12)*12);

SELECT nume, prenume, 
    TO_CHAR(data_nastere, 'MM') 
FROM studenti 
    WHERE bursa IS NULL 
    ORDER BY TO_CHAR(data_nastere,'MM'); 

-- 9
SELECT nume, bursa, DECODE(bursa, 450, 'premiul 1',350, 'premiul 2',250, 'premiul 3', 'mentiune')"premiu" 
FROM studenti;

-- 10
SELECT TRANSLATE(nume, 'ai', 'ia')"nume_formatat" FROM studenti;

-- 11
SELECT prenume, data_nastere,
    FLOOR(MONTHS_BETWEEN(SYSDATE, data_nastere)/12) "ani",
    FLOOR(MONTHS_BETWEEN(SYSDATE, data_nastere) - 12 * FLOOR(MONTHS_BETWEEN(SYSDATE, data_nastere)/12)) "luni",
    FLOOR(SYSDATE - ADD_MONTHS(data_nastere, FLOOR(MONTHS_BETWEEN(SYSDATE, data_nastere)))) "zile",
    FLOOR(1 + ADD_MONTHS(data_nastere, 12 * FLOOR(MONTHS_BETWEEN(SYSDATE, data_nastere)/12 + 1)) /*next aniv*/
    - SYSDATE) "days count"
FROM studenti;

-- 12 - homework
SELECT nume, 
    TO_DATE(LAST_DAY(SYSDATE) + 1)"prima zi din urmatoarea luna",
    DECODE(bursa, 
        450, 450 + 45, 
        350, 350 + 350 * 3 / 20,   
        250, 250 + 50,
        NULL, 0)"bursa urmatoarea luna"
FROM studenti;

-- 13 - homework
SELECT nume, LPAD(RPAD('*', bursa/50, '*'), 450/50)"bursa" 
FROM studenti WHERE bursa IS NOT NULL;
