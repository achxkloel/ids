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

DROP TABLE PERSON_PROG_LANGS;
DROP TABLE MODULE_PROG_LANGS;
DROP TABLE PERSON_MODULES;
DROP TABLE TICKET_BUGS;
DROP TABLE REWARD;
DROP TABLE BUG;
DROP TABLE TICKET;
DROP TABLE MODULE;
DROP TABLE PATCH;
DROP TABLE PROG_LANG;
DROP TABLE PERSON;

-- =============================
-- VYTVOŘENÍ TABULEK
-- =============================

----
-- Person
--
-- Reprezentuje entitu Uživatel.
-- Na rozdíl od datového modelu byl přidán atribut "id",
-- který se stal novým primárním klíčem místo atributu "login".
--
-- Vztah generalizace mezi Programátorem a Uživatelem
-- je transformován do jedné tabulky, kde jsou specializace
-- rozlišeny podle diskriminátoru "role".
----
CREATE TABLE Person (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    login VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    second_name VARCHAR(255) NOT NULL,
    sex CHAR NOT NULL,
    birth_date VARCHAR(255) NOT NULL,
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
    description VARCHAR(255) DEFAULT '',
    create_date VARCHAR(255) NOT NULL,
    status VARCHAR(255) NOT NULL,
    created_by INT NOT NULL,
    patch_id INT DEFAULT NULL
);

----
-- Module
--
-- Reprezentuje entitu Modul.
----
CREATE TABLE Module (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    create_date VARCHAR(255) NOT NULL,
    author INT NOT NULL,
    patch_id INT DEFAULT NULL
);

----
-- Patch
--
-- Reprezentuje entitu Patch.
----
CREATE TABLE Patch (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    create_date VARCHAR(255) NOT NULL,
    deployment_date VARCHAR(255) DEFAULT NULL,
    status VARCHAR(255) NOT NULL,
    created_by INT NOT NULL,
    approved_by INT DEFAULT NULL
);

