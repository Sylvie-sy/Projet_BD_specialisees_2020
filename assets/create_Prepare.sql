-- 01 create a new utilisateur
DEALLOCATE PREPARE new_utl;

PREPARE new_utl (VARCHAR, VARCHAR, INT, VARCHAR) AS 
INSERT INTO Utilisateur VALUES($1,$2,$3,$4, '1','0', '0', NOW());

-- 02 create a new investissement
DEALLOCATE PREPARE new_invs;  

PREPARE new_invs(VARCHAR, VARCHAR, VARCHAR, INTEGER, REAL) AS
INSERT INTO investissement VALUES($1,$2,$3,$4,$5);

-- 03 create a new cinema
-- $1 n_auto $2 nom du cinema $3 programmateur
DEALLOCATE PREPARE new_cinema;  

PREPARE new_cinema(INTEGER, VARCHAR, VARCHAR) AS 
INSERT INTO cinema VALUES($1,$2,'fake adress','Paris','1','1','1','1','1',$3,'5','4','3','2','1','1','1');

