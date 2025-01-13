toc.dat                                                                                             0000600 0004000 0002000 00000050725 14741232524 0014454 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        PGDMP       .                 }            Team-SBL-projet    17.2    17.2 @    @           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                           false         A           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                           false         B           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                           false         C           1262    16479    Team-SBL-projet    DATABASE     �   CREATE DATABASE "Team-SBL-projet" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_United Kingdom.1252';
 !   DROP DATABASE "Team-SBL-projet";
                     postgres    false         �            1259    16554    adherer    TABLE     �   CREATE TABLE public.adherer (
    id_groupe integer NOT NULL,
    id_utilisateur integer NOT NULL,
    role character varying(50) NOT NULL,
    date_adhesion date NOT NULL
);
    DROP TABLE public.adherer;
       public         heap r       postgres    false         �            1259    16594    bloquer    TABLE     �   CREATE TABLE public.bloquer (
    id_utilisateur integer NOT NULL,
    id_utilisateur_bloque integer NOT NULL,
    type_blocage character varying(50) NOT NULL,
    date_debut date NOT NULL,
    date_fin date
);
    DROP TABLE public.bloquer;
       public         heap r       postgres    false         �            1259    16569 	   connecter    TABLE     �   CREATE TABLE public.connecter (
    id_utilisateur integer NOT NULL,
    type_connexion character varying(50) NOT NULL,
    date_connexion date NOT NULL
);
    DROP TABLE public.connecter;
       public         heap r       postgres    false         �            1259    16494    groupe    TABLE     �   CREATE TABLE public.groupe (
    id_groupe integer NOT NULL,
    nom character varying(255) NOT NULL,
    id_theme integer NOT NULL,
    description text,
    date_creation date NOT NULL
);
    DROP TABLE public.groupe;
       public         heap r       postgres    false         �            1259    16493    groupe_id_groupe_seq    SEQUENCE     �   CREATE SEQUENCE public.groupe_id_groupe_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.groupe_id_groupe_seq;
       public               postgres    false    220         D           0    0    groupe_id_groupe_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.groupe_id_groupe_seq OWNED BY public.groupe.id_groupe;
          public               postgres    false    219         �            1259    16536 	   interagir    TABLE     +  CREATE TABLE public.interagir (
    id_interaction integer NOT NULL,
    id_publication integer NOT NULL,
    type_interaction character varying(50) NOT NULL,
    id_parent_interaction integer,
    contenu_commentaire text,
    date_interaction date NOT NULL,
    id_utilisateur integer NOT NULL
);
    DROP TABLE public.interagir;
       public         heap r       postgres    false         �            1259    16535    interagir_id_interaction_seq    SEQUENCE     �   CREATE SEQUENCE public.interagir_id_interaction_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.interagir_id_interaction_seq;
       public               postgres    false    226         E           0    0    interagir_id_interaction_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.interagir_id_interaction_seq OWNED BY public.interagir.id_interaction;
          public               postgres    false    225         �            1259    16517    publication    TABLE       CREATE TABLE public.publication (
    id_publication integer NOT NULL,
    contenu text NOT NULL,
    type_publication character varying(50) NOT NULL,
    visibilite character varying(50) NOT NULL,
    id_theme integer NOT NULL,
    id_groupe integer,
    date_creation date NOT NULL
);
    DROP TABLE public.publication;
       public         heap r       postgres    false         �            1259    16516    publication_id_publication_seq    SEQUENCE     �   CREATE SEQUENCE public.publication_id_publication_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 5   DROP SEQUENCE public.publication_id_publication_seq;
       public               postgres    false    224         F           0    0    publication_id_publication_seq    SEQUENCE OWNED BY     a   ALTER SEQUENCE public.publication_id_publication_seq OWNED BY public.publication.id_publication;
          public               postgres    false    223         �            1259    16481    theme    TABLE     �   CREATE TABLE public.theme (
    id_theme integer NOT NULL,
    nom character varying(255) NOT NULL,
    id_parent_theme integer
);
    DROP TABLE public.theme;
       public         heap r       postgres    false         �            1259    16480    theme_id_theme_seq    SEQUENCE     �   CREATE SEQUENCE public.theme_id_theme_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.theme_id_theme_seq;
       public               postgres    false    218         G           0    0    theme_id_theme_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.theme_id_theme_seq OWNED BY public.theme.id_theme;
          public               postgres    false    217         �            1259    16508    utilisateur    TABLE     �   CREATE TABLE public.utilisateur (
    id_utilisateur integer NOT NULL,
    nom character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    date_inscription date NOT NULL
);
    DROP TABLE public.utilisateur;
       public         heap r       postgres    false         �            1259    16507    utilisateur_id_utilisateur_seq    SEQUENCE     �   CREATE SEQUENCE public.utilisateur_id_utilisateur_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 5   DROP SEQUENCE public.utilisateur_id_utilisateur_seq;
       public               postgres    false    222         H           0    0    utilisateur_id_utilisateur_seq    SEQUENCE OWNED BY     a   ALTER SEQUENCE public.utilisateur_id_utilisateur_seq OWNED BY public.utilisateur.id_utilisateur;
          public               postgres    false    221         �            1259    16579 	   watchtime    TABLE     �   CREATE TABLE public.watchtime (
    id_utilisateur integer NOT NULL,
    id_publication integer NOT NULL,
    temps_debut time without time zone NOT NULL,
    temps_fin time without time zone NOT NULL,
    date_visionnage date NOT NULL
);
    DROP TABLE public.watchtime;
       public         heap r       postgres    false         |           2604    16497    groupe id_groupe    DEFAULT     t   ALTER TABLE ONLY public.groupe ALTER COLUMN id_groupe SET DEFAULT nextval('public.groupe_id_groupe_seq'::regclass);
 ?   ALTER TABLE public.groupe ALTER COLUMN id_groupe DROP DEFAULT;
       public               postgres    false    219    220    220                    2604    16539    interagir id_interaction    DEFAULT     �   ALTER TABLE ONLY public.interagir ALTER COLUMN id_interaction SET DEFAULT nextval('public.interagir_id_interaction_seq'::regclass);
 G   ALTER TABLE public.interagir ALTER COLUMN id_interaction DROP DEFAULT;
       public               postgres    false    225    226    226         ~           2604    16520    publication id_publication    DEFAULT     �   ALTER TABLE ONLY public.publication ALTER COLUMN id_publication SET DEFAULT nextval('public.publication_id_publication_seq'::regclass);
 I   ALTER TABLE public.publication ALTER COLUMN id_publication DROP DEFAULT;
       public               postgres    false    224    223    224         {           2604    16484    theme id_theme    DEFAULT     p   ALTER TABLE ONLY public.theme ALTER COLUMN id_theme SET DEFAULT nextval('public.theme_id_theme_seq'::regclass);
 =   ALTER TABLE public.theme ALTER COLUMN id_theme DROP DEFAULT;
       public               postgres    false    217    218    218         }           2604    16511    utilisateur id_utilisateur    DEFAULT     �   ALTER TABLE ONLY public.utilisateur ALTER COLUMN id_utilisateur SET DEFAULT nextval('public.utilisateur_id_utilisateur_seq'::regclass);
 I   ALTER TABLE public.utilisateur ALTER COLUMN id_utilisateur DROP DEFAULT;
       public               postgres    false    221    222    222         :          0    16554    adherer 
   TABLE DATA           Q   COPY public.adherer (id_groupe, id_utilisateur, role, date_adhesion) FROM stdin;
    public               postgres    false    227       4922.dat =          0    16594    bloquer 
   TABLE DATA           l   COPY public.bloquer (id_utilisateur, id_utilisateur_bloque, type_blocage, date_debut, date_fin) FROM stdin;
    public               postgres    false    230       4925.dat ;          0    16569 	   connecter 
   TABLE DATA           S   COPY public.connecter (id_utilisateur, type_connexion, date_connexion) FROM stdin;
    public               postgres    false    228       4923.dat 3          0    16494    groupe 
   TABLE DATA           V   COPY public.groupe (id_groupe, nom, id_theme, description, date_creation) FROM stdin;
    public               postgres    false    220       4915.dat 9          0    16536 	   interagir 
   TABLE DATA           �   COPY public.interagir (id_interaction, id_publication, type_interaction, id_parent_interaction, contenu_commentaire, date_interaction, id_utilisateur) FROM stdin;
    public               postgres    false    226       4921.dat 7          0    16517    publication 
   TABLE DATA           �   COPY public.publication (id_publication, contenu, type_publication, visibilite, id_theme, id_groupe, date_creation) FROM stdin;
    public               postgres    false    224       4919.dat 1          0    16481    theme 
   TABLE DATA           ?   COPY public.theme (id_theme, nom, id_parent_theme) FROM stdin;
    public               postgres    false    218       4913.dat 5          0    16508    utilisateur 
   TABLE DATA           S   COPY public.utilisateur (id_utilisateur, nom, email, date_inscription) FROM stdin;
    public               postgres    false    222       4917.dat <          0    16579 	   watchtime 
   TABLE DATA           l   COPY public.watchtime (id_utilisateur, id_publication, temps_debut, temps_fin, date_visionnage) FROM stdin;
    public               postgres    false    229       4924.dat I           0    0    groupe_id_groupe_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.groupe_id_groupe_seq', 1, false);
          public               postgres    false    219         J           0    0    interagir_id_interaction_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.interagir_id_interaction_seq', 1, false);
          public               postgres    false    225         K           0    0    publication_id_publication_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.publication_id_publication_seq', 1, false);
          public               postgres    false    223         L           0    0    theme_id_theme_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.theme_id_theme_seq', 1, false);
          public               postgres    false    217         M           0    0    utilisateur_id_utilisateur_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.utilisateur_id_utilisateur_seq', 1, false);
          public               postgres    false    221         �           2606    16558    adherer adherer_pkey 
   CONSTRAINT     i   ALTER TABLE ONLY public.adherer
    ADD CONSTRAINT adherer_pkey PRIMARY KEY (id_groupe, id_utilisateur);
 >   ALTER TABLE ONLY public.adherer DROP CONSTRAINT adherer_pkey;
       public                 postgres    false    227    227         �           2606    16598    bloquer bloquer_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.bloquer
    ADD CONSTRAINT bloquer_pkey PRIMARY KEY (id_utilisateur, id_utilisateur_bloque, date_debut);
 >   ALTER TABLE ONLY public.bloquer DROP CONSTRAINT bloquer_pkey;
       public                 postgres    false    230    230    230         �           2606    16573    connecter connecter_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.connecter
    ADD CONSTRAINT connecter_pkey PRIMARY KEY (id_utilisateur, type_connexion, date_connexion);
 B   ALTER TABLE ONLY public.connecter DROP CONSTRAINT connecter_pkey;
       public                 postgres    false    228    228    228         �           2606    16501    groupe groupe_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.groupe
    ADD CONSTRAINT groupe_pkey PRIMARY KEY (id_groupe);
 <   ALTER TABLE ONLY public.groupe DROP CONSTRAINT groupe_pkey;
       public                 postgres    false    220         �           2606    16543    interagir interagir_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.interagir
    ADD CONSTRAINT interagir_pkey PRIMARY KEY (id_interaction);
 B   ALTER TABLE ONLY public.interagir DROP CONSTRAINT interagir_pkey;
       public                 postgres    false    226         �           2606    16524    publication publication_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.publication
    ADD CONSTRAINT publication_pkey PRIMARY KEY (id_publication);
 F   ALTER TABLE ONLY public.publication DROP CONSTRAINT publication_pkey;
       public                 postgres    false    224         �           2606    16486    theme theme_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.theme
    ADD CONSTRAINT theme_pkey PRIMARY KEY (id_theme);
 :   ALTER TABLE ONLY public.theme DROP CONSTRAINT theme_pkey;
       public                 postgres    false    218         �           2606    16515    utilisateur utilisateur_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.utilisateur
    ADD CONSTRAINT utilisateur_pkey PRIMARY KEY (id_utilisateur);
 F   ALTER TABLE ONLY public.utilisateur DROP CONSTRAINT utilisateur_pkey;
       public                 postgres    false    222         �           2606    16583    watchtime watchtime_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.watchtime
    ADD CONSTRAINT watchtime_pkey PRIMARY KEY (id_utilisateur, id_publication, date_visionnage);
 B   ALTER TABLE ONLY public.watchtime DROP CONSTRAINT watchtime_pkey;
       public                 postgres    false    229    229    229         �           2606    16559    adherer adherer_id_groupe_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.adherer
    ADD CONSTRAINT adherer_id_groupe_fkey FOREIGN KEY (id_groupe) REFERENCES public.groupe(id_groupe);
 H   ALTER TABLE ONLY public.adherer DROP CONSTRAINT adherer_id_groupe_fkey;
       public               postgres    false    227    4739    220         �           2606    16564 #   adherer adherer_id_utilisateur_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.adherer
    ADD CONSTRAINT adherer_id_utilisateur_fkey FOREIGN KEY (id_utilisateur) REFERENCES public.utilisateur(id_utilisateur);
 M   ALTER TABLE ONLY public.adherer DROP CONSTRAINT adherer_id_utilisateur_fkey;
       public               postgres    false    4741    227    222         �           2606    16604 *   bloquer bloquer_id_utilisateur_bloque_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.bloquer
    ADD CONSTRAINT bloquer_id_utilisateur_bloque_fkey FOREIGN KEY (id_utilisateur_bloque) REFERENCES public.utilisateur(id_utilisateur);
 T   ALTER TABLE ONLY public.bloquer DROP CONSTRAINT bloquer_id_utilisateur_bloque_fkey;
       public               postgres    false    230    4741    222         �           2606    16599 #   bloquer bloquer_id_utilisateur_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.bloquer
    ADD CONSTRAINT bloquer_id_utilisateur_fkey FOREIGN KEY (id_utilisateur) REFERENCES public.utilisateur(id_utilisateur);
 M   ALTER TABLE ONLY public.bloquer DROP CONSTRAINT bloquer_id_utilisateur_fkey;
       public               postgres    false    222    230    4741         �           2606    16574 '   connecter connecter_id_utilisateur_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.connecter
    ADD CONSTRAINT connecter_id_utilisateur_fkey FOREIGN KEY (id_utilisateur) REFERENCES public.utilisateur(id_utilisateur);
 Q   ALTER TABLE ONLY public.connecter DROP CONSTRAINT connecter_id_utilisateur_fkey;
       public               postgres    false    222    228    4741         �           2606    16502    groupe groupe_id_theme_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.groupe
    ADD CONSTRAINT groupe_id_theme_fkey FOREIGN KEY (id_theme) REFERENCES public.theme(id_theme);
 E   ALTER TABLE ONLY public.groupe DROP CONSTRAINT groupe_id_theme_fkey;
       public               postgres    false    4737    218    220         �           2606    16544 '   interagir interagir_id_publication_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.interagir
    ADD CONSTRAINT interagir_id_publication_fkey FOREIGN KEY (id_publication) REFERENCES public.publication(id_publication);
 Q   ALTER TABLE ONLY public.interagir DROP CONSTRAINT interagir_id_publication_fkey;
       public               postgres    false    224    226    4743         �           2606    16549 '   interagir interagir_id_utilisateur_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.interagir
    ADD CONSTRAINT interagir_id_utilisateur_fkey FOREIGN KEY (id_utilisateur) REFERENCES public.utilisateur(id_utilisateur);
 Q   ALTER TABLE ONLY public.interagir DROP CONSTRAINT interagir_id_utilisateur_fkey;
       public               postgres    false    226    4741    222         �           2606    16530 &   publication publication_id_groupe_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.publication
    ADD CONSTRAINT publication_id_groupe_fkey FOREIGN KEY (id_groupe) REFERENCES public.groupe(id_groupe);
 P   ALTER TABLE ONLY public.publication DROP CONSTRAINT publication_id_groupe_fkey;
       public               postgres    false    224    4739    220         �           2606    16525 %   publication publication_id_theme_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.publication
    ADD CONSTRAINT publication_id_theme_fkey FOREIGN KEY (id_theme) REFERENCES public.theme(id_theme);
 O   ALTER TABLE ONLY public.publication DROP CONSTRAINT publication_id_theme_fkey;
       public               postgres    false    4737    218    224         �           2606    16487     theme theme_id_parent_theme_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.theme
    ADD CONSTRAINT theme_id_parent_theme_fkey FOREIGN KEY (id_parent_theme) REFERENCES public.theme(id_theme);
 J   ALTER TABLE ONLY public.theme DROP CONSTRAINT theme_id_parent_theme_fkey;
       public               postgres    false    218    218    4737         �           2606    16589 '   watchtime watchtime_id_publication_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.watchtime
    ADD CONSTRAINT watchtime_id_publication_fkey FOREIGN KEY (id_publication) REFERENCES public.publication(id_publication);
 Q   ALTER TABLE ONLY public.watchtime DROP CONSTRAINT watchtime_id_publication_fkey;
       public               postgres    false    224    229    4743         �           2606    16584 '   watchtime watchtime_id_utilisateur_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.watchtime
    ADD CONSTRAINT watchtime_id_utilisateur_fkey FOREIGN KEY (id_utilisateur) REFERENCES public.utilisateur(id_utilisateur);
 Q   ALTER TABLE ONLY public.watchtime DROP CONSTRAINT watchtime_id_utilisateur_fkey;
       public               postgres    false    222    4741    229                                                   4922.dat                                                                                            0000600 0004000 0002000 00000001272 14741232524 0014260 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	1	membre	2023-01-15
