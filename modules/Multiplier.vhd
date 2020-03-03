library ieee;
use ieee.std_logic_1164.all;

entity half_adder is
	Port ( a,b : in std_logic;
	       sum,carry : out std_logic);
end half_adder;

architecture behavioral of half_adder is
begin
	sum <= a xor b;
	carry <= a and b;
end behavioral;

library ieee;
use ieee.std_logic_1164.all;

entity full_adder is
	Port ( a,b,c : in std_logic;
	       sum,carry : out std_logic);
end full_adder;

architecture behavioral of full_adder is
begin
	sum <= (a xor b xor c);
	carry <= (a and b) xor (c and (a xor b));
end behavioral;

library ieee;
use ieee.std_logic_1164.all;

entity dadda_mult is
	Port ( A : in std_logic_vector(15 downto 0);
	       B : in std_logic_vector(15 downto 0);
	       prod : out std_logic_vector(31 downto 0));
end dadda_mult;

architecture behavioral of dadda_mult is

component full_adder is
	Port ( a,b,c : in std_logic;
	       sum,carry : out std_logic);
end component;

component half_adder is
	Port ( a,b : in std_logic;
	       sum,carry : out std_logic);
end component;

-- stage 6 signals
signal s613,s614,s614_2,s615,s615_2,s615_3,s616,s616_2,s616_3,s617,s617_2,s618 : std_logic;
signal c613,c614,c614_2,c615,c615_2,c615_3,c616,c616_2,c616_3,c617,c617_2,c618 : std_logic;

-- stage 5 signals
signal s59,s510,s510_2,s511,s511_2,s511_3,s512,s512_2,s512_3,s512_4,s513,s513_2,s513_3,s513_4,s514,s514_2,s514_3,s514_4,s515,s515_2,s515_3,s515_4,s516,s516_2,s516_3,s516_4,s517,s517_2,s517_3,s517_4,s518,s518_2,s518_3,s518_4,s519,s519_2,s519_3,s519_4,s520,s520_2,s520_3,s521,s521_2,s522 : std_logic;
signal c59,c510,c510_2,c511,c511_2,c511_3,c512,c512_2,c512_3,c512_4,c513,c513_2,c513_3,c513_4,c514,c514_2,c514_3,c514_4,c515,c515_2,c515_3,c515_4,c516,c516_2,c516_3,c516_4,c517,c517_2,c517_3,c517_4,c518,c518_2,c518_3,c518_4,c519,c519_2,c519_3,c519_4,c520,c520_2,c520_3,c521,c521_2,c522 : std_logic;

-- stage 4 signals
signal s46,s47,s47_2,s48,s48_2,s48_3,s49,s49_2,s49_3,s410,s410_2,s410_3,s411,s411_2,s411_3,s412,s412_2,s412_3,s413,s413_2,s413_3,s414,s414_2,s414_3,s415,s415_2,s415_3,s416,s416_2,s416_3,s417,s417_2,s417_3,s418,s418_2,s418_3,s419,s419_2,s419_3,s420,s420_2,s420_3,s421,s421_2,s421_3,s422,s422_2,s422_3,s423,s423_2,s423_3,s424,s424_2,s425 : std_logic;
signal c46,c47,c47_2,c48,c48_2,c48_3,c49,c49_2,c49_3,c410,c410_2,c410_3,c411,c411_2,c411_3,c412,c412_2,c412_3,c413,c413_2,c413_3,c414,c414_2,c414_3,c415,c415_2,c415_3,c416,c416_2,c416_3,c417,c417_2,c417_3,c418,c418_2,c418_3,c419,c419_2,c419_3,c420,c420_2,c420_3,c421,c421_2,c421_3,c422,c422_2,c422_3,c423,c423_2,c423_3,c424,c424_2,c425 : std_logic;

