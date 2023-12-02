### What is an Internet exchange point?

An Internet exchange point (IXP) is a physical location through which Internet infrastructure companies such as Internet Service Providers (ISPs) and CDNs connect with each other. These locations exist on the “edge” of different networks, and allow network providers to share transit outside their own network. By having a presence inside of an IXP location, companies are able to shorten their path to the transit coming from other participating networks, thereby reducing latency, improving round-trip time, and potentially reducing costs.

### How does an Internet exchange point work?

At its core, an IXP is essentially one or more physical locations containing network switches that route traffic between the different members networks. Via various methods, these networks share the costs of maintaining the physical infrastructure and associated services. Similar to how costs are accrued when shipping cargo through third-party locations such as via the Panama Canal, when traffic is transferred across different networks, sometimes those networks charge money for the delivery. To avoid these costs and other drawbacks associated with sending their traffic across a third-party network, member companies connect with each other via IXP to cut down on costs and reduce latency.

IXPs are large Layer 2 LANs (of the OSI network model) that are built with one or many Ethernet switches interconnected together across one or more physical buildings. An IXP is no different in basic concept to a home network, with the only real difference being scale. IXPs can range from 100s of Megabits/second to many Terabits/second of exchanged traffic. Independent of size, their primary goal is to make sure that many networks’ routers are connected together cleanly and efficiently. In comparison, at home someone would normally only have one router and many computers or mobile devices.

Over the last twenty years, there has been a major expansion in network interconnections, running parallel to the enormous expansion of the global Internet. This expansion includes new data center facilities being developed to house network equipment. Some of those data centers have attracted massive numbers of networks, in no small part due to the thriving Internet exchange points that operate within them.

### Why are Internet exchange points important?

Without IXPs, traffic going from one network to another would potentially rely on an intermediary network to carry the traffic from source to destination. These are called transit providers. In some situations there’s no problem with doing this: it’s how a large portion of international Internet traffic flows, as it’s cost prohibitive to maintain direct connections to each-and-every ISP in the world. However, relying on a backbone ISP to carry local traffic can be adverse to performance, sometimes due to the backbone carrier sending data to another network in a completely different city. This situation can lead to what’s known as tromboning, where in the worst case, traffic from one city destined to another ISP in the same city can travel vast distances to be exchanged and then return again. A CDN with IXP presence has the advantage of optimizing the path through which data flows within it’s network, cutting down on inefficient paths.

![](/static/images/2109/p104.webp)

### BGP, the Internet’s backbone protocol

Networks talk between each other using the BGP (Border Gateway Protocol). This protocol allows networks to cleanly delinerate between their internal requirements and their network-edge configurations. All peering at IXPs uses BGP.

### How do providers share traffic across different networks?

#### Transit

The agreement between a customer and it’s upstream provider. A transit provider provides its customers with full connectivity to the rest of the Internet. Transit is a paid-for service. BGP protocol is used to allow customer IP addresses to be announced towards the transit provider and then onwards towards the rest of the global Internet.



#### Peering

The arrangement behind how networks share IP addresses without an intermediary between them. At Internet exchange points, there is predominantly no cost associated with transferring data between member networks. When traffic is transferred for free from one network to the next, the relationship is called settlement-free peering.



#### Peering vs paid transit

Unfortunately for some networks, transferring data is not always without cost. For example, large networks with relatively equal market share are more likely to peer with other large networks but may charge smaller networks for the peering service. In a single IXP, a member company may have different arrangements with several different members. In instances like this, a company may configure their routing protocols to make sure that they optimize for reduced costs or reduced latency using the BGP protocol.



#### Depeering

Over time relationships can change, and sometimes networks no longer want to share free interconnection. When a network decides end their peering arrangement they go through a process called depeering. Depeering can occur for a variety of reasons such as when one party is benefiting more than the other due to bad traffic ratios, or when a network simply decides to start charging the other party money. This process can be highly emotional, and a spurned network may intentionally disrupt the traffic of the other party once the peering relationship has been terminated.




#### How do IXPs use BGP?

Across an IXP's local network, different providers are able to create one-to-one connections using the BGP protocol. This protocol was created to allow disparate networks to announce their IP addresses to each other plus the IP addresses that they have provided connectivity to downstream (i.e. their customers). Once two networks set up a BGP session, their respective routes are exchanged and traffic can flow directly between them. Cloudflare CDN



#### IXP or PNI interconnection

Two networks may consider their traffic to be important enough that they want to move from the shared infrastructure of an IXP and onto a dedicated interconnection between the two networks. A PNI (Private Network Interconnect) is simply a dark fiber connection (normally within a single datacenter, or building) that directly connects a port on network A with a port on network B. The BGP is nearly identical as a shared IXP peering setup.



## 参考

- [What is an Internet exchange point? | How do IXPs work?](https://www.cloudflare.com/zh-cn/learning/cdn/glossary/internet-exchange-point-ixp/)
- [https://www.peeringdb.com/about](https://www.peeringdb.com/about)
- [http://bgp.he.net/](http://bgp.he.net/)