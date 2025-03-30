# BookSwap 📚

A Flutter-Django book swapping application that lets users share and discover books.

## Features ✨
- **User Authentication**: Secure JWT-based login/signup
- **Book Management**: Add/edit/delete books with images
- **Discover Feed**: Browse books from other users
- **Search**: Find books by title or description
- **Profile**: View/edit user details and book collection
- **Swap Requests**: Initiate book exchange requests

## Tech Stack 🛠️
**Frontend**  
- Flutter & Dart  
- State Management: Provider  
- HTTP: Dio Package  
- Image Handling: Image Picker  

**Backend**  
- Django & Django REST Framework  
- Database: SQLite
- Authentication: JWT  
- Image Storage: Django Media Handling

## Installation ⚙️

### Backend Setup
```bash
# Clone repository
git clone https://github.com/4bhisheksharma/book_swap3.git
cd bookswap/backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac)
venv\Scripts\activate  # Windows

# Install dependencies
pip install -r requirements.txt

# Run migrations
python manage.py migrate

# Start server
python manage.py runserver
```

### Frontend Setup
```bash
cd ../frontend

# Install dependencies
flutter pub get

# Run app (connected device required)
flutter run
