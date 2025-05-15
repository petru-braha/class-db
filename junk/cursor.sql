   SET SERVEROUTPUT ON;

DECLARE
   CURSOR statement IS
   SELECT nume,
          prenume
     FROM studenti
    WHERE bursa IS NOT NULL;
   v_nume    studenti.nume%TYPE;
   v_prenume studenti.prenume%TYPE;
BEGIN
   DBMS_OUTPUT.PUT_LINE('the procedure started');
   OPEN statement;
   LOOP
      FETCH statement INTO
         v_nume,
         v_prenume;
      DBMS_OUTPUT.PUT_LINE('the student '
                           || v_nume
                           || ' '
                           || v_prenume
                           || ' has respect');
   END LOOP;
   CLOSE statement;
END;