2	2	admin	2023-02-15
3	3	membre	2023-03-01
4	4	membre	2023-03-12
5	5	membre	2023-03-25
6	6	admin	2023-04-01
7	7	membre	2023-04-10
8	8	membre	2023-04-20
9	9	membre	2023-05-01
10	10	admin	2023-05-10
11	11	membre	2023-05-15
12	12	membre	2023-05-20
13	13	admin	2023-06-01
14	14	membre	2023-06-10
15	15	membre	2023-06-20
16	16	membre	2023-07-01
17	17	admin	2023-07-10
18	18	membre	2023-07-20
19	19	membre	2023-08-01
20	20	admin	2023-08-10
21	21	membre	2023-08-20
22	22	membre	2023-09-01
23	23	admin	2023-09-10
24	24	membre	2023-09-20
25	25	membre	2023-10-01
26	26	membre	2023-10-10
27	27	admin	2023-10-20
28	28	membre	2023-11-01
29	29	membre	2023-11-10
30	30	admin	2023-11-20
\.


                                                                                                                                                                                                                                                                                                                                      4925.dat                                                                                            0000600 0004000 0002000 00000002020 14741232524 0014253 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	3	temporaire	2023-03-01	2023-03-10
2	1	permanent	2023-02-20	\N
4	5	temporaire	2023-04-07	2023-04-14
6	7	temporaire	2023-05-01	2023-05-05
8	9	permanent	2023-05-15	\N
10	11	temporaire	2023-06-01	2023-06-07
12	13	permanent	2023-06-20	\N
14	15	temporaire	2023-07-01	2023-07-10
16	17	temporaire	2023-07-20	2023-07-25
18	19	permanent	2023-08-01	\N
20	21	temporaire	2023-08-10	2023-08-20
22	23	temporaire	2023-09-01	2023-09-10
24	25	permanent	2023-09-15	\N
26	27	temporaire	2023-10-01	2023-10-10
28	29	permanent	2023-10-20	\N
30	1	temporaire	2023-11-01	2023-11-15
2	4	permanent	2023-11-10	\N
5	6	temporaire	2023-11-15	2023-11-25
7	8	permanent	2023-11-20	\N
9	10	temporaire	2023-12-01	2023-12-05
11	12	permanent	2023-12-10	\N
13	14	temporaire	2023-12-15	2023-12-20
15	16	temporaire	2023-12-20	2023-12-30
17	18	permanent	2023-12-25	\N
19	20	temporaire	2023-12-30	2024-01-05
21	22	permanent	2024-01-01	\N
23	24	temporaire	2024-01-05	2024-01-10
25	26	permanent	2024-01-10	\N
27	28	temporaire	2024-01-15	2024-01-20
29	30	permanent	2024-01-20	\N
\.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                4923.dat                                                                                            0000600 0004000 0002000 00000001117 14741232524 0014257 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	ami	2023-01-20
2	follower	2023-02-18
3	ami	2023-03-10
4	ami	2023-03-25
5	follower	2023-04-01
6	ami	2023-04-12
7	follower	2023-04-15
8	ami	2023-04-22
9	ami	2023-05-03
10	follower	2023-05-10
11	ami	2023-05-20
12	ami	2023-06-01
13	follower	2023-06-05
14	ami	2023-06-12
15	ami	2023-06-22
16	follower	2023-07-01
17	ami	2023-07-12
18	follower	2023-07-25
19	ami	2023-08-03
20	ami	2023-08-15
21	follower	2023-08-18
22	ami	2023-09-01
23	follower	2023-09-12
24	ami	2023-09-25
25	ami	2023-10-05
26	follower	2023-10-12
27	ami	2023-10-18
28	ami	2023-11-01
29	follower	2023-11-05
30	ami	2023-11-15
\.


                                                                                                                                                                                                                                                                                                                                                                                                                                                 4915.dat                                                                                            0000600 0004000 0002000 00000004262 14741232524 0014264 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	Développement Web	2	Groupe pour discuter des tendances du développement web	2023-01-01
