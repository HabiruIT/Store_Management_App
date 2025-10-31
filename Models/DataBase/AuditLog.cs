using System.ComponentModel.DataAnnotations;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DataBase
{
    public class AuditLog
    {
        [Key]
        public int LogId { get; set; }
        public string UserId { get; set; }
        public string Action { get; set; }
        public string TableName { get; set; }
        public string RecordId { get; set; }
        public DateTime Timestamp { get; set; }

        public virtual Users Users { get; set; }
    }
}
