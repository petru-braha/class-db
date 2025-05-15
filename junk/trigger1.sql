   set SERVEROUTPUT ON;

CREATE OR REPLACE TRIGGER grade_boost BEFORE
   UPDATE OF valoare ON note
   FOR EACH ROW
BEGIN
   DBMS_OUTPUT.PUT_LINE('the id of the grade is: ' || :OLD.id);
   DBMS_OUTPUT.PUT_LINE('the old grade: ' || :OLD.valoare);
   DBMS_OUTPUT.PUT_LINE('the proposed new grade: ' || :NEW.valoare);
   IF :NEW.valoare < 5 THEN
      :new.valoare := 5;
   END IF;
   DBMS_OUTPUT.PUT_LINE('the final new grade: ' || :NEW.valoare);
END;

UPDATE note
   SET
   valoare = 3
 WHERE id = 100;