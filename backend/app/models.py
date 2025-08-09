from sqlalchemy import Column, Integer, String
from .database import Base


class Item(Base):
    """Item model for the database.

    Attributes:
        id (int): Unique identifier for the item.
        name (str): Name of the item.
        description (str): Description of the item.
    """

    __tablename__ = "items"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    description = Column(String, index=True)
