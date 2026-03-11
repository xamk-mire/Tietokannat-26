# Harjoitus 5: C#-konsolisovellus Entity Framework Corella — University-tietokanta

### Asenna yksinkertainen konsolisovellus EF Corella yhdistettynä materiaalien university_db -tietokantaan

> **Ohjeet:**  
> Luo C# **konsolisovellus**, joka käyttää **Entity Framework Corea** yhdistämään **university_db** PostgreSQL-tietokantaan (jota käytetään materiaaleissa). Määrittelet entiteetit olemassa olevaan skeemaan, konfiguroit DbContextin ja toteutat **vuorovaikutteisen valikon**, josta käyttäjä voi valita suoritettavan kyselyn (opiskelijat, kurssit, arvosanat, ilmoittautumiset, opettajat).
>
> **Edellytykset:**
>
> - .NET 10 SDK
> - PostgreSQL ja luotu/täytetty `university_db` (ks. [university_db_schema.sql](../../Materiaalit/Esimerkki-db/university_db_schema.sql) ja [university_db_seed.sql](../../Materiaalit/Esimerkki-db/university_db_seed.sql))
> - Materiaali 12 (Databases in Programming), 13 (Entity Framework Core)

---

## Tietokannan skeeman viite

`university_db` -tietokannassa on seuraavat taulut:

| Taulu           | Sarakkeet                                       | Huom.                            |
| --------------- | ----------------------------------------------- | -------------------------------- |
| **students**    | student_id (PK), full_name, email               | student_id on IDENTITY           |
| **teachers**    | teacher_id (PK), full_name, email               | teacher_id on IDENTITY           |
| **courses**     | course_id (PK), title, credits, teacher_id (FK) | teacher_id → teachers            |
| **enrollments** | student_id, course_id (yhdistetty PK)           | Molemmat FK; junction-taulu      |
| **grades**      | student_id, course_id (yhdistetty PK), grade    | Molemmat FK; grade 0–5, nullable |

---

## OSA A — Projektin luominen ja EF Core

### A1 — Luo uusi konsoliprojekti

Luo uusi konsolisovellus nimeltä `UniversityConsole`:

```bash
dotnet new console -n UniversityConsole -o UniversityConsole
cd UniversityConsole
```

### A2 — Lisää EF Core - ja konfiguraatiopaketit

Lisää PostgreSQL-provideri, design-time -työkalut ja konfiguraatiotuki (connection stringin lukemiseen `appsettings.json`-tiedostosta):

```bash
dotnet add package Npgsql.EntityFrameworkCore.PostgreSQL
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet add package Microsoft.Extensions.Configuration.Json
```

Asenna EF Core CLI -työkalut globaalisti (jos ei jo asennettuna):

```bash
dotnet tool install --global dotnet-ef
```

### A3 — Valmistele tietokanta

Varmista, että `university_db` on olemassa ja sisältää dataa:

1. Luo tietokanta (tarvittaessa): `CREATE DATABASE university_db;`
2. Aja [university_db_schema.sql](./Materiaalit/Esimerkki-db/university_db_schema.sql) taulujen luomiseksi.
3. Aja [university_db_seed.sql](./Materiaalit/Esimerkki-db/university_db_seed.sql) esimerkkidatan lisäämiseksi.

---

## OSA B — Entiteettien määrittely

Luo `Entities`-kansio ja lisää entiteettiluokat, jotka vastaavat `university_db` -tauluja. Käytä `[Table]`- ja `[Column]`-attribuutteja C#-nimien mapitukseen olemassa olevaan snake_case -skeemaan.

### B1 — Student-entiteetti

```csharp
// Entities/Student.cs
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace UniversityConsole.Entities;

[Table("students")]
public class Student
{
    [Key]
    [Column("student_id")]
    public int StudentId { get; set; }

    [Column("full_name")]
    [MaxLength(100)]
    public required string FullName { get; set; }

    [Column("email")]
    [MaxLength(255)]
    public string? Email { get; set; }

    public ICollection<Enrollment> Enrollments { get; set; } = new List<Enrollment>();
    public ICollection<Grade> Grades { get; set; } = new List<Grade>();
}
```

### B2 — Teacher-entiteetti

```csharp
// Entities/Teacher.cs
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace UniversityConsole.Entities;

[Table("teachers")]
public class Teacher
{
    [Key]
    [Column("teacher_id")]
    public int TeacherId { get; set; }

    [Column("full_name")]
    [MaxLength(100)]
    public required string FullName { get; set; }

    [Column("email")]
    [MaxLength(255)]
    public string? Email { get; set; }

    public ICollection<Course> Courses { get; set; } = new List<Course>();
}
```

### B3 — Course-entiteetti

