-- Fonction d'ajout d'un utilisateur
CREATE OR REPLACE FUNCTION ajouter_utilisateur(nom_utilisateur TEXT, email_utilisateur TEXT) RETURNS INT AS $$
DECLARE
    nouvel_id INT;
BEGIN
    INSERT INTO utilisateur (nom, email, date_inscription)
    VALUES (nom_utilisateur, email_utilisateur, CURRENT_DATE)
    RETURNING id_utilisateur INTO nouvel_id;
    RETURN nouvel_id;
END;
$$ LANGUAGE plpgsql;

-- Fonction de suggestion d'amis
CREATE OR REPLACE FUNCTION suggerer_amis(nouvel_id INT) RETURNS TABLE(nom_utilisateur TEXT, email_utilisateur TEXT) AS $$
DECLARE
    nom_nouvel_utilisateur TEXT;
    email_nouvel_utilisateur TEXT;
BEGIN
    SELECT nom::TEXT, email::TEXT INTO nom_nouvel_utilisateur, email_nouvel_utilisateur FROM utilisateur WHERE id_utilisateur = nouvel_id;

    RETURN QUERY
    SELECT u.nom::TEXT, u.email::TEXT
    FROM utilisateur u
    WHERE u.id_utilisateur != nouvel_id AND (
        -- Comparer le nom de famille
        SPLIT_PART(u.nom, ' ', array_length(string_to_array(u.nom, ' '), 1)) =
        SPLIT_PART(nom_nouvel_utilisateur, ' ', array_length(string_to_array(nom_nouvel_utilisateur, ' '), 1))
        OR
        -- Comparer le domaine email en excluant les domaines génériques
        (
            POSITION('@' IN u.email) > 0
            AND SPLIT_PART(u.email, '@', 2) NOT IN ('gmail.com', 'yahoo.com', 'hotmail.com')
            AND SPLIT_PART(email_nouvel_utilisateur, '@', 2) = SPLIT_PART(u.email, '@', 2)
        )
    )
    ORDER BY (SELECT COUNT(*) FROM connecter WHERE connecter.id_utilisateur_1 = u.id_utilisateur) DESC
    LIMIT 5;
END;
$$ LANGUAGE plpgsql;

-- Fonction de suggestion des groupes populaires
CREATE OR REPLACE FUNCTION suggerer_groupes_populaires(nouvel_id INT) RETURNS TABLE(theme TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT t.nom::TEXT
    FROM publication p
    JOIN theme t ON p.id_theme = t.id_theme
    GROUP BY t.nom
    ORDER BY SUM(calculer_score_engagement(p.id_publication)) DESC
    LIMIT 5;
END;
$$ LANGUAGE plpgsql;

-- Fonction de suggestion des publications tendances
CREATE OR REPLACE FUNCTION suggerer_publications() RETURNS TABLE(id_publication INT, contenu TEXT, type_publication TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT p.id_publication, p.contenu::TEXT, p.type_publication::TEXT
    FROM publication p
    ORDER BY calculer_score_engagement(p.id_publication) DESC
    LIMIT 5;
END;
$$ LANGUAGE plpgsql;

-- Fonction d'intégration d'un utilisateur et de suggestion de contenu
CREATE OR REPLACE FUNCTION integrer_utilisateur(nom_utilisateur TEXT, email_utilisateur TEXT) RETURNS TABLE(type TEXT, info TEXT) AS $$
DECLARE
    nouvel_id INT;
BEGIN
    nouvel_id := ajouter_utilisateur(nom_utilisateur, email_utilisateur);

    RETURN QUERY
    SELECT 'Utilisateur créé'::TEXT, 'ID: ' || nouvel_id::TEXT;

    RETURN QUERY
    SELECT 'Ami suggéré'::TEXT, sa.nom_utilisateur || ' (' || sa.email_utilisateur || ')'
    FROM suggerer_amis(nouvel_id) sa
    WHERE sa.nom_utilisateur IS NOT NULL;

    RETURN QUERY
    SELECT 'Groupe suggéré'::TEXT, sg.theme
    FROM suggerer_groupes_populaires(nouvel_id) sg;

    RETURN QUERY
    SELECT 'Publication tendance'::TEXT, sp.contenu || ' (' || sp.type_publication || ')'
    FROM suggerer_publications() sp;
END;
$$ LANGUAGE plpgsql;

-- Exécution de la fonction
SELECT * FROM integrer_utilisateur('Jean Dupont', 'jean.dupont@exemple.com');
