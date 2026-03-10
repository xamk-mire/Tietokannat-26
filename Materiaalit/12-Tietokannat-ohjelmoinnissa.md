# Tietokannat ohjelmoinnissa: tarkoitus ja tyypillinen käyttö

## 1) Miksi ohjelmoijat käyttävät tietokantoja?

### Perusongelma: ohjelmat tarvitsevat muistin

Ajossa (running) oleva ohjelma pitää dataa **muistissa** (muuttujat, oliot, taulukot). Kun ohjelma sulkeutuu tai kone käynnistyy uudelleen, data katoaa — ellei sitä tallenneta johonkin pysyvästi.

Tietokannat ratkaisevat tämän ongelman:

- **Pysyvyys** — data säilyy ohjelman uudelleenkäynnistyksissä, palvelimen käynnistyksissä ja virran katkeamisissa
- **Jako** — monet käyttäjät, prosessit tai palvelimet voivat työskennellä saman datan parissa
- **Oikeellisuus** — tietokanta pakottaa säännöt (rajoitteet, transaktiot), jotta data pysyy johdonmukaisena
- **Tehokkuus** — indeksit ja kyselyoptimoijat mahdollistavat suurten datamäärien käsittelyn

Ilman tietokantaa ohjelmoijien pitäisi rakentaa tämä itse — ja useimmat sovellukset keksisivät uudelleen joitain hauraampia ratkaisuja.

### Mitä ohjelmoijat saavat tietokannasta

| Tarve                                   | Mitä tietokanta tarjoaa                                         |
| --------------------------------------- | --------------------------------------------------------------- |
| Tallentaa dataa yhden ajon ulkopuolelle | Pysyvä tallennus levylle (tai replikaatio)                      |
| Kysyä dataa joustavasti                 | SQL (tai vastaava) — pyydä _mitä_ haluat, ei _miten_ sen löydät |
| Pitää datan johdonmukaisena             | Rajoitteet, transaktiot, eheyssäännöt                           |
| Tukee useita käyttäjiä yhtä aikaa       | Samanaikaisuuden hallinta, eristys                              |
| Toipua virheistä                        | Kestävyys, lokitus, varmuuskopio/palautus                       |
| Hallita, kuka saa tehdä mitä            | Käyttäjät, roolit, oikeudet                                     |
| Kasvaa datan määrän myötä               | Indeksit, osiointi, skaalausvaihtoehdot                         |

Tietokannat ovat useimpien sovellusten **kirjanpitäjä**: paikka, jossa yrityksen tai tuotteen "oikea" tila on.

---

## 2) Missä tietokannat sijaitsevat sovellusarkkitehtuurissa

### Tyypilliset kerrokset

Useimmat sovellukset jakavat vastuut kerroksiin. Tietokanta on alimpana **datakerroksena**.

```
┌─────────────────────────────────────┐
│  Esitys (UI, API-päätepisteet)      │
├─────────────────────────────────────┤
│  Liiketoimintalogiikka (säännöt)    │
├─────────────────────────────────────┤
│  Datankäyttö (kyselyt, kartoitukset)│
├─────────────────────────────────────┤
│  Tietokanta (tallennus, eheys)      │
└─────────────────────────────────────┘
```

- **Esitys** — vastaanottaa käyttäjän syötteen tai API-pyynnöt
- **Liiketoimintalogiikka** — soveltaa sääntöjä (esim. "voiko käyttäjä tehdä tämän tilauksen?")
- **Datankäyttö** — lähettää kyselyjä tietokantaan ja kartoittaa tulokset sovellusolioiksi
- **Tietokanta** — tallentaa datan, valvoo rajoitteita, suorittaa kyselyjä

Sovelluskoodi _kommunikoi_ tietokannan kanssa; se ei _korvaa_ sitä. Tietokanta vastaa tallennuksesta, eheydestä ja tehokkaasta kyselysuorituksesta.

### Pyyntö–vastaus -kulku (yksinkertaistettu)

Tyypillinen kulku, kun käyttäjä tekee toiminnon:

