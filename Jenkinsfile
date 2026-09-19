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
                sh """
                    docker build \
                    -t harshbhushandixit/cloudcart-auth:${BUILD_NUMBER} \
                    ./services/auth-service

                    docker build \
                    -t harshbhushandixit/cloudcart-product:${BUILD_NUMBER} \
                    ./services/product-service
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
                    docker push harshbhushandixit/cloudcart-auth:${BUILD_NUMBER}
                    docker push harshbhushandixit/cloudcart-product:${BUILD_NUMBER}
                """
            }
        }
    }

    post {
        success {
            echo 'CloudCart CI/CD pipeline completed successfully!'
        }

        failure {
            echo 'CloudCart pipeline failed.'
        }
    }
}