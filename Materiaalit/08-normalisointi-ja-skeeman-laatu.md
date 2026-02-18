# Normalisointi ja skeeman laatu

### Redundanssin vähentäminen ja datan järkevä rakenne

[Materiaalissa 03](Materiaalit/03-Relaatiotietokanta.md) tutustuimme relaatiomalliin ja tauluihin.  
[Materiaaleissa 05](Materiaalit/05-SQL-perusteet.md)–[07](Materiaalit/07-SQL-perusteet-3.md) rakensimme skeemoja viiteavaimilla ja rajoitteilla.

Tässä luvussa keskitytään **skeeman suunnittelun laatuun**:

- **Redundanssin ongelmat** — miksi päällekkäinen data aiheuttaa ongelmia
- **Normaalimuodot (1NF, 2NF, 3NF)** — standardisäännöt taulujen järjestämiseksi
- **Milloin denormalisointi on hyväksyttävää** — puhtauden vaihtaminen käytännön tarpeisiin

Uutta SQL-syntaksia ei tule; kyse on siitä, *miten* taulut rakennetaan, jotta data pysyy yhtenäisenä ja ylläpidettävänä.

---

# 1) Redundanssin ongelmat

**Redundanssi** tarkoittaa saman tiedon tallentamista useaan paikkaan. Pieni redundanssi voi olla tarkoituksellista (esim. välimuisti); liikaa johtaa **anomalioihin**: epäjohdonmukaiseen tai vaikeasti ylläpidettävään dataan.

---

## Mitä redundanssissa menee vikaan

### Päivitysanomaliat

Jos sama tieto on usealla rivillä, yhden paikan päivittäminen jättää muut vanhentuneiksi.

**Esimerkki — yksi taulu toistuvilla asiakastiedoilla:**

| order_id | order_date  | customer_name | customer_email    | product_name | quantity |
| -------: | ----------- | ------------- | ----------------- | ------------ | -------- |
| 1        | 2024-01-15  | Emma Virtanen | emma@example.com  | Tent         | 1        |
| 2        | 2024-02-20  | Emma Virtanen | emma@example.com  | Jacket       | 1        |
| 3        | 2024-01-22  | Jussi Mäkinen| jussi@example.com | Sleeping Bag| 1        |

Jos Emma vaihtaa sähköpostinsa, jokainen rivi, jossa hän esiintyy, on päivitettävä. Jos yksi rivi jää päivittämättä → data on epäjohdonmukaista (kaksi eri sähköpostia samalle asiakkaalle).

---

### Lisäysanomaliat

Emme voi tallentaa tietoa ennen kuin toinen tieto on olemassa, tai joudumme toistamaan tai keksimään dataa.

**Esimerkki:** Haluamme lisätä uuden asiakkaan, jolla ei ole vielä tilauksia. Yllä olevalla taululla "Liisa Korhonen, liisa@example.com" ei ole paikkaa ilman keksittyä tilausta tai NULL-arvoja tilaussarakkeissa. Skeema ei tue "asiakas ilman tilausta".

---

### Poistoanomaliat

Yhden tiedon poistaminen poistaa vahingossa toisen.

**Esimerkki:** Jos poistamme Jussi Mäkinenin ainoan tilauksen, katoaa myös ainoa tieto siitä, että Jussi on asiakas. Saattaa olla tarpeen säilyttää asiakastiedot historiaa tai tulevia tilauksia varten.

---

## Yhteenveto: miksi vältämme redundanssia

| Ongelma            | Vaikutus                                                                 |
| ------------------ | ------------------------------------------------------------------------ |
| **Päivitysanomalia** | Sama tieto monessa paikassa → helppo päivittää osa, ei kaikki → epäjohdonmukaisuus |
| **Lisäysanomalia**   | Ei voi lisätä validia tietoa (esim. asiakas) ilman toista (esim. tilaus) |
| **Poistoanomalia**   | Yhden asian poistaminen (esim. viimeinen tilaus) poistaa toisen (esim. asiakas) |

**Normalisointi** on taulujen uudelleenjärjestelyä redundanssin ja näiden anomalioiden poistamiseksi, yleensä jakamalla data useampaan tauluun ja linkittämällä ne avaimilla.

---

# 2) Normaalimuodot (1NF, 2NF, 3NF)

Normaalimuodot ovat rakenteen tasoja. Jokainen taso perustuu edelliseen: 3NF-taulussa oleva taulu on myös 2NF- ja 1NF-taulussa.

---

## Ensimmäinen normaalimuoto (1NF)

Taulu on **1NF**:ssä, jos:

1. **Atomiarvot** — Jokainen solu sisältää yhden arvon, ei listaa tai sisäkkäistä rakennetta.
2. **Yksilölliset rivit** — Jokainen rivi on yksilöitävissä (esim. pääavaimella).
3. **Yhtenäiset sarakkeet** — Jokaisella sarakkeella on yksi merkitys ja yksi tietotyyppi kaikilla riveillä.

### Mitä 1NF kieltää

