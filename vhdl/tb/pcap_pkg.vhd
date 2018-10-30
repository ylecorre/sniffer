--------------------------------------------------------------------------------
--
-- pcap_pkg
--
--------------------------------------------------------------------------------
--
-- Copyright (c) 2014 Yann Le Corre
-- All rights reserved. Commercial License Usage
--
--------------------------------------------------------------------------------
--
-- Created on:Wed 28 May 2014 12:05:56 CEST by user: yann
-- $Author: ylecorre $
-- $Date: 2014-05-28 16:28:25 +0200 (Wed, 28 May 2014) $
-- $Revision: 166 $
--
--------------------------------------------------------------------------------
-- Documentation:
--   Pcap file format support package. Currently only support writing pcap
--   file. Also only supports micro-seconds timestamps.
-- Mode of operation:
--   pcap file is created using function create on a pcapFileType variable (which
--   is actually a pointer). Then ethernet frames are saved using the member
--   functions startFrame, push, and endFrame in this order. The frame is
--   actually written in the pcap file only when endFrame function is executed.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

use std.textio.all;
library netitf_lib;
use netitf_lib.packet_pkg.all;


package pcap_pkg is

	type characterFileType is file of character;

	type pcapFileType is protected

		procedure create(
			fileName        : in  string;
			numberOfFrames  : in  natural := 1
		);

		procedure startFrame(
			frameNumber : in  natural := 0
		);

		procedure endFrame(
			frameNumber : in  natural := 0
		);

		procedure push(
			data        : in  std_logic_vector(7 downto 0);
			frameNumber : in  natural := 0
		);

		procedure push(
			data        : in  integer range 0 to 255;
			frameNumber : in  natural := 0
		);

		procedure close;

		procedure dump(etherPacket : inout etherPacketType);

	end protected pcapFileType;

end pcap_pkg;


package body pcap_pkg is

	type pcapFileType is protected body

		file outputFile : characterFileType;
		type lineVector is array(natural range <>) of line;
		type lineVectorPtrType is access lineVector;

		variable numFrames : natural := 1;
		variable frames    : lineVectorPtrType;
		variable status    : FILE_OPEN_STATUS := status_error;

		procedure create(
			fileName        : in  string;
			numberOfFrames  : in  natural := 1
		) is
			variable statusV : FILE_OPEN_STATUS;
		begin
			numFrames := numberOfFrames;
			frames := new lineVector(numFrames - 1 downto 0);
			file_open(statusV, outputFile, fileName, write_mode);
			status := statusV;
			if statusV = OPEN_OK then
				-- write PCAP file header
				--- magic number
				write(outputFile, character'val(16#D4#));
				write(outputFile, character'val(16#C3#));
				write(outputFile, character'val(16#B2#));
				write(outputFile, character'val(16#A1#));
				--- major version number
				write(outputFile, character'val(16#02#));
				write(outputFile, character'val(16#00#));
				--- minor version number
				write(outputFile, character'val(16#04#));
				write(outputFile, character'val(16#00#));
				--- GMT to local correction
				write(outputFile, character'val(16#00#));
				write(outputFile, character'val(16#00#));
				write(outputFile, character'val(16#00#));
				write(outputFile, character'val(16#00#));
				--- accuracy of timestamps
				write(outputFile, character'val(16#00#));
				write(outputFile, character'val(16#00#));
				write(outputFile, character'val(16#00#));
				write(outputFile, character'val(16#00#));
				--- max length of captured packets
				write(outputFile, character'val(16#FF#));
				write(outputFile, character'val(16#FF#));
				write(outputFile, character'val(16#00#));
				write(outputFile, character'val(16#00#));
				--- data link type
				write(outputFile, character'val(16#01#));
				write(outputFile, character'val(16#00#));
				write(outputFile, character'val(16#00#));
				write(outputFile, character'val(16#00#));
			end if;
		end create;

		procedure startFrame(
			frameNumber : in  natural := 0
		) is
		begin
			assert frameNumber < numFrames
				report "startFrame: frameNumber " & integer'image(frameNumber) & " not allowed"
				severity FAILURE;
			if frames(frameNumber) /= NULL then
				deallocate(frames(frameNumber));
			end if;
		end startFrame;

		procedure endFrame(
			frameNumber : in  natural := 0
		) is
			variable pcapLength  : unsigned(31 downto 0);
			variable timestampS  : natural;
			variable timestampUS : natural;
			variable tmp         : unsigned(31 downto 0);
		begin
			assert frameNumber < numFrames
				report "endFrame: frameNumber " & integer'image(frameNumber) & " not allowed"
				severity FAILURE;
			-- pcap frame header
			--- timestamp seconds
			timestampS := now/(1 sec);
			tmp := to_unsigned(timestampS, 32);
			-- tmp := to_unsigned(1338882754, 32);
			write(outputFile, character'val(to_integer(tmp(7 downto 0))));
			write(outputFile, character'val(to_integer(tmp(15 downto 8))));
			write(outputFile, character'val(to_integer(tmp(23 downto 16))));
			write(outputFile, character'val(to_integer(tmp(31 downto 24))));
			--- timestamp microseconds
			timestampUS := (now - (1 sec)*timestampS)/(1 us);
			tmp := to_unsigned(timestampUS, 32);
			write(outputFile, character'val(to_integer(tmp(7 downto 0))));
			write(outputFile, character'val(to_integer(tmp(15 downto 8))));
			write(outputFile, character'val(to_integer(tmp(23 downto 16))));
			write(outputFile, character'val(to_integer(tmp(31 downto 24))));
			--- incl_len
			pcapLength := to_unsigned(frames(frameNumber)'length, 32);
			write(outputFile, character'val(to_integer(pcapLength(7 downto 0))));
			write(outputFile, character'val(to_integer(pcapLength(15 downto 8))));
			write(outputFile, character'val(to_integer(pcapLength(23 downto 16))));
			write(outputFile, character'val(to_integer(pcapLength(31 downto 24))));
			--- orig_len (= incl_len)
			write(outputFile, character'val(to_integer(pcapLength(7 downto 0))));
			write(outputFile, character'val(to_integer(pcapLength(15 downto 8))));
			write(outputFile, character'val(to_integer(pcapLength(23 downto 16))));
			write(outputFile, character'val(to_integer(pcapLength(31 downto 24))));
			-- pcap frame data
			for idx in frames(frameNumber)'range loop
				write(outputFile, frames(frameNumber)(idx));
			end loop;
			deallocate(frames(frameNumber));
		end endFrame;

		procedure push(
			data        : in  std_logic_vector(7 downto 0);
			frameNumber : in  natural := 0
		) is
		begin
			push(to_integer(unsigned(data)));
		end push;

		procedure push(
			data        : in  integer range 0 to 255;
			frameNumber : in  natural := 0
		) is
		begin
			assert frameNumber < numFrames
				report "push: frameNumber " & integer'image(frameNumber) & " not allowed"
				severity FAILURE;
			write(frames(frameNumber), character'val(data));
		end push;

		procedure close is
		begin
			deallocate(frames);
			file_close(outputFile);
		end close;

		procedure dump(etherPacket : inout etherPacketType) is
		begin
			startFrame;
			for i in 0 to etherPacket.getLength - 1 loop
				push(etherPacket.getByte(i));
			end loop;
			endFrame;
		end dump;

	end protected body pcapFileType;

end package body;
