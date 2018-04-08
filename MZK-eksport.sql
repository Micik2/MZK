-- SQL Manager for SQL Server 4.0.2.45141
-- ---------------------------------------
-- Host      : localhost\SQLEXPRESS
-- Database  : MZK
-- Version   : Microsoft SQL Server  12.0.2000.8

DROP DATABASE Obsługa_Taboru_Miejskiego

DROP TABLE Autobusy
DROP TABLE Strefy_komunikacyjne
DROP TABLE Zajezdnie
DROP TABLE Kierowcy
DROP TABLE Autobusy_has_kierowcy
DROP TABLE Numery_linii
DROP TABLE Przystanki
DROP TABLE Trasy
DROP TABLE Trasy_has_przystanki
DROP TABLE Trasy_has_Strefy_komunikacyjne

CREATE DATABASE Obsługa_Taboru_Miejskiego
GO 

USE Obsługa_Taboru_Miejskiego
GO

SET LANGUAGE polski
GO

--------------------------------------------------------------------
/*CREATE TABLE Rodzaj_Autobusu (
id_rodzaj_pojazdu int,
opis varchar(50));*/



CREATE TABLE Strefy_komunikacyjne ( -- STREFY SĄ STAŁE!!!
id_strefy char primary key, --M (miejska) i P (podmiejska)
--Zajezdnie_id_zajezdni int references Zajezdnie(id_zajezdni),
--Trasy_id_trasy int references Trasy_has_strefy_komunikacyjne(id_trasy),
zakres text
);


CREATE TABLE Zajezdnie (
id_zajezdni int primary key IDENTITY(1,1),
--Autobusy_numer_seryjny int references Autobusy(numer_seryjny),
jaka_strefa char references Strefy_komunikacyjne(id_strefy),
ilość_autobusów int check (ilość_autobusów >= 0), --??????????????? and ilość_autobusów <= liczba_miejsc_na_autobusy), -- ilość_autobusów <= (SELECT COUNT(numer_seryjny) from Autobusy),
czy_jest_warsztat bit, --check ((SELECT COUNT(czy_jest_warsztat) from Zajezdnie) >= 1),-- check --(SELECT COUNT() from Zajezdnie where czy_jest_warsztat = 1)
czy_jest_myjnia bit, --check ((SELECT COUNT(czy_jest_myjnia) from Zajezdnie) >= 1) , 
czy_można_tankować bit, --check ((SELECT COUNT(czy_można_tankować) from Zajezdnie) >= 1), 
liczba_miejsc_na_autobusy int check (liczba_miejsc_na_autobusy > 0),
adres text
);


CREATE TABLE Autobusy (
numer_seryjny int primary key IDENTITY(800, 1),
Zajezdnie_id_zajezdni int references Zajezdnie(id_zajezdni),
--Egzemplarz_autobusu_numer_seryjny int references Egzemplarz_autobusu(numer_seryjny),
marka varchar(45),
model varchar(45),
pojemność_baku int check (pojemność_baku > 0),
moc_silnika int check (moc_silnika > 0),
rodzaj_autobusu varchar(20) check (rodzaj_autobusu in ('zwykły', 'pośpieszny')) default 'zwykły',
czy_niskopodłogowy bit,
czy_przegubowy bit,
spalanie double precision, --(l/km)
ilość_miejsc_stojących int check (ilość_miejsc_stojących > 0), --????????????????and ilość_miejsc_stojących > ilość_miejsc_siedzących),
ilość_miejsc_siedzących int check (ilość_miejsc_siedzących > 0), --??????????????????and ilość_miejsc_stojących > ilość_miejsc_siedzących),
ilość_drzwi int default 3 check (ilość_drzwi >= 1),
--id_rodzaj_autobusu int DEFAULT '1' ,
rok_produkcji int check (rok_produkcji > 1900),
przebieg int default 0 check (przebieg >= 0),
czy_jest_sprawny bit default 1,
ile_ma_benzyny int check (ile_ma_benzyny >= 0)
); --ile_ma_benzyny <= (SELECT a.pojemność_baku from Autobusy a inner join Egzemplarz_autobusu e on a.numer_seryjny = e.numer_seryjny) );


