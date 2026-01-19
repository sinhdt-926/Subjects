--Phần III. Ngôn ngữ truy vấn dữ liệu.
--Câu 26. Tìm số hóa đơn đã mua tất cả các sản phẩm do Singapore sản xuất.
SELECT CT.SOHD
FROM CTHD CT 
	JOIN SANPHAM SP ON CT.MASP = SP.MASP
WHERE SP.NUOCSX = 'Singapore'
GROUP BY CT.SOHD
HAVING COUNT(DISTINCT SP.MASP) = (SELECT COUNT(*)
									FROM SANPHAM
									WHERE NUOCSX ='Singapore');
--Câu 27. Tìm số hóa đơn trong năm 2006 đã mua tất cả các sản phẩm do Singapore sản xuất.
SELECT HD.SOHD
FROM HOADON HD
	JOIN CTHD CT ON HD.SOHD = CT.SOHD
	JOIN SANPHAM SP ON SP.MASP = CT.MASP
WHERE SP.NUOCSX = 'Singapore' AND YEAR (HD.NGHD) = 2006
GROUP BY HD.SOHD
HAVING COUNT(DISTINCT SP.MASP) = (SELECT COUNT(*)
									FROM SANPHAM
									WHERE NUOCSX ='Singapore');
--Câu 28. Có bao nhiêu hóa đơn không phải của khách hàng đăng ký thành viên mua?
SELECT COUNT(DISTINCT SOHD) 'SoHDKhongPhaiThanhVien'
FROM HOADON
WHERE MAKH IS NULL;
--Câu 29. Có bao nhiêu sản phẩm khác nhau được bán ra trong năm 2006.
SELECT COUNT(DISTINCT CT.MASP) 'SoSPKhacNhauBanTrongNam2006'
FROM CTHD CT JOIN HOADON HD ON HD.SOHD = CT.SOHD
WHERE YEAR(HD.NGHD) = 2006;
--Câu 30. Cho biết trị giá hóa đơn cao nhất, thấp nhất là bao nhiêu ?
SELECT MAX(TRIGIA) 'HOADON_CAONHAT', MIN(TRIGIA) 'HOADON_THAPNHAT'
FROM HOADON;
--Câu 31. Trị giá trung bình của tất cả các hóa đơn được bán ra trong năm 2006 là bao nhiêu?
SELECT AVG(TRIGIA) 'TRIGIATB_HOADON_2006'
FROM HOADON
WHERE YEAR(NGHD) = 2006;
--Câu 32. Tính doanh thu bán hàng trong năm 2006.
SELECT SUM(TRIGIA) 'DOANHTHU_2006'
FROM HOADON
WHERE YEAR(NGHD) = 2006;
--Câu 33. Tìm số hóa đơn có trị giá cao nhất trong năm 2006.
SELECT TOP 1 WITH TIES SOHD
FROM HOADON
WHERE YEAR(NGHD) = 2006
ORDER BY TRIGIA DESC;
--Câu 34. Tìm họ tên khách hàng đã mua hóa đơn có trị giá cao nhất trong năm 2006.
SELECT TOP 1 WITH TIES HOTEN
FROM KHACHHANG KH JOIN HOADON HD ON KH.MAKH = HD.MAKH
WHERE YEAR(NGHD) = 2006
ORDER BY HD.TRIGIA DESC;
--Câu 35. In ra danh sách 3 khách hàng đầu tiên (MAKH, HOTEN) sắp xếp theo doanh số giảm dần.
SELECT TOP 3 KH.MAKH, KH.HOTEN, SUM(TRIGIA) 'DOANHSO'
FROM KHACHHANG KH JOIN HOADON HD ON HD.MAKH = KH.MAKH
GROUP BY KH.MAKH, KH.HOTEN
ORDER BY DOANHSO DESC;
--Câu 36. In ra danh sách các sản phẩm (MASP, TENSP) có giá bán bằng 1 trong 3 mức giá cao nhất.
SELECT MASP, TENSP
FROM SANPHAM 
WHERE GIA IN (
				SELECT DISTINCT TOP 3 GIA
				FROM SANPHAM
				ORDER BY GIA DESC);
--Câu 37. In ra danh sách các sản phẩm (MASP, TENSP) do “Thai Lan” sản xuất có giá bằng 1 trong 3 mức giá cao
--nhất (của tất cả các sản phẩm).
SELECT MASP, TENSP, GIA
FROM SANPHAM 
WHERE NUOCSX = 'Thai Lan' AND GIA IN ( SELECT DISTINCT TOP 3 GIA
										FROM SANPHAM
										ORDER BY GIA DESC);
--Câu 38. In ra danh sách các sản phẩm (MASP, TENSP) do “Trung Quoc” sản xuất có giá bằng 1 trong 3 mức giá
--cao nhất (của sản phẩm do “Trung Quoc” sản xuất).
SELECT MASP, TENSP, GIA
FROM SANPHAM 
WHERE NUOCSX = 'Trung Quoc' AND GIA IN ( SELECT DISTINCT TOP 3 GIA
										FROM SANPHAM
										WHERE NUOCSX = 'Trung Quoc'
										ORDER BY GIA DESC);
--Câu 39. In ra danh sách khách hàng nằm trong 3 hạng cao nhất (xếp hạng theo doanh số).
SELECT TOP 3 WITH TIES KH.MAKH, KH.HOTEN, SUM(HD.TRIGIA) AS DOANHSO
FROM KHACHHANG KH 
JOIN HOADON HD ON HD.MAKH = KH.MAKH
GROUP BY KH.MAKH, KH.HOTEN
ORDER BY DOANHSO DESC;

