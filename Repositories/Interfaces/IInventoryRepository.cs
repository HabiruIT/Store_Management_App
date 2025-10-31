using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories.Interfaces
{
    public interface IInventoryRepository
    {
        Task<IEnumerable<InventoryDto>> GetAllAsync();
        Task<IEnumerable<InventoryDto>> GetByWarehouseAsync(int warehouseId);
        Task<IEnumerable<InventoryDto>> GetByProductAsync(int productId);
        Task<bool> UpdateQuantityAsync(int warehouseId, int productId, int deltaQuantity);
    }
}
