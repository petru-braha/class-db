--CREATE OR REPLACE DIRECTORY MYDIR AS 'A:\uni\class-db\junk\UTL';
DECLARE
   v_fisier UTL_FILE.FILE_TYPE;
BEGIN
   v_fisier := UTL_FILE.FOPEN(
      'MYDIR',
      'myfile.txt',
      'W'
   );
   UTL_FILE.PUTF(
      v_fisier,
      'abcdefg'
   );
   UTL_FILE.FCLOSE(v_fisier);
END;