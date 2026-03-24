# Raportointiohje — Resepti- ja ateriasuunnittelutietokanta -projekti

Raportti täydentää palautettavia deliverableja kuvaamalla suunnittelupäätöksesi ja osoittamalla, että toteutus toimii. Käytä **kuvakaappauksia** tulosten esittämiseen ja **tekstiä** päätösten perusteluun.

---

## Raportin tarkoitus

- Näytä, että tietokanta ja sovellus toimivat tarkoitetulla tavalla
- Selitä **miksi** teit tietyt suunnittelupäätökset
- Todista, että ymmärrät vaatimukset ja osaat perustella toteutuksesi
- Helpota arvioijia ymmärtämään työtäsi nopeasti

---

## Raportin muoto

- **Muoto:** PDF tai Markdown (esim. `REPORT.md` tai `REPORT.pdf`)
- **Pituus:** Painota selkeyttä pituuteen. Tyypillinen raportti voi olla 3–6 sivua (PDF) perus- ja edistyneelle vaiheelle; lisää 1–2 sivua ORM-vaiheesta.
- **Rakenne:** Seuraa alla olevia osioita. Sisällytä vain ne osiot, jotka vastaavat suorittamiasi vaiheita.

---

## Kuvakaappausohjeet

- **Resoluutio:** Käytä selkeitä, luettavia kuvakaappauksia. Vältä liian pieniä tai vahvasti pakattuja kuvia.
- **Konteksti:** Sisällytä riittävästi kontekstia (esim. kysely, tulostaulu, työkalun nimi), jotta lukija ymmärtää mitä kuvassa näkyy.
- **Kuvatekstit:** Lisää jokaisen kuvakaappauksen alle lyhyt kuvateksti.
- **Mitä kuvata:**
  - ER-kaavio (tai vie se erilliseksi kuvaksi ja viittaa siihen)
  - Skeeman suoritus (esim. taulujen onnistunut luonti)
  - Esimerkkikyselyn tulokset
  - Indeksimäärittelyt, roolimäärittelyt
  - Konsolisovelluksen tulostus
- **Luottamuksellisuus:** Älä sisällytä todellisia salasanoja tai arkaluonteisia tietoja kuvakaappauksiin. Käytä paikkamerkkejä tai sumenna tarvittaessa.

---

# Raportin rakenne

## 1. Johdanto

**Sisällytä:**
- Lyhyt projektin yleiskuva (1–2 lausetta)
- Mitkä vaiheet suoritit (perus, edistynyt, ORM)
- Mahdolliset oletukset vaatimusten tulkinnasta

**Kuvakaappaukset:** Ei vaadita.

---

## 2. Perusvaihe

### 2.1 ER-kaavio ja suunnittelupäätökset

**Sisällytä:**
- ER-kaaviosi (kuvakaappaus tai upotettu kuva)
- **Perustelu:** Selitä tärkeimmät suunnittelupäätöksesi, esim.:
  - Miten mallinsit entiteettien väliset suhteet (kardinaliteetti, valinnaisuus)
  - Miten esitit linkit entiteettien välillä, joissa on lisäattribuutteja
  - Miten päätit mitkä attribuutit ovat pakollisia ja mitkä valinnaisia

**Vastattavat kysymykset:**
- Miksi rakensit entiteettien väliset suhteet juuri näin?
- Mitä vaihtoehtoja harkitsit ja miksi valitsit tämän lähestymistavan?

### 2.2 Skeeman toteutus

**Sisällytä:**
- Kuvakaappaus skeeman luonnista (esim. skeemaskriptisi onnistunut suoritus)
- **Perustelu:** Selitä keskeiset toteutusvalinnat, esim.:
  - Tietotyypit eri datalle
  - Lisäämäsi rajoitteet ja miksi
  - Miten toteutit pääavaimet, viiteavaimet ja viite-eheyden (mitä tapahtuu kun rivi päivitetään tai poistetaan)

**Vastattavat kysymykset:**
- Miksi valitsit nämä tietotyypit?
- Miten käsittelit viite-eheyden kun viitattu rivi poistetaan?

### 2.3 Esimerkkidata ja kyselyt

**Sisällytä:**
- Kuvakaappaus edustavasta kyselyn tuloksesta
- **Perustelu:** Selitä miten esimerkkidata täyttää projektin vaatimukset.
- Jos jokin kysely oli haastava, selitä lähestymistapasi ja miten ratkaisit sen.

**Vastattavat kysymykset:**
- Miten esimerkkidatasi osoittaa keskeiset suunnittelusi suhteet?
- Mikä kysely oli vaikein ja miten ratkaisit sen?

---

## 3. Edistyneempi vaihe (jos suoritettu)