- **Toistuvat ryhmät** — esim. `phone1`, `phone2`, `phone3` tai sarake, jossa on `"A, B, C"`.
- **Ei pääavainta** — jolloin rivit eivät ole selvästi erotettavissa.

### Esimerkki — ei 1NF:ssä

| student_id | full_name   | courses        |
| ---------: | ----------- | -------------- |
| 1          | Aino Laine  | DB, Algorithms |
| 2          | Mika Virtanen | DB          |

`courses` ei ole atomiarvo: se sisältää useita arvoja yhdessä solussa. Ei voi luotettavasti kysyä "kuka opiskelee Algorithms?" tai muuttaa yhtä kurssia ilman merkkijonon jäsentämistä.

### Esimerkki — 1NF:ssä

Jaetaan kahteen tauluun: yksi rivi per opiskelija, yksi rivi per ilmoittautuminen.

**students**

| student_id | full_name    |
| ---------: | ------------ |
| 1          | Aino Laine   |
| 2          | Mika Virtanen|

**enrollments** (yksi rivi per opiskelija–kurssi -pari)

| student_id | course_id |
| ---------: | --------: |
| 1          | 1         |
| 1          | 2         |
| 2          | 1         |

Jokainen solu on atomiarvo; jokainen rivi on tunnistettavissa (esim. avaimella `(student_id, course_id)`).

---

## Toinen normaalimuoto (2NF)

Taulu on **2NF**:ssä, jos se on 1NF:ssä ja:

- **Ei osittaista riippuvuutta** — Jokainen ei-avainsarake riippuu **koko** pääavaimesta, ei vain osasta siitä.

Tämä merkitsee, kun pääavain on **yhdistetty** (useampi sarake). Jos attribuutti riippuu vain avaimen osasta, se toistuu jokaisessa kyseiseen osaan liittyvässä yhdistelmässä → redundanssi.

### Esimerkki — rikkoo 2NF:n

| student_id | course_id | full_name   | course_title | grade |
| ---------: | --------: | ----------- | ------------ | ----- |
| 1          | 1         | Aino Laine  | Databases    | 5     |
| 1          | 2         | Aino Laine  | Algorithms   | 4     |
| 2          | 1         | Mika Virtanen | Databases  | 3     |

- Pääavain: `(student_id, course_id)`.
- `full_name` riippuu vain `student_id`:stä → toistuu jokaiselle Ainon kurssille (osittainen riippuvuus).
- `course_title` riippuu vain `course_id`:stä → toistuu jokaiselle kyseisellä kurssilla olevalle opiskelijalle (osittainen riippuvuus).
- `grade` riippuu **molemmista** → OK.

Tuloksena redundanssi ja päivitys-/lisäys-/poistoanomaliat nimille ja tituleille.

### Korjaus: jako riippuvuuden mukaan

- **students** — `student_id` (PK), `full_name`.
- **courses** — `course_id` (PK), `course_title`.
- **grades** — `(student_id, course_id)` (PK), `grade`.

Nyt jokainen ei-avainsarake riippuu taulunsa koko pääavaimesta. Ei osittaisia riippuvuuksia → 2NF.

---

## Kolmas normaalimuoto (3NF)

Taulu on **3NF**:ssä, jos se on 2NF:ssä ja:

- **Ei transitiivista riippuvuutta** — Mikään ei-avainsarake ei riipu toisesta ei-avainsarakkeesta.

Eli jokaisen ei-avainsarakkeen on riipputtava **vain** pääavaimesta (tai kandidattiavaimesta), ei muista ei-avainsarakkeista.

### Esimerkki — rikkoo 3NF:n

| course_id | title      | teacher_id | teacher_name  |
| --------- | ---------- | ---------: | ------------- |
| 1         | Databases  | 1          | Liisa Korhonen|
| 2         | Algorithms | 2          | Pekka Salo    |

- Pääavain: `course_id`.
- `teacher_name` riippuu `teacher_id`:stä ja `teacher_id` riippuu `course_id`:stä. Siis `teacher_name` riippuu `course_id`:stä **kautta** `teacher_id`:n (transitiivinen riippuvuus).
- Jos Liisa vaihtaa nimeään, jokainen kurssirivi, jolla hän on opettajana, on päivitettävä → redundanssi ja päivitysanomalia.

### Korjaus: transitiivinen riippuvuus pois

- **courses** — `course_id` (PK), `title`, `teacher_id` (FK).
- **teachers** — `teacher_id` (PK), `teacher_name`.

Nyt `teacher_name` on vain taulussa `teachers`; `courses` pitää vain avaimen. Ei transitiivista riippuvuutta → 3NF.

---

## Pikaviite: 1NF, 2NF, 3NF

| Muoto | Vaatimus |
| ----- | -------- |
| **1NF** | Atomiarvot; yksilölliset rivit (pääavain); yksi merkitys per sarake. |
| **2NF** | 1NF + ei osittaista riippuvuutta (jokainen ei-avainsarake riippuu **koko** avaimesta). |
| **3NF** | 2NF + ei transitiivista riippuvuutta (mikään ei-avainsarake ei riipu toisesta ei-avainsarakkeesta). |

