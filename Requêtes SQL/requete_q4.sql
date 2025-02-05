DROP FUNCTION IF EXISTS calculer_influence_utilisateur(INT);

CREATE OR REPLACE FUNCTION calculer_influence_utilisateur(user_id INT) RETURNS FLOAT AS $$
DECLARE
    score_publications FLOAT := 0;
    score_commentaires FLOAT := 0;
    score_partages FLOAT := 0;
    score_total FLOAT;
BEGIN
    -- Nombre de publications * 0.5
    SELECT COUNT(*) * 0.5 INTO score_publications
    FROM publication
    WHERE id_utilisateur = user_id;

    -- Nombre de commentaires * 0.3
    SELECT COUNT(*) * 0.3 INTO score_commentaires
    FROM interagir
    WHERE id_utilisateur = user_id AND type_interaction = 'comment';

    -- Nombre de partages * 0.2
    SELECT COUNT(*) * 0.2 INTO score_partages
    FROM interagir
    WHERE id_utilisateur = user_id AND type_interaction = 'partage';

    -- Somme des scores
    score_total := COALESCE(score_publications, 0) + COALESCE(score_commentaires, 0) + COALESCE(score_partages, 0);

    RETURN score_total;
END;
$$ LANGUAGE plpgsql;

SELECT u.id_utilisateur, u.nom, t.nom AS groupe, 
       calculer_influence_utilisateur(u.id_utilisateur) AS score_influence
FROM utilisateur u
LEFT JOIN publication p ON u.id_utilisateur = p.id_utilisateur
LEFT JOIN theme t ON p.id_theme = t.id_theme
GROUP BY u.id_utilisateur, u.nom, t.nom
ORDER BY score_influence DESC
LIMIT 5;

-- SELECT u.id_utilisateur, u.nom, calculer_influence_utilisateur(u.id_utilisateur) AS score_influence FROM utilisateur u WHERE u.id_utilisateur = 1;
