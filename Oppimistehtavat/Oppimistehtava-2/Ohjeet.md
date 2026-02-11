# Tehtävä 2 — TrailShop: Asiakkaat, tilaukset ja liitokset (JOIN)

> [!NOTE]
> Tehtävä jatkaa **Tehtävää 1**. Sinun tulee olla suorittanut trailshop-tietokanta (kategoriat ja tuotteet) ennen kuin aloitat.

> [!IMPORTANT]
> Kopioi Oppimistehtava-2 -kansio tämän Ohjeet.md -tiedoston kanssa luokkarepositorioosi.

Luokkarepositoriosi rakenne voi näyttää tältä:

```md
luokkarepo-nimi
├── Oppimistehtava-1
│ ├── 01_schema.sql
│ ├── 01_seed.sql
│ ├── 01_queries.sql
│ └── Ohjeet.md
├── Oppimistehtava-2
│ └── Ohjeet.md
├── Harjoitus-1
├── Harjoitus-2
├── Harjoitus-3
└── README.md
```

## Esitiedot

- Suoritettu Tehtävä 1 (trailshop-tietokanta tauluineen `categories` ja `products`)
- Tutustuminen [Materiaaliin 07 — SQL-perusteet osa III](../../Materiaalit/07-SQL-perusteet-3.md): liitokset (JOIN), viite-eheys ja rajoitteet

---

## Skenaario

TrailShopin tietokanta laajenee. Tiimi tarvitsee nyt tukea **asiakkaille** ja **tilauksille**. Tehtäväsi on:

1. Lisätä viiteavainrajoitteet olemassa olevaan `products`-tauluun (viitaten `categories`-tauluun)
2. Luoda kolme uutta taulua: `customers`, `orders` ja `order_items`
3. Lisätä esimerkkidata ja kirjoittaa JOIN-kyselyitä usean taulun datan yhdistämiseksi

---

# Osa 1 — Lisää viiteavain tuotteisiin (products)

Tehtävässä 1 taululla `products` oli sarake `category_id`, mutta **ei viiteavainrajoitetta**. Lisää se nyt.

### Vaatimukset

- Lisää viiteavainrajoite siten, että `products.category_id` viittaa `categories(category_id)` -tauluun
- Käytä `ON DELETE RESTRICT` (oletus) — emme halua poistaa kategoriaa, jos tuotteet viittaavat siihen

### Palautettava

Luo tai päivitä skeematiedostosi. Voit joko:

- Lisätä `ALTER TABLE` -lauseen uuteen tiedostoon `02_schema.sql`

**Esimerkkimalli (Materiaali 07 — yliopistoskeema):** Jos taululla `enrollments` olisi `student_id` ilman viiteavainta, lisäisit:

```sql
ALTER TABLE enrollments
  ADD CONSTRAINT fk_enrollments_student
  FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE RESTRICT;
```

TrailShopille sovella sama malli tauluihin `products` ja `categories`.

---

# Osa 2 — Luo uudet taulut

Luo kolme uutta taulua asianmukaisilla rajoitteilla ja viite-eheydellä. Tulkitse alla olevat vaatimukset sarakemäärittelyiksi ja rajoitteiksi.

---

### Taulu: `customers`

TrailShopin tulee tallentaa asiakastiedot.

**Asiakasvaatimukset (tulkitse sarakkeiksi + sääntöiksi):**

- Jokaisella asiakkaalla on **automaattisesti generoitu numeerinen tunniste**
- Jokaisella asiakkaalla on **koko nimi**, joka on aina oltava
- Asiakkaalla voi olla **sähköposti**; kahden asiakkaan ei saa jakaa samaa sähköpostia
- Sähköposti voi puuttua joiltakin asiakkailta

---

### Taulu: `orders`

Jokainen tilaus kuuluu yhdelle asiakkaalle ja tallentaa tilauspäivämäärän.

**Tilausvaatimukset (tulkitse sarakkeiksi + sääntöiksi):**

