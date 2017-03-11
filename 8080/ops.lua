-- Actual implementation of OPs.
-- Good god, this is... huge.
-- Luckily, it is generated.

local band, bor, bxor, rshift, lshift

-- Helpers
local function a8(x)
	return band(a, 0xFF)
end

local function pair(X, Y)
	return bor(lshift(X, 8), Y)
end

local function spair(s, Xn, Yn, res)
	s[Xn] = rshift(band(res, 0xFF00), 8)
	s[Yn] = band(res, 0xFF)
	s.cy = (band(res, 0xFFFF0000) > 0)
end

-- Parity is counting the number of set bits.
-- If the number of set bits is odd, it will return true.
-- If the number bits is even, it will return false.
local function parity(x, size)
	local p = 0
	x = band(x, lshift(1, size) - 1)
	for i=0, size do
		if band(x, 1) ~= 0 then
			p = p + 1
		end
		x = rshift(x, 1)
	end
	return band(p, 1) == 0	
end

local function flaghandle(inst, res, nocy)
	if not nocy then inst.cy = (res > 0xFF) end
	res = band(res, 0xFF)
	inst.z = (res == 0) -- is zero
	inst.s = (band(res, 0x80) ~= 0) -- sign flag, if bit 7 set
	inst.p = parity(res)
	return res
end

local function flaghandlency(inst, res)
	res = band(res, 0xFF)
	inst.z = (res == 0) -- is zero
	inst.s = (band(res, 0x80) ~= 0) -- sign flag, if bit 7 set
	inst.p = parity(res)
	return res
end

