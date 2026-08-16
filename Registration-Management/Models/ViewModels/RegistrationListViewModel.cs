namespace Registration_Management.Models.ViewModels
{
    public class RegistrationListViewModel
    {
        public List<RegistrationListItem> Registrations { get; set; } = new();
        public int TotalCount { get; set; }
        public int PageNumber { get; set; } = 1;
        public int PageSize { get; set; } = 10;
        public int TotalPages => (int)Math.Ceiling((double)TotalCount / PageSize);

        // Search
        public string? SearchTerm { get; set; }

        // Filters
        public string? FilterName { get; set; }
        public string? FilterUsername { get; set; }
        public int? FilterStateId { get; set; }
        public string? FilterGender { get; set; }
        public DateTime? FilterFromDate { get; set; }
        public DateTime? FilterToDate { get; set; }

        // Sort
        public string SortColumn { get; set; } = "CreatedDate";
        public string SortDirection { get; set; } = "DESC";

        // Lookup data for filter dropdowns
        public List<State> States { get; set; } = new();
    }

    public class RegistrationListItem
    {
        public int UserId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Username { get; set; } = string.Empty;
        public DateTime DateOfBirth { get; set; }
        public string Gender { get; set; } = string.Empty;
        public string Hobbies { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public string StateName { get; set; } = string.Empty;
        public string CityName { get; set; } = string.Empty;
        public string Pincode { get; set; } = string.Empty;
        public DateTime CreatedDate { get; set; }
        public int DocumentCount { get; set; }
    }
}
