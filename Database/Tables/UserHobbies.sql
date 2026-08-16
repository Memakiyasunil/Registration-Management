CREATE TABLE [dbo].[UserHobbies] (
    [UserHobbyId] INT IDENTITY (1, 1) NOT NULL,
    [UserId]      INT NOT NULL,
    [HobbyId]     INT NOT NULL,
    PRIMARY KEY CLUSTERED ([UserHobbyId] ASC),
    CONSTRAINT [FK_UserHobbies_Users] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([UserId]),
    CONSTRAINT [FK_UserHobbies_Hobbies] FOREIGN KEY ([HobbyId]) REFERENCES [dbo].[Hobbies] ([HobbyId])
);
