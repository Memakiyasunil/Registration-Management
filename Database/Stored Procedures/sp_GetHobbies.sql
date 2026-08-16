CREATE PROCEDURE [dbo].[sp_GetHobbies]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT HobbyId, HobbyName FROM Hobbies WHERE IsActive = 1 ORDER BY HobbyName;
END
