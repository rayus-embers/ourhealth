from django.urls import path
from .views import Home, RegisterApi, RegisterMedApi,ChangePasswordAPI, MedPersonDetail, LeaderboardView
urlpatterns = [
    path('getmyid/', Home.as_view(), name="get the id"),
    path('register/', RegisterApi.as_view(), name="register user"),
    path('registerMed/', RegisterMedApi.as_view(), name="register med person"),
    path('registerMed/update/', RegisterMedApi.as_view(), name="update med person"),
    path('changepass/', ChangePasswordAPI.as_view(), name="change password"),
    path('read/med/<int:pk>/', MedPersonDetail.as_view(), name="show med person"),
    path('leaderboard/', LeaderboardView.as_view(), name='leaderboard'),
]
