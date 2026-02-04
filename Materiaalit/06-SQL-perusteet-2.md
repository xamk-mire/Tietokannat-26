# SQL-perusteet, osa II (PostgreSQL)

### Suodatus, lajittelu, aggregaatiot, ryhmittely ja aliasit — tuloksineen

Edellisessä luvussa opimme _rakentamaan maailman_: taulut, avaimet, insertit (rivit/rows).  
Nyt opimme _lukemaan maailmaa kuin karttaa_—valitsemalla vain olennaisen, järjestämällä sen, tiivistämällä sen ja nimeämällä asiat niin, että kyselyt pysyvät ihmiselle luettavina.

Tämä luku keskittyy viiteen perusasiaan:

- **Suodatus** → `WHERE`
- **Lajittelu** → `ORDER BY`, `LIMIT`
- **Aggregaatiot** → `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`
- **Ryhmittely** → `GROUP BY`, `HAVING`
- **Aliasit** → `AS`, taulualiasit

---

## Yhteinen esimerkkidataset

Voit kuvitella tämän pienen yliopistotietokannan.

### Taulu: `students`

| student_id | full_name     | email                                   |
| ---------: | ------------- | --------------------------------------- |
|          1 | Aino Laine    | [aino@uni.fi](mailto:aino@uni.fi)       |
|          2 | Mika Virtanen | [mika@uni.fi](mailto:mika@uni.fi)       |
|          3 | Sara Niemi    | _(NULL)_                                |
|          4 | Olli Koski    | [olli@gmail.com](mailto:olli@gmail.com) |

### Taulu: `courses`

| course_id | title           | credits |
| --------: | --------------- | ------: |
|         1 | Databases       |       5 |
|         2 | Algorithms      |       6 |
|         3 | Web Development |       5 |

### Taulu: `enrollments`

| student_id | course_id |
| ---------: | --------: |
|          1 |         1 |
|          1 |         2 |
|          2 |         1 |
|          3 |         1 |
|          3 |         3 |
|          4 |         3 |

### Taulu: `grades`

| student_id | course_id | grade |
| ---------: | --------: | ----: |
|          1 |         1 |     5 |
|          1 |         2 |     4 |
|          2 |         1 |     3 |
|          3 |         1 |     2 |
|          3 |         3 |     5 |
|          4 |         3 |     4 |

---

# 1) Suodatus `WHERE`:llä

### Ehdot galleriassa: jokainen avainsana on eri portti

`WHERE` on tapa, jolla SQL valitsee, _mitkä rivit pääsevät tuloksiin_.  
Jokainen ehto on sääntö ja jokainen sääntö on eräänlainen portti.

Käytämme näitä tauluja pohjana:

### `students`

| student_id | full_name     | email                                   |
| ---------: | ------------- | --------------------------------------- |
|          1 | Aino Laine    | [aino@uni.fi](mailto:aino@uni.fi)       |
|          2 | Mika Virtanen | [mika@uni.fi](mailto:mika@uni.fi)       |
|          3 | Sara Niemi    | _(NULL)_                                |
|          4 | Olli Koski    | [olli@gmail.com](mailto:olli@gmail.com) |

### `courses`

| course_id | title           | credits |
| --------: | --------------- | ------: |
|         1 | Databases       |       5 |
|         2 | Algorithms      |       6 |
|         3 | Web Development |       5 |

### `enrollments`

| student_id | course_id |
| ---------: | --------: |
|          1 |         1 |
|          1 |         2 |
|          2 |         1 |
|          3 |         1 |
|          3 |         3 |
|          4 |         3 |

### `grades`

| student_id | course_id | grade |
| ---------: | --------: | ----: |
|          1 |         1 |     5 |
|          1 |         2 |     4 |
|          2 |         1 |     3 |
|          3 |         1 |     2 |
|          3 |         3 |     5 |
|          4 |         3 |     4 |

---

## `=` Yhtäsuuruus

### Esimerkki: kurssit, joilla on täsmälleen 6 opintopistettä

