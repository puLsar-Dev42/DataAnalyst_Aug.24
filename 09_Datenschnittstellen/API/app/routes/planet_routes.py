# Imports:
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import text
from sqlalchemy.orm import Session
from typing import List

# Services & Dependencies
from app.dependencies.database import get_db
from app.services.planets_services import (get_all_planets,
										   get_all_terrestrials,
										   get_all_super_earths,
										   get_all_gas_giants,
										   get_all_neptune_likes,
										   get_all_unknowns)
from app.schemas.PydanticSchemas import (Exo,
										 Terrestrial,
										 SuperEarth,
										 GasGiant,
										 NeptuneLike,
										 Unknown)

# Planets endpoint:
router = APIRouter()


# Endpoint all_planets:
@router.get('/get_all_planets',
			response_model=List[Exo],
			status_code=status.HTTP_200_OK,
			tags=['Meta'])
def fetch_all_planets(db: Session = Depends(get_db)):
	try:
		planets = get_all_planets(db)
		return planets
	except Exception as e:
		raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
							detail=f"Error: {str(e)}")


# Endpoint all_terrestrials:
@router.get('/get_all_terrestrials',
			response_model=List[Terrestrial],
			status_code=status.HTTP_200_OK,
			tags=['Filtered By Planet Types'])
def fetch_all_terrestrials(db: Session = Depends(get_db)):
	try:
		terrestrials = get_all_terrestrials(db)
		return terrestrials
	except Exception as e:
		raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
							detail=f"Error: {str(e)}")


# Endpoint all_super_earths:
@router.get('/get_all_super_earths',
			response_model=List[SuperEarth],
			status_code=status.HTTP_200_OK,
			tags=['Filtered By Planet Types'])
def fetch_all_super_earths(db: Session = Depends(get_db)):
	try:
		super_earths = get_all_super_earths(db)
		return super_earths
	except Exception as e:
		raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
							detail=f"Error: {str(e)}")


# Endpoint all_gas_giants:
@router.get('/get_all_gas_giants',
			response_model=List[GasGiant],
			status_code=status.HTTP_200_OK,
			tags=['Filtered By Planet Types'])
def fetch_all_gas_giants(db: Session = Depends(get_db)):
	try:
		gas_giants = get_all_gas_giants(db)
		return gas_giants
	except Exception as e:
		raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
							detail=f"Error: {str(e)}")


# Endpoint all_neptune_likes:
@router.get('/get_all_neptune_like',
			response_model=List[NeptuneLike],
			status_code=status.HTTP_200_OK,
			tags=['Filtered By Planet Types'])
def fetch_all_neptune_likes(db: Session = Depends(get_db)):
	try:
		neptune_likes = get_all_neptune_likes(db)
		return neptune_likes
	except Exception as e:
		raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
							detail=f"Error: {str(e)}")


# Endpoint all_unknowns:
@router.get('/get_all_unknown',
			response_model=List[Unknown],
			status_code=status.HTTP_200_OK,
			tags=['Filtered By Planet Types'])
def fetch_all_unknown(db: Session = Depends(get_db)):
	try:
		unknowns = get_all_unknowns(db)
		return unknowns
	except Exception as e:
		raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
							detail=f"Error: {str(e)}")

# Endpoint terrestrials filtered by star_id:
# @router.get('/get_terrestrials_filtered_by_star_id/{star_id}',
# 			response_model=List[Terrestrial],
# 			status_code=status.HTTP_200_OK,
# 			tags=['Filtered By Star ID'])
# def filtered_by_star_id(star_id: int, db: Session = Depends(get_db)):
# 	query = text("SELECT * FROM terrestrial_planets WHERE star_id = :star_id ORDER BY star_id")
# 	terrestrials = db.execute(query, {"star_id": star_id}).fetchall()
# 	if not terrestrials:
# 		raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
# 							detail=f"No planets found for star_id: {star_id}")
#
# 	terrestrial_planets = [
# 		{"planet_id": row.planet_id, "planet_name": row.planet_name, "planet_type": row.planet_type,
# 		 "star_id": row.star_id}
# 		for row in terrestrials
# 	]
# 	return terrestrial_planets
#
#
# # Endpoint super earths filtered by star_id:
# @router.get('/get_super_earths_filtered_by_star_id/{star_id}',
# 			response_model=List[SuperEarth],
# 			status_code=status.HTTP_200_OK,
# 			tags=['Filtered By Star ID'])
# def filtered_by_star_id(star_id: int, db: Session = Depends(get_db)):
# 	query = text("SELECT * FROM super_earth_planets WHERE star_id = :star_id")
# 	super_earths = db.execute(query, {"star_id": star_id}).fetchall()
# 	if not super_earths:
# 		raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
# 							detail=f"No planets found for star_id: {star_id}")
#
# 	super_earth_planets = [
# 		{"planet_id": row.planet_id, "planet_name": row.planet_name, "planet_type": row.planet_type,
# 		 "star_id": row.star_id}
# 		for row in super_earths
# 	]
# 	return super_earth_planets