--Câu 40. Tính tổng số sản phẩm do “Trung Quoc” sản xuất.
SELECT COUNT(MASP) 'TongSoSanPhamDoTrungQuocSanXuat'
FROM SANPHAM
WHERE NUOCSX = 'Trung Quoc';
--Câu 41. Tính tổng số sản phẩm của từng nước sản xuất.
SELECT NUOCSX, COUNT(MASP) 'TongSoSanPham'
FROM SANPHAM
GROUP BY NUOCSX;
--Câu 42. Với từng nước sản xuất, tìm giá bán cao nhất, thấp nhất, trung bình của các sản phẩm.
SELECT NUOCSX, MAX(GIA) 'GIACAONHAT', MIN(GIA) 'GIATHAPNHAT', AVG(GIA) 'TRUNGBINH'
FROM SANPHAM
GROUP BY NUOCSX;
--Câu 43. Tính doanh thu bán hàng mỗi ngày.
SELECT NGHD, SUM(TRIGIA) 'DOANHTHU'
FROM HOADON 
GROUP BY NGHD;
--Câu 44. Tính tổng số lượng của từng sản phẩm bán ra trong tháng 10/2006.
SELECT CT.MASP, SP.TENSP, SUM(CT.SL) 'TONGSOLUONGTUNGSP'
FROM CTHD CT JOIN HOADON HD ON HD.SOHD = CT.SOHD
			JOIN SANPHAM SP ON SP.MASP = CT.MASP
WHERE YEAR(NGHD) = 2006 AND MONTH(NGHD) = 10
GROUP BY CT.MASP, SP.TENSP;
--Câu 45. Tính doanh thu bán hàng của từng tháng trong năm 2006.
SELECT MONTH(NGHD) 'THANG', SUM(TRIGIA) 'DOANHTHUTHEOTHANG'
FROM HOADON 
WHERE YEAR(NGHD) = 2006
GROUP BY MONTH(NGHD);
--Câu 46. Tìm hóa đơn có mua ít nhất 4 sản phẩm khác nhau.
SELECT SOHD
FROM CTHD
GROUP BY SOHD
HAVING COUNT(DISTINCT MASP) >= 4;
--Câu 47. Tìm hóa đơn có mua 3 sản phẩm do “Viet Nam” sản xuất (3 sản phẩm khác nhau).
SELECT SOHD
FROM CTHD CT JOIN SANPHAM SP ON SP.MASP = CT.MASP
WHERE SP.NUOCSX = 'Viet Nam'
GROUP BY SOHD
HAVING COUNT(DISTINCT CT.MASP) = 3;
--Câu 48. Tìm khách hàng (MAKH, HOTEN) có số lần mua hàng nhiều nhất.
SELECT TOP 1 WITH TIES KH.MAKH, KH.HOTEN
FROM KHACHHANG KH JOIN HOADON HD ON HD.MAKH = KH.MAKH
GROUP BY KH.MAKH, KH.HOTEN
ORDER BY COUNT(SOHD) DESC;
--Câu 49. Tháng mấy trong năm 2006, doanh số bán hàng cao nhất?
SELECT TOP 1 WITH TIES MONTH(NGHD) 'THANG', SUM(TRIGIA) 'DOANHSO'
FROM HOADON 
WHERE YEAR(NGHD) = 2006
GROUP BY MONTH(NGHD)
ORDER BY DOANHSO DESC;
--Câu 50. Tìm sản phẩm (MASP, TENSP) có tổng số lượng bán ra thấp nhất trong năm 2006.
SELECT TOP 1 WITH TIES SP.MASP, SP.TENSP, SUM(CT.SL) 'TONGSL'
FROM SANPHAM SP JOIN CTHD CT ON CT.MASP = SP.MASP
	JOIN HOADON HD ON HD.SOHD = CT.SOHD
WHERE YEAR(NGHD) = 2006
GROUP BY SP.MASP, SP.TENSP
ORDER BY TONGSL;

--Câu 51. Mỗi nước sản xuất, tìm sản phẩm (MASP,TENSP) có giá bán cao nhất.
SELECT SP1.MASP, SP1.TENSP, SP1.NUOCSX, SP1.GIA
FROM SANPHAM SP1
WHERE NOT EXISTS (
    SELECT *
    FROM SANPHAM SP2
    WHERE SP2.NUOCSX = SP1.NUOCSX
      AND SP2.GIA > SP1.GIA
);

--Câu 52. Tìm nước sản xuất sản xuất ít nhất 3 sản phẩm có giá bán khác nhau.
SELECT NUOCSX
FROM SANPHAM
GROUP BY NUOCSX
HAVING COUNT(DISTINCT GIA) >= 3;

--Câu 53. Trong 10 khách hàng có doanh số cao nhất, tìm khách hàng có số lần mua hàng nhiều nhất.
SELECT TOP 1 KH.MAKH, KH.HOTEN, COUNT(HD.SOHD) AS SOLANMUA
FROM KHACHHANG KH 
JOIN HOADON HD ON KH.MAKH = HD.MAKH
WHERE KH.MAKH IN (
    SELECT TOP 10 KH.MAKH
    FROM KHACHHANG KH 
    JOIN HOADON HD ON KH.MAKH = HD.MAKH
    GROUP BY KH.MAKH
    ORDER BY SUM(HD.TRIGIA) DESC
)
GROUP BY KH.MAKH, KH.HOTEN
ORDER BY COUNT(HD.SOHD) DESC;