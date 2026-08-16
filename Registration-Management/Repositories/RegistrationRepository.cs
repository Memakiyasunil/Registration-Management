using Microsoft.Data.SqlClient;
using Registration_Management.Data;
using Registration_Management.Models;
using Registration_Management.Models.ViewModels;

namespace Registration_Management.Repositories
{
    public class RegistrationRepository : IRegistrationRepository
    {
        private readonly DbHelper _db;

        public RegistrationRepository(DbHelper db)
        {
            _db = db;
        }

        public async Task<bool> IsUsernameAvailableAsync(string username, int excludeUserId = 0)
        {
            await using var conn = await _db.CreateConnectionAsync();
            await using var cmd = new SqlCommand("sp_CheckUsernameAvailability", conn)
            {
                CommandType = System.Data.CommandType.StoredProcedure
            };
            cmd.Parameters.Add(new SqlParameter("@Username", System.Data.SqlDbType.NVarChar, 50) { Value = username });
            cmd.Parameters.Add(new SqlParameter("@ExcludeUserId", System.Data.SqlDbType.Int) { Value = excludeUserId });
            var count = (int)(await cmd.ExecuteScalarAsync() ?? 0);
            return count == 0;
        }

        public async Task<int> RegisterUserAsync(RegistrationViewModel model, string passwordHash,
            SqlTransaction? transaction = null, SqlConnection? conn = null)
        {
            bool ownConnection = conn == null;
            if (ownConnection) conn = await _db.CreateConnectionAsync();

            try
            {
                await using var cmd = new SqlCommand("sp_RegisterUser", conn)
                {
                    CommandType = System.Data.CommandType.StoredProcedure,
                    Transaction = transaction
                };
                cmd.Parameters.Add(new SqlParameter("@Name", System.Data.SqlDbType.NVarChar, 100) { Value = model.Name });
                cmd.Parameters.Add(new SqlParameter("@Username", System.Data.SqlDbType.NVarChar, 50) { Value = model.Username });
                cmd.Parameters.Add(new SqlParameter("@PasswordHash", System.Data.SqlDbType.NVarChar, 256) { Value = passwordHash });
                cmd.Parameters.Add(new SqlParameter("@DateOfBirth", System.Data.SqlDbType.Date) { Value = model.DateOfBirth!.Value });
                cmd.Parameters.Add(new SqlParameter("@Gender", System.Data.SqlDbType.NVarChar, 10) { Value = model.Gender });
                cmd.Parameters.Add(new SqlParameter("@Address", System.Data.SqlDbType.NVarChar, 500) { Value = model.Address });
                cmd.Parameters.Add(new SqlParameter("@StateId", System.Data.SqlDbType.Int) { Value = model.StateId });
                cmd.Parameters.Add(new SqlParameter("@CityId", System.Data.SqlDbType.Int) { Value = model.CityId });
                cmd.Parameters.Add(new SqlParameter("@Pincode", System.Data.SqlDbType.NVarChar, 6) { Value = model.Pincode });

                var newUserIdParam = new SqlParameter("@NewUserId", System.Data.SqlDbType.Int)
                {
                    Direction = System.Data.ParameterDirection.Output
                };
                cmd.Parameters.Add(newUserIdParam);

                await cmd.ExecuteNonQueryAsync();
                return (int)newUserIdParam.Value;
            }
            finally
            {
                if (ownConnection && conn != null) await conn.DisposeAsync();
            }
        }

        public async Task InsertUserHobbyAsync(int userId, int hobbyId,
            SqlTransaction? transaction = null, SqlConnection? conn = null)
        {
            bool ownConnection = conn == null;
            if (ownConnection) conn = await _db.CreateConnectionAsync();

            try
            {
                await using var cmd = new SqlCommand("sp_InsertUserHobby", conn)
                {
                    CommandType = System.Data.CommandType.StoredProcedure,
                    Transaction = transaction
                };
                cmd.Parameters.Add(new SqlParameter("@UserId", System.Data.SqlDbType.Int) { Value = userId });
                cmd.Parameters.Add(new SqlParameter("@HobbyId", System.Data.SqlDbType.Int) { Value = hobbyId });
                await cmd.ExecuteNonQueryAsync();
            }
            finally
            {
                if (ownConnection && conn != null) await conn.DisposeAsync();
            }
        }

