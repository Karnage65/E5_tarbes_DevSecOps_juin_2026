pipeline {

    agent any


    /*
    Déclaration des paramètres.
    Ils apparaîtront dans Jenkins avec l'option :
    "Build with Parameters"
    */

    parameters {

        string(
            name: 'NAME',
            defaultValue: 'DevOps User',
            description: 'Please tell me your name'
        )


        text(
            name: 'DESC',
            defaultValue: 'Pipeline CI/CD Jenkins GitHub',
            description: 'Description du Job'
        )


        booleanParam(
            name: 'SKIP_TEST',
            defaultValue: false,
            description: 'Skip running Tests ?'
        )


        choice(
            name: 'BRANCH',
            choices: [
                'main',
                'dev',
                'test'
            ],
            description: 'Choose Git branch'
        )


        password(
            name: 'SONAR_SERVER_PWD',
            description: 'Enter SONAR password'
        )

    }


    environment {

        APP_NAME = "web-app"

        DOCKER_IMAGE = "mydockerhub/web-app"

        SONAR_URL = "http://localhost:9000"

    }



    stages {



        /*
        Affichage des paramètres envoyés
        par l'utilisateur
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





        /*
        Récupération du projet depuis Github
        */


        stage('02 - CHECKOUT GITHUB') {


            steps {


                echo "Downloading source code..."


                git branch: "${params.BRANCH}",
                url: 'https://github.com/user/demo-app.git'


            }

        }





        /*
        Compilation de l'application
        */


        stage('03 - BUILD APPLICATION') {


            steps {


                echo "Building Application"


                sh """
                echo Compilation en cours...

                mvn clean package

                """


            }

        }





        /*
        Tests unitaires
        Le stage sera ignoré si SKIP_TEST=true
        */


        stage('04 - RUN TESTS') {


            when {

                expression {

                    return params.SKIP_TEST == false

                }

            }



            steps {


                echo "Running Tests"


                sh """

                mvn test

                """


            }


        }






        /*
        Analyse qualité SonarQube
        */


        stage('05 - SONARQUBE ANALYSIS') {


            steps {


                echo "Scanning source code"


                sh """

                mvn sonar:sonar \\
                -Dsonar.host.url=${SONAR_URL} \\
                -Dsonar.login=${params.SONAR_SERVER_PWD}


                """


            }

        }







        /*
        Création image Docker
        */


        stage('06 - DOCKER BUILD') {


            steps {


                echo "Creating Docker image"


                sh """

                docker build -t ${DOCKER_IMAGE}:latest .

                """

            }


        }






        /*
        Déploiement
        */


        stage('07 - DEPLOY') {


            steps {


                echo "Deploying Application"


                sh """

                docker stop ${APP_NAME} || true

                docker rm ${APP_NAME} || true


                docker run -d \
                --name ${APP_NAME} \
                -p 8080:8080 \
                ${DOCKER_IMAGE}:latest


                """


            }


        }


    }





    /*
    Actions exécutées à la fin
    */

    post {


        success {


            echo """

            =========================

            PIPELINE SUCCESS

            Application deployed

            =========================

            """

        }



        failure {


            echo """

            =========================

            PIPELINE FAILED

            Please check logs

            =========================

            """

        }


    }


}
