using Microsoft.AspNetCore.Mvc;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Services;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class WarehousesController : ControllerBase
    {
        private readonly WarehouseService _service;
        private readonly ILogger<WarehousesController> _logger;

        public WarehousesController(WarehouseService service, ILogger<WarehousesController> logger)
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
                return Ok(new { message = "Lấy danh sách kho thành công", data });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi lấy danh sách kho");
                return StatusCode(500, new { message = "Lỗi hệ thống khi lấy danh sách kho" });
            }
        }

        [HttpGet("detail/{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            try
            {
                var warehouse = await _service.GetByIdAsync(id);
                if (warehouse == null)
                    return NotFound(new { message = "Không tìm thấy kho hàng" });

                return Ok(new { message = "Lấy chi tiết kho thành công", data = warehouse });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi lấy chi tiết kho {id}", id);
                return StatusCode(500, new { message = "Lỗi hệ thống khi lấy chi tiết kho" });
            }
        }

        [HttpPost("create")]
        public async Task<IActionResult> Create([FromBody] CreateWarehouseDto dto)
        {
            try
            {
                var result = await _service.CreateAsync(dto);
                return CreatedAtAction(nameof(GetById), new { id = result.WarehouseId }, result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi thêm kho");
                return StatusCode(500, new { message = "Lỗi hệ thống khi thêm kho" });
            }
        }

        [HttpPut("update/{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateWarehouseDto dto)
        {
            try
            {
                var ok = await _service.UpdateAsync(id, dto);
                if (!ok) return NotFound(new { message = "Không tìm thấy kho để cập nhật" });
                return Ok(new { message = "Cập nhật kho hàng thành công" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi cập nhật kho");
                return StatusCode(500, new { message = "Lỗi hệ thống khi cập nhật kho" });
            }
        }

        [HttpDelete("delete/{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            try
            {
                var ok = await _service.DeleteAsync(id);
                if (!ok) return NotFound(new { message = "Không tìm thấy kho cần xóa" });
                return Ok(new { message = "Xóa kho hàng thành công" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi xóa kho");
                return StatusCode(500, new { message = "Lỗi hệ thống khi xóa kho" });
            }
        }
    }
}
