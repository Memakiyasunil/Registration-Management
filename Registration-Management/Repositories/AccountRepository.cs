using Microsoft.Data.SqlClient;
using Registration_Management.Data;
using Registration_Management.Models;

namespace Registration_Management.Repositories
{
    public class AccountRepository : IAccountRepository
    {
        private readonly DbHelper _db;

        public AccountRepository(DbHelper db)
        {
            _db = db;
        }

        public async Task<User?> GetUserByUsernameAsync(string username)
        {
            await using var conn = await _db.CreateConnectionAsync();
            await using var cmd = new SqlCommand("sp_LoginUser", conn)
            {
                CommandType = System.Data.CommandType.StoredProcedure
            };
            cmd.Parameters.Add(new SqlParameter("@Username", System.Data.SqlDbType.NVarChar, 50) { Value = username });

            await using var reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                return new User
                {
                    UserId = reader.GetInt32(reader.GetOrdinal("UserId")),
                    Name = reader.GetString(reader.GetOrdinal("Name")),
                    Username = reader.GetString(reader.GetOrdinal("Username")),
                    PasswordHash = reader.GetString(reader.GetOrdinal("PasswordHash"))
                };
            }
            return null;
        }
    }
}