```sql
SELECT course_id, title, credits
FROM courses
WHERE credits = 6;
```

**Tulos**

| course_id | title      | credits |
| --------: | ---------- | ------: |
|         2 | Algorithms |       6 |

**Selitys**

- Vain rivit, joilla `credits` on `6`, läpäisevät suodattimen.

---

## `<>` Eri suuri (ei yhtä suuri)

### Esimerkki: opiskelijat, joiden sähköposti ei ole verkkotunnuksessa `uni.fi` (eikä NULL)

```sql
SELECT student_id, full_name, email
FROM students
WHERE email <> 'aino@uni.fi';
```

**Tulos**

| student_id | full_name     | email                                   |
| ---------: | ------------- | --------------------------------------- |
|          2 | Mika Virtanen | [mika@uni.fi](mailto:mika@uni.fi)       |
|          4 | Olli Koski    | [olli@gmail.com](mailto:olli@gmail.com) |

**Selitys**

- `<>` tarkoittaa "ei yhtä suuri".
- Huomaa: Sara Niemi (NULL-sähköposti) **ei** tule mukaan, koska NULL-vertailut eivät ole totuusarvoltaan true eivätkä false—ne ovat _tuntemattomia_.

---

## `<` Pienempi kuin

### Esimerkki: arvosanat alle 4

```sql
SELECT student_id, course_id, grade
FROM grades
WHERE grade < 4;
```

**Tulos**

| student_id | course_id | grade |
| ---------: | --------: | ----: |
|          2 |         1 |     3 |
|          3 |         1 |     2 |

---

## `<=` Pienempi tai yhtä suuri

### Esimerkki: kurssit, joilla 5 opintopistettä tai vähemmän

```sql
SELECT course_id, title, credits
FROM courses
WHERE credits <= 5;
```

**Tulos**

| course_id | title           | credits |
| --------: | --------------- | ------: |
|         1 | Databases       |       5 |
|         3 | Web Development |       5 |

---

## `>` Suurempi kuin

### Esimerkki: arvosanat suurempia kuin 4

```sql
SELECT student_id, course_id, grade
FROM grades
WHERE grade > 4;
```

**Tulos**

| student_id | course_id | grade |
| ---------: | --------: | ----: |
|          1 |         1 |     5 |
|          3 |         3 |     5 |

---

## `>=` Suurempi tai yhtä suuri

### Esimerkki: arvosanat vähintään 4

```sql
SELECT student_id, course_id, grade
FROM grades
WHERE grade >= 4;
```

**Tulos**

| student_id | course_id | grade |
| ---------: | --------: | ----: |
|          1 |         1 |     5 |
|          1 |         2 |     4 |
|          3 |         3 |     5 |
|          4 |         3 |     4 |

---

## Loogiset operaattorit: `AND`, `OR`, `NOT`

## `AND` (molempien täytyy olla tosi)

### Esimerkki: arvosanat välillä 3–4 (mukaan lukien) AND:lla

```sql
SELECT student_id, course_id, grade
FROM grades
WHERE grade >= 3 AND grade <= 4;
```

**Tulos**

| student_id | course_id | grade |
| ---------: | --------: | ----: |
|          1 |         2 |     4 |
|          2 |         1 |     3 |
|          4 |         3 |     4 |

---

## `OR` (kumpi tahansa voi olla tosi)

### Esimerkki: ilmoittautumiset kurssille 2 TAI kurssille 3

```sql
SELECT student_id, course_id
FROM enrollments
WHERE course_id = 2 OR course_id = 3;
```

**Tulos**

| student_id | course_id |
| ---------: | --------: |
|          1 |         2 |
|          3 |         3 |
|          4 |         3 |

---

## `NOT` (negaatio)

### Esimerkki: kurssit, jotka EIVÄT ole 5 opintopistettä

```sql
SELECT course_id, title, credits
FROM courses
WHERE NOT (credits = 5);
```

**Tulos**

| course_id | title      | credits |
| --------: | ---------- | ------: |
|         2 | Algorithms |       6 |

