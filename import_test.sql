-- Создание базы данных
CREATE DATABASE IF NOT EXISTS StarObservatory;
USE StarObservatory;

-- Создание таблицы Sector
CREATE TABLE IF NOT EXISTS Sector (
    sector_id INT AUTO_INCREMENT PRIMARY KEY,
    coordinates VARCHAR(255),
    light_intensity FLOAT,
    foreign_objects_count INT,
    star_objects_count INT,
    unknown_objects_count INT,
    defined_objects_count INT,
    notes TEXT
);

-- Создание таблицы Objects
CREATE TABLE IF NOT EXISTS Objects (
    object_id INT AUTO_INCREMENT PRIMARY KEY,
    object_type VARCHAR(255),
    accuracy FLOAT,
    quantity INT,
    observation_time TIME,
    observation_date DATE,
    notes TEXT
);

-- Создание таблицы NaturalObjects
CREATE TABLE IF NOT EXISTS NaturalObjects (
    natural_object_id INT AUTO_INCREMENT PRIMARY KEY,
    natural_object_type VARCHAR(255),
    galaxy VARCHAR(255),
    accuracy FLOAT,
    light_flow FLOAT,
    associated_objects VARCHAR(255),
    notes TEXT
);

-- Создание таблицы Position
CREATE TABLE IF NOT EXISTS `Position` (
    position_id INT AUTO_INCREMENT PRIMARY KEY,
    earth_position VARCHAR(255),
    sun_position VARCHAR(255),
    moon_position VARCHAR(255)
);

-- Создание таблицы Observation
CREATE TABLE IF NOT EXISTS Observation (
    observation_id INT AUTO_INCREMENT PRIMARY KEY,
    sector_id INT,
    object_id INT,
    natural_object_id INT,
    position_id INT,
    FOREIGN KEY (sector_id) REFERENCES Sector(sector_id),
    FOREIGN KEY (object_id) REFERENCES Objects(object_id),
    FOREIGN KEY (natural_object_id) REFERENCES NaturalObjects(natural_object_id),
    FOREIGN KEY (position_id) REFERENCES `Position`(position_id)
);

DELIMITER //

CREATE TRIGGER UpdateObjects
AFTER UPDATE ON Objects
FOR EACH ROW
BEGIN
    DECLARE column_exists INT DEFAULT 0;
    
    -- Проверка наличия столбца date_update
    SELECT COUNT(*) INTO column_exists
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'Objects' AND COLUMN_NAME = 'date_update';

    -- Добавление столбца, если он отсутствует
    IF column_exists = 0 THEN
        SET @alter_sql = 'ALTER TABLE Objects ADD COLUMN date_update TIMESTAMP';
        PREPARE stmt FROM @alter_sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;

    -- Обновление значения date_update текущей датой и временем
    SET NEW.date_update = NOW();
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE JoinTables(IN table1 VARCHAR(255), IN table2 VARCHAR(255))
BEGIN
    SET @sql = CONCAT('SELECT * FROM ', table1, ' t1 JOIN ', table2, ' t2 ON t1.id = t2.id');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DELIMITER ;