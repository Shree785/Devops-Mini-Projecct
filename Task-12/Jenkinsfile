pipeline {
    agent any

    parameters {
        choice(name: 'APP_ENV', choices: ['production', 'staging', 'development'], description: 'Target Deployment Environment')
        string(name: 'DEPLOY_PORT', defaultValue: '8080', description: 'HTTP Server Port for Deployed Application')
        choice(name: 'DEPLOY_TARGET', choices: ['docker', 'standalone-jar'], description: 'Deployment Platform Target')
        booleanParam(name: 'RUN_UNIT_TESTS', defaultValue: true, description: 'Execute unit and integration tests')
        booleanParam(name: 'RUN_SELENIUM_TESTS', defaultValue: true, description: 'Execute headless Chrome Selenium acceptance tests')
    }

    environment {
        APP_NAME        = 'security-log-review'
        VERSION         = '1.0.0'
        ARTIFACT_JAR    = "target/${APP_NAME}-${VERSION}.jar"
        DOCKER_IMAGE    = "${APP_NAME}:${VERSION}"
        DOCKER_CONTAINER = 'security-log-review-app'
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '5'))
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
    }

    stages {
        stage('Checkout') {
            steps {
                echo "=========================================================="
                echo " [STAGE: CHECKOUT] SCM Revision & Workspace Verification"
                echo "=========================================================="
                checkout scm
                script {
                    if (isUnix()) {
                        sh 'git log -1 --oneline'
                    } else {
                        bat 'tools\\git.cmd log -1 --oneline'
                    }
                }
            }
        }

        stage('Build') {
            steps {
                echo "=========================================================="
                echo " [STAGE: BUILD] Compiling Java 17 Spring Boot Sources"
                echo "=========================================================="
                script {
                    if (isUnix()) {
                        sh 'mvn -B clean compile'
                    } else {
                        bat 'tools\\mvn.cmd -B clean compile'
                    }
                }
            }
        }

        stage('Unit & Service Tests') {
            when {
                expression { return params.RUN_UNIT_TESTS == true }
            }
            steps {
                echo "=========================================================="
                echo " [STAGE: UNIT TESTS] Running Unit & Integration Test Suites"
                echo "=========================================================="
                script {
                    if (isUnix()) {
                        sh 'mvn -B test -Dtest=SecurityLogServiceTest,LogWebControllerTest,SecurityLogApplicationTests'
                    } else {
                        bat 'tools\\mvn.cmd -B test -Dtest=SecurityLogServiceTest,LogWebControllerTest,SecurityLogApplicationTests'
                    }
                }
            }
            post {
                always {
                    junit testResults: 'target/surefire-reports/*.xml', allowEmptyResults: true
                }
            }
        }

        stage('Continuous Testing (Selenium E2E Quality Gate)') {
            when {
                expression { return params.RUN_SELENIUM_TESTS == true }
            }
            steps {
                echo "=========================================================="
                echo " [STAGE: CONTINUOUS TESTING] Headless Chrome Acceptance Suite"
                echo "=========================================================="
                script {
                    if (isUnix()) {
                        sh 'mvn -B test -Dtest=SecurityLogE2ETest'
                    } else {
                        bat 'tools\\mvn.cmd -B test -Dtest=SecurityLogE2ETest'
                    }
                }
            }
            post {
                always {
                    junit testResults: 'target/surefire-reports/TEST-com.securitylog.e2e.*.xml', allowEmptyResults: true
                    archiveArtifacts artifacts: 'target/screenshots/*.png', allowEmptyArchive: true
                }
                failure {
                    echo "=========================================================="
                    echo " [QUALITY GATE FAILED] Selenium acceptance test failure detected!"
                    echo " [ACTION REQUIRED] Pipeline halted. Deployment aborted."
                    echo " [DIAGNOSTICS] Inspect archived failure screenshots in target/screenshots/."
                    echo "=========================================================="
                }
            }
        }

        stage('Package') {
            steps {
                echo "=========================================================="
                echo " [STAGE: PACKAGE] Packaging Production Spring Boot Executable JAR"
                echo "=========================================================="
                script {
                    if (isUnix()) {
                        sh 'mvn -B package -DskipTests'
                    } else {
                        bat 'tools\\mvn.cmd -B package -DskipTests'
                    }
                }
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }

        stage('Docker Build & Tag') {
            when {
                expression { return params.DEPLOY_TARGET == 'docker' }
            }
            steps {
                echo "=========================================================="
                echo " [STAGE: DOCKER BUILD] Building & Tagging OCI Container Image"
                echo " Image: ${env.DOCKER_IMAGE} and ${APP_NAME}:latest"
                echo "=========================================================="
                script {
                    if (isUnix()) {
                        sh "docker build -t ${env.DOCKER_IMAGE} -t ${env.APP_NAME}:latest ."
                        sh "docker images ${env.APP_NAME}"
                    } else {
                        bat "docker build -t ${env.DOCKER_IMAGE} -t ${env.APP_NAME}:latest ."
                        bat "docker images ${env.APP_NAME}"
                    }
                }
            }
        }

        stage('Continuous Deployment (Docker Container)') {
            when {
                expression { return params.DEPLOY_TARGET == 'docker' }
            }
            steps {
                echo "=========================================================="
                echo " [STAGE: DOCKER CD] Automated Zero-Downtime Container Deployment"
                echo " Target Environment : ${params.APP_ENV}"
                echo " Host Port Mapping  : ${params.DEPLOY_PORT} -> 8080"
                echo " Container Name     : ${env.DOCKER_CONTAINER}"
                echo "=========================================================="
                script {
                    if (isUnix()) {
                        sh "bash scripts/deploy-docker.sh ${env.APP_NAME} ${env.VERSION} ${env.DOCKER_CONTAINER} ${params.DEPLOY_PORT} ${params.APP_ENV}"
                    } else {
                        powershell "scripts/deploy-docker.ps1 -ImageName '${env.APP_NAME}' -Tag '${env.VERSION}' -ContainerName '${env.DOCKER_CONTAINER}' -HostPort ${params.DEPLOY_PORT} -AppEnv '${params.APP_ENV}'"
                    }
                }
            }
        }

        stage('Continuous Deployment (Standalone JAR)') {
            when {
                expression { return params.DEPLOY_TARGET == 'standalone-jar' }
            }
            steps {
                echo "=========================================================="
                echo " [STAGE: STANDALONE DEPLOY] Deploying Embedded JAR"
                echo "=========================================================="
                script {
                    if (isUnix()) {
                        sh "bash scripts/deploy.sh ${params.APP_ENV} ${params.DEPLOY_PORT} ${env.ARTIFACT_JAR}"
                    } else {
                        powershell "scripts/deploy.ps1 -AppEnv '${params.APP_ENV}' -DeployPort '${params.DEPLOY_PORT}' -JarPath '${env.ARTIFACT_JAR}'"
                    }
                }
            }
        }
    }

    post {
        success {
            echo "=========================================================="
            echo " [CD PIPELINE SUCCESS] Application Deployed & Verified Green!"
            echo " Deployment Platform : ${params.DEPLOY_TARGET}"
            echo " Target Environment  : ${params.APP_ENV}"
            echo " Access Dashboard    : http://localhost:${params.DEPLOY_PORT}/dashboard"
            echo " Security Logs Stream: http://localhost:${params.DEPLOY_PORT}/logs"
            echo " Actuator Health     : http://localhost:${params.DEPLOY_PORT}/actuator/health"
            echo "=========================================================="
        }
        failure {
            echo "=========================================================="
            echo " [CD PIPELINE FAILURE] Build, Quality Gate, or Deployment Failed."
            echo "=========================================================="
        }
    }
}
