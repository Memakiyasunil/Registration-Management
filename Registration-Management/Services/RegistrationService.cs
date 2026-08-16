using Microsoft.Data.SqlClient;
using Registration_Management.Data;
using Registration_Management.Models;
using Registration_Management.Models.ViewModels;
using Registration_Management.Repositories;

namespace Registration_Management.Services
{
    public class RegistrationService : IRegistrationService
    {
        private readonly IRegistrationRepository _repo;
        private readonly DbHelper _db;

        private static readonly string[] AllowedExtensions = { ".pdf", ".jpg", ".jpeg", ".png", ".doc", ".docx" };
        private const long MaxFileSizeBytes = 5 * 1024 * 1024; // 5 MB
        private const int MaxFileCount = 5;

        public RegistrationService(IRegistrationRepository repo, DbHelper db)
        {
            _repo = repo;
            _db = db;
        }

        public async Task<bool> IsUsernameAvailableAsync(string username, int excludeUserId = 0)
            => await _repo.IsUsernameAvailableAsync(username, excludeUserId);

        public async Task<(bool Success, string? ErrorMessage)> RegisterAsync(
            RegistrationViewModel model, IWebHostEnvironment env, IConfiguration config)
        {
            // --- Password validation ---
            if (string.IsNullOrWhiteSpace(model.Password))
                return (false, "Password is required.");
            var pwdError = ValidatePassword(model.Password);
            if (pwdError != null) return (false, pwdError);
            if (model.Password != model.ConfirmPassword) return (false, "Passwords do not match.");

            // --- Date of Birth validation ---
            if (!model.DateOfBirth.HasValue || model.DateOfBirth.Value.Date >= DateTime.Today)
                return (false, "Date of Birth must be a past date.");

            // --- Username uniqueness ---
            if (!await _repo.IsUsernameAvailableAsync(model.Username))
                return (false, "Username already exists.");

            // --- State / City validation ---
            if (model.StateId <= 0) return (false, "Please select a valid state.");
            if (model.CityId <= 0) return (false, "Please select a valid city.");

            // --- Hobbies ---
            if (!model.SelectedHobbyIds.Any()) return (false, "Please select at least one hobby.");

            // --- File validation ---
            var fileError = ValidateFiles(model.Documents);
            if (fileError != null) return (false, fileError);

            // --- Hash password ---
            string passwordHash = BCrypt.Net.BCrypt.HashPassword(model.Password, workFactor: 12);

            // --- Database transaction ---
            await using var conn = await _db.CreateConnectionAsync();
            await using var transaction = conn.BeginTransaction();

            try
            {
                // 1. Insert user
                int userId = await _repo.RegisterUserAsync(model, passwordHash, transaction, conn);

                // 2. Insert hobbies
                foreach (var hobbyId in model.SelectedHobbyIds)
                    await _repo.InsertUserHobbyAsync(userId, hobbyId, transaction, conn);

                // 3. Save files
                var uploadFolder = Path.Combine(env.WebRootPath, "uploads");
                Directory.CreateDirectory(uploadFolder);

                foreach (var file in model.Documents)
                {
                    if (file.Length == 0) continue;

                    var ext = Path.GetExtension(file.FileName).ToLowerInvariant();
                    var storedName = $"{Guid.NewGuid()}{ext}";
                    var filePath = Path.Combine(uploadFolder, storedName);

                    await using (var stream = new FileStream(filePath, FileMode.Create))
                        await file.CopyToAsync(stream);

                    await _repo.InsertDocumentAsync(userId, file.FileName, storedName, ext, file.Length, transaction, conn);
                }

                transaction.Commit();
                return (true, null);
            }
            catch (Exception)
            {
                transaction.Rollback();
                throw;
            }
        }

        public async Task<(bool Success, string? ErrorMessage)> UpdateAsync(
            RegistrationViewModel model, IWebHostEnvironment env, IConfiguration config)
        {
            // --- Date of Birth validation ---
            if (!model.DateOfBirth.HasValue || model.DateOfBirth.Value.Date >= DateTime.Today)
                return (false, "Date of Birth must be a past date.");

            // --- Username uniqueness (exclude current user) ---
            if (!await _repo.IsUsernameAvailableAsync(model.Username, model.UserId))
                return (false, "Username already exists.");

            // --- State / City validation ---
            if (model.StateId <= 0) return (false, "Please select a valid state.");
            if (model.CityId <= 0) return (false, "Please select a valid city.");

            // --- Hobbies ---
            if (!model.SelectedHobbyIds.Any()) return (false, "Please select at least one hobby.");

            // --- File validation ---
            if (model.Documents.Any())
            {
                var fileError = ValidateFiles(model.Documents);
                if (fileError != null) return (false, fileError);
            }

            // --- Database transaction ---
            await using var conn = await _db.CreateConnectionAsync();
            await using var transaction = conn.BeginTransaction();

            try
            {
                // 1. Update user
                await _repo.UpdateUserAsync(model, transaction, conn);

                // 2. Replace hobbies
                await _repo.DeleteUserHobbiesAsync(model.UserId, transaction, conn);
                foreach (var hobbyId in model.SelectedHobbyIds)
                    await _repo.InsertUserHobbyAsync(model.UserId, hobbyId, transaction, conn);

                // 3. Save new files
                if (model.Documents.Any())
                {
                    var uploadFolder = Path.Combine(env.WebRootPath, "uploads");
                    Directory.CreateDirectory(uploadFolder);

                    foreach (var file in model.Documents)
                    {
                        if (file.Length == 0) continue;
                        var ext = Path.GetExtension(file.FileName).ToLowerInvariant();
                        var storedName = $"{Guid.NewGuid()}{ext}";
                        var filePath = Path.Combine(uploadFolder, storedName);

                        await using (var stream = new FileStream(filePath, FileMode.Create))
                            await file.CopyToAsync(stream);

                        await _repo.InsertDocumentAsync(model.UserId, file.FileName, storedName, ext, file.Length, transaction, conn);
                    }
                }

                transaction.Commit();
                return (true, null);
            }
            catch (Exception)
            {
                transaction.Rollback();
                throw;
            }
        }

