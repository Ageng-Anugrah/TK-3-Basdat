-- 2.1 --
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

-- 2.2 --

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