### 3.1 Laajennettu suunnittelu ja ER-kaavio

**Sisällytä:**
- Päivitetty ER-kaavio kaikkine uusine entiteetteineen
- **Perustelu:** Selitä miten mallinsit:
  - Käyttäjätyypit tai roolit ja niiden suhteet
  - Uudet entiteetit ja niiden suhteet olemassa oleviin
  - Mahdolliset lisätiedot sisältävät attribuutit (esim. paikat, päivät, järjestys)

**Vastattavat kysymykset:**
- Miten mallinsit käyttäjätyypit tai roolit?
- Miten suunnittelit uusien entiteettien ja olemassa olevien välisten linkkien suunnittelun?

### 3.2 Skeeman laajennukset, indeksit ja roolit

**Sisällytä:**
- Kuvakaappaus skeeman laajennusten onnistuneesta suorituksesta
- Kuvakaappaus tai luettelo luoduista indekseistä ja rooleista
- **Perustelu:** Selitä:
  - Miksi lisäsit tiettyjä indeksejä ja mitä ne tukevat
  - Miten annoit oikeudet kullekin roolille
  - Viite-eheysvalinnat uusissa tauluissa

**Vastattavat kysymykset:**
- Mitkä indeksit lisäsit ja mitä käyttötapauksia ne tukevat?
- Miten päätit oikeustason kullekin roolille?

### 3.3 Edistyneemmät kyselyt

**Sisällytä:**
- Kuvakaappaus vähintään yhdestä edistyneemmän kyselyn tuloksesta
- **Perustelu:** Jos kysely vaati erityiskäsittelyä, selitä lähestymistapasi.

---

## 4. Konsolisovellus — ORM-vaihe (jos suoritettu)

### 4.1 Teknologia ja asennus

**Sisällytä:**
- Kuvakaappaus sovelluksen ajamisesta
- **Perustelu:** Selitä:
  - Mitä teknologiaa käytit ja miksi
  - Miten konfiguroit tietokantayhteyden
  - Miten kartoitsit tietokantaskeeman koodiin (generoitu vai käsin kirjoitettu)

**Vastattavat kysymykset:**
- Miten yhdistit sovelluksen tietokantaasi?
- Miten hallitsit konfiguraatiota (esim. yhteysmerkkijono, salaisuudet)?

### 4.2 Toiminnallisuus

**Sisällytä:**
- Kuvakaappaukset sovelluksesta lukemassa ja näyttämässä dataa
- **Perustelu:** Selitä miten ORM:ää käytettiin datan hakemiseen ja mahdolliset kartoitusongelmat.

**Vastattavat kysymykset:**
- Miten sovelluksesi hakee ja näyttää vaaditun datan?
- Kohtasitko kartoitusongelmia skeeman ja ORM:n välillä?

---

## 5. Yhteenveto ja reflektio

**Sisällytä:**
- Lyhyt yhteenveto siitä mitä rakensit ja miten se täyttää vaatimukset
- Mahdolliset rajoitukset tai parannukset, joita tekisit lisäaikaa saadessasi
- Mitä opit projektista

**Kuvakaappaukset:** Ei vaadita.

---

## Tarkistuslista ennen palautusta

- [ ] Kaikki kuvakaappaukset ovat selkeitä ja niillä on kuvatekstit
- [ ] Ei arkaluonteisia tietoja (salasanat, todelliset sähköpostit) kuvakaappauksissa
- [ ] Jokaisella suorittamallasi vaiheella on vastaava osio perusteluineen
- [ ] Suunnittelupäätökset on perusteltu, ei vain kuvattu
- [ ] Raportti on luettava (kielioppi, rakenne, muotoilu)

---

## Valinnainen: Raporttimalli

Voit aloittaa tästä rakenteesta ja täyttää sisällön:

```markdown
# Resepti- ja ateriasuunnittelutietokanta -projektin raportti

## 1. Johdanto
[Yleiskuvaus ja oletukset]

## 2. Perusvaihe
### 2.1 ER-kaavio ja suunnittelupäätökset
[Kaavio + perustelut]
### 2.2 Skeeman toteutus
[Kuvakaappaus + perustelut]
### 2.3 Esimerkkidata ja kyselyt
[Kuvakaappaus + perustelut]

## 3. Edistyneempi vaihe (jos suoritettu)
### 3.1 Laajennettu suunnittelu
### 3.2 Skeema, indeksit, roolit
### 3.3 Edistyneemmät kyselyt

## 4. Konsolisovellus (jos suoritettu)
### 4.1 Teknologia ja asennus
### 4.2 Toiminnallisuus

## 5. Yhteenveto ja reflektio
```
