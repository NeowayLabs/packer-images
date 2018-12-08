### Digital Ocean

### Export your credentials as environment variables

[Create a Digital Ocean API KEY](https://www.digitalocean.com/docs/api/create-personal-access-token/) then export the credentials.

```bash
$ export DO_API_KEY=YOUR_DO_API_KEY
```
### Initialize packer

```bash
$ make packer-build env=digital-ocean image=image-ubuntu
```

After this step you will have a snapshot on your account, to deploy new VMs from the base image.
