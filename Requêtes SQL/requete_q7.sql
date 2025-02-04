SELECT u.id_utilisateur, u.nom,
       SUM(calculer_score_engagement(i.id_publication)) AS score_engagement_hors_cercle
FROM utilisateur u
JOIN interagir i ON u.id_utilisateur = i.id_utilisateur
LEFT JOIN connecter c
    ON (u.id_utilisateur = c.id_utilisateur_1 AND i.id_utilisateur = c.id_utilisateur_2)
    OR (u.id_utilisateur = c.id_utilisateur_2 AND i.id_utilisateur = c.id_utilisateur_1)
WHERE c.id_utilisateur_1 IS NULL AND c.id_utilisateur_2 IS NULL
GROUP BY u.id_utilisateur, u.nom
ORDER BY score_engagement_hors_cercle DESC;


DROP FUNCTION IF EXISTS analyse_utilisateurs_hors_cercle();

CREATE OR REPLACE FUNCTION analyse_utilisateurs_hors_cercle()
RETURNS TABLE(
    attribut TEXT,
    valeur_top_utilisateurs NUMERIC,
    valeur_population_generale NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    WITH top_utilisateurs AS (
        SELECT u.id_utilisateur, u.nom,
               SUM(calculer_score_engagement(i.id_publication)) AS score_engagement_hors_cercle
        FROM utilisateur u
        JOIN interagir i ON u.id_utilisateur = i.id_utilisateur
        LEFT JOIN connecter c
            ON (u.id_utilisateur = c.id_utilisateur_1 AND i.id_utilisateur = c.id_utilisateur_2)
            OR (u.id_utilisateur = c.id_utilisateur_2 AND i.id_utilisateur = c.id_utilisateur_1)
        WHERE c.id_utilisateur_1 IS NULL AND c.id_utilisateur_2 IS NULL
        GROUP BY u.id_utilisateur, u.nom
        ORDER BY score_engagement_hors_cercle DESC
        LIMIT 20
    )

    SELECT 'Ancienneté moyenne (années)',
           AVG(EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM u.date_inscription))::NUMERIC,
           (SELECT AVG(EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM date_inscription)) FROM utilisateur)::NUMERIC
    FROM top_utilisateurs tu
    JOIN utilisateur u ON tu.id_utilisateur = u.id_utilisateur

    UNION ALL

    SELECT 'Nombre moyen d amis',
           AVG((SELECT COUNT(*) FROM connecter c WHERE c.id_utilisateur_1 = tu.id_utilisateur OR c.id_utilisateur_2 = tu.id_utilisateur))::NUMERIC,
           (SELECT AVG((SELECT COUNT(*) FROM connecter c WHERE c.id_utilisateur_1 = u.id_utilisateur OR c.id_utilisateur_2 = u.id_utilisateur)) FROM utilisateur u)::NUMERIC
    FROM top_utilisateurs tu

    UNION ALL

    SELECT 'Interactions moyennes',
           AVG((SELECT COUNT(*) FROM interagir i WHERE i.id_utilisateur = tu.id_utilisateur))::NUMERIC,
           (SELECT AVG((SELECT COUNT(*) FROM interagir i WHERE i.id_utilisateur = u.id_utilisateur)) FROM utilisateur u)::NUMERIC
    FROM top_utilisateurs tu

    UNION ALL

    SELECT 'Nombre moyen de groupes',
           AVG((SELECT COUNT(*) FROM adherer a WHERE a.id_utilisateur = tu.id_utilisateur))::NUMERIC,
           (SELECT AVG((SELECT COUNT(*) FROM adherer a WHERE a.id_utilisateur = u.id_utilisateur)) FROM utilisateur u)::NUMERIC
    FROM top_utilisateurs tu

    UNION ALL

    SELECT 'Nombre moyen de publications',
           AVG((SELECT COUNT(*) FROM publication p WHERE p.id_utilisateur = tu.id_utilisateur))::NUMERIC,
           (SELECT AVG((SELECT COUNT(*) FROM publication p WHERE p.id_utilisateur = u.id_utilisateur)) FROM utilisateur u)::NUMERIC
    FROM top_utilisateurs tu

    UNION ALL

    SELECT 'Interactions avec vidéos',
           AVG((SELECT COUNT(*) FROM interagir i JOIN publication p ON i.id_publication = p.id_publication WHERE i.id_utilisateur = tu.id_utilisateur AND p.type_publication = 'video'))::NUMERIC,
           (SELECT AVG((SELECT COUNT(*) FROM interagir i JOIN publication p ON i.id_publication = p.id_publication WHERE i.id_utilisateur = u.id_utilisateur AND p.type_publication = 'video')) FROM utilisateur u)::NUMERIC
    FROM top_utilisateurs tu

    UNION ALL

    SELECT 'Interactions avec textes',
           AVG((SELECT COUNT(*) FROM interagir i JOIN publication p ON i.id_publication = p.id_publication WHERE i.id_utilisateur = tu.id_utilisateur AND p.type_publication = 'texte'))::NUMERIC,
           (SELECT AVG((SELECT COUNT(*) FROM interagir i JOIN publication p ON i.id_publication = p.id_publication WHERE i.id_utilisateur = u.id_utilisateur AND p.type_publication = 'texte')) FROM utilisateur u)::NUMERIC
    FROM top_utilisateurs tu

    UNION ALL

    SELECT 'Interactions avec images',
           AVG((SELECT COUNT(*) FROM interagir i JOIN publication p ON i.id_publication = p.id_publication WHERE i.id_utilisateur = tu.id_utilisateur AND p.type_publication = 'image'))::NUMERIC,
           (SELECT AVG((SELECT COUNT(*) FROM interagir i JOIN publication p ON i.id_publication = p.id_publication WHERE i.id_utilisateur = u.id_utilisateur AND p.type_publication = 'image')) FROM utilisateur u)::NUMERIC
    FROM top_utilisateurs tu;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM analyse_utilisateurs_hors_cercle() ORDER BY valeur_top_utilisateurs desc;
