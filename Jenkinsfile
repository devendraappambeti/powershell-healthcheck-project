pipeline {
    agent any

    stages {

        stage('Checkout Code') {
            steps {
                git 'https://github.com/your-repo/powershell-healthcheck-project.git'
            }
        }

        stage('Run Health Check') {
            steps {
                powershell '''
                cd scripts
                ./healthcheck.ps1
                '''
            }
        }

        stage('Archive Report') {
            steps {
                archiveArtifacts artifacts: 'output/report.json', fingerprint: true
            }
        }
    }

    post {
        success {
            echo 'Health Check Passed ✅'
        }
        failure {
            echo 'Health Check Failed ❌'
        }
    }
}