1. Käyttäjä lähettää pyynnön (esim. "Näytä tilaukseni").
2. Esityskerros vastaanottaa sen.
3. Liiketoimintalogiikka päättää, mitä dataa tarvitaan.
4. Datankäyttökerros suorittaa kyselyn (esim. `SELECT * FROM orders WHERE user_id = ?`).
5. Tietokanta palauttaa rivit.
6. Datankäyttökerros kartoittaa rivit olioiksi (esim. `Order`).
7. Liiketoimintalogiikka voi käsitellä tai suodattaa.
8. Esityskerros muotoilee ja palauttaa vastauksen.

Tietokanta mukana vaiheissa 4–5: se vastaanottaa kyselyn ja palauttaa datan.

---

## 3) Miten ohjelmat yhdistävät tietokantoihin

### Tietokanta-ajurit ja yhteysmerkkijonot

Tietokannan käyttöön sovelluksen on **yhdistettävä** siihen. Tämä tapahtuu:

- **Tietokanta-ajurin** kautta — kirjasto, joka osaa tietokannan protokollan (esim. `pg` Node.jsille, `psycopg2` Pythonille, JDBC Javalle)
- **Yhteysmerkkijonon** kautta — parametrit, jotka tunnistavat tietokannan ja miten siihen päästään

Esimerkki yhteysmerkkijonosta (PostgreSQL):

```
postgresql://username:password@hostname:5432/database_name
```

Sovellus käyttää ajuria yhteyden avaamiseen, SQL:n lähettämiseen ja tulosten vastaanottamiseen. Jokaisella ohjelmointikielellä on oma ajuriekosysteeminsä.

### Yhteyden elinkaari

1. **Avaa** — luo yhteys tietokantaan (usein käynnistyksessä tai ensimmäisessä pyynnössä)
2. **Käytä** — lähetä kyselyjä ja vastaanota tulokset
3. **Sulje** — vapauta yhteys, kun valmis

Yhteydet ovat rajallinen resurssi. Sovellukset käyttävät usein **yhteydenpooleja**—joukkoa uudelleenkäytettäviä yhteyksiä—jotta uutta yhteyttä ei avata ja suljeta jokaisesta kyselystä.

---

## 4) Miten ohjelmat kommunikoivat tietokannan kanssa

### Vaihtoehto 1: Raaka SQL

Suorin tapa on lähettää **SQL-merkkijonoja** tietokantaan ajurin kautta.

```python
# Python psycopg2:lla (konseptuaalinen)
cursor.execute("SELECT id, name FROM users WHERE email = %s", (email,))
rows = cursor.fetchall()
```

```javascript
// Node.js pg:llä (konseptuaalinen)
const result = await pool.query('SELECT id, name FROM users WHERE email = $1', [
  email,
]);
```

**Tärkeää:** Käytä aina **parametrisoituja kyselyjä** (paikanpitäjiä kuten `%s`, `$1`) merkkijonoliittämisen sijaan. Tämä estää SQL-injektion ja mahdollistaa tietokannan optimoinnin toistuville kyselyille.

### Vaihtoehto 2: Kyselyrakentajat (Query Builders)

Kyselyrakentajat ovat kirjastoja, joilla voit muodostaa SQL:ää ohjelmallisesti:

```javascript
// Konseptuaalinen kyselyrakentaja
db.select('id', 'name').from('users').where('email', '=', email);
```

Hyödyt: vähemmän merkkijonokäsittelyä, suojaa virheiltä. Työskentelet silti lähellä SQL:ää.

### Vaihtoehto 3: ORM:t (Object-Relational Mappers)

ORM:t kartoittavat tietokantataulut ohjelmointikielen **olioiksi** (luokat, structit). Työskentelet olioiden kanssa; ORM generoi SQL:n.

```python
# Konseptuaalinen ORM (esim. SQLAlchemy, Django ORM)
user = User.query.filter_by(email=email).first()
```

```javascript
# Konseptuaalinen ORM (esim. Sequelize, TypeORM)
const user = await User.findOne({ where: { email } });
```

Hyödyt: tuttu olio-orientoitu tyyli, vähemmän boilerplatea yksinkertaiselle CRUDille. Kompromissit: saatat menettää hallinnan tarkasta SQL:stä; monimutkaiset kyselyt voivat olla vaikeampia ilmaista tai optimoida.

