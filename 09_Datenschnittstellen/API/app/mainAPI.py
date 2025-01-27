# Imports:
from fastapi import FastAPI, status, HTTPException
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.routes.planet_routes import router as planet_router
from app.routes.star_routes import router as star_router

# API:
app = FastAPI(title="👽 exoplanetAPI 👽",
			  summary="API: with Nasa-Exoplanets until 2023")

# Planets Router:
app.include_router(planet_router)

# Stars Router:
app.include_router(star_router)
