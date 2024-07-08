-- Criação do banco de dados
CREATE DATABASE company_bd;
USE company_bd;

-- Criação de usuários
CREATE USER 'manager'@localhost IDENTIFIED BY '123456789';
CREATE USER 'employee'@localhost IDENTIFIED BY '123456789';

-- Permissões
GRANT ALL PRIVILEGES ON company_bd.* TO 'manager'@localhost;
GRANT SELECT ON company_bd.EmployeeCountByDeptLocation TO 'employee'@localhost;
GRANT SELECT ON company_bd.DepartmentManagers TO 'employee'@localhost;
GRANT SELECT ON company_bd.ProjectsByEmployeeCount TO 'employee'@localhost;
GRANT SELECT ON company_bd.ProjectsDepartmentsManagers TO 'employee'@localhost;
GRANT SELECT ON company_bd.EmployeesWithDependentsAndManagerStatus TO 'employee'@localhost;

-- Criação de tabelas
-- Tabela Department
CREATE TABLE Department (
    Dnumber INT AUTO_INCREMENT,
    Dname VARCHAR(100) NOT NULL,
    Mgr_ssn INT,
    Mgr_start_date DATE,
    Dlocation VARCHAR(100),
    PRIMARY KEY (Dnumber)
);

-- Tabela Employee
CREATE TABLE Employee (
    Ssn INT,
    Fname VARCHAR(50),
    Minit CHAR(1),
    Lname VARCHAR(50),
    Bdate DATE,
    Address VARCHAR(100),
    Sex CHAR(1),
    Salary FLOAT,
    Super_ssn INT,
    Dno INT,
    PRIMARY KEY (Ssn),
    FOREIGN KEY (Super_ssn) REFERENCES Employee(Ssn) ON DELETE SET NULL,
    FOREIGN KEY (Dno) REFERENCES Department(Dnumber) ON DELETE SET NULL
);

-- Tabela Dependent
CREATE TABLE Dependent (
    Essn INT,
    Dependent_name VARCHAR(50),
    Sex CHAR(1),
    Bdate DATE,
    Relationship VARCHAR(50),
    PRIMARY KEY (Essn, Dependent_name),
    FOREIGN KEY (Essn) REFERENCES Employee(Ssn) ON DELETE CASCADE
);

-- Tabela Project
CREATE TABLE Project (
    Pnumber INT AUTO_INCREMENT,
    Pname VARCHAR(100),
    Plocation VARCHAR(100),
    Dnum INT,
    PRIMARY KEY (Pnumber),
    FOREIGN KEY (Dnum) REFERENCES Department(Dnumber)
);

-- Tabela intermediária para relacionamento muitos-para-muitos entre Employee e Project
CREATE TABLE Works_On (
    Essn INT,
    Pno INT,
    Hours FLOAT,
    PRIMARY KEY (Essn, Pno),
    FOREIGN KEY (Essn) REFERENCES Employee(Ssn) ON DELETE CASCADE,
    FOREIGN KEY (Pno) REFERENCES Project(Pnumber) ON DELETE CASCADE
);

-- View do número de empregados por departamento e localidade
CREATE VIEW EmployeeCountByDeptLocation AS
SELECT 
    d.Dname AS DepartmentName,
    d.Dlocation AS Location,
    COUNT(e.Ssn) AS EmployeeCount
FROM 
    Department d
LEFT JOIN 
    Employee e ON d.Dnumber = e.Dno
GROUP BY 
    d.Dname, d.Dlocation;

-- View da lista de departamentos e seus gerentes
CREATE VIEW DepartmentManagers AS
SELECT 
    d.Dnumber AS DepartmentNumber,
    d.Dname AS DepartmentName,
    e.Fname AS ManagerFirstName,
    e.Minit AS ManagerMiddleInitial,
    e.Lname AS ManagerLastName,
    d.Mgr_start_date AS ManagerStartDate
FROM 
    Department d
LEFT JOIN 
    Employee e ON d.Mgr_ssn = e.Ssn;

-- View dos projetos com maior número de empregados
CREATE VIEW ProjectsByEmployeeCount AS
SELECT 
    p.Pnumber AS ProjectNumber,
    p.Pname AS ProjectName,
    p.Plocation AS ProjectLocation,
    COUNT(w.Essn) AS EmployeeCount
FROM 
    Project p
LEFT JOIN 
    Works_On w ON p.Pnumber = w.Pno
GROUP BY 
    p.Pnumber, p.Pname, p.Plocation
ORDER BY 
    EmployeeCount DESC;

-- View da lista de projetos, departamentos e gerentes
CREATE VIEW ProjectsDepartmentsManagers AS
SELECT 
    p.Pnumber AS ProjectNumber,
    p.Pname AS ProjectName,
    p.Plocation AS ProjectLocation,
    d.Dnumber AS DepartmentNumber,
    d.Dname AS DepartmentName,
    e.Fname AS ManagerFirstName,
    e.Minit AS ManagerMiddleInitial,
    e.Lname AS ManagerLastName
FROM 
    Project p
LEFT JOIN 
    Department d ON p.Dnum = d.Dnumber
LEFT JOIN 
    Employee e ON d.Mgr_ssn = e.Ssn;

-- View dos empregados que possuem dependentes e se são gerentes
CREATE VIEW EmployeesWithDependentsAndManagerStatus AS
SELECT 
    e.Ssn AS EmployeeSSN,
    e.Fname AS FirstName,
    e.Minit AS MiddleInitial,
    e.Lname AS LastName,
    CASE
        WHEN d.Essn IS NOT NULL THEN 'Yes'
        ELSE 'No'
    END AS HasDependents,
    CASE
        WHEN e.Ssn = dept.Mgr_ssn THEN 'Yes'
        ELSE 'No'
    END AS IsManager
FROM 
    Employee e
LEFT JOIN 
    Dependent d ON e.Ssn = d.Essn
LEFT JOIN 
    Department dept ON e.Ssn = dept.Mgr_ssn
GROUP BY 
    e.Ssn, e.Fname, e.Minit, e.Lname, dept.Mgr_ssn;