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
                       echo \$files
                    """)
                }
            }
          }
        }
    }
}
