using System.ComponentModel.DataAnnotations;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DataBase
{
    public class UserProfile
    {
        [Key]
        public string Id { get; set; }
        public string FullName { get; set; }
        public string? Address { get; set; }
        public string? Phone { get; set; }
        public bool Gender { get; set; }
        public DateOnly DateOfBirth { get; set; }
        public int Salary { get; set; }
        public DateTime CreatedAt { get; set; }

        public virtual Users Users { get; set; }
    }
}
