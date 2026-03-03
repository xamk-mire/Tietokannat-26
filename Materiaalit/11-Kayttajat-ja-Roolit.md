# Käyttäjät ja roolit (PostgreSQL)

### Käyttöoikeudet ja lupien hallinta

Tässä luvussa esitellään **tietokannan käyttäjät ja roolit**:

- **Roolit ja käyttäjät** — mitä ne ovat PostgreSQLissä
- **Käyttöoikeudet** — mitä voidaan myöntää tai perua
- **Skeemat ja omistajuus** — kuka omistaa objektit
- **Yleiset roolimallit** — vain luku vs. luku–kirjoitus

---

# 1) Roolit ja käyttäjät PostgreSQLissä

PostgreSQL käyttää **rooleja** käyttöoikeuksien hallintaan.  
Rooli voi toimia **käyttäjänä** (voi kirjautua sisään) tai vain **ryhmänä** oikeuksille.

- **Rooli** — identiteetti, joka voi omistaa objekteja ja saada käyttöoikeuksia
- **Kirjautumisrooli (käyttäjä)** — rooli, jolla on `LOGIN` ja joka voi yhdistää
- **Ryhmärooli** — rooli ilman `LOGIN`ia, käytetään oikeuksien kokoamiseen

Roolit voivat olla myös **jäseniä** toisissa rooleissa. Näin PostgreSQL tukee ryhmäoikeuksia:

- Kirjautumisrooli (käyttäjä) voi periä oikeudet yhdeltä tai useammalta ryhmäroolilta.
- Ryhmärooleja voi sisäkkäistää (esim. `app_write` sisältää `app_read`).

---

## Esimerkki: käyttäjä vs. rooli (käsitteellisesti)

- `app_read` — ryhmärooli vain luku -oikeuksilla
- `app_write` — ryhmärooli luku–kirjoitus -oikeuksilla
- `alice` — kirjautumisrooli (käyttäjä)

Ryhmäroolit myönnetään käyttäjille:

```sql
GRANT app_read TO alice;
GRANT app_write TO alice;
```

Nyt `alice` voi lukea ja kirjoittaa rooleihin liittyvien oikeusten perusteella.

---

## Roolin attribuutit

Rooleilla voi olla attribuutteja, jotka rajoittavat mitä ne saavat tehdä. Yleisimmät:

- **LOGIN** — voi yhdistää tietokantaan (tekee roolista käyttäjän)
- **CREATEDB** — voi luoda tietokantoja
- **CREATEROLE** — voi luoda tai muuttaa muita rooleja

Aloittelijan tasolla `CREATEDB` ja `CREATEROLE` jätetään yleensä pois, paitsi hallintatehtävissä.

---

## Omistajuus vs. käyttöoikeudet

- **Omistajuus** tarkoittaa, että rooli loi objektin (taulun, skeeman, funktion jne.). Omistajat voivat aina muuttaa tai poistaa omia objektejaan.
- **Käyttöoikeudet** (grantit) sallivat pääsyn toisten omistamiin objekteihin.

Siksi yleinen malli on:

1. Luo objektit admin-roolina
2. Myönnä vain tarvittavat oikeudet sovellus-/käyttäjärooleille

---

## Käytännössä

- Luo **ryhmärooleja** oikeuksille (esim. `app_read`, `app_write`)
- Luo **kirjautumisrooleja** henkilöille tai sovelluksille
- Myönnä ryhmäroolit kirjautumisrooleille

Tämä pitää käyttöoikeushallinnan yksinkertaisena ja helpompana ylläpitää.

---

# 2) Roolien ja käyttäjien luominen

PostgreSQL luo **rooleja** komennolla `CREATE ROLE`.  
Erillistä `CREATE USER` -komentoa ei ole (se on alias komennolle `CREATE ROLE ... LOGIN`).

Roolia luodessa päätetään voiko se kirjautua sisään ja mitkä attribuutit sillä on.

---

## Kirjautumisroolin (käyttäjän) luominen

```sql
CREATE ROLE alice LOGIN PASSWORD 'secret';
```

Tämä luo roolin `alice`, joka voi kirjautua salasanalla `secret`.  
Oikeassa järjestelmässä käytä vahvaa salasanaa ja tallenna se turvallisesti.

---

## Ryhmäroolin luominen

```sql
CREATE ROLE app_read;
CREATE ROLE app_write;
```

Ryhmärooleilla ei ole `LOGIN`ia, joten ne eivät voi yhdistää suoraan. Niitä käytetään **oikeuksien kokoamiseen**.

