-- Ageng --
INSERT INTO rumah VALUES
    ('r1','Rumah Pondok Indah','1','Dulu Aja ','Pondok Pinang ','Kebayoran Lama','Jakarta Selatan','DKI Jakarta'),
    ('r2','Home Sweet Home','1','Mundur','Kemiri Muka','Beji','Depok','Jawa Barat '),
    ('r3','Rumah Joglo','0','Maju','Pengasinan','Sawangan','Depok','Jawa Barat '),
    ('r4','Rumah Gadang','0','Tersesat','Gambir','Gambir ','Jakrata Pusat','DKI Jakarta'),
    ('r5','Rumah Selaso Jatuh Kembar','1','Yang Lurus','Ancol','Pademangan','Jakarta Utara','DKI Jakarta'),
    ('r6','Rumah Panggung','0','Ga Benar','Cibogor','Bogor Tengah ','Bogor','Jawa Barat ');

INSERT INTO kamar_rumah VALUES
    ('r1','k1','Triple Single Bed',0),
    ('r1','k2','Queen Bed',0),
    ('r1','k3','Twin Single Bed',0),
    ('r2','k1','Twin Single Bed',0),
    ('r2','k2','Twin Single Bed',0),
    ('r3','k1','Triple Single Bed',215000),
    ('r3','k2','Queen Bed',410000),
    ('r4','k1','Twin Single Bed',280000),
    ('r5','k1','Triple Single Bed',0),
    ('r6','k1','Queen Bed',390000);

INSERT INTO reservasi_rumah VALUES
    ('3111202104661111','2020-06-15 00:00:00','2020-06-29 00:00:00','r1','k1'),
    ('3110200709772121','2020-09-01 00:00:00','2020-10-11 00:00:00','r1','k2'),
    ('3101010909870002','2020-11-10 00:00:00','2020-11-25 00:00:00','r2','k1'),
    ('3101013009870009','2020-07-13 00:00:00','2020-07-31 00:00:00','r3','k1'),
    ('5110230805770051','2020-08-17 00:00:00','2020-08-27 00:00:00','r3','k2'),
    ('1655287447352341','2020-09-08 00:00:00','2020-09-22 00:00:00','r4','k1'),
    ('7372576607771001','2020-12-31 00:00:00','2021-01-14 00:00:00','r5','k1'),
    ('3390304559381002','2020-03-01 00:00:00','2020-03-10 00:00:00','r3','k1'),
    ('3132641005262222','2020-10-16 00:00:00','2020-10-30 00:00:00','r4','k1'),
    ('3191645197734435','2020-10-18 00:00:00','2020-10-27 00:00:00','r6','k1'),
    ('3688115074487853','2021-01-15 00:00:00','2021-01-28 00:00:00','r6','k1');

INSERT INTO transaksi_rumah VALUES
    ('tr1','3101013009870009','2020-08-01 00:00:00','2020-08-01 19:10:25',3870000,'dibayar','2020-07-13 00:00:00'),
    ('tr2','5110230805770051','2020-08-27 00:00:00','2020-08-27 17:20:14',4100000,'dibayar','2020-08-17 00:00:00'),
    ('tr3','1655287447352341','2020-09-25 00:00:00','2020-09-25 21:43:59',3920000,'dibayar','2020-09-08 00:00:00'),
    ('tr4','3390304559381002',NULL,NULL,1935000,'belum bayar','2020-03-01 00:00:00'),
    ('tr5','3132641005262222',NULL,NULL,3920000,'belum bayar','2020-10-16 00:00:00'),
    ('tr6','3191645197734435','2020-10-30 00:00:00','2020-10-30 23:54:59',3510000,'dibayar','2020-10-18 00:00:00'),
    ('tr7','3688115074487853',NULL,NULL,5070000,'belum bayar','2021-01-15 00:00:00');

INSERT INTO gedung VALUES
    ('g1','Gama Tower','1','Rasuna Said','Karet Kuningan','Setiabudi','Jakarta Selatan','DKI Jakarta'),
    ('g2','Wisma 46','0','Jendral Sudirman','Karet Tengsin','Tanah Abang','Jakarta Pusat ','DKI Jakarta'),
    ('g3','Sahid Sudirman','0','Jendral Sudirman','Karet Tengsin','Tanah Abang','Jakarta Pusat ','DKI Jakarta'),
    ('g4','Pakubuwono Signature','1','Pakubuwono','Gunung','Kebayoran Baru','Jakarta Selatan','DKI Jakarta'),
    ('g5','World Capital Tower','1','Mega Kuningan Barat','Kuningan ','Setiabudi','Jakarta Selatan','DKI Jakarta');

INSERT INTO ruangan_gedung VALUES
    ('g1','ru1','Flamboyan'),
    ('g1','ru2','Asoka '),
    ('g2','ru1','Kamboja'),
    ('g2','ru2','Alamanda'),
    ('g2','ru3','Lily'),
    ('g3','ru1','Amarilis'),
    ('g3','ru2','Kenanga'),
    ('g4','ru1','Lavender'),
    ('g5','ru1','Bougenville'),
    ('g5','ru2','Jakaranda');

INSERT INTO tempat_tidur_gedung VALUES
    ('g1','ru1','t1'),
    ('g1','ru2','t1'),
    ('g1','ru1','t2'),
    ('g2','ru1','t1'),
    ('g2','ru2','t1'),
    ('g2','ru2','t2'),
    ('g2','ru3','t1'),
    ('g3','ru1','t1'),
    ('g3','ru1','t2'),
    ('g3','ru2','t1'),
    ('g4','ru1','t1'),
    ('g4','ru1','t2'),
    ('g5','ru1','t1'),
    ('g5','ru1','t2'),
    ('g5','ru2','t1');

INSERT INTO reservasi_gedung VALUES
    ('5103040804030015','2020-01-08 00:00:00','2020-01-18 00:00:00','g1','ru1','t1'),
    ('3101010909000003','2020-01-25 00:00:00','2020-02-10 00:00:00','g1','ru2','t1'),
    ('3210080812740211','2020-03-03 00:00:00','2020-03-15 00:00:00','g2','ru2','t1'),
    ('3101220900871001','2020-04-28 00:00:00','2020-05-10 00:00:00','g2','ru2','t2'),
    ('1102010909981105','2020-05-15 00:00:00','2020-05-29 00:00:00','g2','ru3','t1'),
    ('3291126228711002','2020-06-08 00:00:00','2020-06-28 00:00:00','g3','ru1','t2'),
    ('3224154119263456','2020-07-09 00:00:00','2020-07-25 00:00:00','g3','ru2','t1'),
    ('3284343615071287','2020-11-25 00:00:00','2020-12-12 00:00:00','g4','ru1','t1'),
    ('3217043568559759','2020-12-14 00:00:00','2020-12-31 00:00:00','g4','ru1','t2'),
    ('3235694879182454','2021-02-08 00:00:00','2021-02-19 00:00:00','g5','ru1','t2');


-- Gabriel --
