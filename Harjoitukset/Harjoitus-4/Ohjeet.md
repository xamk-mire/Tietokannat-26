# Tehtävä 4: Normalisointi, transaktiot ja datan muokkaus

### Talviolympialaiset — huonosta suunnittelusta 3NF:ään, sitten datan muutosten harjoittelua

> **Ohjeet:**  
> Saat **huonosti suunnitellun** talviolympiatietokannan (yksi denormalisoitu taulu). **Analysoi** se, **normalisoi** se 3NF:ään, **siirrä** data uusiin tauluihin ja harjoittele sitten UPDATE-, DELETE-, transaktio- ja rollback-käyttöä normalisoidulla tietokannalla. Tarvittaessa viittaa [Materiaaliin 08 — Normalisointi ja skeeman laatu](Materiaalit/08-normalisointi-ja-skeeman-laatu.md) ja [Materiaaliin 09 — Transaktiot ja datan muokkaus](Materiaalit/09-transaktiot-ja-datan-muokaus.md).
>
> **Aloitus (tee ensin):** Luo uusi PostgreSQL-tietokanta **`winter_olympics`**, aja sitten **`04_bad_schema.sql`** ja **`04_bad_seed.sql`**. Sinulla on yksi taulu, **`medal_results`**, jossa on redundanttia dataa.

---

## Aloitussuunnitelma: huono rakenne

Kun olet ajanut `04_bad_schema.sql` ja `04_bad_seed.sql`, sinulla on yksi taulu:

**`medal_results`** — yksi rivi per urheilija per tapahtuma (yksi mitali), sarakkeet:

| Sarake       | Kuvaus (toistuu monella rivillä)                    |
| ------------ | --------------------------------------------------- |
| athlete_id   | Urheilijan tunniste                                 |
| athlete_name | Toistuu jokaisessa kyseisen urheilijan tuloksessa   |
| country_code | Toistuu jokaisessa kyseisen urheilijan tuloksessa   |
| country_name | Toistuu jokaisessa kyseisen urheilijan tuloksessa   |
| event_id     | Tapahtuman tunniste                                 |
| event_name   | Toistuu jokaisessa kyseisen tapahtuman tuloksessa  |
| sport_name   | Toistuu jokaisessa kyseisen tapahtuman tuloksessa  |
| venue_name   | Toistuu jokaisessa kyseisellä paikalla olevassa tuloksessa |
| city         | Toistuu jokaisessa kyseisellä paikalla olevassa tuloksessa |
| medal_type   | gold / silver / bronze (riippuu urheilijasta + tapahtumasta) |

Aja `SELECT * FROM medal_results;` nähdäksesi datan ja toistot.

---

## OSA A — Analysoi huono suunnitelma (Materiaali 08)

Vastaa seuraaviin **`medal_results`** -taulun osalta. Käytä apuna yllä olevaa taulurakennetta ja tietokannassa näkyvää dataa.

---

### A1 — Redundanssi ja anomaliat

**A1.1** **Päivitysanomalia** — Jos Mika Virtasen nimi korjataan (esim. oikeinkirjoitus). Mitä tässä suunnittelussa on tehtävä? Mitä menee vikaan, jos päivitämme vain yhden rivin?

_Vastauksesi:_

---

**A1.2** **Lisäysanomalia** — Haluamme lisätä uuden tapahtuman "Viestikilpailu" maastohiihtoon, paikalle Mountain Resort, Zhangjiakou, ennen kuin kukaan urheilija on kilpaillut siinä. Onnistuuko tämä tällä yhdellä taululla? Selitä lyhyesti.

_Vastauksesi:_

---

**A1.3** **Poistoanomalia** — Jos poistamme Saralle Niemelle naisten pujottelun tuloksen rivin, mitä tietoa menetämme sen yhden mitalituloksen lisäksi?

_Vastauksesi:_

---

### A2 — Ensimmäinen normaalimuoto (1NF)

Taululla `medal_results` on atomiarvot jokaisessa solussa ja pääavain `(athlete_id, event_id)`.

**A2.1** Onko tämä taulu 1NF:ssä? (Kyllä/Ei ja yksi lause miksi.)

_Vastauksesi:_

---

**A2.2** Oletetaan, että olisimme sen sijaan sarake `events_won`, jossa useita arvoja yhdessä solussa, esim. `"Men's Downhill, Men's 50km"`. Miksi se **ei** olisi 1NF?

_Vastauksesi:_

---