### Esimerkki: vain luku- ja luku–kirjoitus -ryhmäroolien luominen

```sql
-- Luo roolit (ei LOGINia)
CREATE ROLE app_read;
CREATE ROLE app_write;

-- Salli skeeman käyttö
GRANT USAGE ON SCHEMA public TO app_read;
GRANT USAGE ON SCHEMA public TO app_write;

-- Vain luku -pääsy
GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_read;

-- Luku–kirjoitus -pääsy
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_write;
```

Lisätäksesi tulevat taulut, aseta oletusoikeudet:

```sql
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT ON TABLES TO app_read;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_write;
```

---

## Ryhmäroolien myöntäminen käyttäjälle

```sql
GRANT app_read TO alice;
GRANT app_write TO alice;
```

Nyt `alice` perii oikeudet rooleilta `app_read` ja `app_write`.

---

## Kirjautumisroolin luominen attribuutteineen

Voit lisätä roolin attribuutteja suoraan:

```sql
CREATE ROLE app_admin
  LOGIN
  PASSWORD 'secret'
  CREATEDB
  CREATEROLE;
```

Yleiset attribuutit:

- `LOGIN` / `NOLOGIN`
- `CREATEDB` / `NOCREATEDB`
- `CREATEROLE` / `NOCREATEROLE`
- `SUPERUSER` / `NOSUPERUSER` (vältä tavallisilta käyttäjiltä)

---

## Olemassa olevien roolien muuttaminen

Salasanan vaihto:

```sql
ALTER ROLE alice PASSWORD 'new_secret';
```

Kirjautumisen myöntäminen tai peruminen:

```sql
ALTER ROLE alice LOGIN;
-- tai
ALTER ROLE alice NOLOGIN;
```

Roolin attribuuttien lisääminen:

```sql
ALTER ROLE alice CREATEDB;
```

---

## Roolien poistaminen

```sql
DROP ROLE alice;
```

Roolin voi poistaa vain jos se:

- ei omista tietokantaobjekteja ja
- ei ole muiden roolien vaatima

## Jos rooli omistaa objekteja, omistajuus täytyy siirtää tai objektit poistaa ensin.

# 3) Käyttöoikeudet (GRANT ja REVOKE)

Käyttöoikeudet määrittävät mitä rooli voi tehdä.

Yleiset oikeudet:

- **SELECT** — rivien lukeminen
- **INSERT** — rivien lisääminen
- **UPDATE** — rivien muuttaminen
- **DELETE** — rivien poistaminen
- **USAGE** (skeemassa) — skeeman objektien käyttö
- **CREATE** (skeemassa) — objektien luominen skeemaan

---

# 3.1) Esimerkki: Yliopistotietokannan roolit (tietokantakohtainen)

Tämä esimerkki näyttää miten roolit asetetaan **yliopistotietokannan** tauluille:  
`students`, `courses`, `enrollments`, `grades`, `teachers`.

Tavoite:

- **uni_read** → vain luku -pääsy kaikkiin yliopiston tauluihin
- **uni_write** → luku–kirjoitus -pääsy kaikkiin yliopiston tauluihin
- **uni_admin** → voi luoda, muuttaa ja poistaa objekteja skeemassa
- Kaikki yllä olevat yhdistävät **vain** **university**-tietokantaan

### Vaihe 1 — Luo ryhmäroolit

```sql
CREATE ROLE uni_read;
CREATE ROLE uni_write;
CREATE ROLE uni_admin;
```

### Vaihe 2 — Rajoita tietokantapääsy

PostgreSQL-roolit ovat **klusterin** tasolla, joten pääsy rajoitetaan tietokannan oikeuksilla.  
Oletetaan tietokannan nimeksi `university_db`.

```sql
-- Poista oletus pääsy (valinnainen, mutta suositeltu)
REVOKE CONNECT ON DATABASE university_db FROM PUBLIC;

-- Salli vain yliopiston rooleille yhteys
GRANT CONNECT ON DATABASE university_db TO uni_read;
GRANT CONNECT ON DATABASE university_db TO uni_write;
GRANT CONNECT ON DATABASE university_db TO uni_admin;
```

Nyt nämä roolit voivat yhdistää vain `university_db`-tietokantaan. Muut tietokannat ovat saavuttamattomia, ellei niille erikseen myönnetä oikeuksia.

---

### Vaihe 3 — Myönnä skeeman käyttö

