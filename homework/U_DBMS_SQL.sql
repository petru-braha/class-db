------------PLSQL9---------------------
----------PACHETUL DBMS_SQL---------------

-- select table_name from user_tables where table_name like ' '
set serveroutput on;
declare
   v_cursor_id INTEGER;
   v_cursor_id1 INTEGER;
   v_ok INTEGER;
   count_tabela number;
begin
  v_cursor_id := DBMS_SQL.OPEN_CURSOR;

-- prima data faceti drop  daca aveti deja creata tabela  
   select count(table_name) into count_tabela from user_tables where table_name like 'TEST';

  if(count_tabela>0) then
  v_cursor_id1  := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(v_cursor_id1, 'drop TABLE TEST', DBMS_SQL.NATIVE);
  v_ok := DBMS_SQL.EXECUTE(v_cursor_id1);
  DBMS_SQL.CLOSE_CURSOR(v_cursor_id1);
  end if;
  
  
  DBMS_SQL.PARSE(v_cursor_id, 'CREATE TABLE TEST(id NUMBER(2,2), val VARCHAR2(30))', DBMS_SQL.NATIVE);
  v_ok := DBMS_SQL.EXECUTE(v_cursor_id);
  DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
 end;

select * from test; 
drop table test;
 -----------------------------------
 -- Executia unui SELECT
 
 create or replace procedure afiseaza_profesori(camp IN varchar2) as
   v_cursor_id INTEGER;
   v_ok INTEGER;
begin
  v_cursor_id := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(v_cursor_id, 'SELECT id, nume, prenume FROM profesori ORDER BY '||camp, DBMS_SQL.NATIVE);
  v_ok := DBMS_SQL.EXECUTE(v_cursor_id);
  DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
end;

--------------------------------
set SERVEROUTPUT  on;
begin
  afiseaza_profesori('id');
end;

-- va genera o eroare pt ca nu exista coloana nume2
begin
  afiseaza_profesori('nume2');
end;

--nu va afisa nimic pentru ca nu s-a specificat sa se afiseze ceva in procedura
begin
  afiseaza_profesori('nume');
end;


describe profesori;
---------------
create or replace procedure afiseaza_profesori(camp IN varchar2) as
   v_cursor_id INTEGER;
   v_ok INTEGER;
   
   v_id_prof number(2);
   v_nume_prof varchar2(15);
   v_prenume_prof varchar2(30);
begin
  v_cursor_id := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(v_cursor_id, 'SELECT id, nume, prenume FROM profesori ORDER BY '||camp, DBMS_SQL.NATIVE);
  DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 1, v_id_prof); 
  DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 2, v_nume_prof,51); 
  -- ATENTIE!! la coloanele de tip varchar2 sau char trebuie specificata si dimensiunea
  DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 3, v_prenume_prof,30);   
  v_ok := DBMS_SQL.EXECUTE(v_cursor_id);
  
  LOOP 
     IF DBMS_SQL.FETCH_ROWS(v_cursor_id)>0 THEN 
         DBMS_SQL.COLUMN_VALUE(v_cursor_id, 1, v_id_prof); 
         DBMS_SQL.COLUMN_VALUE(v_cursor_id, 2, v_nume_prof); 
         DBMS_SQL.COLUMN_VALUE(v_cursor_id, 3, v_prenume_prof); 
 
         DBMS_OUTPUT.PUT_LINE(v_id_prof || '   ' || v_nume_prof || '    ' || v_prenume_prof);
      ELSE 
        EXIT; 
      END IF; 
  END LOOP;   
  DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
end;


begin
  afiseaza_profesori('nume');
end;
----------------------------------------------------------

-- Vom lista si numele coloanelor si valorile din baza de date si pun intr-un fisier
clear screen;
Declare
 
file utl_file.file_type;
v_cursor_id integer;
descColumn DBMS_SQL.DESC_TAB; --definesc coloanele
 
nr_col NUMBER;
variabila_numar Number; -- merge sa declar cu number daca la define column nu dau precizie
variabila_date date;
variabila_varchar varchar2(100);
variabila_char char(100);

v_ok PLS_INTEGER;
v_ok1 PLS_INTEGER;
v_cursor_id1 integer;
nume_tabel number;

expresie varchar2(32000);
separator varchar2(4);
BEGIN
 --open fisier
    file := utl_file.fopen( 'MYDIR', 'coloane.txt', 'w' ); 
 --pas 1 open cursor, obtin id
    v_cursor_id:=DBMS_SQL.Open_cursor;  
    -- puteti testa si pentru un select cu cateva coloane
   -- DBMS_SQL.PARSE(v_cursor_id, 'select id, prenume, data_nastere from studenti', DBMS_SQL.NATIVE); 
  -- pas 2 parsare comanda select
    DBMS_SQL.PARSE(v_cursor_id, 'select * from studenti', DBMS_SQL.NATIVE); 
 ---pas 3 descrierea/definirea coloanelor
    DBMS_SQL.DESCRIBE_COLUMNS(v_cursor_id, nr_col, descColumn); 
 
 expresie:=''; separator:='';
    -- Define columns
