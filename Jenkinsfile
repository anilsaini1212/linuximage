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
  - name: packer-cli
    image: hashicorp/packer
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
       stage('Packer validate') {
          steps {
            container('packer-cli') {
            script {
              withCredentials([azureServicePrincipal('credentials_id')]) {
              sh """
              sed -i '5 i client_id="$AZURE_CLIENT_ID"' linux.json
              sed -i '6 i client_secret="$AZURE_CLIENT_SECRET"' linux.json
              sed -i '7 i tenant_id="$AZURE_TENANT_ID"' linux.json
              sed -i '8 i sub_id="$AZURE_SUBSCRIPTION_ID"' linux.json
              cat linux.json
              packer validate linux.json
              packer build linux.json
              """
              }
          }
      }
     }
   }
}
}
