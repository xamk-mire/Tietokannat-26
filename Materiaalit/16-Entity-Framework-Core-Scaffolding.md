## Entity Framework Core -skaffoldaus (scaffolding): Johdanto

### `DbContext`-luokan (DbContext) ja entiteettien (entities) generointi olemassa olevasta tietokannasta

Tämä materiaali on jatkoa tiedostoille `13-Entity-Framework-Core.md` ja `15-Entity-Framework-Core-Migrations.md`. Se keskittyy **skaffoldaukseen (scaffolding)** – prosessiin, jossa EF Core lukee olemassa olevan tietokannan skeeman (database schema) ja generoi:

- `DbContext`-luokan (DbContext class)
- C#-entiteettiluokat (entity classes), jotka kuvaavat tauluja (tables) ja näkymiä (views)

Tätä lähestymistapaa kutsutaan usein nimillä **tietokanta ensin (database-first)** tai **käänteismallinnus (reverse engineering)**. Se on hyödyllinen, kun:

- Tietokanta on jo olemassa (legacy system tai jaettu yritystietokanta (shared corporate database)).
- Haluat **aloittaa olemassa olevasta skeemasta (existing schema)** sen sijaan, että suunnittelisit mallin (model) ensin C#:ssa.
- Tietokantaa hallinnoi toinen tiimi ja sinun tehtäväsi on rakentaa sovellus, joka käyttää sitä.

---

## 1) Koodi ensin (code-first) vs tietokanta ensin (database-first) vs hybridi (hybrid)

EF Core tukee kolmea yleistä lähestymistapaa:

- **Koodi ensin (code-first)**:
  - Suunnittelet mallin (model) C#:ssa (entiteetit (entities), suhteet (relationships), konfiguraatiot (configurations)).
  - EF Core käyttää migraatioita (migrations) tietokannan skeeman (database schema) luomiseen ja kehittämiseen.

- **Tietokanta ensin (database-first) (skaffoldaus (scaffolding))**:
  - Tietokannan skeema (database schema) on jo olemassa.
  - EF Core lukee skeeman ja generoi sitä vastaavan C#-koodin.

- **Hybridi (hybrid)**:
  - Voit skaffolda (scaffold) kerran tietokannasta.
  - Tämän jälkeen jatkat mallin kehittämistä koodi ensin (code-first) -tyylillä ja migraatioilla (migrations).

Tämä materiaali keskittyy **tietokanta ensin (database-first)** -skaffoldaukseen (scaffolding), mutta halutessasi voit myöhemmin yhdistää siihen koodi ensin (code-first) -tekniikoita.

---

## 2) Mitä skaffoldaus (scaffolding) tekee (ja mitä se ei tee)

### Mitä skaffoldaus (scaffolding) tekee

Kun ajat skaffaldauskomennon (scaffolding command), EF Core:

- Yhdistää olemassa olevaan tietokantaan (connection string + provider (provider)).
- Lukee:
  - Taulut (tables)
  - Näkymät (views)
  - Perusavaimet (primary keys) ja vierasavaimet (foreign keys)
  - Saraketyypit (column types) ja nollakelpoisuuden (nullability)
  - Indeksit (indexes) ja rajoitteet (constraints)
- Generoi:
  - `DbContext`-luokan, jossa on `DbSet<T>`-ominaisuudet (properties) tauluille/näkymille.
  - Entiteettiluokat (entity classes), joissa on ominaisuudet (properties) ja navigaatio-ominaisuudet (navigation properties).
  - Konfiguraation (configuration) (Fluent API:n (Fluent API) tai attribuuttien (attributes) avulla riippuen providerista (provider) ja valinnoista (options)).

### Mitä skaffoldaus (scaffolding) _ei_ tee

Skaffoldaus (scaffolding) ei:

- Pidä mallia (model) ja tietokantaa automaattisesti synkassa alkuperäisen generoinnin (initial generation) jälkeen.
- Säilytä omaa liiketoimintalogiikkaasi (custom business logic) tai annotaatioita (annotations), jos skaffoldaat (re-scaffold) huolimattomasti.
- Korjaa tietokannan suunnitteluongelmia (database design issues) (esim. puuttuvat avaimet (missing keys), epäjohdonmukaiset tyypit (inconsistent types)).

Sinun kehittäjänä (developer) täytyy:

