namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs
{
    public class RegisterDto
    {
        public string Email { get; set; }
        public string Password { get; set; }
        public string FullName { get; set; }
        public string? Phone { get; set; }
        public string? Address { get; set; }
        public bool Gender { get; set; }
        public DateOnly DateOfBirth { get; set; }
        public int Salary { get; set; }

        public string Role { get; set; } = "Sale";
    }

    public class LoginDto
    {
        public string Email { get; set; }
        public string Password { get; set; }
    }

    public class AuthResponseDto
    {
        public string Token { get; set; }
        public string RefreshToken { get; set; }
        public DateTime Expiration { get; set; }
        public string FullName { get; set; }
        public string Email { get; set; }
    }
}
