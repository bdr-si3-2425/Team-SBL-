WITH RECURSIVE amis_indirects AS (
    -- Trouver les amis des amis pour tous les utilisateurs
    SELECT c1.id_utilisateur_1 AS utilisateur, c2.id_utilisateur_2 AS ami_indirect
    FROM connecter c1
    JOIN connecter c2 ON c1.id_utilisateur_2 = c2.id_utilisateur_1
    WHERE c2.id_utilisateur_2 NOT IN (
        SELECT id_utilisateur_2 FROM connecter WHERE connecter.id_utilisateur_1 = c1.id_utilisateur_1
    ) -- Exclure les amis directs
    AND c1.id_utilisateur_1 != c2.id_utilisateur_2 -- Exclure les cas où l'utilisateur se sélectionne lui-même
)
SELECT DISTINCT ai.utilisateur,
       ai.ami_indirect,
       g.nom AS centre_interet_commun
FROM amis_indirects ai
LEFT JOIN adherer a1 ON ai.utilisateur = a1.id_utilisateur
LEFT JOIN adherer a2 ON ai.ami_indirect = a2.id_utilisateur
     AND a1.id_groupe = a2.id_groupe
LEFT JOIN groupe g ON a1.id_groupe = g.id_groupe
WHERE ai.utilisateur != ai.ami_indirect -- Sécurité supplémentaire pour exclure les auto-sélections
ORDER BY ai.utilisateur, ai.ami_indirect, g.nom;