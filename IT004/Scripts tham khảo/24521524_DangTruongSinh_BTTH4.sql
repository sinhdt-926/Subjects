--I. Ngôn ngữ định nghĩa dữ liệu (Data Definition Language):
--Câu 1. Tạo quan hệ và khai báo tất cả các ràng buộc khóa chính, khóa ngoại. Thêm vào 3 thuộc tính GHICHU,
--DIEMTB, XEPLOAI cho quan hệ HOCVIEN.
ALTER TABLE HOCVIEN ADD GHICHU VARCHAR(15) NULL, 
						DIEMTB NUMERIC(4, 2), 
						XEPLOAI VARCHAR(15) NULL;

--Câu 2. Thuộc tính GIOITINH chỉ có giá trị là “Nam” hoặc “Nu”.
ALTER TABLE GIOITINH
ADD CONSTRAINT CK_GT CHECK (GIOITINH IN ('Nam', 'Nu'));

--Câu 3. Điểm số của một lần thi có giá trị từ 0 đến 10 và cần lưu đến 2 số lẽ (VD: 6.22).
ALTER TABLE KETQUATHI
ADD CONSTRAINT CK_DIEM CHECK (DIEM BETWEEN 0 AND 10);

--Câu 4. Kết quả thi là “Dat” nếu điểm từ 5 đến 10 và “Khong dat” nếu điểm nhỏ hơn 5.
ALTER TABLE KETQUATHI ADD CHECK
(
	(KQUA = 'Dat' AND DIEM BETWEEN 5 AND 10)
	OR (KQUA = 'Khong dat' AND DIEM < 5)
)
			
--Câu 5. Học viên thi một môn tối đa 3 lần.
ALTER TABLE KETQUATHI
ADD CONSTRAINT CK_LTHI CHECK (LANTHI BETWEEN 1 AND 3);

--Câu 6. Học kỳ chỉ có giá trị từ 1 đến 3.
ALTER TABLE GIANGDAY
ADD CONSTRAINT CK_HK CHECK (HOCKY BETWEEN 1 AND 3);

--Câu 7. Học vị của giáo viên chỉ có thể là “CN”, “KS”, “Ths”, ”TS”, ”PTS”.
ALTER TABLE GIAOVIEN
ADD CONSTRAINT CK_HVI CHECK (HOCVI IN ('CN', 'KS', 'Ths', 'TS', 'PTS'));

--Câu 8. Học viên ít nhất là 18 tuổi.
ALTER TABLE HOCVIEN
ADD CONSTRAINT CK_TUOI CHECK (GETDATE() - NGSINH >= 18);

--Câu 9. Giảng dạy một môn học ngày bắt đầu (TUNGAY) phải nhỏ hơn ngày kết thúc (DENNGAY).
ALTER TABLE GIANGDAY
ADD CONSTRAINT CK_GDMH CHECK (TUNGAY < DENNGAY);

--Câu 10. Giáo viên khi vào làm ít nhất là 22 tuổi.
ALTER TABLE GIAOVIEN
ADD CONSTRAINT CK_TUOIGV CHECK (NGVL - NGSINH >= 22);

--Câu 11. Tất cả các môn học đều có số tín chỉ lý thuyết và tín chỉ thực hành chênh lệch nhau không quá 3.
ALTER TABLE MONHOC 
ADD CONSTRAINT CK_TC CHECK (ABS(TCLT - TCTH) <= 3);

--II. Ngôn ngữ thao tác dữ liệu (Data Manipulation Language):
--Câu 1. Tăng hệ số lương thêm 0.2 cho những giáo viên là trưởng khoa.
UPDATE GIAOVIEN
SET HESO = HESO + 0.2
WHERE MAGV IN (SELECT TRGKHOA FROM KHOA);
	
--Câu 2. Cập nhật giá trị điểm trung bình tất cả các môn học (DIEMTB) của mỗi học viên (tất cả các môn học
--đều có hệ số 1 và nếu học viên thi một môn nhiều lần, chỉ lấy điểm của lần thi sau cùng).
UPDATE HOCVIEN
SET DIEMTB = (
	SELECT AVG (KQ.DIEM)
	FROM KETQUATHI KQ
	WHERE KQ.MAHV = HOCVIEN.MAHV
	AND LANTHI = (
		SELECT MAX (KQ1.LANTHI)
		FROM KETQUATHI KQ1
		WHERE KQ.MAMH = KQ1.MAMH AND KQ.MAHV = KQ1.MAHV
	)
);

