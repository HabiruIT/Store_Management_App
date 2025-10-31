using Microsoft.AspNetCore.Mvc;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Services;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class InvoiceDetailsController : ControllerBase
    {
        private readonly InvoiceDetailService _service;
        private readonly ILogger<InvoiceDetailsController> _logger;

        public InvoiceDetailsController(InvoiceDetailService service, ILogger<InvoiceDetailsController> logger)
        {
            _service = service;
            _logger = logger;
        }

        [HttpGet("invoice/{invoiceId}")]
        public async Task<IActionResult> GetByInvoice(int invoiceId)
        {
            try
            {
                var items = await _service.GetByInvoiceAsync(invoiceId);
                return Ok(new { message = "Lấy chi tiết hóa đơn thành công", data = items });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi lấy chi tiết hóa đơn");
                return StatusCode(500, new { message = "Lỗi hệ thống khi lấy chi tiết hóa đơn" });
            }
        }

        [HttpPost("add-item")]
        public async Task<IActionResult> AddItem([FromBody] CreateInvoiceDetailDto dto)
        {
            try
            {
                var item = await _service.AddItemAsync(dto);
                return Ok(new { message = "Thêm sản phẩm vào hóa đơn thành công", data = item });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi thêm chi tiết hóa đơn");
                return StatusCode(500, new { message = ex.Message });
            }
        }

        [HttpDelete("delete-item/{invoiceId}/{productId}")]
        public async Task<IActionResult> DeleteItem(int invoiceId, int productId)
        {
            try
            {
                var ok = await _service.DeleteItemAsync(invoiceId, productId);
                if (!ok) return NotFound(new { message = "Không tìm thấy sản phẩm trong hóa đơn" });
                return Ok(new { message = "Xóa sản phẩm khỏi hóa đơn thành công" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi xóa chi tiết hóa đơn");
                return StatusCode(500, new { message = "Lỗi hệ thống khi xóa chi tiết hóa đơn" });
            }
        }
    }
}
