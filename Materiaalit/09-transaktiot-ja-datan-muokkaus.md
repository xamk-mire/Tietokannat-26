# Transaktiot ja datan muokkaus

### UPDATE, DELETE, transaktiot, ACID ja eristys

[Materiaaleissa 05](Materiaalit/05-SQL-perusteet.md)–[07](Materiaalit/07-SQL-perusteet-3.md) käytimme `INSERT`- ja `SELECT`-lauseita datan lisäämiseen ja lukemiseen.  
[Materiaalissa 08](Materiaalit/08-normalisointi-ja-skeeman-laatu.md) käsittelimme skeeman laatua ja normalisointia.

Tässä luvussa keskitytään **datan muuttamiseen ja poistamiseen** sekä **muutosten soveltamisen hallintaan**:

- **UPDATE ja DELETE** — rivien muuttaminen ja poistaminen
- **Transaktiot** — lauseiden ryhmittäminen niin, että ne joko onnistuvat tai epäonnistuvat yhdessä
- **ACID-ominaisuudet** — mitä tietokanta takaaa
- **Rollbackit** — transaktion sisällä tehdyn työn peruuttaminen

Tämä luku käyttää samaa **yliopistotietokantaa** kuin [Materiaalit 05](Materiaalit/05-SQL-perusteet.md)–[07](Materiaalit/07-SQL-perusteet-3.md): `students`, `courses`, `enrollments`, `grades`, `teachers`.

---

## Yhteinen esimerkkikaavio (muistutus)

### Taulu: `students`

| student_id | full_name     | email          |
| ---------: | ------------- | -------------- |
|          1 | Aino Laine    | aino@uni.fi    |
|          2 | Mika Virtanen | mika@uni.fi    |
|          3 | Sara Niemi    | _(NULL)_       |
|          4 | Olli Koski    | olli@gmail.com |

### Taulu: `teachers`

| teacher_id | full_name      | email        |
| ---------: | -------------- | ------------ |
|          1 | Liisa Korhonen | liisa@uni.fi |
|          2 | Pekka Salo     | pekka@uni.fi |
|          3 | Maria Lind     | maria@uni.fi |

### Taulu: `courses`

| course_id | title           | credits | teacher_id |
| --------: | --------------- | ------: | ---------: |
|         1 | Databases       |       5 |          1 |
|         2 | Algorithms      |       6 |          2 |
|         3 | Web Development |       5 |          3 |

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

# 1) UPDATE ja DELETE

`INSERT`- ja `SELECT`-lauseiden lisäksi tärkeimmät datan muokkauslauseet ovat **UPDATE** (muuta olemassa olevia rivejä) ja **DELETE** (poista rivejä). Molemmat käyttävät **WHERE**-ehtoa valitsemaan, mitkä rivit kohdistuvat.

---

## UPDATE — Muuta olemassa olevia rivejä

**Syntaksi (yksinkertaistettu):**

```sql
UPDATE table_name
SET column1 = value1, column2 = value2, ...
WHERE condition;
```

- **SET** — Mitkä sarakkeet muutetaan ja millä arvoilla.
- **WHERE** — Mitkä rivit päivitetään. **Jos WHERE jätetään pois, päivitetään taulun jokainen rivi.**

### Esimerkki: Päivitä yhden opiskelijan sähköposti

```sql
UPDATE students
SET email = 'aino.new@uni.fi'
WHERE student_id = 1;
```

Vain ehdon täyttävät rivit muuttuvat. Käytä mahdollisen mukaan yksilöllistä tunnistetta (esim. `student_id`), jotta et vahingossa päivitä useaa riviä.

### Esimerkki: Päivitä useita rivejä

```sql
UPDATE courses
SET credits = credits + 1
WHERE teacher_id = 1;
```

Tässä jokainen opettajan 1 kurssi saa yhden opintopisteen lisää (esim. opetussuunnitelman muutoksen jälkeen).

### Turvallisuusvinkki

Tarkista aina **kuinka monta riviä** ehtosi koskee ennen päivitystä. Voit ajaa ensin `SELECT`-kyselyn samalla `WHERE`-ehdolla:

```sql
-- Ensin: katso mitkä rivit päivittyisivät
SELECT * FROM students WHERE student_id = 1;

-- Sitten: aja UPDATE
UPDATE students SET email = 'aino.new@uni.fi' WHERE student_id = 1;
```

PostgreSQLissa voit käyttää `UPDATE ... RETURNING *` nähdäksesi päivitetyt rivit lauseen jälkeen.

---

## DELETE — Poista rivejä

**Syntaksi (yksinkertaistettu):**

```sql
DELETE FROM table_name
WHERE condition;
```

- **WHERE** — Mitkä rivit poistetaan. **Jos WHERE jätetään pois tai poistetaan, poistetaan taulun jokainen rivi.**

### Esimerkki: Poista yksi ilmoittautuminen

```sql
DELETE FROM enrollments
WHERE student_id = 3 AND course_id = 1;
```

### Esimerkki: Poista kaikki opiskelijan ilmoittautumiset

```sql
DELETE FROM enrollments
WHERE student_id = 4;
```

(Jos taululla `grades` on `ON DELETE CASCADE`, tietokanta voi poistaa myös liittyvät arvosanarivit, jos suunnittelu linkittää ne niin; tyypillisesti poistat ensin `grades`-taulusta tai käytät rajoitteita kuten [Materiaalissa 07](07-SQL-fundamentals-3.md).)

### Turvallisuusvinkki

Sama kuin UPDATElla: aja ensin `SELECT` samalla `WHERE`-ehdolla nähdäksesi mitkä rivit poistuisivat. PostgreSQLissa `DELETE ... RETURNING *` näyttää poistetut rivit.

---

## Yhteenveto: UPDATE ja DELETE

| Lause      | Tarkoitus            | Vaara ilman WHERE          |
| ---------- | -------------------- | -------------------------- |
| **UPDATE** | Sarakearvojen muutos | Päivittää **kaikki** rivit |
| **DELETE** | Rivien poisto        | Poistaa **kaikki** rivit   |

Käytä aina tarkkaa `WHERE`-ehtoa (mieluummin pääavaimella tai yksilöllisellä sarakkeella), ellet todella tarkoita kohdistaa muutosta koko tauluun.

---

# 2) Transaktiot

**Transaktio** on yhden tai useamman SQL-lauseen ryhmä, jota tietokanta käsittelee **yhtenä työn yksikkönä**: joko **kaikki** niistä tapahtuvat, tai **yhtään** ei.

---

## Miksi transaktiot ovat tärkeitä

Ilman transaktioita voi käydä niin, että yksi lause onnistuu ja seuraava epäonnistuu, ja työ jää puolitiehen (esim. opiskelija ilmoittautuu kurssille mutta arvosanariviä ei luoda). Transaktioiden avulla voit:

- **Commit** — tehdä transaktion kaikista muutoksista pysyviä.
- **Rollback** — perua transaktion kaikki muutokset, ikään kuin niitä ei olisi tehty.

---

## Eksplisiittiset transaktiot PostgreSQLissa

Transaktiota hallitaan näin:

- **BEGIN** (tai **START TRANSACTION**) — aloita uusi transaktio.
- **COMMIT** — päättää transaktion ja tekee kaikista muutoksista pysyviä.
- **ROLLBACK** — päättää transaktion ja hylkää kaikki muutokset.

Kaikki `BEGIN`:in ja `COMMIT`:in (tai `ROLLBACK`:in) välissä kuuluu yhteen transaktioon.

### Esimerkki: Kaksi päivitystä, joiden on tapahduttava yhdessä

Oletetaan, että haluamme vaihtaa kahden kurssin opettajat keskenään. Molempien päivitysten on onnistuttava tai kumpaakaan ei saa tehdä:

```sql
BEGIN;

UPDATE courses SET teacher_id = 2 WHERE course_id = 1;
UPDATE courses SET teacher_id = 1 WHERE course_id = 2;

COMMIT;
```

Jos ajat `COMMIT`, molemmat päivitykset tehdään. Jos ajat sen sijaan `ROLLBACK`, kumpaakaan päivitystä ei tehdä.

### Esimerkki: Useat lisäykset yhdenä yksikkönä

Kun opiskelija ilmoittautuu kurssille, voidaan lisätä sekä ilmoittautuminen että väliaikainen arvosanarivi. Molemmat tulisi luoda yhdessä:

```sql
BEGIN;

INSERT INTO enrollments (student_id, course_id) VALUES (4, 2);
INSERT INTO grades (student_id, course_id, grade) VALUES (4, 2, NULL);

COMMIT;
```

(Jos `grades.grade` on määritelty `NOT NULL`-sarakeeksi, käytä väliaikaista arvoa kuten 0 tai jätä arvosanarivi pois, kunnes arvosana on asetettu; säädä oman skeeman mukaan.) Jos toinen `INSERT` epäonnistuu (esim. rajoiterikkomus), voit tehdä `ROLLBACK`, jotta opiskelija ei jää ilmoittautuneeksi ilman arvosanariviä (tai päin vastoin).

---

## Autocommit (oletuskäyttäytyminen)

Useimmissa asiakkaille jokainen lause commitoidaan automaattisesti, jos et aloita transaktiota. Yksittäinen `UPDATE` tai `DELETE` on käytännössä yhden lauseen transaktio: se commitoidaan heti. Ryhmitelläksesi useita lauseita sinun on käytettävä `BEGIN` … `COMMIT` (tai `ROLLBACK`).

---

# 3) ACID-ominaisuudet

Transaktioita tukevat tietokannat tarjoavat tyypillisesti **ACID**-takuut:

| Ominaisuus                        | Merkitys selkokielisenä                                                                                                                                                                  |
| --------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Atomicity** (atomisuus)         | Transaktio on kaikki-tai-ei-mitään: joko transaktion jokainen lause suoritetaan tai mitään ei suoriteta. Ei "puolittaista committia".                                                    |
| **Consistency** (johdonmukaisuus) | Tietokanta siirtyy yhdestä validista tilasta toiseen. Rajoitteet (esim. viiteavaimet, CHECK) valvotaan, joten data ei riko määriteltyjä sääntöjä.                                        |
| **Isolation** (eristys)           | Samanaikaiset transaktiot eivät näe toistensa committaamattomia muutoksia tavalla, joka rikkoisi eristystason takuut. Yhden transaktion työ on eristetty muista, kunnes se commitoidaan. |
| **Durability** (kestävyys)        | Kun transaktio on commitattu, sen muutokset ovat pysyviä vaikka palvelin kaatuu tai virta katkeaa (ne tallennetaan levylle ja palautetaan käynnistyksen yhteydessä).                     |

---

### Atomisuus

Jos teet `ROLLBACK`:in tai tietokanta keskeyttää transaktion (esim. virheen jälkeen), **kaikki** kyseisessä transaktiossa tehdyt muutokset perutaan. Osittaista committia ei ole.

### Johdonmukaisuus

Tietokanta varmistaa, että jokaisen commitoidun transaktion jälkeen kaikki rajoitteet pätevät. Jos lause rikkoisi rajoitteen, lause epäonnistuu ja (ellei käsittele sitä) transaktio voidaan rollata, jotta tietokanta pysyy validissa tilassa.

### Eristys

