using Registration_Management.Models;

namespace Registration_Management.Repositories
{
    public interface IMasterRepository
    {
        Task<List<State>> GetStatesAsync();
        Task<List<City>> GetCitiesByStateAsync(int stateId);
        Task<List<Hobby>> GetHobbiesAsync();
    }
}
