using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories.Interfaces
{
    public interface IUserRepository
    {
        Task<IEnumerable<UserProfileDto>> GetAllAsync();
        Task<UserProfileDto?> GetByIdAsync(string id);
        Task<UserProfileDto?> CreateAsync(string userId, CreateUserProfileDto dto);
        Task<bool> UpdateAsync(string id, UpdateUserProfileDto dto);
        Task<bool> DeleteAsync(string id);
    }
}
