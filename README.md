# Usage instruction:

0. Make sure you have nvidia card and nvidia docker installed
1. Make sure you have connected your [EpicGames account and your guthub account](https://www.unrealengine.com/en-US/ue4-on-github?sessionInvalidated=true).
2. [Generate keypair and deploy your public key to your github account](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh) (when asked for private key passphrase, leave it blank).
3. Name your private key file as `carla_keys` and place it right next to the Dockerfile
4. Build Dockerfile with someting like `docker build -t my_carla:dev .` (this might take 1 to 3 hours depending on your hardware and ~250GB of free disk space)
5. Run the image with GUI support like this (here I limit cpu usages to `10` cores to leave some processing power for host tasks):

```
docker run \
  -it \
  --env="DISPLAY" \
  --env="QT_X11_NO_MITSHM=1" \
  --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
  --runtime=nvidia \
  --gpus all \
  --cpus="10.0"
  --privileged \
  --network="host" \
  my_carla:dev
```

6. Run `make launch` command. This will start UE4 Editor with Carla plugins.
7. Done. Now you can introduce changes and build standalone packages. For example here you can watch the [viodeo demostrating adding custom map to Carla](https://youtu.be/ctRlzUM8QdM).
