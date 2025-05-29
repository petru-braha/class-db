--! tables
DROP TABLE AUTENTIFICARI CASCADE CONSTRAINTS;
CREATE TABLE AUTENTIFICARI (
  NUME VARCHAR2(30),
  ORA TIMESTAMP(6),
  ORA TIMESTAMP(6)
);


DROP TABLE CURSURI CASCADE CONSTRAINTS;
CREATE TABLE CURSURI (
  ID NUMBER NOT NULL,
  TITLU_CURS VARCHAR2(52) NOT NULL,
  AN NUMBER(1),
  SEMESTRU NUMBER(1),
  CREDITE NUMBER(2),
  CREATED_AT DATE,
  UPDATED_AT DATE,
  UPDATED_AT DATE
);

ALTER TABLE CURSURI ADD CONSTRAINT SYS_C007860 PRIMARY KEY (ID);

DROP TABLE DIDACTIC CASCADE CONSTRAINTS;
CREATE TABLE DIDACTIC (
  ID NUMBER NOT NULL,
  ID_PROFESOR NUMBER NOT NULL,
  ID_CURS NUMBER NOT NULL,
  CREATED_AT DATE,
  UPDATED_AT DATE,
  UPDATED_AT DATE
);

ALTER TABLE DIDACTIC ADD CONSTRAINT SYS_C007874 PRIMARY KEY (ID);
ALTER TABLE DIDACTIC ADD CONSTRAINT FK_DIDACTIC_ID_PROFESOR FOREIGN KEY (ID_PROFESOR) REFERENCES SYS_C007870 ON DELETE NO ACTION;
ALTER TABLE DIDACTIC ADD CONSTRAINT FK_DIDACTIC_ID_CURS FOREIGN KEY (ID_CURS) REFERENCES SYS_C007860 ON DELETE NO ACTION;

DROP TABLE NOTE CASCADE CONSTRAINTS;
CREATE TABLE NOTE (
  ID NUMBER NOT NULL,
  ID_STUDENT NUMBER NOT NULL,
  ID_CURS NUMBER NOT NULL,
  VALOARE NUMBER(2),
  DATA_NOTARE DATE,
  CREATED_AT DATE,
  UPDATED_AT DATE,
  UPDATED_AT DATE
);

ALTER TABLE NOTE ADD CONSTRAINT SYS_C007864 PRIMARY KEY (ID);
ALTER TABLE NOTE ADD CONSTRAINT FK_NOTE_ID_STUDENT FOREIGN KEY (ID_STUDENT) REFERENCES SYS_C007857 ON DELETE NO ACTION;
ALTER TABLE NOTE ADD CONSTRAINT FK_NOTE_ID_CURS FOREIGN KEY (ID_CURS) REFERENCES SYS_C007860 ON DELETE NO ACTION;

DROP TABLE PRIETENI CASCADE CONSTRAINTS;
CREATE TABLE PRIETENI (
  ID NUMBER NOT NULL,
  ID_STUDENT1 NUMBER NOT NULL,
  ID_STUDENT2 NUMBER NOT NULL,
  CREATED_AT DATE,
  UPDATED_AT DATE,
  UPDATED_AT DATE
);

ALTER TABLE PRIETENI ADD CONSTRAINT SYS_C007879 PRIMARY KEY (ID);
ALTER TABLE PRIETENI ADD CONSTRAINT FK_PRIETENI_ID_STUDENT1 FOREIGN KEY (ID_STUDENT1) REFERENCES SYS_C007857 ON DELETE NO ACTION;
ALTER TABLE PRIETENI ADD CONSTRAINT FK_PRIETENI_ID_STUDENT2 FOREIGN KEY (ID_STUDENT2) REFERENCES SYS_C007857 ON DELETE NO ACTION;
ALTER TABLE PRIETENI ADD CONSTRAINT NO_DUPLICATES UNIQUE (ID_STUDENT2);
ALTER TABLE PRIETENI ADD CONSTRAINT NO_DUPLICATES UNIQUE (ID_STUDENT1);

