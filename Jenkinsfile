pipeline { 
    agent any 
    stages {
        stage('Build') { 
            steps { 
                bash 'e3.bash -g test2 all' 
            }
        }
        stage('Test'){
            steps {
                bash 'e3.bash -g test2 load'
            }
        }
        stage('Deploy') {
            steps {
            }
        }
    }
}
