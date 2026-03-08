# Käyttäjien ja roolien hallinta ohjelmoinnissa

### Miten sovellukset käsittelevät todentamisen, valtuuttamisen ja tietokantapääsyn

Tämä materiaali jatkaa aihetta [Tietokannat ohjelmoinnissa](12-Tietokannat-ohjelmoinnissa.md) ja [Käyttäjät ja roolit](11-Kayttajat-ja-Roolit.md).

---

## 1) Kaksi "käyttäjä"- ja "rooli"-tasoa

### Sovelluskäyttäjät vs. tietokantakäyttäjät

Kaksi eri käsitettä on helppo sekoittaa keskenään:

| Käsite                         | Mikä se on                                                                                            | Missä se sijaitsee                                                       | Kuka sitä käyttää                    |
| ------------------------------ | ----------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------ | ------------------------------------ |
| **Sovelluskäyttäjät**          | Henkilöt (tai järjestelmät), jotka käyttävät sovellustasi — esim. Alice, Bob, "admin@yritys.fi"       | Sovelluksen `Users`-taulun (tai vastaavan) rivit                         | Sovelluskoodi kirjautumisen jälkeen  |
| **Tietokantakäyttäjät/roolit** | Identiteetit, joita käytetään **yhteyden muodostamiseen** tietokantaan (esim. `app_user`, `app_read`) | Tietokantajärjestelmän järjestelmäkatalogit (PostgreSQL `pg_roles` jne.) | Tietokantadraiveri, yhteysmerkkijono |

Useimmissa web-sovelluksissa:

- **Loppukäyttäjät** (Alice, Bob) tallennetaan `Users`-taulun riveiksi. He kirjautuvat sähköpostilla ja salasanalla. Sovellus tarkistaa tunnukset ja luo istunnon.
- **Sovellus** yhdistää tietokantaan **yhden tietokantakäyttäjän** tunnuksilla (esim. `app_user` tai `uni_write`). Kaikki kyselyt suoritetaan sillä identiteetillä. Alice ja Bob **eivät** saa omia tietokantakirjautumisiaan.

```
┌─────────────────────────────────────────────────────────────────┐
│  Alice (sovelluskäyttäjä) ──► kirjautuu ──► istunto / JWT        │
│  Bob (sovelluskäyttäjä)   ──► kirjautuu ──► istunto / JWT        │
└─────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────┐
│  Sovellus yhdistää tietokantaan tunnuksella: app_user (tietokantarooli) │
│  Kaikki kyselyt (Alicelle, Bobille jne.) suoritetaan app_userina │
└─────────────────────────────────────────────────────────────────┘
```

Tämän erottelun ymmärtäminen on oleellista sekä tietokantapääsyn että sovellusturvallisuuden suunnittelussa.

---

## 2) Miten sovellus yhdistää tietokantaan

### Yksi tietokantakäyttäjä: tyypillinen malli

Useimmat sovellukset käyttävät **yhtä tietokantakäyttäjää** kaikille operaatioille:

- Yhteysmerkkijono sisältää tunnukset tälle käyttäjälle (esim. `app_user` / `password`).
- Jokainen kysely — olipa kyseessä Alice, Bob tai nimettömän kävijän data — suoritetaan sillä käyttäjällä.
- Tietokanta myöntää tälle käyttäjälle tarvitsemansa oikeudet (esim. SELECT, INSERT, UPDATE, DELETE sovelluksen tauluilla). Katso [Materiaali 11](11-Users-and-Roles-FI.md) roolien ja oikeuksien määrittelyyn.

### Miksi ei yhtä tietokantakäyttäjää per sovelluskäyttäjä?

PostgreSQL-roolin luominen jokaiselle loppukäyttäjälle (Alice, Bob, …) olisi:

- Vaikea hallita suuressa mittakaavassa (tuhansia käyttäjiä)
- Ristiriidassa yhteyspoolingin kanssa (poolit olettavat vähän erillisiä identiteettejä)
- Vaativan dynaamisia yhteysmerkkijonoja, mikä monimutkaistaa turvallisuutta ja konfiguraatiota

