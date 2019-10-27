# ebcustom
An example django application running on an elastic beanstalk custom platform.

### Stack

| component | tool | version |
|:-|:-|:-|
| webapp | django | latest |
| webserver OS | ubuntu | 16.04 LST |
| webserver | nginx | latest |
| webapp server | uwsgi | latest |
| database | RDS postre | latest |
| python package manager | poetry | [0.12.17](https://github.com/sdispater/poetry/releases/tag/0.12.17) |
| job scheduler | celery | latest |
| job scheduler "broker" | redis (managed) | latest |
| AMI provisioner | ansible | latest |
| continuous deployment | circieci | 2.0 |
| JS package manager | npm | latest LTS |

### Requirements

- Run CRUD operation from GUI
- Schedule / execute batch job to worker instance
- Run an arbitrary command on all web instances
- batch jobs on worker instances
- rolling / immutable deployment from circleci

