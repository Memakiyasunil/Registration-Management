using Registration_Management.Models;

namespace Registration_Management.Repositories
{
    public interface IAccountRepository
    {
        Task<User?> GetUserByUsernameAsync(string username);
    }
}
