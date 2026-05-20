DROP DATABASE IF EXISTS session12bt;
CREATE DATABASE session12bt;
USE session12bt;

-- Khách lưu trú
CREATE TABLE guests(
    guest_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(10) NOT NULL,
    points INT CHECK(points >= 0) DEFAULT 0
);

-- Hồ sơ khách
CREATE TABLE guest_Profiles(
    profile_id INT PRIMARY KEY AUTO_INCREMENT,
    guest_id INT,
    address VARCHAR(255) NOT NULL,
    birthday DATE,
    national_id VARCHAR(4) NOT NULL UNIQUE,
    FOREIGN KEY (guest_id) REFERENCES guests(guest_id)
);

-- Phòng
CREATE TABLE rooms(
    room_id INT PRIMARY KEY AUTO_INCREMENT,
    room_name VARCHAR(255) NOT NULL,
    room_type ENUM('Standard', 'Deluxe', 'Suite'),
    price_per_night INT CHECK(price_per_night > 0),
    room_status ENUM('Available', 'Occupied', 'Maintenance')
);

-- Đặt phòng
CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    guest_id INT,
    check_in_date DATETIME,
    check_out_date DATETIME,
    total_charge INT CHECK (total_charge > 0),
    booking_status ENUM('Pending', 'Completed', 'Cancelled'),
    FOREIGN KEY (guest_id) REFERENCES guests(guest_id)
);

-- Nhật ký phòng
CREATE TABLE Room_Log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    room_id INT,
    action_type ENUM('Check-in', 'Check-out', 'Maintenance', 'Cancelled'),
    change_note VARCHAR(255) NOT NULL,
    logged_at DATE,
    FOREIGN KEY (room_id) REFERENCES rooms(room_id)
);

INSERT INTO guests (guest_id, full_name, email, phone, points) VALUES
(1, 'Nguyen Van A', 'anv@gmail.com', '0901234567', 150),
(2, 'Tran Thi B', 'btt@gmail.com', '0912345678', 500),
(3, 'Le Van C', 'cle@yahoo.com', '0922334455', 0),
(4, 'Pham Minh D', 'dpham@hotmail.com', '0933445566', 1000),
(5, 'Hoang Anh E', 'ehoang@gmail.com', '0944556677', 20);

INSERT INTO guest_Profiles (profile_id, guest_id, address, birthday, national_id) VALUES
(101, 1, '123 Le Loi, Q1, HCM', '1990-05-15', '1234'),
(102, 2, '456 Nguyen Hue, Q1, HCM', '1985-10-20', '2345'),
(103, 3, '789 Phan Chu Trinh, Da Nang', '1995-12-01', '3456'),
(104, 4, '101 Hoang Hoa Tham, Ha Noi', '1988-03-25', '4567'),
(105, 5, '202 Tran Hung Dao, Can Tho', '2000-07-10', '5678');

INSERT INTO rooms (room_id, room_name, room_type, price_per_night, room_status) VALUES
(1, 'Room 101', 'Standard', 100000, 'Available'),
(2, 'Room 202', 'Deluxe', 500000, 'Occupied'),
(3, 'Room 303', 'Suite', 5000000, 'Available'),
(4, 'Room 104', 'Standard', 1200000, 'Occupied'),
(5, 'Room 205', 'Deluxe', 2000000, 'Maintenance');

INSERT INTO bookings (booking_id, guest_id, check_in_date, check_out_date, total_charge, booking_status) VALUES
(1001, 1, '2023-11-15 10:30:00', '2023-11-18 12:00:00', 35500000, 'Completed'),
(1002, 2, '2023-12-01 14:20:00', '2023-12-04 12:00:00', 28000000, 'Completed'),
(1003, 1, '2024-01-10 09:15:00', '2024-01-11 12:00:00', 500000, 'Pending'),
(1004, 3, '2023-05-20 16:45:00', '2023-05-22 12:00:00', 7000000, 'Cancelled'),
(1005, 4, '2024-01-18 11:00:00', '2024-01-20 12:00:00', 1200000, 'Completed');

