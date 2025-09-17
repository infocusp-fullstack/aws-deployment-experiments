from sqlalchemy import Column, Integer, String, Boolean

from .database import Base


class Todo(Base):
    """Todo model for the database.

    Attributes:
        id (int): Unique identifier for the todo.
        name (str): Name of the todo.
        description (str): Description of the todo.
        priority (str): Priority level of the todo.
        completed (bool): Completion status of the todo.
        due_date (str): Due date of the todo.
        created_at (str): Creation timestamp of the todo.
        updated_at (str): Last updated timestamp of the todo.
    """

    __tablename__ = "todos"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    description = Column(String, index=True)
    priority = Column(String, index=True)
    completed = Column(Boolean, index=True)
    due_date = Column(Integer, index=True)
    created_at = Column(Integer)
    updated_at = Column(Integer)
