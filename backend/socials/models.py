from django.db import models
from core.models import User, MedPerson
from multiselectfield import MultiSelectField
# Create your models here.
anatomy = (
    ('full body', 'full body'),
    ('upper body', 'upper body'),
    ('lower body', 'lower body'),
    ('head', 'head'),
    ('neck', 'neck'),
    ('nose', 'nose'),
    ('mouth', 'mouth'),
    ('teeth', 'teeth'),
    ('eyes', 'eyes'),
    ('ears', 'ears'),
    ('forehead', 'forehead'),
    ('shoulder', 'shoulder'),
    ('chest', 'chest'),
    ('arm', 'arm'),
    ('forearm', 'forearm'),
    ('hand', 'hand'),
    ('elbow','elbow'),
    ('wrist','wrist'),
    ('upper back', 'upper back'),
    ('lower back', 'lower back'),
    ('abdomen', 'abdomen'),
    ('glutes', 'glutes'),
    ('hips', 'hips'),
    ('genitals', 'genitals'),
    ('fingers/toes', 'fingers/toes'),
    ('palm', 'palm'),
    ('thigh', 'thigh'),
    ('knee', 'knee'),
    ('calf', 'calf'),
    ('ankle', 'ankle'),
    ('foot', 'foot'),
)
class Post(models.Model):
    author = models.ForeignKey(User, on_delete=models.CASCADE)
    title = models.CharField(max_length=150)
    description = models.TextField(max_length=500)
    area_of_pain = MultiSelectField(choices=anatomy, max_choices=6)
    date=models.DateTimeField(auto_now_add=True)
    def __str__(self):
        return f"{self.author.username} said: {self.title} on {self.area_of_pain}"

    
class Comment(models.Model):
    commentor=models.ForeignKey(MedPerson, on_delete=models.CASCADE)
    commented_on = models.ForeignKey(Post, on_delete=models.CASCADE)
    content=models.TextField(max_length=1500)
    date=models.DateTimeField(auto_now_add=True)
    edited = models.BooleanField(default=False)
    score = models.IntegerField(default=0)

    def __str__(self):
        return f"{self.commentor.person.username} commented on {self.commented_on.title} on {self.date} with a score of {self.score}"
    
intchoices=(
    (0, 0),
    (1, 1),
    (-1, -1),
)
class Reaction(models.Model):
    reactor = models.ForeignKey(User, on_delete=models.CASCADE)
    reacted_on = models.ForeignKey(Comment, on_delete=models.CASCADE)
    reaction = models.IntegerField(choices=intchoices)

    def __str__(self):
        return f"{self.reactor.username} reacted on {self.reacted_on.commentor.person.username}'s post with {self.reaction}"
    

    
    
    

    