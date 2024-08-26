# Generated by Django 4.2.14 on 2024-08-01 08:43

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion
import multiselectfield.db.fields


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('core', '0005_remove_user_is_verified_medperson_is_verified_and_more'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='Comment',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('content', models.TextField(max_length=1500)),
                ('date', models.DateTimeField(auto_now_add=True)),
                ('edited', models.BooleanField(default=False)),
                ('score', models.IntegerField(default=0)),
            ],
        ),
        migrations.CreateModel(
            name='Reaction',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('reaction', models.IntegerField(choices=[(0, 0), (1, 1), (-1, -1)])),
                ('reacted_on', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='socials.comment')),
                ('reactor', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name='Post',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('title', models.CharField(max_length=150)),
                ('description', models.TextField(max_length=500)),
                ('area_of_pain', multiselectfield.db.fields.MultiSelectField(choices=[('full body', 'full body'), ('upper body', 'upper body'), ('lower body', 'lower body'), ('head', 'head'), ('neck', 'neck'), ('nose', 'nose'), ('mouth', 'mouth'), ('eyes', 'eyes'), ('forehead', 'forehead'), ('shoulder', 'shoulder'), ('chest', 'chest'), ('arm', 'arm'), ('forearm', 'forearm'), ('hand', 'hand'), ('elbow', 'elbow'), ('wrist', 'wrist'), ('upper back', 'upper back'), ('lower back', 'lower back'), ('abdomen', 'abdomen'), ('glutes', 'glutes'), ('hips', 'hips'), ('genitals', 'genitals'), ('fingers/toes', 'fingers/toes'), ('palm', 'palm'), ('thigh', 'thigh'), ('knee', 'knee'), ('calf', 'calf'), ('ankle', 'ankle'), ('foot', 'foot')], max_length=206)),
                ('date', models.DateTimeField(auto_now_add=True)),
                ('author', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.AddField(
            model_name='comment',
            name='commented_on',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='socials.post'),
        ),
        migrations.AddField(
            model_name='comment',
            name='commentor',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='core.medperson'),
        ),
    ]
