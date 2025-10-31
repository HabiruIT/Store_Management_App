namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs
{
    public class ProductDto
    {
        public int ProductId { get; set; }
        public string ProductName { get; set; }
        public string CategoryName { get; set; }
        public string Unit { get; set; }
        public decimal Price { get; set; }
        public decimal CostPrice { get; set; }
        public bool Status { get; set; }
        public string? ImageUrl { get; set; }
    }

    public class CreateProductDto
    {
        public string ProductName { get; set; }
        public int CategoryId { get; set; }
        public string Unit { get; set; }
        public decimal Price { get; set; }
        public decimal CostPrice { get; set; }
        public string? Barcode { get; set; }
    }

    public class UpdateProductDto
    {
        public string ProductName { get; set; }
        public int CategoryId { get; set; }
        public string Unit { get; set; }
        public decimal Price { get; set; }
        public decimal CostPrice { get; set; }
        public string? Barcode { get; set; }
        public bool Status { get; set; }
    }
}
