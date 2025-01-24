import sqlite3
from fastapi import FastAPI, status, HTTPException
from app.routes.movie_routes import router as movie_router

# Init
app = FastAPI(title='🎦MovieAPI🎦',
              summary='API to manage Movie DB')


# Routen an App binden:
app.include_router(movie_router, prefix='/movies', tags=['Musicals'])



# Home/ Root
@app.get('/', status_code=status.HTTP_200_OK, tags=['Welcome'])
def read_root():
    return {"msg": "Welcome our 🎦MovieAPI🎦."}





# # get_all_unseen
# @app.get('/movies/get_all_unseen/', status_code=status.HTTP_200_OK, tags=['Data'])
# def get_all_unseen():
#     unseen = [movie for movie in movies if not movie["watched"]]
#     if unseen:
#         return unseen
#     else:
#         raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
#                             detail='No unseen Movies found!')
#
#
# # get_all_seen
# @app.get('/movies/get_all_seen/', status_code=status.HTTP_200_OK, tags=['Data'])
# def get_all_seen():
#     seen = [movie for movie in movies if movie["watched"]]
#     if seen:
#         return seen
#     else:
#         raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
#                             detail='No Movies found!')
#
#
# # patch
# @app.patch('/movies/update/', status_code=status.HTTP_204_NO_CONTENT, tags=['Controller'])
# def update_watched(movie_id: int):
#     changed = False
#     for movie in movies:
#         if movie['movie_id'] == movie_id:
#             movie['watched'] = not movie['watched']
#             changed = True
#
#     if changed:
#         return {'msg': 'Movie status changed!'}
#     else:
#         raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
#                             detail='Status not changed!')
#
#
# # post
# @app.post('/movies/add/', status_code=status.HTTP_201_CREATED, tags=['Data'])
# def add_movie(movie: Movie):
#     max_id = movie[-1]['movie_id']
#     movie_dict = movie.model_dump()
#     movie_dict['movie_id'] = max_id + 1
#     movies.append(movie_dict)
#     return {'msg': f'Movie {movie["title"]} added!'}
#
#
# # delete
# @app.delete('/movies/delete/', status_code=status.HTTP_204_NO_CONTENT, tags=['Controller'])
# def delete_movie(movie_id: int):
#     for movie in movies:
#         if movie['movie_id'] == movie_id:
#             movies.remove(movie)
#             return {'msg': 'Movie deleted from list!'}
#
#     raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
#                         detail="No movie found.")
#