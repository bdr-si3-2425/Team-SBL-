-- Table: public.partage

-- DROP TABLE IF EXISTS public.partage;

CREATE TABLE IF NOT EXISTS public.partage
(
    id_partage integer NOT NULL DEFAULT nextval('partage_id_partage_seq'::regclass),
    id_utilisateur integer NOT NULL,
    id_publication integer NOT NULL,
    id_groupe integer NOT NULL,
    date_partage date NOT NULL,
    CONSTRAINT partage_pkey PRIMARY KEY (id_partage),
    CONSTRAINT partage_id_groupe_fkey FOREIGN KEY (id_groupe)
        REFERENCES public.groupe (id_groupe) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT partage_id_publication_fkey FOREIGN KEY (id_publication)
        REFERENCES public.publication (id_publication) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT partage_id_utilisateur_fkey FOREIGN KEY (id_utilisateur)
        REFERENCES public.utilisateur (id_utilisateur) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.partage
    OWNER to postgres;