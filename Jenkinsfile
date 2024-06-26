pipeline {
  agent any
  environment {
    deploymentName = "devsecops"
    containerName = "devsecops-container"
    serviceName = "devsecops-svc"
    imageName = "janadevps1/numeric-app:${GIT_COMMIT}"
  }

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //test
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
     stage('Mutation Tests - PIT') {
      steps {
        sh "mvn org.pitest:pitest-maven:mutationCoverage"
      }
      post {
        always {
          pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
        }
      }
    }
     stage('SonarQube - SAST') {
        steps {
        withSonarQubeEnv('SonarQube') {
        sh "mvn sonar:sonar -Dsonar.projectKey=numeric-application -Dsonar.host.url=http://localhost:9000 -Dsonar.login=0c1ba5cbadb9547f681167e7033ae69b9d4b466f"
        }
          timeout(time: 2, unit: 'MINUTES') {
          script {
            waitForQualityGate abortPipeline: true
          }
        
        }
        }
    }
    //stage('Vulnerability Scan - Docker ') {
      //steps {
       // sh "mvn dependency-check:check"
     // }
      //post {
       // always {
         // dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
        //}
     // }
   // }

      stage('Trivy scan') {
      steps {
       sh "bash trivy-docker-image-scan.sh"
     }
      }

    //stage('OPA scan') {
      //steps {
       // sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile'
     // }
   // }
     
     stage('Docker Build and Push') {
          steps {
            withDockerRegistry([credentialsId: "docker", url: ""]) {
            sh 'printenv'
             sh 'sudo docker build -t janadevps1/numeric-app:""$GIT_COMMIT"" .'
             sh 'docker push janadevps1/numeric-app:""$GIT_COMMIT""'
        }
      }
    }

    stage('Vulnerability Scan - Kubernetes') {
      steps {
        parallel(
          "OPA Scan": {
            sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
          },
          "Kubesec Scan": {
            sh "bash kubesec-scan.sh"
          }
        )
      }
    }
          
    
    //stage('Kubernetes Deployment - DEV') {
     //steps {
      // withKubeConfig([credentialsId: 'kubeconfig']) {
       //  sh "sed -i 's#replace#janadevps1/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
        //sh "kubectl apply -f k8s_deployment_service.yaml"
       //}
      //}

    //}

    stage('K8S Deployment - DEV') {
      steps {
        parallel(
          "Deployment": {
            withKubeConfig([credentialsId: 'kubeconfig']) {
              sh "bash k8s-deployment.sh"
            }
          },
          "Rollout Status": {
            withKubeConfig([credentialsId: 'kubeconfig']) {
              sh "bash k8s-deployment-rollout-status.sh"
            }
          }
        )
      }
    }
  }

  }
   
 