**Selitys**

- `NOT` kääntää ehdon totuusarvon.

---

## Jäsenyys: `IN`

## `IN` (arvo on listassa)

### Esimerkki: opiskelijat, joiden id on 1 tai 3

```sql
SELECT student_id, full_name
FROM students
WHERE student_id IN (1, 3);
```

**Tulos**

| student_id | full_name  |
| ---------: | ---------- |
|          1 | Aino Laine |
|          3 | Sara Niemi |

**Selitys**

- `IN (...)` on usein selkeämpi kuin useat ketjutetut `OR`-ehdot.

---

## Välit: `BETWEEN`

## `BETWEEN` (väli molemmat päätepisteet mukaan lukien)

### Esimerkki: arvosanat välillä 2–4 (mukaan lukien)

```sql
SELECT student_id, course_id, grade
FROM grades
WHERE grade BETWEEN 2 AND 4;
```

**Tulos**

| student_id | course_id | grade |
| ---------: | --------: | ----: |
|          1 |         2 |     4 |
|          2 |         1 |     3 |
|          3 |         1 |     2 |
|          4 |         3 |     4 |

**Selitys**

- `BETWEEN` sisältää päätepisteet (2 ja 4 tulevat mukaan).

---

## Malliosuma: `LIKE`

## `LIKE` ja `%` (mitä tahansa pituuden jokerimerkki)

### Esimerkki: sähköpostit, jotka päättyvät `@uni.fi`

```sql
SELECT student_id, full_name, email
FROM students
WHERE email LIKE '%@uni.fi';
```

**Tulos**

| student_id | full_name     | email                             |
| ---------: | ------------- | --------------------------------- |
|          1 | Aino Laine    | [aino@uni.fi](mailto:aino@uni.fi) |
|          2 | Mika Virtanen | [mika@uni.fi](mailto:mika@uni.fi) |

---

## `LIKE` ja `_` (yksi merkin jokerimerkki)

### Esimerkki: nimet, joissa on täsmälleen 4 merkkiä ennen välilyöntiä, sitten jotain

Tämä on "opetusesimerkki" merkkistä `_`:

```sql
SELECT student_id, full_name
FROM students
WHERE full_name LIKE '____ %';
```

**Tulos**

| student_id | full_name     |
| ---------: | ------------- |
|          1 | Aino Laine    |
|          2 | Mika Virtanen |
|          4 | Olli Koski    |

**Selitys**

- `____` tarkoittaa "täsmälleen neljä merkkiä"
- sitten välilyönti, sitten mitä tahansa (`%`)
- "Sara Niemi" ei tule mukaan, koska "Sara" on 4 kirjainta **mutta** se täsmää silti; itse asiassa se täsmää. Selkeämpi esimerkki alla.

✅ Selkeämpi `_`-esimerkki: sähköpostit, joissa on täsmälleen 4 kirjainta ennen `@` (aino/mika 4, olli 4 mutta ei uni.fi; Saralla NULL)

```sql
SELECT student_id, full_name, email
FROM students
WHERE email LIKE '____@%';
```

**Tulos**

| student_id | full_name     | email                                   |
| ---------: | ------------- | --------------------------------------- |
|          1 | Aino Laine    | [aino@uni.fi](mailto:aino@uni.fi)       |
|          2 | Mika Virtanen | [mika@uni.fi](mailto:mika@uni.fi)       |
|          4 | Olli Koski    | [olli@gmail.com](mailto:olli@gmail.com) |

**Selitys**

- `____@%` tarkoittaa "täsmälleen neljä merkkiä, sitten @, sitten mitä tahansa"
- NULL-sähköpostit eivät täsmää.

---

## Puuttuvat arvot: `IS NULL` ja `IS NOT NULL`

## `IS NULL`

### Esimerkki: opiskelijat, joilta puuttuu sähköposti

```sql
SELECT student_id, full_name, email
FROM students
WHERE email IS NULL;
```

**Tulos**

