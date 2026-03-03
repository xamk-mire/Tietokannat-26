# Indeksit ja indeksointi

### Tehokkaat haut (ja kompromissit)

Tässä luvussa esitellään **indeksit**:

- **Mitä indeksit ovat** — ja miksi ne auttavat
- **Milloin indeksit auttavat (ja milloin eivät)** — selektiivisyys ja käyttötavat
- **Indeksityypit ja suunnittelu** — perusavaimet, unikaat, yhdistelmä- ja järjestysindeksit
- **Kustannukset ja kompromissit** — kirjoitukset, tallennus ja ylläpito

Esimerkit käyttävät samoja **yliopistotietokannan** tauluja kuin aiemmat materiaalit: `students`, `courses`, `enrollments`, `grades`, `teachers`.

---

# 1) Mikä on indeksi?

**Indeksi** on erillinen tietorakenne, jonka tietokanta ylläpitää **rivien nopeampaa löytämiseksi**.  
Voit ajatella sitä kuin kirjan hakemiston: sen sijaan että selaisit jokaista sivua, hyppäät suoraan tarvitsemiisi sivuihin.

Korkean tason tarkastelussa indeksi tallentaa:

- **Indeksiavaimet** (yhdestä tai useammasta sarakkeesta tulevat arvot)
- **Osoittimet** varsinaisiin taulun riveihin (jotta tietokanta voi hypätä suoraan niihin)

Suurin osa PostgreSQL-indekseistä on **B-puu**-indeksejä, jotka pitävät avaimet järjestettyinä ja mahdollistavat nopeat haun, aluehaun ja järjestetyn skannauksen.

---

## Indeksien olemassaolo tietokannassa

Indeksi on **erillinen kohde**, joka tallennetaan levylle samalla tavalla kuin taulu. Sillä on oma nimi, tallennus ja rakenne.  
Indeksin luomisessa tietokanta:

1. **Lukee taulun** ja rakentaa indeksirakenteen (avaimet + osoittimet)
2. **Tallentaa indeksin** levylle
3. **Pitää sen ajan tasalla** aina kun lisäät, päivität tai poistat rivejä

Jokainen rivimuutos vaikuttaa sekä **tauluun** että sen **indekseihin**.

---

## Miten tietokanta käyttää indeksiä

Haun suorituksessa optimoija päättää käytetäänkö indeksiä:

- **Peräkkäisskannaus (Seq Scan):** luetaan jokainen rivi ja suodatetaan
- **Indeksiskannaus:** käytetään indeksiä hypätäksemme vastaaviin riveihin

Valinta riippuu taulun koosta, selektiivisyydestä ja tilastoista. Pienille tauluille tai vähän suodattaville sarakkeille peräkkäisskannaus voi olla nopeampi.

Vaikka indeksi on olemassa, sitä ei välttämättä käytetä kun:

- Haku palauttaa suuren osan taulusta
- Suodatin ei vastaa indeksoitua saraketta/sarakkeita
- Yhdistelmäindeksiä käytetään ilman vasemmanpuoleisinta saraketta
- Sarakkeelle sovelletaan funktiota tai tyypinmuunnosta (ellei ole vastaavaa funktioindeksiä)
- Kuvio alkaa villikortilla, esim. `LIKE '%teksti'`

Indeksit **eivät muuta** hakutuloksia; ne vain muuttavat **tavan**, jolla tietokanta etsii rivit.

---

## Esimerkki: Opiskelijan haku sähköpostilla

Haku:

```sql
SELECT * FROM students WHERE email = 'aino@uni.fi';
```

Jos `students.email` on indeksoitu, tietokanta voi siirtyä suoraan vastaavaan riviin.  
Jos ei, se saattaa skannata koko `students`-taulun.

---

# 2) Milloin indeksit auttavat (ja milloin eivät)

Indeksit ovat hyviä **selektiivisille** hauille — sellaisille, jotka palauttavat pienen osan riveistä.

Ne ovat vähemmän hyödyllisiä kun:

- Sarakkeella on **matala selektiivisyys** (monella rivillä sama arvo)
- Taulu on **pieni** (skannaus on jo halpa)
- Haku ei suodata indeksoidulla sarakkeella

Ne voivat myös olla vähemmän hyödyllisiä kun haku palauttaa **suurimman osan taulusta**. Tällöin taulun skannaus kerran voi olla nopeampi kuin indeksin kautta hypettely.

---

## Selektiivisyyden esimerkki

- `students.email` — tyypillisesti yksilöllinen → **korkea selektiivisyys** → hyvä indeksikohde.
- `grades.grade` — vain arvot 0–5 → **matala selektiivisyys** → indeksi ei välttämättä auta paljoa.

---

# 3) Yleisimmät indeksityypit

Suurin osa PostgreSQL-indekseistä on **B-puu**-indeksejä, jotka toimivat hyvin:

- Yhtälöhaun: `WHERE email = ...`
- Aluehaun: `WHERE grade BETWEEN 3 AND 5`
- Lajittelun: `ORDER BY full_name`

B-puu-indeksiä ei tarvitse valita erikseen; se on oletuksena.

Muita indeksityyppejä on olemassa (esim. hash, GIN, GiST), mutta niitä käytetään erikoistapauksissa. Tietokantojen perusteissa B-puu riittää suurimpaan osaan tarpeista.

---

## Perusavain- ja yksilölliset indeksit

Kun määrittelet **PRIMARY KEY**in, PostgreSQL luo automaattisesti yksilöllisen indeksin.  
Sama pätee **UNIQUE**-rajoitteisiin.

Esimerkki:

```sql
CREATE TABLE students (
  student_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  full_name  VARCHAR(100) NOT NULL,
  email      VARCHAR(255) UNIQUE
);
```

Tämä luo:

- Indeksin sarakkeelle `student_id` (perusavain)
- Yksilöllisen indeksin sarakkeelle `email`

Yksilölliset indeksit palvelevat kahta tarkoitusta:

- **Nopeus** haussa kyseisellä sarakkeella
- **Tiedon eheys** varmistamalla yksilöllisyyden

---

# 4) Indeksien luominen ja poistaminen

Voit luoda indeksin mille tahansa sarakkeelle, jota haetaan usein.

### Yksinkertaisen indeksin luominen

```sql
CREATE INDEX idx_students_full_name ON students (full_name);
```

### Indeksin poistaminen

```sql
DROP INDEX idx_students_full_name;
```

Indeksin nimen kannattaa olla kuvaava, esim. `idx_taulu_sarake` tai `uq_taulu_sarake`.

---

# 5) Yhdistelmä- (monisarakkeiset) indeksit

**Yhdistelmäindeksi** sisältää useita sarakkeita. Se auttaa kun haut suodattavat **indeksin vasemmanpuoleisimmilla sarakkeilla**.

Esimerkki-indeksi:

```sql
CREATE INDEX idx_grades_student_course ON grades (student_id, course_id);
```

Tätä indeksiä hyödynnetään:

- `WHERE student_id = 3 AND course_id = 1`
- `WHERE student_id = 3`

Mutta se **ei auta** kun:

- `WHERE course_id = 1` (koska `course_id` ei ole vasemmanpuoleisin sarake)

---

## Järjestyksellä on merkitystä

Yhdistelmäindeksejä suunniteltaessa laita **selectiivisin** tai **yleisin suodatin** ensin.

Jos useimmat haut suodattavat `student_id`:lla, niin `(student_id, course_id)` on oikein.  
Jos useimmat haut suodattavat `course_id`:lla, niin `(course_id, student_id)` on parempi.

---

# 6) Indeksit ja ORDER BY

Indeksit voivat nopeuttaa lajittelua, jos lajittelujärjestys vastaa indeksin järjestystä.

Esimerkki:

```sql
CREATE INDEX idx_courses_title ON courses (title);
```

Silloin:

```sql
SELECT title FROM courses ORDER BY title;
```

voi käyttää indeksiä välttääkseen ylimääräisen lajitteluvaiheen.

---

# 7) Kustannukset ja kompromissit

Indeksit nopeuttavat lukua, mutta niistä aiheutuu kustannuksia:

- **Kirjoituskulut** — jokainen `INSERT`, `UPDATE` ja `DELETE` päivittää myös indeksit.
- **Tallennus** — indeksit vievät lisää levytilaa.
- **Ylläpito** — liian monet indeksit voivat hidastaa tietojen muutoksia.

Älä siis indeksoi kaikkea. Indeksoi **siellä missä se auttaa**.

---

## Hyvät indeksikandidaatit

- Sarakkeet, joita käytetään usein `WHERE`-ehdossa
- Sarakkeet, joita käytetään `JOIN`-ehdoissa
- Sarakkeet, joita käytetään `ORDER BY`-lauseessa
- Viiteavaimet isoissa tauluissa (usein hyödyllisiä liitoksissa)

---

# 8) Perusteiden jälkeen

Nämä ovat yleisiä indeksi-ideoita, joita näet käytännössä.

---

## Covering- / indeksiskannaus ilman taulua

Jos haun voi vastata **kokonaan indeksista**, PostgreSQL voi joskus välttää taulun (heap) lukemisen kokonaan. Tätä kutsutaan **indeksiskannaukseksi ilman taulua**.

Esimerkki:

```sql
CREATE INDEX idx_students_email_name ON students (email, full_name);

SELECT email, full_name
FROM students
WHERE email LIKE '%@uni.fi';
```

Jos tarvittavat sarakkeet ovat indeksissa, PostgreSQL voi käyttää indeksiä vastaamaan hautaan tehokkaammin.

