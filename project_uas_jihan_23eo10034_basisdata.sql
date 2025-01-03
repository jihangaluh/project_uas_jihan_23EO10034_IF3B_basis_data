CREATE TABLE Users (
    IDUser SERIAL PRIMARY KEY,
    Username VARCHAR(50) UNIQUE NOT NULL,
    Password VARCHAR(255) NOT NULL,
    Role VARCHAR(20) NOT NULL CHECK (Role IN ('superuser', 'admin', 'app_user'))
);

CREATE TABLE Pesanan (
    NoPesanan VARCHAR(20) PRIMARY KEY,
    TotalBayar INT NOT NULL,
    WaktuBayar DATE NOT NULL,
    MetodePembayaran VARCHAR(20) NOT NULL
);

CREATE TABLE Pengiriman (
    IDPengiriman SERIAL PRIMARY KEY,
    NoPesanan VARCHAR(20) NOT NULL,
    NamaPenerima VARCHAR(50) NOT NULL,
    Alamat TEXT NOT NULL,
    Kota VARCHAR(50) NOT NULL,
    KodePos VARCHAR(10) NOT NULL,
    Telepon VARCHAR(15) NOT NULL,
    CONSTRAINT fk_no_pesanan FOREIGN KEY (NoPesanan) REFERENCES Pesanan(NoPesanan) ON DELETE CASCADE
);

CREATE TABLE RincianPesanan (
    IDRincian SERIAL PRIMARY KEY,
    NoPesanan VARCHAR(20) NOT NULL,
    Produk VARCHAR(100) NOT NULL,
    Kuantitas INT NOT NULL,
    Variasi VARCHAR(50),
    Harga INT NOT NULL,
    CONSTRAINT fk_no_pesanan FOREIGN KEY (NoPesanan) REFERENCES Pesanan(NoPesanan) ON DELETE CASCADE
);

CREATE TABLE Pembayaran (
    IDPembayaran SERIAL PRIMARY KEY,
    NoPesanan VARCHAR(20) NOT NULL,
    SubtotalProduk INT NOT NULL,
    SubtotalPengiriman INT NOT NULL,
    BiayaLayanan INT NOT NULL,
    Diskon INT NOT NULL,
    Total INT NOT NULL,
    CONSTRAINT fk_no_pesanan FOREIGN KEY (NoPesanan) REFERENCES Pesanan(NoPesanan) ON DELETE CASCADE
);

INSERT INTO Users (Username, Password, Role)
VALUES 
    ('admin_user', 'password123', 'admin'),
    ('basic_user', 'password123', 'app_user'),
    ('super_user', 'password123', 'superuser');

INSERT INTO Pesanan (NoPesanan, TotalBayar, WaktuBayar, MetodePembayaran) 
VALUES ('2412185GMU8VJE', 29726, '2024-12-20', 'COD');

INSERT INTO Pengiriman (NoPesanan, NamaPenerima, Alamat, Kota, KodePos, Telepon)
VALUES ('2412185GMU8VJE', 'tetehgaluh', 'Jln Lengkong RT 02 RW 05 dusun wanadadi jeruklegi kulon', 'Cilacap', '53252', '088226479384');

INSERT INTO RincianPesanan (NoPesanan, Produk, Kuantitas, Variasi, Harga)
VALUES ('2412185GMU8VJE', 'ID CARD PANITIA CARD CASE', 18, 'B4, biru', 27900);

INSERT INTO Pembayaran (NoPesanan, SubtotalProduk, SubtotalPengiriman, BiayaLayanan, Diskon, Total)
VALUES ('2412185GMU8VJE', 27900, 17000, 2105, -17000, 29726);

-- Membuat user superuser dan memberikan hak akses penuh
CREATE USER superuser WITH PASSWORD 'password';
GRANT ALL PRIVILEGES ON DATABASE project_uas_jihan_23eo10034 TO superuser;

-- Membuat user admin dan memberikan hak akses untuk INSERT dan UPDATE
CREATE USER admin WITH PASSWORD 'password';
GRANT INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO admin;

-- Membuat user biasa dan memberikan hak akses hanya untuk SELECT
CREATE USER app_user WITH PASSWORD 'password';
GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_user;

-- Atomicity
BEGIN;
UPDATE Pembayaran SET Total = Total + 100 WHERE NoPesanan = '2412185GMU8VJE';
-- Simulasi error
-- ROLLBACK; -- Jika terjadi error, transaksi dibatalkan
rollback;
-- Consistency
INSERT INTO Users (Username, Password, Role) VALUES ('invalid_user', 'password', 'unknown_role'); 
-- Harus gagal karena role tidak valid

-- Cek hak akses superuser(memiliki hak akses penuh ke seluruh database, yang berarti mereka dapat melakukan operasi apapun ditabel)
SET ROLE superuser;

-- Superuser bisa melakukan SELECT, INSERT, UPDATE, DELETE
SELECT * FROM Pesanan;
INSERT INTO Pesanan (NoPesanan, TotalBayar, WaktuBayar, MetodePembayaran)
VALUES ('2412185GMU8VJ2', 50000, '2024-12-21', 'Transfer');

UPDATE Pesanan SET TotalBayar = 60000 WHERE NoPesanan = '2412185GMU8VJ2';
DELETE FROM Pesanan WHERE NoPesanan = '2412185GMU8VJ2';

-- Superuser bisa mengelola user
CREATE USER new_user WITH PASSWORD 'newpassword';
GRANT SELECT ON ALL TABLES IN SCHEMA public TO new_user;

--Admin memiliki hak akses terbatas, hanya bisa melakukan INSERT dan UPDATE pada tabel-tabel, namun tidak dapat melakukan SELECT atau DELETE.
-- Cek hak akses admin
SET ROLE admin;

-- Admin bisa melakukan INSERT
INSERT INTO Pesanan (NoPesanan, TotalBayar, WaktuBayar, MetodePembayaran)
VALUES ('2412185GMU8VJ3', 75000, '2024-12-22', 'COD');

-- Admin bisa melakukan UPDATE
UPDATE Pesanan SET TotalBayar = 80000 WHERE NoPesanan = '2412185GMU8VJ3';

-- Admin tidak bisa melakukan SELECT
SELECT * FROM Pesanan; -- Akan gagal

-- Admin tidak bisa melakukan DELETE
DELETE FROM Pesanan WHERE NoPesanan = '2412185GMU8VJ3'; -- Akan gagal

--App_user hanya memiliki hak akses SELECT, yang berarti mereka hanya bisa membaca data dari tabel dan tidak bisa melakukan perubahan apa pun.
-- Cek hak akses app_user
SET ROLE app_user;

-- App_user bisa melakukan SELECT
SELECT * FROM RincianPesanan;  -- Harus berhasil

-- App_user tidak bisa melakukan INSERT
INSERT INTO Pesanan (NoPesanan, TotalBayar, WaktuBayar, MetodePembayaran)
VALUES ('2412185GMU8VJ4', 90000, '2024-12-23', 'Transfer'); -- Akan gagal

-- App_user tidak bisa melakukan UPDATE
UPDATE Pesanan SET TotalBayar = 95000 WHERE NoPesanan = '2412185GMU8VJ4'; -- Akan gagal

-- App_user tidak bisa melakukan DELETE
DELETE FROM Pesanan WHERE NoPesanan = '2412185GMU8VJ4'; -- Akan gagal