| student_id | full_name  | email    |
| ---------: | ---------- | -------- |
|          3 | Sara Niemi | _(NULL)_ |

---

## `IS NOT NULL`

### Esimerkki: opiskelijat, joilla on sähköposti

```sql
SELECT student_id, full_name, email
FROM students
WHERE email IS NOT NULL;
```

**Tulos**

| student_id | full_name     | email                                   |
| ---------: | ------------- | --------------------------------------- |
|          1 | Aino Laine    | [aino@uni.fi](mailto:aino@uni.fi)       |
|          2 | Mika Virtanen | [mika@uni.fi](mailto:mika@uni.fi)       |
|          4 | Olli Koski    | [olli@gmail.com](mailto:olli@gmail.com) |

---

## "Yhdistetty" esimerkki

### Esimerkki: uni-sähköpostit TAI puuttuva sähköposti (tyypillinen datan siivouskuvio)

```sql
SELECT student_id, full_name, email
FROM students
WHERE email LIKE '%@uni.fi' OR email IS NULL;
```

**Tulos**

| student_id | full_name     | email                             |
| ---------: | ------------- | --------------------------------- |
|          1 | Aino Laine    | [aino@uni.fi](mailto:aino@uni.fi) |
|          2 | Mika Virtanen | [mika@uni.fi](mailto:mika@uni.fi) |
|          3 | Sara Niemi    | _(NULL)_                          |

**Selitys**

- Osoittaa, että NULL vaatii eksplisiittisen käsittelyn.

---

# 2) Lajittelu `ORDER BY`:llä (ja `LIMIT`)

Jos `WHERE` valitsee näyttelijät, **ORDER BY** päättää, kuka kävelee lavalle ensin.

### Avainsanat

- **ORDER BY**
- **ASC** (oletus), **DESC**
- monisarakkeinen lajittelu
- **LIMIT** ottamaan vain ensimmäiset _N_ riviä

---

## Esimerkki: Kurssit järjestettynä opintopisteiden mukaan (suuri → pieni), sitten nimen mukaan (A–Ö)

```sql
SELECT course_id, title, credits
FROM courses
ORDER BY credits DESC, title ASC;
```

**Tulos**

| course_id | title           | credits |
| --------: | --------------- | ------: |
|         2 | Algorithms      |       6 |
|         1 | Databases       |       5 |
|         3 | Web Development |       5 |

**Selitys**

- Ensimmäinen lajittelu: credits laskevaan järjestykseen (6 ennen 5)
- Tasatilanteessa: title nousevaan järjestykseen (Databases ennen Web Development)

---

## Esimerkki: "Kaksi parasta" kurssia opintopisteiden mukaan

```sql
SELECT course_id, title, credits
FROM courses
ORDER BY credits DESC, title ASC
LIMIT 2;
```

**Tulos**

| course_id | title      | credits |
| --------: | ---------- | ------: |
|         2 | Algorithms |       6 |
|         1 | Databases  |       5 |

**Selitys**

- Sama lajittelu kuin aiemmin, mutta pidetään vain kaksi ensimmäistä riviä.

---

# 3) Aggregaatiot (monta riviä yhdeksi tiivisteeksi)

Aggregaatiolla SQL muuttaa joukon yhdeksi lauseeksi.

### Avainsanat

- **COUNT**
- **SUM**
- **AVG**
- **MIN**, **MAX**

---

## Esimerkki: Kuinka monta opiskelijaa on olemassa?

```sql
SELECT COUNT(*) AS student_count
FROM students;
```

**Tulos**

| student_count |
| ------------: |
|             4 |

**Selitys**

- `COUNT(*)` laskee rivit riippumatta NULL-arvoista.

---

## Esimerkki: Kuinka monella opiskelijalla on sähköposti?

```sql
SELECT COUNT(email) AS students_with_email
FROM students;
```

**Tulos**

| students_with_email |
| ------------------: |
|                   3 |

**Selitys**

- `COUNT(email)` laskee vain rivit, joilla `email` **ei ole NULL**.