```csharp
// Entities/Course.cs
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace UniversityConsole.Entities;

[Table("courses")]
public class Course
{
    [Key]
    [Column("course_id")]
    public int CourseId { get; set; }

    [Column("title")]
    [MaxLength(200)]
    public required string Title { get; set; }

    [Column("credits")]
    public int Credits { get; set; }

    [Column("teacher_id")]
    public int TeacherId { get; set; }

    public Teacher Teacher { get; set; } = null!;
    public ICollection<Enrollment> Enrollments { get; set; } = new List<Enrollment>();
    public ICollection<Grade> Grades { get; set; } = new List<Grade>();
}
```

### B4 — Enrollment-entiteetti (yhdistetty avain)

```csharp
// Entities/Enrollment.cs
using System.ComponentModel.DataAnnotations.Schema;

namespace UniversityConsole.Entities;

[Table("enrollments")]
public class Enrollment
{
    [Column("student_id")]
    public int StudentId { get; set; }

    [Column("course_id")]
    public int CourseId { get; set; }

    public Student Student { get; set; } = null!;
    public Course Course { get; set; } = null!;
}
```

### B5 — Grade-entiteetti (yhdistetty avain)

```csharp
// Entities/Grade.cs
using System.ComponentModel.DataAnnotations.Schema;

namespace UniversityConsole.Entities;

[Table("grades")]
public class Grade
{
    [Column("student_id")]
    public int StudentId { get; set; }

    [Column("course_id")]
    public int CourseId { get; set; }

    [Column("grade")]
    public int? GradeValue { get; set; }

    public Student Student { get; set; } = null!;
    public Course Course { get; set; } = null!;
}
```

**Tehtävä B5.1 — Konfiguroi yhdistetyt avaimet DbContextissa**

Enrollment- ja Grade-entiteeteillä on yhdistetyt pääavaimet. Konfiguroit nämä Part C:ssä DbContextissa Fluent API -käyttäen.

---

## OSA C — DbContext ja konfiguraatio

### C1 — Luo UniversityDbContext

Luo tiedosto `Data/UniversityDbContext.cs`:

```csharp
// Data/UniversityDbContext.cs
using Microsoft.EntityFrameworkCore;
using UniversityConsole.Entities;

namespace UniversityConsole.Data;

public class UniversityDbContext : DbContext
{
    public UniversityDbContext(DbContextOptions<UniversityDbContext> options)
        : base(options)
    {
    }

    public DbSet<Student> Students => Set<Student>();
    public DbSet<Teacher> Teachers => Set<Teacher>();
    public DbSet<Course> Courses => Set<Course>();
    public DbSet<Enrollment> Enrollments => Set<Enrollment>();
    public DbSet<Grade> Grades => Set<Grade>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Enrollment>(entity =>
        {
            entity.HasKey(e => new { e.StudentId, e.CourseId });
            entity.HasOne(e => e.Student).WithMany(s => s.Enrollments)
                .HasForeignKey(e => e.StudentId).OnDelete(DeleteBehavior.Restrict);
            entity.HasOne(e => e.Course).WithMany(c => c.Enrollments)
                .HasForeignKey(e => e.CourseId).OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<Grade>(entity =>
        {
            entity.HasKey(g => new { g.StudentId, g.CourseId });
            entity.HasOne(g => g.Student).WithMany(s => s.Grades)
                .HasForeignKey(g => g.StudentId).OnDelete(DeleteBehavior.Restrict);
            entity.HasOne(g => g.Course).WithMany(c => c.Grades)
                .HasForeignKey(g => g.CourseId).OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<Course>()
            .HasOne(c => c.Teacher)
            .WithMany(t => t.Courses)
            .HasForeignKey(c => c.TeacherId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
```

### C2 — Lisää connection string

Luo projektin juureen tiedosto `appsettings.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=university_db;Username=KÄYTTÄJÄS;Password=SALASANA"
  }
}
```

Korvaa `KÄYTTÄJÄS` ja `SALASANA` PostgreSQL-tunnuksillasi.

Varmista, että `appsettings.json` kopioidaan output-kansioon. Lisää tiedostoon `UniversityConsole.csproj` elementin `<Project>` sisälle:

```xml
<ItemGroup>
  <None Update="appsettings.json">
    <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>
  </None>
</ItemGroup>
```

**Tärkeää:** Älä commitoi oikeita salasanoja versionhallintaan. Käytä User Secretsia paikallisessa kehityksessä:

```bash
dotnet user-secrets init
dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Host=localhost;Port=5432;Database=university_db;Username=postgres;Password=salasanasi"
```

Lue connection string sitten koodissa User Secretsista tai `appsettings.json`-tiedostosta.

---

## OSA D — Program.cs: vuorovaikutteinen konsoli valikolla

