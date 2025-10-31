using Microsoft.AspNetCore.Mvc;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Services;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly AuthService _authService;
        private readonly ILogger<AuthController> _logger;

        public AuthController(AuthService authService, ILogger<AuthController> logger)
        {
            _authService = authService;
            _logger = logger;
        }

        /// <summary>
        /// Đăng ký tài khoản (Email, Password + Thông tin cá nhân).
        /// </summary>
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(new { message = "Dữ liệu không hợp lệ." });

            try
            {
                var (success, message) = await _authService.RegisterAsync(dto);
                if (!success)
                {
                    _logger.LogWarning("Đăng ký thất bại: {msg}", message);
                    return BadRequest(new { message });
                }

                return CreatedAtAction(nameof(Register), new { email = dto.Email }, new { message = "Đăng ký thành công." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi đăng ký người dùng");
                return StatusCode(500, new { message = "Lỗi hệ thống trong quá trình đăng ký." });
            }
        }

        /// <summary>
        /// Đăng nhập lấy JWT Token.
        /// </summary>
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(new { message = "Dữ liệu không hợp lệ." });

            try
            {
                var result = await _authService.LoginAsync(dto);
                if (result == null)
                {
                    _logger.LogWarning("Đăng nhập thất bại: {email}", dto.Email);
                    return Unauthorized(new { message = "Sai email hoặc mật khẩu." });
                }

                return Ok(new
                {
                    message = "Đăng nhập thành công.",
                    token = result.Token,
                    refreshToken = result.RefreshToken,
                    expiresAt = result.Expiration,
                    user = new { result.FullName, result.Email }
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi đăng nhập");
                return StatusCode(500, new { message = "Lỗi hệ thống khi đăng nhập." });
            }
        }
    }
}
