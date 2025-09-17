import pytest
from fastapi.testclient import TestClient

from main import app

client = TestClient(app)

created_todo_id = None


@pytest.mark.asyncio
async def test_create_todo():
    """
    An integration test that creates a todo.
    """
    response = client.post(
        "/todos/",
        json={
            "name": "Test todo",
            "description": "A test todo description",
            "priority": "High",
            "completed": False,
            "due_date": "2025-09-18T00:00:00.000Z",
        },
    )
    assert response.status_code == 201
    response_data = response.json()
    
    assert response_data["name"] == "Test todo"
    assert response_data["description"] == "A test todo description"
    assert response_data["priority"] == "High"
    assert response_data["completed"] == False
    assert response_data["due_date"] == "2025-09-18T00:00:00.000Z"
    assert "id" in response_data
    
    # Store the created ID for use in other tests
    global created_todo_id
    created_todo_id = response_data["id"]


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
    todo_id = created_todo_id if created_todo_id else 1
    response = client.get(f"/todos/{todo_id}")
    assert response.status_code == 200
    response_data = response.json()
    assert response_data["id"] == todo_id
    assert response_data["name"] == "Test todo"
    assert response_data["description"] == "A test todo description"
    assert response_data["priority"] == "High"
    assert response_data["completed"] == False
    assert response_data["due_date"] == "2025-09-18T00:00:00.000Z"


@pytest.mark.asyncio
async def test_update_todo():
    """
    An integration test that updates a todo.
    """
    todo_id = created_todo_id if created_todo_id else 1
    response = client.put(
        f"/todos/{todo_id}", 
        json={
            "name": "Updated todo", 
            "description": "Updated description",
            "priority": "Medium",
            "completed": True,
            "due_date": "2025-09-18T00:00:00.000Z"
        }
    )
    assert response.status_code == 200
    response_data = response.json()
    assert response_data["id"] == todo_id
    assert response_data["name"] == "Updated todo"
    assert response_data["description"] == "Updated description"
    assert response_data["priority"] == "Medium"
    assert response_data["completed"] == True
    assert response_data["due_date"] == "2025-09-18T00:00:00.000Z"


@pytest.mark.asyncio
async def test_delete_todo():
    """
    An integration test that deletes a todo.
    """
    todo_id = created_todo_id if created_todo_id else 1
    response = client.delete(f"/todos/{todo_id}")
    assert response.status_code == 204

    # Verify the todo is deleted
    response = client.get(f"/todos/{todo_id}")
    assert response.status_code == 404
    assert response.json() == {"detail": "Todo not found"}
