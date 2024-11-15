pipeline {
    agent any
    stages {
        stage('build') {
            steps {
                sh 'perl Makefile.PL'
                sh 'make'
                sh 'sudo make install'
            }
        }
    }
}
