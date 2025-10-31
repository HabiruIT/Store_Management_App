using Microsoft.EntityFrameworkCore;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DataBase;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories.Interfaces;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories
{
    public class InvoiceRepository : IInvoiceRepository
    {
        private readonly StoreDBContext _context;

        public InvoiceRepository(StoreDBContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<InvoiceDto>> GetAllAsync()
        {
            return await _context.Invoices
                .Include(i => i.Customer)
                .Select(i => new InvoiceDto
                {
                    InvoiceId = i.InvoiceId,
                    CustomerName = i.Customer != null ? i.Customer.CustomerName : "Khách lẻ",
                    InvoiceDate = i.InvoiceDate,
                    TotalAmount = i.TotalAmount,
                    PaymentMethod = i.PaymentMethod,
                    Status = i.Status
                }).OrderByDescending(i => i.InvoiceDate)
                .ToListAsync();
        }

        public async Task<InvoiceDto?> GetByIdAsync(int id)
        {
            return await _context.Invoices
                .Include(i => i.Customer)
                .Where(i => i.InvoiceId == id)
                .Select(i => new InvoiceDto
                {
                    InvoiceId = i.InvoiceId,
                    CustomerName = i.Customer != null ? i.Customer.CustomerName : "Khách lẻ",
                    InvoiceDate = i.InvoiceDate,
                    TotalAmount = i.TotalAmount,
                    PaymentMethod = i.PaymentMethod,
                    Status = i.Status
                }).FirstOrDefaultAsync();
        }

        public async Task<InvoiceDto> CreateAsync(CreateInvoiceDto dto)
        {
            var invoice = new Invoice
            {
                CustomerId = dto.CustomerId,
                CreatedBy = dto.CreatedBy,
                InvoiceDate = DateTime.UtcNow,
                TotalAmount = 0,
                PaymentMethod = dto.PaymentMethod,
                Status = "Pending"
            };

            _context.Invoices.Add(invoice);
            await _context.SaveChangesAsync();

            return new InvoiceDto
            {
                InvoiceId = invoice.InvoiceId,
                CustomerName = invoice.CustomerId.HasValue ?
                    (await _context.Customers.FindAsync(invoice.CustomerId))?.CustomerName ?? "Khách lẻ" : "Khách lẻ",
                InvoiceDate = invoice.InvoiceDate,
                TotalAmount = 0,
                PaymentMethod = invoice.PaymentMethod,
                Status = invoice.Status
            };
        }

        public async Task<bool> UpdateTotalAsync(int invoiceId)
        {
            var invoice = await _context.Invoices
                .Include(i => i.Details)
                .FirstOrDefaultAsync(i => i.InvoiceId == invoiceId);

            if (invoice == null) return false;

            invoice.TotalAmount = invoice.Details.Sum(d => (d.UnitPrice * d.Quantity) - d.Discount);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> UpdateStatusAsync(int invoiceId, string status)
        {
            var invoice = await _context.Invoices.FindAsync(invoiceId);
            if (invoice == null) return false;

            invoice.Status = status;
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var invoice = await _context.Invoices.FindAsync(id);
            if (invoice == null) return false;

            _context.Invoices.Remove(invoice);
            await _context.SaveChangesAsync();
            return true;
        }
    }
}
