CREATE PROCEDURE [dbo].[sp_GetDocumentsByUser]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DocumentId, UserId, OriginalFileName, StoredFileName, FileExtension, FileSizeBytes, UploadedDate
    FROM UserDocuments
    WHERE UserId = @UserId
    ORDER BY UploadedDate DESC;
END
