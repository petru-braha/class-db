/*Afișați numărul de studenți din fiecare an.
Afișați numărul de studenți din fiecare grupă a fiecărui an de studiu. Ordonați crescător după anul de studiu și după grupă.
Afișați numărul de studenți din fiecare grupă a fiecărui an de studiu și specificați câți dintre aceștia sunt bursieri.
Afișați suma totală cheltuită de facultate pentru acordarea burselor.
Afișați valoarea bursei/cap de student (se consideră că studentii care nu sunt bursieri primesc 0 RON); altfel spus: cât se cheltuiește în medie pentru un student?
Afișați numărul de note de fiecare fel (câte note de 10, câte de 9,etc.). Ordonați descrescător după valoarea notei.
Afișați numărul de note pus în fiecare zi a săptămânii. Ordonați descrescător după numărul de note.
Afișați numărul de note pus în fiecare zi a săptămânii. Ordonați crescător după ziua saptamanii: Sunday, Monday, etc.
Afișați pentru fiecare elev care are măcar o notă, numele și media notelor sale. Ordonați descrescător după valoarea mediei.
Modificați interogarea anterioară pentru a afișa și elevii fără nici o notă. Media acestora va fi null.
Modificați interogarea anterioară pentru a afișa pentru elevii fără nici o notă media 0.
Modificati interogarea de mai sus pentru a afisa doar studentii cu media mai mare ca 8.
Afișați numele, cea mai mare notă, cea mai mică notă și media doar pentru acei studenti care au primit doar note mai mari sau egale cu 7 (au cea mai mică notă mai mare sau egală cu 7).
Afișați numele și mediile studenților care au cel puțin un număr de 3 note puse în catalog.
Afișați numele și mediile studenților care au cel puțin un număr de 3 note diferite puse în catalog.
Afișați numele și mediile studenților din grupa A2 anul 3.
Afișați cea mai mare medie obținută de vreun student. Puteți să afișați și numărul matricol al studentului care are acea medie maximală ? Argumentați.
Un profesor este iubit de studenti daca pune note mai mari (adica media notelor sale este mai mare). Afisati toti profesorii in ordinea preferintelor studentilor impreuna cu mediile notelor puse de ei scrise cu doua zecimale .
Afisati numarul de restantieri generati de FIECARE profesor (tip: 1 cu 2 restantieri, 4 cu 1 restantier, 11 cu 0 restantieri)*/

-- 1
SELECT an, COUNT(*)"nr studenti" FROM studenti 
    GROUP BY an;

-- 2
SELECT an, grupa, COUNT(*)"nr studenti" FROM studenti 
    GROUP BY an, grupa ORDER BY an, grupa;

-- 3
SELECT 
    an, grupa, 
    COUNT(nr_matricol) AS nr_studenti, 
    COUNT (bursa) AS nr_bursieri
FROM studenti 
    GROUP BY an, grupa;

-- 4
SELECT SUM(bursa) FROM studenti;

-- 5
SELECT AVG(NVL(bursa, 0))"cheltuiala/student" FROM studenti;  

-- 6
SELECT valoare, COUNT(*) 
FROM note GROUP BY valoare ORDER BY valoare ASC;

-- 6 v2
SELECT n.valoare, COUNT(*) FROM studenti s
    JOIN note n ON s.nr_matricol = n.nr_matricol
    GROUP BY n.valoare ORDER BY n.valoare ASC;

-- 7
SELECT TO_CHAR(data_notare, 'day'), COUNT(*)
FROM note GROUP BY TO_CHAR(data_notare, 'day') ORDER BY COUNT(valoare) DESC;

-- 8
SELECT COUNT(valoare), TO_CHAR(data_notare, 'day') FROM note
    GROUP BY data_notare
    ORDER BY TO_CHAR(data_notare, 'day');

-- 9
SELECT s.nume"nume", AVG(n.valoare)"avg nota" 
FROM note n
JOIN studenti s ON s.nr_matricol = n.nr_matricol
    GROUP BY s.nume, s.nr_matricol 
    ORDER BY AVG(n.valoare) DESC;

-- 10
SELECT s.nume"nume", AVG(n.valoare) "avg nota"
FROM studenti s
LEFT OUTER JOIN note n ON s.nr_matricol = n.nr_matricol
    GROUP BY s.nume, s.nr_matricol
    ORDER BY AVG(NVL(n.valoare, 0)) DESC;

-- 13
SELECT s0.nr_matricol, s0.nume,
    MAX(n0.valoare), MIN(n0.valoare), 
    AVG(n0.valoare) 
FROM studenti s0
JOIN note n0 ON s0.nr_matricol = n0.nr_matricol
    GROUP BY s0.nr_matricol, s0.nume
    HAVING MIN(n0.valoare) >= 7;

-- 16
SELECT s.nume, AVG(NVL(n.valoare, 0))"media" FROM studenti s
LEFT OUTER JOIN note n ON s.nr_matricol = n.nr_matricol
    WHERE UPPER(s.grupa) = 'A2' AND an = 3
    GROUP BY s.nume, s.nr_matricol, n.valoare
    ORDER BY s.nume ASC;

-- 17
SELECT MAX(AVG(valoare)) FROM note GROUP BY nr_matricol;

-- 18
SELECT p.nume, p.prenume, 
    TO_CHAR(AVG(n.valoare), '99.99')"media"
FROM note n
JOIN didactic d ON n.id_curs = d.id_curs
JOIN profesori p ON d.id_prof = p.id_prof
    GROUP BY p.nume, p.prenume, p.id_prof, d.id_curs
    ORDER BY AVG(valoare) DESC;

-- 19
SELECT COUNT(p.id_prof), COUNT(s.nr_matricol)
FROM profesori p
JOIN didactic d ON p.id_prof = d.id_prof
JOIN note n ON d.id_curs = n.id_curs
JOIN studenti s ON n.nr_matricol = s.nr_matricol
    GROUP BY n.id_curs, p.id_prof, s.nr_matricol
    HAVING AVG(n.valoare) < 5;

-- COUNT(studenti) cu avg la o materie < 5 

-- print stundeti and their mean to every discipline
SELECT s.nr_matricol, n.id_curs, AVG(NVL(n.valoare, 0))
FROM studenti s
JOIN note n ON s.nr_matricol = n.nr_matricol
    GROUP BY s.nr_matricol, n.id_curs, n.valoare;
    ORDER BY s.nr_matricol, c.id_curs;
