Laborator 1

-- afisam studentii si notele lor

select s.id, nume, prenume, s.an, titlu_curs, valoare from studenti s join note n 
    On s.id=n.id_student join cursuri c ON c.id= n.id_curs
    order by s.id;
    
    
-- prieteni  A - B
select A.id, A.nume, A.prenume, 
       B.id, B.nume, B.prenume

from studenti A join prieteni p  ON A.id = p.id_student1 
                join studenti B  ON B.id = p.id_student2
--where A.id = 1 or B.id=1              
order by A.id;
-----------------------------------------------------------------------

1. Adaugați în script o constrângere care să nu permită unui aceluiași student să aibă două note la aceeași materie. Incercați să adaugați un duplicat; ștergeți constrangerea; încercați să adăugați din nou duplicatul; încercați să puneți din nou constrângerea.

select * from note where id_student = 1025;

alter table note add constraint nota_unica unique (id_student, id_curs);

insert into note (id, id_student, id_curs, valoare, data_notare) values 
(  (select max(id)+1 from note) , 1025, 1, 10, sysdate); 
--generam automat id-ul pentru tabela nota
    
alter table note drop constraint  nota_unica;

-------------------------------------------------------------------------
2. Aflați grupa din facultate care are coeziunea cea mai mare 
(are raportul dintre prieteniile interioare grupei / 
număr de studenți din grupa maxim).

-- prieteniii interioare  A-B  unde A si B din aceeasi grupa

select round ( count(*) / (select count(*) nr_studenti from studenti s where s.an=A.an and s.grupa=A.grupa),4) raport ,  
        A.an, A.grupa
        
from studenti A join prieteni p  ON A.id = p.id_student1 
                join studenti B  ON B.id = p.id_student2
 where A.an = B.an and A.grupa=B.grupa and A.id<>B.id
 group by A.an, A.grupa
 order by raport desc;

/* pentru ca e posibil ca doua grupe sa aiba acelasi nr maxim al coeziunii
atunci nu putem limita nr de inregistrari cu rownum ca sa aflam grupa 
cu cea mai mare coeziune */

--aflam grupa cu raportul cel mai mare prin subselect necorelat

select round ( count(*)/ (select count(*) nr_Studenti from studenti s where s.an=A.an and s.grupa=A.grupa),4) raport ,  
        A.an, A.grupa
        
from studenti A join prieteni p  ON A.id = p.id_student1 
                join studenti B  ON B.id = p.id_student2
 where A.an = B.an and A.grupa=B.grupa and A.id<>B.id
 group by A.an, A.grupa
 having round ( count(*)/ (select count(*) nr_Studenti from studenti s where s.an=A.an and s.grupa=A.grupa),4) = 
  ( 
  select max(round ( count(*)/ (select count(*) nr_Studenti from studenti s where s.an=A.an and s.grupa=A.grupa),4)) raport          
    from studenti A join prieteni p  ON A.id = p.id_student1 
                    join studenti B  ON B.id = p.id_student2
 where A.an = B.an and A.grupa=B.grupa and A.id<>B.id
 group by A.an, A.grupa
 );


------------------------------------------------------------------------
3. Aflați câte dintre prietenii sunt simetrice (dacă A este prieten cu B avem și că B este prieten cu A).


--    A - B si B - A 
-- p1.id_Student1 (A)  - p1.id_student2 (B)
-- p2.id_Student1(B) - p2.id_Student2 (A)
 
select  p1.id_Student1 ||' - '||   p1.id_student2 
from prieteni p1 join prieteni p2 ON 
    p1.id_Student1= p2.id_student2  and
     p2.id_Student1 = p1.id_Student2
;
-- vor aparea ambele perechi A-B si B-A
-- nr lor
select  count(*) /2
from prieteni p1 join prieteni p2 ON 
    p1.id_Student1= p2.id_student2  and
     p2.id_Student1 = p1.id_Student2;

-------------------------------------------------------------------------

4. Adaugați o studenta "Popescu Crina-Nicoleta" și puneți-i nota 10 la materia Baze de date.

insert into studenti (id, nr_matricol, nume, prenume, an, grupa) values
( (select max(id)+1 from studenti), 'AB1000', 'Popescu', 'Crina-Nicoleta', 2, 'A4'  );
describe note;
insert into note (id, id_Student, id_Curs, valoare) values
((select max(id)+1 from note), (select id from studenti where nume like 'Popescu' and prenume like 'Crina-Nicoleta'), 
 (select id from cursuri where titlu_curs like 'Baze de date'), 10 );

