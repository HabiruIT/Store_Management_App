using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DataBase;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories.Interfaces;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories
{
    public class AuthRepository : IAuthRepository
    {
        private readonly UserManager<Users> _userManager;
        private readonly RoleManager<IdentityRole> _roleManager;
        private readonly StoreDBContext _context;
        private readonly IConfiguration _config;

        public AuthRepository(UserManager<Users> userManager,
                              RoleManager<IdentityRole> roleManager,
                              StoreDBContext context,
                              IConfiguration config)
        {
            _userManager = userManager;
            _roleManager = roleManager;
            _context = context;
            _config = config;
        }

        public async Task<(bool success, string message)> RegisterAsync(RegisterDto dto)
        {
            var existingUser = await _userManager.FindByEmailAsync(dto.Email);
            if (existingUser != null)
                return (false, "Email đã tồn tại trong hệ thống.");

            // 🔹 Tạo user
            var user = new Users
            {
                Email = dto.Email,
                UserName = dto.Email,
                PhoneNumber = dto.Phone
            };

            var result = await _userManager.CreateAsync(user, dto.Password);
            if (!result.Succeeded)
            {
                var errors = string.Join("; ", result.Errors.Select(e => e.Description));
                return (false, errors);
            }

            // 🔹 Kiểm tra Role — nếu chưa có, tự tạo
            var roleName = dto.Role?.Trim() ?? "Staff";
            if (!await _roleManager.RoleExistsAsync(roleName))
            {
                var roleResult = await _roleManager.CreateAsync(new IdentityRole(roleName));
                if (!roleResult.Succeeded)
                {
                    var errorMsg = string.Join("; ", roleResult.Errors.Select(e => e.Description));
                    return (false, $"Không thể tạo role mới: {errorMsg}");
                }
            }

            // 🔹 Gán user vào role
            await _userManager.AddToRoleAsync(user, roleName);

            // 🔹 Tạo hồ sơ người dùng
            var profile = new UserProfile
            {
                Id = user.Id,
                FullName = dto.FullName,
                Address = dto.Address,
                Phone = dto.Phone,
                Gender = dto.Gender,
                DateOfBirth = dto.DateOfBirth,
                Salary = dto.Salary,
                CreatedAt = DateTime.UtcNow
            };

            _context.UserProfiles.Add(profile);
            await _context.SaveChangesAsync();

            return (true, $"Đăng ký thành công với quyền {roleName}.");
        }

        public async Task<AuthResponseDto?> LoginAsync(LoginDto dto)
        {
            var user = await _userManager.Users
                .Include(u => u.Profile)
                .FirstOrDefaultAsync(u => u.Email == dto.Email);

            if (user == null || !(await _userManager.CheckPasswordAsync(user, dto.Password)))
                return null;

            var token = await GenerateJwtTokenAsync(user);
            var refreshToken = await GenerateRefreshTokenAsync(user);

            return new AuthResponseDto
            {
                Token = token,
                RefreshToken = refreshToken,
                Expiration = DateTime.UtcNow.AddHours(2),
                FullName = user.Profile?.FullName ?? "Người dùng",
                Email = user.Email
            };
        }

        public async Task<string> GenerateJwtTokenAsync(Users user)
        {
            var secret = _config["JwtSettings:Secret"];
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secret));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var roles = await _userManager.GetRolesAsync(user);

            var claims = new List<Claim>
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.Id),
                new Claim(JwtRegisteredClaimNames.Email, user.Email ?? string.Empty),
                new Claim("FullName", user.Profile?.FullName ?? string.Empty),
                new Claim("UserId", user.Id)
            };

            claims.AddRange(roles.Select(r => new Claim("role", r))); 

            var token = new JwtSecurityToken(
                issuer: _config["JwtSettings:Issuer"],
                audience: _config["JwtSettings:Audience"],
                claims: claims,
                expires: DateTime.UtcNow.AddHours(2),
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }

        public async Task<string> GenerateRefreshTokenAsync(Users user)
        {
            var randomNumber = new byte[64];
            using var rng = RandomNumberGenerator.Create();
            rng.GetBytes(randomNumber);
            return Convert.ToBase64String(randomNumber);
        }
    }
}
