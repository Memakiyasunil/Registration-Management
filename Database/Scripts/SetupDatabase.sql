-- ============================================================
-- Registration Management System — Full Database Setup Script
-- Run this script against your SQL Server instance
-- Database: RegistrationManagementDB
-- ============================================================

USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'RegistrationManagementDB')
BEGIN
    CREATE DATABASE RegistrationManagementDB;
END
GO

USE RegistrationManagementDB;
GO

-- ============================================================
-- TABLES
-- ============================================================

-- States
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'States')
BEGIN
    CREATE TABLE States (
        StateId   INT IDENTITY(1,1) PRIMARY KEY,
        StateName NVARCHAR(100) NOT NULL,
        IsActive  BIT NOT NULL DEFAULT 1
    );
END
GO

-- Cities
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Cities')
BEGIN
    CREATE TABLE Cities (
        CityId    INT IDENTITY(1,1) PRIMARY KEY,
        StateId   INT NOT NULL,
        CityName  NVARCHAR(100) NOT NULL,
        IsActive  BIT NOT NULL DEFAULT 1,
        CONSTRAINT FK_Cities_States FOREIGN KEY (StateId) REFERENCES States(StateId)
    );
END
GO

-- Hobbies
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Hobbies')
BEGIN
    CREATE TABLE Hobbies (
        HobbyId   INT IDENTITY(1,1) PRIMARY KEY,
        HobbyName NVARCHAR(100) NOT NULL,
        IsActive  BIT NOT NULL DEFAULT 1
    );
END
GO

-- Users (Registration)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Users')
BEGIN
    CREATE TABLE Users (
        UserId       INT IDENTITY(1,1) PRIMARY KEY,
        Name         NVARCHAR(100) NOT NULL,
        Username     NVARCHAR(50)  NOT NULL UNIQUE,
        PasswordHash NVARCHAR(256) NOT NULL,
        DateOfBirth  DATE NOT NULL,
        Gender       NVARCHAR(10)  NOT NULL,
        Address      NVARCHAR(500) NOT NULL,
        StateId      INT NOT NULL,
        CityId       INT NOT NULL,
        Pincode      NVARCHAR(6)   NOT NULL,
        IsActive     BIT NOT NULL DEFAULT 1,
        CreatedDate  DATETIME NOT NULL DEFAULT GETDATE(),
        ModifiedDate DATETIME NULL,
        CONSTRAINT FK_Users_States FOREIGN KEY (StateId) REFERENCES States(StateId),
        CONSTRAINT FK_Users_Cities FOREIGN KEY (CityId)  REFERENCES Cities(CityId)
    );
END
GO

-- UserHobbies (many-to-many)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'UserHobbies')
BEGIN
    CREATE TABLE UserHobbies (
        UserHobbyId INT IDENTITY(1,1) PRIMARY KEY,
        UserId      INT NOT NULL,
        HobbyId     INT NOT NULL,
        CONSTRAINT FK_UserHobbies_Users   FOREIGN KEY (UserId)   REFERENCES Users(UserId),
        CONSTRAINT FK_UserHobbies_Hobbies FOREIGN KEY (HobbyId)  REFERENCES Hobbies(HobbyId)
    );
END
GO

-- UserDocuments
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'UserDocuments')
BEGIN
    CREATE TABLE UserDocuments (
        DocumentId       INT IDENTITY(1,1) PRIMARY KEY,
        UserId           INT NOT NULL,
        OriginalFileName NVARCHAR(255) NOT NULL,
        StoredFileName   NVARCHAR(255) NOT NULL,
        FileExtension    NVARCHAR(10)  NOT NULL,
        FileSizeBytes    BIGINT NOT NULL,
        UploadedDate     DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_UserDocuments_Users FOREIGN KEY (UserId) REFERENCES Users(UserId)
    );
END
GO

-- ============================================================
-- SEED DATA
-- ============================================================

