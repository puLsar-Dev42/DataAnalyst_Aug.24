from fastapi import APIRouter, status, Depends
from app.models.BaseModel import Movie
from app.services.movie_service import get_all_movies, add_movie

# Endpunkte für Musicals
router = APIRouter()


@router.get('/get_all', status_code=status.HTTP_200_OK, tags=['GET'])
def list_musicals():
    return get_all_movies()


@router.post('/add_movie', status_code=status.HTTP_201_CREATED, tags=['POST'])
def create_musical(movie: Movie):
     return add_movie(movie)
