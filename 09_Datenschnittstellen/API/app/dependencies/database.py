from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

# DB url & engine:
DB_URL = f"postgresql://postgres:42@localhost:5432/nasa_exoplanets"
engine = create_engine(DB_URL)

# Create session:
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


# Dependency for FastAPI
def get_db():
	db = SessionLocal()
	try:
		yield db
	finally:
		db.close()
