from fastapi import FastAPI
from app.routes.api import router
from app.config import settings

def create_app() -> FastAPI:
    app = FastAPI(title=settings.PROJECT_NAME, version=settings.VERSION)
    
    app.include_router(router)
    
    return app

if __name__ == "__main__":
    import uvicorn
    app = create_app()
    uvicorn.run(app, host=settings.HOST, port=settings.PORT)