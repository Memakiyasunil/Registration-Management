CREATE TABLE [dbo].[States] (
    [StateId]   INT IDENTITY (1, 1) NOT NULL,
    [StateName] NVARCHAR (100)      NOT NULL,
    [IsActive]  BIT                 DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([StateId] ASC)
);
