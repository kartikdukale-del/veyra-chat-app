from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from ..core.database import get_db
from ..core.security import get_current_user
from ..model.user_model import UserModel
from ..schema.login_schema import UserLogin
from ..schema.user_schema import UserCreate, UserResponse, UserUpdate
from ..service.user_service import (
    create_user,
    get_all_users,
    login_user,
    update_user_profile,
)

router = APIRouter(prefix="/users", tags=["Users"])


@router.post(
    "/signup",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
)
def signup(user: UserCreate, db: Session = Depends(get_db)):
    new_user = create_user(user, db)
    if new_user is None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Email already registered",
        )
    return new_user


@router.post("/login")
def login(user: UserLogin, db: Session = Depends(get_db)):
    token = login_user(
        email=user.email,
        password=user.password,
        db=db,
    )
    if token is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )
    return token


@router.get("/", response_model=list[UserResponse])
def get_users(
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(get_current_user),
):
    return get_all_users(current_user, db)


@router.get("/me", response_model=UserResponse)
def get_my_profile(
    current_user: UserModel = Depends(get_current_user),
):
    return current_user


@router.patch("/me", response_model=UserResponse)
def update_my_profile(
    payload: UserUpdate,
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(get_current_user),
):
    updated_user, err = update_user_profile(current_user, payload, db)
    if err:
        code = (
            status.HTTP_409_CONFLICT
            if "already" in err.lower()
            else status.HTTP_400_BAD_REQUEST
        )
        raise HTTPException(status_code=code, detail=err)
    return updated_user
