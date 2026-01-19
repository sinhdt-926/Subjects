--Phần III. Ngôn ngữ truy vấn dữ liệu.
--Câu 1. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất.
SELECT MASP, TENSP
FROM SANPHAM
WHERE NUOCSX = 'Trung Quoc';

--Câu 2. In ra danh sách các sản phẩm (MASP, TENSP) có đơn vị tính là “cay”, ”quyen”.
SELECT MASP, TENSP
FROM SANPHAM
WHERE DVT IN ('cay', 'quyen');

--Câu 3. In ra danh sách các sản phẩm (MASP,TENSP) có mã sản phẩm bắt đầu là “B” và kết thúc là “01”.
SELECT MASP, TENSP
FROM SANPHAM
WHERE MASP LIKE 'B%01';

--Câu 4. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quốc” sản xuất có giá từ 30.000 đến 40.000.
SELECT MASP, TENSP
FROM SANPHAM
WHERE NUOCSX = 'Trung Quoc' AND GIA BETWEEN 30000 AND 40000;

--Câu 5. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” hoặc “Thai Lan” sản xuất có giá từ 30.000
--đến 40.000.
SELECT MASP, TENSP
FROM SANPHAM
WHERE NUOCSX IN ('Trung Quoc', 'Thai lan') AND GIA BETWEEN 30000 AND 40000;

--Câu 6. In ra các số hóa đơn, trị giá hóa đơn bán ra trong ngày 1/1/2007 và ngày 2/1/2007.
SELECT SOHD, TRIGIA, NGHD
FROM HOADON
WHERE NGHD IN ('1/1/2007', '1/2/2007');

--Câu 7. In ra các số hóa đơn, trị giá hóa đơn trong tháng 1/2007, sắp xếp theo ngày (tăng dần) và trị giá của hóa
--đơn (giảm dần).
SELECT SOHD, TRIGIA, NGHD
FROM HOADON
WHERE MONTH (NGHD) = 1 AND YEAR (NGHD) = 2007
ORDER BY NGHD ASC, TRIGIA DESC;

--Câu 8. In ra danh sách các khách hàng (MAKH, HOTEN) đã mua hàng trong ngày 1/1/2007.
SELECT KH.MAKH, KH.HOTEN
FROM KHACHHANG KH INNER JOIN HOADON HD ON KH.MAKH = HD.MAKH
WHERE HD.NGHD = '1/1/2007';

--Câu 9. In ra số hóa đơn, trị giá các hóa đơn do nhân viên có tên “Nguyen Van B” lập trong ngày 28/10/2006.
SELECT HD.SOHD, HD.TRIGIA
FROM HOADON HD INNER JOIN NHANVIEN NV ON NV.MANV = HD.MANV
WHERE NV.HOTEN = 'Nguyen Van B' AND HD.NGHD = '10/28/2006';

--Câu 10. In ra danh sách các sản phẩm (MASP,TENSP) được khách hàng có tên “Nguyen Van A” mua trong tháng
--10/2006.
SELECT DISTINCT SP.MASP, SP.TENSP
FROM KHACHHANG KH 
INNER JOIN HOADON HD ON HD.MAKH = KH.MAKH
INNER JOIN CTHD CT ON HD.SOHD = CT.SOHD
INNER JOIN SANPHAM SP ON CT.MASP = SP.MASP
WHERE MONTH(HD.NGHD) = 10 AND YEAR(HD.NGHD) = 2006 AND KH.HOTEN = 'Nguyen Van A';

--Câu 11. Tìm các số hóa đơn đã mua sản phẩm có mã số “BB01” hoặc “BB02”.
SELECT DISTINCT SOHD
FROM CTHD
WHERE MASP IN ('BB01', 'BB02');

--Câu 12. Tìm các số hóa đơn đã mua sản phẩm có mã số “BB01” hoặc “BB02”, mỗi sản phẩm mua với số lượng từ 10
--đến 20.
SELECT DISTINCT SOHD
FROM CTHD 
WHERE MASP IN ('BB01', 'BB02') AND SL BETWEEN 10 AND 20;

--Câu 13. Tìm các số hóa đơn mua cùng lúc 2 sản phẩm có mã số “BB01” và “BB02”, mỗi sản phẩm mua với số lượng
--từ 10 đến 20.
SELECT SOHD
FROM CTHD 
WHERE MASP IN ('BB01', 'BB02') AND SL BETWEEN 10 AND 20
GROUP BY SOHD
HAVING COUNT(DISTINCT MASP) = 2;

--Câu 14. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất hoặc các sản phẩm được bán ra
--trong ngày 1/1/2007.
SELECT DISTINCT SP.MASP, SP.TENSP
FROM SANPHAM SP
LEFT JOIN CTHD CT ON CT.MASP = SP.MASP
LEFT JOIN HOADON HD ON HD.SOHD = CT.SOHD
WHERE NUOCSX = 'Trung Quoc' OR NGHD = '2007-01-01';

--Câu 15. In ra danh sách các sản phẩm (MASP,TENSP) không bán được.
SELECT SP.MASP, SP.TENSP
FROM SANPHAM SP
LEFT JOIN CTHD CT ON CT.MASP = SP.MASP
WHERE CT.SOHD IS NULL;

