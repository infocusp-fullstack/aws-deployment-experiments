from fastapi import FastAPI

from backend.app import database, models, routes

models.Base.metadata.create_all(bind=database.engine)

app = FastAPI(title="FastAPI SQLite CRUD API")

app.include_router(routes.router)


# health check endpoint
@app.get("/health")
def health_check():
    """Health check endpoint to verify the server is running."""
    return {"status": "ok"}
