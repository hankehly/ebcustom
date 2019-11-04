# ebcustom
An example django application running on an elastic beanstalk provided platform.

## Stack

| component | tool | version |
|:-|:-|:-|
| webapp | django | [2.2](https://docs.djangoproject.com/en/2.2/) |
| database | RDS postre | latest |
| python package manager | poetry | [0.12.17](https://github.com/sdispater/poetry/releases/tag/0.12.17) |
| job scheduler | celery | latest |
| job scheduler "broker" | redis (managed) | latest |
| continuous deployment | circieci | 2.0 |
| JS package manager | node / npm | v12.13.0 / v6.12.0 (Latest LTS: Erbium) |
| FE build | Vue cli | 4.0.5 |
| FE JS framework | Vue | ^2.6.10 |
| FE UI components | vuetify | ^2.1.0 |

## Requirements
- Run CRUD operation from GUI
- Schedule / execute batch job to worker instance
- Run an arbitrary command on all web instances
- batch jobs on worker instances
- rolling / immutable deployment from circleci

## TODO:
- On deploy, create a `requirements.txt` file by parsing the `pyproject.toml`. Add the `requirements.txt` file to `.gitignore` but **leave it out of the .ebignore** file. Will probably want to copy contents of `.gitignore` to `.ebignore` beforehand.

## Q&A

#### Does EB pull my changes to files from GitHub, SCM?
It pulls changes to your application from `.git` not GitHub.

#### How do I specify a version label when deploying
```bash
# example: eb deploy -l v1.2.3
eb deploy (-l|--label) [VERSION]
```
#### What is the `.elasticbeanstalk` folder?
It's a configuration your local `eb` file uses. You don't commit it to SCM.

#### How do I execute a command during the deployment process?
If the command is supposed to be run before the code is "live" you can add an item to the `container_commands` section of one of your `.ebextensions` config files.
```
container_commands:
  01_collectstatic:
    command: "django-admin.py collectstatic --noinput"
  02_migrate:
    command: "django-admin.py migrate"
    leader_only: true
```

#### What does `leader_only` mean?
It's there so you don't run the same command more than once. Only the first instance to be deployed should run this command.

#### I renamed the django app folder, what do I do now?
You need to keep the `DJANGO_SETTINGS_MODULE` and `WSGIPath` settings up to date in your `.ebextensions` config files.
```
option_settings:
  aws:elasticbeanstalk:application:environment:
    DJANGO_SETTINGS_MODULE: web.settings
  aws:elasticbeanstalk:container:python:
    WSGIPath: web/wsgi.py
```

#### Can I have a custom uwsgi setup?
TODO

#### How to add an RDS instance?
Create an instance and connect in the GUI configuration screen, or create one with the beanstalk wizard. This will set the `RDS_*` environment variables for use in the app. [See more](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create-deploy-python-rds.html).
```
if "RDS_HOSTNAME" in os.environ:
    DATABASES = {
        "default": {
            "ENGINE": "django.db.backends.postgresql",
            "NAME": os.environ["RDS_DB_NAME"],
            "USER": os.environ["RDS_USERNAME"],
            "PASSWORD": os.environ["RDS_PASSWORD"],
            "HOST": os.environ["RDS_HOSTNAME"],
            "PORT": os.environ["RDS_PORT"],
        }
    }
else:
    DATABASES = {
        "default": {
            "ENGINE": "django.db.backends.sqlite3",
            "NAME": os.path.join(BASE_DIR, "db.sqlite3"),
        }
```

#### How to swap an RDS instance with another one?
TODO

#### I want to add an environment variable to all my web servers
TODO

#### How do I roll back to the previous version AND sync the database?
TODO

#### I want to include a file in the deployed app but not commit it to SCM
Copy `.gitignore` to `.ebignore` if you haven't already. Add the file to `.gitignore` and leave it out of `.ebignore`. EB will deploy it, but git will not manage it.

#### How do I update the healthcheck url
See Configuration -> Load Balancer -> Processes.
You should also be able to set an option_setting, but it doesn't get applied for some reason..
```yaml
option_settings:
  aws:elasticbeanstalk:application:
    Application Healthcheck URL: /ping/
```
