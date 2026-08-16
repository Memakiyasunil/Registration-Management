CREATE TABLE [dbo].[Cities] (
    [CityId]   INT IDENTITY (1, 1) NOT NULL,
    [StateId]  INT                 NOT NULL,
    [CityName] NVARCHAR (100)      NOT NULL,
    [IsActive] BIT                 DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([CityId] ASC),
    CONSTRAINT [FK_Cities_States] FOREIGN KEY ([StateId]) REFERENCES [dbo].[States] ([StateId])
);
