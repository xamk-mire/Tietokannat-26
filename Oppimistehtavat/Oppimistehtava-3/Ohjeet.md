# Tehtävä 3 — TrailShop: Myymälät, varastot, indeksit ja roolit

> [!NOTE]
> Tehtävä jatkaa **Tehtävää 2**. Sinun tulee olla suorittanut TrailShop-tietokanta tauluineen `categories`, `products`, `customers`, `orders` ja `order_items` ennen kuin aloitat.

> [!IMPORTANT]
> Kopioi Assignment-3 -kansio tämän Instructions.md -tiedoston kanssa omaan luokkarekisteröintirepositorioosi.

Github classroom repositoriosi rakenteen pitäisi näyttää suunnilleen tältä:

```md
your-Classroom-repo-name
├── Assignment-1
│ ├── 01_schema.sql
│ ├── 01_seed.sql
│ ├── 01_queries.sql
│ └── Instructions.md
├── Assignment-2
│ ├── 02_schema.sql
│ ├── 02_seed.sql
│ ├── 02_queries.sql
│ └── Instructions.md
├── Assignment-3
│ └── Instructions.md
├── Exercise-1 (optional)
├── Exercise-2
├── Exercise-3
├── Exercise-4
└── README.md
```

## Edellytykset

- Suoritettu Tehtävä 2 (TrailShop-tietokanta asiakkailla ja tilauksilla)
- Tuntemus [Materiaalista 10 — Indeksit ja indeksointi](../../Materiaalit/10-Indeksit-ja-Indeksointi.md)
- Tuntemus [Materiaalista 11 — Käyttäjät ja roolit](../../Materiaalit/11-Kayttajat-ja-Roolit.md)

---

## Skenaario

TrailShop laajenee useisiin myymälöihin. Tiimi tarvitsee:

1. Myymäläkohtaisen varaston seurannan
2. Myymälätyöntekijät
3. Suorituskykyparannuksia indeksien avulla
4. Roolipohjaisen käyttöoikeushallinnan henkilöstölle ja analyytikoille

---

# Osa 1 — Uusien taulujen lisääminen

Luo **kolme uutta taulua** asianmukaisilla rajoitteilla ja viittaavalla eheydellä. Tulkitsi alla olevat vaatimukset sarakedefinitionsiksi ja rajoitteiksi.

---

### Taulu: `stores`

TrailShopilla on yksi verkkomyymälä ja kaksi fyysistä myymälää.

**Myymälän vaatimukset (tulkitse sarakkeiksi ja säännöiksi):**

- Jokaisella myymälällä on **automaattisesti generoitu numeerinen tunniste**
- Jokaisella myymälällä on **nimi**, jonka on oltava yksilöllinen
- Jokaisella myymälällä on **tyyppi**: `ONLINE` tai `PHYSICAL`
- Fyysisillä myymälöillä on **kaupunki** ja **katuosoite**
- Verkkomyymälällä ei ole fyysistä osoitetta (salli NULL-arvoja osoitekentille)

---

### Taulu: `stocks`

Jokainen myymälä seuraa varastoa tuotteittain.

**Varaston vaatimukset (tulkitse sarakkeiksi ja säännöiksi):**

- Jokainen varastorivi yhdistää yhden **myymälän** ja yhden **tuotteen** (molemmat vaaditaan)
- Tuote voi esiintyä **vain kerran per myymälä** (käytä yhdistelmäperusavainta)
- Jokaisella varastorivillä on **määrä** (0 tai enemmän)
- Jos myymälä poistetaan, sen varastorivit poistetaan myös
- Tuotetta **ei saa** poistaa, jos sitä viitataan millään varastorivillä

---

### Taulu: `employees`

Jokainen työntekijä kuuluu yhteen myymälään.

**Työntekijän vaatimukset (tulkitse sarakkeiksi ja säännöiksi):**

