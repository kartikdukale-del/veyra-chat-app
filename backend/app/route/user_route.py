from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from ..core.database import get_db
from ..schema.user_schema import UserCreate, UserResponse
from ..service.user_service import create_user
from ..schema.login_schema import UserLogin
from ..service.user_service import login_user
from ..core.security import get_current_user
from ..model.user_model import UserModel
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
            detail="Email already registerd"
        )
    return new_user


@router.post("/login")
def login(user: UserLogin, db: Session = Depends(get_db)):
    token = login_user(
        email=user.email,
        password=user.password,
        db=db
    )
    if token is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password"
        )
    return token


@router.get("/me",response_model=UserResponse)
def get_my_profile(
    current_user:UserModel =Depends(get_current_user)
):
    return current_user