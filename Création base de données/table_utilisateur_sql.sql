-- Table: public.utilisateur

-- DROP TABLE IF EXISTS public.utilisateur;

CREATE TABLE IF NOT EXISTS public.utilisateur
(
    id_utilisateur integer NOT NULL DEFAULT nextval('utilisateur_id_utilisateur_seq'::regclass),
    nom character varying(255) COLLATE pg_catalog."default" NOT NULL,
    email character varying(255) COLLATE pg_catalog."default" NOT NULL,
    date_inscription date NOT NULL,
    CONSTRAINT utilisateur_pkey PRIMARY KEY (id_utilisateur)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.utilisateur
    OWNER to postgres;