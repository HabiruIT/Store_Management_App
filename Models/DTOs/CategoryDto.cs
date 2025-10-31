namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs
{
    public class CategoryDto
    {
        public int CategoryId { get; set; }
        public string CategoryName { get; set; }
    }

    public class CreateCategoryDto
    {
        public string CategoryName { get; set; }
    }

    public class UpdateCategoryDto
    {
        public string CategoryName { get; set; }
    }
}