2	Intelligence Artificielle	3	Espace pour partager des ressources sur l’IA	2023-02-15
3	UI/UX Design	4	Discussions sur les bonnes pratiques en design	2023-03-10
4	Big Data	3	Ressources et articles sur la gestion de données massives	2023-04-01
5	Sécurité Informatique	2	Groupe sur les stratégies de sécurité	2023-04-10
6	Développement Mobile	2	Discussions sur les frameworks mobiles	2023-04-20
7	Blockchain	3	Nouveautés et tutoriels sur la blockchain	2023-05-01
8	Internet des Objets	3	Groupe sur les innovations IoT	2023-05-10
9	Cybersécurité	3	Echanges sur la cybersécurité et les bonnes pratiques	2023-05-20
10	Cloud Computing	3	Partage de ressources sur le cloud	2023-06-01
11	Analyse de Données	3	Approches modernes d’analyse de données	2023-06-10
12	Intelligence Artificielle Avancée	3	Discussions poussées sur l’IA avancée	2023-06-20
13	Programmation Front-End	2	Tout sur le développement web côté client	2023-07-01
14	Programmation Back-End	2	Groupe pour les passionnés de serveurs	2023-07-10
15	DevOps	2	Meilleures pratiques DevOps	2023-07-20
16	Open Source	2	Partage de projets open source	2023-08-01
17	Automatisation	3	Discussions sur l’automatisation des tâches	2023-08-10
18	Éthique et IA	3	Réflexions sur l’éthique dans les technologies	2023-08-20
19	Jeux Vidéo	4	Discussions sur le développement de jeux vidéo	2023-09-01
20	Design Graphique	4	Partage de projets graphiques	2023-09-10
21	Photographie	4	Techniques et innovations en photographie	2023-09-20
22	Réseaux	2	Discussion sur les réseaux informatiques	2023-10-01
23	Bases de Données	2	Approfondissement des bases de données	2023-10-10
24	Machine Learning	3	Partage de ressources sur le ML	2023-10-20
25	Robotique	3	Innovations en robotique	2023-11-01
26	Cryptographie	2	Discussions sur la cryptographie	2023-11-10
27	Programmation C++	2	Tutoriels et partage de projets en C++	2023-11-20
28	Programmation Python	2	Groupe pour les passionnés de Python	2023-12-01
29	Systèmes embarqués	2	Discussions techniques sur les systèmes embarqués	2023-12-10
30	Réalité Virtuelle	3	Innovations et projets en VR	2023-12-20
\.


                                                                                                                                                                                                                                                                                                                                              4921.dat                                                                                            0000600 0004000 0002000 00000002306 14741232524 0014256 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	1	like	\N	\N	2023-01-21	1
