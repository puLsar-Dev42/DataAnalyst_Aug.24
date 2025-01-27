from sqlalchemy.orm import Session
from app.models.BaseModel import (Exoplanet,
								  TerrestrialPlanets,
								  SuperEarthPlanets,
								  GasGiantPlanets,
								  NeptuneLikePlanets,
								  UnknownPlanets)


# get_all_planets service:
def get_all_planets(db: Session):
	planets = db.query(Exoplanet).all()
	for planet in planets:
		# Set default values, if values are None or Null
		if not planet.planet_name:
			planet.planet_name = "Unknown"
		if not planet.orbital_period_days:
			planet.orbital_period_days = 0.00
	return planets


# get_all_terrestrial service:
def get_all_terrestrials(db: Session):
	terrestrials = db.query(TerrestrialPlanets).all()
	return terrestrials


# get_all_super_earth service:
def get_all_super_earths(db: Session):
	super_earths = db.query(SuperEarthPlanets).all()
	return super_earths


# get_all_gas_giant service:
def get_all_gas_giants(db: Session):
	gas_giants = db.query(GasGiantPlanets).all()
	return gas_giants


# get_all_neptune-like service:
def get_all_neptune_likes(db: Session):
	neptune_likes = db.query(NeptuneLikePlanets).all()
	return neptune_likes


# get_all_unknown service:
def get_all_unknowns(db: Session):
	unknowns = db.query(UnknownPlanets).all()
	return unknowns
