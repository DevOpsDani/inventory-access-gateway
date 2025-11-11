import requests
from jose import jwt
from flask import current_app

JWKS = None

def fetch_jwks():
    global JWKS
    if JWKS is None:
        url = f"https://cognito-idp.{current_app.config['REGION']}.amazonaws.com/{current_app.config['USER_POOL_ID']}/.well-known/jwks.json"
        JWKS = requests.get(url).json()
    return JWKS

def get_cognito_public_key(kid):
    for key in fetch_jwks().get("keys", []):
        if key["kid"] == kid:
            return key
    return None

def verify_cognito_token(token):
    try:
        headers = jwt.get_unverified_header(token)
        key = get_cognito_public_key(headers["kid"])
        if not key:
            raise Exception("Public key not found")

        payload = jwt.decode(
            token,
            key,
            algorithms=["RS256"],
            audience=current_app.config["APP_CLIENT_ID"],
            issuer=f"https://cognito-idp.{current_app.config['REGION']}.amazonaws.com/{current_app.config['USER_POOL_ID']}"
        )
        return payload
    except Exception as e:
        current_app.logger.error(f"Token verification failed: {e}")
        return None
