using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories.Interfaces
{
    public interface IStockTransactionRepository
    {
        Task<IEnumerable<StockTransactionDto>> GetAllAsync();
        Task<StockTransactionDto?> GetByIdAsync(int id);
        Task<StockTransactionDto> CreateAsync(CreateStockTransactionDto dto);
    }
}