Kopioi seuraava `Program.cs` projektiisi. Se sisältää **vuorovaikutteisen valikon**, josta käyttäjä voi valita suoritettavan kyselyn. Jokaisessa valintavaihtoehdossa on **TODO**-paikka—toteuta kyselylogiikka D1–D8:lle.

**Täysi Program.cs kopioitavaksi:**

```csharp
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using UniversityConsole.Data;
using UniversityConsole.Entities;

// --- Perustiedot (valmiina) ---
var configuration = new ConfigurationBuilder()
    .SetBasePath(Directory.GetCurrentDirectory())
    .AddJsonFile("appsettings.json", optional: false)
    .Build();

var connectionString = configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

var options = new DbContextOptionsBuilder<UniversityDbContext>()
    .UseNpgsql(connectionString)
    .Options;

await RunAsync();

async Task RunAsync()
{
    await using var context = new UniversityDbContext(options);

    while (true)
    {
        Console.WriteLine("\n=== University-tietokanta (konsoli) ===");
        Console.WriteLine("1. Listaa kaikki opiskelijat");
        Console.WriteLine("2. Listaa kurssit opettajilla");
        Console.WriteLine("3. Listaa opiskelijan arvosanat");
        Console.WriteLine("4. Listaa kurssin ilmoittautumiset");
        Console.WriteLine("5. Listaa kaikki opettajat");
        Console.WriteLine("6. Lisää uusi opiskelija (TODO)");
        Console.WriteLine("7. Päivitä opiskelija (TODO)");
        Console.WriteLine("8. Poista opiskelija (TODO)");
        Console.WriteLine("9. Täytä tietokanta seed-datalla");
        Console.WriteLine("0. Lopeta");
        Console.Write("\nValinta: ");
        var input = Console.ReadLine()?.Trim();

        if (input == "0") break;

        switch (input)
        {
            case "1":
                // ========== TODO D1: Listaa kaikki opiskelijat ==========
                Console.WriteLine("(D1 ei vielä toteutettu)");
                break;

            case "2":
                // ========== TODO D2: Listaa kurssit opettajien nimillä ==========
                Console.WriteLine("(D2 ei vielä toteutettu)");
                break;

            case "3":
                Console.Write("Opiskelija-ID: ");
                if (int.TryParse(Console.ReadLine(), out var studentId))
                {
                    // ========== TODO D3: Listaa opiskelijan arvosanat ==========
                    Console.WriteLine("(D3 ei vielä toteutettu)");
                }
                else Console.WriteLine("Virheellinen ID.");
                break;

            case "4":
                Console.Write("Kurssi-ID: ");
                if (int.TryParse(Console.ReadLine(), out var courseId))
                {
                    // ========== TODO D4: Listaa kurssin ilmoittautumiset ==========
                    Console.WriteLine("(D4 ei vielä toteutettu)");
                }
                else Console.WriteLine("Virheellinen ID.");
                break;

            case "5":
                // ========== TODO D5: Listaa kaikki opettajat ==========
                Console.WriteLine("(D5 ei vielä toteutettu)");
                break;

            case "6":
                // ========== TODO D6: Lisää uusi opiskelija ==========
                Console.WriteLine("(D6 ei vielä toteutettu)");
                break;

            case "7":
                // ========== TODO D7: Päivitä opiskelija ==========
                Console.WriteLine("(D7 ei vielä toteutettu)");
                break;

            case "8":
                // ========== TODO D8: Poista opiskelija ==========
                Console.WriteLine("(D8 ei vielä toteutettu)");
                break;

            case "9":
                await SeedDatabaseAsync(context);
                break;

            default:
                Console.WriteLine("Virheellinen valinta.");
                break;
        }
    }

    Console.WriteLine("\nHei hei.");
}

async Task SeedDatabaseAsync(UniversityDbContext context)
{
    Console.Write("Tämä poistaa kaiken datan ja täyttää tietokannan seed-datalla. Jatketaanko? (k/E): ");
    if (Console.ReadLine()?.Trim().ToLowerInvariant() != "k") return;

    await context.Database.ExecuteSqlRawAsync(@"
        TRUNCATE TABLE grades, enrollments, courses, students, teachers
        RESTART IDENTITY CASCADE");

    context.Teachers.AddRange(
        new Teacher { FullName = "Liisa Korhonen", Email = "liisa@uni.fi" },
        new Teacher { FullName = "Pekka Salo", Email = "pekka@uni.fi" },
        new Teacher { FullName = "Maria Lind", Email = "maria@uni.fi" });
    await context.SaveChangesAsync();

    context.Students.AddRange(
        new Student { FullName = "Aino Laine", Email = "aino@uni.fi" },
        new Student { FullName = "Mika Virtanen", Email = "mika@uni.fi" },
        new Student { FullName = "Sara Niemi", Email = null },
        new Student { FullName = "Olli Koski", Email = "olli@gmail.com" });
    await context.SaveChangesAsync();

    var teachers = await context.Teachers.OrderBy(t => t.TeacherId).ToListAsync();
    var students = await context.Students.OrderBy(s => s.StudentId).ToListAsync();
    context.Courses.AddRange(
        new Course { Title = "Databases", Credits = 5, TeacherId = teachers[0].TeacherId },
        new Course { Title = "Algorithms", Credits = 6, TeacherId = teachers[1].TeacherId },
        new Course { Title = "Web Development", Credits = 5, TeacherId = teachers[2].TeacherId });
    await context.SaveChangesAsync();

    var courses = await context.Courses.OrderBy(c => c.CourseId).ToListAsync();
    context.Enrollments.AddRange(
        new Enrollment { StudentId = students[0].StudentId, CourseId = courses[0].CourseId },
        new Enrollment { StudentId = students[0].StudentId, CourseId = courses[1].CourseId },
        new Enrollment { StudentId = students[1].StudentId, CourseId = courses[0].CourseId },
        new Enrollment { StudentId = students[2].StudentId, CourseId = courses[0].CourseId },
        new Enrollment { StudentId = students[2].StudentId, CourseId = courses[2].CourseId },
        new Enrollment { StudentId = students[3].StudentId, CourseId = courses[2].CourseId });
    await context.SaveChangesAsync();

    context.Grades.AddRange(
        new Grade { StudentId = students[0].StudentId, CourseId = courses[0].CourseId, GradeValue = 5 },
        new Grade { StudentId = students[0].StudentId, CourseId = courses[1].CourseId, GradeValue = 4 },
        new Grade { StudentId = students[1].StudentId, CourseId = courses[0].CourseId, GradeValue = 3 },
        new Grade { StudentId = students[2].StudentId, CourseId = courses[0].CourseId, GradeValue = 2 },
        new Grade { StudentId = students[2].StudentId, CourseId = courses[2].CourseId, GradeValue = 5 },
        new Grade { StudentId = students[3].StudentId, CourseId = courses[2].CourseId, GradeValue = 4 });
    await context.SaveChangesAsync();

    Console.WriteLine("Tietokanta täytetty seed-datalla.");
}
```

