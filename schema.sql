--Création des tables:

-- Table des films
CREATE TABLE movies (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    release_date TEXT,
    original_language TEXT,
    overview TEXT,
    runtime INTEGER
);

-- Table des acteurs (casting)
CREATE TABLE casting (
    id INTEGER PRIMARY KEY,
    actor_name TEXT NOT NULL
);

-- Table de liaison films ↔ acteurs
CREATE TABLE movie_cast (
    movie_id INTEGER,
    actor_id INTEGER,
    role TEXT,
    PRIMARY KEY (movie_id, actor_id),
    FOREIGN KEY (movie_id) REFERENCES movies(id),
    FOREIGN KEY (actor_id) REFERENCES casting(id)
);

-- Table des notations (ratings)
CREATE TABLE ratings (
    movie_id INTEGER PRIMARY KEY,
    vote_average REAL,
    vote_count INTEGER,
    popularity REAL,
    FOREIGN KEY (movie_id) REFERENCES movies(id)
);

-- Table des finances (budget et revenus)
CREATE TABLE finance (
    movie_id INTEGER PRIMARY KEY,
    budget INTEGER,
    revenue INTEGER,
    FOREIGN KEY (movie_id) REFERENCES movies(id)
);



-- table temporaire pour inserer les données:
CREATE TABLE raw_movies (
    id INTEGER,
    title TEXT,
    release_date TEXT,
    vote_average REAL,
    vote_count INTEGER,
    popularity REAL,
    original_language TEXT,
    overview TEXT,
    runtime INTEGER,
    budget INTEGER,
    revenue INTEGER,
    top_actors TEXT
);

-- IMPORT DU FICHIER CSV
.mode csv
.separator ","
.import C:/Users/theot/movies_enriched.csv raw_movies

-- SUPPRESSION DE L'ÉVENTUELLE LIGNE D'EN-TÊTE DU CSV
DELETE FROM raw_movies
WHERE id = 'id';


-- Insertion des données dans les tables (+ gestion des doublons problématiques):

INSERT OR IGNORE INTO movies (id, title, release_date, original_language, overview, runtime)
SELECT DISTINCT 
    id, title, release_date, original_language, overview, runtime
FROM raw_movies;


INSERT OR IGNORE INTO ratings (movie_id, vote_average, vote_count, popularity)
SELECT DISTINCT 
    id, vote_average, vote_count, popularity
FROM raw_movies;

INSERT OR IGNORE INTO finance (movie_id, budget, revenue)
SELECT DISTINCT 
    id, budget, revenue
FROM raw_movies;

INSERT OR IGNORE INTO casting (actor_name)
SELECT DISTINCT TRIM(value) AS actor_name
FROM raw_movies, 
     json_each('["' || REPLACE(top_actors, ',', '","') || '"]');

INSERT OR IGNORE INTO movie_cast (movie_id, actor_id, role)
SELECT DISTINCT 
    r.id AS movie_id,
    c.id AS actor_id,
    NULL  
FROM raw_movies r
JOIN json_each('["' || REPLACE(r.top_actors, ',', '","') || '"]') AS actors
JOIN casting c ON TRIM(actors.value) = c.actor_name;


-- deerniers ajustements: 

DELETE FROM casting WHERE actor_name = 'top_actors';

DELETE FROM movie_cast 
WHERE movie_id = 'id' OR actor_id = 1;


-- Quelques stats pour vérifier qu'il n'y ait pas d'erreurs et mobiliser les notions des premiers cours:

--Top 10 des films les plus rentables (revenu - budget)

SELECT m.title, (f.revenue - f.budget) AS profit
FROM movies m
JOIN finance f ON m.id = f.movie_id
ORDER BY profit DESC
LIMIT 10;

--Les 5 acteurs qui ont joué dans le plus de films (de notre petit échantillon)

SELECT c.actor_name, COUNT(*) AS nb_movies
FROM movie_cast mc
JOIN casting c ON mc.actor_id = c.id
GROUP BY c.actor_name
ORDER BY nb_movies DESC
LIMIT 5;

-- Les films les mieux notés (au moins 100 votes pour etre représentatif)
SELECT m.title, r.vote_average, r.vote_count
FROM movies m
JOIN ratings r ON m.id = r.movie_id
WHERE r.vote_count >= 100
ORDER BY r.vote_average DESC
LIMIT 10;

--Nombre de filsm sortis par année 

SELECT SUBSTR(release_date, 1, 4) AS year, COUNT(*) AS nb_films
FROM movies
GROUP BY year
ORDER BY year DESC;

--Films où joue Marlon Brando

SELECT m.title
FROM movie_cast mc
JOIN casting c ON mc.actor_id = c.id
JOIN movies m ON mc.movie_id = m.id
WHERE c.actor_name = 'Marlon Brando';

-- films les + populaires

SELECT m.title, r.popularity
FROM movies m
JOIN ratings r ON m.id = r.movie_id
ORDER BY r.popularity DESC
LIMIT 10;

-- les langues qui ont produies plus de 5 films en VO (pour utiliser having)  --> peut trouver mieux a revoir  + bdd pas suffisamment grande pour les autres langues VO

SELECT original_language, COUNT(*) AS nb_films
FROM movies
GROUP BY original_language
HAVING nb_films > 5
ORDER BY nb_films DESC;

-- Trouver les films avec Leonardo DiCaprio comme acteur (sans join) -->  ne fonctionne pas a revoir

SELECT title 
FROM movies 
WHERE id IN (
    SELECT movie_id 
    FROM movie_cast 
    WHERE actor_id = (
        SELECT id 
        FROM casting 
        WHERE actor_name = 'Leonardo DiCaprio'
    )
);


-- Top 5 acteurs avec les meilleurs films en note moyenne

SELECT c.actor_name, AVG(r.vote_average) AS avg_rating
FROM movie_cast mc
JOIN casting c ON mc.actor_id = c.id
JOIN ratings r ON mc.movie_id = r.movie_id
GROUP BY c.actor_name
HAVING COUNT(mc.movie_id) >= 2
ORDER BY avg_rating DESC
LIMIT 5;

