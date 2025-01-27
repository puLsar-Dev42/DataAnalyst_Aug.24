# Imports:
from pydantic import BaseModel
from typing import Optional


# API Meta table classes:

# Exo class:
class Exo(BaseModel):
	planet_id: int
	planet_name: Optional[str]
	planet_type: Optional[str]
	host_star_name: Optional[str]
	orbital_period_days: Optional[float]
	mass_multiplier: Optional[float]
	mass_wrt: Optional[str]
	radius_multiplier: Optional[float]
	radius_wrt: Optional[str]
	distance: Optional[float]
	discovery_year: Optional[float]
	
	class Config:
		from_attributes = True


# Star class:
class Star(BaseModel):
	star_id: int
	host_star_name: str
	spectral_type: str | None
	planet_name: str | None
	
	class Config:
		from_attributes = True


# PlanetType classes:

# Terrestrial class:
class Terrestrial(BaseModel):
	planet_id: int
	planet_name: Optional[str]
	planet_type: Optional[str]
	star_id: int
	
	class Config:
		from_attributes = True


# Super Earth class:
class SuperEarth(BaseModel):
	planet_id: int
	planet_name: Optional[str]
	planet_type: Optional[str]
	star_id: int
	
	class Config:
		from_attributes = True


# Gas Giant class:
class GasGiant(BaseModel):
	planet_id: int
	planet_name: Optional[str]
	planet_type: Optional[str]
	star_id: int
	
	class Config:
		from_attributes = True


# Neptune-like class:
class NeptuneLike(BaseModel):
	planet_id: int
	planet_name: Optional[str]
	planet_type: Optional[str]
	star_id: int
	
	class Config:
		from_attributes = True


# Unknown class:
class Unknown(BaseModel):
	planet_id: int
	planet_name: Optional[str]
	planet_type: Optional[str]
	star_id: int
	
	class Config:
		from_attributes = True
