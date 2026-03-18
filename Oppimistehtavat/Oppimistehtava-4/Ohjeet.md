# Tehtävä 4 (Assignment 4) — TrailShop: EF Core -konsolisovellus (console app) ja tilausten seuranta (order tracking)

> [!NOTE]
> Tämä tehtävä jatkuu **oppimistehtävästä 3 (Assignment 3)**. Sinulla täytyy olla TrailShop-tietokanta, jossa on kaikki taulut (tables) (categories, products, customers, orders, order_items, stores, stocks, employees) ennen aloittamista.

> [!IMPORTANT]
> Kopioi Assignment-4-kansio, jossa on tämä `Instructions.md`-tiedosto, omaan classroom-repoosi (classroom repository).

Classroom-reposi (classroom repository) kansiorakenne (repository structure) pitäisi näyttää suunnilleen tältä:

```md
your-Classroom-repo-name
├── Assignment-1
│ ├── 01_schema.sql
│ ├── 01_seed.sql
│ ├── 01_queries.sql
│ └── Instructions.md
├── Assignment-2
│ ├── 02_schema.sql
│ ├── 02_seed.sql
│ ├── 02_queries.sql
│ └── Instructions.md
├── Assignment-3
│ ├── 03_schema.sql
│ ├── 03_seed.sql
│ ├── 03_indexes.sql
│ ├── 03_roles.sql
│ ├── 03_queries.sql
│ └── Instructions.md
├── Assignment-4
│ ├── TrailShopConsole/
│ │ └── (project files)
│ ├── 04_seed_order_tracking.sql
│ └── Instructions.md
└── README.md
```

## Esivaatimukset (prerequisites)

- Tehtävät 1–3 tehtynä (Assignments 1–3) (TrailShop-tietokanta (database))
- .NET 10 SDK
- PostgreSQL, jossa TrailShop-tietokanta on luotu ja täytetty (created and populated)
- Perustuntemus materiaalista [Materials 13 — Entity Framework Core](../../Materials/13-Entity-Framework-Core.md)
- Harjoitus 5 (Exercise 5) (University Console with EF Core) auttaa, mutta ei ole pakollinen

---

## Skenaario (scenario)

TrailShop haluaa **konsolisovelluksen (console application)** tietokannan hallintaan ja **tilausten seurantaan (order tracking)**. Sinä:

1. Luot .NET-konsolisovelluksen ja **skaffoldaat (scaffold)** `DbContext`-luokan ja entiteettiluokat (entity classes) olemassa olevasta TrailShop-tietokannasta
2. Luot **alkuperäisen pohjamigraation (initial baseline migration)**, joka kirjaa nykyisen skeeman (schema) migraatiohistoriaan (migration history)
3. Laajennat mallia (model) ja käytät migraatioita (migrations) lisätäksesi tilausten seurannan (`order_status` tilauksiin (orders), uusi `order_tracking`-taulu)
4. Toteutat valikkotoiminnot (menu options) tilausten katseluun, statuksen (status) päivittämiseen ja seurantahistorian (tracking history) hallintaan

---

# Osa 1 (Part 1) — Luo konsolisovellus (console application)

## 1.1 — Projektin alustus (project setup)

Luo uusi konsolisovellus nimellä `TrailShopConsole` Assignment-4-kansion sisälle:

```bash
dotnet new console -n TrailShopConsole -o TrailShopConsole
cd TrailShopConsole
```

Lisää EF Core -paketit (packages):

```bash
dotnet add package Npgsql.EntityFrameworkCore.PostgreSQL
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet add package Microsoft.Extensions.Configuration.Json
```

Asenna EF Core -CLI-työkalut (CLI tools) globaalisti (globally) (jos niitä ei ole jo asennettu):

```bash
dotnet tool install --global dotnet-ef
```

## 1.2 — Yhteysmerkkijono (connection string)

