# Harjoitus: Tiedostopohjainen datanhallinta (ennen tietokantoja)

Sinut on pudotettu maailmaan **ennen relaatiotietokantoja**.
Sinun täytyy silti tallentaa, päivittää ja hakea dataa — mutta ainoat työkalusi ovat **tekstitiedostot** ja oma koodisi.

Tämä harjoitus käsittelee **datan hallintaa**, ei “tietokannan rakentamista”.
Toteutat sellaisia toimintatapoja, joita organisaatiot käyttivät **flat file** -tiedostoilla: päiväkirjat, virkailijat, raportit ja yöajot (batch jobit).

Hallinnoit kolmea CSV-tiedostoihin tallennettua “taulua”:

- `books.csv` — kirjaston kirjat
- `members.csv` — kirjaston jäsenet
- `loans.csv` — lainat (lainaukset / palautukset)

---

## Oppimistavoitteet

Lopussa sinun pitäisi ymmärtää paremmin (havaittujen epäonnistumisten kautta):

- miten datanhallinta toimi **flat file** -tiedostoilla, konventioilla ja eräajoilla (batch processing)
- miksi **haku** on hidasta ilman indeksejä (täydet läpikäynnit / full scans)
- miksi **päivitykset** ovat hankalia ilman tietue-/sivurakenteita (uudelleenkirjoitus vs. lisäys + tiivistys)
- miksi **samanaikaisuus** (kaksi virkailijaa kirjoittaa yhtä aikaa) aiheuttaa tupla-ID:itä ja kadonneita päivityksiä
- miksi **kaatumiset** rikkovat tiedostoja ilman journalingia/transaktioita
- miksi **rajoitteet** (uniikit avaimet, viiteavaimet, sallitut arvot) ovat tärkeitä
- miksi **skeemamuutokset** (uuden sarakkeen lisääminen) ovat tuskallisia ilman migraatioita
- miten alat vähitellen keksiä uudelleen tietokannan ominaisuuksia (lukitus, indeksointi, lokit), jos jatkat paikkailemista

---

## Skenaario (kirjasto vuonna 1985)

Tietokantapalvelinta ei ole. SQL:ää ei ole. “Turvallista päivitystä” ei ole.

Sinulla on:

- jaettu kansio (sinun `data/`-hakemistosi)
- CSV-tiedostot “pääkirjoina”
- komentorivityökalu (CLI), jota virkailijat käyttävät päivittäisiin toimiin
- “yöajot” (skriptit, joita ajat ajoittain) datan tarkistamiseen/täsmäyttämiseen/uudelleenrakentamiseen

Tehtäväsi on tehdä tästä järjestelmästä **riittävän käyttökelpoinen**, että virkailija voisi käyttää sitä, ja samalla dokumentoida matkan varrella syntyvä kipu.

---

## Projektikierros: mitä kukin tiedosto on ja miksi se on olemassa

### Koodi

- `src/filedb/__main__.py`
  Mahdollistaa komennon `python -m src.filedb ...`. Tämä on moduulin entrypoint, joka kutsuu CLI:tä.

- `src/filedb/cli.py`
  Komentoriviohjelma. Täällä elävät “virkailijoiden toiminnot”:

  - komentoriviargumenttien jäsentäminen
  - CSV-pääkirjojen lataus
  - kirjanpitosääntöjen soveltaminen (validointi, liiketoimintasäännöt)
  - päivitettyjen pääkirjojen kirjoittaminen takaisin levylle

- `src/filedb/storage.py`
  Matalan tason CSV I/O -apuja (tahallisen naiiveja):

  - lukee koko tiedoston muistiin
  - kirjoittaa päivityksissä koko tiedoston takaisin
  - tarjoaa naiiviin `next_id`:n (`max(id)+1`), joka on _kilpailutilanteille (race condition) altis_

  Tämä tiedosto on olemassa, jotta “datan käsittelyn mekaniikka” voidaan erottaa `cli.py`:n “virkailijaproseduureista”.

- `src/filedb/models.py`
  Valinnaiset dataclassit (Book/Member/Loan). Voit käyttää niitä siistimpään koodiin, mutta järjestelmä tallentaa lopulta CSV-muodossa.
  Tämä tiedosto on olemassa, jotta tietueiden “muoto” olisi eksplisiittinen koodissa.

