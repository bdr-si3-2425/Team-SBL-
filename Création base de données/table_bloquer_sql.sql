-- Table: public.bloquer

-- DROP TABLE IF EXISTS public.bloquer;

CREATE TABLE IF NOT EXISTS public.bloquer
(
    id_utilisateur integer NOT NULL,
    id_utilisateur_bloque integer NOT NULL,
    type_blocage character varying(50) COLLATE pg_catalog."default" NOT NULL,
    date_debut date NOT NULL,
    date_fin date,
    CONSTRAINT bloquer_pkey PRIMARY KEY (id_utilisateur, id_utilisateur_bloque, date_debut),
    CONSTRAINT bloquer_id_utilisateur_bloque_fkey FOREIGN KEY (id_utilisateur_bloque)
        REFERENCES public.utilisateur (id_utilisateur) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT bloquer_id_utilisateur_fkey FOREIGN KEY (id_utilisateur)
        REFERENCES public.utilisateur (id_utilisateur) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.bloquer
    OWNER to postgres;