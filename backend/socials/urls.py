from django.urls import path
from .views import PostAPI,PostDetail, PostListView, CommentListView, CommentCreateView, CommentUpdateView, ReactionCreateView, CheckReactionView

urlpatterns=[
    path('post/', PostAPI.as_view(), name="post api"),
    path('posts/', PostListView.as_view(), name="post list api"),
    path('post/<int:pk>/', PostDetail.as_view(), name="post detail api"),
    path('posts/<int:post_id>/comments/', CommentListView.as_view(), name='comment list'),
    path('comments/create/', CommentCreateView.as_view(), name='comment create'),
    path('comments/<int:pk>/edit/', CommentUpdateView.as_view(), name='comment edit'),
    path('comments/react/', ReactionCreateView.as_view(), name='react'),
    path('comments/check/<int:pk>', CheckReactionView.as_view(), name='check-reaction'),
]