DROP TABLE PROFESORI CASCADE CONSTRAINTS;
CREATE TABLE PROFESORI (
  ID NUMBER NOT NULL,
  NUME VARCHAR2(15) NOT NULL,
  PRENUME VARCHAR2(30) NOT NULL,
  GRAD_DIDACTIC VARCHAR2(20),
  CREATED_AT DATE,
  UPDATED_AT DATE,
  UPDATED_AT DATE
);

ALTER TABLE PROFESORI ADD CONSTRAINT SYS_C007870 PRIMARY KEY (ID);

DROP TABLE STUDENTI CASCADE CONSTRAINTS;
CREATE TABLE STUDENTI (
  ID NUMBER NOT NULL,
  NR_MATRICOL VARCHAR2(6) NOT NULL,
  NUME VARCHAR2(15) NOT NULL,
  PRENUME VARCHAR2(30) NOT NULL,
  AN NUMBER(1),
  GRUPA CHAR(2),
  BURSA NUMBER(6,2),
  DATA_NASTERE DATE,
  EMAIL VARCHAR2(40),
  CREATED_AT DATE,
  UPDATED_AT DATE,
  UPDATED_AT DATE
);

ALTER TABLE STUDENTI ADD CONSTRAINT SYS_C007857 PRIMARY KEY (ID);

DROP TABLE STUDENTI_BETA CASCADE CONSTRAINTS;
CREATE TABLE STUDENTI_BETA (
  NUME_S VARCHAR2(10),
  PRENUME_S VARCHAR2(10),
  BURSA_CUANTUM_S NUMBER(6,2),
  NOTE_AVERAGE_S NUMBER,
  NOTE_AVERAGE_S NUMBER
);


--! views
CREATE OR REPLACE VIEW VIEW_STUDENTI_INFO AS
SELECT
    id,
    nr_matricol,
    UPPER(nume) AS nume,
    INITCAP(prenume) AS prenume,
    an,
    grupa,
    bursa,
    TO_CHAR(data_nastere, 'DD-MM-YYYY') AS data_nastere,
    email,
    TO_CHAR(created_at, 'DD-MM-YYYY HH24:MI:SS') AS created_at,
    TO_CHAR(updated_at, 'DD-MM-YYYY HH24:MI:SS') AS updated_at
FROM
    studenti;

--! sequences
CREATE SEQUENCE RANDOM_SEQ
  START WITH 1
  INCREMENT BY 1
  MINVALUE 1
  NOCACHE;

--! triggers
CREATE OR REPLACE TRIGGER DML_STUD
BEFORE STATEMENT INSERT OR UPDATE OR DELETE
ON STUDENTI
dml_stud
   BEFORE INSERT OR UPDATE OR DELETE ON studenti

BEGIN
  dbms_output.put_line('Operatie DML in tabela studenti !');
  -- puteti sa vedeti cine a declansat triggerul:
  CASE
     WHEN INSERTING THEN DBMS_OUTPUT.PUT_LINE('INSERT');
     WHEN DELETING THEN DBMS_OUTPUT.PUT_LINE('DELETE');
     WHEN UPDATING THEN DBMS_OUTPUT.PUT_LINE('UPDATE');
     -- WHEN UPDATING('NUME') THEN .... // vedeti mai jos trigere ce se executa doar la modificarea unui camp
  END CASE;
END;

--! indexes
CREATE UNIQUE INDEX SYS_C007860 ON CURSURI (ID);

CREATE UNIQUE INDEX SYS_C007874 ON DIDACTIC (ID);

CREATE UNIQUE INDEX SYS_C007864 ON NOTE (ID);

CREATE UNIQUE INDEX NO_DUPLICATES ON PRIETENI (ID_STUDENT1,ID_STUDENT2);

CREATE UNIQUE INDEX SYS_C007879 ON PRIETENI (ID);

CREATE UNIQUE INDEX SYS_C007870 ON PROFESORI (ID);

CREATE UNIQUE INDEX SYS_C007857 ON STUDENTI (ID);

