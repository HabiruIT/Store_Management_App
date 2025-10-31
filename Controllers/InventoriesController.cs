using Microsoft.AspNetCore.Mvc;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Services;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class InventoriesController : ControllerBase
    {
        private readonly InventoryService _service;
        private readonly ILogger<InventoriesController> _logger;

        public InventoriesController(InventoryService service, ILogger<InventoriesController> logger)
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
                return Ok(new { message = "Lấy danh sách tồn kho thành công", data });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi lấy danh sách tồn kho");
                return StatusCode(500, new { message = "Lỗi hệ thống khi lấy tồn kho" });
            }
        }

        [HttpGet("warehouse/{warehouseId}")]
        public async Task<IActionResult> GetByWarehouse(int warehouseId)
        {
            try
            {
                var data = await _service.GetByWarehouseAsync(warehouseId);
                return Ok(new { message = "Lấy tồn kho theo kho thành công", data });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi lấy tồn kho theo kho {id}", warehouseId);
                return StatusCode(500, new { message = "Lỗi hệ thống khi lấy tồn kho theo kho" });
            }
        }

        [HttpGet("product/{productId}")]
        public async Task<IActionResult> GetByProduct(int productId)
        {
            try
            {
                var data = await _service.GetByProductAsync(productId);
                return Ok(new { message = "Lấy tồn kho theo sản phẩm thành công", data });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi lấy tồn kho theo sản phẩm {id}", productId);
                return StatusCode(500, new { message = "Lỗi hệ thống khi lấy tồn kho theo sản phẩm" });
            }
        }
    }
}
