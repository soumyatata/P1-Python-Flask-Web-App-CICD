pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'myawsdevopsjourney/p1-flask-web-app:latest'
        DOCKER_REGISTRY_CREDENTIALS = 'docker'
        
        SONARQUBE_CREDENTIALS = 'sonar-token'
        SONARQUBE_SERVER = 'sonar-server'
        SCANNER_HOME = tool 'sonar-scanner'
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
            steps {
                script {
                    withSonarQubeEnv("${SONARQUBE_SERVER}") {  
                        sh ''' $SCANNER_HOME/bin/sonar-scanner \
                            -Dsonar.projectName=flask-web-app \
                            -Dsonar.projectKey=flask-web-app '''
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    try {
                        // Wait for Quality Gate result with a timeout of 10 minutes (600 seconds)
                        timeout(time: 10, unit: 'MINUTES') {
                            waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token'  // Continue even if quality gate fails
                        }
                    } catch (Exception e) {
                        echo 'Quality Gate timed out, proceeding to next stage.'
                    }
                }
            }
        }

        stage('Dependency Check with OWASP Dependency-Check') {
            steps {
                dependencyCheck additionalArguments: '--project "Flask Web App" --scan ./ --exclude "node_modules,venv,logs" --disableYarnAudit --disableNodeAudit',
                odcInstallation: 'DP-Check'  // Ensure DP-Check is configured in Jenkins global tools
        
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                script {
                    withDockerRegistry(credentialsId: "${DOCKER_REGISTRY_CREDENTIALS}") {
                        sh '''
                        docker build -t ${DOCKER_IMAGE} .
                        docker push ${DOCKER_IMAGE}
                        '''
                    }
                }
            }
        }

        stage('Vulnerability Scan with Trivy') {
            steps {
                script {
                    sh 'trivy image --no-progress ${DOCKER_IMAGE} > trivy_report.txt'  // Scan the Docker image for vulnerabilities
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
