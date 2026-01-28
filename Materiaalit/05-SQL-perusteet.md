

# SQL PostgreSQL:ssä 

Edellisissä [materiaaleissa](04-PostgreSQL.md) PostgreSQL esiteltiin **huolellisesti hallittuna tiedon kaupunkina** —
paikkana, jossa dataa ei ainoastaan tallenneta, vaan sitä myös **suojellaan**, **rakennetaan** ja **pidetään johdonmukaisena**.

Nyt opimme kielen, jolla tuo kaupunki rakennetaan.

SQL ei ole vain työkalu kysymysten esittämiseen.
Alussa se on työkalu **perustusten luomiseen**:

* taulujen muotoiluun,
* sääntöjen määrittämiseen,
* ensimmäisten datarivien lisäämiseen,
* ja yksinkertaisimpien kyselyjen avaamiseen.

Tämä luento keskittyy kolmeen olennaiseen taitoon:

* **Taulujen luominen (Creating tables, DDL)**
* **Datan lisääminen (Inserting data, DML)**
* **Perus-SELECT (Basic SELECT)** (olemassa olevan lukeminen)

Mitään muuta ei tarvita ensimmäisen toimivan tietokannan rakentamiseen.

---

## 1) Mitä SQL on PostgreSQL:ssä 

SQL (**Structured Query Language**) on standardikieli, jota käytetään PostgreSQL:n kanssa kommunikointiin.

Sen avulla voimme kuvata *rakennetta* ja *toimintaa* selkeästi:

* **Rakenne (Structure)**: ”Miltä data näyttää?”
* **Toiminta (Action)**: ”Mitä tietokannan tulisi tallentaa?”
* **Lukeminen (Reading)**: ”Näytä, mitä taulussa on.”

PostgreSQL:ssä SQL-lauseet (statements) suoritetaan yksi kerrallaan, kuin huolellisesti kirjoitetut komennot.

### Keskeiset SQL-käsitteet 

* **Lause (Statement)** → yksi täydellinen käsky, joka päättyy merkkiin `;`
* **Avainsana (Keyword)** → komentosanat kuten `CREATE`, `INSERT`, `SELECT`
* **Tunniste (Identifier)** → taulujen ja sarakkeiden nimet
* **Literaali (Literal)** → todelliset arvot, kuten `'Aino'` tai `5`

---

## 2) Taulujen luominen: maailman rakenteen kirjoittaminen

Tietokanta alkaa tyhjänä — kuin vihko ilman viivoja.
Taulut ovat viivat. Rakenne. Järjestyksen lupaus.

Taulun luomiseksi PostgreSQL:ssä käytämme:

* **CREATE TABLE**
* sarakemäärittelyjä (column definitions)
* rajoitteita (constraints), jotka valvovat oikeellisuutta

### CREATE TABLE -lauseen yleinen muoto

```sql
CREATE TABLE table_name (
  column_name data_type constraints,
  ...
);
```

### Tärkeät muistettavat asiat

* Taulujen ja sarakkeiden nimet kirjoitetaan usein **snake_case**-muodossa
  * `student_id`, `full_name`, `created_at`
* PostgreSQL käsittelee lainausmerkitsemättömät nimet oletuksena pienikirjaimisina
* Jokaisella taululla tulisi olla **pääavain (primary key)**
* Sarakkeiden tulisi käyttää merkityksellisiä tietotyyppejä ja rajoitteita

---

### Esimerkki 1: `students`-taulun luominen (PostgreSQL)

```sql
CREATE TABLE students (
  student_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  full_name  VARCHAR(100) NOT NULL,
  email      VARCHAR(255) UNIQUE
);
```

#### Selitys (mitä kukin osa tarkoittaa)

* **student_id**

  * `INTEGER` → kokonaisluku
  * `GENERATED ALWAYS AS IDENTITY` → PostgreSQL luo arvon automaattisesti
  * `PRIMARY KEY` → yksilöi jokaisen opiskelijan