Sen sijaan sovellus käyttää **yhtä** tietokanta-identiteettiä ja valvoo **kuka saa tehdä mitä** sovelluslogiikassa (esim. "näytä Alicelle vain hänen omat tilauksensa").

### Milloin useat tietokantakäyttäjät ovat järkeviä

Joskus käytetään eri tietokantakäyttäjiä **eri osissa järjestelmää**:

| Tilanne                                       | Esimerkki                                                                                                                         |
| --------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| **Vain luku -raportointi**                    | Raportointipalvelu yhdistää tunnuksella `app_read` (vain SELECT) vähentääkseen vahinkosädettä mahdollisen kompromission sattuessa |
| **Taustatehtävät**                            | Työntekijä voi käyttää `app_write`:tä tai rajoitettuine oikeuksineen omaa roolia                                                  |
| **Migraatiot / hallinta**                     | Skeeman muutokset ajetaan admin-roolina; sovellus ajetaan `app_user`-käyttäjänä                                                   |
| **Monivuokralainen rivitasoturvallisuudella** | Edistyneissä ratkaisuissa voidaan käyttää vuokralaista kohden rooleja; tämä on harvinaisempaa                                     |

Tyypillisissä CRUD-sovelluksissa yksi sovelluksen tietokantakäyttäjä on normi.

---

## 3) Sovelluskäyttäjien ja roolien tallentaminen

### Taulut käyttäjille ja rooleille

Sovelluskäyttäjät ja roolit tallennetaan yleensä **omiiin tauluihisi**, ei tietokantajärjestelmän järjestelmäkatalogeihin.

Minimaalinen suunnitelma:

- **Users** — `id`, `email`, `password_hash`, `name`, `created_at` jne.
- **Roles** — `id`, `name` (esim. `"Admin"`, `"User"`, `"Moderator"`)
- **UserRoles** — liitostaulu, joka yhdistää käyttäjät rooleihin (moni-moneen)

```
Users                    UserRoles                 Roles
┌────────────┬─────────┐  ┌──────────┬─────────┐  ┌────────┬──────────┐
│ id         │ email   │  │ user_id  │ role_id │  │ id     │ name     │
├────────────┼─────────┤  ├──────────┼─────────┤  ├────────┼──────────┤
│ 1          │ a@x.com │──│ 1        │ 2       │──│ 1      │ Admin    │
│ 2          │ b@x.com │  │ 1        │ 1       │  │ 2      │ User     │
└────────────┴─────────┘  │ 2        │ 1       │  └────────┴──────────┘
                          └──────────┴─────────┘
```

### Tärkeää: älä koskaan tallenna salasanoja selkotekstinä

Salasanat on **hashattava** (yksisuuntaisesti) ennen tallennusta. Älä koskaan tallenna salasanoja selkotekstinä.

- Käytä **salasanan hashausalgoritmia**, joka on suunniteltu tähän tarkoitukseen: bcrypt, Argon2 tai PBKDF2 suurella iterointimäärällä.
- Kirjautumishetkellä hashataan annettu salasana ja verrataan sitä tallennettuun hashiin. Jos ne täsmäävät, salasana on oikein.
- Älä käytä nopeita hasheja kuten MD5 tai SHA256 yksinään salasanoille; ne ovat liian nopeasti brute-force -hyökkäyksen kohteena.

Useimmat frameworkit tarjoavat valmiit apurit (esim. ASP.NET Core Identity käyttää turvallista oletusta).

---

## 4) Todentaminen ja valtuutus

### Todentaminen (Authentication): kuka olet?

**Todentaminen** vastaa: _"Keneltä tämä pyyntö on?"_

- Käyttäjä lähettää sähköpostin ja salasanan.
- Sovellus hakee käyttäjän, tarkistaa salasanan tallennettua hashiin vastaan.
- Jos kelvollinen, sovellus luo **istunnon** (eväste) tai **tokenin** (esim. JWT), joka tunnistaa käyttäjän seuraaville pyynnöille.
- Myöhemmät pyynnöt sisältävät istunnon/tokenin; sovellus tietää, kuka käyttäjä tekee pyynnön.

