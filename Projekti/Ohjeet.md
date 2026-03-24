# Projektityö — Resepti- ja ateriasuunnittelutietokanta

## Johdanto

Tässä projektissa suunnittelet ja toteutat PostgreSQL-tietokannan alusta alkaen. Työskentelet realistisessa skenaariossa: keittokoulu ja ateriasuunnittelupalvelu tarvitsee tietokannan reseptien, ainesosien ja kategorioiden tallentamiseen. Projektin edetessä voit laajentaa sitä käyttäjillä, opettajilla, ateriasuunnitelmilla ja konsolisovelluksella, joka yhdistää tietokantaan ORM:än kautta.

Teet itse suunnittelupäätökset—valitset entiteetit, suhteet, rajoitteet ja toteutusratkaisut—samalla kun täytät liiketoimintavaatimukset. Projekti on jaettu vaiheisiin: pakollinen perusvaihe sekä valinnaiset edistyneempi ja ORM-vaihe. Jokainen vaihe rakentuu edellisen päälle ja vaikuttaa kokonaispisteisiisi.

---

> [!NOTE]
> Tämä on **opiskelijan suunnittelema projekti** useissa vaiheissa. Tulkitset vaatimukset, suunnittelet skeeman ja toteutat tietokannan. Käytä kurssimateriaaleja oikeiden suunnittelupäätösten tekemiseen.

> [!IMPORTANT]
> Suorita Oppimistehtävät 1–4 ennen perusvaiheen aloittamista. Edistyneempi vaihe rakentuu perusvaiheen päälle. ORM-vaihe rakentuu perusvaiheen (ja valinnaisesti edistyneen vaiheen) päälle.

---

## Yleiskatsaus

| Vaihe                  | Fokus                                                              | Esitiedot                                             | Arviointi                                    |
| ---------------------- | ------------------------------------------------------------------ | ----------------------------------------------------- | -------------------------------------------- |
| **Perusvaihe**         | Reseptit, kategoriat, ainesosat ja resepti–ainesosa -liitokset     | Tehtävät 1–3                                          | **Pakollinen** — 10 pistettä                 |
| **Edistyneempi vaihe** | Käyttäjät, opettajat, ateriasuunnitelmat/valikko, indeksit, roolit | Perusvaihe suoritettu                                 | **Valinnainen** — 10 pistettä suoritettaessa |
| **ORM-vaihe**          | Konsolisovellus ORM:llä                                            | Perusvaihe (ja valinnaisesti edistyneempi) suoritettu | **Valinnainen** — 5 pistettä suoritettaessa  |

Perusvaihe on pakollinen (10 pistettä). Edistyneempi vaihe on valinnainen (10 pistettä). ORM-vaihe on valinnainen (5 pistettä). **Yhteensä: 25 pistettä.** Kaikki kolme vaihetta suoritettuna antaa täydet 25 pistettä.

Miten esitellä projekti kuvakaappauksin ja selittää suunnittelupäätökset: katso [Reporting-Guide-FI.md](Reporting-Guide-FI.md). Ennen palautusta käytä [Self-Check-Guide-FI.md](Self-Check-Guide-FI.md) työsi tarkistamiseen.

---

## Skenaario

Paikallinen keittokoulu ja ateriasuunnittelupalvelu tarvitsee PostgreSQL-tietokannan. Järjestelmä hallitsee **reseptejä**, **ainesosia** ja **kategorioita**. Myöhemmin se tukee **käyttäjiä**, jotka selailvat reseptejä ja suunnittelevat aterioita, **opettajia**, jotka luovat ja muokkaavat reseptejä, sekä **ateriasuunnitelmia** (valikoita) reseptien organisointiin ajan mittaan.

---

# Vaihe 1 — Perusvaihe

Suunnittele ja toteuta ydinreseptitietokanta.

---

## Perusvaihe — Liiketoimintavaatimukset

### Kategoriat

