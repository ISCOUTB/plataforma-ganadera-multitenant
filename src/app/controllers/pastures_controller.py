from flask import Blueprint, request, jsonify
from app.services.pastures_service import PastureService

pastures_controller = Blueprint('pastures', __name__)
pasture_service = PastureService()

@pastures_controller.route('/pastures', methods=['POST'])
def create_pasture():
    data = request.json
    try:
        pasture = pasture_service.create_pasture(data)
        return jsonify(pasture), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 400

@pastures_controller.route('/pastures/<int:pasture_id>', methods=['GET'])
def get_pasture(pasture_id):
    try:
        pasture = pasture_service.get_pasture(pasture_id)
        return jsonify(pasture), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 404

@pastures_controller.route('/pastures/<int:pasture_id>', methods=['PUT'])
def update_pasture(pasture_id):
    data = request.json
    try:
        updated_pasture = pasture_service.update_pasture(pasture_id, data)
        return jsonify(updated_pasture), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 400

@pastures_controller.route('/pastures/<int:pasture_id>', methods=['DELETE'])
def delete_pasture(pasture_id):
    try:
        pasture_service.delete_pasture(pasture_id)
        return jsonify({'message': 'Pasture deleted successfully'}), 204
    except Exception as e:
        return jsonify({'error': str(e)}), 404

@pastures_controller.route('/pastures', methods=['GET'])
def list_pastures():
    try:
        pastures = pasture_service.list_pastures()
        return jsonify(pastures), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500