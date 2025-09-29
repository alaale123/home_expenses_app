using System.ComponentModel.DataAnnotations;

namespace HomeExpensesApi.Models
{
    public class User
    {
        [Key]
        public int Id { get; set; }
        [Required]
        public string Name { get; set; } = string.Empty;
        [Required]
        public string Email { get; set; } = string.Empty;
        [Required]
        public string Password { get; set; } = string.Empty;
        [Required]
        public string Role { get; set; } = "Husband"; // or "Wife"
        public string? HusbandEmail { get; set; } // Only for Wife
        public bool IsApproved { get; set; } = false; // For Wife approval
    }
}
