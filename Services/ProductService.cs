using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories.Interfaces;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Services
{
    public class ProductService
    {
        private readonly IProductRepository _repo;
        public ProductService(IProductRepository repo)
        {
            _repo = repo;
        }

        public Task<IEnumerable<ProductDto>> GetAllAsync() => _repo.GetAllAsync();
        public Task<ProductDto?> GetByIdAsync(int id) => _repo.GetByIdAsync(id);
        public Task<IEnumerable<ProductDto>> GetByCategoryAsync(int categoryId) => _repo.GetByCategoryAsync(categoryId);
        public Task<ProductDto> CreateAsync(CreateProductDto dto) => _repo.CreateAsync(dto);
        public Task<bool> UpdateAsync(int id, UpdateProductDto dto) => _repo.UpdateAsync(id, dto);
        public Task<bool> DeleteAsync(int id) => _repo.DeleteAsync(id);
        public async Task<bool> UpdateImageAsync(int productId, string imageUrl)
        {
            return await _repo.UpdateImageAsync(productId, imageUrl);
        }

    }
}
