using System.ComponentModel.DataAnnotations;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DataBase
{
    public class Product
    {
        [Key]
        public int ProductId { get; set; }
        public string ProductName { get; set; }
        public int CategoryId { get; set; }
        public string Unit { get; set; }
        public decimal Price { get; set; }
        public decimal CostPrice { get; set; }
        public string? Barcode { get; set; }
        public bool Status { get; set; }
        public string? ImageUrl { get; set; }

        public virtual Category Category { get; set; }
        public virtual ICollection<InvoiceDetail> InvoiceDetails { get; set; }
        public virtual ICollection<Inventory> Inventories { get; set; }
    }
}
