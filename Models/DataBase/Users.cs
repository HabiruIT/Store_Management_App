using Microsoft.AspNetCore.Identity;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DataBase
{
    public class Users : IdentityUser
    {
        public virtual UserProfile? Profile { get; set; }
    }
}
