pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' // Test
            }
        }   
      stage('Test') {
            steps {
              sh "mvn test"              
            }
             post {
                always {
                   junit "target/surefire-reports/*.xml"
                  jacoco execPattern: "target/jacoco.exec"
                }
             }
      }
     stage('Docker Build and Push') {
           steps {
             withDockerRegistry([credentialsId: "docker", url: ""]) {
             sh 'printenv'
             sh 'docker build -t janadevps1/numeric-app:""$GIT_COMMIT"" .'
             sh 'docker push janadevps1/numeric-app:""$GIT_COMMIT""'
        }
      }
    }

    
    }
}
