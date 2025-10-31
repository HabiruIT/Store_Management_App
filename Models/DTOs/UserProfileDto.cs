namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs
{
    public class UserProfileDto
    {
        public string Id { get; set; }
        public string FullName { get; set; }
        public string? Address { get; set; }
        public string? Phone { get; set; }
        public bool Gender { get; set; }
        public DateOnly DateOfBirth { get; set; }
        public int Salary { get; set; }
        public DateTime CreatedAt { get; set; }
        public string Email { get; set; }
    }

    public class CreateUserProfileDto
    {
        public string FullName { get; set; }
        public string? Address { get; set; }
        public string? Phone { get; set; }
        public bool Gender { get; set; }
        public DateOnly DateOfBirth { get; set; }
        public int Salary { get; set; }
    }

    public class UpdateUserProfileDto
    {
        public string? FullName { get; set; }
        public string? Address { get; set; }
        public string? Phone { get; set; }
        public bool? Gender { get; set; }
        public DateOnly? DateOfBirth { get; set; }
        public int? Salary { get; set; }
    }
}
