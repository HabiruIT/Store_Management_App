namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs
{
    public class InvoiceDetailDto
    {
        public int InvoiceId { get; set; }
        public int ProductId { get; set; }
        public string ProductName { get; set; }
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal Discount { get; set; }
        public decimal LineTotal => Quantity * UnitPrice - Discount;
    }

    public class CreateInvoiceDetailDto
    {
        public int InvoiceId { get; set; }
        public int ProductId { get; set; }
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal Discount { get; set; }
    }
}
