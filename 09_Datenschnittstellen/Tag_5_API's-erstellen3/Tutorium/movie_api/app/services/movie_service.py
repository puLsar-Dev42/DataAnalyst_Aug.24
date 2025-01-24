import sqlite3
from app.models.BaseModel import Movie

def get_con():
    return sqlite3.connect('app/data/movies_api.sqlite')

# get_all
def get_all_movies():
    con=get_con()
    cursor = con.cursor()
    cursor.execute("SELECT * FROM movies;")
    movies = cursor.fetchall()
    movies_list = []

    for movie in movies:
        movie_dict = {'movie_id': movie[0], 'title': movie[1], 'duration': movie[2],
                      'genre': movie[3], 'watched': movie[4], 'release_year': movie[5]}
        movies_list.append(movie_dict)

    return movies_list

# post a movie
def add_movie(movie: Movie):
    pass