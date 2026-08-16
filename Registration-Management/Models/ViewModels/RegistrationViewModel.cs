using System.ComponentModel.DataAnnotations;

namespace Registration_Management.Models.ViewModels
{
    public class RegistrationViewModel
    {
        public int UserId { get; set; }

        // --- Name ---
        [Required(ErrorMessage = "Name is required.")]
        [StringLength(100, MinimumLength = 2, ErrorMessage = "Name must be between 2 and 100 characters.")]
        [Display(Name = "Full Name")]
        public string Name { get; set; } = string.Empty;

        // --- Username ---
        [Required(ErrorMessage = "Username is required.")]
        [StringLength(50, MinimumLength = 4, ErrorMessage = "Username must be between 4 and 50 characters.")]
        [RegularExpression(@"^[a-zA-Z0-9_]+$", ErrorMessage = "Username can only contain letters, numbers, and underscores.")]
        [Display(Name = "Username")]
        public string Username { get; set; } = string.Empty;

        // --- Password (only required on Create) ---
        [DataType(DataType.Password)]
        [Display(Name = "Password")]
        public string? Password { get; set; }

        [DataType(DataType.Password)]
        [Display(Name = "Confirm Password")]
        [Compare("Password", ErrorMessage = "Password and Confirm Password do not match.")]
        public string? ConfirmPassword { get; set; }

        // --- Date of Birth ---
        [Required(ErrorMessage = "Date of Birth is required.")]
        [DataType(DataType.Date)]
        [Display(Name = "Date of Birth")]
        public DateTime? DateOfBirth { get; set; }

        // --- Gender ---
        [Required(ErrorMessage = "Gender is required.")]
        [Display(Name = "Gender")]
        public string Gender { get; set; } = string.Empty;

        // --- Hobbies ---
        [Display(Name = "Hobbies")]
        public List<int> SelectedHobbyIds { get; set; } = new();

        // --- Address ---
        [Required(ErrorMessage = "Address is required.")]
        [StringLength(500, MinimumLength = 10, ErrorMessage = "Address must be between 10 and 500 characters.")]
        [Display(Name = "Address")]
        public string Address { get; set; } = string.Empty;

        // --- State ---
        [Required(ErrorMessage = "State is required.")]
        [Range(1, int.MaxValue, ErrorMessage = "Please select a state.")]
        [Display(Name = "State")]
        public int StateId { get; set; }

        // --- City ---
        [Required(ErrorMessage = "City is required.")]
        [Range(1, int.MaxValue, ErrorMessage = "Please select a city.")]
        [Display(Name = "City")]
        public int CityId { get; set; }

        // --- Pincode ---
        [Required(ErrorMessage = "Pincode is required.")]
        [RegularExpression(@"^\d{6}$", ErrorMessage = "Pincode must be exactly 6 digits.")]
        [Display(Name = "Pincode")]
        public string Pincode { get; set; } = string.Empty;

        // --- Documents ---
        [Display(Name = "Documents")]
        public List<IFormFile> Documents { get; set; } = new();

        // --- Lookup data (populated by controller) ---
        public List<State> States { get; set; } = new();
        public List<City> Cities { get; set; } = new();
        public List<Hobby> AllHobbies { get; set; } = new();
        public List<UserDocument> ExistingDocuments { get; set; } = new();
    }
}
