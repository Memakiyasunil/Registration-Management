using Registration_Management.Models;
using Registration_Management.Models.ViewModels;
using Microsoft.Data.SqlClient;

namespace Registration_Management.Repositories
{
    public interface IRegistrationRepository
    {
        Task<bool> IsUsernameAvailableAsync(string username, int excludeUserId = 0);
        Task<int> RegisterUserAsync(RegistrationViewModel model, string passwordHash, SqlTransaction? transaction = null, SqlConnection? conn = null);
        Task InsertUserHobbyAsync(int userId, int hobbyId, SqlTransaction? transaction = null, SqlConnection? conn = null);
        Task DeleteUserHobbiesAsync(int userId, SqlTransaction? transaction = null, SqlConnection? conn = null);
        Task InsertDocumentAsync(int userId, string originalFileName, string storedFileName, string fileExtension, long fileSizeBytes, SqlTransaction? transaction = null, SqlConnection? conn = null);
        Task<(List<RegistrationListItem> Items, int TotalCount)> GetRegistrationsPagedAsync(
            int pageNumber, int pageSize,
            string? searchTerm, string? filterName, string? filterUsername,
            int? filterStateId, string? filterGender, DateTime? filterFromDate, DateTime? filterToDate,
            string sortColumn, string sortDirection);
        Task<User?> GetUserByIdAsync(int userId);
        Task<List<UserHobby>> GetUserHobbiesAsync(int userId);
        Task<List<UserDocument>> GetDocumentsByUserAsync(int userId);
        Task<UserDocument?> GetDocumentByIdAsync(int documentId);
        Task UpdateUserAsync(RegistrationViewModel model, SqlTransaction? transaction = null, SqlConnection? conn = null);
        Task DeleteUserAsync(int userId);
        Task DeleteDocumentAsync(int documentId);
    }
}
