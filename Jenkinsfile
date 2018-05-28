e3_checkout = {
    sh 'echo "E3_EPICS_PATH:=/tmp" > CONFIG_BASE.local'
    sh 'echo "EPICS_BASE:=/tmp/base-3.15.5" > RELEASE.local'

    dir('e3-base') {
        git url: "https://github.com/icshwi/e3-base"
    }

    dir('e3-require') {
        git url: "https://github.com/icshwi/e3-require"
    }

    modules.each {
        dir(it) {
            git url: "https://github.com/icshwi/${it}"
        }
    }
}

e3_init = {
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

e3_build = {
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
    agent none
    stages {
        stage('checkout') {
            agent {
                label 'docker-ce'
            }
            steps {
                script {
                    checkout scm
                    def content = readFile 'configure/MODULES_COMMON'
                    modules = content.split('\n').findAll { !it.startsWith('#') }
                }
            }
        }
        stage('build') {
            parallel {
                stage('CentOS 7') {
                    agent {
                        dockerfile {
                            dir 'environments/centos/7'
                            label 'docker-ce'
                        }
                    }
                    steps {
                        script {
                            e3_checkout()
                            e3_init()
                            e3_build()
                        }
                    }
                    post {
                        always {
                            cleanWs()
                        }
                    }
                }
                stage('Debian 8') {
                    agent {
                        dockerfile {
                            dir 'environments/debian/8'
                            label 'docker-ce'
                        }
                    }
                    steps {
                        script {
                            e3_checkout()
                            e3_init()
                            e3_build()
                        }
                    }
                    post {
                        always {
                            cleanWs()
                        }
                    }
                }
                stage('Debian 9') {
                    agent {
                        dockerfile {
                            dir 'environments/debian/9'
                            label 'docker-ce'
                        }
                    }
                    steps {
                        script {
                            e3_checkout()
                            e3_init()
                            e3_build()
                        }
                    }
                    post {
                        always {
                            cleanWs()
                        }
                    }
                }
                stage('Fedora 27') {
                    agent {
                        dockerfile {
                            dir 'environments/fedora/27'
                            label 'docker-ce'
                        }
                    }
                    steps {
                        script {
                            e3_checkout()
                            e3_init()
                            e3_build()
                        }
                    }
                    post {
                        always {
                            cleanWs()
                        }
                    }
                }
                stage('Ubuntu 16.04') {
                    agent {
                        dockerfile {
                            dir 'environments/ubuntu/16.04'
                            label 'docker-ce'
                        }
                    }
                    steps {
                        script {
                            e3_checkout()
                            e3_init()
                            e3_build()
                        }
                    }
                    post {
                        always {
                            cleanWs()
                        }
                    }
                }
                stage('Ubuntu 17.10') {
                    agent {
                        dockerfile {
                            dir 'environments/ubuntu/17.10'
                            label 'docker-ce'
                        }
                    }
                    steps {
                        script {
                            e3_checkout()
                            e3_init()
                            e3_build()
                        }
                    }
                    post {
                        always {
                            cleanWs()
                        }
                    }
                }
            }
        }
    }
}
