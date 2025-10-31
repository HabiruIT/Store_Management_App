using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories.Interfaces;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Services
{
    public class AuthService
    {
        private readonly IAuthRepository _repo;

        public AuthService(IAuthRepository repo)
        {
            _repo = repo;
        }

        public Task<(bool success, string message)> RegisterAsync(RegisterDto dto)
            => _repo.RegisterAsync(dto);

        public Task<AuthResponseDto?> LoginAsync(LoginDto dto)
            => _repo.LoginAsync(dto);
    }
}
