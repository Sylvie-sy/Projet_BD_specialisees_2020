--------------
-- Funtions --
--------------

--(01) Lister tous les utilisateurs	 

DROP FUNCTION IF EXISTS show_utilisateur(name VARCHAR);

CREATE OR REPLACE FUNCTION show_utilisateur(name VARCHAR) 
RETURNS TABLE(nom VARCHAR, level INT, connection TIMESTAMP) AS $$
BEGIN
	RETURN QUERY SELECT Utilisateur.nom, Utilisateur.level, Utilisateur.derniere_connection 
	FROM Utilisateur
	WHERE Utilisateur.nom = name;
END;
$$ LANGUAGE plpgsql;

--(02) Create un utilisateur

DROP FUNCTION IF EXISTS create_utilisateur(nom VARCHAR, e_mail VARCHAR, telephone INT, mot_de_pass VARCHAR);

CREATE OR REPLACE FUNCTION create_utilisateur(nom VARCHAR, e_mail VARCHAR, telephone INT, mot_de_pass VARCHAR) 
RETURNS VOID AS $$
BEGIN
	INSERT INTO Utilisateur VALUES(nom, e_mail, telephone, mot_de_pass, '1','0', '0', NOW()::TIMESTAMP);
END;
$$ LANGUAGE plpgsql;

--(03) Create un investissement

DROP FUNCTION IF EXISTS create_investissement(nom VARCHAR, e_mail VARCHAR, telephone INT, mot_de_pass VARCHAR);

CREATE OR REPLACE FUNCTION create_investissement(nom VARCHAR, e_mail VARCHAR, programmateur VARCHAR, n_auto INTEGER, montant REAL) 
RETURNS VOID AS $$
BEGIN
	INSERT INTO investissement VALUES(nom, e_mail, programmateur, n_auto, montant, NOW());
END;
$$ LANGUAGE plpgsql;

--(04) Un bilan sur investissement

DROP FUNCTION IF EXISTS bilan_programmateur(prog VARCHAR);

CREATE OR REPLACE FUNCTION bilan_programmateur(prog VARCHAR)
RETURNS TABLE(programmateur VARCHAR, sum_montant NUMERIC) AS $$
BEGIN
	RETURN QUERY SELECT  investissement.programmateur, SUM(montant) FROM investissement 
	WHERE investissement.programmateur = prog
	GROUP BY investissement.programmateur;
END;
$$ LANGUAGE plpgsql;

--(05) Check password
DROP FUNCTION IF EXISTS check_password(e VARCHAR, mot VARCHAR); 

CREATE OR REPLACE FUNCTION check_password(e VARCHAR, mot VARCHAR)
RETURNS BOOLEAN AS $$
DECLARE 
	passed BOOLEAN;
BEGIN
	SELECT (mot = Utilisateur.mot_de_pass ) INTO passed FROM Utilisateur WHERE e = Utilisateur.e_mail;
	IF NOT FOUND THEN 
		passed := FALSE;
		RAISE NOTICE 'e_mail NOT FOUND';
	END IF;
	RETURN passed;
END;
$$ LANGUAGE plpgsql;

--(06) nth highest function

DROP FUNCTION IF EXISTS nth_chiffre_affaire(n INTEGER);
DROP FUNCTION IF EXISTS nth_profit(n INTEGER);
DROP FUNCTION IF EXISTS nth_film_programme(n INTEGER);
DROP FUNCTION IF EXISTS nth_entree(n INTEGER);

CREATE OR REPLACE FUNCTION nth_chiffre_affaire(n INTEGER )
RETURNS TABLE(nth_programmateur VARCHAR, nth_chiffre_affaire INTEGER)AS $$
BEGIN
	RETURN QUERY 
	SELECT DISTINCT programmateur.programmateur, chiffre_affaire AS nth_c_a 
		       	FROM programmateur WHERE chiffre_affaire IS NOT NULL
			ORDER BY chiffre_affaire DESC
			 OFFSET (n-1) LIMIT 1; 
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION nth_profit(n INTEGER )
RETURNS TABLE(nth_programmateur VARCHAR, nth_profit INTEGER)AS $$
BEGIN
	RETURN QUERY 
	SELECT DISTINCT programmateur.programmateur, profit 
	FROM programmateur WHERE profit IS NOT NULL
	ORDER BY profit DESC
	OFFSET (n-1) LIMIT 1; 
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION nth_film_programme(n INTEGER )
RETURNS TABLE(nom_nth VARCHAR, adresse_nth VARCHAR,nth_film_p INTEGER)AS $$
BEGIN
	RETURN QUERY 
	SELECT DISTINCT nom, adresse, nb_film_programme 
	FROM cinema WHERE nb_film_programme IS NOT NULL
	ORDER BY nb_film_programme DESC
	OFFSET (n-1) LIMIT 1; 
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION nth_entree(n INTEGER )
RETURNS TABLE(nom_nth VARCHAR, adresse_nth VARCHAR,nth_entree INTEGER)AS $$
BEGIN
	RETURN QUERY 
	SELECT DISTINCT nom, adresse, entre_2018 
	FROM cinema WHERE entre_2018 IS NOT NULL
	ORDER BY entre_2018 DESC
	OFFSET (n-1) LIMIT 1; 
END;
$$ LANGUAGE plpgsql;

--(07) RANK population, secances, entree,

DROP FUNCTION IF EXISTS rank_population(n INTEGER);
DROP FUNCTION IF EXISTS rank_chiffre_affaire(n INTEGER);
DROP FUNCTION IF EXISTS rank_profit(n INTEGER);
DROP FUNCTION IF EXISTS rank_entre(n INTEGER);

