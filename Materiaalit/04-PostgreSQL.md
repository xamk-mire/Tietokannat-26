# Johdanto PostgreSQL:n 

### Käytännöllinen ja runollinen alku vakavalle tietokannalle

PostgreSQL (usein kutsuttu nimellä **Postgres**) on tietokanta, joka tuntuu vähemmän varastolaatikolta ja enemmän **hyvin hallitulta tiedon kaupungilta**.
Se ei ainoastaan säilytä dataasi turvallisesti — se *odottaa sen olevan merkityksellistä*, *järjestettyä* ja *sääntöjen suojelemaa*.

Siinä missä jotkut järjestelmät ovat tyytyväisiä ottamaan vastaan mitä tahansa, PostgreSQL kysyy:

> ”Mitä tämä data edustaa?”
> ”Mitä sääntöjä sen tulisi noudattaa?”
> ”Miten sen tulisi liittyä kaikkeen muuhun?”

Ja sitten se auttaa sinua valvomaan näitä sääntöjä johdonmukaisesti, vuosien ajan.

---

## 1) Mikä PostgreSQL on 

PostgreSQL on **relaatiotietokannan hallintajärjestelmä (Relational Database Management System, RDBMS)** — järjestelmä, joka tallentaa tietoa **tauluihin (tables)** ja antaa sinun käsitellä tietoa **SQL-kielellä (SQL)**.

Mutta PostgreSQL on myös enemmän kuin tämä:

* **Avoimen lähdekoodin (Open-source)**
  → vapaasti saatavilla, yhteisövetoisesti kehitetty, maailmanlaajuisesti luotettu
  (käyttäjänä sinä hallitset järjestelmää, ei yritys tai kolmas osapuoli)

* **Standardeihin perustuva (Standards-based)**
  → puhuu SQL:ää rakenteellisella ja kurinalaisella tavalla

* **Tehokas ja laajennettava (Powerful and extensible)**
  → kasvaa ”opiskelijaprojektista” ”tuotantojärjestelmäksi”

* **Luotettava (Reliable)**
  → suunniteltu suojelemaan oikeellisuutta myös kovassa kuormituksessa

Jos relaatiotietokannat ovat kirjastoja, PostgreSQL on sellainen, jossa on myös:

* koulutetut kirjastonhoitajat (rajoitteet ja eheys, constraints and integrity)
* vartijat (roolit ja käyttöoikeudet, roles and permissions)
* ja tarkka kortistojärjestelmä (indeksit ja kyselysuunnittelija, indexes and query planner)

---

## 2) PostgreSQL:n henki: miksi sitä rakastetaan 

PostgreSQL on ansainnut maineen järjestelmänä, joka on:

* **vakava oikeellisuuden suhteen**
* **vahva paineen alla**
* **oppijaystävällinen**
* **kyvykäs suuressa mittakaavassa**

### Keskeiset ideat, jotka määrittelevät PostgreSQL:n

* **Datan eheys (Data integrity)**
  → datan ei pitäisi muuttua järjettömäksi ajan myötä

* **Johdonmukaisuus (Consistency)**
  → sääntöjen tulee olla pakotettavia, ei vapaaehtoisia

* **Samanaikaisuus (Concurrency)**
  → monet käyttäjät voivat työskennellä yhtä aikaa rikkomatta toistensa työtä

* **Laajennettavuus (Extensibility)**
  → PostgreSQL:ää voidaan *räätälöidä*, ei vain konfiguroida

---

## 3) PostgreSQL-tietokanta: sisäinen maailma 

Kun luot tai yhdistät PostgreSQL-tietokantaan, astut rakenteelliseen maailmaan, jossa on tunnistettavat rakennuspalikat.

### Keskeiset objektit, joihin törmäät varhain

* **Tietokanta (Database)** → säiliö, joka sisältää toisiinsa liittyvää dataa ja objekteja
* **Skeema (Schema)** → nimiavaruus (namespace) taulujen järjestämiseen (oletus `public`)
* **Taulu (Table)** → rakenteellinen kokoelma rivejä ja sarakkeita
* **Rivi (Row)** → yksi tietue (yksi ”asia”)
* **Sarake (Column)** → kyseisen asian ominaisuus
* **Rajoite (Constraint)** → sääntö, joka suojelee oikeellisuutta
* **Indeksi (Index)** → rakenne, joka nopeuttaa hakua
* **Näkymä (View)** → tallennettu ”ikkuna” dataan (kuin tallennettu kysely)
* **Sekvenssi / Identiteetti (Sequence / Identity)** → järjestelmä numeeristen ID-arvojen luomiseen

---

