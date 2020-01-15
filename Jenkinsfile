node {

    def mvnHome
    def pom
    def artifactVersion
    def tagVersion
    def retrieveArtifact
    def name
    def SERVICE_NAME
    def REPOSITORY_TAG

      stage('Deploy to Cluster') {
                 
                        sh 'envsubst < ${WORKSPACE}/deploy.yaml'
                        sh 'cat deploy.yaml'
                
            }

    

}