CREATE TABLE Kierowcy (
id_kierowcy int primary key IDENTITY(1,1),
--Egzemplarz_autobusu_numer_seryjny int references Egzemplarz_autobusu(numer_seryjny),
kategoria_prawa_jazdy varchar(20) check (kategoria_prawa_jazdy in('AM', 'A1', 'A2', 'A', 'B', 'B+E', 'B1', 'C', 'C+E', 'C1', 'D', 'D+E', 'D1', 'D1+E')),
wiek int check (wiek >= 21),
godziny_pracy text
);


CREATE TABLE Autobusy_has_kierowcy (
przypisanie_kierowca_autobus int primary key IDENTITY(1, 1),
Autobusy_numer_seryjny int references Autobusy(numer_seryjny),
Kierowcy_id_kierowcy int references Kierowcy(id_kierowcy)
);


CREATE TABLE Numery_linii (
numer_linii int primary key,
--Autobusy_numer_seryjny int references Autobusy(numer_seryjny),
--Trasy_id_trasy int references Trasy(id_trasy),
Autobusy_has_kierowcy_przypisanie_kierowca_autobus int references Autobusy_has_kierowcy(przypisanie_kierowca_autobus),           -- ???????????????????????????????????????????/
jaka_strefa varchar(20)
); 


CREATE TABLE Przystanki (
nazwa varchar(45) primary key,
--Trasy_id_trasy int references Trasy_has_przystanki(id_trasy),
czy_NŻ bit default 0,
jaka_strefa varchar(20)
);


CREATE TABLE Trasy (
id_trasy int primary key IDENTITY(1, 1), --check ((SELECT COUNT(id_trasy) from Trasy) % 2 = 0) ,
Numery_linii_numer_linii int references Numery_linii(numer_linii),
długość int check (długość > 0),
czas_przejazdu int check (czas_przejazdu > 0), --czas w minutach
ilość_przystanków int check (ilość_przystanków >= 2),
skąd varchar(45), 
dokąd varchar(45)
);


CREATE TABLE Trasy_has_przystanki (
Trasy_id_trasy int references Trasy(id_trasy),
Przystanki_nazwa varchar(45) references Przystanki(nazwa)
);


CREATE TABLE Trasy_has_Strefy_komunikacyjne (
Trasy_id_trasy int references Trasy(id_trasy),
Strefy_komunikacyjne_id_strefy char references Strefy_komunikacyjne(id_strefy)
);

----------------SELECT--------------------------------------------------
SELECT * from Zajezdnie
SELECT * from Autobusy
--SELECT * from Egzemplarz_autobusu
SELECT * from Autobusy_has_kierowcy
SELECT * from Strefy_komunikacyjne
SELECT * from Kierowcy
SELECT * from Numery_linii
SELECT * from Trasy
SELECT * from Przystanki


------INSERT---------------------------------------------------
INSERT INTO Strefy_komunikacyjne(id_strefy, zakres) --STREFY SĄ STAŁE!!!
values ('M', 'obszar do granic miasta - strefa miejska'), 
	   ('P', 'obszar poza granicami miasta - strefa podmiejska');

INSERT INTO Zajezdnie--(jaka_strefa, ilość_autobusów, czy_jest_warsztat, czy_jest_myjnia, czy_można_tankować, liczba_miejsc_na_autobusy, adres)
values('M', 2, 1, 1, 0, 6, 'ul. Ceglana 37, 73-110 Rzeszów'), 
	  ('P', 0, 0, 0, 1, 3, 'ul. Stargardzka 57, 74-100 Zieleniewo');

INSERT INTO Autobusy(marka, Zajezdnie_id_zajezdni, model, pojemność_baku, moc_silnika, rodzaj_autobusu, czy_niskopodłogowy, czy_przegubowy, spalanie, ilość_miejsc_stojących, ilość_miejsc_siedzących, rok_produkcji, przebieg, czy_jest_sprawny, ile_ma_benzyny)
values('MAN', 1, 'Lion City', 340, 226, 'zwykły', 1, 0, 0.138, 42, 31, 2001, 244858, 1, 16),
      ('MAN', 1, 'Lion City', 340, 226, 'zwykły', 1, 0, 0.144, 44, 32, 2001, 163246, 1, 92);
	 
INSERT INTO Kierowcy
values ('D', 36, '9:00 - 17:00'), 
	   ('D', 47, '5:00 - 13:00');

