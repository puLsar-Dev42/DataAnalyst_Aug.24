# Imports:
from sqlalchemy import Column, Integer, String, Float, ForeignKey
from app.dependencies.database import Base


# DB Meta table classes:

# ExoPlanet class:
class Exoplanet(Base):
	__tablename__ = "planets"
	
	planet_name = Column(String(75), nullable=True)
	planet_type = Column(String(15), nullable=True)
	host_star_name = Column(String(75), nullable=True)
	orbital_period_days = Column(Float, nullable=True)
	mass_multiplier = Column(Float, nullable=True)
	mass_wrt = Column(String(15), nullable=True)
	radius_multiplier = Column(Float, nullable=True)
	radius_wrt = Column(String(15), nullable=True)
	distance = Column(Float, nullable=True)
	discovery_year = Column(Integer, nullable=True)
	planet_id = Column(Integer, primary_key=True, autoincrement=True)


# HostStar class:
class HostStar(Base):
	__tablename__ = "stars"
	
	host_star_name = Column(String(75), nullable=False)
	spectral_type = Column(String(75), nullable=True)
	planet_name = Column(String(75), nullable=True)
	star_id = Column(Integer, primary_key=True, autoincrement=True)


# PlanetType classes:

# Terrestrial class:
class TerrestrialPlanets(Base):
	__tablename__ = "terrestrial_planets"
	
	planet_id = Column(Integer, autoincrement=True, primary_key=True)
	planet_name = Column(String(75), nullable=True)
	planet_type = Column(String(15), nullable=True)
	star_id = Column(Integer, ForeignKey("stars.star_id"), nullable=False, index=True)


# Super Earth class:
class SuperEarthPlanets(Base):
	__tablename__ = "super_earth_planets"
	
	planet_id = Column(Integer, autoincrement=True, primary_key=True)
	planet_name = Column(String(75), nullable=True)
	planet_type = Column(String(15), nullable=True)
	star_id = Column(Integer, ForeignKey("stars.star_id"), nullable=False, index=True)


# Gas Giant class:
class GasGiantPlanets(Base):
	__tablename__ = "gas_giant_planets"
	
	planet_id = Column(Integer, autoincrement=True, primary_key=True)
	planet_name = Column(String(75), nullable=True)
	planet_type = Column(String(15), nullable=True)
	star_id = Column(Integer, ForeignKey("stars.star_id"), nullable=False, index=True)


# Neptune-like class:
class NeptuneLikePlanets(Base):
	__tablename__ = "neptune_like_planets"
	
	planet_id = Column(Integer, autoincrement=True, primary_key=True)
	planet_name = Column(String(75), nullable=True)
	planet_type = Column(String(15), nullable=True)
	star_id = Column(Integer, ForeignKey("stars.star_id"), nullable=False, index=True)


# Unknown class:
class UnknownPlanets(Base):
	__tablename__ = "unknown_planets"
	
	planet_id = Column(Integer, autoincrement=True, primary_key=True)
	planet_name = Column(String(75), nullable=True)
	planet_type = Column(String(15), nullable=True)
	star_id = Column(Integer, ForeignKey("stars.star_id"), nullable=False, index=True)