Luo `appsettings.json` projektin juureen (project root):

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=trailshop;Username=YOUR_USER;Password=YOUR_PASSWORD"
  }
}
```

Korvaa `YOUR_USER`, `YOUR_PASSWORD` ja `trailshop` omilla arvoillasi (tietokannan nimi (database name) ja tunnukset (credentials)).

**Tärkeää (important):** Älä commitoi (commit) oikeita salasanoja (passwords) versionhallintaan (version control). Käytä User Secrets -ominaisuutta (User Secrets) paikalliseen kehitykseen (local development):

```bash
dotnet user-secrets init
dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Host=localhost;Port=5432;Database=trailshop;Username=postgres;Password=yourpass"
```

---

# Osa 2 (Part 2) — Skaffoldaa (scaffold) `DbContext` ja entiteetit (entities) tietokannasta

Käytä EF Coren **skaffoldausta (scaffolding)** generoimaan `DbContext`-luokka ja entiteettiluokat (entity classes) olemassa olevasta TrailShop-tietokannasta.

## 2.1 — Aja skaffoldauskomento (run the scaffold command)

Aja projektihakemistosta (project directory):

```bash
dotnet ef dbcontext scaffold "Host=localhost;Port=5432;Database=trailshop;Username=YOUR_USER;Password=YOUR_PASSWORD" Npgsql.EntityFrameworkCore.PostgreSQL -o Entities -c TrailShopDbContext --context-dir Data --no-onconfiguring
```

Korvaa yhteysmerkkijono (connection string) omilla tunnuksillasi (tai käytä samoja arvoja kuin `appsettings.json`-tiedostossa). Skaffoldauskomento lukee suoraan tietokannasta, joten yhteysmerkkijonon täytyy olla toimiva.

**Valitsimien (options) selitykset:**

- `-o Entities` — kirjoita entiteettiluokat (entity classes) `Entities`-kansioon
- `-c TrailShopDbContext` — generoidun `DbContext`-luokan nimi
- `--context-dir Data` — laita `DbContext` `Data`-kansioon
- `--no-onconfiguring` — älä lisää `OnConfiguring`-metodia kovakoodatulla yhteysmerkkijonolla (hardcoded connection string) (käytämme konfiguraatiota (configuration) `appsettings.json`-tiedostosta)

## 2.2 — Lisää konstruktori (constructor) ja design-time-tuki (design-time support)

Skaffoldattu `DbContext` voi sisältää vain parametrittoman konstruktorin (parameterless constructor). Lisää konstruktori, joka vastaanottaa `DbContextOptions`-olion, jotta sovellus voi välittää yhteyden konfiguraatiosta (configuration):

```csharp
public TrailShopDbContext(DbContextOptions<TrailShopDbContext> options)
    : base(options)
{
}
```

**Design-time-tuki (design-time support) migraatioille (migrations):** EF Core -työkalut (`dotnet ef migrations add`, `dotnet ef database update`) tarvitsevat `DbContext`-instanssin (instance). Kun käytössä on `--no-onconfiguring` ja vain options-pohjainen konstruktori (options-based constructor), työkalut eivät pysty luomaan optioita (resolve the options). Lisää design-time factory (design-time factory), jotta migraatiot toimivat.

Luo `Data/TrailShopDbContextFactory.cs`:

```csharp
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;

namespace TrailShopConsole.Data;

public class TrailShopDbContextFactory : IDesignTimeDbContextFactory<TrailShopDbContext>
{
    public TrailShopDbContext CreateDbContext(string[] args)
    {
        var configuration = new ConfigurationBuilder()
            .SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("appsettings.json", optional: false)
            .Build();

        var connectionString = configuration.GetConnectionString("DefaultConnection")
            ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

        var optionsBuilder = new DbContextOptionsBuilder<TrailShopDbContext>();
        optionsBuilder.UseNpgsql(connectionString);

        return new TrailShopDbContext(optionsBuilder.Options);
    }
}
```

Muokkaa nimiavaruus (namespace) tarvittaessa. EF Core -työkalut käyttävät tätä factorya migraatioita ajaessa. Varmista, että `Program.cs` rakentaa optiot (options) yhteysmerkkijonosta ajonaikaisesti (runtime) (katso Osa 6 ja [Exercise 5](../../Exercises/Exercise-5/Instructions.md)).

## 2.3 — Mitä generoidaan (what gets generated)

Skaffoldaus (scaffolding) luo entiteetit (entities) kaikille tietokannan tauluille (tables): `Category`, `Product`, `Customer`, `Order`, `OrderItem`, `Store`, `Stock`, `Employee`. Tässä vaiheessa `orders`-taulussa ei **ole** `order_status`-saraketta, eikä `order_tracking`-taulua ole olemassa. Lisäät ne Osassa 4 ja Osassa 5.

**Huom:** Kun muokkaat skaffoldattuja (scaffolded) tiedostoja Osassa 4, älä aja skaffoldauskomentoa uudelleen, muuten muutoksesi ylikirjoitetaan (overwritten).

## 2.4 — Testaa, että skaffoldaus onnistui (test scaffolding)

Korvaa `Program.cs`-tiedoston sisältö alla olevalla pohjalla (template). Se käyttää samaa interaktiivista valikkorakennetta (interactive menu structure) kuin [Exercise 5](../../Exercises/Exercise-5/Instructions.md). Valinnat 1 ja 2 ajavat yksinkertaisia kyselyjä (queries); jos ne toimivat, skaffoldaus onnistui.

**Säädä nimiavaruus (namespace)** `using`-rivillä, jos skaffoldattu `DbContext` käyttää eri nimiavaruutta (esim. `TrailShopConsole.Data` tai `TrailShopConsole`). Säädä `Categories` ja `Products`, jos skaffoldattu `DbContext` käyttää eri `DbSet`-ominaisuuksien nimiä (DbSet property names).

```csharp
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using TrailShopConsole.Data;  // Adjust namespace to match your scaffolded DbContext

