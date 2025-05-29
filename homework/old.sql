   SET SERVEROUTPUT ON;
SET LINESIZE 1000;
SET LONG 1000000;
SET PAGESIZE 0;
SET TRIMSPOOL ON;
SET FEEDBACK OFF;
SET VERIFY OFF;

DECLARE
   v_file           UTL_FILE.FILE_TYPE;
   v_table_ddl      CLOB;
   v_constraint_ddl CLOB;
   v_index_ddl      CLOB;
   v_sequence_ddl   CLOB;
   v_trigger_ddl    CLOB;
   v_source_line    VARCHAR2(4000);
   v_prev_line      VARCHAR2(4000);
   v_view_text      CLOB;
  
  -- cursors
   CURSOR c_tables IS
   SELECT table_name
     FROM user_tables
    ORDER BY table_name;

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

   CURSOR c_indexes IS
   SELECT index_name,
          table_name,
          uniqueness
     FROM user_indexes
    WHERE index_type = 'NORMAL'
    ORDER BY table_name,
             index_name;

   CURSOR c_index_columns (
      p_index_name VARCHAR2
   ) IS
   SELECT column_name
     FROM user_ind_columns
    WHERE index_name = p_index_name
    ORDER BY column_position;

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

   CURSOR c_views IS
   SELECT view_name,
          text
     FROM user_views
    ORDER BY view_name;

