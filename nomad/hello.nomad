job "hello-devops" {

  datacenters = ["dc1"]

  type = "service"

  group "hello" {

    count = 1

    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    task "hello" {

      driver = "docker"

      config {
        image = "devops-intern-final:latest"
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}
