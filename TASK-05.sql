


CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY, 
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL, 
    hire_date DATE NOT NULL,
    salary NUMERIC(10, 2) CHECK (salary >= 30000.00) NOT NULL, 
    department VARCHAR(50) NOT NULL,
    manager_id INTEGER REFERENCES employees(employee_id)
   
);


CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100) UNIQUE NOT NULL,
    start_date DATE  NOT NULL,
    end_date DATE,
    budget NUMERIC(15, 2) CHECK (budget > 0) NOT NULL, 
    status VARCHAR(20) DEFAULT 'Planned' NOT NULL,
    lead_employee_id int REFERENCES employees(employee_id) NOT NULL, 
    priority_level int CHECK (priority_level BETWEEN 1 AND 5) NOT NULL
);

CREATE OR REPLACE FUNCTION insert_employee_data(
    p_first_name VARCHAR,
    p_last_name VARCHAR,
    p_email VARCHAR,
    p_hire_date DATE,
    p_salary NUMERIC,
    p_department VARCHAR,
    p_manager_id INTEGER DEFAULT NULL
)
RETURNS INTEGER 
LANGUAGE plpgsql
AS $$
DECLARE
    inserted_id INTEGER;
BEGIN
    IF p_salary < 30000.00 THEN
        RAISE EXCEPTION 'Salary must be at least $30,000.00 to be inserted.';
    END IF;

    INSERT INTO employees (
        first_name, 
        last_name, 
        email, 
        hire_date, 
        salary, 
        department, 
        manager_id
    )
    VALUES (
        p_first_name, 
        p_last_name, 
        p_email, 
        p_hire_date, 
        p_salary, 
        p_department, 
        p_manager_id
    )
    RETURNING employee_id INTO STRICT inserted_id;

    RETURN inserted_id;
END;
$$;

SELECT insert_employee_data(
    'Alice', 
    'Smith', 
    'alice1.s@company.com', 
    '2023-08-15', 
    80000.00, 
    'Marketing', 
    NULL
);
select * from employees
select * from projects
CREATE OR REPLACE FUNCTION insert_project_data(
    p_project_name VARCHAR,
    p_start_date DATE,
    p_end_date DATE,
    p_budget NUMERIC,
    p_lead_employee_id INTEGER,  
    p_priority_level INTEGER,     
    p_status VARCHAR DEFAULT 'Planned'
)
RETURNS INTEGER 
LANGUAGE plpgsql
AS $$
DECLARE
    inserted_id INTEGER; 
BEGIN
    IF p_end_date IS NOT NULL AND p_end_date <= p_start_date THEN
        RAISE EXCEPTION 'Project end date (%) must be strictly after the start date (%).', 
        p_end_date, p_start_date;
    END IF;

    INSERT INTO projects (
        project_name, 
        start_date, 
        end_date, 
        budget, 
        status, 
        lead_employee_id, 
        priority_level
    )
    VALUES (
        p_project_name, 
        p_start_date, 
        p_end_date, 
        p_budget, 
        p_status, 
        p_lead_employee_id, 
        p_priority_level
    )
    RETURNING project_id INTO inserted_id; 

    RETURN inserted_id;
END;
$$;


SELECT insert_project_data(
    'New Website Launch', 
    '2025-01-01', 
    '2025-06-30', 
    150000.00, 
    'Active', 
    1, 
    4);

	



CREATE OR REPLACE FUNCTION insert_employee_data(
    p_first_name VARCHAR,
    p_last_name VARCHAR,
    p_email VARCHAR,
    p_hire_date DATE,
    p_salary NUMERIC,
    p_department VARCHAR,
    p_manager_id INTEGER DEFAULT NULL
)
RETURNS INTEGER 
LANGUAGE plpgsql
AS $$
DECLARE
    inserted_id INTEGER;
BEGIN
    IF p_salary < 30000.00 THEN
        RAISE EXCEPTION 'Salary must be at least $30,000.00 to be inserted.';
    END IF;

    INSERT INTO employees (
        first_name, 
        last_name, 
        email, 
        hire_date, 
        salary, 
        department, 
        manager_id
    )
    VALUES (
        p_first_name, 
        p_last_name, 
        p_email, 
        p_hire_date, 
        p_salary, 
        p_department, 
        p_manager_id
    )
    RETURNING employee_id INTO STRICT inserted_id;

    RETURN inserted_id;
END;
$$;


CREATE OR REPLACE FUNCTION calculate_employee_avg_budget(
    p_employee_id INTEGER
)
RETURNS NUMERIC(15, 2) 
LANGUAGE plpgsql
AS $$
DECLARE
    avg_budget_result NUMERIC(15, 2);
    project_count INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO project_count
    FROM projects
    WHERE lead_employee_id = p_employee_id;

    IF project_count = 0 THEN
        RETURN NULL; 
    END IF;
    
    SELECT AVG(budget)
    INTO avg_budget_result
    FROM projects
    WHERE lead_employee_id = p_employee_id;

    RETURN avg_budget_result;
END;
$$;



SELECT calculate_employee_avg_budget(1);

SELECT calculate_employee_avg_budget(90); 

