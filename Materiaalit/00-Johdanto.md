### Mikä on tietokanta?

**Tietokanta** on **hallittu kokoelma pysyvää dataa** sekä **mekanismit ja säännöt**, joilla dataa tallennetaan, haetaan ja pidetään oikeellisena ja turvallisena todellisissa olosuhteissa (samanaikaisuus, vikatilanteet, kasvu).

Toisin sanottuna: tietokanta on *data + sopimus* (säännöt siitä, miten käyttäjät saavat käyttää tallennettua/olemassa olevaa dataa).

Tuo “sopimus” sisältää yleensä:

* **Tietomallin** (taulut, dokumentit, graafi jne.)
* **Kyselyrajapinnan** (SQL, API:t, hakukyselyt)
* **Eheys- ja validointisäännöt** (rajoitteet, validointi, relaatiot)
* **Samanaikaisuuden hallinnan** (jotta moni käyttäjä voi lukea/kirjoittaa turvallisesti)
* **Pysyvyyden ja palautumisen** (jotta commitit säilyvät kaatumisista huolimatta)
* **Tietoturvan ja hallinnan** (käyttöoikeudet, auditointi, salaus)
* **Operatiiviset ominaisuudet** (varmuuskopiointi/palautus, replikaatio, monitorointi)

**Esimerkki:**
Relaatiotietokanta, joka tallentaa `Customers`- ja `Orders`-tauluja, ei ole vain tiedostoja riveineen – se valvoo viite-eheyksiä (foreign keys), tukee kyselyitä kuten “liikevaihto kuukausittain”, ja pystyy palautumaan yhtenäiseen tilaan sähkökatkon jälkeen.

---

### Mitä on data?

Tietokannoissa **data** on *tallennettuja esityksiä faktoista tai havainnoista* – se säilytetään rakenteisessa muodossa, jotta järjestelmä voi **hakea, validoida, yhdistää ja käsitellä** sitä luotettavasti.

Vähän “tietokantamaisempi” muotoilu:

**Data** on **pysyvästi talletettuja symboleja** (luvut, teksti, aikaleimat, tunnisteet jne.), joita tietokanta hallitsee **arvoina tietomallin sisällä** (tauluissa, dokumenteissa, graafeissa). Arvot saavat merkityksensä esimerkiksi seuraavista:

* **Skeema/rakenne** (esim. sarake `birth_date` oletetaan päivämääräksi)
* **Rajoitteet** (esim. `order_total >= 0`, viiteavaimet)
* **Relaatiot** (esim. `orders.customer_id → customers.id`)
* **Konteksti/metatiedot** (yksiköt, merkistökoodaus, aikavyöhyke, alkuperä)

#### Pikaesimerkkejä

* `42` on pelkkä arvo. Tietokannassa siitä tulee dataa, kun se asetetaan kontekstiin:

  * `customers.id = 42` (tunniste)
  * `age = 42` (mitta, jolla on merkitys/yksikkö)
  * `invoice_total = 42.00` (valuuttasumma)

* Rivi kuten:

  * `Orders(id=1001, customer_id=42, total=59.90, created_at="2026-01-05T10:12:00Z")`
    on dataa, koska se tallentaa faktoja (tilaus tapahtui) rakenteisessa ja kyseltävässä muodossa.

#### Hyödyllinen erottelu (yleinen tietokantakeskusteluissa)

* **Data:** tallennetut esitykset (”symbolit”).
* **Informaatio:** data tulkittuna kontekstissa (esim. “asiakas 42 käytti tänään 59,90 €”).
* **Tietämys:** informaatiosta johdetut yleistykset (esim. “segmentin X asiakkaat ostavat tyypillisesti viikoittain”).

---

### Metatieto??

**Metatieto (metadata)** on **tietoa tiedosta**: se kuvaa, mitä tallennettu data *tarkoittaa*, miten se on *rakennettu*, mistä se on peräisin ja miten sitä pitäisi *käsitellä*.

Tietokannan näkökulmasta metatieto vastaa kysymyksiin kuten:

* *Mikä tämä kenttä on?* (nimi, tyyppi, yksiköt, sallitut arvot)
* *Miten data on järjestetty?* (taulut/kokoelmat, indeksit, partitiointi)
* *Miten se liittyy muuhun?* (avaimet, relaatiot)
* *Mistä se tuli?* (lähdejärjestelmä, ingest-aika, lineage)
* *Miten sitä saa käyttää?* (oikeudet, säilytysajat, luokittelu)

#### Metatiedon esimerkkejä

**Skeemametatieto (rakenne)**

* Taulu: `Orders`
* Sarake: `created_at TIMESTAMP NOT NULL`
* Rajoite: `total >= 0`
* Relaatio: `orders.customer_id → customers.id`

**Operatiivinen metatieto (miten se tallennetaan/palvellaan)**

* Indeksi: `idx_orders_created_at`
* Partitiointi: “Orders partitioitu kuukausittain”
* Replikaatio: “3 replikaa, yksi leader”
* Tilastot: rivimäärät, arvojakaumat (kyselyoptimoija käyttää)

**Hallinnan metatieto (miten sitä kontrolloidaan)**

* Käyttösäännöt: “Vain finance-rooli saa lukea `salary`”
* Luokittelu: “PII” / “luottamuksellinen”
* Säilytys: “Pidä lokit 90 päivää”

**Alkuperä/lineage-metatieto (mistä se tuli)**

* “Tämä sarake tulee Salesforcen yöajosta”
* “Tämän taulun tuottaa ajotyö X klo 02:00”

---

### Data vs. metatieto

* **Data:** `total = 59.90`
* **Metatieto:** `total` on desimaalimuotoinen valuuttasumma euroissa, ei-negatiivinen, tallennetaan `Orders.total`-sarakkeeseen, indeksoitu raportointia varten, roolit A/B pääsevät siihen, säilytetään 7 vuotta.

---

## Miksi tietokannat kehitettiin

Ennen tietokantoja monet järjestelmät käyttivät **tiedostoja** (flat file -tiedostot, ISAM, räätälöidyt binääriformaatit). Tämä ajautuu nopeasti toistuviin ongelmiin:

1. **Datan kopioituminen ja epäjohdonmukaisuus**
   Sama asiakas on useissa tiedostoissa; yksi päivitys jää tekemättä; todellisuus “haarautuu”.

2. **Kovakoodatut käyttötavat**
   Jos tiedostomuoto on tehty “haku asiakastunnuksella” -tarpeeseen, uusi tarve kuten “parhaat asiakkaat kulutuksen mukaan viime kvartaalilla” on työläs tai mahdoton ilman massiivista uudelleenkirjoitusta.

3. **Samanaikaisuus ja oikeellisuus**
   Kaksi henkilöä muokkaa samaa tietuetta yhtä aikaa → kilpailutilanteita, korruptiota, päivitysten häviämistä.

4. **Palautuminen vikatilanteista**
   Sähkökatko kesken kirjoituksen voi jättää datan puoliksi päivitetyksi. Tarvitaan lokitus, atomisuus ja crash recovery.

5. **Tietoturva ja auditointi**
   Tiedostot eivät luonnostaan tarjoa hienojakoisia oikeuksia, levysalausta tai audit-lokeja.

6. **Skaalaus ja suorituskyky**
   Kun data kasvaa, tarvitaan indeksejä, välimuististrategioita, partitiointia, replikaatiota ja kyselysuunnittelua.

Tietokannat syntyivät **keskittämään datanhallinnan** omaksi osa-alueekseen, jossa samat lupaukset ja takuut voidaan toteuttaa uudelleenkäytettävästi – jotta jokaisen sovellustiimin ei tarvitse keksiä uudelleen haurasta tallennus- ja kyselylogiikkaa.

---

## Tietokantojen lyhyt historia

### 1) Tiedostopohjainen datanhallinta (1950–1960-luku)

**Mikä se oli:** Data tallennettiin flat file -tiedostoihin tai omiin binääriformaatteihin. Jokainen sovellus “omisti” tiedostonsa ja tiesi tarkalleen, miten niitä luetaan ja kirjoitetaan.