- Jokaisella työntekijällä on **automaattisesti generoitu numeerinen tunniste**
- Jokaisella työntekijällä on **koko nimi** (pakollinen)
- Jokaisella työntekijällä on **rooliootsikko** (pakollinen)
- Jokainen työntekijä kuuluu yhteen **myymälään** (pakollinen)
- Jos myymälällä on työntekijöitä, myymälää **ei saa** pystyä poistamaan

---

### Luontijärjestys

Luo taulut riippuvuusjärjestyksessä:

1. `stores` (ei viiteavaimia)
2. `stocks` (viittaa stores- ja products-tauluihin)
3. `employees` (viittaa stores-tauluun)

---

### Palautettava

Lisää `CREATE TABLE` -lauseet tiedostoon `03_schema.sql`.

---

# Osa 2 — Esimerkkidatan lisääminen

Lisää realistista testidataa, jotta tiimi voi harjoitella hakuja ja suorituskykyä.

### Vaihe 1 — Lisää myymälät

Lisää **3 myymälää**:

| name               | type     | city     | street_address     |
| ------------------ | -------- | -------- | ------------------ |
| TrailShop Online   | ONLINE   | _(NULL)_ | _(NULL)_           |
| TrailShop Helsinki | PHYSICAL | Helsinki | Mannerheimintie 10 |
| TrailShop Kuopio   | PHYSICAL | Kuopio   | Puijonkatu 5       |

---

### Vaihe 2 — Lisää työntekijät

Lisää **6 työntekijää** (2 per myymälä). Käytä oikeita `store_id` -arvoja (tarkista `SELECT * FROM stores;`).

| full_name        | role_title      | hire_date  | store (name)       |
| ---------------- | --------------- | ---------- | ------------------ |
| Aino Laine       | Store Manager   | 2023-05-10 | TrailShop Online   |
| Mikko Saarinen   | Sales Support   | 2024-01-15 | TrailShop Online   |
| Ella Virtanen    | Store Manager   | 2022-09-01 | TrailShop Helsinki |
| Jari Lehtonen    | Sales Associate | 2023-11-20 | TrailShop Helsinki |
| Niko Hakkarainen | Store Manager   | 2021-04-12 | TrailShop Kuopio   |
| Salla Niemi      | Sales Associate | 2024-02-05 | TrailShop Kuopio   |

---

### Vaihe 3 — Lisää varastot

Lisää varastorivejä **vähintään 8 tuotteelle** kolmen myymälän yli.

Säännöt:

- Jokaisella myymälällä on vähintään **5 tuotetta** varastossa
- Vähintään **2 tuotetta** on saatavilla **kaikissa kolmessa** myymälässä
- Käytä realistisia määriä (0–100)

---

### Palautettava

Luo `03_seed.sql` kaikilla INSERT-lauseilla myymälöille, työntekijöille ja varastoille.

---

# Osa 3 — Indeksointi

Luo indeksit hakujen suorituskyvyn parantamiseksi. Katso ohje [Materiaalista 10](../../Materiaalit/10-Indeksit-ja-Indeksointi.md).

### Vaaditut indeksit

1. **Varaston hakuindeksi** — Indeksoi `stocks` sarakkeilla `store_id` ja `product_id` nopeuttaaksesi varastotarkistuksia myymäläkohtaisesti.
2. **Työntekijän hakuindeksi** — Indeksoi `employees` sarakkeella `store_id` nopeuttaaksesi myymälän henkilöstöhautuja.
3. **Tilaushakuindeksi** — Lisää indeksi tauluun `orders(customer_id)` nopeuttaaksesi asiakkaan tilaushistoriahautuja.
4. **Tuotteen nimen hakuindeksi** — Lisää indeksi tauluun `products(name)` nopeuttaaksesi tuotehautuja.

Käytä indekseille erillistä tiedostoa.

---

### Palautettava

Luo `03_indexes.sql` kaikilla `CREATE INDEX` -lauseilla.

---

# Osa 4 — Käyttäjät ja roolit

Määritä roolit ja oikeudet TrailShop-henkilöstölle. Katso syntaksi [Materiaalista 11](../../Materiaalit/11-Kayttajat-ja-Roolit.md).

