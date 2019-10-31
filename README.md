# ebcustom
An example django application running on an elastic beanstalk custom platform.

## Stack

| component | tool | version |
|:-|:-|:-|
| webapp | django | [2.2](https://docs.djangoproject.com/en/2.2/) |
| webserver OS | ubuntu | 16.04 LST |
| webserver | nginx | latest |
| webapp server | uwsgi | latest |
| database | RDS postre | latest |
| python package manager | poetry | [0.12.17](https://github.com/sdispater/poetry/releases/tag/0.12.17) |
| job scheduler | celery | latest |
| job scheduler "broker" | redis (managed) | latest |
| AMI provisioner | ansible | 2.8.6 |
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

### Notes

Create following files
- platform.json
- playbook.yml
- playform.yaml

```sh
# setup .elasticbeanstalk in repo
ebp init # short for eb platform init

# in order for this to work, you need to push your platform.yaml file
# to SCM
eb platform create
```

See "General Options" and "Platform Specific Options" for information about port listening / WSGIPath setting..
- https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html
- https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-specific.html#command-options-python

### Troubleshooting
##### cant find platform.yaml in bundle
```
$ eb platform create
Creating application version archive "app-e7a7-191027_141311".
Uploading ebcustom/app-e7a7-191027_141311.zip to S3. This may take a while.
Upload Complete.
Note: An environment called 'eb-custom-platform-builder-packer' has been created in order to build your application. This environment will not automatically be terminated and it does have a cost associated with it. Once your platform creation has completed you can terminate this builder environment using the command 'eb terminate'.
2019-10-27 05:13:16    INFO    Initiated platform version creation for 'ebcustom/1.0.2'.
>> Error like: "cannot find platform.yaml in bundle" ...
```
You need to commit `platform.yaml` to SCM

##### cant find ansible-playbook executable
```
$ eb platform create
Creating application version archive "app-e7a7-191027_141311".
Uploading ebcustom/app-e7a7-191027_141311.zip to S3. This may take a while.
Upload Complete.
Note: An environment called 'eb-custom-platform-builder-packer' has been created in order to build your application. This environment will not automatically be terminated and it does have a cost associated with it. Once your platform creation has completed you can terminate this builder environment using the command 'eb terminate'.
2019-10-27 05:13:16    INFO    Initiated platform version creation for 'ebcustom/1.0.2'.
2019-10-27 05:13:20    INFO    Creating Packer builder environment 'eb-custom-platform-builder-packer'.
2019-10-27 05:15:21    INFO    Starting Packer building task.
 -- Events -- (safe to Ctrl+C)

============= 1.0.2 - /aws/elasticbeanstalk/platform/ebcustom ==============

1.0.2 b'# Logfile created on 2019-10-27 05:15:23 +0000 by logger.rb/47272'
Creating CloudWatch log group '/aws/elasticbeanstalk/platform/ebcustom'.
Downloading EB bootstrap script https://s3.amazonaws.com/elasticbeanstalk-env-resources-us-east-1/stalks/eb_packer_4.0.1.200479.0_1571116623/skeleton/lib/bootstrap/ubuntu1604/eb-user-data...
Downloading EB bootstrap script https://s3.amazonaws.com/elasticbeanstalk-env-resources-us-east-1/stalks/eb_packer_4.0.1.200479.0_1571116623/skeleton/lib/bootstrap/ubuntu1604/eb-bootstrap.sh...
Injecting script awseb-bootstrap/eb-bootstrap.sh into Packer template...
Invoking 'packer build'...
2 error(s) occurred:\n\n* Error running "ansible-playbook --version": exec: "ansible-playbook": executable file not found in $PATH\n* user: could not determine current user from environment.
'packer build' finished.
Packer failed with error: '2 error(s) occurred:
1.0.2 b'* Error running "ansible-playbook --version": exec: "ansible-playbook": executable file not found in $PATH'
1.0.2 b"* user: could not determine current user from environment.'"
'packer build' failed, the build log has been saved to '/var/log/packer-builder/ebcustom:1.0.2-builder.log'
2019-10-27 05:15:25    INFO    Creating CloudWatch log group '/aws/elasticbeanstalk/platform/ebcustom'.
2019-10-27 05:15:25    ERROR   'packer build' failed, the build log has been saved to '/var/log/packer-builder/ebcustom:1.0.2-builder.log'
2019-10-27 05:15:25    ERROR   Packer failed with error: '2 error(s) occurred:

* Error running "ansible-playbook --version": exec: "ansible-playbook": executable file not found in $PATH
* user: could not determine current user from environment.'
2019-10-27 05:15:35    ERROR   [Instance: i-0f3014b4d32339bc6] Command failed on instance. Return code: 1 Output: 'packer build' failed, the build log has been saved to '/var/log/packer-builder/ebcustom:1.0.2-builder.log'. 
Hook /opt/elasticbeanstalk/hooks/packerbuild/build.rb failed. For more detail, check /var/log/eb-activity.log using console or EB CLI.
2019-10-27 05:15:35    INFO    Command execution completed on all instances. Summary: [Successful: 0, Failed: 1].
2019-10-27 05:15:35    ERROR   Unsuccessful command execution on instance id(s) 'i-0f3014b4d32339bc6'. Aborting the operation.
2019-10-27 05:15:35    INFO    Failed to create platform version 'ebcustom/1.0.2'.
                                
ERROR: ServiceError - Failed to create platform version 'ebcustom/1.0.2'.
```
You need to use the `ansible-local` provisioner and install ansible manually beforehand.
```
"provisioners": [
    {
        "type": "shell",
        "inline": [
            "sudo apt-get update",
            "sudo apt-get install -y ansible"
        ]
    },
    {
        "type": "ansible-local",
        "playbook_file": "./playbook.yml"
    }
]
```

See: 
- https://dev.classmethod.jp/server-side/ansible/build_ami_with_packer_using_ansible/
- https://www.packer.io/docs/provisioners/ansible-local.html

##### can't find ansible role
```
==> HVM AMI builder: Provisioning with Ansible...
HVM AMI builder: Creating Ansible staging directory...
HVM AMI builder: Creating directory: /tmp/packer-provisioner-ansible-local/5db6ca8a-cd97-f776-6482-b3f72648f5f2
HVM AMI builder: Uploading main Playbook file...
HVM AMI builder: Uploading inventory file...
HVM AMI builder: Executing Ansible: cd /tmp/packer-provisioner-ansible-local/5db6ca8a-cd97-f776-6482-b3f72648f5f2 && ANSIBLE_FORCE_COLOR=1 PYTHONUNBUFFERED=1 ansible-playbook /tmp/packer-provisioner-ansible-local/5db6ca8a-cd97-f776-6482-b3f72648f5f2/webservers.yml --extra-vars "packer_build_name=HVM AMI builder packer_builder_type=amazon-ebs packer_http_addr="  -c local -i /tmp/packer-provisioner-ansible-local/5db6ca8a-cd97-f776-6482-b3f72648f5f2/packer-provisioner-ansible-local216834584
HVM AMI builder: ERROR! the role 'common' was not found in /tmp/packer-provisioner-ansible-local/5db6ca8a-cd97-f776-6482-b3f72648f5f2/roles:/tmp/packer-provisioner-ansible-local/5db6ca8a-cd97-f776-6482-b3f72648f5f2:/etc/ansible/roles
HVM AMI builder:
HVM AMI builder: The error appears to have been in '/tmp/packer-provisioner-ansible-local/5db6ca8a-cd97-f776-6482-b3f72648f5f2/webservers.yml': line 4%!(PACKER_COMMA) column 7%!(PACKER_COMMA) but may
HVM AMI builder: be elsewhere in the file depending on the exact syntax problem.
HVM AMI builder:
HVM AMI builder: The offending line appears to be:
HVM AMI builder:
HVM AMI builder: roles:
HVM AMI builder: - common
HVM AMI builder: ^ here
HVM AMI builder:
```


## Lingering questions
- Does EB pull my changes to `platform.json` file from SCM?


## Provided platform setup
```
$ eb init
$ eb create
Enter Environment Name
(default is ebcustom-dev): 
Enter DNS CNAME prefix
(default is ebcustom-dev): 

Select a load balancer type
1) classic
2) application
3) network
(default is 2): 
Creating application version archive "app-04df-191031_102633".
Uploading ebcustom/app-04df-191031_102633.zip to S3. This may take a while.
Upload Complete.
Environment details for: ebcustom-dev
  Application name: ebcustom
  Region: us-east-1
  Deployed Version: app-04df-191031_102633
  Environment ID: e-wbmxbruwe8
  Platform: arn:aws:elasticbeanstalk:us-east-1::platform/Python 3.6 running on 64bit Amazon Linux/2.9.3
  Tier: WebServer-Standard-1.0
  CNAME: ebcustom-dev.us-east-1.elasticbeanstalk.com
  Updated: 2019-10-31 01:26:43.389000+00:00
Printing Status:
2019-10-31 01:26:42    INFO    createEnvironment is starting.
2019-10-31 01:26:43    INFO    Using elasticbeanstalk-us-east-1-736867324655 as Amazon S3 storage bucket for environment data.
2019-10-31 01:27:05    INFO    Created target group named: arn:aws:elasticloadbalancing:us-east-1:736867324655:targetgroup/awseb-AWSEB-1O5K6A16LHO2/59e139dcb958624c
2019-10-31 01:27:05    INFO    Created security group named: sg-07ef285e7967e5946
2019-10-31 01:27:21    INFO    Created security group named: awseb-e-wbmxbruwe8-stack-AWSEBSecurityGroup-GTCFKNA6VCPQ
2019-10-31 01:27:21    INFO    Created Auto Scaling launch configuration named: awseb-e-wbmxbruwe8-stack-AWSEBAutoScalingLaunchConfiguration-113G8HE7JE6LA
 -- Events -- (safe to Ctrl+C)
```