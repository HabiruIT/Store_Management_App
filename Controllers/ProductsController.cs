using Microsoft.AspNetCore.Mvc;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Services;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ProductsController : ControllerBase
    {
        private readonly ProductService _service;
        private readonly ILogger<ProductsController> _logger;

        public ProductsController(ProductService service, ILogger<ProductsController> logger)
        {
            _service = service;
            _logger = logger;
        }

        [HttpGet("list")]
        public async Task<IActionResult> GetAll()
        {
            try
            {
                var products = await _service.GetAllAsync();
                return Ok(new { message = "Lấy danh sách sản phẩm thành công", data = products });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi lấy danh sách sản phẩm");
                return StatusCode(500, new { message = "Lỗi hệ thống khi lấy danh sách sản phẩm" });
            }
        }

        [HttpGet("detail/{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            try
            {
                var product = await _service.GetByIdAsync(id);
                if (product == null) return NotFound(new { message = "Không tìm thấy sản phẩm" });
                return Ok(new { message = "Lấy chi tiết sản phẩm thành công", data = product });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi lấy sản phẩm {id}", id);
                return StatusCode(500, new { message = "Lỗi hệ thống khi lấy sản phẩm" });
            }
        }

        [HttpGet("by-category/{categoryId}")]
        public async Task<IActionResult> GetByCategory(int categoryId)
        {
            try
            {
                var data = await _service.GetByCategoryAsync(categoryId);
                return Ok(new { message = "Lấy sản phẩm theo danh mục thành công", data });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi lấy sản phẩm theo danh mục");
                return StatusCode(500, new { message = "Lỗi hệ thống khi lọc sản phẩm" });
            }
        }

        [HttpPost("create")]
        public async Task<IActionResult> Create([FromBody] CreateProductDto dto)
        {
            try
            {
                var result = await _service.CreateAsync(dto);
                return CreatedAtAction(nameof(GetById), new { id = result.ProductId }, result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi thêm sản phẩm");
                return StatusCode(500, new { message = "Lỗi hệ thống khi thêm sản phẩm" });
            }
        }

        [HttpPost("upload-image/{productId}")]
        [RequestSizeLimit(10_000_000)] // giới hạn 10MB
        public async Task<IActionResult> UploadImage(int productId, IFormFile file)
        {
            try
            {
                if (file == null || file.Length == 0)
                    return BadRequest(new { message = "Không có file nào được tải lên." });

                var folderPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "images", "products");
                if (!Directory.Exists(folderPath))
                    Directory.CreateDirectory(folderPath);

                // Tên file duy nhất
                var fileName = $"{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";
                var filePath = Path.Combine(folderPath, fileName);

                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await file.CopyToAsync(stream);
                }

                // Tạo URL đầy đủ
                var baseUrl = $"{Request.Scheme}://{Request.Host}";
                var imageUrl = $"{baseUrl}/images/products/{fileName}";

                var updated = await _service.UpdateImageAsync(productId, imageUrl);
                if (!updated)
                    return NotFound(new { message = "Không tìm thấy sản phẩm để cập nhật ảnh." });

                return Ok(new
                {
                    message = "Tải ảnh sản phẩm thành công.",
                    imageUrl
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi upload ảnh sản phẩm");
                return StatusCode(500, new { message = "Lỗi hệ thống khi tải ảnh." });
            }
        }


        [HttpPut("update/{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateProductDto dto)
        {
            try
            {
                var ok = await _service.UpdateAsync(id, dto);
                if (!ok) return NotFound(new { message = "Không tìm thấy sản phẩm để cập nhật" });
                return Ok(new { message = "Cập nhật sản phẩm thành công" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi cập nhật sản phẩm");
                return StatusCode(500, new { message = "Lỗi hệ thống khi cập nhật sản phẩm" });
            }
        }

        [HttpDelete("delete/{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            try
            {
                var ok = await _service.DeleteAsync(id);
                if (!ok) return NotFound(new { message = "Không tìm thấy sản phẩm cần xóa" });
                return Ok(new { message = "Xóa sản phẩm thành công" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi xóa sản phẩm");
                return StatusCode(500, new { message = "Lỗi hệ thống khi xóa sản phẩm" });
            }
        }
    }
}