### Vaaditut roolit

1. **role_store_manager**
   - Voi SELECT/INSERT/UPDATE taulussa `stocks`
   - Voi SELECT tauluissa `products`, `stores` ja `employees`
2. **role_sales_associate**
   - Voi SELECT tauluissa `products` ja `stocks`
3. **role_analyst**
   - Voi SELECT tauluissa `customers`, `orders`, `order_items`, `products`, `stores`, `stocks`

### Vaaditut käyttäjät

Luo kolme käyttäjää ja määritä roolit:

- `manager1` → `role_store_manager`
- `sales1` → `role_sales_associate`
- `analyst1` → `role_analyst`

Aseta yksinkertaiset salasanat testausta varten (esim. `manager1`, `sales1`, `analyst1`).

---

### Palautettava

Luo `03_roles.sql` kaikilla `CREATE ROLE`-, `CREATE USER`- ja `GRANT`-lauseilla.

---

# Osa 5 — Kyselyt

Kirjoita SQL-kyselyitä, jotka yhdistävät uudet taulut olemassa oleviin.

### Vaaditut kyselyt

1. **Myymälän varastolista** — Näytä jokainen myymälän nimi tuotenimien ja määrien kanssa. Järjestä myymälän nimen, sitten tuotteen nimen mukaan.
2. **Alhaisen varaston raportti** — Näytä tuotteet, joiden kokonaisvarasto kaikissa myymälöissä on alle 10. Sisällytä tuotteen nimi ja kokonaismäärä.
3. **Työntekijät per myymälä** — Näytä jokainen myymälän nimi ja työntekijämäärä. Sisällytä myymälät, joilla ei ole työntekijöitä (LEFT JOIN).
4. **Eniten varastossa olevat tuotteet** — Näytä 5 tuotetta, joilla on korkein kokonaisvarasto kaikissa myymälöissä.

---

### Palautettava

Luo `03_queries.sql` kaikilla 4 kyselyllä.

---

# Palautusvaatimukset

Palauta nämä tiedostot Assignment-3 -kansiosta:

- `03_schema.sql` — CREATE TABLE myymälöille, varastoille, työntekijöille
- `03_seed.sql` — INSERT-lauseet myymälöille, työntekijöille, varastoille
- `03_indexes.sql` — CREATE INDEX -lauseet
- `03_roles.sql` — CREATE ROLE/USER/GRANT -lauseet
- `03_queries.sql` — Kaikki 4 kyselyä

Luokkarekisteröintirepositoriosi pitäisi näyttää tältä:

```md
your-Classroom-repo-name
├── Assignment-1
│ ├── 01_schema.sql
│ ├── 01_seed.sql
│ ├── 01_queries.sql
│ └── Instructions.md
├── Assignment-2
│ ├── 02_schema.sql
│ ├── 02_seed.sql
│ ├── 02_queries.sql
│ └── Instructions.md
├── Assignment-3
│ ├── 03_schema.sql (uusi)
│ ├── 03_seed.sql (uusi)
│ ├── 03_indexes.sql (uusi)
│ ├── 03_roles.sql (uusi)
│ ├── 03_queries.sql (uusi)
│ └── Instructions.md
├── Exercise-1
├── Exercise-2
├── Exercise-3
├── Exercise-4
└── README.md
```

---

# Itsearviointi

Ennen palautusta tarkista:

1. Suoriutuuko `03_schema.sql` ilman virheitä (olettaen että Tehtävän 1 ja 2 taulut ovat olemassa)?
2. Lisääkö `03_seed.sql` kaikki myymälät, työntekijät ja varastot ilman virheitä?
3. Luoko `03_indexes.sql` kaikki indeksit ilman virheitä?
4. Suoriutuvatko rooli- ja käyttäjäkomennot tiedostossa `03_roles.sql` ilman virheitä?
5. Palauttavatko kyselyt 1 ja 2 tulokset, jotka vastaavat lisäämiäsi varastodataa?