### A3 — Toinen normaalimuoto (2NF)

`medal_results` -taulun pääavain on **yhdistetty**: `(athlete_id, event_id)`.

**A3.1** Mitkä attribuutit riippuvat **vain** `athlete_id`:stä? Mitkä **vain** `event_id`:stä? Mitkä **molemmista** (koko avaimesta)?

_Vastauksesi:_

---

**A3.2** Täyttääkö `medal_results` siis 2NF:n? (Kyllä/Ei ja yksi lause.)

_Vastauksesi:_

---

**A3.3** 2NF:ään päästään jakamalla erillisiin tauluihin. Listaa **taulut**, jotka sinulla olisi, ja kunkin taulun **pääavain**. (Toteutat nämä osassa B.)

_Vastauksesi:_

---

### A4 — Kolmas normaalimuoto (3NF)

Oletetaan, että tapahtumat olisi jaettu tauluun **`events(event_id, event_name, sport_id, venue_name, city)`** — eli paikan nimi ja kaupunki olisivat edelleen tapahtumataulussa.

**A4.1** Mikä **transitiivinen riippuvuus** siellä on? (Mikä ei-avainsarake riippuu toisesta ei-avainsarakkeesta?)

_Vastauksesi:_

---

**A4.2** Miten korjaamme sen 3NF:ään? (Nimeä taulut: esim. yksi venues-, yksi events-taulu, jossa vain venue_id.)

_Vastauksesi:_

---

### A5 — Milloin denormalisointi voi olla hyväksyttävää (lyhyt)

Kerro **yksi** tilanne, jossa denormalisointia käytetään joskus redundanssiriski huolimatta.

_Vastauksesi:_

---

## OSA B — Normalisoi 3NF:ään transaktioiden avulla

Tehtäväsi on **suunnitella ja toteuttaa** normalisoitu skeema itse: kirjoita `CREATE TABLE` -lauseet ja **siirrä** sitten data taulusta `medal_results` uusiin tauluihin. Sinun on käytettävä **transaktioita**, jotta normalisointi on turvallinen: jos jokin vaihe epäonnistuu, voit tehdä **ROLLBACK**:in ja tietokanta pysyy johdonmukaisena. **COMMIT** vain, kun olet varmistanut siirron.

**Tärkeää:** Valmista normalisoitua skeemaa tai migraatioskriptiä ei anneta. Kirjoitat ne itse osan A suunnitelman (A3.3 ja A4.2) perusteella. Käytä [Materiaalia 07](Materiaalit/07-SQL-perusteet-3.md) viiteavain- ja rajoitesyntaksissa ja [Materiaalia 09](Materiaalit/09-transaktiot-ja-datan-muokkaus.md) transaktioissa.

---

### B1 — Suunnittele ja luo normalisoitu skeema (transaktion sisällä)

**B1.1** Kirjoita `CREATE TABLE` -lauseet kaikille 3NF-tauluelle: **countries**, **athletes**, **sports**, **venues**, **events**, **results**. Sisällytä pääavaimet, tarvittavat viiteavaimet ja rajoitteet (esim. `CHECK (medal_type IN ('gold', 'silver', 'bronze'))` tulostaululle). Käytä identiteettisarakkeissa `GENERATED ALWAYS AS IDENTITY`. Lisää **athletes** -tauluun **email**-sarake (nullable) myöhempää tehtävää varten. **Älä** poista taulua `medal_results` — tarvitset sen migraatiossa.

Aja CREATE-lauseesi **transaktion sisällä**: `BEGIN;` … CREATE TABLE -lauseesi … `COMMIT;` Jos jokin epäonnistuu, korjaa SQL ja yritä uudelleen. PostgreSQLissa DDL on transaktionaalista, joten joko kaikki taulut luodaan tai mitään.

```sql
BEGIN;

-- CREATE TABLE countries; ... CREATE TABLE results; tähän


COMMIT;
```

---

**B1.2** Miksi normalisoidussa suunnittelussa taululla **events** on `venue_id` (viiteavain) eikä `venue_name` ja `city`? Yksi lause.

_Vastauksesi:_

---

### B2 — Siirrä data transaktion avulla

Kopioi data taulusta `medal_results` uusiin tauluihin **riippuvuusjärjestyksessä**:

