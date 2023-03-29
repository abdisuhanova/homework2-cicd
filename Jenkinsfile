pipeline{

 agent any
 stages {
    stage('installation') {
     steps {
        sh 'sudo apt-get update && sudo apt-get install -y gnupg software-properties-common'
        sh 'wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg'
        sh 'gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint'
        sh 'echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list'
        sh 'sudo apt update'
        sh 'sudo apt-get install terraform'
     }
    }
  
    stage('init') {
    steps {
        sh 'terraform init'
    }
    }
    stage('plan') {
    steps {
        withCredentials([aws(accessKeyVariable:'AWS_ACCESS_KEY_ID', credentialsId: 'aws', secretKeyVarible: 'AWS_SECRET_ACCESS_KEY')]) {
        sh 'terraform plan '
        }
    }
    }
    stage('terraform apply') {
    steps {
        withCredentials([aws(accessKeyVariable:'AWS_ACCESS_KEY_ID', credentialsId: 'aws', secretKeyVarible: 'AWS_SECRET_ACCESS_KEY')]) {
        sh 'terraform apply -auto-approve '
        }
    }
    }
  
    stage('terraform destroy') {
    steps {
        withCredentials([aws(accessKeyVariable:'AWS_ACCESS_KEY_ID', credentialsId: 'aws', secretKeyVarible: 'AWS_SECRET_ACCESS_KEY')]) {
        sh 'terraform destroy -auto-approve '
        }
    }
    }
 }
}
