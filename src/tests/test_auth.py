from fastapi import FastAPI
from fastapi.testclient import TestClient
from app.routes.api import router

app = FastAPI()
app.include_router(router)

client = TestClient(app)

def test_register():
    response = client.post("/register", json={"username": "testuser", "password": "testpass"})
    assert response.status_code == 201
    assert response.json() == {"message": "User registered successfully"}

def test_login():
    response = client.post("/login", json={"username": "testuser", "password": "testpass"})
    assert response.status_code == 200
    assert "access_token" in response.json()

def test_login_invalid_credentials():
    response = client.post("/login", json={"username": "wronguser", "password": "wrongpass"})
    assert response.status_code == 401
    assert response.json() == {"detail": "Invalid credentials"}

def test_register_existing_user():
    response = client.post("/register", json={"username": "testuser", "password": "testpass"})
    assert response.status_code == 400
    assert response.json() == {"detail": "User already exists"}