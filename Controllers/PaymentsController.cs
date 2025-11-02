using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Services;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class PaymentsController : ControllerBase
    {
        private readonly PaymentService _service;
        private readonly ILogger<PaymentsController> _logger;

        public PaymentsController(PaymentService service, ILogger<PaymentsController> logger)
        {
            _service = service;
            _logger = logger;
        }

        [HttpGet("invoice/{invoiceId}")]
        public async Task<IActionResult> GetByInvoice(int invoiceId)
        {
            try
            {
                var payments = await _service.GetByInvoiceAsync(invoiceId);
                return Ok(new { message = "Lấy danh sách thanh toán thành công", data = payments });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi lấy thanh toán");
                return StatusCode(500, new { message = "Lỗi hệ thống khi lấy thanh toán" });
            }
        }

        [HttpPost("create")]
        public async Task<IActionResult> Create([FromBody] CreatePaymentDto dto)
        {
            try
            {
                if (dto.Amount <= 0)
                    return BadRequest(new { message = "Số tiền thanh toán phải lớn hơn 0" });

                var payment = await _service.CreateAsync(dto);
                return Ok(new { message = "Ghi nhận thanh toán thành công", data = payment });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi ghi nhận thanh toán");
                return StatusCode(500, new { message = ex.Message });
            }
        }
    }
}