INSERT INTO Room_Log (log_id, room_id, action_type, change_note, logged_at) VALUES
(1, 1, 'Check-in', 'Guest checked in', '2023-10-01'),
(2, 1, 'Check-out', 'Guest checked out', '2023-11-15'),
(3, 4, 'Maintenance', 'Room reported as damaged', '2023-11-20'),
(4, 2, 'Check-in', 'New guest arrival', '2023-11-25'),
(5, 3, 'Maintenance', 'Schedule maintenance', '2023-12-01');

-- UPDATE
UPDATE guests SET points = points + 200
WHERE email LIKE '%@gmail.com';
SELECT guest_id, full_name, email, phone, points FROM guests;
-- DELETE 
DELETE FROM Room_Log WHERE logged_at < '2023-11-10';
SELECT log_id, room_id, action_type, change_note, logged_at FROM Room_Log;

-- Phần 2
-- Câu 1
SELECT room_name, price_per_night, room_status FROM rooms
WHERE price_per_night > 1000000
OR room_status = 'Maintenance' 
OR room_type ='Suite';

-- Câu 2
SELECT full_name, email FROM guests
WHERE email LIKE '%@gmail.com' 
AND points BETWEEN 50 AND 300;

-- Câu 3
SELECT booking_id, guest_id, check_in_date, check_out_date, total_charge, booking_status FROM bookings
ORDER BY total_charge DESC
LIMIT 3 OFFSET 1;

-- Phần 3
-- Câu 1
SELECT g.full_name, 
		gp.national_id,
        b.booking_id, 
        b.check_in_date, 
        b.total_charge 
FROM bookings b
JOIN guests g ON g.guest_id = b.guest_id
JOIN guest_Profiles gp ON gp.guest_id = b.guest_id;

-- Câu 2
SELECT g.full_name, 
    SUM(b.total_charge) AS sum_charge
FROM bookings b
JOIN guests g ON g.guest_id = b.guest_id
GROUP BY g.guest_id
HAVING sum_charge > 20000000;

-- Câu 3
SELECT r.room_id, r.room_name, r.room_type, r.price_per_night, r.room_status
FROM rooms r
WHERE r.room_id IN (
    SELECT rf.room_id 
    FROM Room_Log rf
    WHERE rf.action_type IN ('Check-in', 'Check-out')
)
ORDER BY r.price_per_night DESC
LIMIT 1;

-- Phần 4
-- Câu 1
CREATE INDEX idx_booking_status_date ON Bookings(booking_status, check_in_date); -- create_at = check_in_date

-- Câu 2
CREATE OR REPLACE VIEW vw_guest_booking_stats AS
SELECT g.full_name,
    count(b.booking_id) AS total_book,
    sum(b.total_charge) AS sum_book
FROM guests g
LEFT JOIN Bookings b ON g.guest_id = b.guest_id
WHERE booking_status NOT LIKE 'Cancelled'
GROUP BY g.guest_id;

SELECT full_name, total_book, sum_book FROM vw_guest_booking_stats;

-- Phần 5
-- Câu 1
-- Lấy thông tin tất cả các phòng
DELIMITER //
CREATE PROCEDURE get_all_rooms()
BEGIN
    SELECT room_id, room_name, room_type, price_per_night, room_status
    FROM rooms;
END //
DELIMITER ;

CALL get_all_rooms();

-- Lấy thông tin phòng theo mã phòng
DELIMITER //
CREATE PROCEDURE get_rooms_byId(IN p_room_id INT)
BEGIN
    SELECT room_id, room_name, room_type, price_per_night, room_status 
    FROM rooms 
    WHERE room_id = p_room_id;
END //
DELIMITER ;

CALL get_rooms_byId(1);

-- Thêm mới một phòng
DELIMITER //
CREATE PROCEDURE add_rooms(
    IN p_room_name VARCHAR(50),
    IN p_room_type VARCHAR(50),
    IN p_price_per_night DECIMAL(10,2),
    IN p_room_status VARCHAR(50)
)
BEGIN
    INSERT INTO rooms (room_name, room_type, price_per_night, room_status) 
    VALUES (p_room_name, p_room_type, p_price_per_night, p_room_status);
