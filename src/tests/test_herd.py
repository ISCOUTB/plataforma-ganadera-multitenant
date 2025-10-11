from app import create_app
from app.services.herd_service import HerdService
import pytest

app = create_app()
client = app.test_client()

@pytest.fixture
def setup_herd():
    # Setup code for herd testing
    herd_service = HerdService()
    # Add any necessary setup for the herd service
    yield herd_service
    # Teardown code if needed

def test_register_animal(setup_herd):
    response = client.post('/api/herd/register', json={
        'id': 1,
        'age': 2,
        'breed': 'Holstein',
        'weight': 500,
        'productive_status': 'Active'
    })
    assert response.status_code == 201
    assert response.json['message'] == 'Animal registered successfully'

def test_get_animal(setup_herd):
    response = client.get('/api/herd/1')
    assert response.status_code == 200
    assert response.json['id'] == 1

def test_update_animal(setup_herd):
    response = client.put('/api/herd/1', json={
        'weight': 550
    })
    assert response.status_code == 200
    assert response.json['message'] == 'Animal updated successfully'

def test_delete_animal(setup_herd):
    response = client.delete('/api/herd/1')
    assert response.status_code == 200
    assert response.json['message'] == 'Animal deleted successfully'