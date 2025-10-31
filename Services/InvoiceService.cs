using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories.Interfaces;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Services
{
    public class InvoiceService
    {
        private readonly IInvoiceRepository _repo;

        public InvoiceService(IInvoiceRepository repo)
        {
            _repo = repo;
        }

        public Task<IEnumerable<InvoiceDto>> GetAllAsync() => _repo.GetAllAsync();
        public Task<InvoiceDto?> GetByIdAsync(int id) => _repo.GetByIdAsync(id);
        public Task<InvoiceDto> CreateAsync(CreateInvoiceDto dto) => _repo.CreateAsync(dto);
        public Task<bool> UpdateTotalAsync(int invoiceId) => _repo.UpdateTotalAsync(invoiceId);
        public Task<bool> UpdateStatusAsync(int invoiceId, string status) => _repo.UpdateStatusAsync(invoiceId, status);
        public Task<bool> DeleteAsync(int id) => _repo.DeleteAsync(id);
    }
}