### Valtuutus (Authorization): mitä saat tehdä?

**Valtuutus** vastaa: _"Saa tämä käyttäjä tehdä tämän?"_

- Todentamisen jälkeen sovellus tarkistaa, onko käyttäjällä oikeus toimintoon.
- Yleinen lähestymistapa: **roolipohjainen pääsynhallinta (RBAC)**. Käyttäjällä on yksi tai useampi rooli; jokainen rooli merkitsee joukkoa käyttöoikeuksia.
- Esimerkki: vain `Admin`-roolin käyttäjät voivat käyttää `/admin/users` -polkua. Sovellus tarkistaa käyttäjän roolit ennen pääsyn sallimista.

### Työnkulku (Flow)

1. **Pyyntö** → sisältää istuntoevästettä tai JWT:tä.
2. **Todentaminen** → tunnista käyttäjä istunnosta/tokenista (tai palauta 401, jos virheellinen).
3. **Valtuutus** → tarkista, onko käyttäjällä vaadittu rooli/käyttöoikeus tälle päätepisteelle (tai palauta 403, jos ei).
4. **Liiketoimintalogiikka** → suorita toiminto (esim. lataa data, tee muutokset).

---

## 5) Roolipohjainen pääsynhallinta koodissa

### Roolien tarkistus sovelluslogiikassa

Kun tiedät nykyisen käyttäjän ja hänen roolinsa, valvot käyttöoikeuksia koodissa.

**Pseudokoodi (käsitteellinen):**

```
if (currentUser.Roles.Contains("Admin")) {
    // Salli pääsy hallintapaneeliin
} else {
    return Forbidden();
}
```

### .NET: ASP.NET Core Identity ja valtuutus

ASP.NET Core tarjoaa **Identityn** käyttäjä- ja roolitallennukseen sekä **valtuutuksen** käyttöoikeustarkistuksiin.

#### Identityn konfigurointi (käyttäjät ja roolit tietokannassa)

Identity tallentaa käyttäjät ja roolit luomiinsa tauluihin (esim. `AspNetUsers`, `AspNetRoles`, `AspNetUserRoles`). Konfiguroit sen käyttämään omaa tietokantaasi (esim. EF Coren kautta):

```csharp
// Program.cs
builder.Services.AddDefaultIdentity<IdentityUser>(options => { /* ... */ })
    .AddRoles<IdentityRole>()
    .AddEntityFrameworkStores<ApplicationDbContext>();
```

#### Roolipohjainen valtuutus

Käytä `[Authorize]`-attribuuttia roolien vaatimiseen:

```csharp
[Authorize(Roles = "Admin")]
public class AdminController : ControllerBase
{
    // Vain Admin-roolin käyttäjät pääsevät näihin toimintoihin
}

[Authorize(Roles = "Admin,Moderator")]
public IActionResult EditPost(int id)
{
    // Admin TAI Moderator
}
```

#### Käytäntöön perustuva valtuutus (joustavampi)

Monimutkaisille säännöille määritä käytännöt:

```csharp
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("RequireAdmin", policy => policy.RequireRole("Admin"));
    options.AddPolicy("CanEditPost", policy =>
        policy.RequireAssertion(context =>
            context.User.IsInRole("Admin") || context.User.IsInRole("Moderator")));
});
```

```csharp
[Authorize(Policy = "RequireAdmin")]
public IActionResult DeleteUser(int id) { /* ... */ }
```

### Muut ekosysteemit

| Alusta                | Yleinen lähestymistapa                                             |
| --------------------- | ------------------------------------------------------------------ |
| **Node.js / Express** | Passport.js + mukautettu middleware roolien tarkistukseen          |
| **Python / Django**   | Django auth (User, Group) + `@login_required`, `@user_passes_test` |
| **Python / Flask**    | Flask-Login + Flask-Principal tai mukautetut dekorointifunktiot    |
| **Java / Spring**     | Spring Security `@PreAuthorize`, `@Secured` -attribuuteilla        |