-- stage 3 signals
signal s34,s35,s35_2,s36,s36_2,s37,s37_2,s38,s38_2,s39,s39_2,s310,s310_2,s311,s311_2,s312,s312_2,s313,s313_2,s314,s314_2,s315,s315_2,s316,s316_2,s317,s317_2,s318,s318_2,s319,s319_2,s320,s320_2,s321,s321_2,s322,s322_2,s323,s323_2,s324,s324_2,s325,s325_2,s326,s326_2,s327 : std_logic;
signal c34,c35,c35_2,c36,c36_2,c37,c37_2,c38,c38_2,c39,c39_2,c310,c310_2,c311,c311_2,c312,c312_2,c313,c313_2,c314,c314_2,c315,c315_2,c316,c316_2,c317,c317_2,c318,c318_2,c319,c319_2,c320,c320_2,c321,c321_2,c322,c322_2,c323,c323_2,c324,c324_2,c325,c325_2,c326,c326_2,c327 : std_logic;

-- stage 2 signals
signal s23,s24,s25,s26,s27,s28,s29,s210,s211,s212,s213,s214,s215,s216,s217,s218,s219,s220,s221,s222,s223,s224,s225,s226,s227,s228 : std_logic;
signal c23,c24,c25,c26,c27,c28,c29,c210,c211,c212,c213,c214,c215,c216,c217,c218,c219,c220,c221,c222,c223,c224,c225,c226,c227,c228 : std_logic;

-- stage 1 signals
signal s12,s13,s14,s15,s16,s17,s18,s19,s110,s111,s112,s113,s114,s115,s116,s117,s118,s119,s120,s121,s122,s123,s124,s125,s126,s127,s128,s129 : std_logic;
signal c12,c13,c14,c15,c16,c17,c18,c19,c110,c111,c112,c113,c114,c115,c116,c117,c118,c119,c120,c121,c122,c123,c124,c125,c126,c127,c128,c129 : std_logic;

-- stage 0 signals
signal s01,s02,s03,s04,s05,s06,s07,s08,s09,s010,s011,s012,s013,s014,s015,s016,s017,s018,s019,s020,s021,s022,s023,s024,s025,s026,s027,s028,s029,s030 : std_logic;
signal c01,c02,c03,c04,c05,c06,c07,c08,c09,c010,c011,c012,c013,c014,c015,c016,c017,c018,c019,c020,c021,c022,c023,c024,c025,c026,c027,c028,c029,c030 : std_logic;


signal p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15 : std_logic_vector(15 downto 0);

begin -- start Behavioral
process(A,B)
begin
	for i in 0 to 15 loop
		p0(i) <= A(i) and B(0);
		p1(i) <= A(i) and B(1);
		p2(i) <= A(i) and B(2);
		p3(i) <= A(i) and B(3);
		p4(i) <= A(i) and B(4);
		p5(i) <= A(i) and B(5);
		p6(i) <= A(i) and B(6);
		p7(i) <= A(i) and B(7);
		p8(i) <= A(i) and B(8);
		p9(i) <= A(i) and B(9);
		p10(i) <= A(i) and B(10);
		p11(i) <= A(i) and B(11);
		p12(i) <= A(i) and B(12);
		p13(i) <= A(i) and B(13);
		p14(i) <= A(i) and B(14);
		p15(i) <= A(i) and B(15);
	end loop;
end process;

-- 32-bit product
prod(0) <= p0(0);
prod(1) <= s01;
prod(2) <= s02;
prod(3) <= s03;
prod(4) <= s04;
prod(5) <= s05;
prod(6) <= s06;
prod(7) <= s07;
prod(8) <= s08;
prod(9) <= s09;
prod(10) <= s010;
prod(11) <= s011;
prod(12) <= s012;
prod(13) <= s013;
prod(14) <= s014;
prod(15) <= s015;
prod(16) <= s016;
prod(17) <= s017;
prod(18) <= s018;
prod(19) <= s019;
prod(20) <= s020;
prod(21) <= s021;
prod(22) <= s022;
prod(23) <= s023;
prod(24) <= s024;
prod(25) <= s025;
prod(26) <= s026;
prod(27) <= s027;
prod(28) <= s028;
prod(29) <= s029;
prod(30) <= c029;
prod(31) <= p15(15);