## 4) PostgreSQL ja SQL: kieli, jota se puhuu 

PostgreSQL puhuu SQL:ää selkeästi ja syvällisesti.
Alussa kehittäjät käyttävät SQL:ää pääasiassa **rakentamiseen**.

### SQL ”ensimmäinen tietokanta” -vaiheessa tarkoittaa tyypillisesti

* **CREATE TABLE** → rakenteiden määrittely
* **PRIMARY KEY / FOREIGN KEY** → identiteetin ja suhteiden määrittely
* **NOT NULL / UNIQUE / CHECK / DEFAULT** → sääntöjen valvonta
* **INSERT INTO** → ensimmäisten rivien lisääminen

PostgreSQL rohkaisee tällaiseen oppimiseen, koska se tekee rakenteesta luonnollisen tuntuisen:
luot taulun kuin loisit sopimuksen.

---

## 5) Tietotyypit: PostgreSQL:n merkityksen sanasto (Data Types)

PostgreSQL on kuuluisa rikkaasta ja käytännöllisestä tietotyyppivalikoimastaan.
Tämä on tärkeää, koska tyypit ovat se tapa, jolla tietokanta ymmärtää *mitä arvot edustavat*.

### Yleisiä PostgreSQL-tyyppejä, joihin opiskelijat törmäävät varhain

* **INTEGER** → kokonaisluvut (ID:t, laskurit)
* **VARCHAR(n)** → teksti, jolla on maksimipituus
* **TEXT** → teksti ilman tiukkaa pituusrajaa
* **BOOLEAN** → tosi/epätosi-arvot
* **DATE** → kalenteripäivät
* **TIMESTAMP** → päivämäärä + aika
* **TIMESTAMPTZ** → aikaleima *aikavyöhyketietoisuudella*
* **NUMERIC(p,s)** → tarkat desimaalit (raha, mittaukset)

Hyvä tietokantasuunnittelu valitsee tyypit huolellisesti, koska tyypit eivät ole koristetta:
ne muokkaavat sitä, mikä on sallittua, mikä on turvallista ja mikä pysyy johdonmukaisena ajan myötä.

---

## 6) Rajoitteet: PostgreSQL totuuden vartijana (Constraints)

Aloittelija saattaa nähdä rajoitteet ”ylimääräisenä työnä”.
PostgreSQL näkee ne **koko asian ytimenä**.

Rajoitteet saavat tietokannan automaattisesti hylkäämään huonon datan.

### Keskeiset rajoitteet, jotka PostgreSQL-opiskelijoiden tulisi tuntea

* **PRIMARY KEY** → identiteetti, yksikäsitteisyys, ei NULL
* **FOREIGN KEY** → suhteiden on viitattava oikeisiin riveihin
* **NOT NULL** → arvon on oltava olemassa
* **UNIQUE** → duplikaatit ovat kiellettyjä
* **CHECK** → arvojen on läpäistävä sääntö
* **DEFAULT** → arvo annetaan automaattisesti

Tämä on yksi PostgreSQL:n suurista vahvuuksista:

> Se estää virheet lähteessä
> sen sijaan, että ne siivottaisiin myöhemmin.

---

## 7) Transaktiot ja ACID: turvalliset muutokset turvattomassa maailmassa

(Transactions and ACID)

Tietokantoja käytetään harvoin vain yhden henkilön toimesta.
Todellisessa elämässä monet käyttäjät, prosessit ja järjestelmät koskettavat samaa dataa.

PostgreSQL hoitaa tämän **transaktioiden (transactions)** avulla.

Transaktio on muutosten ryhmä, jota käsitellään yhtenä kokonaisuutena:

* joko kaikki onnistuvat
* tai mikään ei tapahdu

### ACID-periaatteet, joita PostgreSQL suojelee

* **Atomicity (atomisuus)** → kaikki tai ei mitään
* **Consistency (johdonmukaisuus)** → sääntöjen on pysyttävä totena
* **Isolation (eristys)** → samanaikainen työ ei turmele tuloksia
* **Durability (pysyvyys)** → vahvistetut muutokset säilyvät kaatumisista huolimatta

Käytännössä tämä tekee PostgreSQL:stä luotettavan tuntuisen:
vaikka järjestelmä olisi kovassa kuormassa, data ei ”repeä”.

---

## 8) MVCC: miten PostgreSQL käsittelee monta käyttäjää yhtä aikaa

Yksi PostgreSQL:n määrittävistä ominaisuuksista on **MVCC (Multi-Version Concurrency Control)**
eli moniversioinen samanaikaisuuden hallinta.

Yksinkertaisesti:

