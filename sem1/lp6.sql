/*1. Afişaţi toţi studenţii care au în an cu ei măcar un coleg care să fie mai mare ca ei (vezi data naşterii). Atentie, un student s1 este mai mare daca are data_nastere mai mica decat celalat student s2.
2. Afişaţi toţi studenţii care au media mai mare decât media tuturor notelor colegilor din an cu ei. Pentru aceştia afişaţi numele, prenumele şi media lor.
3. Afişaţi numele, prenumele si grupa celui mai bun student din fiecare grupa în parte.
4. Găsiţi toţi studenţii care au măcar un coleg în acelaşi an care să fi luat aceeaşi nota ca şi el la măcar o materie.
5. Afișați toți studenții care sunt singuri în grupă (nu au alți colegi în aceeași grupă).
6. Afișați profesorii care au măcar un coleg (profesor) ce are media notelor puse la fel ca și el.
7. Fara a folosi join, afisati numele si media fiecarui student.
8. Afisati cursurile care au cel mai mare numar de credite din fiecare an (pot exista si mai multe pe an). - Rezolvati acest exercitiu si corelat si necorelat (se poate in ambele moduri). Care varianta este mai eficienta ?*/

-- laboratory question: returns the people that are not awarded and that don't have any awarded collegues, it runs for every instance of the subquery until one case that is representataive

-- 1
SELECT *
FROM studenti s0
    WHERE EXISTS (
        SELECT *
        FROM studenti s1 
            WHERE s0.an = s1.an AND
            s0.data_nastere > s1.data_nastere);

-- 2
SELECT s0.nume, s0.prenume, AVG(n0.valoare)
FROM studenti s0
    JOIN note n0 ON s0.nr_matricol = n0.nr_matricol
    GROUP BY s0.nr_matricol, s0.nume, s0.prenume, s0.an 
        HAVING AVG(n0.valoare) > (SELECT AVG(n1.valoare)
            FROM studenti s1
                JOIN note n1 ON s1.nr_matricol = n1.nr_matricol
                    WHERE s0.an = s1.an AND
                    s0.nr_matricol != s1.nr_matricol);

-- 3
SELECT 
    s0.nume, 
    s0.prenume, 
    s0.an, 
    s0.grupa,
    (SELECT AVG(n0.valoare) FROM note n0 WHERE n0.nr_matricol = s0.nr_matricol)"medie"
FROM studenti s0
    WHERE (SELECT AVG(n0.valoare) FROM note n0 WHERE n0.nr_matricol = s0.nr_matricol) = 
        (SELECT MAX(AVG(n1.valoare)) 
        FROM studenti s1 
        JOIN note n1 ON s1.nr_matricol = n1.nr_matricol
            WHERE s0.an = s1.an AND
            s0.grupa = s1.grupa 
            GROUP BY s1.nr_matricol);

-- 4
SELECT nume, prenume, grupa
FROM studenti s0
JOIN note n0 ON s0.nr_matricol = n0.nr_matricol
    WHERE EXISTS (
        SELECT *
        FROM studenti s1
        JOIN note n1 ON s1.nr_matricol = n1.nr_matricol
            WHERE s0.an = s1.an AND
            s0.nr_matricol != s1.nr_matricol AND
            n0.valoare = n1.valoare AND
            n0.id_curs = n1.id_curs);

-- 5
SELECT s1.nume, 
    s1.prenume, 
    s1.grupa 
FROM studenti s1
WHERE NOT EXISTS (
    SELECT *
    FROM studenti s2
        WHERE s1.grupa = s2.grupa AND s1.an = s2.an AND s1.nr_matricol != s2.nr_matricol);  

-- 6
SELECT 
    p0.nume,
    p0.prenume,
    AVG(n0.valoare)
FROM profesori p0 
JOIN didactic d0 ON d0.id_prof = p0.id_prof
JOIN note n0 ON d0.id_curs = n0.id_curs
    GROUP BY p0.id_prof, p0.nume, p0.prenume
        HAVING EXISTS (SELECT * FROM profesori p1
            JOIN didactic d1 ON p1.id_prof = d1.id_prof
            JOIN note n1 ON d1.id_curs = n1.id_curs
                WHERE p0.id_prof != p1.id_prof
                GROUP BY p1.id_prof
                HAVING AVG(n0.valoare) = AVG(n1.valoare));

-- 7
 SELECT s.nume, s.prenume,
           (SELECT AVG(n.valoare)
            FROM note n
            WHERE n.nr_matricol = s.nr_matricol) AS medie
    FROM studenti s;

-- 8 
SELECT c0.titlu_curs
FROM cursuri c0
    GROUP BY c0.an, c0.titlu_curs, c0.credite
    HAVING c0.credite = (
        SELECT MAX(c1.credite)
        FROM cursuri c1
            GROUP BY c1.an
            HAVING c0.an = c1.an
    );

-- 8 v2
SELECT c.titlu_curs
FROM cursuri c 
    WHERE (c.an, c.credite) IN (
        SELECT c2.an, MAX(c2.credite) 
        FROM cursuri c2 
            GROUP BY c2.an);
