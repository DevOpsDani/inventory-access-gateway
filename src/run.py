from flask import Flask
from app.config import Config
from app.middleware import authenticate_request
from app.routes import register_routes

# Create Flask app
app = Flask(__name__)
app.config.from_object(Config)

# Register middleware
app.before_request(authenticate_request)

# Register routes
register_routes(app)

if __name__ == "__main__":
    app.run(
        host='0.0.0.0', 
        port=5000, 
        debug=Config.DEBUG
    )