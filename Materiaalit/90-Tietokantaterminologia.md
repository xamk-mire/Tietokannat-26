# Tietokantaterminologia (Glossary of Database Terminology)

Kattava sanasto kurssimateriaaleissa käytetyistä tietokantatermeistä. Termit on järjestetty aakkosjärjestykseen.

**★ = Keskeinen termi** — Ensin opittavat peruskäsitteet.

---

## Keskeiset termit yhteenvedossa


| Alue                 | Keskeiset termit (engl. / suom.)                                                                                         |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| **Perusteet**        | Database / Tietokanta, Data / Data, Table / Taulu, Row / Rivi, Column / Sarake, Schema / Skeema, SQL                     |
| **Datan mallinnus**  | Entity / Entiteetti, Attribute / Ominaisuus, Relationship / Suhde, ER diagram / ER-kaavio, Cardinality / Kardinaliteetti |
| **Avaimet ja eheys** | Primary key / Pääavain, Foreign key / Viiteavain, Constraint / Rajoite, Referential integrity / Viite-eheys              |
| **Normalisointi**    | 1NF, 2NF, 3NF, Redundancy / Päällekkäisyys, Junction table / Liitostaulu                                                 |
| **SQL-perusteet**    | SELECT, INSERT, UPDATE, DELETE, WHERE, JOIN, CRUD                                                                        |
| **Joinit**           | INNER JOIN, LEFT JOIN                                                                                                    |
| **Koostaminen**      | GROUP BY, HAVING, Aggregate function / Koostefunktio                                                                     |
| **Transaktiot**      | Transaction / Transaktio, ACID, COMMIT, ROLLBACK                                                                         |
| **Indeksointi**      | Index / Indeksi, Primary key index / Pääavainindeksi                                                                     |
| **Turvallisuus**     | Role / Rooli, Privilege / Käyttöoikeus, GRANT, Authentication / Todentaminen, Authorization / Valtuutus                  |


---

## A

**ACID** ★ — Transaktioiden takaamat ominaisuudet: *Atomiisuus* (kaikki tai ei mitään), *Johdonmukaisuus* (tietokanta siirtyy vain kelvollisiin tiloihin), *Eristys* (samanaikaiset transaktiot eivät häiritse toisiaan) ja *Kestävyys* (tehdyt muutokset säilyvät kaatumisten jälkeen).

**Ad-hoc querying** — Kyselyiden tekeminen vapaasti ilman valmiita koodipolkuja tai raportteja. Relaatiotietokannat mahdollistavat tämän SQL:llä ja kyselyoptimointiin perustuen.

**Aggregate function (Koostefunktio)** ★ — Funktio, joka tiivistää useita rivejä yhdeksi arvoksi (esim. `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`). Käytetään `GROUP BY`:n kanssa ryhmien yhteenvetoihin.

**Application user (Sovelluskäyttäjä)** — Henkilö tai järjestelmä, joka käyttää sovellustasi (esim. Alice, Bob). Tallennetaan sovelluksen taulujen riveiksi kuten `Users`. Erottaa *tietokantakäyttäjistä*, joita käytetään tietokantayhteyteen.

**Associative entity (Assosiatiivinen entiteetti)** — Entiteetti, joka edustaa kahden tai useamman entiteetin välistä suhdetta. Toteutetaan usein liitostauluna (esim. `Enrollment` yhdistää Studentin ja Coursen).

**Atomic value (Atomiarvo)** — Yksittäinen arvo solussa—ei lista, sisäkkäinen rakenne tai toistuva ryhmä. Vaaditaan ensimmäisessä normaalimuodossa (1NF).

**Atomicity (Atomiisuus)** — Transaktioiden ominaisuus: joko kaikki transaktion lauseet suoritetaan tai yhtään. Ei osittaisia committeja.

**Attribute (Ominaisuus)** ★ — Datan mallinnuksessa: entiteettiä kuvaava ominaisuus. Relaatiomallissa: nimetty sarake relaatioissa. Esimerkkejä: `student_id`, `name`, `email`.

**Authentication (Todentaminen)** ★ — Identiteetin vahvistaminen ("Keneltä tämä pyyntö on?"). Tehdään tyypillisesti sähköposti/salasana -kombinaatiolla, istunnot tai tokenit luodaan onnistumisen jälkeen.

**Authorization (Valtuutus)** ★ — Tarkistus, sallitaanko todennettua käyttäjää suorittaa toiminto ("Mitä saat tehdä?"). Usein roolipohjainen pääsynhallinta.

---

## B

**B-tree** — Yleinen indeksirakenne, joka pitää avaimet järjestyksessä. Hyvä tasavertaisille hauille, välihauille ja yleiskäyttöiselle OLTP:lle. PostgreSQLin oletusindeksityyppi.

**BEGIN** — SQL-avainsana transaktion aloittamiseen. Kaikki ennen `COMMIT`- tai `ROLLBACK`-lausetta on yksi työn yksikkö.

