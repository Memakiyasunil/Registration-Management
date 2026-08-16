CREATE PROCEDURE [dbo].[sp_DeleteUserHobbies]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM UserHobbies WHERE UserId = @UserId;
END
