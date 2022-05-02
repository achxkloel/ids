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
DROP PROCEDURE add_reward;

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
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(255) NOT NULL
        CHECK(REGEXP_LIKE(
			phone, '^(\+\d{1,4}\s)?\d{3}\s?\d{3}\s?\d{3}$', 'i'
		)),
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
    created_by INT DEFAULT NULL,
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
    patch_id INT DEFAULT NULL,
    bugs_count INT DEFAULT NULL
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
    created_by INT DEFAULT NULL,
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
    prog_lang_id INT NOT NULL,
    PRIMARY KEY (person_id, prog_lang_id)
);

----
-- Module_prog_langs
--
-- Reprezentuje vazbu mezi Modulem a Programovacím jazykem.
----
CREATE TABLE Module_prog_langs (
    module_id INT NOT NULL,
    prog_lang_id INT NOT NULL,
    PRIMARY KEY (module_id, prog_lang_id)
);

----
-- Person_modules
--
-- Reprezentuje vazbu mezi Uživatelem a Modulem.
----
CREATE TABLE Person_modules (
    person_id INT NOT NULL,
    module_id INT NOT NULL,
    PRIMARY KEY (person_id, module_id)
);

----
-- Ticket_bugs
--
-- Reprezentuje vazbu mezi Tiketem a Bugem.
----
CREATE TABLE Ticket_bugs (
    ticket_id INT NOT NULL,
    bug_id INT NOT NULL,
    PRIMARY KEY (ticket_id, bug_id)
);

