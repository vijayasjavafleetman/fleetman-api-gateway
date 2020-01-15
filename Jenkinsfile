node {


    def mvnHome
    def pom
    def artifactVersion
    def tagVersion
    def retrieveArtifact
    def name
    def SERVICE_NAME
    def REPOSITORY_TAG

environment{
  artifactVersion = pom.version
              name = pom.name
              REPOSITORY_TAG="${env.DOCKERHUB_USERNAME}/${env.ORGANIZATION_NAME}-${name}:${artifactVersion}.${env.BUILD_ID}"

}
    
    stage('Prepare') {
      mvnHome = tool 'MAVENHOME'
    }

    stage('Checkout') {
       checkout scm
    }
  stage('Deploy to Cluster') {
  
     pom = readMavenPom file: 'pom.xml'
            
              echo "${env.REPOSITORY_TAG}"
                 
                        sh 'envsubst < ${WORKSPACE}/deploy.yaml > ${WORKSPACE}/ndeploy.yaml'
                        sh 'cat ${WORKSPACE}/ndeploy.yaml'
                
            }

    stage('Build') {
       if (isUnix()) {
          sh "'${mvnHome}/bin/mvn' -Dmaven.test.failure.ignore clean package"
       } else {
          bat(/"${mvnHome}\bin\mvn" -Dmaven.test.failure.ignore clean package/)
       }
    }

    stage('Unit Test') {
       junit '**/target/surefire-reports/TEST-*.xml'
       archive 'target/*.jar'
    }

    stage('Integration Test') {
      if (isUnix()) {
         sh "'${mvnHome}/bin/mvn' -Dmaven.test.failure.ignore clean verify"
      } else {
         bat(/"${mvnHome}\bin\mvn" -Dmaven.test.failure.ignore clean verify/)
      }
    }

 

    if(env.BRANCH_NAME == 'master'){
      stage('Validate Build Post Prod Release') {
        if (isUnix()) {
           sh "'${mvnHome}/bin/mvn' clean package"
        } else {
           bat(/"${mvnHome}\bin\mvn" clean package/)
        }
      }

    }

      if(env.BRANCH_NAME == 'develop'){
        stage('Snapshot Build And Upload Artifacts') {
          if (isUnix()) {
             sh "'${mvnHome}/bin/mvn' clean deploy"
          } else {
             bat(/"${mvnHome}\bin\mvn" clean deploy/)
          }

              pom = readMavenPom file: 'pom.xml'
              artifactVersion = pom.version
              name = pom.name
              REPOSITORY_TAG="${env.DOCKERHUB_USERNAME}/${env.ORGANIZATION_NAME}-${name}:${artifactVersion}.${env.BUILD_ID}"
              echo "${REPOSITORY_TAG}"
              echo "artifact version : ${artifactVersion}"
        }
        

         stage('SSH transfer') {
                script {
                  sshPublisher(
                     continueOnError: false,
                     failOnError: true,
                     publishers: [
                                  sshPublisherDesc(
                                  configName: "ansibleserver",
                                  verbose: true,
                                  transfers: [
                                                sshTransfer(
                                                   sourceFiles: "",
                                                   removePrefix: "",
                                                   remoteDirectory: "",
                                                   execCommand: "rm -f *.*"
                                                ),
                                                sshTransfer(
                                                   execTimeout: 240000,
                                                   sourceFiles: "Dockerfile,fleetman-build-playbook.yaml",
                                                   removePrefix: "",
                                                   remoteDirectory: "",
                                                   execCommand: "pwd;ansible-playbook -i /home/ansadmin/jenkins/hosts -u ansadmin -e tag=${REPOSITORY_TAG} -e ARTIFACT_VERSION=${artifactVersion} -e ARTIFACTORY_URL=${env.ARTIFACTORY_SNAPSHOT_URL} -e ARTIFACTORY_USERNAME=${env.ARTIFACTORY_USERNAME} -e ARTIFACTORY_PASSWD=${env.ARTIFACTORY_PASSWD} -e DOCKER_USERNAME=${env.DOCKERHUB_USERNAME} -e DOCKER_PASSWD=${env.DOCKERHUB_PASSWD} /home/ansadmin/jenkins/fleetman-build-playbook.yaml;"
                                                )
                                 ])
                     ])
                  }

            }

            stage('Deploy to Cluster') {
                 
                        sh 'envsubst < ${WORKSPACE}/deploy.yaml'
                        sh 'cat deploy.yaml'
                
            }

      }


}
