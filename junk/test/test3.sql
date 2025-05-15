/*
! 1
In tabela studenti inserati 3 studenti astfel:
1 student sa aiba macar o nota dar sa nu aiba prieteni
1 student sa aiba macar un prieten dar sa nu aiba note
1 student sa nu aiba nici note nici prieteni
Insearea se face in mod normal doar cu comenzi Insert.

! 2
Realizati in PLSQL functii (sau o singura functie, e la alegerea voastra) care primesc ca parametru
un id de student si care sa returneze numele si prenumele, nr de prieteni si media studentului. 
Functiile vor arunca exceptii pentru situatiile: 
- nu exista student in BD
- nu are prieteni 
- nu are note, deci nu are medie
FUNCTIILE DOAR vor arunca exceptiile dar NU LE VOR CAPTA (trata). 

! 3
Intr-un bloc anonim declarati o colectie de 5 id-uri de studenti astfel: 
includeti id-urile celor 3 noi studenti abia adaugati si, un id al unui student care exista in bd si are si note si prieteni si, un id care nu exista in BD.
Afisati numele si prenumele, nr de prieteni si media pentru fiecare din cele 5 id-uri sau mesaj de eroare in functie de caz.
In acest bloc anonim CAPTATI exceptiile aruncate in functii, aceleasi exceptii si nu le declarati din nou in 
blocul anonim ca sa nu avem redundanta altfel se acade 0.5p si afisati mesaje corespunzatoare daca studentul 
cu acel id nu exista in BD, daca studentul nu are prieteni si/sau daca nu are note 
(un student poate in acelasi timp sa nu aiba nici nota nici prieteni si trebuie afisate
ambele mesaje pentru acel student).
*/

--! 1

-- note dar no prieteni
INSERT INTO studenti (
   id,
   nr_matricol,
   nume,
   prenume
) VALUES ( (
   SELECT MAX(id) + 1
     FROM studenti
),
           'ESL',
           'Popescu',
           'Ion' );

INSERT INTO note (
   id,
   id_student,
   id_curs,
   valoare
) VALUES ( (
   SELECT MAX(id) + 1
     FROM note
),
           (
              SELECT MAX(id)
                FROM studenti
           ),
           (
              SELECT MAX(id)
                FROM cursuri
           ),
           8 );

-- prieteni dar nu note
INSERT INTO studenti (
   id,
   nr_matricol,
   nume,
   prenume
) VALUES ( (
   SELECT MAX(id) + 1
     FROM studenti
),
           'OSE',
           'Arhire',
           'Mihai' );

INSERT INTO prieteni (
   id,
   id_student1,
   id_student2
) VALUES ( (
   SELECT MAX(id) + 1
     FROM prieteni
),
           (
              SELECT MAX(id)
                FROM studenti
           ),
           1 );

-- no note, no friends
INSERT INTO studenti (
   id,
   nr_matricol,
   nume,
   prenume
) VALUES ( (
   SELECT MAX(id) + 1
     FROM studenti
),
           'ROSE',
           'Arhire',
           'Victor' );

--! 2
CREATE OR REPLACE FUNCTION get_nume_student (
   p_id IN NUMBER
) RETURN studenti.nume%TYPE IS
   v_nume studenti.nume%TYPE;
BEGIN
   SELECT nume
     INTO v_nume
     FROM studenti
    WHERE id = p_id;

   RETURN v_nume;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(
         -20000,
         'nu exista student in BD.'
      );
END;

CREATE OR REPLACE FUNCTION get_nume_student (
   p_id IN NUMBER
) RETURN studenti.prenume%TYPE IS
   v_prenume studenti.prenume%TYPE;
BEGIN
   SELECT prenume
     INTO v_prenume
     FROM studenti
    WHERE id = p_id;

   RETURN v_prenume;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(
         -20000,
         'nu exista student in BD.'
      );
END;