- Päättää **kuinka usein skaffoldaat uudelleen (how often to re-scaffold)** (jos tietokanta muuttuu).
- Suojata tai tehdä uudelleen omat manuaaliset muutokset (manual changes) koodin regeneroinnin (regenerating) yhteydessä.

---

## 3) Skaffoldauksen (scaffolding) esivaatimukset (prerequisites)

Ennen skaffoldausta tarvitset:

- **.NET-projektin (.NET project)** (konsolisovellus (console app), web API jne.), johon generoitu koodi sijoitetaan.
- **EF Core 10** ja tietokantatoimittajan (provider) paketin (package) asennettuna, esimerkiksi:

PostgreSQL:

```bash
dotnet add package Npgsql.EntityFrameworkCore.PostgreSQL
dotnet add package Microsoft.EntityFrameworkCore.Design
```

SQL Server:

```bash
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.EntityFrameworkCore.Design
```

SQLite:

```bash
dotnet add package Microsoft.EntityFrameworkCore.Sqlite
dotnet add package Microsoft.EntityFrameworkCore.Design
```

Ja EF Core -työkalut (tools):

```bash
dotnet tool install --global dotnet-ef
```

> **Huom:** Aja `dotnet ef` -komennot hakemistosta, jossa `.csproj` sijaitsee, tai määritä `--project`.

Tarvitset myös:

- Pääsyn tietokantapalvelimeen (database server).
- Yhteysmerkkijonon (connection string) siihen tietokantaan, jonka haluat käänteismallintaa (reverse engineer).

---

## 4) Perusskaffaldauskomento (basic scaffolding command)

Ydinkomento on:

```bash
dotnet ef dbcontext scaffold "<CONNECTION_STRING>" <PROVIDER>
```

Esimerkkejä:

- PostgreSQL:

```bash
dotnet ef dbcontext scaffold "Host=localhost;Database=university;Username=app;Password=secret" Npgsql.EntityFrameworkCore.PostgreSQL
```

- SQL Server:

```bash
dotnet ef dbcontext scaffold "Server=localhost;Database=University;Trusted_Connection=True;TrustServerCertificate=True" Microsoft.EntityFrameworkCore.SqlServer
```

- SQLite:

```bash
dotnet ef dbcontext scaffold "Data Source=university.db" Microsoft.EntityFrameworkCore.Sqlite
```

Kun tämän ajaa, EF Core:

- Generoi `DbContext`-luokan (oletuksena tietokannan mukaan nimetty, esim. `UniversityContext`).
- Generoi entiteettiluokat (entity classes) kaikille tauluille, jotka se löytää.

---

## 5) Hyödyllisiä valintoja (options) skaffoldaukseen (scaffolding)

Skaffoldauskomennolla (scaffolding command) on paljon valintoja (options). Yleisiä:

### Tulostehakemistot (output directories)

Erota konteksti (context) ja entiteetit (entities):

```bash
dotnet ef dbcontext scaffold "<CONNECTION_STRING>" Npgsql.EntityFrameworkCore.PostgreSQL \
  --context-dir Data \
  --output-dir Models
```

Tämä:

- Laittaa `DbContext`-luokan `Data`-hakemistoon.
- Laittaa entiteettiluokat (entity classes) `Models`-hakemistoon.

### Rajaa tiettyihin tauluihin (limit to certain tables)

Jos tarvitset vain osan tauluista:

```bash
dotnet ef dbcontext scaffold "<CONNECTION_STRING>" Npgsql.EntityFrameworkCore.PostgreSQL \
  --table Students \
  --table Courses \
  --output-dir Models
```

Voit määrittää useita `--table`-valitsimia.

### Data-annotaatiot (data annotations) vs Fluent API

Oletuksena EF Core käyttää Fluent API:a `OnModelCreating`-metodissa. Jos haluat käyttää data-annotaatioita (data annotations) aina kun mahdollista:

```bash
dotnet ef dbcontext scaffold "<CONNECTION_STRING>" Npgsql.EntityFrameworkCore.PostgreSQL \
  --data-annotations
```

### Nimiavaruus (namespace) ja kontekstin (context) nimi

Määritä oma `DbContext`-nimi:

```bash
dotnet ef dbcontext scaffold "<CONNECTION_STRING>" Npgsql.EntityFrameworkCore.PostgreSQL \
  --context UniversityDbContext
```

Tai oma juurinimiavaruus (root namespace), jos automaattinen ei ole sopiva:

```bash
dotnet ef dbcontext scaffold "<CONNECTION_STRING>" Npgsql.EntityFrameworkCore.PostgreSQL \
  --namespace UniversityApp.Data
```

