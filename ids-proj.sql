/****************************************************************
**  Projekt:    IDS - 2. část
**  Autory:     Vincenc Lukáš <xvince01@vut.cz>
**              Torbin Evgeny <xtorbi00@vut.cz>
**  Téma:       Bug tracker
**  Popis:      SQL skript pro vytvoření databáze informačního
**              systému pro hlášení a správu chyb
*****************************************************************/

-- =============================
-- ODSTRANĚNÍ TABULEK
-- =============================

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

-- =============================
-- VYTVOŘENÍ TABULEK
-- =============================

----
-- Person
--
-- Reprezentuje entitu Uživatel.
-- Vztah generalizace mezi Programátorem a Uživatelem
-- je transformován do jedné tabulky, kde rozlišení specizací
-- podle diskriminátoru "role".
----
CREATE TABLE Person (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    login VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    second_name VARCHAR(255) NOT NULL,
    sex CHAR NOT NULL,
    birth_date DATE NOT NULL,
    email VARCHAR(255) NOT NULL
        -- TODO: rewrite regex
        CHECK(REGEXP_LIKE(
			email, '^[a-z]+[a-z0-9\.]*@[a-z0-9\.-]+\.[a-z]{2,}$', 'i'
		)),
    phone VARCHAR(255) NOT NULL,
    address VARCHAR(255) NOT NULL,
    role VARCHAR(255) NOT NULL,
    position VARCHAR(255)
);

----
-- Ticket
--
-- Reprezentuje entitu Tiket.
----
CREATE TABLE Ticket (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(255) DEFAULT NULL,
    create_date DATE NOT NULL,
    status VARCHAR(255) NOT NULL,
    created_by INT NOT NULL,
    patch_id INT NOT NULL
);

----
-- Module
--
-- Reprezentuje entitu Modul.
----
CREATE TABLE Module (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    create_date DATE NOT NULL,
    author INT NOT NULL,
    patch_id INT NOT NULL
);

----
-- Patch
--
-- Reprezentuje entitu Patch.
----
CREATE TABLE Patch (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    create_date DATE NOT NULL,
    deployment_date DATE DEFAULT NULL,
    status VARCHAR(255) NOT NULL,
    created_by INT NOT NULL,
    approved_by INT NOT NULL
);

----
-- Bug
--
-- Reprezentuje entitu Bug.
----
CREATE TABLE Bug (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(255) DEFAULT NULL,
    priority VARCHAR(255) NOT NULL,
    module_id INT NOT NULL
);

