-- Table: public.groupe

-- DROP TABLE IF EXISTS public.groupe;

CREATE TABLE IF NOT EXISTS public.groupe
(
    id_groupe integer NOT NULL DEFAULT nextval('groupe_id_groupe_seq'::regclass),
    nom character varying(255) COLLATE pg_catalog."default" NOT NULL,
    id_theme integer NOT NULL,
    description text COLLATE pg_catalog."default",
    CONSTRAINT groupe_pkey PRIMARY KEY (id_groupe),
    CONSTRAINT groupe_id_theme_fkey FOREIGN KEY (id_theme)
        REFERENCES public.theme (id_theme) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.groupe
    OWNER to postgres;