- Järjestelmä tallentaa reseptikategoriat (esim. Aamiainen, Jälkiruoka, Pääruoka, Keitto).
- Jokaisella kategorialla on yksilöllinen tunniste ja nimi.
- Kategorianimien on oltava yksilöllisiä. Kahden kategorian ei saa jakaa samaa nimeä.

### Reseptit

- Jokaisella reseptillä on nimi ja se voi sisältää ohjeita (jotka voivat olla pitkiä).
- Resepti voi tallentaa valmistusajan (minuutteina) ja annosmäärän.
- Resepti voi kuulua yhteen tai useampaan kategoriaan. Reseptillä on aina vähintään yksi kategoria.
- Valmistusaika, jos annettu, ei saa olla negatiivinen.
- Annosmäärä, jos annettu, on oltava vähintään 1.

### Resepti–kategoria -suhde

- Resepti voi kuulua yhteen tai useampaan kategoriaan. Kategoria voi sisältää useita reseptejä.
- Jokaiselle resepti–kategoria -parille järjestelmän tallentaa liitoksen.
- Reseptin poistaminen poistaa sen kategorialiitokset.
- Kategorian poistaminen poistaa sen liitokset resepteihin. Suunnittelun on varmistettava, ettei mikään resepti jää ilman vähintään yhtä kategoriaa (esim. estämällä kategorian poistaminen, jos se jättäisi reseptin ilman kategorioita).

### Ainesosat

- Ainesosat ovat uudelleenkäytettäviä eri resepteissä (esim. jauho, maito, oliiviöljy).
- Jokaisella ainesosalla on yksilöllinen tunniste ja yksilöllinen nimi.
- Ainesosalla voi olla tyypillinen oletusyksikkö (esim. g, ml, kpl).

### Resepti–ainesosa -suhde

- Resepti käyttää yhden tai useamman ainesosan. Ainesosa voi esiintyä useissa resepteissä.
- Jokaiselle resepti–ainesosa -parille järjestelmän on tallennettava määrä ja yksikkö (esim. 200 g jauhoa, 2 munaa).
- Määrän on oltava positiivinen.
- Reseptin poistaminen poistaa sen ainesosaliitokset.
- Ainesosaa, joka esiintyy missään reseptissä, ei saa voida poistaa ennen kuin sitä ei enää viitata.

---

## Perusvaihe — Osa 1: ER-kaavio

Luo ER-kaavio, joka:

- Näyttää kaikki perusvaiheen liiketoimintavaatimusten täyttämiseen tarvittavat entiteetit
- Näyttää pääavaimet, viiteavaimet ja kardinaliteetin
- Näyttää valinnaisuuden (pakolliset vs valinnaiset attribuutit/suhteet)

Käytä draw.io, dbdiagram.io tai vastaavaa. Vie PNG- tai PDF-tiedostona.

**Palautettava:** `er_diagram.png` tai `er_diagram.pdf`

---

## Perusvaihe — Osa 2: Skeema

Toteuta PostgreSQL-skeema niin, että se täyttää kaikki perusvaiheen liiketoimintavaatimukset. Käytä sopivia tietotyyppejä, rajoitteita ja viite-eheyssääntöjä.

**Palautettava:** `schema.sql` — kaikki taulujen luontiin tarvittavat lauseet

---

## Perusvaihe — Osa 3: Esimerkkidata

Lisää realistista testidataa niin, että:

- Kategorioita on vähintään 4
- Reseptejä on vähintään 6
- Ainesosia on vähintään 12
- Resepti–ainesosa -liitoksia on vähintään 15
- Resepti–kategoria -liitoksia on vähintään 15 (jokaisella reseptillä vähintään 1 kategoria; vähintään 2 reseptillä useita kategorioita)
- Jokaisella reseptillä on vähintään 2 ainesosaa

**Palautettava:** `seed.sql` — kaikki `INSERT` -lauseet

---

## Perusvaihe — Osa 4: Kyselyt