----
-- Bug
--
-- Reprezentuje entitu Bug.
----
CREATE TABLE Bug (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(255) DEFAULT '',
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
-- PŘIDÁNÍ VAZEB
-- =============================

----
-- Tiket
----

-- Uživatel [1] ---> [0..n] Tiket
ALTER TABLE Ticket ADD CONSTRAINT ticket_created_by_fk
    FOREIGN KEY (created_by) REFERENCES Person(id)
    ON DELETE SET NULL;

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
    ON DELETE SET NULL;

----
-- Patch
----

-- Uživatel [1] ---> [0..n] Patch (vytvoření)
ALTER TABLE Patch ADD CONSTRAINT patch_created_by_fk
    FOREIGN KEY (created_by) REFERENCES Person(id)
    ON DELETE SET NULL;

-- Uživatel [1] ---> [0..n] Patch (schválení)
ALTER TABLE Patch ADD CONSTRAINT patch_approved_by_fk
    FOREIGN KEY (approved_by) REFERENCES Person(id)
    ON DELETE SET NULL;

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

----
-- Uživatele
----

INSERT INTO Person (
    login, first_name, second_name, sex,
    birth_date, email, phone, address,
    role, position
) VALUES (
    'xvince01',
    'Lukáš',
    'Vincenc',
    'M',
    '2000-01-01',
    'xvince01@gmail.com',
    '765 765 765',
    'Božetěchová 44, Brno',
    'programmer',
    'main developer'
);

INSERT INTO Person (
    login, first_name, second_name, sex,
    birth_date, email, phone, address,
    role, position
) VALUES (
    'xtorbi00',
    'Evgeny',
    'Torbin',
    'M',
    '2000-02-02', -- TO DATE
    'xtorbi00@gmail.com',
    '678 678 678',
    'Božetěchová 33, Brno',
    'programmer',
    'developer'
);

INSERT INTO Person (
    login, first_name, second_name, sex,
    birth_date, email, phone, address,
    role, position
) VALUES (
    'xnovak00',
    'Jan',
    'Novák',
    'M',
    '2000-03-03', -- TO DATE
    'xnovak00@gmail.com',
    '675 675 675',
    'Božetěchová 22, Brno',
    'user',
    NULL
);

INSERT INTO Person (
    login, first_name, second_name, sex,
    birth_date, email, phone, address,
    role, position
) VALUES (
    'xnovak01',
    'Jana',
    'Novákova',
    'F',
    '2000-04-04',
    'xnovak01@gmail.com',
    '638 638 638',
    'Božetěchová 11, Brno',
    'user',
    NULL
);

----
-- Programovací jazyky
----

INSERT INTO Prog_lang (name) VALUES ('Javascript');
INSERT INTO Prog_lang (name) VALUES ('C++');
INSERT INTO Prog_lang (name) VALUES ('Kotlin');
INSERT INTO Prog_lang (name) VALUES ('C');
INSERT INTO Prog_lang (name) VALUES ('Go');
INSERT INTO Prog_lang (name) VALUES ('Java');
INSERT INTO Prog_lang (name) VALUES ('Python');
INSERT INTO Prog_lang (name) VALUES ('PHP');

----
-- Programovací jazyky, kterými uživatele disponují
----

INSERT INTO Person_prog_langs (person_id, prog_lang_id) VALUES (1, 1);
INSERT INTO Person_prog_langs (person_id, prog_lang_id) VALUES (1, 4);
INSERT INTO Person_prog_langs (person_id, prog_lang_id) VALUES (1, 8);
INSERT INTO Person_prog_langs (person_id, prog_lang_id) VALUES (2, 1);
INSERT INTO Person_prog_langs (person_id, prog_lang_id) VALUES (2, 7);
INSERT INTO Person_prog_langs (person_id, prog_lang_id) VALUES (3, 6);
INSERT INTO Person_prog_langs (person_id, prog_lang_id) VALUES (3, 3);
INSERT INTO Person_prog_langs (person_id, prog_lang_id) VALUES (4, 5);

----
-- Patche
----

INSERT INTO Patch (create_date, deployment_date, status, created_by, approved_by)
VALUES ('2022-01-05', NULL, 'in process', 1, NULL);

INSERT INTO Patch (create_date, deployment_date, status, created_by, approved_by)
VALUES ('2022-02-05', NULL, 'in process', 3, NULL);

INSERT INTO Patch (create_date, deployment_date, status, created_by, approved_by)
VALUES ('2022-03-06', '2022-03-25', 'approved', 2, 1);

----
-- Moduly
----

INSERT INTO Module (name, create_date, author, patch_id)
VALUES ('View component', '2022-04-01', 1, NULL);

INSERT INTO Module (name, create_date, author, patch_id)
VALUES ('Button component', '2022-04-01', 1, 1);

INSERT INTO Module (name, create_date, author, patch_id)
VALUES ('Time library', '2022-04-01', 1, 2);

----
-- Programovací jazyky modulů
----

INSERT INTO Module_prog_langs (module_id, prog_lang_id) VALUES (1, 1);
INSERT INTO Module_prog_langs (module_id, prog_lang_id) VALUES (2, 1);
INSERT INTO Module_prog_langs (module_id, prog_lang_id) VALUES (3, 2);
INSERT INTO Module_prog_langs (module_id, prog_lang_id) VALUES (3, 4);

----
-- Person modules
----

INSERT INTO Person_modules (person_id, module_id) VALUES (2, 1);
INSERT INTO Person_modules (person_id, module_id) VALUES (2, 2);
INSERT INTO Person_modules (person_id, module_id) VALUES (2, 3);

----
-- Tikety
----

INSERT INTO Ticket (name, create_date, status, created_by, patch_id)
VALUES ('Wrong time', '2022-04-02', 'opened', 3, NULL);

INSERT INTO Ticket (name, description, create_date, status, created_by, patch_id)
VALUES ('Button does not showing', '', '2022-04-03', 'closed', 4, 3);

----
-- Bug
----

INSERT INTO Bug (name, description, priority, module_id)
VALUES ('bug no. 1', 'breaks the whole component', 'high', 2);

INSERT INTO Bug (name, priority, module_id)
VALUES ('bug no. 2', 'low', 3);

INSERT INTO Bug (name, priority, module_id)
VALUES ('bug no. 3', 'low', 3);

----
-- Bugy, které jsou obsazeny v Tiketech
----

INSERT INTO Ticket_bugs (ticket_id, bug_id) VALUES (2, 1);
INSERT INTO Ticket_bugs (ticket_id, bug_id) VALUES (1, 2);
INSERT INTO Ticket_bugs (ticket_id, bug_id) VALUES (1, 3);

----
-- Odměny
----

INSERT INTO Reward (amount, person_id) VALUES ('5000', 3);