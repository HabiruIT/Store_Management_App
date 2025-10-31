using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories.Interfaces;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Services
{
    public class CategoryService
    {
        private readonly ICategoryRepository _repo;
        public CategoryService(ICategoryRepository repo)
        {
            _repo = repo;
        }

        public Task<IEnumerable<CategoryDto>> GetAllAsync() => _repo.GetAllAsync();
        public Task<CategoryDto?> GetByIdAsync(int id) => _repo.GetByIdAsync(id);
        public Task<CategoryDto> CreateAsync(CreateCategoryDto dto) => _repo.CreateAsync(dto);
        public Task<bool> UpdateAsync(int id, UpdateCategoryDto dto) => _repo.UpdateAsync(id, dto);
        public Task<bool> DeleteAsync(int id) => _repo.DeleteAsync(id);
    }
}
