--Phần I: Ngôn ngữ định nghĩa dữ liệu (Data Definition Language):
--Câu 1. Thêm vào thuộc tính GHICHU có kiểu dữ liệu varchar(20) cho quan hệ SANPHAM.
alter table SANPHAM add GHICHU varchar (20);

--Câu 2. Thêm vào thuộc tính LOAIKH có kiểu dữ liệu là tinyint cho quan hệ KHACHHANG.
alter table KHACHHANG add LOAIKH tinyint;

--Câu 3. Sửa kiểu dữ liệu của thuộc tính GHICHU trong quan hệ SANPHAM thành varchar(100).
alter table SANPHAM alter column GHICHU varchar (100);

--Câu 4. Xóa thuộc tính GHICHU trong quan hệ SANPHAM.
alter table SANPHAM drop column GHICHU;

--Câu 5. Làm thế nào để thuộc tính LOAIKH trong quan hệ KHACHHANG có thể lưu các giá trị là: “Vang lai”,
--“Thuong xuyen”, “Vip”, …
alter table KHACHHANG alter column LOAIKH varchar(20);

--Câu 6. Đơn vị tính của sản phẩm chỉ có thể là (“cay”, “hop”, “cai”, “quyen”, “chuc”).
alter table SANPHAM add constraint ck_sanpham_dvt check (DVT in ('cay', 'hop', 'cai', 'quyen', 'chuc'));

--Câu 7. Giá bán của sản phẩm từ 500 đồng trở lên.
alter table SANPHAM add check (GIA >= 500);

--Câu 8. Số điện thoại của nhân viên phải bắt đầu bằng chữ số “0”.
alter table NHANVIEN add check (SODT like '0%');

--Câu 9. Mỗi lần mua hàng, khách hàng phải mua ít nhất 1 sản phẩm.
alter table CTHD add check (SL >=1);

--Câu 10. Ngày khách hàng đăng ký là khách hàng thành viên phải lớn hơn ngày sinh của người đó.
alter table KHACHHANG add check (NGDK > NGSINH);

--Phần II. Ngôn ngữ thao tác dữ liệu (Data Manipulation Language):
--Câu 1. Tạo quan hệ SANPHAM1 chứa toàn bộ dữ liệu của quan hệ SANPHAM. Tạo quan hệ KHACHHANG1 chứa
--toàn bộ dữ liệu của quan hệ KHACHHANG.
select* into SANPHAM1 from SANPHAM;
select* into KHACHHANG1 from KHACHHANG;

--Câu 2. Cập nhật giá tăng 5% đối với những sản phẩm do “Thai Lan” sản xuất (cho quan hệ SANPHAM1)
update SANPHAM1
set GIA = GIA * 1.05
where NUOCSX = 'Thai Lan';

select * from SANPHAM
where NUOCSX = 'Thai lan';
select * from SANPHAM1
where NUOCSX = 'Thai Lan';

--Câu 3. Cập nhật giá giảm 5% đối với những sản phẩm do “Trung Quoc” sản xuất có giá từ 10.000 trở xuống (cho
--quan hệ SANPHAM1).
update SANPHAM1
set GIA = GIA * 0.95
where NUOCSX = 'Trung Quoc' and gia <= 10000;

select * from SANPHAM
where NUOCSX = 'Trung Quoc';
select * from SANPHAM1
where NUOCSX = 'Trung Quoc';

--Câu 4. Cập nhật giá trị LOAIKH là “Vip” đối với những khách hàng đăng ký thành viên trước ngày 1/1/2007 có
--doanh số từ 10.000.000 trở lên hoặc khách hàng đăng ký thành viên từ 1/1/2007 trở về sau có doanh số
--từ 2.000.000 trở lên (cho quan hệ KHACHHANG1).
update KHACHHANG1
set LOAIKH = 'Vip'
where (NGDK < '1/1/2007' and DOANHSO >= 10000000) or (NGDK > '1/1/2007' and DOANHSO >= 2000000);

select * from KHACHHANG;
select * from KHACHHANG1;