* **full_name**

  * teksti, enintään 100 merkkiä
  * `NOT NULL` → jokaisella opiskelijalla on oltava nimi

* **email**

  * teksti, enintään 255 merkkiä
  * `UNIQUE` → kahdella opiskelijalla ei saa olla samaa sähköpostia

✅ Tämä taulu tallentaa:

* identiteetin (**PRIMARY KEY**)
* pakolliset arvot (**NOT NULL**)
* yksikäsitteisyyden (**UNIQUE**)

---

## 3) Toisen taulun luominen: uusi käsite astuu mukaan

Hyvin suunniteltu tietokanta kasvaa yksi käsite kerrallaan.

Tässä esittelemme **kurssit (courses)**.

### Esimerkki 2: `courses`-taulun luominen

```sql
CREATE TABLE courses (
  course_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  title     VARCHAR(200) NOT NULL,
  credits   INTEGER NOT NULL CHECK (credits BETWEEN 1 AND 20)
);
```

#### Selitys

* **course_id** on kurssin identiteetti
* **title** on pakollinen teksti
* **credits** on oltava olemassa ja sen on oltava välillä 1–20

`CHECK`-rajoite on PostgreSQL:n tapa valvoa merkitystä:

> ”Opintopisteet eivät ole vain numeroita — ne ovat *järkeviä numeroita*.”

---

## 4) Suhteet taulujen luonnissa 

*(Valinnainen mutta luonnollinen)*

Jo varhaisessa vaiheessa aloittelijat kohtaavat tauluja, jotka viittaavat toisiinsa.

Selkein aloittelijaesimerkki on **liitostaulu (junction table)**, joka yhdistää opiskelijat ja kurssit.

### Esimerkki 3: `enrollments`-taulun luominen (kahden taulun yhdistäminen)

```sql
CREATE TABLE enrollments (
  student_id INTEGER NOT NULL REFERENCES students(student_id),
  course_id  INTEGER NOT NULL REFERENCES courses(course_id),
  PRIMARY KEY (student_id, course_id)
);
```

#### Mitä tämä opettaa

* **REFERENCES** luo viiteavaimen (foreign key)
* PostgreSQL varmistaa, että viitatut rivit ovat olemassa
* yhdistelmäpääavain (composite primary key) estää tuplailmoittautumiset

Tämä taulu ei kuvaa opiskelijaa eikä kurssia.
Se kuvaa *suhdetta*:

> ”Tämä opiskelija on ilmoittautunut tälle kurssille.”

---

## 5) Datan lisääminen: taulujen täyttäminen elämällä

(Inserting Data)

Taulut ovat rakennetta.
Mutta tietokanta ilman dataa on kuin museo, jonka salit ovat tyhjiä.

Rivien lisäämiseen käytämme **INSERT INTO**.

### INSERT-lauseen yleinen muoto

```sql
INSERT INTO table_name (column1, column2, ...)
VALUES (value1, value2, ...);
```

### Tärkeät lisäyssäännöt

* arvojen on vastattava lueteltujen sarakkeiden järjestystä
* tekstiarvot käyttävät **yksinkertaisia lainausmerkkejä**

  * `'Aino Laine'`
* identity-sarakkeet (kuten `student_id`) jätetään yleensä pois

  * PostgreSQL luo ne automaattisesti

---

### Esimerkki 4: Opiskelijoiden lisääminen

```sql
INSERT INTO students (full_name, email)
VALUES
  ('Aino Laine', 'aino@uni.fi'),
  ('Mika Virtanen', 'mika@uni.fi');
```

#### Selitys

* Lisäämme kaksi riviä kerralla
* `student_id` ei ole mukana → PostgreSQL täyttää sen automaattisesti
* full_name ja email tallennetaan annettuina

---

### Esimerkki 5: Kurssien lisääminen