### Skriptit

- `scripts/generate_data.py`
  Dataset-generaattori, jolla voidaan luoda **pieniä tai suuria pääkirjoja** tarpeen mukaan.
  Tämä on erityisen hyödyllinen “feel the pain” -labroissa, joissa tarvitset isoja tiedostoja hitaiden läpikäyntien ja kalliiden uudelleenkirjoitusten havainnointiin.

### Data (pääkirjasi)

- `data/books.csv`
  Kirjapääkirja: yksi rivi per kirja.

- `data/members.csv`
  Jäsenpääkirja: yksi rivi per jäsen.

- `data/loans.csv`
  Lainapääkirja: yksi rivi per lainaus-/palautustapahtuma.

**Tärkeää:** CSV ei pakota mitään sääntöjä. Koodisi ja proseduurisi täytyy pakottaa:

- sallitut arvot
- uniikkiussäännöt
- viite-eheys (lainarivien on viitattava olemassa oleviin kirja-/jäsenriveihin)

---

## Asennus

Vaatii Pythonin **3.10+**.

#### 1. Varmista, että olet oikeassa työhakemistossa

```bash
cd Naive_File_DB
```

- **Vaihtaa nykyisen hakemistosi** projektikansioon nimeltä `Naive_File_DB`.
- Tämän jälkeen kaikki suhteelliset polut (kuten `.venv` tai `requirements.txt`) haetaan tuon kansion sisältä.

#### 2. Luo virtuaaliympäristö

```bash
python -m venv .venv
```

- Luo **Python-virtuaaliympäristön** kansioon nimeltä `.venv`.
- Virtuaaliympäristö on eristetty “mini-Python-asennus” tälle projektille, jotta asentamasi paketit eivät vaikuta järjestelmänlaajuiseen Python-asennukseen (ja päinvastoin).
- Tulos: näet uuden `.venv/`-hakemiston ilmestyvän.

#### 3. Aktivoi virtuaaliympäristö

###### A) Windows-käyttäjät

```bash
.venv\Scripts\Activate.ps1
```

- Aktivoi virtuaaliympäristön **Windows PowerShellissä**.
- Sama vaikutus kuin `source ...` macOS/Linuxissä: se ohjaa `python`/`pip`-komennot käyttämään `.venv`-ympäristöä.
- Huom: Windows käyttää poluissa kenoviivoja `\`.

##### B) Mac-käyttäjät

```bash
source .venv/bin/activate
```

- **Aktivoi** virtuaaliympäristön macOS/Linuxissä.

- Tämä päivittää shellisi niin, että:

  - `python` osoittaa `.venv`:n Pythoniin
  - `pip` asentaa paketit `.venv`:iin järjestelmä-Pythonin sijaan

- Yleensä terminaalikehote muuttuu (usein näkyy `(.venv)`).

#### Asenna riippuvuudet

```bash
pip install -r requirements.txt
```

- Käyttää `pip`:iä **asentamaan kaikki vaaditut riippuvuudet**, jotka on listattu `requirements.txt`-tiedostossa.
- Koska aktivoiit `.venv`:n ensin, paketit asennetaan virtuaaliympäristöön (ei globaalisti).

---

## Dataset-generaattorin käyttö (scripts/generate_data.py)

Voit käyttää generaattoria milloin tahansa, kun tarvitset **suurempia tiedostoja** tehdäksesi ongelmat selviksi.

### Luo pieni, siisti data `./data`-kansioon (ylikirjoittaa olemassa olevat tiedostot)

```bash
python scripts/generate_data.py --books 50 --members 20 --loans 30 --out ./data
```

### Luo “iso” data suorituskykykipua varten

```bash
python scripts/generate_data.py --books 50000 --members 20000 --loans 40000 --out ./data --seed 1
```

### Luo “huonoa dataa” (rikkinäiset viitteet, epäjohdonmukaiset tilat, skeemadrifti)

```bash
python scripts/generate_data.py --books 5000 --members 2000 --loans 4000 --out ./data \
  --bad-refs 50 --double-checkout 50 --inconsistent 50 --schema-drift
