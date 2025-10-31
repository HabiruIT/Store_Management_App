namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DataBase
{
    public class Inventory
    {
        public int WarehouseId { get; set; }
        public int ProductId { get; set; }
        public int Quantity { get; set; }

        public virtual Warehouse Warehouse { get; set; }
        public virtual Product Product { get; set; }
    }
}
