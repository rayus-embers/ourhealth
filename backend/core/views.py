from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework import generics, mixins, status
from rest_framework_simplejwt.authentication import JWTAuthentication
from .models import User, MedPerson
from .serializers import RegisterSerializer, UserSerializer, RegisterMedSerializer, MedSerializer, ChangePassowrdSerializer
from .permission import IsUserorReadOnly
# Create your views here.
class Home(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]

    def get(self, request, format=None):
        """
        Return your username, user id
        """
        return Response({
            "username":request.user.username,
            "id":request.user.pk,
            "isMed":request.user.is_med,
        })

class RegisterApi(generics.GenericAPIView):
    serializer_class = RegisterSerializer
    permission_classes = [AllowAny]
    def post(self, request, *args,  **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        return Response({
            "user": UserSerializer(user,    context=self.get_serializer_context()).data,
            "message": "User Created Successfully.  Now perform Login to get your token",
        })

class RegisterMedApi(generics.GenericAPIView):
    serializer_class = RegisterMedSerializer
    permission_classes = (IsAuthenticated,)
    def post(self, request, *args,  **kwargs):
        #verify if the user is truly the one tryna make a med account
        if f'{request.user.pk}' == request.data['person']:
            serializer = self.get_serializer(data=request.data)
            serializer.is_valid(raise_exception=True)
            person = serializer.save()
            return Response({
                "message": "Med person Created Successfully."
            })
        else :
            return Response({
            "message":"tryna be sneaky ey?"
        })
    def put(self, request, *args, **kwargs):
        try:
            instance = MedPerson.objects.get(pk=request.data['person'])
        except MedPerson.DoesNotExist:
            return Response({
                "message": "Med person not found."
            })

        if f'{request.user.pk}' == str(instance.person.pk):
            serializer = self.get_serializer(instance, data=request.data)
            serializer.is_valid(raise_exception=True)
            person = serializer.save()
            return Response({
                "message": "Med person updated.",
            })
        else:
            return Response({
                "message": "Trying to be sneaky, ey?"
            },)
    
    def patch(self, request, *args, **kwargs):
        try:
            instance = MedPerson.objects.get(pk=request.data['id'])
        except MedPerson.DoesNotExist:
            return Response({
                "message": "Med person not found."
            })

        if f'{request.user.pk}' == str(instance.person.pk):
            serializer = self.get_serializer(instance, data=request.data, partial=True)
            serializer.is_valid(raise_exception=True)
            person = serializer.save()
            return Response({
                "message": "Med person partially updated.",
            })
        else:
            return Response({
                "message": "Trying to be sneaky, ey?"
            })

class ChangePasswordAPI(generics.GenericAPIView):
    authentication_classes = [JWTAuthentication]
    queryset = User.objects.all()
    permission_classes = (IsAuthenticated,)
    serializer_class = ChangePassowrdSerializer
    def put(self, request, *args, **kwargs):
        try:
            user = request.user
        except user.DoesNotExist:
            #better be safe than sorry
            return Response({
                "message": "user not found."
            })

        serializer = self.get_serializer(user, data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        return Response({
            "message": "password updated.",
        })
    

class MedPersonDetail(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = (IsAuthenticated,)
    def get(self, request, pk, format=None):
        medp = MedPerson.objects.get(pk=pk)
        if not medp.user_avatar:
            usera = "/media/profile_pics/default.jpg"
        else :
            usera = medp.user_avatar.url
        return Response({
            "username":medp.person.username,
            "gender":medp.person.gender,
            "job":medp.job,
            "bio":medp.bio,
            "isStudent":medp.isStudent,
            "spec":medp.spec,
            "points":medp.points,
            "user_avatar":usera,
        })
    
class LeaderboardView(generics.ListAPIView):
    serializer_class = MedSerializer
    permission_classes = (IsAuthenticated,)

    def get_queryset(self):
        queryset = MedPerson.objects.order_by('-points')
        job = self.request.query_params.get('job', None)
        spec = self.request.query_params.get('spec', None)
        stud = self.request.query_params.get('stud', None)       
        if job is not None:
            queryset = queryset.filter(job=job)
        
        if spec is not None:
            queryset = queryset.filter(spec=spec)
        if stud is not None:
            queryset = queryset.filter(isStudent=stud)
        
        return queryset[:50]