   set serveroutput on;
DECLARE
   v_contor1 INTEGER;
   v_contor2 INTEGER;
BEGIN
   << eticheta >> FOR v_contor1 IN 1..5 LOOP
      FOR v_contor2 IN 10..20 LOOP
         DBMS_OUTPUT.PUT_LINE(v_contor1
                              || '-'
                              || v_contor2);
         EXIT eticheta WHEN (
            ( v_contor1 = 3 )
            AND ( v_contor2 = 17 )
         );
      END LOOP;
   END LOOP;
END;