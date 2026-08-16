CREATE PROCEDURE [dbo].[sp_GetCitiesByState]
    @StateId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CityId, CityName FROM Cities WHERE StateId = @StateId AND IsActive = 1 ORDER BY CityName;
END
