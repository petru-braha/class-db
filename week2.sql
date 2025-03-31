declare
    v_nume studenti.nume%type := '&nume';
     v_prenume studenti.nume%type;
     v_id studenti.id%type;
     min_nota note.valoare%type;
     max_nota note.valoare%type;
    nr number;
begin
    select count(nume) into nr from studenti where nume like v_nume;
    if nr =0 then  DBMS_OUTPUT.PUT_LINE('Nu exista student cu numele '||v_nume);
    else
     DBMS_OUTPUT.PUT_LINE('Sunt '||nr||' studenti cu numele '||v_nume);
     select prenume, id into v_prenume, v_id  from 
        (select prenume, id from studenti where nume like v_nume order by prenume)
    where rownum=1;
     DBMS_OUTPUT.PUT_LINE('Studentul are prenumele '||v_prenume||' si id-ul '||v_id);
     select max(valoare), min(valoare) into max_nota, min_nota from note where id_student=v_id;
      DBMS_OUTPUT.PUT_LINE('Studentul are cea mai mare si cea mai mica nota: '||max_nota||' '||min_nota);
      DBMS_OUTPUT.PUT_LINE(max_nota**min_nota);
    end if;
end;