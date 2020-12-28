--------------
-- Triggers --
--------------

--(01) Si on enlève un programmateur dans la table programmateur, alors on enlèvre tous les cinéma qui sont dans la table cinema

DROP FUNCTION IF EXISTS enleve_programmateur();
DROP TRIGGER IF EXISTS trig_enleve_programmteur ON programmateur;

CREATE OR REPLACE FUNCTION enleve_programmateur() RETURNS TRIGGER AS $$
BEGIN
	RAISE NOTICE '-> commencer à enlever programmateur: %', OLD.programmateur;
	DELETE FROM cinema
	WHERE cinema.programmateur = OLD.programmateur;
	RAISE NOTICE '-> programmateur: % est enlevé', OLD.programmateur;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_enleve_programmteur
AFTER DELETE ON programmateur
FOR EACH ROW
EXECUTE PROCEDURE enleve_programmateur();

--(02) Soit la population de une ville est plus petite que 200, on ne compte pas comme une ville intéressante

DROP FUNCTION IF EXISTS empeche_insert_updata_ville();
DROP TRIGGER IF EXISTS trig_vill_popullation ON ville;

CREATE OR REPLACE FUNCTION empeche_insert_updata_ville() RETURNS TRIGGER AS $$
BEGIN
	RAISE NOTICE '--> La population est trop petite';
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_vill_popullation
BEFORE INSERT OR UPDATE ON ville 
FOR EACH ROW
WHEN (NEW.population < 200)
EXECUTE PROCEDURE empeche_insert_updata_ville();	

--(03) Après chaque insertion ou update ou delete, on met à jour automatique lent la table programmateur le nombre de cinémas.

DROP FUNCTION IF EXISTS cinema_prog_insert();
DROP FUNCTION IF EXISTS cinema_prog_delete();
DROP FUNCTION IF EXISTS cinema_prog_update();

DROP TRIGGER IF EXISTS trig_auto_prog_cinema_nb_insert ON cinema;
DROP TRIGGER IF EXISTS trig_auto_prog_cinema_nb_delete ON cinema;
DROP TRIGGER IF EXISTS trig_auto_prog_cinema_nb_update ON cinema;

--insert into cinema un row
CREATE OR REPLACE FUNCTION cinema_prog_insert() RETURNS TRIGGER AS $$
DECLARE 
	ligne programmateur%ROWTYPE;
BEGIN
	SELECT * INTO ligne FROM programmateur WHERE programmateur.programmateur = NEW.programmateur;
	IF ligne IS NULL THEN 
		RAISE NOTICE  'Can not INSERT, Nouvelle programmateur : % ', NEW.programmateur;
	ELSIF ligne.nb_cinema >= 0 THEN
		UPDATE programmateur SET nb_cinema = nb_cinema + 1 WHERE programmateur.programmateur = NEW.programmateur;
	END IF;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trig_auto_prog_cinema_nb_insert
AFTER INSERT ON cinema 
FOR EACH ROW
EXECUTE PROCEDURE cinema_prog_insert();

--delete from cinema un row
CREATE OR REPLACE FUNCTION cinema_prog_delete() RETURNS TRIGGER AS $$
DECLARE 
	ligne programmateur%ROWTYPE;
BEGIN
	SELECT * INTO ligne FROM programmateur WHERE programmateur.programmateur = OLD.programmateur;
	IF ligne.nb_cinema <= 0 THEN
		RAISE NOTICE 'CAN NOT delete, bug, nombre de cinema <=0 : % ', OLD.programmateur;
		RETURN NULL;
	END IF;
	UPDATE programmateur SET nb_cinema = nb_cinema - 1 WHERE programmateur.programmateur = OLD.programmateur;
	RETURN NULL;	
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_auto_prog_cinema_nb_delete
AFTER DELETE ON cinema 
FOR EACH ROW
EXECUTE PROCEDURE cinema_prog_delete();

--update un row in cinema
CREATE OR REPLACE FUNCTION cinema_prog_update() RETURNS TRIGGER AS $$

