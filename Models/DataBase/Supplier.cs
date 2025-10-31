using System.ComponentModel.DataAnnotations;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DataBase
{
    public class Supplier
    {
        [Key]
        public int SupplierId { get; set; }
        public string SupplierName { get; set; }
        public string? Address { get; set; }
        public string? Phone { get; set; }
        public string? Email { get; set; }

        public virtual ICollection<PurchaseOrder> PurchaseOrders { get; set; }
    }
}
