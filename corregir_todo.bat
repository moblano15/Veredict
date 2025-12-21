@echo off
chcp 65001 >nul
echo ============================================
echo    CORRECCIÓN COMPLETA PROYECTO VEREDICT
echo ============================================
echo.

cd /d "C:\Users\monic\Desktop\VEREDICT"

echo 1. Renombrando manage.py...
if exist namage.py ren namage.py manage.py
if exist nanage.py ren nanage.py manage.py

echo.
echo 2. Verificando estructura...
if not exist veredict mkdir veredict

echo.
echo 3. Creando settings.py corregido...
(
echo import os
echo from pathlib import Path
echo.
echo BASE_DIR = Path(__file__).resolve().parent.parent
echo.
echo SECRET_KEY = 'django-insecure-clave-temporal'
echo DEBUG = True
echo ALLOWED_HOSTS = []
echo.
echo INSTALLED_APPS = [
echo     'django.contrib.admin',
echo     'django.contrib.auth',
echo     'django.contrib.contenttypes',
echo     'django.contrib.sessions',
echo     'django.contrib.messages',
echo     'django.contrib.staticfiles',
echo     'usuarios',
echo     'reseñas',
echo     'noticias',
echo ]
echo.
echo MIDDLEWARE = [
echo     'django.middleware.security.SecurityMiddleware',
echo     'django.contrib.sessions.middleware.SessionMiddleware',
echo     'django.middleware.common.CommonMiddleware',
echo     'django.middleware.csrf.CsrfViewMiddleware',
echo     'django.contrib.auth.middleware.AuthenticationMiddleware',
echo     'django.contrib.messages.middleware.MessageMiddleware',
echo     'django.middleware.clickjacking.XFrameOptionsMiddleware',
echo ]
echo.
echo ROOT_URLCONF = 'veredict.urls'
echo.
echo TEMPLATES = [
echo     {
echo         'BACKEND': 'django.template.backends.django.DjangoTemplates',
echo         'DIRS': [],
echo         'APP_DIRS': True,
echo         'OPTIONS': {
echo             'context_processors': [
echo                 'django.template.context_processors.debug',
echo                 'django.template.context_processors.request',
echo                 'django.contrib.auth.context_processors.auth',
echo                 'django.contrib.messages.context_processors.messages',
echo             ],
echo         },
echo     },
echo ]
echo.
echo WSGI_APPLICATION = 'veredict.wsgi.application'
echo.
echo DATABASES = {
echo     'default': {
echo         'ENGINE': 'django.db.backends.sqlite3',
echo         'NAME': BASE_DIR / 'db.sqlite3',
echo     }
echo }
echo.
echo AUTH_PASSWORD_VALIDATORS = []
echo.
echo LANGUAGE_CODE = 'es-es'
echo TIME_ZONE = 'Europe/Madrid'
echo USE_I18N = True
echo USE_TZ = True
echo.
echo STATIC_URL = 'static/'
echo MEDIA_URL = '/media/'
echo MEDIA_ROOT = os.path.join(BASE_DIR, 'media')
echo DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
) > veredict\settings.py

echo.
echo 4. Creando otros archivos necesarios...
if not exist veredict\__init__.py echo # > veredict\__init__.py
if not exist usuarios\__init__.py echo # > usuarios\__init__.py
if not exist reseñas\__init__.py echo # > reseñas\__init__.py
if not exist noticias\__init__.py echo # > noticias\__init__.py

echo.
echo 5. Creando urls.py básico...
(
echo from django.contrib import admin
echo from django.urls import path
echo.
echo urlpatterns = [
echo     path('admin/', admin.site.urls),
echo ]
) > veredict\urls.py

echo.
echo 6. Creando modelo de usuario SIMPLE...
(
echo from django.contrib.auth.models import AbstractUser
echo from django.db import models
echo.
echo class Usuario(AbstractUser):
echo     avatar = models.ImageField(upload_to='avatars/', null=True, blank=True)
echo     fecha_registro = models.DateTimeField(auto_now_add=True)
echo     
echo     class Meta:
echo         verbose_name = 'Usuario'
echo         verbose_name_plural = 'Usuarios'
echo     
echo     def __str__(self):
echo         return self.username
) > usuarios\models.py

echo.
echo 7. Instalando Pillow...
pip install Pillow==10.0.0 --quiet

echo.
echo 8. Aplicando migraciones...
python manage.py makemigrations
python manage.py migrate

echo.
echo 9. Creando superusuario...
python manage.py createsuperuser --username admin --email admin@veredict.com

echo.
echo ============================================
echo    ¡CORRECCIÓN COMPLETADA!
echo ============================================
echo.
echo Ejecuta: python manage.py runserver
echo.
echo Accede a:
echo   http://127.0.0.1:8000
echo   http://127.0.0.1:8000/admin
echo.
echo Credenciales:
echo   Usuario: admin
echo   Contraseña: admin123
echo.
pause