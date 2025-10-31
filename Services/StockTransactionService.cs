using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories.Interfaces;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Services
{
    public class StockTransactionService
    {
        private readonly IStockTransactionRepository _repo;

        public StockTransactionService(IStockTransactionRepository repo)
        {
            _repo = repo;
        }

        public Task<IEnumerable<StockTransactionDto>> GetAllAsync() => _repo.GetAllAsync();
        public Task<StockTransactionDto?> GetByIdAsync(int id) => _repo.GetByIdAsync(id);
        public Task<StockTransactionDto> CreateAsync(CreateStockTransactionDto dto) => _repo.CreateAsync(dto);
    }
}
