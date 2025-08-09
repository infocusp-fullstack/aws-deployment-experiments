from sqlalchemy.orm import Session
from . import models, schemas


def create_item(db: Session, item: schemas.ItemCreate) -> models.Item:
    """Create a new item in the database.

    Args:
        db (Session): Database session.
        item (schemas.ItemCreate): Item data to create.

    Returns:
        models.Item: The created item.
    """
    db_item = models.Item(name=item.name, description=item.description)
    db.add(db_item)
    db.commit()
    db.refresh(db_item)
    return db_item


def get_items(db: Session) -> list[models.Item]:
    """Retrieve all items from the database.

    Args:
        db (Session): Database session.

    Returns:
        list[models.Item]: List of all items.
    """
    return db.query(models.Item).all()


def get_item(db: Session, item_id: int) -> models.Item | None:
    """Retrieve a single item by its ID.
    Args:
        db (Session): Database session.
        item_id (int): ID of the item to retrieve.

    Returns:
        models.Item | None: The item if found, otherwise None.
    """
    return db.query(models.Item).filter(models.Item.id == item_id).first()


def update_item(db: Session, item_id: int, item: schemas.ItemCreate):
    """Update an existing item in the database.
    Args:
        db (Session): Database session.
        item_id (int): ID of the item to update.
        item (schemas.ItemCreate): Updated item data.
    Returns:
        models.Item | None: The updated item if found, otherwise None.
    """
    db_item = get_item(db, item_id)
    if db_item:
        db_item.name = item.name
        db_item.description = item.description
        db.commit()
        db.refresh(db_item)
    return db_item


def delete_item(db: Session, item_id: int):
    """Delete an item from the database.

    Args:
        db (Session): Database session.
        item_id (int): ID of the item to delete.

    Returns:
        models.Item | None: The deleted item if found, otherwise None.
    """
    db_item = get_item(db, item_id)
    if db_item:
        db.delete(db_item)
        db.commit()
    return db_item
