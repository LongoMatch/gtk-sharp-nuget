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
                            nugetextension: "nupkg",
                            buildcommand: "make",
                            postarguments: "",
                            nugetname: "Fluendo.GTK",
                            nugetnameOS: "Fluendo.GTK.osx"
                        ],
                        [
                            jenkins_node: "minimac-longomatch-windows",
                            system: "Windows",
                            root: "../../..",
                            packagedir: "/package/",
                            nugetextension: "nupkg",
                            buildcommand: "",
                            nugetname: "Fluendo.GTK",
                            nugetnameOS: "Fluendo.GTK.win7-x86_64"
                        ]
                    ]

                    for (arch in archlist) {
                        def pkgdir = arch.packagedir
                        def buildcmd = arch.buildcommand
                        String buildarch = arch.system.trim()
                        String strnode = arch.jenkins_node.trim()
                        String strroot = arch.root.trim()
                        String pkgext = arch.nugetextension.trim()
                        String pkgname = arch.nugetname.trim()
                        String pkgnameOS = arch.nugetnameOS.trim()

                        builds["${buildarch}"] = {
                            node (strnode) {
                                catchError(buildResult: 'FAILURE', stageResult: 'FAILURE', message: "Fails in ${buildarch} pipeline") {
                                    stage("Build ${buildarch}") {
                                        
                                        def preargs = ""
                                        checkout scm

                                        sh script: "git submodule init && git submodule sync && git submodule update", label: "Update submodule"

                                        switch(buildarch) {
                                            case "macOS":
                                                sh script: "make build", label: "Mac Build"
                                                break
                                            case "Windows":
                                                sh script: "python cerbero-gtk-sharp-nuget bootstrap -y", label: "Bootstrap"
                                                sh script: "python cerbero-gtk-sharp-nuget package fluendo-gtk", label: "Package"
                                                break
                                            default:
                                                break
                                        }
                                    }

                                    stage("Upload ${buildarch} package") {
                                        
                                        def filedestin = "${env.WORKSPACE}/filelist.txt"

                                        if (buildarch == "Windows"){
                                            filedestin = sh(script:"pwd", returnStdout: true).trim() + "/filelist.txt"
                                        }

                                        // deploy of package to officestorage and nuget server
                                        //-----------------------------------------------------
                                        deployCDpackage(filedestin, pkgname, pkgnameOS, pkgext, buildarch)
                                        //-----------------------------------------------------

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
                slackSend botUser: true, channel: '#buildbot-vas', color: 'danger',
                message: "Failure: job ${env.JOB_NAME} \n More info at: ${env.BUILD_URL}",
                baseUrl: 'https://fluendo.slack.com/services/hooks/jenkins-ci/',
                teamDomain: 'fluendo',
                tokenCredentialId: 'ad868fe8-119c-4083-9bb4-2e4f668ce4fe'
            }
        }
        always {
            script {
                    jiraSendBuildInfo branch: env.BRANCH_NAME, site: 'fluendo.atlassian.net'
            }
        }
        aborted {
            script {
                echo "aborted"
            }
        }
    }
}

def deployCDpackage(filedestin, pkgname, pkgnameOS, pkgext, buildarch)
{
    def nugetpackageversion = ""
    def majordp
    def minordp
    def revisiondp
    def builddp
    def matchversion_up = false
    def command_up = "ls *.nupkg > ${filedestin}"
    
    // looking for the number of version generated via regex
    sh command_up
    def result_up

    if (buildarch == "Windows"){
        result_up = readFile("filelist.txt").trim()
    }else
    {
        result_up = readFile(filedestin).trim()
    }
    
    def version_up = result_up.split("\n")[0]

    def parser_up = /^.*.?(?<majordp>\d+)\.(?<minordp>\d+)\.(?<revisiondp>\d+)\.(?<builddp>\d+).*$/
    def match_up = (version_up =~ parser_up)

    if (match_up.matches()) {
        (majordp, minordp, revisiondp, builddp) = ['majordp', 'minordp', 'revisiondp', 'builddp'].collect { match_up.group(it) }
        match_up = null
        matchversion_up=true
    }

    echo "Version == " + majordp + "." + minordp + "." + revisiondp + "." + builddp
    match_up = null

    if (matchversion_up) {
        
        echo "UPLOAD NUGET TO REPOSITORY"
        nugetpackageversion = "${majordp}.${minordp}.${revisiondp}.${builddp}"

        // delete the packages with the same version and reupload the new ones instead
        deletenuget(pkgname, pkgnameOS,nugetpackageversion, buildarch)
        
        // push nuget
        if (buildarch == "macOS"){
            sh " nuget push -source ${NUGET_SERVER} -ApiKey ${NUGET_KEY} ${pkgname}.${nugetpackageversion}.${pkgext}"
        }
        sh " nuget push -source ${NUGET_SERVER} -ApiKey ${NUGET_KEY} ${pkgnameOS}.${nugetpackageversion}.${pkgext}"
       
    }
}

def deletenuget(nugetpackage, nugetpackageOS, nugetpackageversion, buildarch)
{
    try {
        echo "Removing old Nuget packages with version {${nugetpackageversion}}"
        if (buildarch == "macOS"){
            sh "nuget delete ${nugetpackage} ${nugetpackageversion} -source ${NUGET_SERVER} -ApiKey ${NUGET_KEY} -NonInteractive"
        }
    } catch (Exception e) {
        e.message
    }
    try {
        sh "nuget delete ${nugetpackageOS} ${nugetpackageversion} -source ${NUGET_SERVER} -ApiKey ${NUGET_KEY} -NonInteractive"
    } catch (Exception e) {
        e.message
    }
}

def cleanWorkspace()
{
    // clean workspace
    sleep(5) // files may still be in use
    echo "CLEAN WORKSPACE"
    deleteDir()
}
