/* 
	khi su dung module i2c de dieu khien lcd o che do 4-bit
	thi khuon dang du lieu truyen cho i2c se co dang sau:
		<BL> <EN> <RW> <RS> <B3> <B2> <B1> <B0>
		BL: backlight (0: off, 1: on)
		EN: enable
		RW: read/write (0: write, 1: read)
		RS: register select (0: command, 1: data)
		B3, B2, B1, B0: 4 bit du lieu

	de gui mot lenh 8 bit cho lcd thong thuong ta phai gui 4 lan (vi can phai tao xung enable)
		1. gui 4 bit cao, voi EN = 1: : 1 1 0 0 <B7> <B6> <B5> <B4>
		2. gui 4 bit cao, voi EN = 0: : 1 0 0 0 <B7> <B6> <B5> <B4>
		3. gui 4 bit thap, voi EN = 1: : 1 1 0 0 <B3> <B2> <B1> <B0>
		4. gui 4 bit thap, voi EN = 0: : 1 0 0 0 <B3> <B2> <B1> <B0>

	de gui 8 bit du lieu cho lcd ta cung phai lam tuong tu nhung de RS = 1

	trong file nay se chua cac chu so hexa can phai gui cho module i2c de dieu khien lcd hien thi chuoi:
	"     HQH     "
	" Hello, world!"
*/

#include <bits/stdc++.h>

using namespace std;

int cnt = 0;
int total = 0;

unsigned convert_cmd_2i2c(unsigned char command) {
	const unsigned char upper = command & 0xF0;
	const unsigned char lower = (command << 4) & 0xF0;

	const unsigned char en = 0x0c;	 // BL EN RW RS  =  1 1 0 0
	const unsigned char _en = 0x08;	 // BL EN RW RS  =  1 0 0 0

	const unsigned char b3 = upper | en;
	const unsigned char b2 = upper | _en;
	const unsigned char b1 = lower | en;
	const unsigned char b0 = lower | _en;

	printf("%02x ", b3);
	printf("%02x ", b2);
	printf("%02x ", b1);
	printf("%02x ", b0);
	cnt += 4;
	total += 4;
	if (cnt % 16 == 0) {
		printf("\n");
	}
	const unsigned result = (b3 << 24) | (b2 << 16) | (b1 << 8) | b0;
	return result;
}

unsigned convert_data_2i2c(unsigned char data) {
	const unsigned char upper = data & 0xF0;
	const unsigned char lower = (data << 4) & 0xF0;

	const unsigned char en = 0x0d;	 // BL EN RW RS  =  1 1 0 1
	const unsigned char _en = 0x09;	 // BL EN RW RS  =  1 0 0 1

	const unsigned char b3 = upper | en;
	const unsigned char b2 = upper | _en;
	const unsigned char b1 = lower | en;
	const unsigned char b0 = lower | _en;

	printf("%02x ", b3);
	printf("%02x ", b2);
	printf("%02x ", b1);
	printf("%02x ", b0);
	total += 4;
	cnt += 4;
	if (cnt % 16 == 0) {
		printf("\n");
	}
	const unsigned result = (b3 << 24) | (b2 << 16) | (b1 << 8) | b0;
	return result;
}

int main() {
	freopen("i2c_lcd.txt", "w", stdout);

	// init lcd
	cnt = 0;
	cout << "\n\n// init lcd" << endl;
	convert_cmd_2i2c(0x02);	 // Return home
	convert_cmd_2i2c(0x28);	 // 4-bit mode, 2 lines, 5x7 format
	convert_cmd_2i2c(0x0C);	 // Display On, Cursor Off, Blink Off
	convert_cmd_2i2c(0x06);	 // auto increment cursor
	convert_cmd_2i2c(0x01);	 // clear display

	// move cursor to 0,0
	cnt = 0;
	cout << "\n\n// move cursor to 0,0" << endl;
	convert_cmd_2i2c(0x80);

	// send string "     HQH     "
	cnt = 0;
	cout << "\n\n// send string \"     HQH     \"" << endl;
	string s = "     HQH     ";
	for (unsigned char c : s) {
		convert_data_2i2c(c);
	}


	// move cursor to 1,0
	cnt = 0;
	cout << "\n\n// move cursor to 1,0" << endl;
	convert_cmd_2i2c(0xC0);

	// send string " Hello, world!"
	cnt = 0;
	cout << "\n\n// send string \" Hello, world!\"" << endl;
	s = " Hello, world!";
	for (unsigned char c : s) {
		convert_data_2i2c(c);
	}

	cout << "\n\n// total bytes: " << total << endl;
	return 0;
}