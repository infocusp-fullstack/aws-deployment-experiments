from pydantic import BaseModel, ConfigDict, Field


class TodoBase(BaseModel):
    """Base model for todos.

    Attributes:
        name (str): Name of the todo.
        description (str): Description of the todo.
        priority (str): Priority level of the todo.
        completed (bool): Completion status of the todo.
        due_date (str): Due date of the todo.
    """

    name: str = Field(..., description="Name of the todo.")
    description: str = Field(
        ...,
        description="Description of the todo.",
    )
    priority: str = Field(..., description="Priority level of the todo.")
    completed: bool = Field(..., description="Completion status of the todo.")
    due_date: str = Field(..., description="Due date of the todo.")


class TodoCreate(TodoBase):
    """Model for creating a new todo."""

    pass


class TodoRead(TodoBase):
    """Model for reading an todo from the database.

    Attributes:
        id (int): Unique identifier for the todo.
    """

    id: int

    model_config = ConfigDict(
        from_attributes=True, str_strip_whitespace=True, extra="ignore"
    )