- Jokaisella tilauksella on **automaattisesti generoitu numeerinen tunniste**
- Jokaisen tilauksen tulee tallentaa **asiakas** (`customer_id`)
- Jokaisella tilauksella on **tilauspäivä**
- Jos asiakkaalla on tilauksia, asiakasta **ei saa** voida poistaa — käytä viiteavaimen oikeaa rajoitetta

---

### Taulu: `order_items`

Jokainen tilaus sisältää yhden tai useamman tuotteen. `order_items` on liitostaulu, joka yhdistää `orders`- ja `products`-taulut. Jokainen rivi vastaa yhtä tuotetta yhdessä tilauksessa, määrän ja ostohinnan kanssa.

**Tilausrivivaatimukset (tulkitse sarakkeiksi + sääntöiksi):**

- Jokainen tilausrivi linkittää yhden **tilauksen** ja yhden **tuotteen** (molemmat pakollisia)
- Jokaisella tilausrivillä on **määrä** (vähintään 1)
- Jokainen tilausrivi tallentaa **yksikköhinnan** tilaushetkellä desimaalilukuna (käytä NUMERIC tai DECIMAL)
- Sama tuote voi esiintyä tilauksessa vain kerran — käytä yhdistettyä pääavainta `(order_id, product_id)`
- Kun tilaus poistetaan, sen tilausrivit tulee poistaa myös — käytä tilausviitteen oikeaa rajoitetta
- **Tuotetta ei saa** poistaa, jos sitä viitataan jossakin tilausrivissä — käytä tuoteviitteen oikeaa rajoitetta

---

### Luontijärjestys

Luo taulut riippuvuusjärjestyksessä:

1. `customers` (ei viiteavaimia)
2. `orders` (viittaa asiakkaisiin)
3. `order_items` (viittaa tilauksiin ja tuotteisiin)

---

### Palautettava

Lisää `CREATE TABLE` -lauseet tiedostoon `02_schema.sql`.

---

# Osa 3 — Lisää esimerkkidata

Lisää realistista testidataa, jotta tiimi voi harjoitella kyselyitä.

### Vaihe 1 — Lisää asiakkaat

Lisää **4 asiakasta**:

| full_name      | email             |
| -------------- | ----------------- |
| Emma Virtanen  | emma@example.com  |
| Jussi Mäkinen  | jussi@example.com |
| Liisa Korhonen | liisa@example.com |
| Olli Nieminen  | _(NULL)_          |

---

### Vaihe 2 — Lisää tilaukset

Lisää **5 tilausta**. Käytä oikeita `customer_id`-arvoja (tarkista komennolla `SELECT * FROM customers;`).

| asiakas (full_name) | order_date |
| ------------------- | ---------- |
| Emma Virtanen       | 2024-01-15 |
| Emma Virtanen       | 2024-02-20 |
| Jussi Mäkinen       | 2024-01-22 |
| Liisa Korhonen      | 2024-02-10 |
| Olli Nieminen       | 2024-03-01 |

---

### Vaihe 3 — Lisää tilausrivit

Lisää tilausrivit siten, että:

- **Tilaus 1** (Emma, 2024-01-15): 1× Summit 2P Dome Tent (149,99), 2× Ridgeway 30L Daypack (79,95 kpl)
- **Tilaus 2** (Emma, 2024-02-20): 1× RainShell Waterproof Jacket (119,00)
- **Tilaus 3** (Jussi, 2024-01-22): 1× PolarLite Sleeping Bag -5C (129,00), 1× TrekPro Hiking Poles (54,95)
- **Tilaus 4** (Liisa, 2024-02-10): 3× Thermal Hiking Socks (14,99 kpl)
- **Tilaus 5** (Olli, 2024-03-01): 1× Headlamp 300 Lumens (24,99), 2× Stainless Steel Water Bottle 1L (19,90 kpl)

Käytä oikeita `order_id`- ja `product_id`-arvoja. Tarkista komennoilla `SELECT * FROM orders;` ja `SELECT * FROM products;` ennen lisäystä.

