using System.ComponentModel.DataAnnotations;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DataBase
{
    public class Shift
    {
        [Key]
        public int ShiftId { get; set; }
        public string UserId { get; set; }
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
        public decimal CashOpen { get; set; }
        public decimal CashClose { get; set; }

        public virtual Users User { get; set; }
    }
}
