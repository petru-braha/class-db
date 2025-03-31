DROP TABLE students CASCADE CONSTRAINTS
/
DROP TABLE courses CASCADE CONSTRAINTS
/
DROP TABLE grades CASCADE CONSTRAINTS
/
DROP TABLE profs CASCADE CONSTRAINTS
/
DROP TABLE didactic CASCADE CONSTRAINTS
/

CREATE TABLE students (
  id_stud VARCHAR2(6) NOT NULL,
  lname VARCHAR2(10) NOT NULL,
  fname VARCHAR2(10) NOT NULL,
  year NUMBER(1),
  groupno CHAR(2),
  scholarship NUMBER(6,2),
  dob DATE
)
/

CREATE TABLE courses (
  id_course VARCHAR2(4) PRIMARY KEY,
  course_title VARCHAR2(12) NOT NULL,
  year NUMBER(1),
  sem NUMBER(1),
  credits NUMBER(2)
)
/


CREATE TABLE grades (
  id_stud VARCHAR2(6) NOT NULL,
  id_course VARCHAR2(4) NOT NULL,
  value NUMBER(2),
  grading_date DATE
)
/

CREATE TABLE profs (
  id_prof  VARCHAR2(4) PRIMARY KEY,
  lname VARCHAR2(10) NOT NULL,
  fname VARCHAR2(10) NOT NULL,
  title VARCHAR2(12)
)
/

CREATE TABLE didactic (
  id_prof  VARCHAR2(4),
  id_course  VARCHAR2(4)
)
/


INSERT INTO students VALUES ('111', 'Popescu', 'Bogdan',3, 'A2',NULL, TO_DATE('17/02/1995', 'dd/mm/yyyy'));
INSERT INTO students VALUES ('112', 'Prelipcean', 'Radu',3, 'A2',NULL, TO_DATE('26/05/1995', 'dd/mm/yyyy'));
INSERT INTO students VALUES ('113', 'Antonie', 'Ioana',3, 'A2',450, TO_DATE('3/01/1995', 'dd/mm/yyyy'));
INSERT INTO students VALUES ('114', 'Arhire', 'Raluca',3, 'A4',NULL, TO_DATE('26/12/1995', 'dd/mm/yyyy'));
INSERT INTO students VALUES ('115', 'Panaite', 'Alexandru',3, 'B3',NULL, TO_DATE('13/04/1995', 'dd/mm/yyyy'));


INSERT INTO students VALUES ('116', 'Bodnar', 'Ioana',2, 'A1',NULL, TO_DATE('26/08/1996', 'dd/mm/yyyy'));
INSERT INTO students VALUES ('117', 'Archip', 'Andrada',2, 'A1',350, TO_DATE('03/04/1996', 'dd/mm/yyyy'));
INSERT INTO students VALUES ('118', 'Ciobotariu', 'Ciprian',2, 'A1',350, TO_DATE('03/04/1996', 'dd/mm/yyyy'));
INSERT INTO students VALUES ('119', 'Bodnar', 'Ioana',2, 'B2',NULL, TO_DATE('10/06/1996', 'dd/mm/yyyy'));


INSERT INTO students VALUES ('120', 'Pintescu', 'Andrei',1, 'B1',250, TO_DATE('26/08/1997', 'dd/mm/yyyy'));
INSERT INTO students VALUES ('121', 'Arhire', 'Alexandra',1, 'B1',NULL, TO_DATE('02/07/1997', 'dd/mm/yyyy'));
INSERT INTO students VALUES ('122', 'Cobzaru', 'George',1, 'B1',350, TO_DATE('29/04/1997', 'dd/mm/yyyy'));
INSERT INTO students VALUES ('123', 'Bucur', 'Andreea', 1, 'B2',NULL, TO_DATE('10/05/1997', 'dd/mm/yyyy'));


