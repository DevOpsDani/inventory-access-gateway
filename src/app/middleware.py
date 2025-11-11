from flask import request, jsonify
from .auth_utils import verify_cognito_token

def authenticate_request():
    """JWT authentication middleware for protected routes"""
    if request.endpoint in ("health", "ready"):
        return

    auth_header = request.headers.get("Authorization", "")
    if not auth_header.startswith("Bearer "):
        return jsonify({"error": "Missing or invalid Authorization header"}), 401

    token = auth_header.split(" ")[1]
    payload = verify_cognito_token(token)
    if not payload:
        return jsonify({"error": "Invalid or expired token"}), 401

    request.user = payload
