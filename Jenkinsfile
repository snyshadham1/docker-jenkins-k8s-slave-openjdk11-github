// Build Image
def label = "buildpod1.${env.JOB_NAME}.${env.BUILD_NUMBER}".replace('-', '_').replace('/', '_')
def artifactory_server = "ops0-artifactrepo1-0-prd.data.sfdc.net"
def artifactory_creds = "sfci-docker"
def docker_image = "productivity-devops/centos7-jenkins-kube-dind-openjdk11"

def image_url = artifactory_server + "/" + docker_image
def image_tag = ""
def build_ts = ""

podTemplate(label: label, inheritFrom: 'imagebuild') {
  node(label) {
    timestamps {
      stage ("git pull") {
        checkout scm
      }

      stage("Generate image tag") {
        image_tag = sh (
          script: "git rev-parse --short HEAD",
          returnStdout: true
        ).trim()

        println "image_tag=${image_tag}"
        build_ts="${currentBuild.startTimeInMillis}"
        println "build timestamp: ${build_ts}"
        build_ts=build_ts.reverse().take(4).reverse()
        image_tag = "${image_tag}.${build_ts}"
        println "image_tag=${image_tag}"
        println image_tag
      }

      stage("Build and push docker image") {
        docker.withRegistry("https://" + artifactory_server, artifactory_creds) {
          def base_image = docker.build (docker_image + ":" + image_tag, '.')
          base_image.push "${image_tag}"
          base_image.push 'latest'
        }
      }
    }
  }
}

// Check whether new image is working or not
label = "buildpod2.${env.JOB_NAME}.${env.BUILD_NUMBER}".replace('-', '_').replace('/', '_')
podTemplate(label: label, inheritFrom: 'imagebuild', containers: [
  containerTemplate(name: 'jnlp', image: image_url + ':' + image_tag, args: '${computer.jnlpmac} ${computer.name}')]
) {
  node(label)
  {
    stage("Testing new slave image") {
      sh "echo 'slave pod initiated successfully' ; sleep 10"
    }
  }
}

// Raise PRs for udpating child images
label = "buildpod3.${env.JOB_NAME}.${env.BUILD_NUMBER}".replace('-', '_').replace('/', '_')
podTemplate(label: label, inheritFrom: 'imagebuild') {
  node(label) {
    stage ("git pull") {
        checkout scm
    }

    stage("Created PRs for child repos") {
      println("Branch Name: " + env.BRANCH_NAME)
      if(env.BRANCH_NAME == "master") {
        withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'devops-git-token',
                        usernameVariable: 'github_api_user', passwordVariable: 'git_api_token']]) {
          sh "java -jar dockerfile-image-update.jar -g https://git.soma.salesforce.com/api/v3/ -m 'Automatic Dockerfile Image Updater: Updating Docker Image ${image_url} to latest' parent ${image_url} ${image_tag} sfci_docker_store"
        }
      }
    }
  }
}
