/*

SELECT *
FROM invoices_raw;

SELECT *
FROM expenses_raw;


SELECT column_name, data_type
FROM information_schema.COLUMNS
WHERE table_name = 'invoices_raw';

SELECT column_name
FROM information_schema.COLUMNS
WHERE table_name = 'invoices_raw';

SELECT column_name, data_type
FROM information_schema.COLUMNS
WHERE table_name = 'expenses_raw';

SELECT column_name
FROM information_schema.COLUMNS
WHERE table_name = 'expenses_raw';

*/

DROP TABLE IF EXISTS invoices_wip;
DROP TABLE IF EXISTS expenses_wip;

CREATE TABLE invoices_wip AS
	SELECT 
		id::TEXT,
		subject_id::TEXT,
		client_name AS subject_name,
		proforma,
		status,
		issued_on::DATE,
		paid_at::DATE AS paid_on,
		native_total::REAL AS total,
		paid_amount::REAL,
		lines	
	FROM invoices_raw;

CREATE TABLE expenses_wip AS
	SELECT 
		id::TEXT,
		subject_id::TEXT,
		supplier_name AS subject_name,
		document_type,
		status,
		issued_on::DATE,
		paid_on::DATE,
		(-1)*total::REAL AS total,
		paid_amount::REAL,
		lines	
	FROM expenses_raw;

/*

SELECT *
FROM invoices_wip;

SELECT *
FROM expenses_wip;

 */

DELETE FROM invoices_wip
WHERE proforma IS TRUE AND status = 'overdue';

DELETE FROM expenses_wip
WHERE document_type = 'bill';

ALTER TABLE invoices_wip
DROP COLUMN proforma;

ALTER TABLE expenses_wip
DROP COLUMN document_type;

ALTER TABLE invoices_wip 
ADD	COLUMN lines_name TEXT;

ALTER TABLE invoices_wip
ADD	COLUMN lines_quantity TEXT;

ALTER TABLE invoices_wip
ADD	COLUMN lines_unit_name TEXT;

ALTER TABLE expenses_wip 
ADD	COLUMN lines_name TEXT;

ALTER TABLE expenses_wip
ADD	COLUMN lines_quantity TEXT;

ALTER TABLE expenses_wip
ADD	COLUMN lines_unit_name TEXT;

UPDATE invoices_wip
SET lines_name = lines -> 0 ->> 'name';

UPDATE invoices_wip
SET lines_quantity = lines -> 0 ->> 'quantity';

UPDATE invoices_wip
SET lines_unit_name = lines -> 0 ->> 'unit_name';

UPDATE expenses_wip
SET lines_name = lines -> 0 ->> 'name';

UPDATE expenses_wip
SET lines_quantity = lines -> 0 ->> 'quantity';

UPDATE expenses_wip
SET lines_unit_name = lines -> 0 ->> 'unit_name';

ALTER TABLE invoices_wip
DROP COLUMN lines;

ALTER TABLE expenses_wip
DROP COLUMN lines;

DROP TABLE IF EXISTS movements;

CREATE TABLE movements AS
	SELECT *
	FROM invoices_wip
	UNION
	SELECT *
	FROM expenses_wip;
	
SELECT *
FROM movements
ORDER BY total DESC;

/* COPY (SELECT * FROM movements ORDER BY total DESC) TO 'path' WITH CSV HEADER; this would be server-side copy for cloud etc. applications, 
but for my purpose of outputting this to my local machine, it's better to use the client-side psql command */

/*
the client-side command:

\copy (SELECT * FROM movements ORDER BY total DESC) TO '/home/radimt/projects/case_study/movements.csv' WITH CSV HEADER;

*/