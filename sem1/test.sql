-- 1 
SELECT DISTINCT grupa FROM studenti WHERE an = 2 
MINUS
SELECT DISTINCT grupa FROM studenti WHERE an = 3;

-- 2
SELECT titlu_curs, credite, 
    DECODE(credite,
    3, 'facultativ',
    5, 'optional',
    'obligatoriu'
    ) 
FROM cursuri ORDER BY credite DESC, titlu_curs ASC;

-- 3
SELECT p.nume
FROM profesori p
    JOIN didactic d ON d.id_prof = p.id_prof
    JOIN cursuri c ON c.id_curs = d.id_curs
    WHERE p.grad_didactic IS NOT NULL AND c.credite = 5 AND LENGTH(p.prenume) = 7;

-- 4
SELECT DISTINCT TO_CHAR(s.data_nastere, 'mon') FROM studenti s
    LEFT OUTER JOIN note n ON s.nr_matricol = n.nr_matricol
    WHERE n.valoare IS NULL;

SELECT DISTINCT TO_CHAR(data_nastere, 'mon') FROM studenti
    WHERE nr_matricol NOT IN(SELECT nr_matricol FROM note);

-- 5
SELECT s1.prenume || ', ' || s2.prenume"prenume frati" FROM studenti s1
    JOIN studenti s2 ON s1.nr_matricol != s2.nr_matricol AND s1.nume = s2.nume
    WHERE s1.nr_matricol < s2.nr_matricol;