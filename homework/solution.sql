DECLARE
  -- File handling variables
   v_file           UTL_FILE.FILE_TYPE;
   v_directory      VARCHAR2(100) := 'HOMEWORK_DIR';
   v_filename       VARCHAR2(100) := 'output.sql';
  
  -- Variables for storing metadata and SQL
   v_sql            VARCHAR2(32767);
   v_cursor_id      NUMBER;
   v_rows_processed NUMBER;
   v_column_value   VARCHAR2(4000);
   v_columns        VARCHAR2(4000);
   v_values         VARCHAR2(4000);
  
  -- Cursors for metadata
   CURSOR c_tables IS
   SELECT table_name
     FROM user_tables
    ORDER BY table_name;

   CURSOR c_columns (
      p_table_name VARCHAR2
   ) IS
   SELECT column_name,
          data_type,
          data_length,
          data_precision,
          data_scale,
          nullable,
          data_default
     FROM user_tab_columns
    WHERE table_name = p_table_name
    ORDER BY column_id;

   CURSOR c_constraints (
      p_table_name VARCHAR2
   ) IS
   SELECT constraint_name,
          constraint_type,
          search_condition,
          r_constraint_name,
          delete_rule,
          table_name,
          column_name
     FROM user_constraints c
     LEFT JOIN user_cons_columns cc
   ON c.constraint_name = cc.constraint_name
    WHERE c.table_name = p_table_name
    ORDER BY constraint_type;

   CURSOR c_views IS
   SELECT view_name,
          text
     FROM user_views
    ORDER BY view_name;

   CURSOR c_indexes IS
   SELECT index_name,
          table_name,
          uniqueness
     FROM user_indexes
    WHERE index_type = 'NORMAL'
    ORDER BY table_name,
             index_name;

   CURSOR c_sequences IS
   SELECT sequence_name,
          min_value,
          max_value,
          increment_by,
          cycle_flag,
          cache_size,
          last_number
     FROM user_sequences;

   CURSOR c_triggers IS
   SELECT trigger_name,
          trigger_type,
          triggering_event,
          table_name,
          description,
          trigger_body
     FROM user_triggers;

   CURSOR c_source_code IS
   SELECT name,
          type,
          line,
          text
     FROM user_source
    ORDER BY name,
             type,
             line;

  -- Helper procedure to write to file
   PROCEDURE write_line (
      p_text IN VARCHAR2
   ) IS
   BEGIN
      UTL_FILE.PUT_LINE(
         v_file,
         p_text
      );
   END;