**Miksi se oli olemassa:** Levytila oli kallista, laskentateho rajallista ja ohjelmien tarpeet usein kapeita.

**Miksi se alkoi hajota:**

* Jokainen uusi raportti vaati uutta koodia.
* Datan kopioituminen ja epäjohdonmukaisuus olivat yleisiä.
* Samanaikaisuus ja kaatumisista palautuminen olivat usein ad hoc -toteutuksia (ja usein turvattomia).

**Tunnettu malli:** *ISAM* (Indexed Sequential Access Method) ja vastaavat: hyvä suorituskyky tietyille hakupoluille, mutta joustamaton uusille.

---

### 2) Hierarkkiset tietokannat (1960–1970-luku)

**Mikä se oli:** Data mallinnettiin **puuna** (vanhempi → lapsi).

**Miksi se auttoi:** Jos maailma on luonnostaan hierarkkinen (esim. “yritys → osastot → työntekijät”), saadaan ennustettavaa ja nopeaa navigointia.

**Rajoitukset:** Moni–moni-suhteet ovat kömpelöitä (esim. “opiskelijat ↔ kurssit”). Kyselyt ovat usein “kävele puuta”, mikä sitoo sovelluksen tietorakenteeseen.

---

### 3) Verkko-/CODASYL-tietokannat (1960-luvun loppu – 1970-luku)

**Mikä se oli:** Data mallinnettiin tietueina, joita yhdistivät **eksplisiittiset linkit/osoittimet** (graafimainen rakenne).

**Miksi se auttoi:** Joustavampi kuin puu; moni–moni-suhteet olivat mallinnettavissa.

**Rajoitukset:** Yhä *navigointipohjainen*: sovellus kulkee ennalta määrättyjä polkuja. Jos kysymys muuttuu, koodi muuttuu. Fyysinen toteutus “vuotaa” sovelluslogiikkaan.

---

### 4) Relaatiomalli + SQL (1970–1980-luku)

**Suuri muutos:** Siirryttiin “kerro miten navigoin dataan” → “kerro mitä dataa haluat”.
**Avainideat:**

* Data **relaatioina (tauluina)**
* **Deklaratiivinen kysely** (SQL)
* **Fyysinen riippumattomuus**: indeksejä/tallennusta voidaan muuttaa ilman kyselyiden muuttamista
* **Rajoitteet** (avaimet, viiteavaimet, checkit)
* **Transaktiot** ja palautuminen sisäänrakennettuna

**Miksi relaatiomalli voitti:** Se teki tietokannoista *yleiskäyttöisiä*, mahdollisti *ad hoc -kyselyt* ja antoi optimoijalle mahdollisuuden valita tehokkaita suorituspolkuja automaattisesti.

#### Deklaratiivinen kysely

Kuvaat halutun lopputuloksen, et vaiheittaista menettelyä.
Vastakohta: navigointiin/proseduraaliseen käyttöön perustuva lähestyminen, jossa kuljetaan osoittimia tai silmukoita pitkin.

#### SQL (Structured Query Language)

**Deklaratiivinen** kieli relaatiodatan kyselyyn ja muokkaukseen. Kuvaat *mitä* haluat, ja tietokanta päättää *miten* se toteutetaan tehokkaasti.

#### Indeksi

Tietorakenne, joka nopeuttaa hakuja (kuin kirjan hakemisto).
Yleisiä tyyppejä:

* **B-puu (B-tree):** hyvä aluekyselyihin ja yleiseen OLTP:hen
* **LSM-puu:** hyvä suureen kirjoitusläpäisyyn (yleinen monissa hajautetuissa/NoSQL-järjestelmissä)
* **Käänteinen indeksi (inverted index):** täyden tekstin hakuun
* **Vektori-indeksi:** lähimmän naapurin samankaltaisuushakuun

#### Transaktio

