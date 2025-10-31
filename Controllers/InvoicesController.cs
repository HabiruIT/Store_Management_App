using Microsoft.AspNetCore.Mvc;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Services;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class InvoicesController : ControllerBase
    {
        private readonly InvoiceService _service;
        private readonly ILogger<InvoicesController> _logger;

        public InvoicesController(InvoiceService service, ILogger<InvoicesController> logger)
        {
            _service = service;
            _logger = logger;
        }

        [HttpGet("list")]
        public async Task<IActionResult> GetAll()
        {
            try
            {
                var data = await _service.GetAllAsync();
                return Ok(new { message = "Lấy danh sách hóa đơn thành công", data });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi lấy danh sách hóa đơn");
                return StatusCode(500, new { message = "Lỗi hệ thống khi lấy danh sách hóa đơn" });
            }
        }

        [HttpGet("detail/{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            try
            {
                var invoice = await _service.GetByIdAsync(id);
                if (invoice == null) return NotFound(new { message = "Không tìm thấy hóa đơn" });
                return Ok(new { message = "Lấy thông tin hóa đơn thành công", data = invoice });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi lấy chi tiết hóa đơn {id}", id);
                return StatusCode(500, new { message = "Lỗi hệ thống khi lấy chi tiết hóa đơn" });
            }
        }

        [HttpPost("create")]
        public async Task<IActionResult> Create([FromBody] CreateInvoiceDto dto)
        {
            try
            {
                var result = await _service.CreateAsync(dto);
                return CreatedAtAction(nameof(GetById), new { id = result.InvoiceId }, result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi tạo hóa đơn");
                return StatusCode(500, new { message = "Lỗi hệ thống khi tạo hóa đơn" });
            }
        }

        [HttpPut("update-status/{id}")]
        public async Task<IActionResult> UpdateStatus(int id, [FromQuery] string status)
        {
            try
            {
                var ok = await _service.UpdateStatusAsync(id, status);
                if (!ok) return NotFound(new { message = "Không tìm thấy hóa đơn để cập nhật trạng thái" });
                return Ok(new { message = $"Cập nhật trạng thái hóa đơn thành công: {status}" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi cập nhật trạng thái hóa đơn {id}", id);
                return StatusCode(500, new { message = "Lỗi hệ thống khi cập nhật trạng thái hóa đơn" });
            }
        }

        [HttpDelete("delete/{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            try
            {
                var ok = await _service.DeleteAsync(id);
                if (!ok) return NotFound(new { message = "Không tìm thấy hóa đơn cần xóa" });
                return Ok(new { message = "Xóa hóa đơn thành công" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi xóa hóa đơn {id}", id);
                return StatusCode(500, new { message = "Lỗi hệ thống khi xóa hóa đơn" });
            }
        }
    }
}