Malli on sama: todennus ensin, sitten roolien tai käyttöoikeuksien tarkistus ennen pääsyn sallimista.

---

## 6) Datan käyttö ja nykyinen käyttäjä

### Suodatus nykyisen käyttäjän mukaan

Usein käyttäjien on nähtävä tai muutettava vain **omia** tietojaan:

- Alice näkee vain omat tilauksensa.
- Opiskelija näkee vain omat ilmoittautumisensa.

Tätä valvotaan **kyselyssä**, ei vain päätepistetasolla:

```csharp
// Käsitteellinen: palauta vain kirjautuneen käyttäjän tilaukset
var userId = User.FindFirstValue(ClaimTypes.NameIdentifier); // tai vastaava
var orders = await context.Orders
    .Where(o => o.UserId == userId)
    .ToListAsync();
```

Jos unohdat tämän suodattimen, käyttäjä voi päästä toisen käyttäjän dataan muuttamalla pyyntöä (esim. `GET /orders?userId=123`). **Rajaa aina** kyselyt nykyiseen käyttäjään (tai resursseihin, joihin käyttäjällä on nimenomainen pääsy).

### Omistajuustarkistukset ennen päivityksiä

Ennen päivittämistä tai poistamista varmista, että nykyinen käyttäjä omistaa resurssin:

```csharp
var order = await context.Orders.FindAsync(orderId);
if (order == null) return NotFound();
if (order.UserId != currentUserId) return Forbidden();
// Jatka päivitystä
```

---

## 7) Identity-frameworkit ja ORM-integraatio

### Miksi käyttää identity-frameworkia?

Todentamisen ja valtuutuksen toteuttaminen tyhjästä on virhealtista. Frameworkit tarjoavat:

- Salasanan hashausta
- Istunnon/tokenin käsittelyä
- Roolien tallennusta ja hakutusta
- Suojauksen yleisiä hyökkäyksiä vastaan (CSRF, istunnon kiinnitys jne.)

### ASP.NET Core Identity EF Coren kanssa

Identity integroituu EF Coreen. `ApplicationDbContext` sisältää `DbSet<IdentityUser>`, `DbSet<IdentityRole>` jne. Migraatiot luovat ja päivittävät identity-taulut.

```csharp
public class ApplicationDbContext : IdentityDbContext<IdentityUser>
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options) { }

    public DbSet<Order> Orders { get; set; }
    // Identity lisää: Users, Roles, UserRoles jne.
}
```

Voit laajentaa käyttäjämallia (esim. lisätä `FullName`) luomalla mukautetun luokan, joka periytyy `IdentityUser`:sta ja käyttämällä sitä `IdentityUser`:n tilalla.

### Mukautetut käyttäjä-/roolitaulut ilman Identitytä

Jos et halua käyttää Identitytä, voit:

- Määritellä omat `User`-, `Role`- ja `UserRole`-entiteettisi.
- Toteuttaa salasanan hashausta (esim. `BCrypt.Net`:llä tai vastaavalla).
- Toteuttaa kirjautumisen ja istunnon käsittelyn itse.
- Käyttää samoja valtuutusattribuutteja (`[Authorize]`, käytännöt) mukautetun todentamiskäsittelijän kanssa, joka lataa käyttäjän ja roolit omista tauluistasi.

Tämä antaa täyden hallinnan mutta vaatii enemmän koodia ja huolellisuutta.

---

## 8) Turvallisuuden parhaat käytännöt

### Tunnukset ja konfiguraatio

- **Älä koskaan** kovakoodaa tietokantasalasanoja tai API-avaimia lähdekoodiin.
- Käytä **ympäristömuuttujia** tai turvallista konfiguraatiotallennusta (esim. Azure Key Vault, AWS Secrets Manager).
- Rajoita pääsy tuotantotunnuksiin.

### Tietokantakäyttäjä: vähimmäisoikeudet

