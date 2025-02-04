-- Table: public.interagir

-- DROP TABLE IF EXISTS public.interagir;

CREATE TABLE IF NOT EXISTS public.interagir
(
    id_interaction integer NOT NULL DEFAULT nextval('interagir_id_interaction_seq'::regclass),
    id_publication integer NOT NULL,
    type_interaction character varying(50) COLLATE pg_catalog."default" NOT NULL,
    id_parent_interaction integer,
    contenu_commentaire text COLLATE pg_catalog."default",
    date_interaction date NOT NULL,
    id_utilisateur integer NOT NULL,
    CONSTRAINT interagir_pkey PRIMARY KEY (id_interaction),
    CONSTRAINT interagir_id_publication_fkey FOREIGN KEY (id_publication)
        REFERENCES public.publication (id_publication) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT interagir_id_utilisateur_fkey FOREIGN KEY (id_utilisateur)
        REFERENCES public.utilisateur (id_utilisateur) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.interagir
    OWNER to postgres;