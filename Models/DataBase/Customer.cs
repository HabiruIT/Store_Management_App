using System.ComponentModel.DataAnnotations;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DataBase
{
    public class Customer
    {
        [Key]
        public int CustomerId { get; set; }
        public string CustomerName { get; set; }
        public string? Phone { get; set; }
        public string? Address { get; set; }
        public string? Type { get; set; }

        public virtual ICollection<Invoice> Invoices { get; set; }
    }
}
