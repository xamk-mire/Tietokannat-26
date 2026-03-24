# Media-tiedostot tietokannoissa (media files databases)

### Mitä ne ovat ja miten niitä tyypillisesti käsitellään

[Materiaalissa 03](./03-Relaatiotietokanta.md) esittelimme relaatiomallin (relational model) ja yleiset datatyypit (data types) (kokonaisluvut, teksti, päivämäärät).  
[Materiaaleissa 05](./05-SQL-perusteet.md)–[07](./07-SQL-perusteet-3.md) työskentelimme rakennetun datan (structured data) kanssa tauluissa (tables).

Tässä luvussa esitellään **media-tiedostot (media files)** tietokantayhteydessä:

- **Mitä media-tiedostot ovat** — määrittely, tyypit ja ominaisuudet
- **Miksi ne eroavat** — haasteet verrattuna rakennettuun dataan (structured data)
- **Tallennuslähestymistavat (storage approaches)** — tallennus tietokantaan vs. tiedostojärjestelmään (file system)
- **Skeemasuunnittelumallit (schema design patterns)** — miten mallinnetaan ja viitataan mediaan tauluissa
- **Parhaat käytännöt (best practices) ja kompromissit (trade-offs)** — kokorajat (size limits), varmuuskopiot (backups), suorituskyky (performance) ja turvallisuus (security)

---

# 1) Mitä media-tiedostot (media files) ovat?

**Media-tiedostot (media files)** ovat binääri- tai puolistrukturoituja tiedostoja (binary or semi-structured files), jotka edustavat äänen, kuvan tai dokumenttisisällön sisältöä. Ne esiintyvät kaikkialla nykysovelluksissa: profiilikuvat, tuotekuvat, podcast-jaksot, videotutoriaalit, ladattavat PDF-tiedostot ja skannatut dokumentit. Toisin kuin rakennek data (structured data) (numerot, teksti, päivämäärät), jota tallennamme tyypillisiin tietokantasarakkeisiin (database columns), media-tiedostoilla on erottuvia ominaisuuksia, jotka vaikuttavat tallentamiseen, hakuun ja hallintaan.

---

## Media-tiedostojen määrittävät ominaisuudet (defining characteristics)

Media-tiedostot eroavat pelkästä tekstistä ja numeerisesta datasta useilla tärkeillä tavoilla:

### Koko (size)

- Media-tiedostot vaihtelevat **kilotavuista (kilobytes)** (pienet kuvakkeet, pikkukuvat (thumbnails)) **gigatavuihin (gigabytes)** (raaka video, korkean resoluution skannaukset).
- Yksi älypuhelimen kuva voi olla 3–10 MB; kokopitkä elokuva voi olla useita gigatavuja.
- Tietokantasarakkeet (database columns) on yleensä suunniteltu arvoille, jotka mitataan tavuista muutamaan kilotavuun. Isot media-blobit (media blobs) rasittavat tallennustilaa (storage), varmuuskopiota (backup) ja kyselysuorituskykyä (query performance).

### Binääritallennus (binary storage)

- Media-sisältö tallennetaan **raakoina tavuina (raw bytes)** — binääridatana (binary data), jota ei ole tarkoitettu luettavaksi ihmisen luettavana tekstinä.
- Jotkut muodot (esim. SVG, XML-pohjaiset muodot) ovat teknisesti tekstipohjaisia, mutta sovellukset käsittelevät niitä silti useimmiten läpinäkymättöminä resurssina (opaque assets).
- Tietokanta tallentaa tavut; se ei parsii, validoi tai tulkitse sisältöä. Sen tekee erikoistunut ohjelmisto (kuvadekooderit, mediaohjelmistot, dokumenttien katseluohjelmat).

### Muotoriippuvainen tulkinta (format-dependent interpretation)

- Jokaisella muodolla on oma rakenteensa: otsikot (headers), pakkaus (compression), virrat (streams), metadatalohkot (metadata blocks).
- **JPEG** käyttää DCT-pakkausta; **MP3** käyttää kuulon mukaisessa äänikoodaukseen; **MP4** on säiliö (container), joka voi sisältää H.264-videon ja AAC-äänen.
- Tiedoston näyttämiseen tai käsittelyyn tarvitaan ohjelmistoa, joka ymmärtää kyseisen muodon. Tietokanta ei tarjoa tätä — se vain tallentaa ja palauttaa tavut.

### Metadatapitoinen (metadata-rich)

- Useimmat media-muodot upottavat **metadatan (metadata)** raakan sisällön rinnalle:
  - **Kuvat (images):** mitat (dimensions) (leveys × korkeus), värisyvyys (color depth), orientaatio (orientation), kameran valmistaja/malli (camera make/model), GPS-koordinaatit
  - **Ääni (audio):** kesto (duration), bittinopeus (bitrate), näytteenottotaajuus (sample rate), artisti, albumi
  - **Video:** kesto (duration), resoluutio (resolution), koodekki (codec), kuvataajuus (frame rate)
