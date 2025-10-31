using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories.Interfaces
{
    public interface IInvoiceRepository
    {
        Task<IEnumerable<InvoiceDto>> GetAllAsync();
        Task<InvoiceDto?> GetByIdAsync(int id);
        Task<InvoiceDto> CreateAsync(CreateInvoiceDto dto);
        Task<bool> UpdateTotalAsync(int invoiceId);
        Task<bool> UpdateStatusAsync(int invoiceId, string status);
        Task<bool> DeleteAsync(int id);
    }
}