```sql
INSERT INTO courses (title, credits)
VALUES
  ('Databases', 5),
  ('Algorithms', 6);
```

Jälleen, course_id-arvot luodaan automaattisesti.

---

### Esimerkki 6: Ilmoittautumisten lisääminen

```sql
INSERT INTO enrollments (student_id, course_id)
VALUES
  (1, 1),
  (2, 1);
```

#### Selitys

Tämä olettaa, että:

* opiskelija, jolla on `student_id = 1`, on olemassa
* kurssi, jolla on `course_id = 1`, on olemassa

Jos yrität lisätä ilmoittautumisen tunnisteilla, joita ei ole olemassa, PostgreSQL hylkää sen, koska viiteavaimet pakottavat todellisuuden:

> ”Et voi ilmoittaa opiskelijaa, jota ei ole olemassa.”

---

## 6) Perus-SELECT: olemassa olevan lukeminen

(Basic SELECT)

Tietokantaa ei ole tarkoitettu vain kirjoitettavaksi ja unohdettavaksi.
Sinun täytyy pystyä katsomaan sen sisälle.

Yksinkertaisin tapa on **SELECT**.

### SELECT-lauseen yleinen muoto

```sql
SELECT column1, column2, ...
FROM table_name;
```

Tässä vaiheessa SELECT:iä käytetään:

* varmistamaan, että data on olemassa
* tarkastelemaan taulun sisältöä
* vahvistamaan INSERT-lauseiden tulokset

---

### Esimerkki 7: Kaikkien opiskelijoiden näyttäminen

```sql
SELECT * FROM students;
```

#### Selitys

* `*` tarkoittaa ”kaikki sarakkeet”
* palauttaa jokaisen rivin taulusta

Tämä on täydellinen varhaisessa oppimisessa ja virheiden etsinnässä.

---

### Esimerkki 8: Tiettyjen sarakkeiden näyttäminen

```sql
SELECT full_name, email
FROM students;
```

#### Selitys

Tämä näyttää vain luetellut tiedot:

* opiskelijoiden nimet
* opiskelijoiden sähköpostit

Se opettaa tärkeän tavan:

> Vain tarvittavien sarakkeiden valitseminen tekee tarkoituksestasi selkeämmän.

---

### Esimerkki 9: Kaikkien kurssien näyttäminen

```sql
SELECT * FROM courses;
```

---

### Esimerkki 10: Ilmoittautumisten näyttäminen

```sql
SELECT * FROM enrollments;
```

Jo ilman edistyneempää kyselyä tämä paljastaa suhteita ID-arvojen kautta.

---

## 7) Täydellinen ”ensimmäinen SQL-istunto” -skripti (PostgreSQL)

Tämä skripti on tarkoituksella yksinkertainen:

* luo rakenteen
* lisää dataa
* lukee datan takaisin

```sql
CREATE TABLE students (
  student_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  full_name  VARCHAR(100) NOT NULL,
  email      VARCHAR(255) UNIQUE
);

CREATE TABLE courses (
  course_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  title     VARCHAR(200) NOT NULL,
  credits   INTEGER NOT NULL CHECK (credits BETWEEN 1 AND 20)
);

CREATE TABLE enrollments (
  student_id INTEGER NOT NULL REFERENCES students(student_id),
  course_id  INTEGER NOT NULL REFERENCES courses(course_id),
  PRIMARY KEY (student_id, course_id)
);

INSERT INTO students (full_name, email)
VALUES
  ('Aino Laine', 'aino@uni.fi'),
  ('Mika Virtanen', 'mika@uni.fi');

INSERT INTO courses (title, credits)
VALUES
  ('Databases', 5),
  ('Algorithms', 6);

INSERT INTO enrollments (student_id, course_id)
VALUES
  (1, 1),
  (2, 1);

SELECT * FROM students;
SELECT * FROM courses;
SELECT * FROM enrollments;
```

