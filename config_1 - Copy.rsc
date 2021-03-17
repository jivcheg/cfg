
/interface bridge
add name=bridge-lan
/interface wireless
set [ find default-name=wlan1 ] ssid=MikroTik
/interface ethernet
set [ find default-name=ether1 ] comment="to ISP1"
set [ find default-name=ether2 ] comment="to ISP2"
set [ find default-name=ether3 ] comment="to LAN1"
set [ find default-name=ether4 ] comment="to LAN2"
/interface list
add comment="For Internet" name=WAN
add comment="For Local Area" name=LAN
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip pool
add name=dhcp_pool2 ranges=192.168.88.2-192.168.88.254
/ip dhcp-server
add address-pool=dhcp_pool2 disabled=no interface=bridge-lan name=dhcp1
/ppp profile
add comment="for PPPoE to ISP2" interface-list=WAN name=isp2_client on-down="/\
    ip route remove [ find gateway=\"4.2.2.3\" ]\r\
    \n/ip route remove [ find where dst-address ~\"4.2.2.3\" ]\r\
    \n/ip firewall nat remove  [find comment=\"NAT via ISP2\"]\r\
    \n/ip route rule remove [find comment=\"From ISP2 IP to Inet\"]" on-up="/i\
    p route remove [ find gateway=\"4.2.2.3\" ]; /ip route remove [ find where\
    \_dst-address ~\"4.2.2.3\" ]\r\
    \n/ip route add check-gateway=ping comment=\"For recursion via ISP2\" dist\
    ance=1 dst-address=4.2.2.3/32 gateway=\$\"remote-address\" scope=10\r\
    \n/ip route add check-gateway=ping comment=\"Unmarked via ISP2\" distance=\
    3 gateway=4.2.2.3\r\
    \n/ip route add comment=\"Marked via ISP1 Main\" distance=1 gateway=4.2.2.\
    3 routing-mark=to_isp2\r\
    \n/ip route add comment=\"Marked via ISP2 Backup\" distance=3 gateway=4.2.\
    2.3 routing-mark=to_isp1\r\
    \n/ip firewall mangle set [find comment=\"Connmark in from ISP2\"] in-inte\
    rface=\$\"interface\"\r\
    \n/ip firewall nat add action=src-nat chain=srcnat ipsec-policy=out,none o\
    ut-interface=\$\"interface\" to-addresses=\$\"local-address\" comment=\"NA\
    T via ISP2\"\r\
    \n/ip route rule add comment=\"From ISP2 IP to Inet\" src-address=\$\"loca\
    l-address\" table=to_isp2 "
/interface pppoe-client
add allow=mschap2 comment="to ISP2" disabled=no interface=ether2 name=\
    pppoe-isp2 password=12347890 profile=isp2_client user=m1514092
/interface bridge port
add bridge=bridge-lan interface=ether3 trusted=yes
/ip neighbor discovery-settings
set discover-interface-list=!WAN
/interface list member
add comment=ISP1 interface=ether1 list=WAN
add comment="to ISP2" interface=ether2 list=WAN
add comment="Bridge LAN ETH3-4" interface=bridge-lan list=LAN
/ip address
add address=192.168.88.254/24 comment="LAN1 IP" interface=bridge-lan network=\
    192.168.88.0
/ip dhcp-client
add add-default-route=no disabled=no interface=ether1 script=":if (\$bound=1) \
    do={\r\
    \n   /ip route remove [ find gateway=\"4.2.2.2\" ]; /ip route remove [ fin\
    d where dst-address ~\"4.2.2.2\" ]\r\
    \n   /ip route add check-gateway=ping comment=\"For recursion via ISP1\" d\
    istance=1 dst-address=4.2.2.2/32 gateway=\$\"gateway-address\" scope=10\r\
    \n   /ip route add check-gateway=ping comment=\"Unmarked via ISP1\" distan\
    ce=1 gateway=4.2.2.2\r\
    \n   /ip route add comment=\"Marked via ISP1 Main\" distance=1 gateway=4.2\
    .2.2 routing-mark=to_isp2\r\
    \n   /ip route add comment=\"Marked via ISP2 Backup\" distance=2 gateway=4\
    .2.2.2 routing-mark=to_isp2\r\
    \n   /ip firewall nat add action=src-nat chain=srcnat ipsec-policy=out,non\
    e out-interface=\$\"interface\" to-addresses=\$\"lease-address\" comment=\
    \"NAT via ISP1\"\r\
    \n   /ip route rule add comment=\"From ISP1 IP to Inet\" src-address=\$\"l\
    ease-address\" table=to_isp1 \r\
    \n} else={\r\
    \n   /ip route remove [ find gateway=\"4.2.2.2\" ]; /ip route remove [ fin\
    d where dst-address ~\"4.2.2.2\" ]\r\
    \n   /ip firewall nat remove  [find comment=\"NAT via ISP1\"]\r\
    \n   /ip route rule remove [find comment=\"From ISP1 IP to Inet\"]\r\
    \n}\r\
    \n" use-peer-dns=no use-peer-ntp=no
/ip dhcp-server network
add address=192.168.88.0/24 gateway=192.168.88.1
/ip dns
set servers=1.1.1.1,8.8.8.8
/ip firewall address-list
add address=0.0.0.0/8 comment="\"This\" Network" list=BOGONS
add address=10.0.0.0/8 comment="Private-Use Networks" list=BOGONS
add address=100.64.0.0/10 comment="Shared Address Space. RFC 6598" list=\
    BOGONS
