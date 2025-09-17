from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from . import crud, schemas
from .database import get_db

router = APIRouter()


@router.post("/todos/", response_model=schemas.TodoRead, status_code=201)
def create_todo(todo: schemas.TodoCreate, db: Session = Depends(get_db)):
    """Create a new todo in the database.

    Routes:
        POST /todos/
    Args:
        Todo (schemas.TodoCreate): Todo data to create.
        db (Session): Database session.
    """
    print("Creating todo:", todo)
    try:
        return crud.create_todo(db, todo)
    except Exception as e:
        print("Error creating todo:", e)
        return {}
        # raise HTTPException(status_code=500, detail="Internal Server Error")


@router.get("/todos/", response_model=list[schemas.TodoRead])
def read_todos(db: Session = Depends(get_db)):
    """Retrieve all todos from the database.

    Routes:
        GET /todos/
    Args:
        db (Session): Database session.
    Returns:
        list[schemas.TodoRead]: List of all todos.
    """
    return crud.get_todos(db)


@router.get("/todos/{todo_id}", response_model=schemas.TodoRead)
def read_todo(todo_id: int, db: Session = Depends(get_db)):
    """Retrieve a specific todo by ID.

    Args:
        todo_id (int): ID of the todo to retrieve.
        db (Session): Database session.

    Returns:
        schemas.TodoRead: The todo with the specified ID.
    """
    db_todo = crud.get_todo(db, todo_id)
    if not db_todo:
        raise HTTPException(status_code=404, detail="Todo not found")
    return db_todo


@router.put("/todos/{todo_id}", response_model=schemas.TodoRead)
def update_todo(todo_id: int, todo: schemas.TodoCreate, db: Session = Depends(get_db)):
    """Update an existing todo by ID.

    Args:
        todo_id (int): ID of the todo to update.
        todo (schemas.TodoCreate): Updated todo data.
        db (Session): Database session.

    Returns:
        schemas.TodoRead: The updated todo.
    """
    db_todo = crud.update_todo(db, todo_id, todo)
    if not db_todo:
        raise HTTPException(status_code=404, detail="Todo not found")
    return db_todo


@router.delete("/todos/{todo_id}", status_code=204)
def delete_todo(todo_id: int, db: Session = Depends(get_db)):
    """Delete a todo by ID.

    Args:
        todo_id (int): ID of the todo to delete.
        db (Session): Database session.

    Returns:
        dict: Confirmation message.
    """
    db_todo = crud.delete_todo(db, todo_id)
    if not db_todo:
        raise HTTPException(status_code=404, detail="Todo not found")
    return {"message": "Todo deleted successfully"}