1. **countries** — erilliset `(country_code, country_name)` taulusta `medal_results`
2. **athletes** — erilliset `(athlete_id, athlete_name, country_code)`; tarvitset **countries** -taulusta `country_id`:n (liitä `country_code`:lla). Jotta **results** -taulun `athlete_id`-arvot pysyvät samoina, käytä `INSERT INTO athletes (athlete_id, full_name, country_id) OVERRIDING SYSTEM VALUE SELECT ...`
3. **sports** — erilliset `sport_name`
4. **venues** — erilliset `(venue_name, city)`
5. **events** — erilliset `(event_id, event_name, sport_name, venue_name, city)`; liitä **sports**- ja **venues** -tauluihin saadaksesi `sport_id` ja `venue_id`. Käytä `OVERRIDING SYSTEM VALUE` `event_id`:lle, jotta arvot vastaavat `medal_results` -taulun arvoja
6. **results** — `SELECT athlete_id, event_id, medal_type FROM medal_results`

**B2.1** Aja koko migraatio **yhden transaktion sisällä**: `BEGIN;` sitten kaikki `INSERT ... SELECT` -lauseesi yllä olevassa järjestyksessä, sitten **tarkista** esim. `SELECT COUNT(*) FROM results;` (odota 8) ja `SELECT COUNT(*) FROM athletes;` (odota 6). Vasta sen jälkeen aja **COMMIT;** Jos jokin INSERT epäonnistuu tai lukumäärät ovat väärin, aja **ROLLBACK;** korjaa SQL ja yritä uudelleen.

Kirjoita migraatiosi (kaikki INSERTit) alla olevaan lohkoon. Käytä koko migraatiosta yksi transaktio.

```sql
BEGIN;

-- 1. INSERT INTO countries ...
-- 2. INSERT INTO athletes ... (käytä OVERRIDING SYSTEM VALUE athlete_id:lle)
-- 3. INSERT INTO sports ...
-- 4. INSERT INTO venues ...
-- 5. INSERT INTO events ... (käytä OVERRIDING SYSTEM VALUE event_id:lle, liitä sports- ja venues-tauluihin)
-- 6. INSERT INTO results ...

-- Tarkista ennen COMMIT:iä:
-- SELECT COUNT(*) FROM results;  -- pitäisi olla 8
-- SELECT COUNT(*) FROM athletes;  -- pitäisi olla 6

COMMIT;   -- tai ROLLBACK; jos jotain on vialla
```

---

**B2.2** Miksi on tärkeää ajaa migraatio transaktion sisällä? Yksi lause.

_Vastauksesi:_

---

### B3 — Poista vanha taulu (transaktion sisällä)

**B3.1** Kun migraatio on commitattu ja olet tarkistanut datan (esim. 8 riviä **results** -taulussa, 6 **athletes** -taulussa), poista vanha taulu. Tee se transaktion sisällä: `BEGIN; DROP TABLE medal_results; COMMIT;` jotta voit tehdä ROLLBACK:in, jos jokin muu riippuu siitä.

```sql
BEGIN;
DROP TABLE medal_results;
COMMIT;
```

Tämän jälkeen käytät vain normalisoituja tauluja osassa C.

---

## OSA C — Datan muokkaus normalisoidulla tietokannalla (Materiaali 09)

Käytä **normalisoitua** talviolympiatietokantaa (countries, athletes, sports, venues, events, results). Aja SQL:si **psql**:ssä tai pgAdminissa.

---

### C1 — UPDATE

**C1.1** Lisää tai päivitä urheilijan, jolla `athlete_id = 2` (Sara Niemi), sähköpostiksi `sara.niemi@olympics.fi`. Käytä `WHERE`-ehtoa `athlete_id`:lle.

_Itsetarkistus: `SELECT full_name, email FROM athletes WHERE athlete_id = 2;` näyttää uuden sähköpostin._

```sql


```

---

**C1.2** Päivitä **kaikki** tapahtumat, joilla on `venue_id = 1`, käyttämään `venue_id = 3`. Käytä `WHERE venue_id = 1`.

_Itsetarkistus: Yhtään tapahtumaa ei pitäisi olla venue_id = 1 päivityksen jälkeen._

```sql


```

---

**C1.3** (Turvallisuus) Ennen kuin ajat UPDATE:n, joka koskee useita rivejä, mitä pitäisi tehdä ensin? Yksi lause.

_Vastauksesi:_

---

### C2 — DELETE

**C2.1** Poista **yksi** tulos: rivi, jolla `athlete_id = 5` ja `event_id = 5` (James Chen, pariluistelu). Käytä `WHERE`-ehtoa molemmilla sarakkeilla.

