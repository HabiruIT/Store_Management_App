using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories.Interfaces
{
    public interface IPaymentRepository
    {
        Task<IEnumerable<PaymentDto>> GetByInvoiceAsync(int invoiceId);
        Task<PaymentDto> CreateAsync(CreatePaymentDto dto);
    }
}