> Täyden listan valinnoista (options): aja `dotnet ef dbcontext scaffold --help`.

---

## 6) Generoitu `DbContext` ja entiteetit (entities)

Skaffoldauksen jälkeen näet tyypillisesti:

- `DbContext`-luokan esimerkiksi:

```csharp
public partial class UniversityDbContext : DbContext
{
    public UniversityDbContext()
    {
    }

    public UniversityDbContext(DbContextOptions<UniversityDbContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Student> Students { get; set; } = null!;
    public virtual DbSet<Course> Courses { get; set; } = null!;

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        if (!optionsBuilder.IsConfigured)
        {
            // Connection string configuration (often removed and moved to appsettings)
        }
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Fluent configuration generated from database schema
    }
}
```

- Entiteettiluokat (entity classes), joiden ominaisuudet (properties) mappautuvat sarakkeisiin (columns), esim.:

```csharp
public partial class Student
{
    public int Id { get; set; }
    public string FullName { get; set; } = null!;
    public string? Email { get; set; }

    public virtual ICollection<Enrollment> Enrollments { get; set; } = new List<Enrollment>();
}
```

> **Huom:** Generoidut luokat ovat usein `partial`, jotta voit laajentaa niitä erillisissä tiedostoissa menettämättä muutoksia, kun skaffoldaat uudelleen (re-scaffold).

---

## 7) Generoidun koodin siistiminen (cleaning up)

Heti skaffoldauksen jälkeen on tavallista:

- **Siirtää yhteysmerkkijono (connection string)** pois `OnConfiguring`-metodista ja konfiguraatioon (configuration) (`appsettings.json`, ympäristömuuttujat (environment variables)).
- **Integroi `DbContext` riippuvuuksien injektointiin (dependency injection)**, esim. ASP.NET Coressa:

```csharp
builder.Services.AddDbContext<UniversityDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));
```

- **Tarkistaa nimeäminen (naming)**:
  - Luokkien nimet (class names)
  - Ominaisuuksien nimet (property names) (esim. `full_name` → `FullName`)
  - Navigaatio-ominaisuudet (navigation properties) (esim. `Enrollments`-kokoelma (collection))

- **Päättää, mihin oma logiikka (custom logic) sijoitetaan**:
  - Lisää liiketoimintalogiikka (business logic) **partial-luokkiin (partial classes) tai erillisiin tiedostoihin (separate files)**.
  - Vältä generoidun tiedoston suoraa muokkaamista, jos aiot skaffoldata uudelleen (re-scaffold).

---

## 8) Uudelleenskaffoldaus (re-scaffolding), kun tietokanta muuttuu

Tietokanta ensin (database-first) -työnkulussa (workflow) skeema (database schema) voi muuttua ajan myötä (esim. DBA lisää uuden taulun tai sarakkeen). Tällöin saatat:

- Ajaa skaffolduksen (scaffolding) uudelleen päivittääksesi mallin (model).

Tämä voi kuitenkin ylikirjoittaa generoituja tiedostoja. Jotta et menetä manuaalisia muutoksia (manual changes):

- Suosi:
  - Erillisiä partial-luokkia (partial classes) lisäominaisuuksille ja metodeille (methods).
  - Erillisiä konfiguraatioluokkia (configuration classes) `(IEntityTypeConfiguration<T>)` omaa konfigurointia (custom configuration) varten.
- Uudelleenskaffoldauksessa (re-scaffolding) harkitse:
  - `--force`-valitsimen käyttöä vain, kun ymmärrät mitä ylikirjoitetaan.
  - Nykyisen koodin committaamista versionhallintaan (source control), jotta näet diffin ja voit palauttaa tarvittaessa.

Esimerkkikomento ylikirjoituksella (overwrite):

```bash
dotnet ef dbcontext scaffold "<CONNECTION_STRING>" Npgsql.EntityFrameworkCore.PostgreSQL \
  --output-dir Models \
  --context-dir Data \
  --context UniversityDbContext \
  --force
```

> **Vinkki:** Uudelleenskaffoldaus (re-scaffolding) on helpompaa, kun pidät oman koodin erillisissä partialeissa (partials) tai erillisissä kerroksissa (layers) (esim. DTO:t (DTOs), palvelut (services)).

---

## 9) Skaffoldaus (scaffolding) + migraatiot (migrations) (hybridilähestymistapa (hybrid approach))

