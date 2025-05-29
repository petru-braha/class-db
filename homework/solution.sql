   SET SERVEROUTPUT ON;

DECLARE
   v_file      UTL_FILE.FILE_TYPE;
   v_table_ddl VARCHAR2(4000);
   v_index_ddl VARCHAR2(4000);
   v_prev_line VARCHAR2(4000);

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
      
      -- VARCHAR2
         IF c.data_type IN ( 'VARCHAR2',
                             'CHAR' ) THEN
            v_table_ddl := v_table_ddl
                           || '('
                           || c.data_length
                           || ')';
         END IF;
      
      -- NUMBER
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
         IF c.constraint_type = 'P' THEN
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
         ELSIF c.constraint_type = 'R' THEN
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
         ELSIF c.constraint_type = 'U' THEN
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


--! data
   UTL_FILE.PUT_LINE(
      v_file,
      '--! data'
   );
   FOR tab_data IN (
      SELECT table_name
        FROM user_tables
       ORDER BY table_name
   ) LOOP
      DECLARE
         v_count         NUMBER;
         v_columns       VARCHAR2(4000);
         v_insert_base   VARCHAR2(4000);
         v_cursor_sql    VARCHAR2(4000);
         v_cursor_id     NUMBER;
         v_col_count     NUMBER;
         v_desc_tab      DBMS_SQL.DESC_TAB;
         v_col_value     VARCHAR2(4000);
         v_date_value    DATE;
         v_number_value  NUMBER;
         v_insert_values VARCHAR2(32767);
         v_ret           NUMBER;
      BEGIN
         EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || tab_data.table_name
           INTO v_count;
         IF v_count > 0 THEN
            SELECT
               LISTAGG(LOWER(column_name),
                       ', ') WITHIN GROUP(
                ORDER BY column_id),
               COUNT(*)
              INTO
               v_columns,
               v_col_count
              FROM user_tab_columns
             WHERE table_name = tab_data.table_name;

            v_insert_base := 'INSERT INTO '
                             || LOWER(tab_data.table_name)
                             || ' ('
                             || v_columns
                             || ') VALUES ';
        
        -- SELECT
            v_cursor_sql := 'SELECT * FROM ' || tab_data.table_name;
            v_cursor_id := DBMS_SQL.OPEN_CURSOR;
            DBMS_SQL.PARSE(
               v_cursor_id,
               v_cursor_sql,
               DBMS_SQL.NATIVE
            );
            DBMS_SQL.DESCRIBE_COLUMNS(
               v_cursor_id,
               v_col_count,
               v_desc_tab
            );
            FOR i IN 1..v_col_count LOOP
               IF v_desc_tab(i).col_type = 1 THEN -- VARCHAR2/CHAR
                  DBMS_SQL.DEFINE_COLUMN(
                     v_cursor_id,
                     i,
                     v_col_value,
                     4000
                  );
               ELSIF v_desc_tab(i).col_type = 2 THEN -- NUMBER
                  DBMS_SQL.DEFINE_COLUMN(
                     v_cursor_id,
                     i,
                     v_number_value
                  );
               ELSIF v_desc_tab(i).col_type = 12 THEN -- DATE
                  DBMS_SQL.DEFINE_COLUMN(
                     v_cursor_id,
                     i,
                     v_date_value
                  );
               ELSE
                  DBMS_SQL.DEFINE_COLUMN(
                     v_cursor_id,
                     i,
                     v_col_value,
                     4000
                  );
               END IF;
            END LOOP;

            v_ret := DBMS_SQL.EXECUTE(v_cursor_id);
            WHILE DBMS_SQL.FETCH_ROWS(v_cursor_id) > 0 LOOP
               v_insert_values := '(';
               FOR i IN 1..v_col_count LOOP
                  IF i > 1 THEN
                     v_insert_values := v_insert_values || ', ';
                  END IF;
                  IF v_desc_tab(i).col_type = 1 THEN
                     DBMS_SQL.COLUMN_VALUE(
                        v_cursor_id,
                        i,
                        v_col_value
                     );
                     IF v_col_value IS NULL THEN
                        v_insert_values := v_insert_values || 'NULL';
                     ELSE
                        v_insert_values := v_insert_values
                                           || ''''
                                           || REPLACE(
                           v_col_value,
                           '''',
                           ''''''
                        )
                                           || '''';
                     END IF;
                  ELSIF v_desc_tab(i).col_type = 2 THEN
                     DBMS_SQL.COLUMN_VALUE(
                        v_cursor_id,
                        i,
                        v_number_value
                     );
                     IF v_number_value IS NULL THEN
                        v_insert_values := v_insert_values || 'NULL';
                     ELSE
                        v_insert_values := v_insert_values || TO_CHAR(v_number_value);
                     END IF;
                  ELSIF v_desc_tab(i).col_type = 12 THEN
                     DBMS_SQL.COLUMN_VALUE(
                        v_cursor_id,
                        i,
                        v_date_value
                     );
                     IF v_date_value IS NULL THEN
                        v_insert_values := v_insert_values || 'NULL';
                     ELSE
                        v_insert_values := v_insert_values
                                           || 'TO_DATE('''
                                           || TO_CHAR(
                           v_date_value,
                           'DD-MON-YYYY HH24:MI:SS'
                        )
                                           || ''', ''DD-MON-YYYY HH24:MI:SS'')';
                     END IF;
                  ELSE
                     DBMS_SQL.COLUMN_VALUE(
                        v_cursor_id,
                        i,
                        v_col_value
                     );
                     IF v_col_value IS NULL THEN
                        v_insert_values := v_insert_values || 'NULL';
                     ELSE
                        v_insert_values := v_insert_values
                                           || ''''
                                           || REPLACE(
                           v_col_value,
                           '''',
                           ''''''
                        )
                                           || '''';
                     END IF;
                  END IF;
               END LOOP;

               v_insert_values := v_insert_values || ');';
          
          -- INSERT 
               UTL_FILE.PUT_LINE(
                  v_file,
                  v_insert_base || v_insert_values
               );
            END LOOP;

            DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
            UTL_FILE.PUT_LINE(
               v_file,
               '/'
            );
            UTL_FILE.PUT_LINE(
               v_file,
               ''
            );
         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            IF DBMS_SQL.IS_OPEN(v_cursor_id) THEN
               DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
            END IF;
            NULL;
      END;
   END LOOP;

--! end
   UTL_FILE.PUT_LINE(
      v_file,
      ''
   );
   UTL_FILE.FCLOSE(v_file);
END;