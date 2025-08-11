pipeline {

    agent any

    environment {
	
		// AWS CLI will use 'base-user' profile configured in ~/.aws
		//AWS_PROFILE = 'dev-user'	//If using user profiling yet all
        AWS_REGION = 'ap-south-1'
        AWS_ACCOUNT_ID = '697624189023'
        IMAGE_NAME = 'project-jenkins-amazon'
        IMAGE_TAG = "${BUILD_NUMBER}"
        CONTAINER_NAME = 'project-jenkins-amazon-cont'
        ECR_REPO = 'cicd-jenkins-amazon-repo'
        ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        ECR_REPO_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}"
        ECR_CREDENTIALS_ID = 'amazon-creds'
        WEB_PORT = '8085'
        JENKINS_PORT = '8080'
		
        ROLE = 'DevClusterRole'
        CLUSTER_NAME = 'dev-cluster'
        ROLE_ARN = "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ROLE}"
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
                    docker tag $IMAGE_NAME:$IMAGE_TAG $ECR_REPO_URI:$IMAGE_TAG
                    docker push $ECR_REPO_URI:$IMAGE_TAG
					
					#docker tag $IMAGE_NAME:latest $ECR_REPO_URI:latest
                    #docker push $ECR_REPO_URI:latest
					
					#Remove local/host-machine build
					docker rmi $IMAGE_NAME:$IMAGE_TAG --force
                '''
            }
        }

		stage('Verify Cluster Connectivity') {
			steps {
				sh '''
					echo "Cluster List:"
					aws eks list-clusters --region $AWS_REGION --no-cli-pager
				'''
			}
		}

		stage('Create imagePullSecret for EKS') {
			steps {
				withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'amazon-creds']]) {
					sh '''
						echo "Create imagePullSecret for EKS---started"
						echo "🔧 Updating kubeconfig for cluster access..."
						
						export KUBECONFIG=$WORKSPACE/.kube/config
						
						mkdir -p $(dirname $KUBECONFIG)
						aws eks --region $AWS_REGION update-kubeconfig --name $CLUSTER_NAME --kubeconfig $KUBECONFIG --alias $CLUSTER_NAME
						
						echo "🔍 Verifying context and namespace..."
						kubectl --kubeconfig $KUBECONFIG get ns
						kubectl --kubeconfig $KUBECONFIG config current-context
						kubectl --kubeconfig $KUBECONFIG config view --minify
						kubectl --kubeconfig $KUBECONFIG get sts || echo "STS access may be restricted"
						
						PASSWORD=$(aws ecr get-login-password --region $AWS_REGION)
						
						echo "🔐 Creating ECR imagePullSecret..."
						aws ecr get-login-password --region $AWS_REGION | \
						kubectl --kubeconfig $KUBECONFIG create secret docker-registry ecr-secret \
							--docker-server=$ECR_REGISTRY \
							--docker-username=AWS \
							--docker-password=$PASSWORD \
							--namespace=default \
							--dry-run=client -o yaml | kubectl --kubeconfig $KUBECONFIG apply -f -
						
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
						
						export KUBECONFIG=$WORKSPACE/.kube/config
						
						# Apply manifests (idempotent)
						kubectl --kubeconfig $KUBECONFIG apply -f k8s/deployment.yaml
						kubectl --kubeconfig $KUBECONFIG apply -f k8s/service.yaml
						
						# Update image (only container image)
						kubectl --kubeconfig $KUBECONFIG set image deployment/$IMAGE_NAME $CONTAINER_NAME=$ECR_REPO_URI:$IMAGE_TAG --namespace=default
						
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
