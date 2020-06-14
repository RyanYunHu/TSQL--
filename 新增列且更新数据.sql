If exists(select * from   dbo.sysobjects where id = object_id(N'dbo.PROC_CREATE_VAR') and OBJECTPROPERTY(id, N'IsProcedure') = 1)  
drop procedure dbo.PROC_CREATE_VAR

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [DBO].[PROC_CREATE_VAR](
	@STOCKNAME NVARCHAR(200),
	@CUSTOMER NVARCHAR(200),
	@GATHER_TO_LEVEL NVARCHAR(50),
	@NEW_COLUMN NVARCHAR(200),
	@GATHER_FUNCTION NVARCHAR(50),
	@GATHER_VAR NVARCHAR(200),
	@GATHER_FROM_LEVEL NVARCHAR(50),
	@CONDITION_COLUMN NVARCHAR(200),
	@CONDITION_SIGN NVARCHAR(50),
	@CONDITION_VALUE NVARCHAR(2000),
	@RULE_START_DATE NVARCHAR(50),
	@RULE_END_DATE NVARCHAR(50)
	)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @STOCK_1 NVARCHAR(200)
	DECLARE @CUSTOMER_1 NVARCHAR(200)
	DECLARE @GATHER_TO_LEVEL_1 NVARCHAR(50)
	DECLARE @NEW_COLUMN_1 NVARCHAR(200)
	DECLARE @GATHER_FUNCTION_1 NVARCHAR(50)
	DECLARE @GATHER_VAR_1 NVARCHAR(200)
	DECLARE @GATHER_FROM_LEVEL_1 NVARCHAR(50)
	DECLARE @CONDITION_COLUMN_1 NVARCHAR(200)
	DECLARE @CONDITION_SIGN_1 NVARCHAR(50)
	DECLARE @CONDITION_VALUE_1 NVARCHAR(2000)
	DECLARE @CONDITION_VALUE_SPLIT NVARCHAR(50)
	DECLARE @CONDITION_VALUE_SIGN NVARCHAR(50)
	DECLARE @CONDITION_VALUE_NUM int
	DECLARE @RULE_START_DATE_1 nvarchar(50)
	DECLARE @RULE_END_DATE_1 nvarchar(50)	
	DECLARE @i INT
	DECLARE @GATHER_DIM NVARCHAR(200)
	DECLARE @TABLENAME NVARCHAR(200)
	DECLARE @SQL1	NVARCHAR(2000)
	DECLARE @SQL2	NVARCHAR(2000)
	
	SET @STOCK_1 = @STOCKNAME
	SET @CUSTOMER_1=@CUSTOMER
	SET @GATHER_TO_LEVEL_1 = @GATHER_TO_LEVEL
	SET @NEW_COLUMN_1 = @NEW_COLUMN
	SET @GATHER_FUNCTION_1 = @GATHER_FUNCTION
	SET @GATHER_VAR_1 = @GATHER_VAR
	SET @GATHER_FROM_LEVEL_1 = @GATHER_FROM_LEVEL
	SET @CONDITION_COLUMN_1 = @CONDITION_COLUMN
	
	IF trim(@CONDITION_SIGN) = N'����'
		set @CONDITION_SIGN_1 = N' like '
	else if trim(@CONDITION_SIGN) = N'������'
		set @CONDITION_SIGN_1 = N' not like '
	else if trim(@CONDITION_SIGN) = N'��...��ͷ'
		set @CONDITION_SIGN_1 = N' = '
	else if trim(@CONDITION_SIGN) = N'����...��ͷ'
		set @CONDITION_SIGN_1 = N' <> '
	else if trim(@CONDITION_SIGN) = N'������'
		set @CONDITION_SIGN_1 = N' <> '
	else 
		set @CONDITION_SIGN_1 = trim(@CONDITION_SIGN)

	IF LEFT(TRIM(@CONDITION_VALUE),1)='|' AND RIGHT(TRIM(@CONDITION_VALUE),1)<>'|'
		SET @CONDITION_VALUE_1 = RIGHT(TRIM(@CONDITION_VALUE),LEN(TRIM(@CONDITION_VALUE))-1)
	ELSE IF LEFT(TRIM(@CONDITION_VALUE),1)='&' AND RIGHT(TRIM(@CONDITION_VALUE),1)<>'&'
		SET @CONDITION_VALUE_1 = RIGHT(TRIM(@CONDITION_VALUE),LEN(TRIM(@CONDITION_VALUE))-1)
	ELSE IF RIGHT(TRIM(@CONDITION_VALUE),1)='|' AND LEFT(TRIM(@CONDITION_VALUE),1)<>'|' 
		SET @CONDITION_VALUE_1 = LEFT(TRIM(@CONDITION_VALUE),LEN(TRIM(@CONDITION_VALUE))-1)
	ELSE IF RIGHT(TRIM(@CONDITION_VALUE),1)='&' AND LEFT(TRIM(@CONDITION_VALUE),1)<>'&'
		SET @CONDITION_VALUE_1 = LEFT(TRIM(@CONDITION_VALUE),LEN(TRIM(@CONDITION_VALUE))-1)
	ELSE IF LEFT(TRIM(@CONDITION_VALUE),1)='|' AND RIGHT(TRIM(@CONDITION_VALUE),1)='|'
		SET @CONDITION_VALUE_1 = RIGHT(LEFT(TRIM(@CONDITION_VALUE),LEN(TRIM(@CONDITION_VALUE))-1),LEN(LEFT(TRIM(@CONDITION_VALUE),LEN(TRIM(@CONDITION_VALUE))-1))-1)
	ELSE IF LEFT(TRIM(@CONDITION_VALUE),1)='&' AND RIGHT(TRIM(@CONDITION_VALUE),1)='&'
		SET @CONDITION_VALUE_1 = RIGHT(LEFT(TRIM(@CONDITION_VALUE),LEN(TRIM(@CONDITION_VALUE))-1),LEN(LEFT(TRIM(@CONDITION_VALUE),LEN(TRIM(@CONDITION_VALUE))-1))-1)
	ELSE 
		SET @CONDITION_VALUE_1 = @CONDITION_VALUE
	
	if charindex('|',@CONDITION_VALUE_1,1)>0 
		BEGIN
		   set @CONDITION_VALUE_sign = N'or'
		   set @CONDITION_VALUE_split = N'|'
		   set @CONDITION_VALUE_num = len(@CONDITION_VALUE_1)-len(replace(@CONDITION_VALUE_1,'|',''))+1
		END
	ELSE if charindex('&',@CONDITION_VALUE_1,1)>0 
		BEGIN
		   set @CONDITION_VALUE_sign = N'and'
		   set @CONDITION_VALUE_split = N'&'
		   set @CONDITION_VALUE_num = len(@CONDITION_VALUE_1)-len(replace(@CONDITION_VALUE_1,'&',''))+1
		END
	else if charindex('&',@CONDITION_VALUE_1,1)=0 and charindex('|',@CONDITION_VALUE_1,1)=0 and len(trim(@CONDITION_VALUE_1))<>0
		BEGIN
		   set @CONDITION_VALUE_sign = N'null'
		   set @CONDITION_VALUE_split = N'null'
		   set @CONDITION_VALUE_num = 1
		END
	else
		BEGIN
		   set @CONDITION_VALUE_sign = N'null'
		   set @CONDITION_VALUE_split = N'null'
		   set @CONDITION_VALUE_num = 0
		END			

	set  @RULE_START_DATE_1 = @RULE_START_DATE
	set  @RULE_END_DATE_1 = @RULE_END_DATE
	print(@RULE_START_DATE_1)
	print(@RULE_END_DATE_1)
	SET  @i=1
	SET  @GATHER_DIM = '[�ֿ�����], [��˾], [����], [��������], [�������], [������], [��Դ����], [����ǳ�], [��ݵ���], [��������], [������Ʒ����], [��ݹ�˾], [����], [�˷ѵ���], [����], [��Ҫ�嵥], [ʡ], [ʶ����], [��], [�ջ���ַ], [�ջ���], [������Ʒ����], [�ĵ�ʱ��], [����ʱ��], [�ʱ�], [������ʱ��], [��������], [���䵥λ], [��������], [��������], [�����Ʒ], [�¶�], [����], [���] '
	SET @TABLENAME = 'WCYW.DBO.YW_FH_INCRE_BYMON_DETAIL'
	
	set @sql1 = 'ALTER table ' + @TABLENAME + ' add [' + @NEW_COLUMN_1  + '] nvarchar(50) NOT NULL constraint CON_' + @NEW_COLUMN_1  + ' default 0 '

	IF @GATHER_FROM_LEVEL_1 = N'������ϸ��' AND @GATHER_TO_LEVEL_1 = N'�նȶ�����'
		BEGIN
			IF @GATHER_FUNCTION_1=N'�����ۺ�'
				BEGIN
					IF	@CONDITION_VALUE_NUM = 1
						BEGIN
							IF @CONDITION_SIGN=N'����' or @CONDITION_SIGN=N'������'
								set @sql2 ='update ' + @TABLENAME + ' set [' + @NEW_COLUMN_1 + '] = ' + @GATHER_VAR_1 + ' where [' + @CONDITION_COLUMN_1 + '] ' + @CONDITION_SIGN_1 + ''''+ '%' + @CONDITION_VALUE_1 + '%' + '''' + ' and [��˾] = ' + '''' + @CUSTOMER_1 + ''''+ ' AND [��������] BETWEEN CAST(' + '''' + @RULE_START_DATE_1 + '''' +' AS DATETIME) AND CAST(' + '''' + @RULE_END_DATE_1 + '''' + ' AS DATETIME)'
							else if @CONDITION_SIGN=N'��...��ͷ' or @CONDITION_SIGN=N'����...��ͷ'
								set @sql2 ='update ' + @TABLENAME + ' set [' + @NEW_COLUMN_1 + '] = ' + @GATHER_VAR_1 + ' where LEFT([' + @CONDITION_COLUMN_1 + '], ' + len(trim(@CONDITION_VALUE_1)) + ')' + @CONDITION_SIGN_1 + ''''+ trim(@CONDITION_VALUE_1) + ''''  + ' and [��˾] = ' + '''' + @CUSTOMER_1 + '''' +   ' and [�ֿ�����]= ' + '''' + @STOCK_1 + ''''+ ' AND [��������] BETWEEN CAST(' + '''' + @RULE_START_DATE_1 + '''' +' AS DATETIME) AND CAST(' + '''' + @RULE_END_DATE_1 + '''' + ' AS DATETIME)'
							else if @CONDITION_SIGN=N'������' or @CONDITION_SIGN=N'=' or @CONDITION_SIGN='>=N' or @CONDITION_SIGN=N'<=' or @CONDITION_SIGN=N'>' or @CONDITION_SIGN=N'<'
								set @sql2 ='update ' + @TABLENAME + ' set [' + @NEW_COLUMN_1 + '] = ' + @GATHER_VAR_1 + ' where [' + @CONDITION_COLUMN_1 + '] ' + @CONDITION_SIGN_1 + ''''+ trim(@CONDITION_VALUE_1) + ''''  + ' and [��˾] = ' + '''' + @CUSTOMER_1 + ''''  +   ' and [�ֿ�����]= ' + '''' + @STOCK_1 + ''''+ ' AND [��������] BETWEEN CAST(' + '''' + @RULE_START_DATE_1 + '''' +' AS DATETIME) AND CAST(' + '''' + @RULE_END_DATE_1 + '''' + ' AS DATETIME)'
							else
								set @sql2 = ''
						END
					ELSE IF @CONDITION_VALUE_NUM > 1
						BEGIN
							IF @CONDITION_SIGN=N'����' or @CONDITION_SIGN=N'������'
								BEGIN
									set @sql2 = 'update ' + @TABLENAME + ' set [' + @NEW_COLUMN_1 + '] = ' + @GATHER_VAR_1 + ' where ( '
									WHILE(@i<@CONDITION_VALUE_NUM)
										BEGIN
											set @sql2 =@sql2 + ' [' + @CONDITION_COLUMN_1 + '] ' + @CONDITION_SIGN_1 + ''''+ '%'+ WCYW.dbo.fun_split(@CONDITION_VALUE_1,@CONDITION_VALUE_split,@i)+ '%' + '''' + ' ' + @CONDITION_VALUE_sign + ' '
											set @i = @i + 1
										END
										set @sql2 =@sql2 + ' [' + @CONDITION_COLUMN_1 + '] ' + @CONDITION_SIGN_1 + ''''+ '%'+ WCYW.dbo.fun_split(@CONDITION_VALUE_1,@CONDITION_VALUE_split,@i)+ '%' + '''' +  ') and [��˾] = ' + '''' + @CUSTOMER_1 + ''''  +   ' and [�ֿ�����]= ' + '''' + @STOCK_1 + ''''+ ' AND [��������] BETWEEN CAST(' + '''' + @RULE_START_DATE_1 + '''' +' AS DATETIME) AND CAST(' + '''' + @RULE_END_DATE_1 + '''' + ' AS DATETIME)'
								END
							else if @CONDITION_SIGN=N'��...��ͷ' or @CONDITION_SIGN=N'����...��ͷ'
								BEGIN
									set @sql2 = 'update ' + @TABLENAME + ' set [' + @NEW_COLUMN_1 + '] = ' + @GATHER_VAR_1 + ' where ( '
									while(@i<@CONDITION_VALUE_NUM)
										BEGIN
											set @sql2 =@sql2 + ' left([' + @CONDITION_COLUMN_1 + '], ' + len(trim(WCYW.dbo.fun_split(@CONDITION_VALUE_1,@CONDITION_VALUE_split,@i))) + ')' + @CONDITION_SIGN_1 + ''''+ WCYW.dbo.fun_split(@CONDITION_VALUE_1,@CONDITION_VALUE_split,@i)+ '''' + ' ' + @CONDITION_VALUE_sign + ' '
											set @i = @i + 1
										END
										set @sql2 =@sql2 + ' left([' + @CONDITION_COLUMN_1 + '], ' + len(trim(WCYW.dbo.fun_split(@CONDITION_VALUE_1,@CONDITION_VALUE_split,@i))) + ')' + @CONDITION_SIGN_1 + ''''+ WCYW.dbo.fun_split(@CONDITION_VALUE_1,@CONDITION_VALUE_split,@i)+ '''' + ' ' +  ') and [��˾] = ' + '''' + @CUSTOMER_1 + ''''  +  ' and [�ֿ�����]= ' + '''' + @STOCK_1 + ''''+ ' AND [��������] BETWEEN CAST(' + '''' + @RULE_START_DATE_1 + '''' +' AS DATETIME) AND CAST(' + '''' + @RULE_END_DATE_1 + '''' + ' AS DATETIME)'
								END
							else if @CONDITION_SIGN=N'������' or @CONDITION_SIGN=N'=' or @CONDITION_SIGN=N'>=' or @CONDITION_SIGN=N'<=' or @CONDITION_SIGN=N'>' or @CONDITION_SIGN=N'<'
								BEGIN
									set @sql2 ='update ' + @TABLENAME + ' set [' + @NEW_COLUMN_1 + '] = ' + @GATHER_VAR_1 + ' where (' 
									while(@i<@CONDITION_VALUE_NUM)
										BEGIN
											set @sql2 =@sql2 + ' [' + @CONDITION_COLUMN_1 + '] ' + @CONDITION_SIGN_1 + ''''+ WCYW.dbo.fun_split(@CONDITION_VALUE_1,@CONDITION_VALUE_split,@i)+ '''' + ' ' + @CONDITION_VALUE_sign + ' '
											set @i = @i + 1
										END
										set @sql2 =@sql2 + ' [' + @CONDITION_COLUMN_1 + '] ' + @CONDITION_SIGN_1 + ''''+ WCYW.dbo.fun_split(@CONDITION_VALUE_1,@CONDITION_VALUE_split,@i)+ '''' + ' ' +  ') and [��˾] = ' + '''' + @CUSTOMER_1 + ''''  + ' and [�ֿ�����]= ' + '''' + @STOCK_1 + ''''	+  ' and [�ֿ�����]= ' + '''' + @STOCK_1 + ''''+ ' AND [��������] BETWEEN CAST(' + '''' + @RULE_START_DATE_1 + '''' +' AS DATETIME) AND CAST(' + '''' + @RULE_END_DATE_1 + '''' + ' AS DATETIME)'

								END
							else
								set @sql2 = ''					
						END
					ELSE
						set @sql2 = ''
				END
			ELSE
				set @sql2 = ''
		END	
	ELSE IF @GATHER_FROM_LEVEL_1 = '�նȶ�����' AND @GATHER_TO_LEVEL_1 = '�¶ȶ�����'
		BEGIN
			set @sql2 = ''
		END
	ELSE
		set @sql2 = ''

	select @sql1
	select @sql2
	exec(@sql1)
	exec(@sql2)	
