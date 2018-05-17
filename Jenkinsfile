init = {
    dir('e3-base') {
        sh 'make init'
        sh 'make env'
        sh 'make patch'
    }
    dir('e3-require') {
        sh 'make init'
        sh 'make env'
    }
    modules.each {
        dir(it) {
            sh 'make init'
            sh 'make env'
            sh 'make patch'
        }
    }
}

build = {
    dir('e3-base') {
        sh 'make build'
    }
    dir('e3-require') {
        sh 'make build'
        sh 'make install'
    }
    modules.each {
        dir(it) {
            sh 'make build'
            sh 'make install'
        }
    }
}

pipeline {
    agent {
        label 'docker-ce'
    }
    stages {
        stage('checkout') {
            steps {
                checkout scm
                sh 'echo "E3_EPICS_PATH:=/tmp" > CONFIG_BASE.local'
                sh 'echo "EPICS_BASE:=/tmp/base-3.15.5" > RELEASE.local'

                dir('e3-base') {
                    git url: "https://github.com/icshwi/e3-base"
                }

                dir('e3-require') {
                    git url: "https://github.com/icshwi/e3-require"
                }

                script {
                    def content = readFile 'configure/MODULES_COMMON'
                    modules = content.split('\n').findAll { !it.startsWith('#') }
                    modules.each {
                        dir(it) {
                            git url: "https://github.com/icshwi/${it}"
                        }
                    }
                }
            }
        }
        stage('build') {
            parallel {
                stage('Debian 9') {
                    agent {
                        dockerfile {
                            dir 'environments/debian/9'
                            reuseNode true
                        }
                    }
                    steps {
                        script {
                            init()
                            build()
                        }
                    }
                }
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
