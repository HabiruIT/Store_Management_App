using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories.Interfaces;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Services
{
    public class InvoiceDetailService
    {
        private readonly IInvoiceDetailRepository _repo;
        public InvoiceDetailService(IInvoiceDetailRepository repo)
        {
            _repo = repo;
        }

        public Task<IEnumerable<InvoiceDetailDto>> GetByInvoiceAsync(int invoiceId) => _repo.GetByInvoiceAsync(invoiceId);
        public Task<InvoiceDetailDto> AddItemAsync(CreateInvoiceDetailDto dto) => _repo.AddItemAsync(dto);
        public Task<bool> DeleteItemAsync(int invoiceId, int productId) => _repo.DeleteItemAsync(invoiceId, productId);
    }
}