// --- Setup (already complete) ---
var configuration = new ConfigurationBuilder()
    .SetBasePath(Directory.GetCurrentDirectory())
    .AddJsonFile("appsettings.json", optional: false)
    .Build();

var connectionString = configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

var options = new DbContextOptionsBuilder<TrailShopDbContext>()
    .UseNpgsql(connectionString)
    .Options;

await RunAsync();

async Task RunAsync()
{
    await using var context = new TrailShopDbContext(options);

    while (true)
    {
        Console.WriteLine("\n=== TrailShop Database Console ===");
        Console.WriteLine("1. List categories");
        Console.WriteLine("2. List products (first 5)");
        Console.WriteLine("0. Exit");
        Console.Write("\nChoice: ");
        var input = Console.ReadLine()?.Trim();

        if (input == "0") break;

        switch (input)
        {
            case "1":
                var categories = await context.Categories.OrderBy(c => c.CategoryId).ToListAsync();
                Console.WriteLine($"\nCategories ({categories.Count}):");
                foreach (var c in categories)
                    Console.WriteLine($"  {c.CategoryId}: {c.Name}");
                break;

            case "2":
                var products = await context.Products.OrderBy(p => p.ProductId).Take(5).ToListAsync();
                var total = await context.Products.CountAsync();
                Console.WriteLine($"\nProducts (first 5 of {total}):");
                foreach (var p in products)
                    Console.WriteLine($"  {p.ProductId}: {p.Name} ({p.Price:C})");
                break;

            default:
                Console.WriteLine("Invalid choice.");
                break;
        }
    }

    Console.WriteLine("\nGoodbye.");
}
```

Aja sovellus (run the application):

```bash
dotnet run
```

Sinun pitäisi nähdä kategoriat (categories) ja tuotteet (products) TrailShop-tietokannastasi. Jos saat virheitä puuttuvista nimiavaruuksista (namespaces) tai ominaisuuksista (properties), tarkista että skaffoldaus (scaffolding) onnistui ja että `using`-direktiivi (using directive) sekä `DbSet`-nimet vastaavat generoituja (generated) nimiä. Kun tämä toimii, siirry Osaan 3.

---

# Osa 3 (Part 3) — Luo alkuperäinen pohjamigraatio (initial baseline migration)

Luo **pohjamigraatio (baseline migration)**, joka kirjaa nykyisen skeeman (schema) EF Coren migraatiohistoriaan (migration history) muuttamatta tietokantaa. Näin myöhemmät migraatiot soveltavat (apply) vain uudet muutokset. Tee tämä **ennen** kuin lisäät `order_status` ja `order_tracking`.

## 3.1 — Luo pohjamigraatio (create the baseline migration)

Projektihakemistossa (project directory):

```bash
dotnet ef migrations add InitialCreate
```

Tämä generoi migraation, jonka `Up`-metodi (Up method) loisi kaikki olemassa olevat taulut. Koska taulut ovat jo olemassa, teemme tästä migraatiosta ei-operaation (no-op).

## 3.2 — Muokkaa pohja ei-operaatioksi (edit baseline to a no-op)

Avaa generoitu tiedosto `Migrations/[timestamp]_InitialCreate.cs`. Poista `Up`-metodista kaikki lauseet (statements), jotta se jää tyhjäksi:

```csharp
protected override void Up(MigrationBuilder migrationBuilder)
{
    // No-op: tables already exist from Assignments 1-3
}
```

Jätä `Down`-metodi (Down method) ennalleen (tai tyhjennä sekin, jos haluat). Pohjan (baseline) tarvitsee vain näkyä historiassa (recorded in history); sen ei pidä muuttaa tietokantaa.

## 3.3 — Sovella pohja (apply the baseline)

```bash
dotnet ef database update
```

Tämä lisää `InitialCreate`-migraation `__EFMigrationsHistory`-tauluun ja ajaa tyhjän `Up`-metodin, joten skeemamuutoksia (schema changes) ei tapahdu. EF Core käsittelee tätä nyt lähtöpisteenä (starting point) tuleville migraatioille. Siirry Osaan 4.

---

# Osa 4 (Part 4) — Laajenna malli (model) tilausten seurantaa (order tracking) varten

Lisää tuki tilausten seurantaan (order tracking) skaffoldattuun malliin (scaffolded model). Tietokannassa ei vielä ole näitä; Osan 5 migraatio luo ne. Käytä `DbContext`-luokassa **Fluent API:a (Fluent API)** mappaamiseen (mapping) (ei data-annotaatioita (data annotations) entiteeteissä).

## 4.1 — Lisää `order_status` `Order`-entiteettiin (entity)

Avaa `Entities/Order.cs` (tai skaffoldattu nimi) ja lisää yksinkertainen ominaisuus (property):

```csharp
public string OrderStatus { get; set; } = "PENDING";
```

Lisää navigaatiokokoelma (navigation collection) seurantahistorialle (tracking history):

```csharp
public ICollection<OrderTracking> OrderTrackings { get; set; } = new List<OrderTracking>();
```

Mappaa ominaisuus (map the property) tietokantaan `DbContext`-luokassa Fluent API:lla (katso 4.3). Sallitut arvot (allowed values): `PENDING`, `CONFIRMED`, `PROCESSING`, `SHIPPED`, `DELIVERED`, `CANCELLED`.

## 4.2 — Luo `OrderTracking`-entiteetti (entity)

Luo uusi tiedosto `Entities/OrderTracking.cs` tavallisella luokalla (plain class) (ei attribuutteja (no attributes)). Kaikki taulu- ja sarakemappaus (table and column mapping) tehdään `DbContext`-luokassa:

```csharp
namespace TrailShopConsole.Entities;

