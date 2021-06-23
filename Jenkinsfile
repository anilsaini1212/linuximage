pipeline {
agent {
        kubernetes {
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: test-odu
spec:
  securityContext:
    runAsUser: 10000
    runAsGroup: 10000
  containers:
  - name: jnlp
    image: 'jenkins/jnlp-slave:4.3-4-alpine'
    args: ['\$(JENKINS_SECRET)', '\$(JENKINS_NAME)']
  - name: checkov
    image: kennethreitz/pipenv:latest
    command:
    - cat
    tty: true
    securityContext: # https://github.com/GoogleContainerTools/kaniko/issues/681
      runAsUser: 0
      runAsGroup: 0
  - name: terraform-cli
    image: gsaini05/terraform-az-go:0.15
    command:
    - cat
    tty: true
    securityContext: # https://github.com/GoogleContainerTools/kaniko/issues/681
      runAsUser: 0
      runAsGroup: 0
  volumes:
  - name: regsecret
    projected:
      sources:
      - secret:
          name: regsecret
          items:
            - key: .dockerconfigjson
              path: config.json
  imagePullSecrets:
  - name: oduregsecret
  - name: regsecret
"""
        }
    }
   
    stages {
       stage('Checkov: Analyzing static codes for IaC') {
          steps {
            container('checkov') {
            
            script {
              sh "echo sucess"
 
              }
          }
      }      
     }
      stage('TF Init & Unit Test') {
        steps {
          container('terraform-cli') {
          withCredentials([azureServicePrincipal('credentials_id')]) {
          sh """ 
         
        }      
      }
      }
      }
      stage('TF Plan') {
        steps {
           container('terraform-cli') {
           sh """
           export PATH=$PATH:/usr/local/go/bin
           terraform plan
           """
        }      
      }
     }
      stage('Terratest: Deploy, Validate & Undeploy') {
        steps {
           container('terraform-cli') {
           withCredentials([azureServicePrincipal('credentials_id')]) {
           sh """
           az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID
           cd tests
           export PATH=$PATH:/usr/local/go/bin
           export ARM_SUBSCRIPTION_ID="${AZURE_SUBSCRIPTION_ID}"
           go test -tags azure . -v
           """
        }      
      } 
     }
      } 
      stage('Approval: Confirm/Abort') {
        steps {
          script {
            def userInput = input(id: 'confirm', message: 'Apply Terraform?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Apply terraform', name: 'confirm'] ])
          }
        }
      }

      stage('Provision Infra in MS Azure Cloud') {
        steps {
          container('terraform-cli') {
           sh """
           terraform apply -auto-approve
           """
        }
      }
    }
      stage('Show: Provisioned Infra Details') {
        steps {
          container('terraform-cli') {
           sh """
           terraform show
           """
        }
      }
    } 
  }
}
