using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories.Interfaces;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Services
{
    public class PaymentService
    {
        private readonly IPaymentRepository _repo;

        public PaymentService(IPaymentRepository repo)
        {
            _repo = repo;
        }

        public Task<IEnumerable<PaymentDto>> GetByInvoiceAsync(int invoiceId) => _repo.GetByInvoiceAsync(invoiceId);
        public Task<PaymentDto> CreateAsync(CreatePaymentDto dto) => _repo.CreateAsync(dto);
    }
}