---

## OSA E — Varmistus

1. Suorita sovellus: `dotnet run`
2. Käytä valikkoa: valitse 1–9. Kohdissa 3 ja 4 syötä kelvollinen opiskelija- tai kurssi-ID (esim. 1). Käytä 9 seed-datan lataamiseen Create/Update/Delete-testien jälkeen.
3. Valitse 0 lopettaaksesi.
4. Varmista, että tuloste vastaa tietokannassa näkyvää dataa (esim. psql tai pgAdmin).

---

## Valinnaiset laajennukset

- D8: ennen poistamista tarkista, onko opiskelijalla ilmoittautumisia tai arvosanoja; poista ne ensin tai näytä viesti, että opiskelijaa ei voi poistaa.
- Lisää yksinkertainen virheenkäsittely: jos opiskelija- tai kurssi-ID:tä ei löydy, näytä selkeä viesti.
- Tulosten näyttämisen jälkeen lisää `Console.WriteLine("Paina Enter jatkaaksesi..."); Console.ReadLine();` jotta käyttäjä ehtii lukea tulosteen ennen valikon uudelleennäkyvyyttä.

---

## Tarkistuslista

- [ ] Konsoliprojekti luotu EF Corella ja Npgsql:llä
- [ ] Kaikki viisi entiteettiä määritelty ja mappattu olemassa olevaan skeemaan
- [ ] Yhdistetyt avaimet konfiguroitu Enrollment- ja Grade-entiteeteille
- [ ] DbContext luotu ja connection string ladattu konfiguraatiosta
- [ ] Vuorovaikutteinen valikko toimii; vähintään kolme lukuvaihtoehtoa (D1–D5) toteutettu
- [ ] Vaihtoehdot 3 ja 4 kysyvät ID:n ja näyttävät oikean datan `university_db`:stä
- [ ] (Valinnainen) D6 Create, D7 Update, D8 Delete toteutettu
- [ ] Vaihtoehto 9 Re-seed toimii; tietokanta voidaan nollata alkuperäiseen seed-dataan

---

## Liittyvät materiaalit

- [12 – Tietokannat ohjelmoinnissa](./Materiaalit/12-Tietokannat-ohjelmoinnissa.md)
- [13 – Entity Framework Core](./Materiaalit/13-Entity-Framework-Core.md)
- [university_db_schema.sql](./Materiaalit/Esimerkki-db/university_db_schema.sql)
- [university_db_seed.sql](./Materiaalit/Esimerkki-db/university_db_seed.sql)
