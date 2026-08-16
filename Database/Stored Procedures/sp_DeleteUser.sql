CREATE PROCEDURE [dbo].[sp_DeleteUser]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Users SET IsActive = 0, ModifiedDate = GETDATE() WHERE UserId = @UserId;
END
