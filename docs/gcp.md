### Google Cloud

### Export your credentials as environment variables

[Create Google cloud Service Account Key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys) then export the credentials as a variable to use inside a container.

```bash
$ export TF_VAR_gcp_token=$(cat /path/to/account.json )
```

### Initialize packer

```bash
$ make packer-build env=google-cloud image=image-ubuntu
```

After this step, you will have a image on your image list repository, inside the project where your Service Account Key was generated.

### Destroy the packer environment

TIP: don't destroy the `env` where is the build image. You will use this for your VMs later.

```bash
$ make terraform-destroy provider=azure env=images-tester
```