_Itsetarkistus: `SELECT * FROM results;` pitäisi näyttää 7 riviä._

```sql


```

---

**C2.2** Jos haluaisimme poistaa kaikki urheilijan 3 tulokset, ajaisimme `DELETE FROM results WHERE athlete_id = 3;`. Ennen sitä mitä pitäisi ajaa ensin ja miksi?

_Vastauksesi:_

---

### C3 — Transaktiot (BEGIN, COMMIT)

**C3.1** Käytä **transaktiota** tehdäksesi kaksi asiaa yhdessä:

1. Lisää uusi urheilija: `full_name = 'Liisa Korhonen'`, `country_id = 1` (Suomi), `email = NULL`.
2. Lisää uusi tulos tälle urheilijalle tapahtumassa `event_id = 4` (naisten sprintti) arvolla `medal_type = 'bronze'`.

Tarvitset uuden `athlete_id`:n tulostariviä varten (esim. käytä ensimmäisen INSERTin jälkeen `RETURNING athlete_id` tai `currval(pg_get_serial_sequence('athletes','athlete_id'))`). Käytä INSERTien edellä `BEGIN;` ja jälkeen `COMMIT;`.

```sql
BEGIN;


COMMIT;
```

---

**C3.2** Yhdellä lauseella: miksi on hyödyllistä laittaa nämä kaksi INSERTiä yhteen transaktioon?

_Vastauksesi:_

---

### C4 — Rollback

**C4.1** Aloita transaktio, päivitä jonkin urheilijan sähköposti testiarvoon (esim. `'rollback_test@test.com'` urheilijalle `athlete_id = 1`), aja sitten **ROLLBACK;** COMMITin sijaan. Sen jälkeen aja `SELECT email FROM athletes WHERE athlete_id = 1;` — sähköpostin pitäisi olla muuttumaton. Kirjoita ajamasi lauseet.

```sql
BEGIN;


ROLLBACK;
```

---

**C4.2** Yhdellä lauseella: mitä ROLLBACK tekee viimeisestä BEGINistä lähtien tehdyille muutoksille?

_Vastauksesi:_

---

### C5 — Eristystaso (johdanto)

**C5.1** Aseta eristystasoksi **REPEATABLE READ** nykyiselle transaktiolle, aja `SELECT * FROM athletes;`, sitten COMMIT. Kirjoita lauseet.

```sql
BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;


COMMIT;
```

---

**C5.2** Milloin voisit valita **REPEATABLE READ**:n oletuksen (READ COMMITTED) sijaan? Yksi lyhyt syy.

_Vastauksesi:_

---

## Itsetarkistus (validointi)

Ennen lopetusta varmista:

1. **Osa A:** Tunnistit päivitys-, lisäys- ja poistoanomaliat; osittaiset riippuvuudet (2NF); transitiivisen riippuvuuden (3NF).
2. **Osa B:** Kirjoitit ja ajat omat CREATE TABLE -lauseesi transaktion sisällä; kirjoitit ja ajat oman migraatiosi (INSERT...SELECT) transaktion sisällä ja tarkistit rivimäärät ennen COMMIT:iä; poistit `medal_results` -taulun transaktion sisällä. Lopputila: 8 riviä **results** -taulussa, 6 **athletes** -taulussa.
3. **Osa C:** C1.1 ja C1.2 tehty; C2.1 poisti yhden tuloksen; C3 ajoi kaksi INSERTiä yhdessä transaktiossa; C4:n rollback jätti urheilijan 1 sähköpostin ennalleen; C5 (valinnainen) asetti eristystason REPEATABLE READ ja ajoi SELECTin.

---

## Tiedostot tässä tehtävässä

| Tiedosto                | Tarkoitus                                                                 |
| ----------------------- | ------------------------------------------------------------------------- |
| **Instructions.md**     | Tämä dokumentti (englanninkielinen)                                       |
| **Instructions-FI.md**  | Tämä dokumentti (suomeksi)                                                |
| **04_bad_schema.sql**   | Luo huonon suunnitelman (yksi taulu `medal_results`) — aja ensin          |
| **04_bad_seed.sql**     | Esimerkkidata taululle `medal_results` — aja toiseksi                     |

Normalisoidun skeeman (CREATE TABLE) ja migraation (INSERT...SELECT) kirjoitat itse käyttäen transaktioita kuten osassa B kuvataan.

---

_Tehtävä 4 loppuu._
