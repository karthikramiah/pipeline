pipeline {
    agent any
    
    stages {
        stage('Git Checkout') {
            agent any
            steps {
              dir('.') {
                sshagent(credentials:['git']) {
                    sh("""
                       git checkout master
                       git pull
                       curdate=\$(date +"%m%d%Y%H%M")
                       tag="Build_${currentBuild.number}_\${curdate}"
                       echo \$tag
                       git checkout -b \$tag
                       files=\$(git diff --name-only HEAD^)
                       mkdir -p tmp
                       for i in \$files
                       do
                         cp \$i tmp/.
                       done
                       ls | grep -v tmp | xargs rm -rf
                       cp tmp/* .
                       rm -rf tmp
                       git config --global user.email "dev@dev-VirtualBox"
                       git config --global user.name "dev"
                       git add .
                       git commit -m "\$tag"
                       git push origin \$tag                       
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
