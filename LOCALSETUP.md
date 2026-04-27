# How to test code in to local machine using docker-compose

## ✨ How to use it

> **Step 1** - Download the code from the GH repository (using `GIT`)

```bash
$ # Get the code
$ git clone https://github.com/kelvinmanavar/django-celery-app-github-action.git 
$ cd django-celery-app-github-action
```

### Make some changes
- Copy env.sample in to .env
    - cp env.sample .env
    - Open .env file and uncomment all lines
- open this path core/settings.py and Uncomment these lines

```bash
# ALLOWED_HOSTS        = ['localhost', 'localhost:85', '127.0.0.1', env('SERVER', default='127.0.0.1') ]
# CSRF_TRUSTED_ORIGINS = ['http://localhost', 'http://127.0.0.1', 'https://' + env('SERVER', default='127.0.0.1') ]
```
- open this path core/settings.py and Comment these lines

```bash
ALLOWED_HOSTS = os.environ.get("ALLOWED_HOSTS", "").split(",")
CSRF_TRUSTED_ORIGINS = os.environ.get("CSRF_TRUSTED_ORIGINS", "").split(",")
```

<br />

## ✨ Start the app in Docker

> **Step 2** - Start the APP in `Docker`

```bash
$ docker-compose up --build 
```

Visit `http://localhost:5085` in your browser. The app should be up & running.

<br /> 

### 👉 Set Up for `Unix`, `MacOS` 

> Install modules via `VENV`  

```bash
$ virtualenv env
$ source env/bin/activate
$ pip3 install -r requirements.txt
```

<br />

> Set Up Database

```bash
$ python manage.py makemigrations
$ python manage.py migrate
```

<br />

> Start the app

```bash
$ python manage.py runserver
```

At this point, the app runs at `http://127.0.0.1:8000/`. 

<br />

> Start Celery (another terminal)

> Note: `Redis` server is expected on port `6379` (default)

```bash
$ celery --app=core.celery.app worker --loglevel=info 
```

### 👉 Set Up for `Windows` 

> Install modules via `VENV` (windows) 

```
$ virtualenv env
$ .\env\Scripts\activate
$ pip3 install -r requirements.txt
```

<br />

> Set Up Database

```bash
$ python manage.py makemigrations
$ python manage.py migrate
```

<br />

> Start the app

```bash
$ python manage.py runserver
```

At this point, the app runs at `http://127.0.0.1:8000/`. 

<br />

## ✨ Create Users

By default, the app redirects guest users to authenticate. In order to access the private pages, follow this set up: 

- Start the app via `python manage.py runserver`
- Access the `registration` page and create a new user:
  - `http://127.0.0.1:8000/register/`
- Access the `sign in` page and authenticate
  - `http://127.0.0.1:8000/login/`

<br />
