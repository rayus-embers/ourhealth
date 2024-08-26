from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.exceptions import ValidationError
from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.authentication import JWTAuthentication
from .serializers import PostSerializer, CommentSerializer, ReactionSerializer, CustomPostSerializer, ReactionStatusSerializer
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import SearchFilter
from .models import Post, Comment, Reaction
from .filters import PostFilter
from .permissions import IsOwnerOrRead
# Create your views here.
class PostAPI(generics.GenericAPIView):
    serializer_class = PostSerializer
    permission_classes=[IsAuthenticated]
    def post(self, request, *args,  **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        post = serializer.save()
        return Response({
            "post by":f"{post.author.username}",
            "message":f"post created on {post.date}"
        })
    

class PostDetail(generics.RetrieveAPIView):
    permission_classes = (IsAuthenticated,)
    queryset = Post.objects.all()
    serializer_class = PostSerializer

class PostListView(generics.ListAPIView):
    queryset = Post.objects.order_by('-date')
    serializer_class = CustomPostSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, SearchFilter]
    filterset_class = PostFilter
    search_fields = ['title']

class CommentListView(generics.ListAPIView):
    serializer_class = CommentSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        post_id = self.kwargs['post_id']
        return Comment.objects.filter(commented_on_id=post_id).order_by('-score')

class CommentCreateView(generics.CreateAPIView):
    serializer_class = CommentSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        try:
            medperson = self.request.user.medperson
        except :
            raise ValidationError({"detail": "User does not have a MedPerson profile."}, code=status.HTTP_400_BAD_REQUEST)
        
        serializer.save(commentor=medperson)

class CommentUpdateView(generics.UpdateAPIView):
    queryset = Comment.objects.all()
    serializer_class = CommentSerializer
    permission_classes = [IsAuthenticated, IsOwnerOrRead]

    def perform_update(self, serializer):
        
        serializer.save()

class ReactionCreateView(generics.GenericAPIView):
    queryset = Reaction.objects.all()
    serializer_class = ReactionSerializer
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        data = request.data
        reactor = request.user
        reacted_on_id = data.get('reacted_on')
        if data.get('reaction') == "0" :
            return Response({
                "message":"operation not allowed"
            }, status = status.HTTP_406_NOT_ACCEPTABLE)
        # Check if the comment exists
        try:
            reacted_on = Comment.objects.get(id=reacted_on_id)
        except Comment.DoesNotExist:
            return Response({"detail": "Comment not found."}, status=status.HTTP_404_NOT_FOUND)

        reaction = data.get('reaction')
        created = True
        person = reacted_on.commentor
        existing_reaction = Reaction.objects.filter(reactor=reactor, reacted_on=reacted_on).first()
        rea = 0
        if existing_reaction:
            created = False
            rea = int(reaction) - existing_reaction.reaction
            if f'{existing_reaction.reaction}' == reaction:
                existing_reaction.reaction = 0
                rea = - int(reaction)
            else:
                existing_reaction.reaction = int(reaction)
            
        else:
            existing_reaction = Reaction(reactor=reactor, reacted_on=reacted_on, reaction = int(reaction))
            rea = int(reaction)
        person.points += rea
        person.save()
        reacted_on.score += rea
        reacted_on.save()
        existing_reaction.save()

        if created:
            message = "Reaction created successfully."
        else:
            message = "Reaction updated successfully."

        return Response({
            "message": message,
            "reaction": {
                "id": existing_reaction.id,
                "reactor": existing_reaction.reactor.username,
                "reacted_on": existing_reaction.reacted_on.id,
                "newscore": existing_reaction.reacted_on.score,
                "reaction": existing_reaction.reaction
            }
        })
    
class CheckReactionView(generics.RetrieveAPIView):
    serializer_class = ReactionStatusSerializer
    permission_classes = (IsAuthenticated,)
    def get(self, request, *args, **kwargs):
        user = request.user
        comment_id = kwargs['pk']

        try:
            comment = Comment.objects.get(pk=comment_id)
        except Comment.DoesNotExist:
            return Response({"detail": "Comment not found."}, status=status.HTTP_404_NOT_FOUND)
        
        try:
            reaction = Reaction.objects.get(reactor = user, reacted_on=comment)
        except Reaction.DoesNotExist:
            return Response({
                "reaction":0,
            })
        serializer = self.get_serializer(reaction)
        return Response(serializer.data)