```

**Mitä se muuttaa käytännössä:**
Se kirjoittaa uudet versiot `books.csv`-, `members.csv`- ja `loans.csv`-tiedostoista kansioon, jonka määrität `--out`-parametrilla.

> Vinkki: Jos haluat säilyttää useita datasettejä, generoita uusiin kansioihin:
> `--out ./datasets/big1` ja aja sitten CLI `--data-dir ./datasets/big1` -parametrilla

---

## Pika-aloitus (aja kerran toimimaan)

### 1) Katso, mitä komentoja on olemassa

```bash
python -m src.filedb --help
```

**Käytännössä:** virkailija kysyy “mitä tällä järjestelmällä voi tehdä?” Tämä on “proseduurien menu”.

### 2) Luo esimerkkipääkirjat (jos puuttuu)

```bash
python -m src.filedb init-data
```

**Käytännössä:** pystytät arkistokaapit. Jos tiedostot ovat jo olemassa, niitä ei ylikirjoiteta.

> Jos haluat enemmän dataa kuin pienissä aloitustiedostoissa on, käytä generaattoria:
> `python scripts/generate_data.py --books 50 --members 20 --loans 30 --out ./data`

### 3) Hae kirja nimen perusteella

```bash
python -m src.filedb find-book --title dune
```

**Käytännössä:** virkailija selaa koko kirjapääkirjan läpi etsiessään otsikkoa vastaavaa riviä.
Tämä on koko tiedoston läpikäynti (hidasta, kun pääkirja on suuri).

---

## Päivä elämässä: vaiheittainen läpikäynti

Tämä on realistinen “virkailijan työnkulku” järjestelmää käyttäen.

### Vaihe 1 — Lisää uusi jäsen

```bash
python -m src.filedb add-member --name "Ada Lovelace" --email "ada@example.com"
```

**Mitä se tekee käytännössä:**

- lukee `members.csv`
- valitsee uuden jäsentunnuksen (tällä hetkellä naiivi: `max(id)+1`)
- lisää rivin
- kirjoittaa koko `members.csv`-tiedoston uudelleen

### Vaihe 2 — Lisää uusi kirja

```bash
python -m src.filedb add-book --title "Dune" --author "Frank Herbert" --year 1965 --isbn "9780441172719"
```

**Mitä se tekee käytännössä:**

- lukee `books.csv`
- varaa uuden ID:n
- kirjoittaa rivin tilalla `AVAILABLE`
- kirjoittaa `books.csv`-tiedoston uudelleen

### Vaihe 3 — Lainaa kirja

```bash
python -m src.filedb checkout --book-id 1 --member-id 1
```

**Mitä se tekee käytännössä:**

- lukee `books.csv`, `members.csv`, `loans.csv`
- luo uuden rivin `loans.csv`-tiedostoon tilalla `OUT`
- päivittää kirjan rivin `books.csv`-tiedostossa tilaan `OUT`
- kirjoittaa `loans.csv`- ja `books.csv`-tiedostot uudelleen

### Vaihe 4 — Palauta kirja

```bash
python -m src.filedb return --loan-id 1
```

**Mitä se tekee käytännössä:**

- päivittää lainarivin tilaan `RETURNED` + asettaa `return_date`
- päivittää kirjan tilan takaisin `AVAILABLE`
- kirjoittaa `loans.csv`- ja `books.csv`-tiedostot uudelleen

### Vaihe 5 — Listaa jäsenen lainahistoria

```bash
python -m src.filedb member-loans --member-id 1
```

**Mitä se tekee käytännössä:** käy koko `loans.csv`-tiedoston läpi ja tulostaa kyseisen jäsenen rivit.

### Vaihe 6 — Etsi myöhässä olevat lainat

```bash
python -m src.filedb overdue --days 14
```

**Mitä se tekee käytännössä:** käy koko `loans.csv`-tiedoston läpi ja tulostaa vanhat `OUT`-lainat.

---

## Mitä sinun täytyy tehdä (EI KOODAUSTA VAADITA)

Harjoituksen vaadittu osa on **käyttää** tiedostopohjaista järjestelmää kuten ennen tietokantoja toimiva organisaatio tekisi, ja dokumentoida mitä tapahtuu.

### Tehtävä 1 — Tarkastele “pääkirjoja” (CSV-tiedostot)

1. Aja `init-data`
2. Avaa `data/books.csv`, `data/members.csv`, `data/loans.csv` tekstieditorissa
3. Vastaa raportissasi:

   - Mitä tyhjät kentät tarkoittavat (esim. `return_date`)?
   - Mitkä säännöt ovat “oletettuja” mutta CSV ei pakota niitä?
   - Mitä tiedosto(ja) pitäisi muokata lainauksessa? palautuksessa?

### Tehtävä 2 — Suorita kokonainen työnkulku ja selitä se

Aja tämä sarja ja selitä, mitä tiedostoille tapahtuu jokaisen vaiheen jälkeen:

```bash
python -m src.filedb init-data
python -m src.filedb add-member --name "Ada Lovelace" --email "ada@example.com"
python -m src.filedb add-book --title "Dune" --author "Frank Herbert" --year 1965 --isbn "9780441172719"
python -m src.filedb checkout --book-id 1 --member-id 1
python -m src.filedb return --loan-id 1
python -m src.filedb member-loans --member-id 1
```

Raportissa, jokaiselle komennolle:

- mitkä CSV-tiedostot luettiin?
- mitkä CSV-tiedostot kirjoitettiin kokonaan uudelleen?
- mitä voisi mennä pieleen, jos ohjelma kaatuu väärään aikaan?

### Tehtävä 3 — “Feel the pain” -minilabrat (mittaa + selitä)

Ajetaan kolme lyhyttä demoa ja kirjataan havainnot.

Nämä labrat toimivat parhaiten **isoilla pääkirjoilla**. Luo ne ensin generaattorilla:

```bash
python scripts/generate_data.py --books 50000 --members 20000 --loans 40000 --out ./data --seed 1
```

> Vaihtoehto: generoita erilliseen kansioon ja käytä `--data-dir`:
>
> - `python scripts/generate_data.py ... --out ./datasets/big1`
> - `python -m src.filedb --data-dir ./datasets/big1 find-book --title the`

#### Labra A: Lineaarinen haku

Aja `find-book` useita kertoja ja huomaa, että se skannaa koko tiedoston:

```bash
python -m src.filedb find-book --title the
python -m src.filedb find-book --title dune
```

Selitä, miksi tämä hidastuu suurilla tiedostoilla.

#### Labra B: Yksi päivitys kirjoittaa koko tiedoston uudelleen

Palauta laina ja huomaa, että se kirjoittaa kokonaiset tiedostot uudelleen (`loans.csv` ja `books.csv`).
Selitä, miksi “yhden rivin päivittäminen” on kallista flat file -tallennuksessa.

> Vinkki: Jos datasetissäsi ei ole selvästi `OUT`-tilassa olevaa lainaa palautettavaksi, generoita data suuremmalla out-suhteella:
> `python scripts/generate_data.py --books 50000 --members 20000 --loans 40000 --out ./data --out-ratio 0.7`

#### Labra C: Ei transaktioita (osittainen epäonnistuminen)

Lainaus koskee **kahta tiedostoa** (`loans.csv` + `books.csv`).
Selitä, miltä epäjohdonmukainen tila näyttäisi, jos ohjelma kaatuu sen jälkeen, kun yksi tiedosto on päivitetty mutta toinen ei.

> Vinkki: Voit demonstroida tämän ilman koodausta kuvaamalla, _mikä tiedosto_ päivittyisi ensin ja millaisen ristiriidan se synnyttää.

> Valinnainen “huono data” -demo (ei vieläkään koodausta):
> Generoi rikkinäiset/epäjohdonmukaiset pääkirjat ja tarkastele niitä:
>
> ```bash
> python scripts/generate_data.py --books 5000 --members 2000 --loans 4000 --out ./data \
>   --bad-refs 50 --double-checkout 50 --inconsistent 50 --schema-drift
> ```
>
> Avaa sitten CSV:t ja kuvaa, millaisia ongelmia niissä näkyy.

### Tehtävä 4 — Kirjoita “kansiokirjan säännöt” (proseduurit)

Kirjoita raporttiisi lyhyt osio (luettelomerkkeinä käy), jossa määrittelet organisaatiosi “kirjanpidon ohjekansion”:

- sallitut tilat kirjoille/jäsenille/lainoille
- miltä validi laina näyttää
- mitä teet, jos löydät rikkinäisiä viitteitä (laina viittaa puuttuvaan kirjaan/jäseneen)
- mitä teet, jos kirjat ja lainat ovat eri mieltä siitä, onko kirja `OUT`
- miten käsittelisit skeemamuutokset (uuden sarakkeen lisääminen) CSV:ssä

Näin pre-DB-tiimit oikeasti tekivät: _dokumentoi säännöt + aja täsmäytyseräajot_.

---

## Valinnaiset / lisätehtävät (KOODAUS SUOSITELTUA)

Kaikki alla oleva on vapaaehtoista. Jos haluat tehdä käytännön koodausta, valitse yksi tai useampi.
Jokaisessa tehtävässä on **esimerkkikoodi** ja tarkka ohje, **mihin se laitetaan**.

### Lisätehtävä 1 — Lisää validointiapurit (suositeltu aloituskoodaustehtävä)

**Tavoite:** hylkää selvästi huonot syötteet (vuosilukuväli, sähköpostiformaatti, sallitut tilat).

**Mihin lisätä koodi:**

- Lisää apurifunktiot `src/filedb/cli.py`-tiedoston alkuun (importtien alle, ennen komentofunktioita).
- Kutsu niitä `cmd_add_book`- ja `cmd_add_member`-funktioiden sisällä.

**Lisättävä esimerkkikoodi (tiedostoon `cli.py`):**

```python
import re
from datetime import date