INSERT INTO Autobusy_has_kierowcy--(Autobusy_numer_seryjny, Kierowcy_id_kierowcy)
values (800, 1),
	   (801, 2);

--INSERT INTO Egzemplarz_autobusu--(numer_seryjny, Autobusy_3w3333333333333333aa3w, data_produkcji, przebieg, czy_jest_sprawny, czy_niskopodłogowy, ile_ma_benzyny)
--values (804, 1, 1, 2007, 40000, 1, 1, 56), (805, 2, 2, 2008, 45000, 0, 1, 92);

INSERT INTO Numery_linii(numer_linii, jaka_strefa)
values (1, 'M'), 
	   (3, 'P');

INSERT INTO Trasy
values (1, 9, 21, 18, 'Spokojna', 'Os. Chopina'), 
	   (1, 8, 22, 18, 'Os. Chopina', 'Spokojna'),
	   (3, 18, 60, 35, 'Kobylanka', 'Tychowo'), 
	   (3, 16, 28, 23, 'Tychowo', 'Kobylanka');

INSERT INTO Przystanki
values ('Spokojna', 0, 'M'), 
	   ('Os. Chopina', 0, 'M'), 
	   ('Kobylanka', 1, 'P'), 
	   ('Tychowo', 0, 'P');


--**********************************PROCEDURY***************************************--

CREATE PROCEDURE Przypisz_kierowcę_do_autobusu --to tylko przypisanie (nie wysyła kierowcy jeszcze w trasę)
@id_kierowcy int,
@numer_seryjny int,
@id_zajezdni int
AS
BEGIN
  IF((SELECT ilość_autobusów from Zajezdnie where id_zajezdni = @id_zajezdni) >= 1 and @id_kierowcy in (SELECT id_kierowcy from Kierowcy) and @id_kierowcy not in (SELECT Kierowcy_id_kierowcy from Autobusy_has_kierowcy) and (SELECT czy_jest_sprawny from Autobusy where numer_seryjny = @numer_seryjny) = 1)
	BEGIN
		INSERT INTO Autobusy_has_kierowcy(Autobusy_numer_seryjny, Kierowcy_id_kierowcy) 
		values(@numer_seryjny, @id_kierowcy);
		UPDATE Zajezdnie SET ilość_autobusów = ilość_autobusów - 1 WHERE id_zajezdni = @id_zajezdni
		UPDATE Autobusy SET Zajezdnie_id_zajezdni = NULL where numer_seryjny = @numer_seryjny
	END
  ELSE 
	PRINT 'Nie możesz przypisać, ponieważ w podanej zajezdni nie ma żadnych autobusów albo kierowca o takim identyfikatorze nie istnieje, bądź też kierowca jest przypisany aktualnie do jakiegoś autobusu lub autobus jest niesprawny!'
