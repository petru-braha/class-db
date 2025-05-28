   SET SERVEROUTPUT ON;
SET LINESIZE 1000;
SET LONG 1000000;
SET PAGESIZE 0;
SET TRIMSPOOL ON;
SET FEEDBACK OFF;
SET VERIFY OFF;
SPOOL views_export.sql

DECLARE
   v_view_text CLOB;
  
  -- Cursor for views
   CURSOR c_views IS
   SELECT view_name,
          text
     FROM user_views
    ORDER BY view_name;

BEGIN
   DBMS_OUTPUT.PUT_LINE('-- Views export generated on ' || TO_CHAR(
      SYSDATE,
      'DD-MON-YYYY HH24:MI:SS'
   ));
   DBMS_OUTPUT.PUT_LINE('SET ECHO OFF;');
   DBMS_OUTPUT.PUT_LINE('SET VERIFY OFF;');
   DBMS_OUTPUT.PUT_LINE('SET FEEDBACK OFF;');
   DBMS_OUTPUT.PUT_LINE('SET SERVEROUTPUT ON;');
   DBMS_OUTPUT.PUT_LINE('');
  
  -- Export Views
   FOR v IN c_views LOOP
      DBMS_OUTPUT.PUT_LINE('-- View: ' || v.view_name);
      DBMS_OUTPUT.PUT_LINE('CREATE OR REPLACE VIEW '
                           || v.view_name
                           || ' AS');
    
    -- Format the view text by replacing multiple spaces with a single space
      v_view_text := REGEXP_REPLACE(
         v.text,
         '\s+',
         ' '
      );
    
    -- Add proper line breaks after common SQL keywords for better readability
      v_view_text := REGEXP_REPLACE(
         v_view_text,
         '(SELECT|FROM|WHERE|GROUP BY|HAVING|ORDER BY|LEFT JOIN|RIGHT JOIN|INNER JOIN|OUTER JOIN|FULL JOIN|UNION|UNION ALL|INTERSECT|MINUS)'
         ,
         CHR(10)
         || '\1',
         1,
         0,
         'i'
      );

      DBMS_OUTPUT.PUT_LINE(v_view_text || ';');
      DBMS_OUTPUT.PUT_LINE('/');
      DBMS_OUTPUT.PUT_LINE('');
   END LOOP;

   DBMS_OUTPUT.PUT_LINE('COMMIT;');
   DBMS_OUTPUT.PUT_LINE('/');
   DBMS_OUTPUT.PUT_LINE('EXIT;');
END;
/

SPOOL OFF;