_EMAIL_RE = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")

def require_year(year: int) -> None:
    current = date.today().year
    if year < 1400 or year > current:
        raise SystemExit(f"Invalid year: {year}. Expected 1400..{current}.")

def require_email(email: str) -> None:
    if not _EMAIL_RE.match(email):
        raise SystemExit(f"Invalid email: {email}")

def require_one_of(value: str, allowed: set[str], field: str) -> None:
    v = (value or "").upper()
    if v not in allowed:
        raise SystemExit(f"Invalid {field}: {value}. Allowed: {sorted(allowed)}")
```

**Mistä sitä kutsutaan:**

- `cmd_add_book(args)`-funktiossa, ennen kirjoittamista:

```python
require_year(args.year)
```

- `cmd_add_member(args)`-funktiossa, ennen kirjoittamista:

```python
require_email(args.email)
```

**Miksi tämä on olemassa pre-DB-järjestelmissä:** virkailijoilla oli proseduurit (“älä hyväksy lomakkeita ilman X”). Tässä validointi on sinun “proseduurin pakottaminen”.

---

### Lisätehtävä 2 — Lisää raporttikomento (inventaarioraportti)

**Tavoite:** lisää pre-DB “raportti”-komento, esim. määrät tiloittain ja top-kirjoittajat.

**Mihin lisätä koodi:**

1. Lisää uusi funktio `src/filedb/cli.py`-tiedostoon:

   - sijoita muiden komentofunktioiden lähelle, esim. `cmd_overdue`-funktion alle

2. Rekisteröi se `build_parser()`-funktiossa (lisää uusi subparser)

**Esimerkkikomennon funktio (lisää `cli.py`):**

```python
def cmd_report_inventory(args: argparse.Namespace) -> int:
    books_path = path_for(args.data_dir, BOOKS_CSV)
    rows = read_csv_dicts(books_path)

    by_status: dict[str, int] = {}
    by_author: dict[str, int] = {}

    for r in rows:
        status = (r.get("status") or "").upper()
        author = (r.get("author") or "").strip()
        by_status[status] = by_status.get(status, 0) + 1
        by_author[author] = by_author.get(author, 0) + 1

    print("Books by status:")
    for k in sorted(by_status):
        print(f"  {k}: {by_status[k]}")

    print("\nTop authors:")
    top = sorted(by_author.items(), key=lambda kv: kv[1], reverse=True)[:10]
    for author, count in top:
        print(f"  {author}: {count}")
    return 0
