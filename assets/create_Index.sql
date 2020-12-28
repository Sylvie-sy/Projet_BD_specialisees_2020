-----------
-- Index --
-----------

--(01) Index pour cinema

DROP INDEX IF EXISTS index_n_auto_cinema;
DROP INDEX IF EXISTS index_unite_urbaine_cinema;

CREATE INDEX index_n_auto_cinema
ON cinema USING BTREE (n_auto);

CREATE INDEX index_unite_urbaine_cinema
ON cinema USING HASH (unite_urbaine);

--(02) Index pour uilisateur

DROP INDEX IF EXISTS index_nom_util;
DROP INDEX IF EXISTS index_e_mail_util;

CREATE INDEX index_nom_util
ON utilisateur USING BTREE (nom);

CREATE INDEX index_e_mail_util
ON utilisateur USING BTREE (e_mail);

--(03) Index pour investissement

DROP INDEX IF EXISTS index_nom_inv;
DROP INDEX IF EXISTS index_e_mail_inv;
DROP INDEX IF EXISTS index_n_auto_inv;

CREATE INDEX index_n_auto_inv
ON investissement USING BTREE(n_auto);

CREATE INDEX index_nom_inv
ON investissement USING BTREE (nom);

CREATE INDEX index_e_mail_inv
ON investissement USING BTREE (e_mail);