BEGIN
	UPDATE programmateur SET nb_cinema = nb_cinema - 1 WHERE programmateur.programmateur = OLD.programmateur;
	UPDATE programmateur SET nb_cinema = nb_cinema + 1 WHERE programmateur.programmateur = NEW.programmateur;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_auto_prog_cinema_nb_update
AFTER UPDATE ON cinema 
FOR EACH ROW
EXECUTE PROCEDURE cinema_prog_update();

--(04) Vérifier @ dans la table Utilisateur

DROP FUNCTION IF EXISTS trig_mauvais_e_mail();
DROP TRIGGER IF EXISTS trig_mail_in_utilisteur ON Utilisateur;

CREATE OR REPLACE FUNCTION trig_mauvais_e_mail() RETURNS TRIGGER AS $$
BEGIN
	RAISE NOTICE '--> Mauvais e_mail';
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_mail_in_utilisteur
BEFORE INSERT OR UPDATE ON Utilisateur
FOR EACH ROW
WHEN (NEW.e_mail !~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$')
EXECUTE PROCEDURE trig_mauvais_e_mail();

--(05) auto timestamp

DROP FUNCTION IF EXISTS auto_timestamp();
DROP TRIGGER IF EXISTS trig_auto_timestamp ON investissement; 

CREATE OR REPLACE FUNCTION auto_timestamp() RETURNS TRIGGER AS $$
BEGIN
	NEW.time = NOW();
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_auto_timestamp_inv 
BEFORE INSERT OR UPDATE ON investissement
FOR EACH ROW
EXECUTE PROCEDURE auto_timestamp();

--(06) intégrité de investissement

DROP FUNCTION IF EXISTS identique_inv();
DROP TRIGGER IF EXISTS trig_integrale_inv ON investissement;

CREATE OR REPLACE FUNCTION identique_inv() RETURNS TRIGGER AS $$
DECLARE
	nom_t investissement.nom%TYPE;
	prog_t investissement.programmateur%TYPE;
BEGIN
	-- nom du investisseur
	SELECT nom INTO nom_t FROM Utilisateur 
	WHERE Utilisateur.e_mail = NEW.e_mail;

	-- programmateur du cinema
	SELECT programmateur INTO prog_t FROM cinema
	WHERE cinema.n_auto = NEW.n_auto;

	IF nom_t = NEW.nom AND prog_t = NEW.programmateur THEN
		RETURN NEW;
	ELSE RETURN NULL;
	END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_integrale_inv
BEFORE INSERT OR UPDATE ON investissement
FOR EACH ROW
EXECUTE PROCEDURE identique_inv();

--(07) auto transfert

DROP FUNCTION IF EXISTS auto_transfert_insert();
DROP FUNCTION IF EXISTS auto_transfert_update();
DROP TRIGGER IF EXISTS trig_auto_transfert_insert ON investissement;
DROP TRIGGER IF EXISTS trig_auto_transfert_update ON investissement;

-- insert transfert

CREATE OR REPLACE FUNCTION auto_transfert_insert() RETURNS TRIGGER AS $$
BEGIN
	UPDATE Utilisateur SET solde = solde - NEW.montant WHERE Utilisateur.e_mail = NEW.e_mail;
	UPDATE Utilisateur SET mise_de_fonds = mise_de_fonds + NEW.montant WHERE Utilisateur.e_mail = NEW.e_mail;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_auto_transfert_insert
AFTER INSERT ON investissement
FOR EACH ROW 
EXECUTE PROCEDURE auto_transfert_insert();
 
-- update transfert

CREATE OR REPLACE FUNCTION auto_transfert_update() RETURNS TRIGGER AS $$
BEGIN
	UPDATE Utilisateur SET solde = solde - (NEW.montant - OLD.montant) WHERE Utilisateur.e_mail = NEW.e_mail;
	UPDATE Utilisateur SET mise_de_fonds = mise_de_fonds + (NEW.montant - OLD.montant) WHERE Utilisateur.e_mail = NEW.e_mail;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_auto_transfert_update
AFTER UPDATE ON investissement
FOR EACH ROW 
EXECUTE PROCEDURE auto_transfert_update();

