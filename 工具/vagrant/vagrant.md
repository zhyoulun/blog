- 创建一个新的空目录
- 在空目录中执行`vagrant init ubuntu/xenial64 https://vagrantcloud.com/ubuntu/xenial64`，将会创建一个Vagrantfile
- 执行`vagrant validate`文件内容是否是正确的
- 启动vagrant机器，`vagrant up`
- 进入机器`vagrant ssh`


```Vagrantfile
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.box_url = "https://vagrantcloud.com/ubuntu/xenial64"
  config.vm.provider "virtualbox" do |v|
    v.gui = true
  end
end
```

### 问题记录

```
There was an error while executing `VBoxManage`, a CLI used by Vagrant
for controlling VirtualBox. The command and stderr is shown below.

Command: ["startvm", "8542f243-920d-4677-9f1a-2fb1c7cb9005", "--type", "headless"]

Stderr: VBoxManage: error: The virtual machine 'test2_default_1636804654822_80764' has terminated unexpectedly during startup because of signal 10
VBoxManage: error: Details: code NS_ERROR_FAILURE (0x80004005), component MachineWrap, interface IMachine
```

我这里的原因是`--type headless`有问题，原因未知，通过在配置文件中增加如下内容可以绕过

```vagrantfile
  config.vm.provider "virtualbox" do |v|
    v.gui = true
  end
```