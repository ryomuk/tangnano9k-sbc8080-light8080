-- light8080_ucode_pkg.vhdl -- Microcode table for light8080 CPU core.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package light8080_ucode_pkg is

  type t_rom is array (0 to 511) of std_logic_vector(31 downto 0);
  constant microcode : t_rom := (
  "00000000000000000000000000000000", -- 000
  "00000000000001001000000001000100", -- 001
  "00000000000001000000000001000100", -- 002
  "10111101101001001000000001001101", -- 003
  "10110110101001000000000001001101", -- 004
  "00100000000000000000000000000000", -- 005
  "00000000000000000000000000000000", -- 006
  "11100100000000000000000000000000", -- 007
  "00000000101010000000000000000000", -- 008
  "00000100000100000000000001010111", -- 009
  "00001000000000000000110000011001", -- 00a
  "00000100000100000000000001010111", -- 00b
  "00000000101010000000000010010111", -- 00c
  "00001000000000000000110000011100", -- 00d
  "00001000000000000000110000011111", -- 00e
  "00000100000100000000000001010111", -- 00f
  "00001000000000000000110000011111", -- 010
  "00001000000000000000110000011100", -- 011
  "00001000000000000000110000011111", -- 012
  "00000000000110001000000001010111", -- 013
  "00001000000000000000110000011111", -- 014
  "00000100000110000000000001010111", -- 015
  "00001000000000000000110000101110", -- 016
  "00001000000000000000110000100010", -- 017
  "00000100000000111000000001010111", -- 018
  "00001000000000000000110000101110", -- 019
  "00000000101000111000000010010111", -- 01a
  "00001000000000000000110000100101", -- 01b
  "00001000000000000000110000101110", -- 01c
  "10111101101001100000000001001101", -- 01d
  "10110110101001101000000001001101", -- 01e
  "00000000100000101000000001010111", -- 01f
  "00001000000000000000110000100010", -- 020
  "00000100000000100000000001010111", -- 021
  "00001000000000000000110000101110", -- 022
  "00000000101000101000000010010111", -- 023
  "10111101101001100000000001001101", -- 024
  "10111010101001101000000001001101", -- 025
  "00000000101000100000000010010111", -- 026
  "00001000000000000000110000100101", -- 027
  "00001000000000000000110000101000", -- 028
  "00000100000000111000000001010111", -- 029
  "00000000101000111000000010010111", -- 02a
  "00001000000000000000110000101011", -- 02b
  "00000000101000010000000000000000", -- 02c
  "00000000000001010000000001010111", -- 02d
  "00000000101000011000000000000000", -- 02e
  "00000000000001011000000001010111", -- 02f
  "00000000101000100000000000000000", -- 030
  "00000000000000010000000001010111", -- 031
  "00000000101000101000000000000000", -- 032
  "00000000000000011000000001010111", -- 033
  "00000000101001010000000000000000", -- 034
  "00000000000000100000000001010111", -- 035
  "00000000101001011000000000000000", -- 036
  "00000100000000101000000001010111", -- 037
  "00001000000000000000110000011111", -- 038
  "00000100011000111000001101001100", -- 039
  "00001000000000000000110000011111", -- 03a
  "00000100011000111000001101001101", -- 03b
  "00001000000000000000110000011111", -- 03c
  "00000100011000111000001101001110", -- 03d
  "00001000000000000000110000011111", -- 03e
  "00000100011000111000001101001111", -- 03f
  "00001000000000000000110000011111", -- 040
  "00000100011000111100001101000100", -- 041
  "00001000000000000000110000011111", -- 042
  "00000100011000111100001101000101", -- 043
  "00001000000000000000110000011111", -- 044
  "00000100011000111100001101000110", -- 045
  "00001000000000000000110000011111", -- 046
  "00000100011000111000001110001110", -- 047
  "00000000101010000000000000000000", -- 048
  "00000100011000111000001101001100", -- 049
  "00000000101010000000000000000000", -- 04a
  "00000100011000111000001101001101", -- 04b
  "00000000101010000000000000000000", -- 04c
  "00000100011000111000001101001110", -- 04d
  "00000000101010000000000000000000", -- 04e
  "00000100011000111000001101001111", -- 04f
  "00000000101010000000000000000000", -- 050
  "00000100011000111100001101000100", -- 051
  "00000000101010000000000000000000", -- 052
  "00000100011000111100001101000101", -- 053
  "00000000101010000000000000000000", -- 054
  "00000100011000111100001101000110", -- 055
  "00000000101010000000000000000000", -- 056
  "00000100011000111000001110001110", -- 057
  "00001000000000000000110000011001", -- 058
  "00000100011000111000001101001100", -- 059
  "00001000000000000000110000011001", -- 05a
  "00000100011000111000001101001101", -- 05b
  "00001000000000000000110000011001", -- 05c
  "00000100011000111000001101001110", -- 05d
  "00001000000000000000110000011001", -- 05e
  "00000100011000111000001101001111", -- 05f
  "00001000000000000000110000011001", -- 060
  "00000100011000111100001101000100", -- 061
  "00001000000000000000110000011001", -- 062
  "00000100011000111100001101000101", -- 063
  "00001000000000000000110000011001", -- 064
  "00000100011000111100001101000110", -- 065
  "00001000000000000000110000011001", -- 066
  "00000100011000111000001110001110", -- 067
  "10111100101100000000001001001101", -- 068
  "00000100000000000000000000000000", -- 069
  "00001000000000000000110000011001", -- 06a
  "10111100000000000000001010001101", -- 06b
  "00001000000000000000110000011100", -- 06c
  "10111100011100000000001001001111", -- 06d
  "00000100000000000000000000000000", -- 06e
  "00001000000000000000110000011001", -- 06f
  "11000000000000000000000000000000", -- 070
  "10111100011001010000001010001111", -- 071
  "00001000000000000000110000011100", -- 072
  "10111100101110001000000001001101", -- 073
  "10100100101110000000000001001101", -- 074
  "10111100011110001000000001001111", -- 075
  "10100100011110000000000001001111", -- 076
  "00000000011110001000000000000000", -- 077
  "00000000101000101000000101001100", -- 078
  "00000000011110000000000000000000", -- 079
  "00000100101000100000000101001101", -- 07a
  "00000000101000111000000010101000", -- 07b
  "00000100101000111000001101101000", -- 07c
  "00000100101000111000000101000000", -- 07d
  "00000100101000111000000101000001", -- 07e
  "00000100101000111000000101000010", -- 07f
  "00000100101000111000000101000011", -- 080
  "00000100101000111000000001000111", -- 081
  "00000100000000000000000100101100", -- 082
  "00000100000000000000000100101101", -- 083
  "00001000000000000000110000101110", -- 084
  "00000000101001100000000000000000", -- 085
  "00000000000001001000000001010111", -- 086
  "00000000101001101000000000000000", -- 087
  "00000100000001000000000001010111", -- 088
  "00000100000000000000000000000000", -- 089
  "00001000000000000000110000101110", -- 08a
  "00010000000000000000100000000101", -- 08b
  "00001000000000000000110000101110", -- 08c
  "11000000101001000000000010010111", -- 08d
  "00001000000000000000110000110100", -- 08e
  "11000000101001001000000010010111", -- 08f
  "00001000000000000000110000110100", -- 090
  "00000000101001100000000000000000", -- 091
  "00000000000001001000000001010111", -- 092
  "00000000101001101000000000000000", -- 093
  "00000100000001000000000001010111", -- 094
  "00001000000000000000110000101110", -- 095
  "00010000000000000000100000001101", -- 096
  "00001000000000000000110000111001", -- 097
  "00000000000001001000000001010111", -- 098
  "00001000000000000000110000111001", -- 099
  "00000100000001000000000001010111", -- 09a
  "00010000000000000000100000010111", -- 09b
  "11000000101001000000000010010111", -- 09c
  "00001000000000000000110000110100", -- 09d
  "11000000101001001000000010010111", -- 09e
  "00001000000000000000110000110100", -- 09f
  "11000000000001001000000001011111", -- 0a0
  "00000100000001000000000001000100", -- 0a1
  "00000000101000101000000000000000", -- 0a2
  "00000000000001001000000001010111", -- 0a3
  "00000000101000100000000000000000", -- 0a4
  "00000100000001000000000001010111", -- 0a5
  "11000000101110000000000010010111", -- 0a6
  "00001000000000000000110000110100", -- 0a7
  "11000000101110001000000010010111", -- 0a8
  "00001000000000000000110000110100", -- 0a9
  "00000100000000000000000000000000", -- 0aa
  "11000000101000111000000010010111", -- 0ab
  "00001000000000000000110000110100", -- 0ac
  "11000000000000000000000010110000", -- 0ad
  "00001000000000000000110000110100", -- 0ae
  "00000100000000000000000000000000", -- 0af
  "00001000000000000000110000111001", -- 0b0
  "00000000000110001000000001010111", -- 0b1
  "00001000000000000000110000111001", -- 0b2
  "00000100000110000000000001010111", -- 0b3
  "00001000000000000000110000111001", -- 0b4
  "00000000000000110000001101010111", -- 0b5
  "00001000000000000000110000111001", -- 0b6
  "00000100000000111000000001010111", -- 0b7
  "00001000000000000000110000111001", -- 0b8
  "00000000000001100000000001010111", -- 0b9
  "00001000000000000000110000111001", -- 0ba
  "00000000000001101000000001010111", -- 0bb
  "11000000101000100000000010010111", -- 0bc
  "00001000000000000000110000110100", -- 0bd
  "11000000101000101000000010010111", -- 0be
  "00001000000000000000110000110100", -- 0bf
  "00000000101001100000000000000000", -- 0c0
  "00000000000000101000000001010111", -- 0c1
  "00000000101001101000000000000000", -- 0c2
  "00000100000000100000000001010111", -- 0c3
  "00000000101000101000000000000000", -- 0c4
  "00000000000001111000000001010111", -- 0c5
  "00000000101000100000000000000000", -- 0c6
  "00000100000001110000000001010111", -- 0c7
  "01100100000000000000000000000000", -- 0c8
  "01000100000000000000000000000000", -- 0c9
  "00000000000001101000000001010111", -- 0ca
  "00001000000000000000110000011111", -- 0cb
  "00000000000001100000000001010111", -- 0cc
  "00000000000000000000000000000000", -- 0cd
  "00000001101001100000000000000000", -- 0ce
  "10010110101001101000000000000000", -- 0cf
  "00000100100000111000000001010111", -- 0d0
  "00000000000001101000000001010111", -- 0d1
  "00001000000000000000110000011111", -- 0d2
  "00000000000001100000000001010111", -- 0d3
  "00000000101000111000000010010111", -- 0d4
  "00000001101001100000000000000000", -- 0d5
  "10011010101001101000000000000000", -- 0d6
  "00000100000000000000000000000000", -- 0d7
  "11100100000000000000000000000000", -- 0d8
  "00000001101000101000000000000000", -- 0d9
  "00010110101000100000000000000000", -- 0da
  "00001100100001010000000001010111", -- 0db
  "00000001101000101000000000000000", -- 0dc
  "00011010101000100000000000000000", -- 0dd
  "00000100000000000000000000000000", -- 0de
  "10111101101001001000000001001101", -- 0df
  "10110110101001000000000001001101", -- 0e0
  "00001100100000000000000010010111", -- 0e1
  "00000001101001100000000000000000", -- 0e2
  "00010110101001101000000000000000", -- 0e3
  "00001100100000000000000000000000", -- 0e4
  "00000001101001100000000000000000", -- 0e5
  "00011010101001101000000000000000", -- 0e6
  "00000100000000000000000000000000", -- 0e7
  "00000001101110001000000000000000", -- 0e8
  "00010110101110000000000000000000", -- 0e9
  "00001100100000000000000000000000", -- 0ea
  "00000001101110001000000000000000", -- 0eb
  "00011010101110000000000000000000", -- 0ec
  "00000100000000000000000000000000", -- 0ed
  "10111101101001001000000001001101", -- 0ee
  "10110110101001000000000001001101", -- 0ef
  "00000000100001100000000001010111", -- 0f0
  "10111101101001001000000001001101", -- 0f1
  "10110110101001000000000001001101", -- 0f2
  "00001100100001101000000001010111", -- 0f3
  "10111100011001111000000001001111", -- 0f4
  "10100000011001110000000001001111", -- 0f5
  "00000001101001111000000000000000", -- 0f6
  "00011010101001110000000000000000", -- 0f7
  "00001100000000000000000000000000", -- 0f8
  "10111101101001111000000001001101", -- 0f9
  "10110110101001110000000001001101", -- 0fa
  "00001100100000000000000000000000", -- 0fb
  "00000100000000000000000000000000", -- 0fc
  "00000100000000000000000000000000", -- 0fd
  "00000100000000000000000000000000", -- 0fe
  "00000100000000000000000000000000", -- 0ff
  "00001000000000000000100000001001", -- 100
  "00001000000000000000000000010010", -- 101
  "00001000000000000000000000101010", -- 102
  "00001000000000000000010000110011", -- 103
  "00001000000000000000010000101000", -- 104
  "00001000000000000000010000101101", -- 105
  "00001000000000000000000000001110", -- 106
  "00001000000000000000010000111101", -- 107
  "00001000000000000000000000000000", -- 108
  "00001000000000000000010000110111", -- 109
  "00001000000000000000000000101000", -- 10a
  "00001000000000000000010000110101", -- 10b
  "00001000000000000000010000101000", -- 10c
  "00001000000000000000010000101101", -- 10d
  "00001000000000000000000000001110", -- 10e
  "00001000000000000000010000111110", -- 10f
  "00001000000000000000000000000000", -- 110
  "00001000000000000000000000010010", -- 111
  "00001000000000000000000000101010", -- 112
  "00001000000000000000010000110011", -- 113
  "00001000000000000000010000101000", -- 114
  "00001000000000000000010000101101", -- 115
  "00001000000000000000000000001110", -- 116
  "00001000000000000000010000111111", -- 117
  "00001000000000000000000000000000", -- 118
  "00001000000000000000010000110111", -- 119
  "00001000000000000000000000101000", -- 11a
  "00001000000000000000010000110101", -- 11b
  "00001000000000000000010000101000", -- 11c
  "00001000000000000000010000101101", -- 11d
  "00001000000000000000000000001110", -- 11e
  "00001000000000000000100000000000", -- 11f
  "00001000000000000000000000000000", -- 120
  "00001000000000000000000000010010", -- 121
  "00001000000000000000000000100010", -- 122
  "00001000000000000000010000110011", -- 123
  "00001000000000000000010000101000", -- 124
  "00001000000000000000010000101101", -- 125
  "00001000000000000000000000001110", -- 126
  "00001000000000000000010000111011", -- 127
  "00001000000000000000000000000000", -- 128
  "00001000000000000000010000110111", -- 129
  "00001000000000000000000000011100", -- 12a
  "00001000000000000000010000110101", -- 12b
  "00001000000000000000010000101000", -- 12c
  "00001000000000000000010000101101", -- 12d
  "00001000000000000000000000001110", -- 12e
  "00001000000000000000100000000001", -- 12f
  "00001000000000000000000000000000", -- 130
  "00001000000000000000000000010010", -- 131
  "00001000000000000000000000011001", -- 132
  "00001000000000000000010000110011", -- 133
  "00001000000000000000010000101010", -- 134
  "00001000000000000000010000101111", -- 135
  "00001000000000000000000000010000", -- 136
  "00001000000000000000100000000011", -- 137
  "00001000000000000000000000000000", -- 138
  "00001000000000000000010000110111", -- 139
  "00001000000000000000000000010110", -- 13a
  "00001000000000000000010000110101", -- 13b
  "00001000000000000000010000101000", -- 13c
  "00001000000000000000010000101101", -- 13d
  "00001000000000000000000000001110", -- 13e
  "00001000000000000000100000000010", -- 13f
  "00001000000000000000000000001000", -- 140
  "00001000000000000000000000001000", -- 141
  "00001000000000000000000000001000", -- 142
  "00001000000000000000000000001000", -- 143
  "00001000000000000000000000001000", -- 144
  "00001000000000000000000000001000", -- 145
  "00001000000000000000000000001010", -- 146
  "00001000000000000000000000001000", -- 147
  "00001000000000000000000000001000", -- 148
  "00001000000000000000000000001000", -- 149
  "00001000000000000000000000001000", -- 14a
  "00001000000000000000000000001000", -- 14b
  "00001000000000000000000000001000", -- 14c
  "00001000000000000000000000001000", -- 14d
  "00001000000000000000000000001010", -- 14e
  "00001000000000000000000000001000", -- 14f
  "00001000000000000000000000001000", -- 150
  "00001000000000000000000000001000", -- 151
  "00001000000000000000000000001000", -- 152
  "00001000000000000000000000001000", -- 153
  "00001000000000000000000000001000", -- 154
  "00001000000000000000000000001000", -- 155
  "00001000000000000000000000001010", -- 156
  "00001000000000000000000000001000", -- 157
  "00001000000000000000000000001000", -- 158
  "00001000000000000000000000001000", -- 159
  "00001000000000000000000000001000", -- 15a
  "00001000000000000000000000001000", -- 15b
  "00001000000000000000000000001000", -- 15c
  "00001000000000000000000000001000", -- 15d
  "00001000000000000000000000001010", -- 15e
  "00001000000000000000000000001000", -- 15f
  "00001000000000000000000000001000", -- 160
  "00001000000000000000000000001000", -- 161
  "00001000000000000000000000001000", -- 162
  "00001000000000000000000000001000", -- 163
  "00001000000000000000000000001000", -- 164
  "00001000000000000000000000001000", -- 165
  "00001000000000000000000000001010", -- 166
  "00001000000000000000000000001000", -- 167
  "00001000000000000000000000001000", -- 168
  "00001000000000000000000000001000", -- 169
  "00001000000000000000000000001000", -- 16a
  "00001000000000000000000000001000", -- 16b
  "00001000000000000000000000001000", -- 16c
  "00001000000000000000000000001000", -- 16d
  "00001000000000000000000000001010", -- 16e
  "00001000000000000000000000001000", -- 16f
  "00001000000000000000000000001100", -- 170
  "00001000000000000000000000001100", -- 171
  "00001000000000000000000000001100", -- 172
  "00001000000000000000000000001100", -- 173
  "00001000000000000000000000001100", -- 174
  "00001000000000000000000000001100", -- 175
  "00001000000000000000110000011000", -- 176
  "00001000000000000000000000001100", -- 177
  "00001000000000000000000000001000", -- 178
  "00001000000000000000000000001000", -- 179
  "00001000000000000000000000001000", -- 17a
  "00001000000000000000000000001000", -- 17b
  "00001000000000000000000000001000", -- 17c
  "00001000000000000000000000001000", -- 17d
  "00001000000000000000000000001010", -- 17e
  "00001000000000000000000000001000", -- 17f
  "00001000000000000000010000001000", -- 180
  "00001000000000000000010000001000", -- 181
  "00001000000000000000010000001000", -- 182
  "00001000000000000000010000001000", -- 183
  "00001000000000000000010000001000", -- 184
  "00001000000000000000010000001000", -- 185
  "00001000000000000000010000011000", -- 186
  "00001000000000000000010000001000", -- 187
  "00001000000000000000010000001010", -- 188
  "00001000000000000000010000001010", -- 189
  "00001000000000000000010000001010", -- 18a
  "00001000000000000000010000001010", -- 18b
  "00001000000000000000010000001010", -- 18c
  "00001000000000000000010000001010", -- 18d
  "00001000000000000000010000011010", -- 18e
  "00001000000000000000010000001010", -- 18f
  "00001000000000000000010000001100", -- 190
  "00001000000000000000010000001100", -- 191
  "00001000000000000000010000001100", -- 192
  "00001000000000000000010000001100", -- 193
  "00001000000000000000010000001100", -- 194
  "00001000000000000000010000001100", -- 195
  "00001000000000000000010000011100", -- 196
  "00001000000000000000010000001100", -- 197
  "00001000000000000000010000001110", -- 198
  "00001000000000000000010000001110", -- 199
  "00001000000000000000010000001110", -- 19a
  "00001000000000000000010000001110", -- 19b
  "00001000000000000000010000001110", -- 19c
  "00001000000000000000010000001110", -- 19d
  "00001000000000000000010000011110", -- 19e
  "00001000000000000000010000001110", -- 19f
  "00001000000000000000010000010000", -- 1a0
  "00001000000000000000010000010000", -- 1a1
  "00001000000000000000010000010000", -- 1a2
  "00001000000000000000010000010000", -- 1a3
  "00001000000000000000010000010000", -- 1a4
  "00001000000000000000010000010000", -- 1a5
  "00001000000000000000010000100000", -- 1a6
  "00001000000000000000010000010000", -- 1a7
  "00001000000000000000010000010010", -- 1a8
  "00001000000000000000010000010010", -- 1a9
  "00001000000000000000010000010010", -- 1aa
  "00001000000000000000010000010010", -- 1ab
  "00001000000000000000010000010010", -- 1ac
  "00001000000000000000010000010010", -- 1ad
  "00001000000000000000010000100010", -- 1ae
  "00001000000000000000010000010010", -- 1af
  "00001000000000000000010000010100", -- 1b0
  "00001000000000000000010000010100", -- 1b1
  "00001000000000000000010000010100", -- 1b2
  "00001000000000000000010000010100", -- 1b3
  "00001000000000000000010000010100", -- 1b4
  "00001000000000000000010000010100", -- 1b5
  "00001000000000000000010000100100", -- 1b6
  "00001000000000000000010000010100", -- 1b7
  "00001000000000000000010000010110", -- 1b8
  "00001000000000000000010000010110", -- 1b9
  "00001000000000000000010000010110", -- 1ba
  "00001000000000000000010000010110", -- 1bb
  "00001000000000000000010000010110", -- 1bc
  "00001000000000000000010000010110", -- 1bd
  "00001000000000000000010000100110", -- 1be
  "00001000000000000000010000010110", -- 1bf
  "00001000000000000000100000011011", -- 1c0
  "00001000000000000000100000110000", -- 1c1
  "00001000000000000000100000001010", -- 1c2
  "00001000000000000000100000000100", -- 1c3
  "00001000000000000000100000010101", -- 1c4
  "00001000000000000000100000100110", -- 1c5
  "00001000000000000000000000111000", -- 1c6
  "00001000000000000000100000011100", -- 1c7
  "00001000000000000000100000011011", -- 1c8
  "00001000000000000000100000010111", -- 1c9
  "00001000000000000000100000001010", -- 1ca
  "00001000000000000000000000000000", -- 1cb
  "00001000000000000000100000010101", -- 1cc
  "00001000000000000000100000001100", -- 1cd
  "00001000000000000000000000111010", -- 1ce
  "00001000000000000000100000011100", -- 1cf
  "00001000000000000000100000011011", -- 1d0
  "00001000000000000000100000110000", -- 1d1
  "00001000000000000000100000001010", -- 1d2
  "00001000000000000000110000010001", -- 1d3
  "00001000000000000000100000010101", -- 1d4
  "00001000000000000000100000100110", -- 1d5
  "00001000000000000000000000111100", -- 1d6
  "00001000000000000000100000011100", -- 1d7
  "00001000000000000000100000011011", -- 1d8
  "00001000000000000000000000000000", -- 1d9
  "00001000000000000000100000001010", -- 1da
  "00001000000000000000110000001010", -- 1db
  "00001000000000000000100000010101", -- 1dc
  "00001000000000000000000000000000", -- 1dd
  "00001000000000000000000000111110", -- 1de
  "00001000000000000000100000011100", -- 1df
  "00001000000000000000100000011011", -- 1e0
  "00001000000000000000100000110000", -- 1e1
  "00001000000000000000100000001010", -- 1e2
  "00001000000000000000100000111000", -- 1e3
  "00001000000000000000100000010101", -- 1e4
  "00001000000000000000100000100110", -- 1e5
  "00001000000000000000010000000000", -- 1e6
  "00001000000000000000100000011100", -- 1e7
  "00001000000000000000100000011011", -- 1e8
  "00001000000000000000100000100010", -- 1e9
  "00001000000000000000100000001010", -- 1ea
  "00001000000000000000000000101100", -- 1eb
  "00001000000000000000100000010101", -- 1ec
  "00001000000000000000000000000000", -- 1ed
  "00001000000000000000010000000010", -- 1ee
  "00001000000000000000100000011100", -- 1ef
  "00001000000000000000100000011011", -- 1f0
  "00001000000000000000100000110100", -- 1f1
  "00001000000000000000100000001010", -- 1f2
  "00001000000000000000110000001001", -- 1f3
  "00001000000000000000100000010101", -- 1f4
  "00001000000000000000100000101011", -- 1f5
  "00001000000000000000010000000100", -- 1f6
  "00001000000000000000100000011100", -- 1f7
  "00001000000000000000100000011011", -- 1f8
  "00001000000000000000110000000100", -- 1f9
  "00001000000000000000100000001010", -- 1fa
  "00001000000000000000110000001000", -- 1fb
  "00001000000000000000100000010101", -- 1fc
  "00001000000000000000000000000000", -- 1fd
  "00001000000000000000010000000110", -- 1fe
  "00001000000000000000100000011100"  -- 1ff

);
end package;