2	2	comment	\N	Très clair, merci !	2023-02-12	2
3	3	like	\N	\N	2023-02-16	3
4	4	comment	\N	Excellent résumé.	2023-03-02	4
5	5	like	\N	\N	2023-03-17	5
6	6	like	\N	\N	2023-04-02	6
7	7	comment	\N	Quels outils recommandez-vous ?	2023-04-11	7
8	8	like	\N	\N	2023-04-22	8
9	9	comment	\N	Superbe introduction.	2023-05-02	9
10	10	like	\N	\N	2023-05-16	10
11	11	comment	\N	Merci pour cet article.	2023-05-21	11
12	12	like	\N	\N	2023-06-02	12
13	13	comment	\N	Peut-on avoir un exemple ?	2023-06-12	13
14	14	like	\N	\N	2023-06-21	14
15	15	comment	\N	Très complet.	2023-07-02	15
16	16	like	\N	\N	2023-07-16	16
17	17	comment	\N	Un plaisir à lire.	2023-08-02	17
18	18	like	\N	\N	2023-08-12	18
19	19	comment	\N	Merci beaucoup !	2023-08-22	19
20	20	like	\N	\N	2023-09-02	20
21	21	comment	\N	Impressionnant.	2023-09-16	21
22	22	like	\N	\N	2023-09-21	22
23	23	comment	\N	Où trouver plus d’infos ?	2023-10-02	23
24	24	like	\N	\N	2023-10-12	24
25	25	comment	\N	Super article, bravo !	2023-10-17	25
26	26	like	\N	\N	2023-11-02	26
27	27	comment	\N	Merci pour cet éclairage.	2023-11-11	27
28	28	like	\N	\N	2023-11-21	28
29	29	comment	\N	Instructif et clair.	2023-12-02	29
30	30	like	\N	\N	2023-12-16	30
\.


                                                                                                                                                                                                                                                                                                                          4919.dat                                                                                            0000600 0004000 0002000 00000003752 14741232524 0014273 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	Introduction aux bases de données	article	public	20	23	2023-01-20
