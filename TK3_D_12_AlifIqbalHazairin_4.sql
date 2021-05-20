---- Auto-Generate idTransaksi Varchar ----
CREATE OR REPLACE FUNCTION hotel_transact_id() 
RETURNS VARCHAR AS 
$$
DECLARE
    id_Transaksi VARCHAR;
    randomString VARCHAR;
    randomInt VARCHAR;
    BEGIN

        SELECT array_to_string(ARRAY(SELECT chr((97 + round(random() * 25)) :: integer) 
        FROM generate_series(1,4)), '') INTO randomString;

        SELECT array_to_string(ARRAY(SELECT chr((48 + round(random() * 9)) :: integer) 
        FROM generate_series(1,6)), '') INTO randomInt;

        SELECT randomString || randomInt INTO id_Transaksi;

        RETURN id_Transaksi;
    END;
$$ language plpgsql;

---- FUNCTION TRANSAKSI_HOTEL ----
CREATE OR REPLACE FUNCTION make_hotel_transaction()
RETURNS TRIGGER AS
$$
    DECLARE 
        total INT;
        dayDiff INT;
        hargaRoom INT;
        idTransaksi varchar := hotel_transact_id() ;
    BEGIN
        SELECT DATE_PART('day', NEW.TglKeluar::TIMESTAMP - NEW.TglMasuk::TIMESTAMP) INTO dayDiff;
        SELECT HARGA into hargaRoom
        FROM HOTEL_ROOM HR
        WHERE HR.KodeHotel = NEW.KodeHotel
        AND HR.KodeRoom = NEW.KodeRoom;
        SELECT dayDiff*hargaRoom INTO total;
        
        INSERT INTO TRANSAKSI_HOTEL(IdTransaksi, KodePasien, TotalBayar, StatusBayar)
        VALUES (idTransaksi, NEW.KodePasien, total, 'Belum Lunas');

        RETURN NEW;
    END;
$$
LANGUAGE PLPGSQL;

---- FUNCTION TRANSAKSI_BOOKING ----
CREATE OR REPLACE FUNCTION make_booking_transaction()
RETURNS TRIGGER AS
$$
    DECLARE
        tgl_Masuk DATE;
    BEGIN
        SELECT TglMasuk INTO tgl_Masuk
        FROM RESERVASI_HOTEL RH
        WHERE RH.KodePasien = NEW.KodePasien;

        INSERT INTO TRANSAKSI_BOOKING
        VALUES (NEW.idTransaksi, NEW.TotalBayar, NEW.KodePasien, tgl_Masuk);

        RETURN NEW;
    END;
$$
LANGUAGE PLPGSQL;

---- TRIGGER ----
CREATE TRIGGER HOTEL_TRANSACTION
AFTER INSERT ON RESERVASI_HOTEL
FOR EACH ROW EXECUTE PROCEDURE make_hotel_transaction();

CREATE TRIGGER BOOKING_TRANSACTION
AFTER INSERT ON TRANSAKSI_HOTEL
FOR EACH ROW EXECUTE PROCEDURE make_booking_transaction();