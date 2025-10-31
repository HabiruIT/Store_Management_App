using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories.Interfaces;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class UsersController : ControllerBase
    {
        private readonly IUserRepository _repo;
        private readonly ILogger<UsersController> _logger;

        public UsersController(IUserRepository repo, ILogger<UsersController> logger)
        {
            _repo = repo;
            _logger = logger;
        }

        [HttpGet("list")]
        public async Task<IActionResult> GetAll()
        {
            try
            {
                var users = await _repo.GetAllAsync();
                return Ok(new { message = "Lấy danh sách người dùng thành công.", data = users });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi lấy danh sách người dùng");
                return StatusCode(500, new { message = "Lỗi hệ thống." });
            }
        }

        [HttpPut("update/{id}")] public async Task<IActionResult> Update(string id, [FromBody] UpdateUserProfileDto dto) {
            try {
                var ok = await _repo.UpdateAsync(id, dto);
                if (!ok) return NotFound(new { message = "Không tìm thấy người dùng để cập nhật." });
                return Ok(new { message = "Cập nhật người dùng thành công." });
            } catch (Exception ex)
            { 
                _logger.LogError(ex, "Lỗi khi cập nhật user {id}", id); 
                return StatusCode(500, new { message = "Lỗi hệ thống." });
            } 
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(string id)
        {
            try
            {
                var user = await _repo.GetByIdAsync(id);
                if (user == null)
                    return NotFound(new { message = "Không tìm thấy người dùng." });

                return Ok(new { message = "Lấy thông tin người dùng thành công.", data = user });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi lấy chi tiết user {id}", id);
                return StatusCode(500, new { message = "Lỗi hệ thống." });
            }
        }

        [HttpDelete("delete/{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            try
            {
                var ok = await _repo.DeleteAsync(id);
                if (!ok)
                    return NotFound(new { message = "Không tìm thấy người dùng để xóa." });

                return Ok(new { message = "Xóa người dùng thành công." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi xóa user {id}", id);
                return StatusCode(500, new { message = "Lỗi hệ thống." });
            }
        }
    }
}
