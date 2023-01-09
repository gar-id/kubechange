# Kubechange

Simple bash script for change kubectl config

### MacOS installation :
- Adjust line 39-40 in kubechange.sh with your configuration
- Copy kubechange.sh to some directory (for example : /opt) :  
`sudo cp -R kubechange.sh /opt/kubechange.sh`
- Create alias to .zshrc file :  
`echo 'alias kubechange="bash /opt/kubechange.sh"' >> $HOME/.zshrc`
- Reload .zshrc file :  
`source $HOME/.zshrc`

### Usage :
After installation, you can change kube config with `kubechange` command. There is 2 option : 
- Type `kubechange` and choose your kube context file
- Type `kubechange edit` to edit your current kube context
- Type `kubechange contextfile` will let this script automatically change config if file available  
Example :
`kubechange k3s-node1`

### Notes :
- Starting from Catalina, Apple change default MacOS shell to zsh
- If you have kube config file named with only 1 character, please rename it to at least 2 characters
