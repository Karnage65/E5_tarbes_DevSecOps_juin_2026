pipeline {

    agent any

    /*
    Déclaration des paramètres.
    Ils apparaîtront dans Jenkins avec l'option : "Build with Parameters"
    */
    parameters {
        string(
            name: 'NAME',
            defaultValue: 'Karnage65',
            description: 'Please tell me your name'
        )

        text(
            name: 'DESC',
            defaultValue: 'Pipeline CI/CD Jenkins GitHub - Projet E5 Tarbes',
            description: 'Description du Job'
        )

        booleanParam(
            name: 'SKIP_TEST',
            defaultValue: false,
            description: 'Skip running Tests ?'
        )

        choice(
            name: 'BRANCH',
            choices: ['main', 'dev', 'test'],
            description: 'Choose Git branch'
        )

        password(
            name: 'SONAR_SERVER_PWD',
            description: 'Enter SONAR token or password'
        )
    }

    environment {
        APP_NAME = "e5-web-app"
        DOCKER_IMAGE = "karnage65/e5-web-app"
        // Comme tout est en local natif sur Windows, localhost fonctionne parfaitement
        
        TRIVY_EXE = "C:\\ProgramData\\chocolatey\\bin\\trivy.exe"

        SNYK_EXE = "C:\\ProgramData\\chocolatey\\bin\\snyk.exe"
    }

    stages {

        /*
        Affichage des paramètres envoyés par l'utilisateur
        */
        stage('01 - PRINT PARAMETERS') {
            steps {
                echo "Hello ${params.NAME}"
                echo """
                Job Description:
                ${params.DESC}
                """
                echo "Branch Selected : ${params.BRANCH}"
                echo "Skip Test : ${params.SKIP_TEST}"
            }
        }
        stage('02 - CHECK TOOLS') {

            steps {

                bat """
                echo ===== MAVEN =====
                mvn -version
                echo ===== DOCKER =====
                docker --version
                echo ===== TRIVY =====
                "%TRIVY_EXE%" --version
                echo ===== SNYK =====
                "%SNYK_EXE%" --version
                """
            }
        }


        /*
        Récupération du projet depuis ton Github personnalisé
        */
        stage('02 - CHECKOUT GITHUB') {
            steps {
                echo "Downloading source code from your repository..."
                git branch: "${params.BRANCH}", url: 'https://github.com/Karnage65/E5_tarbes_DevSecOps_juin_2026.git'
            }
        }

        /*
        Compilation de l'application avec Maven (Syntaxe Windows 'bat')
        */
        stage('03 - BUILD APPLICATION') {
            steps {
                echo "Building Application"
                bat "mvn clean package"
            }
        }

        /*
        Tests unitaires (Le stage sera ignoré si SKIP_TEST=true)
        */
        stage('04 - RUN TESTS') {
            when {
                expression {
                    return params.SKIP_TEST == false
                }
            }
            steps {
                echo "Running Tests"
                bat "mvn test"
            }
        }

        stage('Security Scan') {
            steps {
                bat """
                trivy image --severity HIGH,CRITICAL ${DOCKER_IMAGE}:latest
                """
            }
        }
        /*
        Création de ton image Docker locale
        */
        stage('06 - DOCKER BUILD') {
            steps {
                echo "Creating Docker image"
                bat "docker build -t ${DOCKER_IMAGE}:latest ."
            }
        }

        /*
        Déploiement sur le port 8082 (pour ne pas bloquer Jenkins sur le 8080)
        */
        stage('07 - DEPLOY') {
            steps {
                echo "Deploying Application"
                
                // returnStatus: true évite de faire planter le script si le conteneur n'existe pas encore
                bat script: "docker stop ${APP_NAME}", returnStatus: true
                bat script: "docker rm ${APP_NAME}", returnStatus: true

                // Lancement du nouveau conteneur sur le port 8082
                bat "docker run -d --name ${APP_NAME} -p 8082:8080 ${DOCKER_IMAGE}:latest"
            }
        }
    
        stage('09 - SNYK CONTAINER SCAN') {
            when {
                expression {
                    return params.SKIP_SNYK == false
                }
            }
            steps {
                echo "Analyse de l'image Docker avec Snyk via archive Docker..."
                withCredentials([string(credentialsId: 'snyk-token', variable: 'SNYK_TOKEN')]) {
                    bat """
                    "%SNYK_EXE%" auth %SNYK_TOKEN%
                    docker save %DOCKER_IMAGE%:latest -o snyk-image.tar
                    "%SNYK_EXE%" container test docker-archive:snyk-image.tar ^
                    --severity-threshold=high
                    """
                }
            }
        }
    }
    /*
    Actions exécutées à la fin du pipeline
    */
    post {
        success {
            echo """
            =========================
            PIPELINE SUCCESS
            Application deployed on http://localhost:8082
            =========================
            """
        }
        failure {
            echo """
            =========================
            PIPELINE FAILED
            Please check logs above
            =========================
            """
        }
    }
}
