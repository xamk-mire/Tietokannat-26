## Entity Framework Core -migraatiot (migrations): Johdanto

### Tietokannan skeeman (database schema) versiointi koodina

Tämä materiaali on jatkoa tiedostolle `13-Entity-Framework-Core.md`. Se keskittyy vain **EF Coren migraatioihin (migrations)** – mekanismiin, jolla EF Core **luo ja kehittää** tietokannan skeemaa (database schema) C#-entiteettiluokkiesi (entity classes) perusteella.

Tavoitteena on oppia, miten:

- **Alustat (initialize)** tietokannan mallistasi (model)
- **Seuraat skeemamuutoksia (schema changes) ajan kuluessa** versioituina migraatiotiedostoina (migration files)
- **Sovellat ja peruutat (apply and roll back)** skeemamuutoksia (schema changes) eri ympäristöissä (development, test, production)
- **Vältät yleisiä sudenkuoppia (common pitfalls)** muokatessasi entiteettejä (entities) ja ajaessasi migraatioita (migrations)

---

## 1) Mitä migraatiot (migrations) ovat ja miksi niitä käytetään?

### Ongelma: skeeman (schema) ja koodin synkassa pitäminen

Tyypillisessä projektissa:

- **C#-malli (C# model)** (entiteetit (entities), `DbContext`, konfiguraatiot (configurations)) kehittyy, kun lisäät ominaisuuksia (features).
- **Tietokannan skeeman (database schema)** (taulut (tables), sarakkeet (columns), indeksit (indexes), rajoitteet (constraints)) täytyy kehittyä samassa tahdissa.

Jos muutokset tehdään manuaalisesti tietokantaan (esim. ajamalla ad-hoc SQL:ää GUI-työkalussa), menetät nopeasti näkyvyyden siihen:

- Mitä muutoksia tehtiin
- Missä järjestyksessä
- Mihin ympäristöön (environment)

Tämä tekee vaikeaksi:

- Perehdyttää uusia kehittäjiä (onboard new developers)
- Luoda tietokanta alusta alkaen uudelleen (recreate a database from scratch)
- Peruuttaa epäonnistunut käyttöönotto (roll back a broken deployment)

### Ratkaisu: skeema (schema) koodina

**EF Coren migraatiot (migrations)** käsittelevät skeemaa (schema) **versioituna koodina (versioned code)**:

- Jokainen migraatio (migration) on **pieni, järjestetty askel** (small, ordered step) (esim. “AddStudentsTable”, “AddEnrollmentCourseRelation”).
- Migraatiot (migrations) elävät **versionhallinnassa (source control)** sovelluskoodisi rinnalla.
- EF Core pitää tietokannassa **historiataulun (history table)**, jonka avulla se tietää, mitkä migraatiot (migrations) on jo ajettu.

Hyödyt:

- **Toistettavuus (repeatability)**: Voit luoda tietokannan alusta ajamalla kaikki migraatiot (migrations) uudelleen.
- **Jäljitettävyys (traceability)**: Näet tarkasti, mitä muutoksia tapahtui ja milloin.
- **Tiimiyhteistyö (team-friendly)**: Useat kehittäjät voivat tehdä yhteistyötä skeeman (schema) kehittämisessä.

---

## 2) Esivaatimukset (prerequisites) ja asennus (setup)

Ennen migraatioiden (migrations) käyttämistä varmista, että sinulla on:

- **EF Core 10** -paketit (packages) ja tietokantatoimittaja (provider) asennettuna projektiin (katso `13-Entity-Framework-Core.md`).
- **EF Core -työkalut (tools)** asennettuna:

```bash
dotnet tool install --global dotnet-ef
# or update
dotnet tool update --global dotnet-ef
```

Kun projektisi kohdistaa useaan kehykseen (targets multiple frameworks) (esim. `net8.0` ja `net10.0`), määritä käytettävä kehys (framework) työkalukomennoissa:

```bash
dotnet ef migrations add InitialCreate --framework net10.0
```

> **Huom:** Kaikki `dotnet ef` -komennot tulee ajaa **projektihakemistosta (project directory)**, jossa `.csproj` sijaitsee (tai määritä `--project`).

---

## 3) Ensimmäinen migraatio (migration): InitialCreate

Oletetaan, että sinulla on:

- `DbContext` (esim. `UniversityDbContext`)
- Joitakin entiteettejä (entities) (esim. `Student`, `Course`, `Enrollment`)

### Vaihe 1: Lisää alkuperäinen migraatio (initial migration)

Projektihakemistossa:

```bash
dotnet ef migrations add InitialCreate
```

Tämä komento:

- Tarkistaa nykyisen mallin (model) (entiteetit (entities) + konfiguraatio (configuration)).
- Vertaa sitä **tyhjään (empty)** tietokantaan.
- Luo migraatiotiedoston (migration file) (oletuksena hakemistoon `Migrations/`).

Tyypillinen sisältö (yksinkertaistettu):

```csharp
public partial class InitialCreate : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        // Create tables, columns, constraints
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        // Reverse actions from Up (drop tables, etc.)
    }
}
```

### Vaihe 2: Luo tietokanta (create the database)

Sovella migraatio (apply the migration) tietokantaan:

```bash
dotnet ef database update
```

Tämä:

- Ajaa kaikkien **odottavien (pending)** migraatioiden (migrations) `Up`-metodit järjestyksessä.
- Luo EF Coren migraatiohistorian (migrations history) taulun (oletuksena `__EFMigrationsHistory`).

Jos tietokantaa ei vielä ole, EF Core luo sen.

---

## 4) Miten EF Core seuraa skeeman (schema) versioita

EF Core tallentaa migraatiotiedon (migration information) kahteen paikkaan:

- **Koodiin (code)**: migraatioluokat (migration classes) hakemistossa `Migrations/`
- **Tietokantaan (database)**: `__EFMigrationsHistory`-tauluun (table)

Jokainen rivi (row) `__EFMigrationsHistory`-taulussa sisältää:

- **Migraatio-ID:n (migration ID)** (esim. `20260316120000_InitialCreate`)
- **Tuoteversion (product version)** (esim. `10.0.0`)

Kun ajat:

```bash
dotnet ef database update
```

EF Core:

1. Lukee kaikki projektin migraatioluokat (migration classes).
2. Tarkistaa, mitkä niistä on jo merkitty `__EFMigrationsHistory`-tauluun.
3. Soveltaa (applies) vain **puuttuvat (missing)** migraatiot (migrations) järjestyksessä.

---

## 5) Tyypillinen migraatiotyönkulku (migration workflow) kehityksessä (development)

Kun muokkaat malliasi (model), seuraa tätä mallia.

### Vaihe 1: Muuta mallia (change the model)

Esimerkkejä:

- Lisää ominaisuus (property) entiteettiin (entity):

```csharp
public class Student
{
    public int Id { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string? Email { get; set; }
    public DateTime EnrolledAt { get; set; }  // new property
}
```

- Lisää uusi entiteetti (new entity):

```csharp
public class Teacher
{
    public int Id { get; set; }
    public string FullName { get; set; } = string.Empty;
}
```

### Vaihe 2: Lisää migraatio (add a migration)

Käytä **kuvaavaa nimeä (descriptive name)**:

```bash
dotnet ef migrations add AddStudentEnrolledAt
dotnet ef migrations add AddTeacherEntity
```

Tämä luo uudet migraatiotiedostot (migration files), jotka kuvaavat muutokset:

- Sarakkeen (column) lisääminen (`EnrolledAt`) tauluun `Students`
- Uuden taulun (table) luominen (`Teachers`)

### Vaihe 3: Tarkista migraatio (review the migration)

Avaa luotu migraatioluokka (migration class) ja tarkista:

- Ovatko taulu- ja sarakenimet (table/column names) odotetut?
- Onko nollakelpoisuus (nullability) ja oletusarvot (default values) oikein?
- Onko vierasavaimet (foreign keys) ja indeksit (indexes) konfiguroitu oikein?

Voit muokata migraatiota (edit the migration) tarvittaessa (erityisesti data-korjauksia (data fixes) varten).

### Vaihe 4: Sovella migraatio (apply the migration)

Päivitä paikallinen tietokanta (local database):

```bash
dotnet ef database update
```

Nyt sekä:

- **Malli (model)** että
- **Tietokannan skeema (database schema)**

ovat synkassa uudessa versiossa.

---

## 6) Yleisiä `dotnet ef` -komentoja migraatioille (migrations)

### Lisää migraatio (add a migration)

```bash
dotnet ef migrations add MigrationName
```

Valitsimia (options):

- `--project` – projekti, joka sisältää `DbContext`-luokan
- `--startup-project` – projekti, jossa on sovelluksen käynnistys (app entry point) (esim. web API)
- `--context` – valitse tietty `DbContext`, jos niitä on useita
- `--output-dir` – migraatiohakemisto (oletus `Migrations`)

### Sovella migraatiot (apply migrations) (päivitä tietokanta)

```bash
dotnet ef database update
```

Voit myös määrittää kohdemigraation (target migration):

