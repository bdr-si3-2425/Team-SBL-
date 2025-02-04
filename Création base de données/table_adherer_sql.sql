-- Table: public.adherer

-- DROP TABLE IF EXISTS public.adherer;

CREATE TABLE IF NOT EXISTS public.adherer
(
    id_groupe integer NOT NULL,
    id_utilisateur integer NOT NULL,
    role character varying(50) COLLATE pg_catalog."default" NOT NULL,
    date_adhesion_debut date NOT NULL,
    date_adhesion_fin date,
    CONSTRAINT adherer_pkey PRIMARY KEY (id_groupe, id_utilisateur),
    CONSTRAINT adherer_id_groupe_fkey FOREIGN KEY (id_groupe)
        REFERENCES public.groupe (id_groupe) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT adherer_id_utilisateur_fkey FOREIGN KEY (id_utilisateur)
        REFERENCES public.utilisateur (id_utilisateur) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.adherer
    OWNER to postgres;