**Bridge table (Liitostaulu)** — Katso *Junction table*.

**Business logic (Liiketoimintalogiikka)** — Sovelluksen kerros, joka soveltaa toimialan sääntöjä (esim. "voiko tämä käyttäjä tehdä tämän tilauksen?"). Sijoittuu esitys- ja data-kerr väliin.

---

## C

**CASCADE** — `ON DELETE`- tai `ON UPDATE` -toimenpide viiteavaimella. Kun vanhemman rivi poistetaan tai päivitetään, lapseen rivit poistetaan tai päivitetään automaattisesti.

**Candidate key (Ehdokasavain)** — Sarake tai sarakeyhmä, joka voisi yksilöidä taulun rivit. Pääavain valitaan ehdokasavaimista.

**Cardinality (Kardinaliteetti)** ★ — Suhteen "kuinka monta": yksi-yhteen (1:1), yksi-moneen (1:N) tai monta-monta (M:N).

**CHECK constraint (CHECK-rajoite)** — Tietokantasääntö, jonka mukaan arvojen on täytettävä totuusarvoehto (esim. `credits BETWEEN 1 AND 20`).

**Column (Sarake)** ★ — Pystysuora arvojen joukko taulussa, edustaa yhtä ominaisuutta. Relaatiomallissa sama kuin *attribuutti*.

**Columnar storage (Sarakkeittainen tallennus)** — Data tallennettu sarakkeittain rivien sijaan. Hyvä OLAP:lle, koska kyselyt usein lukevat muutaman sarakkeen monilta riveiltä ja koostavat ne; pakkautuu hyvin.

**COMMIT** ★ — SQL-avainsana transaktion päättämiseen ja kaikkien muutosten tekemiseen pysyviksi.

**Composite key (Yhdistetty avain)** — Pää- tai yksilöivä avain, joka koostuu kahdesta tai useammasta sarakkeesta (esim. `(student_id, course_id)` ilmoittautumistaulussa).

**Composite index (Yhdistetty indeksi)** — Indeksi usealle sarakkeelle. Järjestyksellä on merkitystä: vasemmanpuoleisimmat sarakkeet ovat hyödyllisimpiä. Auttaa, kun kyselyt suodattavat indeksoiduilla sarakkeilla järjestyksessä.

**Conceptual data model (Käsitteellinen datamalli)** — Datamallinnuksen korkein taso: kuvaa toimialan keskeiset käsitteet ja suhteet ilman toteutusyksityiskohtia. Ei määrittele pääavaimia, datatyppejä tai tauluja.

**Concurrency control (Samanaikaisuuden hallinta)** — Mekanismit, jotka pitävät transaktiot oikeina, kun useita suoritetaan samanaikaisesti. Yleisiä lähestymistapoja: lukitus ja MVCC.

**Connection pool (Yhteyspooli)** — Joukkio uudelleenkäytettäviä tietokantayhteyksiä, jotta sovellusten ei tarvitse avata ja sulkea uutta yhteyttä jokaiselle kyselylle.

**Connection string (Yhteysmerkkijono)** — Parametrit, jotka tunnistavat tietokannan ja sen sijainnin (esim. `postgresql://username:password@hostname:5432/database_name`).

**Consistency (Johdonmukaisuus)** — ACID-ominaisuus: tietokanta pakottaa rajoitteet niin, että jokaisen commitoidun transaktion jälkeen tietokanta on kelvollisessa tilassa.

**Constraint (Rajoite)** ★ — Sääntö, jota tietokanta valvoo pitääkseen datan siistinä ja merkityksellisenä (esim. PRIMARY KEY, FOREIGN KEY, NOT NULL, UNIQUE, CHECK, DEFAULT).

**CRUD** ★ — Neljä perusoperaatiota: *Create* (INSERT), *Read* (SELECT), *Update* (UPDATE), *Delete* (DELETE).

---

## D

**Data (Data)** ★ — Faktojen tai havaintojen tallennetut esitykset, varastoitu rakenteellisessa muodossa, jotta järjestelmä voi hakea, validoida, yhdistää ja käsitellä niitä luotettavasti.

**Data access layer (Datan käyttökerros)** — Sovelluksen osa, joka lähettää kyselyt tietokantaan ja kartoittaa tulokset sovelluksen olioihin.

**Data model (Datamalli)** — Rakenne ja säännöt datan järjestämiselle (taulut, dokumentit, graafit jne.).

**Data type (Datatyyppi)** — Arvotyyppi, jonka sarake voi sisältää (esim. INTEGER, VARCHAR, DATE, BOOLEAN).

**Data warehouse (Datavarasto)** — OLAP:ään optimoitu järjestelmä, usein sisältää siivottua ja yhdistettyä historiallista dataa useista lähteistä. "Yksi paikka" analytiikalle.