Looginen työyksikkö (esim. “siirrä rahaa A:lta B:lle”), jonka pitää toimia oikein myös vikatilanteissa ja monen käyttäjän toimiessa yhtä aikaa.

#### Ad hoc -kyselyt

Uusien kysymysten esittäminen **lennosta** ilman valmiiksi rakennettuja raportteja tai koodipolkuja.
Esim. “Näytä Helsingissä olevat asiakkaat, jotka ostivat tuotteen X viimeisen 30 päivän aikana ja joiden churn-riski > 0,7.”
Relaatiotietokannoissa tämä on käytännöllistä SQL:n ja kyselyoptimoinnin ansiosta.

---

### 5) Transaktiokäsittely keskiöön (1980–1990-luku)

Kun tietokannoista tuli liiketoimintajärjestelmien ydin, keskityttiin mm.:

* suureen samanaikaisuuteen (paljon yhtäaikaisia käyttäjiä)
* eristykseen ja oikeellisuuteen kuormassa
* lokitukseen ja palautumiseen
* parempiin indekseihin ja kyselysuunnitteluun

Tällä aikakaudella ajatus “tietokanta = luotettava järjestelmän totuuden lähde” vakiintui.

#### Samanaikaisuuden hallinta

Mekanismit, joilla transaktiot pidetään oikeina, kun niitä ajetaan yhtä aikaa. Yleisiä:

* **Lukitus** (ristiriitaiset operaatiot estetään)
* **MVCC** (Multi-Version Concurrency Control): lukijat näkevät johdonmukaisen tilannekuvan, kirjoittajat luovat uusia versioita.

#### Kyselyoptimoija / kyselysuunnittelu

Tietokannan osa, joka valitsee *miten* kysely suoritetaan (join-järjestys, indeksien käyttö, rinnakkaisuus). Tämä on yksi syy siihen, miksi deklaratiivinen SQL voi olla nopeaa.

---

### 6) Tietovarastot ja OLAP (1990–2000-luku)

Organisaatiot halusivat analytiikkaa valtavista historiadatoista: “Miten myynti jakautui alueittain 5 vuoden aikana?”
Tämä eroaa operatiivisista kuormista (tilausten teko, tilien päivitys).

**Tietovarasto/OLAP-trendejä:**

* data kopioidaan operatiivisista järjestelmistä analyyttiseen varastoon (ETL/ELT)
* skeemat kuten tähti-/lumihiutalemalli
* raskas aggregointi, skannaukset ja joinit suurilla datamassoilla
* siirtymä kohti **sarakepohjaista tallennusta** analytiikan nopeuttamiseksi

#### OLAP (Online Analytical Processing)

Kuormat, joissa tehdään **laajoja skannauksia ja aggregointeja** suuren datan yli.
Esim. dashboardit, trendit, kohorttianalyysi, “myynti alueittain 5 vuoden ajalta”.

#### Tietovarasto (data warehouse)

Järjestelmä, joka on optimoitu OLAP:lle ja sisältää usein siivottua/yhdistettyä historiadataa useista lähteistä. Tyypillisesti analytiikan “yksi paikka”.

#### Sarakepohjainen tallennus (columnar storage)

Data tallennetaan **sarakkeittain** rivien sijasta.
Hyvä OLAP:lle, koska kyselyt lukevat usein muutaman sarakkeen monista riveistä ja aggregoivat; lisäksi pakkaus toimii hyvin.

---

### 7) Web-mittakaava + NoSQL (2000-luvun puoliväli – 2010-luku)

Massiivinen liikenne ja hajautus paljastivat perinteisten “skaalaa ylöspäin” -relaatiomallien rajoja:

* tarvittiin helpompaa horisontaalista skaalausta, korkeaa käytettävyyttä ja joustavia skeemoja
* moni järjestelmä vaihtoi tiukan johdonmukaisuuden parempaan saatavuuteen/viiveeseen hajautetuissa ympäristöissä

NoSQL ei ole yksi asia, vaan joukko malleja (avain–arvo, dokumentti, wide-column, graafi), joista kukin optimoi eri käyttötapauksia.