--Câu 3. Cập nhật giá trị cho cột GHICHU là “Cam thi” đối với trường hợp: học viên có một môn bất kỳ thi lần
--thứ 3 dưới 5 điểm.
UPDATE HOCVIEN
SET GHICHU = 'Cam thi'
WHERE MAHV IN (
	SELECT MAHV
	FROM KETQUATHI
	WHERE LANTHI = 3 AND DIEM < 5
);

--Câu 4. Cập nhật giá trị cho cột XEPLOAI trong quan hệ HOCVIEN như sau:
--o Nếu DIEMTB  9 thì XEPLOAI =”XS”
--o Nếu 8  DIEMTB < 9 thì XEPLOAI = “G”
--o Nếu 6.5  DIEMTB < 8 thì XEPLOAI = “K”
--o Nếu 5  DIEMTB < 6.5 thì XEPLOAI = “TB”
--o Nếu DIEMTB < 5 thì XEPLOAI = ”Y”
UPDATE HOCVIEN
SET XEPLOAI =
(
	CASE 
	WHEN DIEMTB >= 9 THEN 'XS'
	WHEN DIEMTB >=8 AND DIEMTB < 9 THEN 'G'
	WHEN DIEMTB >= 6.5 AND DIEMTB < 8 THEN 'K'
	WHEN DIEMTB >= 5 AND DIEMTB < 6.5 THEN 'TB'
	ELSE 'Y'
END
);

--III. Ngôn ngữ truy vấn dữ liệu:
--Câu 1. In ra danh sách (mã học viên, họ tên, ngày sinh, mã lớp) lớp trưởng của các lớp.
SELECT L.MALOP, MAHV, CONCAT(HO, ' ', TEN) AS 'HOTEN', HV.NGSINH
FROM HOCVIEN HV
	JOIN LOP L ON HV.MAHV = L.TRGLOP;

--Câu 2. In ra bảng điểm khi thi (mã học viên, họ tên , lần thi, điểm số) môn CTRR của lớp “K12”, sắp xếp theo
--tên, họ học viên.
SELECT HV.MAHV, CONCAT(HO, ' ', TEN) AS 'HOTEN', LANTHI, DIEM
FROM HOCVIEN HV JOIN KETQUATHI KQTHI ON HV.MAHV = KQTHI.MAHV
WHERE HV.MALOP = 'K12' AND KQTHI.MAMH = 'CTRR'
ORDER BY TEN, HO;

--Câu 3. In ra danh sách những học viên (mã học viên, họ tên) và những môn học mà học viên đó thi lần thứ
--nhất đã đạt.
SELECT HV.MAHV, CONCAT(HO, ' ', TEN) AS 'HOTEN', TENMH
FROM HOCVIEN HV JOIN KETQUATHI KQTHI ON HV.MAHV = KQTHI.MAHV
	JOIN MONHOC MH ON MH.MAMH = KQTHI.MAMH
WHERE KQTHI.LANTHI = 1 AND KQUA = 'Dat';

--Câu 4. In ra danh sách học viên (mã học viên, họ tên) của lớp “K11” thi môn CTRR không đạt (ở lần thi 1).
SELECT HV.MAHV, CONCAT(HO, ' ', TEN) AS HOTEN, MAMH, LANTHI
FROM HOCVIEN HV JOIN KETQUATHI KQTHI ON HV.MAHV = KQTHI.MAHV
WHERE HV.MALOP = 'K11' AND MAMH = 'CTRR' AND KQUA = 'Khong dat' AND LANTHI = 1; 

--Câu 5. * Danh sách học viên (mã học viên, họ tên) của lớp có mã bắt đầu bằng “K” thi môn CTRR không đạt (ở tất cả các lần thi).
SELECT DISTINCT KQT.MAHV, (HO+TEN) HOTEN
FROM HOCVIEN HV JOIN KETQUATHI KQT ON HV.MAHV = KQT.MAHV
WHERE MAMH = 'CTRR' AND MALOP LIKE 'K%'
					AND KQT.MAHV NOT IN (SELECT MAHV
										 FROM KETQUATHI
										 WHERE MAMH = 'CTRR' AND KQUA = 'Dat');

--Câu 6. Tìm tên những môn học mà giáo viên có tên “Tran Tam Thanh” dạy trong học kỳ 1 năm 2006.Trang 9
SELECT DISTINCT MH.TENMH
FROM MONHOC MH JOIN GIANGDAY GD ON MH.MAMH = GD.MAMH
			JOIN GIAOVIEN GV ON GV.MAGV = GD.MAGV