-- stage d6 = 13
ha613 : half_adder port map(p13(0),p12(1),s613,c613);
fa614 : full_adder port map(c613,p14(0),p13(1),s614,c614);
ha614_2 : half_adder port map(p12(2),p11(3),s614_2,c614_2);
fa615 : full_adder port map(c614_2,c614,p15(0),s615,c615);
fa615_2 : full_adder port map(p14(1),p13(2),p12(3),s615_2,c615_2);
ha615_3 : half_adder port map(p11(4),p10(5),s615_3,c615_3);
fa616 : full_adder port map(c615_3,c615_2,c615,s616,c616);
fa616_2 : full_adder port map(p15(1),p14(2),p13(3),s616_2,c616_2);
ha616_3 : half_adder port map(p12(4),p11(5),s616_3,c616_3);
fa617 : full_adder port map(c616_3,c616_2,c616,s617,c617);
fa617_2 : full_adder port map(p15(2),p14(3),p13(4),s617_2,c617_2);
fa618 : full_adder port map(c617_2,c617,p15(3),s618,c618);

-- stage d5 = 9
ha59 : half_adder port map(p9(0),p8(1),s59,c59);
fa510 : full_adder port map(c59,p10(0),p9(1),s510,c510);
ha510_2 : half_adder port map(p8(2),p7(3),s510_2,c510_2);
fa511 : full_adder port map(c510_2,c510,p11(0),s511,c511);
fa511_2 : full_adder port map(p10(1),p9(2),p8(3),s511_2,c511_2);
ha511_3 : half_adder port map(p7(4),p6(5),s511_3,c511_3);
fa512 : full_adder port map(c511_3,c511_2,c511,s512,c512);
fa512_2 : full_adder port map(p12(0),p11(1),p10(2),s512_2,c512_2);
fa512_3 : full_adder port map(p9(3),p8(4),p7(5),s512_3,c512_3);
ha512_4 : half_adder port map(p6(6),p5(7),s512_4,c512_4);
fa513 : full_adder port map(c512_4,c512_3,c512_2,s513,c513);
fa513_2 : full_adder port map(c512,p11(2),p10(3),s513_2,c513_2);
fa513_3 : full_adder port map(p9(4),p8(5),p7(6),s513_3,c513_3);
fa513_4 : full_adder port map(p6(7),p5(8),p4(9),s513_4,c513_4);
fa514 : full_adder port map(c513_4,c513_3,c513_2,s514,c514);
fa514_2 : full_adder port map(c513,p10(4),p9(5),s514_2,c514_2);
fa514_3 : full_adder port map(p8(6),p7(7),p6(8),s514_3,c514_3);
fa514_4 : full_adder port map(p5(9),p4(10),p3(11),s514_4,c514_4);
fa515 : full_adder port map(c514_4,c514_3,c514_2,s515,c515);
fa515_2 : full_adder port map(c514,p9(6),p8(7),s515_2,c515_2);
fa515_3 : full_adder port map(p7(8),p6(9),p5(10),s515_3,c515_3);
fa515_4 : full_adder port map(p4(11),p3(12),p2(13),s515_4,c515_4);
fa516 : full_adder port map(c515_4,c515_3,c515_2,s516,c516);
fa516_2 : full_adder port map(c515,p10(6),p9(7),s516_2,c516_2);
fa516_3 : full_adder port map(p8(8),p7(9),p6(10),s516_3,c516_3);
fa516_4 : full_adder port map(p5(11),p4(12),p3(13),s516_4,c516_4);
fa517 : full_adder port map(c516_4,c516_3,c516_2,s517,c517);
fa517_2 : full_adder port map(c516,p12(5),p11(6),s517_2,c517_2);
fa517_3 : full_adder port map(p10(7),p9(8),p8(9),s517_3,c517_3);
fa517_4 : full_adder port map(p7(10),p6(11),p5(12),s517_4,c517_4);
fa518 : full_adder port map(c517_4,c517_3,c517_2,s518,c518);
fa518_2 : full_adder port map(c517,p14(4),p13(5),s518_2,c518_2);
fa518_3 : full_adder port map(p12(6),p11(7),p10(8),s518_3,c518_3);
fa518_4 : full_adder port map(p9(9),p8(10),p7(11),s518_4,c518_4);
fa519 : full_adder port map(c518_4,c518_3,c518_2,s519,c519);
fa519_2 : full_adder port map(c518,c618,p15(4),s519_2,c519_2);
fa519_3 : full_adder port map(p14(5),p13(6),p12(7),s519_3,c519_3);
fa519_4 : full_adder port map(p11(8),p10(9),p9(10),s519_4,c519_4);
fa520 : full_adder port map(c519_4,c519_3,c519_2,s520,c520);
fa520_2 : full_adder port map(c519,p15(5),p14(6),s520_2,c520_2);
fa520_3 : full_adder port map(p13(7),p12(8),p11(9),s520_3,c520_3);
fa521 : full_adder port map(c520_3,c520_2,c520,s521,c521);
fa521_2 : full_adder port map(p15(6),p14(7),p13(8),s521_2,c521_2);
fa522 : full_adder port map(c521_2,c521,p15(7),s522,c522);

