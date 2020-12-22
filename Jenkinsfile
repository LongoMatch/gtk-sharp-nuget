boolean uploadPackage = false
boolean isdevel = false

pipeline {
    agent none

    stages{
        
        stage("Build") {
            steps {
                script {
                    builds = [:]
                    echo "Build for LongoMatch ${env.BRANCH_NAME} branch scheduled"

                    def archlist = [
                        [
                            jenkins_node: "minimac-longomatch-macos",
                            system: "macOS",
                            root: "../..",
                            packagedir: "/package/",
                            packageextension: "pkg",
                            buildcommand: "make",
                            postarguments: ""
                        ],
                        [
                            jenkins_node: "minimac-longomatch-windows",
                            system: "Windows",
                            root: "../../..",
                            packagedir: "/package/",
                            packageextension: "exe",
                            buildcommand: "",
                        ]
                    ]

                    for (arch in archlist) {
                        def pkgdir = arch.packagedir
                        def buildcmd = arch.buildcommand
                        String buildarch = arch.system.trim()
                        String strnode = arch.jenkins_node.trim()
                        String strroot = arch.root.trim()
                        String pkgext = arch.packageextension.trim()

                        builds["${buildarch}"] = {
                            node (strnode) {
                                catchError(buildResult: 'FAILURE', stageResult: 'FAILURE', message: "Fails in ${buildarch} pipeline") {
                                    stage("Build ${buildarch}") {
                                        checkout scm
                                        sh script: "git init && git submodule update", label: "Update submodule"
                                        sh script: "./cerbero-gtk-sharp-nuget bootstrap", label: "Bootstrap"
                                        sh script: "./cerbero-gtk-sharp-nuget package fluendo-gtk", label: "Package"
                                    }

                                }
                                cleanWorkspace()
                            }
                        }
                    }
                    parallel builds
                }
            }
        }
    }

    post {
        success {
            script {
                echo "success"
                if (uploadPackage) {
                    slackSend botUser: true, channel: '#buildbot-vas', color: 'good',
                    message: "Success: job ${env.JOB_NAME} \n More info at: ${env.BUILD_URL}",
                    baseUrl: 'https://fluendo.slack.com/services/hooks/jenkins-ci/',
                    teamDomain: 'fluendo',
                    tokenCredentialId: 'ad868fe8-119c-4083-9bb4-2e4f668ce4fe'
                }
            }
        }
        failure {
            script {
                echo "failure"
                if (uploadPackage) {
                    slackSend botUser: true, channel: '#buildbot-vas', color: 'danger',
                    message: "Failure: job ${env.JOB_NAME} \n More info at: ${env.BUILD_URL}",
                    baseUrl: 'https://fluendo.slack.com/services/hooks/jenkins-ci/',
                    teamDomain: 'fluendo',
                    tokenCredentialId: 'ad868fe8-119c-4083-9bb4-2e4f668ce4fe'
                }
            }
        }
        always {
            script {
                if (!uploadPackage) {
                    jiraSendBuildInfo branch: env.BRANCH_NAME, site: 'fluendo.atlassian.net'
                }
            }
        }
        aborted {
            script {
                echo "aborted"
            }
        }
    }
}

def getPackageVersion()
{
    return sh(script: "src/build/git-version-gen src/Version.txt", returnStdout: true, label: "Get version").trim()
}

def uploadPackages(packagedir, filename, fileextension)
{
    currentlocation = sh(script: "pwd", returnStdout: true).trim()
    majordp = packageVersion.split("\\.")[0]
    minordp = packageVersion.split("\\.")[1]
    revisiondp = packageVersion.split("\\.")[2]
    ftpfolder = URL_DEVEL_FTP

    if (env.BRANCH_NAME == 'longomatch-release') {
        ftpfolder = URL_RELEASE_FTP
        sh script:"curl -T ${currentlocation}${packagedir}/${filename}.${fileextension}.dsa ${URL_BASE_FTP}/${ftpfolder}/${majordp}.${minordp}.${revisiondp}/ --ftp-create-dirs --user ${FLU_USERNAME}:\"${FTP_PRE} ${FTP_SUF}\"", label: "Upload"
    }

    sh script: "curl -T ${currentlocation}${packagedir}/${filename}.${fileextension} ${URL_BASE_FTP}/${ftpfolder}/${majordp}.${minordp}.${revisiondp}/ --ftp-create-dirs --user ${FLU_USERNAME}:\"${FTP_PRE} ${FTP_SUF}\"", label: "Upload"
}

def cleanWorkspace()
{
    // clean workspace
    sleep(5) // files may still be in use
    echo "CLEAN WORKSPACE"
    deleteDir()
}
