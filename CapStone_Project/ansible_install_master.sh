sudo apt-get update -y
sudo apt-get install software-properties-common -y
sudo apt-add-repository --yes ppa:ansible/ansible 
sudo apt update -y
sudo apt install ansible -y
ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa <<< y
