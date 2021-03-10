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
                       git tag -a \$tag \$commitid -m "\$tag"
                       git push --tags
                     """)
                }
            }
          }
        }
    }
}
