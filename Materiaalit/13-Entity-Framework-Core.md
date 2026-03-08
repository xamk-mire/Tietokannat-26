# Entity Framework Core: Johdanto

### Käytännön johdatus .NETin ORM:ään tietokantakäyttöön

Tämä materiaali jatkaa aihetta [Tietokannat ohjelmoinnissa](12-Tietokannat-ohjelmoinnissa.md).

---

## 1) Johdanto Object-Relational Mappers (ORM) -kirjastoihin

### Impedanssierotus

Relaatiotietokannat tallentavat dataa **tauluissa, riveissä ja sarakkeissa**. Ohjelmointikielet työskentelevät **olioiden, ominaisuuksien ja viittausten** kanssa. Nämä mallit eivät luonnollisesti vastaa toisiaan:

- Tietokannan rivi voi kartoittua olioksi, mutta suhteet ilmaistaan viiteavaimilla, ei olio-viittauksilla.
- NULL-sallivuus, tyypit ja nimentäkonventiot poikkeavat SQL:n ja C#:n välillä.
- SQL:n kirjoittaminen käsin jokaiselle operaatiolle johtaa toistuvaan ja virhealtista koodiin.

### Mitä ORM tekee

**Object-Relational Mapper (ORM)** sijaitsee sovelluskoodin ja tietokannan välimaastossa. Se:

| Vastuu                  | Merkitys                                                                                                                |
| ----------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| **Kartoitus**           | Kääntää tietokannan rivit/sarakkeet ohjelmointikielen olioiksi                                                          |
| **Kyselygenerointi**    | Muuntaa olio-orientoituja tai LINQ-tyylisiä kyselyjä SQL:ksi                                                            |
| **Muutosten seuranta**  | Tietää, mitkä oliot ovat uusia, muokattuja tai muuttumattomia, jotta voi generoida oikeat INSERT/UPDATE/DELETE -lauseet |
| **Suhteiden käsittely** | Lataa liittyvät entiteetit (esim. opiskelijan ilmoittautumiset) ja hallitsee viiteavaimia                               |

Kirjoitat koodia **olioiden ja LINQ:n** termein; ORM generoi ja suorittaa SQL:n.

### ORM:t eri kielissä

Eri ekosysteemeillä on eri ORM:t:

| Kieli                 | Esimerkki-ORM:t               |
| --------------------- | ----------------------------- |
| C# / .NET             | Entity Framework Core, Dapper |
| Java                  | Hibernate, JPA                |
| Python                | SQLAlchemy, Django ORM        |
| JavaScript/TypeScript | TypeORM, Prisma, Sequelize    |
| Ruby                  | ActiveRecord                  |

Jokaisella on omat konventionsa, mutta ydinidea on sama: työskentele olioiden kanssa, anna ORM:n hoitaa SQL.

### Hyödyt ja kompromissit

**Hyödyt:**

- **Tuottavuus** — vähemmän boilerplatea CRUD:lle ja yleisille kyselyille
- **Tyypiturvallisuus** — ominaisuusnimien ja -tyyppien tarkistus käännösaikana
- **Abstraktio** — vaihda tietokantaa tai skeemaa ilman, että jokainen kysely kirjoitetaan uudelleen
- **Johdonmukaisuus** — parametrisoidut kyselyt oletuksena, mikä vähentää SQL-injektioriskiä

**Kompromissit:**

- **Kontrolli** — generoitu SQL ei välttämättä ole optimaalinen monimutkaisissa tai suorituskykykriittisissä tapauksissa
- **Oppimiskäyrä** — sinun täytyy ymmärtää sekä ORM että taustalla oleva SQL
- **Debuggaaminen** — kun kysely käyttäytyy odottamattomasti, täytyy tutkia generoitua SQL:ää

Tärkeää on tietää, milloin käyttää ORM:ää ja milloin siirtyä raakaan SQL:ään.

---

## 2) Mikä on Entity Framework Core?

### EF Core: .NETin ORM

**Entity Framework Core (EF Core)** on Microsoftin ORM .NETille. Se on Entity Framework 6:n seuraaja (joka kohdistui .NET Frameworkiin) ja on rakennettu nykyaikaiselle .NET:lle (Core ja sitä uudemmille).