```bash
dotnet ef database update 20260316120000_InitialCreate
dotnet ef database update InitialCreate
dotnet ef database update 0      # Revert all migrations (drop everything created by migrations)
```

### Listaa migraatiot (list migrations)

```bash
dotnet ef migrations list
```

Näyttää:

- Sovelletut migraatiot (applied migrations)
- Odottavat migraatiot (pending migrations) (ei vielä ajettu tietokantaan)

### Poista viimeisin migraatio (remove the last migration) (vain kehityksessä)

Jos lisäsit migraation, mutta **et ole** vielä soveltanut sitä mihinkään jaettuun tietokantaan (shared database):

```bash
dotnet ef migrations remove
```

Tämä poistaa viimeisimmän migraatiotiedoston (migration file) ja päivittää mallin tilannekuvan (model snapshot). Käytä tätä, jos haluat korjata kirjoitusvirheen tai muun pienen virheen ennen committia.

---

## 7) Palautus (rolling back) ja kohdennetut päivitykset (targeted updates)

Joskus sinun täytyy:

- Palata aiempaan skeemaversioon (roll back to an earlier schema version)
- Soveltaa migraatioita vaiheittain (apply migrations step by step)

### Palauta aiempaan migraatioon (roll back to a previous migration)

Siirtääksesi tietokannan skeeman (database schema) **taaksepäin (back)** tiettyyn migraatioon:

```bash
dotnet ef database update PreviousMigrationName
```

EF Core:

- Selvittää, mitkä migraatiot (migrations) ovat kohdemigraation **jälkeen (after)**  
- Ajaa niiden `Down`-metodit käänteisessä järjestyksessä (reverse order)

> **Varoitus:** Migraatioiden palautus (rolling back) voi tuhota dataa (esim. taulujen tai sarakkeiden pudottaminen (dropping tables/columns)). Käytä varoen ja tyypillisesti vain kehitys- (development) tai test-ympäristöissä (test).

### Migraatioiden soveltaminen vaiheittain

Voit määrittää minkä tahansa migraation kohteeksi (target). EF Core:

- Ajaa puuttuvat `Up`-metodit edetäkseen **eteenpäin (forward)**, tai
- Ajaa `Down`-metodit palatakseen **taaksepäin (backward)**

Tämä on hyödyllistä manuaalisissa käyttöönotossa (deployment), joissa haluat eksplisiittisen kontrollin skeemamuutoksiin (schema changes).

---

## 8) Datan alustus (seeding data) migraatioilla (migrations)

Joskus tarvitset **siemendataa (seed data)**: alkuarvoja (initial records), joita sovellus tarvitsee toimiakseen (esim. oletusroolit (default roles), ylläpitäjä (admin user), testidata (test data)).

### Mallipohjainen alustus (model-based seeding) `OnModelCreating`-metodilla

Yksi tapa on käyttää `HasData`-metodia `OnModelCreating`-metodissa. Tällöin EF Core generoi lisäys-/päivityslauseet (insert/update statements) migraatioiden (migrations) sisälle automaattisesti.

Esimerkki:

```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    modelBuilder.Entity<Course>().HasData(
        new Course { Id = 1, Title = "Intro to Databases", Credits = 5 },
        new Course { Id = 2, Title = "Advanced SQL", Credits = 5 }
    );
}
```

Kun lisäät migraation tämän muutoksen jälkeen, migraatio sisältää sopivat `InsertData`-kutsut.

### Räätälöidyt dataoperaatiot (custom data operations) migraatioissa

Voit myös kirjoittaa omia datamuutoksia suoraan migraatioon:

```csharp
protected override void Up(MigrationBuilder migrationBuilder)
{
    migrationBuilder.Sql(
        "UPDATE Students SET EnrolledAt = CURRENT_TIMESTAMP WHERE EnrolledAt IS NULL");
}
```

Käytä tätä harkiten:

- Pidä logiikka yksinkertaisena ja deterministisenä (deterministic).
- Vältä monimutkaista sovelluslogiikkaa (application logic) migraatioissa.

---

## 9) Parhaat käytännöt (best practices) ja yleiset sudenkuopat (common pitfalls)

### Parhaat käytännöt

- **Yksi ominaisuus (feature) = yksi migraatio (migration) (tai muutama)**  
  Pidä migraatiot pieninä ja fokusoituna. Tämä helpottaa tarkistamista (review) ja vianetsintää (debug).

- **Luo migraatiot aina puhtaasta tilasta (clean state)**  
  Varmista, että koodi kääntyy (compiles) ja malli (model) on johdonmukainen ennen migraation lisäämistä.

