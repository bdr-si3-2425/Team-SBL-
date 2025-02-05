-- Suppression des anciennes fonctions obsolètes
DROP FUNCTION IF EXISTS themes_activite_recente(INT);
DROP FUNCTION IF EXISTS recommander_connexions(INT);
DROP FUNCTION IF EXISTS recommander_activite(INT);
DROP FUNCTION IF EXISTS recommander_groupes(INT);
DROP FUNCTION IF EXISTS recent_group();

-- Récupérer groupes récents
CREATE OR REPLACE FUNCTION recent_group()
RETURNS TABLE(id_groupe INT) AS
$$
BEGIN
    RETURN QUERY
    SELECT g.id_groupe
    FROM groupe g
    JOIN (
        SELECT a.id_groupe, MAX(date_adhesion_debut) AS last_activity
        FROM adherer a
        GROUP BY a.id_groupe
    ) a ON g.id_groupe = a.id_groupe
    ORDER BY a.last_activity DESC
    LIMIT 10;
END;
$$ LANGUAGE plpgsql;




-- Thèmes d'activité récente
CREATE OR REPLACE FUNCTION themes_activite_recente(user_id INT) RETURNS TABLE(id_theme INT) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT p.id_theme
    FROM interagir i
    JOIN publication p ON i.id_publication = p.id_publication
    WHERE i.id_utilisateur = user_id
          AND i.date_interaction >= NOW() - INTERVAL '7 DAYS';
END;
$$ LANGUAGE plpgsql;

-- Recommandation de groupes récents
CREATE OR REPLACE FUNCTION recommander_groupes_recent(user_id INT) RETURNS TABLE(nom_groupe TEXT, score_final FLOAT) AS $$
BEGIN
    RETURN QUERY
    WITH themes_utilisateur AS (
        SELECT DISTINCT g.id_theme
        FROM adherer a
        JOIN groupe g ON a.id_groupe = g.id_groupe
        WHERE a.id_utilisateur = user_id
    ),
    groupes_recents AS (
        SELECT id_groupe FROM recent_group()
    ),
    groupes_parents AS (
        SELECT g.nom::TEXT AS groupe_nom, COUNT(a.id_utilisateur) * 0.7 AS score
        FROM groupe g
        JOIN theme t ON g.id_theme = t.id_theme
        LEFT JOIN adherer a ON g.id_groupe = a.id_groupe
        WHERE g.id_groupe IN (SELECT id_groupe FROM groupes_recents)
        AND t.id_theme IN (
            SELECT t.id_parent_theme FROM theme t WHERE t.id_theme IN (SELECT id_theme FROM themes_utilisateur)
        )
        GROUP BY g.nom, g.id_groupe
    ),
    groupes_apparents AS (
        SELECT g.nom::TEXT AS groupe_nom, COUNT(a.id_utilisateur) * 0.7 AS score
        FROM groupe g
        JOIN theme t ON g.id_theme = t.id_theme
        LEFT JOIN adherer a ON g.id_groupe = a.id_groupe
        WHERE g.id_groupe IN (SELECT id_groupe FROM groupes_recents)
        AND t.id_parent_theme IN (
            SELECT t.id_parent_theme FROM theme t WHERE t.id_theme IN (SELECT id_theme FROM themes_utilisateur)
        )
        AND g.id_theme NOT IN (SELECT id_theme FROM themes_utilisateur)
        GROUP BY g.nom, g.id_groupe
    ),
    groupes_tendances AS (
        SELECT g.nom::TEXT AS groupe_nom, SUM(calculer_score_engagement(p.id_publication)) * 0.3 AS score
        FROM publication p
        JOIN theme t ON p.id_theme = t.id_theme
        JOIN groupe g ON g.id_theme = t.id_theme
        WHERE g.id_groupe IN (SELECT id_groupe FROM groupes_recents)
        GROUP BY g.nom, g.id_groupe
        ORDER BY SUM(calculer_score_engagement(p.id_publication)) DESC
        LIMIT 5
    )
    SELECT groupe_nom, score FROM groupes_parents
    UNION ALL
    SELECT groupe_nom, score FROM groupes_apparents
    UNION ALL
    SELECT groupe_nom, score FROM groupes_tendances
    ORDER BY score DESC
    LIMIT 5;
END;
$$ LANGUAGE plpgsql;

-- Recommandation globale de connexions
CREATE OR REPLACE FUNCTION recommander_connexions_globale(user_id INT) 
RETURNS TABLE(nom_utilisateur TEXT, email_utilisateur TEXT, score_final FLOAT) AS $$ 
BEGIN
    RETURN QUERY
    WITH connexions_interactions AS (
        SELECT rc.nom_utilisateur, rc.email_utilisateur, CAST(COUNT(rc.nb_connexions) * 0.5 AS FLOAT) AS score
        FROM recommander_connexions_selon_publication(user_id) rc
        GROUP BY rc.nom_utilisateur, rc.email_utilisateur
    ),
    connexions_groupes AS (
        SELECT rg.nom_utilisateur, rg.email_utilisateur, CAST(COUNT(rg.nb_groupes_communs) * 0.3 AS FLOAT) AS score
        FROM recommander_connexions_selon_groupe(user_id) rg
        GROUP BY rg.nom_utilisateur, rg.email_utilisateur
    ),
    connexions_activite_recente AS (
        SELECT sa.nom_utilisateur, sa.email_utilisateur, CAST(0.2 AS FLOAT) AS score
        FROM suggerer_connexions_selon_contacts(user_id) sa
    )
    SELECT fusion.nom_utilisateur, fusion.email_utilisateur, CAST(SUM(fusion.score) AS FLOAT) AS score_final
    FROM (
        SELECT ci.nom_utilisateur, ci.email_utilisateur, ci.score FROM connexions_interactions ci
        UNION ALL
        SELECT cg.nom_utilisateur, cg.email_utilisateur, cg.score FROM connexions_groupes cg
        UNION ALL
        SELECT ca.nom_utilisateur, ca.email_utilisateur, ca.score FROM connexions_activite_recente ca
    ) AS fusion
    GROUP BY fusion.nom_utilisateur, fusion.email_utilisateur
    ORDER BY score_final DESC
    LIMIT 5;
END;
$$ LANGUAGE plpgsql;

-- select * from recommander_groupes_recent(6);
-- select * from recommander_connexions_globale(6);