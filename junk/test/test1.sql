   SET SERVEROUTPUT ON;

/*
Creați un bloc anonim în care pentru fiecare profesor în parte aflați care este procentul (%) de studenți restanțieri din totalul de studenți la care acei profesori au pus note

Calculați procentul cu o singura zecimală.

De exemplu, un profesor a pus note la 1025 de studenți în total, dintre care 162 sunt restanțieri deci
procentul de restanțieri este de 15.8%. 

În funcție de valoarea acestui procent vom codifica în baza de date care profesor este mai exigent
asociind la gradul didactic o cifră de la 1 la 3 unde 1 este foarte exigent si 3 mai permisiv.
- daca procentul este mai mic de 14.5 atunci adăugați la coloana grad_didactic, la final, cifra 3(permisiv)
- daca procentul este între 14.6 și 16 atunci adăugați la coloana grad_didactic, la final, cifra 2(așa și asa :) )
- dacă procentul este peste 16 atunci adăugați la coloana grad_didactic, la final, cifra 1 (exigent)
Exemplu:  în baza de date ar trebui să apară Lector1 sau Colaborator3 sau Profesor2, etc.

Atenție, dacă un profesor nu predă niciun curs, atunci afișați un mesaj corespunzător împreună cu 
id-ul, numele și prenumele acelui profesor.
Obligatoriu se va utiliza un cursor ce permite update-ul informațiilor.

Apoi creați un al doilea bloc anonim în care să citiți de la tastatură o valoare între 1 și 3 și
în funcție de această valoare afișați, câți profesori au adăugat la final de grad didactic acea valoare
și care sunt acei profesori cu id-ul lor, numele și prenumele lor și gradul lor didactic.
Exemplu:  Sunt 3 profesori cu codificarea 1. Acestia sunt:
            id1 Nume 1 prenume 1 Grad_didactic1 
            ... etc
*/

/*
    - student are nota sub 5
    - note.valoare
    - note.id_curs
    - didactic.id_curs
    - didactic.id_profesor
    
    for(prof)
        i = 0, j = 0;
        for(curs)
            for(stud in curs)
                j++;
                if(nota < 5)
                    i++;
        p = i / j;
        if(p < 14.5)
            concat 3
        else if (p >= 14.6 && p < 16)
            concat 2
        else
            concat 1
            
        if(count course)
            print percent
        else
            print id, nume, prenume, nu are cursuri
*/

DECLARE
   CURSOR arr_prof IS
   SELECT *
     FROM profesori;
   it_prof             arr_prof%ROWTYPE;
   v_id_prof           profeori.id%TYPE := 0;
   CURSOR arr_curs IS
   SELECT *
     FROM cursuri c
     JOIN didactic d
   ON c.id = d.id_curs
     JOIN profesori p
   ON d.id_profesor = p.id
    WHERE p.id = v_id_prof;
   it_curs             arr_curs%ROWTYPE;
   v_id_curs           cursuri.id%TYPE := 0;
   CURSOR arr_note IS
   SELECT *
     FROM note n
     JOIN cursuri c
   ON n.id_curs = c.id
    WHERE c.id = v_id_curs;
   it_note             arr_note%ROWTYPE;
   v_count_restantieri INTEGER := 0;
   v_count_studenti    INTEGER := 0;
   v_procent           NUMBER(
      38,
      1
   ) := 0;
BEGIN
   FOR it_prof IN arr_prof LOOP
      v_count_restantieri := 0;
      v_count_studenti := 0;
      v_id_prof := it_prof.id;
      FOR it_curs IN arr_curs LOOP
         v_id_prof := it_prof.id;
         FOR it_note IN arr_note LOOP
            v_count_studenti := v_count_studenti + 1;
            IF ( it_note.valoare < 5 ) THEN
               v_count_restantieri := v_count_restantieri + 1;
            END IF;
         END LOOP;

      END LOOP;

      v_procent := v_count_restantieri / v_count_studenti;
        /* if cases */

   END LOOP;

   SELECT DISTINCT COUNT(*)
     INTO v_count_restantieri
     FROM profesori p
     JOIN didactic d
   ON p.id = d.id_profesor
     JOIN note n
   ON n.id_curs = d.id_curs
     JOIN studenti s
   ON s.id = n.id_student
    WHERE n.valoare IS NOT NULL
      AND n.valoare < 5;

   SELECT DISTINCT COUNT(*)
     INTO v_count_trecuti
     FROM profesori p
     JOIN didactic d
   ON p.id = d.id_profesor
     JOIN note n
   ON n.id_curs = d.id_curs
     JOIN studenti s
   ON s.id = n.id_student
    WHERE n.valoare IS NOT NULL;

   v_procent := v_count_restantieri / v_count_trecuti;
   dbms_output.put_line(v_count_restantieri
                        || ' '
                        || v_count_trecuti);
   dbms_output.put_line(v_procent);
   UPDATE profesori
      SET
      grad_didactic = grad_didactic || 3
    WHERE v_procent < 14.5;
   UPDATE profesori
      SET
      grad_didactic = grad_didactic || 2
    WHERE v_procent >= 14.6
      AND v_procent < 16;
   UPDATE profesori
      SET
      grad_didactic = grad_didactic || 1
    WHERE v_procent >= 16;

END;