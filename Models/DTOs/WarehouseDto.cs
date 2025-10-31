namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs
{
    public class WarehouseDto
    {
        public int WarehouseId { get; set; }
        public string WarehouseName { get; set; }
        public string? Location { get; set; }
    }

    public class CreateWarehouseDto
    {
        public string WarehouseName { get; set; }
        public string? Location { get; set; }
    }

    public class UpdateWarehouseDto
    {
        public string WarehouseName { get; set; }
        public string? Location { get; set; }
    }
}