```

**Rekisteröi se `build_parser()`-funktioon (muiden alikomentojen lähelle):**

```python
s = sub.add_parser("report-inventory", help="Report counts of books by status and top authors")
s.set_defaults(func=cmd_report_inventory)
```

---

### Lisätehtävä 3 — Lisää “verify-data” eräajo (yöskannaus)

**Tavoite:** skannaa kaikki tiedostot, löydä rikkinäiset viitteet ja mahdottomat tilat.

**Mihin lisätä koodi:**

- Lisää `cmd_verify_data` `cli.py`-tiedostoon
- Rekisteröi se `build_parser()`-funktiossa

**Esimerkkieräajo (lisää `cli.py`):**

```python
def cmd_verify_data(args: argparse.Namespace) -> int:
    books = read_csv_dicts(path_for(args.data_dir, BOOKS_CSV))
    members = read_csv_dicts(path_for(args.data_dir, MEMBERS_CSV))
    loans = read_csv_dicts(path_for(args.data_dir, LOANS_CSV))

    book_ids = {b.get("id") for b in books}
    member_ids = {m.get("id") for m in members}

    problems = 0

    for loan in loans:
        lid = loan.get("id")
        if loan.get("book_id") not in book_ids:
            print(f"[BROKEN] loan {lid}: missing book_id={loan.get('book_id')}")
            problems += 1
        if loan.get("member_id") not in member_ids:
            print(f"[BROKEN] loan {lid}: missing member_id={loan.get('member_id')}")
            problems += 1

        status = (loan.get("status") or "").upper()
        rdate = (loan.get("return_date") or "").strip()
        if status == "RETURNED" and rdate == "":
            print(f"[IMPOSSIBLE] loan {lid}: RETURNED but return_date empty")
            problems += 1
        if status == "OUT" and rdate != "":
            print(f"[IMPOSSIBLE] loan {lid}: OUT but return_date set")
            problems += 1

    print(f"Verify complete. Problems found: {problems}")
    return 0 if problems == 0 else 2
