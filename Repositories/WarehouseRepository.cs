using Microsoft.EntityFrameworkCore;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DataBase;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories.Interfaces;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories
{
    public class WarehouseRepository : IWarehouseRepository
    {
        private readonly StoreDBContext _context;
        public WarehouseRepository(StoreDBContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<WarehouseDto>> GetAllAsync()
        {
            return await _context.Warehouses
                .Select(w => new WarehouseDto
                {
                    WarehouseId = w.WarehouseId,
                    WarehouseName = w.WarehouseName,
                    Location = w.Location
                }).ToListAsync();
        }

        public async Task<WarehouseDto?> GetByIdAsync(int id)
        {
            return await _context.Warehouses
                .Where(w => w.WarehouseId == id)
                .Select(w => new WarehouseDto
                {
                    WarehouseId = w.WarehouseId,
                    WarehouseName = w.WarehouseName,
                    Location = w.Location
                }).FirstOrDefaultAsync();
        }

        public async Task<WarehouseDto> CreateAsync(CreateWarehouseDto dto)
        {
            var entity = new Warehouse
            {
                WarehouseName = dto.WarehouseName,
                Location = dto.Location
            };
            _context.Warehouses.Add(entity);
            await _context.SaveChangesAsync();
            return new WarehouseDto
            {
                WarehouseId = entity.WarehouseId,
                WarehouseName = entity.WarehouseName,
                Location = entity.Location
            };
        }

        public async Task<bool> UpdateAsync(int id, UpdateWarehouseDto dto)
        {
            var entity = await _context.Warehouses.FindAsync(id);
            if (entity == null) return false;
            entity.WarehouseName = dto.WarehouseName;
            entity.Location = dto.Location;
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var entity = await _context.Warehouses.FindAsync(id);
            if (entity == null) return false;
            _context.Warehouses.Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }
    }
}