- Tätä metadataa puretaan usein ja tallennetaan erikseen tietokantaan kyselyjen ja suodattamisen vuoksi (esim. "etsi kaikki kuvat, joiden leveys on yli 1920 px" tai "listaa videot, joiden pituus on yli 10 minuuttia").

---

## Yleiset media-tiedostotyyppit (common types of media files)

Eri media-kategorioilla on erilaiset tallennustarpeet, tyypilliset koot ja käyttötarkoitukset sovelluksissa.

| Kategoria (category) | Esimerkkejä (examples) | Tyypilliset päätteet (extensions) | Tyypillinen kokovälillä (size range) |
| -------------------- | ---------------------- | --------------------------------- | ------------------------------------ |
| **Kuvat (images)**   | Valokuvat, kuvakkeet, pikkukuvat | `.jpg`, `.png`, `.gif`, `.webp`, `.svg` | 10 KB – 50 MB |
| **Ääni (audio)**     | Musiikki, podcastit, nauhoitukset | `.mp3`, `.wav`, `.ogg`, `.m4a` | 100 KB – 100 MB |
| **Video**            | Elokuvat, klipit, live-streamit | `.mp4`, `.webm`, `.avi`, `.mkv` | 1 MB – 10+ GB |
| **Dokumentit (documents)** | PDF:t, Office-tiedostot | `.pdf`, `.docx`, `.xlsx`, `.pptx` | 10 KB – 100 MB |
| **Arkistot (archives)**   | Zip, tarballit | `.zip`, `.tar.gz`, `.7z` | Vaihteleva |

### Kuvat (images)

- **Rasterikuvat (raster images)** (JPEG, PNG, GIF, WebP): pikseliruudukot (pixel grids); koko kasvaa resoluution ja värisyvyyden mukana. Usein pakattuja (compressed) (tappiollinen (lossy) valokuviin, häviötön (lossless) grafiikkaan).
- **Vektorikuvat (vector images)** (SVG): tallennetaan tekstinä/XML:nä; skaalautuvat ilman laadun menetystä; tyypillisesti pienempiä logoihin ja kuvakkeisiin.
- Yleinen käyttö: avatarit, tuottegalleria, pikkukuvat (thumbnails), infografiikka, kaaviot.

### Ääni (audio)

- **Pakattu (compressed)** (MP3, AAC, OGG): pienempiä tiedostoja, sopii striimaukseen (streaming) ja tallennukseen. Laatu riippuu bittinopeudesta.
- **Pakkaamaton (uncompressed)** (WAV, FLAC): isompi, käytetään kun laatu tai muokkaus on kriittistä.
- Yleinen käyttö: podcast-jaksot, musiikkikappaleet, äänimuistiinpanot, ääniefektit, äänikirjat.

### Video

- Videotiedostot ovat yleensä **suurin** mediatyyppi. Muutama minuutti HD-materiaalia voi ylittää 100 MB.
- Monet videomuodot ovat **säiliöitä (containers)** (esim. MP4, MKV, WebM), jotka yhdistävät:
  - Yhden tai useamman videovirran (e.g. H.264, VP9)
  - Yhden tai useamman äänivirran (e.g. AAC, Opus)
  - Valinnaiset tekstitykset, luvut ja metadata
- Yleinen käyttö: kurssiluennot, markkinointiklipit, käyttäjien luoma sisältö (user-generated content), valvontakuvat.

### Dokumentit (documents)

- PDF:t ja Office-tiedostot (.docx, .xlsx, .pptx) ovat **yhdistelmämuotoja (compound formats)**: sisäisesti ne voivat sisältää tekstiä, kuvia, fontteja ja upotettuja objekteja (embedded objects).
- Koko vaihtelee paljon: yksinkertainen tekstipdf voi olla 50 KB; skannattu kirja voi olla satoja megatavuja.
- Yleinen käyttö: sopimukset, raportit, käsikirjat, taulukot, esitykset.

### Arkistot (archives)

- Zip, tar.gz, 7z: muiden tiedostojen niput (bundles), usein pakattuja. Koko riippuu kokonaan sisällöstä.
- Joskus käytetään useiden liittyvien tiedostojen tallentamiseen (esim. dokumenttien "paketti") tai siirron koon pienentämiseen.

---

## Säiliömuodot (container formats) vs. yksitarkoitusmuodot (single-purpose formats)

- **Säiliömuodot (container formats)** (MP4, MKV, WebM, OGG) toimivat kääreinä (wrappers): ne sisältävät useita virtoja (video + ääni + tekstitys) ja metadatan yhdessä tiedostossa. Sama säiliö voi sisältää eri koodekkeja.
- **Yksitarkoitusmuodot (single-purpose formats)** (JPEG, PNG, MP3, WAV) tallentavat yhden sisältötyypin. Yksinkertaisemmat, mutta vähemmän joustavat.

---

## Media vs. rakennek data (media vs. structured data)

Relaatiotietokannassa (relational database) useimmat sarakkeet (columns) pitävät **rakennettua dataa (structured data)**:

