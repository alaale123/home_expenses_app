using HomeExpensesApi.Models;
using Microsoft.EntityFrameworkCore;

namespace HomeExpensesApi.Data
{
    public static class DbInitializer
    {
        public static void Initialize(AppDbContext context)
        {
            context.Database.EnsureCreated();

            if (context.Users.Any())
            {
                return; // DB has been seeded
            }

            var husband = new User
            {
                Name = "DefaultHusband",
                Email = "husband@home.com",
                Password = "password123",
                Role = "Husband",
                IsApproved = true
            };
            context.Users.Add(husband);
            context.SaveChanges();
        }
    }
}
