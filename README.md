# test-supervisor-with-docker

## Assumption / What I want to test

* We want to provide our product container image that includes two processes to make our product work properly.
* We don't want users to remove one of two processes. Because it causes some unexpected issues and our product does not work properly.
* We want to confirm whether we can satisfy the above two requirements or not by using `supervisor`.

## How to build testing images

* Build sample apps
  ```console
  go build -o app1/app1 app1/app1.go
  go build -o app2/app2 app2/app2.go
  ```
* Build first container image
  ```console
  docker build -t example.com/test/supervisor:latest .
  ```
* Build second container image (testing for overriding entrypoint)
  ```console
  docker build -t example.com/test/supervisor-override:latest -f Dockerfile-Override-Entrypoint-Test .
  ```

## How to test

### Run supervisor

1. Start container.
   ```console
   docker run -d --name supervisor example.com/test/supervisor:latest
   ```

1. You can see the `COMMAND` (i.e., PID=1) is `supervisord`.
   ```console
   $ docker ps -n 1
   CONTAINER ID   IMAGE                                COMMAND                  CREATED              STATUS              PORTS     NAMES
   82d9db06840f   example.com/test/supervisor:latest   "/usr/bin/supervisord"   About a minute ago   Up About a minute             supervisor
   ```

1. You also can see the `app1` and `app2` are running in the container.
   ```console
   $ docker logs supervisor | tail -n 4
   2023-07-28 01:30:40.990770232 +0000 UTC m=+184.067225134
   App 1
   2023-07-28 01:30:40.990766091 +0000 UTC m=+184.067022370
   App 2
   ```

### Override entorypoint (i.e., run `app1` only) by using `--entrypoint` option

You can run `app1` (or `app2`) only by overriding entrypoint.

1. Start container with `--entrypoint` option.
   ```console
   docker run -d --name app1 --entrypoint /foo/app1 example.com/test/supervisor:latest
   ```

1. You can see the `COMMAND` (i.e., PID=1) is `app1`.
   ```console
   $ docker ps -n 2
   CONTAINER ID   IMAGE                                COMMAND                  CREATED         STATUS         PORTS     NAMES
   aed1027dd695   example.com/test/supervisor:latest   "/foo/app1"              6 seconds ago   Up 5 seconds             app1
   82d9db06840f   example.com/test/supervisor:latest   "/usr/bin/supervisord"   6 minutes ago   Up 6 minutes             supervisor
   ```

1. You also can see only `app1` is running in the container.
   ```console
   $ docker logs app1 -n 8
   2023-07-28 01:35:26.71205839 +0000 UTC m=+112.042968652
   App 1
   2023-07-28 01:35:27.712609824 +0000 UTC m=+113.043520073
   App 1
   2023-07-28 01:35:28.712939735 +0000 UTC m=+114.043849988
   App 1
   2023-07-28 01:35:29.71340331 +0000 UTC m=+115.044313561
   App 1
   ```

### Override entorypoint (i.e., run `app1` only) by re-building image

You can run `app1` (or `app2`) only by using re-builded container image.

1. Start container.
   ```console
   docker run -d --name re-build-image example.com/test/supervisor-override:latest
   ```

1. You can see the `COMMAND` (i.e., PID=1) is `app1`.
   ```console
   $ docker ps -n 3
   CONTAINER ID   IMAGE                                         COMMAND                  CREATED          STATUS          PORTS     NAMES
   f393bb2b715b   example.com/test/supervisor-override:latest   "/foo/app1"              6 seconds ago    Up 5 seconds              re-build-image
   aed1027dd695   example.com/test/supervisor:latest            "/foo/app1"              4 minutes ago    Up 4 minutes              app1
   82d9db06840f   example.com/test/supervisor:latest            "/usr/bin/supervisord"   10 minutes ago   Up 10 minutes             supervisor
   ```

1. You also can see only `app1` is running in the container.
   ```console
   $ docker logs re-build-image -n 8
   2023-07-28 01:39:17.716371433 +0000 UTC m=+50.017909408
   App 1
   2023-07-28 01:39:18.716841711 +0000 UTC m=+51.018379688
   App 1
   2023-07-28 01:39:19.717266353 +0000 UTC m=+52.018804331
   App 1
   2023-07-28 01:39:20.717722276 +0000 UTC m=+53.019260254
   App 1
   ```

## Conclusion

It seems that removing one of two processes is easy. So, I think it is a bit difficult to achieve the following requirement.

* We don't want users to remove one of two processes. Because it causes some unexpected issues and our product does not work properly.