| Lähestymistapa  | Kontrolli | Abstraktio | Parhaimmillaan kun                            |
| --------------- | --------- | ---------- | --------------------------------------------- |
| Raaka SQL       | Korkea    | Matala     | Monimutkaiset kyselyt, suorituskyvyn säätö    |
| Kyselyrakentaja | Keskitaso | Keskitaso  | Luettavat kyselyt ilman merkkijonoliittämistä |
| ORM             | Matalampi | Korkea     | Vakiintunut CRUD, nopea kehitys               |

---

## 5) Neljä operaatiota: CRUD koodista

Suurin osa sovellus–tietokanta -vuorovaikutuksesta tiivistyy **CRUDiin**:

| Operaatio  | SQL      | Tyypillinen käyttö koodissa                            |
| ---------- | -------- | ------------------------------------------------------ |
| **Create** | `INSERT` | Lisää uusi käyttäjä, tilaus tai tietue                 |
| **Read**   | `SELECT` | Lataa dataa näyttöä tai käsittelyä varten              |
| **Update** | `UPDATE` | Muuta olemassa olevia tietueita (esim. tila, profiili) |
| **Delete** | `DELETE` | Poista tietueita, joita ei enää tarvita                |

Ohjelmoijat harvoin kirjoittavat SQL:ää käsin jokaista operaatiota varten; he käyttävät patterneja (patterns) (funktiot, repository-luokat, ORM-metodit), jotka kääri näitä operaatioita. Tietokanta saa silti taustalla INSERT-, SELECT-, UPDATE- tai DELETE-lauseen.

### Esimerkki: luonti ja lukeminen

Konseptuaalisesti kun käyttäjä rekisteröityy:

1. Sovellus vastaanottaa `email`, `name`, `password`.
2. Liiketoimintalogiikka validoi syötteen.
3. Datankäyttö suorittaa: `INSERT INTO users (email, name, password_hash) VALUES (?, ?, ?)`.
4. Tietokanta lisää rivin ja palauttaa (esim. uuden `id`).
5. Sovellus voi palauttaa onnistumisviestin tai uuden käyttäjäolion.

Kun käyttäjä kirjautuu:

1. Sovellus vastaanottaa `email`, `password`.
2. Datankäyttö suorittaa: `SELECT id, name, password_hash FROM users WHERE email = ?`.
3. Tietokanta palauttaa vastaavan rivin (tai ei mitään).
4. Sovellus tarkistaa salasanan ja luo istunnon.

---

## 6) Transaktiot sovelluskoodissa

Joissakin operaatioissa täytyy olla **kaikki tai ei mitään**. Esimerkki: rahan siirto: vähennä yhdeltä tililtä, lisää toiselle. Jos toinen vaihe epäonnistuu, ensimmäinen on peruttava.

Tietokannat tarjoavat **transaktiot** tähän. Sovelluskoodista kuvio on:

1. **Aloita** transaktio
2. Suorita yksi tai useampi kysely
3. **Commit** jos kaikki onnistui, tai **Rollback** jos jotain meni pieleen

```python
# Konseptuaalinen transaktiokuvio
with connection.transaction():
    cursor.execute("UPDATE accounts SET balance = balance - 100 WHERE id = 1")
    cursor.execute("UPDATE accounts SET balance = balance + 100 WHERE id = 2")
    # Commit tapahtuu automaattisesti onnistuessa; rollback poikkeuksessa
```

Monet ORM:t ja frameworkit hoitavat tämän implisiittisesti (esim. "yksi transaktio per pyyntö"). Transaktioiden ymmärtäminen on tärkeää oikeellisuuden kannalta, kun useiden taulujen tai rivien on pysyttävä synkassa.

---

## 7) Tyypillisiä käyttötapoja ohjelmoinnissa

### Verkkosovellukset

- **Backend** (.NET, Python, Java jne.) yhdistää tietokantaan
- Käyttäjän toimintojen laukaisevat kyselyt (sivun data, lomakkeiden lähetys)
- Istuntodata voi tallentua tietokantaan (tai välimuistiin)
- Tyypillistä: relaatiotietokanta käyttäjille, tilauksille, tuotteille; mahdollisesti Redis välimuistille

### Mobiilisovellukset

