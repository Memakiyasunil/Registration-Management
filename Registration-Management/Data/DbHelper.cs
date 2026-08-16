using Microsoft.Data.SqlClient;

namespace Registration_Management.Data
{
    /// <summary>
    /// ADO.NET connection factory — creates and returns a new SqlConnection.
    /// </summary>
    public class DbHelper
    {
        private readonly string _connectionString;

        public DbHelper(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        /// <summary>
        /// Opens and returns a new SqlConnection. Caller is responsible for disposal.
        /// </summary>
        public SqlConnection CreateConnection()
        {
            var conn = new SqlConnection(_connectionString);
            conn.Open();
            return conn;
        }

        /// <summary>
        /// Asynchronously opens and returns a new SqlConnection.
        /// </summary>
        public async Task<SqlConnection> CreateConnectionAsync()
        {
            var conn = new SqlConnection(_connectionString);
            await conn.OpenAsync();
            return conn;
        }
    }
}
