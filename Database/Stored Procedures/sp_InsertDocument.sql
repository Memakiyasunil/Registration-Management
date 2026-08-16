CREATE PROCEDURE [dbo].[sp_InsertDocument]
    @UserId           INT,
    @OriginalFileName NVARCHAR(255),
    @StoredFileName   NVARCHAR(255),
    @FileExtension    NVARCHAR(10),
    @FileSizeBytes    BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO UserDocuments (UserId, OriginalFileName, StoredFileName, FileExtension, FileSizeBytes)
    VALUES (@UserId, @OriginalFileName, @StoredFileName, @FileExtension, @FileSizeBytes);
    SELECT SCOPE_IDENTITY() AS DocumentId;
END
