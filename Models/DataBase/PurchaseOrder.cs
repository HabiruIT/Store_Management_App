using System.ComponentModel.DataAnnotations;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DataBase
{
    public class PurchaseOrder
    {
        [Key]
        public int POId { get; set; }
        public int SupplierId { get; set; }
        public string CreatedBy { get; set; }
        public DateTime OrderDate { get; set; }
        public string Status { get; set; }

        public virtual Supplier Supplier { get; set; }
        public virtual ICollection<PurchaseOrderDetail> Details { get; set; }
    }
}