Sinun ei tarvitse pysyä ikuisesti pelkässä tietokanta ensin (database-first) -mallissa. Yleinen **hybridi (hybrid)** -työnkulku:

1. **Aloita skaffoldauksella (start with scaffolding)** olemassa olevasta tietokannasta:
   - Saat nopeasti toimivan `DbContext`-luokan ja entiteetit (entities).
2. **Ota migraatiot (migrations) käyttöön**:
   - Kun EF Core “omistaa” mallin (model), teet muutokset koodissa ja käytät `dotnet ef migrations add` ja `dotnet ef database update`.
3. **Sovi käytännöt DBA:iden kanssa (coordinate with DBAs)**:
   - Määritä prosessi skeemamuutoksille (schema changes) (kuka muuttaa mitä ja mihin suuntaan).

Keskeinen ajatus:

- Skaffoldaus (scaffolding) on **lähtöpiste (starting point)** EF Core -malleille (models), kun tietokanta on jo olemassa.
- Migraatiot (migrations) ovat **jatkuva evoluutiotyökalu (continuous evolution tool)**, kun malli (model) on koodissa.

---

## 10) Parhaat käytännöt (best practices) ja yleiset sudenkuopat (common pitfalls)

### Parhaat käytännöt

- **Käytä partial-luokkia (partial classes)**  
  Laajenna generoituja entiteettejä (entities) partialeilla, jotta uudelleenskaffoldaus (re-scaffolding) ei tuhoa omaa koodiasi.

- **Siirrä konfiguraatio (configuration) startupiin**  
  Älä pidä oikeita yhteysmerkkijonoja (connection strings) generoidussa `OnConfiguring`-metodissa. Käytä konfiguraatiotiedostoja ja DI:tä (dependency injection) sen sijaan.

- **Generoi omiin hakemistoihin (dedicated folders)**  
  Käytä `--output-dir` ja `--context-dir` niin, että generoitu koodi erotetaan selvästi käsin kirjoitetusta koodista.

- **Ole eksplisiittinen tauluista (be explicit about tables)**  
  Jos tietokanta on suuri, skaffoldaa vain tarvitut taulut (tables) `--table`-valitsimella.

- **Versionoi kaikki (version control everything)**  
  Commitoi skaffolduksen muutokset, jotta voit katselmoida (review) diffit ja perua virheet.

### Yleiset sudenkuopat

- **Muokkaat generoituja tiedostoja ja sitten skaffoldaat uudelleen `--force`:lla**  
  Tämä voi poistaa muutoksesi hiljaisesti. Käytä partialeja (partial classes) ja erillisiä tiedostoja omalle logiikalle.

- **Unohdat provider-kohtaisen käyttäytymisen (provider-specific behavior)**  
  Eri tietokannat (PostgreSQL, SQL Server, SQLite) mappaavat tyyppejä eri tavoin; tarkista aina generoitu tyypitys (types) ja konfiguraatio (configuration).

- **Yhteysmerkkijonojen vuotaminen (leaking connection strings)**  
  Vältä tunnusten (credentials) kovakoodausta; käytä turvallista konfiguraatiota (secure configuration).

- **Iso skeema → paljon koodia (big schemas → lots of code)**  
  Suuren tietokannan skaffoldaus voi generoida satoja luokkia; harkitse rajauksia (limit to needed tables).

---

## 11) Yhteenveto (summary)

EF Core -skaffoldaus (scaffolding) on tärkein työkalu olemassa olevan tietokannan **käänteismallintamiseen (reverse engineering)** EF Core -malliksi:

- **`dotnet ef dbcontext scaffold`** yhdistää tietokantaan ja generoi `DbContext`-luokan sekä entiteetit (entities).
- Voit hallita, mitkä taulut (tables), nimiavaruudet (namespaces) ja tulostehakemistot (output directories) käytetään.
- Generoitu koodi on **lähtöpiste (starting point)**, joka kannattaa tarkistaa, siistiä ja integroida sovelluksen arkkitehtuuriin (architecture).
- Partial-luokkien (partial classes), DI:n (dependency injection) ja varovaisen uudelleenskaffoldauksen (re-scaffolding) avulla voit ylläpitää turvallisesti tietokanta ensin (database-first) - tai hybridityönkulkua (hybrid workflow).

Skaffoldaus (scaffolding) antaa sinulle EF Coren hyödyt myös silloin, kun tietokantaa ei ole alun perin suunniteltu EF Core mielessä.

