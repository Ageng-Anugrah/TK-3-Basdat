-- 1 --

CREATE OR REPLACE FUNCTION CHECK_PASSWORD() RETURNS TRIGGER AS
$$
DECLARE 
	pass text;
    valid BOOLEAN:= FALSE;
BEGIN
    SELECT password into pass FROM AKUN_PENGGUNA WHERE username = NEW.username;
    IF(pass != upper(pass) AND (select pass ~ '^[0-9\.]+$')) THEN
        valid:= TRUE;
    END IF;
    IF (valid) THEN
        RETURN NEW;
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
    jumlah integer;
BEGIN
    SELECT SUM(harga) into jumlah
    FROM (
            SELECT *
            FROM (
                    (
                        SELECT *
                        FROM DAFTAR_PESAN DP
                        WHERE DP.idTransaksiMakan = NEW.idTransaksiMakan and DP.id_transaksi = NEW.idTransaksi
                    ) AS pesanan_sesuai_transaksi_makan
                    JOIN PAKET_MAKAN PM 
                    ON PM.kodeHotel = DP.kodeHotel and PM.kodePaket = DP.kodePaket
                ) AS pesanan_dan_harga
        ) AS final;

    UPDATE TRANSAKSI_HOTEL TH
    SET totalbayar = totalbayar + jumlah
    WHERE NEW.idTransaksi = TH.idTransaksi;
    RETURN NEW;
END 
$$ 
LANGUAGE PLPGSQL;

CREATE TRIGGER add_nominal_transaksi_hotel
AFTER INSERT ON TRANSAKSI_MAKAN 
FOR EACH ROW 
EXECUTE PROCEDURE add_nominal_transaksi_hotel();

-- Fina 2.1 --
CREATE OR REPLACE FUNCTION JADWAL_CHECK() RETURNS TRIGGER AS
$$
DECLARE 
	count_jadwal integer;
BEGIN
    SELECT COUNT(*) into count_jadwal
    FROM MEMERIKSA
    WHERE Username_Dokter = NEW.Username_Dokter AND 
          Praktek_Shift = NEW.Praktek_Shift AND
          Tgl_Periksa = NEW.Tgl_Periksa AND
		  Kode_Faskes = NEW.Kode_Faskes;
          
    IF(count_jadwal >= 30) THEN
        RAISE EXCEPTION 'Jadwal konsultasi tidak dapat dibuat. Telah terdapat 30 antrian pasien';
	END IF;
    UPDATE JADWAL_DOKTER 
    SET JmlPasien = count_jadwal + 1
    FROM JADWAL_DOKTER J, MEMERIKSA
    WHERE J.Username = NEW.Username_Dokter AND
        J.Tanggal = NEW.Tgl_Periksa AND
        J.Shift = NEW.Praktek_Shift AND
        J.Kode_Faskes = NEW.Kode_Faskes;
    RETURN NEW;
END;
$$
LANGUAGE PLPGSQL;

CREATE TRIGGER JADWAL_VIOLATION
BEFORE INSERT ON MEMERIKSA 
FOR EACH ROW
EXECUTE PROCEDURE JADWAL_CHECK();

-- Fina 2.2 --
-- belum -- 
CREATE OR REPLACE FUNCTION INCBED_CHECK() RETURNS trigger AS 
$$
BEGIN
	UPDATE RUANGAN_RS 
	SET JmlBed = JmlBed + 1
	WHERE KodeRS = NEW.KodeRS AND
		  KodeRuangan = NEW.KodeRuangan;
	RETURN NEW;
END;
$$ 
LANGUAGE PLPGSQL;

CREATE TRIGGER INCJUMLAHBED
AFTER INSERT ON BED_RS
FOR EACH ROW
EXECUTE PROCEDURE JUMLAHBED_CHECK();

CREATE OR REPLACE FUNCTION DECJUMLAHBED_CHECK() RETURNS trigger AS 
$$
BEGIN
	UPDATE RUANGAN_RS 
	SET JmlBed = JmlBed - 1
	WHERE KodeRS = NEW.KodeRS AND
		  KodeRuangan = NEW.KodeRuangan;
    RETURN NEW;
END;
$$ 
LANGUAGE PLPGSQL;

CREATE TRIGGER DECJUMLAHBED
AFTER INSERT ON RESERVASI_RS
FOR EACH ROW
EXECUTE PROCEDURE JUMLAHBED_CHECK();

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
        idTransaksi := lpad((_r::integer + 1)::varchar, 10, '0');

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
    BEGIN
        SELECT DATEDIFF(day, NEW.TglMasuk, NEW.TglKeluar) into dayDiff;
        SELECT HARGA into hargaRoom
        FROM HOTEL_ROOM HR
        WHERE HR.KodeHotel = NEW.KodeHotel
        AND HR.KodeRoom = NEW.KodeRoom;
        SELECT dayDiff*hargaRoom INTO total;
        
        INSERT INTO TRANSAKSI_HOTEL(IdTransaksi, KodePasien, TotalBayar, StatusBayar)
        VALUES (SELECT hotel_id(), NEW.KodePasien, total, 'Belum Lunas');
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
        VALUES (NEW.idTransaksi, NEW.KodePasien, tglMasuk, NEW.TotalBayar)
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