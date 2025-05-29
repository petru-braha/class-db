   SET SERVEROUTPUT ON;

DECLARE
   v_file        UTL_FILE.FILE_TYPE;
   v_table_ddl   VARCHAR2(4000);
   v_index_ddl   VARCHAR2(4000);
   v_source_line VARCHAR2(4000);
   v_prev_line   VARCHAR2(4000);
  
  -- cursors
   CURSOR c_tables IS
   SELECT table_name
     FROM user_tables
    ORDER BY table_name;

   CURSOR c_constraints (
      p_table_name VARCHAR2
   ) IS
   SELECT c.constraint_name,
          constraint_type,
          search_condition,
          r_constraint_name,
          delete_rule,
          c.table_name,
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
          order_flag,
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
   v_file := UTL_FILE.FOPEN(
      'MYDIR',
      'output.sql',
      'W'
   );

--! tables
   UTL_FILE.PUT_LINE(
      v_file,
      '--! tables'
   );
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
      
      -- size for VARCHAR2
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
      
      -- nullable
         IF c.nullable = 'N' THEN
            v_table_ddl := v_table_ddl || ' NOT NULL';
         END IF;
      
      -- default value
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
         ''
      );
    
    -- constraints
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
         THEN
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
         ''
      );
   END LOOP;

--! views
   UTL_FILE.PUT_LINE(
      v_file,
      '--! views'
   );
   FOR v IN c_views LOOP
      UTL_FILE.PUT_LINE(
         v_file,
         'CREATE OR REPLACE VIEW '
         || v.view_name
         || ' AS'
      );
      UTL_FILE.PUT_LINE(
         v_file,
         v.text || ';'
      );
      UTL_FILE.PUT_LINE(
         v_file,
         ''
      );
   END LOOP;

--! sequences
   UTL_FILE.PUT_LINE(
      v_file,
      '--! sequences'
   );
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
         ''
      );
   END LOOP;
  
  --! triggers
   UTL_FILE.PUT_LINE(
      v_file,
      '--! triggers'
   );
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
         t.trigger_body
      );
      UTL_FILE.PUT_LINE(
         v_file,
         ''
      );
   END LOOP;

--! indexes
   UTL_FILE.PUT_LINE(
      v_file,
      '--! indexes'
   );
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
                   
    -- index columns
      FOR c IN c_index_columns(i.index_name) LOOP
         v_index_ddl := v_index_ddl
                        || c.column_name
                        || ',';
      END LOOP;
    
    -- final touch
      v_index_ddl := RTRIM(
         v_index_ddl,
         ','
      );
      UTL_FILE.PUT_LINE(
         v_file,
         v_index_ddl || ');'
      );
      UTL_FILE.PUT_LINE(
         v_file,
         ''
      );
   END LOOP;

--! packages, procedures, functions, types
   UTL_FILE.PUT_LINE(
      v_file,
      '--! packages, procedures, functions, types'
   );
   v_prev_line := NULL;
   FOR s IN c_source_code LOOP
      IF s.type IN ( 'PROCEDURE',
                     'FUNCTION',
                     'PACKAGE',
                     'PACKAGE BODY',
                     'TYPE',
                     'TYPE BODY' ) THEN
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

         UTL_FILE.PUT_LINE(
            v_file,
            s.text
         );
         v_prev_line := s.name || s.type;
      END IF;
   END LOOP;

--! end
   UTL_FILE.PUT_LINE(
      v_file,
      ''
   );
   UTL_FILE.FCLOSE(v_file);
END;