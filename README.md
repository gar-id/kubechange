# Kubechange

Simple bash script for change kubectl config

### MacOS installation :
- Adjust line 143-144 in kubechange.sh with your configuration
- Copy kubechange.sh to some directory (for example : /opt) :  
`sudo cp -R kubechange.sh /opt/kubechange.sh`
- Create alias to .zshrc file :  
`echo 'alias kubechange="bash /opt/kubechange.sh"' >> $HOME/.zshrc`
- Reload .zshrc file :  
`source $HOME/.zshrc`

### Usage :
After installation, you can change kube config with `kubechange` command. There is 2 option : 
- Type 	kubechange help` to show kubechange usage
- Type `kubechange context` and choose your kube context file
- Type `kubechange edit` to edit your current kube context
- Type `kubechange new filename` to create new kube context
- Type `kubechange context filename` will let this script automatically change config if file available  
- Type `kubechange ns` to change your default kube namespace
- Type `kubechange ns namespacename` will let this script automatically change namespace if available
Example :
`kubechange context k3s-node1`
`kubechange ns prod`
`kubechange edit`

### Notes :
- Starting from Catalina, Apple change default MacOS shell to zsh
- If you have kube config file named with only 1 character, please rename it to at least 2 characters