Oletetaan taulut skeemassa `public`:

```sql
GRANT USAGE ON SCHEMA public TO uni_read;
GRANT USAGE ON SCHEMA public TO uni_write;
GRANT USAGE, CREATE ON SCHEMA public TO uni_admin;
```

### Vaihe 4 — Myönnä taulukohtaiset oikeudet

```sql
GRANT SELECT ON ALL TABLES IN SCHEMA public TO uni_read;

GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA public TO uni_write;
```

### Vaihe 5 — Oletusoikeudet tuleville tauluille

```sql
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT ON TABLES TO uni_read;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO uni_write;
```

### Vaihe 6 — Luo kirjautumiskäyttäjät ja määritä roolit

```sql
CREATE ROLE uni_student LOGIN PASSWORD 'secret';
CREATE ROLE uni_teacher LOGIN PASSWORD 'secret';
CREATE ROLE uni_admin_user LOGIN PASSWORD 'secret';

GRANT uni_read TO uni_student;
GRANT uni_write TO uni_teacher;
GRANT uni_admin TO uni_admin_user;
```

### Selitys

- **uni_student** voi lukea yliopiston dataa mutta ei voi muuttaa sitä.
- **uni_teacher** voi lukea ja päivittää dataa (esim. lisätä arvosanoja).
- **uni_admin_user** voi luoda tai muuttaa tauluja skeemassa.

---

## Esimerkki: vain luku -rooli

```sql
-- Salli public-skeeman käyttö
GRANT USAGE ON SCHEMA public TO app_read;

-- Salli lukuoikeus kaikkiin tauluihin
GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_read;
```

---

## Esimerkki: rajoita pääsy tietyille tauluille (uni_student)

Jos haluat roolin lukevan **vain** tietyt taulut, myönnä SELECT vain niille tauluille.

Esimerkkitavoite:

- `uni_student` voi lukea **students**-, **courses**- ja **grades**-taulut
- `uni_student` ei voi lukea **enrollments**- tai **teachers**-tauluja

```sql
-- Salli skeeman käyttö
GRANT USAGE ON SCHEMA public TO uni_student;

-- Myönnä SELECT vain tietyille tauluille
GRANT SELECT ON TABLE students, courses, grades TO uni_student;

-- (Valinnainen) peru laajempi pääsy, jos se myönnettiin aiemmin
REVOKE SELECT ON ALL TABLES IN SCHEMA public FROM uni_student;
```

Jos haluat rajoittaa tulevia tauluja, **älä** myönnä oletusoikeuksia laajasti.

---

## Esimerkki: luku–kirjoitus -rooli

```sql
GRANT USAGE ON SCHEMA public TO app_write;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_write;
```

---

# 4) Oletusoikeudet

Kun myönnät oikeuksia olemassa oleville tauluille, **uudet taulut eivät sisälly automaattisesti**.  
Jotta tulevat taulut käyttäisivät samoja oikeuksia, aseta **oletusoikeudet**:

```sql
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT ON TABLES TO app_read;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_write;
```

Nämä oletusoikeudet koskevat objekteja, jotka **luo rooli, joka suorittaa ALTER DEFAULT PRIVILEGES -komennon**.

---

# 5) Omistajuus ja skeemat

Jokaisella tietokantaobjektilla on **omistaja** (rooli). Omistaja voi:

- muuttaa käyttöoikeuksia
- muuttaa tai poistaa objektin

Skeemat ovat nimitiloja (kuin kansiot).  
Yleiset asetukset:

- Pidä taulut skeemassa `public`
- Luo sovelluskohtaiset skeemat (esim. `app`)

Esimerkki:

```sql
CREATE SCHEMA app AUTHORIZATION alice;
```

---

# 6) Yleiset roolimallit

### Malli A: Vain luku ja luku–kirjoitus

- `app_read` → vain SELECT
- `app_write` → SELECT + INSERT + UPDATE + DELETE
- Määritä käyttäjät yhteen tai molempiin rooleihin

### Malli B: Erillinen admin-rooli

- `app_admin` → voi CREATE, ALTER, DROP
- `app_read` / `app_write` → data-pääsy

---

# 7) Hyvät käytännöt

- **Vähimmäisoikeudet** — myönnä vain tarvittava
- **Käytä ryhmärooleja** — helpompi hallita kuin käyttäjäkohtaiset grantit
- **Dokumentoi** mitä kukin rooli voi tehdä
- **Vältä superuserin** käyttämistä normaaleissa tehtävissä

---

