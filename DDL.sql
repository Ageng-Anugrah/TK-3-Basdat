DROP SCHEMA SIRUCO CASCADE;
CREATE SCHEMA SIRUCO;
SET SEARCH_PATH TO SIRUCO;

-- Fina --
CREATE TABLE AKUN_PENGGUNA(
    Username VARCHAR(50) NOT NULL,
    Password VARCHAR(20) NOT NULL,
    Peran VARCHAR(20) NOT NULL,
    PRIMARY KEY (Username)
);

CREATE TABLE ADMIN(
    Username VARCHAR(50) NOT NULL,
    PRIMARY KEY (Username),
    FOREIGN KEY (Username) REFERENCES AKUN_PENGGUNA (Username) ON UPDATE CASCADE ON DELETE CASCADE

);

CREATE TABLE PENGGUNA_PUBLIK(
    Username VARCHAR(50) NOT NULL,
    NIK VARCHAR(20) NOT NULL,
    Nama VARCHAR(50) NOT NULL,
    Status VARCHAR(10) NOT NULL,
    Peran VARCHAR(20) NOT NULL,
    NoHp VARCHAR(12) NOT NULL,
    PRIMARY KEY (Username),
    FOREIGN KEY (Username) REFERENCES AKUN_PENGGUNA (Username) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE PASIEN(
    NIK VARCHAR(20) NOT NULL,
    IdPendaftar VARCHAR(50),
    Nama VARCHAR(50) NOT NULL,
    KTP_Jalan VARCHAR(30) NOT NULL,
    KTP_Kelurahan VARCHAR(30) NOT NULL,
    KTP_Kecamatan VARCHAR(30) NOT NULL,
    KTP_KabKot VARCHAR(30) NOT NULL,
    KTP_Prov VARCHAR(30) NOT NULL,
    Dom_Jalan VARCHAR(30) NOT NULL,
    Dom_Kelurahan VARCHAR(30) NOT NULL,
    Dom_Kecamatan VARCHAR(30) NOT NULL,
    Dom_KabKot VARCHAR(30) NOT NULL,
    Dom_Prov VARCHAR(30) NOT NULL,
    NoTelp VARCHAR(20) NOT NULL,
    NoHp VARCHAR(12) NOT NULL,
    PRIMARY KEY (NIK),
    FOREIGN KEY (IdPendaftar,NIK) REFERENCES PENGGUNA_PUBLIK (Username) ON UPDATE CASCADE ON DELETE CASCADE

);

CREATE TABLE KOMORBID_PASIEN(
    NIK VARCHAR(20) NOT NULL,
    NamaKomorbid VARCHAR(50) NOT NULL,
    PRIMARY KEY (NIK, NamaKomorbid),
    FOREIGN KEY (NIK) REFERENCES PASIEN (NIK) ON UPDATE CASCADE ON DELETE CASCADE

);

CREATE TABLE GEJALA_PASIEN(
    NIK VARCHAR(20) NOT NULL,
    NamaGejala VARCHAR(50) NOT NULL,
    PRIMARY KEY (NIK, NamaGejala),
    FOREIGN KEY (NIK) REFERENCES PASIEN (NIK) ON UPDATE CASCADE ON DELETE CASCADE

);

CREATE TABLE TES(
    NIK_pasien VARCHAR(20) NOT NULL,
    TanggalTes DATE NOT NULL,
    Jenis VARCHAR(10) NOT NULL,
    Status VARCHAR(15) NOT NULL,
    NilaiCT VARCHAR(5),
    PRIMARY KEY (NIK_pasien, TanggalTes),
    FOREIGN KEY (NIK_pasien) REFERENCES PASIEN (NIK) ON UPDATE CASCADE ON DELETE CASCADE

);

CREATE TABLE DOKTER(
    Username VARCHAR(50) NOT NULL,
    NoSTR VARCHAR(20) NOT NULL,
    Nama VARCHAR(50) NOT NULL,
    NoHp VARCHAR(12) NOT NULL,
    GelarDepan VARCHAR(10) NOT NULL,
    GelarBelakang VARCHAR(10) NOT NULL,
    PRIMARY KEY (Username, NoSTR),
    FOREIGN KEY (Username) REFERENCES ADMIN (Username) ON UPDATE CASCADE ON DELETE CASCADE

);

CREATE TABLE FASKES(
    Kode VARCHAR(3) NOT NULL,
    Tipe VARCHAR(30) NOT NULL,
    Nama VARCHAR(50) NOT NULL,
    StatusMilik VARCHAR(30) NOT NULL,
    Jalan VARCHAR(30) NOT NULL,
    Kelurahan VARCHAR(30) NOT NULL,
    Kecamatan VARCHAR(30) NOT NULL,
    KabKot VARCHAR(30) NOT NULL,
    Prov VARCHAR(30) NOT NULL,
    PRIMARY KEY (Kode)
);

CREATE TABLE JADWAL(
    Kode_Faskes VARCHAR(3) NOT NULL,
    Shift VARCHAR(15) NOT NULL,
    Tanggal DATE NOT NULL,
    PRIMARY KEY (Kode_Faskes, Shift, Tanggal),
    FOREIGN KEY (Kode_Faskes) REFERENCES FASKES (Kode) ON UPDATE CASCADE ON DELETE CASCADE

);



-- Gabriel --
CREATE TABLE JADWAL_DOKTER (
    NoSTR               VARCHAR(20) NOT NULL,
    Username            VARCHAR(50) NOT NULL,
    Kode_Faskes         VARCHAR(3)  NOT NULL,
    Shift               VARCHAR(15) NOT NULL,
    Tanggal             DATE        NOT NULL,
    JmlPasien           int,
    PRIMARY KEY (NoSTR, Username, Kode_Faskes, Shift, Tanggal),
    FOREIGN KEY (NoSTR, Username)               REFERENCES DOKTER(NoSTR, Username),
    FOREIGN KEY (Kode_Faskes, Shift, Tanggal)   REFERENCES JADWAL(Kode_Faskes, Shift, Tanggal)
);

CREATE TABLE MEMERIKSA (
    NIK_Pasien          VARCHAR(20) NOT NULL,
    NoSTR               VARCHAR(20) NOT NULL,
    Username_Dokter     VARCHAR(50) NOT NULL,
    Kode_Faskes         VARCHAR(3)  NOT NULL,
    Praktek_Shift       VARCHAR(15) NOT NULL,
    Praktek_Tgl         DATE        NOT NULL,
    Rekomendasi         VARCHAR(500),
    PRIMARY KEY (NIK_Pasien, NoSTR, Username_Dokter, Kode_Faskes, Praktek_Shift, Praktek_Tgl),
    FOREIGN KEY (NoSTR, Username_Dokter, Kode_Faskes, Praktek_Shift, Praktek_Tgl) 
                                        REFERENCES JADWAL_DOKTER(NoSTR, Username, Kode_Faskes, Shift, Tanggal),
    FOREIGN KEY (NIK_Pasien)            REFERENCES PASIEN(NIK)
);

CREATE TABLE TELEPON_FASKES (
    Kode_Faskes     VARCHAR(3)  NOT NULL,
    NoTelp          VARCHAR(20) NOT NULL,
    PRIMARY KEY (Kode_Faskes, NoTelp),
    FOREIGN KEY (Kode_Faskes) REFERENCES FASKES(Kode)
);

CREATE TABLE ADMIN_SATGAS (
    Username            VARCHAR(50) NOT NULL,
    IdFaskes            VARCHAR(3),
    PRIMARY KEY (Username),
    FOREIGN KEY (Username)          REFERENCES ADMIN(Username),
    FOREIGN KEY (IdFaskes)          REFERENCES FASKES(Kode)
);

CREATE TABLE RUMAH_SAKIT (
    Kode_Faskes         VARCHAR(3)  NOT NULL,
    IsRujukan           CHAR(1)     NOT NULL,
    PRIMARY KEY (Kode_Faskes),
    FOREIGN KEY (Kode_Faskes) REFERENCES FASKES(Kode)
);

CREATE TABLE VENTILATOR (
    KodeRS              VARCHAR(3)  NOT NULL,
    KodeVentilator      VARCHAR(5)  NOT NULL,
    Kondisi             VARCHAR(10) NOT NULL,
    PRIMARY KEY (KodeRS, KodeVentilator),
    FOREIGN KEY (KodeRS) REFERENCES RUMAH_SAKIT(Kode_Faskes)
);

CREATE TABLE RUANGAN_RS (
    KodeRS              VARCHAR(3)  NOT NULL,
    KodeRuangan         VARCHAR(5)  NOT NULL,
    Tipe                VARCHAR(10) NOT NULL,
    JmlBed              int         NOT NULL,
    Harga               int         NOT NULL,
    PRIMARY KEY (KodeRS, KodeRuangan),
    FOREIGN KEY (KodeRS) REFERENCES RUMAH_SAKIT(Kode_Faskes)
);

CREATE TABLE BED_RS (
    KodeRuangan         VARCHAR(5)  NOT NULL,
    KodeRS              VARCHAR(3)  NOT NULL,
    KodeBed             VARCHAR(5)  NOT NULL,
    PRIMARY KEY (KodeRuangan, KodeRS, KodeBed),
    FOREIGN KEY (KodeRuangan, KodeRS) REFERENCES RUANGAN_RS(KodeRuangan, KodeRS)
);

CREATE TABLE RESERVASI_RS (
    KodePasien          VARCHAR(20) NOT NULL,
    TglMasuk            DATE        NOT NULL,
    TglKeluar           DATE        NOT NULL,
    KodeRS              VARCHAR(3),
    KodeRuangan         VARCHAR(5),
    KodeBed             VARCHAR(5),
    KodeVentilator      VARCHAR(5),
    PRIMARY KEY (KodePasien, TglMasuk),
    FOREIGN KEY (KodePasien)                    REFERENCES PASIEN(NIK),
    FOREIGN KEY (KodeRS, KodeRuangan, KodeBed)  REFERENCES BED_RS(KodeRS, KodeRuangan, KodeBed),
    FOREIGN KEY (KodeRS, KodeVentilator)        REFERENCES VENTILATOR(KodeRS, KodeVentilator)
);

CREATE TABLE TRANSAKSI_RS (
    IdTransaksi         VARCHAR(10) NOT NULL,
    KodePasien          VARCHAR(20),
    TanggalPembayaran   DATE,
    WaktuPembayaran     TIMESTAMP,
    TglMasuk            DATE,
    TotalBiaya          int,
    StatusBayar         VARCHAR(15) NOT NULL,
    PRIMARY KEY (IdTransaksi),
    FOREIGN KEY (KodePasien, TglMasuk)        REFERENCES RESERVASI_RS(KodePasien, TglMasuk)
);



-- Iqbal --
CREATE TABLE HOTEL (
    Kode VARCHAR(5),
    Nama VARCHAR(30) NOT NULL,
    isRujukan CHAR(1) NOT NULL,
    Jalan VARCHAR(30) NOT NULL,
    Kelurahan VARCHAR(30) NOT NULL,
    Kecamatan VARCHAR(30) NOT NULL,
    KabKot VARCHAR(30) NOT NULL,
    Prov VARCHAR(30) NOT NULL,
    PRIMARY KEY (Kode)
);

CREATE TABLE HOTEL_ROOM (
    KodeHotel VARCHAR(5),
    KodeRoom VARCHAR(5),
    JenisBed VARCHAR(10) NOT NULL,
    Tipe VARCHAR(10) NOT NULL,
    Harga INT NOT NULL,
    PRIMARY KEY (KodeHotel, KodeRoom),
    FOREIGN KEY (KodeHotel) REFERENCES HOTEL (Kode) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE PAKET_MAKAN (
    KodeHotel VARCHAR(5),
    KodePaket VARCHAR(5),
    Nama VARCHAR(20) NOT NULL,
    Harga INT NOT NULL,
    PRIMARY KEY (KodeHotel, KodePaket),
    FOREIGN KEY (KodeHotel) REFERENCES HOTEL (Kode) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE RESERVASI_HOTEL(
    KodePasien VARCHAR(20),
    TglMasuk DATE,
    TglKeluar DATE NOT NULL,
    KodeHotel VARCHAR(5),
    KodeRoom VARCHAR(5),
    PRIMARY KEY (KodePasien, TglMasuk),
    FOREIGN KEY (KodePasien) REFERENCES PASIEN (NIK) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (KodeHotel, KodeRoom) REFERENCES HOTEL_ROOM (KodeHotel, KodeRoom) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE TRANSAKSI_HOTEL (
    IdTransaksi VARCHAR(10),
    KodePasien VARCHAR(20),
    TanggalPembayaran DATE,
    WaktuPembayaran TIMESTAMP,
    TotalBayar INT,
    StatusBayar VARCHAR(15) NOT NULL,
    PRIMARY KEY (IdTransaksi),
    FOREIGN KEY (KodePasien) REFERENCES PASIEN(NIK) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE TRANSAKSI_BOOKING (
    IdTransaksiBooking VARCHAR(10),
    TotalBayar INT,
    KodePasien VARCHAR(20),
    TglMasuk DATE,
    PRIMARY KEY (IdTransaksiBooking),
    FOREIGN KEY (IdTransaksiBooking) REFERENCES TRANSAKSI_HOTEL (IdTransaksi) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (KodePasien) REFERENCES PASIEN (NIK) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (KodePasien, TglMasuk) REFERENCES RESERVASI_HOTEL (KodePasien, TglMasuk) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE TRANSAKSI_MAKAN (
    IdTransaksi VARCHAR(10),
    IdTransaksiMakan VARCHAR(10),
    TotalBayar INT,
    PRIMARY KEY (IdTransaksi, IdTransaksiMakan),
    FOREIGN KEY (IdTransaksi) REFERENCES TRANSAKSI_HOTEL (IdTransaksi) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE DAFTAR_PESAN (
    IdTransaksiMakan VARCHAR(10),
    Id_Pesanan SERIAL,
    Id_Transaksi VARCHAR(10),
    KodeHotel VARCHAR(5),
    KodePaket VARCHAR(5),
    PRIMARY KEY (IdTransaksiMakan, Id_Pesanan, Id_Transaksi),
    FOREIGN KEY (Id_Transaksi, IdTransaksiMakan) REFERENCES TRANSAKSI_MAKAN (IdTransaksi, IdTransaksiMakan) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (KodeHotel, KodePaket) REFERENCES PAKET_MAKAN (KodeHotel, KodePaket) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Ageng --
CREATE TABLE rumah (
    koderumah VARCHAR(5),
    nama VARCHAR(30) NOT NULL,
    isrujukan CHAR(1) NOT NULL,
    jalan VARCHAR(30) NOT NULL,
    kelurahan VARCHAR(30) NOT NULL,
    kecamatan VARCHAR(30) NOT NULL,
    kabkot VARCHAR(30) NOT NULL,
    prov VARCHAR(30) NOT NULL,
    PRIMARY KEY (koderumah)
);

CREATE TABLE kamar_rumah (
    koderumah VARCHAR(5),
    kodekamar VARCHAR(5),
    jenisbed VARCHAR(20) NOT NULL,
    harga INT NOT NULL,
    PRIMARY KEY (koderumah, kodekamar),
    FOREIGN KEY (koderumah) REFERENCES rumah(koderumah)
);

CREATE TABLE reservasi_rumah (
    kodepasien VARCHAR(20),
    tglmasuk DATE,
    tglkeluar DATE NOT NULL,
    koderumah VARCHAR(5),
    kodekamar VARCHAR(5),
    PRIMARY KEY (kodepasien, tglmasuk),
    FOREIGN KEY (kodepasien) REFERENCES pasien(nik),
    FOREIGN KEY (koderumah, kodekamar) REFERENCES kamar_rumah(koderumah, kodekamar)
);

CREATE TABLE transaksi_rumah (
    idtransaksi VARCHAR(10),
    kodepasien VARCHAR(20),
    tanggalpembayaran DATE,
    waktupembayaran TIMESTAMP,
    totalbayar INT,
    statusbayar VARCHAR(15) NOT NULL,
    tglmasuk DATE,
    PRIMARY KEY (idtransaksi),
    FOREIGN KEY (kodepasien, tglmasuk) REFERENCES reservasi_rumah(kodepasien, tglmasuk)
);

CREATE TABLE gedung (
    kodegedung VARCHAR(5),
    nama VARCHAR(30) NOT NULL,
    isrujukan CHAR(1) NOT NULL,
    jalan VARCHAR(30) NOT NULL,
    kelurahan VARCHAR(30) NOT NULL,
    kecamatan VARCHAR(30) NOT NULL,
    kabkot VARCHAR(30) NOT NULL,
    prov VARCHAR(30) NOT NULL,
    PRIMARY KEY (kodegedung)
);

CREATE TABLE ruangan_gedung (
    kodegedung VARCHAR(5),
    koderuangan VARCHAR(5),
    namaruangan VARCHAR(20) NOT NULL,
    PRIMARY KEY (kodegedung, koderuangan),
    FOREIGN KEY (kodegedung) REFERENCES gedung(kodegedung)
);

CREATE TABLE tempat_tidur_gedung (
    kodegedung VARCHAR(5),
    koderuangan VARCHAR(5),
    notempattidur VARCHAR(5),
    PRIMARY KEY (kodegedung, koderuangan, notempattidur),
    FOREIGN KEY (kodegedung, koderuangan) REFERENCES ruangan_gedung(kodegedung, koderuangan)
);

CREATE TABLE reservasi_gedung (
    kodepasien VARCHAR(20),
    tglmasuk DATE,
    tglkeluar DATE NOT NULL,
    kodegedung VARCHAR(5),
    noruang VARCHAR(5),
    notempattidur VARCHAR(5),
    PRIMARY KEY (kodepasien, tglmasuk),
    FOREIGN KEY (kodepasien) REFERENCES pasien(nik),
    FOREIGN KEY (kodegedung, noruang, notempattidur) REFERENCES tempat_tidur_gedung(kodegedung, koderuangan, notempattidur)
);