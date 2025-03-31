/* Afişaţi studenţii şi notele pe care le-au luat si profesorii care le-au pus acele note.
Afişaţi studenţii care au luat nota 10 la materia 'BD'. Singurele valori pe care aveţi voie să le hardcodaţi în interogare sunt valoarea notei (10) şi numele cursului ('BD').
Afisaţi profesorii (numele şi prenumele) impreuna cu cursurile pe care fiecare le ţine.
Modificaţi interogarea de la punctul 3 pentru a fi afişaţi şi acei profesori care nu au încă alocat un curs.
Modificaţi interogarea de la punctul 3 pentru a fi afişate acele cursuri ce nu au alocate încă un profesor.
Modificaţi interogarea de la punctul 3 astfel încât să fie afişaţi atat profesorii care nu au nici un curs alocat cât şi cursurile care nu sunt încă predate de nici un profesor.
În tabela studenți există studenți care s-au născut în aceeași zi a săptămânii. De exemplu, Cobzaru George și Pintescu Andrei s-au născut amândoi într-o zi de marți. Construiți o listă cu studenții care s-au născut în aceeași zi, grupându-i doi câte doi în ordine alfabetică a numelor (de exemplu, în rezultat va apărea combinația Cobzaru-Pintescu, dar nu va apărea și Pintescu-Cobzaru). Lista va trebui să conțină doar numele de familie a celor doi, împreună cu ziua în care cei doi s-au născut. Evident, dacă există și alți studenți care s-au născut marți, vor apărea și ei în combinație cu cei doi amintiți mai sus. Lista va fi ordonată în funcție de ziua săptămânii în care s-au născut și, în cazul în care sunt mai mult de trei studenți născuți în aceeași zi, rezultatele vor fi ordonate și după numele primei persoane din listă.
Să se afișeze, pentru fiecare student, numele colegilor care au luat notă mai mare ca ei la fiecare dintre cursuri. Formulați rezultatele ca propoziții (de forma "Popescu Gigel a luat notă mai mare ca Vasilescu Ionel la materia BD."). Dați un nume corespunzător coloanei [pont: interogarea trebuie să returneze 118 rânduri].
Afișați studenții doi câte doi împreună cu diferența de vârstă dintre ei. Sortați în ordine crescătoare în funcție de aceste diferențe. Aveți grijă să nu comparați un student cu el însuși.
Afișați posibilele prietenii dintre studenți și profesori. Un profesor și un student se pot împrieteni dacă numele lor de familie are același număr de litere.
Afișați denumirile cursurilor la care s-au pus note cel mult egale cu 8 (<=8).
Afișați numele studenților care au toate notele mai mari ca 7 sau egale cu 7.
Să se afișeze studenții care au luat nota 7 sau nota 10 la OOP într-o zi de marți.
O sesiune este identificată prin luna și anul în care a fost ținută. Scrieți numele și prenumele studenților ce au promovat o anumită materie, cu notele luate de aceștia și sesiunea în care a fost promovată materia. Formatul ce identifică sesiunea este "LUNA, AN", fără alte spații suplimentare (De ex. "JUNE, 2015" sau "FEBRUARY, 2014"). În cazul în care luna în care s-a ținut sesiunea a avut mai puțin de 30 de zile, afișați simbolul "+" pe o coloană suplimentară, indicând faptul că acea sesiune a fost mai grea (având mai puține zile), în caz contrar (când luna are mai mult de 29 de zile) valoarea coloanei va fi null.*/

-- 1
SELECT s.nume, s.prenume, valoare, p.nume, p.prenume 
FROM studenti s 
    JOIN note n ON s.nr_matricol = n.nr_matricol 
    JOIN didactic d ON n.id_curs = d.id_curs 
    JOIN profesori p ON d.id_prof = p.id_prof;

-- 2
SELECT s.nume, s.prenume
FROM studenti s
    JOIN note n ON s.nr_matricol = n.nr_matricol
    JOIN cursuri c ON n.id_curs = c.id_curs
    WHERE n.valoare = 10 AND UPPER(c.titlu_curs) = 'BD';

-- 3
SELECT prof.nume, prof.prenume, course.titlu_curs FROM profesori prof
    JOIN didactic d ON d.id_prof = prof.id_prof
    JOIN cursuri course ON d.id_curs = course.id_curs; 

-- 4
SELECT prof.nume, prof.prenume, course.titlu_curs FROM profesori prof
    LEFT OUTER JOIN didactic d ON d.id_prof = prof.id_prof
    LEFT OUTER JOIN cursuri course ON d.id_curs = course.id_curs;

-- 5 
SELECT p.nume, p.prenume, c.titlu_curs 
    FROM profesori p 
    RIGHT OUTER JOIN didactic d ON p.id_prof = d.id_prof RIGHT OUTER JOIN cursuri c ON d.id_curs = c.id_curs;

SELECT titlu_curs FROM cursuri MINUS SELECT c.titlu_curs FROM cursuri c
    JOIN didactic d ON d.id_curs = c.id_curs
    JOIN profesori prof ON d.id_prof = prof.id_prof;

-- 6
-- 7
-- 8
SELECT
    s1.nume || ' ' || s1.prenume || ' a luat notă mai mare ca ' || s2.nume || ' ' || s2.prenume ||
    ' la materia ' || c.titlu_curs"nume sugestiv"
    FROM studenti s1
        JOIN note g1 ON g1.nr_matricol = s1.nr_matricol
        JOIN cursuri c ON g1.id_curs = c.id_curs
        JOIN studenti s2 ON 
            s2.nr_matricol != s1.nr_matricol AND s1.grupa = s2.grupa
        JOIN note g2 ON 
            g2.nr_matricol = s2.nr_matricol AND g1.valoare > g2.valoare;

-- 9
-- 10
SELECT s.nume || ' ' || s.prenume"nume student", p.nume || ' ' || p.prenume"profesor prieten" 
    FROM studenti s
        JOIN profesori p ON LENGTH(TRIM(p.nume)) = LENGTH(s.nume);

-- 10 v2
SELECT s.prenume, p.prenume 
    FROM studenti s
        JOIN profesori p ON LENGTH(s.nume) = LENGTH(TRIM(p.nume));

-- 12
SELECT nume, prenume
    FROM studenti s
        JOIN note n ON n.valoare >= 7 AND n.nr_matricol = s.nr_matricol
        MINUS SELECT nume, prenume FROM studenti s
            JOIN note n ON n.valoare < 7 AND n.nr_matricol = s.nr_matricol; 

-- 13
SELECT s.nume, s.prenume
    FROM studenti s
        JOIN note n ON 
            n.valoare = 7 OR n.valoare = 10 AND 
            n.nr_matricol = s.nr_matricol AND 
            n.data_notare = marti
        JOIN cursuri c ON 
            cursuri.id_curs = n.id_curs AND 
            UPPER(c.titlu_curs) = 'OOP'
    MINUS SELECT s.nume, s.prenume FROM studenti s
        JOIN note n ON 
            n.valoare != 7 AND n.valoare != 10 AND 
            n.nr_matricol = s.nr_matricol OR 
            n.data_notare != marti
        JOIN cursuri c ON 
            cursuri.id_curs = n.id_curs AND 
            UPPER(c.titlu_curs) = 'OOP';


SELECT nume, an, grupa FROM studenti WHERE an = 2 
MINUS
SELECT nume, an, grupa FROM studenti WHERE an = 3;