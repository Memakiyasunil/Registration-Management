using Registration_Management.Models;

namespace Registration_Management.Services
{
    public interface IAccountService
    {
        Task<User?> LoginAsync(string username, string password);
    }
}
