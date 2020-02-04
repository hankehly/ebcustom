# ebcustom
An example django application running on AWS Elastic Beanstalk.

## Stack

| component | tool | version |
|:-|:-|:-|
| web app | django | [2.2](https://docs.djangoproject.com/en/2.2/) |
| database | RDS PostgreSQL | latest |
| python package manager | poetry | [1.0](https://github.com/sdispater/poetry/releases) |
| CI | github actions | |
| cache | redis | latest |
| batch job runner | elastic beanstalk worker instance |
| javascript package manager | node / npm | v12.13.0 / v6.12.0 (Latest LTS: Erbium) |
| frontend build | Vue cli | 4.0 |
| SPA framework | Vue | ^2.6.10 |
| UI component framework | vuetify | ^2.1.0 |
| static asset server | cloudfront (s3 backend) | |

## Requirements
- [x] Run CRUD operations from GUI
- [x] Run CRON scheduled job on worker instance
- [ ] Run queued job on worker instance
- [x] Versioned assets served from cloudfront
- [ ] Run an arbitrary command on a web instance
- [ ] Rolling / immutable deployments on code push

## TODO
- SQS triggered jobs on worker instances

## Q&A

#### In this example project, which AWS resources are managed by terraform and which are managed by Elastic Beanstalk?
| Resource                      | Terraform | Beanstalk |
|:------------------------------|:----------|:---------:|
| EC2 Instances                 |           |     √     |
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


#### How do I connect my domain name with my CloudFront distribution?
Follow [this guide](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-to-cloudfront-distribution.html). Be careful about the record type.

#### How do I rename an Elastic Beanstalk environment?
You have to back up the environment and the restore it. Someone [asked this question](https://forums.aws.amazon.com/thread.jspa?threadID=151978) on the AWS forum, and someone else created a [blog post](http://pminkov.github.io/blog/how-to-shut-down-and-restore-an-elastic-beanstalk-environment.html) about it.

#### What can I specify in an `.ebextensions` config file?
Packages to install on the machine, users to create, commands you want to execute on deployment, etc.. See [this page](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/customize-containers-ec2.html) for a full list.

#### Do I need to push my changes to GitHub in order to deploy them?
No. Elastic Beanstalk uses your local `.git` folder to build and deploy your application.

#### How do I specify a version label when deploying?
Like this:
```bash
# example: eb deploy -l v1.2.3
eb deploy (-l|--label) [VERSION]
```

#### What is the `.elasticbeanstalk` folder?
It's a configuration file that tracks your local machine preferences for the `eb` command. You don't need to commit it to SCM.

#### What if I want to execute some arbitrary command on my web server?
If the command is supposed to be run just before the code is "live" then you can add an item to the `container_commands` section of one of your `.ebextensions` config files. The commands get executed in order.
```yaml
container_commands:
  01_collectstatic:
    command: "django-admin.py collectstatic --noinput"
  02_migrate:
    command: "django-admin.py migrate"
    leader_only: true
```

#### What does `leader_only` mean?
It means that only the first instance deployed should execute that command. It exists so that you don't run the same command more than once.

#### What should I do if I renamed the django app folder?
You just need to keep the `DJANGO_SETTINGS_MODULE` and `WSGIPath` settings up to date in your `.ebextensions` config files.
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
You can temporarily stop an environment by using time based scaling. See "Configuration -> Capacity -> Time Based Scaling" in the console. You will basically create a "stop" event to run 2 minutes from now, and that will stop your instances.
- [Link](https://jun711.github.io/aws/how-to-pause-or-stop-elastic-beanstalk-environment-from-running/#:~:text=There%20is%20no%20straightforward%20way,pay%20when%20you%20use%20it.)
- [Link](https://hackernoon.com/how-to-save-on-aws-elastic-beanstalk-ec2-machines-by-putting-them-to-sleep-d8533aeb610a)

#### How can I attach an RDS instance?
You can do this [via the Elastic Beanstalk console](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create-deploy-python-rds.html), but I chose to create the instance separately in this example repository. Just create your RDS instance and reference the endpoint from your python application.

#### How to swap an RDS instance with another one?
In this case you would have to change the endpoint URL that you reference in your python application from the old RDS endpoint to the new RDS endpoint url and re-deploy.

#### I want to add an environment variable to all my web servers
You can do either of the following. The both SHOULD have the same result, and you should be able to see all the variables in the Elastic Beanstalk console.
1. Use the AWS console (see Configuration -> Software -> Environment properties)
1. Use the ebcli commandline tool
```sh
eb setenv FOO=VAR
```

#### How do I roll back to the previous version of my app AND run backward DB migrations?
TODO

#### I want to include a file in the deployed app but not commit it to SCM
Add the file to `.gitignore` and leave it out of `.ebignore`. EB will deploy it, but git will ignore it.

#### How do I update the healthcheck url?
Use the AWS console (see Configuration -> Load Balancer -> Processes). You should also be able to set an `option_setting` like below, but it did not work for me one time..
```yaml
option_settings:
  aws:elasticbeanstalk:application:
    Application Healthcheck URL: /ping/
```

## Troubleshooting
Here are some errors I encountered during development. I will leave them here for future reference.
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
