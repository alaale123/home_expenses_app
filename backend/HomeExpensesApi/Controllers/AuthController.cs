using Microsoft.AspNetCore.Mvc;
using HomeExpensesApi.Data;
using HomeExpensesApi.Models;
using Microsoft.EntityFrameworkCore;

namespace HomeExpensesApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly AppDbContext _context;
        public AuthController(AppDbContext context)
        {
            _context = context;
        }

        // Register endpoint
        [HttpPost("register")]
        public async Task<IActionResult> Register(User user)
        {
            Console.WriteLine($"Register attempt: {user.Email}, Role: {user.Role}");
            if (await _context.Users.AnyAsync(u => u.Email == user.Email))
                return BadRequest("Email already exists");

            if (user.Role == "Wife")
            {
                user.IsApproved = false;
            }
            else
            {
                user.IsApproved = true;
            }

            _context.Users.Add(user);
            await _context.SaveChangesAsync();
            return Ok(user);
        }

        // Login endpoint
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] User login)
        {
            Console.WriteLine($"Login attempt: {login.Email}, Role: {login.Role}");
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == login.Email && u.Password == login.Password && u.Role == login.Role);
            if (user == null)
            {
                Console.WriteLine("Login failed: user not found or wrong password");
                return Unauthorized("Invalid credentials");
            }
            if (user.Role == "Wife" && !user.IsApproved)
            {
                Console.WriteLine("Login failed: wife not approved");
                return Unauthorized("Wife account not approved by husband");
            }
            Console.WriteLine("Login successful");
            return Ok(user);
        }

        // Approve wife endpoint (called by husband)
        [HttpPost("approve-wife")]
        public async Task<IActionResult> ApproveWife([FromBody] string wifeEmail)
        {
            var wife = await _context.Users.FirstOrDefaultAsync(u => u.Email == wifeEmail && u.Role == "Wife");
            if (wife == null)
                return NotFound("Wife not found");

            wife.IsApproved = true;
            await _context.SaveChangesAsync();
            return Ok("Wife approved");
        }
    }
}
