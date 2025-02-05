-- Table des utilisateurs
CREATE TABLE IF NOT EXISTS utilisateur (
    id_utilisateur SERIAL PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    date_inscription DATE DEFAULT CURRENT_DATE
);

-- Table des publications
CREATE TABLE IF NOT EXISTS publication (
    id_publication SERIAL PRIMARY KEY,
    id_utilisateur INT NOT NULL,
    contenu TEXT NOT NULL,
    type_publication VARCHAR(50) CHECK (type_publication IN ('texte', 'photo', 'video')),
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_utilisateur) REFERENCES utilisateur(id_utilisateur) ON DELETE CASCADE
);

-- Table des interactions (likes, commentaires)
CREATE TABLE IF NOT EXISTS interagir (
    id_interaction SERIAL PRIMARY KEY,
    id_publication INT NOT NULL,
    type_interaction VARCHAR(50) CHECK (type_interaction IN ('like', 'comment')),
    contenu_commentaire TEXT,
    date_interaction TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_utilisateur INT NOT NULL,
    FOREIGN KEY (id_publication) REFERENCES publication(id_publication) ON DELETE CASCADE,
    FOREIGN KEY (id_utilisateur) REFERENCES utilisateur(id_utilisateur) ON DELETE CASCADE
);

-- Table des groupes avec rôle (admin/membre)
CREATE TABLE IF NOT EXISTS groupe (
    id_groupe SERIAL PRIMARY KEY,
    id_utilisateur INT NOT NULL,
    role VARCHAR(50) CHECK (role IN ('admin', 'membre')),
    date_adhesion_debut DATE DEFAULT CURRENT_DATE,
    date_adhesion_fin DATE,
    FOREIGN KEY (id_utilisateur) REFERENCES utilisateur(id_utilisateur) ON DELETE CASCADE
);
TRUNCATE TABLE interagir, publication, groupe, utilisateur RESTART IDENTITY CASCADE;
