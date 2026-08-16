CREATE TABLE [dbo].[Hobbies] (
    [HobbyId]   INT IDENTITY (1, 1) NOT NULL,
    [HobbyName] NVARCHAR (100)      NOT NULL,
    [IsActive]  BIT                 DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([HobbyId] ASC)
);
