using Registration_Management.Models;
using Registration_Management.Models.ViewModels;
using Registration_Management.Repositories;

namespace Registration_Management.Services
{
    public interface IRegistrationService
    {
        Task<bool> IsUsernameAvailableAsync(string username, int excludeUserId = 0);
        Task<(bool Success, string? ErrorMessage)> RegisterAsync(RegistrationViewModel model, IWebHostEnvironment env, IConfiguration config);
        Task<(bool Success, string? ErrorMessage)> UpdateAsync(RegistrationViewModel model, IWebHostEnvironment env, IConfiguration config);
        Task<RegistrationDetailsViewModel?> GetDetailsAsync(int userId);
        Task<RegistrationViewModel?> GetForEditAsync(int userId, IMasterRepository masterRepo);
        Task<(List<RegistrationListItem> Items, int TotalCount)> GetPagedAsync(
            int pageNumber, int pageSize,
            string? searchTerm, string? filterName, string? filterUsername,
            int? filterStateId, string? filterGender, DateTime? filterFromDate, DateTime? filterToDate,
            string sortColumn, string sortDirection);
        Task DeleteAsync(int userId);
        Task<UserDocument?> GetDocumentAsync(int documentId);
        Task DeleteDocumentAsync(int documentId, IWebHostEnvironment env);
    }
}
