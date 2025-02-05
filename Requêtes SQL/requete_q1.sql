WITH RECURSIVE amis_indirects AS (
    -- Niveau 1 : Trouver les amis directs
    SELECT c1.id_utilisateur_1 AS utilisateur, c2.id_utilisateur_2 AS ami, 1 AS niveau
    FROM connecter c1
    JOIN connecter c2 ON c1.id_utilisateur_2 = c2.id_utilisateur_1

    UNION

    -- Niveau 2 : Trouver les amis d'amis
    SELECT ai.utilisateur, c.id_utilisateur_2 AS ami, 2 AS niveau
    FROM amis_indirects ai
    JOIN connecter c ON ai.ami = c.id_utilisateur_1
    WHERE ai.niveau = 1 -- On s'arrête après 2 niveaux
)
SELECT ai.utilisateur, 
       ai.ami, 
       STRING_AGG(DISTINCT g.nom, ', ') AS centres_interet_communs
FROM amis_indirects ai
LEFT JOIN adherer a1 ON ai.utilisateur = a1.id_utilisateur
LEFT JOIN adherer a2 ON ai.ami = a2.id_utilisateur AND a1.id_groupe = a2.id_groupe
LEFT JOIN groupe g ON a1.id_groupe = g.id_groupe
WHERE ai.utilisateur != ai.ami -- Exclure les auto-relations
AND ai.ami NOT IN (
    SELECT id_utilisateur_2 FROM connecter WHERE id_utilisateur_1 = ai.utilisateur
) -- Exclure les amis directs
GROUP BY ai.utilisateur, ai.ami
ORDER BY ai.utilisateur, ai.ami;
