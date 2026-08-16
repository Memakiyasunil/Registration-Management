CREATE PROCEDURE [dbo].[sp_CheckUsernameAvailability]
    @Username NVARCHAR(50),
    @ExcludeUserId INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(1) AS [Count]
    FROM Users
    WHERE Username = @Username
      AND UserId != @ExcludeUserId
      AND IsActive = 1;
END
