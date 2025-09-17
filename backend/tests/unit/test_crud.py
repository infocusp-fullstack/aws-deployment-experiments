import pytest
from sqlalchemy import Column, Integer, String, Boolean, create_engine
from sqlalchemy.orm import declarative_base, sessionmaker

from app.crud import create_todo, delete_todo, get_todo, get_todos, update_todo

# ---------- Mock Models & Schemas ----------
Base = declarative_base()


class Todo(Base):
    """Todo model for the database.
    Attributes:
        id (int): Unique identifier for the todo.
        name (str): Name of the todo.
        description (str): Description of the todo.
        priority (str): Priority level of the todo.
        completed (bool): Completion status of the todo.
        due_date (int): Due date of the todo.
        created_at (int): Creation timestamp of the todo.
        updated_at (int): Last updated timestamp of the todo.
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


class TodoCreate:
    """Model for creating a new todo."""

    def __init__(
        self,
        name: str,
        description: str,
        priority: str = "Low",
        completed: bool = False,
        due_date: str = "2025-12-31",
    ):
        self.name = name
        self.description = description
        self.priority = priority
        self.completed = completed
        self.due_date = due_date


# Patch imports
models = type("models", (), {"Todo": Todo})
schemas = type("schemas", (), {"TodoCreate": TodoCreate})


# ---------- Pytest Fixtures ----------
@pytest.fixture
def db_session():
    """Creates an in-memory SQLite DB and returns a session."""
    engine = create_engine("sqlite:///:memory:")
    TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    Base.metadata.create_all(bind=engine)
    session = TestingSessionLocal()
    try:
        yield session
    finally:
        session.close()


# ---------- Tests ----------
def test_create_todo(db_session):
    todo_data = TodoCreate(
        name="Test Todo", description="A test description", priority="High"
    )
    todo = create_todo(db_session, todo_data)

    assert todo.id is not None
    assert todo.name == "Test Todo"
    assert todo.description == "A test description"
    assert todo.priority == "High"


def test_get_todos(db_session):
    """Test retrieving multiple todos from the database."""
    db_session.add(
        Todo(
            name="Todo 1",
            description="Desc 1",
            priority="High",
            completed=False,
            due_date=1672531200,
        )
    )
    db_session.add(
        Todo(
            name="Todo 2",
            description="Desc 2",
            priority="Low",
            completed=True,
            due_date=1672531200,
        )
    )
    db_session.commit()

    todos = get_todos(db_session)
    assert len(todos) == 2
    assert {i.name for i in todos} == {"Todo 1", "Todo 2"}


def test_get_todo(db_session):
    """Test retrieving a single todo by ID."""
    new_todo = Todo(
        name="Single",
        description="Only one",
        priority="Medium",
        completed=False,
        due_date=1672531200,
    )
    db_session.add(new_todo)
    db_session.commit()

    fetched = get_todo(db_session, new_todo.id)
    assert fetched.name == "Single"
    assert fetched.description == "Only one"
    assert fetched.priority == "Medium"


def test_update_todo(db_session):
    """Test updating an existing todo."""
    new_todo = Todo(
        name="Old",
        description="Old desc",
        priority="Low",
        completed=False,
        due_date=1672531200,
    )
    db_session.add(new_todo)
    db_session.commit()

    updated_data = TodoCreate(name="New", description="New desc", priority="High")
    updated_todo = update_todo(db_session, new_todo.id, updated_data)

    assert updated_todo.name == "New"
    assert updated_todo.description == "New desc"
    assert updated_todo.priority == "High"


def test_delete_todo(db_session):
    """Test deleting a todo from the database."""
    new_todo = Todo(
        name="ToDelete",
        description="Delete me",
        priority="Medium",
        completed=False,
        due_date=1672531200,
    )
    db_session.add(new_todo)
    db_session.commit()

    deleted_todo = delete_todo(db_session, new_todo.id)
    assert deleted_todo.name == "ToDelete"
