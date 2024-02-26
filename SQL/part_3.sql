-- noinspection NonAsciiCharactersForFile

/*****************************************
 * @brief 2. časť projektu z predmetu IDS.
 * @author Roman Fulla  <xfulla00>
 * @author Vojtěch Ulej <xulejv00>
 *****************************************/

/**     DROP TABLE      **/

DROP TABLE "Užívateľ"               CASCADE CONSTRAINTS;
DROP TABLE "Interprét"              CASCADE CONSTRAINTS;
DROP TABLE "Album"                  CASCADE CONSTRAINTS;

DROP SEQUENCE "ID udalosti (kombinované)";

DROP TABLE "Ročník festivalu"      CASCADE CONSTRAINTS;
DROP TABLE "Stage"                 CASCADE CONSTRAINTS;
DROP TABLE "Koncert"               CASCADE CONSTRAINTS;
DROP TABLE "Vstupenka na koncert"  CASCADE CONSTRAINTS;
DROP TABLE "Vstupenka na RF"       CASCADE CONSTRAINTS;
DROP TABLE "Žáner"                 CASCADE CONSTRAINTS;

DROP TABLE "Je členom"             CASCADE CONSTRAINTS;
DROP TABLE "Je obľúbený"           CASCADE CONSTRAINTS;
DROP TABLE "Je bežný program"      CASCADE CONSTRAINTS;

DROP TABLE "RF je žánru"           CASCADE CONSTRAINTS;
DROP TABLE "Interprét je žánru"    CASCADE CONSTRAINTS;
DROP TABLE "Album je žánru"        CASCADE CONSTRAINTS;

/**     CREATE TABLE    **/

CREATE TABLE "Užívateľ" (
    "E-mail"              VARCHAR2 (254) PRIMARY KEY CHECK (REGEXP_LIKE("E-mail", '^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,})$')),

    "Meno"                NVARCHAR2 (20),
    "Priezvisko"          NVARCHAR2 (20),
    "Heslo"               CHAR (64) NOT NULL             -- Hash hesla (bezpečnosť)
);

CREATE TABLE "Interprét" (
    "Názov interpréta"    NVARCHAR2 (100) PRIMARY KEY,

    "Dátum vzniku"        DATE
);

CREATE TABLE "Album" (
    "ID albumu"           INTEGER GENERATED ALWAYS AS IDENTITY UNIQUE,
    "Názov albumu"        NVARCHAR2 (100) NOT NULL,

    "Dátum vydania"       DATE,

    "Interprét"           NVARCHAR2 (100) NOT NULL,
    CONSTRAINT "PK Album"
        PRIMARY KEY ("Interprét", "Názov albumu"),
    CONSTRAINT "CK Interprét"                            -- Vydal
        FOREIGN KEY ("Interprét") REFERENCES "Interprét" ("Názov interpréta") ON DELETE CASCADE
);

CREATE SEQUENCE "ID udalosti (kombinované)" START WITH 10000 INCREMENT BY 1;

CREATE TABLE "Ročník festivalu" (
    "ID udalosti"         INTEGER DEFAULT "ID udalosti (kombinované)".NEXTVAL PRIMARY KEY,

    "Dátum a čas konania" DATE NOT NULL,
    "Miesto konania"      NVARCHAR2 (100) NOT NULL,
    "Kapacita udalosti"   INTEGER NOT NULL CHECK ("Kapacita udalosti" > 0),

    "Názov festivalu"     NVARCHAR2 (100) NOT NULL,
    "Číslo ročníka"       INTEGER NOT NULL CHECK ("Číslo ročníka" >= 0),
    "Dĺžka trvania"       INTEGER NOT NULL CHECK ("Dĺžka trvania" > 0 AND "Dĺžka trvania" <= 366)  -- "Dĺžka trvania" > 366 -> nový ročník (potenciálny priestupný rok)
);

