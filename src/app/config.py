import os
from dotenv import load_dotenv

# load_dotenv() Needed for local use

class Config:
    REGION = os.getenv("REGION")
    USER_POOL_ID = os.getenv("USER_POOL_ID")
    APP_CLIENT_ID = os.getenv("APP_CLIENT_ID")
    DEBUG = os.getenv("DEBUG", "False").lower() in ("true", "1", "yes")
    APPSYNC_API_URL = os.getenv("APPSYNC_API_URL")