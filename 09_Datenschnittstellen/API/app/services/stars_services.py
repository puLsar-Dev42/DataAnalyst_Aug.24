# Imports:
from sqlalchemy.orm import Session
from app.models.BaseModel import HostStar


# get_all_planets service:
def get_all_stars(db: Session):
	stars = db.query(HostStar).all()
	return stars