        public async Task DeleteUserHobbiesAsync(int userId,
            SqlTransaction? transaction = null, SqlConnection? conn = null)
        {
            bool ownConnection = conn == null;
            if (ownConnection) conn = await _db.CreateConnectionAsync();

            try
            {
                await using var cmd = new SqlCommand("sp_DeleteUserHobbies", conn)
                {
                    CommandType = System.Data.CommandType.StoredProcedure,
                    Transaction = transaction
                };
                cmd.Parameters.Add(new SqlParameter("@UserId", System.Data.SqlDbType.Int) { Value = userId });
                await cmd.ExecuteNonQueryAsync();
            }
            finally
            {
                if (ownConnection && conn != null) await conn.DisposeAsync();
            }
        }

        public async Task InsertDocumentAsync(int userId, string originalFileName, string storedFileName,
            string fileExtension, long fileSizeBytes,
            SqlTransaction? transaction = null, SqlConnection? conn = null)
        {
            bool ownConnection = conn == null;
            if (ownConnection) conn = await _db.CreateConnectionAsync();

            try
            {
                await using var cmd = new SqlCommand("sp_InsertDocument", conn)
                {
                    CommandType = System.Data.CommandType.StoredProcedure,
                    Transaction = transaction
                };
                cmd.Parameters.Add(new SqlParameter("@UserId", System.Data.SqlDbType.Int) { Value = userId });
                cmd.Parameters.Add(new SqlParameter("@OriginalFileName", System.Data.SqlDbType.NVarChar, 255) { Value = originalFileName });
                cmd.Parameters.Add(new SqlParameter("@StoredFileName", System.Data.SqlDbType.NVarChar, 255) { Value = storedFileName });
                cmd.Parameters.Add(new SqlParameter("@FileExtension", System.Data.SqlDbType.NVarChar, 10) { Value = fileExtension });
                cmd.Parameters.Add(new SqlParameter("@FileSizeBytes", System.Data.SqlDbType.BigInt) { Value = fileSizeBytes });
                await cmd.ExecuteNonQueryAsync();
            }
            finally
            {
                if (ownConnection && conn != null) await conn.DisposeAsync();
            }
        }

        public async Task<(List<RegistrationListItem> Items, int TotalCount)> GetRegistrationsPagedAsync(
            int pageNumber, int pageSize,
            string? searchTerm, string? filterName, string? filterUsername,
            int? filterStateId, string? filterGender, DateTime? filterFromDate, DateTime? filterToDate,
            string sortColumn, string sortDirection)
        {
            var items = new List<RegistrationListItem>();
            int totalCount = 0;

            await using var conn = await _db.CreateConnectionAsync();
            await using var cmd = new SqlCommand("sp_GetRegistrationsPaged", conn)
            {
                CommandType = System.Data.CommandType.StoredProcedure
            };

            cmd.Parameters.Add(new SqlParameter("@PageNumber", System.Data.SqlDbType.Int) { Value = pageNumber });
            cmd.Parameters.Add(new SqlParameter("@PageSize", System.Data.SqlDbType.Int) { Value = pageSize });
            cmd.Parameters.Add(new SqlParameter("@SearchTerm", System.Data.SqlDbType.NVarChar, 100) { Value = (object?)searchTerm ?? DBNull.Value });
            cmd.Parameters.Add(new SqlParameter("@FilterName", System.Data.SqlDbType.NVarChar, 100) { Value = (object?)filterName ?? DBNull.Value });
            cmd.Parameters.Add(new SqlParameter("@FilterUsername", System.Data.SqlDbType.NVarChar, 50) { Value = (object?)filterUsername ?? DBNull.Value });
            cmd.Parameters.Add(new SqlParameter("@FilterStateId", System.Data.SqlDbType.Int) { Value = (object?)filterStateId ?? DBNull.Value });
            cmd.Parameters.Add(new SqlParameter("@FilterGender", System.Data.SqlDbType.NVarChar, 10) { Value = (object?)filterGender ?? DBNull.Value });
            cmd.Parameters.Add(new SqlParameter("@FilterFromDate", System.Data.SqlDbType.Date) { Value = (object?)filterFromDate ?? DBNull.Value });
            cmd.Parameters.Add(new SqlParameter("@FilterToDate", System.Data.SqlDbType.Date) { Value = (object?)filterToDate ?? DBNull.Value });
            cmd.Parameters.Add(new SqlParameter("@SortColumn", System.Data.SqlDbType.NVarChar, 50) { Value = sortColumn });
            cmd.Parameters.Add(new SqlParameter("@SortDirection", System.Data.SqlDbType.NVarChar, 4) { Value = sortDirection });

            var totalParam = new SqlParameter("@TotalCount", System.Data.SqlDbType.Int)
            {
                Direction = System.Data.ParameterDirection.Output
            };
            cmd.Parameters.Add(totalParam);

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                items.Add(new RegistrationListItem
                {
                    UserId = reader.GetInt32(reader.GetOrdinal("UserId")),
                    Name = reader.GetString(reader.GetOrdinal("Name")),
                    Username = reader.GetString(reader.GetOrdinal("Username")),
                    DateOfBirth = reader.GetDateTime(reader.GetOrdinal("DateOfBirth")),
                    Gender = reader.GetString(reader.GetOrdinal("Gender")),
                    Hobbies = reader.IsDBNull(reader.GetOrdinal("Hobbies")) ? "" : reader.GetString(reader.GetOrdinal("Hobbies")),
                    Address = reader.GetString(reader.GetOrdinal("Address")),
                    StateName = reader.GetString(reader.GetOrdinal("StateName")),
                    CityName = reader.GetString(reader.GetOrdinal("CityName")),
                    Pincode = reader.GetString(reader.GetOrdinal("Pincode")),
                    CreatedDate = reader.GetDateTime(reader.GetOrdinal("CreatedDate")),
                    DocumentCount = reader.GetInt32(reader.GetOrdinal("DocumentCount"))
                });
            }