END
GO


declare cur_createvar cursor
for 
select [�ֿ�],[����],[����ҵ�����],[�¶���ۺ��ֶ�����],[�ۺϺ���],[�ۺϱ���],[��ʼҵ�����],[�����ֶ�],[��������],[����ֵ],[������Ч����],[����ʧЧ����] from [WCYW].[dbo].[YW_FH_RULE_CREATENEWVAR]  where trim([����ҵ�����])='�նȶ�����'

open cur_createvar

declare @stock nvarchar(200), @cust nvarchar(200),@gath_to nvarchar(50),@namedvar nvarchar(200),@gath_fun nvarchar(50),@gath_var nvarchar(200),@gath_from nvarchar(50),@con_col nvarchar(200),@con_sign nvarchar(50),@con_value nvarchar(2000),@start_date datetime,@end_date datetime
declare @sql3 varchar(2000)

set @sql3 = 'SELECT [�ֿ�����], [��˾], [����], [��������], [�������], [������], [��Դ����], [����ǳ�], [��ݵ���], [��������], [������Ʒ����], [��ݹ�˾], [����], [�˷ѵ���], [����], [��Ҫ�嵥], [ʡ], [ʶ����], [��], [�ջ���ַ], [�ջ���], [������Ʒ����], [�ĵ�ʱ��], [����ʱ��], [�ʱ�], [������ʱ��], [��������], [���䵥λ], [��������], [��������], [�����Ʒ], [�¶�], [����], [���] '