-- stage d4 = 6
ha46 : half_adder port map(p6(0),p5(1),s46,c46);
fa47 : full_adder port map(c46,p7(0),p6(1),s47,c47);
ha47_2 : half_adder port map(p5(2),p4(3),s47_2,c47_2);
fa48 : full_adder port map(c47_2,c47,p8(0),s48,c48);
fa48_2 : full_adder port map(p7(1),p6(2),p5(3),s48_2,c48_2);
ha48_3 : half_adder port map(p4(4),p3(5),s48_3,c48_3);
fa49 : full_adder port map(c48_3,c48_2,c48,s49,c49);
fa49_2 : full_adder port map(p7(2),p6(3),p5(4),s49_2,c49_2);
fa49_3 : full_adder port map(p4(5),p3(6),p2(7),s49_3,c49_3);
fa410 : full_adder port map(c49_3,c49_2,c49,s410,c410);
fa410_2 : full_adder port map(p6(4),p5(5),p4(6),s410_2,c410_2);
fa410_3 : full_adder port map(p3(7),p2(8),p1(9),s410_3,c410_3);
fa411 : full_adder port map(c410_3,c410_2,c410,s411,c411);
fa411_2 : full_adder port map(p5(6),p4(7),p3(8),s411_2,c411_2);
fa411_3 : full_adder port map(p2(9),p1(10),p0(11),s411_3,c411_3);
fa412 : full_adder port map(c411_3,c411_2,c411,s412,c412);
fa412_2 : full_adder port map(p4(8),p3(9),p2(10),s412_2,c412_2);
fa412_3 : full_adder port map(p1(11),p0(12),s512,s412_3,c412_3);
fa413 : full_adder port map(c412_3,c412_2,c412,s413,c413);
fa413_2 : full_adder port map(p3(10),p2(11),p1(12),s413_2,c413_2);
fa413_3 : full_adder port map(p0(13),s613,s513,s413_3,c413_3);
fa414 : full_adder port map(c413_3,c413_2,c413,s414,c414);
fa414_2 : full_adder port map(p2(12),p1(13),p0(14),s414_2,c414_2);
fa414_3 : full_adder port map(s614,s614_2,s514,s414_3,c414_3);
fa415 : full_adder port map(c414_3,c414_2,c414,s415,c415);
fa415_2 : full_adder port map(p1(14),p0(15),s615,s415_2,c415_2);
fa415_3 : full_adder port map(s615_2,s615_3,s515,s415_3,c415_3);
fa416 : full_adder port map(c415_3,c415_2,c415,s416,c416);
fa416_2 : full_adder port map(p2(14),p1(15),s616,s416_2,c416_2);
fa416_3 : full_adder port map(s616_2,s616_3,s516,s416_3,c416_3);
fa417 : full_adder port map(c416_3,c416_2,c416,s417,c417);
fa417_2 : full_adder port map(p4(13),p3(14),p2(15),s417_2,c417_2);
fa417_3 : full_adder port map(s617,s617_2,s517,s417_3,c417_3);
fa418 : full_adder port map(c417_3,c417_2,c417,s418,c418);
fa418_2 : full_adder port map(p6(12),p5(13),p4(14),s418_2,c418_2);
fa418_3 : full_adder port map(p3(15),s618,s518,s418_3,c418_3);
fa419 : full_adder port map(c418_3,c418_2,c418,s419,c419);
fa419_2 : full_adder port map(p8(11),p7(12),p6(13),s419_2,c419_2);
fa419_3 : full_adder port map(p5(14),p4(15),s519,s419_3,c419_3);
fa420 : full_adder port map(c419_3,c419_2,c419,s420,c420);
fa420_2 : full_adder port map(p10(10),p9(11),p8(12),s420_2,c420_2);
fa420_3 : full_adder port map(p7(13),p6(14),p5(15),s420_3,c420_3);
fa421 : full_adder port map(c420_3,c420_2,c420,s421,c421);
fa421_2 : full_adder port map(p12(9),p11(10),p10(11),s421_2,c421_2);
fa421_3 : full_adder port map(p9(12),p8(13),p7(14),s421_3,c421_3);
fa422 : full_adder port map(c421_3,c421_2,c421,s422,c422);
fa422_2 : full_adder port map(p14(8),p13(9),p12(10),s422_2,c422_2);
fa422_3 : full_adder port map(p11(11),p10(12),p9(13),s422_3,c422_3);
fa423 : full_adder port map(c422_3,c422_2,c422,s423,c423);
fa423_2 : full_adder port map(c522,p15(8),p14(9),s423_2,c423_2);
fa423_3 : full_adder port map(p13(10),p12(11),p11(12),s423_3,c423_3);
fa424 : full_adder port map(c423_3,c423_2,c423,s424,c424);
fa424_2 : full_adder port map(p15(9),p14(10),p13(11),s424_2,c424_2);
fa425 : full_adder port map(c424_2,c424,p15(10),s425,c425);

