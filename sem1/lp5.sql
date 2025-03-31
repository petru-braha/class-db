/* Afișați numele studenților care iau cea mai mare bursa acordată.
Afișați numele studenților care sunt colegi cu un student pe nume Arhire (coleg = același an si aceeași grupă).
Pentru fiecare grupă afișați numele studenților care au obținut cea mai mică notă la nivelul grupei.
Identificați studenții a căror medie este mai mare decât media tuturor notelor din baza de date. Afișați numele și media acestora.
Afișați numele și media primilor trei studenți ordonați descrescător după medie.
Afișați numele studentului (studenților) cu cea mai mare medie precum și valoarea mediei (atenție: limitarea numărului de linii poate elimina studenții de pe poziții egale; găsiți altă soluție).
Afişaţi numele şi prenumele tuturor studenţilor care au luat aceeaşi nota ca şi Ciprian Ciobotariu la materia Logică. Excludeţi-l pe acesta din listă. (Se știe în mod cert că există un singur Ciprian Ciobotariu și că acesta are o singură notă la logică)
Din tabela studenti, afisati al cincilea prenume in ordine alfabetica.
Punctajul unui student se calculeaza ca fiind o suma intre produsul dintre notele luate si creditele la materiile la care au fost luate notele. Afisati toate informatiile studentului care este pe locul 3 in acest top.
Afișați studenții care au notă maximă la o materie precum și nota și materia respectivă. */

-- 1
SELECT nume
FROM studenti
    WHERE bursa = (SELECT MAX(bursa) FROM studenti);

-- 2
SELECT s0.nume 
FROM studenti s0
    JOIN studenti s1 ON s0.an = s1.an AND s0.grupa = s1.grupa 
    AND UPPER(s1.nume) = 'ARHIRE' and UPPER(s0.nume) != 'ARHIRE'; 

-- 2 v2
SELECT nume FROM studenti 
    WHERE (an, grupa) IN (SELECT DISTINCT an, grupa FROM studenti WHERE UPPER(nume) = 'ARHIRE') 
    AND nr_matricol NOT IN (SELECT nr_matricol FROM studenti WHERE UPPER(nume) = 'ARHIRE');

-- 3
SELECT DISTINCT grupa, an, nume, prenume, valoare
FROM studenti s JOIN note n ON s.nr_matricol = n.nr_matricol
    WHERE (an, grupa, valoare) IN
    (SELECT an, grupa, MIN(valoare) 
    FROM studenti s
        JOIN note n ON s.nr_matricol = n.nr_matricol
        GROUP BY an, grupa
        )
    ORDER BY an, grupa;

-- 4
SELECT nume, AVG(valoare) FROM studenti s
    JOIN note n ON s.nr_matricol = n.nr_matricol
    GROUP BY s.nume, s.nr_matricol HAVING AVG(n.valoare) > (SELECT AVG(valoare) FROM note);

-- 5
SELECT * FROM (SELECT nume, AVG(valoare) 
    FROM studenti s
        JOIN note n ON s.nr_matricol = n.nr_matricol 
        GROUP BY s.nume, s.nr_matricol
        ORDER BY AVG(valoare) DESC
    )
    WHERE ROWNUM < 4;

-- 6
SELECT nume, AVG(valoare) FROM studenti s
    JOIN note n ON s.nr_matricol = n.nr_matricol
    GROUP BY nume, s.nr_matricol 
        HAVING AVG(valoare) = (SELECT MAX(AVG(valoare)) FROM note
            GROUP BY nr_matricol);

-- 7
SELECT s.nume, s.prenume
FROM studenti s
JOIN note n ON s.nr_matricol = n.nr_matricol
JOIN cursuri c ON n.id_curs = c.id_curs
    WHERE UPPER(s.nume) != 'CIOBOTARIU'
    AND UPPER(s.prenume) != 'CIPRIAN'
    AND UPPER(c.titlu_curs) = 'LOGICA'
    AND n.valoare IN (
        SELECT n1.valoare
        FROM studenti s1
        JOIN note n1 ON s1.nr_matricol = n1.nr_matricol
        JOIN cursuri c1 ON n1.id_curs = c1.id_curs
            WHERE UPPER(s1.nume) = 'CIOBOTARIU'
            AND UPPER(s1.prenume) = 'CIPRIAN'
            AND UPPER(c1.titlu_curs) = 'LOGICA');

-- 8
SELECT prenume, i FROM 
    (SELECT prenume, ROWNUM as i FROM 
        (SELECT prenume FROM studenti ORDER BY prenume ASC)) WHERE i = 5;

-- 10
SELECT nume, prenume, valoare, titlu_curs 
FROM studenti s
    JOIN note n ON s.nr_matricol = n.nr_matricol
    JOIN cursuri c ON c.id_curs = n.id_curs
        WHERE (valoare, titlu_curs) IN 
            (SELECT MAX(valoare), titlu_curs 
            FROM cursuri c 
                JOIN note n ON c.id_curs = n.id_curs 
                    GROUP BY c.id_curs, titlu_curs) 
        ORDER BY titlu_curs, nume, prenume;

-- 10 wrong
SELECT c.titlu_curs, s.nume, n.valoare
FROM studenti s
    JOIN note n ON s.nr_matricol = n.nr_matricol
    JOIN cursuri c ON n.id_curs = c.id_curs
    GROUP BY c.id_curs, c.titlu_curs, s.nume, n.valoare
        HAVING (c.id_curs, s.nume, n.valoare) =
            (SELECT c.id_curs, s.nume, MAX(n.valoare) 
            FROM studenti s
                JOIN note n ON s.nr_matricol = n.nr_matricol 
                JOIN cursuri c ON n.id_curs = c.id_curs
                GROUP BY c.id_curs, s.nume
                ORDER BY c.id_curs)
    ORDER BY c.id_curs;

/* 
INSERT INTO studenti VALUES ('800', 'Archip', 'Andrada',2, 'A2',350, TO_DATE('03/04/1996', 'dd/mm/yyyy'));
DELETE FROM studenti WHERE nr_matricol = 800; */
