from django_filters import rest_framework as filters
from .models import Post

class PostFilter(filters.FilterSet):
    area_of_pain = filters.CharFilter(method='filter_area_of_pain')

    class Meta:
        model = Post
        fields = ['area_of_pain']

    def filter_area_of_pain(self, queryset, name, value):
        values = value.split(',')
        for v in values:
            queryset = queryset.filter(area_of_pain__contains=v)
        return queryset