Kaksi samanaikaisesti ajettavaa transaktiota näkevät datasta näkymän, joka riippuu **eristystasosta**. Korkeammalla tasolla transaktiosi on enemmän "suojassa" muiden transaktioiden committaamattomilta tai myöhemmiltä muutoksilta; matalammalla tasolla saatat nähdä uudempia tai väliarvoja. Katso [Kohta 5](#5-eristystasot-johdanto) alla.

### Kestävyys

`COMMIT`:in jälkeen tietokanta ei "unohda" muutoksiasi käynnistyksessä. Ne kirjoitetaan kestävämpään tallennusvälineeseen (esim. WAL ja datatiedostot) ja toistetaan palautuksen yhteydessä.

---

# 4) Rollbackit

**Rollback** tarkoittaa transaktion päättämistä **hylkäämällä** kaikki kyseisessä transaktiossa tehdyt muutokset. Tietokanta palauttaa tilan transaktion alun tilaan (transaktiosi näkökulmasta).

---

## Eksplisiittinen ROLLBACK

Voit tehdä rollbackin eksplisiittisesti ajamalla:

```sql
ROLLBACK;
```

Kaikki viimeisestä `BEGIN`:istä lähtien perutaan. Sitä transaktiota ei päivitetä, lisätä tai poisteta yhtään riviä.

### Esimerkki

```sql
BEGIN;
UPDATE students SET email = 'test@test.com' WHERE student_id = 1;
-- Päätät perua:
ROLLBACK;
```

Sähköpostia ei muuteta; transaktio päättyy ilman pysyviä muutoksia.

---

## Automaattinen rollback virheen yhteydessä

Jos transaktion sisällä oleva lause **epäonnistuu** (esim. rajoiterikkomus, syntaksivirhe), tietokanta merkitsee transaktion keskeytetyksi. Seuraavat lauseet samassa transaktiossa epäonnistuvat, kunnes joko:

- **ROLLBACK** — hylkää transaktion ja aloita alusta, tai
- **COMMIT** — monissa järjestelmissä `COMMIT` virheen jälkeen käytännössä tekee transaktiosta rollbackin (mitään muutoksia ei commitoida).

Käytännössä virheen jälkeen annat yleensä `ROLLBACK`:in ja sitten yrität uudelleen tai korjaat logiikan.

---

## Tallennuspisteet (valinnainen)

PostgreSQL (ja muut) tukevat **tallennuspisteitä** (savepoints) transaktion sisällä: voit tehdä rollbackin tiettyyn nimetyyn kohtaan ilman koko transaktion perumista.

```sql
BEGIN;
UPDATE courses SET credits = 6 WHERE course_id = 1;
SAVEPOINT before_second_change;
UPDATE courses SET credits = 4 WHERE course_id = 2;
-- Jos jotain on vialla:
ROLLBACK TO SAVEPOINT before_second_change;
-- Ensimmäinen UPDATE on edelleen transaktiossa; toinen on peruttu.
COMMIT;
```

Tämä on hyödyllistä "osittaiseen peruutukseen" yhden transaktion sisällä. Johdantokurssilla tallennuspisteet voi jättää pois ja käyttää vain `BEGIN` / `COMMIT` / `ROLLBACK`.

---

## Johdanto-ote

- **READ COMMITTED** — Oletus; hyvä tasapaino. Et koskaan näe muiden committaamatonta dataa; saatat nähdä eri tulokset, jos ajat saman kyselyn kahdesti.
- **REPEATABLE READ** — Sama tilannevedos koko transaktion ajan; vähemmän "yllätyksiä" mutta enemmän lukituksia.
- **SERIALIZABLE** — Tiukin eristys; käytä kun tarvitset vahvoja takuita ja voit käsitellä uudelleenyritykset.

Useimpiin sovellustarpeisiin oletus (READ COMMITTED) riittää. Käytä korkeampia tasoja, kun oikeellisuusvaatimukset ovat tiukat (esim. rahoitus tai raportointi) ja ymmärrät, että ne voivat vähentää samanaikaista suoritusta tai aiheuttaa enemmän rollbackeja.

---

## Yhteenveto

| Aihe            | Keskeiset asiat                                                                                                                                                      |
| --------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **UPDATE**      | Muuta sarakearvoja; käytä WHERE rajoittaaksesi rivejä. Ilman WHERE kaikki rivit päivitetään.                                                                         |
| **DELETE**      | Poista rivejä; käytä WHERE rajoittaaksesi rivejä. Ilman WHERE kaikki rivit poistetaan.                                                                               |
| **Transaktiot** | BEGIN … COMMIT (tai ROLLBACK) ryhmittelee lauseet yhdeksi työn yksiköksi. Kaikki tai ei mitään.                                                                      |
| **ACID**        | Atomisuus (kaikki tai ei mitään), Johdonmukaisuus (rajoitteet pätevät), Eristys (samanaikaiset transaktiot), Kestävyys (commitattu data säilyy kaatumisten jälkeen). |
| **Rollbackit**  | ROLLBACK hylkää kaikki nykyisen transaktion muutokset. Virheet keskeyttävät tyypillisesti transaktion; sitten ROLLBACK ja uudelleenyritys.                           |
| **Eristys**     | Taso määrittää, mitä yksi transaktio näkee muista. READ COMMITTED (oletus), REPEATABLE READ, SERIALIZABLE. Tiukempi = vähemmän anomalioita, enemmän lukituksia.      |

---

_Materiaali 09 loppuu._
