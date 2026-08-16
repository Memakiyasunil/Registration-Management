using Microsoft.Data.SqlClient;
using Registration_Management.Data;
using Registration_Management.Models;

namespace Registration_Management.Repositories
{
    public class MasterRepository : IMasterRepository
    {
        private readonly DbHelper _db;

        public MasterRepository(DbHelper db)
        {
            _db = db;
        }

        public async Task<List<State>> GetStatesAsync()
        {
            var states = new List<State>();
            await using var conn = await _db.CreateConnectionAsync();
            await using var cmd = new SqlCommand("sp_GetStates", conn)
            {
                CommandType = System.Data.CommandType.StoredProcedure
            };
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                states.Add(new State
                {
                    StateId = reader.GetInt32(reader.GetOrdinal("StateId")),
                    StateName = reader.GetString(reader.GetOrdinal("StateName"))
                });
            }
            return states;
        }

        public async Task<List<City>> GetCitiesByStateAsync(int stateId)
        {
            var cities = new List<City>();
            await using var conn = await _db.CreateConnectionAsync();
            await using var cmd = new SqlCommand("sp_GetCitiesByState", conn)
            {
                CommandType = System.Data.CommandType.StoredProcedure
            };
            cmd.Parameters.Add(new SqlParameter("@StateId", System.Data.SqlDbType.Int) { Value = stateId });
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                cities.Add(new City
                {
                    CityId = reader.GetInt32(reader.GetOrdinal("CityId")),
                    StateId = stateId,
                    CityName = reader.GetString(reader.GetOrdinal("CityName"))
                });
            }
            return cities;
        }

        public async Task<List<Hobby>> GetHobbiesAsync()
        {
            var hobbies = new List<Hobby>();
            await using var conn = await _db.CreateConnectionAsync();
            await using var cmd = new SqlCommand("sp_GetHobbies", conn)
            {
                CommandType = System.Data.CommandType.StoredProcedure
            };
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                hobbies.Add(new Hobby
                {
                    HobbyId = reader.GetInt32(reader.GetOrdinal("HobbyId")),
                    HobbyName = reader.GetString(reader.GetOrdinal("HobbyName"))
                });
            }
            return hobbies;
        }
    }
}