Kirjoita SQL-kyselyitä, jotka tuottavat seuraavat tulokset. Valitse sopivat tekniikat kurssimateriaalien perusteella.

1. **Reseptit kategorioineen** — Listaa kaikki reseptit kategorianimineen. Resepti, jolla on useita kategorioita, voi esiintyä kerran per kategoria. Järjestä kategorian nimen, sitten reseptin nimen mukaan.

2. **Reseptin ainesosat** — Valitulle reseptille (esim. nimellä) näytä ainesosan nimi, määrä ja yksikkö, järjestettynä ainesosan nimen mukaan.

3. **Reseptit, joissa on tietty ainesosa** — Listaa kaikki reseptit, jotka käyttävät valittua ainesosaa (esim. jauho), näyttäen reseptin nimen ja kategorian (tai kategoriat).

4. **Ainesosamäärä per resepti** — Jokaiselle reseptille näytä reseptin nimi ja käytettävien ainesosien lukumäärä, järjestettynä ainesosamäärän mukaan laskevaan järjestykseen.

5. **Käyttämättömät ainesosat** — Listaa ainesosat, joita ei esiinny missään reseptissä.

6. **Keskimääräinen valmistusaika kategorialla** — Jokaiselle kategorialle näytä kategorian nimi ja sen reseptien keskimääräinen valmistusaika (minuutteina), järjestettynä keskimääräisen valmistusajan mukaan laskevaan järjestykseen. Resepti useassa kategoriassa vaikuttaa kunkin kategorian keskiarvoon. Kategoriat ilman reseptejä tai ilman valmistusaikoja käsitellään asianmukaisesti.

**Palautettava:** `queries.sql` — kaikki 6 kyselyä lyhyine kommentteineen

---

# Vaihe 2 — Edistyneempi vaihe

Laajenna tietokantaa käyttäjillä, opettajilla, ateriasuunnitelmilla, indekseillä ja rooleilla. Edistyneempi vaihe olettaa, että perusvaihe on valmis ja toimii.

---

## Edistyneempi vaihe — Liiketoimintavaatimukset

### Käyttäjät

- Järjestelmä tallentaa käyttäjiä (henkilöt, jotka selailivat reseptejä ja luovat ateriasuunnitelmia).
- Jokaisella käyttäjällä on yksilöllinen tunniste.
- Käyttäjät on tunnistettava (esim. nimellä tai sähköpostilla) siten, että duplikaatit voidaan estää tarpeen mukaan.

### Opettajat

- Opettajat ovat käyttäjiä, jotka voivat luoda ja muokata reseptejä, ainesosia ja kategorioita.
- Järjestelmän on erotettava opettajat tavallisista käyttäjistä.
- Tavalliset käyttäjät voivat selata reseptejä ja luoda henkilökohtaisia ateriasuunnitelmia, mutta eivät voi muokata reseptejä, ainesosia tai kategorioita.

### Ateriasuunnitelmat (valikot)

- Ateriasuunnitelma on nimetty reseptikokoelma, joka on organisoitu ajalle tai tietyille aterioille (esim. viikoittainen valikko tai maanantain lounas, tiistain illallinen).
- Ateriasuunnitelma kuuluu käyttäjälle.
- Ateriasuunnitelma sisältää yhden tai useamman reseptiviitteen. Järjestelmän on tallennettava, mikä resepti on suunniteltu mille paikalle (esim. päivä, ateriatyyppi tai järjestys).
- Käyttäjän poistaminen voi poistaa hänen ateriasuunnitelmansa, tai poistaminen estetään, jos käyttäjällä on suunnitelmia — suunnittelusi käsittelee tämän johdonmukaisesti.
- Reseptin poistaminen on estettävä, jos sitä viitataan jossakin ateriasuunnitelmassa, tai suunnittelusi määrittelee, miten tällaiset viittaukset päivitetään tai poistetaan.

### Indeksit

