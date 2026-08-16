namespace Registration_Management.Models
{
    public class City
    {
        public int CityId { get; set; }
        public int StateId { get; set; }
        public string CityName { get; set; } = string.Empty;
        public bool IsActive { get; set; } = true;
    }
}
