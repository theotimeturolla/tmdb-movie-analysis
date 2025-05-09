import requests
import csv
import time  # Pour éviter de surcharger l’API

load_dotenv() # Charge la clé depuis le .env

bearer_token = os.getenv("TMDB_BEARER_TOKEN")

headers = {
    "Authorization": f"Bearer {bearer_token}",
    "accept": "application/json"
}

movies = []

for page in range(1, 6):  # 5 pages = 100 films
    url = f"https://api.themoviedb.org/3/movie/popular?language=en-US&page={page}"
    response = requests.get(url, headers=headers)
    
    if response.status_code == 200:
        data = response.json()
        movies.extend(data["results"])
    else:
        print(f"Erreur sur la page {page} :", response.status_code)

enriched_movies = []

for movie in movies:
    movie_id = movie.get("id")
    
    # Détails du film
    details_url = f"https://api.themoviedb.org/3/movie/{movie_id}"
    details_resp = requests.get(details_url, headers=headers)
    
    # Casting du film
    credits_url = f"https://api.themoviedb.org/3/movie/{movie_id}/credits"
    credits_resp = requests.get(credits_url, headers=headers)
    
    if details_resp.status_code == 200 and credits_resp.status_code == 200:
        details = details_resp.json()
        credits = credits_resp.json()
        
        # Récupère les 3 premiers acteurs principaux
        top_cast = [member['name'] for member in credits.get("cast", [])[:3]]
        actors = ", ".join(top_cast)
        
        enriched_movies.append([
            movie.get("id"),
            movie.get("title"),
            movie.get("release_date"),
            movie.get("vote_average"),
            movie.get("vote_count"),
            movie.get("popularity"),
            movie.get("original_language"),
            movie.get("overview").replace('\n', ' ').replace('\r', '') if movie.get("overview") else "",
            details.get("runtime"),
            details.get("budget"),
            details.get("revenue"),
            actors
        ])
    
    time.sleep(0.25)  # Petite pause pour ne pas dépasser les limites de l’API

# Export CSV enrichi
with open("movies_enriched.csv", "w", newline="", encoding="utf-8") as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow([
        "id", "title", "release_date", "vote_average", "vote_count", "popularity",
        "original_language", "overview", "runtime", "budget", "revenue", "top_actors"
    ])

    for movie in enriched_movies:
        writer.writerow(movie)

print("✅ Fichier movies_enriched.csv créé avec succès !")
