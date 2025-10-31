namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs
{
    public class InventoryDto
    {
        public int WarehouseId { get; set; }
        public string WarehouseName { get; set; }
        public int ProductId { get; set; }
        public string ProductName { get; set; }
        public int Quantity { get; set; }
    }
}