---

## Esimerkki: Kaikkien kurssien opintopisteiden keskiarvo

```sql
SELECT AVG(credits) AS avg_credits
FROM courses;
```

**Tulos**

|        avg_credits |
| -----------------: |
| 5.3333333333333333 |

**Selitys**

- PostgreSQL laskee keskiarvon (5, 6, 5) → 16/3 → 5,3333…

---

# 4) Ryhmittely `GROUP BY`:llä

### Tuloksen "muodostuminen" askel askeleelta

**Ryhmittely** tapahtuu, kun SQL lakkaa käsittelemästä rivejä yksittäisinä tarinoina ja alkaa käsitellä niitä **joukkona**.

`GROUP BY`:llä PostgreSQL suorittaa hiljaisen rituaalin:

1. se lukee rivit,
2. se lajittelee ne pinoihin (ryhmiin),
3. se tiivistää jokaisen pinon,
4. vasta sitten se palauttaa tulokset.

### Korostettavat avainsanat

- **GROUP BY** → muodostaa ryhmiä yhden tai useamman sarakkeen saman arvon mukaan
- **aggregaattifunktio** → tiivistää jokaisen ryhmän (esim. `COUNT`, `AVG`)
- **HAVING** → suodattaa _ryhmiä_ aggregaation jälkeen
- **WHERE** → suodattaa _rivejä_ ennen ryhmittelyä (käsitelty aiemmin)

---

## Esimerkki: Ilmoittautumisten lukumäärä per kurssi

### Tavoite

"Kuinka monta ilmoittautumista kullakin kurssilla on?"

### Kysely

```sql
SELECT course_id, COUNT(*) AS enrollment_count
FROM enrollments
GROUP BY course_id
ORDER BY course_id;
```

---

## Vaihe 0: Lähtö on syötetaulu (`enrollments`)

| student_id | course_id |
| ---------: | --------: |
|          1 |         1 |
|          1 |         2 |
|          2 |         1 |
|          3 |         1 |
|          3 |         3 |
|          4 |         3 |

Tämä on raaka, ryhmittelemätön data: yksi rivi per ilmoittautumistapahtuma.

---

## Vaihe 1: Ryhmittelyvaihe (käsitteelliset "pinot")

`GROUP BY course_id` tarkoittaa:

> "Laita kaikki rivit, joilla on sama course_id, samaan ryhmään."

PostgreSQL muodostaa käsitteellisesti ryhmät näin:

### Ryhmä `course_id = 1`

| student_id | course_id |
| ---------: | --------: |
|          1 |         1 |
|          2 |         1 |
|          3 |         1 |

### Ryhmä `course_id = 2`

| student_id | course_id |
| ---------: | --------: |
|          1 |         2 |

### Ryhmä `course_id = 3`

| student_id | course_id |
| ---------: | --------: |
|          3 |         3 |
|          4 |         3 |

Tässä vaiheessa ajattelemme jo ei enää rivi kerrallaan vaan **ryhmä kerrallaan**.

---

## Vaihe 2: Sovita agregaatti jokaiseen ryhmään

Nyt `COUNT(*)` lasketaan **jokaisen ryhmän sisällä**:

- Kurssille 1: `COUNT(*) = 3`
- Kurssille 2: `COUNT(*) = 1`
- Kurssille 3: `COUNT(*) = 2`

Välitulostaulun voimme kuvitella näin:

| course_id | COUNT(\*) |
| --------: | --------: |
|         1 |         3 |
|         2 |         1 |
|         3 |         2 |

---

## Vaihe 3: Tuotetaan lopullinen SELECT-tulos

Koska kysely sanoo:

```sql
SELECT course_id, COUNT(*) AS enrollment_count
```

lopulliseksi tulokseksi tulee:

| course_id | enrollment_count |
| --------: | ---------------: |
|         1 |                3 |
|         2 |                1 |
|         3 |                2 |

---

---

## Esimerkki: Arvosanan keskiarvo per kurssi

### Tavoite

