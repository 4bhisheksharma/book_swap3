from rest_framework import serializers
from .models import Book, SwapRequest
from django.contrib.auth.models import User 

class BookSerializer(serializers.ModelSerializer):
    owner = serializers.StringRelatedField(source='owner.username')
    class Meta:
        model = Book
        fields = ['id', 'name', 'description', 'credit', 'price', 'image', 'owner']
        extra_kwargs = {
            'credit': {'required': False},  # Allow partial updates
            'price': {'required': False}
        }
        read_only_fields = ['owner']

class SwapRequestSerializer(serializers.ModelSerializer):
    class Meta:
        model = SwapRequest
        fields = '__all__'
        read_only_fields = ('requester', 'created_at')
        
class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=True, min_length=8)
    email = serializers.EmailField(required=True)

    class Meta:
        model = User
        fields = ['username', 'email', 'password']
    
    def validate_username(self, value):
        if User.objects.filter(username=value).exists():
            raise serializers.ValidationError("Username already exists")
        return value

    def validate_email(self, value):
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("Email already registered")
        return value

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password']
        )
        return user