WHERE GV.HOTEN = 'Tran Tam Thanh' AND GD.HOCKY = 1 AND GD.NAM = 2006;

--Câu 7. Tìm những môn học (mã môn học, tên môn học) mà giáo viên chủ nhiệm lớp “K11” dạy trong học kỳ 1
--năm 2006.
SELECT DISTINCT MH.MAMH, MH.TENMH
FROM MONHOC MH JOIN GIANGDAY GD ON GD.MAMH = MH.MAMH
			   JOIN LOP L ON L.MAGVCN = GD.MAGV
WHERE L.MALOP = 'K11' AND HOCKY = 1 AND NAM = 2006;

--Câu 8. Tìm họ tên lớp trưởng của các lớp mà giáo viên có tên “Nguyen To Lan” dạy môn “Co So Du Lieu”.
SELECT CONCAT(HO, ' ', TEN) AS 'HOTEN', L.MALOP
FROM HOCVIEN HV JOIN LOP L ON L.TRGLOP = HV.MAHV
	 JOIN GIANGDAY GD ON GD.MALOP = L.MALOP 
	 JOIN GIAOVIEN GV ON GV.MAGV = GD.MAGV
WHERE GV.HOTEN = 'Nguyen To Lan' AND GD.MAMH = 'CSDL';

--Câu 9. In ra danh sách những môn học (mã môn học, tên môn học) phải học liền trước môn “Co So Du Lieu”.
SELECT DK.MAMH_TRUOC, MH.TENMH
FROM DIEUKIEN DK JOIN MONHOC MH ON DK.MAMH_TRUOC = MH.MAMH
WHERE DK.MAMH = 'CSDL';

--Câu 10. Môn “Cau Truc Roi Rac” là môn bắt buộc phải học liền trước những môn học (mã môn học, tên môn
--học) nào.
SELECT MH.MAMH, MH.TENMH
FROM MONHOC MH JOIN DIEUKIEN DK ON MH.MAMH = DK.MAMH
WHERE DK.MAMH_TRUOC = 'CTRR';

--Câu 11. Tìm họ tên giáo viên dạy môn CTRR cho cả hai lớp “K11” và “K12” trong cùng học kỳ 1 năm 2006.
SELECT GV.HOTEN
FROM GIAOVIEN GV JOIN GIANGDAY GD ON GV.MAGV = GD.MAGV
WHERE GD.MALOP = 'K11' AND GD.MAMH = 'CTRR'
UNION
SELECT GV.HOTEN
FROM GIAOVIEN GV JOIN GIANGDAY GD ON GV.MAGV = GD.MAGV
WHERE GD.MALOP = 'K12' AND GD.MAMH = 'CTRR'

--Câu 12. Tìm những học viên (mã học viên, họ tên) thi không đạt môn CSDL ở lần thi thứ 1 nhưng chưa thi lại
--môn này.
SELECT DISTINCT HV.MAHV, (HO + ' ' + TEN) AS HOTEN
FROM HOCVIEN HV 
JOIN KETQUATHI KQ1 ON KQ1.MAHV = HV.MAHV
WHERE KQ1.MAMH = 'CSDL' AND KQ1.LANTHI = 1 AND KQ1.KQUA = 'Khong Dat' AND HV.MAHV NOT IN (
        SELECT MAHV
        FROM KETQUATHI
        WHERE MAMH = 'CSDL' AND LANTHI >= 2 
);

--Câu 13. Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào.
SELECT MAGV, HOTEN			
FROM GIAOVIEN 
WHERE MAGV NOT IN (
	SELECT DISTINCT MAGV
	FROM GIANGDAY
);

--Câu 14. Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào thuộc khoa
--giáo viên đó phụ trách.
SELECT GV.MAGV, GV.HOTEN
FROM GIAOVIEN GV
WHERE NOT EXISTS (
    SELECT *
    FROM MONHOC MH
    JOIN GIANGDAY GD ON GD.MAMH = MH.MAMH
    WHERE MH.MAKHOA = GV.MAKHOA AND GD.MAGV = GV.MAGV
);

