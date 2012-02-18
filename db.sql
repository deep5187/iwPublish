/****** Object:  Table [dbo].[administrator] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[administrator](
	[admin_id] [int] IDENTITY(1,1) NOT NULL,
	[admin_fname] [varchar](256) NULL,
	[admin_lname] [varchar](256) NULL,
	[admin_username] [varchar](64) NOT NULL,
	[admin_password] [varchar](32) NOT NULL,
	[admin_email] [varchar](256) NOT NULL,
	[admin_last_login] [datetime] NULL,
 CONSTRAINT [PK_administrator] PRIMARY KEY CLUSTERED 
(
	[admin_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF


/****** Object:  Table [dbo].[posting] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[posting](
	[pst_id] [int] IDENTITY(1,1) NOT NULL,
	[pst_title] [varchar](256) NOT NULL,
	[pst_summary] [varchar](256) NULL,
	[pst_text] [text] NOT NULL,
	[pst_allow_comments] [bit] NOT NULL,
	[pst_date] [datetime] NOT NULL,
	[pst_hidden] [bit] NOT NULL,
	[admin_id] [int] NOT NULL,
 CONSTRAINT [PK_posting] PRIMARY KEY CLUSTERED 
(
	[pst_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[posting]  WITH CHECK ADD  CONSTRAINT [FK_posting_administrator] FOREIGN KEY([admin_id])
REFERENCES [dbo].[administrator] ([admin_id])
GO
ALTER TABLE [dbo].[posting] CHECK CONSTRAINT [FK_posting_administrator]


/****** Object:  Table [dbo].[category] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[category](
	[cat_id] [int] IDENTITY(1,1) NOT NULL,
	[cat_name] [varchar](256) NOT NULL,
	[cat_rank] [int] NULL,
 CONSTRAINT [PK_category] PRIMARY KEY CLUSTERED 
(
	[cat_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF


/****** Object:  Table [dbo].[posting_category] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[posting_category](
	[cat_id] [int] NOT NULL,
	[pst_id] [int] NOT NULL,
 CONSTRAINT [PK_posting_category] PRIMARY KEY CLUSTERED 
(
	[cat_id] ASC,
	[pst_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[posting_category]  WITH CHECK ADD  CONSTRAINT [FK_posting_category_category] FOREIGN KEY([cat_id])
REFERENCES [dbo].[category] ([cat_id])
GO
ALTER TABLE [dbo].[posting_category] CHECK CONSTRAINT [FK_posting_category_category]
GO
ALTER TABLE [dbo].[posting_category]  WITH CHECK ADD  CONSTRAINT [FK_posting_category_posting] FOREIGN KEY([pst_id])
REFERENCES [dbo].[posting] ([pst_id])
GO
ALTER TABLE [dbo].[posting_category] CHECK CONSTRAINT [FK_posting_category_posting]



/****** Object:  Table [dbo].[comment] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[comment](
	[cmt_id] [int] IDENTITY(1,1) NOT NULL,
	[pst_id] [int] NOT NULL,
	[cmt_name] [varchar](256) NOT NULL,
	[cmt_email] [varchar](256) NULL,
	[cmt_text] [text] NOT NULL,
	[cmt_date] [datetime] NOT NULL,
 CONSTRAINT [PK_comment] PRIMARY KEY CLUSTERED 
(
	[cmt_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[comment]  WITH CHECK ADD  CONSTRAINT [FK_comment_posting] FOREIGN KEY([pst_id])
REFERENCES [dbo].[posting] ([pst_id])
GO
ALTER TABLE [dbo].[comment] CHECK CONSTRAINT [FK_comment_posting]