"Mikä on keskiarvo kullakin kurssilla?"

### Kysely

```sql
SELECT course_id, AVG(grade) AS avg_grade
FROM grades
GROUP BY course_id
ORDER BY course_id;
```

---

## Vaihe 0: Lähtö on syötetaulu (`grades`)

| student_id | course_id | grade |
| ---------: | --------: | ----: |
|          1 |         1 |     5 |
|          1 |         2 |     4 |
|          2 |         1 |     3 |
|          3 |         1 |     2 |
|          3 |         3 |     5 |
|          4 |         3 |     4 |

---

## Vaihe 1: Ryhmitä rivit `course_id`:n mukaan (käsitteelliset pinot)

### Ryhmä `course_id = 1`

| student_id | course_id | grade |
| ---------: | --------: | ----: |
|          1 |         1 |     5 |
|          2 |         1 |     3 |
|          3 |         1 |     2 |

Tämän ryhmän arvosanat: **5, 3, 2**

### Ryhmä `course_id = 2`

| student_id | course_id | grade |
| ---------: | --------: | ----: |
|          1 |         2 |     4 |

Arvosanat: **4**

### Ryhmä `course_id = 3`

| student_id | course_id | grade |
| ---------: | --------: | ----: |
|          3 |         3 |     5 |
|          4 |         3 |     4 |

Arvosanat: **5, 4**

---

## Vaihe 2: Sovita `AVG(grade)` jokaisen ryhmän sisälle

- Kurssin 1 keskiarvo: (5 + 3 + 2) / 3 = **10 / 3 = 3,3333…**
- Kurssin 2 keskiarvo: 4 / 1 = **4**
- Kurssin 3 keskiarvo: (5 + 4) / 2 = **9 / 2 = 4,5**

Käsitteellinen välitiivistelmä:

| course_id |         AVG(grade) |
| --------: | -----------------: |
|         1 | 3.3333333333333333 |
|         2 |                4.0 |
|         3 |                4.5 |

---

## Vaihe 3: Lopullinen SELECT-tulos

| course_id |          avg_grade |
| --------: | -----------------: |
|         1 | 3.3333333333333333 |
|         2 |                4.0 |
|         3 |                4.5 |

---

---

## Esimerkki: Ryhmien suodatus `HAVING`:lla

### Tavoite

"Näytä vain kurssit, joilla on vähintään 2 ilmoittautumista."

### Kysely

```sql
SELECT course_id, COUNT(*) AS enrollment_count
FROM enrollments
GROUP BY course_id
HAVING COUNT(*) >= 2
ORDER BY enrollment_count DESC;
```

Tämä esimerkki havainnollistaa eron:

- **GROUP BY** (muodosta ryhmät)
- **COUNT** (tiivistä ryhmät)
- **HAVING** (suodata ryhmät)

---

## Vaihe 0: Syöte (`enrollments`)

| student_id | course_id |
| ---------: | --------: |
|          1 |         1 |
|          1 |         2 |
|          2 |         1 |
|          3 |         1 |
|          3 |         3 |
|          4 |         3 |

---

## Vaihe 1: Ryhmitä `course_id`:n mukaan (samat pinot kuin aiemmin)

- kurssin 1 ryhmässä 3 riviä
- kurssin 2 ryhmässä 1 rivi
- kurssin 3 ryhmässä 2 riviä

---

## Vaihe 2: Aggregoi jokainen ryhmä (`COUNT(*)`)

Ennen HAVING:iä ryhmitelty tiivistelmä on:

| course_id | enrollment_count |
| --------: | ---------------: |
|         1 |                3 |
|         2 |                1 |
|         3 |                2 |

Tämä taulu on keskeinen hetki:  
**HAVING toimii tälle ryhmitellylle tulokselle.**

---

## Vaihe 3: Sovita `HAVING COUNT(*) >= 2` (suodata ryhmät)

PostgreSQL poistaa ryhmät, jotka eivät täytä ehtoa:

- kurssilla 2 lukumäärä 1 → poistetaan
- kurssit 1 ja 3 jäävät