public class OrderTracking
{
    public int TrackingId { get; set; }
    public int OrderId { get; set; }
    public string Status { get; set; } = string.Empty;
    public DateTime RecordedAt { get; set; }
    public string? Notes { get; set; }

    public Order Order { get; set; } = null!;
}
```

**Säädä nimiavaruus (namespace)** vastaamaan skaffoldattuja entiteettejäsi (esim. `TrailShopConsole.Entities` tai mikä tahansa skaffoldaus generoi).

## 4.3 — Konfiguroi Fluent API:lla `DbContext`-luokassa

Tiedostossa `Data/TrailShopDbContext.cs`:

1. Lisää `DbSet<OrderTracking> OrderTrackings => Set<OrderTracking>();`

2. Lisää `OnModelCreating`-metodiin Fluent API -konfiguraatio (configuration) molemmille entiteeteille:

**Order — mappaa OrderStatus:**

```csharp
modelBuilder.Entity<Order>(entity =>
{
    entity.Property(o => o.OrderStatus)
        .HasColumnName("order_status")
        .HasMaxLength(20)
        .HasDefaultValue("PENDING");
});
```

> Jos skaffoldattu `Order`-entiteetti on jo konfiguroitu `OnModelCreating`-metodissa, lisää `OrderStatus`-konfiguraatio (property configuration) siihen olemassa olevaan `Order`-lohkoon (block) sen sijaan, että loisit uuden.

**OrderTracking — taulu (table), sarakkeet (columns), avain (key) ja relaatio (relationship):**

```csharp
modelBuilder.Entity<OrderTracking>(entity =>
{
    entity.ToTable("order_tracking");

    entity.HasKey(e => e.TrackingId);

    entity.Property(e => e.TrackingId)
        .HasColumnName("tracking_id")
        .UseIdentityByDefaultColumn();

    entity.Property(e => e.OrderId).HasColumnName("order_id");
    entity.Property(e => e.Status).HasColumnName("status").HasMaxLength(20);
    entity.Property(e => e.RecordedAt).HasColumnName("recorded_at");
    entity.Property(e => e.Notes).HasColumnName("notes");

    entity.HasOne(e => e.Order)
        .WithMany(o => o.OrderTrackings)
        .HasForeignKey(e => e.OrderId)
        .OnDelete(DeleteBehavior.Cascade);
});
```

---

# Osa 5 (Part 5) — EF Core -migraatio (migration) tilausten seurantaan (order tracking)

Koska loit pohjamigraation (baseline migration) Osassa 3, EF Core tuntee nyt olemassa olevan skeeman (existing schema). Seuraava migraatio sisältää vain uudet muutokset.

## 5.1 — Luo migraatio (create the migration)

Projektihakemistossa:

```bash
dotnet ef migrations add AddOrderTracking
```

Tämä generoi migraation, jonka pitäisi lisätä vain `order_status`-sarake (column) ja `order_tracking`-taulu (table). Avaa generoitu tiedosto ja varmista, että `Up`-metodi sisältää:

- `AddColumn` (tai vastaava) `order_status`:lle `orders`-tauluun
- `CreateTable` `order_tracking`:lle

Jos migraatio sisältää virheellisesti `CreateTable`-kutsuja (CreateTable) olemassa oleville tauluille (`categories`, `products` jne.), poista ne ja pidä vain `order_status`- ja `order_tracking`-muutokset. Jos pohja (baseline) on sovellettu oikein, tämän ei pitäisi olla tarpeen.

## 5.2 — Sovella migraatio (apply the migration)

```bash
dotnet ef database update
```

Tämä päivittää tietokannan ja kirjaa migraation `__EFMigrationsHistory`-tauluun. Olemassa oleva data säilyy (preserved); olemassa olevat tilaukset (orders) saavat oletuksena `order_status = 'PENDING'`.

## 5.3 — Siemennä (seed) tilausten seurantadata (order tracking data)

Lisää alkuperäinen seurantahistoria (initial tracking history), jotta sinulla on dataa “View order tracking history” ja “Update order status” -ominaisuuksien testaamiseen.

Luo `04_seed_order_tracking.sql` Assignment-4-kansioon:

```sql
-- Seed order tracking history for existing orders
-- Run this after applying the AddOrderTracking migration (e.g. via psql or pgAdmin)

