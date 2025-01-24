from pydantic import BaseModel, Field

class Movie(BaseModel):
	title: str = Field(min_length=2, max_length=75, default='Please enter title')
	duration: int = Field(gt=0)
	genre: str = Field(min_length=5, max_length=75, default='Please enter genre')
	watched: bool = False
	release_year: int = Field(ge=1900, lt=2026)