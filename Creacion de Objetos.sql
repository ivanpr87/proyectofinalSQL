-- Creacion de BD 
-- Ivan Bastos



-- creo base de datos
CREATE DATABASE servicio_tecnico;


USE servicio_tecnico;

-- Tabla clientes
CREATE TABLE Customers (
    id_customer INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(200),
    phone VARCHAR(20),
    email VARCHAR(100)
);

-- Tabla equipos
CREATE TABLE Equipment (
    id_equipment INT AUTO_INCREMENT PRIMARY KEY,
    brand VARCHAR(100) NOT NULL,
    model VARCHAR(100),
    serial_number VARCHAR(50),
    id_customer INT,
    FOREIGN KEY (id_customer) REFERENCES Customers(id_customer)
);


-- Tabla componentes
CREATE TABLE Components (
    id_component INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(200),
    price DECIMAL(10, 2) NOT NULL
);

-- Tabla reparacion
CREATE TABLE Repairs (
    id_repair INT AUTO_INCREMENT PRIMARY KEY,
    start_date DATE NOT NULL,
    end_date DATE,
    description VARCHAR(200),
    total_cost DECIMAL(10, 2),
    id_equipment INT,
    FOREIGN KEY (id_equipment) REFERENCES Equipment(id_equipment)
);

-- Tabla componente_reparacion
CREATE TABLE Repair_Components (
    id_repair_component INT AUTO_INCREMENT PRIMARY KEY,
    id_repair INT,
    id_component INT,
    quantity INT,
    FOREIGN KEY (id_repair) REFERENCES Repairs(id_repair),
    FOREIGN KEY (id_component) REFERENCES Components(id_component)
);


-- tabla tecnicos
CREATE TABLE Technicians (
    id_technician INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100)
);


-- tabla asignamiento
CREATE TABLE Assignments (
    id_assignment INT AUTO_INCREMENT PRIMARY KEY,
    id_repair INT,
    id_technician INT,
    assignment_date DATE,
    FOREIGN KEY (id_repair) REFERENCES Repairs(id_repair),
    FOREIGN KEY (id_technician) REFERENCES Technicians(id_technician)
);

-- tabla estado de reparacion 
CREATE TABLE Repair_Status (
    id_status INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);


-- Tabla  del historial de la reparaciones
CREATE TABLE Status_History (
    id_status_history INT AUTO_INCREMENT PRIMARY KEY,
    id_repair INT,
    id_status INT,
    change_date DATE,
    FOREIGN KEY (id_repair) REFERENCES Repairs(id_repair),
    FOREIGN KEY (id_status) REFERENCES Repair_Status(id_status)
);

-- tabla facturas
CREATE TABLE Invoices (
    id_invoice INT AUTO_INCREMENT PRIMARY KEY,
    id_repair INT,
    emission_date DATE,
    total_amount DECIMAL(10, 2),
    FOREIGN KEY (id_repair) REFERENCES Repairs(id_repair)
);


CREATE TABLE Stock (
    id_stock INT AUTO_INCREMENT PRIMARY KEY,
    id_component INT,
    quantity INT,
    update_date DATE,
    FOREIGN KEY (id_component) REFERENCES Components(id_component)
);


-- Vistas



-- Esta vista muestra los detalles de cada reparación junto con la información del equipo y los componentes asociados.
CREATE VIEW View_RepairDetails AS
SELECT r.id_repair, r.start_date, r.end_date, r.description AS repair_description, r.total_cost,
       e.id_equipment, e.brand, e.model, e.serial_number,
       c.id_component, c.name AS component_name, rc.quantity AS component_quantity
FROM Repairs r
JOIN Equipment e ON r.id_equipment = e.id_equipment
LEFT JOIN Repair_Components rc ON r.id_repair = rc.id_repair
LEFT JOIN Components c ON rc.id_component = c.id_component;


-- Esta vista muestra los detalles de cada asignación de técnicos a reparaciones.

CREATE VIEW View_Assignments AS
SELECT a.id_assignment, a.id_repair, r.description AS repair_description,
       a.id_technician, t.name AS technician_name, a.assignment_date
FROM Assignments a
JOIN Repairs r ON a.id_repair = r.id_repair
JOIN Technicians t ON a.id_technician = t.id_technician;


-- Esta vista muestra los detalles de las facturas emitidas para cada reparación.

