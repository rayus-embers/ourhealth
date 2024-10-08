from rest_framework import permissions

class IsUserorReadOnly(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        #READ only requests
        if request.method in permissions.SAFE_METHODS:
            return True
        
        return obj.person == request.user