END //
DELIMITER ;

CALL add_rooms('Room 200', 'Suite', 39, 'Available');
SELECT room_name, room_type, price_per_night, room_status FROM rooms;

-- Cập nhật thông tin một phòng
DELIMITER //
CREATE PROCEDURE update_rooms(
    IN p_room_id INT,
    IN p_room_name VARCHAR(50),
    IN p_room_type VARCHAR(50),
    IN p_price_per_night DECIMAL(10,2),
    IN p_room_status VARCHAR(50)
)
BEGIN
    UPDATE rooms 
    SET room_name = p_room_name,
        room_type = p_room_type,
        price_per_night = p_price_per_night,
        room_status = p_room_status
    WHERE room_id = p_room_id;
END //
DELIMITER ;

CALL update_rooms(1, 'Room 101', 'Suite', 200, 'Occupied'); -- Update room 101
SELECT room_name, room_type, price_per_night, room_status FROM rooms;

-- Xóa một phòng, trước khi xóa cần kiểm tra phòng có xóa được không, nếu không xóa được thì không thực hiện xóa
-- DROP PROCEDURE IF EXISTS delete_rooms;
-- DELIMITER //
-- CREATE PROCEDURE delete_rooms(IN p_room_id INT)
-- BEGIN
--     IF EXISTS (SELECT 1 FROM Room_Log WHERE room_id = p_room_id) THEN
--         SELECT 'Không thể xóa phòng' AS message;
--     ELSE
--         DELETE FROM rooms WHERE room_id = p_room_id;
--         SELECT 'Xóa phòng thành công' AS message;
--     END IF;
-- END //
-- DELIMITER ;
-- CALL delete_rooms(1);
-- CALL delete_rooms(9);
-- SELECT room_name, room_type, price_per_night, room_status FROM rooms;

-- Câu 2
DROP PROCEDURE IF EXISTS sp_get_room_status;
DELIMITER //
CREATE PROCEDURE sp_get_room_status(IN p_room_id INT)
BEGIN
    DECLARE v_status VARCHAR(50);
    
    SELECT room_status INTO v_status 
    FROM rooms 
    WHERE room_id = p_room_id;

    IF v_status = 'Available' THEN 
        SELECT 'Phòng trống' AS message;
        
    ELSEIF v_status = 'Occupied' THEN 
        SELECT 'Đang có khách' AS message;
        
    ELSEIF v_status = 'Maintenance' THEN 
        SELECT 'Bảo trì' AS message;
        
    ELSE 
        SELECT 'Phòng không tồn tại' AS message;
    END IF;
END //
DELIMITER ;

CALL sp_get_room_status(101); -- Phòng trống
CALL sp_get_room_status(102); -- Đang có khách
CALL sp_get_room_status(103); -- Bảo trì

-- Câu 3
-- DROP PROCEDURE IF EXISTS sp_cancel_booking; 
-- DELIMITER //
-- CREATE PROCEDURE sp_cancel_booking(IN p_booking_id INT)
-- BEGIN
--     DECLARE v_room_id INT;
--     
--     SELECT room_id INTO v_room_id 
--     FROM Bookings 
--     WHERE booking_id = p_booking_id;

--     IF v_room_id IS NOT NULL THEN
--         
--         UPDATE Bookings 
--         SET booking_status = 'Cancelled' 
--         WHERE booking_id = p_booking_id;

--         UPDATE rooms 
--         SET room_status = 'Available' 
--         WHERE room_id = v_room_id;

--         INSERT INTO Room_Log (room_id, action_type, log_date) 
--         VALUES (v_room_id, 'Cancelled', NOW());

--         SELECT 'Hủy đặt phòng và cập nhật thành công' AS message;
--         
--     ELSE
--         SELECT 'Mã phòng không tồn tại' AS message;
--     END IF;
-- END //
-- DELIMITER ;
