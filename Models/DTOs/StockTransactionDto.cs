namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs
{
    public class StockTransactionDto
    {
        public int TransactionId { get; set; }
        public int WarehouseId { get; set; }
        public int ProductId { get; set; }
        public string ProductName { get; set; }
        public string TransactionType { get; set; } // IN | OUT | TRANSFER
        public int Quantity { get; set; }
        public string CreatedBy { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class CreateStockTransactionDto
    {
        public int WarehouseId { get; set; }
        public int ProductId { get; set; }
        public int Quantity { get; set; }
        public string TransactionType { get; set; }
        public string CreatedBy { get; set; }
    }
}
