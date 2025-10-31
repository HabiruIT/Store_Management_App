using Microsoft.EntityFrameworkCore;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DataBase;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories.Interfaces;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories
{
    public class PaymentRepository : IPaymentRepository
    {
        private readonly StoreDBContext _context;
        private readonly IInvoiceRepository _invoiceRepo;

        public PaymentRepository(StoreDBContext context, IInvoiceRepository invoiceRepo)
        {
            _context = context;
            _invoiceRepo = invoiceRepo;
        }

        public async Task<IEnumerable<PaymentDto>> GetByInvoiceAsync(int invoiceId)
        {
            return await _context.Payments
                .Where(p => p.InvoiceId == invoiceId)
                .Select(p => new PaymentDto
                {
                    PaymentId = p.PaymentId,
                    InvoiceId = p.InvoiceId,
                    Amount = p.Amount,
                    PaymentMethod = p.PaymentMethod,
                    PaymentDate = p.PaymentDate
                }).OrderByDescending(p => p.PaymentDate).ToListAsync();
        }

        public async Task<PaymentDto> CreateAsync(CreatePaymentDto dto)
        {
            var invoice = await _context.Invoices.FindAsync(dto.InvoiceId);
            if (invoice == null)
                throw new Exception("Không tìm thấy hóa đơn.");

            var payment = new Payment
            {
                InvoiceId = dto.InvoiceId,
                Amount = dto.Amount,
                PaymentMethod = dto.PaymentMethod,
                PaymentDate = DateTime.UtcNow
            };

            _context.Payments.Add(payment);
            await _context.SaveChangesAsync();

            // ✅ cập nhật trạng thái nếu đủ tiền
            var paid = await _context.Payments
                .Where(p => p.InvoiceId == dto.InvoiceId)
                .SumAsync(p => p.Amount);

            if (paid >= invoice.TotalAmount)
                await _invoiceRepo.UpdateStatusAsync(dto.InvoiceId, "Paid");
            else
                await _invoiceRepo.UpdateStatusAsync(dto.InvoiceId, "Partial");

            return new PaymentDto
            {
                PaymentId = payment.PaymentId,
                InvoiceId = payment.InvoiceId,
                Amount = payment.Amount,
                PaymentMethod = payment.PaymentMethod,
                PaymentDate = payment.PaymentDate
            };
        }
    }
}
