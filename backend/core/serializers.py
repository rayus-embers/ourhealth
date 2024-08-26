from rest_framework import  serializers
from rest_framework.permissions import IsAuthenticated
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError
from django.db import models
from .models import User, MedPerson
from django.contrib.auth import authenticate
from django.contrib.auth.hashers import make_password

class RegisterSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id','username','password','gender')
        extra_kwargs = {
            'password':{'write_only': True},
        }
    def create(self, validated_data):
        if validated_data['gender'] == None:
            validated_data['gender'] = False
        user = User.objects.create_user(validated_data['username'], password = validated_data['password']  ,gender=validated_data['gender'])
        return user
# User serializer
class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('username', 'gender')

class RegisterMedSerializer(serializers.ModelSerializer):
    class Meta:
        model = MedPerson
        fields = ('person','job','spec', 'bio', 'user_avatar', 'isStudent')
        extra_kwargs = {
            'person':{'write_only': True},
        }
    def create(self, validated_data):
        if validated_data['isStudent'] == None:
            validated_data['isStudent'] = False
        person = MedPerson.objects.create(
            person=validated_data['person'],
            job = validated_data['job'],
            spec= validated_data['spec'],
            bio=validated_data['bio'],
            isStudent=validated_data['isStudent'],
            user_avatar=validated_data['user_avatar'],
            )
        validated_data['person'].is_med = True
        validated_data['person'].save()
        return person
    def update(self,instance, validated_data):
        if validated_data['isStudent'] == None:
            validated_data['isStudent'] = False
        instance.person=validated_data.get('person', instance.person)
        instance.job = validated_data.get('job', instance.job)
        instance.bio=validated_data.get('bio', instance.bio)
        instance.isStudent=validated_data.get('isStudent', instance.isStudent)
        instance.user_avatar=validated_data.get('user_avatar', instance.user_avatar)
        instance.save()
        return instance

class MedSerializer(serializers.ModelSerializer):
    person_username = serializers.CharField(source='person.username', read_only=True)
    class Meta:
        model = MedPerson
        fields = ('pk','person_username', 'person', 'job', 'spec', 'bio', 'user_avatar', 'isStudent', 'points', 'is_verified')

class ChangePassowrdSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
    old_password = serializers.CharField(write_only=True, required=True)
    
    class Meta:
        model = User
        fields = ('old_password', 'password')


    def validate_old_password(self, value):
        user = self.context['request'].user
        if not user.check_password(value):
            raise serializers.ValidationError({"old_password": "Old password is not correct"})
        return value

    def update(self, instance, validated_data):
        instance.set_password(validated_data['password'])
        instance.save()
        return instance