import jwt
from jwt import PyJWKClient
from flask import current_app

JWKS_CLIENT = None

def get_jwks_client():
    """Get or create the PyJWT JWKS client with caching"""
    global JWKS_CLIENT
    if JWKS_CLIENT is None:
        jwks_url = f'https://cognito-idp.{current_app.config["REGION"]}.amazonaws.com/{current_app.config["USER_POOL_ID"]}/.well-known/jwks.json'
        JWKS_CLIENT = PyJWKClient(jwks_url, cache_keys=True)
    return JWKS_CLIENT

def verify_cognito_token(token):
    """
    Verify AWS Cognito access token
    
    Returns:
        dict: Token payload if valid
        None: If verification fails
    """
    try:
        # Get signing key from token
        jwks_client = get_jwks_client()
        signing_key = jwks_client.get_signing_key_from_jwt(token)
        
        # Decode and verify token
        payload = jwt.decode(
            token,
            signing_key.key,
            algorithms=["RS256"],
            issuer=f"https://cognito-idp.{current_app.config['REGION']}.amazonaws.com/{current_app.config['USER_POOL_ID']}",
            options={
                "verify_signature": True,
                "verify_exp": True,
                "verify_iss": True
            }
        )
        
        # Verify it's an access token with correct client_id
        if payload.get("token_use") != "access":
            current_app.logger.error(f"Invalid token type: {payload.get('token_use')}")
            return None
            
        if payload.get("client_id") != current_app.config["APP_CLIENT_ID"]:
            current_app.logger.error("Invalid client_id")
            return None
        
        return payload
        
    except jwt.ExpiredSignatureError:
        current_app.logger.error("Token has expired")
        return None
    except jwt.InvalidIssuerError:
        current_app.logger.error("Invalid token issuer")
        return None
    except jwt.InvalidSignatureError:
        current_app.logger.error("Invalid token signature")
        return None
    except Exception as e:
        current_app.logger.error(f"Token verification failed: {e}")
        return None