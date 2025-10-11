from fastapi import APIRouter, HTTPException, Depends
from app.schemas.user import UserCreate, UserUpdate, UserResponse
from app.services.users_service import UsersService
from app.dependencies import get_users_service

router = APIRouter()

@router.post("/users/", response_model=UserResponse)
async def create_user(user: UserCreate, users_service: UsersService = Depends(get_users_service)):
    return await users_service.create_user(user)

@router.get("/users/{user_id}", response_model=UserResponse)
async def read_user(user_id: int, users_service: UsersService = Depends(get_users_service)):
    user = await users_service.get_user(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@router.put("/users/{user_id}", response_model=UserResponse)
async def update_user(user_id: int, user: UserUpdate, users_service: UsersService = Depends(get_users_service)):
    updated_user = await users_service.update_user(user_id, user)
    if not updated_user:
        raise HTTPException(status_code=404, detail="User not found")
    return updated_user

@router.delete("/users/{user_id}", response_model=dict)
async def delete_user(user_id: int, users_service: UsersService = Depends(get_users_service)):
    result = await users_service.delete_user(user_id)
    if not result:
        raise HTTPException(status_code=404, detail="User not found")
    return {"detail": "User deleted successfully"}