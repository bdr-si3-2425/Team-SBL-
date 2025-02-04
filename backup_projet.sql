toc.dat                                                                                             0000600 0004000 0002000 00000157624 14750436373 0014472 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        PGDMP   3                    }         
   Projet_BDR    17.2    17.2 g    i           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                           false         j           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                           false         k           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                           false         l           1262    16991 
   Projet_BDR    DATABASE     �   CREATE DATABASE "Projet_BDR" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_United Kingdom.1252';
    DROP DATABASE "Projet_BDR";
                     postgres    false         �            1255    16992    ajouter_utilisateur(text, text)    FUNCTION     o  CREATE FUNCTION public.ajouter_utilisateur(nom_utilisateur text, email_utilisateur text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    nouvel_id INT;
BEGIN
    INSERT INTO utilisateur (nom, email, date_inscription) 
    VALUES (nom_utilisateur, email_utilisateur, CURRENT_DATE)
    RETURNING id_utilisateur INTO nouvel_id;
    RETURN nouvel_id;
END;
$$;
 X   DROP FUNCTION public.ajouter_utilisateur(nom_utilisateur text, email_utilisateur text);
       public               postgres    false         �            1255    16993 %   ajouter_utilisateur(text, text, text)    FUNCTION     a  CREATE FUNCTION public.ajouter_utilisateur(nom text, prenom text, email text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    nouvel_id INT;
BEGIN
    INSERT INTO utilisateur (nom, prenom, email, date_inscription) 
    VALUES (nom, prenom, email, CURRENT_DATE)
    RETURNING id_utilisateur INTO nouvel_id;
    
    RETURN nouvel_id;
END;
$$;
 M   DROP FUNCTION public.ajouter_utilisateur(nom text, prenom text, email text);
       public               postgres    false         �            1255    16994 "   analyse_utilisateurs_hors_cercle()    FUNCTION       CREATE FUNCTION public.analyse_utilisateurs_hors_cercle() RETURNS TABLE(attribut text, valeur_top_utilisateurs numeric, valeur_population_generale numeric)
    LANGUAGE plpgsql
    AS $$
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
$$;
 9   DROP FUNCTION public.analyse_utilisateurs_hors_cercle();
       public               postgres    false         �            1255    16995 '   calculer_influence_utilisateur(integer)    FUNCTION     �  CREATE FUNCTION public.calculer_influence_utilisateur(user_id integer) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
DECLARE
    score_publications FLOAT;
    score_commentaires FLOAT;
    score_partages FLOAT;
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
$$;
 F   DROP FUNCTION public.calculer_influence_utilisateur(user_id integer);
       public               postgres    false         �            1255    16996 "   calculer_nombre_followers(integer)    FUNCTION     B  CREATE FUNCTION public.calculer_nombre_followers(utilisateur_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    nombre_followers INT;
BEGIN
    SELECT COALESCE(COUNT(*), 0)
    INTO nombre_followers
    FROM connecter
    WHERE id_utilisateur_2 = utilisateur_id;

    RETURN nombre_followers;
END;
$$;
 H   DROP FUNCTION public.calculer_nombre_followers(utilisateur_id integer);
       public               postgres    false         �            1255    16997 $   calculer_score_commentaires(integer)    FUNCTION     �  CREATE FUNCTION public.calculer_score_commentaires(commentaire_id integer) RETURNS double precision
    LANGUAGE plpgsql
    AS $$ 
DECLARE
    score_base FLOAT := 1.0;
    score_likes FLOAT;
    score_reponses FLOAT;
    score_likes_reponses FLOAT;
    score_total FLOAT;
BEGIN
    -- Score des likes sur le commentaire
    SELECT COALESCE(SUM(calculer_nombre_followers(i.id_utilisateur) * 0.2), 0) 
    INTO score_likes
    FROM interagir i
    WHERE i.id_parent_interaction = commentaire_id 
          AND i.type_interaction = 'like';

    -- Nombre de réponses (chaque réponse ajoute un point)
    SELECT COALESCE(COUNT(*), 0) 
    INTO score_reponses
    FROM interagir ic
    WHERE ic.id_parent_interaction = commentaire_id 
          AND ic.type_interaction = 'comment';

    -- Score des likes sur les réponses aux commentaires
    SELECT COALESCE(SUM(calculer_nombre_followers(i.id_utilisateur) * 0.1), 0) 
    INTO score_likes_reponses
    FROM interagir i
    WHERE i.type_interaction = 'like' 
          AND i.id_parent_interaction IN (
              SELECT ic.id_interaction 
              FROM interagir ic 
              WHERE ic.id_parent_interaction = commentaire_id 
                    AND ic.type_interaction = 'comment'
          );

    -- Ajout du score des sous-commentaires de manière récursive
    SELECT COALESCE(SUM(calculer_score_commentaires(ic.id_interaction) * 0.5), 0)
    INTO score_reponses
    FROM interagir ic
    WHERE ic.id_parent_interaction = commentaire_id 
          AND ic.type_interaction = 'comment';

    -- Calcul du score total en combinant les éléments
    score_total := score_base + (score_likes * 0.5) + (score_reponses * 0.5) + (score_likes_reponses * 0.25);

    RETURN score_total;
END;
$$;
 J   DROP FUNCTION public.calculer_score_commentaires(commentaire_id integer);
       public               postgres    false         �            1255    16998 "   calculer_score_engagement(integer)    FUNCTION     �  CREATE FUNCTION public.calculer_score_engagement(publication_id integer) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
DECLARE
    score_watchtime FLOAT;
    score_likes FLOAT;
    score_commentaires FLOAT;
    score_partages FLOAT;
    engagement FLOAT;
BEGIN
    --  Récupérer les scores individuels
    score_watchtime := calculer_score_watchtime(publication_id);
    score_likes := calculer_score_likes(publication_id);
    score_partages := calculer_score_partages(publication_id);

    --  Calculer le score total des commentaires de cette publication
    SELECT COALESCE(SUM(calculer_score_commentaires(i.id_interaction)), 0)
    INTO score_commentaires
    FROM interagir i
    WHERE i.id_publication = publication_id 
          AND i.type_interaction = 'comment';

    --  Fusionner les scores avec pondération
    engagement := (score_watchtime * 0.35) + (score_likes * 0.25) + (score_commentaires * 0.25) + (score_partages * 0.15);

    --  Retourner le score final
    RETURN engagement;
END;
$$;
 H   DROP FUNCTION public.calculer_score_engagement(publication_id integer);
       public               postgres    false         �            1255    16999    calculer_score_likes(integer)    FUNCTION     �  CREATE FUNCTION public.calculer_score_likes(publication_id integer) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
DECLARE
    score_likes FLOAT;
BEGIN
    SELECT COALESCE(SUM(LOG(10, calculer_nombre_followers(i.id_utilisateur) + 1)), 0) 
    INTO score_likes
    FROM interagir i
    WHERE i.type_interaction = 'like'
          AND i.id_publication = publication_id;

    RETURN score_likes;
END;
$$;
 C   DROP FUNCTION public.calculer_score_likes(publication_id integer);
       public               postgres    false         �            1255    17000     calculer_score_partages(integer)    FUNCTION     �  CREATE FUNCTION public.calculer_score_partages(publication_id integer) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
DECLARE
    score_partages FLOAT;
BEGIN
    SELECT COALESCE(SUM(0.5 + (calculer_nombre_followers(i.id_utilisateur) * 0.05)), 0) 
    INTO score_partages
    FROM interagir i
    WHERE i.type_interaction = 'partage'
          AND i.id_publication = publication_id;

    RETURN score_partages;
END;
$$;
 F   DROP FUNCTION public.calculer_score_partages(publication_id integer);
       public               postgres    false                     1255    17001 !   calculer_score_watchtime(integer)    FUNCTION     �  CREATE FUNCTION public.calculer_score_watchtime(publication_id integer) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
DECLARE
    total_watchtime FLOAT;
    nombre_vues INT;
    duree_moyenne FLOAT;
    duree_totale FLOAT;
    ratio FLOAT;
    score FLOAT;
BEGIN
    -- 1️⃣ Calcul du total du watchtime et du nombre de vues
    SELECT 
        COALESCE(SUM(EXTRACT(EPOCH FROM (temps_fin - temps_debut))) / 60, 0), 
        COUNT(*)
    INTO total_watchtime, nombre_vues
    FROM watchtime
    WHERE id_publication = publication_id;

    -- 2️⃣ Éviter la division par zéro
    IF nombre_vues > 0 THEN
        duree_moyenne := total_watchtime / nombre_vues;
    ELSE
        duree_moyenne := 0;
    END IF;

    -- 3️⃣ Récupérer la durée totale de la publication et éviter NULL
    SELECT COALESCE(contenu_duree, 1) INTO duree_totale
    FROM publication 
    WHERE id_publication = publication_id;

    -- 4️⃣ Calcul du ratio de visionnage
    ratio := (duree_moyenne / duree_totale) * 100;

    -- 5️⃣ Calcul du score avec pondération logarithmique
    score := ratio * LOG(10, nombre_vues + 1);

    -- 6️⃣ Retourner le score ou 0 si aucune donnée n’existe
    RETURN COALESCE(score, 0);
END;
$$;
 G   DROP FUNCTION public.calculer_score_watchtime(publication_id integer);
       public               postgres    false         �            1255    17002 %   classement_interactions_hors_cercle()    FUNCTION     �  CREATE FUNCTION public.classement_interactions_hors_cercle() RETURNS TABLE(id_utilisateur integer, nom text, interactions_hors_cercle integer, score_hors_cercle numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id_utilisateur,
        u.nom::TEXT,  
        COUNT(i.id_interaction)::INT AS interactions_hors_cercle,  
        SUM(
            CASE 
                WHEN i.type_interaction = 'comment' THEN 3
                WHEN i.type_interaction = 'partage' THEN 2
                WHEN i.type_interaction = 'like' THEN 1
                ELSE 0
            END
        )::NUMERIC AS score_hors_cercle
    FROM utilisateur u
    LEFT JOIN interagir i ON u.id_utilisateur = i.id_utilisateur
    WHERE i.id_publication IN (
        SELECT p.id_publication FROM publication p
        WHERE p.visibilite = 'public'
    )
    GROUP BY u.id_utilisateur, u.nom
    ORDER BY score_hors_cercle DESC;
END;
$$;
 <   DROP FUNCTION public.classement_interactions_hors_cercle();
       public               postgres    false                    1255    17003 %   classement_utilisateurs_hors_cercle()    FUNCTION     �  CREATE FUNCTION public.classement_utilisateurs_hors_cercle() RETURNS TABLE(id_utilisateur integer, nom text, taux_hors_cercle double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT u.id_utilisateur, u.nom::TEXT, 
           COALESCE((interactions_hors_cercle(u.id_utilisateur)::FLOAT / NULLIF(COUNT(i.id_interaction), 0)) * 100, 0) AS taux_hors_cercle
    FROM utilisateur u
    LEFT JOIN interagir i ON u.id_utilisateur = i.id_utilisateur
    GROUP BY u.id_utilisateur, u.nom
    HAVING COALESCE((interactions_hors_cercle(u.id_utilisateur)::FLOAT / NULLIF(COUNT(i.id_interaction), 0)) * 100, 0) > 30
    ORDER BY taux_hors_cercle DESC;
END;
$$;
 <   DROP FUNCTION public.classement_utilisateurs_hors_cercle();
       public               postgres    false         �            1255    17004 !   interactions_hors_cercle(integer)    FUNCTION     6  CREATE FUNCTION public.interactions_hors_cercle(user_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    total_hors_cercle INT;
BEGIN
    SELECT COUNT(*) INTO total_hors_cercle
    FROM interagir i
    JOIN publication p ON i.id_publication = p.id_publication
    LEFT JOIN connecter c ON i.id_utilisateur = c.id_utilisateur_2 
                          AND c.id_utilisateur_1 = user_id
    WHERE i.id_utilisateur != user_id
    AND p.visibilite = 'public'
    AND c.id_utilisateur_1 IS NULL; 

    RETURN COALESCE(total_hors_cercle, 0);
END;
$$;
 @   DROP FUNCTION public.interactions_hors_cercle(user_id integer);
       public               postgres    false         �            1255    17005 !   intégrer_utilisateur(text, text)    FUNCTION     �  CREATE FUNCTION public."intégrer_utilisateur"(nom_utilisateur text, email_utilisateur text) RETURNS TABLE(type text, info text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    nouvel_id INT;
BEGIN
    nouvel_id := ajouter_utilisateur(nom_utilisateur, email_utilisateur);

    RETURN QUERY
    SELECT 'Utilisateur créé'::TEXT, 'ID: ' || nouvel_id::TEXT;

    RETURN QUERY
    SELECT 'Ami suggéré'::TEXT, sa.nom_utilisateur || ' (' || sa.email_utilisateur || ')'
    FROM suggérer_amis(nouvel_id) sa;

    RETURN QUERY
    SELECT 'Groupe suggéré'::TEXT, sg.theme
    FROM suggérer_groupes(nouvel_id) sg;

    RETURN QUERY
    SELECT 'Publication tendance'::TEXT, sp.contenu || ' (' || sp.type_publication || ')'
    FROM suggérer_publications() sp;
END;
$$;
 \   DROP FUNCTION public."intégrer_utilisateur"(nom_utilisateur text, email_utilisateur text);
       public               postgres    false                    1255    17006 '   intégrer_utilisateur(text, text, text)    FUNCTION       CREATE FUNCTION public."intégrer_utilisateur"(nom text, prenom text, email text) RETURNS TABLE(type text, info text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    nouvel_id INT;
BEGIN
    -- 1️⃣ Ajouter l'utilisateur et récupérer son ID
    nouvel_id := ajouter_utilisateur(nom, prenom, email);

    -- 2️⃣ Retourner l'ID du nouvel utilisateur
    RETURN QUERY
    SELECT 'Utilisateur créé' AS type, 'ID: ' || nouvel_id::TEXT AS info;
    
    -- 3️⃣ Retourner les amis suggérés
    RETURN QUERY
    SELECT 'Ami suggéré' AS type, nom || ' ' || prenom || ' (' || email || ')' AS info
    FROM suggérer_amis(nouvel_id);

    -- 4️⃣ Retourner les groupes suggérés
    RETURN QUERY
    SELECT 'Groupe suggéré' AS type, theme || ' (Score: ' || score_engagement_total || ')' AS info
    FROM suggérer_groupes(nouvel_id);

    -- 5️⃣ Retourner les publications tendances
    RETURN QUERY
    SELECT 'Publication tendance' AS type, contenu || ' (' || type_publication || ')' AS info
    FROM suggérer_publications();
END;
$$;
 Q   DROP FUNCTION public."intégrer_utilisateur"(nom text, prenom text, email text);
       public               postgres    false                    1255    17007    recommander_activite(integer)    FUNCTION     O  CREATE FUNCTION public.recommander_activite(user_id integer) RETURNS TABLE(type text, suggestion text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Ajouter les groupes suggérés
    RETURN QUERY
    SELECT 'Groupe recommandé'::TEXT, rg.nom_groupe || ' (' || rg.nb_membres || ' membres)'
    FROM recommander_groupes(user_id) rg;

    -- Ajouter les connexions suggérées
    RETURN QUERY
    SELECT 'Connexion suggérée'::TEXT, rc.nom_utilisateur || ' (' || rc.email_utilisateur || ', ' || rc.nb_connexions || ' connexions communes)'
    FROM recommander_connexions(user_id) rc;
END;
$$;
 <   DROP FUNCTION public.recommander_activite(user_id integer);
       public               postgres    false                    1255    17008    recommander_connexions(integer)    FUNCTION     �  CREATE FUNCTION public.recommander_connexions(user_id integer) RETURNS TABLE(nom_utilisateur text, email_utilisateur text, nb_connexions integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT u.nom::TEXT, u.email::TEXT, COUNT(c.id_utilisateur_2)::INT AS nb_connexions  -- 🔥 Conversion explicite en INT
    FROM utilisateur u
    JOIN interagir i ON u.id_utilisateur = i.id_utilisateur
    LEFT JOIN connecter c ON u.id_utilisateur = c.id_utilisateur_1
    WHERE i.id_publication IN (
        SELECT id_publication FROM interagir WHERE id_utilisateur = user_id
    )
    AND u.id_utilisateur != user_id
    GROUP BY u.id_utilisateur, u.nom, u.email
    ORDER BY nb_connexions DESC
    LIMIT 5;
END;
$$;
 >   DROP FUNCTION public.recommander_connexions(user_id integer);
       public               postgres    false                    1255    17009 '   recommander_connexions_globale(integer)    FUNCTION     �  CREATE FUNCTION public.recommander_connexions_globale(user_id integer) RETURNS TABLE(nom_utilisateur text, email_utilisateur text, score_final double precision)
    LANGUAGE plpgsql
    AS $$ 
BEGIN
    RETURN QUERY
    WITH connexions_interactions AS (
        -- 50% basé sur les interactions dans les mêmes publications
        SELECT rc.nom_utilisateur, rc.email_utilisateur, CAST(COUNT(rc.nb_connexions) * 0.5 AS FLOAT) AS score
        FROM recommander_connexions_selon_publication(user_id) rc
        GROUP BY rc.nom_utilisateur, rc.email_utilisateur
    ),
    connexions_groupes AS (
        -- 30% basé sur les connexions dans les mêmes groupes
        SELECT rg.nom_utilisateur, rg.email_utilisateur, CAST(COUNT(rg.nb_groupes_communs) * 0.3 AS FLOAT) AS score
        FROM recommander_connexions_selon_groupe(user_id) rg
        GROUP BY rg.nom_utilisateur, rg.email_utilisateur
    ),
    connexions_activite_recente AS (
        -- 20% basé sur les suggestions d'amis
        SELECT sa.nom_utilisateur, sa.email_utilisateur, CAST(0.2 AS FLOAT) AS score
        FROM suggerer_connexions_selon_contacts(user_id) sa
    )
    -- Fusionner toutes les recommandations et appliquer la pondération
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
$$;
 F   DROP FUNCTION public.recommander_connexions_globale(user_id integer);
       public               postgres    false                    1255    17010 .   recommander_connexions_selon_contacts(integer)    FUNCTION     �  CREATE FUNCTION public.recommander_connexions_selon_contacts(user_id integer) RETURNS TABLE(nom_utilisateur text, email_utilisateur text, nb_connexions integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT u.nom::TEXT, u.email::TEXT, COUNT(c.id_utilisateur_2)::INT AS nb_connexions
    FROM utilisateur u
    JOIN interagir i ON u.id_utilisateur = i.id_utilisateur
    LEFT JOIN connecter c ON u.id_utilisateur = c.id_utilisateur_1
    WHERE i.id_publication IN (
        SELECT id_publication FROM interagir WHERE id_utilisateur = user_id
    )
    AND u.id_utilisateur != user_id
    GROUP BY u.id_utilisateur, u.nom, u.email
    ORDER BY nb_connexions DESC
    LIMIT 5;
END;
$$;
 M   DROP FUNCTION public.recommander_connexions_selon_contacts(user_id integer);
       public               postgres    false                    1255    17011 ,   recommander_connexions_selon_groupe(integer)    FUNCTION     r  CREATE FUNCTION public.recommander_connexions_selon_groupe(user_id integer) RETURNS TABLE(nom_utilisateur text, email_utilisateur text, nb_groupes_communs integer)
    LANGUAGE plpgsql
    AS $$ 
BEGIN
    RETURN QUERY
    SELECT u2.nom::TEXT, u2.email::TEXT, COUNT(a2.id_groupe)::INT AS nb_groupes_communs
    FROM adherer a1
    JOIN adherer a2 ON a1.id_groupe = a2.id_groupe
    JOIN utilisateur u2 ON a2.id_utilisateur = u2.id_utilisateur
    WHERE a1.id_utilisateur = user_id
    AND u2.id_utilisateur != user_id
    GROUP BY u2.id_utilisateur, u2.nom, u2.email
    ORDER BY nb_groupes_communs DESC
    LIMIT 5;
END;
$$;
 K   DROP FUNCTION public.recommander_connexions_selon_groupe(user_id integer);
       public               postgres    false                    1255    17012 1   recommander_connexions_selon_publication(integer)    FUNCTION     �  CREATE FUNCTION public.recommander_connexions_selon_publication(user_id integer) RETURNS TABLE(nom_utilisateur text, email_utilisateur text, nb_connexions integer)
    LANGUAGE plpgsql
    AS $$ 
BEGIN
    RETURN QUERY
    SELECT u.nom::TEXT, u.email::TEXT, COUNT(c.id_utilisateur_2)::INT AS nb_connexions
    FROM utilisateur u
    JOIN interagir i ON u.id_utilisateur = i.id_utilisateur
    LEFT JOIN connecter c ON u.id_utilisateur = c.id_utilisateur_1
    WHERE i.id_publication IN (
        SELECT id_publication FROM interagir WHERE id_utilisateur = user_id
    )
    AND u.id_utilisateur != user_id
    GROUP BY u.id_utilisateur, u.nom, u.email
    ORDER BY nb_connexions DESC
    LIMIT 5;
END;
$$;
 P   DROP FUNCTION public.recommander_connexions_selon_publication(user_id integer);
       public               postgres    false         	           1255    17013    recommander_groupes(integer)    FUNCTION     	  CREATE FUNCTION public.recommander_groupes(user_id integer) RETURNS TABLE(nom_groupe text, score_final double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    WITH themes_utilisateur AS (
        -- Récupérer les thèmes des groupes auxquels l'utilisateur appartient
        SELECT DISTINCT g.id_theme
        FROM adherer a
        JOIN groupe g ON a.id_groupe = g.id_groupe
        WHERE a.id_utilisateur = user_id
    ),
    groupes_parents AS (
        -- Recommander des groupes liés à un thème parent (pondération 0.7)
        SELECT g.nom::TEXT AS groupe_nom, COUNT(a.id_utilisateur) * 0.7 AS score
        FROM groupe g
        JOIN theme t ON g.id_theme = t.id_theme
        LEFT JOIN adherer a ON g.id_groupe = a.id_groupe
        WHERE t.id_theme IN (
            SELECT t.id_parent_theme FROM theme t WHERE t.id_theme IN (SELECT id_theme FROM themes_utilisateur)
        )
        GROUP BY g.nom, g.id_groupe
    ),
    groupes_apparents AS (
        -- Recommander d'autres groupes partageant le même thème parent (pondération 0.7)
        SELECT g.nom::TEXT AS groupe_nom, COUNT(a.id_utilisateur) * 0.7 AS score
        FROM groupe g
        JOIN theme t ON g.id_theme = t.id_theme
        LEFT JOIN adherer a ON g.id_groupe = a.id_groupe
        WHERE t.id_parent_theme IN (
            SELECT t.id_parent_theme FROM theme t WHERE t.id_theme IN (SELECT id_theme FROM themes_utilisateur)
        )
        AND g.id_theme NOT IN (SELECT id_theme FROM themes_utilisateur)
        GROUP BY g.nom, g.id_groupe
    ),
    groupes_tendances AS (
        -- Sélectionner les groupes tendances avec une pondération de 0.3
        SELECT g.nom::TEXT AS groupe_nom, SUM(calculer_score_engagement(p.id_publication)) * 0.3 AS score
        FROM publication p
        JOIN theme t ON p.id_theme = t.id_theme
        JOIN groupe g ON g.id_theme = t.id_theme
        GROUP BY g.nom, g.id_groupe
        ORDER BY SUM(calculer_score_engagement(p.id_publication)) DESC
        LIMIT 5
    )
    -- Fusionner toutes les recommandations et classer par score final
    SELECT groupe_nom, score FROM groupes_parents
    UNION ALL
    SELECT groupe_nom, score FROM groupes_apparents
    UNION ALL
    SELECT groupe_nom, score FROM groupes_tendances
    ORDER BY score DESC
    LIMIT 5;
END;
$$;
 ;   DROP FUNCTION public.recommander_groupes(user_id integer);
       public               postgres    false         
           1255    17014 +   suggerer_connexions_selon_contacts(integer)    FUNCTION     B  CREATE FUNCTION public.suggerer_connexions_selon_contacts(user_id integer) RETURNS TABLE(nom_utilisateur text, email_utilisateur text)
    LANGUAGE plpgsql
    AS $$ 
BEGIN
    RETURN QUERY
    SELECT u.nom::TEXT, u.email::TEXT
    FROM utilisateur u
    WHERE (
        SPLIT_PART(u.nom, ' ', 2) = SPLIT_PART((SELECT nom FROM utilisateur WHERE id_utilisateur = user_id), ' ', 2)
        OR (
            POSITION('@' IN u.email) > 0 
            AND SPLIT_PART(u.email, '@', 2) NOT IN ('gmail.com', 'yahoo.com', 'hotmail.com')
            AND SPLIT_PART((SELECT email FROM utilisateur WHERE id_utilisateur = user_id), '@', 2) = SPLIT_PART(u.email, '@', 2)
        )
    )
    AND u.id_utilisateur != user_id
    ORDER BY (SELECT COUNT(*) FROM connecter WHERE connecter.id_utilisateur_1 = u.id_utilisateur) DESC
    LIMIT 5;
END;
$$;
 J   DROP FUNCTION public.suggerer_connexions_selon_contacts(user_id integer);
       public               postgres    false                    1255    17015    suggérer_amis(integer)    FUNCTION     �  CREATE FUNCTION public."suggérer_amis"(nouvel_id integer) RETURNS TABLE(nom_utilisateur text, email_utilisateur text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    nom_nouvel_utilisateur TEXT;
    email_nouvel_utilisateur TEXT;
BEGIN
    SELECT nom, email INTO nom_nouvel_utilisateur, email_nouvel_utilisateur FROM utilisateur WHERE id_utilisateur = nouvel_id;

    RETURN QUERY
    SELECT u.nom::TEXT, u.email::TEXT
    FROM utilisateur u
    WHERE (
        -- Comparer le nom de famille (dernier mot du champ nom)
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
    AND u.id_utilisateur != nouvel_id
    ORDER BY (SELECT COUNT(*) FROM connecter WHERE connecter.id_utilisateur_1 = u.id_utilisateur) DESC
    LIMIT 5;
END;
$$;
 :   DROP FUNCTION public."suggérer_amis"(nouvel_id integer);
       public               postgres    false                    1255    17016    suggérer_groupes(integer)    FUNCTION     T  CREATE FUNCTION public."suggérer_groupes"(nouvel_id integer) RETURNS TABLE(theme text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT t.nom::TEXT
    FROM publication p
    JOIN theme t ON p.id_theme = t.id_theme
    GROUP BY t.nom
    ORDER BY SUM(calculer_score_engagement(p.id_publication)) DESC
    LIMIT 5;
END;
$$;
 =   DROP FUNCTION public."suggérer_groupes"(nouvel_id integer);
       public               postgres    false                    1255    17017    suggérer_publications()    FUNCTION     e  CREATE FUNCTION public."suggérer_publications"() RETURNS TABLE(id_publication integer, contenu text, type_publication text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT p.id_publication, p.contenu::TEXT, p.type_publication::TEXT
    FROM publication p
    ORDER BY calculer_score_engagement(p.id_publication) DESC
    LIMIT 5;
END;
$$;
 1   DROP FUNCTION public."suggérer_publications"();
       public               postgres    false                    1255    17018     themes_activite_recente(integer)    FUNCTION     u  CREATE FUNCTION public.themes_activite_recente(user_id integer) RETURNS TABLE(id_theme integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT p.id_theme
    FROM interagir i
    JOIN publication p ON i.id_publication = p.id_publication
    WHERE i.id_utilisateur = user_id
          AND i.date_interaction >= NOW() - INTERVAL '7 DAYS';
END;
$$;
 ?   DROP FUNCTION public.themes_activite_recente(user_id integer);
       public               postgres    false         �            1259    17019    adherer    TABLE     �   CREATE TABLE public.adherer (
    id_groupe integer NOT NULL,
    id_utilisateur integer NOT NULL,
    role character varying(50) NOT NULL,
    date_adhesion_debut date NOT NULL,
    date_adhesion_fin date
);
    DROP TABLE public.adherer;
       public         heap r       postgres    false         �            1259    17022    bloquer    TABLE     �   CREATE TABLE public.bloquer (
    id_utilisateur integer NOT NULL,
    id_utilisateur_bloque integer NOT NULL,
    type_blocage character varying(50) NOT NULL,
    date_debut date NOT NULL,
    date_fin date
);
    DROP TABLE public.bloquer;
       public         heap r       postgres    false         �            1259    17025 	   connecter    TABLE     �   CREATE TABLE public.connecter (
    id_utilisateur_1 integer NOT NULL,
    id_utilisateur_2 integer NOT NULL,
    type_connexion character varying(50) NOT NULL,
    date_connexion_debut date NOT NULL,
    date_connexion_fin date
);
    DROP TABLE public.connecter;
       public         heap r       postgres    false         �            1259    17028    groupe    TABLE     �   CREATE TABLE public.groupe (
    id_groupe integer NOT NULL,
    nom character varying(255) NOT NULL,
    id_theme integer NOT NULL,
    description text
);
    DROP TABLE public.groupe;
       public         heap r       postgres    false         �            1259    17033    groupe_id_groupe_seq    SEQUENCE     �   CREATE SEQUENCE public.groupe_id_groupe_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.groupe_id_groupe_seq;
       public               postgres    false    220         m           0    0    groupe_id_groupe_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.groupe_id_groupe_seq OWNED BY public.groupe.id_groupe;
          public               postgres    false    221         �            1259    17034 	   interagir    TABLE     +  CREATE TABLE public.interagir (
    id_interaction integer NOT NULL,
    id_publication integer NOT NULL,
    type_interaction character varying(50) NOT NULL,
    id_parent_interaction integer,
    contenu_commentaire text,
    date_interaction date NOT NULL,
    id_utilisateur integer NOT NULL
);
    DROP TABLE public.interagir;
       public         heap r       postgres    false         �            1259    17039    interagir_id_interaction_seq    SEQUENCE     �   CREATE SEQUENCE public.interagir_id_interaction_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.interagir_id_interaction_seq;
       public               postgres    false    222         n           0    0    interagir_id_interaction_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.interagir_id_interaction_seq OWNED BY public.interagir.id_interaction;
          public               postgres    false    223         �            1259    17153    partage    TABLE     �   CREATE TABLE public.partage (
    id_partage integer NOT NULL,
    id_utilisateur integer NOT NULL,
    id_publication integer NOT NULL,
    id_groupe integer NOT NULL,
    date_partage date NOT NULL
);
    DROP TABLE public.partage;
       public         heap r       postgres    false         �            1259    17152    partage_id_partage_seq    SEQUENCE     �   CREATE SEQUENCE public.partage_id_partage_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.partage_id_partage_seq;
       public               postgres    false    232         o           0    0    partage_id_partage_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.partage_id_partage_seq OWNED BY public.partage.id_partage;
          public               postgres    false    231         �            1259    17040    publication    TABLE     ?  CREATE TABLE public.publication (
    id_publication integer NOT NULL,
    contenu text NOT NULL,
    type_publication character varying(50) NOT NULL,
    visibilite character varying(50) NOT NULL,
    id_theme integer NOT NULL,
    date_creation date NOT NULL,
    id_utilisateur integer,
    contenu_duree integer
);
    DROP TABLE public.publication;
       public         heap r       postgres    false         p           0    0     COLUMN publication.contenu_duree    COMMENT     �  COMMENT ON COLUMN public.publication.contenu_duree IS 'Donne la durée totale des différents types de  publications : 

  - Vidéo : durée de la vidéo
  - Photo : Valeur par défaut de 5 secondes qui est 
                 le temps moyen de visionnage d''une 
                 photo
  - Textuel : à partir du nombre total de mot de la 
                   publication, on attribut 0.3s/mot (temps 
                  de visionnage moyen)';
          public               postgres    false    224         �            1259    17045    publication_id_publication_seq    SEQUENCE     �   CREATE SEQUENCE public.publication_id_publication_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 5   DROP SEQUENCE public.publication_id_publication_seq;
       public               postgres    false    224         q           0    0    publication_id_publication_seq    SEQUENCE OWNED BY     a   ALTER SEQUENCE public.publication_id_publication_seq OWNED BY public.publication.id_publication;
          public               postgres    false    225         �            1259    17046    theme    TABLE     �   CREATE TABLE public.theme (
    id_theme integer NOT NULL,
    nom character varying(255) NOT NULL,
    id_parent_theme integer
);
    DROP TABLE public.theme;
       public         heap r       postgres    false         �            1259    17049    theme_id_theme_seq    SEQUENCE     �   CREATE SEQUENCE public.theme_id_theme_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.theme_id_theme_seq;
       public               postgres    false    226         r           0    0    theme_id_theme_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.theme_id_theme_seq OWNED BY public.theme.id_theme;
          public               postgres    false    227         �            1259    17050    utilisateur    TABLE     �   CREATE TABLE public.utilisateur (
    id_utilisateur integer NOT NULL,
    nom character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    date_inscription date NOT NULL
);
    DROP TABLE public.utilisateur;
       public         heap r       postgres    false         �            1259    17055    utilisateur_id_utilisateur_seq    SEQUENCE     �   CREATE SEQUENCE public.utilisateur_id_utilisateur_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 5   DROP SEQUENCE public.utilisateur_id_utilisateur_seq;
       public               postgres    false    228         s           0    0    utilisateur_id_utilisateur_seq    SEQUENCE OWNED BY     a   ALTER SEQUENCE public.utilisateur_id_utilisateur_seq OWNED BY public.utilisateur.id_utilisateur;
          public               postgres    false    229         �            1259    17056 	   watchtime    TABLE     �   CREATE TABLE public.watchtime (
    id_utilisateur integer NOT NULL,
    id_publication integer NOT NULL,
    temps_debut time without time zone NOT NULL,
    temps_fin time without time zone NOT NULL,
    date_visionnage date NOT NULL
);
    DROP TABLE public.watchtime;
       public         heap r       postgres    false         �           2604    17059    groupe id_groupe    DEFAULT     t   ALTER TABLE ONLY public.groupe ALTER COLUMN id_groupe SET DEFAULT nextval('public.groupe_id_groupe_seq'::regclass);
 ?   ALTER TABLE public.groupe ALTER COLUMN id_groupe DROP DEFAULT;
       public               postgres    false    221    220         �           2604    17060    interagir id_interaction    DEFAULT     �   ALTER TABLE ONLY public.interagir ALTER COLUMN id_interaction SET DEFAULT nextval('public.interagir_id_interaction_seq'::regclass);
 G   ALTER TABLE public.interagir ALTER COLUMN id_interaction DROP DEFAULT;
       public               postgres    false    223    222         �           2604    17156    partage id_partage    DEFAULT     x   ALTER TABLE ONLY public.partage ALTER COLUMN id_partage SET DEFAULT nextval('public.partage_id_partage_seq'::regclass);
 A   ALTER TABLE public.partage ALTER COLUMN id_partage DROP DEFAULT;
       public               postgres    false    231    232    232         �           2604    17061    publication id_publication    DEFAULT     �   ALTER TABLE ONLY public.publication ALTER COLUMN id_publication SET DEFAULT nextval('public.publication_id_publication_seq'::regclass);
 I   ALTER TABLE public.publication ALTER COLUMN id_publication DROP DEFAULT;
       public               postgres    false    225    224         �           2604    17062    theme id_theme    DEFAULT     p   ALTER TABLE ONLY public.theme ALTER COLUMN id_theme SET DEFAULT nextval('public.theme_id_theme_seq'::regclass);
 =   ALTER TABLE public.theme ALTER COLUMN id_theme DROP DEFAULT;
       public               postgres    false    227    226         �           2604    17063    utilisateur id_utilisateur    DEFAULT     �   ALTER TABLE ONLY public.utilisateur ALTER COLUMN id_utilisateur SET DEFAULT nextval('public.utilisateur_id_utilisateur_seq'::regclass);
 I   ALTER TABLE public.utilisateur ALTER COLUMN id_utilisateur DROP DEFAULT;
       public               postgres    false    229    228         W          0    17019    adherer 
   TABLE DATA           j   COPY public.adherer (id_groupe, id_utilisateur, role, date_adhesion_debut, date_adhesion_fin) FROM stdin;
    public               postgres    false    217       4951.dat X          0    17022    bloquer 
   TABLE DATA           l   COPY public.bloquer (id_utilisateur, id_utilisateur_bloque, type_blocage, date_debut, date_fin) FROM stdin;
    public               postgres    false    218       4952.dat Y          0    17025 	   connecter 
   TABLE DATA           �   COPY public.connecter (id_utilisateur_1, id_utilisateur_2, type_connexion, date_connexion_debut, date_connexion_fin) FROM stdin;
    public               postgres    false    219       4953.dat Z          0    17028    groupe 
   TABLE DATA           G   COPY public.groupe (id_groupe, nom, id_theme, description) FROM stdin;
    public               postgres    false    220       4954.dat \          0    17034 	   interagir 
   TABLE DATA           �   COPY public.interagir (id_interaction, id_publication, type_interaction, id_parent_interaction, contenu_commentaire, date_interaction, id_utilisateur) FROM stdin;
    public               postgres    false    222       4956.dat f          0    17153    partage 
   TABLE DATA           f   COPY public.partage (id_partage, id_utilisateur, id_publication, id_groupe, date_partage) FROM stdin;
    public               postgres    false    232       4966.dat ^          0    17040    publication 
   TABLE DATA           �   COPY public.publication (id_publication, contenu, type_publication, visibilite, id_theme, date_creation, id_utilisateur, contenu_duree) FROM stdin;
    public               postgres    false    224       4958.dat `          0    17046    theme 
   TABLE DATA           ?   COPY public.theme (id_theme, nom, id_parent_theme) FROM stdin;
    public               postgres    false    226       4960.dat b          0    17050    utilisateur 
   TABLE DATA           S   COPY public.utilisateur (id_utilisateur, nom, email, date_inscription) FROM stdin;
    public               postgres    false    228       4962.dat d          0    17056 	   watchtime 
   TABLE DATA           l   COPY public.watchtime (id_utilisateur, id_publication, temps_debut, temps_fin, date_visionnage) FROM stdin;
    public               postgres    false    230       4964.dat t           0    0    groupe_id_groupe_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.groupe_id_groupe_seq', 1, false);
          public               postgres    false    221         u           0    0    interagir_id_interaction_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.interagir_id_interaction_seq', 111, true);
          public               postgres    false    223         v           0    0    partage_id_partage_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.partage_id_partage_seq', 1, false);
          public               postgres    false    231         w           0    0    publication_id_publication_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.publication_id_publication_seq', 1, false);
          public               postgres    false    225         x           0    0    theme_id_theme_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.theme_id_theme_seq', 1, false);
          public               postgres    false    227         y           0    0    utilisateur_id_utilisateur_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.utilisateur_id_utilisateur_seq', 43, true);
          public               postgres    false    229         �           2606    17065    adherer adherer_pkey 
   CONSTRAINT     i   ALTER TABLE ONLY public.adherer
    ADD CONSTRAINT adherer_pkey PRIMARY KEY (id_groupe, id_utilisateur);
 >   ALTER TABLE ONLY public.adherer DROP CONSTRAINT adherer_pkey;
       public                 postgres    false    217    217         �           2606    17067    bloquer bloquer_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.bloquer
    ADD CONSTRAINT bloquer_pkey PRIMARY KEY (id_utilisateur, id_utilisateur_bloque, date_debut);
 >   ALTER TABLE ONLY public.bloquer DROP CONSTRAINT bloquer_pkey;
       public                 postgres    false    218    218    218         �           2606    17069    connecter connecter_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.connecter
    ADD CONSTRAINT connecter_pkey PRIMARY KEY (id_utilisateur_1, id_utilisateur_2, date_connexion_debut);
 B   ALTER TABLE ONLY public.connecter DROP CONSTRAINT connecter_pkey;
       public                 postgres    false    219    219    219         �           2606    17071    groupe groupe_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.groupe
    ADD CONSTRAINT groupe_pkey PRIMARY KEY (id_groupe);
 <   ALTER TABLE ONLY public.groupe DROP CONSTRAINT groupe_pkey;
       public                 postgres    false    220         �           2606    17073    interagir interagir_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.interagir
    ADD CONSTRAINT interagir_pkey PRIMARY KEY (id_interaction);
 B   ALTER TABLE ONLY public.interagir DROP CONSTRAINT interagir_pkey;
       public                 postgres    false    222         �           2606    17158    partage partage_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.partage
    ADD CONSTRAINT partage_pkey PRIMARY KEY (id_partage);
 >   ALTER TABLE ONLY public.partage DROP CONSTRAINT partage_pkey;
       public                 postgres    false    232         �           2606    17075    publication publication_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.publication
    ADD CONSTRAINT publication_pkey PRIMARY KEY (id_publication);
 F   ALTER TABLE ONLY public.publication DROP CONSTRAINT publication_pkey;
       public                 postgres    false    224         �           2606    17077    theme theme_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.theme
    ADD CONSTRAINT theme_pkey PRIMARY KEY (id_theme);
 :   ALTER TABLE ONLY public.theme DROP CONSTRAINT theme_pkey;
       public                 postgres    false    226         �           2606    17079    utilisateur utilisateur_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.utilisateur
    ADD CONSTRAINT utilisateur_pkey PRIMARY KEY (id_utilisateur);
 F   ALTER TABLE ONLY public.utilisateur DROP CONSTRAINT utilisateur_pkey;
       public                 postgres    false    228         �           2606    17081    watchtime watchtime_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.watchtime
    ADD CONSTRAINT watchtime_pkey PRIMARY KEY (id_utilisateur, id_publication, date_visionnage);
 B   ALTER TABLE ONLY public.watchtime DROP CONSTRAINT watchtime_pkey;
       public                 postgres    false    230    230    230         �           2606    17082    adherer adherer_id_groupe_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.adherer
    ADD CONSTRAINT adherer_id_groupe_fkey FOREIGN KEY (id_groupe) REFERENCES public.groupe(id_groupe);
 H   ALTER TABLE ONLY public.adherer DROP CONSTRAINT adherer_id_groupe_fkey;
       public               postgres    false    4776    217    220         �           2606    17087 #   adherer adherer_id_utilisateur_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.adherer
    ADD CONSTRAINT adherer_id_utilisateur_fkey FOREIGN KEY (id_utilisateur) REFERENCES public.utilisateur(id_utilisateur);
 M   ALTER TABLE ONLY public.adherer DROP CONSTRAINT adherer_id_utilisateur_fkey;
       public               postgres    false    228    4784    217         �           2606    17092 *   bloquer bloquer_id_utilisateur_bloque_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.bloquer
    ADD CONSTRAINT bloquer_id_utilisateur_bloque_fkey FOREIGN KEY (id_utilisateur_bloque) REFERENCES public.utilisateur(id_utilisateur);
 T   ALTER TABLE ONLY public.bloquer DROP CONSTRAINT bloquer_id_utilisateur_bloque_fkey;
       public               postgres    false    228    218    4784         �           2606    17097 #   bloquer bloquer_id_utilisateur_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.bloquer
    ADD CONSTRAINT bloquer_id_utilisateur_fkey FOREIGN KEY (id_utilisateur) REFERENCES public.utilisateur(id_utilisateur);
 M   ALTER TABLE ONLY public.bloquer DROP CONSTRAINT bloquer_id_utilisateur_fkey;
       public               postgres    false    228    4784    218         �           2606    17102 )   connecter connecter_id_utilisateur_1_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.connecter
    ADD CONSTRAINT connecter_id_utilisateur_1_fkey FOREIGN KEY (id_utilisateur_1) REFERENCES public.utilisateur(id_utilisateur);
 S   ALTER TABLE ONLY public.connecter DROP CONSTRAINT connecter_id_utilisateur_1_fkey;
       public               postgres    false    219    228    4784         �           2606    17107 )   connecter connecter_id_utilisateur_2_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.connecter
    ADD CONSTRAINT connecter_id_utilisateur_2_fkey FOREIGN KEY (id_utilisateur_2) REFERENCES public.utilisateur(id_utilisateur);
 S   ALTER TABLE ONLY public.connecter DROP CONSTRAINT connecter_id_utilisateur_2_fkey;
       public               postgres    false    228    219    4784         �           2606    17112    groupe groupe_id_theme_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.groupe
    ADD CONSTRAINT groupe_id_theme_fkey FOREIGN KEY (id_theme) REFERENCES public.theme(id_theme);
 E   ALTER TABLE ONLY public.groupe DROP CONSTRAINT groupe_id_theme_fkey;
       public               postgres    false    220    4782    226         �           2606    17117 '   interagir interagir_id_publication_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.interagir
    ADD CONSTRAINT interagir_id_publication_fkey FOREIGN KEY (id_publication) REFERENCES public.publication(id_publication);
 Q   ALTER TABLE ONLY public.interagir DROP CONSTRAINT interagir_id_publication_fkey;
       public               postgres    false    224    4780    222         �           2606    17122 '   interagir interagir_id_utilisateur_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.interagir
    ADD CONSTRAINT interagir_id_utilisateur_fkey FOREIGN KEY (id_utilisateur) REFERENCES public.utilisateur(id_utilisateur);
 Q   ALTER TABLE ONLY public.interagir DROP CONSTRAINT interagir_id_utilisateur_fkey;
       public               postgres    false    222    228    4784         �           2606    17169    partage partage_id_groupe_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.partage
    ADD CONSTRAINT partage_id_groupe_fkey FOREIGN KEY (id_groupe) REFERENCES public.groupe(id_groupe) ON DELETE CASCADE;
 H   ALTER TABLE ONLY public.partage DROP CONSTRAINT partage_id_groupe_fkey;
       public               postgres    false    220    232    4776         �           2606    17164 #   partage partage_id_publication_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.partage
    ADD CONSTRAINT partage_id_publication_fkey FOREIGN KEY (id_publication) REFERENCES public.publication(id_publication) ON DELETE CASCADE;
 M   ALTER TABLE ONLY public.partage DROP CONSTRAINT partage_id_publication_fkey;
       public               postgres    false    232    4780    224         �           2606    17159 #   partage partage_id_utilisateur_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.partage
    ADD CONSTRAINT partage_id_utilisateur_fkey FOREIGN KEY (id_utilisateur) REFERENCES public.utilisateur(id_utilisateur) ON DELETE CASCADE;
 M   ALTER TABLE ONLY public.partage DROP CONSTRAINT partage_id_utilisateur_fkey;
       public               postgres    false    232    228    4784         �           2606    17127 %   publication publication_id_theme_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.publication
    ADD CONSTRAINT publication_id_theme_fkey FOREIGN KEY (id_theme) REFERENCES public.theme(id_theme);
 O   ALTER TABLE ONLY public.publication DROP CONSTRAINT publication_id_theme_fkey;
       public               postgres    false    224    226    4782         �           2606    17132 +   publication publication_id_utilisateur_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.publication
    ADD CONSTRAINT publication_id_utilisateur_fkey FOREIGN KEY (id_utilisateur) REFERENCES public.utilisateur(id_utilisateur) ON DELETE CASCADE;
 U   ALTER TABLE ONLY public.publication DROP CONSTRAINT publication_id_utilisateur_fkey;
       public               postgres    false    4784    228    224         �           2606    17137     theme theme_id_parent_theme_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.theme
    ADD CONSTRAINT theme_id_parent_theme_fkey FOREIGN KEY (id_parent_theme) REFERENCES public.theme(id_theme);
 J   ALTER TABLE ONLY public.theme DROP CONSTRAINT theme_id_parent_theme_fkey;
       public               postgres    false    4782    226    226         �           2606    17142 '   watchtime watchtime_id_publication_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.watchtime
    ADD CONSTRAINT watchtime_id_publication_fkey FOREIGN KEY (id_publication) REFERENCES public.publication(id_publication);
 Q   ALTER TABLE ONLY public.watchtime DROP CONSTRAINT watchtime_id_publication_fkey;
       public               postgres    false    4780    230    224         �           2606    17147 '   watchtime watchtime_id_utilisateur_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.watchtime
    ADD CONSTRAINT watchtime_id_utilisateur_fkey FOREIGN KEY (id_utilisateur) REFERENCES public.utilisateur(id_utilisateur);
 Q   ALTER TABLE ONLY public.watchtime DROP CONSTRAINT watchtime_id_utilisateur_fkey;
       public               postgres    false    4784    230    228                                                                                                                    4951.dat                                                                                            0000600 0004000 0002000 00000002356 14750436373 0014276 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	1	membre	2023-01-15	\N
1	2	membre	2023-02-20	2023-06-30
2	3	admin	2023-03-01	\N
2	4	membre	2023-03-12	2023-09-10
3	5	membre	2023-03-25	\N
3	6	admin	2023-04-01	2023-07-15
4	7	membre	2023-04-10	\N
4	8	membre	2023-04-20	2023-12-01
5	9	membre	2023-05-01	\N
5	10	admin	2023-05-10	2023-11-30
6	11	membre	2023-05-15	\N
6	12	membre	2023-05-20	2023-10-10
7	13	admin	2023-06-01	\N
7	14	membre	2023-06-10	2023-09-20
8	15	membre	2023-06-20	\N
8	16	membre	2023-07-01	2024-01-05
9	17	admin	2023-07-10	\N
9	18	membre	2023-07-20	2023-11-01
10	19	membre	2023-08-01	\N
10	20	admin	2023-08-10	2023-12-20
11	21	membre	2023-08-20	\N
11	22	membre	2023-09-01	2024-02-01
12	23	admin	2023-09-10	\N
12	24	membre	2023-09-20	2024-03-10
13	25	membre	2023-10-01	\N
13	26	membre	2023-10-10	2024-04-15
14	27	admin	2023-10-20	\N
14	28	membre	2023-11-01	2024-05-10
15	29	membre	2023-11-10	\N
15	30	admin	2023-11-20	2024-06-01
2	1	membre	2023-02-01	\N
3	2	membre	2023-04-01	\N
4	5	membre	2023-05-10	\N
5	6	membre	2023-06-15	\N
6	7	membre	2023-07-20	\N
7	8	membre	2023-08-05	\N
8	9	membre	2023-09-01	\N
9	10	membre	2023-09-15	\N
10	11	membre	2023-10-10	\N
11	12	membre	2023-10-25	\N
12	14	membre	2023-11-05	\N
13	16	membre	2023-11-20	\N
14	18	membre	2023-12-01	\N
15	20	membre	2023-12-15	\N
\.


                                                                                                                                                                                                                                                                                  4952.dat                                                                                            0000600 0004000 0002000 00000002020 14750436373 0014263 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	3	temporaire	2023-03-01	2023-03-10
2	1	permanent	2023-02-20	\N
4	5	temporaire	2023-04-07	2023-04-14
6	7	temporaire	2023-05-01	2023-05-05
8	9	permanent	2023-05-15	\N
10	11	temporaire	2023-06-01	2023-06-07
12	13	permanent	2023-06-20	\N
14	15	temporaire	2023-07-01	2023-07-10
16	17	temporaire	2023-07-20	2023-07-25
18	19	permanent	2023-08-01	\N
20	21	temporaire	2023-08-10	2023-08-20
22	23	temporaire	2023-09-01	2023-09-10
24	25	permanent	2023-09-15	\N
26	27	temporaire	2023-10-01	2023-10-10
28	29	permanent	2023-10-20	\N
30	1	temporaire	2023-11-01	2023-11-15
2	4	permanent	2023-11-10	\N
5	6	temporaire	2023-11-15	2023-11-25
7	8	permanent	2023-11-20	\N
9	10	temporaire	2023-12-01	2023-12-05
11	12	permanent	2023-12-10	\N
13	14	temporaire	2023-12-15	2023-12-20
15	16	temporaire	2023-12-20	2023-12-30
17	18	permanent	2023-12-25	\N
19	20	temporaire	2023-12-30	2024-01-05
21	22	permanent	2024-01-01	\N
23	24	temporaire	2024-01-05	2024-01-10
25	26	permanent	2024-01-10	\N
27	28	temporaire	2024-01-15	2024-01-20
29	30	permanent	2024-01-20	\N
\.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                4953.dat                                                                                            0000600 0004000 0002000 00000006512 14750436373 0014276 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	2	ami	2023-02-25	2023-05-10
1	3	ami	2023-03-15	\N
2	4	follower	2023-03-28	2023-06-20
3	5	ami	2023-04-05	\N
4	6	ami	2023-04-12	2023-07-01
5	7	follower	2023-04-22	\N
6	8	ami	2023-05-02	\N
7	9	ami	2023-05-12	2023-08-15
8	10	follower	2023-05-18	\N
9	11	ami	2023-05-22	\N
10	12	ami	2023-06-05	2023-09-10
11	13	follower	2023-06-12	\N
12	14	ami	2023-06-22	\N
13	15	ami	2023-07-02	2023-10-05
14	16	follower	2023-07-12	\N
15	17	ami	2023-07-22	\N
16	18	ami	2023-08-02	2023-11-01
17	19	follower	2023-08-12	\N
18	20	ami	2023-08-22	\N
19	21	ami	2023-09-02	2023-12-10
20	22	follower	2023-09-12	\N
21	23	ami	2023-09-22	\N
22	24	ami	2023-10-02	2024-01-15
23	25	follower	2023-10-12	\N
24	26	ami	2023-10-22	\N
25	27	ami	2023-11-02	2024-02-20
26	28	follower	2023-11-12	\N
27	29	ami	2023-11-22	\N
28	30	ami	2023-12-02	2024-03-05
29	1	follower	2023-12-10	\N
2	4	ami	2024-03-01	\N
3	6	ami	2024-03-02	\N
5	8	ami	2024-03-03	\N
6	9	ami	2024-03-04	\N
7	10	ami	2024-03-05	\N
9	12	ami	2024-03-06	\N
10	14	ami	2024-03-07	\N
12	15	ami	2024-03-08	\N
14	17	ami	2024-03-09	\N
16	18	ami	2024-03-10	\N
17	20	ami	2024-03-11	\N
19	22	ami	2024-03-12	\N
21	24	ami	2024-03-13	\N
23	26	ami	2024-03-14	\N
25	28	ami	2024-03-15	\N
27	30	ami	2024-03-16	\N
29	1	ami	2024-03-17	\N
30	3	ami	2024-03-18	\N
1	3	follower	2024-03-01	\N
2	4	follower	2024-03-02	\N
3	5	follower	2024-03-03	\N
4	6	follower	2024-03-04	\N
5	7	follower	2024-03-05	\N
6	8	follower	2024-03-06	\N
7	9	follower	2024-03-07	\N
8	10	follower	2024-03-08	\N
9	11	follower	2024-03-09	\N
10	12	follower	2024-03-10	\N
11	13	follower	2024-03-11	\N
12	14	follower	2024-03-12	\N
13	15	follower	2024-03-13	\N
14	16	follower	2024-03-14	\N
15	17	follower	2024-03-15	\N
16	18	follower	2024-03-16	\N
17	19	follower	2024-03-17	\N
18	20	follower	2024-03-18	\N
19	21	follower	2024-03-19	\N
20	22	follower	2024-03-20	\N
21	23	follower	2024-03-21	\N
22	24	follower	2024-03-22	\N
23	25	follower	2024-03-23	\N
24	26	follower	2024-03-24	\N
25	27	follower	2024-03-25	\N
26	28	follower	2024-03-26	\N
27	29	follower	2024-03-27	\N
28	30	follower	2024-03-28	\N
29	1	follower	2024-03-29	\N
30	2	follower	2024-03-30	\N
2	1	follower	2024-03-01	\N
3	1	follower	2024-03-02	\N
4	1	follower	2024-03-03	\N
5	1	follower	2024-03-04	\N
6	1	follower	2024-03-05	\N
7	1	follower	2024-03-06	\N
8	1	follower	2024-03-07	\N
9	1	follower	2024-03-08	\N
10	1	follower	2024-03-09	\N
11	1	follower	2024-03-10	\N
12	1	follower	2024-03-11	\N
13	1	follower	2024-03-12	\N
14	1	follower	2024-03-13	\N
15	1	follower	2024-03-14	\N
16	1	follower	2024-03-15	\N
17	1	follower	2024-03-16	\N
18	1	follower	2024-03-17	\N
19	1	follower	2024-03-18	\N
20	1	follower	2024-03-19	\N
21	1	follower	2024-03-20	\N
5	3	follower	2024-03-01	\N
6	3	follower	2024-03-02	\N
7	3	follower	2024-03-03	\N
8	3	follower	2024-03-04	\N
9	3	follower	2024-03-05	\N
10	3	follower	2024-03-06	\N
11	7	follower	2024-03-01	\N
12	7	follower	2024-03-02	\N
13	9	follower	2024-03-01	\N
14	9	follower	2024-03-02	\N
15	9	follower	2024-03-03	\N
16	9	follower	2024-03-04	\N
17	9	follower	2024-03-05	\N
18	9	follower	2024-03-06	\N
19	9	follower	2024-03-07	\N
20	11	follower	2024-03-01	\N
21	11	follower	2024-03-02	\N
22	11	follower	2024-03-03	\N
23	11	follower	2024-03-04	\N
24	11	follower	2024-03-05	\N
25	11	follower	2024-03-06	\N
26	15	follower	2024-03-01	\N
27	15	follower	2024-03-02	\N
28	15	follower	2024-03-03	\N
29	15	follower	2024-03-04	\N
30	15	follower	2024-03-05	\N
\.


                                                                                                                                                                                      4954.dat                                                                                            0000600 0004000 0002000 00000003576 14750436373 0014306 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	Développement Web	2	Groupe pour discuter des tendances du développement web
6	Développement Mobile	2	Discussions sur les frameworks mobiles
13	Programmation Front-End	2	Tout sur le développement web côté client
14	Programmation Back-End	2	Groupe pour les passionnés de serveurs
2	Intelligence Artificielle	21	Espace pour partager des ressources sur l’IA
3	UI/UX Design	18	Discussions sur les bonnes pratiques en design
4	Big Data	6	Ressources et articles sur la gestion de données massives
5	Sécurité Informatique	11	Groupe sur les stratégies de sécurité
7	Blockchain	15	Nouveautés et tutoriels sur la blockchain
8	Internet des Objets	10	Groupe sur les innovations IoT
9	Cybersécurité	11	Echanges sur la cybersécurité et les bonnes pratiques
10	Cloud Computing	9	Partage de ressources sur le cloud
11	Analyse de Données	9	Approches modernes d’analyse de données
12	Intelligence Artificielle Avancée	21	Discussions poussées sur l’IA avancée
15	DevOps	13	Meilleures pratiques DevOps
16	Open Source	24	Partage de projets open source
17	Automatisation	14	Discussions sur l’automatisation des tâches
18	Éthique et IA	21	Réflexions sur l’éthique dans les technologies
19	Jeux Vidéo	30	Discussions sur le développement de jeux vidéo
20	Design Graphique	18	Partage de projets graphiques
21	Photographie	29	Techniques et innovations en photographie
22	Réseaux	12	Discussion sur les réseaux informatiques
23	Bases de Données	20	Approfondissement des bases de données
24	Machine Learning	7	Partage de ressources sur le ML
25	Robotique	23	Innovations en robotique
26	Cryptographie	22	Discussions sur la cryptographie
27	Programmation C++	28	Tutoriels et partage de projets en C++
28	Programmation Python	26	Groupe pour les passionnés de Python
29	Systèmes embarqués	23	Discussions techniques sur les systèmes embarqués
30	Réalité Virtuelle	16	Innovations et projets en VR
\.


                                                                                                                                  4956.dat                                                                                            0000600 0004000 0002000 00000004707 14750436373 0014305 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	1	like	\N	\N	2023-01-21	1
3	3	like	\N	\N	2023-02-16	3
6	6	like	\N	\N	2023-04-02	6
7	7	comment	\N	Quels outils recommandez-vous ?	2023-04-11	7
8	8	like	\N	\N	2023-04-22	8
10	10	like	\N	\N	2023-05-16	10
11	11	comment	\N	Merci pour cet article.	2023-05-21	11
12	12	like	\N	\N	2023-06-02	12
13	13	comment	\N	Peut-on avoir un exemple ?	2023-06-12	13
14	14	like	\N	\N	2023-06-21	14
17	17	comment	\N	Un plaisir à lire.	2023-08-02	17
18	18	like	\N	\N	2023-08-12	18
19	19	comment	\N	Merci beaucoup !	2023-08-22	19
20	20	like	\N	\N	2023-09-02	20
21	21	comment	\N	Impressionnant.	2023-09-16	21
22	22	like	\N	\N	2023-09-21	22
23	23	comment	\N	Où trouver plus d’infos ?	2023-10-02	23
24	24	like	\N	\N	2023-10-12	24
25	25	comment	\N	Super article, bravo !	2023-10-17	25
26	26	like	\N	\N	2023-11-02	26
27	27	comment	\N	Merci pour cet éclairage.	2023-11-11	27
28	28	like	\N	\N	2023-11-21	28
29	29	comment	\N	Instructif et clair.	2023-12-02	29
30	30	like	\N	\N	2023-12-16	30
2	2	comment	9	Très clair, merci !	2023-02-12	2
4	4	comment	9	Excellent résumé.	2023-03-02	4
5	5	like	4	\N	2023-03-17	5
9	9	comment	\N	Comment était mon résumé ? 	2023-01-02	9
15	15	comment	9	Très complet.	2023-07-02	15
16	16	like	9	\N	2023-07-16	16
31	5	partage	\N	\N	2023-12-20	8
32	12	partage	\N	\N	2023-12-21	15
33	9	like	9	\N	2023-12-10	2
34	12	like	9	\N	2023-12-21	18
35	9	partage	\N	\N	2023-11-10	5
36	14	like	9	\N	2023-12-21	18
38	1	comment	\N	Super intéressant !	2023-02-15	5
39	2	like	\N	\N	2023-02-20	6
40	3	comment	\N	Je suis d’accord !	2023-03-05	7
41	4	like	\N	\N	2023-03-10	8
42	5	partage	\N	\N	2023-03-18	9
43	6	comment	\N	Très bien expliqué.	2023-03-25	10
44	7	like	\N	\N	2023-03-30	11
45	1	partage	\N	\N	2023-04-01	12
46	2	comment	2	Oui, totalement !	2023-04-05	13
47	3	like	\N	\N	2023-04-10	14
48	4	comment	\N	Merci pour cet article.	2023-04-15	15
49	5	like	\N	\N	2023-04-20	16
50	6	comment	6	Intéressant, mais j’ai une question.	2023-04-25	17
51	7	partage	\N	\N	2023-05-01	18
52	1	comment	\N	Où puis-je trouver plus d’infos ?	2023-05-05	19
53	2	like	\N	\N	2023-05-10	20
54	3	comment	\N	Super résumé !	2023-05-15	21
55	4	partage	\N	\N	2023-05-20	22
56	5	comment	5	Bien vu !	2023-05-25	23
57	6	like	\N	\N	2023-06-01	24
58	7	comment	\N	J’adore cette analyse.	2023-06-05	25
59	1	like	\N	\N	2023-06-10	26
60	2	partage	\N	\N	2023-06-15	27
61	3	comment	\N	Est-ce que cela fonctionne pour tous les cas ?	2023-06-20	28
62	4	like	\N	\N	2023-06-25	29
63	5	comment	\N	Merci pour l’info !	2023-07-01	30
\.


                                                         4966.dat                                                                                            0000600 0004000 0002000 00000000667 14750436373 0014307 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	5	17	11	2023-08-05
2	10	18	2	2023-08-12
3	15	19	10	2023-08-25
4	20	20	16	2023-09-05
5	25	21	24	2023-09-18
6	30	22	27	2023-09-22
7	7	23	23	2023-10-03
8	12	24	26	2023-10-12
9	18	25	21	2023-10-16
10	22	26	9	2023-11-03
11	3	27	25	2023-11-12
12	8	28	28	2023-11-21
13	14	29	19	2023-12-03
14	19	30	18	2023-12-17
15	1	1	23	2023-01-25
16	6	2	24	2023-02-12
17	11	3	9	2023-02-18
18	16	4	1	2023-03-05
19	21	5	17	2023-03-20
20	26	6	4	2023-04-05
\.


                                                                         4958.dat                                                                                            0000600 0004000 0002000 00000004027 14750436373 0014302 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	Introduction aux bases de données	texte	public	20	2023-01-20	1	309
2	Les bases du Machine Learning	video	membre	7	2023-02-10	2	607
3	Top 5 des outils pour la cybersécurité	texte	membre	11	2023-02-15	2	120
4	Les nouveautés de HTML5	video	public	25	2023-03-01	3	301
5	Introduction à l’automatisation des tests	photo	public	14	2023-03-15	4	5
6	Guide complet sur le Big Data	texte	public	6	2023-04-01	5	1802
7	Développer des applications avec Python	texte	membre	26	2023-04-10	6	1504
8	Tutoriel sur les réseaux informatiques	photo	public	12	2023-04-20	7	5
9	Découverte de la cryptographie	texte	membre	22	2023-05-01	8	180
10	Les tendances en Blockchain	video	public	15	2023-05-15	9	122
11	Améliorer le design UX	texte	public	18	2023-05-20	9	330
13	Les bases du DevOps	photo	membre	13	2023-06-10	13	5
14	Programmation avancée en Java	photo	membre	27	2023-06-20	13	5
15	Explorer les systèmes embarqués	texte	public	23	2023-07-01	15	304
16	Le futur de l’IA	photo	membre	21	2023-07-15	16	5
17	Techniques de Data Science	texte	public	19	2023-08-01	18	666
18	Nouveautés en réalité augmentée	texte	public	17	2023-08-10	18	303
19	L’évolution des technologies Cloud	video	public	9	2023-08-20	19	708
20	Les avantages du code open source	texte	membre	24	2023-09-01	21	122
21	Tutoriel sur le Machine Learning avancé	texte	public	7	2023-09-15	21	808
22	Programmation efficace avec C++	photo	public	28	2023-09-20	22	5
23	Comment optimiser vos requêtes SQL	photo	membre	20	2023-10-01	24	5
24	Introduction au développement mobile	texte	public	25	2023-10-10	24	602
25	Photographie numérique : astuces	video	membre	29	2023-10-15	25	601
26	La cybersécurité en entreprise	texte	public	11	2023-11-01	27	606
27	Les innovations dans la robotique	photo	public	23	2023-11-10	28	5
28	Data visualisation avec Python	photo	membre	26	2023-11-20	29	5
29	Créer un jeu vidéo en Unity	texte	public	30	2023-12-01	30	1800
30	Le guide ultime de l’éthique en IA	texte	membre	21	2023-12-15	30	888
12	Initiation à la réalité virtuelle	video	public	16	2023-06-01	12	1000
\.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         4960.dat                                                                                            0000600 0004000 0002000 00000001161 14750436373 0014267 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	Technologie	\N
2	Programmation	1
3	Data Science	1
4	Conception	1
5	Sécurité	1
6	Big Data	3
7	Machine Learning	3
8	Deep Learning	7
9	Cloud Computing	1
10	Internet des Objets	1
11	Cybersécurité	5
12	Réseaux	5
13	DevOps	1
14	Automatisation	1
15	Blockchain	5
16	Réalité Virtuelle	4
17	Réalité Augmentée	4
18	UI/UX Design	4
19	Analyse de Données	3
20	Bases de Données	1
21	Intelligence Artificielle	3
22	Cryptographie	5
23	Systèmes Embarqués	1
24	Open Source	1
25	Langages de Programmation	2
26	Programmation Python	25
27	Programmation Java	25
28	Programmation C++	25
29	Photographie Numérique	4
30	Gaming	4
\.


                                                                                                                                                                                                                                                                                                                                                                                                               4962.dat                                                                                            0000600 0004000 0002000 00000003311 14750436373 0014270 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	Alice Dupont	alice.dupont@example.com	2023-01-15
2	Bob Martin	bob.martin@example.com	2023-02-20
3	Charlie Nguyen	charlie.nguyen@example.com	2023-03-10
4	Diane Leroy	diane.leroy@example.com	2023-03-25
5	Eve Blanc	eve.blanc@example.com	2023-04-01
6	Fabien Morel	fabien.morel@example.com	2023-04-10
7	Georges Lefevre	georges.lefevre@example.com	2023-04-20
8	Hélène Dubois	helene.dubois@example.com	2023-05-01
9	Isabelle Renaud	isabelle.renaud@example.com	2023-05-10
10	Julien Petit	julien.petit@example.com	2023-05-15
11	Karim Youssef	karim.youssef@example.com	2023-05-20
12	Laurence Simon	laurence.simon@example.com	2023-06-01
13	Marc Verdier	marc.verdier@example.com	2023-06-10
14	Nadia Clément	nadia.clement@example.com	2023-06-20
15	Olivier Durand	olivier.durand@example.com	2023-07-01
16	Pauline Millet	pauline.millet@example.com	2023-07-10
17	Quentin Lemoine	quentin.lemoine@example.com	2023-07-20
18	Romain Fontaine	romain.fontaine@example.com	2023-08-01
19	Sophie Charron	sophie.charron@example.com	2023-08-10
20	Thomas Giraud	thomas.giraud@example.com	2023-08-20
21	Ursula Lefebvre	ursula.lefebvre@example.com	2023-09-01
22	Vincent Chevalier	vincent.chevalier@example.com	2023-09-10
23	William Robert	william.robert@example.com	2023-09-20
24	Xavier Mercier	xavier.mercier@example.com	2023-10-01
25	Yasmine Boucher	yasmine.boucher@example.com	2023-10-10
26	Zacharie Lambert	zacharie.lambert@example.com	2023-10-20
27	Anne Dupuis	anne.dupuis@example.com	2023-11-01
28	Bruno Vasseur	bruno.vasseur@example.com	2023-11-10
29	Claire Perrot	claire.perrot@example.com	2023-11-20
30	David Colin	david.colin@example.com	2023-12-01
42	Jean Dupont	jean.dupont@exemple.com	2025-02-02
43	Jean Dupont	jean.dupont@exemple.com	2025-02-02
\.


                                                                                                                                                                                                                                                                                                                       4964.dat                                                                                            0000600 0004000 0002000 00000006503 14750436373 0014300 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	2	10:00:00	10:15:00	2023-02-25
1	4	11:00:00	11:20:00	2023-03-01
3	10	09:00:00	09:20:00	2023-05-20
3	19	10:30:00	10:55:00	2023-06-01
5	25	15:00:00	15:20:00	2023-10-10
6	2	13:00:00	13:25:00	2023-06-10
6	10	14:00:00	14:30:00	2023-07-15
9	19	16:30:00	16:50:00	2023-09-10
9	25	17:10:00	17:40:00	2023-09-20
10	25	17:00:00	17:30:00	2023-11-10
12	4	10:45:00	11:00:00	2023-07-12
12	19	12:10:00	12:30:00	2023-07-20
14	19	11:30:00	11:50:00	2023-10-05
14	25	14:45:00	15:10:00	2023-10-15
17	4	15:00:00	15:20:00	2023-09-22
17	10	16:15:00	16:40:00	2023-09-25
19	19	16:45:00	17:10:00	2023-11-12
19	25	18:00:00	18:25:00	2023-11-15
22	4	11:15:00	11:40:00	2023-10-15
23	10	14:25:00	14:50:00	2023-11-05
23	19	15:30:00	15:50:00	2023-11-10
25	25	10:05:00	10:30:00	2024-01-01
27	4	16:00:00	16:25:00	2023-12-10
27	10	17:15:00	17:45:00	2023-12-15
30	25	18:30:00	18:50:00	2024-04-01
1	2	10:00:00	10:10:00	2024-02-02
2	3	11:15:00	11:30:00	2024-02-03
3	4	14:00:00	14:20:00	2024-02-04
5	6	12:20:00	12:35:00	2024-02-06
6	7	16:40:00	17:00:00	2024-02-07
8	9	07:00:00	07:15:00	2024-02-09
9	10	21:45:00	22:00:00	2024-02-10
10	11	23:00:00	23:20:00	2024-02-11
1	12	08:00:00	08:15:00	2024-02-12
4	15	17:50:00	18:05:00	2024-02-15
6	17	06:50:00	07:05:00	2024-02-17
7	18	09:10:00	09:25:00	2024-02-18
8	19	11:45:00	12:00:00	2024-02-19
9	20	20:00:00	20:15:00	2024-02-20
10	21	22:30:00	22:45:00	2024-02-21
1	2	10:00:00	10:12:00	2024-02-01
2	2	12:15:00	12:30:00	2024-02-01
3	2	14:45:00	15:00:00	2024-02-01
4	3	09:00:00	09:18:00	2024-02-02
5	3	20:00:00	20:30:00	2024-02-02
6	4	11:10:00	11:35:00	2024-02-03
7	4	22:50:00	23:05:00	2024-02-03
1	6	10:10:00	10:25:00	2024-02-05
2	6	14:00:00	14:20:00	2024-02-05
3	7	08:30:00	08:50:00	2024-02-06
4	7	19:15:00	19:30:00	2024-02-06
7	9	10:30:00	10:50:00	2024-02-08
8	9	15:45:00	16:00:00	2024-02-08
9	10	21:00:00	21:15:00	2024-02-09
10	10	07:10:00	07:25:00	2024-02-09
1	11	11:30:00	11:50:00	2024-02-10
2	11	18:20:00	18:35:00	2024-02-10
3	12	14:10:00	14:30:00	2024-02-11
4	12	09:50:00	10:10:00	2024-02-11
5	12	22:10:00	22:25:00	2024-02-11
10	15	23:00:00	23:20:00	2024-02-14
1	15	08:20:00	08:35:00	2024-02-14
4	17	19:40:00	20:00:00	2024-02-16
5	17	09:15:00	09:35:00	2024-02-16
6	18	11:50:00	12:10:00	2024-02-17
7	18	14:45:00	15:05:00	2024-02-17
8	19	18:30:00	18:50:00	2024-02-18
9	19	22:10:00	22:30:00	2024-02-18
10	20	07:30:00	07:50:00	2024-02-19
1	20	12:40:00	13:00:00	2024-02-19
2	21	17:20:00	17:40:00	2024-02-20
3	21	21:45:00	22:05:00	2024-02-20
1	26	09:00:00	09:15:00	2024-02-21
2	26	11:30:00	11:45:00	2024-02-21
3	26	15:10:00	15:25:00	2024-02-21
10	29	08:10:00	08:25:00	2024-02-24
1	29	14:30:00	14:50:00	2024-02-24
2	29	19:15:00	19:30:00	2024-02-24
4	5	09:30:00	09:30:05	2024-02-05
8	5	13:25:00	13:25:02	2024-02-04
9	5	18:40:00	18:40:09	2024-02-04
10	5	07:30:00	07:30:04	2024-02-05
2	16	10:50:00	10:50:13	2024-02-15
3	16	15:30:00	15:30:06	2024-02-15
5	16	19:20:00	19:20:03	2024-02-16
4	27	10:20:00	10:20:06	2024-02-22
5	27	13:50:00	13:50:03	2024-02-22
6	27	17:00:00	17:00:03	2024-02-22
7	28	12:00:00	12:00:01	2024-02-23
8	28	18:30:00	18:30:04	2024-02-23
9	28	20:45:00	20:45:02	2024-02-23
3	14	15:10:00	15:10:01	2024-02-14
8	14	17:30:00	17:30:02	2024-02-13
9	14	20:15:00	20:15:01	2024-02-13
5	8	12:45:00	12:45:12	2024-02-07
6	8	17:10:00	17:10:04	2024-02-07
7	8	18:10:00	18:10:10	2024-02-08
2	13	13:30:00	13:30:04	2024-02-13
6	13	06:40:00	06:40:03	2024-02-12
7	13	13:20:00	13:20:08	2024-02-12
\.


                                                                                                                                                                                             restore.sql                                                                                         0000600 0004000 0002000 00000143444 14750436373 0015412 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        --
-- NOTE:
--
-- File paths need to be edited. Search for $$PATH$$ and
-- replace it with the path to the directory containing
-- the extracted data files.
--
--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2
-- Dumped by pg_dump version 17.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE "Projet_BDR";
--
-- Name: Projet_BDR; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE "Projet_BDR" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_United Kingdom.1252';


ALTER DATABASE "Projet_BDR" OWNER TO postgres;

\connect "Projet_BDR"

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: ajouter_utilisateur(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ajouter_utilisateur(nom_utilisateur text, email_utilisateur text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    nouvel_id INT;
BEGIN
    INSERT INTO utilisateur (nom, email, date_inscription) 
    VALUES (nom_utilisateur, email_utilisateur, CURRENT_DATE)
    RETURNING id_utilisateur INTO nouvel_id;
    RETURN nouvel_id;
END;
$$;


ALTER FUNCTION public.ajouter_utilisateur(nom_utilisateur text, email_utilisateur text) OWNER TO postgres;

--
-- Name: ajouter_utilisateur(text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ajouter_utilisateur(nom text, prenom text, email text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    nouvel_id INT;
BEGIN
    INSERT INTO utilisateur (nom, prenom, email, date_inscription) 
    VALUES (nom, prenom, email, CURRENT_DATE)
    RETURNING id_utilisateur INTO nouvel_id;
    
    RETURN nouvel_id;
END;
$$;


ALTER FUNCTION public.ajouter_utilisateur(nom text, prenom text, email text) OWNER TO postgres;

--
-- Name: analyse_utilisateurs_hors_cercle(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.analyse_utilisateurs_hors_cercle() RETURNS TABLE(attribut text, valeur_top_utilisateurs numeric, valeur_population_generale numeric)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.analyse_utilisateurs_hors_cercle() OWNER TO postgres;

--
-- Name: calculer_influence_utilisateur(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculer_influence_utilisateur(user_id integer) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
DECLARE
    score_publications FLOAT;
    score_commentaires FLOAT;
    score_partages FLOAT;
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
$$;


ALTER FUNCTION public.calculer_influence_utilisateur(user_id integer) OWNER TO postgres;

--
-- Name: calculer_nombre_followers(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculer_nombre_followers(utilisateur_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    nombre_followers INT;
BEGIN
    SELECT COALESCE(COUNT(*), 0)
    INTO nombre_followers
    FROM connecter
    WHERE id_utilisateur_2 = utilisateur_id;

    RETURN nombre_followers;
END;
$$;


ALTER FUNCTION public.calculer_nombre_followers(utilisateur_id integer) OWNER TO postgres;

--
-- Name: calculer_score_commentaires(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculer_score_commentaires(commentaire_id integer) RETURNS double precision
    LANGUAGE plpgsql
    AS $$ 
DECLARE
    score_base FLOAT := 1.0;
    score_likes FLOAT;
    score_reponses FLOAT;
    score_likes_reponses FLOAT;
    score_total FLOAT;
BEGIN
    -- Score des likes sur le commentaire
    SELECT COALESCE(SUM(calculer_nombre_followers(i.id_utilisateur) * 0.2), 0) 
    INTO score_likes
    FROM interagir i
    WHERE i.id_parent_interaction = commentaire_id 
          AND i.type_interaction = 'like';

    -- Nombre de réponses (chaque réponse ajoute un point)
    SELECT COALESCE(COUNT(*), 0) 
    INTO score_reponses
    FROM interagir ic
    WHERE ic.id_parent_interaction = commentaire_id 
          AND ic.type_interaction = 'comment';

    -- Score des likes sur les réponses aux commentaires
    SELECT COALESCE(SUM(calculer_nombre_followers(i.id_utilisateur) * 0.1), 0) 
    INTO score_likes_reponses
    FROM interagir i
    WHERE i.type_interaction = 'like' 
          AND i.id_parent_interaction IN (
              SELECT ic.id_interaction 
              FROM interagir ic 
              WHERE ic.id_parent_interaction = commentaire_id 
                    AND ic.type_interaction = 'comment'
          );

    -- Ajout du score des sous-commentaires de manière récursive
    SELECT COALESCE(SUM(calculer_score_commentaires(ic.id_interaction) * 0.5), 0)
    INTO score_reponses
    FROM interagir ic
    WHERE ic.id_parent_interaction = commentaire_id 
          AND ic.type_interaction = 'comment';

    -- Calcul du score total en combinant les éléments
    score_total := score_base + (score_likes * 0.5) + (score_reponses * 0.5) + (score_likes_reponses * 0.25);

    RETURN score_total;
END;
$$;


ALTER FUNCTION public.calculer_score_commentaires(commentaire_id integer) OWNER TO postgres;

--
-- Name: calculer_score_engagement(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculer_score_engagement(publication_id integer) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
DECLARE
    score_watchtime FLOAT;
    score_likes FLOAT;
    score_commentaires FLOAT;
    score_partages FLOAT;
    engagement FLOAT;
BEGIN
    --  Récupérer les scores individuels
    score_watchtime := calculer_score_watchtime(publication_id);
    score_likes := calculer_score_likes(publication_id);
    score_partages := calculer_score_partages(publication_id);

    --  Calculer le score total des commentaires de cette publication
    SELECT COALESCE(SUM(calculer_score_commentaires(i.id_interaction)), 0)
    INTO score_commentaires
    FROM interagir i
    WHERE i.id_publication = publication_id 
          AND i.type_interaction = 'comment';

    --  Fusionner les scores avec pondération
    engagement := (score_watchtime * 0.35) + (score_likes * 0.25) + (score_commentaires * 0.25) + (score_partages * 0.15);

    --  Retourner le score final
    RETURN engagement;
END;
$$;


ALTER FUNCTION public.calculer_score_engagement(publication_id integer) OWNER TO postgres;

--
-- Name: calculer_score_likes(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculer_score_likes(publication_id integer) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
DECLARE
    score_likes FLOAT;
BEGIN
    SELECT COALESCE(SUM(LOG(10, calculer_nombre_followers(i.id_utilisateur) + 1)), 0) 
    INTO score_likes
    FROM interagir i
    WHERE i.type_interaction = 'like'
          AND i.id_publication = publication_id;

    RETURN score_likes;
END;
$$;


ALTER FUNCTION public.calculer_score_likes(publication_id integer) OWNER TO postgres;

--
-- Name: calculer_score_partages(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculer_score_partages(publication_id integer) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
DECLARE
    score_partages FLOAT;
BEGIN
    SELECT COALESCE(SUM(0.5 + (calculer_nombre_followers(i.id_utilisateur) * 0.05)), 0) 
    INTO score_partages
    FROM interagir i
    WHERE i.type_interaction = 'partage'
          AND i.id_publication = publication_id;

    RETURN score_partages;
END;
$$;


ALTER FUNCTION public.calculer_score_partages(publication_id integer) OWNER TO postgres;

--
-- Name: calculer_score_watchtime(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculer_score_watchtime(publication_id integer) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
DECLARE
    total_watchtime FLOAT;
    nombre_vues INT;
    duree_moyenne FLOAT;
    duree_totale FLOAT;
    ratio FLOAT;
    score FLOAT;
BEGIN
    -- 1️⃣ Calcul du total du watchtime et du nombre de vues
    SELECT 
        COALESCE(SUM(EXTRACT(EPOCH FROM (temps_fin - temps_debut))) / 60, 0), 
        COUNT(*)
    INTO total_watchtime, nombre_vues
    FROM watchtime
    WHERE id_publication = publication_id;

    -- 2️⃣ Éviter la division par zéro
    IF nombre_vues > 0 THEN
        duree_moyenne := total_watchtime / nombre_vues;
    ELSE
        duree_moyenne := 0;
    END IF;

    -- 3️⃣ Récupérer la durée totale de la publication et éviter NULL
    SELECT COALESCE(contenu_duree, 1) INTO duree_totale
    FROM publication 
    WHERE id_publication = publication_id;

    -- 4️⃣ Calcul du ratio de visionnage
    ratio := (duree_moyenne / duree_totale) * 100;

    -- 5️⃣ Calcul du score avec pondération logarithmique
    score := ratio * LOG(10, nombre_vues + 1);

    -- 6️⃣ Retourner le score ou 0 si aucune donnée n’existe
    RETURN COALESCE(score, 0);
END;
$$;


ALTER FUNCTION public.calculer_score_watchtime(publication_id integer) OWNER TO postgres;

--
-- Name: classement_interactions_hors_cercle(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.classement_interactions_hors_cercle() RETURNS TABLE(id_utilisateur integer, nom text, interactions_hors_cercle integer, score_hors_cercle numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id_utilisateur,
        u.nom::TEXT,  
        COUNT(i.id_interaction)::INT AS interactions_hors_cercle,  
        SUM(
            CASE 
                WHEN i.type_interaction = 'comment' THEN 3
                WHEN i.type_interaction = 'partage' THEN 2
                WHEN i.type_interaction = 'like' THEN 1
                ELSE 0
            END
        )::NUMERIC AS score_hors_cercle
    FROM utilisateur u
    LEFT JOIN interagir i ON u.id_utilisateur = i.id_utilisateur
    WHERE i.id_publication IN (
        SELECT p.id_publication FROM publication p
        WHERE p.visibilite = 'public'
    )
    GROUP BY u.id_utilisateur, u.nom
    ORDER BY score_hors_cercle DESC;
END;
$$;


ALTER FUNCTION public.classement_interactions_hors_cercle() OWNER TO postgres;

--
-- Name: classement_utilisateurs_hors_cercle(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.classement_utilisateurs_hors_cercle() RETURNS TABLE(id_utilisateur integer, nom text, taux_hors_cercle double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT u.id_utilisateur, u.nom::TEXT, 
           COALESCE((interactions_hors_cercle(u.id_utilisateur)::FLOAT / NULLIF(COUNT(i.id_interaction), 0)) * 100, 0) AS taux_hors_cercle
    FROM utilisateur u
    LEFT JOIN interagir i ON u.id_utilisateur = i.id_utilisateur
    GROUP BY u.id_utilisateur, u.nom
    HAVING COALESCE((interactions_hors_cercle(u.id_utilisateur)::FLOAT / NULLIF(COUNT(i.id_interaction), 0)) * 100, 0) > 30
    ORDER BY taux_hors_cercle DESC;
END;
$$;


ALTER FUNCTION public.classement_utilisateurs_hors_cercle() OWNER TO postgres;

--
-- Name: interactions_hors_cercle(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.interactions_hors_cercle(user_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    total_hors_cercle INT;
BEGIN
    SELECT COUNT(*) INTO total_hors_cercle
    FROM interagir i
    JOIN publication p ON i.id_publication = p.id_publication
    LEFT JOIN connecter c ON i.id_utilisateur = c.id_utilisateur_2 
                          AND c.id_utilisateur_1 = user_id
    WHERE i.id_utilisateur != user_id
    AND p.visibilite = 'public'
    AND c.id_utilisateur_1 IS NULL; 

    RETURN COALESCE(total_hors_cercle, 0);
END;
$$;


ALTER FUNCTION public.interactions_hors_cercle(user_id integer) OWNER TO postgres;

--
-- Name: intégrer_utilisateur(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."intégrer_utilisateur"(nom_utilisateur text, email_utilisateur text) RETURNS TABLE(type text, info text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    nouvel_id INT;
BEGIN
    nouvel_id := ajouter_utilisateur(nom_utilisateur, email_utilisateur);

    RETURN QUERY
    SELECT 'Utilisateur créé'::TEXT, 'ID: ' || nouvel_id::TEXT;

    RETURN QUERY
    SELECT 'Ami suggéré'::TEXT, sa.nom_utilisateur || ' (' || sa.email_utilisateur || ')'
    FROM suggérer_amis(nouvel_id) sa;

    RETURN QUERY
    SELECT 'Groupe suggéré'::TEXT, sg.theme
    FROM suggérer_groupes(nouvel_id) sg;

    RETURN QUERY
    SELECT 'Publication tendance'::TEXT, sp.contenu || ' (' || sp.type_publication || ')'
    FROM suggérer_publications() sp;
END;
$$;


ALTER FUNCTION public."intégrer_utilisateur"(nom_utilisateur text, email_utilisateur text) OWNER TO postgres;

--
-- Name: intégrer_utilisateur(text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."intégrer_utilisateur"(nom text, prenom text, email text) RETURNS TABLE(type text, info text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    nouvel_id INT;
BEGIN
    -- 1️⃣ Ajouter l'utilisateur et récupérer son ID
    nouvel_id := ajouter_utilisateur(nom, prenom, email);

    -- 2️⃣ Retourner l'ID du nouvel utilisateur
    RETURN QUERY
    SELECT 'Utilisateur créé' AS type, 'ID: ' || nouvel_id::TEXT AS info;
    
    -- 3️⃣ Retourner les amis suggérés
    RETURN QUERY
    SELECT 'Ami suggéré' AS type, nom || ' ' || prenom || ' (' || email || ')' AS info
    FROM suggérer_amis(nouvel_id);

    -- 4️⃣ Retourner les groupes suggérés
    RETURN QUERY
    SELECT 'Groupe suggéré' AS type, theme || ' (Score: ' || score_engagement_total || ')' AS info
    FROM suggérer_groupes(nouvel_id);

    -- 5️⃣ Retourner les publications tendances
    RETURN QUERY
    SELECT 'Publication tendance' AS type, contenu || ' (' || type_publication || ')' AS info
    FROM suggérer_publications();
END;
$$;


ALTER FUNCTION public."intégrer_utilisateur"(nom text, prenom text, email text) OWNER TO postgres;

--
-- Name: recommander_activite(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.recommander_activite(user_id integer) RETURNS TABLE(type text, suggestion text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Ajouter les groupes suggérés
    RETURN QUERY
    SELECT 'Groupe recommandé'::TEXT, rg.nom_groupe || ' (' || rg.nb_membres || ' membres)'
    FROM recommander_groupes(user_id) rg;

    -- Ajouter les connexions suggérées
    RETURN QUERY
    SELECT 'Connexion suggérée'::TEXT, rc.nom_utilisateur || ' (' || rc.email_utilisateur || ', ' || rc.nb_connexions || ' connexions communes)'
    FROM recommander_connexions(user_id) rc;
END;
$$;


ALTER FUNCTION public.recommander_activite(user_id integer) OWNER TO postgres;

--
-- Name: recommander_connexions(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.recommander_connexions(user_id integer) RETURNS TABLE(nom_utilisateur text, email_utilisateur text, nb_connexions integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT u.nom::TEXT, u.email::TEXT, COUNT(c.id_utilisateur_2)::INT AS nb_connexions  -- 🔥 Conversion explicite en INT
    FROM utilisateur u
    JOIN interagir i ON u.id_utilisateur = i.id_utilisateur
    LEFT JOIN connecter c ON u.id_utilisateur = c.id_utilisateur_1
    WHERE i.id_publication IN (
        SELECT id_publication FROM interagir WHERE id_utilisateur = user_id
    )
    AND u.id_utilisateur != user_id
    GROUP BY u.id_utilisateur, u.nom, u.email
    ORDER BY nb_connexions DESC
    LIMIT 5;
END;
$$;


ALTER FUNCTION public.recommander_connexions(user_id integer) OWNER TO postgres;

--
-- Name: recommander_connexions_globale(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.recommander_connexions_globale(user_id integer) RETURNS TABLE(nom_utilisateur text, email_utilisateur text, score_final double precision)
    LANGUAGE plpgsql
    AS $$ 
BEGIN
    RETURN QUERY
    WITH connexions_interactions AS (
        -- 50% basé sur les interactions dans les mêmes publications
        SELECT rc.nom_utilisateur, rc.email_utilisateur, CAST(COUNT(rc.nb_connexions) * 0.5 AS FLOAT) AS score
        FROM recommander_connexions_selon_publication(user_id) rc
        GROUP BY rc.nom_utilisateur, rc.email_utilisateur
    ),
    connexions_groupes AS (
        -- 30% basé sur les connexions dans les mêmes groupes
        SELECT rg.nom_utilisateur, rg.email_utilisateur, CAST(COUNT(rg.nb_groupes_communs) * 0.3 AS FLOAT) AS score
        FROM recommander_connexions_selon_groupe(user_id) rg
        GROUP BY rg.nom_utilisateur, rg.email_utilisateur
    ),
    connexions_activite_recente AS (
        -- 20% basé sur les suggestions d'amis
        SELECT sa.nom_utilisateur, sa.email_utilisateur, CAST(0.2 AS FLOAT) AS score
        FROM suggerer_connexions_selon_contacts(user_id) sa
    )
    -- Fusionner toutes les recommandations et appliquer la pondération
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
$$;


ALTER FUNCTION public.recommander_connexions_globale(user_id integer) OWNER TO postgres;

--
-- Name: recommander_connexions_selon_contacts(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.recommander_connexions_selon_contacts(user_id integer) RETURNS TABLE(nom_utilisateur text, email_utilisateur text, nb_connexions integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT u.nom::TEXT, u.email::TEXT, COUNT(c.id_utilisateur_2)::INT AS nb_connexions
    FROM utilisateur u
    JOIN interagir i ON u.id_utilisateur = i.id_utilisateur
    LEFT JOIN connecter c ON u.id_utilisateur = c.id_utilisateur_1
    WHERE i.id_publication IN (
        SELECT id_publication FROM interagir WHERE id_utilisateur = user_id
    )
    AND u.id_utilisateur != user_id
    GROUP BY u.id_utilisateur, u.nom, u.email
    ORDER BY nb_connexions DESC
    LIMIT 5;
END;
$$;


ALTER FUNCTION public.recommander_connexions_selon_contacts(user_id integer) OWNER TO postgres;

--
-- Name: recommander_connexions_selon_groupe(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.recommander_connexions_selon_groupe(user_id integer) RETURNS TABLE(nom_utilisateur text, email_utilisateur text, nb_groupes_communs integer)
    LANGUAGE plpgsql
    AS $$ 
BEGIN
    RETURN QUERY
    SELECT u2.nom::TEXT, u2.email::TEXT, COUNT(a2.id_groupe)::INT AS nb_groupes_communs
    FROM adherer a1
    JOIN adherer a2 ON a1.id_groupe = a2.id_groupe
    JOIN utilisateur u2 ON a2.id_utilisateur = u2.id_utilisateur
    WHERE a1.id_utilisateur = user_id
    AND u2.id_utilisateur != user_id
    GROUP BY u2.id_utilisateur, u2.nom, u2.email
    ORDER BY nb_groupes_communs DESC
    LIMIT 5;
END;
$$;


ALTER FUNCTION public.recommander_connexions_selon_groupe(user_id integer) OWNER TO postgres;

--
-- Name: recommander_connexions_selon_publication(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.recommander_connexions_selon_publication(user_id integer) RETURNS TABLE(nom_utilisateur text, email_utilisateur text, nb_connexions integer)
    LANGUAGE plpgsql
    AS $$ 
BEGIN
    RETURN QUERY
    SELECT u.nom::TEXT, u.email::TEXT, COUNT(c.id_utilisateur_2)::INT AS nb_connexions
    FROM utilisateur u
    JOIN interagir i ON u.id_utilisateur = i.id_utilisateur
    LEFT JOIN connecter c ON u.id_utilisateur = c.id_utilisateur_1
    WHERE i.id_publication IN (
        SELECT id_publication FROM interagir WHERE id_utilisateur = user_id
    )
    AND u.id_utilisateur != user_id
    GROUP BY u.id_utilisateur, u.nom, u.email
    ORDER BY nb_connexions DESC
    LIMIT 5;
END;
$$;


ALTER FUNCTION public.recommander_connexions_selon_publication(user_id integer) OWNER TO postgres;

--
-- Name: recommander_groupes(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.recommander_groupes(user_id integer) RETURNS TABLE(nom_groupe text, score_final double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    WITH themes_utilisateur AS (
        -- Récupérer les thèmes des groupes auxquels l'utilisateur appartient
        SELECT DISTINCT g.id_theme
        FROM adherer a
        JOIN groupe g ON a.id_groupe = g.id_groupe
        WHERE a.id_utilisateur = user_id
    ),
    groupes_parents AS (
        -- Recommander des groupes liés à un thème parent (pondération 0.7)
        SELECT g.nom::TEXT AS groupe_nom, COUNT(a.id_utilisateur) * 0.7 AS score
        FROM groupe g
        JOIN theme t ON g.id_theme = t.id_theme
        LEFT JOIN adherer a ON g.id_groupe = a.id_groupe
        WHERE t.id_theme IN (
            SELECT t.id_parent_theme FROM theme t WHERE t.id_theme IN (SELECT id_theme FROM themes_utilisateur)
        )
        GROUP BY g.nom, g.id_groupe
    ),
    groupes_apparents AS (
        -- Recommander d'autres groupes partageant le même thème parent (pondération 0.7)
        SELECT g.nom::TEXT AS groupe_nom, COUNT(a.id_utilisateur) * 0.7 AS score
        FROM groupe g
        JOIN theme t ON g.id_theme = t.id_theme
        LEFT JOIN adherer a ON g.id_groupe = a.id_groupe
        WHERE t.id_parent_theme IN (
            SELECT t.id_parent_theme FROM theme t WHERE t.id_theme IN (SELECT id_theme FROM themes_utilisateur)
        )
        AND g.id_theme NOT IN (SELECT id_theme FROM themes_utilisateur)
        GROUP BY g.nom, g.id_groupe
    ),
    groupes_tendances AS (
        -- Sélectionner les groupes tendances avec une pondération de 0.3
        SELECT g.nom::TEXT AS groupe_nom, SUM(calculer_score_engagement(p.id_publication)) * 0.3 AS score
        FROM publication p
        JOIN theme t ON p.id_theme = t.id_theme
        JOIN groupe g ON g.id_theme = t.id_theme
        GROUP BY g.nom, g.id_groupe
        ORDER BY SUM(calculer_score_engagement(p.id_publication)) DESC
        LIMIT 5
    )
    -- Fusionner toutes les recommandations et classer par score final
    SELECT groupe_nom, score FROM groupes_parents
    UNION ALL
    SELECT groupe_nom, score FROM groupes_apparents
    UNION ALL
    SELECT groupe_nom, score FROM groupes_tendances
    ORDER BY score DESC
    LIMIT 5;
END;
$$;


ALTER FUNCTION public.recommander_groupes(user_id integer) OWNER TO postgres;

--
-- Name: suggerer_connexions_selon_contacts(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.suggerer_connexions_selon_contacts(user_id integer) RETURNS TABLE(nom_utilisateur text, email_utilisateur text)
    LANGUAGE plpgsql
    AS $$ 
BEGIN
    RETURN QUERY
    SELECT u.nom::TEXT, u.email::TEXT
    FROM utilisateur u
    WHERE (
        SPLIT_PART(u.nom, ' ', 2) = SPLIT_PART((SELECT nom FROM utilisateur WHERE id_utilisateur = user_id), ' ', 2)
        OR (
            POSITION('@' IN u.email) > 0 
            AND SPLIT_PART(u.email, '@', 2) NOT IN ('gmail.com', 'yahoo.com', 'hotmail.com')
            AND SPLIT_PART((SELECT email FROM utilisateur WHERE id_utilisateur = user_id), '@', 2) = SPLIT_PART(u.email, '@', 2)
        )
    )
    AND u.id_utilisateur != user_id
    ORDER BY (SELECT COUNT(*) FROM connecter WHERE connecter.id_utilisateur_1 = u.id_utilisateur) DESC
    LIMIT 5;
END;
$$;


ALTER FUNCTION public.suggerer_connexions_selon_contacts(user_id integer) OWNER TO postgres;

--
-- Name: suggérer_amis(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."suggérer_amis"(nouvel_id integer) RETURNS TABLE(nom_utilisateur text, email_utilisateur text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    nom_nouvel_utilisateur TEXT;
    email_nouvel_utilisateur TEXT;
BEGIN
    SELECT nom, email INTO nom_nouvel_utilisateur, email_nouvel_utilisateur FROM utilisateur WHERE id_utilisateur = nouvel_id;

    RETURN QUERY
    SELECT u.nom::TEXT, u.email::TEXT
    FROM utilisateur u
    WHERE (
        -- Comparer le nom de famille (dernier mot du champ nom)
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
    AND u.id_utilisateur != nouvel_id
    ORDER BY (SELECT COUNT(*) FROM connecter WHERE connecter.id_utilisateur_1 = u.id_utilisateur) DESC
    LIMIT 5;
END;
$$;


ALTER FUNCTION public."suggérer_amis"(nouvel_id integer) OWNER TO postgres;

--
-- Name: suggérer_groupes(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."suggérer_groupes"(nouvel_id integer) RETURNS TABLE(theme text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT t.nom::TEXT
    FROM publication p
    JOIN theme t ON p.id_theme = t.id_theme
    GROUP BY t.nom
    ORDER BY SUM(calculer_score_engagement(p.id_publication)) DESC
    LIMIT 5;
END;
$$;


ALTER FUNCTION public."suggérer_groupes"(nouvel_id integer) OWNER TO postgres;

--
-- Name: suggérer_publications(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."suggérer_publications"() RETURNS TABLE(id_publication integer, contenu text, type_publication text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT p.id_publication, p.contenu::TEXT, p.type_publication::TEXT
    FROM publication p
    ORDER BY calculer_score_engagement(p.id_publication) DESC
    LIMIT 5;
END;
$$;


ALTER FUNCTION public."suggérer_publications"() OWNER TO postgres;

--
-- Name: themes_activite_recente(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.themes_activite_recente(user_id integer) RETURNS TABLE(id_theme integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT p.id_theme
    FROM interagir i
    JOIN publication p ON i.id_publication = p.id_publication
    WHERE i.id_utilisateur = user_id
          AND i.date_interaction >= NOW() - INTERVAL '7 DAYS';
END;
$$;


ALTER FUNCTION public.themes_activite_recente(user_id integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: adherer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adherer (
    id_groupe integer NOT NULL,
    id_utilisateur integer NOT NULL,
    role character varying(50) NOT NULL,
    date_adhesion_debut date NOT NULL,
    date_adhesion_fin date
);


ALTER TABLE public.adherer OWNER TO postgres;

--
-- Name: bloquer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bloquer (
    id_utilisateur integer NOT NULL,
    id_utilisateur_bloque integer NOT NULL,
    type_blocage character varying(50) NOT NULL,
    date_debut date NOT NULL,
    date_fin date
);


ALTER TABLE public.bloquer OWNER TO postgres;

--
-- Name: connecter; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.connecter (
    id_utilisateur_1 integer NOT NULL,
    id_utilisateur_2 integer NOT NULL,
    type_connexion character varying(50) NOT NULL,
    date_connexion_debut date NOT NULL,
    date_connexion_fin date
);


ALTER TABLE public.connecter OWNER TO postgres;

--
-- Name: groupe; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.groupe (
    id_groupe integer NOT NULL,
    nom character varying(255) NOT NULL,
    id_theme integer NOT NULL,
    description text
);


ALTER TABLE public.groupe OWNER TO postgres;

--
-- Name: groupe_id_groupe_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.groupe_id_groupe_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.groupe_id_groupe_seq OWNER TO postgres;

--
-- Name: groupe_id_groupe_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.groupe_id_groupe_seq OWNED BY public.groupe.id_groupe;


--
-- Name: interagir; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.interagir (
    id_interaction integer NOT NULL,
    id_publication integer NOT NULL,
    type_interaction character varying(50) NOT NULL,
    id_parent_interaction integer,
    contenu_commentaire text,
    date_interaction date NOT NULL,
    id_utilisateur integer NOT NULL
);


ALTER TABLE public.interagir OWNER TO postgres;

--
-- Name: interagir_id_interaction_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.interagir_id_interaction_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.interagir_id_interaction_seq OWNER TO postgres;

--
-- Name: interagir_id_interaction_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.interagir_id_interaction_seq OWNED BY public.interagir.id_interaction;


--
-- Name: partage; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.partage (
    id_partage integer NOT NULL,
    id_utilisateur integer NOT NULL,
    id_publication integer NOT NULL,
    id_groupe integer NOT NULL,
    date_partage date NOT NULL
);


ALTER TABLE public.partage OWNER TO postgres;

--
-- Name: partage_id_partage_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.partage_id_partage_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.partage_id_partage_seq OWNER TO postgres;

--
-- Name: partage_id_partage_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.partage_id_partage_seq OWNED BY public.partage.id_partage;


--
-- Name: publication; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.publication (
    id_publication integer NOT NULL,
    contenu text NOT NULL,
    type_publication character varying(50) NOT NULL,
    visibilite character varying(50) NOT NULL,
    id_theme integer NOT NULL,
    date_creation date NOT NULL,
    id_utilisateur integer,
    contenu_duree integer
);


ALTER TABLE public.publication OWNER TO postgres;

--
-- Name: COLUMN publication.contenu_duree; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.publication.contenu_duree IS 'Donne la durée totale des différents types de  publications : 

  - Vidéo : durée de la vidéo
  - Photo : Valeur par défaut de 5 secondes qui est 
                 le temps moyen de visionnage d''une 
                 photo
  - Textuel : à partir du nombre total de mot de la 
                   publication, on attribut 0.3s/mot (temps 
                  de visionnage moyen)';


--
-- Name: publication_id_publication_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.publication_id_publication_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.publication_id_publication_seq OWNER TO postgres;

--
-- Name: publication_id_publication_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.publication_id_publication_seq OWNED BY public.publication.id_publication;


--
-- Name: theme; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.theme (
    id_theme integer NOT NULL,
    nom character varying(255) NOT NULL,
    id_parent_theme integer
);


ALTER TABLE public.theme OWNER TO postgres;

--
-- Name: theme_id_theme_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.theme_id_theme_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.theme_id_theme_seq OWNER TO postgres;

--
-- Name: theme_id_theme_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.theme_id_theme_seq OWNED BY public.theme.id_theme;


--
-- Name: utilisateur; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.utilisateur (
    id_utilisateur integer NOT NULL,
    nom character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    date_inscription date NOT NULL
);


ALTER TABLE public.utilisateur OWNER TO postgres;

--
-- Name: utilisateur_id_utilisateur_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.utilisateur_id_utilisateur_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.utilisateur_id_utilisateur_seq OWNER TO postgres;

--
-- Name: utilisateur_id_utilisateur_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.utilisateur_id_utilisateur_seq OWNED BY public.utilisateur.id_utilisateur;


--
-- Name: watchtime; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.watchtime (
    id_utilisateur integer NOT NULL,
    id_publication integer NOT NULL,
    temps_debut time without time zone NOT NULL,
    temps_fin time without time zone NOT NULL,
    date_visionnage date NOT NULL
);


ALTER TABLE public.watchtime OWNER TO postgres;

--
-- Name: groupe id_groupe; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groupe ALTER COLUMN id_groupe SET DEFAULT nextval('public.groupe_id_groupe_seq'::regclass);


--
-- Name: interagir id_interaction; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interagir ALTER COLUMN id_interaction SET DEFAULT nextval('public.interagir_id_interaction_seq'::regclass);


--
-- Name: partage id_partage; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.partage ALTER COLUMN id_partage SET DEFAULT nextval('public.partage_id_partage_seq'::regclass);


--
-- Name: publication id_publication; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publication ALTER COLUMN id_publication SET DEFAULT nextval('public.publication_id_publication_seq'::regclass);


--
-- Name: theme id_theme; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.theme ALTER COLUMN id_theme SET DEFAULT nextval('public.theme_id_theme_seq'::regclass);


--
-- Name: utilisateur id_utilisateur; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utilisateur ALTER COLUMN id_utilisateur SET DEFAULT nextval('public.utilisateur_id_utilisateur_seq'::regclass);


--
-- Data for Name: adherer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.adherer (id_groupe, id_utilisateur, role, date_adhesion_debut, date_adhesion_fin) FROM stdin;
\.
COPY public.adherer (id_groupe, id_utilisateur, role, date_adhesion_debut, date_adhesion_fin) FROM '$$PATH$$/4951.dat';

--
-- Data for Name: bloquer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bloquer (id_utilisateur, id_utilisateur_bloque, type_blocage, date_debut, date_fin) FROM stdin;
\.
COPY public.bloquer (id_utilisateur, id_utilisateur_bloque, type_blocage, date_debut, date_fin) FROM '$$PATH$$/4952.dat';

--
-- Data for Name: connecter; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.connecter (id_utilisateur_1, id_utilisateur_2, type_connexion, date_connexion_debut, date_connexion_fin) FROM stdin;
\.
COPY public.connecter (id_utilisateur_1, id_utilisateur_2, type_connexion, date_connexion_debut, date_connexion_fin) FROM '$$PATH$$/4953.dat';

--
-- Data for Name: groupe; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groupe (id_groupe, nom, id_theme, description) FROM stdin;
\.
COPY public.groupe (id_groupe, nom, id_theme, description) FROM '$$PATH$$/4954.dat';

--
-- Data for Name: interagir; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.interagir (id_interaction, id_publication, type_interaction, id_parent_interaction, contenu_commentaire, date_interaction, id_utilisateur) FROM stdin;
\.
COPY public.interagir (id_interaction, id_publication, type_interaction, id_parent_interaction, contenu_commentaire, date_interaction, id_utilisateur) FROM '$$PATH$$/4956.dat';

--
-- Data for Name: partage; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.partage (id_partage, id_utilisateur, id_publication, id_groupe, date_partage) FROM stdin;
\.
COPY public.partage (id_partage, id_utilisateur, id_publication, id_groupe, date_partage) FROM '$$PATH$$/4966.dat';

--
-- Data for Name: publication; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.publication (id_publication, contenu, type_publication, visibilite, id_theme, date_creation, id_utilisateur, contenu_duree) FROM stdin;
\.
COPY public.publication (id_publication, contenu, type_publication, visibilite, id_theme, date_creation, id_utilisateur, contenu_duree) FROM '$$PATH$$/4958.dat';

--
-- Data for Name: theme; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.theme (id_theme, nom, id_parent_theme) FROM stdin;
\.
COPY public.theme (id_theme, nom, id_parent_theme) FROM '$$PATH$$/4960.dat';

--
-- Data for Name: utilisateur; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.utilisateur (id_utilisateur, nom, email, date_inscription) FROM stdin;
\.
COPY public.utilisateur (id_utilisateur, nom, email, date_inscription) FROM '$$PATH$$/4962.dat';

--
-- Data for Name: watchtime; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.watchtime (id_utilisateur, id_publication, temps_debut, temps_fin, date_visionnage) FROM stdin;
\.
COPY public.watchtime (id_utilisateur, id_publication, temps_debut, temps_fin, date_visionnage) FROM '$$PATH$$/4964.dat';

--
-- Name: groupe_id_groupe_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.groupe_id_groupe_seq', 1, false);


--
-- Name: interagir_id_interaction_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.interagir_id_interaction_seq', 111, true);


--
-- Name: partage_id_partage_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.partage_id_partage_seq', 1, false);


--
-- Name: publication_id_publication_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.publication_id_publication_seq', 1, false);


--
-- Name: theme_id_theme_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.theme_id_theme_seq', 1, false);


--
-- Name: utilisateur_id_utilisateur_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.utilisateur_id_utilisateur_seq', 43, true);


--
-- Name: adherer adherer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adherer
    ADD CONSTRAINT adherer_pkey PRIMARY KEY (id_groupe, id_utilisateur);


--
-- Name: bloquer bloquer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bloquer
    ADD CONSTRAINT bloquer_pkey PRIMARY KEY (id_utilisateur, id_utilisateur_bloque, date_debut);


--
-- Name: connecter connecter_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.connecter
    ADD CONSTRAINT connecter_pkey PRIMARY KEY (id_utilisateur_1, id_utilisateur_2, date_connexion_debut);


--
-- Name: groupe groupe_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groupe
    ADD CONSTRAINT groupe_pkey PRIMARY KEY (id_groupe);


--
-- Name: interagir interagir_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interagir
    ADD CONSTRAINT interagir_pkey PRIMARY KEY (id_interaction);


--
-- Name: partage partage_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.partage
    ADD CONSTRAINT partage_pkey PRIMARY KEY (id_partage);


--
-- Name: publication publication_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publication
    ADD CONSTRAINT publication_pkey PRIMARY KEY (id_publication);


--
-- Name: theme theme_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.theme
    ADD CONSTRAINT theme_pkey PRIMARY KEY (id_theme);


--
-- Name: utilisateur utilisateur_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utilisateur
    ADD CONSTRAINT utilisateur_pkey PRIMARY KEY (id_utilisateur);


--
-- Name: watchtime watchtime_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.watchtime
    ADD CONSTRAINT watchtime_pkey PRIMARY KEY (id_utilisateur, id_publication, date_visionnage);


--
-- Name: adherer adherer_id_groupe_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adherer
    ADD CONSTRAINT adherer_id_groupe_fkey FOREIGN KEY (id_groupe) REFERENCES public.groupe(id_groupe);


--
-- Name: adherer adherer_id_utilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adherer
    ADD CONSTRAINT adherer_id_utilisateur_fkey FOREIGN KEY (id_utilisateur) REFERENCES public.utilisateur(id_utilisateur);


--
-- Name: bloquer bloquer_id_utilisateur_bloque_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bloquer
    ADD CONSTRAINT bloquer_id_utilisateur_bloque_fkey FOREIGN KEY (id_utilisateur_bloque) REFERENCES public.utilisateur(id_utilisateur);


--
-- Name: bloquer bloquer_id_utilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bloquer
    ADD CONSTRAINT bloquer_id_utilisateur_fkey FOREIGN KEY (id_utilisateur) REFERENCES public.utilisateur(id_utilisateur);


--
-- Name: connecter connecter_id_utilisateur_1_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.connecter
    ADD CONSTRAINT connecter_id_utilisateur_1_fkey FOREIGN KEY (id_utilisateur_1) REFERENCES public.utilisateur(id_utilisateur);


--
-- Name: connecter connecter_id_utilisateur_2_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.connecter
    ADD CONSTRAINT connecter_id_utilisateur_2_fkey FOREIGN KEY (id_utilisateur_2) REFERENCES public.utilisateur(id_utilisateur);


--
-- Name: groupe groupe_id_theme_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groupe
    ADD CONSTRAINT groupe_id_theme_fkey FOREIGN KEY (id_theme) REFERENCES public.theme(id_theme);


--
-- Name: interagir interagir_id_publication_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interagir
    ADD CONSTRAINT interagir_id_publication_fkey FOREIGN KEY (id_publication) REFERENCES public.publication(id_publication);


--
-- Name: interagir interagir_id_utilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interagir
    ADD CONSTRAINT interagir_id_utilisateur_fkey FOREIGN KEY (id_utilisateur) REFERENCES public.utilisateur(id_utilisateur);


--
-- Name: partage partage_id_groupe_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.partage
    ADD CONSTRAINT partage_id_groupe_fkey FOREIGN KEY (id_groupe) REFERENCES public.groupe(id_groupe) ON DELETE CASCADE;


--
-- Name: partage partage_id_publication_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.partage
    ADD CONSTRAINT partage_id_publication_fkey FOREIGN KEY (id_publication) REFERENCES public.publication(id_publication) ON DELETE CASCADE;


--
-- Name: partage partage_id_utilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.partage
    ADD CONSTRAINT partage_id_utilisateur_fkey FOREIGN KEY (id_utilisateur) REFERENCES public.utilisateur(id_utilisateur) ON DELETE CASCADE;


--
-- Name: publication publication_id_theme_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publication
    ADD CONSTRAINT publication_id_theme_fkey FOREIGN KEY (id_theme) REFERENCES public.theme(id_theme);


--
-- Name: publication publication_id_utilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publication
    ADD CONSTRAINT publication_id_utilisateur_fkey FOREIGN KEY (id_utilisateur) REFERENCES public.utilisateur(id_utilisateur) ON DELETE CASCADE;


--
-- Name: theme theme_id_parent_theme_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.theme
    ADD CONSTRAINT theme_id_parent_theme_fkey FOREIGN KEY (id_parent_theme) REFERENCES public.theme(id_theme);


--
-- Name: watchtime watchtime_id_publication_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.watchtime
    ADD CONSTRAINT watchtime_id_publication_fkey FOREIGN KEY (id_publication) REFERENCES public.publication(id_publication);


--
-- Name: watchtime watchtime_id_utilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.watchtime
    ADD CONSTRAINT watchtime_id_utilisateur_fkey FOREIGN KEY (id_utilisateur) REFERENCES public.utilisateur(id_utilisateur);


--
-- PostgreSQL database dump complete
--

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            