```

**Rekisteröi se `build_parser()`-funktiossa:**

```python
s = sub.add_parser("verify-data", help="Batch job: scan files and report data problems")
s.set_defaults(func=cmd_verify_data)
```

---

### Lisätehtävä 4 — Demonstroi kilpailutilanteet ID:issä (kaksi virkailijaa)

**Tavoite:** tee ongelma selväksi lisäämällä pieni viive.

**Mihin lisätä koodi:**

- `src/filedb/storage.py`-tiedostossa, `next_id_naive`-funktion sisään
- (Valinnainen) nuku vain, jos ympäristömuuttuja on asetettu

**Esimerkkikoodi (tiedostoon `storage.py`):**

```python
import time
import os

def next_id_naive(rows: List[Dict[str, str]]) -> int:
    if os.environ.get("FILEDB_SLOW_ID") == "1":
        time.sleep(0.2)
    # compute max(id)+1 as before...
```

Sitten aja kahdessa terminaalissa:

```bash
cmd /c "FILEDB_SLOW_ID=1 python -m src.filedb add-member --name "Clerk A" --email "a@example.com""
cmd /c "FILEDB_SLOW_ID=1 python -m src.filedb add-member --name "Clerk B" --email "b@example.com""
```

---

## Palautettavat

### Pakollinen (ei koodausta)

- Lyhyt raportti, joka kattaa pakolliset tehtävät 1–4:

  - miten pääkirjat toimivat
  - mitkä toiminnot kirjoittavat mitkä tiedostot uudelleen
  - mitä vikaskenaarioita on (kaatuminen, osittaiset kirjoitukset, epäjohdonmukaisuudet)
  - “kansiokirjan säännöt” (proseduurit)

### Valinnainen (lisäpisteet / jatko)

- Toteutetut lisätehtävät (validointi, raportit, verify-data-eräajo jne.)
- Liitä kuvakaappauksia / esimerkkiajoja, jotka näyttävät ominaisuuden ja kompromissit

---

## Vinkit

- Jos jatkat “korjausten” lisäämistä (tiedostolukitukset, indeksit, lokit, tiivistys), alat vähitellen keksiä uudelleen tietokannan.
- Se on tarkoitus. Dokumentoi jokainen korjaus ja ne uudet ongelmat, joita se tuo.
- Järjestelmäsi saa olla hidas ja hauras — kunhan _näytät sen_ ja selität miksi.
