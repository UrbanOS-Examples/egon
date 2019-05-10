library(
    identifier: 'pipeline-lib@4.3.4',
    retriever: modernSCM([$class: 'GitSCMSource',
                          remote: 'https://github.com/SmartColumbusOS/pipeline-lib',
                          credentialsId: 'jenkins-github-user'])
)

properties([
    pipelineTriggers([scos.dailyBuildTrigger('10-12')]), //UTC
])

def image

def doStageIf = scos.&doStageIf
def doStageIfRelease = doStageIf.curry(scos.changeset.isRelease)
def doStageUnlessRelease = doStageIf.curry(!scos.changeset.isRelease)
def doStageIfPromoted = doStageIf.curry(scos.changeset.isMaster)

node('infrastructure') {
    ansiColor('xterm') {
        scos.doCheckoutStage()

        doStageUnlessRelease('Build') {
            withCredentials([string(credentialsId: 'hex-read', variable: 'HEX_TOKEN')]) {
                image = docker.build("scos/egon:${env.GIT_COMMIT_HASH}", '--build-arg HEX_TOKEN=$HEX_TOKEN .')

                sh('''
                    export HOST_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
                    mix local.hex --force
                    mix local.rebar --force
                    mix hex.organization auth smartcolumbus_os --key $HEX_TOKEN
                    mix deps.get
                ''')
            }

        }

        doStageUnlessRelease('Deploy to Dev') {
            scos.withDockerRegistry {
                image.push()
                image.push('latest')
            }

            deployTo('dev')
        }

        doStageIfPromoted('Deploy to Staging') {
            def environment = 'staging'

            deployTo(environment)

            scos.applyAndPushGitHubTag(environment)

            scos.withDockerRegistry {
                image.push(environment)
            }
        }

        doStageIfRelease('Deploy to Production') {
            def releaseTag = env.BRANCH_NAME
            def environment = 'prod'

            deployTo(environment)

            scos.applyAndPushGitHubTag(environment)

            scos.withDockerRegistry {
                image = scos.pullImageFromDockerRegistry("scos/egon", env.GIT_COMMIT_HASH)
                image.push(releaseTag)
                image.push(environment)
            }
        }
    }
}

def deployTo(environment) {
    scos.withEksCredentials(environment) {
        sh("""#!/bin/bash
            set -e
            helm init --client-only
            helm upgrade --install egon \
                ./chart \
                --namespace=default \
                --set image.tag="${env.GIT_COMMIT_HASH}" \
        """.trim())
    }
}
