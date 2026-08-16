CREATE PROCEDURE [dbo].[sp_GetDocumentById]
    @DocumentId INT,
    @UserId     INT = NULL   -- NULL = admin / no ownership check
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DocumentId, UserId, OriginalFileName, StoredFileName, FileExtension, FileSizeBytes, UploadedDate
    FROM UserDocuments
    WHERE DocumentId = @DocumentId
      AND (@UserId IS NULL OR UserId = @UserId);
END
