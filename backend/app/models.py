from sqlalchemy import Column, Integer, String

from .database import Base


class Todo(Base):
    """Todo model for the database.

    Attributes:
        id (int): Unique identifier for the todo.
        name (str): Name of the todo.
        description (str): Description of the todo.
    """

    __tablename__ = "todos"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    description = Column(String, index=True)
