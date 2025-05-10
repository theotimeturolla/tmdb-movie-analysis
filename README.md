# 🎬 TMDB Movie Data Analysis

Projet de récupération, normalisation et analyse de données de films à partir de l'API TMDB.

## 📂 Structure du Projet

```
├── tmdb_extract.py      # Script pour récupérer et enrichir les données de films  
├── schema.sql           # Script SQL pour créer la base de données relationnelle  
├── movies_enriched.csv  # Données enrichies exportées (non versionnées)  
├── .env                 # Clé API TMDB (non versionné)  
└── README.md            # Ce fichier  
```

---

## 🚀 Comment utiliser le projet ?

### 1️⃣ Récupération des données

- Installer les librairies nécessaires :

```bash
pip install requests python-dotenv
```

- Configurer la clé API dans un fichier `.env` à la racine du projet :

```env
TMDB_BEARER_TOKEN=ta_clé_tmdb_ici
```

- Exécuter le script pour récupérer et enrichir les données :

```bash
python tmdb_extract.py
```

Un fichier `movies_enriched.csv` sera généré avec les données enrichies.

### 2️⃣ Création de la base de données

- Exécuter le script SQL pour créer les tables (exemple avec SQLite) :

```sql
.read schema.sql
```

- Importer les données du fichier `movies_enriched.csv` dans la table correspondante.

### 3️⃣ Analyse des données

Tu peux ensuite effectuer des requêtes SQL pour analyser :
- La popularité des films par année.
- Les films ayant les meilleurs scores de vote.
- Les budgets et revenus moyens par langue ou genre de film.
- Le casting le plus récurrent, etc.

---
### 📂 Données incluses

Le fichier `movies_enriched.csv` est directement inclus dans ce dépôt afin de faciliter l’accès aux données sans avoir besoin de réexécuter le script d’extraction.  

Cette base de données a été générée à partir de l’API TMDB et peut être utilisée directement pour les analyses SQL présentées dans ce projet.

## 📚 Fonctionnalités prévues

- ✅ Extraction des données via l'API TMDB.  
- ✅ Nettoyage et enrichissement des données.  
- ✅ Création d'une base de données relationnelle normalisée.  
- ✅ Analyse via requêtes SQL.

  📖 *Ce projet a été réalisé en collaboration avec Lucien Bauer Eberspecher dans le cadre d'un devoir académique.*