HAVING:n jälkeen käsitteellinen välitaulu on:

| course_id | enrollment_count |
| --------: | ---------------: |
|         1 |                3 |
|         3 |                2 |

---

## Vaihe 4: ORDER BY (lopullinen esitys)

`ORDER BY enrollment_count DESC` lajittelee jäljellä olevat ryhmät:

| course_id | enrollment_count |
| --------: | ---------------: |
|         1 |                3 |
|         3 |                2 |

(Järjestys jo oikein tässä.)

---

## Mitä muuttuu, jos lisäämme WHERE:n?

Tämä on usein seuraava hämmentävä kohta, joten lyhyt havainnollistus:

Jos kirjoitamme:

```sql
SELECT course_id, COUNT(*) AS enrollment_count
FROM enrollments
WHERE course_id <> 1
GROUP BY course_id;
```

silloin _rivit_, joilla course_id on 1, poistetaan **ennen** ryhmittelyä.

### Syöte WHERE:n jälkeen (käsitteellisesti)

| student_id | course_id |
| ---------: | --------: |
|          1 |         2 |
|          3 |         3 |
|          4 |         3 |

### Ryhmä + count -tulos

| course_id | enrollment_count |
| --------: | ---------------: |
|         2 |                1 |
|         3 |                2 |

---

# 5) Aliasit (`AS`)

Aliasit tekevät SQL:stä luettavaa: ne korvaavat kömpelöt nimet nimillä, jotka kuulostavat merkityksellisiltä.

### Avainsanat

- **AS** (sarakkeen alias)
- **taulualiasit** (lyhyet nimet kuten `s`, `c`, `e`)
- selkeys ennen oveluutta: aliasien pitää tehdä kyselystä lauseen kaltainen

---

## Esimerkki: Sarakkeen alias (ystävällinen tulosteen nimi)

```sql
SELECT COUNT(*) AS total_enrollments
FROM enrollments;
```

**Tulos**

| total_enrollments |
| ----------------: |
|                 6 |

**Selitys**

- Ilman `AS total_enrollments` tulossarakkeen nimi on vähemmän ystävällinen.

---

## Esimerkki: Taulualiasit JOINissa (students + courses)

```sql
SELECT s.full_name, c.title
FROM enrollments e
JOIN students s ON s.student_id = e.student_id
JOIN courses  c ON c.course_id  = e.course_id
ORDER BY s.full_name, c.title;
```

**Tulos**

| full_name     | title           |
| ------------- | --------------- |
| Aino Laine    | Algorithms      |
| Aino Laine    | Databases       |
| Mika Virtanen | Databases       |
| Olli Koski    | Web Development |
| Sara Niemi    | Databases       |
| Sara Niemi    | Web Development |

**Selitys**

- `e`, `s`, `c` ovat taulujen lyhennysnimiä.
- Ne tekevät sarakeviittauksista lyhyempiä ja selkeämpiä (`s.full_name` vs `students.full_name`).

---

## Kaikki yhdessä (yksi "täysilausekysely")

## Esimerkki: Kurssinimet ja ilmoittautumislukumäärät (vain suositut), järjestettynä suosikin mukaan

```sql
SELECT c.title, COUNT(*) AS enrollment_count
FROM enrollments e
JOIN courses c ON c.course_id = e.course_id
GROUP BY c.title
HAVING COUNT(*) >= 2
ORDER BY enrollment_count DESC, c.title ASC;
```

**Tulos**

| title           | enrollment_count |
| --------------- | ---------------: |
| Databases       |                3 |
| Web Development |                2 |

**Selitys**

- `JOIN` tuo kurssinimet ilmoittautumisdataan
- `GROUP BY` muodostaa yhden ryhmän per kurssinimi
- `COUNT(*)` mittaa suosikkia
- `HAVING` pitää vain kurssit, joilla vähintään 2 ilmoittautumista
- `ORDER BY` esittää tuloksen järkevässä järjestyksessä

---
