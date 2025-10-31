using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories.Interfaces;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Services
{
    public class InventoryService
    {
        private readonly IInventoryRepository _repo;

        public InventoryService(IInventoryRepository repo)
        {
            _repo = repo;
        }

        public Task<IEnumerable<InventoryDto>> GetAllAsync() => _repo.GetAllAsync();
        public Task<IEnumerable<InventoryDto>> GetByWarehouseAsync(int warehouseId) => _repo.GetByWarehouseAsync(warehouseId);
        public Task<IEnumerable<InventoryDto>> GetByProductAsync(int productId) => _repo.GetByProductAsync(productId);
    }
}