- Kokonaisluvut (integers), desimaalit (decimals), päivämäärät (dates), lyhyet merkkijonot (short text strings)
- Pieni, kiinteä tai rajattu koko (tyypillisesti tavuista muutamaan KB)
- Suoraan verrattavissa, järjestettävissä ja indeksoitavissa
- Sopii luontevasti riveihin (rows) ja sarakkeisiin (columns); tietokanta voi tehokkaasti suodattaa, yhdistää (join) ja aggregoida (aggregate)

Media-tiedostot ovat tietokannan näkökulmasta **rakentamattomia (unstructured)** (tai puolistrukturoituja):

- Tietokanta ei "ymmärrä" sisältöä — se ei voi parsia JPEG:ää tai dekoodata MP3:aa
- Koko voi vaihdella valtavasti, muutamasta KB:sta moniin GB:iin
- Et harvoin kysy *sisällä* tavuissa (esim. "etsi kaikki MP3:t, joissa kertosäe mainitsee X:n") — se vaatisi koko tekstin haun (full-text search) dekoodatun sisällön yli tai erikoistuneita järjestelmiä
- Kysyt **metadatan** perusteella (esim. "etsi kaikki kuvat, jotka käyttäjä X latasi" tai "etsi videot, joiden pituus on yli 10 minuuttia")

Joten tietokannan rooli median kanssa on yleensä **tallentaa viittaukset (references) ja metadata**, ei tulkita tai etsiä raakaa sisältöä. Todelliset tavut sijaitsevat joko tietokannan sisällä BLOBina tai, yleisemmin, ulkoisessa tallennustilassa (external storage) (tiedostojärjestelmässä tai objektitallennuksessa (object storage)), johon tietokanta viittaa.

---

# 2) Miksi media-tiedostot eroavat

Relaatiotietokannat (relational databases) ovat erinomaisia rakennetun datan (structured data) tallentamiseen ja kyselyyn: rivejä kokonaisluvuista, tekstistä ja päivämääristä, jotka mahtuvat siististi tauluihin ja hyötyvät indekseistä (indexes), yhdistämisistä (joins) ja transaktioista (transactions). Media-tiedostoilla on kuitenkin erilaiset ominaisuudet — koko, käyttömallit (access patterns) ja elinkaari (lifecycle) — jotka ovat ristiriidassa tietokantojen suunnittelun ja käytön kanssa. Näiden jännitteiden ymmärtäminen auttaa selittämään, miksi median tallennus tietokannan *sisälle* on usein huono sopivuus, ja miksi monet järjestelmät pitävät median tiedostojärjestelmässä tai objektitallennuksessa (object storage).

---

## Koko ja tallennus (size and storage)

- **Skaalan epäsuhde (scale mismatch):** Yksi korkean resoluution video voi ylittää 1 GB. Tyypillinen tietokantarivi (database row) mitataan tavuista muutamaan kilotavuun. Satojen tai tuhansien media-tiedostojen tallennus BLOBeina (BLOBs) tekee tietokannasta nopeasti suuruusluokkalta isomman kuin sen ydin-transaktiodata (core transactional data).
- **Optimointikohteet (optimization targets):** Tietokannat on viritetty pienille ja keskikokoisille rivikooille. Isot BLOBit voivat aiheuttaa sivun turpoamista (page bloat), tehottoman puskurivälimuistin käytön (buffer cache usage) ja hitaampia peräkkäisiä skannauksia (sequential scans), kun optimointija (optimizer) koskee BLOB-sarakkeisiin.
- **Varmuuskopio ja replikaatio (backup and replication):** Jokainen täysi varmuuskopio (full backup) sisältää media-tavut. Replikaatiovirrat (replication streams) täytyy siirtää ne. 100 GB:n metadatatietokannasta tulee 1 TB:n tietokanta, kun lisäät 900 GB:n upotettua mediaa — varmuuskopiointiikkunat (backup windows) ja palautusajat (restore times) kasvavat vastaavasti.
- **Tietokantarajat (database limits):** Monet järjestelmät asettavat arvokohtaisia rajoja (e.g. PostgreSQL `BYTEA` jopa 1 GB, MySQL `BLOB` oletuksena 64 KB ellei konfiguroitu `MEDIUMBLOB` tai `LONGBLOB`). Erittäin isot tiedostot saattavat ei mahtua lainkaan tai vaativat erityistä viritystä.
- **Kirjoitus-ennalta-loki (write-ahead logging, WAL):** Jotkut tietokannat kirjaavat BLOB-muutokset kestävyyden (durability) vuoksi. Isot BLOBit voivat paisuttaa WAL-tilavuutta ja monimutkaistaa pisteen-aikaispalautusta (point-in-time recovery).

---

## Käyttömallit (access patterns)

