CREATE PROCEDURE [dbo].[sp_LoginUser]
    @Username NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT UserId, Name, Username, PasswordHash
    FROM Users
    WHERE Username = @Username
      AND IsActive = 1;
END
