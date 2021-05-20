-- 1 --

CREATE OR REPLACE FUNCTION CHECK_PASSWORD() RETURNS TRIGGER AS
$$
BEGIN
    IF((NEW.password ~ '[A-Z]') AND (NEW.password ~ '[0-9]')) THEN
        RETURN NEW;
    ELSE
        RAISE EXCEPTION 'Password harus terdapat minimal 1 huruf kapital dan 1 angka';
	END IF;
END;
$$
LANGUAGE PLPGSQL;


CREATE TRIGGER PASSWORD_VIOLATION
BEFORE INSERT ON AKUN_PENGGUNA
FOR EACH ROW
EXECUTE PROCEDURE CHECK_PASSWORD();

-- Ageng 5 --
CREATE OR REPLACE FUNCTION add_nominal_transaksi_hotel() 
RETURNS trigger AS 
$$
DECLARE 
    harga integer;
BEGIN
    SELECT PM.harga into harga
    FROM PAKET_MAKAN PM
    WHERE NEW.kodehotel = PM.kodehotel AND NEW.kodepaket = PM.kodepaket

    UPDATE TRANSAKSI_MAKAN TM
    SET totalbayar = totalbayar + harga
    WHERE NEW.id_transaksi = TM.idTransaksi and NEW.IdTransaksiMakan = TM.IdTransaksiMakan;

    UPDATE TRANSAKSI_HOTEL TH
    SET totalbayar = totalbayar + harga
    WHERE NEW.id_transaksi = TH.idTransaksi;
    RETURN NEW;
END 
$$ 
LANGUAGE PLPGSQL;

CREATE TRIGGER add_nominal_transaksi_hotel
AFTER INSERT ON DAFTAR_PESAN
FOR EACH ROW 
EXECUTE PROCEDURE add_nominal_transaksi_hotel();

-- Fina 2.1 --
CREATE OR REPLACE FUNCTION JADWAL_CHECK() RETURNS TRIGGER AS
$$
DECLARE
pasien_counter integer;
BEGIN
    SELECT JmlPasien into pasien_counter
    FROM JADWAL_DOKTER
    WHERE Username = NEW.Username_Dokter AND Tanggal = NEW.Praktek_Tgl;

    IF (pasien_counter>=30) THEN
        RAISE EXCEPTION 'Jadwal tidak dapat dibuat. Telah terdapat 30 antrian pasien';
    ELSE
        UPDATE JADWAL_DOKTER
        SET JmlPasien = pasien_counter + 1
        WHERE Username = NEW.Username_Dokter AND Tanggal = NEW.Praktek_Tgl;
	END IF;
    RETURN NEW;
END;
$$
LANGUAGE PLPGSQL;

CREATE TRIGGER JADWAL_VIOLATION
BEFORE INSERT ON MEMERIKSA 
FOR EACH ROW
EXECUTE PROCEDURE JADWAL_CHECK();

-- Fina 2.2 --

CREATE OR REPLACE FUNCTION BED_CHECK() RETURNS trigger AS 
$$
DECLARE
tmp text;
BEGIN
    tmp := TG_TABLE_NAME::regclass::text;
    IF (tmp = 'bed_rs') THEN
        UPDATE RUANGAN_RS 
        SET JmlBed = JmlBed + 1
        WHERE KodeRS = NEW.KodeRS AND KodeRuangan = NEW.KodeRuangan;
    ELSE
        UPDATE RUANGAN_RS 
        SET JmlBed = JmlBed - 1
        WHERE KodeRS = NEW.KodeRS AND KodeRuangan = NEW.KodeRuangan;
    END IF;
    RETURN NEW;
END;
$$ 
LANGUAGE PLPGSQL;

CREATE TRIGGER INCBED
AFTER INSERT ON BED_RS
FOR EACH ROW
EXECUTE PROCEDURE BED_CHECK();

CREATE TRIGGER DECBED
AFTER INSERT ON RESERVASI_RS
FOR EACH ROW
EXECUTE PROCEDURE BED_CHECK();


---- Iqbal ----

---- Auto-Generate idTransaksi Varchar ----
CREATE OR REPLACE FUNCTION hotel_id() 
RETURNS VARCHAR AS 
$$
DECLARE
    idTransaksi VARCHAR;
    BEGIN
        SELECT IdTransaksi INTO idTransaksi
        FROM TRANSAKSI_HOTEL
        ORDER BY IdTransaksi DESC
        limit 1;
        idTransaksi := lpad((idTransaksi::integer + 1)::varchar, 10, '0');

        RETURN idTransaksi;
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
        idTransaksi varchar;
    BEGIN
        SELECT DATE_PART('day', NEW.TglKeluar::TIMESTAMP - NEW.TglMasuk::TIMESTAMP) AS dayDiff;
        SELECT HARGA into hargaRoom
        FROM HOTEL_ROOM HR
        WHERE HR.KodeHotel = NEW.KodeHotel
        AND HR.KodeRoom = NEW.KodeRoom;
        SELECT dayDiff*hargaRoom INTO total;
        SELECT hotel_id() INTO idTransaksi;
        
        INSERT INTO TRANSAKSI_HOTEL(IdTransaksi, KodePasien, TotalBayar, StatusBayar)
        VALUES (idTransaksi, NEW.KodePasien, total, 'Belum Lunas');
    END;
$$
LANGUAGE PLPGSQL;

---- FUNCTION TRANSAKSI_BOOKING ----
CREATE OR REPLACE FUNCTION make_booking_transaction()
RETURNS TRIGGER AS
$$
    DECLARE
        tglMasuk DATE;
    BEGIN
        SELECT TglMasuk INTO tglMasuk
        FROM RESERVASI_HOTEL RH
        WHERE RH.KodePasien = NEW.KodePasien;

        INSERT INTO TRANSAKSI_BOOKING
        VALUES (NEW.idTransaksi, NEW.KodePasien, tglMasuk, NEW.TotalBayar);
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








-- Gabriel 3 --

-- Id generator
CREATE OR REPLACE FUNCTION CREATE_ID()
RETURNS id AS
$$
    DECLARE
        nextId id;
    BEGIN
        SELECT IdTransaksi INTO nextId  
        FROM TRANSAKSI_RS 
        ORDER BY IdTransaksi DESC
        LIMIT 1;
        nextId := lpad((nextId::integer + 1)::varchar, 10, '0');
        RETURN nextId;
    END;
$$
LANGUAGE PLPGSQL;

-- Function
CREATE OR REPLACE FUNCTION MAKE_HOSPITAL_TRANSACTION()\
RETURNS TRIGGER AS
$$
    BEGIN
        INSERT INTO TRANSAKSI_RS 
        VALUES (SELECT CREATE_ID(), NEW.KodePasien, NULL, NULL, NEW.TglMasuk, NULL, 'Belum Lunas');
    END;
$$
LANGUAGE PLPGSQL;

-- Trigger
CREATE TRIGGER ON_CREATE_HOSPITAL_RESERVATION
AFTER INSERT ON RESERVASI_RS
FOR EACH ROW
EXECUTE PROCEDURE MAKE_HOSPITAL_TRANSACTION();