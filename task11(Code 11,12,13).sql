use AdventureWorks2019

--SS 11
--VD1
create table Production.parts(
part_id int not null,
part_name nvarchar(100)
)
go

--VD2
create clustered index ix_parts on Production.parts (part_id);

--VD3
exec sp_rename 
	N'Production.parts.ix_parts_id',
	N'index_part_id',
N'INDEX';

--VD4
alter index ix_parts
on Production.parts
disable;

--VD5
alter index all on Production.parts
disable;

--VD6
drop index if exists
ix_parts on Production.parts;

--VD7
create nonclustered index index_customer_storeid
on Sales.Customer(StoreID);

--VD8
create unique index AK_Customer_rowguid
on Sales.Customer(rowguid);

--VD9
create index index_cust_personId on
Sales.Customer(PersonID)
where PersonID is not null;

--VD10
select CustomerID, PersonId, StoreID from Sales.Customer where PersonID = 1700;

--VD11
create partition function partition_function (int)
range left for values (20200630, 20200731, 20200831);

--VD12
(select 20200613 date, $partition.partition_function()20200613)PartitionNumber)
union
(select 20200713 date, $partition.partition_function()20200713)PartitionNumber)
union
(select 20200813 date, $partition.partition_function()20200813)PartitionNumber)
union
(select 20200913 date, $partition.partition_function()20200913)PartitionNumber);

--VD13
create primary xml index pxml_ProductModel_CatalogDescription
on Production.ProductModel (CatalogDescription);

--VD14
create xml index ixml_ProductModel_CatalogDescription_Path
on Production.ProductModel (CatalogDescription)
using xml index pxml_ProductModel_CatalogDescription
for Path;

--VD15
create columnstore index IX_SalesOrderDetails_ProductIDOrderQty_columnstore on Sales.SalesOrderDetail (ProductID, OrderQty);

--VD16
select ProductID, SUM(OrderQty)
from Sales.SalesOrderDetail
group by ProductID;

--SS 12 
--VD1
create table Locations (LocationID int, LocName varchar(100));
create table LocationHistory (LocationID int, ModifiedDate datetime);

--VD2
create trigger trigger_insert_Locations on Locations
for insert 
not for replication
as
	begin 
		insert into LocationHistory
		select LocationID 
		,getdate()
		from inserted 
	end;

