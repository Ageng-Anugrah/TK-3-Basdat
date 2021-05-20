CREATE OR REPLACE FUNCTION CREATE_ID()
RETURNS VARCHAR(10) AS
$$
    DECLARE
        nextId VARCHAR(10);
    BEGIN
        SELECT IdTransaksi INTO nextId  
        FROM TRANSAKSI_RS 
        ORDER BY IdTransaksi DESC
        LIMIT 1;

        if nextId is null then
            nextId := '0000000001';
            return nextId;
        end if;

        nextId := lpad((nextId::integer + 1)::varchar, 10, '0');
        RETURN nextId;
    END;
$$
LANGUAGE PLPGSQL;



CREATE OR REPLACE FUNCTION MAKE_HOSPITAL_TRANSACTION()
RETURNS TRIGGER AS
$$
    DECLARE
        transactionId VARCHAR(10);
        numOfDays int;
        grandTotal int;
    BEGIN
        SELECT CREATE_ID() INTO transactionId;

        SELECT DATE_PART('day', NEW.TglKeluar::timestamp - NEW.TglMasuk::timestamp) INTO numOfDays;
        grandTotal := numOfDays * 500000;

        INSERT INTO TRANSAKSI_RS 
        VALUES (transactionId, NEW.KodePasien, NULL, NULL, NEW.TglMasuk, grandTotal, 'Belum Lunas');

        RETURN NEW;
    END;
$$
LANGUAGE PLPGSQL;



CREATE TRIGGER ON_CREATE_HOSPITAL_RESERVATION
AFTER INSERT ON RESERVASI_RS
FOR EACH ROW
EXECUTE PROCEDURE MAKE_HOSPITAL_TRANSACTION();
