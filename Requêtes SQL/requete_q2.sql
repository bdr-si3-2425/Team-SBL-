-- Fonction de calcul du score de watchtime
CREATE OR REPLACE FUNCTION calculer_score_watchtime(publication_id INT) RETURNS FLOAT AS $$
DECLARE
    total_watchtime FLOAT;
    nombre_vues INT;
    duree_moyenne FLOAT;
    duree_totale FLOAT;
    ratio FLOAT;
    score FLOAT;
BEGIN
    -- Récupérer le watchtime total et le nombre de vues
    SELECT COALESCE(SUM(EXTRACT(EPOCH FROM (temps_fin - temps_debut))) / 60, 0), COUNT(*)
    INTO total_watchtime, nombre_vues
    FROM watchtime
    WHERE id_publication = publication_id;

    -- Calcul de la durée moyenne de visionnage
    duree_moyenne := CASE WHEN nombre_vues > 0 THEN total_watchtime / nombre_vues ELSE 0 END;
    
    -- Récupération de la durée totale du contenu
    SELECT COALESCE(contenu_duree, 1) INTO duree_totale
    FROM publication
    WHERE id_publication = publication_id;

    -- Calcul du ratio de visionnage
    ratio := (duree_moyenne / duree_totale) * 100;
    
    -- Calcul du score final
    score := ratio * LOG(10, nombre_vues + 1);
    
    RETURN COALESCE(score, 0);
END;
$$ LANGUAGE plpgsql;

















-- Fonction de calcul du score des commentaires
CREATE OR REPLACE FUNCTION calculer_score_commentaires(commentaire_id INT) RETURNS FLOAT AS $$
DECLARE
    score_likes FLOAT;
    score_reponses FLOAT;
    score_likes_reponses FLOAT;
    score_total FLOAT;
BEGIN
    -- Calcul des likes sur le commentaire
    SELECT COALESCE(SUM(calculer_nombre_followers(i.id_utilisateur) * 0.2), 0)
    INTO score_likes
    FROM interagir i
    WHERE i.id_parent_interaction = commentaire_id AND i.type_interaction = 'like';

    -- Calcul du nombre de réponses
    SELECT COUNT(*) INTO score_reponses
    FROM interagir
    WHERE id_parent_interaction = commentaire_id AND type_interaction = 'comment';

    -- Calcul des likes sur les réponses au commentaire
    SELECT COALESCE(SUM(calculer_nombre_followers(i.id_utilisateur) * 0.1), 0)
    INTO score_likes_reponses
    FROM interagir i
    WHERE i.type_interaction = 'like'
          AND i.id_parent_interaction IN (
              SELECT id_interaction FROM interagir
              WHERE id_parent_interaction = commentaire_id AND type_interaction = 'comment'
          );

    -- Calcul du score total
    score_total := 1.0 + (score_likes * 0.5) + (score_reponses * 0.5) + (score_likes_reponses * 0.25);
    RETURN score_total;
END;
$$ LANGUAGE plpgsql;





















-- Fonction de calcul du score des likes
CREATE OR REPLACE FUNCTION calculer_score_likes(publication_id INT) RETURNS FLOAT AS $$
DECLARE
    score_likes FLOAT;
BEGIN
    SELECT COALESCE(SUM(LOG(10, calculer_nombre_followers(i.id_utilisateur) + 1)), 0)
    INTO score_likes
    FROM interagir i
    WHERE i.type_interaction = 'like' AND i.id_publication = publication_id;
    
    RETURN score_likes;
END;
$$ LANGUAGE plpgsql;







-- Fonction de calcul du score des partages
CREATE OR REPLACE FUNCTION calculer_score_partages(publication_id INT) RETURNS FLOAT AS $$
DECLARE
    score_partages FLOAT;
BEGIN
    SELECT COALESCE(SUM(0.5 + (calculer_nombre_followers(i.id_utilisateur) * 0.05)), 0)
    INTO score_partages
    FROM interagir i
    WHERE i.type_interaction = 'partage' AND i.id_publication = publication_id;
    
    RETURN score_partages;
END;
$$ LANGUAGE plpgsql;





















-- Fonction de calcul du score d'engagement global
CREATE OR REPLACE FUNCTION calculer_score_engagement(publication_id INT) RETURNS FLOAT AS $$
DECLARE
    score_watchtime FLOAT;
    score_likes FLOAT;
    score_commentaires FLOAT;
    score_partages FLOAT;
    engagement FLOAT;
BEGIN
    -- Récupérer les scores individuels
    score_watchtime := calculer_score_watchtime(publication_id);
    score_likes := calculer_score_likes(publication_id);
    score_partages := calculer_score_partages(publication_id);

    -- Calcul du score total des commentaires
    SELECT COALESCE(SUM(calculer_score_commentaires(i.id_interaction)), 0)
    INTO score_commentaires
    FROM interagir i
    WHERE i.id_publication = publication_id AND i.type_interaction = 'comment';

    -- Calcul du score final
    engagement := (score_watchtime * 0.35) + (score_likes * 0.25) + (score_commentaires * 0.25) + (score_partages * 0.15);
    
    RETURN engagement;
END;
$$ LANGUAGE plpgsql;





















-- Fonction de calcul du nombre de followers
CREATE OR REPLACE FUNCTION calculer_nombre_followers(utilisateur_id INT) RETURNS INT AS $$
DECLARE
    nombre_followers INT;
BEGIN
    SELECT COUNT(*)
    INTO nombre_followers
    FROM connecter
    WHERE id_utilisateur_2 = utilisateur_id;
    
    RETURN nombre_followers;
END;
$$ LANGUAGE plpgsql;






SELECT t.nom AS Groupe,
       SUM(calculer_score_engagement(p.id_publication)) AS score_engagement_total
FROM publication p
JOIN theme t ON p.id_theme = t.id_theme
GROUP BY t.nom
ORDER BY score_engagement_total DESC;


SELECT p.type_publication,
       COUNT(p.id_publication) AS nombre_publications,
       SUM(calculer_score_engagement(p.id_publication)) AS engagement_total,
       AVG(calculer_score_engagement(p.id_publication)) AS engagement_moyen,
       (SUM(calculer_score_engagement(p.id_publication)) / COUNT(p.id_publication)) *
       (1 + LOG(10, COUNT(p.id_publication))) AS score_final
FROM publication p
GROUP BY p.type_publication
ORDER BY score_final DESC;
