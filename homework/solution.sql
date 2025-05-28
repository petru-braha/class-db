   SET SERVEROUTPUT ON;
SET LINESIZE 1000;
SET LONG 1000000;
SET PAGESIZE 0;
SET TRIMSPOOL ON;
SET FEEDBACK OFF;
SET VERIFY OFF;
SPOOL export_script.sql

DECLARE
  -- Variables for storing metadata
   v_table_ddl      CLOB;
   v_constraint_ddl CLOB;
   v_index_ddl      CLOB;
   v_sequence_ddl   CLOB;
   v_trigger_ddl    CLOB;
   v_source_line    VARCHAR2(4000);
   v_prev_line      VARCHAR2(4000);
  
  -- Cursors
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

BEGIN
   DBMS_OUTPUT.PUT_LINE('-- Export generated on ' || TO_CHAR(
      SYSDATE,
      'DD-MON-YYYY HH24:MI:SS'
   ));
   DBMS_OUTPUT.PUT_LINE('SET ECHO OFF;');
   DBMS_OUTPUT.PUT_LINE('SET VERIFY OFF;');
   DBMS_OUTPUT.PUT_LINE('SET FEEDBACK OFF;');
   DBMS_OUTPUT.PUT_LINE('SET SERVEROUTPUT ON;');
   DBMS_OUTPUT.PUT_LINE('WHENEVER SQLERROR EXIT SQL.SQLCODE;');
   DBMS_OUTPUT.PUT_LINE('');
  
  -- Export Tables
   FOR t IN c_tables LOOP
      DBMS_OUTPUT.PUT_LINE('-- Table: ' || t.table_name);
      DBMS_OUTPUT.PUT_LINE('DROP TABLE '
                           || t.table_name
                           || ' CASCADE CONSTRAINTS;');
      DBMS_OUTPUT.PUT_LINE('CREATE TABLE '
                           || t.table_name
                           || ' (');
    
    -- Columns
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

         DBMS_OUTPUT.PUT_LINE(v_table_ddl || ',');
      END LOOP;
    
    -- Remove last comma
      DBMS_OUTPUT.PUT_LINE(RTRIM(
         v_table_ddl,
         ','
      ));
      DBMS_OUTPUT.PUT_LINE(');');
      DBMS_OUTPUT.PUT_LINE('/');
      DBMS_OUTPUT.PUT_LINE('');
    
    -- Constraints
      FOR c IN c_constraints(t.table_name) LOOP
         IF c.constraint_type = 'P' THEN  -- Primary Key
            DBMS_OUTPUT.PUT_LINE('ALTER TABLE '
                                 || t.table_name
                                 || ' ADD CONSTRAINT '
                                 || c.constraint_name
                                 || ' PRIMARY KEY ('
                                 || c.column_name
                                 || ');');
         ELSIF c.constraint_type = 'R' THEN  -- Foreign Key
            DBMS_OUTPUT.PUT_LINE('ALTER TABLE '
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
            DBMS_OUTPUT.PUT_LINE('ALTER TABLE '
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
            DBMS_OUTPUT.PUT_LINE('ALTER TABLE '
                                 || t.table_name
                                 || ' ADD CONSTRAINT '
                                 || c.constraint_name
                                 || ' CHECK ('
                                 || c.search_condition
                                 || ');');
         END IF;
      END LOOP;
      DBMS_OUTPUT.PUT_LINE('/');
      DBMS_OUTPUT.PUT_LINE('');
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
      DBMS_OUTPUT.PUT_LINE(v_index_ddl);
      DBMS_OUTPUT.PUT_LINE('/');
      DBMS_OUTPUT.PUT_LINE('');
   END LOOP;
  
  -- Export Sequences
   FOR s IN c_sequences LOOP
      DBMS_OUTPUT.PUT_LINE('CREATE SEQUENCE ' || s.sequence_name);
      DBMS_OUTPUT.PUT_LINE('  START WITH ' || s.last_number);
      DBMS_OUTPUT.PUT_LINE('  INCREMENT BY ' || s.increment_by);
      DBMS_OUTPUT.PUT_LINE('  MINVALUE ' || s.min_value);
      IF s.max_value < 999999999999999999999999999 THEN
         DBMS_OUTPUT.PUT_LINE('  MAXVALUE ' || s.max_value);
      END IF;
      IF s.cycle_flag = 'Y' THEN
         DBMS_OUTPUT.PUT_LINE('  CYCLE');
      END IF;
      IF s.cache_size = 0 THEN
         DBMS_OUTPUT.PUT_LINE('  NOCACHE;');
      ELSE
         DBMS_OUTPUT.PUT_LINE('  CACHE '
                              || s.cache_size
                              || ';');
      END IF;
      DBMS_OUTPUT.PUT_LINE('/');
      DBMS_OUTPUT.PUT_LINE('');
   END LOOP;
  
  -- Export Triggers
   FOR t IN c_triggers LOOP
      DBMS_OUTPUT.PUT_LINE('CREATE OR REPLACE TRIGGER ' || t.trigger_name);
      DBMS_OUTPUT.PUT_LINE(t.trigger_type
                           || ' '
                           || t.triggering_event);
      DBMS_OUTPUT.PUT_LINE('ON ' || t.table_name);
      IF t.description IS NOT NULL THEN
         DBMS_OUTPUT.PUT_LINE(t.description);
      END IF;
      DBMS_OUTPUT.PUT_LINE('BEGIN');
      DBMS_OUTPUT.PUT_LINE(t.trigger_body);
      DBMS_OUTPUT.PUT_LINE('END;');
      DBMS_OUTPUT.PUT_LINE('/');
      DBMS_OUTPUT.PUT_LINE('');
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
            DBMS_OUTPUT.PUT_LINE('CREATE OR REPLACE '
                                 || s.type
                                 || ' '
                                 || s.name);
         END IF;
      
      -- Output the source code line
         DBMS_OUTPUT.PUT_LINE(s.text);
      
      -- If line ends with '/', add a newline
         IF s.text = '/' THEN
            DBMS_OUTPUT.PUT_LINE('');
         END IF;
         v_prev_line := s.name || s.type;
      END IF;
   END LOOP;

   DBMS_OUTPUT.PUT_LINE('COMMIT;');
   DBMS_OUTPUT.PUT_LINE('/');
   DBMS_OUTPUT.PUT_LINE('EXIT;');
END;
/

SPOOL OFF;