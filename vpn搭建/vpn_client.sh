# --------------------------------------------------------
# centos安装vpn客户端步骤
# --------------------------------------------------------


# 创建 VPN 变量 （替换为你自己的值）
export VPN_SERVER_IP='服务端ip'
export VPN_IPSEC_PSK='共享秘钥'
export VPN_USER='账号'
export VPN_PASSWORD='密码'

#配置 strongSwan：

cat > /etc/ipsec.conf <<EOF
# ipsec.conf - strongSwan IPsec configuration file

# basic configuration

config setup
  # strictcrlpolicy=yes
  # uniqueids = no

# Add connections here.

# Sample VPN connections

conn %default
  ikelifetime=60m
  keylife=20m
  rekeymargin=3m
  keyingtries=1
  keyexchange=ikev1
  authby=secret
  ike=aes256-sha1-modp2048,aes128-sha1-modp2048!
  esp=aes256-sha1-modp2048,aes128-sha1-modp2048!

conn myvpn
  keyexchange=ikev1
  left=%defaultroute
  auto=add
  authby=secret
  type=transport
  leftprotoport=17/1701
  rightprotoport=17/1701
  right=$VPN_SERVER_IP
EOF

cat > /etc/ipsec.secrets <<EOF
: PSK "$VPN_IPSEC_PSK"
EOF

chmod 600 /etc/ipsec.secrets

# For CentOS/RHEL & Fedora ONLY
mv /etc/strongswan/ipsec.conf /etc/strongswan/ipsec.conf.old 2>/dev/null
mv /etc/strongswan/ipsec.secrets /etc/strongswan/ipsec.secrets.old 2>/dev/null
ln -s /etc/ipsec.conf /etc/strongswan/ipsec.conf
ln -s /etc/ipsec.secrets /etc/strongswan/ipsec.secrets

#配置 xl2tpd：

cat > /etc/xl2tpd/xl2tpd.conf <<EOF
[lac myvpn]
lns = $VPN_SERVER_IP
ppp debug = yes
pppoptfile = /etc/ppp/options.l2tpd.client
length bit = yes
EOF

cat > /etc/ppp/options.l2tpd.client <<EOF
ipcp-accept-local
ipcp-accept-remote
refuse-eap
require-chap
noccp
noauth
mtu 1280
mru 1280
noipdefault
defaultroute
usepeerdns
connect-delay 5000
name $VPN_USER
password $VPN_PASSWORD
EOF

chmod 600 /etc/ppp/options.l2tpd.client



#至此 VPN 客户端配置已完成。按照下面的步骤进行连接。

#注： 当你每次尝试连接到 VPN 时，必须重复下面的所有步骤。

#创建 xl2tpd 控制文件：

mkdir -p /var/run/xl2tpd
touch /var/run/xl2tpd/l2tp-control

#重启服务：
service strongswan restart
service xl2tpd restart


#开始 L2TP 连接：
echo "c myvpn" > /var/run/xl2tpd/l2tp-control

#配置路由，注gw未ifconfig中ppp0的网关
route add -net 172.16.102.24 netmask 255.255.255.255 gw 172.16.254.1


#断开 L2TP 连接：
echo "d myvpn" > /var/run/xl2tpd/l2tp-control