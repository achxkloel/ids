------------------------------- mazání tabulek -------------------------------
DROP TABLE PERSON;
DROP TABLE TICKET;
DROP TABLE MODULE;
DROP TABLE PATCH;
DROP TABLE BUG;
DROP TABLE PROG_LANG;
DROP TABLE REWARD;
DROP TABLE PERSON_PROG_LANGS;
DROP TABLE MODULE_PROG_LANGS;
DROP TABLE PERSON_MODULES;
DROP TABLE TICKET_BUGS;

------------------------------- vytvoření tabulek -------------------------------
-- PERSON reprezentuje entitu user
-- spojili jsme uživatele a programátora, to, zda je uživatel programátor určuje role
CREATE TABLE PERSON (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    login VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    second_name VARCHAR(255) NOT NULL,
    sex CHAR NOT NULL,
    birth_date DATE NOT NULL,
    email VARCHAR(255) NOT NULL
        CHECK(REGEXP_LIKE(
			"email", '^[a-z]+[a-z0-9\.]*@[a-z0-9\.-]+\.[a-z]{2,}$', 'i'
		)),,
    phone VARCHAR(255) NOT NULL,
    address VARCHAR(255) NOT NULL,
    role VARCHAR(255) NOT NULL,
    position VARCHAR(255)
);

CREATE TABLE TICKET (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255),
    description VARCHAR(255),
    create_date DATE,
    status VARCHAR(255),
    created_by INT,
    patch_id INT
);

CREATE TABLE MODULE (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255),
    create_date DATE,
    author INT,
    patch_id INT
);

CREATE TABLE PATCH (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    create_date DATE,
    deployment_date DATE,
    status VARCHAR(255),
    created_by INT,
    approved_by INT
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
);

CREATE TABLE REWARD (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    amount INT,
    user_id INT
);

CREATE TABLE PERSON_PROG_LANGS (
    person_id INT,
    prog_lang_id INT
);

CREATE TABLE MODULE_PROG_LANGS (
    module_id INT,
    prog_lang_id INT
);

CREATE TABLE PERSON_MODULES (
    person_id INT,
    module_id INT
);

CREATE TABLE TICKET_BUGS (
    ticket_id INT,
    bug_id INT
);

------------------------------- vytvoření vazeb -------------------------------
----------------- vazby ticketu -----------------
-- vazba mezi ticketem a uživatelem, který jej vytvořil
ALTER TABLE TICKET ADD CONSTRAINT ticket_created_by_fk
    FOREIGN KEY (created_by) REFERENCES PERSON(id)
    ON DELETE CASCADE;
-- vazba mezi ticketem a patchem, který jej řeší
ALTER TABLE TICKET ADD CONSTRAINT ticket_patch_id_fk
    FOREIGN KEY (patch_id) REFERENCES PATCH(id)
    ON DELETE CASCADE;

----------------- vazby modulu -----------------
-- vazba mezi modulem a uživatelem, který jej vytvořil
ALTER TABLE MODULE ADD CONSTRAINT module_author_fk
    FOREIGN KEY (author) REFERENCES PERSON(id)
    ON DELETE CASCADE;
-- vazba mezi modulem a patchem, ke kterému se modul vztahuje
ALTER TABLE MODULE ADD CONSTRAINT module_patch_id_fk
    FOREIGN KEY (patch_id) REFERENCES PATCH(id)
    ON DELETE CASCADE;

----------------- vazby patche -----------------
-- vazba mezi patchem a uživatelem, který jej vytvořil
ALTER TABLE PATCH ADD CONSTRAINT patch_created_by_fk
    FOREIGN KEY (created_by) REFERENCES PERSON(id)
    ON DELETE CASCADE;
-- vazba mezi patchem a programátorem, který jej schválil
ALTER TABLE PATCH ADD CONSTRAINT patch_approved_by_fk
    FOREIGN KEY (approved_by) REFERENCES PERSON(id)
    ON DELETE CASCADE;

----------------- vazba bugu -----------------
-- vazba mezi bugem a modulem, ve kterém se bug nachází
ALTER TABLE BUG ADD CONSTRAINT bug_module_id_fk
    FOREIGN KEY (module_id) REFERENCES PERSON(id)
    ON DELETE CASCADE;

----------------- vazba odměny -----------------
-- vazba mezi odměnou a uživatelem, který ji dostane
ALTER TABLE REWARD ADD CONSTRAINT reward_user_id_fk
    FOREIGN KEY (user_id) REFERENCES PERSON(id)
    ON DELETE CASCADE;

------------------------------- vložení testovacích dat -------------------------------
INSERT INTO PERSON (login, first_name, second_name, sex, birth_date, email, phone, address, role, position)
VALUES ('xvince01', 'Lukáš', 'Vincenc', 'M', '01.01.2000', 'xvince@gmail.com', '765 765 765', 'Brno 33', 'programmer', 'developer');
INSERT INTO PERSON (login, first_name, second_name, sex, birth_date, email, phone, address, role, position)
VALUES ('xtorbi00', 'Evgeny', 'Torbin', 'M', '02.02.2000', 'xtorbi@gmail.com', '678 678 678', 'Brno 22', 'programmer', 'developer');
INSERT INTO PERSON (login, first_name, second_name, sex, birth_date, email, phone, address, role, position)
VALUES ('xuser00', 'Jan', 'Novák', 'M', '03.03.2000', 'xuser@gmail.com', '675 675 675', 'Brno 11', 'user', NULL);
