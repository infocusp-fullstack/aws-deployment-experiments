from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from . import crud, schemas
from .database import get_db

router = APIRouter()


@router.post("/items/", response_model=schemas.ItemRead)
def create_item(item: schemas.ItemCreate, db: Session = Depends(get_db)):
    """Create a new item in the database.

    Routes:
        POST /items/
    Args:
        item (schemas.ItemCreate): Item data to create.
        db (Session): Database session.
    """
    return crud.create_item(db, item)


@router.get("/items/", response_model=list[schemas.ItemRead])
def read_items(db: Session = Depends(get_db)):
    """Retrieve all items from the database.

    Routes:
        GET /items/
    Args:
        db (Session): Database session.
    Returns:
        list[schemas.ItemRead]: List of all items.
    """
    return crud.get_items(db)


@router.get("/items/{item_id}", response_model=schemas.ItemRead)
def read_item(item_id: int, db: Session = Depends(get_db)):
    db_item = crud.get_item(db, item_id)
    if not db_item:
        raise HTTPException(status_code=404, detail="Item not found")
    return db_item


@router.put("/items/{item_id}", response_model=schemas.ItemRead)
def update_item(item_id: int, item: schemas.ItemCreate, db: Session = Depends(get_db)):
    db_item = crud.update_item(db, item_id, item)
    if not db_item:
        raise HTTPException(status_code=404, detail="Item not found")
    return db_item


@router.delete("/items/{item_id}")
def delete_item(item_id: int, db: Session = Depends(get_db)):
    db_item = crud.delete_item(db, item_id)
    if not db_item:
        raise HTTPException(status_code=404, detail="Item not found")
    return {"message": "Item deleted successfully"}