        public async Task<RegistrationDetailsViewModel?> GetDetailsAsync(int userId)
        {
            var user = await _repo.GetUserByIdAsync(userId);
            if (user == null) return null;

            return new RegistrationDetailsViewModel
            {
                User = user,
                Hobbies = await _repo.GetUserHobbiesAsync(userId),
                Documents = await _repo.GetDocumentsByUserAsync(userId)
            };
        }

        public async Task<RegistrationViewModel?> GetForEditAsync(int userId, IMasterRepository masterRepo)
        {
            var user = await _repo.GetUserByIdAsync(userId);
            if (user == null) return null;

            var hobbies = await _repo.GetUserHobbiesAsync(userId);
            var docs = await _repo.GetDocumentsByUserAsync(userId);

            return new RegistrationViewModel
            {
                UserId = user.UserId,
                Name = user.Name,
                Username = user.Username,
                DateOfBirth = user.DateOfBirth,
                Gender = user.Gender,
                Address = user.Address,
                StateId = user.StateId,
                CityId = user.CityId,
                Pincode = user.Pincode,
                SelectedHobbyIds = hobbies.Select(h => h.HobbyId).ToList(),
                States = await masterRepo.GetStatesAsync(),
                Cities = await masterRepo.GetCitiesByStateAsync(user.StateId),
                AllHobbies = await masterRepo.GetHobbiesAsync(),
                ExistingDocuments = docs
            };
        }

        public async Task<(List<RegistrationListItem> Items, int TotalCount)> GetPagedAsync(
            int pageNumber, int pageSize,
            string? searchTerm, string? filterName, string? filterUsername,
            int? filterStateId, string? filterGender, DateTime? filterFromDate, DateTime? filterToDate,
            string sortColumn, string sortDirection)
            => await _repo.GetRegistrationsPagedAsync(
                pageNumber, pageSize, searchTerm, filterName, filterUsername,
                filterStateId, filterGender, filterFromDate, filterToDate,
                sortColumn, sortDirection);

        public async Task DeleteAsync(int userId) => await _repo.DeleteUserAsync(userId);

        public async Task<UserDocument?> GetDocumentAsync(int documentId)
            => await _repo.GetDocumentByIdAsync(documentId);

        public async Task DeleteDocumentAsync(int documentId, IWebHostEnvironment env)
        {
            var doc = await _repo.GetDocumentByIdAsync(documentId);
            if (doc != null)
            {
                var filePath = Path.Combine(env.WebRootPath, "uploads", doc.StoredFileName);
                if (File.Exists(filePath)) File.Delete(filePath);
                await _repo.DeleteDocumentAsync(documentId);
            }
        }

        // -------------------------------------------------------
        // Private helpers
        // -------------------------------------------------------

        private static string? ValidatePassword(string password)
        {
            if (password.Length < 8)
                return "Password must be at least 8 characters.";
            if (!password.Any(char.IsUpper))
                return "Password must contain at least one uppercase letter.";
            if (!password.Any(char.IsLower))
                return "Password must contain at least one lowercase letter.";
            if (!password.Any(char.IsDigit))
                return "Password must contain at least one number.";
            if (!password.Any(c => !char.IsLetterOrDigit(c)))
                return "Password must contain at least one special character (e.g. @, #, !).";
            return null;
        }

        private static string? ValidateFiles(List<IFormFile> files)
        {
            if (files.Count > MaxFileCount)
                return $"You can upload a maximum of {MaxFileCount} files.";

            foreach (var file in files)
            {
                if (file.Length == 0) return "Empty files are not allowed.";
                if (file.Length > MaxFileSizeBytes) return $"File '{file.FileName}' exceeds the 5 MB size limit.";

                var ext = Path.GetExtension(file.FileName).ToLowerInvariant();
                if (!AllowedExtensions.Contains(ext))
                    return $"File type '{ext}' is not allowed. Allowed: PDF, JPG, JPEG, PNG, DOC, DOCX.";

                // Server-side MIME check (basic magic bytes)
                var allowedMimes = new[] {
                    "application/pdf", "image/jpeg", "image/png",
                    "application/msword",
                    "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                };
                if (!allowedMimes.Contains(file.ContentType.ToLowerInvariant()))
                {
                    // Only reject if MIME is clearly wrong (some browsers send octet-stream)
                    if (file.ContentType != "application/octet-stream")
                        return $"File '{file.FileName}' has an invalid content type.";
                }
            }
            return null;
        }
    }
}
