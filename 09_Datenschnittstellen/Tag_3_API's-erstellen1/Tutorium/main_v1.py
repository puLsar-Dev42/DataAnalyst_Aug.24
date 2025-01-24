from fastapi import FastAPI, status

app = FastAPI()

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


# fn's

# get_all
@app.get('/movies/get_all', status_code=status.HTTP_200_OK)
def get_all():
	return movies


# get_all_unseen
@app.get('/movies/get_all_unseen', status_code=status.HTTP_200_OK)
def get_all_unseen():
	unseen = [movie for movie in movies if not movie["watched"]]
	if unseen:
		return unseen
	else:
		return {"msg": "No unseen movies"}


# get_all_seen
@app.get('/movies/get_all_seen', status_code=status.HTTP_200_OK)
def get_all_seen():
	seen = [movie for movie in movies if movie["watched"]]
	if seen:
		return seen
	else:
		return {'msg': 'No seen movies'}


# patch
@app.patch('/movies/update', status_code=status.HTTP_204_NO_CONTENT)
def update_watched(movie_id: int):
	changed = False
	for movie in movies:
		if movie['movie_id'] == movie_id:
			movie['watched'] = not movie['watched']
			changed = True
	
	if changed:
		return {'msg': 'Movie status changed!'}
	return {'msg': f'{movie_id} Not changed'}


# post
@app.post('/movies/add', status_code=status.HTTP_201_CREATED)
def add_movie(movie: dict):
	movies.append(movie)
	return {'msg': f'Movie {movie["title"]} added!'}


# delete
@app.delete('/movies/delete', status_code=status.HTTP_204_NO_CONTENT)
def delete_movie(movie_id: int):
	movies.pop(movie_id - 1)  # Index aushebeln
	return {'msg': f'Movie with ID {movie_id} deleted!'}
