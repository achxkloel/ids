DROP TABLE PERSON;

CREATE TABLE PERSON (
    login VARCHAR(255) PRIMARY KEY,
    first_name VARCHAR(255),
    second_name VARCHAR(255),
    sex CHAR,
    birth_date DATE,
    email VARCHAR(255),
    phone VARCHAR(255),
    address VARCHAR(255),
    role VARCHAR(255),
    position VARCHAR(255)
);