-- stage d3 = 4
ha34 : half_adder port map(p4(0),p3(1),s34,c34);
fa35 : full_adder port map(c34,p5(0),p4(1),s35,c35);
ha35_2 : half_adder port map(p3(2),p2(3),s35_2,c35_2);
fa36 : full_adder port map(c35_2,c35,p4(2),s36,c36);
fa36_2 : full_adder port map(p3(3),p2(4),p1(5),s36_2,c36_2);
fa37 : full_adder port map(c36_2,c36,p3(4),s37,c37);
fa37_2 : full_adder port map(p2(5),p1(6),p0(7),s37_2,c37_2);
fa38 : full_adder port map(c37_2,c37,p2(6),s38,c38);
fa38_2 : full_adder port map(p1(7),p0(8),s48,s38_2,c38_2);
fa39 : full_adder port map(c38_2,c38,p1(8),s39,c39);
fa39_2 : full_adder port map(p0(9),s59,s49,s39_2,c39_2);
fa310 : full_adder port map(c39_2,c39,p0(10),s310,c310);
fa310_2 : full_adder port map(s510,s510_2,s410,s310_2,c310_2);
fa311 : full_adder port map(c310_2,c310,s511,s311,c311);
fa311_2 : full_adder port map(s511_2,s511_3,s411,s311_2,c311_2);
fa312 : full_adder port map(c311_2,c311,s512_2,s312,c312);
fa312_2 : full_adder port map(s512_3,s512_4,s412,s312_2,c312_2);
fa313 : full_adder port map(c312_2,c312,s513_2,s313,c313);
fa313_2 : full_adder port map(s513_3,s513_4,s413,s313_2,c313_2);
fa314 : full_adder port map(c313_2,c313,s514_2,s314,c314);
fa314_2 : full_adder port map(s514_3,s514_4,s414,s314_2,c314_2);
fa315 : full_adder port map(c314_2,c314,s515_2,s315,c315);
fa315_2 : full_adder port map(s515_3,s515_4,s415,s315_2,c315_2);
fa316 : full_adder port map(c315_2,c315,s516_2,s316,c316);
fa316_2 : full_adder port map(s516_3,s516_4,s416,s316_2,c316_2);
fa317 : full_adder port map(c316_2,c316,s517_2,s317,c317);
fa317_2 : full_adder port map(s517_3,s517_4,s417,s317_2,c317_2);
fa318 : full_adder port map(c317_2,c317,s518_2,s318,c318);
fa318_2 : full_adder port map(s518_3,s518_4,s418,s318_2,c318_2);
fa319 : full_adder port map(c318_2,c318,s519_2,s319,c319);
fa319_2 : full_adder port map(s519_3,s519_4,s419,s319_2,c319_2);
fa320 : full_adder port map(c319_2,c319,s520,s320,c320);
fa320_2 : full_adder port map(s520_2,s520_3,s420,s320_2,c320_2);
fa321 : full_adder port map(c320_2,c320,p6(15),s321,c321);
fa321_2 : full_adder port map(s521,s521_2,s421,s321_2,c321_2);
fa322 : full_adder port map(c321_2,c321,p8(14),s322,c322);
fa322_2 : full_adder port map(p7(15),s522,s422,s322_2,c322_2);
fa323 : full_adder port map(c322_2,c322,p10(13),s323,c323);
fa323_2 : full_adder port map(p9(14),p8(15),s423,s323_2,c323_2);
fa324 : full_adder port map(c323_2,c323,p12(12),s324,c324);
fa324_2 : full_adder port map(p11(13),p10(14),p9(15),s324_2,c324_2);
fa325 : full_adder port map(c324_2,c324,p14(11),s325,c325);
fa325_2 : full_adder port map(p13(12),p12(13),p11(14),s325_2,c325_2);
fa326 : full_adder port map(c325_2,c325,c425,s326,c326);
fa326_2 : full_adder port map(p15(11),p14(12),p13(13),s326_2,c326_2);
fa327 : full_adder port map(c326_2,c326,p15(12),s327,c327);

