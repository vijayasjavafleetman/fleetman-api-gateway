node {

    def mvnHome
    def pom
    def artifactVersion
    def tagVersion
    def retrieveArtifact
    def name
    def SERVICE_NAME
    def REPOSITORY_TAG

    stage('Prepare') {
      mvnHome = tool 'MAVENHOME'
    }

    stage('Checkout') {
       checkout scm
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
        }
        

stage('SSH transfer') {

 script {

  sshPublisher(
    continueOnError: false, failOnError: true,

   publishers: [

    sshPublisherDesc(

     configName: "ansibleserver",

     verbose: true,

     transfers: [

      sshTransfer(

       sourceFiles: ["Dockerfile","fleetman-build-playbook.yaml"],

       removePrefix: "",

       remoteDirectory: "",

       execCommand: "rm -f *.*;ansible-playbook -i localhost, -u ansadmin -k -e tag=${REPOSITORY_TAG} fleetman-build-playbook.yaml;"

      )

     ])

   ])

 }

}


      }


}
