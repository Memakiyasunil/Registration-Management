CREATE PROCEDURE [dbo].[sp_GetUserHobbies]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT uh.UserHobbyId, uh.HobbyId, h.HobbyName
    FROM UserHobbies uh
    INNER JOIN Hobbies h ON uh.HobbyId = h.HobbyId
    WHERE uh.UserId = @UserId;
END
