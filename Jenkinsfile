pipeline {
 agent any
 stages {
  stage('checkout') {
    steps {
       git branch: 'master', url: 'https://github.com/raj-2107/raj.git' 
    }
  }

  stage('credentials') {
    steps {
    withCredentials([string(credentialsId: 'ACCESS_KEY_ID', variable: 'SECRET')]) { //set SECRET with the credential content
        echo "My secret text is '${SECRET}'"
    }

 withCredentials([string(credentialsId: 'SECRET_ACCESS_KEY_ID', variable: 'SECRET')]) { //set SECRET with the credential content
        echo "My secret text is '${SECRET}'"
    }
   }
}


 stage('Provision infrastructure') {
 steps {
 sh "/usr/local/bin/terraform init"
 sh "/usr/local/bin/terraform plan -out=plan"
 sh "/usr/local/bin/terraform apply plan"
 sh "/usr/local/bin/terraform destroy -auto-approve"
}
}
}
}