- Lisää indeksit tueksi seuraaville:
  - Reseptien haku kategorian mukaan
  - Reseptin ainesosien listaus
  - Reseptien haku ainesosan mukaan
  - Ainesosien haku nimen mukaan
  - Ateriasuunnitelmien haku käyttäjän mukaan
  - Ateriasuunnitelmarivien haku reseptin mukaan

### Roolit

- Määritä tietokantaroolit niin, että:
  - **Opettajat** voivat lukea, lisätä ja päivittää reseptejä, resepti–ainesosa -liitoksia, resepti–kategoria -liitoksia, ainesosia ja kategorioita. He saattavat tarvita sopivat oikeudet käyttäjätauluihin suunnittelustasi riippuen.
  - **Tavalliset käyttäjät** voivat lukea reseptejä, ainesosia ja kategorioita ja hallita omia ateriasuunnitelmiaan (lukea, lisätä, päivittää, poistaa omaa dataa).
  - **Katselijat** voivat vain lukea kaikkia tauluja (esim. raportointia tai tarkastusta varten).

---

## Edistyneempi vaihe — Osa 1: Laajennettu ER-kaavio

Päivitä ER-kaaviosi sisältämään:

- Käyttäjät ja opettajat
- Ateriasuunnitelmat ja niiden suhde käyttäjiin ja resepteihin
- Kaikki uudet pääavaimet, viiteavaimet ja kardinaliteetti

**Palautettava:** `er_diagram_advanced.png` tai `er_diagram_advanced.pdf` (tai päivitetty versio peruskaaviostasi)

---

## Edistyneempi vaihe — Osa 2: Skeeman laajennukset

Lisää tai muuta tauluja käyttäjien, opettajien ja ateriasuunnitelmien tukemiseksi. Varmista, että viite-eheys ja rajoitteet vastaavat edistyneempiä liiketoimintavaatimuksia.

**Palautettava:** `schema_advanced.sql` — kaikki `CREATE TABLE`-, `ALTER TABLE`- ja muut laajennuksiin tarvittavat lauseet

---

## Edistyneempi vaihe — Osa 3: Esimerkkidatan laajennukset

Lisää esimerkkidata niin, että:

- Käyttäjiä on vähintään 3, joista vähintään 1 on opettaja
- Ateriasuunnitelmia on vähintään 2
- Jokaisella ateriasuunnitelmalla on vähintään 3 reseptimerkintää

**Palautettava:** `seed_advanced.sql` — kaikki uudelle datalle tarvittavat `INSERT` -lauseet

---

## Edistyneempi vaihe — Osa 4: Indeksit

Lisää indeksit edistyneempiä liiketoimintavaatimuksia tukemaan.

**Palautettava:** `indexes.sql` — `CREATE INDEX` -lauseet

---

## Edistyneempi vaihe — Osa 5: Roolit

Määritä roolit ja myönnä oikeudet edistyneempien liiketoimintavaatimusten mukaisesti.

**Palautettava:** `roles.sql` — `CREATE ROLE`-, `CREATE USER`- ja `GRANT`-lauseet

---

## Edistyneempi vaihe — Osa 6: Lisäkyselyt

Kirjoita SQL-kyselyitä, jotka tuottavat seuraavat tulokset:

1. **Ateriasuunnitelmat käyttäjällä** — Listaa kaikki ateriasuunnitelmat omistajineen (käyttäjän nimi tai tunniste), järjestettynä omistajan, sitten ateriasuunnitelman nimen mukaan.

2. **Reseptit ateriasuunnitelmassa** — Valitulle ateriasuunnitelmalle näytä reseptin nimi, kategoria (tai kategoriat) ja paikka (päivä/ateria/järjestys), johon se on sijoitettu, järjestettynä asianmukaisesti.

3. **Käyttäjät ateriasuunnitelmalukumäärineen** — Jokaiselle käyttäjälle näytä käyttäjän tunniste/nimi ja heidän ateriasuunnitelmien lukumäärä, järjestettynä ateriasuunnitelmalukumäärän mukaan laskevaan järjestykseen. Sisällytä käyttäjät, joilla ei ole ateriasuunnitelmia.