fetch next from cur_createvar into @stock , @cust ,@gath_to ,@namedvar,@gath_fun ,@gath_var ,@gath_from ,@con_col,@con_sign ,@con_value ,@start_date ,@end_date

while(@@FETCH_STATUS=0)
	BEGIN
		if exists(select * from syscolumns where id=object_id('WCYW.dbo.YW_FH_INCRE_BYMON_DETAIL') and name=@namedvar) 
		BEGIN
			declare @sql4 varchar(2000)
			declare @sql5 varchar(2000)
			set @sql4 = 'alter table [WCYW].[dbo].[YW_FH_INCRE_BYMON_DETAIL] drop constraint con_' + @namedvar
			set @sql5 = 'alter table [WCYW].[dbo].[YW_FH_INCRE_BYMON_DETAIL] drop column ' + @namedvar
			print(@sql4)
			print(@sql5)
			exec(@sql4)
			exec(@sql5)
		END
		Exec PROC_CREATE_VAR @STOCKNAME=@stock , @CUSTOMER=@cust ,@GATHER_TO_LEVEL=@gath_to ,@NEW_COLUMN=@namedvar,@GATHER_FUNCTION=@gath_fun ,@GATHER_VAR=@gath_var ,@GATHER_FROM_LEVEL=@gath_from ,@CONDITION_COLUMN=@con_col,@CONDITION_SIGN=@con_sign ,@CONDITION_VALUE=@con_value ,@RULE_START_DATE=@start_date ,@RULE_END_DATE=@end_date
		set @sql3 = @sql3 + ',SUM(cast([' + @namedvar + '] as int)) as ['+@namedvar + ']'

		fetch next from cur_createvar into  @stock , @cust ,@gath_to ,@namedvar,@gath_fun ,@gath_var ,@gath_from ,@con_col,@con_sign ,@con_value ,@start_date ,@end_date
	END
IF OBJECT_ID(N'WCYW.dbo.YW_FH_INCRE_BYMON_DAYTAB', N'U') IS NOT NULL
drop table [WCYW].[dbo].[YW_FH_INCRE_BYMON_DAYTAB]

set @sql3 = @sql3 + ' into [WCYW].[dbo].[YW_FH_INCRE_BYMON_DAYTAB] FROM [WCYW].[dbo].[YW_FH_INCRE_BYMON_DETAIL] group by [�ֿ�����], [��˾], [����], [��������], [�������], [������], [��Դ����], [����ǳ�], [��ݵ���], [��������], [������Ʒ����], [��ݹ�˾], [����], [�˷ѵ���], [����], [��Ҫ�嵥], [ʡ], [ʶ����], [��], [�ջ���ַ], [�ջ���], [������Ʒ����], [�ĵ�ʱ��], [����ʱ��], [�ʱ�], [������ʱ��], [��������], [���䵥λ], [��������], [��������], [�����Ʒ], [�¶�], [����], [���]'
print(@sql3)
exec(@sql3)
close cur_createvar
deallocate cur_createvar

