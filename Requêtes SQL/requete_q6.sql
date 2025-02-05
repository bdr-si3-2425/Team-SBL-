WITH VueCounts AS (
    SELECT
        p.id_publication,
        COUNT(w.temps_debut) AS total_vues
    FROM
        PUBLICATION p
    LEFT JOIN WATCHTIME w ON p.id_publication = w.id_publication
    GROUP BY p.id_publication
),
LikeCounts AS (
    SELECT
        p.id_publication,
        COUNT(i.id_interaction) AS total_likes
    FROM
        PUBLICATION p
    LEFT JOIN INTERAGIR i ON p.id_publication = i.id_publication
    WHERE i.type_interaction = 'like'
    GROUP BY p.id_publication
),
PartageCounts AS (
    SELECT
        p.id_publication,
        COUNT(pa.id_partage) AS total_partages
    FROM
        PUBLICATION p
    LEFT JOIN PARTAGE pa ON p.id_publication = pa.id_publication
    GROUP BY p.id_publication
)
SELECT
    p.id_publication,
    p.contenu,
    COALESCE(vc.total_vues, 0) AS total_vues,
    COALESCE(lc.total_likes, 0) AS total_likes,
    COALESCE(pc.total_partages, 0) AS total_partages,
    (COALESCE(vc.total_vues, 0) + COALESCE(lc.total_likes, 0) + COALESCE(pc.total_partages, 0)) AS total_interactions
FROM
    PUBLICATION p
LEFT JOIN VueCounts vc ON p.id_publication = vc.id_publication
LEFT JOIN LikeCounts lc ON p.id_publication = lc.id_publication
LEFT JOIN PartageCounts pc ON p.id_publication = pc.id_publication
ORDER BY total_interactions DESC;