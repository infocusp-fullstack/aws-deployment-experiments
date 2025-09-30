import os

from app import database, models, routes
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

models.Base.metadata.create_all(bind=database.engine)

app = FastAPI(title="FastAPI SQLite CRUD API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.router.prefix = "/api"

app.include_router(routes.router)


# health check endpoint
@app.get("/health")
def health_check():
    """Health check endpoint to verify the server is running."""
    return {"status": "ok", "hostname": os.uname().nodename}
    
