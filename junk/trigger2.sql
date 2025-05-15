CREATE TABLE autentificari (
   nume VARCHAR2(30),
   ora  TIMESTAMP
);

CREATE OR REPLACE TRIGGER check_user
   AFTER LOGON ON DATABASE DECLARE
      v_nume VARCHAR2(30);
   BEGIN
      v_nume := ora_login_user;
      INSERT INTO autentificari VALUES ( v_nume,
                                         CURRENT_TIMESTAMP );
   END;
/