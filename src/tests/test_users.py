from fastapi import FastAPI
from fastapi.testclient import TestClient
from app.controllers.users_controller import create_user, get_user, update_user, delete_user

app = FastAPI()

@app.post("/users/")
def test_create_user():
    response = client.post("/users/", json={"username": "testuser", "password": "testpass"})
    assert response.status_code == 201
    assert response.json() == {"username": "testuser"}

@app.get("/users/{user_id}")
def test_get_user():
    response = client.get("/users/1")
    assert response.status_code == 200
    assert response.json() == {"id": 1, "username": "testuser"}

@app.put("/users/{user_id}")
def test_update_user():
    response = client.put("/users/1", json={"username": "updateduser"})
    assert response.status_code == 200
    assert response.json() == {"id": 1, "username": "updateduser"}

@app.delete("/users/{user_id}")
def test_delete_user():
    response = client.delete("/users/1")
    assert response.status_code == 204
    assert response.content == b""