END
----------------------------------------------------------------------------------------------
CREATE VIEW Autobusy_w_zajezdniach
AS 
(SELECT id_zajezdni, numer_seryjny, ilość_autobusów, liczba_miejsc_na_autobusy, rodzaj_autobusu, czy_niskopodłogowy, czy_przegubowy, czy_jest_sprawny 
from Zajezdnie, Autobusy)
------------------------------------------------------------------------------------------
CREATE PROCEDURE Wyślij_kierowcę_w_trasę
@przypisanie_kierowca_autobus int, -- = znany jest numer seryjny autobusu oraz id kierowcy
@numer_linii int,
@ilość_cykli int
AS
BEGIN
	DECLARE @nr int
	SET @nr = (SELECT Autobusy_numer_seryjny from Autobusy_has_kierowcy ak inner join Autobusy a on ak.Autobusy_numer_seryjny = a.numer_seryjny where przypisanie_kierowca_autobus = @przypisanie_kierowca_autobus)

	INSERT INTO Numery_linii(numer_linii, Autobusy_has_kierowcy_przypisanie_kierowca_autobus)
	values (@numer_linii, @przypisanie_kierowca_autobus);

	--DECLARE @strefa char
	--SET @strefa = 'M'

	--IF('P' EXISTS in (SELECT jaka_strefa from Przystanki where nazwa in (SELECT skąd from Trasy t inner join Przystanki p on t.skąd = p.nazwa where t.Numery_linii_numer_linii = 1)))-- and jaka_strefa = 'M'))

	WHILE(@ilość_cykli > 0)
		BEGIN
			DECLARE @nowy_przebieg int
			SET @nowy_przebieg = (SELECT SUM(długość) from Trasy where Numery_linii_numer_linii = @numer_linii)
			UPDATE Autobusy SET przebieg = przebieg + @nowy_przebieg where numer_seryjny = @nr
			
			DECLARE @strata_benzyny int
			SET @strata_benzyny = @nowy_przebieg * (SELECT spalanie from Autobusy where numer_seryjny = @nr)
			UPDATE Autobusy SET ile_ma_benzyny = ile_ma_benzyny - @strata_benzyny

			--DECLARE @nr int
			--SET @nr = (SELECT Autobusy_numer_seryjny from Autobusy_has_kierowcy ak inner join Autobusy a on ak.Autobusy_numer_seryjny = a.numer_seryjny where przypisanie_kierowca_autobus = @przypisanie_kierowca_autobus)
			--PRINT 'Autobus o numerze seryjnym ' + CAST(@nr as varchar(10)) + ' się zepsuł!'


			DECLARE @sprawność int
			SET @sprawność = RAND(@sprawność)
			IF(@sprawność <= 0.01) 
				BEGIN
					UPDATE Autobusy SET czy_jest_sprawny = 0 where numer_seryjny = @nr
					PRINT 'Autobus o numerze seryjnym ' + CAST(@nr as varchar(10)) + ' się zepsuł'

					DECLARE @strefa char
					SET @strefa = (SELECT jaka_strefa from Numery_linii where numer_linii = @nr) 
					exec Wyślij_autobus_do_naprawy(@nr, @strefa)
				END
			SET @ilość_cykli = @ilość_cykli - 1
		END
END

CREATE PROC Wyślij_autobus_do_naprawy
@nr_seryjny int,
@strefa char
AS
BEGIN
	DECLARE @zajezdnia int
	SET @zajezdnia = (SELECT id_zajezdni from Zajezdnie where czy_jest_warsztat = 1 and jaka_strefa = @strefa and ilość_autobusów < liczba_miejsc_na_autobusy)
	IF(@zajezdnia is not null)
		BEGIN
			UPDATE Zajezdnie SET ilość_autobusów = ilość_autobusów + 1 where id_zajezdni = @zajezdnia
			UPDATE Autobusy SET Zajezdnie_id_zajezdni = @zajezdnia where numer_seryjny = @nr_seryjny

			DECLARE @przypisanie int
			SET @przypisanie = (SELECT przypisanie_kierowca_autobus from Autobusy_has_kierowcy where Autobusy_numer_seryjny = @nr_seryjny)
			DELETE from Autobusy_has_kierowcy where Autobusy_numer_seryjny = @nr_seryjny
			UPDATE Numery_linii SET Autobusy_has_kierowcy_przypisanie_kierowca_autobus = NULL where  Autobusy_has_kierowcy_przypisanie_kierowca_autobus = @przypisanie

			--DECLARE @nr_ser int
			--SET @nr_ser = 800

			WAITFOR DELAY '00:00:10'
			--UPDATE Autobusy SET czy_jest_sprawny = 1 where @nr_ser in (SELECT numer_seryjny from Autobusy)
			--PRINT 'Autobus o numerze seryjnym ' + CAST(@nr_ser as varchar(10)) + ' został naprawiony!'
			UPDATE Autobusy SET czy_jest_sprawny = 1 where @nr_seryjny in (SELECT numer_seryjny from Autobusy)
			PRINT 'Autobus o numerze seryjnym ' + CAST(@nr_seryjny as varchar(10)) + ' został naprawiony!'  
		END
END


/*
CREATE FUNCTION Kiedy_do_myjni(@przebieg int) returns int
AS
BEGIN
	SET @przebieg = @przebieg
END
	*/