CREATE OR REPLACE FUNCTION get_nrPrieteni_student (
   p_id IN NUMBER
) RETURN NUMBER IS
   v_nr NUMBER;
BEGIN

  -- exceptie
   DECLARE
      v_id_temp INTEGER;
   BEGIN
      SELECT id
        INTO v_id_temp
        FROM studenti
       WHERE id = p_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RAISE_APPLICATION_ERROR(
            -20000,
            'nu exista student in BD.'
         );
   END;
  
  -- calcul
   SELECT COUNT(*)
     INTO v_nr
     FROM prieteni
    WHERE id_student1 = p_id
       OR id_student2 = p_id;

   IF v_nr = 0 THEN
      RAISE_APPLICATION_ERROR(
         -20001,
         'nu are prieteni.'
      );
   END IF;
   RETURN v_nr;
END;

CREATE OR REPLACE FUNCTION get_medie_student (
   p_id IN NUMBER
) RETURN NUMBER IS
   v_medie NUMBER;
BEGIN

  -- exceptie
   DECLARE
      v_id_temp INTEGER;
   BEGIN
      SELECT id
        INTO v_id_temp
        FROM studenti
       WHERE id = p_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RAISE_APPLICATION_ERROR(
            -20000,
            'nu exista student in BD.'
         );
   END;

  -- calcul
   SELECT AVG(valoare)
     INTO v_medie
     FROM note
    WHERE id_student = p_id;

   IF v_medie IS NULL THEN
      RAISE_APPLICATION_ERROR(
         -20002,
         'nu are note, deci nu are medie.'
      );
   END IF;
   RETURN v_medie;
END;

-- testare existent
DECLARE
   v_data INTEGER;
BEGIN
   SELECT get_nrPrieteni_student(1)
     INTO v_data
     FROM DUAL;

   DBMS_OUTPUT.PUT_LINE('There ' || v_data);
END;

-- testare inexistent
DECLARE
   v_data INTEGER;
BEGIN
   SELECT get_nrPrieteni_student(-1)
     INTO v_data
     FROM DUAL;

   DBMS_OUTPUT.PUT_LINE('There ' || v_data);
END;

--! 3
DECLARE
   TYPE id_array IS
      VARRAY(5) OF NUMBER;
   student_ids   id_array := id_array(
      (
         SELECT MAX(id)
           FROM studenti
      ),
      (
         SELECT MAX(id) - 1
           FROM studenti
      ),
      (
         SELECT MAX(id) - 2
           FROM studenti
      ),
      1,
      ( -- nu exista
         SELECT MAX(id) + 1
           FROM studenti
      )
   );
   v_nume        VARCHAR2(100);
   v_prenume     VARCHAR2(100);
   v_nr_prieteni NUMBER;
   v_medie       NUMBER;

-- begin
BEGIN
   FOR i IN 1..student_ids.COUNT LOOP
      DBMS_OUTPUT.PUT_LINE('id student: ' || student_ids(i));
      BEGIN
         v_nume := get_nume_student(student_ids(i));
         v_prenume := get_prenume_student(student_ids(i));
         DBMS_OUTPUT.PUT_LINE('nume student: ' || v_nume);
         DBMS_OUTPUT.PUT_LINE('prenume student: ' || v_prenume);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Eroare: NU exista in BD.');
            CONTINUE;
      END;

      BEGIN
         v_nr_prieteni := get_nrPrieteni_student(student_ids(i));
         DBMS_OUTPUT.PUT_LINE('prieteni: ' || v_nr_prieteni);
      EXCEPTION
         WHEN OTHERS THEN
            IF SQLCODE = -20001 THEN
               DBMS_OUTPUT.PUT_LINE('Eroare: NU are prieteni.');
            ELSE
               DBMS_OUTPUT.PUT_LINE('Eroare necunoscută la prieteni: ' || SQLERRM);
            END IF;
      END;

   END LOOP;
END;