Tämä materiaali kohdistuu **EF Core 10** -versioon, joka julkaistiin marraskuussa 2025. EF Core 10 on Long Term Support (LTS) -versio, jota tuetaan marraskuuhun 2028 asti. Sen käyttöön tarvitaan **.NET 10**.

### Keskeiset rakennuspalikat

- **Entiteetti** — C#-luokka, joka kartoittuu tietokantatauluun
- **DbContext** — keskeinen olio, joka edustaa istuntoa tietokannan kanssa ja seuraa entiteettejä
- **DbSet&lt;T&gt;** — tyypitetty kokoelma, joka edustaa taulua (esim. `DbSet<Student>` taululle `Students`)

EF Core tukee useita tietokantatarjoajia (SQL Server, PostgreSQL, SQLite, MySQL ja muut). Kirjoitat saman C#-koodin; tarjoaja kääntää sen tietokannan SQL-murteeksi.

### Miksi käyttää EF Corea?

| Hyöty                                             | Merkitys                                                                                                |
| ------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| Työskentele olioiden, ei SQL-merkkijonojen kanssa | Kirjoita `context.Students.Where(s => s.Email == email)` manuaalisen SQL:n sijaan                       |
| Tyypiturvallisuus                                 | Ominaisuusnimien ja -tyyppien tarkistus käännösaikana                                                   |
| Migraatiot                                        | Skeeman muutokset versioidaan ja sovelletaan koodina                                                    |
| Tietokantariippumattomuus                         | Vaihda tarjoajaa (esim. SQLite kehitykseen, PostgreSQL tuotantoon) ilman kyselyjen uudelleenkirjoitusta |
| LINQ-integraatio                                  | Käytä C#-LINQ:ta suodatukseen, projisointiin ja koostamiseen                                            |

---

## 3) Keskeiset käsitteet: Entiteetit, DbContext ja DbSet

### Entiteetit

**Entiteetti** on C#-luokka, jonka instanssit vastaavat taulun rivejä. Konvention mukaan:

- Luokan nimi kartoittuu taulun nimeen (esim. `Student` → `Students`)
- Julkiset ominaisuudet kartoittuvat sarakkeisiin

```csharp
public class Student
{
    public int Id { get; set; }           // Pääavain (konventio: "Id" tai "ClassNameId")
    public string FullName { get; set; }  = string.Empty;
    public string? Email { get; set; }
}
```

```csharp
public class Course
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public int Credits { get; set; }
}
```

### DbContext

**DbContext** on pääsisäänkäynti tietokantaoperaatioihin. Luot luokan, joka periytyy `DbContext`:istä ja paljastaa `DbSet<T>`-ominaisuudet kullekin taululle.

```csharp
public class UniversityDbContext : DbContext
{
    public DbSet<Student> Students => Set<Student>();
    public DbSet<Course> Courses => Set<Course>();

    public UniversityDbContext(DbContextOptions<UniversityDbContext> options)
        : base(options)
    {
    }
}
```

`DbContext`:

- Hallitsee tietokantayhteyksiä
- Seuraa entiteettejä (tietää, mitkä ovat uusia, muokattuja tai muuttumattomia)
- Kääntää LINQ-kyselyt SQL:ksi
- Suorittaa `SaveChanges()` tallettaakseen lisäykset, päivitykset ja poistot

### DbSet

**DbSet<T>** edustaa taulua. Käytät sitä datan kyselyyn ja muokkaamiseen:

```csharp
// Kysely
var student = await context.Students.FindAsync(1);
var students = await context.Students.Where(s => s.Email != null).ToListAsync();

// Lisäys
context.Students.Add(new Student { FullName = "Aino Laine", Email = "aino@uni.fi" });
await context.SaveChangesAsync();
```

---

## 4) EF Core 10:n asentaminen projektiin

### Esivaatimukset

EF Core 10 vaatii **.NET 10**. Varmista, että .NET 10 SDK on asennettu:

```bash
dotnet --version
# Pitäisi näyttää 10.x.x tai uudempi
```

### Asenna paketit

Tyypilliselle web API - tai konsolisovellukselle tarvitset:

