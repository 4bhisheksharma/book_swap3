from django.urls import path
from .views import book_list

path('books/', book_list)