- Mobiilisovellus puhuu **API**:lle (REST, GraphQL)
- API-palvelin käyttää tietokantaa datan tallentamiseen ja hakuun
- Mobiilisovellus ei yhdistä suoraan tietokantaan; se käyttää API:a turvallisuuden ja keskitetyn hallinnan vuoksi

### Mikropalvelut

- Jokaisella palvelulla voi olla oma tietokantansa (tai skeemansa)
- Palvelut kommunikoivat API:en kautta; tietokantoja ei jaeta suoraan
- Jokainen palvelu omistaa datansa ja käyttää tietokantaa totuuden lähteenä

### Taustatyöt ja työntekijät

- Työt lukevat jonosta (tai taulusta, jota käytetään jonona)
- Työntekijät käsittelevät kohdetta ja päivittävät tietokantaa (esim. "tilaus lähetetty", "sähköposti lähetetty")
- Tietokanta tallentaa jokaisen työn nykyisen tilan

### Raportointi ja analytiikka

- Sovellukset (tai erilliset työt) kysyvät tietokannasta raportteja, kojelautoja, vientejä varten
- Joskus data kopioidaan datalageriin raskaaseen analytiikkaan; pääsovelluksen tietokanta pysyy transaktiodatan järjestelmänä

---

## 8) Turvallisuus tietokantaa käytettäessä koodissa

### SQL-injektio

**Älä koskaan** rakenna SQL:ää liittämällä käyttäjän syötettä:

```python
# VAARALLINEN
query = f"SELECT * FROM users WHERE email = '{user_input}'"
```

Käytä sen sijaan **parametrisoituja kyselyjä**:

```python
# TURVALLINEN
cursor.execute("SELECT * FROM users WHERE email = %s", (user_input,))
```

### Credentialit ja konfiguraatio

- Älä koskaan kovakoodaa tietokantasalasanoja lähdekoodiin
- Käytä ympäristömuuttujia tai turvallista konfiguraatiojärjestelmää
- Rajoita tietokantakäyttäjän oikeudet: sovelluksen ei pitäisi tarvita `SUPERUSER`- tai skeemaa muuttavia oikeuksia normaalissa toiminnassa

### Vähimmäisoikeudet

- Luo sovellukselle omistettu tietokantakäyttäjä
- Anna vain tarvittavat oikeudet (esim. `SELECT`, `INSERT`, `UPDATE`, `DELETE` tietyille tauluille)

---

## 9) Yhteenveto: tietokannat ohjelmoijan työkaluna

Ohjelmoijan näkökulmasta tietokannat:

1. **Tallentavat datan** yksittäisen ohjelman ajon ulkopuolelle
2. **Keskittävät jaetun tilan** monille käyttäjille ja prosesseille
3. **Pakkottavat oikeellisuuden** rajoitteiden ja transaktioiden kautta
4. **Tarjoavat kyselyrajapinnan** (SQL) datan pyytämiseen ilman matalan tason tiedosto- tai tallennuslogiikkaa

Sovellukset yhdistävät **ajurien** kautta, lähettävät **kyselyitä** (raaka SQL, kyselyrakentajat tai ORM-generoitu) ja vastaanottavat **tulokset**. Tietokanta hoitaa tallennuksen, indeksoinnin, samanaikaisuuden ja palautuksen.

Tietokantojen roolin ymmärtäminen ohjelmoinnissa—niiden tarkoitus ja käyttö—helpottaa sovellusten suunnittelua, jotka ovat oikein toimivia, skaalautuvia ja ylläpidettäviä.

---

## Liittyvät materiaalit

- [00 – Johdanto](./00-Johdanto.md) — Mikä on tietokanta ja miksi niitä kehitettiin?
- [04 – PostgreSQL](./04-PostgreSQL.md) — Johdanto PostgreSQLiin
- [05 – SQL-perusteet](./05-SQL-perusteet.md) — Taulujen rakentaminen ja kyselyt SQL:llä
- [13 – Entity Framework Core](./13-Entity-Framework-Core.md) — Käytännön ORM .NET-sovelluksille
- [14 – Käyttäjien ja roolien hallinta ohjelmoinnissa](./14-Kayttajien-ja-roolien-hallinta-ohjelmoinnissa.md) — Sovellustason käyttäjät, roolit ja tietokantakäyttö
