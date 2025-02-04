-- Table: public.watchtime

-- DROP TABLE IF EXISTS public.watchtime;

CREATE TABLE IF NOT EXISTS public.watchtime
(
    id_utilisateur integer NOT NULL,
    id_publication integer NOT NULL,
    temps_debut time without time zone NOT NULL,
    temps_fin time without time zone NOT NULL,
    date_visionnage date NOT NULL,
    CONSTRAINT watchtime_pkey PRIMARY KEY (id_utilisateur, id_publication, date_visionnage),
    CONSTRAINT watchtime_id_publication_fkey FOREIGN KEY (id_publication)
        REFERENCES public.publication (id_publication) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT watchtime_id_utilisateur_fkey FOREIGN KEY (id_utilisateur)
        REFERENCES public.utilisateur (id_utilisateur) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.watchtime
    OWNER to postgres;