--Adaugați două relații de prietenie între Crina și două colege din grupa sa
--primul coleg al crinei
select * from ( 
select id from studenti where (an, grupa) = 
(select an, grupa from studenti where nume like 'Popescu' and prenume like 'Crina-Nicoleta') and 
id != (select id from studenti where nume like 'Popescu' and prenume like 'Crina-Nicoleta') order by id desc
) where rownum <2;

-- al doilea coleg

select id from studenti where (an, grupa) = 
(select an, grupa from studenti where nume like 'Popescu' and prenume like 'Crina-Nicoleta') and 
id != (select id from studenti where nume like 'Popescu' and prenume like 'Crina-Nicoleta') and rownum <2;

--sau o varianta de a afla doua valori odata, dar nu se preteaza la utilizarea in insert unde putem insera o valoare odata
select id, nr from (
select id, rownum nr from ( 
select id from studenti where (an, grupa) = 
(select an, grupa from studenti where nume like 'Popescu' and prenume like 'Crina-Nicoleta') and 
id != (select id from studenti where nume like 'Popescu' and prenume like 'Crina-Nicoleta') order by id desc
) )
where nr in (3, 5);

---adaugare
insert into prieteni (id, id_student1, id_student2) values 
( 
(select max(id)+1 from prieteni),
   
(select id from studenti where nume like 'Popescu' and prenume like 'Crina-Nicoleta'),

(select id from studenti s where (an, grupa) = 
(select an, grupa from studenti s1 where nume like 'Popescu' and prenume like 'Crina-Nicoleta' and s1.id<>s.id) 
and rownum <2)
)
;
--- sau cu max(id) ca sa nu mai facem cu rownum
insert into prieteni (id, id_student1, id_student2) values 
( 
(select max(id)+1 from prieteni),
   
(select id from studenti where nume like 'Popescu' and prenume like 'Crina-Nicoleta'),

(select max(id) from studenti s where (an, grupa) = 
(select an, grupa from studenti s1 where nume like 'Popescu' and prenume like 'Crina-Nicoleta' and s.id<>s1.id) 
)
)
;

-- sau cu min(id) si cu id-ul Nicoletei pe pozitia id_student2 din prieteni
insert into prieteni (id, id_student1, id_student2) values 
( 
(select max(id)+1 from prieteni),
   
(select min(id) from studenti s where (an, grupa) = 
(select an, grupa from studenti s1 where nume like 'Popescu' and prenume like 'Crina-Nicoleta' and s.id<>s1.id) 
),

(select id from studenti where nume like 'Popescu' and prenume like 'Crina-Nicoleta')
)
;


5. Stergeți din baza de date pe una din colegele Crinei care era prietena cu ea 
(pentru că s-a transferat la alta facultate).

/* Pentru a sterge un student din baza de date trebuie sa tinem cont de legaturile deja existente intre tabele
 Acel student posibil ca are alti prieteni la randul sau si de asemenea are note. Asta inseamna ca trebuie 
 sa stergem intai din tabele de legatura (legatura prin cheia straina) si abia apoi din tabela studenti
 
 Ce putem face pe moment este sa aflam cine este prieten cu Popescu Crina-Nicoleta, deoarece am adaugat prietenii
 cu id-uri in mod aleatoriu. */

select c.id from studenti c where (c.id, an, grupa) in 
((select p.id_student2, an, grupa from studenti s join prieteni p on s.id=p.id_Student1 and nume like 'Popescu'
and prenume like 'Crina-Nicoleta') union (select p.id_student1, an, grupa from studenti s join prieteni p 
on s.id=p.id_student2 and nume like 'Popescu' and prenume like 'Crina-Nicoleta')) ;

--Odata aflate aceste id-uri puteti manual sa alegeti un id si sa stergeti din baza de date intai din tabela prieteni
--acele prietenii ale respectivului id cat si din tabela note. Dupa care stergeti studentul din tabela studenti.

6. Afișați studenții care au bursa mai mare de 1350;

select nume, prenume, bursa from studenti where bursa > 1350;

7. Afișati grupa (sau grupele dacă sunt mai multe) cu numarul cel mai mare de resțantieri.

select an, grupa, count(*) nr from studenti s join note n on s.id=n.id_student where valoare =4 
group by an, grupa, s.id
 having count(*) =
 ( select max(count(*)) nr from studenti s join note n on s.id=n.id_student where valoare =4 
group by an, grupa, s.id)
