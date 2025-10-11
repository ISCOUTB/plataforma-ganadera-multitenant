from functools import wraps
from flask import request, jsonify
from your_project_name.services.auth_service import AuthService

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None

        # Verificar si el token está en los encabezados
        if 'Authorization' in request.headers:
            token = request.headers['Authorization'].split(" ")[1]

        # Si no hay token, devolver un error
        if not token:
            return jsonify({'message': 'Token is missing!'}), 403

        try:
            # Verificar el token
            current_user = AuthService.verify_token(token)
        except Exception as e:
            return jsonify({'message': str(e)}), 403

        return f(current_user, *args, **kwargs)

    return decorated