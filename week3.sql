set serveroutput on;

-- ctrl + f7

DECLARE
    v_contor INTEGER := 0;
BEGIN

    -- REVERSE is used as follows not 10..1
    FOR v_contor IN REVERSE 1..10 LOOP
        dbms_output.put_line(v_contor);
    END LOOP;
END;

BEGIN 

    FOR A IN 1..10000 LOOP
    prim := TRUE;
    if(A = 1) THEN 