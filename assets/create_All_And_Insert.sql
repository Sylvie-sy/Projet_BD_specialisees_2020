-------------------------
-- 01 creer les tables --
-------------------------
DROP TABLE IF EXISTS bai.Cinema CASCADE;
DROP TABLE IF EXISTS bai.Programmateur CASCADE;
DROP TABLE IF EXISTS bai.Departement CASCADE;
DROP TABLE IF EXISTS bai.Ville CASCADE;
DROP TABLE IF EXISTS bai.Festival CASCADE;
DROP TABLE IF EXISTS bai.Utilisateur CASCADE;
DROP TABLE IF EXISTS bai.Investissement CASCADE;
-- DROP SCHEMA IF EXISTS bai CASCADE;

-- CREATE SCHEMA bai;

CREATE TABLE bai.Utilisateur(
	nom VARCHAR(50),
	e_mail VARCHAR(150) UNIQUE,
	telephone INTEGER,
	mot_de_pass VARCHAR(50) NOT NULL,
	level INTEGER,
	solde NUMERIC CONSTRAINT solde_positif CHECK (solde>=0),
	mise_de_fonds NUMERIC CONSTRAINT fond_positif CHECK (mise_de_fonds >=0),
	derniere_connection TIMESTAMP,
	PRIMARY KEY (nom, e_mail)
);

CREATE TABLE bai.Programmateur(
	programmateur VARCHAR PRIMARY KEY,
	chiffre_affaire INTEGER,
	profit INTEGER,
	nb_employes INTEGER,
	nb_cinema INTEGER
);

CREATE TABLE bai.Ville(
	unite_urbaine VARCHAR(30) PRIMARY KEY,
	population NUMERIC CONSTRAINT population_positif CHECK (population>0),
	loyer NUMERIC CONSTRAINT loyer_positif CHECK (loyer > 0)
);

CREATE TABLE bai.Departement(
	dep INTEGER PRIMARY KEY,
	unite_urbaine VARCHAR(30) NOT NULL,
	FOREIGN KEY (unite_urbaine) REFERENCES bai.Ville ON UPDATE CASCADE
);

CREATE TABLE bai.Cinema(
	n_auto INTEGER PRIMARY KEY,
	nom VARCHAR,
	adresse VARCHAR,
	unite_urbaine VARCHAR(30),
	ecrans INTEGER,
	fauteuils INTEGER,
	seances INTEGER,
	entre_2018 INTEGER,
	evolution_entre VARCHAR,
	programmateur VARCHAR,
	nb_film_programme INTEGER,
	nb_film_indedits INTEGER,
	pdm_fr REAL,
	pdm_us REAL,
	pdm_eu REAL,
	pdm_autre REAL,
	film_art_essai INTEGER,
	UNIQUE (n_auto, nom, adresse),
	--FOREIGN KEY (programmateur) REFERENCES bai.Programmateur(programmateur) ON UPDATE CASCADE,
	FOREIGN KEY (unite_urbaine) REFERENCES bai.Ville(unite_urbaine) ON UPDATE CASCADE,
	CONSTRAINT film_programme CHECK(nb_film_programme > nb_film_indedits),
	CONSTRAINT pdm_somme_101 CHECK(pdm_fr+pdm_us+pdm_eu+pdm_autre <= 101)
);

CREATE TABLE bai.Festival(
	programmateur VARCHAR NOT NULL, 
	nom VARCHAR(150) NOT NULL,
	debut TIMESTAMP,
	fin TIMESTAMP,
	PRIMARY KEY (programmateur, nom),
	CONSTRAINT debuf_fin CHECK (debut <= fin)
);

CREATE TABLE bai.Investissement(
	nom VARCHAR(50),
	e_mail VARCHAR(150),
	programmateur VARCHAR(30),
	n_auto INTEGER,
	montant NUMERIC CONSTRAINT montant_positif CHECK (montant>0),
	time TIMESTAMP,
	PRIMARY KEY (nom, e_mail, time),
	FOREIGN KEY (n_auto) REFERENCES bai.Cinema(n_auto),
	FOREIGN KEY (nom, e_mail) REFERENCES bai.Utilisateur(nom, e_mail),
	FOREIGN KEY (programmateur) REFERENCES bai.Programmateur(programmateur) 
);

--------------------
-- 02 Insert Data --
--------------------

-- selon pwd, on trouve le path de les fichiers
\set programmateur_path `pwd`'/source/programmateur.csv'
\set ville_path `pwd`'/source/ville.csv'
\set cinema_path `pwd`'/source/cinema.csv'
\set festival_path `pwd`'/source/festival.csv'

\COPY bai.Programmateur FROM '/info/nouveaux/bai/BD_projet/source/programmateur.csv' WITH DELIMITER ',' CSV HEADER;
\COPY bai.Ville FROM  '/info/nouveaux/bai/BD_projet/source/ville.csv' DELIMITER ',' CSV HEADER;
\COPY bai.Cinema FROM '/info/nouveaux/bai/BD_projet/source/cinema.csv'  DELIMITER ',' CSV HEADER;
\COPY bai.Festival FROM '/info/nouveaux/bai/BD_projet/source/festival.csv'  DELIMITER ',' CSV HEADER;

INSERT INTO bai.Utilisateur VALUES('admin','admin@hotmail.com','012345678','admin','10','1000000','0','2020-05-15 10:25:30');
INSERT INTO bai.Utilisateur VALUES('shiying','shiying@hotmail.com','01111111','abc','10','1000000','500','2020-05-18 11:15:20');
INSERT INTO bai.Utilisateur VALUES('yuchen','yuchen@hotmail.com','02222222','abc','10','1000000','0','2020-05-25 16:05:50');

INSERT INTO bai.Investissement VALUES('shiying','shiying@hotmail.com','UGC','31', '500',NOW());

--------------------------
-- 03 Grant les droites --
--------------------------

-- GRANT USAGE ON SCHEMA bai to PUBLIC;
-- GRANT SELECT ON ALL TABLES IN SCHEMA bai to PUBLIC;
-- GRANT INSERT ON ALL TABLES IN SCHEMA bai to PUBLIC;

--------------------
-- 04 search path --
--------------------

--set search_path
SHOW search_path;
-- ici, 'bai' est mon login, vous devez le remplacer par votre
-- SET search_path TO bai,bai;

