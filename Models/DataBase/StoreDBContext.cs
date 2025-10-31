using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DataBase
{
    public class StoreDBContext : IdentityDbContext<Users>
    {
        public StoreDBContext(DbContextOptions<StoreDBContext> options) : base(options) { }

        public DbSet<UserProfile> UserProfiles { get; set; }
        public DbSet<Category> Categories { get; set; }
        public DbSet<Product> Products { get; set; }
        public DbSet<Supplier> Suppliers { get; set; }
        public DbSet<Warehouse> Warehouses { get; set; }
        public DbSet<Inventory> Inventories { get; set; }
        public DbSet<StockTransaction> StockTransactions { get; set; }
        public DbSet<PurchaseOrder> PurchaseOrders { get; set; }
        public DbSet<PurchaseOrderDetail> PurchaseOrderDetails { get; set; }
        public DbSet<Customer> Customers { get; set; }
        public DbSet<Invoice> Invoices { get; set; }
        public DbSet<InvoiceDetail> InvoiceDetails { get; set; }
        public DbSet<Payment> Payments { get; set; }
        public DbSet<Shift> Shifts { get; set; }
        public DbSet<AuditLog> AuditLogs { get; set; }

        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);

            builder.Entity<UserProfile>()
                .HasOne(p => p.Users)
                .WithOne(u => u.Profile)
                .HasForeignKey<UserProfile>(p => p.Id);

            builder.Entity<Inventory>()
                .HasKey(i => new { i.WarehouseId, i.ProductId });

            builder.Entity<InvoiceDetail>()
                .HasKey(d => new { d.InvoiceId, d.ProductId });

            builder.Entity<PurchaseOrderDetail>()
                .HasKey(d => new { d.POId, d.ProductId });

            builder.Entity<Category>(e =>
            {
                e.Property(x => x.CategoryName).HasMaxLength(100);
            });

            builder.Entity<Product>(e =>
            {
                e.Property(x => x.ProductName).HasMaxLength(200);
                e.Property(x => x.Unit).HasMaxLength(50);
                e.Property(x => x.Barcode).HasMaxLength(50);
            });

            builder.Entity<Supplier>(e =>
            {
                e.Property(x => x.SupplierName).HasMaxLength(200);
                e.Property(x => x.Phone).HasMaxLength(20).IsUnicode(false);
                e.Property(x => x.Email).HasMaxLength(150);
                e.Property(x => x.Address).HasMaxLength(250);
            });

            builder.Entity<Warehouse>(e =>
            {
                e.Property(x => x.WarehouseName).HasMaxLength(150);
                e.Property(x => x.Location).HasMaxLength(200);
            });

            builder.Entity<Customer>(e =>
            {
                e.Property(x => x.CustomerName).HasMaxLength(200);
                e.Property(x => x.Phone).HasMaxLength(20).IsUnicode(false);
                e.Property(x => x.Address).HasMaxLength(250);
                e.Property(x => x.Type).HasMaxLength(50);
            });

            builder.Entity<Invoice>(e =>
            {
                e.Property(x => x.PaymentMethod).HasMaxLength(50);
                e.Property(x => x.Status).HasMaxLength(50);
            });

            builder.Entity<StockTransaction>(e =>
            {
                e.Property(x => x.TransactionType).HasMaxLength(50);
            });

            builder.Entity<PurchaseOrder>(e =>
            {
                e.Property(x => x.Status).HasMaxLength(50);
            });

            builder.Entity<UserProfile>(e =>
            {
                e.Property(x => x.FullName).HasMaxLength(200);
                e.Property(x => x.Address).HasMaxLength(250);
                e.Property(x => x.Phone).HasMaxLength(20).IsUnicode(false);
            });

            builder.Entity<AuditLog>(e =>
            {
                e.Property(x => x.Action).HasMaxLength(50);
                e.Property(x => x.TableName).HasMaxLength(100);
                e.Property(x => x.RecordId).HasMaxLength(50);
            });

            builder.Entity<Product>(e =>
            {
                e.Property(x => x.Price).HasPrecision(18, 2);
                e.Property(x => x.CostPrice).HasPrecision(18, 2);
            });

            builder.Entity<Invoice>(e =>
            {
                e.Property(x => x.TotalAmount).HasPrecision(18, 2);
            });

            builder.Entity<InvoiceDetail>(e =>
            {
                e.Property(x => x.UnitPrice).HasPrecision(18, 2);
                e.Property(x => x.Discount).HasPrecision(18, 2);
            });

            builder.Entity<Payment>(e =>
            {
                e.Property(x => x.Amount).HasPrecision(18, 2);
            });

            builder.Entity<PurchaseOrderDetail>(e =>
            {
                e.Property(x => x.UnitPrice).HasPrecision(18, 2);
            });

            builder.Entity<Shift>(e =>
            {
                e.Property(x => x.CashOpen).HasPrecision(18, 2);
                e.Property(x => x.CashClose).HasPrecision(18, 2);
            });

        }
    }
}
