CREATE DATABASE TrungTam_TDTT;

use TrungTam_TDTT

create table PHONGTAP
(
	MAPH char (5) primary key,
	TENPHONG varchar(50),
	DIACHI varchar (100),
	SUCCHUA int,
	TRANGTHAI varchar(20)
);

create table HUANLUYENVIEN
(
	MAHLV char(5) primary key,
	HOTEN  varchar(50),
	CHUYENMON varchar(50), 
	SDT varchar (15),
	EMAIL varchar (50)
);

create table HOCVIEN
(
	MAHV char (5) primary key,
	HOTEN varchar (50),
	NGSINH smalldatetime,
	SDT varchar(15),
	DIACHI varchar (100),
	GIOITINH varchar (10),
	NGTG smalldatetime
);

CREATE TABLE LOPTAP
(
    MALOP CHAR(5) PRIMARY KEY,
    MAPH CHAR(5),
    MAHLV CHAR(5),
    TENLOP VARCHAR(50),
    NGAYBD SMALLDATETIME,
    NGAYKT SMALLDATETIME,
    TRANGTHAI VARCHAR(20)
);


create table DANGKY
(
	MAHV char(5),
	MALOP char(5),
	NGAYDK smalldatetime,
	CONSTRAINT pk_dangky primary key (MAHV, MALOP)
);

create table LICHTAP 
(
	MALOP char(5),
	NGAYTAP smalldatetime,
	GIOBATDAU time,
	GIOKETTHUC time
	CONSTRAINT pk_lichtap primary key (MALOP, NGAYTAP, GIOBATDAU)
);

ALTER TABLE LOPTAP ADD FOREIGN KEY (MAPH) REFERENCES PHONGTAP(MAPH);
ALTER TABLE LOPTAP ADD FOREIGN KEY (MAHLV) REFERENCES HUANLUYENVIEN(MAHLV);
ALTER TABLE DANGKY ADD FOREIGN KEY (MAHV) REFERENCES HOCVIEN(MAHV);
ALTER TABLE DANGKY ADD FOREIGN KEY (MALOP) REFERENCES LOPTAP(MALOP);
ALTER TABLE LICHTAP ADD FOREIGN KEY (MALOP) REFERENCES LOPTAP(MALOP);

INSERT INTO PHONGTAP VALUES ('PH001', 'Yoga Linh Dam', 'Ha Noi', 25, 'Hoat dong'), ('PH002', 'Gym Nguyen Van Cu', 'TP.HCM', 60, 'Hoat dong');
INSERT INTO HUANLUYENVIEN VALUES ('HLV01', 'Pham Thi Hong', 'Yoga', '0905127656', 'hong.yoga@gmail.com'), ('HLV02','Le Minh Quan', 'Gym', '0916947354', 'quan.gym@gmail.com' );
set dateformat dmy;
INSERT INTO HOCVIEN VALUES ('HV001','Tran Van Bao','20/5/2002 ', '0878691539', 'Ha Noi', 'Nam', '1/11/2024'), ('HV002', 'Ho Thi Mai', '11/9/2000', '0931212890', 'Quang Ngai','Nu','2/12/2024');
INSERT INTO LOPTAP VALUES ('LT001', 'PH001', 'HLV01', 'Yoga fo Beginners','06/4/2025 ', '05/5/2025', 'Da ket thuc'), ('LT002', 'PH002', 'HLV02', 'Morning Gym', '16/5/2025', '15/6/2025', 'Dang hoat dong');
INSERT INTO DANGKY VALUES ('HV001', 'LT001', '15/3/2025'), ('HV002', 'LT002', '29/4/2025');
INSERT INTO LICHTAP VALUES ('LT001', '07/4/2025', '18:30', '19:30'), ('LT001', '13/4/2025', '19:00', '20:00'), ('LT002', '18/5/2025', '7:00', '8:00'), ('LT002', '25/5/2025', '7:30', '8:30');   
