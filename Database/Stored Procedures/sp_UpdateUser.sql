CREATE PROCEDURE [dbo].[sp_UpdateUser]
    @UserId      INT,
    @Name        NVARCHAR(100),
    @Username    NVARCHAR(50),
    @DateOfBirth DATE,
    @Gender      NVARCHAR(10),
    @Address     NVARCHAR(500),
    @StateId     INT,
    @CityId      INT,
    @Pincode     NVARCHAR(6)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Users
    SET
        Name         = @Name,
        Username     = @Username,
        DateOfBirth  = @DateOfBirth,
        Gender       = @Gender,
        Address      = @Address,
        StateId      = @StateId,
        CityId       = @CityId,
        Pincode      = @Pincode,
        ModifiedDate = GETDATE()
    WHERE UserId = @UserId AND IsActive = 1;
END
