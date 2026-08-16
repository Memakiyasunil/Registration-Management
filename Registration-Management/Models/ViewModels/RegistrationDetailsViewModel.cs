namespace Registration_Management.Models.ViewModels
{
    public class RegistrationDetailsViewModel
    {
        public User User { get; set; } = new();
        public List<UserHobby> Hobbies { get; set; } = new();
        public List<UserDocument> Documents { get; set; } = new();
    }
}
