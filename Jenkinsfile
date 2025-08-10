pipeline {

    agent any

    environment {
	
		// AWS CLI will use 'base-user' profile configured in ~/.aws
		AWS_PROFILE = 'iam-user'
        AWS_REGION = 'ap-south-1'
        AWS_ACCOUNT_ID = '697624189023'
        IMAGE_NAME = 'project-jenkins-amazon'
        //IMAGE_TAG = "${BUILD_NUMBER}"
		IMAGE_TAG = '27'
        CONTAINER_NAME = 'project-jenkins-amazon-cont'
        ECR_REPO = 'cicd-jenkins-amazon-repo'
        ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        ECR_REPO_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}"
        ECR_CREDENTIALS_ID = 'amazon-creds'
        WEB_PORT = '8085'
        JENKINS_PORT = '8080'
		
        ROLE = 'iam-role'
        CLUSTER_NAME = 'iam-eks-cluster'
        ROLE_ARN = "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ROLE}"
        SESSION_NAME = 'eks-admin-session'
        PROFILE_USER = 'eks-admin'
    }

    stages {
	
	
/*
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
*/




        /*
        stage('Assume Role') {
            steps {
                script {
                    def creds = sh(script: """
                        aws sts assume-role \
                          --role-arn $ROLE_ARN \
                          --role-session-name $SESSION_NAME \
                          --no-cli-pager \
                          --output json
                    """, returnStdout: true).trim()

                    def json = readJSON text: creds

                    env.AWS_ACCESS_KEY_ID     = json.Credentials.AccessKeyId
                    env.AWS_SECRET_ACCESS_KEY = json.Credentials.SecretAccessKey
                    env.AWS_SESSION_TOKEN     = json.Credentials.SessionToken
                }
            }
        }
        */

        stage('Update kube Config') {
            steps {
                sh '''
					aws eks --region $AWS_REGION update-kubeconfig \
						--name $CLUSTER_NAME \
						--profile $PROFILE_USER --no-cli-pager
                '''
            }
        }

        stage('Verify Cluster Connectivity') {
            steps {
                sh '''
                    echo "Cluster List:"
                    aws eks list-clusters --profile $PROFILE_USER --region $AWS_REGION --no-cli-pager
                '''
            }
        }

		stage('Create imagePullSecret for EKS') {
			steps {
				withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'amazon-creds']]) {
					sh '''
						echo "Create imagePullSecret for EKS---started"
						echo "🔧 Updating kubeconfig for cluster access..."
						export AWS_PROFILE=$PROFILE_USER
						export KUBECONFIG=/root/.kube/config

						aws eks --region $AWS_REGION update-kubeconfig \
							--name $CLUSTER_NAME \
							--profile $AWS_PROFILE --no-cli-pager

						echo "🔍 Verifying context and namespace..."
						kubectl get ns
						kubectl config current-context
						kubectl config view --minify
						kubectl get sts || echo "STS access may be restricted"

						PASSWORD=$(aws ecr get-login-password --region $AWS_REGION)
						
						echo "🔐 Creating ECR imagePullSecret..."
						aws ecr get-login-password --region $AWS_REGION | \
						kubectl create secret docker-registry ecr-secret \
							--docker-server=$ECR_REGISTRY \
							--docker-username=AWS \
							--docker-password=$PASSWORD \
							--namespace=default \
							--dry-run=client -o yaml | kubectl apply -f -
						
						echo "Create imagePullSecret for EKS---finished"
					'''
				}
			}
		}


        stage('Update K8s Deployment') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'amazon-creds']]) {
                    sh '''
					
						echo "Deploy to EKS --- started"

						# Login to cluster
						./scripts/eks-login.sh

						# Apply manifests (idempotent)
						kubectl apply -f deployment.yaml
						kubectl apply -f service.yaml

						# Update image (will only change the container image without touching other specs)
						kubectl set image deployment/$IMAGE_NAME $CONTAINER_NAME=$ECR_REPO_URI:$IMAGE_TAG --namespace=default

						echo "Deploy to EKS --- finished"
                    '''
                }
            }
        }

        /*
        stage('Deploy Locally') {
            steps {
                sh '''
                    docker stop $CONTAINER_NAME || true
                    docker rm $CONTAINER_NAME || true

                    docker run -d -p $WEB_PORT:$JENKINS_PORT --name $CONTAINER_NAME $IMAGE_NAME:$BUILD_NUMBER
                '''
            }
        }
        */
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