--Câu 16. In ra danh sách các sản phẩm (MASP,TENSP) không bán được trong năm 2006.
SELECT MASP, TENSP
FROM SANPHAM SP
WHERE NOT EXISTS (
	SELECT *
	FROM CTHD CT
	WHERE CT.MASP = SP.MASP
);

--Câu 17. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất không bán được trong năm 2006.
SELECT MASP, TENSP
FROM SANPHAM
WHERE NUOCSX = 'Trung Quoc' AND MASP NOT IN (
	SELECT DISTINCT CT.MASP
	FROM CTHD CT
	INNER JOIN HOADON HD ON HD.SOHD = CT.SOHD
	INNER JOIN SANPHAM SP ON SP.MASP = CT.MASP
	WHERE YEAR(HD.NGHD) = 2006
);

--Câu 18. Thống kê số lượng hóa đơn do mỗi nhân viên lập trong năm 2006, hiển thị (MANV, HOTEN, SoLuongHD).
SELECT NV.MANV, NV.HOTEN, COUNT (HD.SOHD) AS SoLuongHD
FROM NHANVIEN NV
INNER JOIN HOADON HD ON HD.MANV = NV.MANV AND YEAR(HD.NGHD) = 2006
GROUP BY NV.MANV, NV.HOTEN;

--Câu 19. In ra danh sách nhân viên và tổng số khách hàng khác nhau mà họ đã bán hàng cho trong năm 2006.
SELECT NV.MANV, NV.HOTEN, COUNT (DISTINCT HD.MAKH) AS TongSoKhachHang
FROM NHANVIEN NV
INNER JOIN HOADON HD ON HD.MANV = NV.MANV AND YEAR(HD.NGHD) = 2006
GROUP BY NV.MANV, NV.HOTEN;

--Câu 20.Liệt kê sản phẩm (MASP, TENSP) có tổng số lượng bán ra nhiều nhất trong năm 2006.

SELECT TOP 1 WITH TIES SP.MASP, SP.TENSP, SUM(CT.SL) AS TongSoLuong
FROM SANPHAM SP
INNER JOIN CTHD CT ON SP.MASP = CT.MASP
INNER JOIN HOADON HD ON HD.SOHD = CT.SOHD
WHERE YEAR(HD.NGHD) = 2006
GROUP BY SP.MASP, SP.TENSP
ORDER BY SUM(CT.SL) DESC;

--Câu 21. Tìm nhân viên có doanh số bán hàng cao nhất trong tháng 10/2006.
SELECT TOP 1 WITH TIES NV.HOTEN, NV.MANV, SUM (HD.TRIGIA) AS DoanhSo
FROM NHANVIEN NV
INNER JOIN HOADON HD ON HD.MANV = NV.MANV
WHERE YEAR(HD.NGHD) = 2006 AND MONTH(HD.NGHD) = 10
GROUP BY NV.HOTEN, NV.MANV
ORDER BY SUM(HD.TRIGIA) DESC;

--Câu 22. In ra danh sách sản phẩm không bán được trong năm 2007 nhưng có bán trong năm 2006.
SELECT MASP, TENSP
FROM SANPHAM
WHERE MASP IN (
	SELECT DISTINCT CT.MASP
	FROM CTHD CT
	INNER JOIN HOADON HD ON HD.SOHD = CT.SOHD
	WHERE YEAR(HD.NGHD) = 2006

	EXCEPT

	SELECT DISTINCT CT.MASP
	FROM CTHD CT
	INNER JOIN HOADON HD ON HD.SOHD = CT.SOHD
	WHERE YEAR(HD.NGHD) = 2007
);

--Câu 23. Liệt kê danh sách sản phẩm (MASP, TENSP) được bán bởi ít nhất 2 nhân viên khác nhau.
SELECT SP.MASP, SP.TENSP
FROM SANPHAM SP
INNER JOIN CTHD CT ON CT.MASP = SP.MASP
INNER JOIN HOADON HD ON HD.SOHD = CT.SOHD
GROUP BY SP.MASP, SP.TENSP
HAVING COUNT(DISTINCT HD.MANV) >= 2;

--Câu 24. In ra danh sách khách hàng không mua sản phẩm nào do Thái Lan sản xuất.
SELECT DISTINCT HOTEN
FROM KHACHHANG 
WHERE MAKH NOT IN (
	SELECT KH.MAKH
	FROM KHACHHANG KH
	INNER JOIN HOADON HD ON HD.MAKH = KH.MAKH
	INNER JOIN CTHD CT ON CT.SOHD = HD.SOHD
	INNER JOIN SANPHAM SP ON SP.MASP = CT.MASP
	WHERE SP.NUOCSX = 'Thai Lan'
);

--Câu 25. Tìm hóa đơn có trị giá lớn nhất trong năm 2006, in ra (SOHD, NGHD, TRIGIA)
SELECT TOP 1 WITH TIES SOHD, NGHD, TRIGIA
FROM HOADON
WHERE YEAR(NGHD) = 2006
ORDER BY TRIGIA DESC;