-- Order 1: Full tracking history (PENDING -> CONFIRMED -> SHIPPED)
INSERT INTO order_tracking (order_id, status, recorded_at, notes)
VALUES
  (1, 'PENDING', '2024-01-15 10:00:00', 'Order placed'),
  (1, 'CONFIRMED', '2024-01-16 09:00:00', 'Payment received'),
  (1, 'SHIPPED', '2024-01-18 14:30:00', 'Dispatched via standard delivery');

UPDATE orders SET order_status = 'SHIPPED' WHERE order_id = 1;

-- Order 2: PENDING -> CONFIRMED
INSERT INTO order_tracking (order_id, status, recorded_at, notes)
VALUES
  (2, 'PENDING', '2024-02-20 11:15:00', 'Order placed'),
  (2, 'CONFIRMED', '2024-02-21 08:00:00', 'Processing');

UPDATE orders SET order_status = 'CONFIRMED' WHERE order_id = 2;

-- Orders 3, 4, 5: Initial PENDING only
INSERT INTO order_tracking (order_id, status, recorded_at, notes)
VALUES
  (3, 'PENDING', '2024-01-22 16:45:00', 'Order placed'),
  (4, 'PENDING', '2024-02-10 09:30:00', 'Order placed'),
  (5, 'PENDING', '2024-03-01 13:00:00', 'Order placed');
