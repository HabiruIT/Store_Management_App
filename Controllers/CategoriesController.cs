using Microsoft.AspNetCore.Mvc;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Services;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CategoriesController : ControllerBase
    {
        private readonly CategoryService _service;
        private readonly ILogger<CategoriesController> _logger;

        public CategoriesController(CategoryService service, ILogger<CategoriesController> logger)
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
                return Ok(new { message = "Lấy danh mục thành công", data });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi lấy danh sách danh mục");
                return StatusCode(500, new { message = "Lỗi hệ thống khi lấy danh mục" });
            }
        }

        [HttpPost("create")]
        public async Task<IActionResult> Create([FromBody] CreateCategoryDto dto)
        {
            try
            {
                var result = await _service.CreateAsync(dto);
                return CreatedAtAction(nameof(GetAll), new { id = result.CategoryId }, result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi thêm danh mục");
                return StatusCode(500, new { message = "Lỗi hệ thống khi thêm danh mục" });
            }
        }

        [HttpPut("update/{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateCategoryDto dto)
        {
            try
            {
                var ok = await _service.UpdateAsync(id, dto);
                if (!ok) return NotFound(new { message = "Không tìm thấy danh mục để cập nhật" });
                return Ok(new { message = "Cập nhật danh mục thành công" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi cập nhật danh mục");
                return StatusCode(500, new { message = "Lỗi hệ thống khi cập nhật danh mục" });
            }
        }

        [HttpDelete("delete/{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            try
            {
                var ok = await _service.DeleteAsync(id);
                if (!ok) return NotFound(new { message = "Không tìm thấy danh mục cần xóa" });
                return Ok(new { message = "Xóa danh mục thành công" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi xóa danh mục");
                return StatusCode(500, new { message = "Lỗi hệ thống khi xóa danh mục" });
            }
        }
    }
}