--pas 4 parcurg coloanele si le definesc in functie de tip date. 
--In acest caz stim sigur ca avem doar 3 tipuri de date numeric, varchar2 si date de accea putem face cu IF
    FOR i IN 1 .. nr_col LOOP   
        IF descColumn(i).col_type = 2 THEN
           DBMS_SQL.DEFINE_COLUMN(v_cursor_id, i, variabila_numar);  
-- avem tip numeric, nu punem precizie ca altfel da eroare de tip mismach si va merge doar cu varchar2
           expresie:=descColumn(i).col_name||' number('||descColumn(i).col_precision||','||descColumn(i).col_scale||')';
        ELSIF descColumn(i).col_type = 12 THEN
            DBMS_SQL.DEFINE_COLUMN(v_cursor_id, i, variabila_date);  --avem tip date
            expresie:=descColumn(i).col_name||' date';
         ELSIF descColumn(i).col_type = 96 THEN
            DBMS_SQL.DEFINE_COLUMN(v_cursor_id, i, variabila_char, descColumn(i).col_max_len);  
--avem tip varchar2/char, aici trebuie sa specificam si dimensiunea neaparat
            expresie:= descColumn(i).col_name||' char('||descColumn(i).col_max_len||')';
        else DBMS_SQL.DEFINE_COLUMN(v_cursor_id, i, variabila_varchar, descColumn(i).col_max_len);
            expresie:= descColumn(i).col_name||' varchar2('||descColumn(i).col_max_len||')';
         END IF;
         expresie:=separator||expresie;
        DBMS_OUTPUT.PUT(expresie);
        utl_file.putf(file,expresie);  
        separator:=',';
    END LOOP;
-- HINT ->  SE POATE FOLOSI SI O VARIABILA DE TIMP VARCAHR2 care sa fie asociata cu toate coloanele
--si folosita apoi in COLUMN_VALUE SAU
-- SE POATE FOLOSI O COLECTIE DE VARCHAR2-uri ALE CAREI ELEMENTE LE ASOCIEM LA COLOANE...
--ASTA CA SA NU MAI FOLOSITI VRIABILE SPECIFICE PT FIECARE TIP IN PARTE
   
  
 dbms_output.new_line;
 utl_file.put_line(file,'');
 
 v_ok:=DBMS_SQl.execute(v_cursor_id);  --pas 5 executam comanda
 expresie:=''; separator:=''; 
--   Fetch Rows  --pas 6 preluarea RANDURILOR din cursor cu fetch rows
    WHILE DBMS_SQL.FETCH_ROWS(v_cursor_id) > 0 LOOP
        FOR i IN 1 .. nr_col LOOP  -- pas 7 preluarea VALORILOR de pe fiecare rand
          IF (descColumn(i).col_type = 1) THEN
            DBMS_SQL.COLUMN_VALUE(v_cursor_id, i, variabila_varchar); 
            expresie:=variabila_varchar;
         ELSIF (descColumn(i).col_type = 2) THEN
            DBMS_SQL.COLUMN_VALUE(v_cursor_id, i, variabila_numar);
            expresie:=nvl(variabila_numar,0);
          ELSIF (descColumn(i).col_type = 12) THEN
            DBMS_SQL.COLUMN_VALUE(v_cursor_id, i, variabila_date);
            expresie:=variabila_date;
          ELSE  DBMS_SQL.COLUMN_VALUE(v_cursor_id, i, variabila_char);
            expresie:=trim(variabila_char);
          END IF;
        expresie:=separator||expresie;
        DBMS_OUTPUT.PUT(expresie);
        utl_file.putf( file, expresie);
        separator:=' | ';
        END LOOP;
        dbms_output.new_line;
        utl_file.put_line(file,'');
        
    END LOOP;

    DBMS_SQL.CLOSE_CURSOR(v_cursor_id);

    utl_file.fclose(file );
END;
/

/*
https://docs.oracle.com/cd/E18283_01/appdev.112/e16760/d_sql.htm  --foarte dataliat pachetul
https://docs.oracle.com/database/121/SQLRF/sql_elements001.htm#SQLRF30020    --  Oracle Built-in Data Types  -> pentru a afla codul fiecarui tip de date in oracle
https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/dynamic.htm#LNPLS01113 
*/