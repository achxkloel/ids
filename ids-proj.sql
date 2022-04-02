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
			email, '^[a-z]+[a-z0-9\.]*@[a-z0-9\.-]+\.[a-z]{2,}$', 'i'
		)),
    phone VARCHAR(255) NOT NULL,
    address VARCHAR(255) NOT NULL,
    role VARCHAR(255) NOT NULL,
    position VARCHAR(255)
);

CREATE TABLE TICKET (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(255) DEFAULT NULL,
    create_date DATE NOT NULL,
    status VARCHAR(255) NOT NULL,
    created_by INT NOT NULL,
    patch_id INT NOT NULL
);

CREATE TABLE MODULE (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    create_date DATE NOT NULL,
    author INT NOT NULL,
    patch_id INT NOT NULL
);

CREATE TABLE PATCH (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    create_date DATE NOT NULL,
    deployment_date DATE DEFAULT NULL,
    status VARCHAR(255) NOT NULL,
    created_by INT NOT NULL,
    approved_by INT NOT NULL
);

CREATE TABLE BUG (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(255) DEFAULT NULL,
    priority VARCHAR(255) NOT NULL,
    module_id INT NOT NULL
);

CREATE TABLE PROG_LANG (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE REWARD (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    amount INT DEFAULT 0,
    person_id INT NOT NULL
);

CREATE TABLE PERSON_PROG_LANGS (
    person_id INT NOT NULL,
    prog_lang_id INT NOT NULL
);

CREATE TABLE MODULE_PROG_LANGS (
    module_id INT NOT NULL,
    prog_lang_id INT NOT NULL
);

CREATE TABLE PERSON_MODULES (
    person_id INT NOT NULL,
    module_id INT NOT NULL
);

CREATE TABLE TICKET_BUGS (
    ticket_id INT NOT NULL,
    bug_id INT NOT NULL
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
ALTER TABLE REWARD ADD CONSTRAINT reward_person_id_fk
    FOREIGN KEY (person_id) REFERENCES PERSON(id)
    ON DELETE CASCADE;

ALTER TABLE MODULE_PROG_LANGS ADD CONSTRAINT module_prog_langs_module_id_fk
    FOREIGN KEY (module_id) REFERENCES MODULE(id)
    ON DELETE CASCADE;
ALTER TABLE MODULE_PROG_LANGS ADD CONSTRAINT module_prog_langs_prog_lang_id_fk
    FOREIGN KEY (prog_lang_id) REFERENCES PROG_LANG(id)
    ON DELETE CASCADE;

ALTER TABLE TICKET_BUGS ADD CONSTRAINT ticket_bugs_ticket_id_fk
    FOREIGN KEY (ticket_id) REFERENCES TICKET(id)
    ON DELETE CASCADE;
ALTER TABLE TICKET_BUGS ADD CONSTRAINT ticket_bugs_bug_id_fk
    FOREIGN KEY (bug_id) REFERENCES BUG(id)
    ON DELETE CASCADE;

ALTER TABLE PERSON_PROG_LANGS ADD CONSTRAINT person_prog_langs_person_id_fk
    FOREIGN KEY (person_id) REFERENCES PERSON(id)
    ON DELETE CASCADE;
ALTER TABLE PERSON_PROG_LANGS ADD CONSTRAINT person_prog_langs_prog_lang_id_fk
    FOREIGN KEY (prog_lang_id) REFERENCES PROG_LANG(id)
    ON DELETE CASCADE;

ALTER TABLE PERSON_MODULES ADD CONSTRAINT person_modules_person_id_fk
    FOREIGN KEY (person_id) REFERENCES PERSON(id)
    ON DELETE CASCADE;
ALTER TABLE PERSON_MODULES ADD CONSTRAINT person_modules_module_id_fk
    FOREIGN KEY (module_id) REFERENCES MODULE(id)
    ON DELETE CASCADE;

------------------------------- vložení testovacích dat -------------------------------
INSERT INTO PERSON (login, first_name, second_name, sex, birth_date, email, phone, address, role, position)
VALUES ('xvince01', 'Lukáš', 'Vincenc', 'M', TO_DATE('01/01/2000', 'DD/MM/YYYY'), 'xvince@gmail.com', '765 765 765', 'Brno 33', 'programmer', 'developer');
INSERT INTO PERSON (login, first_name, second_name, sex, birth_date, email, phone, address, role, position)
VALUES ('xtorbi00', 'Evgeny', 'Torbin', 'M', TO_DATE('02/02/2000', 'DD/MM/YYYY'), 'xtorbi@gmail.com', '678 678 678', 'Brno 22', 'programmer', 'developer');
INSERT INTO PERSON (login, first_name, second_name, sex, birth_date, email, phone, address, role, position)
VALUES ('xuser00', 'Jan', 'Novák', 'M', TO_DATE('03/03/2000', 'DD/MM/YYYY'), 'xuser@gmail.com', '675 675 675', 'Brno 11', 'user', NULL);

INSERT INTO TICKET (name, description, create_date, status, created_by, patch_id)
VALUES ('ticket no. 1', NULL, TO_DATE('24/12/2021', 'DD/MM/YYYY'), 'V řešení', 1, 1);
INSERT INTO TICKET (name, create_date, status, created_by, patch_id)
VALUES ('ticket no. 2', 'example description', TO_DATE('01/04/2022', 'DD/MM/YYYY'), 'Vyřešen', 2, 2);

INSERT INTO PATCH (create_date, deployment_date, status, created_by, approved_by)
VALUES (TO_DATE('05/01/2022'), NULL, 'Implementován', 2, 1);
INSERT INTO PATCH (create_date, deployment_date, status, created_by, approved_by)
VALUES (TO_DATE('06/03/2022'), TO_DATE('25/03/2022'), 'Nasazeno', 3, 2);

INSERT INTO BUG (name, description, priority, module_id)
VALUES ('bug no. 1', 'example description', 'high', 1);
INSERT INTO BUG (name, description, priority, module_id)
VALUES ('bug no. 2', NULL, 'low', 2);

INSERT INTO MODULE_PROG_LANGS (module_id, prog_lang_id)
VALUES (1, 1);
INSERT INTO MODULE_PROG_LANGS (module_id, prog_lang_id)
VALUES (2, 1);

INSERT INTO TICKET_BUGS (ticket_id, bug_id)
VALUES (1, 1);
INSERT INTO TICKET_BUGS (ticket_id, bug_id)
VALUES (1, 2);
