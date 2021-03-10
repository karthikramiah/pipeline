pipeline {
    agent any
    
    stages {
        stage('Git Checkout') {
            agent any
            steps {
              dir('build') {
                sshagent(credentials:['git']) {
                    sh("""
                       git checkout master
                       git pull
                       commitid=\$(git log -1 | head -1 | awk '{print \$2}')
                       files=\$(git show --pretty="" --name-only \${commitid})
                       curdate=\$(date +"%m%d%Y%H%M")
                       tag="Build_${currentBuild.number}_\${curdate}"
                       echo \$tag
                       git config --global user.email "dev@dev-VirtualBox"
                       git config --global user.name "dev"
                       git tag -a \$tag \$commitid -m "\$tag"
                       git push --tags
                     """)
                }
            }
          }
        }
        stage('Approval') {
            agent none
            steps {
                mail to: 'karthikramiah@outlook.com',
                    subject: "Job $JOB_NAME is waiting for your approval",
                    body: """Build ${currentBuild.number} is waiting for your approval.Go to $BUILD_URL and approve"""
                timeout(time: 1, unit: 'DAYS'){
                   input('Proceed to next Step?')
                }
            }
        }
    }
}
