namespace Registration_Management.Models
{
    public class State
    {
        public int StateId { get; set; }
        public string StateName { get; set; } = string.Empty;
        public bool IsActive { get; set; } = true;
    }
}
