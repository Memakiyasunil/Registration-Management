CREATE PROCEDURE [dbo].[sp_InsertUserHobby]
    @UserId  INT,
    @HobbyId INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO UserHobbies (UserId, HobbyId) VALUES (@UserId, @HobbyId);
END