CREATE VIEW View_Invoices AS
SELECT i.id_invoice, i.id_repair, r.description AS repair_description, i.emission_date, i.total_amount
FROM Invoices i
JOIN Repairs r ON i.id_repair = r.id_repair;


-- Esta vista muestra los detalles de cada cliente y los equipos que tienen asociados.

CREATE VIEW View_CustomerEquipment AS
SELECT c.id_customer, c.name AS customer_name, c.address, c.phone, c.email,
       e.id_equipment, e.brand, e.model, e.serial_number
FROM Customers c
LEFT JOIN Equipment e ON c.id_customer = e.id_customer;

-- Funciones

-- Función para obtener la lista de reparaciones de un cliente específico:
DELIMITER //

CREATE FUNCTION GetRepairsByCustomer(customer_id INT)
RETURNS VARCHAR(1000)
DETERMINISTIC
BEGIN
    DECLARE repairs_list VARCHAR(1000);
    SELECT GROUP_CONCAT(CONCAT('ID: ', r.id_repair, ', Start Date: ', r.start_date, ', End Date: ', r.end_date, ', Description: ', r.description, ', Total Cost: ', r.total_cost) SEPARATOR '\n') INTO repairs_list
    FROM Repairs r
    INNER JOIN Equipment e ON r.id_equipment = e.id_equipment
    WHERE e.id_customer = customer_id;
    RETURN repairs_list;
END //

DELIMITER ;
-- Función para calcular el costo total de reparaciones para un cliente
DELIMITER //

CREATE FUNCTION GetTotalCostByCustomer(customer_id INT)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE total_cost DECIMAL(10, 2);
    SELECT SUM(r.total_cost) INTO total_cost
    FROM Repairs r
    INNER JOIN Equipment e ON r.id_equipment = e.id_equipment
    WHERE e.id_customer = customer_id;
    RETURN total_cost;
END //

DELIMITER ;

-- Función para obtener el número de reparaciones asignadas a un técnico:

DELIMITER //