CREATE TABLE "Stage" (
    "ID stageu"           INTEGER GENERATED ALWAYS AS IDENTITY UNIQUE,
    "Názov stageu"        NVARCHAR2 (100) NOT NULL,

    "Kapacita publika"    INTEGER CHECK ("Kapacita publika" > 0),
    "Kapacita pódia"      INTEGER CHECK ("Kapacita pódia" > 0),
    "Plocha"              FLOAT CHECK ("Plocha" > 0),    -- m²

    "ID udalosti"         INTEGER NOT NULL,
    CONSTRAINT "PK Stage"
        PRIMARY KEY ("ID udalosti", "Názov stageu"),
    CONSTRAINT "CK Ročník festivalu"
        FOREIGN KEY ("ID udalosti") REFERENCES "Ročník festivalu" ("ID udalosti") ON DELETE CASCADE,

    "Headliner"           NVARCHAR2 (100) NOT NULL,
    CONSTRAINT "CK Headliner"                            -- Hrá ako headliner
        FOREIGN KEY ("Headliner") REFERENCES "Interprét" ("Názov interpréta") ON DELETE CASCADE
);

CREATE TABLE "Koncert" (
    "ID udalosti"         INTEGER DEFAULT "ID udalosti (kombinované)".NEXTVAL PRIMARY KEY,

    "Dátum a čas konania" DATE NOT NULL,
    "Miesto konania"      NVARCHAR2 (100) NOT NULL,
    "Kapacita udalosti"   INTEGER NOT NULL CHECK ("Kapacita udalosti" > 0),

    "Hlavný bod"          NVARCHAR2 (100) NOT NULL,
    CONSTRAINT "CK Hlavný bod"                           -- Hrá ako hlavný bod
        FOREIGN KEY ("Hlavný bod") REFERENCES "Interprét" ("Názov interpréta") ON DELETE CASCADE,

    -- Predskokani --

    "1. predskokan"       NVARCHAR2 (100) DEFAULT NULL,
    CONSTRAINT "CK 1. predskokan"                        -- Hrá ako predskokan
        FOREIGN KEY ("1. predskokan") REFERENCES "Interprét" ("Názov interpréta") ON DELETE SET NULL,
    "2. predskokan"       NVARCHAR2 (100) DEFAULT NULL,
    CONSTRAINT "CK 2. predskokan"                        -- Hrá ako predskokan
        FOREIGN KEY ("2. predskokan") REFERENCES "Interprét" ("Názov interpréta") ON DELETE SET NULL,
    "3. predskokan"       NVARCHAR2 (100) DEFAULT NULL,
    CONSTRAINT "CK 3. predskokan"                        -- Hrá ako predskokan
        FOREIGN KEY ("3. predskokan") REFERENCES "Interprét" ("Názov interpréta") ON DELETE SET NULL
);

CREATE TABLE "Vstupenka na koncert" (
    "ID vstupenky"        INTEGER GENERATED ALWAYS AS IDENTITY UNIQUE,

    "Typ"                 NVARCHAR2 (20) DEFAULT 'Obyčajná',
    "Cena"                NUMBER (9,2) NOT NULL CHECK ("Cena" >= 0),

    "Vlastník"            VARCHAR2 (254) DEFAULT NULL,
    CONSTRAINT "CK Vlastník vstupenky na koncert"          -- Vlastní
        FOREIGN KEY ("Vlastník") REFERENCES "Užívateľ" ("E-mail") ON DELETE SET NULL,

    "ID udalosti"         INTEGER NOT NULL,
    CONSTRAINT "PK Vstupenka na koncert"
        PRIMARY KEY ("ID udalosti", "ID vstupenky"),
    CONSTRAINT "CK ID udalosti (koncert)"                  -- Akceptuje
        FOREIGN KEY ("ID udalosti") REFERENCES "Koncert" ("ID udalosti") ON DELETE CASCADE
);

CREATE TABLE "Vstupenka na RF" (
    "ID vstupenky"        INTEGER GENERATED ALWAYS AS IDENTITY UNIQUE,

    "Typ"                 NVARCHAR2 (20) DEFAULT 'Obyčajná',
    "Cena"                NUMBER (9,2) NOT NULL CHECK ("Cena" >= 0),

    "Vlastník"            VARCHAR2 (254) DEFAULT NULL,
    CONSTRAINT "CK Vlastník vstupenky na RF"               -- Vlastní
        FOREIGN KEY ("Vlastník") REFERENCES "Užívateľ" ("E-mail") ON DELETE SET NULL,

    "ID udalosti"         INTEGER NOT NULL,
    CONSTRAINT "PK Vstupenka na RF"
        PRIMARY KEY ("ID udalosti", "ID vstupenky"),
    CONSTRAINT "CK ID udalosti (RF)"                       -- Akceptuje
        FOREIGN KEY ("ID udalosti") REFERENCES "Ročník festivalu" ("ID udalosti") ON DELETE CASCADE
);

