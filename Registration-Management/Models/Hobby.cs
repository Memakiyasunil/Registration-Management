namespace Registration_Management.Models
{
    public class Hobby
    {
        public int HobbyId { get; set; }
        public string HobbyName { get; set; } = string.Empty;
        public bool IsActive { get; set; } = true;
    }
}