-- OPS
local ops = {
	[0x00] = function(s)  end, -- NOP
	[0x01] = function(s, b2, b3) s.B = b3 s.C = b2 end, -- LXI B,D16
	[0x02] = function(s) s:setb(pair(s.B, s.C), s.A) end, -- STAX B
	[0x03] = function(s) local t = s.C + 1 if a8(t) == 0 then B = a8(B + 1) end s.C = t end, -- INX B
	[0x04] = function(s) s.B = flaghandle(s, s.B + 1) end, -- INR B
	[0x05] = function(s) s.B = flaghandle(s, s.B - 1) end, -- DCR B
	[0x06] = function(s, b) s.B = b end, -- MVI B, D8
	-- Missing 0x07: RLC
	[0x08] = function(s)  end, -- NOP
	[0x09] = function(s) spair(s, 'H', 'L', pair(s.H, s.L) + pair(s.B, s.C)) end, -- DAD B
	[0x0a] = function(s) s.A = s:getb(pair(s.B, s.C)) end, -- LDAX B
	[0x0b] = function(s) local t = s.C - 1 if a8(t) == 0xFF then B = a8(B - 1) end s.C = t end, -- DCX B
	[0x0c] = function(s) s.C = flaghandle(s, s.C + 1) end, -- INR C
	[0x0d] = function(s) s.C = flaghandle(s, s.C - 1) end, -- DCR C
	[0x0e] = function(s, b) s.C = b end, -- MVI C,D8
	-- Missing 0x0f: RRC
	[0x10] = function(s)  end, -- NOP
	[0x11] = function(s, b2, b3) s.D = b3 s.E = b2 end, -- LXI D,D16
	[0x12] = function(s) s:setb(pair(s.D, s.E), s.A) end, -- STAX D
	[0x13] = function(s) local t = s.E + 1 if a8(t) == 0 then D = a8(D + 1) end s.E = t end, -- INX D
	[0x14] = function(s) s.D = flaghandle(s, s.D + 1) end, -- INR D
	[0x15] = function(s) s.D = flaghandle(s, s.D - 1) end, -- DCR D
	[0x16] = function(s, b) s.D = b end, -- MVI D, D8
	-- Missing 0x17: RAL
	[0x18] = function(s)  end, -- NOP
	[0x19] = function(s) spair(s, 'H', 'L', pair(s.H, s.L) + pair(s.D, s.E)) end, -- DAD D
	[0x1a] = function(s) s.A = s:getb(pair(s.D, s.E)) end, -- LDAX D
	[0x1b] = function(s) local t = s.E - 1 if a8(t) == 0xFF then D = a8(D - 1) end s.E = t end, -- DCX D
	[0x1c] = function(s) s.E = flaghandle(s, s.E + 1) end, -- INR E
	[0x1d] = function(s) s.E = flaghandle(s, s.E - 1) end, -- DCR E
	[0x1e] = function(s, b) s.E = b end, -- MVI E,D8
	-- Missing 0x1f: RAR
	[0x20] = function(s)  end, -- NOP
	[0x21] = function(s, b2, b3) s.H = b3 s.L = b2 end, -- LXI H,D16
	-- Missing 0x22: SHLD adr
	[0x23] = function(s) local t = s.L + 1 if a8(t) == 0 then H = a8(H + 1) end s.L = t end, -- INX H
	[0x24] = function(s) s.H = flaghandle(s, s.H + 1) end, -- INR H
	[0x25] = function(s) s.H = flaghandle(s, s.H - 1) end, -- DCR H
	[0x26] = function(s, b) s.H = b end, -- MVI H,D8
	-- Missing 0x27: DAA
	[0x28] = function(s)  end, -- NOP
	[0x29] = function(s) spair(s, 'H', 'L', pair(s.H, s.L) + pair(s.H, s.L)) end, -- DAD H
	-- Missing 0x2a: LHLD adr
	[0x2b] = function(s) local t = s.L - 1 if a8(t) == 0xFF then H = a8(H - 1) end s.L = t end, -- DCX H
	[0x2c] = function(s) s.L = flaghandle(s, s.L + 1) end, -- INR L
	[0x2d] = function(s) s.L = flaghandle(s, s.L - 1) end, -- DCR L
	[0x2e] = function(s, b) s.L = b end, -- MVI L, D8
	-- Missing 0x2f: CMA
	[0x30] = function(s)  end, -- NOP
	[0x31] = function(s, b2, b3) s.SP = pair(b3, b2) end, -- LXI SP, D16
	-- Missing 0x32: STA adr
	[0x33] = function(s) local t = s.SP + 1 if a8(t) == 0 then SP = a8(SP + 1) end s.SP = t end, -- INX SP
	[0x34] = function(s) local loc = pair(s.H, s.L) s:setb(loc, flaghandlency(s, s:getb(loc) + 1)) end, -- INR M
	[0x35] = function(s) local loc = pair(s.H, s.L) s:setb(loc, flaghandlency(s, s:getb(loc) - 1)) end, -- DCR M
	[0x36] = function(s) s:setb(pair(s.H, s.L), b) end, -- MVI M,D8
	-- Missing 0x37: STC
	[0x38] = function(s)  end, -- NOP
	[0x39] = function(s) spair(s, 'H', 'L', pair(s.H, s.L) + s.SP) end, -- DAD SP
	-- Missing 0x3a: LDA adr
	[0x3b] = function(s) local t = s.SP - 1 if a8(t) == 0xFF then SP = a8(SP - 1) end s.SP = t end, -- DCX SP
	[0x3c] = function(s) s.A = flaghandle(s, s.A + 1) end, -- INR A
	[0x3d] = function(s) s.A = flaghandle(s, s.A - 1) end, -- DCR A
	[0x3e] = function(s, b) s.A = b end, -- MVI A,D8
	-- Missing 0x3f: CMC
	[0x40] = function(s) s.B = s.B end, -- MOV B,B
	[0x41] = function(s) s.B = s.C end, -- MOV B,C
	[0x42] = function(s) s.B = s.D end, -- MOV B,D
	[0x43] = function(s) s.B = s.E end, -- MOV B,E
	[0x44] = function(s) s.B = s.H end, -- MOV B,H
	[0x45] = function(s) s.B = s.L end, -- MOV B,L
	[0x46] = function(s) s.B = s:getb(pair(s.H, s.L)) end, -- MOV B,M
	[0x47] = function(s) s.B = s.A end, -- MOV B,A
	[0x48] = function(s) s.C = s.B end, -- MOV C,B
	[0x49] = function(s) s.C = s.C end, -- MOV C,C
	[0x4a] = function(s) s.C = s.D end, -- MOV C,D
	[0x4b] = function(s) s.C = s.E end, -- MOV C,E
	[0x4c] = function(s) s.C = s.H end, -- MOV C,H
	[0x4d] = function(s) s.C = s.L end, -- MOV C,L
	[0x4e] = function(s) s.C = s:getb(pair(s.H, s.L)) end, -- MOV C,M
	[0x4f] = function(s) s.C = s.A end, -- MOV C,A
	[0x50] = function(s) s.D = s.B end, -- MOV D,B
	[0x51] = function(s) s.D = s.C end, -- MOV D,C
	[0x52] = function(s) s.D = s.D end, -- MOV D,D
	[0x53] = function(s) s.D = s.E end, -- MOV D,E
	[0x54] = function(s) s.D = s.H end, -- MOV D,H
	[0x55] = function(s) s.D = s.L end, -- MOV D,L
	[0x56] = function(s) s.D = s:getb(pair(s.H, s.L)) end, -- MOV D,M
	[0x57] = function(s) s.D = s.A end, -- MOV D,A
	[0x58] = function(s) s.E = s.B end, -- MOV E,B
	[0x59] = function(s) s.E = s.C end, -- MOV E,C
	[0x5a] = function(s) s.E = s.D end, -- MOV E,D
	[0x5b] = function(s) s.E = s.E end, -- MOV E,E
	[0x5c] = function(s) s.E = s.H end, -- MOV E,H
	[0x5d] = function(s) s.E = s.L end, -- MOV E,L
	[0x5e] = function(s) s.E = s:getb(pair(s.H, s.L)) end, -- MOV E,M
	[0x5f] = function(s) s.E = s.A end, -- MOV E,A
	[0x60] = function(s) s.H = s.B end, -- MOV H,B
	[0x61] = function(s) s.H = s.C end, -- MOV H,C
	[0x62] = function(s) s.H = s.D end, -- MOV H,D
	[0x63] = function(s) s.H = s.E end, -- MOV H,E
	[0x64] = function(s) s.H = s.H end, -- MOV H,H
	[0x65] = function(s) s.H = s.L end, -- MOV H,L
	[0x66] = function(s) s.H = s:getb(pair(s.H, s.L)) end, -- MOV H,M
	[0x67] = function(s) s.H = s.A end, -- MOV H,A
	[0x68] = function(s) s.L = s.B end, -- MOV L,B
	[0x69] = function(s) s.L = s.C end, -- MOV L,C
	[0x6a] = function(s) s.L = s.D end, -- MOV L,D
	[0x6b] = function(s) s.L = s.E end, -- MOV L,E
	[0x6c] = function(s) s.L = s.H end, -- MOV L,H
	[0x6d] = function(s) s.L = s.L end, -- MOV L,L
	[0x6e] = function(s) s.L = s:getb(pair(s.H, s.L)) end, -- MOV L,M
	[0x6f] = function(s) s.L = s.A end, -- MOV L,A
	[0x70] = function(s) s:setb(pair(s.H, s.L), s.B) end, -- MOV M,B
	[0x71] = function(s) s:setb(pair(s.H, s.L), s.C) end, -- MOV M,C
	[0x72] = function(s) s:setb(pair(s.H, s.L), s.D) end, -- MOV M,D
	[0x73] = function(s) s:setb(pair(s.H, s.L), s.E) end, -- MOV M,E
	[0x74] = function(s) s:setb(pair(s.H, s.L), s.H) end, -- MOV M,H
	[0x75] = function(s) s:setb(pair(s.H, s.L), s.L) end, -- MOV M,L
	-- Missing 0x76: HLT
	[0x77] = function(s) s:setb(pair(s.H, s.L), s.A) end, -- MOV M,A
	[0x78] = function(s) s.A = s.B end, -- MOV A,B
	[0x79] = function(s) s.A = s.C end, -- MOV A,C
	[0x7a] = function(s) s.A = s.D end, -- MOV A,D
	[0x7b] = function(s) s.A = s.E end, -- MOV A,E
	[0x7c] = function(s) s.A = s.H end, -- MOV A,H
	[0x7d] = function(s) s.A = s.L end, -- MOV A,L
	[0x7e] = function(s) s.A = s:getb(pair(s.H, s.L)) end, -- MOV A,M
	[0x7f] = function(s) s.A = s.A end, -- MOV A,A
	[0x80] = function(s) s.A = flaghandle(s, s.A + s.B) end, -- ADD B
	[0x81] = function(s) s.A = flaghandle(s, s.A + s.C) end, -- ADD C
	[0x82] = function(s) s.A = flaghandle(s, s.A + s.D) end, -- ADD D
	[0x83] = function(s) s.A = flaghandle(s, s.A + s.E) end, -- ADD E
	[0x84] = function(s) s.A = flaghandle(s, s.A + s.H) end, -- ADD H
	[0x85] = function(s) s.A = flaghandle(s, s.A + s.L) end, -- ADD L
	[0x86] = function(s) s.A = flaghandle(s, s.A + s:getb(pair(s.H, s.L))) end, -- ADD M
	[0x87] = function(s) s.A = flaghandle(s, s.A + s.A) end, -- ADD A
	[0x88] = function(s) s.A = flaghandle(s, s.A + s.B + (s.cy and 1 or 0)) end, -- ADC B
	[0x89] = function(s) s.A = flaghandle(s, s.A + s.C + (s.cy and 1 or 0)) end, -- ADC C
	[0x8a] = function(s) s.A = flaghandle(s, s.A + s.D + (s.cy and 1 or 0)) end, -- ADC D
	[0x8b] = function(s) s.A = flaghandle(s, s.A + s.E + (s.cy and 1 or 0)) end, -- ADC E
	[0x8c] = function(s) s.A = flaghandle(s, s.A + s.H + (s.cy and 1 or 0)) end, -- ADC H
	[0x8d] = function(s) s.A = flaghandle(s, s.A + s.L + (s.cy and 1 or 0)) end, -- ADC L
	[0x8e] = function(s) s.A = flaghandle(s, s.A + s:getb(pair(s.H, s.L)) + (s.cy and 1 or 0)) end, -- ADC M
	[0x8f] = function(s) s.A = flaghandle(s, s.A + s.A + (s.cy and 1 or 0)) end, -- ADC A
	[0x90] = function(s) s.A = flaghandle(s, s.A - s.B) end, -- SUB B
	[0x91] = function(s) s.A = flaghandle(s, s.A - s.C) end, -- SUB C
	[0x92] = function(s) s.A = flaghandle(s, s.A - s.D) end, -- SUB D
	[0x93] = function(s) s.A = flaghandle(s, s.A - s.E) end, -- SUB E
	[0x94] = function(s) s.A = flaghandle(s, s.A - s.H) end, -- SUB H
	[0x95] = function(s) s.A = flaghandle(s, s.A - s.L) end, -- SUB L
	[0x96] = function(s) s.A = flaghandle(s, s.A - s:getb(pair(s.H, s.L))) end, -- SUB M
	[0x97] = function(s) s.A = flaghandle(s, s.A - s.A) end, -- SUB A
	[0x98] = function(s) s.A = flaghandle(s, s.A - s.B - (s.cy and 1 or 0)) end, -- SBB B
	[0x99] = function(s) s.A = flaghandle(s, s.A - s.C - (s.cy and 1 or 0)) end, -- SBB C
	[0x9a] = function(s) s.A = flaghandle(s, s.A - s.D - (s.cy and 1 or 0)) end, -- SBB D
	[0x9b] = function(s) s.A = flaghandle(s, s.A - s.E - (s.cy and 1 or 0)) end, -- SBB E
	[0x9c] = function(s) s.A = flaghandle(s, s.A - s.H - (s.cy and 1 or 0)) end, -- SBB H
	[0x9d] = function(s) s.A = flaghandle(s, s.A - s.L - (s.cy and 1 or 0)) end, -- SBB L
	[0x9e] = function(s) s.A = flaghandle(s, s.A - s:getb(pair(s.H, s.L)) - (s.cy and 1 or 0)) end, -- SBB M
	[0x9f] = function(s) s.A = flaghandle(s, s.A - s.A - (s.cy and 1 or 0)) end, -- SBB A
	[0xa0] = function(s) s.A = flaghandle(s, band(s.A, s.B)) end, -- ANA B
	[0xa1] = function(s) s.A = flaghandle(s, band(s.A, s.C)) end, -- ANA C
	[0xa2] = function(s) s.A = flaghandle(s, band(s.A, s.D)) end, -- ANA D
	[0xa3] = function(s) s.A = flaghandle(s, band(s.A, s.E)) end, -- ANA E
	[0xa4] = function(s) s.A = flaghandle(s, band(s.A, s.H)) end, -- ANA H
	[0xa5] = function(s) s.A = flaghandle(s, band(s.A, s.L)) end, -- ANA L
	[0xa6] = function(s) s.A = flaghandle(s, band(s.A, s:getb(pair(s.H, s.L)))) end, -- ANA M
	[0xa7] = function(s) s.A = flaghandle(s, band(s.A, s.A)) end, -- ANA A
	[0xa8] = function(s) s.A = flaghandle(s, bxor(s.A, s.B)) end, -- XRA B
	[0xa9] = function(s) s.A = flaghandle(s, bxor(s.A, s.C)) end, -- XRA C
	[0xaa] = function(s) s.A = flaghandle(s, bxor(s.A, s.D)) end, -- XRA D
	[0xab] = function(s) s.A = flaghandle(s, bxor(s.A, s.E)) end, -- XRA E
	[0xac] = function(s) s.A = flaghandle(s, bxor(s.A, s.H)) end, -- XRA H
	[0xad] = function(s) s.A = flaghandle(s, bxor(s.A, s.L)) end, -- XRA L
	[0xae] = function(s) s.A = flaghandle(s, bxor(s.A, s:getb(pair(s.H, s.L)))) end, -- XRA M
	[0xaf] = function(s) s.A = flaghandle(s, bxor(s.A, s.A)) end, -- XRA A
	[0xb0] = function(s) s.A = flaghandle(s, bor(s.A, s.B)) end, -- ORA B
	[0xb1] = function(s) s.A = flaghandle(s, bor(s.A, s.C)) end, -- ORA C
	[0xb2] = function(s) s.A = flaghandle(s, bor(s.A, s.D)) end, -- ORA D
	[0xb3] = function(s) s.A = flaghandle(s, bor(s.A, s.E)) end, -- ORA E
	[0xb4] = function(s) s.A = flaghandle(s, bor(s.A, s.H)) end, -- ORA H
	[0xb5] = function(s) s.A = flaghandle(s, bor(s.A, s.L)) end, -- ORA L
	[0xb6] = function(s) s.A = flaghandle(s, bor(s.A, s:getb(pair(s.H, s.L)))) end, -- ORA M
	[0xb7] = function(s) s.A = flaghandle(s, bor(s.A, s.A)) end, -- ORA A
	-- Missing 0xb8: CMP B
	-- Missing 0xb9: CMP C
	-- Missing 0xba: CMP D
	-- Missing 0xbb: CMP E
	-- Missing 0xbc: CMP H
	-- Missing 0xbd: CMP L
	-- Missing 0xbe: CMP M
	-- Missing 0xbf: CMP A
	-- Missing 0xc0: RNZ
	-- Missing 0xc1: POP B
	[0xc2] = function(sb2, b3) local addr = pair(B2, B3) if s.z == false then s.PC = addr - 3 end end, -- JNZ adr
	[0xc3] = function(sb2, b3) local addr = pair(B2, B3) s.PC = addr - 3 end, -- JMP adr
	-- Missing 0xc4: CNZ adr
	-- Missing 0xc5: PUSH B
	[0xc6] = function(s, b) s.A = flaghandle(s, s.A + b) end, -- ADI D8
	-- Missing 0xc7: RST 0
	-- Missing 0xc8: RZ
	-- Missing 0xc9: RET
	[0xca] = function(sb2, b3) local addr = pair(B2, B3) if s.z == true then s.PC = addr - 3 end end, -- JZ adr
	[0xcb] = function(sb2, b3) local addr = pair(B2, B3) s.PC = addr - 3 end, -- JMP adr
	-- Missing 0xcc: CZ adr
	-- Missing 0xcd: CALL adr
	-- Missing 0xce: ACI D8
	-- Missing 0xcf: RST 1
	-- Missing 0xd0: RNC
	-- Missing 0xd1: POP D
	[0xd2] = function(sb2, b3) local addr = pair(B2, B3) if s.cy == false then s.PC = addr - 3 end end, -- JNC adr
	-- Missing 0xd3: OUT D8
	-- Missing 0xd4: CNC adr
	-- Missing 0xd5: PUSH D
	[0xd6] = function(s, b) s.A = flaghandle(s, s.A - b - (s.cy and 1 or 0)) end, -- SUI D8
	-- Missing 0xd7: RST 2
	-- Missing 0xd8: RC
	-- Missing 0xd9: RET
	[0xda] = function(sb2, b3) local addr = pair(B2, B3) if s.cy == true then s.PC = addr - 3 end end, -- JC adr
	-- Missing 0xdb: IN D8
	-- Missing 0xdc: CC adr
	-- Missing 0xdd: CALL adr
	[0xde] = function(s, b) s.A = flaghandle(s, s.A - b) end, -- SBI D8
	-- Missing 0xdf: RST 3
	-- Missing 0xe0: RPO
	-- Missing 0xe1: POP H
	[0xe2] = function(sb2, b3) local addr = pair(B2, B3) if s.p == true then s.PC = addr - 3 end end, -- JPO adr
	-- Missing 0xe3: XTHL
	-- Missing 0xe4: CPO adr
	-- Missing 0xe5: PUSH H
	[0xe6] = function(s, b) s.A = flaghandle(s, band(s.A, b)) end, -- ANI D8
	-- Missing 0xe7: RST 4
	-- Missing 0xe8: RPE
	[0xe9] = function(s) s.PC = pair(s.H, s.L) - 1 end, -- PCHL
	[0xea] = function(sb2, b3) local addr = pair(B2, B3) if s.p == false then s.PC = addr - 3 end end, -- JPE adr
	-- Missing 0xeb: XCHG
	-- Missing 0xec: CPE adr
	-- Missing 0xed: CALL adr
	[0xee] = function(s, b) s.A = flaghandle(s, bxor(s.A, b)) end, -- XRI D8
	-- Missing 0xef: RST 5
	-- Missing 0xf0: RP
	-- Missing 0xf1: POP PSW
	[0xf2] = function(sb2, b3) local addr = pair(B2, B3) if s.s == true then s.PC = addr - 3 end end, -- JP adr
	-- Missing 0xf3: DI
	-- Missing 0xf4: CP adr
	-- Missing 0xf5: PUSH PSW
	[0xf6] = function(s, b) s.A = flaghandle(s, bor(s.A, b)) end, -- ORI D8
	-- Missing 0xf7: RST 6
	-- Missing 0xf8: RM
	-- Missing 0xf9: SPHL
	[0xfa] = function(sb2, b3) local addr = pair(B2, B3) if s.s == false then s.PC = addr - 3 end end, -- JM adr
	-- Missing 0xfb: EI
	-- Missing 0xfc: CM adr
	-- Missing 0xfd: CALL adr
	-- Missing 0xfe: CPI D8
	-- Missing 0xff: RST 7
}
	
return {
	inst_bitops = function(bit32)
		band, bor, bxor = bit32.band, bit32.bor, bit32.bxor
		rshift, lshift = bit32.rshift, bit32.lshift
	end,
	ops = ops
}
