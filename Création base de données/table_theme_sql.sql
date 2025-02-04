-- Table: public.theme

-- DROP TABLE IF EXISTS public.theme;

CREATE TABLE IF NOT EXISTS public.theme
(
    id_theme integer NOT NULL DEFAULT nextval('theme_id_theme_seq'::regclass),
    nom character varying(255) COLLATE pg_catalog."default" NOT NULL,
    id_parent_theme integer,
    CONSTRAINT theme_pkey PRIMARY KEY (id_theme),
    CONSTRAINT theme_id_parent_theme_fkey FOREIGN KEY (id_parent_theme)
        REFERENCES public.theme (id_theme) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.theme
    OWNER to postgres;