--Câu 15. Tìm họ tên các học viên thuộc lớp “K11” thi một môn bất kỳ quá 3 lần vẫn “Khong dat” hoặc thi lần thứ
--2 môn CTRR được 5 điểm.
SELECT DISTINCT HV.MAHV, CONCAT(HO, ' ', TEN) AS HOTEN
FROM HOCVIEN HV
WHERE HV.MALOP = 'K11'
  AND (
        EXISTS (
            SELECT 1
            FROM KETQUATHI KQ1
            WHERE KQ1.MAHV = HV.MAHV AND KQ1.KQUA = 'Khong dat'
            GROUP BY KQ1.MAMH
            HAVING COUNT(*) > 3
        )

        OR

        EXISTS (
            SELECT 1
            FROM KETQUATHI KQ2
            WHERE KQ2.MAHV = HV.MAHV AND KQ2.MAMH = 'CTRR' AND KQ2.LANTHI = 2 AND KQ2.DIEM = 5
        )
      );


--Câu 16. Tìm họ tên giáo viên dạy môn CTRR cho ít nhất hai lớp trong cùng một học kỳ của một năm học.
SELECT DISTINCT GV.MAGV, HOTEN AS HOTEN
FROM GIAOVIEN GV
JOIN GIANGDAY GD ON GV.MAGV = GD.MAGV
WHERE GD.MAMH = 'CTRR' AND EXISTS (
    SELECT 1
    FROM GIANGDAY GD2
    WHERE GD2.MAGV = GV.MAGV AND GD2.MAMH = 'CTRR'
    GROUP BY GD2.HOCKY, GD2.NAM
    HAVING COUNT(DISTINCT GD2.MALOP) >= 2
);


--Câu 17. Danh sách học viên và điểm thi môn CSDL (chỉ lấy điểm của lần thi sau cùng).
SELECT HV.MAHV,CONCAT(HO, ' ', TEN) AS HOTEN, KQ.DIEM
FROM HOCVIEN HV JOIN KETQUATHI KQ ON KQ.MAHV = HV.MAHV
WHERE KQ.MAMH = 'CSDL' AND KQ.LANTHI = (
	SELECT MAX(LANTHI)
	FROM KETQUATHI KQ1 
	WHERE KQ.MAHV = KQ1.MAHV AND KQ1.MAMH = KQ.MAMH
);

--Câu 18. Danh sách học viên và điểm thi môn “Co So Du Lieu” (chỉ lấy điểm cao nhất của các lần thi).
SELECT HV.MAHV,CONCAT(HO, ' ', TEN) AS HOTEN, KQ.DIEM
FROM HOCVIEN HV JOIN KETQUATHI KQ ON KQ.MAHV = HV.MAHV
WHERE KQ.MAMH = 'CSDL' AND KQ.DIEM = (
	SELECT MAX(DIEM)
	FROM KETQUATHI KQ1 
	WHERE KQ.MAHV = KQ1.MAHV AND KQ1.MAMH = KQ.MAMH
);
--Câu 19. Khoa nào (mã khoa, tên khoa) được thành lập sớm nhất.
SELECT TOP 1 WITH TIES MAKHOA, TENKHOA 
FROM KHOA
ORDER BY NGTLAP; 

--Câu 20. Có bao nhiêu giáo viên có học hàm là “GS” hoặc “PGS”.
SELECT COUNT(*) SOLUONG
FROM GIAOVIEN
WHERE HOCHAM IN ('GS', 'PGS');

--Câu 21. Thống kê có bao nhiêu giáo viên có học vị là “CN”, “KS”, “Ths”, “TS”, “PTS” trong mỗi khoa.
SELECT K.MAKHOA, K.TENKHOA,
       SUM(CASE WHEN GV.HOCVI = 'CN'  THEN 1 ELSE 0 END) AS SO_CN,
       SUM(CASE WHEN GV.HOCVI = 'KS'  THEN 1 ELSE 0 END) AS SO_KS,
       SUM(CASE WHEN GV.HOCVI = 'Ths' THEN 1 ELSE 0 END) AS SO_THS,
       SUM(CASE WHEN GV.HOCVI = 'TS'  THEN 1 ELSE 0 END) AS SO_TS,
       SUM(CASE WHEN GV.HOCVI = 'PTS' THEN 1 ELSE 0 END) AS SO_PTS
FROM GIAOVIEN GV JOIN KHOA K ON GV.MAKHOA = K.MAKHOA
GROUP BY K.MAKHOA, K.TENKHOA;


