# Imports:
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

# Services & Dependencies
from app.dependencies.database import get_db
from app.schemas.PydanticSchemas import Star
from app.services.stars_services import get_all_stars

# Stars endpoint:
router = APIRouter()


# Endpoint all_stars:
@router.get('/get_all_stars',
			response_model=List[Star],
			status_code=status.HTTP_200_OK,
			tags=['Meta'])
def fetch_all_stars(db: Session = Depends(get_db)):
	try:
		stars = get_all_stars(db)
		return stars
	except Exception as e:
		raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
							detail=f"Error: {str(e)}")