INSERT INTO courses VALUES ('21', 'Logic', 1, 1, 5);
INSERT INTO courses VALUES ('22', 'Math', 1, 1, 4);
INSERT INTO courses VALUES ('23', 'OOP', 1, 2, 5);
INSERT INTO courses VALUES ('24', 'BD', 2, 1, 8);
INSERT INTO courses VALUES ('25', 'Java', 2, 2, 5);
INSERT INTO courses VALUES ('26', 'Web Tech.', 2, 2, 5);
INSERT INTO courses VALUES ('27', 'Security', 3, 1, 5);
INSERT INTO courses VALUES ('28', 'Arduino', 3, 1, 6);
INSERT INTO courses VALUES ('29', 'Statistics', 2, 1, 5);



INSERT INTO profs VALUES ('p1', 'Masalagiu', 'Cristian', 'Prof');
INSERT INTO profs VALUES ('p2', 'Buraga', 'Sabin', 'Conf');
INSERT INTO profs VALUES ('p3', 'Lucanu', 'Dorel', 'Prof');
INSERT INTO profs VALUES ('p4', 'Tiplea', 'Laurentiu', 'Prof');
INSERT INTO profs VALUES ('p5', 'Iacob', 'Florin', 'Lect');
INSERT INTO profs VALUES ('p6', 'Breaban', 'Mihaela', 'Conf');
INSERT INTO profs VALUES ('p7', 'Varlan', 'Cosmin', 'Lect');
INSERT INTO profs VALUES ('p8', 'Frasinaru', 'Cristian', 'Prof');
INSERT INTO profs VALUES ('p9', 'Ciobaca', 'Stefan', 'Conf');
INSERT INTO profs VALUES ('p10', 'Captarencu', 'Oana', 'Lect');
INSERT INTO profs VALUES ('p11', 'Moruz', 'Alexandru', 'Lect');



INSERT INTO didactic VALUES ('p1','21');
INSERT INTO didactic VALUES ('p9','21');
INSERT INTO didactic VALUES ('p5','22');
INSERT INTO didactic VALUES ('p3','23');
INSERT INTO didactic VALUES ('p6','24');
INSERT INTO didactic VALUES ('p7','24');
INSERT INTO didactic VALUES ('p8','25');
INSERT INTO didactic VALUES ('p2','26');
INSERT INTO didactic VALUES ('p4','27');
INSERT INTO didactic VALUES ('p7','28');


INSERT INTO grades VALUES ('111', '21',  8, TO_DATE('17/02/2014', 'dd/mm/yyyy'));
INSERT INTO grades VALUES ('111', '22',  9, TO_DATE('19/02/2014', 'dd/mm/yyyy'));
INSERT INTO grades VALUES ('111', '23', 10, TO_DATE('24/06/2014', 'dd/mm/yyyy'));
INSERT INTO grades VALUES ('111', '24',  9, TO_DATE('17/02/2015', 'dd/mm/yyyy'));
INSERT INTO grades VALUES ('111', '25',  7, TO_DATE('20/06/2015', 'dd/mm/yyyy'));
INSERT INTO grades VALUES ('111', '26',  8, TO_DATE('21/06/2015', 'dd/mm/yyyy'));

INSERT INTO grades VALUES ('112', '21',  7, TO_DATE('25/02/2014', 'dd/mm/yyyy'));
INSERT INTO grades VALUES ('112', '22',  6, TO_DATE('19/02/2014', 'dd/mm/yyyy'));
INSERT INTO grades VALUES ('112', '23',  5, TO_DATE('24/06/2014', 'dd/mm/yyyy'));
INSERT INTO grades VALUES ('112', '24',  6, TO_DATE('17/02/2015', 'dd/mm/yyyy'));
INSERT INTO grades VALUES ('112', '25',  7, TO_DATE('20/06/2015', 'dd/mm/yyyy'));
INSERT INTO grades VALUES ('112', '26',  4, TO_DATE('21/06/2015', 'dd/mm/yyyy'));

