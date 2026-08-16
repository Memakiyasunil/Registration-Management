namespace Registration_Management.Models
{
    public class UserDocument
    {
        public int DocumentId { get; set; }
        public int UserId { get; set; }
        public string OriginalFileName { get; set; } = string.Empty;
        public string StoredFileName { get; set; } = string.Empty;
        public string FileExtension { get; set; } = string.Empty;
        public long FileSizeBytes { get; set; }
        public DateTime UploadedDate { get; set; }
    }
}
