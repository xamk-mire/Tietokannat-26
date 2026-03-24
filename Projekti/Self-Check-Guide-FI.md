# Itsetarkistusohje — Resepti- ja ateriasuunnittelutietokanta -projekti

Käytä tätä tarkistuslistaa ennen palautusta varmistaaksesi, että työsi täyttää arviointikriteerit. Ruksaa jokainen suoritettu kohta. Kohdat, joissa on *(pakollinen)*, tarvitaan perusvaiheessa.

**Pisteyhteenveto:** Perus 10 pistettä | Edistynyt 10 pistettä | ORM 5 pistettä | **Yhteensä 25 pistettä**

---

## Perusvaihe (10 pistettä)

### ER-kaavio (2 pistettä)

- [ ] *(pakollinen)* Kaikki entiteetit näkyvät (kategoriat, reseptit, ainesosat ja liitostaulut)
- [ ] Pääavaimet ja viiteavaimet on merkitty
- [ ] Kardinaliteetti on selkeä (1:N, M:N)
- [ ] Valinnaiset vs pakolliset attribuutit näkyvät
- [ ] Kaavio on luettava (selkeät nimet, ei päällekkäisiä elementtejä)

### Skeema (3 pistettä)

- [ ] *(pakollinen)* Kaikki vaaditut taulut ovat olemassa
- [ ] Tietotyypit sopivat jokaiselle sarakkeelle
- [ ] Rajoitteet on käytetty tarpeen mukaan (NOT NULL, UNIQUE, CHECK)
- [ ] Viiteavaimilla on sopiva viite-eheys (mitä tapahtuu poistettaessa)
- [ ] Resepti–kategoria -suhde tukee useita kategorioita per resepti
- [ ] `schema.sql` suorittuu ilman virheitä tyhjällä tietokannalla

### Esimerkkidata (2 pistettä)

- [ ] *(pakollinen)* Vähintään 4 kategoriaa
- [ ] Vähintään 6 reseptiä
- [ ] Vähintään 12 ainesosaa
- [ ] Vähintään 15 resepti–ainesosa -liitosta
- [ ] Vähintään 15 resepti–kategoria -liitosta
- [ ] Vähintään 2 reseptiä useilla kategorioilla
- [ ] Jokaisella reseptillä vähintään 2 ainesosaa
- [ ] `seed.sql` suorittuu ilman virheitä skeeman jälkeen

### Kyselyt (3 pistettä)

- [ ] *(pakollinen)* Kysely 1: Reseptit kategorioineen — oikea tulos ja järjestys
- [ ] Kysely 2: Reseptin ainesosat — oikea tulos ja järjestys
- [ ] Kysely 3: Reseptit tietyn ainesosan kanssa — oikea tulos
- [ ] Kysely 4: Ainesosamäärä per resepti — oikea GROUP BY ja COUNT
- [ ] Kysely 5: Käyttämättömät ainesosat — oikea tulos (ainesosat, joita ei ole missään reseptissä)
- [ ] Kysely 6: Keskimääräinen valmistusaika kategorialla — oikea tulos, tyhjät kategoriat käsitelty

---

## Edistyneempi vaihe (10 pistettä) — jos suoritit sen

### Laajennettu ER-kaavio (1 piste)

- [ ] Käyttäjät ja opettajat (tai vastaava) näkyvät
- [ ] Ateriasuunnitelmat ja niiden linkit käyttäjiin ja resepteihin näkyvät
- [ ] Pääavaimet, viiteavaimet ja kardinaliteetti oikein

### Skeeman laajennukset (3 pistettä)

- [ ] Taulut käyttäjille ja opettajille (tai rooleille)
- [ ] Taulut ateriasuunnitelmille ja suunnitelmariveille
- [ ] Viiteavaimet ja rajoitteet oikein
- [ ] `schema_advanced.sql` suorittuu ilman virheitä perusskeeman päällä

### Esimerkkidatan laajennukset (1 piste)

- [ ] Vähintään 3 käyttäjää
- [ ] Vähintään 1 opettaja
- [ ] Vähintään 2 ateriasuunnitelmaa
- [ ] Jokaisella ateriasuunnitelmalla vähintään 3 reseptimerkintää
- [ ] `seed_advanced.sql` suorittuu ilman virheitä

### Indeksit (2 pistettä)

- [ ] Indeksit tukevat reseptien hakutta kategorian mukaan
- [ ] Indeksit tukevat reseptin ainesosien listaa
- [ ] Indeksit tukevat reseptien hakutta ainesosan mukaan
- [ ] Indeksit tukevat ainesosien hakutta nimen mukaan
- [ ] Indeksit tukevat ateriasuunnitelmien hakutta käyttäjän mukaan
- [ ] Indeksit tukevat suunnitelmarivien hakutta reseptin mukaan

### Roolit (2 pistettä)

- [ ] Opettajarooli sopivilla oikeuksilla
- [ ] Tavallinen käyttäjärooli sopivilla oikeuksilla
- [ ] Katselijarooli (vain luku)
- [ ] `roles.sql` suorittuu ilman virheitä

### Lisäkyselyt (1 piste)

- [ ] Kysely 1: Ateriasuunnitelmat käyttäjällä — oikea tulos
- [ ] Kysely 2: Reseptit ateriasuunnitelmassa — oikea tulos paikkatiedoin
- [ ] Kysely 3: Käyttäjät ateriasuunnitelmalukumäärineen — sisältää käyttäjät ilman suunnitelmia

---

## Konsolisovellus — ORM-vaihe (5 pistettä) — jos suoritit sen

### Sovellus (5 pistettä)

- [ ] Sovellus yhdistää tietokantaan ORM:ää käyttäen (ei raakaa SQL:ää)
- [ ] Sovellus listaa reseptit (kategorioineen)
- [ ] Yhteysmerkkijono on konfiguraatiossa, ei kovakoodattuna
- [ ] README selittää miten konfiguroida, rakentaa ja ajaa
- [ ] Sovellus rakentuu ja suorittuu onnistuneesti

---

## Ennen palautusta

- [ ] Kaikki tiedostot on nimetty oikein (katso Ohjeet)
- [ ] Ei salasanoja tai arkaluonteisia tietoja koodissa tai kuvakaappauksissa
- [ ] ER-kaavio vastaa skeemaasi
- [ ] Olet ajanut koko työnkulun: skeema → seed → kyselyt (ja edistynyt/ORM jos sovellettavissa)

---

## Arvioitu pistemäärä

| Jos suoritit... | Arv. max pisteet |
|-----------------|-------------------|
| Vain perusvaiheen | 10 |
| Perus + edistynyt | 20 |
| Perus + edistynyt + ORM | 25 |

*Osittainen hyväksyntä on mahdollista. Tämä ohje auttaa tunnistamaan puutteet; opettaja käyttää täyttä arviointimatriisia lopullisessa arvioinnissa.*
