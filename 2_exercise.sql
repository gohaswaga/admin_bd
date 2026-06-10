use User_Actions

alter database User_Actions add filegroup Sector_frag
go
alter database User_Actions add file(
	name = 'Sector_frag',
	filename = 'D:\SQL\Sector_frag.ndf') to filegroup Sector_frag
go


create partition function pf_Sector_month(date)
as range right for values (
	'2025-02-01', '2025-03-01', '2025-04-01', 
    '2025-05-01', '2025-06-01', '2025-07-01', 
    '2025-08-01', '2025-09-01', '2025-10-01', 
    '2025-11-01', '2025-12-01')
go


create partition scheme ps_Sector_frag
as partition pf_Sector_month to (
Sector_frag, Sector_frag, Sector_frag, Sector_frag, Sector_frag, Sector_frag, 
Sector_frag, Sector_frag, Sector_frag, Sector_frag, Sector_frag, Sector_frag)
go


create table Logs_frag(
	id UNIQUEIDENTIFIER DEFAULT NEWID(),
	username TEXT NOT NULL,
	user_action TEXT NOT NULL,
	action_date DATE NOT NULL,
	action_time TIME NOT NULL,
	action_result TEXT NOT NULL,

	constraint pk_logs primary key clustered (id, action_date)
) on ps_Sector_frag(action_date)


insert into Logs_frag (username, user_action, action_date, action_time, action_result) 
	select username, user_action, action_date, action_time, action_result from User_Logs

select * from Logs_frag
where $partition.pf_Sector_month(action_date) = 2
