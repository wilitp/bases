drop database if exists world;
create database if not exists world ; 

use world;

create table country (
	Code varchar(255) primary key,
	Name varchar(255),
	Continent varchar(255),
	Region varchar(255),
	SurfaceArea int,
	IndepYear int,
	Population int,
	LifeExpectancy int,
	GNP int,
	GNPOld int,
	LocalName varchar(255),
	GovernmentForm varchar(255),
	HeadOfState varchar(255),
	Capital int,
	Code2 varchar(255)
)

create table city (
	ID int primary key,
	Name varchar(255),
	CountryCode varchar(255),
	District varchar(255),
	Population int
)

create table countrylanguage (
	CountryCode varchar(255),
	Language varchar(255),
	IsOfficial varchar(255),
	Percentage int
)

-- Primary key para languages
alter table countrylanguage
add constraint primary key (CountryCode, Language);

-- Relacion muchos a uno ciudad - pais
alter table city
add foreign key (CountryCode) references country(Code);

-- Relacion uno a uno idioma - pais

alter table countrylanguage 
add foreign key (CountryCode) references country(Code);


