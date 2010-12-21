#!/usr/bin/expect -f
#!/bin/sh

# Copyright (C) 2008  Antoine Mercadal
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

set arguments [lindex $argv 0]
set password [lindex $argv 1]

eval spawn $arguments

match_max 100000

set timeout 1
#expect  "*yes/no*" {send "yes\r"; exp_continue};

set timeout 30
expect {
		"?sh: Error*" {puts "CONNECTION_ERROR"; exit};
		"*yes/no*" {send "yes\r"; exp_continue};
		"*Could not resolve hostname*" {puts "CONNECTION_REFUSED"; exit};
		"*Operation timed out*" {puts "CONNECTION_REFUSED"; exit};
		"*Connection refused*" {puts "CONNECTION_REFUSED"; exit};
		"*?assword:*" {	send "$password\r"; set timeout 4;
						expect "*?assword:*" {puts "WRONG_PASSWORD"; exit;}
					  };
}

puts "CONNECTED";
set timeout -1
expect eof;