- **Rakennek data:** Haet rivin (row), luet muutaman sarakkeen, käytät arvoja sovelluksessasi. Operaatio on pieni, nopea ja transaktionaalinen.
- **Media:** Käyttäjät tarvitsevat usein **striimata (stream)** sisältöä — aloittaa videon tai äänen toisto ennen kuin koko tiedosto on ladattu — tai **etsiä (seek)** tiedoston sisällä (hyppy tiettyyn aikaleimaan). Web-palvelimet ja CDN:t tukevat **HTTP-aluepyyntöjä (HTTP range requests)** (esim. "anna tavut 1 000 000–2 000 000"), jotka mahdollistavat osittaiset lataukset ja tehokkaan etsimisen. Tietokannat on rakennettu kokonaisarvon lukemiseen ja transaktionaaliseen semantiikkaan, ei suurisuorituskykyiseen peräkkäiseen striimaukseen isoista tavualueista monille samanaikaisille asiakkaille.
- **Samanaikaisuus (concurrency):** Suosittua videota saatetaan pyytää tuhansia kertoja minuutissa. Jokainen pyyntö sitoisi tietokantayhteyden ja lukisi samaa useaan sataan MB:n blobia toistuvasti. Tietokantayhteyden poolit (connection pools) ja I/O-kaista eivät ole suunniteltu tähän kuormaan; sitä varten on omat mediapalvelimet ja CDN:t.
- **Viive (latency):** Sovellukset haluavat tyypillisesti matalaa viivettä metadatalle ("näytä videolista") mutta voivat sietää korkeampaa viivettä median itsensä kannalta ("aloita videon puskurointi"). Metadatan (tietokannassa) ja median (tallennustilassa) erottaminen mahdollistaa jokaisen polun optimoinnin erikseen.

---

## Välimuisti ja sisällön toimitus (caching and content delivery)

- **Maantieteellinen jakelu (geographic distribution):** Kuvat ja videot hyötyvät **CDN:istä (Content Delivery Networks)** — reunapalvelinverkkoista (edge servers), jotka sijaitsevat käyttäjien lähellä maailmanlaajuisesti. Tokion käyttäjä saa videon Tokion reunapalvelimelta eikä yhdestä keskus-tietokannasta, mikä vähentää viivettä ja mannerten välistä kaistaa.
- **Välimuistikäyttäytyminen (caching behavior):** Media-tiedostot ovat usein **muuttumattomia (immutable)** (sama URL palauttaa aina samat tavut). Se tekee niistä ihanteellisia välimuistitettaviksi: kerran reunalla välimuistissa, seuraavat pyynnöt eivät koske alkuperään (origin). Tietokantatuloksia voidaan välimuistaa myös, mutta välimuistin mitätöinti (cache invalidation) on hankalampaa, kun data muuttuu usein.
- **Kustannus ja kuorma (cost and load):** Median palveleminen CDN:stä on käyttäjille nopeampaa ja sinulle halvempaa — CDN:stä pois menevän datan (egress) kustannus on tyypillisesti halvempaa kuin tietokannan I/O, ja vältät tietokannan kuormittamisen runsaalla media-liikenteellä. Tietokantapalvelimet on parempi varata transaktio- ja kyselykuormalle.
- **Ei tietokantaa kriittisessä polussa (no database in the hot path):** Kun media sijaitsee objektitallennuksessa (object storage) (esim. S3, Azure Blob) tai tiedostojärjestelmässä, sovellus hakee URL:n tietokannasta kerran, jonka jälkeen selain tai sovellus pyytää median suoraan tallennustilasta tai CDN:stä. Tietokanta ei ole kriittisessä polussa (critical path) jokaiselle mediapyynnölle.

---

## Varmuuskopio ja palautus (backup and recovery)

- **Varmuuskopion koko ja kesto (backup size and duration):** Isot media-blobit paisuttavat varmuuskopion kokoa ja kestoa. Yön täysi varmuuskopio, joka kestää 10 minuuttia ilman mediaa, voi kestää tunteja satojen GB:n upotetuilla tiedostoilla. Inkrementaaliset varmuuskopiot (incremental backups) voivat auttaa, mutta BLOB-painavissa tauluissa ne hallitsevat silti varmuuskopion kokoa.
- **Palautuksen tarkkuus (restore granularity):** Täyden varmuuskopion palauttaminen vain muutaman metadatarivin tai yhden korruptoituneen tiedoston palauttamiseksi on tehokasta. Kun media on ulkoisessa tallennustilassa, voit palauttaa tietokannan (metadata) ja tallennustilan (files) erikseen ja palauttaa vain sen, mikä epäonnistui.
- **Säilytys ja arkistointi (retention and archiving):** Media-tiedostoilla on usein eri säilytys- ja arkistointitarpeet kuin transaktiodatalla. Laki tai käytäntö voi vaatia dokumenttien säilyttämistä 7 vuotta, mutta käyttölokien (access logs) poistamista 90 päivän jälkeen. Median ja transaktiodatan sekoittaminen yhdessä varmuuskopiossa monimutkaistaa säilytyskäytäntöjä ja vaatimustenmukaisuutta (compliance).
- **Palautustavoitteet (recovery objectives):** **RTO** (Recovery Time Objective, palautumisaika) ja **RPO** (Recovery Point Objective, palautumispiste) voivat erota metadatalle ja medialle. Saatat tarvita metadatan palautettavan minuuteissa, mutta median voi palauttaa tunteina erillisistä arkistoista. Samassa paikassa pitäminen pakottaa yhden palautusstrategian molemmille.

---

# 3) Tallennuslähestymistavat (storage approaches)

