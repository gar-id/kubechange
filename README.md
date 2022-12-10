# Kubechange

Simple bash script for change kubectl config

### MacOS installation :
Note : starting from Catalina, Apple change default MacOS shell to zsh
- Adjust line 31-32 in kubechange.sh with your configuration
- Copy kubechange.sh to some directory (for example : /opt) :  
`sudo cp -R kubechange.sh /opt/kubechange.sh`
- Create alias to .zshrc file :  
`echo 'alias kubechange="bash /opt/kubechange.sh"' >> $HOME/.zshrc`
- Reload .zshrc file :  
`source $HOME/.zshrc`

### Usage :
After installation, you can change kube config with `kubechange` command. There is 2 option : 
- Type `kubechange` and choose your config file
- Type `kubechange fileconfig` will let this script automatically change config if file available
Example :
`kubectl k3s-node1`
