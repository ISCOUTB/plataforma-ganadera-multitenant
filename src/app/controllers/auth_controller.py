from fastapi import APIRouter, HTTPException, Depends
from app.schemas.auth import UserCreate, UserLogin
from app.services.auth_service import AuthService
from app.dependencies import get_auth_service

router = APIRouter()

@router.post("/register")
async def register(user: UserCreate, auth_service: AuthService = Depends(get_auth_service)):
    try:
        return await auth_service.register(user)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/login")
async def login(user: UserLogin, auth_service: AuthService = Depends(get_auth_service)):
    try:
        return await auth_service.login(user)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))