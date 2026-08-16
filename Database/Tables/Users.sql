CREATE TABLE [dbo].[Users] (
    [UserId]       INT            IDENTITY (1, 1) NOT NULL,
    [Name]         NVARCHAR (100) NOT NULL,
    [Username]     NVARCHAR (50)  NOT NULL,
    [PasswordHash] NVARCHAR (256) NOT NULL,
    [DateOfBirth]  DATE           NOT NULL,
    [Gender]       NVARCHAR (10)  NOT NULL,
    [Address]      NVARCHAR (500) NOT NULL,
    [StateId]      INT            NOT NULL,
    [CityId]       INT            NOT NULL,
    [Pincode]      NVARCHAR (6)   NOT NULL,
    [IsActive]     BIT            DEFAULT ((1)) NOT NULL,
    [CreatedDate]  DATETIME       DEFAULT (getdate()) NOT NULL,
    [ModifiedDate] DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([UserId] ASC),
    CONSTRAINT [UQ_Users_Username] UNIQUE NONCLUSTERED ([Username] ASC),
    CONSTRAINT [FK_Users_States] FOREIGN KEY ([StateId]) REFERENCES [dbo].[States] ([StateId]),
    CONSTRAINT [FK_Users_Cities] FOREIGN KEY ([CityId]) REFERENCES [dbo].[Cities] ([CityId])
);
