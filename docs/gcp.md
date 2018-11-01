### Google Cloud

### Export your credentials as environment variables

[Create Google cloud Service Account Key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys) then export the credentials as a variable to use inside a container.

```bash
$ export GCLOUD_KEYFILE_JSON=$(cat /path/to/credentials.json )
```

### Initialize packer

```bash
$ make packer-build env=google-cloud image=image-ubuntu
```

Afer this step, you will have a image on your image list repository, inside the project where your Service Account Key was generated.

### Destroy the packer environment

TIP: don't destroy the `env` where is the build image. You will use this for your VMs later.

```bash
$ make terraform-destroy provider=azure env=images-tester
```