--Câu 22. Mỗi môn học thống kê số lượng học viên theo kết quả (đạt và không đạt).
SELECT MH.MAMH, MH.TENMH,
       SUM(CASE WHEN KQ.KQUA = 'Dat' THEN 1 ELSE 0 END) AS SO_DAT,
       SUM(CASE WHEN KQ.KQUA = 'Khong Dat' THEN 1 ELSE 0 END) AS SO_KHONG_DAT
FROM MONHOC MH JOIN KETQUATHI KQ ON MH.MAMH = KQ.MAMH
GROUP BY MH.MAMH, MH.TENMH;

--Câu 23. Tìm giáo viên (mã giáo viên, họ tên) là giáo viên chủ nhiệm của một lớp, đồng thời dạy cho lớp đó ít
--nhất một môn học.
SELECT DISTINCT GV.MAGV, GV.HOTEN
FROM GIAOVIEN GV
	JOIN LOP L ON L.MAGVCN = GV.MAGV
	JOIN GIANGDAY GD ON GD.MAGV = GV.MAGV AND GD.MALOP = L.MALOP;


--Câu 24. Tìm họ tên lớp trưởng của lớp có sỉ số cao nhất.
SELECT CONCAT(HO,' ' ,TEN) AS HOTEN
FROM HOCVIEN HV JOIN LOP L ON HV.MAHV = L.TRGLOP
WHERE L.SISO = (SELECT MAX(L2.SISO)
				FROM LOP L2
				);
--Câu 25. * Tìm họ tên những LOPTRG thi không đạt quá 3 môn (mỗi môn đều thi không đạt ở tất cả các lần
--thi).

--Câu 26. Tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9,10 nhiều nhất.
SELECT MAHV, CONCAT(HO, ' ', TEN) AS HOTEN
FROM HOCVIEN
WHERE MAHV IN (
	SELECT TOP 1 WITH TIES HV2.MAHV
	FROM HOCVIEN HV2 JOIN KETQUATHI KQ ON HV2.MAHV = KQ.MAHV
	WHERE DIEM BETWEEN 9 AND 10
	GROUP BY HV2.MAHV
	ORDER BY COUNT(DIEM) DESC
);
--Câu 27. Trong từng lớp, tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9,10 nhiều nhất.
SELECT HV1.MALOP, HV1.MAHV, CONCAT(HV1.HO, ' ', HV1.TEN) AS HOTEN
FROM HOCVIEN HV1
WHERE NOT EXISTS (
    SELECT *
    FROM HOCVIEN HV2
    WHERE HV2.MALOP = HV1.MALOP       
      AND (
          (SELECT COUNT(DIEM)
           FROM KETQUATHI KQ2
           WHERE KQ2.MAHV = HV2.MAHV
             AND KQ2.DIEM BETWEEN 9 AND 10)
          >
          (SELECT COUNT(DIEM)
           FROM KETQUATHI KQ1
           WHERE KQ1.MAHV = HV1.MAHV
             AND KQ1.DIEM BETWEEN 9 AND 10)
      )
)
ORDER BY HV1.MALOP, HV1.MAHV;

--Câu 28. Trong từng học kỳ của từng năm, mỗi giáo viên phân công dạy bao nhiêu môn học, bao nhiêu lớp.
SELECT GD.HOCKY, GD.NAM, GV.MAGV, GV.HOTEN,
    COUNT(DISTINCT GD.MAMH) AS SoMonHoc,
    COUNT(DISTINCT GD.MALOP) AS SoLop
FROM GIANGDAY GD JOIN GIAOVIEN GV ON GV.MAGV = GD.MAGV
GROUP BY GD.HOCKY, GD.NAM, GV.MAGV, GV.HOTEN
ORDER BY GD.HOCKY, GD.NAM, GV.MAGV;

--Câu 29. Trong từng học kỳ của từng năm, tìm giáo viên (mã giáo viên, họ tên) giảng dạy nhiều nhất.
SELECT GD1.HOCKY, GD1.NAM, GV.MAGV, GV.HOTEN
FROM GIANGDAY GD1
JOIN GIAOVIEN GV ON GV.MAGV = GD1.MAGV
GROUP BY GD1.HOCKY, GD1.NAM, GV.MAGV, GV.HOTEN
HAVING NOT EXISTS (
    SELECT 1
    FROM GIANGDAY GD2
    WHERE GD2.HOCKY = GD1.HOCKY AND GD2.NAM = GD1.NAM
    GROUP BY GD2.MAGV
    HAVING COUNT(GD2.MALOP) > COUNT(GD1.MALOP)
)
ORDER BY GD1.HOCKY, GD1.NAM;

