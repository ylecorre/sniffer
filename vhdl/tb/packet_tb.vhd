--------------------------------------------------------------------------------
--
-- packet_pkg testbench
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

use std.textio.all;

use work.packet_pkg.all;
use work.pcap_pkg.all;


entity packet_tb is
end packet_tb;


architecture bench of packet_tb is

begin

	process
		variable l           : line;
		variable rawPacket   : rawPacketType;
		variable udpPacket   : udpPacketType;
		variable ipPacket    : ip4PacketType;
		variable arpPacket   : arpPacketType;
		variable etherPacket : etherPacketType;
		variable pcapFile    : pcapFileType;
	begin

		rawPacket.create((x"12", x"34"));
		rawPacket.append(x"56");
		write(l, string'("RAW  : "));
		write(l, rawPacket);
		writeline(OUTPUT, l);

		udpPacket.create(56789, 56789);
		udpPacket.encapsulate(rawPacket);
		write(l, string'("UDP  : "));
		write(l, udpPacket);
		writeline(OUTPUT, l);

		ipPacket.create((192, 168, 0, 2), (10, 151, 0, 254));
		ipPacket.encapsulate(udpPacket);
		write(l, string'("IP   : "));
		write(l, ipPacket);
		writeline(OUTPUT, l);

		etherPacket.create((x"ff", x"ff", x"ff", x"ff", x"ff", x"ff"), (x"00", x"10", x"a4", x"7b", x"ea", x"80"));
		etherPacket.encapsulate(ipPacket);
		write(l, string'("ether: "));
		write(l, etherPacket);
		writeline(OUTPUT, l);

		pcapFile.create("test.pcap");
		pcapFile.startFrame;
		for i in 0 to etherPacket.getLength - 1 loop
			pcapFile.push(etherPacket.getByte(i));
		end loop;
		pcapFile.endFrame;

		rawPacket.deallocate;
		udpPacket.deallocate;
		ipPacket.deallocate;
		etherPacket.deallocate;
		pcapFile.close;

		arpPacket.create(
			ARP_REQUEST,
			(x"00", x"10", x"a4", x"7b", x"ea", x"80"),
			(192, 168, 0, 2),
			(x"11", x"22", x"33", x"44", x"55", x"66"),
			(10, 151, 0, 254)
		);
		write(l, string'("ARP   :"));
		write(l, arpPacket);
		writeline(OUTPUT, l);

		etherPacket.create((x"ff", x"ff", x"ff", x"ff", x"ff", x"ff"), (x"00", x"10", x"a4", x"7b", x"ea", x"80"));
		etherPacket.encapsulate(arpPacket);
		write(l, string'("ether: "));
		write(l, etherPacket);
		writeline(OUTPUT, l);

		pcapFile.create("testarp.pcap");
		pcapFile.dump(etherPacket);
		pcapFile.close;

		arpPacket.deallocate;
		etherPacket.deallocate;
		
		wait;
	end process;

end bench;
