USE [master]
GO
/****** Object:  Database [iwPublish]    Script Date: 02/01/2012 17:38:55 ******/
CREATE DATABASE [iwPublish] ON  PRIMARY 
( NAME = N'iwPublish', FILENAME = N'c:\Program Files\Microsoft SQL Server\MSSQL10_50.SQLEXPRESS\MSSQL\DATA\iwPublish.mdf' , SIZE = 2048KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'iwPublish_log', FILENAME = N'c:\Program Files\Microsoft SQL Server\MSSQL10_50.SQLEXPRESS\MSSQL\DATA\iwPublish_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [iwPublish] SET COMPATIBILITY_LEVEL = 100
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [iwPublish].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [iwPublish] SET ANSI_NULL_DEFAULT OFF
GO
ALTER DATABASE [iwPublish] SET ANSI_NULLS OFF
GO
ALTER DATABASE [iwPublish] SET ANSI_PADDING OFF
GO
ALTER DATABASE [iwPublish] SET ANSI_WARNINGS OFF
GO
ALTER DATABASE [iwPublish] SET ARITHABORT OFF
GO
ALTER DATABASE [iwPublish] SET AUTO_CLOSE OFF
GO
ALTER DATABASE [iwPublish] SET AUTO_CREATE_STATISTICS ON
GO
ALTER DATABASE [iwPublish] SET AUTO_SHRINK OFF
GO
ALTER DATABASE [iwPublish] SET AUTO_UPDATE_STATISTICS ON
GO
ALTER DATABASE [iwPublish] SET CURSOR_CLOSE_ON_COMMIT OFF
GO
ALTER DATABASE [iwPublish] SET CURSOR_DEFAULT  GLOBAL
GO
ALTER DATABASE [iwPublish] SET CONCAT_NULL_YIELDS_NULL OFF
GO
ALTER DATABASE [iwPublish] SET NUMERIC_ROUNDABORT OFF
GO
ALTER DATABASE [iwPublish] SET QUOTED_IDENTIFIER OFF
GO
ALTER DATABASE [iwPublish] SET RECURSIVE_TRIGGERS OFF
GO
ALTER DATABASE [iwPublish] SET  DISABLE_BROKER
GO
ALTER DATABASE [iwPublish] SET AUTO_UPDATE_STATISTICS_ASYNC OFF
GO
ALTER DATABASE [iwPublish] SET DATE_CORRELATION_OPTIMIZATION OFF
GO
ALTER DATABASE [iwPublish] SET TRUSTWORTHY OFF
GO
ALTER DATABASE [iwPublish] SET ALLOW_SNAPSHOT_ISOLATION OFF
GO
ALTER DATABASE [iwPublish] SET PARAMETERIZATION SIMPLE
GO
ALTER DATABASE [iwPublish] SET READ_COMMITTED_SNAPSHOT OFF
GO
ALTER DATABASE [iwPublish] SET HONOR_BROKER_PRIORITY OFF
GO
ALTER DATABASE [iwPublish] SET  READ_WRITE
GO
ALTER DATABASE [iwPublish] SET RECOVERY SIMPLE
GO
ALTER DATABASE [iwPublish] SET  MULTI_USER
GO
ALTER DATABASE [iwPublish] SET PAGE_VERIFY CHECKSUM
GO
ALTER DATABASE [iwPublish] SET DB_CHAINING OFF
GO
USE [iwPublish]
GO
/****** Object:  ForeignKey [FK_option_question]    Script Date: 02/01/2012 17:38:57 ******/
ALTER TABLE [dbo].[option] DROP CONSTRAINT [FK_option_question]
GO
/****** Object:  ForeignKey [FK_question_administrator]    Script Date: 02/01/2012 17:38:57 ******/
ALTER TABLE [dbo].[question] DROP CONSTRAINT [FK_question_administrator]
GO
/****** Object:  ForeignKey [FK_question_category]    Script Date: 02/01/2012 17:38:57 ******/
ALTER TABLE [dbo].[question] DROP CONSTRAINT [FK_question_category]
GO
/****** Object:  ForeignKey [FK_question_option]    Script Date: 02/01/2012 17:38:57 ******/
ALTER TABLE [dbo].[question] DROP CONSTRAINT [FK_question_option]
GO
/****** Object:  ForeignKey [FK_posting_administrator]    Script Date: 02/01/2012 17:38:57 ******/
ALTER TABLE [dbo].[posting] DROP CONSTRAINT [FK_posting_administrator]
GO
/****** Object:  ForeignKey [FK_posting_category_category]    Script Date: 02/01/2012 17:38:57 ******/
ALTER TABLE [dbo].[posting_category] DROP CONSTRAINT [FK_posting_category_category]
GO
/****** Object:  ForeignKey [FK_posting_category_posting]    Script Date: 02/01/2012 17:38:57 ******/
ALTER TABLE [dbo].[posting_category] DROP CONSTRAINT [FK_posting_category_posting]
GO
/****** Object:  ForeignKey [FK_comment_posting]    Script Date: 02/01/2012 17:38:57 ******/
ALTER TABLE [dbo].[comment] DROP CONSTRAINT [FK_comment_posting]
GO
/****** Object:  Table [dbo].[comment]    Script Date: 02/01/2012 17:38:57 ******/
ALTER TABLE [dbo].[comment] DROP CONSTRAINT [FK_comment_posting]
GO
DROP TABLE [dbo].[comment]
GO
/****** Object:  Table [dbo].[posting_category]    Script Date: 02/01/2012 17:38:57 ******/
ALTER TABLE [dbo].[posting_category] DROP CONSTRAINT [FK_posting_category_category]
GO
ALTER TABLE [dbo].[posting_category] DROP CONSTRAINT [FK_posting_category_posting]
GO
DROP TABLE [dbo].[posting_category]
GO
/****** Object:  Table [dbo].[posting]    Script Date: 02/01/2012 17:38:57 ******/
ALTER TABLE [dbo].[posting] DROP CONSTRAINT [FK_posting_administrator]
GO
DROP TABLE [dbo].[posting]
GO
/****** Object:  Table [dbo].[administrator]    Script Date: 02/01/2012 17:38:57 ******/
DROP TABLE [dbo].[administrator]
GO
/****** Object:  Table [dbo].[question]    Script Date: 02/01/2012 17:38:57 ******/
ALTER TABLE [dbo].[question] DROP CONSTRAINT [FK_question_administrator]
GO
ALTER TABLE [dbo].[question] DROP CONSTRAINT [FK_question_category]
GO
ALTER TABLE [dbo].[question] DROP CONSTRAINT [FK_question_option]
GO
DROP TABLE [dbo].[question]
GO
/****** Object:  Table [dbo].[category]    Script Date: 02/01/2012 17:38:57 ******/
DROP TABLE [dbo].[category]
GO
/****** Object:  Table [dbo].[option]    Script Date: 02/01/2012 17:38:57 ******/
ALTER TABLE [dbo].[option] DROP CONSTRAINT [FK_option_question]
GO
DROP TABLE [dbo].[option]
GO
/****** Object:  Table [dbo].[option]    Script Date: 02/01/2012 17:38:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[option](
	[opt_id] [int] IDENTITY(1,1) NOT NULL,
	[q_id] [int] NOT NULL,
	[opt_text] [text] NOT NULL,
 CONSTRAINT [PK_option] PRIMARY KEY CLUSTERED 
(
	[opt_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[option] ON
INSERT [dbo].[option] ([opt_id], [q_id], [opt_text]) VALUES (2, 1, N'Option23')
INSERT [dbo].[option] ([opt_id], [q_id], [opt_text]) VALUES (4, 1, N'Option1')
SET IDENTITY_INSERT [dbo].[option] OFF
/****** Object:  Table [dbo].[category]    Script Date: 02/01/2012 17:38:57 ******/
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
GO
SET IDENTITY_INSERT [dbo].[category] ON
INSERT [dbo].[category] ([cat_id], [cat_name], [cat_rank]) VALUES (1, N'CATnews', 1)
SET IDENTITY_INSERT [dbo].[category] OFF
/****** Object:  Table [dbo].[question]    Script Date: 02/01/2012 17:38:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[question](
	[q_id] [int] IDENTITY(1,1) NOT NULL,
	[q_name] [varchar](250) NULL,
	[cat_id] [int] NULL,
	[q_date] [date] NULL,
	[q_instruction] [text] NULL,
	[q_text] [text] NULL,
	[q_diagram] [text] NULL,
	[q_ans_id] [int] NULL,
	[admin_id] [int] NULL,
	[q_solution] [text] NULL,
 CONSTRAINT [PK_questions] PRIMARY KEY CLUSTERED 
(
	[q_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
SET IDENTITY_INSERT [dbo].[question] ON
INSERT [dbo].[question] ([q_id], [q_name], [cat_id], [q_date], [q_instruction], [q_text], [q_diagram], [q_ans_id], [admin_id], [q_solution]) VALUES (1, N'Question 1', NULL, CAST(0x66330B00 AS Date), N'Test Instruction', N'Test Question', NULL, NULL, 1, N'Test Solution')
SET IDENTITY_INSERT [dbo].[question] OFF
/****** Object:  Table [dbo].[administrator]    Script Date: 02/01/2012 17:38:57 ******/
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
GO
SET IDENTITY_INSERT [dbo].[administrator] ON
INSERT [dbo].[administrator] ([admin_id], [admin_fname], [admin_lname], [admin_username], [admin_password], [admin_email], [admin_last_login]) VALUES (1, N'Deep', N'Shah', N'deshah', N'1krishna', N'deep5187@gmail.com', NULL)
SET IDENTITY_INSERT [dbo].[administrator] OFF
/****** Object:  Table [dbo].[posting]    Script Date: 02/01/2012 17:38:57 ******/
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
SET IDENTITY_INSERT [dbo].[posting] ON
INSERT [dbo].[posting] ([pst_id], [pst_title], [pst_summary], [pst_text], [pst_allow_comments], [pst_date], [pst_hidden], [admin_id]) VALUES (1, N'First Post', N'This is to test the setup on the local server.', N'This is to test the setup on the local server.', 1, CAST(0x00009FE800000000 AS DateTime), 0, 1)
INSERT [dbo].[posting] ([pst_id], [pst_title], [pst_summary], [pst_text], [pst_allow_comments], [pst_date], [pst_hidden], [admin_id]) VALUES (2, N'Test 2 ', N'Showing sumit the design', N'Testing to show sumit the design', 1, CAST(0x00009FE800000000 AS DateTime), 0, 1)
INSERT [dbo].[posting] ([pst_id], [pst_title], [pst_summary], [pst_text], [pst_allow_comments], [pst_date], [pst_hidden], [admin_id]) VALUES (4, N'Sorting test', N'sorting test', N'Testing sort functionality', 1, CAST(0x00009FD200000000 AS DateTime), 0, 1)
SET IDENTITY_INSERT [dbo].[posting] OFF
/****** Object:  Table [dbo].[posting_category]    Script Date: 02/01/2012 17:38:57 ******/
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
INSERT [dbo].[posting_category] ([cat_id], [pst_id]) VALUES (1, 1)
INSERT [dbo].[posting_category] ([cat_id], [pst_id]) VALUES (1, 2)
INSERT [dbo].[posting_category] ([cat_id], [pst_id]) VALUES (1, 4)
/****** Object:  Table [dbo].[comment]    Script Date: 02/01/2012 17:38:57 ******/
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
/****** Object:  ForeignKey [FK_option_question]    Script Date: 02/01/2012 17:38:57 ******/
ALTER TABLE [dbo].[option]  WITH CHECK ADD  CONSTRAINT [FK_option_question] FOREIGN KEY([q_id])
REFERENCES [dbo].[question] ([q_id])
GO
ALTER TABLE [dbo].[option] CHECK CONSTRAINT [FK_option_question]
GO
/****** Object:  ForeignKey [FK_question_administrator]    Script Date: 02/01/2012 17:38:57 ******/
ALTER TABLE [dbo].[question]  WITH CHECK ADD  CONSTRAINT [FK_question_administrator] FOREIGN KEY([admin_id])
REFERENCES [dbo].[administrator] ([admin_id])
GO
ALTER TABLE [dbo].[question] CHECK CONSTRAINT [FK_question_administrator]
GO
/****** Object:  ForeignKey [FK_question_category]    Script Date: 02/01/2012 17:38:57 ******/
ALTER TABLE [dbo].[question]  WITH CHECK ADD  CONSTRAINT [FK_question_category] FOREIGN KEY([cat_id])
REFERENCES [dbo].[category] ([cat_id])
GO
ALTER TABLE [dbo].[question] CHECK CONSTRAINT [FK_question_category]
GO
/****** Object:  ForeignKey [FK_question_option]    Script Date: 02/01/2012 17:38:57 ******/
ALTER TABLE [dbo].[question]  WITH CHECK ADD  CONSTRAINT [FK_question_option] FOREIGN KEY([q_ans_id])
REFERENCES [dbo].[option] ([opt_id])
GO
ALTER TABLE [dbo].[question] CHECK CONSTRAINT [FK_question_option]
GO
/****** Object:  ForeignKey [FK_posting_administrator]    Script Date: 02/01/2012 17:38:57 ******/
ALTER TABLE [dbo].[posting]  WITH CHECK ADD  CONSTRAINT [FK_posting_administrator] FOREIGN KEY([admin_id])
REFERENCES [dbo].[administrator] ([admin_id])
GO
ALTER TABLE [dbo].[posting] CHECK CONSTRAINT [FK_posting_administrator]
GO
/****** Object:  ForeignKey [FK_posting_category_category]    Script Date: 02/01/2012 17:38:57 ******/
ALTER TABLE [dbo].[posting_category]  WITH CHECK ADD  CONSTRAINT [FK_posting_category_category] FOREIGN KEY([cat_id])
REFERENCES [dbo].[category] ([cat_id])
GO
ALTER TABLE [dbo].[posting_category] CHECK CONSTRAINT [FK_posting_category_category]
GO
/****** Object:  ForeignKey [FK_posting_category_posting]    Script Date: 02/01/2012 17:38:57 ******/
ALTER TABLE [dbo].[posting_category]  WITH CHECK ADD  CONSTRAINT [FK_posting_category_posting] FOREIGN KEY([pst_id])
REFERENCES [dbo].[posting] ([pst_id])
GO
ALTER TABLE [dbo].[posting_category] CHECK CONSTRAINT [FK_posting_category_posting]
GO
/****** Object:  ForeignKey [FK_comment_posting]    Script Date: 02/01/2012 17:38:57 ******/
ALTER TABLE [dbo].[comment]  WITH CHECK ADD  CONSTRAINT [FK_comment_posting] FOREIGN KEY([pst_id])
REFERENCES [dbo].[posting] ([pst_id])
GO
ALTER TABLE [dbo].[comment] CHECK CONSTRAINT [FK_comment_posting]
GO