2	Les bases du Machine Learning	article	membre	7	24	2023-02-10
3	Top 5 des outils pour la cybersécurité	article	membre	11	9	2023-02-15
4	Les nouveautés de HTML5	article	public	25	1	2023-03-01
5	Introduction à l’automatisation des tests	article	public	14	17	2023-03-15
6	Guide complet sur le Big Data	article	public	6	4	2023-04-01
7	Développer des applications avec Python	article	membre	26	28	2023-04-10
8	Tutoriel sur les réseaux informatiques	article	public	12	22	2023-04-20
9	Découverte de la cryptographie	article	membre	22	26	2023-05-01
10	Les tendances en Blockchain	article	public	15	7	2023-05-15
11	Améliorer le design UX	article	public	18	3	2023-05-20
12	Initiation à la réalité virtuelle	article	public	16	30	2023-06-01
13	Les bases du DevOps	article	membre	13	15	2023-06-10
14	Programmation avancée en Java	article	membre	27	2	2023-06-20
15	Explorer les systèmes embarqués	article	public	23	29	2023-07-01
16	Le futur de l’IA	article	membre	21	3	2023-07-15
17	Techniques de Data Science	article	public	19	6	2023-08-01
18	Nouveautés en réalité augmentée	article	public	17	16	2023-08-10
19	L’évolution des technologies Cloud	article	public	9	10	2023-08-20
20	Les avantages du code open source	article	membre	24	16	2023-09-01
21	Tutoriel sur le Machine Learning avancé	article	public	7	21	2023-09-15
22	Programmation efficace avec C++	article	public	28	27	2023-09-20
23	Comment optimiser vos requêtes SQL	article	membre	20	23	2023-10-01
24	Introduction au développement mobile	article	public	25	6	2023-10-10
25	Photographie numérique : astuces	article	membre	29	29	2023-10-15
26	La cybersécurité en entreprise	article	public	11	9	2023-11-01
27	Les innovations dans la robotique	article	public	23	25	2023-11-10
28	Data visualisation avec Python	article	membre	26	28	2023-11-20
29	Créer un jeu vidéo en Unity	article	public	30	19	2023-12-01
30	Le guide ultime de l’éthique en IA	article	membre	21	18	2023-12-15
\.


                      4913.dat                                                                                            0000600 0004000 0002000 00000001161 14741232524 0014255 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	Technologie	\N
