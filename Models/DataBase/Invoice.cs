using System.ComponentModel.DataAnnotations;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DataBase
{
    public class Invoice
    {
        [Key]
        public int InvoiceId { get; set; }
        public int? CustomerId { get; set; }
        public string CreatedBy { get; set; }
        public DateTime InvoiceDate { get; set; }
        public decimal TotalAmount { get; set; }
        public string PaymentMethod { get; set; }
        public string Status { get; set; }

        public virtual Customer Customer { get; set; }
        public virtual Users User { get; set; }
        public virtual ICollection<InvoiceDetail> Details { get; set; }
        public virtual ICollection<Payment> Payments { get; set; }
    }
}