---

## Osittaiset indeksit

**Osittainen indeksi** tallentaa vain ne rivit, jotka täyttävät ehdon. Se voi olla pienempi ja nopeampi kun haet aina osajoukon.

Esimerkki: indeksoi vain opiskelijat, joilla on sähköposti:

```sql
CREATE INDEX idx_students_email_not_null
ON students (email)
WHERE email IS NOT NULL;
```

Haut, joissa on `WHERE email IS NOT NULL`, voivat käyttää indeksiä; muut eivät.

---

## Funktioindeksit

Jos haut käyttävät funktiota WHERE-ehdossa, tavallista indeksiä ei välttämättä käytetä. **Funktioindeksi** voi auttaa.

Esimerkki: isot ja pienet kirjaimet huomioimaton sähköpostihaku:

```sql
CREATE INDEX idx_students_email_lower
ON students (LOWER(email));

SELECT * FROM students WHERE LOWER(email) = 'aino@uni.fi';
```

---

# 9) Indeksin käytön tarkistaminen

PostgreSQL voi näyttää haun suunnitelman komennolla:

```sql
EXPLAIN SELECT * FROM students WHERE email = 'aino@uni.fi';
```

Jos näet **Index Scan**, indeksiä käytetään.  
Jos näet **Seq Scan**, tietokanta valitsi peräkkäisskannauksen.

Käytä `EXPLAIN`-komentoa oppimiseen ja virheenetsintään; todelliseen suorituskykyanalyysiin käytät `EXPLAIN ANALYZE`-komentoa.

Voit vertailla saman haun kahta versiota ennen ja jälkeen indeksin luomisen nähdäksesi suunnittelijan valinnan muuttumisen.

### Peräkkäisskannauksen pakottaminen päälle ja pois (pienet tietokannat)

Pienillä tauluilla PostgreSQL usein suosii peräkkäisskannausta vaikka indeksi olisi olemassa.  
Oppimista varten voit tilapäisesti estää Seq Scan -skannaukset nähdäksesi indeksin käytön.

```sql
-- Pakota suunnittelija välttämään peräkkäisskannaukset
SET enable_seqscan = off;

EXPLAIN SELECT * FROM students WHERE email = 'aino@uni.fi';

-- Palauta oletuskäyttäytyminen
SET enable_seqscan = on;
```

Nämä asetukset ovat sessiokohtaisia ja nollautuvat kun yhdistät uudelleen.

---

## EXPLAIN käytännössä

`EXPLAIN` näyttää **hausehdotelman** — vaiheet, joita PostgreSQL käyttää haun suorittamiseen. Se **ei suorita** hakua.

### Peruskäyttö

```sql
EXPLAIN
SELECT s.full_name, c.title
FROM enrollments e
JOIN students s ON s.student_id = e.student_id
JOIN courses c ON c.course_id = e.course_id
WHERE s.student_id = 1;
```

### Mihin kiinnittää huomiota

- **Seq Scan** — PostgreSQL skannaa koko taulun.
- **Index Scan / Index Only Scan** — PostgreSQL käyttää indeksiä.
- **Join-tyyppi** (esim. Nested Loop, Hash Join) — miten taulut yhdistetään.

Jos odotit indeksiä mutta näet Seq Scanin, tarkista:

- Onko suodatin tarpeeksi selektiivinen?
- Vastaako haku indeksoitua saraketta ja järjestystä?
- Sovelletko funktiota tai tyypinmuunnosta ilman vastaavaa funktioindeksiä?

### EXPLAIN ANALYZE (suorittaa haun)

`EXPLAIN ANALYZE` **suorittaa** haun ja raportoi todelliset ajat ja rivimäärät:

```sql
EXPLAIN ANALYZE
SELECT * FROM students WHERE email = 'aino@uni.fi';
```

Käytä sitä kun haluat todellista suorituskykydataa, mutta varo isoilla tauluilla.

---

## Yhteenveto

| Aihe | Keskeiset ideaat |
| ---- | ---------------- |
| **Indeksi** | Erillinen tietorakenne, joka nopeuttaa hakuja ja lajittelua. |
| **Milloin auttaa** | Korkea selektiivisyys, usein käytetyt suodattimet, liitokset, lajittelu. |
| **Milloin ei auta** | Matala selektiivisyys, pienet taulut, väärä käyttötapa. |
| **Yhdistelmäindeksi** | Järjestyksellä on merkitystä; vasemmanpuoleisimmat sarakkeet ovat hyödyllisimmat. |
| **Laajennetut perusteet** | Covering-, osittaiset ja funktioindeksit voivat auttaa erityisissä tapauksissa. |
| **Kompromissit** | Nopeampi lukeminen vs. hitaampi kirjoittaminen ja enemmän tallennustilaa. |

---

_Materiaalin 10 loppu._