> Lukijat eivät estä kirjoittajia,
> eikä kirjoittaminen estä lukemista (ainakaan niin paljon kuin pelkäisit).

Sen sijaan, että PostgreSQL lukitsisi kaiken aggressiivisesti, se säilyttää **rivien versioita**, mahdollistaen johdonmukaiset tilannekuvat (snapshots) samalla kun päivityksiä tapahtuu.

### Mitä MVCC antaa sinulle

* **Sujuva samanaikaisuus (Smooth concurrency)** → monet käyttäjät voivat työskennellä turvallisesti
* **Johdonmukaiset lukutulokset (Consistent reads)** → kyselyt näkevät vakaan näkymän dataan
* **Vähemmän konflikteja (Fewer conflicts)** → vähemmän ”kaikki on lukittu” -tilanteita

---

## 9) Suorituskyvyn perusta: indeksit ja suunnittelija

(Performance Foundations: Indexes and the Planner)

PostgreSQL ei ole nopea sattumalta — se on nopea suunnittelun ansiosta.

Kaksi PostgreSQL:n suorituskyvyn keskeistä pilaria ovat:

### A) Indeksit (Indexes) — tietokannan oikopolut

Indeksit ovat kuin:

* kirjan hakemisto
* kirjaston kortisto
* kartan selite

Ne auttavat tietokantaa löytämään rivejä nopeasti ilman, että kaikkea tarvitsee lukea läpi.

Aloittelijat kohtaavat usein ensin:

* **PRIMARY KEY -indeksit** (luodaan automaattisesti)
* **UNIQUE-indeksit** (luodaan automaattisesti)

---

### B) Kyselysuunnittelija (The Query Planner) — tietokannan strategi

PostgreSQL ei vain ”aja” kyselyä.
Se päättää ensin, *miten* se ajetaan.

Se arvioi mahdollisia strategioita ja valitsee tehokkaan suunnitelman:

* mitä indeksejä käytetään
* mitä tauluja luetaan
* miten data yhdistetään

Jo aloittelijat hyötyvät siitä, että tietävät tämän olevan olemassa:

> PostgreSQL ei ole tyhmä suorittaja — se on huolellinen optimoija.

---

## 10) PostgreSQL relaatiomallin tuolla puolen: modernit ominaisuudet

PostgreSQL on syvästi relaatiopohjainen, mutta se ottaa myös modernit datatarpeet avosylin vastaan.

### Merkittäviä PostgreSQL-ominaisuuksia

* **JSON / JSONB** → JSON-dokumenttien tehokas tallennus ja kysely
* **Taulukot (Arrays)** → arvojen taulukoiden tallennus tarvittaessa
* **Kokotekstihaku (Full-text search)** → tekstihaku kuin hakukoneessa
* **Laajennukset (Extensions)** → lisää uusia kykyjä tietokantaan

  * esim. **PostGIS** paikkatietoa varten
* **Mukautetut tyypit (Custom types)** → toimialueeseen sopivien tyyppien suunnittelu

PostgreSQL on klassinen tietokanta, joka on oppinut modernit kielet unohtamatta juuriaan.

---

## 11) Työkalut, joita aloittelijat yleisesti käyttävät

PostgreSQL:n oppiminen on helpompaa, kun aloittelijat tunnistavat työkalut, joihin he törmäävät.

### Tyypillisiä aloittelijaystävällisiä työkaluja

* **psql** → PostgreSQL:n komentorivikäyttöliittymä
* **pgAdmin** → graafinen hallintatyökalu
* **Docker** → PostgreSQL paikallisesti ilman monimutkaista asennusta
* **Tietokanta-asiakkaat (Database clients)**
  → DBeaver, DataGrip, VS Code -laajennukset

Tärkeä idea ei ole työkalu — vaan tapa:

* luo tauluja
* määritä rajoitteet
* lisää esimerkkidataa
* rakenna uudelleen itsevarmasti

---

## 12) Mitä PostgreSQL opettaa sinulle kehittäjänä

PostgreSQL ei vain tallenna dataa.
Se opettaa sinulle ajattelutavan:

### PostgreSQL-ajattelutapa näyttää tältä

* **Mallinna maailma selkeästi**

  * taulut edustavat käsitteitä
* **Suojele merkitystä rajoitteilla**

  * älä luota vain sovelluskoodiin
* **Käytä suhteita toiston sijaan**

  * viiteavaimet estävät ajautumisen erilleen
* **Luota tietokantaan sääntöjen valvojana**

  * anna sen tehdä työnsä

Monissa järjestelmissä tietokantaa kohdellaan passiivisena säiliönä.
PostgreSQL:ssä tietokanta on **kumppani oikeellisuudessa**.