BEGIN
   v_fisier := UTL_FILE.FOPEN(
      'MYDIR',
      'output.sql',
      'W'
   );

  -- tables
   FOR t IN c_tables LOOP
      UTL_FILE.PUT_LINE(
         v_file,
         'DROP TABLE '
         || t.table_name
         || ' CASCADE CONSTRAINTS;'
      );
      UTL_FILE.PUT_LINE(
         v_file,
         'CREATE TABLE '
         || t.table_name
         || ' ('
      );
    
    -- columns
      FOR c IN c_columns(t.table_name) LOOP
         v_table_ddl := '  '
                        || c.column_name
                        || ' '
                        || c.data_type;
      
      -- Add size for VARCHAR2, CHAR, etc.
         IF c.data_type IN ( 'VARCHAR2',
                             'CHAR' ) THEN
            v_table_ddl := v_table_ddl
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
               v_table_ddl := v_table_ddl
                              || '('
                              || c.data_precision
                              || ')';
            ELSE
               v_table_ddl := v_table_ddl
                              || '('
                              || c.data_precision
                              || ','
                              || c.data_scale
                              || ')';
            END IF;
         END IF;
      
      -- Add nullable constraint
         IF c.nullable = 'N' THEN
            v_table_ddl := v_table_ddl || ' NOT NULL';
         END IF;
      
      -- Add default value if exists
         IF c.data_default IS NOT NULL THEN
            v_table_ddl := v_table_ddl
                           || ' DEFAULT '
                           || TRIM(BOTH ' ' FROM c.data_default);
         END IF;

         UTL_FILE.PUT_LINE(
            v_file,
            v_table_ddl || ','
         );
      END LOOP;
    
    -- Remove last comma
      UTL_FILE.PUT_LINE(
         v_file,
         RTRIM(
            v_table_ddl,
            ','
         )
      );
      UTL_FILE.PUT_LINE(
         v_file,
         ');'
      );
      UTL_FILE.PUT_LINE(
         v_file,
         '/'
      );
      UTL_FILE.PUT_LINE(
         v_file,
         ''
      );
    
    -- Constraints
      FOR c IN c_constraints(t.table_name) LOOP
         IF c.constraint_type = 'P' THEN  -- Primary Key
            UTL_FILE.PUT_LINE(
               v_file,
               'ALTER TABLE '
               || t.table_name
               || ' ADD CONSTRAINT '
               || c.constraint_name
               || ' PRIMARY KEY ('
               || c.column_name
               || ');'
            );
         ELSIF c.constraint_type = 'R' THEN  -- Foreign Key
            UTL_FILE.PUT_LINE(
               v_file,
               'ALTER TABLE '
               || t.table_name
               || ' ADD CONSTRAINT '
               || c.constraint_name
               || ' FOREIGN KEY ('
               || c.column_name
               || ') REFERENCES '
               || c.r_constraint_name
               || ' ON DELETE '
               || c.delete_rule
               || ';'
            );
         ELSIF c.constraint_type = 'U' THEN  -- Unique
            UTL_FILE.PUT_LINE(
               v_file,
               'ALTER TABLE '
               || t.table_name
               || ' ADD CONSTRAINT '
               || c.constraint_name
               || ' UNIQUE ('
               || c.column_name
               || ');'
            );
         ELSIF
            c.constraint_type = 'C'
            AND c.search_condition NOT LIKE '%IS NOT NULL%'
         THEN  -- Check
            UTL_FILE.PUT_LINE(
               v_file,
               'ALTER TABLE '
               || t.table_name
               || ' ADD CONSTRAINT '
               || c.constraint_name
               || ' CHECK ('
               || c.search_condition
               || ');'
            );
         END IF;
      END LOOP;
      UTL_FILE.PUT_LINE(
         v_file,
         '/'
      );
      UTL_FILE.PUT_LINE(
         v_file,
         ''
      );
   END LOOP;
  
  -- Export Indexes
   FOR i IN c_indexes LOOP
      v_index_ddl := 'CREATE ';
      IF i.uniqueness = 'UNIQUE' THEN
         v_index_ddl := v_index_ddl || 'UNIQUE ';
      END IF;
      v_index_ddl := v_index_ddl
                     || 'INDEX '
                     || i.index_name
                     || ' ON '
                     || i.table_name
                     || ' (';
                   
    -- Get index columns
      FOR c IN c_index_columns(i.index_name) LOOP
         v_index_ddl := v_index_ddl
                        || c.column_name
                        || ',';
      END LOOP;
    
    -- Remove last comma and close parenthesis
      v_index_ddl := RTRIM(
         v_index_ddl,
         ','
      )
                     || ');';
      UTL_FILE.PUT_LINE(
         v_file,
         v_index_ddl
      );
      UTL_FILE.PUT_LINE(
         v_file,
         '/'
      );
      UTL_FILE.PUT_LINE(
         v_file,
         ''
      );
   END LOOP;
  
  -- Export Sequences
   FOR s IN c_sequences LOOP
      UTL_FILE.PUT_LINE(
         v_file,
         'CREATE SEQUENCE ' || s.sequence_name
      );
      UTL_FILE.PUT_LINE(
         v_file,
         '  START WITH ' || s.last_number
      );
      UTL_FILE.PUT_LINE(
         v_file,
         '  INCREMENT BY ' || s.increment_by
      );
      UTL_FILE.PUT_LINE(
         v_file,
         '  MINVALUE ' || s.min_value
      );
      IF s.max_value < 999999999999999999999999999 THEN
         UTL_FILE.PUT_LINE(
            v_file,
            '  MAXVALUE ' || s.max_value
         );
      END IF;
      IF s.cycle_flag = 'Y' THEN
         UTL_FILE.PUT_LINE(
            v_file,
            '  CYCLE'
         );
      END IF;
      IF s.cache_size = 0 THEN
         UTL_FILE.PUT_LINE(
            v_file,
            '  NOCACHE;'
         );
      ELSE
         UTL_FILE.PUT_LINE(
            v_file,
            '  CACHE '
            || s.cache_size
            || ';'
         );
      END IF;
      UTL_FILE.PUT_LINE(
         v_file,
         '/'
      );
      UTL_FILE.PUT_LINE(
         v_file,
         ''
      );
   END LOOP;
  
  -- Export Triggers
   FOR t IN c_triggers LOOP
      UTL_FILE.PUT_LINE(
         v_file,
         'CREATE OR REPLACE TRIGGER ' || t.trigger_name
      );
      UTL_FILE.PUT_LINE(
         v_file,
         t.trigger_type
         || ' '
         || t.triggering_event
      );
      UTL_FILE.PUT_LINE(
         v_file,
         'ON ' || t.table_name
      );
      IF t.description IS NOT NULL THEN
         UTL_FILE.PUT_LINE(
            v_file,
            t.description
         );
      END IF;
      UTL_FILE.PUT_LINE(
         v_file,
         'BEGIN'
      );
      UTL_FILE.PUT_LINE(
         v_file,
         t.trigger_body
      );
      UTL_FILE.PUT_LINE(
         v_file,
         'END;'
      );
      UTL_FILE.PUT_LINE(
         v_file,
         '/'
      );
      UTL_FILE.PUT_LINE(
         v_file,
         ''
      );
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
            UTL_FILE.PUT_LINE(
               v_file,
               'CREATE OR REPLACE '
               || s.type
               || ' '
               || s.name
            );
         END IF;
      
      -- Output the source code line
         UTL_FILE.PUT_LINE(
            v_file,
            s.text
         );
      
      -- If line ends with '/', add a newline
         IF s.text = '/' THEN
            UTL_FILE.PUT_LINE(
               v_file,
               ''
            );
         END IF;
         v_prev_line := s.name || s.type;
      END IF;
   END LOOP;

   UTL_FILE.PUT_LINE(
      v_file,
      'COMMIT;'
   );
   UTL_FILE.PUT_LINE(
      v_file,
      '/'
   );
   UTL_FILE.PUT_LINE(
      v_file,
      'EXIT;'
   );
   UTL_FILE.PUT_LINE(
      v_file,
      '-- Views export generated on ' || TO_CHAR(
         SYSDATE,
         'DD-MON-YYYY HH24:MI:SS'
      )
   );
   UTL_FILE.PUT_LINE(
      v_file,
      'SET ECHO OFF;'
   );
   UTL_FILE.PUT_LINE(
      v_file,
      'SET VERIFY OFF;'
   );
   UTL_FILE.PUT_LINE(
      v_file,
      'SET FEEDBACK OFF;'
   );
   UTL_FILE.PUT_LINE(
      v_file,
      'SET SERVEROUTPUT ON;'
   );
   UTL_FILE.PUT_LINE(
      v_file,
      ''
   );
  
  -- Export Views
   FOR v IN c_views LOOP
      UTL_FILE.PUT_LINE(
         v_file,
         '-- View: ' || v.view_name
      );
      UTL_FILE.PUT_LINE(
         v_file,
         'CREATE OR REPLACE VIEW '
         || v.view_name
         || ' AS'
      );
    
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

      UTL_FILE.PUT_LINE(
         v_file,
         v_view_text || ';'
      );
      UTL_FILE.PUT_LINE(
         v_file,
         '/'
      );
      UTL_FILE.PUT_LINE(
         v_file,
         ''
      );
   END LOOP;

   UTL_FILE.PUT_LINE(
      v_file,
      'COMMIT;'
   );
   UTL_FILE.PUT_LINE(
      v_file,
      '/'
   );
   UTL_FILE.PUT_LINE(
      v_file,
      'EXIT;'
   );
   UTL_FILE.FCLOSE(v_fisier);
END;
/