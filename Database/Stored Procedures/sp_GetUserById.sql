CREATE PROCEDURE [dbo].[sp_GetUserById]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        u.UserId, u.Name, u.Username, u.DateOfBirth, u.Gender,
        u.Address, u.StateId, s.StateName, u.CityId, c.CityName,
        u.Pincode, u.IsActive, u.CreatedDate, u.ModifiedDate
    FROM Users u
    INNER JOIN States s ON u.StateId = s.StateId
    INNER JOIN Cities c ON u.CityId  = c.CityId
    WHERE u.UserId = @UserId AND u.IsActive = 1;
END