CREATE FUNCTION GetAssignedRepairsCount(technician_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE repairs_count INT;
    SELECT COUNT(*) INTO repairs_count
    FROM Assignments a
    WHERE a.id_technician = technician_id;
    RETURN repairs_count;
END //

DELIMITER ;

-- Función para obtener el estado actual de una reparación.:

DELIMITER //

CREATE FUNCTION GetCurrentRepairStatus(repair_id INT)
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE current_status VARCHAR(100);
    SELECT s.name INTO current_status
    FROM Status_History sh
    INNER JOIN Repair_Status s ON sh.id_status = s.id_status
    WHERE sh.id_repair = repair_id
    ORDER BY sh.change_date DESC
    LIMIT 1;
    RETURN current_status;
END //

DELIMITER ;



-- Store procedure


-- Este procedimiento calculará el costo total de todas las reparaciones realizadas por un técnico específico
DELIMITER //
CREATE PROCEDURE CalculateTotalCostByTechnician(
    IN technician_id INT,
    OUT total_cost DECIMAL(10, 2)
)
BEGIN
    SELECT SUM(R.total_cost) INTO total_cost
    FROM Repairs R
    INNER JOIN Assignments A ON R.id_repair = A.id_repair
    WHERE A.id_technician = technician_id;
END;
//
DELIMITER ;

-- Este procedimiento obtendrá el historial de estados de una reparación específica.
DELIMITER //
CREATE PROCEDURE GetRepairStatusHistory(
    IN repair_id INT
)
BEGIN
    SELECT RH.change_date, RS.name
    FROM Status_History RH
    INNER JOIN Repair_Status RS ON RH.id_status = RS.id_status
    WHERE RH.id_repair = repair_id
    ORDER BY RH.change_date;
END;
//
DELIMITER ;

-- este SP calculará el costo total de todas las reparaciones realizadas para un cliente específico dentro de las semanas que especifiquemos y devolverá el resultado con su IVA.
DELIMITER //
CREATE PROCEDURE CalculateTotalCostInRangeWithIVA(
    IN customer_id INT,
    IN start_date DATE,
    IN end_date DATE,
    OUT total_cost_with_iva DECIMAL(10, 2)
)
BEGIN
    -- Calculamos el costo total de las reparaciones en el rango de fechas especificado
    SELECT COALESCE(SUM(R.total_cost), 0) INTO total_cost_with_iva
    FROM Repairs R
    INNER JOIN Equipment E ON R.id_equipment = E.id_equipment
    WHERE E.id_customer = customer_id
    AND R.start_date BETWEEN start_date AND end_date;
    
    -- Calculamos el IVA y lo sumamos al costo total
    SET total_cost_with_iva = total_cost_with_iva + (total_cost_with_iva * 0.21);
END;
//
DELIMITER ;
-- con este actualizamos el precio de los componentes.
DELIMITER //
CREATE PROCEDURE UpdateComponentPrice(
    IN component_id INT,
    IN new_price DECIMAL(10, 2)
)
BEGIN
    UPDATE Components
    SET price = new_price
    WHERE id_component = component_id;
END;
//
DELIMITER ;

-- este SP chequeara si el costo de reparacion supera cierto monto
DELIMITER //
CREATE PROCEDURE CheckCostThreshold(
    IN customer_id INT,
    OUT message VARCHAR(100)
)
BEGIN
    DECLARE total_cost DECIMAL(10, 2);
    DECLARE cost_threshold DECIMAL(10, 2);
    
    -- Calculamos el costo total de las reparaciones para el cliente
    SELECT COALESCE(SUM(R.total_cost), 0) INTO total_cost
    FROM Repairs R
    INNER JOIN Equipment E ON R.id_equipment = E.id_equipment
    WHERE E.id_customer = customer_id;
    
    -- Definimos el umbral de costo
    SET cost_threshold = 500.00;
    
    -- Comparación y mensaje de salida
    IF total_cost <= cost_threshold THEN
        SET message = CONCAT('El costo total de las reparaciones para el cliente está por debajo del umbral (', cost_threshold, ').');
    ELSE
        SET message = CONCAT('El costo total de las reparaciones para el cliente está por encima del umbral (', cost_threshold, ').');
    END IF;
END;
//
DELIMITER ;



-- Triggers 


-- Trigger después de actualizar un cliente:

DELIMITER //
CREATE TRIGGER TR_AfterUpdateCustomer
AFTER UPDATE ON Customers
FOR EACH ROW
BEGIN
    IF NOT (OLD.name <=> NEW.name AND OLD.address <=> NEW.address AND OLD.phone <=> NEW.phone AND OLD.email <=> NEW.email) THEN
        INSERT INTO Customer_Log (id_customer, change_date, action, modified_by)
        VALUES (NEW.id_customer, NOW(), CONCAT('Se modificó el cliente con ID: ', NEW.id_customer), @user);
    END IF;
END;
//
DELIMITER ;



-- Trigger después de insertar un nuevo cliente:
DELIMITER //
CREATE TRIGGER TR_AfterInsertCustomer
AFTER INSERT ON Customers
FOR EACH ROW
BEGIN
    INSERT INTO Customer_Log (id_customer, change_date, action, modified_by)
    VALUES (NEW.id_customer, NOW(), CONCAT('Se agregó un nuevo cliente con ID: ', NEW.id_customer), @user);
END;
//
DELIMITER ;



-- Trigger después de eliminar un cliente:

DELIMITER //
CREATE TRIGGER TR_AfterDeleteCustomer
AFTER DELETE ON Customers
FOR EACH ROW
BEGIN
    INSERT INTO Customer_Log (id_customer, change_date, action, modified_by)
    VALUES (OLD.id_customer, NOW(), CONCAT('Se eliminó el cliente con ID: ', OLD.id_customer), @user);
END;
//
DELIMITER ;


-- Trigger antes de insertar un nuevo componente:

DELIMITER //
CREATE TRIGGER TR_BeforeInsertComponent
BEFORE INSERT ON Components
FOR EACH ROW
BEGIN
    IF NEW.name IS NULL OR NEW.name='' OR NEW.description IS NULL OR NEW.description= '' OR NEW.price IS NULL THEN 
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se pueden insertar registros con campos nulos en la tabla Components';
    END IF;
END;
//
DELIMITER ;


-- Trigger antes de actualizar un componente:


DELIMITER //
CREATE TRIGGER TR_BeforeUpdateComponent
BEFORE UPDATE ON Components
FOR EACH ROW
BEGIN
    IF NEW.name IS NULL OR  NEW.description IS NULL OR NEW.price IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se pueden actualizar registros con campos nulos en la tabla Components';
    END IF;
END;
//
DELIMITER ;

-- Trigger antes de eliminar un componente:

DELIMITER //
CREATE TRIGGER TR_BeforeDeleteComponent
BEFORE DELETE ON Components
FOR EACH ROW
BEGIN
    DECLARE num_repairs INT;
    
    SELECT COUNT(*) INTO num_repairs
    FROM Repair_Components
    WHERE id_component = OLD.id_component;
    
    IF num_repairs > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se puede eliminar un componente con reparaciones asociadas';
    END IF;
END;
//
DELIMITER ;


-- Trigger guarda los cambios en la tabla componente ya se agregado o modficacion del mismo.
DELIMITER //
CREATE TRIGGER TR_BeforeModifyComponent
BEFORE INSERT ON Components
FOR EACH ROW
BEGIN
    DECLARE action_description VARCHAR(200);
    
    -- Si es una inserción, registra la acción como "Nuevo componente agregado"
    IF NEW.id_component IS NULL THEN
        SET action_description = CONCAT('Nuevo componente agregado: ', NEW.name);
    ELSE
        -- Si es una actualización, registra la acción como "Componente actualizado"
        SET action_description = CONCAT('Componente actualizado: ', NEW.name);
    END IF;
    
    -- Inserta el registro en la tabla de log
    INSERT INTO components_log (action_date, action_description, performed_by)
    VALUES (NOW(), action_description, @user);
END;
//
DELIMITER ;


-- Creado de tablas Logs


CREATE TABLE Customer_Log (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_customer INT,
    change_date TIMESTAMP,
    action VARCHAR(200),
    modified_by VARCHAR(100)
);


CREATE TABLE Components_Log (
	id_log INT AUTO_INCREMENT PRIMARY KEY,
    action_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action_description VARCHAR(200),
    performed_by VARCHAR(100)
);


-- TCL


-- Iniciar la transacción
START TRANSACTION;

-- Borrar los registros de la tabla "Components"
DELETE FROM Components WHERE id_component = 13;
DELETE FROM Components WHERE id_component = 16;
-- revertir la transacción
ROLLBACK;
-- Si todo está bien, confirmar la transacción
COMMIT;



-- Iniciar la transacción
START TRANSACTION;

-- Insertar nuevos registros en la tabla "Customers"
INSERT INTO Customers (name, address, phone, email)
VALUES 	('Nuevo Cliente 3', 'Dirección 3', '123-456-7893', 'nuevo3@gmail.com'),
		('Nuevo Cliente 4', 'Dirección 4', '123-456-7894', 'nuevo4@gmail.com'),
        ('Nuevo Cliente 5', 'Dirección 5', '123-456-7895', 'nuevo5@gmail.com'),
        ('Nuevo Cliente 6', 'Dirección 6', '123-456-7896', 'nuevo6@gmail.com');

-- Crear un punto de guardado (SAVEPOINT)
SAVEPOINT after_insert_1;

-- Insertar otro nuevo registro
INSERT INTO Customers (name, address, phone, email)
VALUES 	('Nuevo Cliente 7', 'Dirección 7', '987-654-3217', 'nuevo7@gamil.com'),
		('Nuevo Cliente 8', 'Dirección 8', '987-654-3218', 'nuevo8@gamil.com'),
        ('Nuevo Cliente 9', 'Dirección 9', '987-654-3219', 'nuevo9@gamil.com'),
        ('Nuevo Cliente 10', 'Dirección 10', '987-654-3220', 'nuevo10@gamil.com');

-- Eliminar el punto de guardado después de insertar los primeros 4 registros
-- RELEASE SAVEPOINT after_insert_1;

-- Si algo sale mal, revertir a after_insert_1
-- ROLLBACK TO after_insert_1;

-- Confirmar la transacción
COMMIT;


-- Implementacion de sentencias.


CREATE USER 'Pepito'@'localhost' IDENTIFIED BY '1234'; -- Creo el usuario Pepito y su correspondiente contraseña.

GRANT SELECT ON servicio_tecnico.* TO 'Pepito'@'localhost'; -- le di solamente permisos de lectura con "select" a Pepito

CREATE USER 'YO'@'localhost' IDENTIFIED BY '12345'; -- Creo el usuario YO y su correspondiente contraseña.

GRANT SELECT, INSERT, UPDATE ON servicio_tecnico.* TO 'YO'@'localhost'; -- Le di permisos de lectura con "Select", le di permisos de insercion con "Insert", le di permisos de modificacion con "Update" al usuario YO.






