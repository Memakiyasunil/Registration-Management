namespace Registration_Management.Models
{
    public class UserHobby
    {
        public int UserHobbyId { get; set; }
        public int UserId { get; set; }
        public int HobbyId { get; set; }
        public string HobbyName { get; set; } = string.Empty;
    }
}