-- stage d2 = 3
ha23 : half_adder port map(p3(0),p2(1),s23,c23);
fa24 : full_adder port map(c23,p2(2),p1(3),s24,c24);
fa25 : full_adder port map(c24,p1(4),p0(5),s25,c25);
fa26 : full_adder port map(c25,p0(6),s46,s26,c26);
fa27 : full_adder port map(c26,s47,s47_2,s27,c27);
fa28 : full_adder port map(c27,s48_2,s48_3,s28,c28);
fa29 : full_adder port map(c28,s49_2,s49_3,s29,c29);
fa210 : full_adder port map(c29,s410_2,s410_3,s210,c210);
fa211 : full_adder port map(c210,s411_2,s411_3,s211,c211);
fa212 : full_adder port map(c211,s412_2,s412_3,s212,c212);
fa213 : full_adder port map(c212,s413_2,s413_3,s213,c213);
fa214 : full_adder port map(c213,s414_2,s414_3,s214,c214);
fa215 : full_adder port map(c214,s415_2,s415_3,s215,c215);
fa216 : full_adder port map(c215,s416_2,s416_3,s216,c216);
fa217 : full_adder port map(c216,s417_2,s417_3,s217,c217);
fa218 : full_adder port map(c217,s418_2,s418_3,s218,c218);
fa219 : full_adder port map(c218,s419_2,s419_3,s219,c219);
fa220 : full_adder port map(c219,s420_2,s420_3,s220,c220);
fa221 : full_adder port map(c220,s421_2,s421_3,s221,c221);
fa222 : full_adder port map(c221,s422_2,s422_3,s222,c222);
fa223 : full_adder port map(c222,s423_2,s423_3,s223,c223);
fa224 : full_adder port map(c223,s424,s424_2,s224,c224);
fa225 : full_adder port map(c224,p10(15),s425,s225,c225);
fa226 : full_adder port map(c225,p12(14),p11(15),s226,c226);
fa227 : full_adder port map(c226,p14(13),p13(14),s227,c227);
fa228 : full_adder port map(c227,c327,p15(13),s228,c228);

