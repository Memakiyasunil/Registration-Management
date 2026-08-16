CREATE PROCEDURE [dbo].[sp_RegisterUser]
    @Name         NVARCHAR(100),
    @Username     NVARCHAR(50),
    @PasswordHash NVARCHAR(256),
    @DateOfBirth  DATE,
    @Gender       NVARCHAR(10),
    @Address      NVARCHAR(500),
    @StateId      INT,
    @CityId       INT,
    @Pincode      NVARCHAR(6),
    @NewUserId    INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Users (Name, Username, PasswordHash, DateOfBirth, Gender, Address, StateId, CityId, Pincode)
    VALUES (@Name, @Username, @PasswordHash, @DateOfBirth, @Gender, @Address, @StateId, @CityId, @Pincode);
    SET @NewUserId = SCOPE_IDENTITY();
END
