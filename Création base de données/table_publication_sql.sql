-- Table: public.publication

-- DROP TABLE IF EXISTS public.publication;

CREATE TABLE IF NOT EXISTS public.publication
(
    id_publication integer NOT NULL DEFAULT nextval('publication_id_publication_seq'::regclass),
    contenu text COLLATE pg_catalog."default" NOT NULL,
    type_publication character varying(50) COLLATE pg_catalog."default" NOT NULL,
    visibilite character varying(50) COLLATE pg_catalog."default" NOT NULL,
    id_theme integer NOT NULL,
    date_creation date NOT NULL,
    id_utilisateur integer,
    contenu_duree integer,
    CONSTRAINT publication_pkey PRIMARY KEY (id_publication),
    CONSTRAINT publication_id_theme_fkey FOREIGN KEY (id_theme)
        REFERENCES public.theme (id_theme) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT publication_id_utilisateur_fkey FOREIGN KEY (id_utilisateur)
        REFERENCES public.utilisateur (id_utilisateur) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.publication
    OWNER to postgres;

COMMENT ON COLUMN public.publication.contenu_duree
    IS 'Donne la durée totale des différents types de  publications : 

  - Vidéo : durée de la vidéo
  - Photo : Valeur par défaut de 5 secondes qui est 
                 le temps moyen de visionnage d''une 
                 photo
  - Textuel : à partir du nombre total de mot de la 
                   publication, on attribut 0.3s/mot (temps 
                  de visionnage moyen)';