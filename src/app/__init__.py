from fastapi import FastAPI

app = FastAPI()

from .routes.api import router as api_router

app.include_router(api_router)