**Database (Tietokanta)** ★ — Hallittu kokoelma pysyvää dataa sekä mekanismeja ja sääntöjä sen tallentamiseen, hakemiseen ja pitämiseen oikeana ja turvallisena. Tarkasti ottaen: rakenteellinen data itse (erillään DBMS:stä).

**Database driver (Tietokantadraiveri)** — Kirjasto, joka puhuu tietokannan protokollaa (esim. `pg` Node.js:lle, `psycopg2` Pythonille, Npgsql .NET:lle).

**Database user (Tietokantakäyttäjä)** — Identiteetti, jota käytetään tietokantayhteyteen (esim. `app_user`, `uni_read`). Sijaitsee tietokannan järjestelmäkatalogeissa. Erottaa *sovelluskäyttäjistä*.

**DbContext** — Entity Framework Core -kirjastossa: keskeinen olio, joka edustaa istuntoa tietokannan kanssa. Hallitsee yhteyksiä, seuraa entiteettejä, kääntää LINQ:n SQL:ksi ja suorittaa SaveChanges:n.

**DbSet** — Entity Framework Core -kirjastossa: tyypitetty kokoelma, joka edustaa taulua (esim. `DbSet<Student>` Students-taululle).

**DDL** — Data Definition Language. SQL-lauseet, jotka määrittelevät rakenteen (CREATE TABLE, ALTER TABLE, DROP TABLE jne.).

**Declarative query (Deklaratiivinen kysely)** — Tulos halutaan määritellä, ei vaiheittainen prosessi. Vastakohta navigaatioperustaiselle/proseduraaliselle pääsylle. SQL on deklaratiivinen.

**DELETE** ★ — SQL-lause, joka poistaa rivejä taulusta. Käyttää `WHERE`:tä määrittämään mitkä rivit. WHERE:n pois jättäminen poistaa kaikki rivit.

**Delete anomaly (Poistoanomalia)** — Normalisointiongelma: yhden faktan poistaminen poistaa vahingossa toisen (esim. viimeisen tilauksen poistaminen poistaa asiakastietueen).

**Denormalization (Denormalisointi)** — Tahallaan lisätty päällekkäisyys kyselyjen yksinkertaistamiseksi tai suorituskyvyn parantamiseksi. Kompromissi: hyväksytään ylimääräinen ylläpito hyötyjen vuoksi.

**Derived attribute (Johdettu ominaisuus)** — Attribuutti, joka lasketaan muusta datasta (esim. ikä syntymäpäivästä). Vältetään päällekkäisyys ja epäjohdonmukaisuus.

**DML** — Data Manipulation Language. SQL-lauseet, jotka muokkaavat dataa (INSERT, UPDATE, DELETE, SELECT).

**Domain (Arvoalue)** — Arvojen joukko, joita attribuutti saa sisältää. Pakotetaan datatyypeillä ja rajoitteilla.

**Durability (Kestävyys)** — ACID-ominaisuus: kun transaktio on commitettu, sen muutokset säilyvät kaatumusten ja sähkökatkosten jälkeen (lokituksen, replikoinnin jne. kautta).

---

## E

**Entity (Entiteetti)** ★ — Reaalimaailman olio tai käsite, joka voidaan yksilöidä ja jolla on merkityksellistä dataa. Esimerkkejä: Customer, Order, Product, Student.

**Entity Framework Core (EF Core)** — Microsoftin ORM .NET:lle. Kartoittaa C#-luokat tietokantatauluihin, generoi SQL:ää LINQ:sta ja tukee migraatioita.

