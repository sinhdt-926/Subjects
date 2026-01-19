--Câu 1. Ngày mua hàng (NGHD) của một khách hàng thành viên sẽ lớn hơn hoặc bằng ngày khách hàng đó
--đăng ký thành viên (NGDK).
CREATE TRIGGER trg_ckngdk_hoadon
ON HOADON
AFTER INSERT, UPDATE 
AS 
BEGIN
	IF EXISTS (SELECT * 
			   FROM inserted i JOIN KHACHHANG KH ON KH.MAKH = i.MAKH
			   WHERE i.MAKH IS NOT NULL AND i.NGHD < KH.NGDK)
	BEGIN
		RAISERROR ('NGAY MUA HANG PHAI LON HON NGAY DANG KY', 16, 1);
		ROLLBACK;
	END
END;

--Câu 2. Ngày bán hàng (NGHD) của một nhân viên phải lớn hơn hoặc bằng ngày nhân viên đó vào làm.
GO
CREATE TRIGGER trg_ckngvl_hoadon
ON HOADON 
AFTER INSERT, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT *
			   FROM inserted i JOIN NHANVIEN NV ON NV.MANV = i.MANV
			   WHERE i.NGHD < NV.NGVL)
	BEGIN
		RAISERROR ('NGAY BAN HANG PHAI LON HON NGAY VAO LAM CUA NHAN VIEN', 16, 1);
		ROLLBACK;
	END
END;
--Câu 3. Trị giá của một hóa đơn là tổng thành tiền (số lượng*đơn giá) của các chi tiết thuộc hóa đơn đó.
GO 
CREATE TRIGGER trg_tgiahd_hoadon
ON HOADON
AFTER INSERT, UPDATE
AS 
BEGIN 
	UPDATE HD
	SET HD.TRIGIA = (SELECT SUM(CT.SL * SP.GIA)
				  FROM CTHD CT JOIN SANPHAM SP ON SP.MASP = CT.MASP
				  WHERE CT.SOHD = HD.SOHD)
	FROM HOADON HD JOIN inserted i ON i.SOHD = HD.SOHD
END;

--Câu 4. Doanh số của một khách hàng là tổng trị giá các hóa đơn mà khách hàng thành viên đó đã mua.
GO
CREATE TRIGGER trg_doanhso_khachhang
ON KHACHHANG
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE KH
    SET DOANHSO = (
        SELECT SUM(HD.TRIGIA)
        FROM HOADON HD
        WHERE HD.MAKH = KH.MAKH
    )
    FROM KHACHHANG KH
    JOIN inserted I ON KH.MAKH = I.MAKH;  
END
GO


--SỬ DỤNG CƠ SỞ DỮ LIỆU: QUẢN LÝ GIÁO VỤ
--Câu 1. Lớp trưởng của một lớp phải là học viên của lớp đó.
CREATE TRIGGER trg_ins_udt_LopTruong
ON LOP
AFTER INSERT, UPDATE
AS
BEGIN
	IF NOT EXISTS (SELECT *
				   FROM inserted I, HOCVIEN HV
				   WHERE I.TRGLOP = HV.MAHV AND I.MALOP = HV.MALOP)
	BEGIN
		RAISERROR ('Error: Lop truong cua mọ lop phai la hoc vien cua lop do',16 ,1 );
		ROLLBACK TRANSACTION
	END
END;

GO
CREATE TRIGGER trg_del_LopTruong
ON HOCVIEN
AFTER DELETE
AS
BEGIN
	IF EXISTS (SELECT *
				   FROM deleted D JOIN LOP L ON D.MAHV = L.TRGLOP
				   WHERE D.MALOP = L.MALOP)
	BEGIN
		RAISERROR ('Error: Hoc vien hien tai dang la truong lop',16 ,1 );
		ROLLBACK TRANSACTION
	END
