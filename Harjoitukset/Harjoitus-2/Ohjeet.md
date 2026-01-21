# **Harjoitus 2: ER-MALLINNUS**

# **Suunnittele ja mallinna: Kirjaston lainausjärjestelmä**

> **Ohjeet:**
> Käy jokainen osio läpi järjestyksessä. Kirjoita vastauksesi tyhjiin kohtiin.

---

## **OSA 0 — Ongelman ymmärtäminen**

### 📌 Skenaario (lue huolellisesti)

Pieni kirjasto haluaa tietokannan, jolla seurataan jäsenten kirjojen lainaamista.

Keskeiset vaatimukset:

* Kirjasto tallentaa **kirjat** (id, nimi, julkaisuvuosi).
* Jokaisella kirjalla on **täsmälleen yksi kustantaja**; yksi kustantaja voi julkaista monia kirjoja.
* Kirjalla voi olla **yksi tai useampi kirjoittaja**; kirjoittaja voi kirjoittaa monta kirjaa.
* Ihmiset rekisteröityvät **jäseniksi** (id, nimi, sähköposti, liittymispäivä).
* Jäsen voi lainata monta kirjaa ajan myötä.
* Kirjaa voidaan lainata monta kertaa ajan myötä, mutta jokainen lainaus liittyy yhteen jäseneen ja yhteen kirjaan.
* Jokaisesta lainauksesta tallennetaan: **lainauspäivä, eräpäivä, palautuspäivä** (voi olla tyhjä).
* Kirjastolla on useita **toimipisteitä** (id, nimi, osoite).
* Jokainen fyysinen kirjan kopio kuuluu täsmälleen yhteen toimipisteeseen.
* Kirjasto voi omistaa useita kopioita samasta kirjasta.

---

## **Tietomallinnus (Käsitteellisestä → Loogiseen)**

### **Vaihe 1 — Ehdokkaiden tunnistaminen (substantiivien metsästys)**

Alleviivaa substantiivit skenaariosta ja listaa ehdokasentiteetit alle:

**Ehdokasentiteetit:**

*
*
*
*
*
*
*

---

### **Vaihe 2 — Lopulliset entiteetit + yhden lauseen määritelmä**

Valitse lopulliset entiteetit ja määrittele kukin yhdellä lauseella.

| Entiteetti | Yhden lauseen määritelmä |
| ---------- | ------------------------ |
|            |                          |
|            |                          |
|            |                          |
|            |                          |
|            |                          |
|            |                          |
|            |                          |

---

### **Vaihe 3 — Pääavainten valinta (tunnisteet)**

Ehdota kullekin entiteetille pääavain.

| Entiteetti | Pääavain (PK) |
| ---------- | ------------- |
|            |               |
|            |               |
|            |               |
|            |               |
|            |               |
|            |               |
|            |               |

> 💬 Pohdinta: Miksi nimet tai otsikot eivät yleensä ole hyviä pääavaimia?
>
> Vastauksesi:

---

### **Vaihe 4 — Keskeisten attribuuttien lisääminen**

Listaa keskeiset attribuutit vaatimuksista (älä yli-analysoi — sisällytä vain tärkeimmät).

#### (kirjoita entiteetin nimi tähän)

* PK:
* ## Muut attribuutit:

  *

#### (kirjoita entiteetin nimi tähän)

* PK:
* ## Muut attribuutit:

  *

#### (kirjoita entiteetin nimi tähän)

* PK:
* ## Muut attribuutit:

  *
  *

#### (kirjoita entiteetin nimi tähän)

* PK:
* ## Muut attribuutit:

#### (kirjoita entiteetin nimi tähän)

* PK:
* ## Muut attribuutit:

#### (kirjoita entiteetin nimi tähän)

* PK:
* ## Muut attribuutit:

  *

#### (kirjoita entiteetin nimi tähän)

* PK:
* ## Muut attribuutit:

  *
  *

---

### **Vaihe 5 — Relaatioiden tunnistaminen (verbien metsästys)**

