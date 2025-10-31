using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories.Interfaces
{
    public interface IInvoiceDetailRepository
    {
        Task<IEnumerable<InvoiceDetailDto>> GetByInvoiceAsync(int invoiceId);
        Task<InvoiceDetailDto> AddItemAsync(CreateInvoiceDetailDto dto);
        Task<bool> DeleteItemAsync(int invoiceId, int productId);
    }
}
