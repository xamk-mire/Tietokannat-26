# **Harjoitus 2: ER-MALLINNUS**
Jasse Kuutsuo
Vladislav Jeskin
Lauri Tauren
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

* Kirja
* kustantaja
* Kirjoittaja
* Jäsen
* Kopio
* Toimipiste
* Lainaus
---

### **Vaihe 2 — Lopulliset entiteetit + yhden lauseen määritelmä**

Valitse lopulliset entiteetit ja määrittele kukin yhdellä lauseella.

| Entiteetti | Yhden lauseen määritelmä
| Kirja      | abstrakti kirja,ei fyysinen
| Kustantaja | organisaatio joka julkaisee kirjoja
| Kirjoittaja| Henkilö joka kirjoittaa kirjoja
| Jäsen      | kirjautunut kirjaston jäsen, joka voi lainata kirjoja
| kopio      | fyysinen kirja tietyssä toimipisteessä
| lainaus    | tilanne/eventti
| toimipiste | fyysinen kirjaston lokaatio
---

### **Vaihe 3 — Pääavainten valinta (tunnisteet)**

Ehdota kullekin entiteetille pääavain.

| Entiteetti | Pääavain (PK) |
| ---------- | ------------- |
| kirja      | kirja_id      |
| kustantaja | kustantaja_id |
| Kirjoittaja| kirjoittaja_id|
| jäsen      | jäsen_id      |
| kopio      | kopio_id      |
| lainaus    | lainaus_id    |
| toimipiste | toimipiste_id |

> 💬 Pohdinta: Miksi nimet tai otsikot eivät yleensä ole hyviä pääavaimia?
>
> Vastauksesi:
Nimet voivat toistua liian usein ja otsikot eivat kerro esim mikä kirja on kyseessä.
oma päätelmä tossa
saatan olla väärässäkin


### **Vaihe 4 — Keskeisten attribuuttien lisääminen**

Listaa keskeiset attribuutit vaatimuksista (älä yli-analysoi — sisällytä vain tärkeimmät).

#### (kirja)

* PK: kirja_id
* ## Muut attribuutit:

  * nimi
  * julkaisuvuosi

#### (kustantaja)

* PK: kustantaja_id
* ## Muut attribuutit:

  * kirja

#### (kirjoittaja)

* PK: kirjoittaja_id
* ## Muut attribuutit:

  * kirja
  

#### (jäsen)

* PK: jäsen_id
* ## Muut attribuutit:

* nimi
* sähköposti
* liittymispäivä

#### (kopio)

* PK: kopio_id
* ## Muut attribuutit:

* nimi
* julkaisuvuosi

#### (lainaus)

* PK: lainaus_id
* ## Muut attribuutit:

  * lainauspäivä
  * palautuspäivä
  * eräpäivä

#### (toimipiste)

* PK: toimipiste_id
* ## Muut attribuutit:

  * nimi
  * osoite


### **Vaihe 5 — Relaatioiden tunnistaminen (verbien metsästys)**

Kirjoita suhteet muodossa: **Entiteetti — verbi — Entiteetti**

* Kirja on toimipisteellä.
* Jäsen lainaa kirjan.
* Jäsen palauttaa kirjan.
* Kustantaja kustantaa kirjan.
* Kirjoittaja kirjoittaaa kirjan.

### **Vaihe 6 — Kardinaliteetin määrittäminen (1:1, 1:N, M:N)**

Täytä alla oleva taulukko.

| Suhde    | Kardinaliteetti | Perustelu (lyhyesti) |
| -----    | --------------- | -------------------- |
|Kirja     | Kirjasto        |Kirjastossa on paljon kirjoja  |
|Lainaus   | Toimipiste      |Lainataan paljon toimipisteellä|
|kirjailija| Kirja        |Kirjailija kirjoittaa kirjoja  |
|opiskelija| Koulu        |Opiskelijat opiskelee koulussa |
|Lehmä     | maito        |lehmät tuottavat maitoa        |

---

### **Vaihe 7 — Valinnainen vs. pakollinen osallistuminen**

Vastaa seuraaviin kysymyksiin:

1. **Pitääkö jokaisella kirjalla olla kustantaja?**

   * [X] Kyllä (pakollinen) [ ] Ei (valinnainen)
   * Miksi? Jokaisella kirjalla on täsmälleen yksi kustantaja

2. **Voiko kustantaja olla olemassa ilman yhtään kirjaa?**

   * [X] Kyllä [ ] Ei
   * Miksi? Kustantajalla voi olla monta kirjaa. Mutta ei mainita pitääkö kustantajalla olla kirjoja. 
   Joten kirjattomat kustantajat ovat mahdollisia

3. **Pitääkö jokaisella kirjalla olla vähintään yksi kirjoittaja?**

   * [X] Kyllä [ ] Ei
   * Miksi? kirjalla voi olla yksi tai useampi. joten kaikilla kirjoilla tulee olla ainakin yksi kirjoittaja

4. **Pitääkö jokaisen kirjan kopion kuulua johonkin toimipisteeseen?**

   * [X] Kyllä [ ] Ei
   * Miksi? Jokainen fyysinen kirjan kopio kuuluu täsmälleen yhteen toimipisteeseen.

5. **Onko palautuspäivä pakollinen vai valinnainen Lainauksessa?**

   * [ ] Pakollinen [X] Valinnainen
   * Miksi? Palautuspäivä voi olla tyhjä
  

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
![alt text](Näyttökuva 2026-01-26 191943.png)
```



### **Vaihe 9 — Lisää relaatiot**

Lisää nimetyt viivat entiteettien välille → selitä suhteet entiteettien välillä.



### **Vaihe 10 — Merkitse kardinaliteetti ja valinnaisuus**

Merkitse jokaiseen suhteeseen selvästi:

* 1, N tai M
* Pakollinen vs. valinnainen (jos käyttämäsi notaatiotapa tukee tätä)

---

## **Itsetarkistus (validointikysymykset)**

Tukeeko mallisi seuraavia tilanteita?

Merkitse ✔ tai ✘ ja selitä lyhyesti.

1. Voiko jäsen lainata useita kirjoja ajan myötä?

   * [X] Kyllä [ ] Ei
   * Miksi? Jäsen–Lainaus -suhde on 1:N, joten yhdellä jäsenellä voi olla useita lainauksia eri aikoina.

2. Voiko samaa kirjakappaletta lainata useita kertoja eri kuukausina?

   * [X] Kyllä [ ] Ei
   * Miksi? Kyllä kirjan ja kopion suhde on 1:N

3. Voiko kirjalla olla useita kirjoittajia?

   * [X] Kyllä [] Ei
   * Miksi? Kirja–Kirjailija -suhde on M:N, jolloin kirjalla voi olla useampi kirjoittaja ja kirjoittaja voi kirjoittaa useita kirjoja.

4. Voiko kirja olla olemassa ilman kustantajaa?

   * [X] Kyllä [] Ei
   * Miksi? Kyllä, koska Kirjan ja julkaisijan suhde on valinnainen

5. Voiko lainauksella olla tyhjä return_date?

   * [X] Kyllä [ ] Ei
   * Miksi? Koska Palautuspäivä on valinnainen atribuutti
