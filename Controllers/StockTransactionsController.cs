using Microsoft.AspNetCore.Mvc;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Services;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class StockTransactionsController : ControllerBase
    {
        private readonly StockTransactionService _service;
        private readonly ILogger<StockTransactionsController> _logger;

        public StockTransactionsController(StockTransactionService service, ILogger<StockTransactionsController> logger)
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
                return Ok(new { message = "Lấy danh sách giao dịch kho thành công", data });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi lấy danh sách giao dịch kho");
                return StatusCode(500, new { message = "Lỗi hệ thống khi lấy giao dịch kho" });
            }
        }

        [HttpGet("detail/{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            try
            {
                var record = await _service.GetByIdAsync(id);
                if (record == null) return NotFound(new { message = "Không tìm thấy giao dịch" });
                return Ok(new { message = "Lấy chi tiết giao dịch thành công", data = record });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi lấy chi tiết giao dịch kho {id}", id);
                return StatusCode(500, new { message = "Lỗi hệ thống khi lấy chi tiết giao dịch kho" });
            }
        }

        [HttpPost("create")]
        public async Task<IActionResult> Create([FromBody] CreateStockTransactionDto dto)
        {
            try
            {
                if (dto.Quantity <= 0)
                    return BadRequest(new { message = "Số lượng phải lớn hơn 0" });

                var result = await _service.CreateAsync(dto);
                return Ok(new { message = "Tạo giao dịch kho thành công", data = result });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi tạo giao dịch kho");
                return StatusCode(500, new { message = "Lỗi hệ thống khi tạo giao dịch kho" });
            }
        }
    }
}
