from app import database, models, routes
from fastapi import FastAPI

models.Base.metadata.create_all(bind=database.engine)

app = FastAPI(title="FastAPI SQLite CRUD API")

app.include_router(routes.router)
