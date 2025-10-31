namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DataBase
{
    public class PurchaseOrderDetail
    {
        public int POId { get; set; }
        public int ProductId { get; set; }
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }

        public virtual PurchaseOrder PurchaseOrder { get; set; }
        public virtual Product Product { get; set; }
    }
}