2	Programmation	1
3	Data Science	1
4	Conception	1
5	Sécurité	1
6	Big Data	3
7	Machine Learning	3
8	Deep Learning	7
9	Cloud Computing	1
10	Internet des Objets	1
11	Cybersécurité	5
12	Réseaux	5
13	DevOps	1
14	Automatisation	1
15	Blockchain	5
16	Réalité Virtuelle	4
17	Réalité Augmentée	4
18	UI/UX Design	4
19	Analyse de Données	3
20	Bases de Données	1
21	Intelligence Artificielle	3
22	Cryptographie	5
23	Systèmes Embarqués	1
24	Open Source	1
25	Langages de Programmation	2
26	Programmation Python	25
27	Programmation Java	25
28	Programmation C++	25
29	Photographie Numérique	4
30	Gaming	4
\.


                                                                                                                                                                                                                                                                                                                                                                                                               4917.dat                                                                                            0000600 0004000 0002000 00000003145 14741232524 0014265 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	Alice Dupont	alice.dupont@example.com	2023-01-15
2	Bob Martin	bob.martin@example.com	2023-02-20
3	Charlie Nguyen	charlie.nguyen@example.com	2023-03-10
4	Diane Leroy	diane.leroy@example.com	2023-03-25
5	Eve Blanc	eve.blanc@example.com	2023-04-01
6	Fabien Morel	fabien.morel@example.com	2023-04-10
7	Georges Lefevre	georges.lefevre@example.com	2023-04-20
8	Hélène Dubois	helene.dubois@example.com	2023-05-01
9	Isabelle Renaud	isabelle.renaud@example.com	2023-05-10
10	Julien Petit	julien.petit@example.com	2023-05-15
11	Karim Youssef	karim.youssef@example.com	2023-05-20
12	Laurence Simon	laurence.simon@example.com	2023-06-01
13	Marc Verdier	marc.verdier@example.com	2023-06-10
14	Nadia Clément	nadia.clement@example.com	2023-06-20
15	Olivier Durand	olivier.durand@example.com	2023-07-01
16	Pauline Millet	pauline.millet@example.com	2023-07-10
17	Quentin Lemoine	quentin.lemoine@example.com	2023-07-20
18	Romain Fontaine	romain.fontaine@example.com	2023-08-01
19	Sophie Charron	sophie.charron@example.com	2023-08-10
20	Thomas Giraud	thomas.giraud@example.com	2023-08-20
21	Ursula Lefebvre	ursula.lefebvre@example.com	2023-09-01
22	Vincent Chevalier	vincent.chevalier@example.com	2023-09-10
23	William Robert	william.robert@example.com	2023-09-20
24	Xavier Mercier	xavier.mercier@example.com	2023-10-01
25	Yasmine Boucher	yasmine.boucher@example.com	2023-10-10
26	Zacharie Lambert	zacharie.lambert@example.com	2023-10-20
27	Anne Dupuis	anne.dupuis@example.com	2023-11-01
28	Bruno Vasseur	bruno.vasseur@example.com	2023-11-10
29	Claire Perrot	claire.perrot@example.com	2023-11-20
30	David Colin	david.colin@example.com	2023-12-01
\.


                                                                                                                                                                                                                                                                                                                                                                                                                           4924.dat                                                                                            0000600 0004000 0002000 00000002015 14741232524 0014256 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	1	10:00:00	10:15:00	2023-01-21
2	2	14:00:00	14:30:00	2023-02-19
3	3	09:00:00	09:20:00	2023-03-02
4	4	12:00:00	12:30:00	2023-04-06
5	5	15:00:00	15:20:00	2023-05-20
6	6	13:00:00	13:25:00	2023-05-21
7	7	11:00:00	11:15:00	2023-06-01
8	8	09:45:00	10:10:00	2023-06-02
9	9	16:30:00	16:50:00	2023-06-15
10	10	17:00:00	17:30:00	2023-06-16
11	11	08:00:00	08:15:00	2023-07-01
12	12	10:45:00	11:00:00	2023-07-05
13	13	13:15:00	13:45:00	2023-07-15
14	14	11:30:00	11:50:00	2023-07-20
15	15	10:20:00	10:40:00	2023-07-25
16	16	09:00:00	09:25:00	2023-08-01
17	17	15:00:00	15:20:00	2023-08-05
18	18	14:00:00	14:15:00	2023-08-12
19	19	16:45:00	17:10:00	2023-08-20
20	20	08:15:00	08:45:00	2023-09-01
21	21	10:30:00	10:50:00	2023-09-05
22	22	11:15:00	11:40:00	2023-09-10
23	23	14:25:00	14:50:00	2023-09-20
24	24	13:50:00	14:10:00	2023-09-25
25	25	10:05:00	10:30:00	2023-10-01
26	26	12:00:00	12:20:00	2023-10-15
27	27	16:00:00	16:25:00	2023-10-20
28	28	17:45:00	18:10:00	2023-11-01
29	29	15:10:00	15:40:00	2023-11-10
30	30	18:30:00	18:50:00	2023-11-20
\.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   restore.sql                                                                                         0000600 0004000 0002000 00000040600 14741232524 0015370 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        --
-- NOTE:
--
-- File paths need to be edited. Search for $$PATH$$ and
-- replace it with the path to the directory containing
-- the extracted data files.
--
--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2
-- Dumped by pg_dump version 17.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE "Team-SBL-projet";
--
-- Name: Team-SBL-projet; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE "Team-SBL-projet" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_United Kingdom.1252';


ALTER DATABASE "Team-SBL-projet" OWNER TO postgres;

\connect -reuse-previous=on "dbname='Team-SBL-projet'"

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: adherer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adherer (
    id_groupe integer NOT NULL,
    id_utilisateur integer NOT NULL,
    role character varying(50) NOT NULL,
    date_adhesion date NOT NULL
);


ALTER TABLE public.adherer OWNER TO postgres;

--
-- Name: bloquer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bloquer (
    id_utilisateur integer NOT NULL,
    id_utilisateur_bloque integer NOT NULL,
    type_blocage character varying(50) NOT NULL,
    date_debut date NOT NULL,
    date_fin date
);