Käytännössä: jaa taulut niin, että jokainen taulu kuvaa yhden "asian" (yhden entiteetin tai yhden suhteen), ja ei-avainsarakkeet riippuvat vain kyseisen taulun avaimesta. Viiteavaimet linkittävät taulut.

---

# 3) Milloin denormalisointi on hyväksyttävää

**Denormalisointi** tarkoittaa tarkoituksellista redundanssin lisäämistä (esim. toisen taulun arvon kopioiminen tai taulujen yhdistäminen) kyselyjen yksinkertaistamiseksi tai suorituskyvyn parantamiseksi.

Normalisointi on oletus transaktiodatalle: se vähentää anomalioita ja pitää skeeman selkeänä. Denormalisointi on **kompromissi**: hyväksytään redundanssia ja ylimääräistä ylläpitoa vastineeksi hyödyistä muualla.

---

## Tilanteet, joissa denormalisointia usein harkitaan

### 1. Lukupainotteinen raportointi tai analytiikka

- **Ajatus:** Raportointitaulu tai -näkymä voi duplikoida dataa useista normalisoiduista tauluista (esim. esiliitetty "tilausyhteenveto" asiakasnimellä, tuotenimellä, summillä).
- **Hyöty:** Raportit toimivat vähemmällä JOINilla ja kuormittavat vähemmän transaktioskeemaa.
- **Hinta:** Duplikoidun datan on pysyttävä synkassa (triggereillä, ETL:llä tai sovelluslogiikalla). Vanhentunut tai epäjohdonmukainen data on riski.

### 2. Suorituskykykriittiset lukupolut

- **Ajatus:** Usein tarvittavan arvon tallentaminen samalle riville, josta sitä luetaan (esim. `order_total` taulussa `orders`, vaikka se voitaisiin laskea `order_items`:istä).
- **Hyöty:** Vähemmän liitoksia tai koostelaskuja lukuvaiheessa; joskus parempi indeksien hyödyntäminen.
- **Hinta:** Kirjoituksissa duplikoidun arvon on päivitettävä; logiikka on kahdessa paikassa (laskenta vs. tallennus).

### 3. Yksinkertaisuus tietylle käyttötapaukselle

- **Ajatus:** Pieni, kiinteän muotoinen taulu (esim. konfig tai hakutaulu) voi toistaa nimeä tai koodia useassa sarakkeessa, jos se yksinkertaistaa yhtä sovellusta.
- **Hyöty:** Yksinkertaisempi koodi ja kyselyt kyseiselle tapaukselle.
- **Hinta:** Hyväksyttävää vain, kun dataa on vähän, se muuttuu harvoin ja redundanssi on rajoitettua ja hallittua.

### 4. Välimuistit ja materialisoidut näkymät

- **Ajatus:** Materialisoitu näkymä tai välimuistitaulu, joka tallentaa monimutkaisen kyselyn tuloksen (esim. kojetaulun yhteenveto).
- **Hyöty:** Erittäin nopeat lukemiset; pääskeema pysyy normalisoituna.
- **Hinta:** Päivitysstrategia (milloin ja miten päivitetään); voi olla vanhentunutta ennen päivitystä.

---

## Ohjeet

| Tee | Vältä |
| --- | ----- |
| Dokumentoi *miksi* ja *missä* denormalisoit | Päätransaktioskeeman denormalisointia "kaikkialla" |
| Pidä yksi totuuden lähde ja synkronoi siitä | Useiden lähteiden ajautumista erilleen |
| Suosi materialisoituja näkymiä / raportointitauluja ydintaulujen muuttamisen sijaan | Redundanttien sarakkeiden lisäämistä ydintauluihin ilman selkeää suorituskyvytarvetta |
| Tarkista uudelleen, kun vaatimukset tai käyttö muuttuu | Denormalisointia "varalta" ennen todellisen ongelman mittaamista |

---

## Yhteenveto

| Aihe | Keskeiset asiat |
| ---- | ---------------- |
| **Redundanssi** | Duplikoidut tiedot → päivitys-, lisäys- ja poistoanomaliat. Normalisointi vähentää redundanssia jakamalla taulut ja käyttämällä avaimia. |
| **1NF** | Atomiarvot, yksilölliset rivit, yksi merkitys per sarake. Ei toistuvia ryhmiä. |
| **2NF** | Ei osittaista riippuvuutta: jokainen ei-avainsarake riippuu koko pääavaimesta. |
| **3NF** | Ei transitiivista riippuvuutta: mikään ei-avainsarake ei riipu toisesta ei-avainsarakkeesta. |
| **Denormalisointi** | Tarkoituksellista redundanssia suorituskyvyn tai yksinkertaisuuden vuoksi. Käytä harvakseltaan, dokumentoi ja pidä selkeä totuuden lähde. |

---

_Materiaali 08 loppuu._
