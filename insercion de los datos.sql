-- insert datos 
-- Ivan Bastos

USE servicio_tecnico;
-- inserto clientes
INSERT INTO Customers (name, address, phone, email)
VALUES
    ('John Doe', '123 Main St, Anytown', '555-123-4567', 'john.doe@example.com'),
    ('Jane Smith', '456 Elm Ave, Springfield', '555-987-6543', 'jane.smith@example.com'),
    ('Denys Eccott','43235 Riverside Point','167-261-5681','deccott0@sohu.com'),
	('Liane Tincknell','0614 Lillian Park','545-160-2837','ltincknell1@topsy.com'),
	('Cedric Brocks','74 Troy Way','458-863-3025','cbrocks2@macromedia.com'),
	('Erina Pohl','0 Pond Pass','446-642-0142','epohl3@cbc.ca'),
	('Silvain Dick','685 Coolidge Pass','322-313-0654','sdick4@blogspot.com'),
	('Kaitlyn Babar','789 Fulton Parkway','840-259-5142','kbabar5@gov.uk'),
	('Indira Whyman','6 Montana Way','468-955-0783','iwhyman6@weebly.com'),
	('Collie Smees','5053 Petterle Junction','393-898-4229','csmees7@amazonaws.com'),
	('Bogart Yorke','91747 Comanche Street','312-552-6043','byorke8@nydailynews.com'),
	('Noemi McIlvoray','7174 Eliot Trail','564-187-9770','nmcilvoray9@omniture.com'),
	('Oates Deaton','852 Donald Trail','378-489-9946','odeatona@photobucket.com'),
	('Giavani Parradye','19 Almo Court','687-162-2680','gparradyeb@comsenz.com'),
	('Angie Oldam','10 Farwell Drive','799-386-3052','aoldamc@google.fr'),
	('Corbie Masic','9365 Old Shore Lane','234-153-0954','cmasicd@a8.net'),
	('Jaynell Wolfenden','7 Messerschmidt Point','128-798-3693','jwolfendene@wisc.edu'),
	('Othella Healy','860 Lillian Plaza','499-994-2898','ohealyf@wordpress.com'),
	('Tomas Presnail','462 Portage Street','621-786-9033','tpresnailg@typepad.com'),
    ('Michael Johnson', '789 Oak St, Metroville', '555-555-5555', 'michael.johnson@example.com');
    
  -- inserto equipos  
    
INSERT INTO equipment (brand, model, serial_number, id_customer)
VALUES
		('NASDAQ','3 Series','230-12-5737','1'),
		('NYSES','afari','843-22-3235','2'),
		('NYSEV','ersa','266-56-2268','3'),
		('NYSEN','avigator','835-47-5614','4'),
		('NASDAQ','Equus','713-89-6181','5'),
		('NASDAQ','Malibu','484-46-3485','6'),
		('NASDAQ','Grand Am','429-59-4709','7'),
		('NASDAQ','I','378-15-8158','8'),
		('NYSEB','oxster','210-93-5280','9'),
		('NASDAQ','Supra','658-69-2791','10');
 -- inserto nombre y descripcion de componentes   
INSERT INTO components (name, description, price)
VALUES 
    ('Nadolol', 'Oth injury due to oth accident on board fishing boat, init', 15.00),
    ('Perphenazine', 'Puncture wound without foreign body of scalp', 250.00),
    ('Hammer Baking', 'Poisoning by unsp antieplptc and sed-hypntc drugs, undet', 350.00),
    ('Cockroach American', 'Neuroendocrine cell hyperplasia of infancy', 50.00),
    ('Quinapril', 'Pressr ulc of contig site of back, buttock & hip, unstageable', 750.00),
    ('Stemphylium sarciniforms', 'Commrcl fix-wing aircraft collision injuring occupant, subs', 50.40),
    ('Prednisone', 'Toxic effect of ingested mushrooms, self-harm, subs', 520.80),
    ('Sanitizer Original', 'Torus fx upper end of unsp tibia, subs for fx w routn heal', 999.99),
    ('COTTON SEED', 'Ophiasis', 29.99),
    ('Quinapril', 'Osteolysis, unspecified site', 329.99);


            
   -- inserto reparaciones 
   
INSERT INTO Repairs (start_date, end_date, description, total_cost, id_equipment)
VALUES
    ('2023-07-15', '2023-07-20', 'Laptop screen replacement', 150.00, 1),
    ('2023-07-20', '2023-07-22', 'Hard drive upgrade', 100.00, 2),
    ('2023-06-20','2023-06-27','hub usb',100.00,1),
    ('2023-02-01', '2023-02-05', 'CPU fan replacement', 800.00, 5),
    ('2023-04-01', '2023-04-05', 'reset', 10.00, 5),
	('2023-08-01', '2023-08-05', 'set windows', 50.00, 5);
    
-- inserto tecnicos
INSERT INTO technicians (name, specialization)
VALUES
    ('Alex Johnson', 'Reparación de laptops'),
    ('Emily White', 'Reparación de computadoras de escritorio'),
    ('William Davis', 'Soporte de redes');
    
-- inserto estados de repracion
INSERT INTO repair_status (name)
VALUES
    ('En Progreso'),
    ('En Espera'),
    ('Completada'),
    ('Cancelada');
    
    
    -- insertare  los estado de cada reparacion
INSERT INTO status_history(id_repair, id_status, change_date)
VALUES (1, 3, '2023-08-05');

INSERT INTO status_history(id_repair, id_status, change_date)
VALUES (1, 2, '2023-08-10');

INSERT INTO status_history(id_repair, id_status, change_date)
VALUES (2, 3, '2023-08-05');

-- asigno repraciones a tecnicos
INSERT INTO assignments (id_repair,id_technician , assignment_date)
VALUES (3, 3, '2023-07-14'),
		(6,2,'2023-09-03');
        
  -- asigno facturas a a las tabla invoices      
INSERT INTO invoices (id_repair,emission_date , total_amount)
VALUES (3, '2023-07-26', 1000),
		(6,'2023-09-30',150);
        

-- Insertar datos en la tabla "Stock" y obtener el último valor generado para cada componente
INSERT INTO Stock (id_component, quantity, update_date) VALUES
    (1, 100, NOW()), -- Nadolol
    (2, 10, NOW()), -- Perphenazine
    (3, 70, NOW()), -- Hammer Baking
    (4, 18, NOW()), -- Cockroach American
    (5, 0, NOW()), -- Quinapril
    (6, 300, NOW()), -- Stemphylium sarciniforms
    (7, 40, NOW()), -- Prednisone
    (8, 20, NOW()), -- Sanitizer Original
    (9, 110, NOW()), -- COTTON SEED
    (10, 170, NOW()); -- Quinapril
    


