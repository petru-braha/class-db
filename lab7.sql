   SET SERVEROUTPUT ON;

-- 0
-- UPDATE studenti set bursa = bursa + 10 WHERE bursa > 300;
<< global >> DECLARE
   v_cartofi INTEGER := 10;
BEGIN
   << local >> DECLARE
      v_cartofi studenti.id%TYPE := 15;
   BEGIN
      SELECT id
        INTO local.v_cartofi
        FROM studenti
       WHERE ROWNUM = 1;
      dbms_output.put_line('ay lmao 1 ' || local.v_cartofi);
      dbms_output.put_line('ay lmao 2 ' || global.v_cartofi);
   END;
END;

-- 1
DECLARE
   CURSOR lista_studenti IS
   SELECT *
     FROM studenti;
   v_std_linie lista_studenti%ROWTYPE;
BEGIN
   OPEN lista_studenti;
   LOOP
      FETCH lista_studenti INTO v_std_linie;
      EXIT WHEN lista_studenti%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE(v_std_linie.nume
                           || ' '
                           || v_std_linie.data_nastere);
   END LOOP;
   CLOSE lista_studenti;
END;

-- 2
DECLARE
   CURSOR lista_studenti IS
   SELECT *
     FROM studenti;
BEGIN
   FOR v_std_linie IN lista_studenti LOOP
      DBMS_OUTPUT.PUT_LINE(v_std_linie.nume
                           || ' '
                           || v_std_linie.data_nastere);
   END LOOP;
END;