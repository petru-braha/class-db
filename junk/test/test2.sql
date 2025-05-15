/*

--! class declaration
Sa se defineasca o clasa cu informatii despre studenti precum last_name, first_name, mean si cate note de zece are. 
- Creatiti un constructor pentru a crea obiectele, care prin intermediul
unui id de student din tabela studenti sa preia informatiile necesare. 
- Creati o metoda de comparare la alegere care sa compare doua obiecte dupa mean lor.
- Creati o procedura de afisare a informatiilor despre obiecte.

--! collection
Intr-un bloc anonim creati o colectie (la alegere) de 10 obiecte de tip student si afisati informatii
despre ele. 
- Afisati care este cel mai bun in functie de medie.
- Afisati si care sunt obiectele de tip student (afisati last_name, first_name, numar note de zece) care au cele
mai multe note de zece, deoarece e posibil ca mai multi sa aiba acelasi numar de note de zece dintre cei 10.

--! subtype
Creati apoi un subtip al tipului student care are in plus ca atribut si numarul total de puncte
corespunzator cu nota obtinuta la un curs inmultit cu numarul de credite la acel curs 
(nr total de puncte pentru fiecare student in parte). 
- Creati un constructor pentru subtip care sa
preia conform unui id de student din tabela studenti in plus si acest numar de puncte.
- Suprascrieti metoda de ordonare a obiectelor pentru a le ordona dupa numarul de puncte si nu dupa medie.
- Suprascrieti si metoda de afisare pentru a afisa si numarul de puncte.

--! block
Creati un al doilea bloc anonim pentru a crea o colectie de 10 obiecte de subtipul respectiv, 
utilizand id-uri din tabela studenti si apelati metoda de afisare suprascrisa si afisati si cine 
are cele mai multe puncte (metoda de comparare dupa puncte). 
*/

--! class declaration
CREATE OR REPLACE TYPE student_mean_t AS OBJECT (
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
/

--! class definition
CREATE OR REPLACE TYPE BODY student_mean_t AS
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
/

--! collection
DECLARE
   TYPE student_arr IS
      TABLE OF student_mean_t;
   arr       student_arr := student_arr();
   s         student_mean_t;
   best      student_mean_t;
   count_max NUMBER := 0;
BEGIN
   FOR i IN 1..10 LOOP
      s := student_mean_t(i);
      arr.EXTEND;
      arr(i) := s;
      s.print;

      -- best mean
      IF best IS NULL
      OR s.cMp(best) = 1 THEN
         best := s;
      END IF;

      IF s.count_best_grade > count_max THEN
         count_max := s.count_best_grade;
      END IF;
   END LOOP;

   DBMS_OUTPUT.PUT_LINE('best student based on their means:');
   best.print;
   DBMS_OUTPUT.PUT_LINE('most amount of 10s for a student: ' || count_max);
   DBMS_OUTPUT.PUT_LINE('the students respecting this criteria are the following: ');
 
    -- print those with max == count_best_grade
   FOR i IN 1..arr.COUNT LOOP
      IF arr(i).count_best_grade = count_max THEN
         DBMS_OUTPUT.PUT_LINE(arr(i).last_name
                              || ' '
                              || arr(i).first_name);
      END IF;
   END LOOP;
END;
/

--! subtype declaration
CREATE OR REPLACE TYPE student_point_t UNDER student_mean_t (
      points NUMBER,
      OVERRIDING CONSTRUCTOR FUNCTION student_point_t (
           p_id NUMBER
        ) RETURN SELF AS RESULT,
      OVERRIDING MEMBER FUNCTION cMp (
           p_alt_student student_mean_t
        ) RETURN INTEGER,
      OVERRIDING MEMBER PROCEDURE print
);
/