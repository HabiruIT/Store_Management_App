using Microsoft.EntityFrameworkCore;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DataBase;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories.Interfaces;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories
{
    public class ProductRepository : IProductRepository
    {
        private readonly StoreDBContext _context;
        public ProductRepository(StoreDBContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<ProductDto>> GetAllAsync()
        {
            return await _context.Products
                .Include(p => p.Category)
                .Select(p => new ProductDto
                {
                    ProductId = p.ProductId,
                    ProductName = p.ProductName,
                    CategoryName = p.Category.CategoryName,
                    Unit = p.Unit,
                    Price = p.Price,
                    CostPrice = p.CostPrice,
                    Barcode = p.Barcode,
                    Status = p.Status,
                    ImageUrl = p.ImageUrl // ✅ thêm ánh xạ ảnh
                }).ToListAsync();
        }

        public async Task<ProductDto?> GetByIdAsync(int id)
        {
            return await _context.Products
                .Include(p => p.Category)
                .Where(p => p.ProductId == id)
                .Select(p => new ProductDto
                {
                    ProductId = p.ProductId,
                    ProductName = p.ProductName,
                    CategoryName = p.Category.CategoryName,
                    Unit = p.Unit,
                    Price = p.Price,
                    CostPrice = p.CostPrice,
                    Barcode = p.Barcode,
                    Status = p.Status,
                    ImageUrl = p.ImageUrl // ✅ thêm
                }).FirstOrDefaultAsync();
        }

        public async Task<IEnumerable<ProductDto>> GetByCategoryAsync(int categoryId)
        {
            return await _context.Products
                .Include(p => p.Category)
                .Where(p => p.CategoryId == categoryId)
                .Select(p => new ProductDto
                {
                    ProductId = p.ProductId,
                    ProductName = p.ProductName,
                    CategoryName = p.Category.CategoryName,
                    Unit = p.Unit,
                    Price = p.Price,
                    CostPrice = p.CostPrice,
                    Barcode = p.Barcode,
                    Status = p.Status,
                    ImageUrl = p.ImageUrl // ✅ thêm
                }).ToListAsync();
        }

        public async Task<ProductDto> CreateAsync(CreateProductDto dto)
        {
            var product = new Product
            {
                ProductName = dto.ProductName,
                CategoryId = dto.CategoryId,
                Unit = dto.Unit,
                Price = dto.Price,
                CostPrice = dto.CostPrice,
                Barcode = dto.Barcode,
                Status = true,
                ImageUrl = null
            };

            _context.Products.Add(product);
            await _context.SaveChangesAsync();

            var category = await _context.Categories.FindAsync(dto.CategoryId);

            return new ProductDto
            {
                ProductId = product.ProductId,
                ProductName = product.ProductName,
                CategoryName = category?.CategoryName ?? "Unknown",
                Unit = product.Unit,
                Price = product.Price,
                CostPrice = product.CostPrice,
                Barcode = product.Barcode,
                Status = product.Status,
                ImageUrl = product.ImageUrl // ✅ thêm
            };
        }

        public async Task<bool> UpdateAsync(int id, UpdateProductDto dto)
        {
            var product = await _context.Products.FindAsync(id);
            if (product == null) return false;

            product.ProductName = dto.ProductName;
            product.CategoryId = dto.CategoryId;
            product.Unit = dto.Unit;
            product.Price = dto.Price;
            product.CostPrice = dto.CostPrice;
            product.Barcode = dto.Barcode;
            product.Status = dto.Status;

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var product = await _context.Products.FindAsync(id);
            if (product == null) return false;

            _context.Products.Remove(product);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> UpdateImageAsync(int productId, string imageUrl)
        {
            var product = await _context.Products.FindAsync(productId);
            if (product == null) return false;

            product.ImageUrl = imageUrl;
            await _context.SaveChangesAsync();
            return true;
        }
    }
}
