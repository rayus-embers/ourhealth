from rest_framework.permissions import BasePermission
from rest_framework import status
from rest_framework.exceptions import ValidationError
#because the persmission verification happens before the code in the views so i had to put it in here
class IsOwnerOrRead(BasePermission):
    def has_object_permission(self, request, view, obj):
        try:
            medperson = request.user.medperson
            return obj.commentor == request.user.medperson
        except :
            raise ValidationError({"detail": "User does not have a MedPerson profile."}, code=status.HTTP_400_BAD_REQUEST)
            