- Sovelluksen tietokantakäyttäjän pitää olla **vain** tarvitsemansa oikeudet.
- Suosittele vain luku -yhteyksiä raportointiin tai luku painoisiin palveluihin.
- Vältä `SUPERUSER`- tai skeeman muutosoikeuksia tavalliselle sovelluskäyttäjälle. Katso [Materiaali 11](11-Users-and-Roles-FI.md) roolisuunnittelusta.

### Sovelluskäyttäjät: puolustus syvyydessä

- **Todentaminen** — vahva salasanapolitiikka, valinnainen MFA.
- **Valtuutus** — tarkista roolit/käyttöoikeudet jokaisella suojatulla päätepisteellä.
- **Datan käyttö** — suodata aina `UserId`:n tai vastaavan mukaan kun palautat käyttäjäkohtaista dataa.
- **Tarkastus** — kirjaa arkaluonteiset toiminnat (kirjautuminen, roolimuutokset, data-eksportit) debuggausta ja vaatimustenmukaisuutta varten.

### Yleisiä sudenkuoppia

| Sudenkuoppa                                         | Turvallisempi lähestymistapa                                                         |
| --------------------------------------------------- | ------------------------------------------------------------------------------------ |
| Luottaa asiakkaalta saataviin käyttäjätunnuksiin    | Johda nykyinen käyttäjä istunnosta/tokenista; älä koskaan kyselyparametreista        |
| Valtuutuksen ohittaminen "sisäisissä" API:issa      | Jokaisen datan palauttavan tai muuttavan päätepisteen pitää tarkistaa käyttöoikeudet |
| Selkotekstisalanojen tallentaminen                  | Käytä asianmukaista salasanan hashauskirjastoa                                       |
| Liian runsaasti oikeuksia omaava tietokantakäyttäjä | Luo erillinen rooli minimaalisilla oikeuksilla                                       |

---

## 9) Yhteenveto

| Aihe                                          | Keskeinen ajatus                                                                                                    |
| --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| **Sovelluskäyttäjät vs. tietokantakäyttäjät** | Sovelluskäyttäjät (Alice, Bob) ovat tauluissasi; sovellus yhdistää tietokantaan yhtenä tietokantakäyttäjänä         |
| **Yhteyden malli**                            | Tyypillisesti yksi tietokantakäyttäjä; useita tietokantakäyttäjiä eri palveluille (esim. vain luku) tarvittaessa    |
| **Käyttäjän ja roolin tallennus**             | Tallenna käyttäjät ja roolit omiin tauluihisi (tai käytä Identitytä); älä koskaan tallenna salasanoja selkotekstinä |
| **Todentaminen**                              | Varmista identiteetti (esim. sähköposti/salasana); luo istunto tai token                                            |
| **Valtuutus**                                 | Tarkista roolit/käyttöoikeudet ennen pääsyn sallimista; käytä `[Authorize]`, käytäntöjä tai vastaavaa               |
| **Datan rajaus**                              | Suodata kyselyt nykyisen käyttäjän mukaan; varmista omistajuus ennen päivityksiä/poistoja                           |
| **Identity-frameworkit**                      | Käytä ASP.NET Core Identitytä (tai vastaavaa) välttääksesi todentamisen uudelleenkeksimisen                         |
| **Turvallisuus**                              | Vähimmäisoikeudet tietokantakäyttäjälle; ei kovakoodattuja salaisuuksia; puolustus syvyydessä                       |

---

## Liittyvät materiaalit

- [11 – Käyttäjät ja roolit](11-Users-and-Roles-FI.md) — Tietokantatason roolit, oikeudet, GRANT/REVOKE PostgreSQLissä
- [12 – Tietokannat ohjelmoinnissa](12-Databases-in-Programming-FI.md) — Tietokantojen tarkoitus ohjelmoinnissa, yhteyden mallit
- [13 – Entity Framework Core](13-Entity-Framework-Core-FI.md) — ORM .NETille, mukaan lukien Identity-integraatio
