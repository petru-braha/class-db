/* Cum poate fi utilizată o secvență la inserare?
Răspundeți creând o secvență care sa vă ajute sa inserați noi cursuri cu id unic, cu intrari consecutive crescătoare cu pasul 1. Inserati 3 cursuri noi cu id-ul generat de secventa.*/

CREATE SEQUENCE s0
    INCREMENT BY 1
    START WITH 30;

INSERT INTO cursuri (id_curs) VALUES (TO_CHAR(s0.NEXTVAL));
INSERT INTO cursuri (id_curs) VALUES (TO_CHAR(s0.NEXTVAL));
INSERT INTO cursuri (id_curs) VALUES (TO_CHAR(s0.NEXTVAL));

DELETE FROM cursuri WHERE id_curs = (SELECT MAX(id_curs) FROM cursuri);
DELETE FROM cursuri WHERE id_curs = (SELECT MAX(id_curs) FROM cursuri);
DELETE FROM cursuri WHERE id_curs = (SELECT MAX(id_curs) FROM cursuri);

DROP SEQUENCE s0;

-- 1. Actualizati valoarea bursei pentru studentii care au măcar o notă de 10. Acestia vor primi ca bursa 500RON.
-- 2. Toti studentii primesc o bursa egala cu 100*media notelor lor. Efectuati modificarile necesare.

-- 1
UPDATE studenti s0
SET s0.bursa = NVL(s0.bursa, 0) + 500
    WHERE EXISTS (SELECT * FROM studenti s
                    JOIN note n ON s.nr_matricol = n.nr_matricol
                        WHERE s0.nr_matricol = s.nr_matricol 
                        AND n.valoare = 10);

-- 2
UPDATE studenti s0
SET s0.bursa = 100 * (SELECT AVG(n1.valoare)
                FROM studenti s1
                JOIN note n1 on s1.nr_matricol = n1.nr_matricol
                    WHERE s0.nr_matricol = s1.nr_matricol);

-- 1. Stergeti toti studentii care nu au nici o nota

-- 1
DELETE FROM studenti 
    WHERE nr_matricol NOT IN 
        (SELECT s.nr_matricol 
        FROM studenti s
        JOIN note n ON s.nr_matricol = n.nr_matricol
            WHERE n.valoare IS NOT NULL -- extra but necessary
        );

-- 1. Executati comanda ROLLBACK. Creati apoi o tabelă care să stocheze numele, prenumele, bursa si mediile studentilor.
ROOLBACK;
CREATE TABLE studenti_beta(
    nume_s,
    prenume_s,
    bursa_cuantum_s,
    note_average_s
) AS (SELECT s0.nume, s0.prenume, s0.bursa, AVG(n0.valoare)
FROM studenti s0
JOIN note n0 ON s0.nr_matricol = n0.nr_matricol
    GROUP BY s0.nr_matricol, s0.nume, s0.prenume, s0.bursa
);

DROP TABLE studenti_beta;

/*
1. Executati din nou scriptul de creare de aici: http://profs.info.uaic.ro/~vcosmin/BD/facultate.sql
2. Adăugați constrângerile de tip cheie primară pentru tabelele Studenti, Profesori, Cursuri.
3. Adăugați constrângerile referențiale pentru tabelele Note și Didactic. La ștergerea unui profesor din tabela Profesori, în tabela Didactic id-ul profesorului șters va deveni null. La stergerea unui curs din tabela Cursuri, in tabela Didactic va fi stearsă înregistrarea care referențiază cursul șters. Scrieți comenzi de ștergere înregistrări pentru tabelele referențiate și studiați comportamentul.
4. Impuneți constrângerea ca un student să nu aibă mai mult de o notă la un curs.
5. Impuneți constrângerea ca valoarea notei să fie cuprinsă între 1 și 10. */

-- 1
@facultate.sql

-- 2
ALTER TABLE studenti ADD CONSTRAINT pk PRIMARY KEY(nr_matricol);
ALTER TABLE profesori ADD CONSTRAINT pk1 PRIMARY KEY(id_prof);
ALTER TABLE cursuri ADD CONSTRAINT pk2 PRIMARY KEY(id_curs);

-- 3
ALTER TABLE note ADD CONSTRAINT fk FOREIGN KEY (nr_matricol) REFERENCES studenti(nr_matricol);