1. **EF Core -tarjoajan** — käyttämäsi tietokantaa varten (esim. PostgreSQL, SQL Server, SQLite)
2. **Suunnitteluajan työkalut** — migraatioita varten (valinnainen mutta suositeltu)

Esimerkki PostgreSQLille (EF Core 10):

```bash
dotnet add package Npgsql.EntityFrameworkCore.PostgreSQL
dotnet add package Microsoft.EntityFrameworkCore.Design
```

Esimerkki SQLitelle (yksinkertainen paikallinen kehitys):

```bash
dotnet add package Microsoft.EntityFrameworkCore.Sqlite
dotnet add package Microsoft.EntityFrameworkCore.Design
```

Nämä komennot asentavat uusimmat yhteensopivat versiot. EF Core 10:lle käytä paketteja versiota **10.0.x** (ne seuraavat EF Core -versiota).

Asenna EF Core -työkalut globaalisti (migraatioita varten):

```bash
dotnet tool install --global dotnet-ef
```

Päivittääksesi uusimpiin EF Core -työkaluihin: `dotnet tool update --global dotnet-ef`

**Huomio useille kohteille tähtääville projekteille:** EF Core 10:ssa, jos projektisi kohdistaa useisiin frameworkeihin (esim. `net8.0` ja `net10.0`), sinun täytyy määrittää, mitä frameworkia käytetään EF-työkaluja ajettaessa, esim.: `dotnet ef migrations add InitialCreate --framework net10.0`

### Konfiguroi DbContext

**ASP.NET Core** -sovelluksessa rekisteröit DbContextin `Program.cs`:ssä (tai `Startup.cs`:ssä) ja injektoit sen tarvittaessa:

```csharp
// Program.cs
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

builder.Services.AddDbContext<UniversityDbContext>(options =>
    options.UseNpgsql(connectionString));
```

**SQLitelle**:

```csharp
builder.Services.AddDbContext<UniversityDbContext>(options =>
    options.UseSqlite("Data Source=university.db"));
```

### Yhteysmerkkijono

Tallenna yhteysmerkkijono konfiguraatioon (esim. `appsettings.json` tai ympäristömuuttujiin), ei koodiin:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Database=university;Username=myuser;Password=mypass"
  }
}
```

---

## 5) Migraatiot: Skeema koodina

EF Core käyttää **migraatioita** tietokantaskeeman luomiseen ja päivittämiseen entiteettimallisi perusteella.

### Luo migraatio

Entiteettien määrittelyn tai muuttamisen jälkeen:

```bash
dotnet ef migrations add InitialCreate
```

Tämä luo migraatioluokan (esim. `AddStudentsAndCourses`), joka sisältää SQL:n (tai tarjoajakohtaiset komennot) taulujen luontiin tai muuttamiseen.

### Sovella migraatiot

Tietokannan luomiseksi tai päivittämiseksi:

```bash
dotnet ef database update
```

Kehitysympäristössä voit soveltaa migraatioita myös käynnistyksessä:

```csharp
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<UniversityDbContext>();
    db.Database.Migrate();
}
```

### Työnkulku

1. Muuta entiteettejä (lisää ominaisuus, lisää uusi entiteetti, muuta suhde).
2. Aja `dotnet ef migrations add KuvaavaNimi`.
3. Tarkasta luotu migraatio.
4. Aja `dotnet ef database update` (tai anna sovelluksen tehdä sen kehityksessä).

Migraatiot ovat versionshallinnassa; ne mahdollistavat skeeman kehittämisen ajallisesti uudelleen toistettavasti.

---

## 6) CRUD-operaatiot EF Corella

### Create (lisäys)

```csharp
var student = new Student
{
    FullName = "Mika Virtanen",
    Email = "mika@uni.fi"
};

context.Students.Add(student);
await context.SaveChangesAsync();

// SaveChanges:n jälkeen student.Id on täytetty (jos käytät identiteettiä)
```

### Read (kysely)

```csharp
// Pääavaimella
var student = await context.Students.FindAsync(1);

// Suodatus LINQ:lla
var withEmail = await context.Students
    .Where(s => s.Email != null)
    .ToListAsync();