Keskeinen suunnittelukysymys on: **missä todelliset tavut sijaitsevat?** Voit tallentaa median **tietokannan sisälle** binääridatana (binary data) tai **tietokannan ulkopuolelle** (levylle tai objektitallennukseen) ja pitää vain viittauksen (reference) ja metadatan tietokannassa. Valinta vaikuttaa johdonmukaisuuteen (consistency), suorituskykyyn, skaalautuvuuteen (scalability) ja operaatioihin. Ei ole yhtä oikeaa vastausta — se riippuu tiedostokoosta, määrästä, käyttömalleista ja operatiivisista rajoituksista.

---

## Lähestymistapa 1: Tallenna media tietokannan sisälle (BLOB)

Tallenna raakatavut (raw bytes) sarakkeeseen binäärityypillä (binary type). Tiedosto ja sen metadata sijaitsevat samassa taulussa; tietokanta on ainoa totuuden lähde (single source of truth) molemmille.

### Binääridatan tietokantatyypit (database types for binary data)

| Tietokanta (database) | Tyyppi (type) | Tyypillinen raja (limit) |
| --------------------- | ------------- | ------------------------ |
| PostgreSQL | `BYTEA` | ~1 GB arvoa kohti |
| PostgreSQL | `bytea` TOASTin kanssa | Isot arvot tallennetaan automaattisesti rivin ulkopuolelle (out-of-line) |
| MySQL | `BLOB` | 64 KB (oletus); `MEDIUMBLOB` 16 MB; `LONGBLOB` 4 GB |
| SQL Server | `VARBINARY(MAX)` | 2 GB |

PostgreSQL käyttää **TOASTia** (The Oversized-Attribute Storage Technique) arvoille, jotka ovat isompia kuin ~2 KB: päätaulu tallentaa viittauksen, ja todelliset tavut ovat erillisessä TOAST-taulussa. Tämä pitää päätaulun kompaktina, mutta silti kaikki tallennetaan tietokantaan.

### Skeemaluonnos (schema sketch)

```
┌────────────────────────────────────────────────────────────┐
│  media_files                                               │
├──────────┬──────────┬──────────┬───────────┬───────────────┤
│ id       │ name     │ mime_type│ size_bytes│ file_content  │  ← binary data
│ 1        │ photo.jpg│ image/…  │ 245000    │ <0xFFD8FFE0…> │
└──────────┴──────────┴──────────┴───────────┴───────────────┘
```

### Plussat (pros)

- **Ainoa totuuden lähde (single source of truth)** — tiedosto ja metadata yhdessä paikassa; ei ulkoista järjestelmää koordinoitavaksi
- **Transaktionaalinen johdonmukaisuus (transactional consistency)** — lisää, päivitä tai poista tiedosto ja metadata yhdessä transaktiossa; ei riskiä rivistä ilman tiedostoa tai tiedostosta ilman riviä
- **Yksinkertaisempi varmuuskopio** — yksi varmuuskopio sisältää kaiken (vaikka se voi olla valtava)
- **Ei orpo-tiedostoja (no orphaned files)** — rivin poistaminen poistaa tiedoston automaattisesti; ei siivousjobeja tarvita
- **Pääsynhallinta (access control)** — tietokannan roolit (roles) ja oikeudet (privileges) koskevat tiedostoa; ei erillisiä tallennusoikeuksia hallittavaksi

### Miinukset (cons)

- **Iso tietokannan koko** — varmuuskopiot, replikaatio ja tallennuskustannukset kasvavat nopeasti median määrän mukana
- **Suorituskyky (performance)** — suurten blobien lukeminen lataa datan tietokannan kautta; ei ihanteellista striimaukseen tai korkealle samanaikaisuudelle
- **Yhteysoverhead (connection overhead)** — 100 MB:n tiedoston haku sitoa tietokantayhteyden siirron ajan
- **Kokorajat (size limits)** — tietokantakohtaiset rajat pätevät; erittäin isot tiedostot saattavat ei mahtua tai vaativat erityiskonfiguraatiota
- **Huono sopivuus CDN:lle** — media on loukussa tietokannassa; et voi osoittaa CDN-alkuperää (CDN origin) tietokantatauluun
- **WAL ja replikaatio** — isot lisäykset/päivitykset kasvattavat WAL-tilavuutta ja replikaation viivettä (replication lag)

### Milloin käyttää

- **Pienet tiedostot** — esim. pikkukuvat (thumbnails), kuvakkeet tai pikkudokumentit alle ~100 KB
- **Vahva johdonmukaisuusvaatimus** — esim. sääntely- tai auditointitarpeet ("tiedoston ja metadatan täytyy aina täsmätä")
- **Pieni määrä** — kymmeniä tai satoja tiedostoja, ei miljoonia
- **Yksinkertainen käyttöönotto** — ei halua operoida objektitallennusta tai erillistä mediapalvelua
- **Ei striimaus- tai CDN-tarvetta** — tiedostot ovat tarpeeksi pieniä, että kokolataus on hyväksyttävissä

---

