from sqlalchemy.orm import Session

from . import models, schemas


def create_todo(db: Session, todo: schemas.TodoCreate) -> models.Todo:
    """Create a new todo in the database.

    Args:
        db (Session): Database session.
        todo (schemas.TodoCreate): Todo data to create.

    Returns:
        models.Todo: The created todo.
    """
    db_todo = models.Todo(name=todo.name, description=todo.description)
    db.add(db_todo)
    db.commit()
    db.refresh(db_todo)
    return db_todo


def get_todos(db: Session) -> list[models.Todo]:
    """Retrieve all todos from the database.

    Args:
        db (Session): Database session.

    Returns:
        list[models.Todo]: List of all todos.
    """
    return db.query(models.Todo).all()


def get_todo(db: Session, todo_id: int) -> models.Todo | None:
    """Retrieve a single todo by its ID.
    Args:
        db (Session): Database session.
        todo_id (int): ID of the todo to retrieve.

    Returns:
        models.Todo | None: The todo if found, otherwise None.
    """
    return db.query(models.Todo).filter(models.Todo.id == todo_id).first()


def update_todo(db: Session, todo_id: int, todo: schemas.TodoCreate):
    """Update an existing todo in the database.
    Args:
        db (Session): Database session.
        todo_id (int): ID of the todo to update.
        todo (schemas.TodoCreate): Updated todo data.
    Returns:
        models.Todo | None: The updated todot if found, otherwise None.
    """
    db_todo = get_todo(db, todo_id)
    if db_todo:
        db_todo.name = todo.name
        db_todo.description = todo.description
        db.commit()
        db.refresh(db_todo)
    return db_todo


def delete_todo(db: Session, todo_id: int) -> models.Todo | None:
    """Delete an todo from the database.

    Args:
        db (Session): Database session.
        todo_id (int): ID of the todo to delete.

    Returns:
        models.Todo | None: The deleted todo if found, otherwise None.
    """
    db_todo = get_todo(db, todo_id)
    if db_todo:
        db.delete(db_todo)
        db.commit()
    return db_todo
