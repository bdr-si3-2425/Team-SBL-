-- Table: public.connecter

-- DROP TABLE IF EXISTS public.connecter;

CREATE TABLE IF NOT EXISTS public.connecter
(
    id_utilisateur_1 integer NOT NULL,
    id_utilisateur_2 integer NOT NULL,
    type_connexion character varying(50) COLLATE pg_catalog."default" NOT NULL,
    date_connexion_debut date NOT NULL,
    date_connexion_fin date,
    CONSTRAINT connecter_pkey PRIMARY KEY (id_utilisateur_1, id_utilisateur_2, date_connexion_debut),
    CONSTRAINT connecter_id_utilisateur_1_fkey FOREIGN KEY (id_utilisateur_1)
        REFERENCES public.utilisateur (id_utilisateur) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT connecter_id_utilisateur_2_fkey FOREIGN KEY (id_utilisateur_2)
        REFERENCES public.utilisateur (id_utilisateur) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.connecter
    OWNER to postgres;