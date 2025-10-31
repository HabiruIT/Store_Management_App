using Microsoft.EntityFrameworkCore;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DataBase;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Models.DTOs;
using quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories.Interfaces;

namespace quan_ly_chuoi_cua_hang_tap_hoa_api.Repositories
{
    public class UserRepository : IUserRepository
    {
        private readonly StoreDBContext _context;

        public UserRepository(StoreDBContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<UserProfileDto>> GetAllAsync()
        {
            return await _context.Users
                .Include(u => u.Profile)
                .Select(u => new UserProfileDto
                {
                    Id = u.Id,
                    FullName = u.Profile.FullName,
                    Address = u.Profile.Address,
                    Phone = u.Profile.Phone,
                    Gender = u.Profile.Gender,
                    DateOfBirth = u.Profile.DateOfBirth,
                    Salary = u.Profile.Salary,
                    CreatedAt = u.Profile.CreatedAt,
                    Email = u.Email
                }).ToListAsync();
        }

        public async Task<UserProfileDto?> GetByIdAsync(string id)
        {
            var user = await _context.Users.Include(u => u.Profile)
                .FirstOrDefaultAsync(u => u.Id == id);
            if (user == null || user.Profile == null) return null;

            return new UserProfileDto
            {
                Id = user.Id,
                FullName = user.Profile.FullName,
                Address = user.Profile.Address,
                Phone = user.Profile.Phone,
                Gender = user.Profile.Gender,
                DateOfBirth = user.Profile.DateOfBirth,
                Salary = user.Profile.Salary,
                CreatedAt = user.Profile.CreatedAt,
                Email = user.Email
            };
        }

        public async Task<UserProfileDto?> CreateAsync(string userId, CreateUserProfileDto dto)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null) return null;

            var profile = new UserProfile
            {
                Id = userId,
                FullName = dto.FullName,
                Address = dto.Address,
                Phone = dto.Phone,
                Gender = dto.Gender,
                DateOfBirth = dto.DateOfBirth,
                Salary = dto.Salary,
                CreatedAt = DateTime.UtcNow
            };

            _context.UserProfiles.Add(profile);
            await _context.SaveChangesAsync();

            return new UserProfileDto
            {
                Id = userId,
                FullName = dto.FullName,
                Address = dto.Address,
                Phone = dto.Phone,
                Gender = dto.Gender,
                DateOfBirth = dto.DateOfBirth,
                Salary = dto.Salary,
                CreatedAt = profile.CreatedAt,
                Email = user.Email
            };
        }

        public async Task<bool> UpdateAsync(string id, UpdateUserProfileDto dto)
        {
            var profile = await _context.UserProfiles.FindAsync(id);
            if (profile == null) return false;

            profile.FullName = dto.FullName ?? profile.FullName;
            profile.Address = dto.Address ?? profile.Address;
            profile.Phone = dto.Phone ?? profile.Phone;
            if (dto.Gender.HasValue) profile.Gender = dto.Gender.Value;
            if (dto.DateOfBirth.HasValue) profile.DateOfBirth = dto.DateOfBirth.Value;
            if (dto.Salary.HasValue) profile.Salary = dto.Salary.Value;

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> DeleteAsync(string id)
        {
            var user = await _context.Users.Include(u => u.Profile).FirstOrDefaultAsync(u => u.Id == id);
            if (user == null) return false;

            if (user.Profile != null)
                _context.UserProfiles.Remove(user.Profile);

            _context.Users.Remove(user);
            await _context.SaveChangesAsync();
            return true;
        }
    }
}
