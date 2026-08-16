using Registration_Management.Models;
using Registration_Management.Repositories;

namespace Registration_Management.Services
{
    public class AccountService : IAccountService
    {
        private readonly IAccountRepository _accountRepo;

        public AccountService(IAccountRepository accountRepo)
        {
            _accountRepo = accountRepo;
        }

        public async Task<User?> LoginAsync(string username, string password)
        {
            if (string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(password))
                return null;

            var user = await _accountRepo.GetUserByUsernameAsync(username);
            if (user == null) return null;

            // Verify BCrypt hash — never compare plain text
            bool passwordValid = BCrypt.Net.BCrypt.Verify(password, user.PasswordHash);
            return passwordValid ? user : null;
        }
    }
}