INSERT INTO grades VALUES ('113', '21',  9, TO_DATE('17/02/2014', 'dd/mm/yyyy'));
INSERT INTO grades VALUES ('113', '22',  9, TO_DATE('19/02/2014', 'dd/mm/yyyy'));
INSERT INTO grades VALUES ('113', '23',  7, TO_DATE('24/06/2014', 'dd/mm/yyyy'));
INSERT INTO grades VALUES ('113', '24', 10, TO_DATE('17/02/2015', 'dd/mm/yyyy'));
INSERT INTO grades VALUES ('113', '25',  4, TO_DATE('20/06/2015', 'dd/mm/yyyy'));
INSERT INTO grades VALUES ('113', '26',  7, TO_DATE('21/06/2015', 'dd/mm/yyyy'));

INSERT INTO grades VALUES ('114', '21',  6, TO_DATE('17/02/2014', 'dd/mm/yyyy'));
INSERT INTO grades VALUES ('114', '22',  9, TO_DATE('19/02/2014', 'dd/mm/yyyy'));
INSERT INTO grades VALUES ('114', '23', 10, TO_DATE('24/06/2014', 'dd/mm/yyyy'));
INSERT INTO grades VALUES ('114', '24',  4, TO_DATE('17/02/2015', 'dd/mm/yyyy'));
INSERT INTO grades VALUES ('114', '25',  5, TO_DATE('20/06/2015', 'dd/mm/yyyy'));
INSERT INTO grades VALUES ('114', '26',  4, TO_DATE('21/06/2015', 'dd/mm/yyyy'));

INSERT INTO grades VALUES ('115', '21', 10, TO_DATE('17/02/2014', 'dd/mm/yyyy'));
INSERT INTO grades VALUES ('115', '22',  7, TO_DATE('19/02/2014', 'dd/mm/yyyy'));
INSERT INTO grades VALUES ('115', '23', 10, TO_DATE('24/06/2014', 'dd/mm/yyyy'));
INSERT INTO grades VALUES ('115', '24', 10, TO_DATE('17/02/2015', 'dd/mm/yyyy'));
INSERT INTO grades VALUES ('115', '25',  8, TO_DATE('20/06/2015', 'dd/mm/yyyy'));
INSERT INTO grades VALUES ('115', '26',  9, TO_DATE('21/06/2015', 'dd/mm/yyyy'));


INSERT INTO grades VALUES ('116', '21', 10, TO_DATE('18/02/2015', 'dd/mm/yyyy'));
INSERT INTO grades VALUES ('116', '22', 10, TO_DATE('20/02/2015', 'dd/mm/yyyy'));
INSERT INTO grades VALUES ('116', '23',  9, TO_DATE('21/06/2015', 'dd/mm/yyyy'));

INSERT INTO grades VALUES ('117', '21',  7, TO_DATE('18/02/2015', 'dd/mm/yyyy'));
INSERT INTO grades VALUES ('117', '22',  6, TO_DATE('20/02/2015', 'dd/mm/yyyy'));
INSERT INTO grades VALUES ('117', '23',  4, TO_DATE('25/06/2015', 'dd/mm/yyyy'));

INSERT INTO grades VALUES ('118', '21',  7, TO_DATE('22/02/2015', 'dd/mm/yyyy'));
INSERT INTO grades VALUES ('118', '22',  7, TO_DATE('24/02/2015', 'dd/mm/yyyy'));
INSERT INTO grades VALUES ('118', '23',  7, TO_DATE('21/06/2015', 'dd/mm/yyyy'));

INSERT INTO grades VALUES ('119', '21',  7, TO_DATE('18/02/2015', 'dd/mm/yyyy'));
INSERT INTO grades VALUES ('119', '22',  8, TO_DATE('20/02/2015', 'dd/mm/yyyy'));
INSERT INTO grades VALUES ('119', '23',  9, TO_DATE('21/06/2015', 'dd/mm/yyyy'));


INSERT INTO profs VALUES('p20', 'PASCARIU', 'GEORGIANA', null);
INSERT INTO profs VALUES('p21', 'LAZAR', 'LUCIAN', null);
INSERT INTO profs VALUES('p22', 'Kristo', 'ROBERT', null);

COMMIT;