add address=127.0.0.0/8 comment=Loopback list=BOGONS
add address=169.254.0.0/16 comment="Link Local" list=BOGONS
add address=172.16.0.0/12 comment="Private-Use Networks" list=BOGONS
add address=192.0.0.0/24 comment="IETF Protocol Assignments" list=BOGONS
add address=192.0.2.0/24 comment=TEST-NET-1 list=BOGONS
add address=192.168.0.0/16 comment="Private-Use Networks" list=BOGONS
add address=198.18.0.0/15 comment=\
    "Network Interconnect Device Benchmark Testing" list=BOGONS
add address=198.51.100.0/24 comment=TEST-NET-2 list=BOGONS
add address=203.0.113.0/24 comment=TEST-NET-3 list=BOGONS
add address=224.0.0.0/4 comment=Multicast list=BOGONS
add address=192.88.99.0/24 comment="6to4 Relay Anycast" list=BOGONS
add address=240.0.0.0/4 comment="Reserved for Future Use" list=BOGONS
add address=255.255.255.255 comment="Limited Broadcast" list=BOGONS
/ip firewall filter
add action=accept chain=input comment="Related Established Untracked Allow" \
    connection-state=established,related,untracked
add action=accept chain=input comment="ICMP from ALL" protocol=icmp
add action=drop chain=input comment="All other WAN Drop" in-interface-list=\
    WAN
add action=accept chain=forward comment=\
    "Established, Related, Untracked allow" connection-state=\
    established,related,untracked
add action=drop chain=forward comment="Invalid drop" connection-state=invalid
/ip firewall mangle
add action=mark-connection chain=prerouting comment="Connmark in from ISP1" \
    connection-mark=no-mark in-interface=ether1 new-connection-mark=conn_isp1 \
    passthrough=no
add action=mark-connection chain=prerouting comment="Connmark in from ISP2" \
    connection-mark=no-mark in-interface=pppoe-isp2 new-connection-mark=\
    conn_isp2 passthrough=no
add action=mark-routing chain=prerouting comment=\
    "Routemark transit out via ISP1" connection-mark=conn_isp1 \
    dst-address-type=!local in-interface-list=!WAN new-routing-mark=to_isp1 \
    passthrough=no
add action=mark-routing chain=prerouting comment=\
    "Routemark transit out via ISP2" connection-mark=conn_isp2 \
    dst-address-type=!local in-interface-list=!WAN new-routing-mark=to_isp2 \
    passthrough=no
add action=mark-routing chain=output comment="Routemark local out via ISP1" \
    connection-mark=conn_isp1 dst-address-type=!local new-routing-mark=\
    to_isp1 passthrough=no
add action=mark-routing chain=output comment="Routemark local out via ISP2" \
    connection-mark=conn_isp2 dst-address-type=!local new-routing-mark=\
    to_isp2 passthrough=no
add action=mark-routing chain=prerouting comment="Address List via ISP1" \
    dst-address-list=!BOGONS new-routing-mark=to_isp1 passthrough=no \
    src-address-list=Via_ISP1
add action=mark-routing chain=prerouting comment="Address List via ISP2" \
    dst-address-list=!BOGONS new-routing-mark=to_isp2 passthrough=no \
    src-address-list=Via_ISP2
/ip firewall nat
add action=src-nat chain=srcnat comment="NAT via ISP1" ipsec-policy=out,none \
    out-interface=ether1 to-addresses=192.168.1.177
add action=src-nat chain=srcnat comment="NAT via ISP2" ipsec-policy=out,none \
    out-interface=pppoe-isp2 to-addresses=95.47.122.70
/ip route
add comment="Marked via ISP2 Backup" distance=3 gateway=4.2.2.3 routing-mark=\
    to_isp1
add comment="Marked via ISP1 Main" distance=1 gateway=4.2.2.2 routing-mark=\
    to_isp2
add comment="Marked via ISP1 Main" distance=1 gateway=4.2.2.3 routing-mark=\
    to_isp2
add comment="Marked via ISP2 Backup" distance=2 gateway=4.2.2.2 routing-mark=\
    to_isp2
add check-gateway=ping comment="Unmarked via ISP1" distance=1 gateway=4.2.2.2
add check-gateway=ping comment="Unmarked via ISP2" distance=3 gateway=4.2.2.3
add check-gateway=ping comment="For recursion via ISP1" distance=1 \
    dst-address=4.2.2.2/32 gateway=192.168.1.1 scope=10
add check-gateway=ping comment="For recursion via ISP2" distance=1 \
    dst-address=4.2.2.3/32 gateway=146.120.244.9 scope=10
/ip route rule
add comment="to LAN1" dst-address=192.168.88.0/24 table=main
add comment="From ISP1 IP to Inet" src-address=192.168.1.177/32 table=to_isp1
add comment="From ISP2 IP to Inet" src-address=95.47.122.70/32 table=to_isp2
/system clock
set time-zone-name=Europe/Kiev
/system ntp client
set enabled=yes server-dns-names=0.pool.ntp.org,1.pool.ntp.org,2.pool.ntp.org
/tool mac-server
set allowed-interface-list=LAN
/tool mac-server mac-winbox
set allowed-interface-list=LAN