-- States
IF NOT EXISTS (SELECT 1 FROM States)
BEGIN
    INSERT INTO States (StateName) VALUES
        ('Andhra Pradesh'),
        ('Assam'),
        ('Bihar'),
        ('Chhattisgarh'),
        ('Delhi'),
        ('Goa'),
        ('Gujarat'),
        ('Haryana'),
        ('Himachal Pradesh'),
        ('Jharkhand'),
        ('Karnataka'),
        ('Kerala'),
        ('Madhya Pradesh'),
        ('Maharashtra'),
        ('Manipur'),
        ('Meghalaya'),
        ('Odisha'),
        ('Punjab'),
        ('Rajasthan'),
        ('Tamil Nadu'),
        ('Telangana'),
        ('Uttar Pradesh'),
        ('Uttarakhand'),
        ('West Bengal');
END
GO

-- Cities (seeded for major states)
IF NOT EXISTS (SELECT 1 FROM Cities)
BEGIN
    -- Gujarat (StateId=7)
    INSERT INTO Cities (StateId, CityName) VALUES
        (7, 'Ahmedabad'), (7, 'Surat'), (7, 'Vadodara'), (7, 'Rajkot'),
        (7, 'Gandhinagar'), (7, 'Bhavnagar'), (7, 'Jamnagar'), (7, 'Surendranagar');

    -- Maharashtra (StateId=14)
    INSERT INTO Cities (StateId, CityName) VALUES
        (14, 'Mumbai'), (14, 'Pune'), (14, 'Nagpur'), (14, 'Nashik'),
        (14, 'Aurangabad'), (14, 'Solapur'), (14, 'Kolhapur'), (14, 'Thane');

    -- Delhi (StateId=5)
    INSERT INTO Cities (StateId, CityName) VALUES
        (5, 'New Delhi'), (5, 'Dwarka'), (5, 'Rohini'), (5, 'Janakpuri'),
        (5, 'Saket'), (5, 'Karol Bagh'), (5, 'Connaught Place'), (5, 'Lajpat Nagar');

    -- Karnataka (StateId=11)
    INSERT INTO Cities (StateId, CityName) VALUES
        (11, 'Bangalore'), (11, 'Mysore'), (11, 'Hubli'), (11, 'Mangalore'),
        (11, 'Belgaum'), (11, 'Shimoga'), (11, 'Davangere'), (11, 'Tumkur');

    -- Tamil Nadu (StateId=20)
    INSERT INTO Cities (StateId, CityName) VALUES
        (20, 'Chennai'), (20, 'Coimbatore'), (20, 'Madurai'), (20, 'Salem'),
        (20, 'Tiruchirappalli'), (20, 'Tiruppur'), (20, 'Erode'), (20, 'Vellore');

    -- Uttar Pradesh (StateId=22)
    INSERT INTO Cities (StateId, CityName) VALUES
        (22, 'Lucknow'), (22, 'Kanpur'), (22, 'Agra'), (22, 'Varanasi'),
        (22, 'Prayagraj'), (22, 'Noida'), (22, 'Meerut'), (22, 'Ghaziabad');

    -- Rajasthan (StateId=19)
    INSERT INTO Cities (StateId, CityName) VALUES
        (19, 'Jaipur'), (19, 'Jodhpur'), (19, 'Udaipur'), (19, 'Ajmer'),
        (19, 'Kota'), (19, 'Bikaner'), (19, 'Alwar'), (19, 'Bharatpur');

    -- West Bengal (StateId=24)
    INSERT INTO Cities (StateId, CityName) VALUES
        (24, 'Kolkata'), (24, 'Siliguri'), (24, 'Durgapur'), (24, 'Asansol'),
        (24, 'Howrah'), (24, 'Bardhaman'), (24, 'Malda'), (24, 'Kharagpur');

    -- Punjab (StateId=18)
    INSERT INTO Cities (StateId, CityName) VALUES
        (18, 'Chandigarh'), (18, 'Ludhiana'), (18, 'Amritsar'), (18, 'Jalandhar'),
        (18, 'Patiala'), (18, 'Bathinda'), (18, 'Mohali'), (18, 'Pathankot');

    -- Telangana (StateId=21)
    INSERT INTO Cities (StateId, CityName) VALUES
        (21, 'Hyderabad'), (21, 'Warangal'), (21, 'Nizamabad'), (21, 'Karimnagar'),
        (21, 'Khammam'), (21, 'Ramagundam'), (21, 'Mahabubnagar'), (21, 'Nalgonda');

    -- Kerala (StateId=12)
    INSERT INTO Cities (StateId, CityName) VALUES
        (12, 'Thiruvananthapuram'), (12, 'Kochi'), (12, 'Kozhikode'), (12, 'Thrissur'),
        (12, 'Kollam'), (12, 'Palakkad'), (12, 'Alappuzha'), (12, 'Kannur');

    -- Madhya Pradesh (StateId=13)
    INSERT INTO Cities (StateId, CityName) VALUES
        (13, 'Bhopal'), (13, 'Indore'), (13, 'Jabalpur'), (13, 'Gwalior'),
        (13, 'Ujjain'), (13, 'Sagar'), (13, 'Dewas'), (13, 'Satna');

    -- Bihar (StateId=3)
    INSERT INTO Cities (StateId, CityName) VALUES
        (3, 'Patna'), (3, 'Gaya'), (3, 'Bhagalpur'), (3, 'Muzaffarpur'),
        (3, 'Purnia'), (3, 'Darbhanga'), (3, 'Ara'), (3, 'Begusarai');

    -- Andhra Pradesh (StateId=1)
    INSERT INTO Cities (StateId, CityName) VALUES
        (1, 'Visakhapatnam'), (1, 'Vijayawada'), (1, 'Guntur'), (1, 'Nellore'),
        (1, 'Kurnool'), (1, 'Kakinada'), (1, 'Tirupati'), (1, 'Rajahmundry');

    -- Haryana (StateId=8)
    INSERT INTO Cities (StateId, CityName) VALUES
        (8, 'Gurugram'), (8, 'Faridabad'), (8, 'Panipat'), (8, 'Ambala'),
        (8, 'Hisar'), (8, 'Rohtak'), (8, 'Karnal'), (8, 'Sonipat');

    -- Goa (StateId=6)
    INSERT INTO Cities (StateId, CityName) VALUES
        (6, 'Panaji'), (6, 'Margao'), (6, 'Vasco da Gama'), (6, 'Mapusa'),
        (6, 'Ponda'), (6, 'Bicholim'), (6, 'Curchorem'), (6, 'Sanquelim');

    -- Assam (StateId=2)
    INSERT INTO Cities (StateId, CityName) VALUES
        (2, 'Guwahati'), (2, 'Silchar'), (2, 'Dibrugarh'), (2, 'Jorhat'),
        (2, 'Nagaon'), (2, 'Tinsukia'), (2, 'Lakhimpur'), (2, 'Tezpur');

    -- Odisha (StateId=17)
    INSERT INTO Cities (StateId, CityName) VALUES
        (17, 'Bhubaneswar'), (17, 'Cuttack'), (17, 'Rourkela'), (17, 'Brahmapur'),
        (17, 'Sambalpur'), (17, 'Puri'), (17, 'Balasore'), (17, 'Bhadrak');

    -- Uttarakhand (StateId=23)
    INSERT INTO Cities (StateId, CityName) VALUES
        (23, 'Dehradun'), (23, 'Haridwar'), (23, 'Roorkee'), (23, 'Rishikesh'),
        (23, 'Kashipur'), (23, 'Rudrapur'), (23, 'Haldwani'), (23, 'Mussoorie');

    -- Himachal Pradesh (StateId=9)
    INSERT INTO Cities (StateId, CityName) VALUES
        (9, 'Shimla'), (9, 'Manali'), (9, 'Dharamshala'), (9, 'Kullu'),
        (9, 'Mandi'), (9, 'Solan'), (9, 'Baddi'), (9, 'Una');

    -- Chhattisgarh (StateId=4)
    INSERT INTO Cities (StateId, CityName) VALUES
        (4, 'Raipur'), (4, 'Bhilai'), (4, 'Durg'), (4, 'Bilaspur'),
        (4, 'Korba'), (4, 'Rajnandgaon'), (4, 'Jagdalpur'), (4, 'Raigarh');

    -- Jharkhand (StateId=10)
    INSERT INTO Cities (StateId, CityName) VALUES
        (10, 'Ranchi'), (10, 'Jamshedpur'), (10, 'Dhanbad'), (10, 'Bokaro'),
        (10, 'Hazaribagh'), (10, 'Deoghar'), (10, 'Giridih'), (10, 'Ramgarh');

    -- Meghalaya (StateId=16)
    INSERT INTO Cities (StateId, CityName) VALUES
        (16, 'Shillong'), (16, 'Tura'), (16, 'Jowai'), (16, 'Nongstoin');

    -- Manipur (StateId=15)
    INSERT INTO Cities (StateId, CityName) VALUES
        (15, 'Imphal'), (15, 'Thoubal'), (15, 'Bishnupur'), (15, 'Churachandpur');
