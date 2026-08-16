CREATE PROCEDURE [dbo].[sp_GetStates]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT StateId, StateName FROM States WHERE IsActive = 1 ORDER BY StateName;
END
