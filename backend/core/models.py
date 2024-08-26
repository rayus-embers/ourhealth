from django.db import models
from django.contrib.auth.models import AbstractUser
from PIL import Image
# Create your models here.

class User(AbstractUser):
    gender = models.BooleanField(null=True, default=False)
    is_med = models.BooleanField(default=False, null=True)
Jobs = (
    ("Physician", "Physician"),
    ("Nurse", "Nurse"),
    ("Dentist", "Dentist"),
)
Spec = (
    ("none", "none"),
    ("Allergist/Immunologist","Allergist/Immunologist"),
    ("Anesthesiologist","Anesthesiologist"),
    ("Cardiologist","Cardiologist"),
    ("Colon and Rectal Surgeon","Colon and Rectal Surgeon"),
    ("Critical Care","Critical Care"),
    ("Dermatologist","Dermatologist"),
    ("Endocrinologist","Endocrinologist"),
    ("Emergency Medicine","Emergency Medicine"),
    ("Family Physician","Family Physician"),
    ("Geriatric Medicine","Geriatric Medicine"),
    ("Hematologist","Hematologist"),
    ("Hospice and Palliative Medicine","Hospice and Palliative Medicine"),
    ("Infectious Disease","Infectious Disease"),
    ("Internist","Internist"),
    ("Medical Geneticist","Medical Geneticist"),
    ("Nephrologist","Nephrologist"),
    ("Neurologist","Neurologist"),
    ("Obstetrician","Obstetrician"),
    ("Gynecologist","Gynecologist"),
    ("Oncologist","Oncologist"),
    ("Ophthalmologist","Ophthalmologist"),
    ("Osteopath","Osteopath"),
    ("Otolaryngologist","Otolaryngologist"),
    ("Pathologist","Pathologist"),
    ("Pediatrician","Pediatrician"),
    ("Physiatrist","Physiatrist"),
    ("Plastic Surgeon","Plastic Surgeon"),
    ("Podiatrist","Podiatrist"),
    ("Preventive Medicine","Preventive Medicine"),
    ("Psychiatrist","Psychiatrist"),
    ("Pulmonologist","Pulmonologist"),
    ("Radiologist","Radiologist"),
    ("Rheumatologist","Rheumatologist"),
    ("Sleep Medicine","Sleep Medicine"),
    ("Sports Medicine","Sports Medicine"),
    ("General Surgeon","General Surgeon"),
    ("Urologist","Urologist"),
)
class MedPerson(models.Model):
    person = models.OneToOneField(User, on_delete=models.CASCADE, primary_key=True)
    is_verified = models.BooleanField(default=False)
    job = models.CharField(max_length=50, choices=Jobs)
    isStudent = models.BooleanField(default=False)
    spec = models.CharField(max_length=100, choices=Spec)
    bio = models.CharField(max_length=500)
    points = models.BigIntegerField(default=0)
    user_avatar = models.ImageField(upload_to="profile_pics", blank=True, null=True)
    def __str__(self):
        v = ''
        if self.spec !='none':
            v = ': '+ self.spec
        if self.isStudent:
            return f'{self.person.username} is still studying to be a {self.job}{v}'
        return f'{self.person.username} is a {self.job}{v}'
    
    #resizing the image
    def save(self, *args, **kwargs):
    # Call the parent class's save method with all arguments
        super().save(*args, **kwargs)

    # Check if the avatar exists
        if self.user_avatar:
            try:
                pic = Image.open(self.user_avatar.path)

                if pic.height > 300:
                    output_size = (200, 90)
                    pic.thumbnail(output_size)
                    pic.save(self.user_avatar.path)
            except Exception as e:
                print(f"Error processing the image: {e}")