## Lähestymistapa 2: Tallenna media tiedostojärjestelmään (file system) tai objektitallennukseen (object storage), viittaus tietokannassa

Tallenna tiedosto **tietokannan ulkopuolelle**: paikalliselle tai verkkoon liitetylle levylle tai **objektitallennukseen (object storage)** (Amazon S3, Azure Blob Storage, Google Cloud Storage, MinIO jne.). Tietokannassa tallenna vain:

- **Polku (path)** tai **URL** tiedostoon (e.g. `/media/products/123/abc-def.jpg` tai `s3://bucket/media/123/abc-def.jpg`)
- **Metadata** (nimi, koko, MIME-tyyppi, mitat, kesto, latausaika, tarkistussumma jne.)

Tietokanta pitää *indeksin*; tallennustila pitää *sisällön*.

### Tiedostojärjestelmä (file system) vs. objektitallennus (object storage)

| Näkökulma (aspect) | Tiedostojärjestelmä (levy, NFS) | Objektitallennus (S3, Azure Blob) |
| ------------------ | ------------------------------- | --------------------------------- |
| **Käyttömalli (access model)** | Polkupohjainen (path-based) | Avainpohjainen (key-based) |
| **Skaalautuvuus (scaling)** | Rajoitettu levyn/palvelimen mukaan | Suunniteltu massiiviseen skaalaukseen |
| **Kestävyys (durability)** | Riippuu RAID/varmuuskopiosta | Sisäänrakennettu replikaatio, versiointi |
| **HTTP-pääsy** | Vaatii web-palvelimen | Natiivit HTTP(S)-API:t, allekirjoitetut URL:t |
| **Kustannus (cost)** | Levyn kustannus | GB-perusteinen tallennus + lähtevä liikenne (egress) |
| **Tyypillinen käyttö** | Yksi palvelin, yksinkertaiset asennukset | Pilvisovellukset, monialue, CDN-alkuperät |

Objektitallennus on rakennettu rakentamattomalle datalle (unstructured data) mittakaavassa: laitat objektit sisään, saat ne avaimella ulos, ja toimittaja hoitaa kestävyyden ja saatavuuden. Useimmat CDN:t voivat käyttää objektitallennusta alkuperänä (origin).

### Skeemaluonnos (schema sketch)

```
┌────────────────────────────────────────────────────────────┐
│  media_files (database)                                    │
├──────────┬──────────┬──────────┬───────────┬───────────────┤
│ id       │ name     │ mime_type│ size_bytes│ file_path     │  ← reference only
│ 1        │ photo.jpg│ image/…  │ 245000    │ /media/1/…    │
└──────────┴──────────┴──────────┴───────────┴───────────────┘

┌────────────────────────────────────────────────────────────┐
│  File system / Object storage                              │
├────────────────────────────────────────────────────────────┤
│  /media/1/abc123-photo.jpg  (actual bytes on disk/S3)      │
└────────────────────────────────────────────────────────────┘
```

### Plussat (pros)

- **Tietokanta pysyy pienessä** — vain metadata ja viittaukset; ei turpoamista binäärisisällöstä
- **Nopeammat varmuuskopiot** — tietokannan varmuuskopio on nopea; mediaa voi varmuuskopioida tai replikoida erikseen
- **Striimausystävällinen** — web-palvelin tai CDN palvelee tiedostoja suoraan; HTTP-aluepyynnöt, tavualueiden palvelu
- **CDN-integraatio** — osoita CDN tallennustilaan; välimuisti reunalla; vähennä alkuperän kuormaa
- **Skaalautuvuus** — objektitallennus skaalautuu itsenäisesti; lisää kapasiteettia koskematta tietokantaan
- **Ei BLOB-kokorajoja** — tiedoston kokoa rajoittaa tallennustila, ei tietokannan rajoitteet
- **Halvempi mittakaavassa** — objektitallennus ja CDN:n lähtevä liikenne maksavat usein vähemmän kuin tietokannan I/O isolle medialle

### Miinukset (cons)

- **Kaksi paikkaa hallittavaksi** — tiedosto ja tietokantarivi voivat mennä epäsynkkaan: orpo-tiedostot (orphaned files) (tiedosto on olemassa, ei riviä), rikkinäiset viittaukset (broken references) (rivi osoittaa puuttuvaan tiedostoon) tai päällekkäiset lataukset
- **Ei sisäänrakennettuja transaktioita** — tiedoston lataus ja rivin lisäys ovat erillisiä vaiheita; tarvitaan sovellustason logiikkaa (esim. lataa ensin, sitten lisää; tai lisää placeholderilla, sitten päivitä) ja siivousjobeja virhetilanteille
- **Polun/URL:n suunnittelu** — täytyy päättää nimeäminen (UUID:t, ID:t), versiointi ja käyttömallit (julkinen vs. allekirjoitetut URL:t)
- **Pääsynhallinta** — tallennuksen oikeudet ovat erilliset tietokannan rooleista; usein toteutettu allekirjoitettujen URL:ien (signed URLs) kautta vanhenemisella (expiration)

### Operatiiviset näkökulmat (operational considerations)

