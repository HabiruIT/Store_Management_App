using System.ComponentModel.DataAnnotations;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DataBase
{
    public class StockTransaction
    {
        [Key]
        public int TransactionId { get; set; }
        public int WarehouseId { get; set; }
        public int ProductId { get; set; }
        public int Quantity { get; set; }
        public string TransactionType { get; set; }
        public int? ReferenceId { get; set; }
        public string CreatedBy { get; set; }
        public DateTime CreatedAt { get; set; }

        public virtual Warehouse Warehouse { get; set; }
        public virtual Product Product { get; set; }
        public virtual Users User { get; set; }
    }
}
