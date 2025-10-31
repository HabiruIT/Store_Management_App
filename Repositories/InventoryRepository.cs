using Microsoft.EntityFrameworkCore;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DataBase;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories.Interfaces;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories
{
    public class InventoryRepository : IInventoryRepository
    {
        private readonly StoreDBContext _context;
        public InventoryRepository(StoreDBContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<InventoryDto>> GetAllAsync()
        {
            return await _context.Inventories
                .Include(i => i.Warehouse)
                .Include(i => i.Product)
                .Select(i => new InventoryDto
                {
                    WarehouseId = i.WarehouseId,
                    WarehouseName = i.Warehouse.WarehouseName,
                    ProductId = i.ProductId,
                    ProductName = i.Product.ProductName,
                    Quantity = i.Quantity
                }).ToListAsync();
        }

        public async Task<IEnumerable<InventoryDto>> GetByWarehouseAsync(int warehouseId)
        {
            return await _context.Inventories
                .Include(i => i.Product)
                .Include(i => i.Warehouse)
                .Where(i => i.WarehouseId == warehouseId)
                .Select(i => new InventoryDto
                {
                    WarehouseId = i.WarehouseId,
                    WarehouseName = i.Warehouse.WarehouseName,
                    ProductId = i.ProductId,
                    ProductName = i.Product.ProductName,
                    Quantity = i.Quantity
                }).ToListAsync();
        }

        public async Task<IEnumerable<InventoryDto>> GetByProductAsync(int productId)
        {
            return await _context.Inventories
                .Include(i => i.Product)
                .Include(i => i.Warehouse)
                .Where(i => i.ProductId == productId)
                .Select(i => new InventoryDto
                {
                    WarehouseId = i.WarehouseId,
                    WarehouseName = i.Warehouse.WarehouseName,
                    ProductId = i.ProductId,
                    ProductName = i.Product.ProductName,
                    Quantity = i.Quantity
                }).ToListAsync();
        }

        public async Task<bool> UpdateQuantityAsync(int warehouseId, int productId, int deltaQuantity)
        {
            var record = await _context.Inventories.FindAsync(warehouseId, productId);
            if (record == null)
            {
                var productExists = await _context.Products.AnyAsync(p => p.ProductId == productId);
                var warehouseExists = await _context.Warehouses.AnyAsync(w => w.WarehouseId == warehouseId);
                if (!productExists || !warehouseExists) return false;

                record = new Inventory { WarehouseId = warehouseId, ProductId = productId, Quantity = deltaQuantity };
                _context.Inventories.Add(record);
            }
            else
            {
                record.Quantity += deltaQuantity;
                if (record.Quantity < 0) record.Quantity = 0;
            }

            await _context.SaveChangesAsync();
            return true;
        }
    }
}