ALTER TABLE public.bloquer OWNER TO postgres;

--
-- Name: connecter; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.connecter (
    id_utilisateur integer NOT NULL,
    type_connexion character varying(50) NOT NULL,
    date_connexion date NOT NULL
);


ALTER TABLE public.connecter OWNER TO postgres;

--
-- Name: groupe; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.groupe (
    id_groupe integer NOT NULL,
    nom character varying(255) NOT NULL,
    id_theme integer NOT NULL,
    description text,
    date_creation date NOT NULL
);


ALTER TABLE public.groupe OWNER TO postgres;

--
-- Name: groupe_id_groupe_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.groupe_id_groupe_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.groupe_id_groupe_seq OWNER TO postgres;

--
-- Name: groupe_id_groupe_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.groupe_id_groupe_seq OWNED BY public.groupe.id_groupe;


--
-- Name: interagir; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.interagir (
    id_interaction integer NOT NULL,
    id_publication integer NOT NULL,
    type_interaction character varying(50) NOT NULL,
    id_parent_interaction integer,
    contenu_commentaire text,
    date_interaction date NOT NULL,
    id_utilisateur integer NOT NULL
);


ALTER TABLE public.interagir OWNER TO postgres;

--
-- Name: interagir_id_interaction_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.interagir_id_interaction_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.interagir_id_interaction_seq OWNER TO postgres;

--
-- Name: interagir_id_interaction_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.interagir_id_interaction_seq OWNED BY public.interagir.id_interaction;


--
-- Name: publication; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.publication (
    id_publication integer NOT NULL,
    contenu text NOT NULL,
    type_publication character varying(50) NOT NULL,
    visibilite character varying(50) NOT NULL,
    id_theme integer NOT NULL,
    id_groupe integer,
    date_creation date NOT NULL
);


ALTER TABLE public.publication OWNER TO postgres;

--
-- Name: publication_id_publication_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.publication_id_publication_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.publication_id_publication_seq OWNER TO postgres;

--
-- Name: publication_id_publication_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.publication_id_publication_seq OWNED BY public.publication.id_publication;


--
-- Name: theme; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.theme (
    id_theme integer NOT NULL,
    nom character varying(255) NOT NULL,
    id_parent_theme integer
);


ALTER TABLE public.theme OWNER TO postgres;

--
-- Name: theme_id_theme_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.theme_id_theme_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.theme_id_theme_seq OWNER TO postgres;

--
-- Name: theme_id_theme_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.theme_id_theme_seq OWNED BY public.theme.id_theme;


--
-- Name: utilisateur; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.utilisateur (
    id_utilisateur integer NOT NULL,
    nom character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    date_inscription date NOT NULL
);


ALTER TABLE public.utilisateur OWNER TO postgres;

--
-- Name: utilisateur_id_utilisateur_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.utilisateur_id_utilisateur_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.utilisateur_id_utilisateur_seq OWNER TO postgres;

--
-- Name: utilisateur_id_utilisateur_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.utilisateur_id_utilisateur_seq OWNED BY public.utilisateur.id_utilisateur;


--
-- Name: watchtime; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.watchtime (
    id_utilisateur integer NOT NULL,
    id_publication integer NOT NULL,
    temps_debut time without time zone NOT NULL,
    temps_fin time without time zone NOT NULL,
    date_visionnage date NOT NULL
);


ALTER TABLE public.watchtime OWNER TO postgres;

--
-- Name: groupe id_groupe; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groupe ALTER COLUMN id_groupe SET DEFAULT nextval('public.groupe_id_groupe_seq'::regclass);


--
-- Name: interagir id_interaction; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interagir ALTER COLUMN id_interaction SET DEFAULT nextval('public.interagir_id_interaction_seq'::regclass);


--
-- Name: publication id_publication; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publication ALTER COLUMN id_publication SET DEFAULT nextval('public.publication_id_publication_seq'::regclass);


--
-- Name: theme id_theme; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.theme ALTER COLUMN id_theme SET DEFAULT nextval('public.theme_id_theme_seq'::regclass);


--
-- Name: utilisateur id_utilisateur; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utilisateur ALTER COLUMN id_utilisateur SET DEFAULT nextval('public.utilisateur_id_utilisateur_seq'::regclass);


--
-- Data for Name: adherer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.adherer (id_groupe, id_utilisateur, role, date_adhesion) FROM stdin;
\.
COPY public.adherer (id_groupe, id_utilisateur, role, date_adhesion) FROM '$$PATH$$/4922.dat';

--
-- Data for Name: bloquer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bloquer (id_utilisateur, id_utilisateur_bloque, type_blocage, date_debut, date_fin) FROM stdin;
\.
COPY public.bloquer (id_utilisateur, id_utilisateur_bloque, type_blocage, date_debut, date_fin) FROM '$$PATH$$/4925.dat';

--
-- Data for Name: connecter; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.connecter (id_utilisateur, type_connexion, date_connexion) FROM stdin;
\.
COPY public.connecter (id_utilisateur, type_connexion, date_connexion) FROM '$$PATH$$/4923.dat';

--
-- Data for Name: groupe; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groupe (id_groupe, nom, id_theme, description, date_creation) FROM stdin;
\.
COPY public.groupe (id_groupe, nom, id_theme, description, date_creation) FROM '$$PATH$$/4915.dat';

--
-- Data for Name: interagir; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.interagir (id_interaction, id_publication, type_interaction, id_parent_interaction, contenu_commentaire, date_interaction, id_utilisateur) FROM stdin;
\.
COPY public.interagir (id_interaction, id_publication, type_interaction, id_parent_interaction, contenu_commentaire, date_interaction, id_utilisateur) FROM '$$PATH$$/4921.dat';