CREATE TABLE "Žáner" (
    "Názov žánru"         NVARCHAR2 (25) PRIMARY KEY
);

/**  N ku N vazby  **/

CREATE TABLE "Je členom" (
    "Názov interpréta"    NVARCHAR2 (100) NOT NULL,
    "Názov skupiny"       NVARCHAR2 (100) NOT NULL,
    CONSTRAINT "PK Je členom"
        PRIMARY KEY ("Názov skupiny", "Názov interpréta"),
    CONSTRAINT "CK Názov interpréta (členstvo)"
        FOREIGN KEY ("Názov interpréta") REFERENCES "Interprét" ("Názov interpréta") ON DELETE CASCADE,
    CONSTRAINT "CK Názov skupiny"
        FOREIGN KEY ("Názov skupiny") REFERENCES "Interprét" ("Názov interpréta") ON DELETE CASCADE
);

CREATE TABLE "Je obľúbený" (
    "Názov interpréta"    NVARCHAR2 (100) NOT NULL,
    "Užívateľ"            VARCHAR2 (254) NOT NULL,
    CONSTRAINT "PK Je obľúbený"
        PRIMARY KEY ("Názov interpréta", "Užívateľ"),
    CONSTRAINT "CK Užívateľ"
        FOREIGN KEY ("Užívateľ") REFERENCES "Užívateľ" ("E-mail") ON DELETE CASCADE,
    CONSTRAINT "CK Názov interpréta (obľúbenosť)"
        FOREIGN KEY ("Názov interpréta") REFERENCES "Interprét" ("Názov interpréta") ON DELETE CASCADE
);

CREATE TABLE "Je bežný program" (
    "Názov interpréta"    NVARCHAR2 (100) NOT NULL,
    "ID stageu"           INTEGER,
    CONSTRAINT "PK Je bežný program"
        PRIMARY KEY ("Názov interpréta", "ID stageu"),
    CONSTRAINT "CK Názov stageu"
        FOREIGN KEY ("ID stageu") REFERENCES "Stage" ("ID stageu") ON DELETE CASCADE,
    CONSTRAINT "CK Názov interpréta (bežný program)"
        FOREIGN KEY ("Názov interpréta") REFERENCES "Interprét" ("Názov interpréta") ON DELETE CASCADE
);

CREATE TABLE "RF je žánru" (
    "ID festivalu"        INTEGER NOT NULL,
    "Názov žánru"         NVARCHAR2 (25) NOT NULL,
    CONSTRAINT "PK RF je žánru"
        PRIMARY KEY ("ID festivalu", "Názov žánru"),
    CONSTRAINT "CK Názov žánru (RF)"
        FOREIGN KEY ("Názov žánru") REFERENCES "Žáner" ("Názov žánru") ON DELETE CASCADE,
    CONSTRAINT "CK ID festivalu"
        FOREIGN KEY ("ID festivalu") REFERENCES "Ročník festivalu" ("ID udalosti") ON DELETE CASCADE
);

CREATE TABLE "Interprét je žánru" (
    "Názov interpréta"    NVARCHAR2 (100) NOT NULL,
    "Názov žánru"         NVARCHAR2 (25) NOT NULL,
    CONSTRAINT "PK Interprét je žánru"
        PRIMARY KEY ("Názov interpréta", "Názov žánru"),
    CONSTRAINT "CK Názov žánru (interprét)"
        FOREIGN KEY ("Názov žánru") REFERENCES "Žáner" ("Názov žánru") ON DELETE CASCADE,
    CONSTRAINT "CK Názov interpréta (žáner)"
        FOREIGN KEY ("Názov interpréta") REFERENCES "Interprét" ("Názov interpréta") ON DELETE CASCADE
);

CREATE TABLE "Album je žánru" (
    "ID albumu"           INTEGER,
    "Názov žánru"         NVARCHAR2 (25) NOT NULL,
    CONSTRAINT "PK Album je žánru"
        PRIMARY KEY ("ID albumu", "Názov žánru"),
    CONSTRAINT "CK Názov žánru (album)"
        FOREIGN KEY ("Názov žánru") REFERENCES "Žáner" ("Názov žánru") ON DELETE CASCADE,
    CONSTRAINT "CK ID albumu"
        FOREIGN KEY ("ID albumu") REFERENCES "Album" ("ID albumu") ON DELETE CASCADE
);

