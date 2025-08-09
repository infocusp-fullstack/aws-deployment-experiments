# test_crud.py
import pytest
from app.crud import create_item, delete_item, get_item, get_items, update_item
from sqlalchemy import Column, Integer, String, create_engine
from sqlalchemy.orm import declarative_base, sessionmaker

# ---------- Mock Models & Schemas ----------
Base = declarative_base()


class Item(Base):
    __tablename__ = "items"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    description = Column(String, index=True)


class ItemCreate:
    def __init__(self, name: str, description: str):
        self.name = name
        self.description = description


# Patch imports in your_module
import app.models as models
import app.schemas as schemas

models = type("models", (), {"Item": Item})
schemas = type("schemas", (), {"ItemCreate": ItemCreate})


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
def test_create_item(db_session):
    item_data = ItemCreate(name="Test Item", description="A test description")
    item = create_item(db_session, item_data)

    assert item.id is not None
    assert item.name == "Test Item"
    assert item.description == "A test description"


def test_get_items(db_session):
    db_session.add(Item(name="Item 1", description="Desc 1"))
    db_session.add(Item(name="Item 2", description="Desc 2"))
    db_session.commit()

    items = get_items(db_session)
    assert len(items) == 2
    assert {i.name for i in items} == {"Item 1", "Item 2"}


def test_get_item(db_session):
    new_item = Item(name="Single", description="Only one")
    db_session.add(new_item)
    db_session.commit()

    fetched = get_item(db_session, new_item.id)
    assert fetched.name == "Single"
    assert fetched.description == "Only one"


def test_update_item(db_session):
    new_item = Item(name="Old", description="Old desc")
    db_session.add(new_item)
    db_session.commit()

    updated_data = ItemCreate(name="New", description="New desc")
    updated_item = update_item(db_session, new_item.id, updated_data)

    assert updated_item.name == "New"
    assert updated_item.description == "New desc"


def test_delete_item(db_session):
    new_item = Item(name="ToDelete", description="Delete me")
    db_session.add(new_item)
    db_session.commit()

    deleted_item = delete_item(db_session, new_item.id)
    assert deleted_item.name == "ToDelete"
