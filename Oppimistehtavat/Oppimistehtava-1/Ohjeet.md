# Tehtävä 1 — TrailShop: Tietokannan perustaminen (Tarina + vaatimukset)

> [!NOTE]  
> Varmista, että sinulla on PostgreSQL ja pgAdmin asennettuna.  
> Jos jostain syystä joudut käyttämään psql:ää (SQL shell), opiskele miten psql-työkalu toimii ja miten sitä käytetään: [psql doc](https://www.postgresql.org/docs/current/app-psql.html)

> [!IMPORTANT]  
> Kopioi Oppimistehtava-1 -kansio, jossa on Ohjeet.md-tiedosto, omaan classroom-repositoriosi kansioon (se, jota olet käyttänyt harjoitusten palautukseen).

Ennen jatkamista classroom-repositoriosi kansiorakenteen pitäisi näyttää suunnilleen tältä:

```md
classroom-repostioriosi-nimi
├── Oppimistehtava-1
│ └── Ohjeet.md
├── Harjoitus-1 (valinnainen)
├── Harjoitus-2 (ER harjoitus)
└── README.md
```

## Skenaario 

Sinut on palkattu junior-tason tietokantakehittäjäksi pienelle startupille nimeltä **TrailShop** — verkkokaupalle, joka myy **ulkoiluvarusteita, retkeilyvälineitä, leiriytymistarvikkeita ja seikkailuvaatteita**.

Ennen kuin web-kehittäjät voivat aloittaa kaupan käyttöliittymän (UI) rakentamisen, TrailShop tarvitsee toimivan PostgreSQL-tietokannan realistisilla aloitustiedoilla.

Tällä viikolla tehtäväsi on rakentaa tietokannan ensimmäinen versio, joka tallentaa:

✅ tuotekategoriat (product categories)  
✅ tuotteet (products) näissä kategorioissa  
✅ riittävästi esimerkkidataa, jotta tiimi voi testata kyselyjä (queries)

Yritys haluaa tietokannan rakenteen sellaiseksi, että se voi kasvaa myöhemmin kurssin aikana.

---

# Tehtäväsi 

Lopuksi TrailShopilla täytyy olla:

✅ Paikallinen PostgreSQL-tietokanta nimeltä **trailshop**  
✅ Taulu, joka tallentaa **ulkoilutuotekategoriat**  
✅ Taulu, joka tallentaa kaupan myymät **tuotteet**  
✅ Vähintään 5 kategoriaa ja 15 tuotetta lisättynä  
✅ Muutama yksinkertainen kysely, jotka varmistavat että data on olemassa

---

# Osa 1 — Luo tietokanta 

TrailShopin kehittäjät haluavat, että kaikki käyttävät samaa tietokannan nimeä, jotta tulevaisuudessa vältytään sekaannuksilta.

📌 Vaatimus:

- Luo PostgreSQL-tietokanta nimeltä **trailshop**
    

---

# Osa 2 — Rakenna ensimmäiset taulut 

TrailShop haluaa ryhmitellä tuotteensa kategorioihin (esimerkiksi: “Tents”, “Hiking Gear”, “Clothing”).

### Kategoriavaatimukset (tulkitse sarakkeiksi + säännöiksi)

TrailShop tarvitsee tavan tallentaa kategoriat siten, että:

- Jokaisella kategorialla on **automaattisesti luotu numeerinen tunniste** (id)
    
- Jokaisella kategorialla on **nimi** (name)
    
- Kategorian nimen täytyy **aina olla olemassa**
    
- Kahdella kategorialla **ei saa olla samaa nimeä**
    

---

TrailShopin täytyy myös tallentaa tuotteet ja perustiedot, joita tarvitaan niiden myymiseen.

### Tuotevaatimukset (tulkitse sarakkeiksi + säännöiksi)

TrailShopin tuotteiden täytyy tukea seuraavaa:

- Jokaisella tuotteella on **automaattisesti luotu numeerinen tunniste** (id)
    
- Jokaisella tuotteella on **nimi**  (name), jonka täytyy aina olla olemassa
    
- Jokaisella tuotteella on **hinta** (price), joka tallennetaan tarkasti (**rahaa ei saa tallentaa liukulukuna / floating-point**)
    
- Jokaisella tuotteella on **varastosaldo** (stock), joka tallennetaan kokonaislukuna
    
- Jokaisella tuotteella täytyy olla tieto siitä, mihin kategoriaan se kuuluu tallentamalla kategorian tunniste (**category_id**)
    

⚠️ Viikon 1 huomio:

- Älä lisää **viiteavainrajoitteita (foreign key constraints)** vielä  
    (suhteet + rajoitteet lisätään myöhemmin kurssilla)
    

---

### Palautettava tiedosto osaan 2

Luo tiedosto:

✅ `01_schema.sql`

Tämän tiedoston täytyy sisältää SQL, joka luo TrailShopin tarvitsemat taulut. (Create kyselyt)

---

# Osa 3 — Lisää esimerkkidata 

TrailShop haluaa realistista testidataa, jotta kehitystiimi voi heti aloittaa tuoteluetteloiden ja peruskyselyjen testaamisen.

Lisäät:

✅ **5 vaadittua kategoriaa**  
✅ **15 vaadittua tuotetta** (tarkat nimet + hinnat + varastosaldot)

---

## Vaihe 1 — Lisää vaaditut kategoriat (Insert the Required Categories)

TrailShopin ensimmäinen julkaisu sisältää nämä kategoriat (lisää ne täsmälleen tässä muodossa):

1. **Tents**
    
2. **Backpacks**
    
3. **Sleeping Gear**
    
4. **Hiking Accessories**
    
5. **Outdoor Clothing**
    

📌 Vaatimukset:

- Näiden 5 kategorian nimen on oltava olemassa **täsmälleen**
    
- Kategorianimien on oltava **uniikkeja (unique)**
    
- Tietokannan on luotava kategorioiden tunnisteet automaattisesti
    

---

## Vaihe 2 — Lisää vaaditut tuotteet 

TrailShop haluaa lisätä kaupan luetteloon **15 tuotetta**.

📌 Säännöt:

- Lisää **kaikki alla listatut tuotteet**
    
- Jokaisessa tuotteessa täytyy olla:
    
    - nimi (name)
        
    - hinta (price)
        
    - varastosaldo (stock)
        
    - category_id
        
- Varastosaldon on oltava kokonaisluku väliltä **0–200**
    
- Hinnat tulee tallentaa tarkasti (älä käytä liukulukutyyppejä / floating point types)

---

## Kategoriamäppäysvaatimus (Category Mapping) (Tärkeä)

Tuotteidesi täytyy viitata oikeaan kategoriaan käyttämällä `category_id`:tä.

✅ Voit olettaa, että kategoriat lisätään samassa järjestyksessä kuin yllä:

1. Tents
    
2. Backpacks
    
3. Sleeping Gear
    
4. Hiking Accessories
    
5. Outdoor Clothing
    

Jolloin `category_id`-arvot ovat todennäköisesti:

- Tents → `1`
    
- Backpacks → `2`
    
- Sleeping Gear → `3`
    
- Hiking Accessories → `4`
    
- Outdoor Clothing → `5`
    

📌 Tietokantasi voi kuitenkin antaa eri ID:t riippuen siitä, miten lisäsit datan.  
Siksi sinun täytyy **varmistaa ID:t** ajamalla:

```sql
SELECT * FROM categories;
```

Ja käyttää sitten oikeita ID-arvoja tuotteen INSERT-lauseissa.   

---

## ✅ Vaaditut tuotteet lisättäväksi (Required Products to Insert)

### Kategoria: **Tents**

|Product name|Price|Stock|
|---|--:|--:|
|Summit 2P Dome Tent|149.99|25|
|TrailLite 1P Tent|119.50|12|
|StormGuard 4P Family Tent|279.00|8|

---

### Kategoria: **Backpacks**

|Product name|Price|Stock|
|---|--:|--:|
|Ridgeway 30L Daypack|79.95|40|
|Alpine Trek 55L Pack|169.00|18|
|Waterproof Dry Bag 20L|29.99|60|

---

### Kategoria: **Sleeping Gear**

|Product name|Price|Stock|
|---|--:|--:|
|PolarLite Sleeping Bag -5C|129.00|20|
|Summer Breeze Sleeping Bag +10C|89.90|35|
|Ultralight Sleeping Pad|49.50|50|

---

### Kategoria: **Hiking Accessories**

|Product name|Price|Stock|
|---|--:|--:|
|TrekPro Hiking Poles (Pair)|54.95|30|
|Headlamp 300 Lumens|24.99|70|
|Stainless Steel Water Bottle 1L|19.90|90|

---

### Kategoria: **Outdoor Clothing**

|Product name|Price|Stock|
|---|--:|--:|
|Merino Wool Base Layer Top|64.00|45|
|RainShell Waterproof Jacket|119.00|22|
|Thermal Hiking Socks (2-Pack)|14.99|120|



---

## Palautettava tiedosto 

Luo:

✅ `01_seed.sql`

Sen täytyy sisältää:

- INSERT-lauseet 5 kategoriasta
    
- INSERT-lauseet kaikista 15 yllä listatusta tuotteesta
    

---

# Osa 4 — Ensimmäiset kyselyt tiimille 

TrailShopin kehittäjät haluavat muutaman yksinkertaisen SQL-kyselyn, joita he voivat ajaa testauksen aikana.

Kirjoita kyselyt, jotka palauttavat:

1. Kaikki kategoriat
    
2. Kaikki tuotteet
    
3. Vain tuotteiden nimet ja hinnat
    
4. Kaikki tuotteet, joiden hinta on yli 50
    
5. Tuotteiden nimet ja hinnat järjestettynä kalleimmasta → halvimpaan
    

### Palautettava tiedosto osaan 4 

Luo tiedosto:

✅ `01_queries.sql`

Tämän tiedoston täytyy sisältää vaaditut kyselyt.

---

# Palautusvaatimukset

Palauta nämä kolme tiedostoa tehtävän repositorion sisällä:

- ✅ `01_schema.sql`
    
- ✅ `01_seed.sql`
    
- ✅ `01_queries.sql`
    

Classroom-repositoriosi pitäisi näyttää suunnilleen tältä:

```md
classroom-repositoriosi-nimi
├── Oppimistehtava-1
│ ├── 01_schema.sql
│ ├── 01_seed.sql
│ ├── 01_queries.sql
│ └── Ohjeet.md
├── Harjoitus-1 (valinnainen)
├── Harjoitus-2 (ER harjoitus)
└── README.md
```
