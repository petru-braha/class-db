   set serveroutput on;

CREATE OR REPLACE TRIGGER dml_stud1 BEFORE
   INSERT OR UPDATE OR DELETE ON studenti
DECLARE
   v_nume studenti.nume%TYPE;
BEGIN
   SELECT nume
     INTO v_nume
     FROM studenti
    WHERE id = 200;
   dbms_output.put_line('Before DML TRIGGER: ' || v_nume);
END;
/

CREATE OR REPLACE TRIGGER dml_stud2 AFTER
   INSERT OR UPDATE OR DELETE ON studenti
DECLARE
   v_nume studenti.nume%TYPE;
BEGIN
   SELECT nume
     INTO v_nume
     FROM studenti
    WHERE id = 200;
   dbms_output.put_line('After DML TRIGGER: ' || v_nume);
END;
/

UPDATE STUDENTI
   SET
   nume = 'fasole'
 WHERE id = 200;