pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'myawsdevopsjourney/p1-flask-web-app:latest'
        DOCKER_REGISTRY_CREDENTIALS = 'docker'
        K8S_CREDENTIALS = 'k8s'
        SONARQUBE_CREDENTIALS = 'Sonar-token'
        SONARQUBE_SERVER = 'sonar-server'
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()  // Clean up previous builds
            }
        }

        stage('Checkout code from GitHub') {
            steps {
                git branch: 'main', url: 'https://github.com/soumyatata/p1-flask-aws-devops-pipeline.git'
            }
        }

        stage('SonarQube Code Quality Check') {
            script {
                withSonarQubeEnv("${SONARQUBE_SERVER}") {  
                    sh 'sonar-scanner -Dsonar.projectKey=flask-web-app -Dsonar.sources=.'
                }
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    waitForQualityGate abortPipeline: true, credentialsId: "${SONARQUBE_CREDENTIALS}"  // Abort if quality gate fails
                }
            }
        }

        stage('Dependency Check with OWASP Dependency-Check') {
            steps {
                script {
                    sh 'dependency-check --project "Flask Web App" --scan . --out dependency-check-report'
                    archiveArtifacts artifacts: 'dependency-check-report/*.html', allowEmptyArchive: true  // Archive OWASP Dependency-Check report
                }
            }
        }

        // stage('Trivy FS Scan') {
        //     steps {
        //         sh "trivy fs . > trivyfs.txt"  // Scan filesystem for vulnerabilities (optional, based on app's needs)
        //     }
        // }

        stage('Build and Push Docker Image') {
            steps {
                script {
                    withDockerRegistry(credentialsId: "${DOCKER_REGISTRY_CREDENTIALS}") {
                        sh '''
                        docker build -t ${DOCKER_IMAGE} .
                        docker tag p1-flask-web-app:latest ${DOCKER_IMAGE}
                        docker push ${DOCKER_IMAGE}
                        '''
                    }
                }
            }
        }

        stage('Vulnerability Scan with Trivy') {
            steps {
                script {
                    sh 'trivy image --skip-update --no-progress ${DOCKER_IMAGE} > trivy_report.txt'  // Scan the Docker image for vulnerabilities
                    archiveArtifacts artifacts: 'trivy_report.txt', allowEmptyArchive: true  // Save the Trivy report as an artifact
                }
            }
        }

        stage('Deploy Docker Container') {
            steps {
                script {
                    // Check if container is running before stopping and removing
                    sh '''
                    docker ps -q -f name=p1-flask-web-app || true
                    docker stop p1-flask-web-app || true
                    docker rm p1-flask-web-app || true
                    docker run -d --name p1-flask-web-app -p 5000:5000 ${DOCKER_IMAGE}
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: "${K8S_CREDENTIALS}", namespace: '', restrictKubeConfigAccess: false, serverUrl: '') {
                        sh '''
                        kubectl apply -f deployment.yml
                        kubectl apply -f service.yml
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                sh 'docker container prune -f || true'  // Clean up unused containers
                sh 'docker image prune -f || true'  // Clean up unused images
                sh 'docker volume prune -f || true' // Clean up unused volumes
            }
        }
    }
}