CREATE PROCEDURE Wyślij_autobus_do_myjni
@nr_seryjny int,
@nr_zajezdni int
AS
BEGIN
	IF EXISTS( SELECT id_zajezdni from Zajezdnie where czy_jest_myjnia = 1) or (SELECT liczba_miejsc_na_autobusy from Zajezdnie where id_zajezdni = @nr_zajezdni) > (SELECT ilość_autobusów from Zajezdnie where id_zajezdni = @nr_zajezdni)
		BEGIN
			UPDATE Zajezdnie SET ilość_autobusów = ilość_autobusów + 1 where id_zajezdni = @nr_zajezdni 
			UPDATE Autobusy SET Zajezdnie_id_zajezdni = @nr_zajezdni where numer_seryjny = @nr_seryjny
		END
	ELSE PRINT 'Nie ma tu myjni lub doszłoby do przepełnienia w zajezdni!'
END


CREATE PROCEDURE Dodaj_nową_linię
@linia int,
@strefa char
AS
BEGIN
	INSERT INTO Numery_linii
	values (@linia, NULL, @strefa)

CREATE PROCEDURE Dodaj_nową_trasę_i_przypisz_do_niej_linię
@linia int,
@długość int,
@czas int,
@przystanki int,
@od varchar(45),
@do varchar(45)
AS
BEGIN
	IF (NOT EXISTS (SELECT numer_linii from Numery_linii where numer_linii = @linia) and EXISTS(SELECT nazwa from Przystanki where nazwa = @od) and EXISTS(SELECT nazwa from Przystanki where nazwa = @do))
		BEGIN
			INSERT INTO Trasy(Numery_linii_numer_linii, długość, czas_przejazdu, ilość_przystanków, skąd, dokąd)
			values (@linia, @długość, @czas, @przystanki, @od, @do)
		END
END

CREATE PROCEDURE Zmiana_trasy
@id int,
@dług int,
@czas int, 
@przystanki int,
@od varchar(45),
@do varchar(45)
AS
BEGIN
	UPDATE Trasy SET długość = @dług where id_trasy = @id
	UPDATE Trasy SET czas_przejazdu = @czas where id_trasy = @id
	UPDATE Trasy SET ilość_przystanków = @przystanki where id_trasy = @id
	UPDATE Trasy SET skąd = @od where id_trasy = @id
	UPDATE Trasy SET dokąd = @do where id_trasy = @id
END

CREATE PROCEDURE Dodaj_autobus
@zajezdnia int,
@marka varchar(45),
@model varchar(45),
@pojemność int,
@moc int,
@rodzaj varchar(20),
@niskpodłogowy bit,
@przegubowy bit,
@spalanie double precision, 
@miejsca_stojące int,
@miejsca_siedzące int,
@drzwi int,
@rok int
AS
BEGIN
	IF ((SELECT SUM(liczba_miejsc_na_autobusy) from Zajezdnie) >= (SELECT SUM(ilość_autobusów) from Zajezdnie)
		BEGIN
			INSERT INTO Autobusy(Zajezdnie_id_zajezdni, marka, model, pojemność_baku, moc_silnika, rodzaj_autobusu, czy_niskopodłogowy, czy_przegubowy, spalanie, ilość_miejsc_stojących, ilość_miejsc_siedzących, ilość_drzwi, rok_produkcji, ile_ma_benzyny)
			values (@zajezdnia, @marka, @model, @pojemność, @moc, @rodzaj, @niskopodłogowy, @przegubowy, @spalanie, @miejsca_stojące, @miejsca_siedzące, @drzwi, @rok, @pojemność)
		END
	ELSE
		PRINT 'Nie można dodać autobusu, ponieważ doszłoby do przepełnienia w zajezdniach!'
END

------TRIGGERY------------------------------------------------------
CREATE TRIGGER Wysłanie_autobusu_w_trasę
on Numery_linii
AFTER insert
AS
	DECLARE @linia int, @seryjny int, @kierowca int
	SELECT @linia = numer_linii from INSERTED  
	SELECT @seryjny = Autobusy_numer_seryjny, @kierowca = Kierowcy_id_kierowcy from Autobusy_has_kierowcy inner join inserted on przypisanie_kierowca_autobus = Autobusy_has_kierowcy_przypisanie_kierowca_autobus
	PRINT 'Autobus o numerze seryjnym ' + CAST(@seryjny as varchar(10)) + ' wyjechał w trasę jako numer linii: ' + CAST(@linia as varchar(10)) + ', kieruje nim kierowca o id: ' + CAST(@kierowca as varchar(10)) 
	
	