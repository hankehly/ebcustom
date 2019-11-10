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
- [x] Run CRUD operation from GUI
- [ ] Schedule / execute batch job to worker instance
- [ ] Run an arbitrary command on all web instances
- [ ] batch jobs on worker instances
- [ ] rolling / immutable deployment from circleci
- [x] versioned assets served from S3

## TODO
- Move RDS, ElastiCache, etc.. external resources to Terraform config

## Q&A

#### In this example project, what AWS resources are managed by terraform and what are managed by beanstalk?
| Resource                      | Terraform | Beanstalk |
|:------------------------------|:----------|:---------:|
| EC2 Instance Creation         |           |     √     |
| RDS                           |     √     |           |
| ElastiCache                   |     √     |           |
| Security Groups               |     √     |           |
| VPC                           |     √     |           |
| SQS                           |     √     |           |
| Beanstalk Application         |     √     |           |
| Beanstalk Environment         |     √     |           |
| Beanstalk Application Version |           |     √     |
| Beanstalk Configuration       |           |     √     |
| app `option_settings`         |           |     √     |
| CloudFront                    |     √     |           |


#### How do I connect my domain name with cloudfront distribution?
Follow [this guide](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-to-cloudfront-distribution.html). Be careful about the record type.

#### How do I rename an environment?
You have to back up the environment and the restore it. Someone [asked this question](https://forums.aws.amazon.com/thread.jspa?threadID=151978) on the forum. And someone else created a [blog post](http://pminkov.github.io/blog/how-to-shut-down-and-restore-an-elastic-beanstalk-environment.html) about it.

#### What things can I specify in an `.ebextensions` config file?
See [this page](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/customize-containers-ec2.html)

#### Does EB pull my changes to files from GitHub, SCM?
It pulls changes to your application from `.git` not GitHub.

#### How do I specify a version label when deploying?
```bash
# example: eb deploy -l v1.2.3
eb deploy (-l|--label) [VERSION]
```
#### What is the `.elasticbeanstalk` folder?
It's a configuration your local `eb` file uses. You don't commit it to SCM.

#### How do I execute a command during the deployment process?
If the command is supposed to be run before the code is "live" you can add an item to the `container_commands` section of one of your `.ebextensions` config files.
```yaml
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
```yaml
option_settings:
  aws:elasticbeanstalk:application:environment:
    DJANGO_SETTINGS_MODULE: web.settings
  aws:elasticbeanstalk:container:python:
    WSGIPath: web/wsgi.py
```

#### Can I have a custom uwsgi setup?
TODO

#### How do I temporarily stop an environment without terminating it?
Use time based scaling (see Configuration -> Capacity -> Time Based Scaling)
- [Link](https://jun711.github.io/aws/how-to-pause-or-stop-elastic-beanstalk-environment-from-running/#:~:text=There%20is%20no%20straightforward%20way,pay%20when%20you%20use%20it.)
- [Link](https://hackernoon.com/how-to-save-on-aws-elastic-beanstalk-ec2-machines-by-putting-them-to-sleep-d8533aeb610a)

#### How to add an RDS instance?
Create an instance and connect in the GUI configuration screen, or create one with the beanstalk wizard. This will set the `RDS_*` environment variables for use in the app. [See more](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create-deploy-python-rds.html).
```python
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
Option 1) Use the ebcli commandline tool
```sh
eb setenv FOO=VAR
```
Option 2) Use the AWS console
See Configuration -> Software -> Environment properties

#### How do I roll back to the previous version AND sync the database?
TODO

#### I want to include a file in the deployed app but not commit it to SCM
Copy `.gitignore` to `.ebignore` if you haven't already. Add the file to `.gitignore` and leave it out of `.ebignore`. EB will deploy it, but git will not manage it.

#### How do I update the healthcheck url
Use the AWS console (see Configuration -> Load Balancer -> Processes). You should also be able to set an `option_setting` like below, but it doesn't get applied for some reason..
```yaml
option_settings:
  aws:elasticbeanstalk:application:
    Application Healthcheck URL: /ping/
```

#### How do I force restart the web server?
TODO


## Troubleshooting
#### The following resource(s) failed to create: MyCacheSecurityGroup.
```
$ eb deploy
2019-11-05 00:25:19    INFO    Environment update is starting.      
2019-11-05 00:25:42    ERROR   Service:AmazonCloudFormation, Message:Stack named 'awseb-e-wbmxbruwe8-stack' aborted operation. Current state: 'UPDATE_ROLLBACK_IN_PROGRESS'  Reason: The following resource(s) failed to create: [MyCacheSecurityGroup]. 
2019-11-05 00:25:42    ERROR   Creating security group named: sg-0fee88b49cda8b643 failed Reason: Invalid id: "awseb-e-wbmxbruwe8-stack-AWSEBSecurityGroup-GTCFKNA6VCPQ" (expecting "sg-...") (Service: AmazonEC2; Status Code: 400; Error Code: InvalidGroupId.Malformed; Request ID: fdc762ec-f799-4753-bf2e-110d62ccf87d)
2019-11-05 00:25:42    ERROR   Failed to deploy application. 
```
The documentation uses `SourceSecurityGroupId` instead of `SourceSecurityGroupName` in their example
```yaml
SourceSecurityGroupId: # << should be SourceSecurityGroupName
  Ref: "AWSEBSecurityGroup"
```
After changing:
```
2019-11-05 00:34:15    INFO    Environment update is starting.      
2019-11-05 00:34:38    INFO    Created security group named: sg-06269f92dba330485
2019-11-05 00:39:01    INFO    Deploying new version to instance(s).
2019-11-05 00:40:00    INFO    New application version was deployed to running EC2 instances.
2019-11-05 00:40:00    INFO    Environment update completed successfully.
```
