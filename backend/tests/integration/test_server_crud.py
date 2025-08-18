import pytest
from fastapi.testclient import TestClient

from main import app

client = TestClient(app)


@pytest.mark.asyncio
async def test_create_todo():
    """
    An integration test that creates a todo.
    """
    response = client.post(
        "/todos/", json={"name": "Test todo", "description": "A test todo description"}
    )
    assert response.status_code == 201
    assert response.json() == {
        "id": 1,
        "name": "Test todo",
        "description": "A test todo description",
    }


@pytest.mark.asyncio
async def test_get_todos():
    """
    An integration test that retrieves todos.
    """
    response = client.get("/todos/")
    assert response.status_code == 200
    assert isinstance(response.json(), list)


@pytest.mark.asyncio
async def test_get_todo():
    """
    An integration test that retrieves a specific todo.
    """
    response = client.get("/todos/1")
    assert response.status_code == 200
    assert response.json() == {
        "id": 1,
        "name": "Test todo",
        "description": "A test todo description",
    }


@pytest.mark.asyncio
async def test_update_todo():
    """
    An integration test that updates a todo.
    """
    response = client.put(
        "/todos/1", json={"name": "Updated todo", "description": "Updated description"}
    )
    assert response.status_code == 200
    assert response.json() == {
        "id": 1,
        "name": "Updated todo",
        "description": "Updated description",
    }


@pytest.mark.asyncio
async def test_delete_todo():
    """
    An integration test that deletes a todo.
    """
    response = client.delete("/todos/1")
    assert response.status_code == 204

    # Verify the todo is deleted
    response = client.get("/todos/1")
    assert response.status_code == 404
    assert response.json() == {"detail": "Todo not found"}
