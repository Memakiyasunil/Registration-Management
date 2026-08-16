CREATE PROCEDURE [dbo].[sp_DeleteDocument]
    @DocumentId INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM UserDocuments WHERE DocumentId = @DocumentId;
END