- **Allekirjoitetut URL:t (signed URLs):** Objektitallennus käyttää usein **allekirjoitettuja URL:ia** (aikarajoitettuja, tokenisoituja URL:eja), jotta voit myöntää väliaikaisen pääsyn tekemättä objekteista julkisia. Sovellus generoi allekirjoitetun URL:n tietokannan viittauksesta ja palauttaa sen asiakkaalle.
- **Orpo-siivous (orphan cleanup):** Säännölliset jobit voivat etsiä tallennustilasta tiedostoja, joille ei ole vastaavaa tietokantariviä (tai päinvastoin), ja siivota ne.
- **Idempotentit lataukset (idempotent uploads):** Käytä deterministisiä avaimia (e.g. sisältötarkistussumma (content hash)), jotta saman tiedoston uudelleenlataus ei luo duplikaatteja.

### Milloin käyttää

- **Keskikokoiset ja isot tiedostot** — kuvat, ääni, video, dokumentit
- **Korkea määrä tai runsas liikenne** — tuhansia tiedostoja tai monia samanaikaisia katsojia
- **Striimaus, CDN tai tehokas toimitus** — tarvitaan aluepyyntöjä, reunavälimuistia tai matalaa viivettä
- **Useimmat tuotantosovellukset** — de facto -valinta käyttäjien luomalle sisällölle, tuotekatalogeille ja mediapaineisille sovelluksille

---

## Hybridilähestymistapa (hybrid approach)

Yhdistä molemmat strategiat: tallenna **metadata ja viittaus** tietokantaan ja **koko tiedosto** objektitallennukseen. Valinnaisesti tallenna ** pienet pikkukuvat tai esikatselut** BLOBeina tietokantaan nopeaa näyttöä varten listoissa tai ruudukoissa.

### Esimerkki

- **Koko kuva** (2 MB) → objektitallennus, viitattu URL:lla `media_files.file_path`:ssa
- **Pikkukuva** (15 KB) → BLOB `media_files.thumbnail_content`:ssa nopeaa renderöintiä varten listanäkymissä

Hyödyt: saat transaktionaalisen johdonmukaisuuden pienelle esikatselulle (ei ylimääräistä HTTP-pyyntöä listanäkymille) pitäen samalla ison tiedoston tallennustilassa täysikokoiselle näytölle ja CDN-toimitukselle. Vastapainona on lisätty skeeman monimutkaisuus ja pikkukuvien generoinnin ja tallennuksen tarve latauksessa.

---

# 4) Skeemasuunnittelumallit (schema design patterns)

Kun käytät **viittauslähestymistapaa (reference approach)** (tiedosto tietokannan ulkopuolella), tietokanta tallentaa metadatan ja osoittimen (pointer). Tässä yleisiä malleja.

---

## Perus media-taulu (basic media table)

```sql
CREATE TABLE media_files (
    id           SERIAL PRIMARY KEY,
    filename     VARCHAR(255) NOT NULL,
    mime_type    VARCHAR(100) NOT NULL,
    size_bytes   BIGINT NOT NULL,
    file_path    VARCHAR(500) NOT NULL,   -- or storage_url for S3, etc.
    uploaded_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    uploaded_by  INTEGER REFERENCES users(id)
);
```

- `file_path` tai `storage_url`: polku levyllä tai URL objektitallennuksessa
- `mime_type`: esim. `image/jpeg`, `video/mp4` — käytetään HTTP `Content-Type`:ssä
- `size_bytes`: hyödyllinen kiintiöille (quotas), käyttöliittymälle ja validointiin

---

## Media linkitettynä entiteetteihin (media linked to entities)

Media liittyy usein muihin entiteetteihin (user avatar, product image, document attachment): käyttäjän avatar, tuotekuva, dokumenttiliite.

```sql
-- Product images: one product, many images
CREATE TABLE product_images (
    id          SERIAL PRIMARY KEY,
    product_id  INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    filename    VARCHAR(255) NOT NULL,
    mime_type   VARCHAR(100) NOT NULL,
    file_path   VARCHAR(500) NOT NULL,
    sort_order  INTEGER DEFAULT 0,    -- for ordering (e.g. primary image first)
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User avatar: one-to-one
CREATE TABLE users (
    id            SERIAL PRIMARY KEY,
    email         VARCHAR(255) NOT NULL,
    avatar_path   VARCHAR(500),       -- nullable; user may have no avatar
    -- ...
);
```

---

## Erillinen metadata eri mediatyypeille (separate metadata for different media types)

Rikkaammalle metadatalle (e.g. kuvien mitat, videon kesto) voit laajentaa skeemaa:

```sql
CREATE TABLE images (
    id          SERIAL PRIMARY KEY,
    file_path   VARCHAR(500) NOT NULL,
    width_px    INTEGER,
    height_px   INTEGER,
    -- ...
);

CREATE TABLE videos (
    id           SERIAL PRIMARY KEY,
    file_path    VARCHAR(500) NOT NULL,
    duration_sec INTEGER,
    width_px     INTEGER,
    height_px    INTEGER,
    codec        VARCHAR(50),
    -- ...
);
```