--Câu 30. Tìm môn học (mã môn học, tên môn học) có nhiều học viên thi không đạt (ở lần thi thứ 1) nhất.
SELECT MH.MAMH, MH.TENMH
FROM MONHOC MH
JOIN KETQUATHI KQ ON KQ.MAMH = MH.MAMH
WHERE KQ.LANTHI = 1 AND KQ.KQUA = 'Khong Dat'
GROUP BY MH.MAMH, MH.TENMH
HAVING NOT EXISTS (
    SELECT 1
    FROM KETQUATHI KQ2
    WHERE KQ2.LANTHI = 1 AND KQ2.KQUA = 'Khong Dat'
    GROUP BY KQ2.MAMH
    HAVING COUNT(KQ2.MAHV) > COUNT(KQ.MAHV)
);

--Câu 31. Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi thứ 1).
SELECT HV.MAHV, (HO + ' ' + TEN) AS HOTEN
FROM HOCVIEN HV
WHERE NOT EXISTS (
    SELECT 1
    FROM KETQUATHI KQ
    WHERE KQ.MAHV = HV.MAHV
      AND KQ.LANTHI = 1
      AND KQ.KQUA = 'Khong Dat'
);

--Câu 32. * Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi sau cùng).
SELECT HV.MAHV, (HO + ' ' + TEN) AS HOTEN
FROM HOCVIEN HV
WHERE NOT EXISTS (
    SELECT 1
    FROM KETQUATHI KQ
    WHERE KQ.MAHV = HV.MAHV
      AND KQ.KQUA = 'Khong Dat'
      AND KQ.LANTHI = (
          SELECT MAX(KQ2.LANTHI)
          FROM KETQUATHI KQ2
          WHERE KQ2.MAHV = KQ.MAHV AND KQ2.MAMH = KQ.MAMH
      )
);

--Câu 33. * Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn đều đạt (chỉ xét lần thi thứ 1).
SELECT HV.MAHV, (HO + ' ' + TEN) AS HOTEN
FROM HOCVIEN HV
WHERE NOT EXISTS (
    SELECT *
    FROM MONHOC MH
    WHERE NOT EXISTS (
        SELECT 1
        FROM KETQUATHI KQ
        WHERE KQ.MAHV = HV.MAHV
          AND KQ.MAMH = MH.MAMH
          AND KQ.LANTHI = 1
          AND KQ.KQUA = 'Dat'
    )
);

--Câu 34. * Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn đều đạt (chỉ xét lần thi sau cùng).
SELECT HV.MAHV, (HV.HO + ' ' + HV.TEN) AS HOTEN
FROM HOCVIEN HV
WHERE NOT EXISTS (
    SELECT 1
    FROM MONHOC MH
    WHERE NOT EXISTS (
        SELECT 1
        FROM KETQUATHI KQ
        WHERE KQ.MAHV = HV.MAHV
          AND KQ.MAMH = MH.MAMH
          AND KQ.LANTHI = (
              SELECT MAX(KQ2.LANTHI)
              FROM KETQUATHI KQ2
              WHERE KQ2.MAHV = KQ.MAHV
                AND KQ2.MAMH = KQ.MAMH
          )
          AND KQ.KQUA = 'Dat'
    )
);


--Câu 35. ** Tìm học viên (mã học viên, họ tên) có điểm thi cao nhất trong từng môn (lấy điểm ở lần thi sau
--cùng).
SELECT KQ.MAMH, HV.MAHV, (HV.HO + ' ' + HV.TEN) AS HOTEN, KQ.DIEM
FROM KETQUATHI KQ
JOIN HOCVIEN HV ON HV.MAHV = KQ.MAHV
WHERE KQ.LANTHI = (
    SELECT MAX(KQ2.LANTHI)
    FROM KETQUATHI KQ2
    WHERE KQ2.MAHV = KQ.MAHV
      AND KQ2.MAMH = KQ.MAMH
)
AND NOT EXISTS (
    SELECT 1
    FROM KETQUATHI KQ3
    WHERE KQ3.MAMH = KQ.MAMH
      AND KQ3.LANTHI = (
          SELECT MAX(KQ4.LANTHI)
          FROM KETQUATHI KQ4
          WHERE KQ4.MAHV = KQ3.MAHV
            AND KQ4.MAMH = KQ3.MAMH
      )
      AND KQ3.DIEM > KQ.DIEM
)
ORDER BY KQ.MAMH, KQ.DIEM DESC;