END;
--Câu 2. Trưởng khoa phải là giáo viên thuộc khoa và có học vị “TS” hoặc “PTS”.
CREATE TRIGGER trg_Check_TRGKHOA
ON KHOA
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT I.MAKHOA
        FROM inserted I
        WHERE I.TRGKHOA IS NOT NULL AND NOT EXISTS (
            SELECT *
            FROM GIAOVIEN GV
            WHERE GV.MAGV = I.TRGKHOA
                AND GV.MAKHOA = I.MAKHOA
                AND (GV.HOCVI = 'TS' OR GV.HOCVI = 'PTS')
        )
    )
    BEGIN
        RAISERROR('Truong khoa phai là giao vien thuoc khoa, có học vị TS hoac PTS.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
--Câu 3. Học viên chỉ được thi một môn học nào đó khi lớp của học viên đã học xong môn học này.
CREATE TRIGGER trg_Check_monthi
ON KETQUATHI
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT I.MAHV
        FROM inserted I JOIN HOCVIEN HV ON I.MAHV = HV.MAHV
        LEFT JOIN GIANGDAY GD ON HV.MALOP = GD.MALOP AND I.MAMH = GD.MAMH
        WHERE GD.DENNGAY IS NULL OR I.NGTHI < GD.DENNGAY -- Có thể phức tạp hơn, nhưng đơn giản là phải học xong
    )
    BEGIN
        RAISERROR('Hoc vien chi duoc thi khi lop da hoc xong mon hoc nay.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

--Câu 4. Mỗi học kỳ của một năm học, một lớp chỉ được học tối đa 3 môn.
CREATE TRIGGER trg_Check_SoMon
ON GIANGDAY
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT G.MALOP, G.HOCKY, G.NAM
        FROM GIANGDAY G
        JOIN inserted I ON G.MALOP = I.MALOP AND G.HOCKY = I.HOCKY AND G.NAM = I.NAM
        GROUP BY G.MALOP, G.HOCKY, G.NAM
        HAVING COUNT(DISTINCT G.MAMH) > 3
    )
    BEGIN
        RAISERROR('Moi học ky của mot nam hoc, mot lop chi duoc hoc toi da 3 mon.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

--Câu 5. Sỉ số của một lớp bằng với số lượng học viên thuộc lớp đó.
CREATE TRIGGER trg_Update_SiSo
ON HOCVIEN
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @AffectedMALOP TABLE (MALOP CHAR(3));
    INSERT INTO @AffectedMALOP (MALOP)
    SELECT MALOP FROM inserted
    UNION
    SELECT MALOP FROM deleted;

    UPDATE LOP
    SET SISO = (
        SELECT COUNT(HV.MAHV)
        FROM HOCVIEN HV
        WHERE HV.MALOP = LOP.MALOP
    )
    WHERE MALOP IN (SELECT MALOP FROM @AffectedMALOP);
END;

--Câu 6. Trong quan hệ DIEUKIEN giá trị của thuộc tính MAMH và MAMH_TRUOC trong cùng một bộ không
--được giống nhau (“A”,”A”) và cũng không tồn tại hai bộ (“A”,”B”) và (“B”,”A”).
CREATE TRIGGER trg_Check_DIEUKIEN_Symmetry
ON DIEUKIEN
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE MAMH = MAMH_TRUOC)
    BEGIN
        RAISERROR('Mon hoc truoc khong the la chinh no.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    IF EXISTS (
        SELECT I.MAMH
        FROM inserted I JOIN DIEUKIEN D
        ON I.MAMH = D.MAMH_TRUOC AND I.MAMH_TRUOC = D.MAMH
    )
    BEGIN
        RAISERROR('Khong the ton tai dieu kien rang buoc doi xung (A,B) va (B,A).', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;

--Câu 7. Các giáo viên có cùng học vị, học hàm, hệ số lương thì mức lương bằng nhau.
CREATE TRIGGER trg_Check_MucLuong
ON GIAOVIEN
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT I.MAGV
        FROM inserted I JOIN GIAOVIEN GV ON
            I.HOCVI = GV.HOCVI AND I.HOCHAM = GV.HOCHAM AND I.HESO = GV.HESO
            AND I.MAGV <> GV.MAGV 
        WHERE I.MUCLUONG <> GV.MUCLUONG
    )
    BEGIN
        RAISERROR('Cac giao vien co cung hoc vi, hoc ham, he so luong thi muc luong bang nhau.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

--Câu 8. Học viên chỉ được thi lại (lần thi >1) khi điểm của lần thi trước đó dưới 5.
CREATE TRIGGER trg_Check_ThiLai
ON KETQUATHI
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT I.MAHV
        FROM inserted I
        JOIN KETQUATHI KQT_PREV ON
            I.MAHV = KQT_PREV.MAHV AND I.MAMH = KQT_PREV.MAMH
        WHERE I.LANTHI > 1
            AND I.LANTHI = KQT_PREV.LANTHI + 1
            AND KQT_PREV.DIEM >= 5.00
    )
    BEGIN
        RAISERROR(N'Hoc vien chi duoc thi lai khi diem cua lan thi truoc do duoi 5', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

--Câu 9. Ngày thi của lần thi sau phải lớn hơn ngày thi của lần thi trước (cùng học viên, cùng môn học).
CREATE TRIGGER trg_Check_NgayThiLai
ON KETQUATHI
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT I.MAHV
        FROM inserted I
        JOIN KETQUATHI KQT_PREV ON
            I.MAHV = KQT_PREV.MAHV AND I.MAMH = KQT_PREV.MAMH
        WHERE I.LANTHI > 1
            AND I.LANTHI = KQT_PREV.LANTHI + 1
            AND I.NGTHI <= KQT_PREV.NGTHI
    )
    BEGIN
        RAISERROR(N'Ngay thi cua lan thi sau phai lon hon ngay thi cua lan thi truoc', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

--Câu 10. Học viên chỉ được thi những môn mà lớp của học viên đó đã học xong.
CREATE TRIGGER trg_Check_DieuKienThi
ON KETQUATHI
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT I.MAHV
        FROM inserted I JOIN HOCVIEN HV ON I.MAHV = HV.MAHV
        WHERE NOT EXISTS (
            SELECT *
            FROM GIANGDAY GD
            WHERE GD.MALOP = HV.MALOP AND GD.MAMH = I.MAMH
        )
    )
    BEGIN
        RAISERROR(N'Hoc vien chi duoc thi nhung mon ma lop cua hoc vien do da hoc xong.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

--Câu 11. Khi phân công giảng dạy một môn học, phải xét đến thứ tự trước sau giữa các môn học (sau khi học
--xong những môn học phải học trước mới được học những môn liền sau).
CREATE TRIGGER trg_Check_GIANGDAY_ThuTuMonHoc
ON GIANGDAY
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT I.MALOP
        FROM inserted I JOIN DIEUKIEN DK ON I.MAMH = DK.MAMH
        JOIN GIANGDAY GD_TRUOC ON
            GD_TRUOC.MALOP = I.MALOP AND GD_TRUOC.MAMH = DK.MAMH_TRUOC
        WHERE I.TUNGAY <= GD_TRUOC.DENNGAY
    )
    BEGIN
        RAISERROR(N'Mon hoc truoc phai duoc hoc xong truoc khi hoc mon lien sau no.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

--Câu 12. Giáo viên chỉ được phân công dạy những môn thuộc khoa giáo viên đó phụ trách.
CREATE TRIGGER trg_Check_PhanCong_GV_Khoa
ON GIANGDAY
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT I.MAGV
        FROM inserted I JOIN GIAOVIEN GV ON I.MAGV = GV.MAGV
        JOIN MONHOC MH ON I.MAMH = MH.MAMH
        WHERE GV.MAKHOA <> MH.MAKHOA
    )
    BEGIN
        RAISERROR(N'Giao vien chi duoc phan cong day nhung mon thuoc khoa giao vien do phu trach.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;