Kirjoita suhteet muodossa: **Entiteetti — verbi — Entiteetti**

*
*
*
*
*

---

### **Vaihe 6 — Kardinaliteetin määrittäminen (1:1, 1:N, M:N)**

Täytä alla oleva taulukko.

| Suhde | Kardinaliteetti | Perustelu (lyhyesti) |
| ----- | --------------- | -------------------- |
|       |                 |                      |
|       |                 |                      |
|       |                 |                      |
|       |                 |                      |
|       |                 |                      |

---

### **Vaihe 7 — Valinnainen vs. pakollinen osallistuminen**

Vastaa seuraaviin kysymyksiin:

1. **Pitääkö jokaisella kirjalla olla kustantaja?**

   * [ ] Kyllä (pakollinen) [ ] Ei (valinnainen)
   * Miksi?

2. **Voiko kustantaja olla olemassa ilman yhtään kirjaa?**

   * [ ] Kyllä [ ] Ei
   * Miksi?

3. **Pitääkö jokaisella kirjalla olla vähintään yksi kirjoittaja?**

   * [ ] Kyllä [ ] Ei
   * Miksi?

4. **Pitääkö jokaisen kirjan kopion kuulua johonkin toimipisteeseen?**

   * [ ] Kyllä [ ] Ei
   * Miksi?

5. **Onko palautuspäivä pakollinen vai valinnainen Lainauksessa?**

   * [ ] Pakollinen [ ] Valinnainen
   * Miksi?

---

## **Piirrä ER-kaavio (looginen malli)**

### **Vaihe 8 — Entiteettien piirtäminen (laatikot)**

Piirrä suorakulmio jokaiselle entiteetille ja merkitse selvästi sen **pääavain**.

Käytä tätä tilaa (tai erillistä paperia):

* Voit piirtää ER-kaavion ohjelmistolla tai sovelluksella:

* [drawIo](https://www.drawio.com/)  (perus ja aloittelijaystävällinen)

* [smartdraw](https://www.smartdraw.com/entity-relationship-diagram/er-diagram-tool.htm) (hyvä, mutta osa työkaluista hieman piilossa)

* [dbdiagram](https://dbdiagram.io/home) (piirrä ER-kaavioita taulukoilla)

* [lucidchart](https://www.lucidchart.com/pages/examples/er-diagram-tool) (loistava työkalu, mutta vaatii tilin)
* 

* Kun olet valmis, voit ladata kuvan tai ottaa kuvakaappauksen

* Lisää kuva tehtäväkansioosi/repositorioon

* Voit katsoa mallia kuvien liittämisestä markdown tiedostoon täältä: [Adding images in markdown](https://www.markdownguide.org/basic-syntax/#images-1)

```
[ Lisää ER-kaaviosi tähän ]
```

---

### **Vaihe 9 — Lisää relaatiot**

Lisää nimetyt viivat entiteettien välille → selitä suhteet entiteettien välillä.

---

### **Vaihe 10 — Merkitse kardinaliteetti ja valinnaisuus**

Merkitse jokaiseen suhteeseen selvästi:

* 1, N tai M
* Pakollinen vs. valinnainen (jos käyttämäsi notaatiotapa tukee tätä)

---

## **Itsetarkistus (validointikysymykset)**

Tukeeko mallisi seuraavia tilanteita?

Merkitse ✔ tai ✘ ja selitä lyhyesti.

1. Voiko jäsen lainata useita kirjoja ajan myötä?

   * [ ] Kyllä [ ] Ei
   * Miksi?

2. Voiko samaa kirjakappaletta lainata useita kertoja eri kuukausina?

   * [ ] Kyllä [ ] Ei
   * Miksi?

3. Voiko kirjalla olla useita kirjoittajia?

   * [ ] Kyllä [ ] Ei
   * Miksi?

4. Voiko kirja olla olemassa ilman kustantajaa?

   * [ ] Kyllä [ ] Ei
   * Miksi?

5. Voiko lainauksella olla tyhjä return_date?

   * [ ] Kyllä [ ] Ei
   * Miksi?