----
-- Prog_lang
--
-- Reprezentuje entitu Programovací jazyk.
----
CREATE TABLE Prog_lang (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

----
-- Reward
--
-- Reprezentuje entitu Odměna.
----
CREATE TABLE Reward (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    amount INT DEFAULT 0,
    person_id INT NOT NULL
);

----
-- Person_prog_lang
--
-- Reprezentuje vazbu mezi Uživatelem a Programovacím jazykem.
----
CREATE TABLE Person_prog_langs (
    person_id INT NOT NULL,
    prog_lang_id INT NOT NULL
);

----
-- Module_prog_langs
--
-- Reprezentuje vazbu mezi Modulem a Programovacím jazykem.
----
CREATE TABLE Module_prog_langs (
    module_id INT NOT NULL,
    prog_lang_id INT NOT NULL
);

----
-- Person_modules
--
-- Reprezentuje vazbu mezi Uživatelem a Modulem.
----
CREATE TABLE Person_modules (
    person_id INT NOT NULL,
    module_id INT NOT NULL
);

----
-- Ticket_bugs
--
-- Reprezentuje vazbu mezi Tiketem a Bugem.
----
CREATE TABLE Ticket_bugs (
    ticket_id INT NOT NULL,
    bug_id INT NOT NULL
);

-- =============================
-- PŘÍDÁNÍ VAZEB
-- =============================

----
-- Tiket
----

-- Uživatel [1] ---> [0..n] Tiket
ALTER TABLE Ticket ADD CONSTRAINT ticket_created_by_fk
    FOREIGN KEY (created_by) REFERENCES Person(id)
    ON DELETE CASCADE;

-- Patch [1] ---> [1..n] Tiket
ALTER TABLE Ticket ADD CONSTRAINT ticket_patch_id_fk
    FOREIGN KEY (patch_id) REFERENCES Patch(id)
    ON DELETE CASCADE;

----
-- Module
----

-- Uživatel [1] ---> [0..n] Modul
ALTER TABLE Module ADD CONSTRAINT module_author_fk
    FOREIGN KEY (author) REFERENCES Person(id)
    ON DELETE CASCADE;

-- Patch [1] ---> [1..n] Modul
ALTER TABLE Module ADD CONSTRAINT module_patch_id_fk
    FOREIGN KEY (patch_id) REFERENCES Patch(id)
    ON DELETE CASCADE;

----
-- Patch
----

-- Uživatel [1] ---> [0..n] Patch (vytvoření)
ALTER TABLE Patch ADD CONSTRAINT patch_created_by_fk
    FOREIGN KEY (created_by) REFERENCES Person(id)
    ON DELETE CASCADE;

-- Uživatel [1] ---> [0..n] Patch (schválení)
ALTER TABLE Patch ADD CONSTRAINT patch_approved_by_fk
    FOREIGN KEY (approved_by) REFERENCES Person(id)
    ON DELETE CASCADE;

----
-- Bug
----

-- Modul [1] ---> [0..n] Bug
ALTER TABLE Bug ADD CONSTRAINT bug_module_id_fk
    FOREIGN KEY (module_id) REFERENCES Module(id)
    ON DELETE CASCADE;

----
-- Reward
----

-- Uživatel [1] ---> [0..n] Odměna
ALTER TABLE Reward ADD CONSTRAINT reward_person_id_fk
    FOREIGN KEY (person_id) REFERENCES Person(id)
    ON DELETE CASCADE;

----
-- Module_prog_langs
--
-- Modul [0..n] ---> [1..n] Programovací jazyk
----

-- Odkaz na Modul
ALTER TABLE Module_prog_langs ADD CONSTRAINT module_prog_langs_module_id_fk
    FOREIGN KEY (module_id) REFERENCES Module(id)
    ON DELETE CASCADE;

-- Odkaz na Programovací jazyk
ALTER TABLE Module_prog_langs ADD CONSTRAINT module_prog_langs_prog_lang_id_fk
    FOREIGN KEY (prog_lang_id) REFERENCES Prog_lang(id)
    ON DELETE CASCADE;

----
-- Ticket_bugs
--
-- Tiket [1..n] ---> [1..n] Bug
----

-- Odkaz na Tiket
ALTER TABLE Ticket_bugs ADD CONSTRAINT ticket_bugs_ticket_id_fk
    FOREIGN KEY (ticket_id) REFERENCES Ticket(id)
    ON DELETE CASCADE;

-- Odkaz na Bug
ALTER TABLE Ticket_bugs ADD CONSTRAINT ticket_bugs_bug_id_fk
    FOREIGN KEY (bug_id) REFERENCES Bug(id)
    ON DELETE CASCADE;

----
-- Person_prog_langs
--
-- Uživatel [0..n] ---> [1..n] Programovací jazyk
----

-- Odkaz na Uživatele
ALTER TABLE Person_prog_langs ADD CONSTRAINT person_prog_langs_person_id_fk
    FOREIGN KEY (person_id) REFERENCES Person(id)
    ON DELETE CASCADE;

-- Odkaz na Programovací jazyk
ALTER TABLE Person_prog_langs ADD CONSTRAINT person_prog_langs_prog_lang_id_fk
    FOREIGN KEY (prog_lang_id) REFERENCES Prog_lang(id)
    ON DELETE CASCADE;

----
-- Person_modules
--
-- Uživatel [0..n] ---> [1..n] Modul
----

-- Odkaz na Uživatele
ALTER TABLE Person_modules ADD CONSTRAINT person_modules_person_id_fk
    FOREIGN KEY (person_id) REFERENCES Person(id)
    ON DELETE CASCADE;

-- Odkaz na Modul
ALTER TABLE Person_modules ADD CONSTRAINT person_modules_module_id_fk
    FOREIGN KEY (module_id) REFERENCES Module(id)
    ON DELETE CASCADE;

-- =============================
-- VLOŽENÍ UKÁZKOVÝCH DAT
-- =============================
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
