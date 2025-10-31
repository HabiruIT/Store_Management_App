using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DataBase;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories.Interfaces
{
    public interface IAuthRepository
    {
        Task<(bool success, string message)> RegisterAsync(RegisterDto dto);
        Task<AuthResponseDto?> LoginAsync(LoginDto dto);
        Task<string> GenerateJwtTokenAsync(Users user);
        Task<string> GenerateRefreshTokenAsync(Users user);
    }
}