END
GO

-- Hobbies
IF NOT EXISTS (SELECT 1 FROM Hobbies)
BEGIN
    INSERT INTO Hobbies (HobbyName) VALUES
        ('Reading'),
        ('Cricket'),
        ('Football'),
        ('Music'),
        ('Travel'),
        ('Gaming'),
        ('Photography'),
        ('Coding'),
        ('Drawing'),
        ('Cooking'),
        ('Dancing'),
        ('Yoga');
END
GO

-- ============================================================
-- STORED PROCEDURES
-- ============================================================

-- 1. Check Username Availability
IF OBJECT_ID('sp_CheckUsernameAvailability', 'P') IS NOT NULL
    DROP PROCEDURE sp_CheckUsernameAvailability;
GO
CREATE PROCEDURE sp_CheckUsernameAvailability
    @Username NVARCHAR(50),
    @ExcludeUserId INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(1) AS [Count]
    FROM Users
    WHERE Username = @Username
      AND UserId != @ExcludeUserId
      AND IsActive = 1;
END
GO

-- 2. Register User
IF OBJECT_ID('sp_RegisterUser', 'P') IS NOT NULL
    DROP PROCEDURE sp_RegisterUser;
GO
CREATE PROCEDURE sp_RegisterUser
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
GO

-- 3. Login User
IF OBJECT_ID('sp_LoginUser', 'P') IS NOT NULL
    DROP PROCEDURE sp_LoginUser;