**Palautettava:** `queries_advanced.sql` — kaikki 3 kyselyä lyhyine kommentteineen

---

# Vaihe 3 — ORM-konsolisovellus (Valinnainen)

Toteuta yksinkertainen konsolisovellus, joka yhdistää Resepti- ja ateriasuunnittelutietokantaasi ORM:ää käyttäen. Tämä vaihe tehdään **edistyneen vaiheen** jälkeen (tai perusvaiheen jälkeen, jos et suorittanut edistyneempää vaihetta).

---

## Teknologia

- **Oletus:** .NET 10 ja Entity Framework Core
- **Vaihtoehto:** Voit käyttää myös toista kieltä ja ORM:ää (esim. Python + SQLAlchemy, Java + Hibernate, Node.js + Prisma). Sovelluksen on yhdistettävä PostgreSQL-tietokantaan ja käytettävä ORM:ää — ei raakaa SQL-merkkijonoa.

---

## ORM-vaihe — Vaatimukset

### Sovelluksen toiminta

- Sovellus yhdistää Resepti- ja ateriasuunnittelutietokantaasi (perusskeema tai perus + edistynyt, jos suoritit edistyneen vaiheen).
- Sovellus käyttää ORM:ää datan lukemiseen. Vähintään sen on listattava reseptit (kategorioineen) tietokannasta.
- Valinnaisesti sovellus voi tukea datan lisäämistä, päivittämistä tai poistamista (esim. uudet reseptit, ateriasuunnitelmarivit).
- Sovelluksen ei saa olla kovakoodattuja yhteysmerkkijonoja tai salaisuuksia lähdekoodissa. Käytä konfiguraatiota (esim. `appsettings.json`, ympäristömuuttujat tai User Secrets .NETille).

### Palautettavat

1. **Lähdekoodi** — Koko konsolisovelluksen projekti (esim. `RecipePlannerConsole/` tai vastaava).
2. **README** — Lyhyt README projektin sisällä tai vieressä, jossa selitetään:
   - Miten yhteysmerkkijono konfiguroidaan
   - Miten sovellus rakennetaan ja ajetaan
   - Mitä teknologiaa ja ORM:ää käytit (jos et .NET + EF Core)

### .NET + EF Core -valinnassa

- Käytä .NET 10 ja EF Core PostgreSQL-providerin kanssa.
- Voit scaffoldata DbContextin ja entiteetit olemassa olevasta tietokannastasi tai määritellä ne manuaalisesti ja käyttää migraatioita. Sovelluksen on yhdistettävä vaiheissa 1 ja 2 rakentamaasi tietokantaan.
- Katso [Materiaali 13 — Entity Framework Core](../../Materials/13-Entity-Framework-Core.md), [Materiaali 16 — EF Core Scaffolding](../../Materials/16-Entity-Framework-Core-Scaffolding.md) ja [Materiaali 15 — EF Core Migrations](../../Materials/15-Entity-Framework-Core-Migrations.md).

---

**Palautettava:** Projektikansio (esim. `RecipePlannerConsole/`) ja `README.md` asennus- ja käyttöohjeineen.

---

# Palautusvaatimukset

### Perusvaihe (pakollinen — vaaditaan projektin pisteisiin)

| Tiedosto              | Vaihe | Pakollinen |
| --------------------- | ----- | ---------- |
| er_diagram.png / .pdf | Perus | Kyllä      |
| schema.sql            | Perus | Kyllä      |
| seed.sql              | Perus | Kyllä      |
| queries.sql           | Perus | Kyllä      |

### Edistyneempi vaihe (valinnainen — lisäpisteitä)