**Entity instance (Entiteettiesiintymä)** — Entiteetin tietty esiintymä (esim. Student #1001: Alice). Tietokannoissa rivit edustavat entiteettiesiintymiä.

**Entity type (Entiteettityyppi)** — Entiteetin yleinen kategoria (esim. Student). Tietokannoissa taulut edustavat entiteettityyppejä.

**ER diagram (ER-kaavio)** ★ — Entity-Relationship -kaavio. Graafinen malli järjestelmän datarakenteesta, joka näyttää entiteetit, attribuutit, suhteet, kardinaliteetin ja valinnallisuuden.

**EXPLAIN** — PostgreSQL-komento, joka näyttää kyselysuunnitelman—vaiheet, joilla tietokanta suorittaa kyselyn. Ei suorita kyselyä.

**EXPLAIN ANALYZE** — Kuten EXPLAIN, mutta suorittaa kyselyn ja raportoi todelliset ajat ja rivimäärät.

---

## F

**Filtering (Suodatus)** — Valitaan, mitkä rivit tulevat kyselyn tuloksiin. Tehdään `WHERE`-lauseella.

**First Normal Form (1NF) (Ensimmäinen normaalimuoto)** ★ — Taulu on 1NF:ssä jos: (1) jokainen solu sisältää yhden atomiarvon, (2) jokainen rivi on yksilöitävissä, (3) jokaisella sarakkeella on yksi merkitys ja yksi datatyyppi. Ei toistuvia ryhmiä.

**Fluent API** — EF Core:ssa: ohjelmallinen tapa konfiguroida entiteetit ja suhteet `OnModelCreating`:ssä vaihtoehtona data-annotaatioille.

**Foreign key (FK) (Viiteavain)** ★ — Sarake yhdessä taulussa, joka viittaa toisen taulun pääavaimiin. Pakottaa viite-eheyttä: ei voi viitata olemattomaan.

**Full outer join (Täysi ulkoinen yhdistäminen)** — JOIN-tyyppi, joka pitää kaikki rivit molemmista tauluista. Missä ei ole osumaa, toisen puolen sarakkeet ovat NULL.

**Functional index (Funktioindeksi)** — Indeksi, joka rakennetaan lausekkeelle (esim. `LOWER(email)`) raakasarakkeen sijaan. Hyödyllinen kun kyselyt käyttävät funktioita WHERE-lauseessa.

---

## G

**GROUP BY** ★ — SQL-lause, joka muodostaa rivityhmät yhden tai useamman sarakkeen yhtäläisten arvojen perusteella. Koostefunktiot tiivistävät sitten jokaisen ryhmän.

**Group role (Ryhmärooli)** — PostgreSQLissa: rooli ilman LOGIN-oikeutta, jota käytetään oikeuksien keräämiseen. Käyttäjät perivät oikeudet saamalla ryhmäroolin.

**GRANT** ★ — SQL-lause, joka myöntää käyttöoikeuksia (SELECT, INSERT, UPDATE, DELETE, USAGE jne.) roolille.

---

## H

**HAVING** ★ — SQL-lause, joka suodattaa *ryhmiä* koostamisen jälkeen. Toisin kuin WHERE, joka suodattaa rivit ennen ryhmittelemistä.

**Horizontal scaling (scale out) (Vaakasuuntainen skaalaus)** — Kapasiteetin lisääminen lisäämällä koneita ja jakamalla data/työ niiden kesken.

**Hash index (Hash-indeksi)** — Indeksityyppi, joka on optimoitu tasavertaisille hauille. Harvinaisempi kuin B-tree PostgreSQLissa yleiskäytössä.

---

## I

**Identifier (Tunniste)** — SQL:ssä: taulujen ja sarakkeiden nimet. Datan mallinnuksessa: arvo, joka yksilöi entiteettiesiintymän.

**Identity** — PostgreSQLissa: mekanismi automaattisten numeeristen ID:iden generointiin (`GENERATED ALWAYS AS IDENTITY` tai `GENERATED BY DEFAULT AS IDENTITY`).

**Impedance mismatch (Impedanssierotus)** — Eristys relaatiotietokantojen (taulut, rivit, sarakkeet) ja olio-orientoituneen ohjelmoinnin (oliot, ominaisuudet, viittaukset) välillä. ORM:t vastaavat tähän.

**Index (Indeksi)** ★ — Erillinen tietorakenne, joka nopeuttaa hakutöitä. Tallentaa indeksiavaimet ja osoittimet tauluriveihin. Kuin kirjan hakemisto. Yleisiä tyyppejä: B-tree, hash, GIN, GiST.

**Index-only scan (Indeksivain-haku)** — Kun kysely voidaan vastata kokonaan indeksista, PostgreSQL voi välttää taulun lukemisen. Kutsutaan myös *covering index scan* -hauksi.

**INNER JOIN** ★ — JOIN-tyyppi, joka palauttaa vain rivit, joissa yhdistämisehto on tosi molemmissa tauluissa. Osumattomat rivit jätetään pois.

**Insert anomaly (Lisäysanomalia)** — Normalisointiongelma: ei voi tallentaa kelvollista faktaa ennen kuin toinen fakta on olemassa, tai täytyy keksii/kopioida dataa.

**Instance (Instanssi / Esiintymä)** — Taulun nykyinen sisältö (data juuri nyt). Erottaa *skeemasta*, joka on pysyvä rakenne.

**Isolation (Eristys)** — ACID-ominaisuus: samanaikaiset transaktiot eivät näe toistensa commitoimattomia muutoksia tavalla, joka rikkoisi takuita. Riippuu eristystasosta.

**Isolation level (Eristystaso)** — Eristyksen "voimakkuus" (esim. read committed, repeatable read, serializable). Kompromissi oikeellisuuden ja suorituskyvyn välillä.

---

## J

**JOIN** ★ — SQL-operaatio, joka yhdistää rivejä kahdesta tai useammasta taulusta suhteen perusteella. Tyypit: INNER, LEFT, RIGHT, FULL OUTER.

**Junction table (Liitostaulu)** ★ — Taulu, joka toteuttaa monta-monta -suhteen sisältämällä viiteavaimet molempiin liittyviin tauluihin. Kutsutaan myös *bridge table* tai *associative table*. Esimerkki: `Enrollments(student_id, course_id)`.

---

## K

**Key (Avain)** — Sarake tai sarakeyhmä, joka tunnistaa rivit. Katso *primary key*, *foreign key*, *candidate key*, *composite key*.

**Keyword (Avainsana)** — SQL:ssä: komentasanat kuten CREATE, INSERT, SELECT, WHERE.

---

## L

**LEFT JOIN (LEFT OUTER JOIN)** ★ — JOIN-tyyppi, joka pitää kaikki vasemman taulun rivit ja oikean taulun vastaavat rivit. Missä ei ole osumaa, oikean taulun sarakkeet ovat NULL.

**Least privilege (Vähimmäisoikeudet)** — Turvallisuusperiaate: myönnä vain tarvittavat oikeudet, ei enempää.

**Literal (Literaali)** — SQL:ssä: varsinaiset arvot, kuten `'Aino'` tai `5`.

**Logical data model (Looginen datamalli)** — Datamallinnuksen keskitaso: määrittelee entiteetit, attribuutit, pääavaimet, suhteet ja kardinaliteetin. ER-kaavioita käytetään tyypillisesti. Pysyy riippumattomana tietystä tietokantajärjestelmästä.

**Logical operators (Loogiset operaattorit)** — AND, OR, NOT. Käytetään ehtojen yhdistämiseen WHERE-lauseissa.

**Login role (Kirjautumisrooli)** — PostgreSQLissa: rooli, jolla on LOGIN ja joka voi yhdistää tietokantaan. Käytännössä "käyttäjä" arkikielessä.

---

## M

**Mandatory participation (Pakollinen osallistuminen)** — Suhteiden rajoite: entiteetin on osallistuttava (esim. jokainen Employee kuuluu Departmenttiin). Tietokannassa: viiteavain on NOT NULL.

**Materialized view (Materialisoitu näkymä)** — Kyselyn tallennettu tulos, kuin välimuistissa oleva taulu. Päivitetään säännöllisesti. Erittäin nopea lukeminen; voi olla vanhentunut ennen päivitystä.

**Metadata (Metatiedot)** — Dataa datasta: kuvaa mitä tallennettu data tarkoittaa, miten se on rakennettu, mistä se tuli ja miten sitä käsitellään.

**Migration (Migraatio)** — EF Core:ssa: versionattu skeeman muutos. Migraatiot ovat kooditiedostoja, jotka luovat tai muuttavat tietokannan rakennetta. Sovelletaan komennolla `dotnet ef database update`.

**Multi-valued attribute (Moniarvoinen ominaisuus)** — Attribuutti, joka voi olla useita arvoja per entiteetti (esim. puhelinnumerot). Relaatiotietokannoissa yleensä muunnetaan erilliseksi tauluksi.

**MVCC** — Multi-Version Concurrency Control. Lukijat näkevät johdonmukaisen tilanvedon samalla kun kirjoittajat luovat uusia versioita. Lukijat eivät estä kirjoittajia ja kirjoittajat eivät estä lukijoita yhtä voimakkaasti kuin lukituksella.

---

## N

**Navigation property (Navigointiominaisuus)** — EF Core:ssa: entiteetin ominaisuus, joka viittaa liittyvään entiteettiin (esim. `Student.Enrollments`). Käytetään `.Include()`:n kanssa liittyvän datan lataamiseen.

**NoSQL** — Tietokantamallien perhe (avain-arvo, dokumentti, leveyssarake, graafi), jotka usein priorisoivat joustavuutta, skaalaa tai tiettyjä käyttötapoja tiukkojen relaatiotakujen sijaan. "Not Only SQL."

**Normalization (Normalisointi)** ★ — Taulujen uudelleenjärjestely päällekkäisyyden ja anomalioiden (päivitys, lisäys, poisto) poistamiseksi. Saavutetaan jakamalla data useampaan tauluun ja yhdistämällä avaimilla.

**NOT NULL** — Rajoite: sarake ei voi sisältää NULL:ia. Jokaisella rivillä täytyy olla arvo.

**Null** ★ — Erikoisarvo, joka tarkoittaa "puuttuvaa" tai "tuntematonta." Erottaa tyhjästä merkkijonosta tai nollasta. Vertailut NULL:n kanssa tuottavat tuntemattoman (ei tosi tai epätosi).

---

## O

**OLAP** — Online Analytical Processing. Työmäärät, jotka keskittyvät suuriin skannauksiin ja koostamisiin paljon dataa (dashboardit, trendianalyysi, "myynti alueittain viiden vuoden ajalta").

**OLTP** — Online Transaction Processing. Työmäärät, jotka keskittyvät moniin pieniin, usein toistuviin transaktioihin (tilaukset, tilien päivitykset).

**Optional participation (Valinnainen osallistuminen)** — Suhteiden rajoite: entiteetti voi tai ei voi osallistua (esim. Opiskelijalla voi olla tai ei Mentor). Tietokannassa: viiteavain voi olla NULL.

**ORM** — Object-Relational Mapper. Kirjasto, joka kartoittaa tietokantataulut ohjelmointikielen olioihin. Generoi SQL:ää olio-orientoituneesta tai LINQ-tyylisestä koodista. Esimerkkejä: Entity Framework Core, Hibernate, SQLAlchemy.

**Orphaned record (Orpo rivi)** — Rivi, jonka viiteavain viittaa olemattomaan vanhemman riviin. Viiteavaimen rajoitteet estävät tämän.

**Ownership (Omistajuus)** — PostgreSQLissa: rooli, joka loi objektin (taulu, skeema jne.). Omistajat voivat muuttaa tai poistaa objektejaan. Erottaa oikeuksista (grantit).

---

## P

**Parameterized query (Parametrisoitu kysely)** — Kysely, joka käyttää paikanpitäjiä (esim. `%s`, `$1`) arvoille merkkijonojen ketjutuksen sijaan. Estää SQL-injektion ja mahdollistaa kyselyoptimointiin.

**Partial dependency (Osittainen riippuvuus)** — 2NF-rikkomus: ei-avainattribuutti riippuu vain osasta yhdistetystä pääavaimesta. Aiheuttaa päällekkäisyyttä.

**Partial index (Osittainen indeksi)** — Indeksi, joka tallentaa vain ehdon täyttävät rivit. Pienempi ja nopeampi kun kysytään aina osajoukkoa.

**Password hashing (Salasanan hashaus)** — Salasanojen yksisuuntainen muunnos ennen tallennusta. Käytä bcrypt, Argon2 tai PBKDF2. Älä koskaan tallenna salasanoja selkotekstinä.

**Persistence (Pysyvyys)** — Datat säilyvät ohjelman uudelleenkäynnistyksen, palvelimen uudelleenkäynnistyksen ja sähkökatkosten jälkeen. Keskeinen tietokantojen etu.

**Physical data model (Fyysinen datamalli)** — Datamallinnuksen matalin taso: todellinen toteutus taulujen, saraketyyppien, viiteavaimien, rajoitteiden ja indeksien kanssa. SQL DDL.

**Polyglot persistence (Polyglottipysyvyys)** — Erilaisten tietokantojen käyttö eri tarpeisiin (esim. relaatiot transaktioille, hakukone full-text:lle, välimuisti suorituskyvylle).

**Primary key (PK) (Pääavain)** ★ — Taulun rivien päätunniste. Oltava yksilöllinen, NOT NULL, vakaa ja minimaalinen. Vain yksi per taulu (voi olla yhdistetty).

**Privilege (Käyttöoikeus)** ★ — Roolille myönnetty oikeus (SELECT, INSERT, UPDATE, DELETE, USAGE, CREATE). Hallitaan GRANT- ja REVOKE-lauseilla.

---

## Q

**Query optimizer / Query planner (Kyselysuunnittelija)** — Tietokannan komponentti, joka päättää *miten* kysely suoritetaan (yhdistämisjärjestys, indeksien käyttö, rinnakkaisuus). Mahdollistaa deklaratiivisen SQL:n tehokkuuden.

**Query plan (Kyselysuunnitelma)** — Vaiheet, joita tietokanta käyttää kyselyn suorittamiseen. Näytetään EXPLAIN-komennolla.

---

## R

**RBAC (Roolipohjainen pääsynhallinta)** — Role-Based Access Control. Valtuutus käyttäjäroolien perusteella; jokainen rooli merkitsee joukkoa käyttöoikeuksia.

**RDBMS** — Relational Database Management System. Järjestelmä, joka tallentaa dataa tauluihin ja tukee SQL:ää (esim. PostgreSQL, MySQL).

**Record (Tietue)** — Katso *Row*.

**Recovery (Palautuminen)** — Tietokannan palauttaminen johdonmukaisiin tilaan kaatumisen jälkeen. Saavutetaan lokituksella (esim. WAL PostgreSQLissa).

**Redundancy (Päällekkäisyys)** ★ — Sama fakta tallennettuna useaan paikkaan. voi aiheuttaa päivitys-, lisäys- ja poistoanomalioita.

**REFERENCES** — SQL-avainsana, joka luo viiteavaimen. Varmistaa, että sarakearvo on olemassa viitatussa taulussa.

**Referential integrity (Viite-eheys)** ★ — Sääntö, jonka mukaan jokaisen viiteavaimen arvon täytyy viitata olemassa olevaan riviin viitatussa taulussa (tai olla NULL jos sallittu). Tietokanta valvoo tätä automaattisesti.

**Relation (Relaatio)** ★ — Relaatiomallissa: taulu. Rakenteellisten faktojen kokoelma tietystä asiasta. Sillä on nimi, attribuutit (sarakkeet) ja tuplet (rivit).

**Relational model (Relaatiomalli)** ★ — Suunnittelufilosofia ja matemaattinen viitekehys relaatiotietokantojen takana. Käsittelee dataa relaatioina (tauluina) avaimilla, rajoitteilla ja logiikkaan perustuvilla operaatioilla. Esitteli E. F. Codd.

**Relationship (Suhde)** ★ — Kahden entiteetin välinen yhteys. Kuvaa miten ne liittyvät (esim. Student suorittaa Coursen). Sillä on kardinaliteetti ja valinnallisuus.

**REVOKE** — SQL-lause, joka poistaa käyttöoikeudet roolilta.

**Right join (Oikea ulkoinen yhdistäminen)** — Sama kuin LEFT JOIN mutta pitää kaikki oikean taulun rivit. Harvoin tarvitaan; voidaan kirjoittaa uudelleen vaihtamalla taulujen järjestys.

**ROLLBACK** ★ — SQL-avainsana transaktion päättämiseen ja kaikkien siinä tehtyjen muutosten hylkäämiseen.

**Role (Rooli)** ★ — PostgreSQLissa: identiteetti, joka voi omistaa objekteja ja saada käyttöoikeuksia. Voi olla kirjautumisrooli (käyttäjä) tai ryhmärooli.

**Row (Rivi)** ★ — Yksittäinen tietue taulussa. Relaatiomallissa sama kuin *tuple*. Edustaa yhtä entiteettiesiintymää.

---

## S

**Savepoint (Tallennuspiste)** — Nimetty piste transaktion sisällä. Voit tehdä rollbackin savepointiin ilman koko transaktion rollbackia.

**Schema (Skeema)** ★ — (1) Tietokannan rakenne: taulut, sarakkeet, rajoitteet jne. (2) PostgreSQLissa: nimiavaruus objektien järjestämiseen (esim. `public`). Kuin kansio.

**Second Normal Form (2NF) (Toinen normaalimuoto)** ★ — Taulu on 2NF:ssä jos se on 1NF:ssä ja sillä ei ole osittaisia riippuvuuksia: jokainen ei-avainattribuutti riippuu *koko* pääavaimesta.

**SELECT** ★ — SQL-lause, joka lukee dataa tauluista. Voi suodattaa (WHERE), lajitella (ORDER BY), koostaa (COUNT, SUM jne.) ja ryhmitellä (GROUP BY).

**Selectivity (Selektiivisyys)** — Kuinka monella rivillä on sama arvo. Korkea selektiivisyys (esim. yksilöllinen sähköposti) → hyvä indekseille. Matala selektiivisyys (esim. arvosana 0–5) → indeksi ei välttämättä auta.

**Self-join (Itsensä yhdistäminen)** — Taulun yhdistäminen itseensä. Käyttää eri aliaksia "vasemmalle" ja "oikealle" kopiolle. Yleistä hierarkioissa (esim. työntekijät ja esimiehet).

**Sequence (Sekvenssi)** — Tietokantaobjekti, joka generoi yksilöllisiä numeerisia arvoja. Käytetään automaattisesti kasvaviin ID:ihin.

**Sequential scan (Seq Scan) (Peräkkäishaku)** — Jokaisen taulun rivin lukeminen ja suodatus. Indeksihaun vastakohta. Käytetään kun indeksi ei auttaisi tai sitä ei ole.

**SET NULL** — ON DELETE- tai ON UPDATE -toimenpide: aseta viiteavain NULL:ksi lapseen riveissä kun vanhempi poistetaan/päivitetään. Vaatii nullable FK -sarakkeen.

**Single-valued attribute (Yksiarvoinen ominaisuus)** — Attribuutti, jolla on yksi arvo per entiteetti (esim. syntymäpäivä).

**SQL** ★ — Structured Query Language. Deklaratiivinen kieli relaatiodatan kyselyyn ja muokkaukseen. Kuvaat *mitä* haluat; tietokanta päättää *miten* se suoritetaan.

**SQL injection (SQL-injektio)** — Turvallisuushaavoittuvuus, jossa haitallinen syöte ketjutetaan SQL:ään ja suoritetaan. Estetään parametrisoiduilla kyselyillä.

**Statement (Lause)** — Yksi täydellinen SQL-ohje, joka päättyy `;`:ään.

**Subquery (Alakysely)** — Toisen kyselyn sisällä oleva kysely. Voidaan käyttää WHERE-, FROM- tai SELECT-lauseissa.

**Surrogate key (Sijaistunniste)** — keinotekoisesti generoitu tunniste (esim. autokasvava ID) ilman liiketoimintamerkitystä. Suositellaan luonnollisten avaimien sijaan kun luonnolliset avaimet voivat muuttua.

**System of record (Totuuden lähde)** — Auktoritatiivinen totuuden lähde jollekin toimialalle (esim. maksujen kirja, tilaukset). Vaativat vahvoja oikeellisuustakuita ja auditointikykyä.

---

## T

**Table (Taulu)** ★ — Rakenteellinen riveistä ja sarakkeista koostuva kokoelma. Pääasiallinen tallennusrakenne relaatiotietokannoissa. Edustaa relaatiota.

**Ternary relationship (Kolmiosainen suhde)** — Kolmea entiteettiä käsittävä suhde (esim. Lääkäri hoitaa Potilasta Sairaalassa). Monimutkaisempi; usein tarvitsee liitostaulun.

**Third Normal Form (3NF) (Kolmas normaalimuoto)** ★ — Taulu on 3NF:ssä jos se on 2NF:ssä ja sillä ei ole transitiivisia riippuvuuksia: mikään ei-avainattribuutti ei riipu toisesta ei-avainattribuutista.

**Token (Tokeni)** — Tunniste (esim. JWT), joka tunnistaa käyttäjän myöhemmille pyynnöille todentamisen jälkeen. Vaihtoehto istuntoevästeille.

**Transaction (Transaktio)** ★ — Looginen työn yksikkö: yksi tai useampi SQL-lause käsiteltynä yhtenä yksikkönä. Joko kaikki onnistuvat tai mikään ei. Hallitaan BEGIN-, COMMIT- ja ROLLBACK-lauseilla.

**Transitive dependency (Transitiivinen riippuvuus)** — 3NF-rikkomus: ei-avainattribuutti riippuu toisesta ei-avainattribuutista (esim. teacher_name riippuu teacher_id:stä, joka riippuu course_id:stä).

**Tuple** — Relaatiomallissa: rivi. Yksi täydellinen tietue relaatiossa. Sisältää yhden arvon jokaiselle attribuutille.

**Type** — Katso *Data type*.

---

## U

**UNIQUE** — Rajoite: kahdella rivillä ei saa olla samaa arvoa/arvoja rajoitetuissa sarakkeissa.

**Unique index (Yksilöivä indeksi)** — Indeksi, joka pakottaa yksilöllisyyden. Luodaan automaattisesti PRIMARY KEY- ja UNIQUE-rajoitteille.

**Update anomaly (Päivitysanomalia)** — Normalisointiongelma: jos sama fakta tallennetaan moniin riveihin, sen päivittäminen yhdessä paikassa jättää muut vanhentuneiksi. Johtaa epäjohdonmukaiseen dataan.

**UPDATE** ★ — SQL-lause, joka muuttaa olemassa olevia rivejä. Käyttää SET:ää uusille arvoille ja WHERE:tä määrittämään mitkä rivit. WHERE:n pois jättäminen päivittää kaikki rivit.

**User (Käyttäjä)** — PostgreSQLissa: rooli, jolla on LOGIN ja joka voi yhdistää. Sovelluskontekstissa: sovelluskäyttäjä (omissa tauluissasi).

**USING** — SQL-lause JOINeissa kun molemmilla tauluilla on sama sarakenimi yhdistämistä varten. Lyhenne sille, että ON left.col = right.col.

---

## V

**Vertical scaling (scale up) (Pystysuuntainen skaalaus)** — Kapasiteetin lisääminen tekemällä yhdestä koneesta isompi (enemmän CPU:a, RAMia, nopeampi levy).

**View (Näkymä)** — Tallennettu "ikkuna" dataan—tallennettu kysely. Toimii kuin virtuaalitaulu. Voi yksinkertaistaa kyselyjä ja hallita pääsyä.

---

## W

**WAL** — Write-Ahead Logging. PostgreSQL tallentaa muutokset lokiin ennen soveltamista dataan. Mahdollistaa kestävyyden ja palautumisen.

**WHERE** ★ — SQL-lause, joka suodattaa mitkä rivit sisällytetään tulokseen. Sovelletaan ennen GROUP BY:tä.

**Wildcard (Jokerimerkki)** — Kuviovertailussa: `%` (mikä tahansa pituus) ja `_` (yksi merkki) LIKE-lauseissa.

---

## Liittyvät materiaalit

Tämä sanasto kattaa termit seuraavista materiaaleista:

- 00 – Johdanto (Introduction)
- 01 – Datan mallinnus (Data Modelling)
- 02 – ER-kaaviot (ER Diagrams)
- 03 – Relaatiotietokanta (Relational Database)
- 04 – PostgreSQL
- 05–07 – SQL-perusteet (SQL Fundamentals)
- 08 – Normalisointi ja skeeman laatu (Normalization and Schema Quality)
- 09 – Transaktiot ja datan muokkaus (Transactions and Data Modification)
- 10 – Indeksit ja indeksointi (Indexes and Indexing)
- 11 – Käyttäjät ja roolit (Users and Roles)
- 12 – Tietokannat ohjelmoinnissa (Databases in Programming)
- 13 – ORM ja EF Core (Entity Framework Core)
- 14 – Käyttäjien ja roolien hallinta ohjelmoinnissa (Managing Users and Roles in Programming)
- 99 – Yleiset virhekäsitykset (Common Misconceptions)

