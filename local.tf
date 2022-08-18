locals {
  user_data = <<EOF
#!/bin/bash
sudo apt-get update -y 
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install openjdk-11-jre -y 
sudo apt install default-jdk -y 
sudo apt-get update -y 
sudo apt-get install jenkins -y 
sudo systemctl start jenkins
sudo systemctl enable jenkins


 EOF

  user_data_node = <<EOF
#!/bin/bash
sudo apt-get update -y 
sudo apt install default-jdk -y 

EOF
}