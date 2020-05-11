pipeline {
 agent any
 stages {
  stage('checkout') {
    steps {
       git branch: 'master', url: 'https://github.com/raj-2107/raj.git' 
    }
  }
 stage('Provision infrastructure') {
 steps {
 sh "/usr/local/bin/terraform init"
 sh "/usr/local/bin/terraform plan -out=plan"
 sh "/usr/local/bin/terraform apply plan"
 sh "/usr/local/bin/terraform destroy -y"
}
}
}
}