            // Close reader before reading output param
            await reader.CloseAsync();
            totalCount = (int)(totalParam.Value ?? 0);

            return (items, totalCount);
        }

        public async Task<User?> GetUserByIdAsync(int userId)
        {
            await using var conn = await _db.CreateConnectionAsync();
            await using var cmd = new SqlCommand("sp_GetUserById", conn)
            {
                CommandType = System.Data.CommandType.StoredProcedure
            };
            cmd.Parameters.Add(new SqlParameter("@UserId", System.Data.SqlDbType.Int) { Value = userId });

            await using var reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                return new User
                {
                    UserId = reader.GetInt32(reader.GetOrdinal("UserId")),
                    Name = reader.GetString(reader.GetOrdinal("Name")),
                    Username = reader.GetString(reader.GetOrdinal("Username")),
                    DateOfBirth = reader.GetDateTime(reader.GetOrdinal("DateOfBirth")),
                    Gender = reader.GetString(reader.GetOrdinal("Gender")),
                    Address = reader.GetString(reader.GetOrdinal("Address")),
                    StateId = reader.GetInt32(reader.GetOrdinal("StateId")),
                    StateName = reader.GetString(reader.GetOrdinal("StateName")),
                    CityId = reader.GetInt32(reader.GetOrdinal("CityId")),
                    CityName = reader.GetString(reader.GetOrdinal("CityName")),
                    Pincode = reader.GetString(reader.GetOrdinal("Pincode")),
                    IsActive = reader.GetBoolean(reader.GetOrdinal("IsActive")),
                    CreatedDate = reader.GetDateTime(reader.GetOrdinal("CreatedDate")),
                    ModifiedDate = reader.IsDBNull(reader.GetOrdinal("ModifiedDate")) ? null : reader.GetDateTime(reader.GetOrdinal("ModifiedDate"))
                };
            }
            return null;
        }

        public async Task<List<UserHobby>> GetUserHobbiesAsync(int userId)
        {
            var hobbies = new List<UserHobby>();
            await using var conn = await _db.CreateConnectionAsync();
            await using var cmd = new SqlCommand("sp_GetUserHobbies", conn)
            {
                CommandType = System.Data.CommandType.StoredProcedure
            };
            cmd.Parameters.Add(new SqlParameter("@UserId", System.Data.SqlDbType.Int) { Value = userId });
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                hobbies.Add(new UserHobby
                {
                    UserHobbyId = reader.GetInt32(reader.GetOrdinal("UserHobbyId")),
                    HobbyId = reader.GetInt32(reader.GetOrdinal("HobbyId")),
                    HobbyName = reader.GetString(reader.GetOrdinal("HobbyName")),
                    UserId = userId
                });
            }
            return hobbies;
        }

        public async Task<List<UserDocument>> GetDocumentsByUserAsync(int userId)
        {
            var docs = new List<UserDocument>();
            await using var conn = await _db.CreateConnectionAsync();
            await using var cmd = new SqlCommand("sp_GetDocumentsByUser", conn)
            {
                CommandType = System.Data.CommandType.StoredProcedure
            };
            cmd.Parameters.Add(new SqlParameter("@UserId", System.Data.SqlDbType.Int) { Value = userId });
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                docs.Add(MapDocument(reader));
            }
            return docs;
        }

        public async Task<UserDocument?> GetDocumentByIdAsync(int documentId)
        {
            await using var conn = await _db.CreateConnectionAsync();
            await using var cmd = new SqlCommand("sp_GetDocumentById", conn)
            {
                CommandType = System.Data.CommandType.StoredProcedure
            };
            cmd.Parameters.Add(new SqlParameter("@DocumentId", System.Data.SqlDbType.Int) { Value = documentId });
            cmd.Parameters.Add(new SqlParameter("@UserId", System.Data.SqlDbType.Int) { Value = DBNull.Value });
            await using var reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
                return MapDocument(reader);
            return null;
        }

        public async Task UpdateUserAsync(RegistrationViewModel model,
            SqlTransaction? transaction = null, SqlConnection? conn = null)
        {
            bool ownConnection = conn == null;
            if (ownConnection) conn = await _db.CreateConnectionAsync();

            try
            {
                await using var cmd = new SqlCommand("sp_UpdateUser", conn)
                {
                    CommandType = System.Data.CommandType.StoredProcedure,
                    Transaction = transaction
                };
                cmd.Parameters.Add(new SqlParameter("@UserId", System.Data.SqlDbType.Int) { Value = model.UserId });
                cmd.Parameters.Add(new SqlParameter("@Name", System.Data.SqlDbType.NVarChar, 100) { Value = model.Name });
                cmd.Parameters.Add(new SqlParameter("@Username", System.Data.SqlDbType.NVarChar, 50) { Value = model.Username });
                cmd.Parameters.Add(new SqlParameter("@DateOfBirth", System.Data.SqlDbType.Date) { Value = model.DateOfBirth!.Value });
                cmd.Parameters.Add(new SqlParameter("@Gender", System.Data.SqlDbType.NVarChar, 10) { Value = model.Gender });
                cmd.Parameters.Add(new SqlParameter("@Address", System.Data.SqlDbType.NVarChar, 500) { Value = model.Address });
                cmd.Parameters.Add(new SqlParameter("@StateId", System.Data.SqlDbType.Int) { Value = model.StateId });
                cmd.Parameters.Add(new SqlParameter("@CityId", System.Data.SqlDbType.Int) { Value = model.CityId });
                cmd.Parameters.Add(new SqlParameter("@Pincode", System.Data.SqlDbType.NVarChar, 6) { Value = model.Pincode });
                await cmd.ExecuteNonQueryAsync();
            }
            finally
            {
                if (ownConnection && conn != null) await conn.DisposeAsync();
            }
        }

        public async Task DeleteUserAsync(int userId)
        {
            await using var conn = await _db.CreateConnectionAsync();
            await using var cmd = new SqlCommand("sp_DeleteUser", conn)
            {
                CommandType = System.Data.CommandType.StoredProcedure
            };
            cmd.Parameters.Add(new SqlParameter("@UserId", System.Data.SqlDbType.Int) { Value = userId });
            await cmd.ExecuteNonQueryAsync();
        }

        public async Task DeleteDocumentAsync(int documentId)
        {
            await using var conn = await _db.CreateConnectionAsync();
            await using var cmd = new SqlCommand("sp_DeleteDocument", conn)
            {
                CommandType = System.Data.CommandType.StoredProcedure
            };
            cmd.Parameters.Add(new SqlParameter("@DocumentId", System.Data.SqlDbType.Int) { Value = documentId });
            await cmd.ExecuteNonQueryAsync();
        }

        private static UserDocument MapDocument(SqlDataReader reader) => new()
        {
            DocumentId = reader.GetInt32(reader.GetOrdinal("DocumentId")),
            UserId = reader.GetInt32(reader.GetOrdinal("UserId")),
            OriginalFileName = reader.GetString(reader.GetOrdinal("OriginalFileName")),
            StoredFileName = reader.GetString(reader.GetOrdinal("StoredFileName")),
            FileExtension = reader.GetString(reader.GetOrdinal("FileExtension")),
            FileSizeBytes = reader.GetInt64(reader.GetOrdinal("FileSizeBytes")),
            UploadedDate = reader.GetDateTime(reader.GetOrdinal("UploadedDate"))
        };
    }
}