CREATE TABLE Module_wrong_access_log (
    id GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    create_date VARCHAR(255) NOT NULL,
    person_id INT NOT NULL,
    module_id INT NOT NULL
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

ALTER TABLE Module_wrong_access_log ADD CONSTRAINT module_wrong_access_log_person_modules_fk
    FOREIGN KEY (person_id, module_id) REFERENCES Person_modules(person_id, module_id)
    ON DELETE CASCADE;

-- =============================
-- DATABÁZOVÉ TRIGGERY
-- =============================

-- Trigger, který při vytvoření nového bugu inkrementuje počítadlo bugů v jednotlivých modulech.
CREATE OR REPLACE TRIGGER bugs_in_module_count
    AFTER INSERT OR DELETE ON Bug
    REFERENCING OLD AS deleted NEW AS inserted
    FOR EACH ROW
BEGIN
    IF INSERTING THEN
        UPDATE Module M SET bugs_count = bugs_count + 1
        WHERE M.id = :inserted.module_id;
    ELSIF DELETING THEN
        UPDATE Module M SET bugs_count = bugs_count - 1
        WHERE M.id = :deleted.module_id;
    END IF;
END;
/

----
-- Triger, který při vytvoření nebo změně vazby mezi uživatelem a modulem
-- zkontroluje role uživatele a v připadě chyby přístupu zapíše tuto informaci
-- do přislušné tabulky.
----
CREATE OR REPLACE TRIGGER person_module_access
    AFTER INSERT OR UPDATE OF person_id ON Person_modules
    FOR EACH ROW
DECLARE
    user_role_cnt NUMBER;
    wrong_access EXCEPTION;
BEGIN
    SELECT COUNT(*)
    INTO user_role_cnt
    FROM Person P
    WHERE P.id = NEW.person_id AND P.role = 'user';

    IF user_role_cnt > 0 THEN
        RAISE wrong_access;
    END IF;
EXCEPTION
    WHEN wrong_access THEN
        INSERT INTO Module_wrong_access_log (create_date, person_id, module_id)
        VALUES (TO_CHAR(sysdate, 'YYYY-MM-DD'), NEW.person_id, NEW.module_id);
END;
/

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
INSERT INTO Person_prog_langs (person_id, prog_lang_id) VALUES (4, 2);
INSERT INTO Person_prog_langs (person_id, prog_lang_id) VALUES (2, 2);

----
-- Patche
----

INSERT INTO Patch (create_date, deployment_date, status, created_by, approved_by)
VALUES ('2022-01-05', NULL, 'in process', 1, NULL);

INSERT INTO Patch (create_date, deployment_date, status, created_by, approved_by)
VALUES ('2022-02-05', NULL, 'in process', 3, NULL);

INSERT INTO Patch (create_date, deployment_date, status, created_by, approved_by)
VALUES ('2022-03-06', '2022-03-25', 'approved', 2, 1);

INSERT INTO Patch (create_date, deployment_date, status, created_by, approved_by)
VALUES ('2022-02-11', '2022-03-12', 'approved', 3, 2);

----
-- Moduly
----

INSERT INTO Module (name, create_date, author, patch_id, bugs_count)
VALUES ('View component', '2022-04-01', 1, NULL, 0);

INSERT INTO Module (name, create_date, author, patch_id, bugs_count)
VALUES ('Button component', '2022-04-01', 1, 1, 0);

INSERT INTO Module (name, create_date, author, patch_id, bugs_count)
VALUES ('Time library', '2022-04-01', 1, 2, 0);

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
VALUES ('Wrong time', '2022-04-02', 'closed', 3, 4);

INSERT INTO Ticket (name, create_date, status, created_by, patch_id)
VALUES ('Wrong spelling', '2022-04-02', 'opened', 3, NULL);

INSERT INTO Ticket (name, description, create_date, status, created_by, patch_id)
VALUES ('Button is not showing up', '', '2022-04-03', 'closed', 4, 3);

INSERT INTO Ticket (name, description, create_date, status, created_by, patch_id)
VALUES ('System is crashing', '', '2022-04-15', 'opened', 1, NULL);

INSERT INTO Ticket (name, description, create_date, status, created_by, patch_id)
VALUES ('Division by zero', '', '2022-01-26', 'opened', 1, NULL);

INSERT INTO Ticket (name, description, create_date, status, created_by, patch_id)
VALUES ('Web page is not showing up', '', '2022-03-15', 'opened', 2, NULL);

----
-- Bug
----

INSERT INTO Bug (name, description, priority, module_id)
VALUES ('bug no. 1', 'breaks the whole component', 'high', 2);

INSERT INTO Bug (name, priority, module_id)
VALUES ('bug no. 2', 'low', 3);

INSERT INTO Bug (name, priority, module_id)
VALUES ('bug no. 3', 'low', 3);

INSERT INTO Bug (name, priority, module_id)
VALUES ('bug no. 4', 'high', 3);

INSERT INTO Bug (name, priority, module_id)
VALUES ('bug no. 5', 'low', 1);

INSERT INTO Bug (name, priority, module_id)
VALUES ('bug no. 6', 'low', 3);

INSERT INTO Bug (name, priority, module_id)
VALUES ('bug no. 7', 'low', 1);

INSERT INTO Bug (name, priority, module_id)
VALUES ('bug no. 8', 'low', 1);

INSERT INTO Bug (name, priority, module_id)
VALUES ('bug no. 9', 'low', 1);

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
INSERT INTO Reward (amount, person_id) VALUES ('16000', 3);
INSERT INTO Reward (amount, person_id) VALUES ('20000', 2);
INSERT INTO Reward (amount, person_id) VALUES ('5000', 1);

-- =============================
-- SELECT DOTAZY
-- =============================

----
-- Kteří uživatelé disponují programovacím jazykem C++? (login, first_name, second_name, role, position)
----

SELECT
    login,
    first_name,
    second_name,
    role,
    position
FROM
    Person_prog_langs PPL
    JOIN Person P ON PPL.person_id = P.id
    JOIN Prog_lang PL ON PPL.prog_lang_id = PL.id
WHERE
    PL.name = 'C++';

----
-- Které moduly obsahují více než 3 bugy? (name, pocet_bugu)
-- Seřazeno sestupně podle počtu bugů.
----

SELECT
    M.name,
    COUNT(*) pocet_bugu
FROM
    Module M
    JOIN Bug B ON M.id = B.module_id
GROUP BY
    M.name
HAVING
    COUNT(*) > 3
ORDER BY
    pocet_bugu DESC;

----
-- Kteří programátoři (muži) vytvářeli tikety pouze v roce 2022? (login, first_name, second_name, pocet_tiketu)
----

WITH person_id_list AS (
    SELECT
        id,
        login,
        first_name,
        second_name
    FROM
        Person P
    WHERE
        P.sex = 'M'
        AND P.role = 'programmer'
    AND NOT EXISTS (
        SELECT * FROM
            Ticket T
        WHERE
            P.id = T.created_by
            AND TO_DATE(create_date, 'YYYY-MM-DD') NOT BETWEEN
                TO_DATE('2022-01-01', 'YYYY-MM-DD') AND
                TO_DATE('2022-12-31', 'YYYY-MM-DD')
    )
)
SELECT
      IDList.login,
      IDList.first_name,
      IDList.second_name,
      COUNT(*) pocet_tiketu
FROM
    Ticket T
    JOIN person_id_list IDList ON T.created_by = IDList.id
GROUP BY (
    IDList.login, IDList.first_name, IDList.second_name
);

----
-- Kteří uživatelé dostali více než 10000 Kč za celou dobu? (login, celkova_castka)
----

SELECT
    login,
    SUM(amount) celkova_castka
FROM
    Person P
    JOIN Reward R ON P.id = R.person_id
GROUP BY
    login
HAVING
    SUM(amount) > 10000;

----
-- Které moduly obsahují bugy s vysokou prioritou? (id, jmeno)
----
SELECT
    M.id,
    M.name
FROM
    Module M
    JOIN Bug B ON M.id = B.module_id
WHERE
    priority = 'high';

----
-- Kteří uživatelé vytvořili více než jeden patch? (id, jmeno, prijmeni, pocet_patchu)
----
SELECT
    Pe.id,
    first_name,
    second_name,
    COUNT(Pa.id) pocet_patchu
FROM
    Patch Pa
    JOIN Person Pe ON Pa.created_by = Pe.id
HAVING
    COUNT(Pa.id) > 1
GROUP BY
    Pe.id,
    first_name,
    second_name;

----
-- Kteří uživatelé vytvořili některý modul? (id, jmeno, prijmeni)
----
SELECT
    id,
    first_name,
    second_name
FROM
    Person P
WHERE
    P.id
IN (
    SELECT author FROM Module GROUP BY author
);

----
-- Který patch vyřešil tikety s největším počtem bugů? Může být více Patchů se stejným počtem bugů. (id_patche, author_jmeno, author_prijmeni, pocet_bugu)
----
SELECT
    id id_patche,
    first_name,
    second_name,
    MAX(bugu) pocet_bugu
FROM (
    SELECT
        P.id,
        Pe.first_name,
        Pe.second_name,
        COUNT(T.id) bugu
    FROM
        Ticket T
        JOIN Ticket_bugs Tb on T.id = Tb.ticket_id
        JOIN Bug B on Tb.bug_id = B.id
        JOIN Patch P on P.id = T.patch_id
        JOIN Person Pe on P.created_by = Pe.id
    GROUP BY
        P.id,
        Pe.first_name,
        Pe.second_name
)
GROUP BY
    id,
    first_name,
    second_name;

-- =============================
-- PROCEDURY
-- =============================

-- Procedura, která přidá vybranou odměnu každému uživateli, který vytvořil Patch, který byl schválen.

CREATE OR REPLACE PROCEDURE add_reward (reward_to_employee NUMBER) AS
    C_id Patch.created_by%type;
    CURSOR C IS
        SELECT created_by FROM Patch WHERE (status = 'approved');
    BEGIN
        OPEN C;
        LOOP
            FETCH C INTO C_id;
            EXIT WHEN C%NOTFOUND;
            INSERT INTO Reward (amount, person_id) VALUES (add_reward.reward_to_employee, C_id);
        END LOOP;
        CLOSE C;
    END add_reward;

BEGIN
    add_reward(1000);
END;
