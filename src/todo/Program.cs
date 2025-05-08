using Azure.Identity;
using Microsoft.Azure.Cosmos;
using todo;
using todo.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllersWithViews();

// Configure Cosmos DB
var cosmosDbConfig = builder.Configuration.GetSection("CosmosDb");
string databaseName = cosmosDbConfig.GetSection("DatabaseName").Value!;
string containerName = cosmosDbConfig.GetSection("ContainerName").Value!;
string account = cosmosDbConfig.GetSection("Account").Value!;

Console.WriteLine($"Connecting to Cosmos DB account: {account}");
Console.WriteLine($"Using DefaultAzureCredential with RBAC authentication");

// Create Cosmos client with RBAC credentials
var credential = new DefaultAzureCredential(new DefaultAzureCredentialOptions
{
    // Explicitly specify which credentials to try
    ExcludeSharedTokenCacheCredential = false,
    ExcludeVisualStudioCredential = false,
    ExcludeVisualStudioCodeCredential = false,
    ExcludeAzureCliCredential = false,
    ExcludeInteractiveBrowserCredential = false,
    ExcludeManagedIdentityCredential = false
});

var client = new CosmosClient(account, credential);

// Initialize Cosmos DB and add service
try
{
    // Create database and container if they don't exist
    DatabaseResponse database = await client.CreateDatabaseIfNotExistsAsync(databaseName);
    await database.Database.CreateContainerIfNotExistsAsync(containerName, "/id");
    
    // Add Cosmos DB service to DI
    builder.Services.AddSingleton<ICosmosDbService>(new CosmosDbService(client, databaseName, containerName));
    Console.WriteLine($"Successfully connected to Cosmos DB using RBAC");
    Console.WriteLine($"Database: {databaseName}, Container: {containerName}");
}
catch (Exception ex)
{
    Console.WriteLine($"Error connecting to Cosmos DB: {ex.Message}");
    if (ex.InnerException != null)
    {
        Console.WriteLine($"Inner exception: {ex.InnerException.Message}");
    }
    throw; // Re-throw the exception after logging
}

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
    Console.WriteLine("Running in Development environment");
}
else
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
    Console.WriteLine("Running in Production environment");
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Item}/{action=Index}/{id?}");

// Log when the application is fully started
Console.WriteLine("Application startup complete - ready to accept requests");

app.Run();
