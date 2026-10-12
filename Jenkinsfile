pipeline {
    agent any

    environment {
        IMAGE_NAME = 'store-rating-backend'
        IMAGE_TAG  = "${env.BUILD_NUMBER}"
    }

    triggers {
        // Fallback if no webhook is configured: poll GitHub every 2 minutes
        pollSCM('H/2 * * * *')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                dir('backend') {
                    bat 'call npm ci'
                }
                dir('frontend') {
                    bat 'call npm ci'
                    bat 'call npm run build'
                }
            }
        }

        stage('Test') {
            steps {
                // The project has no unit tests yet: syntax-check every backend source file
                powershell '''
                    Get-ChildItem -Recurse backend\\src, backend\\scripts -Filter *.js | ForEach-Object {
                        node --check $_.FullName
                        if ($LASTEXITCODE -ne 0) { exit 1 }
                    }
                '''
            }
        }

        stage('Package') {
            steps {
                bat 'tar -czf store-rating-%IMAGE_TAG%.tar.gz backend/src backend/scripts backend/package.json frontend/dist'
                archiveArtifacts artifacts: 'store-rating-*.tar.gz', fingerprint: true
            }
        }

        stage('Docker Build') {
            steps {
                bat 'docker build -t %IMAGE_NAME%:%IMAGE_TAG% -t %IMAGE_NAME%:latest .'
            }
        }

        stage('Deploy') {
            steps {
                bat 'docker rm -f store-rating-app || ver > nul'
                bat 'docker run -d --name store-rating-app -p 5000:5000 %IMAGE_NAME%:%IMAGE_TAG%'
            }
        }
    }

    post {
        success { echo 'Pipeline finished: application deployed on port 5000' }
        failure { echo 'Pipeline failed - check the stage logs above' }
    }
}