--
-- Data for Name: publication; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.publication (id_publication, contenu, type_publication, visibilite, id_theme, id_groupe, date_creation) FROM stdin;
\.
COPY public.publication (id_publication, contenu, type_publication, visibilite, id_theme, id_groupe, date_creation) FROM '$$PATH$$/4919.dat';

--
-- Data for Name: theme; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.theme (id_theme, nom, id_parent_theme) FROM stdin;
\.
COPY public.theme (id_theme, nom, id_parent_theme) FROM '$$PATH$$/4913.dat';

--
-- Data for Name: utilisateur; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.utilisateur (id_utilisateur, nom, email, date_inscription) FROM stdin;
\.
COPY public.utilisateur (id_utilisateur, nom, email, date_inscription) FROM '$$PATH$$/4917.dat';

--
-- Data for Name: watchtime; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.watchtime (id_utilisateur, id_publication, temps_debut, temps_fin, date_visionnage) FROM stdin;
\.
COPY public.watchtime (id_utilisateur, id_publication, temps_debut, temps_fin, date_visionnage) FROM '$$PATH$$/4924.dat';

--
-- Name: groupe_id_groupe_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.groupe_id_groupe_seq', 1, false);


--
-- Name: interagir_id_interaction_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.interagir_id_interaction_seq', 1, false);


--
-- Name: publication_id_publication_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.publication_id_publication_seq', 1, false);


--
-- Name: theme_id_theme_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.theme_id_theme_seq', 1, false);


--
-- Name: utilisateur_id_utilisateur_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.utilisateur_id_utilisateur_seq', 1, false);


--
-- Name: adherer adherer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adherer
    ADD CONSTRAINT adherer_pkey PRIMARY KEY (id_groupe, id_utilisateur);


--
-- Name: bloquer bloquer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bloquer
    ADD CONSTRAINT bloquer_pkey PRIMARY KEY (id_utilisateur, id_utilisateur_bloque, date_debut);


--
-- Name: connecter connecter_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.connecter
    ADD CONSTRAINT connecter_pkey PRIMARY KEY (id_utilisateur, type_connexion, date_connexion);


--
-- Name: groupe groupe_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groupe
    ADD CONSTRAINT groupe_pkey PRIMARY KEY (id_groupe);


--
-- Name: interagir interagir_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interagir
    ADD CONSTRAINT interagir_pkey PRIMARY KEY (id_interaction);


--
-- Name: publication publication_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publication
    ADD CONSTRAINT publication_pkey PRIMARY KEY (id_publication);


--
-- Name: theme theme_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.theme
    ADD CONSTRAINT theme_pkey PRIMARY KEY (id_theme);


--
-- Name: utilisateur utilisateur_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utilisateur
    ADD CONSTRAINT utilisateur_pkey PRIMARY KEY (id_utilisateur);


--
-- Name: watchtime watchtime_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.watchtime
    ADD CONSTRAINT watchtime_pkey PRIMARY KEY (id_utilisateur, id_publication, date_visionnage);


--
-- Name: adherer adherer_id_groupe_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adherer
    ADD CONSTRAINT adherer_id_groupe_fkey FOREIGN KEY (id_groupe) REFERENCES public.groupe(id_groupe);


--
-- Name: adherer adherer_id_utilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adherer
    ADD CONSTRAINT adherer_id_utilisateur_fkey FOREIGN KEY (id_utilisateur) REFERENCES public.utilisateur(id_utilisateur);


--
-- Name: bloquer bloquer_id_utilisateur_bloque_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bloquer
    ADD CONSTRAINT bloquer_id_utilisateur_bloque_fkey FOREIGN KEY (id_utilisateur_bloque) REFERENCES public.utilisateur(id_utilisateur);


--
-- Name: bloquer bloquer_id_utilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bloquer
    ADD CONSTRAINT bloquer_id_utilisateur_fkey FOREIGN KEY (id_utilisateur) REFERENCES public.utilisateur(id_utilisateur);


--
-- Name: connecter connecter_id_utilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.connecter
    ADD CONSTRAINT connecter_id_utilisateur_fkey FOREIGN KEY (id_utilisateur) REFERENCES public.utilisateur(id_utilisateur);


--
-- Name: groupe groupe_id_theme_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groupe
    ADD CONSTRAINT groupe_id_theme_fkey FOREIGN KEY (id_theme) REFERENCES public.theme(id_theme);


--
-- Name: interagir interagir_id_publication_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interagir
    ADD CONSTRAINT interagir_id_publication_fkey FOREIGN KEY (id_publication) REFERENCES public.publication(id_publication);


--
-- Name: interagir interagir_id_utilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interagir
    ADD CONSTRAINT interagir_id_utilisateur_fkey FOREIGN KEY (id_utilisateur) REFERENCES public.utilisateur(id_utilisateur);


--
-- Name: publication publication_id_groupe_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publication
    ADD CONSTRAINT publication_id_groupe_fkey FOREIGN KEY (id_groupe) REFERENCES public.groupe(id_groupe);


--
-- Name: publication publication_id_theme_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publication
    ADD CONSTRAINT publication_id_theme_fkey FOREIGN KEY (id_theme) REFERENCES public.theme(id_theme);


--
-- Name: theme theme_id_parent_theme_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.theme
    ADD CONSTRAINT theme_id_parent_theme_fkey FOREIGN KEY (id_parent_theme) REFERENCES public.theme(id_theme);


--
-- Name: watchtime watchtime_id_publication_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.watchtime
    ADD CONSTRAINT watchtime_id_publication_fkey FOREIGN KEY (id_publication) REFERENCES public.publication(id_publication);


--
-- Name: watchtime watchtime_id_utilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.watchtime
    ADD CONSTRAINT watchtime_id_utilisateur_fkey FOREIGN KEY (id_utilisateur) REFERENCES public.utilisateur(id_utilisateur);


--
-- PostgreSQL database dump complete
--

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                