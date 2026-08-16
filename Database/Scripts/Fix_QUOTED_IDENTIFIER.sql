-- ============================================================================
-- Fix for: Microsoft.Data.SqlClient.SqlException
-- 'SELECT failed because the following SET options have incorrect settings: QUOTED_IDENTIFIER'
--
-- Instructions: Execute this script in SQL Server Management Studio (SSMS)
-- against your database (RegistrationDB).
-- ============================================================================

USE [RegistrationDB];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetRegistrationsPaged]
    @PageNumber     INT = 1,
    @PageSize       INT = 10,
    @SearchTerm     NVARCHAR(100) = NULL,
    @FilterName     NVARCHAR(100) = NULL,
    @FilterUsername NVARCHAR(50)  = NULL,
    @FilterStateId  INT           = NULL,
    @FilterGender   NVARCHAR(10)  = NULL,
    @FilterFromDate DATE          = NULL,
    @FilterToDate   DATE          = NULL,
    @SortColumn     NVARCHAR(50)  = 'CreatedDate',
    @SortDirection  NVARCHAR(4)   = 'DESC',
    @TotalCount     INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET QUOTED_IDENTIFIER ON;
    SET ANSI_NULLS ON;

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
    SET QUOTED_IDENTIFIER ON;
    SET ANSI_NULLS ON;
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
END;
GO
