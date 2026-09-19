pipeline {

    agent any

    stages {

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

                // Auth Service tests
                dir('services/auth-service') {
                    sh 'npm test --if-present'
                }

                // Product Service tests
                dir('services/product-service') {
                    sh '''
                        if grep -q '"test"' package.json && ! grep -q 'no test specified' package.json; then
                            npm test
                        else
                            echo "No tests configured for Product Service - skipping."
                        fi
                    '''
                }
            }
        }

        stage('Docker Check') {
            steps {
                sh '''
                    echo "Checking Docker..."
                    docker --version
                    docker info
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh """
                    echo "Building Auth Service image..."

                    docker build \
                    -t harshbhushandixit/cloudcart-auth:${BUILD_NUMBER} \
                    ./services/auth-service

                    echo "Building Product Service image..."

                    docker build \
                    -t harshbhushandixit/cloudcart-product:${BUILD_NUMBER} \
                    ./services/product-service

                    echo "Docker images built successfully."

                    docker images | grep cloudcart
                """
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
                sh """
                    echo "Pushing Auth Service image..."

                    docker push \
                    harshbhushandixit/cloudcart-auth:${BUILD_NUMBER}

                    echo "Pushing Product Service image..."

                    docker push \
                    harshbhushandixit/cloudcart-product:${BUILD_NUMBER}

                    echo "Images pushed successfully."
                """
            }
        }
    }

    post {
        success {
            echo 'CloudCart CI/CD pipeline completed successfully!'
            echo "Build Number: ${BUILD_NUMBER}"
        }

        failure {
            echo 'CloudCart pipeline failed.'
            echo "Build Number: ${BUILD_NUMBER}"
        }

        always {
            echo 'CloudCart pipeline execution finished.'
        }
    }
}