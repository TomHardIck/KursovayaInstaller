set ansi_nulls on
go
set ansi_padding on
go
set quoted_identifier on 
go


create database PraktikaShimbirev
go

use PraktikaShimbirev
go


select * from [User]

select * from [Order]

create table UserRole
(
	ID_User_Role int not null identity(1,1),
	User_Role_Name varchar(50) not null,
	constraint PK_User_Role primary key clustered (ID_User_Role ASC) on [PRIMARY]
)

insert into UserRole values ('Менеджер по продажам')

create table [User]
(
	ID_User int not null identity(1,1),
	User_Login varchar(50) not null,
	User_Password varchar(50) not null,
	User_FName varchar(50) not null,
	User_LName varchar(50) not null,
	User_Role_ID int not null,
	Salt varchar(8) not null,
	constraint PK_User primary key clustered (ID_User ASC) on [PRIMARY],
	constraint FK_User_Role foreign key (User_Role_ID) references UserRole(ID_User_Role) on delete cascade
)

alter table [User] alter column User_Password varchar(255) not null

alter table [User] alter column Salt varchar(100) not null

insert into UserRole values ('Администратор')

insert into [User] values ('root', 'root', 'Иван', 'Иванов', 1, 'qwerty12')

update [User] set User_Password = 'pG/BhBfoUPK0hZ4CRMcM+IrFJUEOd92ixrB0TMSi2us=' where User_Login = 'root'

select * from [User]

create table [Category]
(
	ID_Category int not null identity(1,1),
	Category_Name varchar(50) not null,
	constraint PK_Category primary key clustered (ID_Category ASC) on [PRIMARY]
)

insert into Category values ('Наушники'), ('Клавиатуры')

create table [Product]
(
	ID_Product int not null identity(1,1),
	Product_Name varchar(50) not null,
	Product_Quantity int not null,
	Category_ID int not null,
	Photo_URL varchar(50) not null,
	constraint PK_Product primary key clustered (ID_Product ASC) on [PRIMARY],
	constraint FK_Category foreign key (Category_ID) references Category(ID_Category) on delete cascade
)
alter table Product add [Price] float not null

insert into Product values ('Наушники Acer Predator', 10, 1, 'test', 5000)

insert into Product values ('Наушники Asus TUF', 100, 1, 'test', 5500)

create table [Status]
(
	ID_Status int not null identity(1,1),
	Status_Name varchar(50) not null,
	constraint PK_Status primary key clustered (ID_Status ASC) on [PRIMARY]
)

create table [Order]
(
	ID_Order int not null identity(1,1),
	Order_Num varchar(7) not null,
	Order_Date date not null,
	[User_ID] int not null,
	Status_ID int not null,
	Order_Sum float not null,
	constraint PK_Order primary key clustered (ID_Order ASC) on [PRIMARY],
	constraint FK_User foreign key ([User_ID]) references [User](ID_User),
	constraint FK_Status foreign key ([Status_ID]) references [Status](ID_Status),
)

select * from [User]


insert into [Order] values ('1234567', CURRENT_TIMESTAMP, 9, 1, 10000)

create table [Products_In_Order]
(
	ID_Product_In_Order int not null identity(1,1),
	Product_ID int not null,
	Order_ID int not null,
	constraint PK_Products_In_Order primary key clustered (ID_Product_In_Order ASC) on [PRIMARY],
	constraint FK_Position foreign key (Product_ID) references Product(ID_Product),
	constraint FK_Order foreign key (Order_ID) references [Order](ID_Order)
)


select * from [Products_In_Order]


create table Dealer
(
	ID_Dealer int not null identity(1,1),
	Dealer_Name varchar(50) not null,
	constraint PK_Dealer primary key clustered (ID_Dealer ASC) on [PRIMARY]
)

create table Dealers_Products
(
	ID_Dealers_Products int not null identity(1,1),
	Dealer_ID int not null,
	Product_ID int not null,
	constraint PK_Dealers_Products primary key clustered (ID_Dealers_Products ASC) on [PRIMARY],
	constraint FK_Dealer foreign key (Dealer_ID) references Dealer(ID_Dealer),
	constraint FK_Product foreign key (Product_ID) references Product(ID_Product)
)

create table Act_History
(
	ID_Act int not null identity(1,1),
	[User_ID] int not null,
	[Description] varchar(max) not null,
	constraint PK_Act_History primary key clustered (ID_Act ASC) on [PRIMARY],
	constraint FK_ActUser foreign key ([User_ID]) references [User]([ID_User])
)

insert into [Status] values ('Оформлен'), ('Закрыт'), ('В процессе выполнения'), ('Отменен')


create or alter procedure ChangeOrderStatus(@IdNewStatus int, @IdToChange int)
as
begin
	update [Order] set Status_ID = @IdNewStatus where ID_Order = @IdToChange
end;


create or alter view [UsersData] as
	select [User_FName] as 'Имя',
			[User_LName] as 'Фамилия',
			[User_Login] as 'Логин',
			[User_Role_Name] as 'Роль'
from [User] inner join UserRole on UserRole.ID_User_Role = [User].User_Role_ID

select * from UsersData


create or alter view [OrdersData] as
	select [Order_Num] as 'Номер заказа',
			[Order_Date] as 'Дата оформления заказа',
			[User_Login] as 'Логин заказчика',
			[Order_Sum] as 'Сумма заказа',
			[Status_Name] as 'Статус заказа'
	from [Order] inner join [User] on [Order].[User_ID] = [User].ID_User
	inner join Status on [Status].ID_Status = [Order].Status_ID


create or alter view [ProductData] as 
	select [Product_Name] as 'Название товара',
			[Product_Quantity] as 'Количество товара',
			[Price] as 'Цена',
			Category_Name as 'Категория'
	from [Product] inner join Category on Category.ID_Category = Product.Category_ID



create or alter view ProductInOrderView
as
select [Order].Order_Num as 'Номер заказа',
		[Product].Product_Name as 'Название товара'
from Products_In_Order inner join [Order] on [Order].ID_Order = Products_In_Order.Order_ID
inner join Product on ID_Product = Product_ID


select * from ProductInOrderView

create or alter trigger ProductInsert on [Product]
after insert
as
begin
	declare @IdProduct int = (select ID_Product from [inserted])
	insert into Act_History values (1, CONCAT('Добавлен новый товар! ID: ', @IdProduct))
end