---

### Palautettava

Luo tiedosto `02_seed.sql`, jossa on kaikki INSERT-lauseet asiakkaille, tilauksille ja tilausriveille.

---

# Osa 4 — JOIN-kyselyt

Kirjoita SQL-kyselyitä, jotka yhdistävät dataa useista tauluista. Katso [Materiaali 07](../../Materials/07-SQL-fundamentals-3.md) liitosyntaksista ja esimerkeistä.

Alla olevat esimerkit käyttävät **yliopistotietokantaa** (opiskelijat, kurssit, ilmoittautumiset) Materiaalista 07. Sovella samat mallit TrailShopiin (asiakkaat, tilaukset, tilausrivit, tuotteet).

### Vaaditut kyselyt

1. **Tilaukset asiakasnimineen** — Listaa jokaisen tilauksen `order_id`, `order_date` ja asiakkaan `full_name`. Käytä INNER JOIN. Järjestä `order_date` laskevaan järjestykseen.

2. **Tilausrivit tuotenimineen** — Jokaiselle tilausriville näytä `order_id`, tuotteen `name`, `quantity` ja `unit_price`. Käytä INNER JOIN taulujen `order_items` ja `products` välillä. Järjestä `order_id`:n, sitten tuotenimen mukaan.

3. **Tilauksen yhteenveto** — Jokaiselle tilaukselle näytä `order_id`, `order_date`, asiakkaan `full_name`, tuotteen `name`, `quantity` ja `unit_price`. Käytä liitoksia taulujen `orders`, `customers`, `order_items` ja `products` välillä. Järjestä `order_id`:n, sitten tuotenimen mukaan.

4. **Asiakkaat tilausmäärineen** — Listaa jokaisen asiakkaan `full_name` ja heidän tilaustensa lukumäärä. Käytä LEFT JOIN niin, että asiakkaat ilman tilauksia näkyvät lukumäärällä 0. Järjestä tilausmäärän mukaan laskevaan, sitten nimen mukaan.

5. **Koskaan tilatut tuotteet** — Listaa niiden tuotteiden nimet, joita ei ole koskaan tilattu. Käytä LEFT JOIN taulusta `products` tauluun `order_items` ja suodata rivit, joilla `order_id` IS NULL.

---

### Palautettava

Luo tiedosto `02_queries.sql`, jossa on kaikki 5 kyselyä.

---

# Palautusvaatimukset

Palauta Assignment-2 -kansiosta nämä tiedostot:

- `02_schema.sql` — ALTER TABLE tuotteille, CREATE TABLE asiakkaille, tilauksille ja tilausriveille
- `02_seed.sql` — INSERT-lauseet asiakkaille, tilauksille ja tilausriveille
- `02_queries.sql` — Kaikki 5 JOIN-kyselyä

Luokkarepositoriosi rakenne:

```md
luokkarepo-nimi
├── Oppimistehtava-1
│ ├── 01_schema.sql
│ ├── 01_seed.sql
│ ├── 01_queries.sql
│ └── Ohjeet.md
├── Oppimistehtava-2
│ ├── 02_schema.sql
│ ├── 02_seed.sql
│ ├── 02_queries.sql
│ └── Ohjeet.md
├── Harjoitus-1
├── Harjoitus-2
├── Harjoitus-3
└── README.md
```

---

# Itsetarkistus

Ennen palautusta tarkista:

1. Suorituuko `02_schema.sql` ilman virheitä (olettaen, että trailshop-tietokanta ja Tehtävän 1 taulut ovat olemassa)?
2. Lisäävätkö `02_seed.sql`:n INSERT-lauseet kaikki asiakkaat, tilaukset ja tilausrivit ilman virheitä?
3. Palauttaako kysely 4 Olli Niemisen 1 tilauksella (tai oikea määrä datasi mukaan)?
4. Palauttaako kysely 5 tuotteet, joita ei ole missään tilausrivissä?