GO
CREATE PROCEDURE sp_LoginUser
    @Username NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT UserId, Name, Username, PasswordHash
    FROM Users
    WHERE Username = @Username
      AND IsActive = 1;
END
GO

-- 4. Get User By Id
IF OBJECT_ID('sp_GetUserById', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetUserById;
GO
CREATE PROCEDURE sp_GetUserById
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
GO

-- 5. Get Registrations Paged (with search, filter, sort)
IF OBJECT_ID('sp_GetRegistrationsPaged', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetRegistrationsPaged;
GO
CREATE PROCEDURE sp_GetRegistrationsPaged
    @PageNumber    INT = 1,
    @PageSize      INT = 10,
    @SearchTerm    NVARCHAR(100) = NULL,
    @FilterName    NVARCHAR(100) = NULL,
    @FilterUsername NVARCHAR(50) = NULL,
    @FilterStateId INT = NULL,
    @FilterGender  NVARCHAR(10)  = NULL,
    @FilterFromDate DATE = NULL,
    @FilterToDate   DATE = NULL,
    @SortColumn    NVARCHAR(50)  = 'CreatedDate',
    @SortDirection NVARCHAR(4)   = 'DESC',
    @TotalCount    INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Whitelist sort column to prevent injection
    DECLARE @SafeSortCol NVARCHAR(50) =
        CASE @SortColumn
            WHEN 'Name'        THEN 'u.Name'
            WHEN 'Username'    THEN 'u.Username'
            WHEN 'DateOfBirth' THEN 'u.DateOfBirth'
            WHEN 'CreatedDate' THEN 'u.CreatedDate'
            ELSE 'u.CreatedDate'
        END;

    DECLARE @SafeSortDir NVARCHAR(4) =
        CASE UPPER(@SortDirection) WHEN 'ASC' THEN 'ASC' ELSE 'DESC' END;

    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

    -- Count query
    SELECT @TotalCount = COUNT(1)
    FROM Users u
    WHERE u.IsActive = 1
      AND (@SearchTerm IS NULL OR u.Name LIKE '%' + @SearchTerm + '%' OR u.Username LIKE '%' + @SearchTerm + '%')
      AND (@FilterName IS NULL OR u.Name LIKE '%' + @FilterName + '%')
      AND (@FilterUsername IS NULL OR u.Username LIKE '%' + @FilterUsername + '%')
      AND (@FilterStateId IS NULL OR u.StateId = @FilterStateId)
      AND (@FilterGender IS NULL OR u.Gender = @FilterGender)
      AND (@FilterFromDate IS NULL OR CAST(u.CreatedDate AS DATE) >= @FilterFromDate)
      AND (@FilterToDate IS NULL OR CAST(u.CreatedDate AS DATE) <= @FilterToDate);

    -- Data query with dynamic sort
    DECLARE @SQL NVARCHAR(MAX) = N'
    SELECT
        u.UserId, u.Name, u.Username, u.DateOfBirth, u.Gender,
        u.Address, s.StateName, c.CityName, u.Pincode,
        u.CreatedDate,
        ISNULL(STUFF((
            SELECT '', '' + h.HobbyName
            FROM UserHobbies uh
            INNER JOIN Hobbies h ON uh.HobbyId = h.HobbyId
            WHERE uh.UserId = u.UserId
            FOR XML PATH(''''), TYPE).value(''.'', ''NVARCHAR(MAX)''), 1, 2, ''''), '''') AS Hobbies,
        (SELECT COUNT(1) FROM UserDocuments d WHERE d.UserId = u.UserId) AS DocumentCount
    FROM Users u
    INNER JOIN States s ON u.StateId = s.StateId
    INNER JOIN Cities c ON u.CityId  = c.CityId
    WHERE u.IsActive = 1
      AND (@SearchTerm IS NULL OR u.Name LIKE ''%'' + @SearchTerm + ''%'' OR u.Username LIKE ''%'' + @SearchTerm + ''%'')
      AND (@FilterName IS NULL OR u.Name LIKE ''%'' + @FilterName + ''%'')
      AND (@FilterUsername IS NULL OR u.Username LIKE ''%'' + @FilterUsername + ''%'')
      AND (@FilterStateId IS NULL OR u.StateId = @FilterStateId)
      AND (@FilterGender IS NULL OR u.Gender = @FilterGender)
      AND (@FilterFromDate IS NULL OR CAST(u.CreatedDate AS DATE) >= @FilterFromDate)
      AND (@FilterToDate IS NULL OR CAST(u.CreatedDate AS DATE) <= @FilterToDate)
    ORDER BY ' + @SafeSortCol + ' ' + @SafeSortDir + N'
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;';

    EXEC sp_executesql @SQL,
        N'@SearchTerm NVARCHAR(100), @FilterName NVARCHAR(100), @FilterUsername NVARCHAR(50),
          @FilterStateId INT, @FilterGender NVARCHAR(10), @FilterFromDate DATE, @FilterToDate DATE,
          @Offset INT, @PageSize INT',
        @SearchTerm, @FilterName, @FilterUsername, @FilterStateId, @FilterGender,
        @FilterFromDate, @FilterToDate, @Offset, @PageSize;
END
GO

-- 6. Get States
IF OBJECT_ID('sp_GetStates', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetStates;
GO
CREATE PROCEDURE sp_GetStates
AS
BEGIN
    SET NOCOUNT ON;
    SELECT StateId, StateName FROM States WHERE IsActive = 1 ORDER BY StateName;
END
GO

-- 7. Get Cities By State
IF OBJECT_ID('sp_GetCitiesByState', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetCitiesByState;
GO
CREATE PROCEDURE sp_GetCitiesByState
    @StateId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CityId, CityName FROM Cities WHERE StateId = @StateId AND IsActive = 1 ORDER BY CityName;
END
GO

-- 8. Get Hobbies
IF OBJECT_ID('sp_GetHobbies', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetHobbies;
GO
CREATE PROCEDURE sp_GetHobbies
AS
BEGIN
    SET NOCOUNT ON;
    SELECT HobbyId, HobbyName FROM Hobbies WHERE IsActive = 1 ORDER BY HobbyName;
END
GO

-- 9. Insert User Hobby
IF OBJECT_ID('sp_InsertUserHobby', 'P') IS NOT NULL
    DROP PROCEDURE sp_InsertUserHobby;
GO
CREATE PROCEDURE sp_InsertUserHobby
    @UserId  INT,
    @HobbyId INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO UserHobbies (UserId, HobbyId) VALUES (@UserId, @HobbyId);
END
GO

-- 10. Delete User Hobbies
IF OBJECT_ID('sp_DeleteUserHobbies', 'P') IS NOT NULL
    DROP PROCEDURE sp_DeleteUserHobbies;
GO
CREATE PROCEDURE sp_DeleteUserHobbies
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM UserHobbies WHERE UserId = @UserId;
END
GO

-- 11. Insert Document
IF OBJECT_ID('sp_InsertDocument', 'P') IS NOT NULL
    DROP PROCEDURE sp_InsertDocument;
GO
CREATE PROCEDURE sp_InsertDocument
    @UserId           INT,
    @OriginalFileName NVARCHAR(255),
    @StoredFileName   NVARCHAR(255),
    @FileExtension    NVARCHAR(10),
    @FileSizeBytes    BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO UserDocuments (UserId, OriginalFileName, StoredFileName, FileExtension, FileSizeBytes)
    VALUES (@UserId, @OriginalFileName, @StoredFileName, @FileExtension, @FileSizeBytes);
    SELECT SCOPE_IDENTITY() AS DocumentId;
END
GO

-- 12. Get Documents By User
IF OBJECT_ID('sp_GetDocumentsByUser', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetDocumentsByUser;
GO
CREATE PROCEDURE sp_GetDocumentsByUser
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DocumentId, UserId, OriginalFileName, StoredFileName, FileExtension, FileSizeBytes, UploadedDate
    FROM UserDocuments
    WHERE UserId = @UserId
    ORDER BY UploadedDate DESC;
END
GO

-- 13. Get Document By Id (secure — also verifies ownership)
IF OBJECT_ID('sp_GetDocumentById', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetDocumentById;
GO
CREATE PROCEDURE sp_GetDocumentById
    @DocumentId INT,
    @UserId     INT = NULL   -- NULL = admin / no ownership check
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DocumentId, UserId, OriginalFileName, StoredFileName, FileExtension, FileSizeBytes, UploadedDate
    FROM UserDocuments
    WHERE DocumentId = @DocumentId
      AND (@UserId IS NULL OR UserId = @UserId);
END
GO

-- 14. Update User
IF OBJECT_ID('sp_UpdateUser', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateUser;
GO
CREATE PROCEDURE sp_UpdateUser
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
GO

-- 15. Delete User (Soft Delete)
IF OBJECT_ID('sp_DeleteUser', 'P') IS NOT NULL
    DROP PROCEDURE sp_DeleteUser;
GO
CREATE PROCEDURE sp_DeleteUser
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Users SET IsActive = 0, ModifiedDate = GETDATE() WHERE UserId = @UserId;
END
GO

-- 16. Get User Hobbies
IF OBJECT_ID('sp_GetUserHobbies', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetUserHobbies;
GO
CREATE PROCEDURE sp_GetUserHobbies
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT uh.UserHobbyId, uh.HobbyId, h.HobbyName
    FROM UserHobbies uh
    INNER JOIN Hobbies h ON uh.HobbyId = h.HobbyId
    WHERE uh.UserId = @UserId;
END
GO

-- 17. Delete Document
IF OBJECT_ID('sp_DeleteDocument', 'P') IS NOT NULL
    DROP PROCEDURE sp_DeleteDocument;
GO
CREATE PROCEDURE sp_DeleteDocument
    @DocumentId INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM UserDocuments WHERE DocumentId = @DocumentId;
END
GO

PRINT 'Database setup complete.';
GO
