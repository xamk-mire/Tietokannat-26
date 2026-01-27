
# 1) Mikä on relaatiotietokanta? (Relational Database)

[IBM: What is a relational dabase?](https://www.ibm.com/think/topics/relational-databases#228874317)

Relaatiotietokanta (Relational Database) on tapa järjestää tietoa niin, että se tuntuu vähemmän kaoottiselta muistiinpanokasalta ja enemmän hyvin järjestetyltä kirjastolta.  
Sen sijaan, että tieto tallennettaisiin ”kaikki kaikkialle”, relaatiotietokanta tallentaa tiedon **tauluihin** (tables), jotka voidaan **liittää** (linked) toisiinsa huolellisesti määriteltyjen sääntöjen avulla.

Perustaltaan se pohjautuu **relaatiomalliin** (relational model), jonka esitteli **E. F. Codd**. Malli käsittelee tietoa relaatioiden (taulujen) joukkona ja käyttää logiikkaan perustuvia operaatioita niiden käsittelemiseen.

### Keskeinen idea

Relaatiotietokanta kysyy:

> ”Mitkä ovat maailmamme _asiat_, mitkä ovat niiden _ominaisuudet_, ja miten ne ovat _yhteydessä_ toisiinsa?”

Koulujärjestelmässä:

- Asiat (Things): **Oppilaat (Students)**, **Kurssit (Courses)**, **Opettajat (Teachers)**
    
- Ominaisuudet (Properties): oppilaan nimi, kurssin nimi jne.
    
- Yhteydet (Connections): oppilaat ilmoittautuvat kursseille, opettajat opettavat kursseja
    

---

# 2) Relaatiomalli (The Relational Model)

Tietokanta voi tallentaa tietoa monella eri tavalla.  
Relaatiotietokanta tekee kuitenkin hyvin erityisen lupauksen:

> Tietoa ei tallenneta sotkuisena faktojen kokoelmana,  
> vaan **rakenteellisten relaatioiden** (structured relations) järjestelmänä, jota voidaan loogisesti käsitellä.

**Relaatiomalli** (relational model) on tämän lupauksen taustalla oleva ajatus.  
Se on _teoria_, joka selittää, miksi relaatiotietokannat käyttäytyvät niin kuin ne käyttäytyvät — miksi taulut ovat olemassa, miksi avaimet ovat tärkeitä ja miksi SQL voi yhdistää tietoa monesta paikasta ilman, että merkitys katoaa.

Tärkeää:

- relaatiomalli **ei ole PostgreSQL**
    
- se **ei ole MySQL**
    
- se **ei ole ohjelmistotuote**
    

Se on _suunnittelufilosofia_ ja matemaattinen viitekehys, jota nämä järjestelmät toteuttavat.

Kun opit relaatiomallin, opit sen, mikä tekee relaatiotietokannasta **luotettavan, johdonmukaisen ja ennustettavan**.

---

## Keskeiset käsitteet (Core Concepts)

Relaatiomalli rakentuu pienestä joukosta voimakkaita perusrakennuspalikoita.  
Jokainen on yksinkertainen — mutta yhdessä ne mahdollistavat monimutkaisten maailmojen mallintamisen.

---

### **Relaatio (Relation)** → taulu (table)

**Relaatio** (relation) on kokoelma rakenteellisia faktoja tietyn tyyppisestä asiasta.

✅ Keskeiset kohdat:

- relaatio on _kuin_ taulu (table) nykyaikaisissa tietokannoissa
    
- sillä on **nimi** (name) (esim. `Students`)
    
- se koostuu **attribuuteista** (attributes) (sarakkeet / columns)
    
- se sisältää **monikkoja** (tuples) (rivit / rows)
    

Esimerkkirelaatio: `Students`

|StudentID|Name|Email|
|---|---|---|
|1|Aino|[aino@uni.fi](mailto:aino@uni.fi)|
|2|Mika|[mika@uni.fi](mailto:mika@uni.fi)|

Puhtaassa matemaattisessa relaatiomallissa relaatiot käsitellään **joukkona** (sets), mikä tarkoittaa:

- duplikaatteja ei ole (joukko ei voi sisältää samaa alkiota kahdesti)
    
- järjestyksellä ei ole merkitystä
    

Todelliset tietokannat saattavat _näennäisesti_ sallia duplikaatteja, mutta **avaimet (keys) ja rajoitteet (constraints)** ovat keinoja palauttaa järjestelmä kurinalaiseksi.

---

### **Monikko (Tuple)** → rivi (row)

**Monikko** (tuple) on yksi täydellinen tietue relaatiossa.

✅ Keskeiset kohdat:

- jokainen monikko edustaa **yhtä entiteetti-instanssia** (one entity instance)
    
- monikko sisältää yhden arvon jokaiselle attribuutille
    
- monikkojen järjestyksellä ei ole teoreettisesti merkitystä
    

Esimerkkimonikko:

- `(StudentID=1, Name="Aino", Email="aino@uni.fi")`
    

Monikko on kuin yksi ”kortti” kirjaston kortistossa.  
Se on täydellinen kuvaus yhdestä objektista — käyttäen relaation määrittelemää rakennetta.

---

### **Attribuutti (Attribute)** → sarake (column)

**Attribuutti** (attribute) on nimetty ominaisuus, joka kuvaa jotakin relaation sisällä.

✅ Keskeiset kohdat:

- attribuutit määrittävät arvojen _merkityksen_ monikossa
    
- niillä on nimet (esim. `Email`)
    
- niillä on tietotyypit tai arvovälit (**data types / domains**)
    

Esimerkkiattribuutit `Students`-relaatiosta:

- `StudentID` → tunnistenumero
    
- `Name` → opiskelijan nimi
    
- `Email` → yhteystieto
    

🟦 Hyödyllinen tapa selittää attribuutit:

> Jos monikko on **lause**, attribuutit ovat **kielioppisäännöt**, jotka antavat sille rakenteen.

---

### **Arvojoukko (Domain)** → sallitut arvot attribuutille

**Arvojoukko** (domain) on niiden arvojen joukko, joita attribuutti saa ottaa.

✅ Keskeiset kohdat:

- arvojoukot estävät virheelliset arvot
    
- arvojoukot ilmaisevat merkitystä (“millaisia asioita tähän kuuluu?”)
    
- käytännössä arvojoukkoja valvotaan käyttämällä:
    
    - **tietotyyppejä (data types)**
        
    - **rajoitteita (constraints)** (NOT NULL, CHECK, jne.)
        

Esimerkkejä:

- `StudentID`-attribuutin arvojoukko voi olla: positiiviset kokonaisluvut
    
    - `{1, 2, 3, 4, …}`
        
- `Credits`-attribuutin arvojoukko voi olla: kokonaisluvut väliltä 1–20
    
    - `{1, 2, …, 20}`
        
- `Email`-attribuutin arvojoukko voi olla: merkkijonot, jotka vastaavat sähköpostin sääntöjä
    
    - usein valvottu uniikkiudella ja muotosäännöillä (sovelluksen tai rajoitteiden kautta)
        

Esimerkki SQL:ssä (PostgreSQL):

```sql
Credits INTEGER CHECK (Credits BETWEEN 1 AND 20)
```

Arvojoukot estävät tietokantaa hyväksymästä järjettömyyksiä kuten:

- credits = -500
    
- student_id = "banana"
    

---

### **Instanssi (Instance)** → nykyinen sisältö (current data)

Jos skeema (schema) on rakennuspiirustus, **instanssi** (instance) on tämänhetkinen datan sisältö.

✅ Keskeiset kohdat:

- skeema on vakaa (muuttuu harvoin)
    
- instanssi muuttuu jatkuvasti (rivejä lisätään/päivitetään/poistetaan)
    
- samalla skeemalla voi olla monta eri instanssia ajan kuluessa
    

Esimerkki:

- maanantaiaamuna: taulussa on 10 opiskelijaa
    
- perjantai-iltapäivänä: taulussa on 200 opiskelijaa
    

**Taulun rakenne (table structure)** pysyy samana, mutta **instanssi (instance)** on kasvanut.


---

# 3) Taulut, rivit, sarakkeet (Tables, Rows, Columns)

_(Relaatio (Relation), monikko (Tuple), attribuutti (Attribute))_

## A) Taulut (Tables) – relaatiot (Relations)

Taulu (table) on kokoelma tietoa yhdestä asiasta tai asiaryhmästä.

🔑 Tärkeät kohdat:

- Taululla on **nimi** (name)
    
- Taululla on **sarakkeita** (columns) eli attribuutteja (attributes)
    
- Taulu sisältää **rivejä** (rows) eli monikkoja (tuples)
    
- Jokainen rivi on yksi ”tietue” (record), joka kuvaa yhtä objektia
    

Esimerkkitaulu: `Students`

|StudentID|Name|Email|
|--:|---|---|
|1|Aino|[aino@uni.fi](mailto:aino@uni.fi)|
|2|Mika|[mika@uni.fi](mailto:mika@uni.fi)|

**Mitä tämä taulu esittää?**

- **Käsitteen** ”Opiskelija (Student)”
    
- Jokainen rivi edustaa **yhtä opiskelijaa**
    
- Jokainen sarake edustaa **opiskelijan ominaisuutta**
    

---

## B) Sarakkeet (Columns) – attribuutit (Attributes)

Sarake (column) määrittelee ominaisuuden, joka on yhteinen kaikille riveille.

✅ Keskeiset kohdat:

- Jokaisella sarakkeella on **nimi** (name) (`Name`, `Email`)
    
- Jokaisella sarakkeella on **tietotyyppi** (data type)
    
    - esim. kokonaisluku (integer), teksti (text), päivämäärä (date)
        
- Jokaisella sarakkeella on **arvojoukko** (domain)
    
    - esim. `StudentID` on oltava kokonaisluku ≥ 1
        
    - `Email`-kentän tulee noudattaa sähköpostimuotoa (sääntöä usein valvotaan rajoitteilla (constraints))
        

Hyvin suunniteltu sarake on:

- **Atominen (Atomic)** — yksi arvo, ei lista
    
- **Johdonmukainen (Consistent)** — sama merkitys jokaisella rivillä
    

⚠️ Huono sarakesuunnittelun esimerkki  
Useiden arvojen tallentaminen yhteen sarakkeeseen:

|StudentID|Name|PhoneNumbers|
|--:|---|---|
|1|Aino|0501..., 0442...|

Parempi lähestymistapa:

- luo erillinen `StudentPhones`-taulu sen sijaan
    

---

## C) Rivit (Rows) – monikot (Tuples)

Rivi (row) on yksi täydellinen entiteetin instanssi (entity instance) taulussa.

✅ Keskeiset kohdat:

- Jokainen rivi on yksi tietue (record)
    
- Jokainen rivi tulisi voida yksilöidä yksikäsitteisesti (uniquely identifiable)
    
- Rivit eivät perustu ”sijaintiin” (position) (esim. ”rivi #17” ei tarkoita mitään itsessään)
    

Esimerkkirivi:

- `(StudentID=1, Name="Aino", Email="aino@uni.fi")`
    


---

# 4) Avaimet: datan identiteetti

Relaatiotietokannoissa identiteetillä on merkitystä.  
Tietokannan on pystyttävä erottamaan jokainen rivi kaikista muista riveistä — luotettavasti ja aina.

Tässä **avaimet** (keys) tulevat kuvaan.

---

## A) Pääavain (Primary Key, PK)

Pääavain (primary key) on taulun rivien **ensisijainen tunniste** (main identifier).

✅ Pääavaimen säännöt:

- **Yksikäsitteinen (Unique)**: ei sallita duplikaatteja
    
- **Ei NULL (Not NULL)**: arvo on aina oltava olemassa
    
- **Vakaa (Stable)**: ei pitäisi muuttua usein
    
- **Minimaalinen (Minimal)**: ei saa sisältää turhia attribuutteja
    

Esimerkki: `Students(StudentID)` pääavaimena.

### Miksi nimiä ei käytetä pääavaimina?

Koska nimet eivät ole vakaita eivätkä yksikäsitteisiä.

Kaksi opiskelijaa voi olla nimeltään ”Mika”.  
Yksi Mika voi myöhemmin vaihtaa nimensä.

Siksi käytämme sen sijaan:

- `StudentID` (luotu kokonaisluku, generated integer)
    
- tai UUID (globaalisti yksikäsitteinen tunniste, globally unique identifier)
    

---

## B) Ehdokasavaimet (Candidate Keys)

Ehdokasavain (candidate key) on mikä tahansa sarake (tai sarakkeiden yhdistelmä), joka _voisi_ yksikäsitteisesti tunnistaa rivit.

Esimerkki: Jos opiskelijoiden sähköpostien on oltava uniikkeja:

- `StudentID` = ehdokasavain ✅
    
- `Email` = ehdokasavain ✅
    

Pääavain on se, jonka valitsemme virallisesti.

---

## C) Yhdistelmäavaimet (Composite Keys)

Joskus yksikäsitteisyys vaatii useamman sarakkeen.

Esimerkki: Ilmoittautumistiedot (enrollment records):

|StudentID|CourseID|Grade|
|--:|--:|---|
|1|101|5|
|1|102|4|

Opiskelija voi osallistua monelle kurssille.  
Kurssilla voi olla monta opiskelijaa.

Pelkkä `StudentID` tai pelkkä `CourseID` ei yksinään yksilöi riviä.  
Mutta yhdessä:

✅ Yhdistelmäavain (composite key): `(StudentID, CourseID)`

Yhdistelmäavaimia käytetään tyypillisesti liitostauluissa (junction tables) yhdistämällä kaksi tai useampia viiteavaimia (foreign keys). Tämä poistaa tarpeen luoda erillinen lisäsarake/attribuutti tunnistetta varten, mikä vähentää rakenteen monimutkaisuutta ja voi jopa estää virheellisiä datatilanteita.


---

# 5) Viiteavaimet: säikeet taulujen välillä (Foreign Keys)

Viiteavain (foreign key, FK) on se, miten taulut ”tuntevat toisensa”.

Se on yhden taulun sarake, joka viittaa toisen taulun pääavaimeen (primary key).

### Miksi viiteavaimet ovat tärkeitä

Ne valvovat **viite-eheyttä** (referential integrity), mikä tarkoittaa:

> ”Et voi viitata johonkin, mitä ei ole olemassa.”

---

## Esimerkki: Opiskelijat ja kurssit 

### `Students`

|StudentID (PK)|Name|
|--:|---|
|1|Aino|
|2|Mika|

### `Courses`

|CourseID (PK)|Title|
|--:|---|
|101|Databases|
|102|Web Development|

### `Enrollments`

|StudentID (FK)|CourseID (FK)|
|--:|--:|
|1|101|
|1|102|
|2|101|

🔎 Mitä tapahtuu?

- `Enrollments.StudentID` viittaa `Students.StudentID`:hen
    
- `Enrollments.CourseID` viittaa `Courses.CourseID`:hen
    

✅ Tämä mahdollistaa kyselyt kuten:

- ”Millä kursseilla Aino on?”
    
- ”Mitkä opiskelijat ovat Databases-kurssilla?”
    

---

## Viiteavaimen säännöt (Foreign Key rules)

- Viiteavaimen arvo täytyy joko:
    
    - vastata olemassa olevaa pääavaimen arvoa, tai
        
    - olla NULL (jos sallittu)
        
- Viiteavaimet auttavat estämään **orpoja tietueita** (orphaned records)
    

### Orpo-esimerkki (ei sallittu)

Jos opiskelija poistetaan, mutta ilmoittautumistiedot jäävät:

|StudentID|CourseID|
|--:|--:|
|999|101|

Opiskelijaa 999 ei ole olemassa → tietokannan tulisi hylätä tämä.


---

# 6) Taulujen väliset suhteet (Relationships Between Tables)

_(pikakertaus tietomallinnuksesta / quick recap from Data Modelling)_

Relaatiotietokannat loistavat todellisten maailman suhteiden mallintamisessa.

## A) Yksi yhteen (One-to-One, 1:1)

Jokainen rivi taulussa A liittyy enintään yhteen riviin taulussa B.

Esimerkki:

- Henkilöllä on täsmälleen yksi passi (joissain yksinkertaistetuissa malleissa)
    

Usein toteutetaan:

- jakamalla sama pääavain (primary key) molemmissa tauluissa, tai
    
- käyttämällä uniikkia viiteavainta (unique foreign key)
    

---

## B) Yksi moneen (One-to-Many, 1:N)

Yksi rivi taulussa A liittyy moneen riviin taulussa B.

Esimerkki:

- Yksi opettaja opettaa monta kurssia
    
- Yksi asiakas tekee monta tilausta
    

Toteutus:

- viiteavain ”monen” puolella
    

`Orders(CustomerID FK → Customers.CustomerID)`

---

## C) Monta moneen (Many-to-Many, M:N)

Monta riviä taulussa A liittyy moneen riviin taulussa B.

Esimerkki:

- Opiskelijat käyvät monella kurssilla
    
- Kursseilla on monta opiskelijaa
    

Toteutus:

- tarvitaan **liitostaulu** (junction table), jota kutsutaan myös siltatauluksi (bridge table)
    

`Enrollments(StudentID FK, CourseID FK)`

Tämä on erittäin yleinen rakenne.


---

# 7) Rajoitteet: tietokanta sääntökirjana (Constraints)

Rajoitteet (constraints) ovat sääntöjä, jotka pitävät datan puhtaana ja merkityksellisenä.

### Yleiset rajoitteet (Common constraints)

- **PRIMARY KEY (pääavain)**
    
    - yksikäsitteisyys (uniqueness) + ei NULL (not null)
        
- **FOREIGN KEY (viiteavain)**
    
    - viittaa toiseen tauluun (references another table)
        
- **NOT NULL**
    
    - kentässä on oltava arvo
        
- **UNIQUE**
    
    - arvo ei saa toistua
        
- **CHECK**
    
    - arvon on täytettävä ehto
        
    - (esim. arvosana väliltä 0–5)
        
- **DEFAULT**
    
    - antaa oletusarvon, jos arvoa ei anneta
        

---

## Esimerkki rajoitteen perustelusta 

Jos kurssin opintopisteiden (credits) täytyy olla väliltä 1–20:

- **CHECK (Credits BETWEEN 1 AND 20)**
    

Tämä estää vahingossa syntyvät virheelliset arvot kuten `-100` tai `9999`.

---

# 8) Täydellinen mini-tietokantaesimerkki 

Alla on esimerkki pienestä tietokannasta (mini database).

### Taulu 1: Student (Opiskelija)

|StudentID (PK)|Name|
|--:|---|
|1|Aino|
|2|Mika|

### Taulu 2: Course (Kurssi)

|CourseID (PK)|Title|
|--:|---|
|101|Databases|
|102|Algorithms|

### Taulu 3: Enrollment (Ilmoittautuminen, liitostaulu / junction)

|StudentID (FK)|CourseID (FK)|
|--:|--:|
|1|101|
|1|102|
|2|101|

### Kysymyksiä, joihin voimme nyt vastata 

✅ ”Millä kursseilla Aino on?”

- Haetaan Ainon StudentID = 1
    
- Etsitään ilmoittautumiset, joissa StudentID = 1 → CourseID:t 101 ja 102
    
- Yhdistetään (join) Course-tauluun, jotta saadaan kurssien nimet
    

> Tässä esimerkissä meidän ei tarvitse tietää Course-taulun CourseID-arvoja etukäteen. Pelkästään opiskelijan tunnisteen avulla pystymme hakemaan asiaankuuluvat tiedot Course-taulusta Enrollment-taulun ansiosta.

✅ ”Kuinka monta opiskelijaa on Databases-kurssilla?”

- Databases-kurssin CourseID = 101
    
- Lasketaan ilmoittautumiset, joissa CourseID = 101 → 2 opiskelijaa
    

Tämä on relaatiomalli käytännössä:

- taulut määrittävät rakenteen
    
- avaimet rakentavat yhteydet
    
- kyselyt tuovat merkityksen
    


---

# 9) Miksi relaatiotietokannat ovat tehokkaita 

Relaatiotietokannat ovat suosittuja, koska ne yhdistävät:

- **selkeyden (clarity)** — tietorakenne on eksplisiittinen ja näkyvä
    
- **oikeellisuuden (correctness)** — rajoitteet estävät järjettömän datan
    
- **kyseltävyyden (queryability)** — SQL on ilmaisukykyinen
    
- **skaalautuvuuden (scalability)** — käsittelee suuria tietomääriä tehokkaasti
    

Ne toimivat erityisen hyvin, kun:

- suhteilla (relationships) on merkitystä
    
- datan täytyy olla luotettavaa
    
- päivitysten on pysyttävä johdonmukaisina
    
- välität oikeellisuudesta enemmän kuin ”nopeasta tallennuksesta”
    

---
