CREATE TABLE [dbo].[UserDocuments] (
    [DocumentId]       INT            IDENTITY (1, 1) NOT NULL,
    [UserId]           INT            NOT NULL,
    [OriginalFileName] NVARCHAR (255) NOT NULL,
    [StoredFileName]   NVARCHAR (255) NOT NULL,
    [FileExtension]    NVARCHAR (10)  NOT NULL,
    [FileSizeBytes]    BIGINT         NOT NULL,
    [UploadedDate]     DATETIME       DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([DocumentId] ASC),
    CONSTRAINT [FK_UserDocuments_Users] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([UserId])
);
