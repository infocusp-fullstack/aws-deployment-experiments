from pydantic import BaseModel, ConfigDict, Field


class ItemBase(BaseModel):
    """Base model for items.

    Attributes:
        name (str): Name of the item.
        description (str): Description of the item.
    """

    name: str = Field(..., description="Name of the item.")
    description: str = Field(
        ...,
        description="Description of the item.",
    )


class ItemCreate(ItemBase):
    """Model for creating a new item."""

    pass


class ItemRead(ItemBase):
    """Model for reading an item from the database.

    Attributes:
        id (int): Unique identifier for the item.
    """

    id: int

    model_config = ConfigDict(
        from_attributes=True, str_strip_whitespace=True, extra="ignore"
    )
