# Home
Repo for organizing my home infrastructure

## Network Diagram
![Home Network Diagram](./static/network.png)

I had to run the follow in terraform to enable managing the built in switch
```console
terraform import unifi_device.udm
```
