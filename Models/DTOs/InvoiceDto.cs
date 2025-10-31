namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs
{
    public class InvoiceDto
    {
        public int InvoiceId { get; set; }
        public string? CustomerName { get; set; }
        public DateTime InvoiceDate { get; set; }
        public decimal TotalAmount { get; set; }
        public string PaymentMethod { get; set; }
        public string Status { get; set; }
    }

    public class CreateInvoiceDto
    {
        public int? CustomerId { get; set; }
        public string CreatedBy { get; set; }
        public string PaymentMethod { get; set; }
    }
}
