from rest_framework import  serializers
from rest_framework.permissions import IsAuthenticated
from .models import Post, Comment, Reaction, anatomy, intchoices

class PostSerializer(serializers.ModelSerializer):
    area_of_pain = serializers.ListField(
        child=serializers.ChoiceField(choices=anatomy)
    )
    author_username = serializers.CharField(source='author.username', read_only=True)
    class Meta:
        model=Post
        fields='__all__'
        
    def create(self, validated_data):
        post = Post.objects.create(author=self.context["request"].user,title=validated_data['title'], description = validated_data['description']  ,area_of_pain=validated_data['area_of_pain'])
        return post

#just a lighter version not to load description each time
class CustomPostSerializer(serializers.ModelSerializer):
    area_of_pain = serializers.ListField(
        child=serializers.ChoiceField(choices=anatomy),
        required=False
    )
    author_username = serializers.CharField(source='author.username', read_only=True)

    class Meta:
        model = Post
        fields = ['id', 'author_username', 'title', 'area_of_pain', 'date']
class CommentSerializer(serializers.ModelSerializer):
    commentor_username = serializers.CharField(source='commentor.person.username', read_only=True)
    commentor_id = serializers.IntegerField(source='commentor.person.id', read_only=True)
    commented_on_id = serializers.IntegerField(source='commented_on.id', read_only=True)
    commentor_status = serializers.BooleanField(source='commentor.is_verified', read_only = True)
    commentor_school = serializers.BooleanField(source='commentor.isStudent', read_only = True)
    class Meta:
        model = Comment
        fields = ['id', 'commentor', 'commented_on', 'commentor_school', 'content', 'date', 'edited', 'score', 'commentor_username', 'commented_on_id', 'commentor_status', 'commentor_id']
        read_only_fields = ['date', 'edited', 'score', 'commentor']

    def create(self, validated_data):
        return Comment.objects.create(**validated_data)

    def update(self, instance, validated_data):
        instance.content = validated_data.get('content', instance.content)
        instance.edited = True
        instance.save()
        return instance

class ReactionSerializer(serializers.ModelSerializer):
    reactor_username = serializers.CharField(source='reactor.username', read_only=True)
    reacted_on_comment = serializers.CharField(source='reacted_on.content', read_only=True)
    reaction = serializers.ChoiceField(choices=intchoices)

    class Meta:
        model = Reaction
        fields = ['id', 'reactor', 'reacted_on', 'reaction', 'reactor_username', 'reacted_on_comment']
        read_only_fields = ['reactor', 'reactor_username', 'reacted_on_comment']

class ReactionStatusSerializer(serializers.ModelSerializer):
    class Meta:
        model = Reaction
        fields = ['reaction']