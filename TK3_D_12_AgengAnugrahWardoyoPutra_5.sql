CREATE OR REPLACE FUNCTION add_nominal_transaksi_hotel() 
RETURNS trigger AS 
$$
DECLARE 
    harga integer;
BEGIN
    IF (TG_OP = 'INSERT') THEN
        SELECT PM.harga into harga
        FROM PAKET_MAKAN PM
        WHERE NEW.kodehotel = PM.kodehotel AND NEW.kodepaket = PM.kodepaket;

        UPDATE TRANSAKSI_MAKAN TM
        SET totalbayar = totalbayar + harga
        WHERE NEW.id_transaksi = TM.idTransaksi AND NEW.IdTransaksiMakan = TM.IdTransaksiMakan;

        UPDATE TRANSAKSI_HOTEL TH
        SET totalbayar = totalbayar + harga
        WHERE NEW.id_transaksi = TH.idTransaksi;
        RETURN NEW;

    ELSIF (TG_OP = 'DELETE') THEN
        SELECT PM.harga into harga
        FROM PAKET_MAKAN PM
        WHERE OLD.kodehotel = PM.kodehotel AND OLD.kodepaket = PM.kodepaket;

        UPDATE TRANSAKSI_MAKAN TM
        SET totalbayar = totalbayar - harga
        WHERE OLD.id_transaksi = TM.idTransaksi AND OLD.IdTransaksiMakan = TM.IdTransaksiMakan;

        UPDATE TRANSAKSI_HOTEL TH
        SET totalbayar = totalbayar - harga
        WHERE OLD.id_transaksi = TH.idTransaksi;
        RETURN OLD;
    END IF;
END 
$$ 
LANGUAGE PLPGSQL;

CREATE TRIGGER add_nominal_transaksi_hotel
AFTER INSERT OR DELETE ON DAFTAR_PESAN
FOR EACH ROW 
EXECUTE PROCEDURE add_nominal_transaksi_hotel();