// Yksi tai oletus
var aino = await context.Students
    .FirstOrDefaultAsync(s => s.Email == "aino@uni.fi");
```

Kyselyt ovat **viivästettyjä**: tietokantaa ei kutsuta ennen kuin tuloksia iteroidaan (esim. `.ToListAsync()`, `await foreach`).

### Update (päivitys)

```csharp
var student = await context.Students.FindAsync(1);
if (student != null)
{
    student.Email = "aino.new@uni.fi";
    await context.SaveChangesAsync();
}
```

EF Core seuraa muutoksia. Kun muokkaat seurattua entiteettiä ja kutsut `SaveChanges()`, se generoi asianmukaisen `UPDATE`-lauseen.

### Delete (poisto)

```csharp
var student = await context.Students.FindAsync(1);
if (student != null)
{
    context.Students.Remove(student);
    await context.SaveChangesAsync();
}
```

---

## 7) Suhteet ja navigointiominaisuudet

Entiteetit liittyvät usein toisiinsa (esim. opiskelija ilmoittautuu useaan kurssiin). Mallinnat tämän **navigointiominaisuuksilla** ja **viiteavaimilla**.

### Yksi-moneen -esimerkki: Course ja Enrollments

```csharp
public class Enrollment
{
    public int Id { get; set; }
    public int StudentId { get; set; }      // Viiteavain
    public int CourseId { get; set; }       // Viiteavain
    public int? Grade { get; set; }

    public Student Student { get; set; } = null!;   // Navigointiominaisuus
    public Course Course { get; set; } = null!;
}

public class Student
{
    public int Id { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string? Email { get; set; }

    public ICollection<Enrollment> Enrollments { get; set; } = new List<Enrollment>();
}
```

### Sisällytä liittyvä data

Käytä `.Include()` liittyvien entiteettien lataamiseen ja N+1-kyselyongelman välttämiseen:

```csharp
var studentsWithEnrollments = await context.Students
    .Include(s => s.Enrollments)
        .ThenInclude(e => e.Course)
    .ToListAsync();
```

Tämä tuottaa kyselyn, joka liittää taulut ja lataa kaiken yhdessä tai muutamassa kierroksessa.

---

## 8) Fluent API ja data-annotaatiot

EF Core päättelee paljon konventioista. Kun täytyy ohittaa tai tarkentaa, käytä **data-annotaatioita** tai **Fluent API:ta**.

### Data-annotaatiot

```csharp
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

public class Student
{
    [Key]
    public int Id { get; set; }

    [Required]
    [MaxLength(200)]
    public string FullName { get; set; } = string.Empty;

    [MaxLength(256)]
    public string? Email { get; set; }

    [Column("enrolled_at")]
    public DateTime EnrolledAt { get; set; }
}
```

### Fluent API (DbContextissä)

```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    modelBuilder.Entity<Student>(entity =>
    {
        entity.HasKey(e => e.Id);
        entity.Property(e => e.FullName).IsRequired().HasMaxLength(200);
        entity.Property(e => e.Email).HasMaxLength(256);
        entity.Property(e => e.EnrolledAt).HasColumnName("enrolled_at");
    });

    modelBuilder.Entity<Enrollment>()
        .HasOne(e => e.Student)
        .WithMany(s => s.Enrollments)
        .HasForeignKey(e => e.StudentId);
}
```

Fluent API on usein suositeltu monimutkaisille konfiguraatioille, koska se pitää entiteetit vapaina tietokantakohtaisista attribuuteista.

---

## 9) Milloin käyttää raakaa SQL:ää

EF Core on tehokas, mutta joissakin tilanteissa raaka SQL on hyödyllinen:

- Monimutkaiset raportointi- tai analytiikkakyselyt
- Tietokantakohtaiset ominaisuudet (esim. ikkunafunktiot, CTE:t)
- Suorituskykykriittiset polut, joissa tarvitset täyden kontrollin

### Raaka SQL EF Corella

Entiteeteille käytä `FromSqlRaw` tai `FromSql`:

```csharp
var students = await context.Students
    .FromSqlRaw("SELECT * FROM students WHERE email LIKE {0}", "%@uni.fi")
    .ToListAsync();
