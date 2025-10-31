using Microsoft.EntityFrameworkCore;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DataBase;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories.Interfaces;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories
{
    public class StockTransactionRepository : IStockTransactionRepository
    {
        private readonly StoreDBContext _context;
        private readonly IInventoryRepository _inventoryRepo;

        public StockTransactionRepository(StoreDBContext context, IInventoryRepository inventoryRepo)
        {
            _context = context;
            _inventoryRepo = inventoryRepo;
        }

        public async Task<IEnumerable<StockTransactionDto>> GetAllAsync()
        {
            return await _context.StockTransactions
                .Include(t => t.Product)
                .Include(t => t.Warehouse)
                .Select(t => new StockTransactionDto
                {
                    TransactionId = t.TransactionId,
                    WarehouseId = t.WarehouseId,
                    ProductId = t.ProductId,
                    ProductName = t.Product.ProductName,
                    Quantity = t.Quantity,
                    TransactionType = t.TransactionType,
                    CreatedBy = t.CreatedBy,
                    CreatedAt = t.CreatedAt
                }).OrderByDescending(t => t.CreatedAt).ToListAsync();
        }

        public async Task<StockTransactionDto?> GetByIdAsync(int id)
        {
            return await _context.StockTransactions
                .Include(t => t.Product)
                .Include(t => t.Warehouse)
                .Where(t => t.TransactionId == id)
                .Select(t => new StockTransactionDto
                {
                    TransactionId = t.TransactionId,
                    WarehouseId = t.WarehouseId,
                    ProductId = t.ProductId,
                    ProductName = t.Product.ProductName,
                    Quantity = t.Quantity,
                    TransactionType = t.TransactionType,
                    CreatedBy = t.CreatedBy,
                    CreatedAt = t.CreatedAt
                }).FirstOrDefaultAsync();
        }

        public async Task<StockTransactionDto> CreateAsync(CreateStockTransactionDto dto)
        {
            // ✅ cập nhật tồn kho
            int delta = dto.TransactionType.ToUpper() == "OUT" ? -dto.Quantity : dto.Quantity;
            await _inventoryRepo.UpdateQuantityAsync(dto.WarehouseId, dto.ProductId, delta);

            var entity = new StockTransaction
            {
                WarehouseId = dto.WarehouseId,
                ProductId = dto.ProductId,
                Quantity = dto.Quantity,
                TransactionType = dto.TransactionType,
                CreatedBy = dto.CreatedBy,
                CreatedAt = DateTime.UtcNow
            };

            _context.StockTransactions.Add(entity);
            await _context.SaveChangesAsync();

            var product = await _context.Products.FindAsync(dto.ProductId);
            return new StockTransactionDto
            {
                TransactionId = entity.TransactionId,
                WarehouseId = entity.WarehouseId,
                ProductId = entity.ProductId,
                ProductName = product?.ProductName ?? "",
                Quantity = entity.Quantity,
                TransactionType = entity.TransactionType,
                CreatedBy = entity.CreatedBy,
                CreatedAt = entity.CreatedAt
            };
        }
    }
}