-- stage d1 = 2
ha12 : half_adder port map(p2(0),p1(1),s12,c12);
fa13 : full_adder port map(c12,p1(2),p0(3),s13,c13);
fa14 : full_adder port map(c13,p0(4),s34,s14,c14);
fa15 : full_adder port map(c14,s35,s35_2,s15,c15);
fa16 : full_adder port map(c15,s36,s36_2,s16,c16);
fa17 : full_adder port map(c16,s37,s37_2,s17,c17);
fa18 : full_adder port map(c17,s38,s38_2,s18,c18);
fa19 : full_adder port map(c18,s39,s39_2,s19,c19);
fa110 : full_adder port map(c19,s310,s310_2,s110,c110);
fa111 : full_adder port map(c110,s311,s311_2,s111,c111);
fa112 : full_adder port map(c111,s312,s312_2,s112,c112);
fa113 : full_adder port map(c112,s313,s313_2,s113,c113);
fa114 : full_adder port map(c113,s314,s314_2,s114,c114);
fa115 : full_adder port map(c114,s315,s315_2,s115,c115);
fa116 : full_adder port map(c115,s316,s316_2,s116,c116);
fa117 : full_adder port map(c116,s317,s317_2,s117,c117);
fa118 : full_adder port map(c117,s318,s318_2,s118,c118);
fa119 : full_adder port map(c118,s319,s319_2,s119,c119);
fa120 : full_adder port map(c119,s320,s320_2,s120,c120);
fa121 : full_adder port map(c120,s321,s321_2,s121,c121);
fa122 : full_adder port map(c121,s322,s322_2,s122,c122);
fa123 : full_adder port map(c122,s323,s323_2,s123,c123);
fa124 : full_adder port map(c123,s324,s324_2,s124,c124);
fa125 : full_adder port map(c124,s325,s325_2,s125,c125);
fa126 : full_adder port map(c125,s326,s326_2,s126,c126);
fa127 : full_adder port map(c126,p12(15),s327,s127,c127);
fa128 : full_adder port map(c127,p14(14),p13(15),s128,c128);
fa129 : full_adder port map(c128,c228,p15(14),s129,c129);

-- stage 0
ha01 : half_adder port map(p1(0),p0(1),s01,c01);
fa02 : full_adder port map(c01,p0(2),s12,s02,c02);
fa03 : full_adder port map(c02,s23,s13,s03,c03);
fa04 : full_adder port map(c03,s24,s14,s04,c04);
fa05 : full_adder port map(c04,s25,s15,s05,c05);
fa06 : full_adder port map(c05,s26,s16,s06,c06);
fa07 : full_adder port map(c06,s27,s17,s07,c07);
fa08 : full_adder port map(c07,s28,s18,s08,c08);
fa09 : full_adder port map(c08,s29,s19,s09,c09);
fa010 : full_adder port map(c09,s210,s110,s010,c010);
fa011 : full_adder port map(c010,s211,s111,s011,c011);
fa012 : full_adder port map(c011,s212,s112,s012,c012);
fa013 : full_adder port map(c012,s213,s113,s013,c013);
fa014 : full_adder port map(c013,s214,s114,s014,c014);
fa015 : full_adder port map(c014,s215,s115,s015,c015);
fa016 : full_adder port map(c015,s216,s116,s016,c016);
fa017 : full_adder port map(c016,s217,s117,s017,c017);
fa018 : full_adder port map(c017,s218,s118,s018,c018);
fa019 : full_adder port map(c018,s219,s119,s019,c019);
fa020 : full_adder port map(c019,s220,s120,s020,c020);
fa021 : full_adder port map(c020,s221,s121,s021,c021);
fa022 : full_adder port map(c021,s222,s122,s022,c022);
fa023 : full_adder port map(c022,s223,s123,s023,c023);
fa024 : full_adder port map(c023,s224,s124,s024,c024);
fa025 : full_adder port map(c024,s225,s125,s025,c025);
fa026 : full_adder port map(c025,s226,s126,s026,c026);
fa027 : full_adder port map(c026,s227,s127,s027,c027);
fa028 : full_adder port map(c027,s228,s128,s028,c028);
fa029 : full_adder port map(c028,p14(15),s129,s029,c029);
--ha030 : half_adder port map(c029,p15(15),s030,c030);
-- end dadda
end behavioral;
