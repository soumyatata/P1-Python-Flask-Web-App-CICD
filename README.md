# 🚀**Flask Web App Deployment using Jenkins CI/CD Pipeline**

## **Overview:**

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
Once Jenkins installed access with EC2 with public IP address with 8080 port.
On first login Username as 'admin' and for Password

```bash
    sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Install Trivy

```bash

    sudo apt-get install wget apt-transport-https gnupg lsb-release -y
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
    sudo apt-get update
    sudo apt-get install trivy -y
    
```
Install Docker

```bash
    sudo apt-get update
    sudo apt-get install docker.io -y
    sudo usermod -aG docker $USER       
    newgrp docker
    sudo chmod 777 /var/run/docker.sock
```


**Step 3:** Deploy SonarQube using Docker

```bash
        docker run -d --name sonar -p 9000:9000 sonarqube:lts-community
```
**Step 4:** Install Jenkins Plugins

Navigate to Manage Jenkins → Plugin Manager → Install: 

o SonarQube Scanner

o OWASP Dependency Check

o Docker

o Docker Pipeline

o Docker Commons

o Docker API


Configure all tools that we install using Plugins, Go to Manage Jenkins → Tools → Add dependencies for Sonar, Docker, Dependency Check


**Step 5:** Configure Sonar Server in Jenkins

Grab the Public IP Address of your EC2 Instance, Sonarqube works on Port 9000, so <Public IP>:9000. Goto your Sonarqube Server. Click on Administration → Security → Users → Click on Tokens and Update Token → Give it a name → and click on Generate Token

Now Copy Token , Goto Jenkins Dashboard → Manage Jenkins → Credentials → Add Secret Text → paste the token under Secret

Now, go to Dashboard → Manage Jenkins → System → Add SonarQube Server Details.

In the Sonarqube Dashboard add a quality gate also

Administration → Configuration → Webhooks → Create

#In url section of quality gate

http://jenkins-public-ip:8080/sonarqube-webhook/

**Step 6:** Add DockerHub Username and Password under Global Credentials

Go to Dashboard → Manage Jenkins → Credentials → System → Global → Username with password

**Step 7:** Create a Jenkins Pipeline

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
                        git branch: 'main', url: 'https://github.com/soumyatata/P1-Python-Flask-Web-App-CICD'
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

🔗 **GitHub:** [PYTHON-FLASK-WEB-APP](https://github.com/soumyatata/P1-Python-Flask-Web-App-CICD)

🔗 **LinkedIn:** [SoumyaTata](https://www.linkedin.com/in/t-soumya/)

🚀 Happy Coding & DevOps Journey! 🚀