```

Mukautetuille tyypeille (DTO:t), joita ei ole kartoitettu entiteeteiksi, käytä `SqlQuery` (EF Core 10) tai `SqlQueryRaw` `context.Database` -oliolta:

```csharp
var result = await context.Database
    .SqlQuery<StudentSummary>($"SELECT id, full_name FROM students WHERE id = {studentId}")
    .ToListAsync();
```

`SqlQuery`:lla merkkijonon interpolointi on turvallista: EF Core muuntaa arvot parametreiksi. `FromSqlRaw`:ssa käytä paikanpitäjiä `{0}`, `{1}` jne. ja välitä arvot lisäargumentteina. **Älä koskaan** liitä käyttäjän syötettä SQL-merkkijonoihin.

---

## 10) Riippuvuuden injektointi ja DbContext:n elinkaari

### DbContext:n injektointi

ASP.NET Core -sovelluksessa injektoit tyypillisesti `DbContext`:in kontrollereihin tai palveluihin:

```csharp
[ApiController]
[Route("api/[controller]")]
public class StudentsController : ControllerBase
{
    private readonly UniversityDbContext _context;

    public StudentsController(UniversityDbContext context)
    {
        _context = context;
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<Student>> GetStudent(int id)
    {
        var student = await _context.Students.FindAsync(id);
        if (student == null) return NotFound();
        return student;
    }
}
```

### DbContext:n elinkaari

`AddDbContext`:n oletuselinkaari on **scoped**: yksi instanssi per HTTP-pyyntö. Tämä tarkoittaa:

- Jokainen pyyntö saa oman `DbContext`:insa
- Instanssi vapautetaan, kun pyyntö päättyy
- Älä käytä yhtä `DbContext`:ia useiden pyyntöjen yli tai taustapalveluissa luomatta uutta scopeta

---

## 11) Yhteenveto

Entity Framework Core 10 tuo ORM-hyödyt .NETiin:

- **Entiteetit** — tauluihin kartoitetut C#-luokat
- **DbContext** — istunto tietokannan kanssa, seuraa entiteettejä, suorittaa kyselyitä
- **DbSet&lt;T&gt;** — tyypitetty pääsy tauluun
- **Migraatiot** — skeeman muutokset versiona koodina
- **LINQ** — tyypiturvalliset, ilmaisuvoimaiset kyselyt parannellulla käännöksellä EF Core 10:ssa
- **Tarjoajat** — SQL Server, PostgreSQL, SQLite ja muut

EF Core 10 ( .NET 10:n kanssa) lisää ominaisuuksia kuten parannellun LINQ-SQL-käännöksen useammille .NET-metodeille, nimettyjen kyselysuodattimien (soft delete, multitenancy), vektorihaku (SQL Server) ja natiivinen JSON-tyyppituki. Työskentelet olioiden ja LINQ:n kanssa; EF Core generoi SQL:n. Monimutkaisissa tapauksissa voit siirtyä raakaan SQL:ään pysyen saman frameworkin sisällä.

---

## Liittyvät materiaalit

- [12 – Tietokannat ohjelmoinnissa](12-Databases-in-Programming-FI.md) — Tietokantojen tarkoitus ohjelmoinnissa, ORM:t, CRUD, transaktiot
- [05 – SQL-perusteet](05-SQL-fundamentals.md) — SQL-perusteet (taulut, avaimet, kyselyt)
- [09 – Transaktiot ja datan muokkaus](09-Transactions-and-Data-Modification-FI.md) — Transaktiot SQL:ssä
- [14 – Käyttäjien ja roolien hallinta ohjelmoinnissa](14-Managing-Users-and-Roles-in-Programming.md) — Sovelluksen käyttäjät, roolit ja Identity-integraatio

## Lisäluettavaa

- [EF Core -dokumentaatio](https://learn.microsoft.com/en-us/ef/core/) — Microsoftin virallinen dokumentaatio
- [EF Core 10 -uutuudet](https://learn.microsoft.com/en-us/ef/core/what-is-new/ef-core-10.0/whatsnew) — EF Core 10 -julkaisutiedote
