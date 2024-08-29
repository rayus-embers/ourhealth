# OurHealth

OurHealth is a simple app that functions like a lite Stack Overflow for physicians. Users can post about health issues, specifying the area of pain and describing it, while qualified medical staff can respond in the comments. These responses can receive upvotes, helping medical professionals climb the leaderboards and gain popularity.

## Features

- **User Registration and Login**: Users can register, log in, and manage their profiles.
- **Create Posts**: Users can create posts describing their health issues.
- **Commenting System**: Qualified medical staff can respond to posts with comments.
- **Voting System**: Users can upvote helpful comments, which contributes to a leaderboard.
- **Profile Viewing**: Click on a commenter's username to view their profile.
- **Responsive Design**: The app is designed to work across different platforms, including Windows, Linux, macOS, Android, iOS, and web.

## Technologies Used

- **Frontend**: Flutter
- **Backend**: Django with Django REST framework
- **State Management**: Provider
- **Authentication**: JWT (JSON Web Tokens)
- **Database**: SQLite
- **File Handling**: Image upload and display with support for various platforms
- **Icons**: Custom app icons set for each platform

## Installation

### Prerequisites

- Flutter SDK
- Dart
- Python 3.x
- Django
- Node.js (for web deployment)
- Git

### Setup Instructions

1. **Clone the Repository**:

    ```bash
    git clone https://github.com/rayus-embers/ourhealth.git
    cd ourhealth
    ```

2. **Backend Setup**:

    ```bash
    cd backend
    python -m venv venv
    source venv/bin/activate  # On Windows use `venv\Scripts\activate`
    pip install -r requirements.txt
    python manage.py migrate
    python manage.py runserver
    ```

3. **Frontend Setup**:

    ```bash
    cd frontend
    flutter pub get
    flutter run
    ```

    If you are deploying to the web, use:

    ```bash
    flutter build web
    ```

4. **Environment Variables**:

    Create a `.env` file in the backend directory with the necessary environment variables:

    ```env
    SECRET_KEY=your_secret_key
    DEBUG=True
    ```


## Contribution

Feel free to fork the repository and submit pull requests. All contributions are welcome!
