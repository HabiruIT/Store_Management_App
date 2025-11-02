using Microsoft.EntityFrameworkCore;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DataBase;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories.Interfaces;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories
{
    public class InvoiceDetailRepository : IInvoiceDetailRepository
    {
        private readonly StoreDBContext _context;
        private readonly IInventoryRepository _inventoryRepo;
        private readonly IInvoiceRepository _invoiceRepo;

        public InvoiceDetailRepository(StoreDBContext context, IInventoryRepository inventoryRepo, IInvoiceRepository invoiceRepo)
        {
            _context = context;
            _inventoryRepo = inventoryRepo;
            _invoiceRepo = invoiceRepo;
        }

        public async Task<IEnumerable<InvoiceDetailDto>> GetByInvoiceAsync(int invoiceId)
        {
            return await _context.InvoiceDetails
                .Include(d => d.Product)
                .Where(d => d.InvoiceId == invoiceId)
                .Select(d => new InvoiceDetailDto
                {
                    InvoiceId = d.InvoiceId,
                    ProductId = d.ProductId,
                    ProductName = d.Product.ProductName,
                    Quantity = d.Quantity,
                    UnitPrice = d.UnitPrice,
                    Discount = d.Discount
                }).ToListAsync();
        }

        public async Task<InvoiceDetailDto> AddItemAsync(CreateInvoiceDetailDto dto)
        {
            // ✅ kiểm tra sản phẩm & hóa đơn có tồn tại
            var product = await _context.Products.FindAsync(dto.ProductId);
            var invoice = await _context.Invoices.FindAsync(dto.InvoiceId);
            if (product == null || invoice == null)
                throw new Exception("Không tìm thấy sản phẩm hoặc hóa đơn.");

            // ✅ trừ tồn kho (1 sản phẩm chỉ nằm ở kho mặc định id=1, có thể mở rộng sau)
            await _inventoryRepo.UpdateQuantityAsync(3, dto.ProductId, -dto.Quantity);

            // ✅ thêm chi tiết
            var detail = new InvoiceDetail
            {
                InvoiceId = dto.InvoiceId,
                ProductId = dto.ProductId,
                Quantity = dto.Quantity,
                UnitPrice = dto.UnitPrice,
                Discount = dto.Discount
            };

            _context.InvoiceDetails.Add(detail);
            await _context.SaveChangesAsync();

            // ✅ cập nhật tổng tiền
            await _invoiceRepo.UpdateTotalAsync(dto.InvoiceId);

            return new InvoiceDetailDto
            {
                InvoiceId = dto.InvoiceId,
                ProductId = dto.ProductId,
                ProductName = product.ProductName,
                Quantity = dto.Quantity,
                UnitPrice = dto.UnitPrice,
                Discount = dto.Discount
            };
        }

        public async Task<bool> DeleteItemAsync(int invoiceId, int productId)
        {
            var detail = await _context.InvoiceDetails.FindAsync(invoiceId, productId);
            if (detail == null) return false;

            _context.InvoiceDetails.Remove(detail);
            await _context.SaveChangesAsync();

            await _invoiceRepo.UpdateTotalAsync(invoiceId);
            return true;
        }
    }
}