--! packages, procedures, functions, types
CREATE OR REPLACE PROCEDURE AFISEAZA
PROCEDURE afiseaza AS

   my_name varchar2(20):='Gigel';

BEGIN

   DBMS_OUTPUT.PUT_LINE('Ma cheama ' || my_name);

END afiseaza;



DESCRIBE studenti
CREATE OR REPLACE FUNCTION GET_NRPRIETENI_STUDENT
FUNCTION get_nrPrieteni_student (

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
CREATE OR REPLACE FUNCTION GET_NUME_STUDENT
FUNCTION get_nume_student (

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
CREATE OR REPLACE PROCEDURE INC
PROCEDURE inc (p_val IN OUT NUMBER) AS

BEGIN

   p_val := p_val + 1;

END;





SET SERVEROUTPUT ON;



DECLARE

   v_numar NUMBER := 7;

BEGIN

   DBMS_OUTPUT.PUT_LINE( v_numar );

END;
CREATE OR REPLACE PACKAGE PRINT_UTILS
PACKAGE print_utils AS

  PROCEDURE print_message(p_message IN VARCHAR2);

END print_utils;
CREATE OR REPLACE PACKAGE BODY PRINT_UTILS
PACKAGE BODY print_utils AS

  PROCEDURE print_message(p_message IN VARCHAR2) IS

  BEGIN

    DBMS_OUTPUT.PUT_LINE(p_message);

  END print_message;

END print_utils;
CREATE OR REPLACE TYPE STUDENT_MEAN_T
TYPE student_mean_t AS OBJECT (

      id               INTEGER,

      last_name        VARCHAR2(100),

      first_name       VARCHAR2(100),

      mean             NUMBER,

      count_best_grade INTEGER,



      -- methods

      CONSTRUCTOR FUNCTION student_mean_t (

           p_id NUMBER

        ) RETURN SELF AS RESULT,

      MEMBER FUNCTION cMp (

           p_alt_student student_mean_t

        ) RETURN INTEGER,

      MEMBER PROCEDURE print

)

CREATE OR REPLACE TYPE BODY STUDENT_MEAN_T
TYPE BODY student_mean_t AS

   CONSTRUCTOR FUNCTION student_mean_t (

      p_id NUMBER

   ) RETURN SELF AS RESULT IS

   BEGIN

      SELECT id,

             last_name,

             first_name

        INTO

         SELF.id,

         SELF.last_name,

         SELF.first_name

        FROM studenti

       WHERE id = p_id;



      SELECT MEAN(valoare)

        INTO SELF.mean

        FROM note

       WHERE id_student = id;



      SELECT COUNT(valoare)

        INTO SELF.count_best_grade

        FROM note

       WHERE id_student = id

         AND valoare = (

         SELECT MAX(valoare)

           FROM note

          WHERE id_student = id

      );



      RETURN;

   END;



   MEMBER FUNCTION cMp (

      p_alt_student student_mean_t

   ) RETURN INTEGER IS

   BEGIN

      IF SELF.mean > p_alt_student.mean THEN

         RETURN 1;

      ELSIF SELF.mean < p_alt_student.mean THEN

         RETURN -1;

      ELSE

         RETURN 0;

      END IF;

   END;



   MEMBER PROCEDURE print IS

   BEGIN

      DBMS_OUTPUT.PUT_LINE('student: '

                           || last_name

                           || ' '

                           || first_name

                           || ', mean: '

                           || mean

                           || ', count_best_grade: '

                           || count_best_grade);

   END;

END;

CREATE OR REPLACE TYPE STUDENT_POINT_T
TYPE student_point_t UNDER student_mean_t (

      points NUMBER,

      OVERRIDING CONSTRUCTOR FUNCTION student_point_t (

           p_id NUMBER

        ) RETURN SELF AS RESULT,

      OVERRIDING MEMBER FUNCTION cMp (

           p_alt_student student_mean_t

        ) RETURN INTEGER,

      OVERRIDING MEMBER PROCEDURE print

);