--VD3
insert into dbo.Locations (LocationID, LocName) values (443101, 'Alaska'

--VD4
create trigger trigger_upadte_Locations on Locations
for update 
not for replication
as 
	begin 
	insert into LocationHistory
	select LocationID
	,getdate()
	from inserted
end;

--VD5
update dbo.Locations set LocName='Alatka'
where LocationID = '443101';

--VD6
create trigger trigger_delete_Locations on Locations 
for delete
not for replication
as 
	begin
	insert into LocationHistory
	select LocationID ,getdate()
	from deleted
end;

--VD7
delete from dbo.Locations 
where LocationID= '443101'

--VD8
create trigger alter_insert_Locations on Locations 
after insert 
as 
	begin 
	insert into LocationHistory
	select LocationID
	, getdate()
	from inserted
end;

--VD9
insert into dbo.Locations (LocationID, LocName) values (443101, 'SAN ROMAN')

--VD10
create trigger insteadof_delete_Locations on Locations
instead of delete 
as 
	begin 
	select 'Sample Instead of trigger' as 'Khanh sieu dep trai'
end;

--VD11
delete from dbo.Locations
where LocationID = 443101

--vd12
exec sp_settriggerorder @triggername = 'trigger_delete_Locations', @order = 'first', @stmttype = 'delete' 

--VD13
sp_helptext trigger_delete_Locations

--VD14
alter trigger trigger_update_Locations on Locations 
with excryption for insert 
as	
	if '443101' in (select LocationID from inserted)
	begin 
		print 'Location cannot be updated'
		rollback transaction
end;

--VD15
drop trigger trigger_update_Locations

--VD16
create trigger secure on database 
for drop_table, alter_table as 
print 'You must disable Trigger "Secure" to drop or alter tables !'
rollback;

--VD17
create trigger Employee_deletion on HumanResources.Employee
after delete
as
	begin
	print 'Deletion will be affect EmployeePayHistory table'
delete from EmployeePayHistory where BusinessEntityID in (select BusinessEntityID from deleted)
end;

--VD18
create trigger deletion_Confirmation
on HumanResources.EmployeePayHistory after delete
as 
	begin 
	print 'Employee details succesfully deleted from EmployeePayHistory table'
end;
delete from EmployeePayHistory where EmpID = 1

--VD19
create trigger Accounting on Production.TransactionHistory after update 
as 
if (update (TransactionID) or update (ProductID) ) begin
raiserror (5009, 16, 10) end;
go

--VD20
use AdventureWorks2019
go
create trigger PODetails
on Purchasing.PurchaseOrderDetail after insert as
update PurchaseOrderHeader
set SubTotal = SubTotal + LineTotal from inserted
where PurchaseOrderHeader.PurchaseOrderID = inserted.PurchaseOrderID;

--VD21
create trigger PODetailsMultiple
on Purchasing.PurchaseOrderDetail after insert as 
update Purchasing.PurchaseOrderHeader set SubTotal = SubTotal + (select sum(LineTotal) from inserted
where PurchaseOrderHeader.PurchaseOrderID = inserted.PurchaseOrderID)
where PurchaseOrderHeader.PurchaseOrderID in (select PurchaseOrderID from inserted);

--VD22
create trigger track_login on ALL SEVER
for logon as
	begin 
		insert into LoginActivity
		select EVENTDATA()
		,GETDATE()
end;

--SS 13
--VD1
use AdventureWorks2019
go
create view dbo.vProduct
as
select ProductNumber, Name from Production.Product;
go
select * from dbo.vProduct;
go

--VD2
begin transaction 
go
use AdventureWorks2019
go
create table Company(
Id_Num int identity(100, 5),
CompanyName varchar(100)
)
go

insert into Company(CompanyName) values
(N'A Bike Store'),
(N'Progressive Sport'),
(N'Modular Cycle Systems'),
(N'Advanced Bike Components'),
(N'Metropolitan Sports Supply'),
(N'Aerobic Exercise Company'),
(N'Associated Bike'),
(N'Exemplary Cycle')

select Id_Num, CompanyName from dbo.Company
order by CompanyName ASC

--VD3 
declare @find varchar(30) = 'Man%';
select p.LastName, p.FirstName, ph.PhoneNumber from Person.Person as p
join Person.PersonPhone as ph on  p.BusinessEntityID = ph.BusinessEntityID
where LastName like @find;

--VD4
declare @myvar char(20);
set @myvar = 'This is a test';

--VD5
declare @varl nvarchar(30);
select @varl = 'Unnamed Company';
select @varl = Name from Sales.Store where BusinessEntityID = 10;
select @varl as 'Company Name';

--VD6
create SYNONYM MyAddressType
for AdventureWork2019.Person.AddressType;
go

--VD7
begin transaction;
go
if @@TRANCOUNT = 0 begin
select FirstName. MiddleName 
from Person.Person where LastName = 'Andy';
rollback transaction;
print N'Rolling back the transaction two times would cause an error.';
end;
rollback transaction;
print N'Rolled back the transaction.'
go

--VD8
declare @ListPrice money;
set @ListPrice = (select max(p.ListPrice) from Production.Product as p
join Production.ProductSubcategory as s
on p.ProductSubcategoryID = s.ProductSubcategoryID where s.[Name] = 'Mountain Bikes');
print @ListPrice
if @ListPrice < 3000
print 'All the product in this category can be purchased for an amount less than 300'
else 
print 'The prices for some product in this category exceed 3000'

--VD9
declare @flag int set @flag = 10 while (@flag <=95) begin
if @flag%2 = 0 print @flag 
set @flag = @flag + 1
cotinue; end
go

--VD10
if OBJECT_ID (N'Sales.ufn_CustDates', N'IF') is not null 
drop function Sales.ufn_CustDates
go
create function Sales.ufn_CustDates () returns table
as return (
select A.CustomerID, B.DueDate, B.ShipDate from Sales.Customer A 
left outer join Sales.SalesOrderHeader B 
on A.CustomerID = B.CustomerID and YEAR (B.DueDate)<2020);

--VD11
select * from Sales.ufn_CustDates();

--VD12
alter function [dbo].[ufnGetAccountingEndDate] () returns [datetime]
as begin
return dateadd(MILLISECOND, -2, convert(datetime, '20040701', 112));
end;

--VD13
select SalesOrderID, ProductID, OrderQty, SUM(OrderQty) over(Partition by SalesOrderID) as Total,
MAX(OrderQty) over (Partition by SalesOrderID) as MaxOrderQty from Sales.SalesOrderDetail
where ProductID in (776, 773);
go

--VD14
select CustomerID, StoreID, 
RANK() over (ORDER BY StoreID DESC) as Rnk_All, RANK() over (Partition by PersonID
order by CustomerID DESC) as Rnk_Cust
from Sales.Customer;

--VD15
select TerritoryID, Name, SalesYTD, RANK() over (order by SalesYTD DESC) as Rnk_One, RANK() over (Partition by TerritoryID
order by SalesYTD DESC) as Rnk_Two
from Sales.SalesTerritory;

--VD16
select ProductID, Shelf, Quantity, SUM(Quantity) over (Partition by ProductID
order by LocationID 
rows between unbounded preceding and current row) as RunQty
from Production.ProductInventory;

--VD17
select p.FirstName, p.LastName,
ROW_NUMBER() over (order by a.PostalCode) as 'Row Number',
NTILE(4) over (order by a.PostalCode) as 'NTILE',
s.SalesYTD, a.PostalCode from Sales.SalesPerson as s
inner join Person.Person as p
on s.BusinessEntityID = p.BusinessEntityID
inner join Person.Address as a
on a.AddressID = p.BusinessEntityID
where TerritoryID is not null and SalesYTD <>0;

--VD18