Vaihtoehtoisesti käytä yhtä `media_files`-taulua tyyppikohtaisille kentille nollakelpoisilla sarakkeilla, tai generistä `metadata` JSONB-saraketta.

---

# 5) Huomioitavaa ja parhaat käytännöt (considerations and best practices)

---

## Tiedostonimitys ja polut (file naming and paths)

- **Vältä törmäyksiä (avoid collisions):** Käytä UUID:ita tai yhdistelmäavaimia (composite keys) (esim. `{id}-{uuid}.{ext}`), jotta kaksi latausta ei koskaan ylikirjoita toisiaan.
- **Järjestä kontekstin mukaan:** esim. `/media/products/123/`, `/media/users/456/avatars/`
- **Sisällytä pääte (extension):** Yksinkertaistaa MIME-logiikan ja helpottaa asiakkaita ja CDN:itä.

---

## Johdonmukaisuus ulkoista tallennusta käytettäessä (consistency when using external storage)

- **Latauspolku (upload flow):**  
  1. Tallenna tiedosto tallennustilaan.  
  2. Lisää rivi polulla/URL:lla.  
  Jos vaihe 2 epäonnistuu, saat orpo-tiedoston — aja säännöllisiä siivousjobeja.
- **Poistopolku (delete flow):**  
  1. Poista rivi.  
  2. Poista tiedosto.  
  Jos vaihe 2 epäonnistuu, saat jääneen tiedoston — sama siivouslähestymistapa.
- **Transaktiot:** Jotkut objektitallennukset tukevat transaktionaalisia API:ta; muuten suunnittele lopullista johdonmukaisuutta (eventual consistency) ja siivousta varten.

---

## Kokorajat ja validointi (size limits and validation)

- Validoi tiedoston koko ja tyyppi **ennen** tallennusta (sovelluksessa).
- Aseta rajat tiedostotyypin mukaan (esim. avatarit max 2 MB, dokumentit max 50 MB).
- Käytä `CHECK`-rajoitteita (constraints) metadatalle mahdollisuuksien mukaan, esim. `size_bytes > 0 AND size_bytes <= 104857600`.

---

## Turvallisuus (security)

- **Älä luota käyttäjän antamiin tiedostonimiin** — sanitoi tai generoi turvalliset nimet välttääksesi polkutraversal-hyökkäykset (path traversal) (esim. `../../../etc/passwd`).
- **Validoi MIME-tyypit** — älä luota vain päätteeseen; tarkista taikaluvut (magic bytes) tai luotettava kirjasto.
- **Hallitse pääsyä** — palvele tiedostoja sovelluksen tai allekirjoitettujen URL:ien kautta, jotta voit täytäntöönpanna valtuutuksen (authorization).
- **Skannaa haittaohjelmista** — käyttäjien latauksissa harkitse virusskannusta ennen tallennusta.

---

## Varmuuskopiot (backups)

- **Tietokanta:** Varmuuskopioi metadatataulut normaalisti; pidä ne pieninä ja nopeina palauttaa.
- **Media-tiedostot:** Varmuuskopioi tallennustila erikseen (objektitallennuksella on usein sisäänrakennettu versiointi ja monialueinen replikaatio).
- **Synkronointi:** Dokumentoi miten palautetaan, jos tietokanta ja tallennustila palautetaan eri aikapisteistä.

---

# 6) Yhteenveto (summary)

| Näkökulma (aspect) | BLOB tietokannassa | Tiedostojärjestelmä / objektitallennus + viittaus |
| ------------------ | ------------------ | ------------------------------------------------- |
| **Käyttötapaus (use case)** | Pienet tiedostot, vahva johdonmukaisuus | Keskikokoiset/isot tiedostot, korkea määrä, striimaus |
| **Tietokannan koko** | Kasvaa median mukana | Pysyy pienessä |
| **Varmuuskopio** | Yksi varmuuskopio, mutta iso | Tietokanta ja tallennustila varmuuskopioidaan erikseen |
| **Striimaus/CDN** | Kömpelö | Luonnollinen sopivuus |
| **Johdonmukaisuus** | Atominen | Sovelluksen hallitsema, voi vaatia siivousta |
| **Skaalautuvuus** | Rajoitettu tietokannalla | Tallennustila skaalautuu itsenäisesti |

**Suositus:** Useimmissa sovelluksissa tallenna media-tiedostot objektitallennukseen (tai tiedostojärjestelmään) ja pidä vain metadata ja polku/URL tietokannassa. Käytä BLOBeja vain kun tiedostot ovat pieniä, vähän kappaleita ja transaktionaalinen johdonmukaisuus on kriittistä.

---

## Liittyvät materiaalit (related materials)

- [Materiaali 03](./03-Relaatiotietokanta.md) — Relaatiomalli (relational model) ja datatyypit (data types)
- [Materiaali 08](./08-normalisointi-ja-skeeman-laatu.md) — Skeeman suunnittelu (schema design) ja redundanssin välttäminen
- [Materiaali 12](./12-Tietokannat-ohjelmoinnissa.md) — Miten sovellukset vuorovaikuttavat tietokantojen kanssa