/**        INSERT       **/

-- Užívatelia --

INSERT INTO "Užívateľ"
("E-mail", "Meno", "Priezvisko", "Heslo")
VALUES
('jan.novak@gmail.com', 'Jan', 'Novák', '9e6c0c1db1e0dfb3fa5159deb4ecd9715b3c8cd6b06bd4a3ad77e9a8c5694219');

INSERT INTO "Užívateľ"
("E-mail", "Meno", "Priezvisko", "Heslo")
VALUES
('picek12345@seznam.cz', 'Marek', 'Picek', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f');

INSERT INTO "Užívateľ"
("E-mail", "Meno", "Priezvisko", "Heslo")
VALUES
('alenka42@centrum.sk', 'Alena', 'Čierna', '7a98a391f2072313e0dcfbfa151ae2c0405210694324607e41e35e8d9bce9472');

-- Interpréti --

INSERT INTO "Interprét"                             -- Kapela
("Názov interpréta", "Dátum vzniku")
VALUES
('Rammstein', TO_DATE('01/1994', 'MM/YYYY'));

INSERT INTO "Interprét"
("Názov interpréta", "Dátum vzniku")
VALUES
('Till Lindemann', TO_DATE('04/01/1963', 'DD/MM/YYYY'));

INSERT INTO "Interprét"                             -- Kapela
("Názov interpréta", "Dátum vzniku")
VALUES
('Sabaton', TO_DATE('12/1999', 'MM/YYYY'));

INSERT INTO "Interprét"                             -- Kapela
("Názov interpréta", "Dátum vzniku")
VALUES
('Hollywood Vampires', TO_DATE('2015', 'YYYY'));

INSERT INTO "Interprét"                             -- Kapela
("Názov interpréta", "Dátum vzniku")
VALUES
('Aerosmith', TO_DATE('11/1970', 'MM/YYYY'));

INSERT INTO "Interprét"
("Názov interpréta", "Dátum vzniku")
VALUES
('Alice Cooper', TO_DATE('04/02/1948', 'DD/MM/YYYY'));

INSERT INTO "Interprét"
("Názov interpréta", "Dátum vzniku")
VALUES
('Johnny Depp', TO_DATE('09/06/1963', 'DD/MM/YYYY'));

INSERT INTO "Interprét"
("Názov interpréta", "Dátum vzniku")
VALUES
('Joe Perry', TO_DATE('10/09/1950', 'DD/MM/YYYY'));

-- Členstvá --

INSERT INTO "Je členom"
("Názov interpréta", "Názov skupiny")
VALUES
('Joe Perry', 'Aerosmith');

INSERT INTO "Je členom"
("Názov interpréta", "Názov skupiny")
VALUES
('Till Lindemann', 'Rammstein');

INSERT INTO "Je členom"
("Názov interpréta", "Názov skupiny")
VALUES
('Alice Cooper', 'Hollywood Vampires');

INSERT INTO "Je členom"
("Názov interpréta", "Názov skupiny")
VALUES
('Johnny Depp', 'Hollywood Vampires');

INSERT INTO "Je členom"
("Názov interpréta", "Názov skupiny")
VALUES
('Joe Perry', 'Hollywood Vampires');

-- Obľúbenosť --

INSERT INTO "Je obľúbený"
("Názov interpréta", "Užívateľ")
VALUES
('Rammstein', 'jan.novak@gmail.com');

INSERT INTO "Je obľúbený"
("Názov interpréta", "Užívateľ")
VALUES
('Till Lindemann', 'jan.novak@gmail.com');

INSERT INTO "Je obľúbený"
("Názov interpréta", "Užívateľ")
VALUES
('Aerosmith', 'alenka42@centrum.sk');

INSERT INTO "Je obľúbený"
("Názov interpréta", "Užívateľ")
VALUES
('Rammstein', 'alenka42@centrum.sk');

-- Albumy --

INSERT INTO "Album"
("Interprét", "Názov albumu", "Dátum vydania")
VALUES
('Rammstein', 'Sehnsucht', TO_DATE('25/08/1997', 'DD/MM/YYYY'));

INSERT INTO "Album"
("Interprét", "Názov albumu", "Dátum vydania")
VALUES
('Rammstein', 'Reise, Reise', TO_DATE('27/09/2004', 'DD/MM/YYYY'));

INSERT INTO "Album"
("Interprét", "Názov albumu", "Dátum vydania")
VALUES
('Rammstein', 'Untitled', TO_DATE('17/05/2019', 'DD/MM/YYYY'));

INSERT INTO "Album"
("Interprét", "Názov albumu", "Dátum vydania")
VALUES
('Sabaton', 'The Great War', TO_DATE('19/07/2019', 'DD/MM/YYYY'));

-- Festivaly --

INSERT INTO "Ročník festivalu"
("Miesto konania", "Dátum a čas konania", "Kapacita udalosti", "Názov festivalu", "Číslo ročníka", "Dĺžka trvania")
VALUES
('Hradec Králové', TO_DATE('14:00 18/06/2020', 'HH24:MI DD/MM/YYYY'), 30000, 'Rock for People', 26, 3);

INSERT INTO "Ročník festivalu"
("Miesto konania", "Dátum a čas konania", "Kapacita udalosti", "Názov festivalu", "Číslo ročníka", "Dĺžka trvania")
VALUES
('Ostrava', TO_DATE('12:00 15/07/2020', 'HH24:MI DD/MM/YYYY'), 50000, 'Colours of Ostrava', 19, 4);

INSERT INTO "Ročník festivalu"
("Miesto konania", "Dátum a čas konania", "Kapacita udalosti", "Názov festivalu", "Číslo ročníka", "Dĺžka trvania")
VALUES
('Hradec Králové', TO_DATE('16:00 17/06/2021', 'HH24:MI DD/MM/YYYY'), 35000, 'Rock for People', 27, 4);

-- Stage --

INSERT INTO "Stage"
("Názov stageu", "Kapacita publika", "Kapacita pódia", "Plocha", "ID udalosti", "Headliner")
VALUES
(
 'Hlavný stage', 15000, 5, 20.4,
 (SELECT "ID udalosti" FROM "Ročník festivalu" WHERE "Názov festivalu" = 'Rock for People' AND "Číslo ročníka" = 26),
 'Aerosmith'
);

-- Bežný program stageu --

INSERT INTO "Je bežný program"
("Názov interpréta", "ID stageu")
VALUES
('Till Lindemann', (SELECT "ID stageu" FROM "Stage" WHERE "Názov stageu" = 'Hlavný stage'));

-- Koncerty --

INSERT INTO "Koncert"
("Hlavný bod", "Dátum a čas konania", "Miesto konania", "Kapacita udalosti", "1. predskokan")
VALUES
('Rammstein', TO_DATE('20:00 13/11/2020','HH24:MI DD/MM/YYYY'), 'Brno Bobby Hall', 8000, 'Aerosmith');

INSERT INTO "Koncert"
("Hlavný bod", "Dátum a čas konania", "Miesto konania", "Kapacita udalosti", "1. predskokan", "2. predskokan")
VALUES
('Rammstein', TO_DATE('20:00 14/11/2020','HH24:MI DD/MM/YYYY'), 'O2 Arena Praha', 18000, 'Aerosmith', 'Alice Cooper');

INSERT INTO "Koncert"
("Hlavný bod", "Dátum a čas konania", "Miesto konania", "Kapacita udalosti", "1. predskokan")
VALUES
('Hollywood Vampires', TO_DATE('18:00 18/02/2021','HH24:MI DD/MM/YYYY'), 'O2 Arena Praha', 18000, 'Till Lindemann');

-- Vstupenky --

INSERT INTO "Vstupenka na koncert"
("Cena", "ID udalosti")
VALUES
(35.5, (SELECT "ID udalosti" FROM "Koncert" WHERE "Hlavný bod" = 'Rammstein' AND "Dátum a čas konania" = TO_DATE('20:00 13/11/2020','HH24:MI DD/MM/YYYY')));

INSERT INTO "Vstupenka na RF"
("Cena", "ID udalosti")
VALUES
(70, (SELECT "ID udalosti" FROM "Ročník festivalu" WHERE "Miesto konania" = 'Hradec Králové' AND "Dátum a čas konania" = TO_DATE('14:00 18/06/2020', 'HH24:MI DD/MM/YYYY')));

INSERT INTO "Vstupenka na koncert"
("Cena", "ID udalosti", "Typ", "Vlastník")
VALUES
(150, (SELECT "ID udalosti" FROM "Koncert" WHERE "Hlavný bod" = 'Rammstein' AND "Dátum a čas konania" = TO_DATE('20:00 13/11/2020','HH24:MI DD/MM/YYYY')), 'VIP', 'jan.novak@gmail.com');

-- Žánre --

INSERT INTO "Žáner"
("Názov žánru")
VALUES
('Metal');

INSERT INTO "Žáner"
("Názov žánru")
VALUES
('Rock');

INSERT INTO "Žáner"
("Názov žánru")
VALUES
('Power metal');

INSERT INTO "Žáner"
("Názov žánru")
VALUES
('Industriálny metal');

-- Žánre RF --

INSERT INTO "RF je žánru"
("ID festivalu", "Názov žánru")
VALUES
((SELECT "ID udalosti" FROM "Ročník festivalu" WHERE "Názov festivalu" = 'Rock for People' AND "Číslo ročníka" = 26), 'Rock');

-- Žánre interprétov --

INSERT INTO "Interprét je žánru"
("Názov interpréta", "Názov žánru")
VALUES
('Rammstein', 'Industriálny metal');

INSERT INTO "Interprét je žánru"
("Názov interpréta", "Názov žánru")
VALUES
('Sabaton', 'Metal');

INSERT INTO "Interprét je žánru"
("Názov interpréta", "Názov žánru")
VALUES
('Sabaton', 'Power metal');

INSERT INTO "Interprét je žánru"
("Názov interpréta", "Názov žánru")
VALUES
('Hollywood Vampires', 'Rock');

-- Žánre albumov --

INSERT INTO "Album je žánru"
("ID albumu", "Názov žánru")
VALUES
((SELECT "ID albumu" FROM "Album" WHERE "Názov albumu" = 'The Great War'), 'Power metal');

/**        SELECT       **/

-- Dve otázky využívajúce spojenie dvoch tabuliek:

-- Všetky albumy interpréta Rammstein
SELECT "Interprét"."Názov interpréta", "Album"."Názov albumu"
FROM "Interprét"
INNER JOIN "Album"
ON "Interprét"."Názov interpréta" = "Album"."Interprét"
WHERE "Názov interpréta" = 'Rammstein';

-- Všetky koncerty interpréta Rammstein
SELECT "Interprét"."Názov interpréta", "Koncert"."Miesto konania", "Koncert"."Dátum a čas konania"
FROM "Interprét"
INNER JOIN "Koncert"
ON "Interprét"."Názov interpréta" = "Koncert"."Hlavný bod"
WHERE "Názov interpréta" = 'Rammstein';

-- Jedna otázka využívajúca spojenie troch tabuliek:

-- Kto je headliner Hlavného stageu na 26. ročníku festivalu Rock for People
SELECT "Interprét"."Názov interpréta", "Stage"."Názov stageu", "Ročník festivalu"."Názov festivalu", "Ročník festivalu"."Číslo ročníka"
FROM "Interprét"
INNER JOIN "Stage"
ON "Stage"."Headliner" = "Interprét"."Názov interpréta"
INNER JOIN "Ročník festivalu"
ON "Ročník festivalu"."ID udalosti" = "Stage"."ID udalosti"
WHERE "Názov stageu" = 'Hlavný stage'
AND "Názov festivalu" = 'Rock for People'
AND "Číslo ročníka" = 26;

-- Dve otázky s klauzulou GROUP BY a agregačnou funkciou:

-- Koľko je ročníkov rôznych festivalov
SELECT COUNT("ID udalosti"), "Názov festivalu"
FROM "Ročník festivalu"
GROUP BY "Názov festivalu";

-- Počet albumov od interpréta Rammstein
SELECT COUNT("ID albumu"), "Interprét"
FROM "Album"
WHERE "Interprét" = 'Rammstein'
GROUP BY "Interprét";

-- Jedna otázka obsahujúca predikát EXISTS:

-- Kapely v databáze (nie jednotlivci)
SELECT "Názov interpréta"
FROM "Interprét"
WHERE EXISTS (SELECT * FROM "Je členom" WHERE "Interprét"."Názov interpréta" = "Názov skupiny");

-- Jedna otázka s prediktátom IN s vnoreným selectom:

-- Všetci obľúbený interpréti užívateľa s emailom jan.novak@gmail.com
SELECT "Názov interpréta"
FROM "Interprét"
WHERE "Názov interpréta" IN (SELECT "Názov interpréta" FROM "Je obľúbený" WHERE "Užívateľ" = 'jan.novak@gmail.com');