| Tiedosto                       | Vaihe     | Pakollinen                      |
| ------------------------------ | --------- | ------------------------------- |
| er_diagram_advanced.png / .pdf | Edistynyt | Jos suoritat edistyneen vaiheen |
| schema_advanced.sql            | Edistynyt | Jos suoritat edistyneen vaiheen |
| seed_advanced.sql              | Edistynyt | Jos suoritat edistyneen vaiheen |
| indexes.sql                    | Edistynyt | Jos suoritat edistyneen vaiheen |
| roles.sql                      | Edistynyt | Jos suoritat edistyneen vaiheen |
| queries_advanced.sql           | Edistynyt | Jos suoritat edistyneen vaiheen |

### ORM-vaihe (valinnainen — 5 pistettä)

| Palautus                                                  | Vaihe | Pakollinen               |
| --------------------------------------------------------- | ----- | ------------------------ |
| Konsolisovelluksen projekti (esim. RecipePlannerConsole/) | ORM   | Jos suoritat ORM-vaiheen |
| README asennus- ja käyttöohjeineen                        | ORM   | Jos suoritat ORM-vaiheen |

### Raportti (suositeltava)

| Palautus                 | Pakollinen                                                          |
| ------------------------ | ------------------------------------------------------------------- |
| REPORT.md tai REPORT.pdf | Suositeltava — käytä [Reporting-Guide-FI.md](Reporting-Guide-FI.md) |

**Arviointi:** Perus = 10 pistettä (pakollinen), Edistyneempi = 10 pistettä (valinnainen), ORM = 5 pistettä (valinnainen). **Yhteensä: 25 pistettä.**

Katso [Reporting-Guide-FI.md](Reporting-Guide-FI.md) miten esitellä projekti. Käytä [Self-Check-Guide-FI.md](Self-Check-Guide-FI.md) työn tarkistamiseen ennen palautusta.

### Kansiorakenne

```
Project-Recipe-MealPlanner/
├── Instructions-FI.md (tämä tiedosto)
├── Reporting-Guide-FI.md
├── Self-Check-Guide-FI.md
├── er_diagram.png
├── schema.sql
├── seed.sql
├── queries.sql
├── er_diagram_advanced.png
├── schema_advanced.sql
├── seed_advanced.sql
├── indexes.sql
├── roles.sql
├── queries_advanced.sql
├── RecipePlannerConsole/     (valinnainen — jos suoritat ORM-vaiheen)
│   └── (projektitiedostot)
├── README.md                 (ORM-vaiheen asennus- ja käyttöohjeet)
└── REPORT.md tai REPORT.pdf  (suositeltava — katso Reporting-Guide-FI.md)
```

---

# Itsetarkistus

### Perusvaihe

1. Suorittuuko skeema ilman virheitä tyhjällä tietokannalla?
2. Suorittuuko esimerkkidata ilman virheitä skeeman jälkeen?
3. Palauttavatko kaikki 6 kyselyä oikeat tulokset datallesi?
4. Onko ER-kaavio yhtenevä skeeman kanssa?
5. Vastaavatko rajoitteet ja viite-eheyssäännöt liiketoimintavaatimuksia?

### Edistyneempi vaihe

1. Suorittuuko `schema_advanced.sql` ilman virheitä perusskeeman päällä?
2. Suorittuuko `seed_advanced.sql` ilman virheitä?
3. Palauttavatko kaikki edistyneemmät kyselyt oikeat tulokset?
4. Tukevatko indeksit tarkoitettuja käyttötapauksia?
5. Ovatko rooleilla oikeat käyttöoikeudet?

### ORM-vaihe

1. Yhdistääkö sovellus tietokantaan ORM:ää käyttäen (ei raakaa SQL:ää)?
2. Listaako se reseptit (kategorioineen) tietokannasta?
3. Onko yhteysmerkkijono konfiguroitu konfiguraation kautta (ei kovakoodattuna)?
4. Selittääkö README miten sovellus rakennetaan, konfiguroidaan ja ajetaan?

---

# Viitteet

- Materiaalit 1-16
- [Reporting-Guide-FI.md](Reporting-Guide-FI.md) — Miten esitellä projekti kuvakaappauksin ja suunnitteluperusteluin