CREATE OR REPLACE FUNCTION rank_population(n INTEGER)
RETURNS TABLE(rank_p BIGINT, pop NUMERIC, ville_name VARCHAR) AS $$
BEGIN
	RETURN QUERY
	SELECT (SELECT COUNT(DISTINCT B.population) 
		FROM Ville B WHERE B.population >= A.population) AS "RANK",
		A.population, A.unite_urbaine 
	FROM Ville A
	ORDER BY A.population DESC
	LIMIT n;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION rank_chiffre_affaire(n INTEGER)
RETURNS TABLE(rank_c_a BIGINT, c_a INTEGER, programmateur VARCHAR) AS $$
BEGIN
	RETURN QUERY
	SELECT (SELECT COUNT(DISTINCT B.chiffre_affaire) 
		FROM programmateur B WHERE B.chiffre_affaire >= A.chiffre_affaire) AS "RANK",
		A.chiffre_affaire, A.programmateur 
	FROM programmateur A
	WHERE A.chiffre_affaire IS NOT NULL
	ORDER BY A.chiffre_affaire DESC
	LIMIT n;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION rank_profit(n INTEGER)
RETURNS TABLE(rank_pf BIGINT, pf INTEGER, programmateur VARCHAR) AS $$
BEGIN
	RETURN QUERY
	SELECT (SELECT COUNT(DISTINCT B.profit) 
		FROM programmateur B WHERE B.profit >= A.profit) AS "RANK",
		A.profit, A.programmateur 
	FROM programmateur A
	WHERE A.profit IS NOT NULL
	ORDER BY A.profit DESC
	LIMIT n;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION rank_entre(n INTEGER)
RETURNS TABLE(rank_pf BIGINT, nb_entre INTEGER, nom VARCHAR, adresse VARCHAR) AS $$
BEGIN
	RETURN QUERY
	SELECT (SELECT COUNT(DISTINCT B.entre_2018) 
		FROM cinema B WHERE B.entre_2018 >= A.entre_2018) AS "RANK",
		A.entre_2018, A.nom, A.adresse 
	FROM cinema A
	WHERE A.entre_2018 IS NOT NULL
	ORDER BY A.entre_2018 DESC
	LIMIT n;
END;
$$ LANGUAGE plpgsql;

--(08) chaque programmateur, les n premier mieux en entrée

DROP FUNCTION IF EXISTS chaque_programmateur_n_premiers_entre(n INTEGER);

CREATE OR REPLACE FUNCTION chaque_programmateur_n_premiers_entre(n INTEGER)
RETURNS TABLE(programmateur_ VARCHAR, nom_ VARCHAR, entre_ INTEGER) AS $$
BEGIN
	RETURN QUERY
	SELECT P.programmateur, C1.nom, C1.entre_2018 FROM cinema C1, programmateur P
	WHERE n > (
		SELECT COUNT(DISTINCT C2.entre_2018)
		FROM cinema C2
		WHERE C1.entre_2018 < C2.entre_2018 
		AND C1.programmateur = C2.programmateur) 
	AND C1.programmateur = P.programmateur 
	ORDER BY P.programmateur,C1.entre_2018 DESC;
END;
$$ LANGUAGE plpgsql;

--(09) chaque programmateur, les n premier mieux en evolution seances

DROP FUNCTION IF EXISTS chaque_programmateur_n_premiers_seances(n INTEGER);

CREATE OR REPLACE FUNCTION chaque_programmateur_n_premiers_seances(n INTEGER)
RETURNS TABLE(programmateur_ VARCHAR, nom_ VARCHAR, seance INTEGER) AS $$
BEGIN
	RETURN QUERY
	SELECT P.programmateur, C1.nom, C1.seances FROM cinema C1, programmateur P
	WHERE n > (
		SELECT COUNT(DISTINCT C2.seances)
		FROM cinema C2
		WHERE C1.seances < C2.seances
		AND C1.programmateur = C2.programmateur) 
	AND C1.programmateur = P.programmateur 
	ORDER BY P.programmateur,C1.seances DESC;
END;
$$ LANGUAGE plpgsql;

--(10) festival en cours

DROP FUNCTION IF EXISTS festival_en_cours();
DROP FUNCTION IF EXISTS festival_en_cours(pro_f VARCHAR);

CREATE OR REPLACE FUNCTION festival_en_cours()
RETURNS SETOF festival AS $$
BEGIN
	RETURN QUERY
	SELECT * FROM festival WHERE NOW() <= festival.fin
	ORDER BY festival.debut;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION festival_en_cours(pro_f VARCHAR)
RETURNS SETOF festival AS $$
BEGIN
	RETURN QUERY
	SELECT * FROM festival 
	WHERE NOW() <= festival.fin AND festival.programmateur = pro_f 
	ORDER BY festival.debut;
END;
$$ LANGUAGE plpgsql;

--(11) nombre de festival dans les programmateur

DROP FUNCTION IF EXISTS festival_nombre();
DROP FUNCTION IF EXISTS festival_nombre(pro_f VARCHAR);

CREATE OR REPLACE FUNCTION festival_nombre()
RETURNS TABLE(programmateur_f VARCHAR, nb_f BIGINT) AS $$
BEGIN
	RETURN QUERY
	SELECT festival.programmateur, COUNT(DISTINCT festival.nom) 
	FROM festival	
	GROUP BY festival.programmateur
	ORDER BY festival.programmateur;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION festival_nombre(pro_f VARCHAR)
RETURNS TABLE(programmateur_f VARCHAR, nb_f BIGINT) AS $$
BEGIN
	RETURN QUERY
	SELECT festival.programmateur, COUNT(DISTINCT festival.nom) 
	FROM festival	
	WHERE festival.programmateur = pro_f
	GROUP BY festival.programmateur;
END;
$$ LANGUAGE plpgsql;

