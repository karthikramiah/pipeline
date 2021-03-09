pipeline {
    agent any
    
    stages {
        stage('Git Checkout') {
            dir('build') {
                sshagent(credentials:['dev']) {
                    sh("""
                       git checkout master
                       commitid=\$(git log -1 | head -1 | awk '{print \$2}')
                       files=\$(git show --pretty="" --no-commit-id --name-only \$commitid)
                       echo \$files
                    """)
                }
            }
        }
    }
}