#### Horisontaalinen skaalaus (scale out)

Kapasiteetin kasvattaminen **lisäämällä koneita** ja jakamalla data/työ niiden kesken.

#### Vertikaalinen skaalaus (scale up)

Kapasiteetin kasvattaminen **tekemällä yhdestä koneesta suurempi** (enemmän CPU/RAM/nopeampi levy).

---

### 8) Hajautettu SQL / “NewSQL” (2010-luku – nykyhetki)

Vastaliike: “Haluamme **SQL + ACID**, mutta myös **horisontaalisen skaalauksen** ja monialueisen (multi-region) kestävyyden.”
Modernit hajautetut SQL-järjestelmät pyrkivät säilyttämään relaatiomallin ja transaktiotakuut, mutta jakamaan tallennuksen ja laskennan solmuille.

#### ACID

Transaktioiden joukko takuita (transaktio = lukuja/kirjoituksia yhtenä kokonaisuutena).

* **Atomicity (atomisuus):** kaikki tai ei mitään.
* **Consistency (johdonmukaisuus):** rajoitteet ja säännöt pitävät kannan validina.
* **Isolation (eristys):** rinnakkaiset transaktiot eivät aiheuta epätoivottuja poikkeamia.
* **Durability (pysyvyys):** commitin jälkeen muutokset säilyvät kaatumisista huolimatta (lokitus, replikaatio jne.).

#### Eristystasot (isolation levels)

Eri “vahvuuksia” eristykselle (vaihtokauppa oikeellisuuden ja suorituskyvyn välillä).
Esim. read committed, repeatable read, snapshot isolation, serializable.

---

### 9) Erikoistumisen räjähdys (2010-luku – nykyhetki)

Pilvi, halpa tallennus ja orkestrointi helpottivat useiden erikoistuneiden järjestelmien käyttöä:

* aikasarjatietokannat observabilityyn/IoT:hen
* hakumoottorit täyteen tekstihakuun + suodatukseen
* stream-prosessorit / event storet
* vektorikannat upotesimilariteettiin (AI-kuormat)

Nykyarkkitehtuureissa käytetään usein **polyglot persistence** -mallia: eri tarpeisiin eri tietokannat, jotka yhdistetään putkistoilla.

---

## Nykyisin yleiset tietokantatyypit

### 1) Relaatiotietokannat (RDBMS)

**Malli:** taulut + relaatiot
**Vahvuudet:** vahva eheys, ACID-transaktiot, SQL, kypsät työkalut
**Parhaiten:** liiketoimintajärjestelmät, talous, tilaukset, varasto – kaikki missä oikeellisuus ja rajoitteet ovat tärkeitä

Keskeisiä ominaisuuksia:

* skeema, normalisointi, rajoitteet
* transaktiot, lukitukset tai MVCC
* kyselysuunnittelija/optimoija
* sekundääri-indeksit

### 2) Hajautettu SQL (usein “NewSQL”)

**Malli:** relaatiomalli + SQL
**Vahvuudet:** horisontaalinen skaala + ACID + tuttu SQL
**Parhaiten:** globaalit sovellukset, jotka tarvitsevat vahvan oikeellisuuden ja monialueisen kestävyyden

Kompromisseja:

* monimutkaisempi operointi
* joissain asetuksissa korkeampi kirjoitusviive konsensuksen/replikaation vuoksi

### 3) Avain–arvo-tietokannat (key-value)

**Malli:** avain → läpinäkymätön arvo
**Vahvuudet:** erittäin nopeat perusoperaatiot, helppo skaalaus
**Parhaiten:** välimuisti, sessiot, laskurit, feature flagit, yksinkertaiset haut

Kompromissi:

* rajallinen kyselyilmaisu, ellei mukana ole sekundääri-indeksoinnin lisäominaisuuksia

### 4) Dokumenttitietokannat

**Malli:** dokumentit (usein JSON/BSON)
**Vahvuudet:** joustava skeema, luonnollinen sovellusolioille, sisäkkäinen data
**Parhaiten:** sisällönhallinta, katalogit, eventit, nopeasti muuttuvat tuoteominaisuudet

