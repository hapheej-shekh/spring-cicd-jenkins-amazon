@echo off

echo Building Docker image...
docker build -t amazon-cli-kubectl .

echo Running container from image amazon-cli-kubectl...

REM Run container and mount your .kube config
REM docker run -it --rm -v %USERPROFILE%\.kube:/root/.kube amazon-cli-kubectl

REM Run container and mount your .kube and .aws config
REM docker run -it --rm -v %USERPROFILE%\.kube:/root/.kube -v %USERPROFILE%\.aws:/root/.aws amazon-cli-kubectl

REM -it-> interactive mode[Goes inside ontainer], -dit-> Run container in background (detached mode):
REM docker run -dit --name amazon-cli-kubectl -v %USERPROFILE%\.kube:/root/.kube -v %USERPROFILE%\.aws:/root/.aws amazon-cli-kubectl

REM run as root
docker run -dit --name amazon-cli-kubectl --user root -v %USERPROFILE%\.aws:/root/.aws amazon-cli-kubectl

REM --rm: Automatically removes the container when it exits
REM --name: Gives the container a fixed name
REM --rm removes & --name gives permanent name so dont use both in same command