# 8) Pikaluettelo

Ennen tietokannan käyttöönottoa:

1. Luo ryhmäroolit (`app_read`, `app_write`)
2. Myönnä skeeman käyttö ja taulukohtaiset oikeudet
3. Aseta oletusoikeudet tuleville tauluille
4. Luo kirjautumisroolit ja määritä ryhmät
5. Testaa vain luku -käyttäjällä

---

## 9) Oikeuksien testaus (käytännössä)

Roolien ja oikeuksien luomisen jälkeen **testaa**, että pääsy toimii odotetulla tavalla.  
Yksinkertaisin tapa on yhdistää kunkin roolin nimellä ja kokeilla sekä sallittuja että kiellettyjä toimintoja.

### A) Testaus vain luku -käyttäjänä (PowerShell/terminaali tai SQL-shell)

**Vaihtoehto 1 — PowerShell/terminaali → psql**

> Varmista, että psql on polussa (PATH) — muuten järjestelmä ei ehkä tunnista komentoa

```
psql -U uni_student -d university_db
```

**Vaihtoehto 2 — SQL-shell (psql)**

Jos olet jo psql:ssä, yhdistä käyttäjänä:

```
\c university_db uni_student
```

Suorita sitten **SELECT** (pitäisi onnistua):

```sql
SELECT * FROM students;
```

3. Kokeile **INSERT** (pitäisi epäonnistua):

```sql
INSERT INTO students (full_name, email) VALUES ('Test User', 'test@uni.fi');
```

Odotettu tulos: permission denied taululle `students`.

---

### B) Testaus luku–kirjoitus -käyttäjänä (PowerShell/terminaali tai SQL-shell)

**Vaihtoehto 1 — PowerShell/terminaali → psql**

```
psql -U uni_teacher -d university_db
```

**Vaihtoehto 2 — SQL-shell (psql)**

Jos olet jo psql:ssä, yhdistä käyttäjänä:

```
\c university_db uni_teacher
```

Suorita **SELECT** (pitäisi onnistua):

```sql
SELECT * FROM courses;
```

3. Suorita **UPDATE** (pitäisi onnistua):

```sql
UPDATE courses SET credits = credits + 1 WHERE course_id = 1;
```

4. Suorita **DELETE** (pitäisi onnistua, jos myönnetty):

```sql
DELETE FROM enrollments WHERE student_id = 1 AND course_id = 2;
```

---

### C) Tietokantapääsyn testaus (PowerShell/terminaali tai SQL-shell)

Jos rajoitit tietokantapääsyä (esim. `REVOKE CONNECT FROM PUBLIC`), vahvista että rooli **ilman** CONNECTia ei voi kirjautua:

Luo uusi testikäyttäjä (`test_user`)

```sql
CREATE ROLE test_user LOGIN PASSWORD 'test';
```

**Vaihtoehto 1 — PowerShell/terminaali → psql**

```
psql -U test_user -d university_db
```

**Vaihtoehto 2 — SQL-shell (psql)**

Jos olet jo psql:ssä, kokeile yhdistää:

```
\c university_db test_user
```

Odotettu tulos: permission denied tietokannalle `university_db`.

---

### Vinkki: tarkista grantit SQL:llä

PostgreSQL tarjoaa apufunktioita oikeuksien tarkistamiseen:

```sql
SELECT has_table_privilege('uni_student', 'students', 'SELECT');
SELECT has_table_privilege('uni_student', 'students', 'INSERT');
```

Ne palauttavat `true` tai `false`.

---

## Yhteenveto

| Aihe | Keskeiset ideaat |
| ---- | ---------------- |
| **Roolit** | Roolit ovat identiteettejä; kirjautumisroolit ovat käyttäjiä; ryhmäroolit kokoavat oikeuksia. |
| **Käyttöoikeudet** | GRANT/REVOKE hallitsevat SELECT/INSERT/UPDATE/DELETE ja skeeman käyttöä. |
| **Omistajuus** | Omistajat voivat muuttaa tai poistaa objekteja; skeemat ryhmittelevät objekteja. |
| **Mallit** | Vain luku vs. luku–kirjoitus -roolit; erilliset admin-roolit. |
| **Oletukset** | Oletusoikeudet hallitsevat pääsyä tuleviin objekteihin. |
| **Testaus** | Vahvista oikeudet yhdistämällä jokaisen roolin nimellä ja kokeilemalla sallittuja ja kiellettyjä toimintoja. |

---

_Materiaalin 11 loppu._
