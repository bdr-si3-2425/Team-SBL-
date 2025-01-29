ALTER TABLE publication
ADD CONSTRAINT publication_id_utilisateur_fkey
FOREIGN KEY (id_utilisateur)
REFERENCES utilisateur(id_utilisateur)
ON DELETE CASCADE;