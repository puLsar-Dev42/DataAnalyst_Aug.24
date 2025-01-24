import sqlite3
from fastapi import FastAPI, status, HTTPException, Depends
from pydantic import BaseModel, Field

app = FastAPI(title='🎦MovieAPI🎦',
			  summary='API to manage Movie DB')

movies = [
	dict(movie_id=1, title="Fear & Lothing in Las Vegas", duration=118, genre="Comedy-Adventure",
		 watched=True, release_year=1998),
	dict(movie_id=2, title="Blow", duration=124, genre="Docu-Drama", watched=True,
		 release_year=2001),
	dict(movie_id=3, title="Natural Born Kills", duration=119, genre="Action-Crime",
		 watched=True, release_year=1994),
	dict(movie_id=4, title="James Bond 'Golden Eye'", duration=130, genre="Action-Adventure",
		 watched=True, release_year=1995),
	dict(movie_id=5, title="Stephen King's ES", duration=192, genre='Horror',
		 watched=True, release_year=1990),
	dict(movie_id=6, title="Bad Boys", duration=114, genre="Action-Comedy",
		 watched=True, release_year=1995),
	dict(movie_id=7, title="Interstellar", duration=169, genre="Sci-Fi",
		 watched=True, release_year=2014),
	dict(movie_id=8, title="Primer", duration=77, genre="Sci-Fi",
		 watched=True, release_year=2004),
	dict(movie_id=9, title="Waking Life", duration=160, genre="Animation-Drama",
		 watched=True, release_year=2001),
	dict(movie_id=10, title="Hangover 1", duration=100, genre="Comedy-Adventure",
		 watched=True, release_year=2009)
]


# class(BaseModel)

class Movie(BaseModel):
	title: str = Field(min_length=2, max_length=75, default='Please enter title')
	duration: int = Field(gt=0)
	genre: str = Field(min_length=5, max_length=75, default='Please enter genre')
	watched: bool = False
	release_year: int = Field(ge=1900, lt=2026)


# connection sqlite db

# connection
def get_connected():
	return sqlite3.connect('movies.sqlite')


# fn's

# root
@app.get('/', status_code=status.HTTP_200_OK, tags=['Welcome'])
def greet_user():
	return {'msg': 'Welcome to The 🎦MovieAPI🎦'}


# get_all
@app.get('/movies/get_all/', status_code=status.HTTP_200_OK, tags=['Data'])
def get_all(conn=Depends(get_connected)):
	query = 'SELECT * FROM movies;'
	cursor = conn.cursor()
	cursor.execute(query)
	movies = cursor.fetchall()
	movies_list = []
	
	for movie in movies:
		movie_dict = {'movie_id': movie[0], 'title': movie[1], 'duration': movie[2],
					  'genre': movie[3], 'watched': movie[4], 'release_year': movie[5]}
		movies_list.append(movie_dict)
	
	return movies_list


# get_all_unseen
@app.get('/movies/get_all_unseen/', status_code=status.HTTP_200_OK, tags=['Data'])
def get_all_unseen():
	unseen = [movie for movie in movies if not movie["watched"]]
	if unseen:
		return unseen
	else:
		raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
							detail='No unseen Movies found!')


# get_all_seen
@app.get('/movies/get_all_seen/', status_code=status.HTTP_200_OK, tags=['Data'])
def get_all_seen():
	seen = [movie for movie in movies if movie["watched"]]
	if seen:
		return seen
	else:
		raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
							detail='No Movies found!')


# patch
@app.patch('/movies/update/', status_code=status.HTTP_204_NO_CONTENT, tags=['Controller'])
def update_watched(movie_id: int):
	changed = False
	for movie in movies:
		if movie['movie_id'] == movie_id:
			movie['watched'] = not movie['watched']
			changed = True
	
	if changed:
		return {'msg': 'Movie status changed!'}
	else:
		raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
							detail='Status not changed!')


# post
@app.post('/movies/add/', status_code=status.HTTP_201_CREATED, tags=['Data'])
def add_movie(movie: Movie):
	max_id = movie[-1]['movie_id']
	movie_dict = movie.model_dump()
	movie_dict['movie_id'] = max_id + 1
	movies.append(movie_dict)
	return {'msg': f'Movie {movie["title"]} added!'}


# delete
@app.delete('/movies/delete/', status_code=status.HTTP_204_NO_CONTENT, tags=['Controller'])
def delete_movie(movie_id: int):
	for movie in movies:
		if movie['movie_id'] == movie_id:
			movies.remove(movie)
			return {'msg': 'Movie deleted from list!'}
	
	raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
						detail="No movie found.")
