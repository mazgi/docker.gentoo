workflow "Build docker image on push" {
  on = "push"
  resolves = ["Build"]
}

action "Build Image" {
  uses = "actions/action-builder/docker@master"
  runs = "docker"
  args = "build -t docker.pkg.github.com/mazgi/docker.gentoo/basic:latest Dockerfile.d"
}

action "Publish Filter" {
  needs = ["Build Image"]
  uses = "actions/bin/filter@master"
  args = "branch master"
}

action "Push Image" {
  uses = "actions/action-builder/docker@master"
  runs = "docker"
  args = "push docker.pkg.github.com/mazgi/docker.gentoo/basic:latest Dockerfile.d"
}
