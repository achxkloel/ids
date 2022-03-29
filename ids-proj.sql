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

CREATE TABLE TICKET (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255),
    description VARCHAR(255),
    create_date DATE,
    status VARCHAR(255),
    created_by VARCHAR(255),
    patch_id INT
);

CREATE TABLE MODULE (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255),
    create_date DATE,
    author VARCHAR(255),
    patch_id INT
);

CREATE TABLE PATCH (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    create_date DATE,
    deployment_date DATE,
    status VARCHAR(255),
    created_by VARCHAR(255),
    approved_by VARCHAR(255)
);

CREATE TABLE BUG (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255),
    description VARCHAR(255),
    priority VARCHAR(255),
    module_id INT
);

CREATE TABLE PROG_LANG (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255)
)

CREATE TABLE REWARD (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    amount INT,
    user_login VARCHAR(255)
)