BEGIN
  -- Create or replace directory (requires appropriate privileges)
   EXECUTE IMMEDIATE 'CREATE OR REPLACE DIRECTORY HOMEWORK_DIR AS ''.''/homework''';
  
  -- Open the output file
   v_file := UTL_FILE.FOPEN(
      v_directory,
      v_filename,
      'W',
      32767
   );
  
  -- Write header
   write_line('-- Export generated on ' || TO_CHAR(
      SYSDATE,
      'DD-MON-YYYY HH24:MI:SS'
   ));
   write_line('SET ECHO OFF;');
   write_line('SET VERIFY OFF;');
   write_line('SET FEEDBACK OFF;');
   write_line('SET SERVEROUTPUT ON;');
   write_line('ALTER SESSION SET NLS_DATE_FORMAT=''DD-MON-YYYY HH24:MI:SS'';');
   write_line('');
  
  -- Export Tables
   FOR t IN c_tables LOOP
    -- Drop table if exists
      write_line('DROP TABLE '
                 || t.table_name
                 || ' CASCADE CONSTRAINTS;');
      write_line('/');
    
    -- Create table
      write_line('CREATE TABLE '
                 || t.table_name
                 || ' (');
    
    -- Add columns
      FOR c IN c_columns(t.table_name) LOOP
         v_sql := '  '
                  || c.column_name
                  || ' '
                  || c.data_type;
      
      -- Add size for VARCHAR2, CHAR, etc.
         IF c.data_type IN ( 'VARCHAR2',
                             'CHAR' ) THEN
            v_sql := v_sql
                     || '('
                     || c.data_length
                     || ')';
         END IF;
      
      -- Add precision and scale for NUMBER
         IF
            c.data_type = 'NUMBER'
            AND c.data_precision IS NOT NULL
         THEN
            IF c.data_scale = 0 THEN
               v_sql := v_sql
                        || '('
                        || c.data_precision
                        || ')';
            ELSE
               v_sql := v_sql
                        || '('
                        || c.data_precision
                        || ','
                        || c.data_scale
                        || ')';
            END IF;
         END IF;
      
      -- Add nullable constraint
         IF c.nullable = 'N' THEN
            v_sql := v_sql || ' NOT NULL';
         END IF;
      
      -- Add default value if exists
         IF c.data_default IS NOT NULL THEN
            v_sql := v_sql
                     || ' DEFAULT '
                     || TRIM(BOTH ' ' FROM c.data_default);
         END IF;

         write_line(v_sql || ',');
      END LOOP;
    
    -- Remove last comma
      v_sql := RTRIM(
         v_sql,
         ','
      );
      write_line(v_sql);
      write_line(');');
      write_line('/');
      write_line('');
    
    -- Add constraints
      FOR c IN c_constraints(t.table_name) LOOP
         IF c.constraint_type = 'P' THEN  -- Primary Key
            write_line('ALTER TABLE '
                       || t.table_name
                       || ' ADD CONSTRAINT '
                       || c.constraint_name
                       || ' PRIMARY KEY ('
                       || c.column_name
                       || ');');
         ELSIF c.constraint_type = 'R' THEN  -- Foreign Key
            write_line('ALTER TABLE '
                       || t.table_name
                       || ' ADD CONSTRAINT '
                       || c.constraint_name
                       || ' FOREIGN KEY ('
                       || c.column_name
                       || ') REFERENCES '
                       || c.r_constraint_name
                       || ' ON DELETE '
                       || c.delete_rule
                       || ';');
         ELSIF c.constraint_type = 'U' THEN  -- Unique
            write_line('ALTER TABLE '
                       || t.table_name
                       || ' ADD CONSTRAINT '
                       || c.constraint_name
                       || ' UNIQUE ('
                       || c.column_name
                       || ');');
         ELSIF
            c.constraint_type = 'C'
            AND c.search_condition NOT LIKE '%IS NOT NULL%'
         THEN  -- Check
            write_line('ALTER TABLE '
                       || t.table_name
                       || ' ADD CONSTRAINT '
                       || c.constraint_name
                       || ' CHECK ('
                       || c.search_condition
                       || ');');
         END IF;
         write_line('/');
      END LOOP;
      write_line('');
    
    -- Export data using DBMS_SQL
      v_cursor_id := DBMS_SQL.OPEN_CURSOR;
      v_sql := 'SELECT * FROM ' || t.table_name;
      DBMS_SQL.PARSE(
         v_cursor_id,
         v_sql,
         DBMS_SQL.NATIVE
      );
      v_rows_processed := DBMS_SQL.EXECUTE(v_cursor_id);
    
    -- Get column names for INSERT statement
      v_columns := '';
      FOR c IN c_columns(t.table_name) LOOP
         v_columns := v_columns
                      || c.column_name
                      || ',';
      END LOOP;
      v_columns := RTRIM(
         v_columns,
         ','
      );
    
    -- Fetch and write data
      LOOP
         IF DBMS_SQL.FETCH_ROWS(v_cursor_id) > 0 THEN
            v_values := '';
            FOR c IN c_columns(t.table_name) LOOP
               DBMS_SQL.COLUMN_VALUE(
                  v_cursor_id,
                  c.column_name,
                  v_column_value
               );
               IF v_column_value IS NULL THEN
                  v_values := v_values || 'NULL,';
               ELSIF c.data_type IN ( 'VARCHAR2',
                                      'CHAR',
                                      'DATE' ) THEN
                  v_values := v_values
                              || ''''
                              || REPLACE(
                     v_column_value,
                     '''',
                     ''''''
                  )
                              || ''',';
               ELSE
                  v_values := v_values
                              || v_column_value
                              || ',';
               END IF;
            END LOOP;
            v_values := RTRIM(
               v_values,
               ','
            );
            write_line('INSERT INTO '
                       || t.table_name
                       || ' ('
                       || v_columns
                       || ') VALUES ('
                       || v_values
                       || ');');
         ELSE
            EXIT;
         END IF;
      END LOOP;

      DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
      write_line('/');
      write_line('COMMIT;');
      write_line('');
   END LOOP;
  
  -- Export Views
   FOR v IN c_views LOOP
      write_line('-- View: ' || v.view_name);
      write_line('CREATE OR REPLACE VIEW '
                 || v.view_name
                 || ' AS');
      write_line(v.text || ';');
      write_line('/');
      write_line('');
   END LOOP;
  
  -- Export Sequences
   FOR s IN c_sequences LOOP
      write_line('-- Sequence: ' || s.sequence_name);
      write_line('DROP SEQUENCE '
                 || s.sequence_name
                 || ';');
      write_line('/');
      write_line('CREATE SEQUENCE ' || s.sequence_name);
      write_line('  START WITH ' || s.last_number);
      write_line('  INCREMENT BY ' || s.increment_by);
      write_line('  MINVALUE ' || s.min_value);
      IF s.max_value < 999999999999999999999999999 THEN
         write_line('  MAXVALUE ' || s.max_value);
      END IF;
      IF s.cycle_flag = 'Y' THEN
         write_line('  CYCLE');
      END IF;
      IF s.cache_size = 0 THEN
         write_line('  NOCACHE');
      ELSE
         write_line('  CACHE ' || s.cache_size);
      END IF;
      write_line(';');
      write_line('/');
      write_line('');
   END LOOP;
  
  -- Export Triggers
   FOR t IN c_triggers LOOP
      write_line('-- Trigger: ' || t.trigger_name);
      write_line('CREATE OR REPLACE TRIGGER ' || t.trigger_name);
      write_line(t.trigger_type
                 || ' '
                 || t.triggering_event);
      write_line('ON ' || t.table_name);
      IF t.description IS NOT NULL THEN
         write_line(t.description);
      END IF;
      write_line('BEGIN');
      write_line(t.trigger_body);
      write_line('END;');
      write_line('/');
      write_line('');
   END LOOP;
  
  -- Export Procedures, Functions, Packages, and Types
   v_prev_line := NULL;
   FOR s IN c_source_code LOOP
      IF s.type IN ( 'PROCEDURE',
                     'FUNCTION',
                     'PACKAGE',
                     'PACKAGE BODY',
                     'TYPE',
                     'TYPE BODY' ) THEN
         -- Start of a new object
         IF v_prev_line IS NULL
         OR v_prev_line != s.name || s.type THEN
            write_line('-- '
                       || s.type
                       || ': '
                       || s.name);
            write_line('CREATE OR REPLACE '
                       || s.type
                       || ' '
                       || s.name);
         END IF;
         
         -- Output the source code line
         write_line(s.text);
         
         -- If line ends with '/', add a newline
         IF s.text = '/' THEN
            write_line('');
         END IF;
         v_prev_line := s.name || s.type;
      END IF;
   END LOOP;
  
  -- Close the file
   UTL_FILE.FCLOSE(v_file);
  
  -- Clean up
   EXECUTE IMMEDIATE 'DROP DIRECTORY HOMEWORK_DIR';
END;
/