```

Aja skripti (run the script) TrailShop-tietokantaa vasten (esim. `psql -d trailshop -f 04_seed_order_tracking.sql` tai suorita se pgAdminissa). Tämä antaa esimerkkihistorian (sample tracking history): tilauksella 1 on kolme merkintää (entries), tilauksella 2 on kaksi, ja tilauksilla 3–5 on yksi.

---

# Osa 6 (Part 6) — `Program.cs`-valikko (menu)

Toteuta interaktiivinen valikko (interactive menu) `Program.cs`-tiedostoon vähintään näillä valinnoilla (options):

1. **Listaa kaikki tilaukset (list all orders)** — Näytä `order_id`, `order_date`, asiakkaan (customer) `full_name`, `order_status`. Järjestä `order_date` laskevasti (descending).
2. **Listaa tilauksen tiedot (list order details)** — Kysy `order_id`; näytä tilauksen otsikko (order header) (asiakas (customer), päivämäärä (date), status) ja tilausrivit (order items) (tuotenimi (product name), määrä (quantity), yksikköhinta (unit_price)).
3. **Näytä seurantahistoria (view order tracking history)** — Kysy `order_id`; näytä kaikki seurantamerkinnät (tracking entries) (`status`, `recorded_at`, `notes`) kyseiselle tilaukselle, järjestettynä `recorded_at` mukaan.
4. **Päivitä tilauksen status (update order status)** — Kysy `order_id` ja uusi status. Päivitä `orders.order_status` ja lisää uusi rivi (row) `order_tracking`-tauluun uudella statuksella ja nykyisellä aikaleimalla (current timestamp).
5. **Listaa asiakkaat (list customers)** — Näytä `customer_id`, `full_name`, `email`.
6. **Listaa tuotteet kategorian mukaan (list products by category)** — Näytä tuotteet (products) kategorianimellä (category name).
7. **Poistu (exit)**

Käytä samaa konfiguraatio- ja `DbContext`-asetusten (setup) mallia kuin Exercise 5:ssä (lue yhteysmerkkijono konfiguraatiosta (read connection string from configuration), luo optiot (create options), aja valikkosilmukka (menu loop)).

---

# Palautusvaatimukset (submission requirements)

Palauta Assignment-4-kansiossa (Assignment-4 folder):

- `TrailShopConsole/` — koko .NET-projekti (Program.cs, Entities, Data, Migrations, appsettings.json, .csproj)
- `04_seed_order_tracking.sql` — seurantadatan siemennys (seed data) (ajetaan migraation jälkeen (run after migration))

Classroom-reposi (classroom repository) pitäisi näyttää tältä:

```md
Assignment-4
├── TrailShopConsole/
│ ├── Entities/
│ │ ├── Category.cs (scaffolded)
│ │ ├── Product.cs (scaffolded)
│ │ ├── Customer.cs (scaffolded)
│ │ ├── Order.cs (scaffolded, then modified with OrderStatus)
│ │ ├── OrderItem.cs (scaffolded)
│ │ ├── Store.cs (scaffolded)
│ │ ├── Stock.cs (scaffolded)
│ │ ├── Employee.cs (scaffolded)
│ │ └── OrderTracking.cs (created manually)
│ ├── Data/
│ │ ├── TrailShopDbContext.cs (scaffolded, then modified)
│ │ └── TrailShopDbContextFactory.cs (design-time support for migrations)
│ ├── Migrations/
│ │ ├── [timestamp]\_InitialCreate.cs
│ │ ├── [timestamp]\_AddOrderTracking.cs
│ │ └── TrailShopDbContextModelSnapshot.cs
│ ├── Program.cs
│ ├── appsettings.json
│ └── TrailShopConsole.csproj
├── 04_seed_order_tracking.sql
└── Instructions.md
```

Skaffoldaus (scaffolding) voi generoida hieman eri nimiä tai nimiavaruuksia (namespaces) riippuen tietokannastasi; säädä `OrderTracking.cs`-tiedoston nimiavaruus (namespace) vastaamaan.

---

# Itsetarkistus (self-check)

Ennen palautusta, varmista:

1. Suorituuko skaffoldauskomento (scaffold command) ja generoituvatko entiteettiluokat (entity classes) sekä `DbContext`?
2. Syntyykö ja soveltuuko pohjamigraatio (baseline migration) (`InitialCreate`) ilman virheitä?
3. Soveltuuko `AddOrderTracking`-migraatio ilman virheitä?
4. Yhdistyykö sovellus (app) TrailShop-tietokantaan ja toimiiko se ilman virheitä?
5. Ajoitko `04_seed_order_tracking.sql` migraation jälkeen?
6. Listaako valinta 1 kaikki tilaukset (orders) asiakkaan nimellä (customer names) ja statuksella (status)?
7. Näyttääkö valinta 3 seurantahistorian (tracking history) (esim. tilauksella 1 on 3 merkintää, tilauksella 2 on 2)?
8. Kun päivität tilauksen statuksen (update an order status) (valinta 4), lisätäänkö uusi rivi (row) `order_tracking`-tauluun?

---

# Liittyvät materiaalit (related materials)

- [Materials 13 — Entity Framework Core](../../Materials/13-Entity-Framework-Core.md)
- [Exercise 5 — University Console with EF Core](../../Harjoitukset/Harjoitus-5/Ohjeet.md)
- [Assignment 1–3 schema and seed files](../Oppimistehtava-1/), [Assignment-2](../Oppimistehtava-2/), [Assignment-3](../Oppimistehtava-3/))