Kompromisseja:

* joinit ja dokumenttien väliset rajoitteet usein heikompia kuin relaatiokannoissa
* datan kopioituminen voi hiipiä mukaan, jos suunnittelu ei ole huolellista

### 5) Wide-column / column-family -tietokannat

**Malli:** rivit, joilla voi olla valtavasti harvoja sarakkeita, ryhmiteltynä perheisiin
**Vahvuudet:** suuri kirjoitusläpäisy, iso hajautettu tallennus, ennustettavat käyttötavat
**Parhaiten:** massiiviset lokit, telemetria, suuret harvat datasetit, isot hajautetut kuormat

Kompromisseja:

* mallinnat kyselyt ensin; joustavuus pienempi kuin relaatiomallissa
* transaktiot ja ad hoc -kyselyt vaihtelevat järjestelmittäin

### 6) Graafitietokannat

**Malli:** solmut + kaaret + ominaisuudet
**Vahvuudet:** suhteiden läpikäynti, polkukyselyt, suosittelut, verkostoanalyysi
**Parhaiten:** sosiaaliset verkot, petosverkostot, tietämysgraafit, riippuvuuskartat

Kompromisseja:

* osa graafikyselyistä on kalliita suuressa mittakaavassa ilman huolellista mallinnusta
* usein rinnalla käytetään muita kantoja ei-graafiseen dataan

### 7) Aikasarjatietokannat (time-series)

**Malli:** mittaukset ajan yli (aikaleima + tagit + arvot)
**Vahvuudet:** pakkaus, downsampling, säilytyspolitiikat, nopeat aggregoinnit aikajaksoissa
**Parhaiten:** metriikat, observability, IoT, finanssidata (tickit)

Kompromissi:

* ei ihanteellinen vahvasti relaatiopohjaiseen liiketoimintadataan

### 8) Sarakepohjaiset analyyttiset tietokannat (OLAP)

**Malli:** usein “relaatiomainen”, mutta tallennus sarakkeittain
**Vahvuudet:** erittäin nopeat skannaukset/aggregoinnit, pakkaus, vektorisoitu suoritus
**Parhaiten:** BI, analytiikka, dashboardit, tietovarastot/data lake -ratkaisut

Kompromissi:

* ei optimoitu tiheään tehtäviin pieniin transaktiopäivityksiin

### 9) Hakumoottorit tietokantoina (täysteksti + relevanssi)

**Malli:** käänteinen indeksi + dokumentit
**Vahvuudet:** täystekstihaku, ranking, sumea haku, facetit/suodattimet
**Parhaiten:** sivustohaku, lokien tutkiminen, dokumenttihaku, observability-haku

Kompromissi:

* ei korvaa transaktiototuutta; usein “johdettu” lähdejärjestelmän datasta

### 10) In-memory-tietokannat

**Malli:** vaihtelee (usein avain–arvo tai relaatiomalli), mutta ensisijainen tallennus on RAM
**Vahvuudet:** erittäin pieni viive
**Parhaiten:** välimuisti, reaaliaikaiset leaderboardit, väliaikainen tila, joskus nopea OLTP

Kompromisseja:

* pysyvyys vaatii snapshotit/lokituksen; muistin hinta ja vikamallit korostuvat

### 11) Vektorikannat (AI-aikakausi)

**Malli:** vektorit (embeddingit) + metatieto
**Vahvuudet:** samankaltaisuushaku (lähimmät naapurit), hybridhaku (vektori + suodattimet/teksti)
**Parhaiten:** semanttinen haku, RAG-järjestelmät, suosittelu, deduplikointi, klusterointi

Kompromissi:

* harvoin transaktionaalinen “järjestelmän totuuden lähde”; tyypillisesti rinnalla relaati-/dokumenttikanta

#### “System of record”

Jonkin osa-alueen auktoritatiivinen totuuden lähde (esim. maksukirjanpito, tilaukset). Vaatii yleensä vahvat oikeellisuustakuut ja auditoinnin.
