
DROP TABLE booleans CASCADE CONSTRAINTS
\

DROP TABLE problems CASCADE CONSTRAINTS
\

-- course exemple
CREATE TABLE booleans (
    id NUMBER ,
    a NUMBER ,
    b NUMBER ,
    c NUMBER ,
    d NUMBER 
)
\

-- second boolean class
CREATE TABLE problems (
    id_problem NUMBER ,
    c NUMBER ,
    d NUMBER ,
    e NUMBER 
)
\

INSERT INTO booleans VALUES(0, 0, 1, 0, 0);
INSERT INTO booleans VALUES(1, 1, 1, 0, 0);
INSERT INTO booleans VALUES(2, 0, 0, 1, 0);
INSERT INTO booleans VALUES(3, 1, 1, 0, 1);
INSERT INTO booleans VALUES(4, 0, 1, 0, 1);

INSERT INTO problems VALUES(0, 1, 1, 0);
INSERT INTO problems VALUES(1, 1, 1, 1);
INSERT INTO problems VALUES(2, 0, 0, 0);
INSERT INTO problems VALUES(3, 1, 0, 0);
INSERT INTO problems VALUES(4, 1, 0, 1);

--COMMIT;

--DROP TABLE IF EXISTS B,C,A;
-- not in use
--after creating everything, the table remains in the memory of the server
--watch facultate.sql
--@ C:\Users\PETRU\Desktop\db\facultate.sql

-- connect student/STUDENT