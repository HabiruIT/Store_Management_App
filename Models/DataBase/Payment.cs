using System.ComponentModel.DataAnnotations;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DataBase
{
    public class Payment
    {
        [Key]
        public int PaymentId { get; set; }
        public int InvoiceId { get; set; }
        public decimal Amount { get; set; }
        public string PaymentMethod { get; set; }
        public DateTime PaymentDate { get; set; }

        public virtual Invoice Invoice { get; set; }
    }
}
