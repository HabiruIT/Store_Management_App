using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories.Interfaces;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Services
{
    public class WarehouseService
    {
        private readonly IWarehouseRepository _repo;

        public WarehouseService(IWarehouseRepository repo)
        {
            _repo = repo;
        }

        public Task<IEnumerable<WarehouseDto>> GetAllAsync() => _repo.GetAllAsync();
        public Task<WarehouseDto?> GetByIdAsync(int id) => _repo.GetByIdAsync(id);
        public Task<WarehouseDto> CreateAsync(CreateWarehouseDto dto) => _repo.CreateAsync(dto);
        public Task<bool> UpdateAsync(int id, UpdateWarehouseDto dto) => _repo.UpdateAsync(id, dto);
        public Task<bool> DeleteAsync(int id) => _repo.DeleteAsync(id);
    }
}
