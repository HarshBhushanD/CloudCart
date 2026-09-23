pipeline {

    agent any

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Auth Service - Install') {
            steps {
                dir('services/auth-service') {
                    sh 'npm ci'
                }
            }
        }

        stage('Product Service - Install') {
            steps {
                dir('services/product-service') {
                    sh 'npm ci'
                }
            }
        }

        stage('Test') {
            steps {
                echo 'Running CloudCart tests...'

                dir('services/auth-service') {
                    sh 'npm test --if-present'
                }

                dir('services/product-service') {
                    sh 'npm test --if-present'
                }
            }
        }

        stage('Docker Build') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {

                    sh '''
                        echo "Building Auth Service image..."

                        docker build \
                            -t $DOCKER_USER/cloudcart-auth:${BUILD_NUMBER} \
                            ./services/auth-service

                        echo "Building Product Service image..."

                        docker build \
                            -t $DOCKER_USER/cloudcart-product:${BUILD_NUMBER} \
                            ./services/product-service

                        echo "Docker images built successfully."
                    '''
                }
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {

                    sh '''
                        echo "$DOCKER_PASS" | docker login \
                            -u "$DOCKER_USER" \
                            --password-stdin
                    '''
                }
            }
        }

        stage('Push Images') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {

                    sh '''
                        echo "Pushing Auth Service image..."

                        docker push \
                            $DOCKER_USER/cloudcart-auth:${BUILD_NUMBER}

                        echo "Pushing Product Service image..."

                        docker push \
                            $DOCKER_USER/cloudcart-product:${BUILD_NUMBER}

                        echo "Docker images pushed successfully."
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {

                    sh '''
                        echo "Deploying Auth Service..."

                        kubectl set image deployment/auth-service \
                            auth-service=$DOCKER_USER/cloudcart-auth:${BUILD_NUMBER} \
                            -n cloudcart

                        echo "Deploying Product Service..."

                        kubectl set image deployment/product-service \
                            product-service=$DOCKER_USER/cloudcart-product:${BUILD_NUMBER} \
                            -n cloudcart

                        echo "Waiting for Auth Service rollout..."

                        kubectl rollout status \
                            deployment/auth-service \
                            -n cloudcart \
                            --timeout=180s

                        echo "Waiting for Product Service rollout..."

                        kubectl rollout status \
                            deployment/product-service \
                            -n cloudcart \
                            --timeout=180s

                        echo "Kubernetes deployment successful."
                    '''
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    echo "Checking Auth Service..."

                    kubectl get deployment auth-service \
                        -n cloudcart

                    echo "Checking Product Service..."

                    kubectl get deployment product-service \
                        -n cloudcart

                    echo "Checking CloudCart pods..."

                    kubectl get pods \
                        -n cloudcart

                    echo "CloudCart deployment verified successfully."
                '''
            }
        }
    }

    post {

        success {
            echo '========================================'
            echo 'CloudCart CI/CD Pipeline SUCCESS'
            echo "Build Number: ${BUILD_NUMBER}"
            echo '========================================'
        }

        failure {
            echo '========================================'
            echo 'CloudCart CI/CD Pipeline FAILED'
            echo "Build Number: ${BUILD_NUMBER}"
            echo '========================================'
        }

        always {
            echo 'CloudCart pipeline execution finished.'
        }
    }
}