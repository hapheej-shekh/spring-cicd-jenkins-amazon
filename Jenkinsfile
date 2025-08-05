pipeline {

    agent any

    environment {
	
        AWS_REGION = 'ap-south-1'
        AWS_ACCOUNT_ID = '697624189023'
        IMAGE_NAME = 'project-jenkins-amazon'
        CONTAINER_NAME = 'project-jenkins-amazon-cont'
        ECR_REPO = 'cicd-jenkins-amazon-repo'
		ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        ECR_REPO_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}"
        ECR_CREDENTIALS_ID = 'amazon-creds'
        WEB_PORT = 8085
        JENKINS_PORT = 8080
		
		CLUSTER_NAME = 'amazon-eks-cluster'
		IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/hapheej-shekh/spring-cicd-jenkins-amazon.git'
            }
        }

        stage('Build JAR') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME:$BUILD_NUMBER .'
            }
        }

		stage('Login to ECR') {
			steps {
				withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${ECR_CREDENTIALS_ID}"]]) {
					sh '''
						aws ecr get-login-password --region $AWS_REGION | \
						docker login --username AWS --password-stdin $ECR_REGISTRY
					'''
				}
			}
		}

        stage('Push to ECR') {
            steps {
                sh '''
                    docker tag $IMAGE_NAME:$BUILD_NUMBER $ECR_REPO_URI:$BUILD_NUMBER
                    docker tag $IMAGE_NAME:$BUILD_NUMBER $ECR_REPO_URI:latest
                    docker push $ECR_REPO_URI:$BUILD_NUMBER
                    docker push $ECR_REPO_URI:latest
                '''
            }
        }

		stage('Create imagePullSecret for EKS') {
			steps {
				withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'amazon-creds']]) {
					sh '''
						aws ecr get-login-password --region $AWS_REGION | \
						kubectl create secret docker-registry ecr-secret \
						--docker-server=$ECR_REGISTRY \
						--docker-username=AWS \
						--docker-password-stdin || true
					'''
				}
			}
		}

		stage('Update K8s Deployment') {
			steps {
				sh '''
					chmod +x scripts/eks-login.sh
					chmod +x scripts/deploy.sh

					echo "Logging into EKS..."
					./scripts/eks-login.sh

					echo "Updating deployment with new image...Kubernetes resources: deployment"
					kubectl set image deployment/$IMAGE_NAME $CONTAINER_NAME=$ECR_REPO_URI:$IMAGE_TAG || true

					echo "Applying all configs (fallback)..."
					./scripts/deploy.sh
				'''
			}
		}

        stage('Deploy Locally') {
            steps {
                sh '''
                    docker stop $CONTAINER_NAME || true
                    docker rm $CONTAINER_NAME || true

                    docker run -d -p $WEB_PORT:$JENKINS_PORT --name $CONTAINER_NAME $IMAGE_NAME:$BUILD_NUMBER
                '''
            }
        }
		

    post {
        success {
            echo '🚀 Deployment Success!'
        }
        failure {
            echo '❌ Build failed!'
        }
    }
}
