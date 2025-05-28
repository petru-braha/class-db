------------PACHETUL UTL_FILE-------------------
-- Folosit pentru stocarea direct pe HDD-ul serverului (citirea/scrierea de fisiere).
-- Acest pachet este definit in fisierul utlfile.sql creat de ORACLE la instalarea serverului si,
-- de regula il gasiti la dresa C:\oraclexe\app\oracle\product\11.2.0\server\rdbms\admin 
-- daca ati pastrat locatia de instalare default a serverului Oracle

-- CA SA VA CREATI LOCAL PROPRIILE FISIERE cu informatiile din BD faceti PASII:
1. Va conecatati ca SYS (conn as sysdba ) si dati comanda: 
                GRANT EXECUTE ON UTL_FILE TO STUDENT;
2. Creati un director "D:\STUDENT" pe calculatorul vostru (numele directorului nu este case sensitive)
3. Intrati IAR in contul SYS (cu comanda: conn sys as sysdba) si scrieti comanda: 
                GRANT CREATE ANY DIRECTORY TO STUDENT;  
4. Intrati in contul STUDENT si executati comanda: 
                CREATE OR REPLACE DIRECTORY MYDIR as 'D:\STUDENT';
    -- MYDIR va reprezenta un identificator pentru calea fizica unde vor fi salvate fisierele voastre
5. Intrati IAR in contul SYS si dati comanda: 
                GRANT READ,WRITE ON DIRECTORY MYDIR TO STUDENT;
6. Intrati la final in contul STUDENT si scrieti urmatorul program de test:
 --Scriere in fisier
DECLARE
  v_fisier UTL_FILE.FILE_TYPE;
BEGIN
  v_fisier:=UTL_FILE.FOPEN('MYDIR','myfile.txt','W');
  UTL_FILE.PUTF(v_fisier,'abcdefg');
  UTL_FILE.FCLOSE(v_fisier);
END;
/

7.Ar trebui ca in directorul D:\STUDENT pe calculatorul personal sa se creeze fisierul myfile.txt cu textul sbcdefg

-- Citire din fisier:
set serveroutput on;
DECLARE
  v_fisier UTL_FILE.FILE_TYPE;
  v_sir VARCHAR2(50);
BEGIN
  v_fisier:=UTL_FILE.FOPEN('MYDIR','myfile.txt','R');
  UTL_FILE.GET_LINE(v_fisier,v_sir);
  DBMS_OUTPUT.PUT_LINE(v_sir);
  UTL_FILE.FCLOSE(v_fisier);
END;
/

-- Toate functiile si procedurile pe care le puteti utiliza din UTL_FILE:
DESC UTL_FILE;

/*
functiile FOPEN si IS_OPEN; 
procedurile GET_LINE, PUT, PUT_LINE, PUTF, NEW_LINE, FCLOSE, FCLOSEALL, FFLUSH

Cateva ERORI:
INVALID_PATH - numele sau locatia fisierului sunt invalide;

INVALID_MODE - parametrul OPEN_MODE (prin care se specifica daca fisierul este deschis pentru citire, scriere, adaugare) este invalid;

INVALID_FILEHANDLE - handler-ul de fisier obtinut in urma deschiderii este invalid;

INVALID_OPERATION - operatie invalida asupra fisierului;

READ_ERROR - o eroare a sistemului de operare a aparut in timpul operatiei de citire;

WRITE_ERROR - o eroare a sistemului de operare a aparut in timpul operatiei de scriere;

INTERNAL_ERROR - o eroare nespecificata a aparut in PL/SQL.
*/

-- Documentatie:
https://docs.oracle.com/cd/B19306_01/appdev.102/b14258/u_file.htm#i997577
https://docstore.mik.ua/orelly/oracle/bipack/ch06_02.htm

Indicatii pentru un cod corect :

SCRIERE in fisier:
1. Declarati un file handle: v_fisier UTL_FILE.FILE_TYPE;
2. Deschideti fisierul folosind FOPEN in modul de scriere: v_fisier:=UTL_FILE.FOPEN('MYDIR','fisier.txt','W');
3. Intr-o bucla puneti in fisier date din BD: utl_file.put_line(v_fisier, <info_citite_din_tabele>);
4. Inchideti fisierul cu un apel catre FCLOSE: UTL_FILE.fclose(v_fisier);

 CITIRE din fisier:
1. Declarati un file handle: v_fisier UTL_FILE.FILE_TYPE;
2. Deschideti fisierul folosind FOPEN in modul de citire:v_fisier:=UTL_FILE.FOPEN('MYDIR','fisier.txt','R');
3. Utilizati procedura GET_LINE pentru a citi date din fisier.
Pentru a citi toate liniile dintr-un fisier, trebuie sa executati GET_LINE intr-o bucla.
Daca trebuie populata o tabela atunci linile citite din fisier sunt parsate pentru a obtine fiecare
valoare in parte care vor fi introduse in tabele.
4. Inchideti fisierul cu un apel catre FCLOSE. 

 UTL_FILE.FOPEN('location','filename','openmode')

-- openmode :
--              R - read-only ;
--              W - read and write in replace mode ;
--              A - read and write in append mode ;



