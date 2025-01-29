# **Flask Web App Deployment using Jenkins CI/CD Pipeline**
🚀 Overview
This project demonstrates a CI/CD pipeline for deploying a Flask web application using Jenkins, Docker, SonarQube, OWASP Dependency-Check, and Trivy. The pipeline automates testing, security scanning, Docker image building, and deployment.
________________________________________

## 📌 **Steps to Set Up & Deploy**

**Step 1:** Create an AWS EC2 Instance

•	Launch an Ubuntu T2 Large instance.

•	Configure security groups to allow Jenkins (8080), SonarQube (9000), and Flask App (5000).

**Step 2:**  Install Jenkins, Docker, and Trivy

```bash
        sudo apt update && sudo apt upgrade -y
        sudo apt install -y openjdk-11-jdk docker.io
        sudo systemctl enable --now docker
        sudo usermod -aG docker $USER                       

        # Install Jenkins
        wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
        echo "deb http://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list
        sudo apt update && sudo apt install -y jenkins
        sudo systemctl enable --now jenkins
```

**Step 3:** Deploy SonarQube using Docker

```bash
        docker run -d --name sonar -p 9000:9000 sonarqube:lts-community
```
**Step 4:** Install Jenkins Plugins

Navigate to Manage Jenkins → Plugin Manager → Install: 

o SonarQube Scanner
o OWASP Dependency Check
o Docker Pipeline
o Pipeline Utility Steps
o Trivy Scanner

**Step 5:** Configure Sonar Server in Jenkins

Go to Manage Jenkins → Global Tool Configuration → SonarQube Scanner → Add SonarQube Server Details.

**Step 6:** Create a Jenkins Pipeline

1️⃣ Go to Jenkins Dashboard → New Item → Pipeline.

2️⃣ Add the following pipeline script:

```bash

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
                stage('Checkout Code') {
                    steps {
                        git branch: 'main', url: 'https://github.com/soumyatata/p1-flask-aws-devops-pipeline.git'
                    }
                }

                stage('Code Quality Check with SonarQube') {
                    steps {
                        script {
                            withSonarQubeEnv("${SONARQUBE_SERVER}") {
                                sh """
                                $SCANNER_HOME/bin/sonar-scanner \
                                -Dsonar.projectName=flask-web-app \
                                -Dsonar.projectKey=flask-web-app
                                """
                            }
                        }
                    }
                }

                stage('Dependency Check with OWASP') {
                    steps {
                        dependencyCheck additionalArguments: '--scan ./', odcInstallation: 'DP-Check'
                    }
                }

                stage('Build & Push Docker Image') {
                    steps {
                        script {
                            withDockerRegistry(credentialsId: "${DOCKER_REGISTRY_CREDENTIALS}") {
                                sh """
                                docker build -t ${DOCKER_IMAGE} .
                                docker push ${DOCKER_IMAGE}
                                """
                            }
                        }
                    }
                }

                stage('Security Scan with Trivy') {
                    steps {
                        sh 'trivy image --no-progress ${DOCKER_IMAGE} > trivy_report.txt'
                    }
                }

                stage('Deploy Docker Container') {
                    steps {
                        script {
                            sh """
                            docker stop p1-flask-web-app || true
                            docker rm p1-flask-web-app || true
                            docker run -d --name p1-flask-web-app -p 5000:5000 ${DOCKER_IMAGE}
                            """
                        }
                    }
                }
            }
        }
```

**Step 7:** Run the Pipeline

1️⃣ Click on 'Build Now' in Jenkins.

2️⃣	The pipeline will pull code, run tests, build a Docker image, and deploy the container.
________________________________________

## 📌 **Key Tools & Technologies Used**

✅ Jenkins - CI/CD automation

✅ Docker - Containerization

✅ SonarQube - Code quality analysis

✅ OWASP Dependency-Check - Security vulnerability scanning

✅ Trivy - Docker image vulnerability scanner

✅ AWS EC2 - Cloud deployment
________________________________________
📢 Let's Connect!

If you have any questions or suggestions, feel free to reach out. Contributions are welcome!

🔗 **GitHub:** [PYTHON-FLASK-WEB-APP](https://github.com/soumyatata/p1-flask-aws-devops-pipeline)

🔗 **LinkedIn:** [SoumyaTata](https://www.linkedin.com/in/t-soumya/)

🚀 Happy Coding & DevOps Journey! 🚀