- **Tarkista generoidut migraatiot (generated migrations)**  
  Älä luota sokeasti generoituihin skripteihin (scripts), erityisesti kun pudotetaan (dropping) tai nimetään uudelleen sarakkeita (renaming columns).

- **Aja migraatiot paikallisesti ennen pushia**  
  Varmista, että `dotnet ef database update` onnistuu omalla koneellasi.

- **Käytä eksplisiittisiä nimiä (explicit names)**  
  Käytä merkityksellisiä migraationimiä (esim. `AddEnrollmentTable`, `RenameStudentEmailToUniversityEmail`).

### Yleiset sudenkuopat

- **Entiteettien (entities) nimien muuttaminen käsittelemättä dataa**  
  Entiteetin tai ominaisuuden (property) uudelleennimeäminen voi johtaa drop + create -toimintaan, joka voi poistaa dataa. Käytä tarvittaessa eksplisiittisiä `RenameTable`/`RenameColumn`-operaatioita.

- **Vanhojen migraatioiden muokkaaminen niiden jo oltua ajettuna**  
  Vältä sellaisten migraatioiden muokkaamista, jotka on jo ajettu jaettuihin tietokantoihin (shared databases). Sen sijaan:
  - Tee uusia migraatioita skeeman hienosäätöön, tai
  - Koordinoi tiimin kanssa huolellisesti, jos tuhoava muutos (destructive change) on pakollinen.

- **Useita kehittäjiä luo päällekkäisiä migraatioita (overlapping migrations)**  
  Tiimityössä:
  - Pulla (pull) viimeisimmät muutokset ennen uusien migraatioiden luontia.
  - Ratkaise konfliktit migraatiotiedostoissa ja mallin tilannekuvassa (model snapshot) huolellisesti.

- **Työkalujen ajaminen väärässä projektissa**  
  Jos EF Core ei löydä `DbContext`-luokkaa, määritä `--project` ja/tai `--startup-project`.

---

## 10) Migraatiot (migrations) eri ympäristöissä (environments)

### Kehitys (development)

Yleisiä tapoja:

- Sovella migraatiot automaattisesti sovelluksen käynnistyessä:

```csharp
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<UniversityDbContext>();
    db.Database.Migrate();
}
```

- Tai aja `dotnet ef database update` manuaalisesti aina, kun malli (model) muuttuu.

### Testi / CI (continuous integration)

Automaattisissa testeissä:

- Luo uusi tietokanta (fresh database) (usein SQLite tai testi-PostgreSQL/SQL Server -instanssi).
- Sovella kaikki migraatiot (apply all migrations) ennen testien ajamista:

```bash
dotnet ef database update
```

Jotkin projektit käyttävät **muistinsisäisiä (in-memory)** tietokantoja yksikkötesteihin (unit tests) ja oikeita tietokantoja migraatioineen integraatiotesteihin (integration tests).

### Tuotanto (production)

Tuotannossa (production) tyypillisesti joko:

- Ajetaan `dotnet ef database update` osana käyttöönottoa (deployment step), _tai_
- Generoidaan SQL-skriptejä (SQL scripts) ja ajetaan ne DBA:n (database administrator) tai putken (deployment pipeline) kautta.

SQL-skriptin generointi:

```bash
dotnet ef migrations script
```

Valitsimia (options):

- `dotnet ef migrations script 0 LastMigration` – skripti alusta viimeisimpään migraatioon
- `dotnet ef migrations script FromMigration ToMigration` – skripti vain tietylle välille (range)

Skriptit:

- Voidaan katselmoida (review) DBA:n toimesta
- Voidaan ajaa olemassa olevilla tietokantatyökaluilla (database tooling)

---

## 11) Yhteenveto (summary)

EF Coren migraatiot (migrations) ovat keskeinen mekanismi **skeemamuutosten (schema changes) hallintaan koodina**:

- **Migraatiot (migrations)** kuvaavat inkrementaalisia (incremental), versioituja (versioned) skeemamuutoksia.
- **`dotnet ef` -työkalut (tools)** auttavat lisäämään, tarkastelemaan (inspect), soveltamaan (apply) ja palauttamaan (roll back) migraatioita.
- **Malli (model)**, **migraatiotiedostot (migration files)** ja **tietokannan historiataulu (database history table)** täytyy pitää synkassa.
- Hyvät tavat – pienet migraatiot, selkeät nimet ja huolellinen katselmointi (review) – pitävät tietokannan kehityksen hallittavana ja ymmärrettävänä.

Kun hallitset migraatiot (migrations), voit kehittää tietokannan skeemaa (database schema) luottavaisesti ilman, että kontrolli katoaa tai ympäristöt (environments) rikkoutuvat.

