#include <arpa/inet.h>
#include <linux/if_packet.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <termios.h>
#include <net/if.h>
#include <netinet/ether.h>
#include <unistd.h>

#include "sender.h"

struct ifreq get_interface_index(char *if_name) {
	struct ifreq if_idx;
	memset(&if_idx, 0, sizeof(struct ifreq));
	strncpy(if_idx.ifr_name, if_name, IFNAMSIZ-1);
	return if_idx;
}

struct ifreq get_interface_mac_address(char *if_name) {
	struct ifreq if_mac;
	memset(&if_mac, 0, sizeof(struct ifreq));
	strncpy(if_mac.ifr_name, if_name, IFNAMSIZ-1);
	return if_mac;
}

int create_raw_socket(struct ifreq if_idx, struct ifreq if_mac) {
	int rawsock;
	
	/* Open RAW socket to send on */
	if((rawsock = socket(AF_PACKET, SOCK_RAW, htons(ETH_P_ALL))) == -1) {
	    printf("Could not create raw socket\n");
	    return -1;
	}
	
	if(ioctl(rawsock, SIOCGIFINDEX, &if_idx) < 0) {
	    printf("Could not set raw socket interface\n");
	    return -1;
	}
	
	/* Get the MAC address of the interface to send on */
	if(ioctl(rawsock, SIOCGIFHWADDR, &if_mac) < 0) {
	    printf("Could not set raw socket source mac\n");
	    return -1;
	}
	
	return rawsock;
}

PACKET create_packet(struct ifreq if_idx, struct ifreq if_mac, unsigned int dst_addr[6]) {
	PACKET new_packet;
	new_packet.len = 0;
	new_packet.eh = (struct ether_header *) new_packet.send_buffer;
	
	/* Construct the Ethernet header */
	memset(new_packet.send_buffer, 0, BUF_SIZE);
	
	/* Ethernet header */
	new_packet.eh->ether_shost[0] = ((uint8_t *)&if_mac.ifr_hwaddr.sa_data)[0];
	new_packet.eh->ether_shost[1] = ((uint8_t *)&if_mac.ifr_hwaddr.sa_data)[1];
	new_packet.eh->ether_shost[2] = ((uint8_t *)&if_mac.ifr_hwaddr.sa_data)[2];
	new_packet.eh->ether_shost[3] = ((uint8_t *)&if_mac.ifr_hwaddr.sa_data)[3];
	new_packet.eh->ether_shost[4] = ((uint8_t *)&if_mac.ifr_hwaddr.sa_data)[4];
	new_packet.eh->ether_shost[5] = ((uint8_t *)&if_mac.ifr_hwaddr.sa_data)[5];
	new_packet.eh->ether_dhost[0] = dst_addr[0];
	new_packet.eh->ether_dhost[1] = dst_addr[1];
	new_packet.eh->ether_dhost[2] = dst_addr[2];
	new_packet.eh->ether_dhost[3] = dst_addr[3];
	new_packet.eh->ether_dhost[4] = dst_addr[4];
	new_packet.eh->ether_dhost[5] = dst_addr[5];
	
	new_packet.eh->ether_type = htons(ETH_P_IP);
	new_packet.len += sizeof(struct ether_header);
 
	/* Packet data 
	 * We just set it to 0xaa you send arbitrary payload you like*/
	int i;
	for(i = 1; i <= 1000; i++) {
		new_packet.send_buffer[new_packet.len++] = 0xaa;
	}
	
	new_packet.iph = (struct iphdr *) (new_packet.send_buffer + sizeof(struct ether_header));
	
	new_packet.socket_address.sll_ifindex = if_idx.ifr_ifindex;
	new_packet.socket_address.sll_family = PF_PACKET;    
	new_packet.socket_address.sll_protocol = htons(ETH_P_IP);  
	new_packet.socket_address.sll_hatype = ARPHRD_ETHER;
	new_packet.socket_address.sll_pkttype  = PACKET_OTHERHOST;
	new_packet.socket_address.sll_halen    = ETH_ALEN;
	new_packet.socket_address.sll_addr[0] = dst_addr[0];
	new_packet.socket_address.sll_addr[1] = dst_addr[1];
	new_packet.socket_address.sll_addr[2] = dst_addr[2];
	new_packet.socket_address.sll_addr[3] = dst_addr[3];
	new_packet.socket_address.sll_addr[4] = dst_addr[4];
	new_packet.socket_address.sll_addr[5] = dst_addr[5];
	
	return new_packet;
}

void send_packet(int rawsock, PACKET packet_to_send, unsigned int quantity) {
    int wait_time = 1000000/quantity;
	for(; quantity > 0; quantity--) {
		if (usleep(wait_time) == -1) {
			printf("sleep failed\n");
		}
		
		if (sendto(rawsock, packet_to_send.send_buffer, packet_to_send.len, 0,
			(struct sockaddr*)&packet_to_send.socket_address,
			sizeof(struct sockaddr_ll)) < 0) 
		{
			printf("Send failed\n");
		}
	}
}